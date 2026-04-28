// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/cbuilder/compiler_resolver.dart';
import 'package:path/path.dart' as p;

final logger = Logger('')
  ..level = Level.INFO
  ..onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.userDefines['include_test_utils'] != true) {
      return;
    }

    if (!input.config.buildCodeAssets) {
      return;
    }

    final packageName = input.packageName;

    // 1. Build native_test
    await CBuilder.library(
      name: 'native_test',
      assetName: 'native_test',
      sources: ['test/native_test/native_test.c'],
      flags: [
        if (input.config.code.targetOS == OS.windows)
          '-Wl,/DEF:${input.packageRoot.resolve('test/native_test/native_test.def').toFilePath()}',
      ],
    ).run(input: input, output: output, logger: logger);

    if (input.config.code.targetOS == OS.macOS) {
      final builder = await Builder.create(
        input,
        input.packageRoot.toFilePath(),
      );

      // 2. Build Swift test
      final swiftFile = 'test/native_objc_test/swift_class_test.swift';
      final swiftHeader = 'test/native_objc_test/swift_class_test-Swift.h';
      final swiftLib = input.outputDirectory.resolve('swift_class_test.dylib');

      await builder.buildSwift(
        input.packageRoot.resolve(swiftFile).toFilePath(),
        input.packageRoot.resolve(swiftHeader).toFilePath(),
        swiftLib.toFilePath(),
      );
      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: 'swift_class_test',
          file: swiftLib,
          linkMode: DynamicLoadingBundled(),
        ),
      );

      // 3. Build objc_test
      final testNames = _getTestNames(
        input.packageRoot.resolve('test/native_objc_test/'),
      );
      final mFiles = <String>[];
      for (final name in testNames) {
        final mFile = 'test/native_objc_test/${name}_test.m';
        if (File.fromUri(input.packageRoot.resolve(mFile)).existsSync()) {
          mFiles.add(mFile);
        }
        final bindingMFile = 'test/native_objc_test/${name}_test_bindings.m';
        if (File.fromUri(
          input.packageRoot.resolve(bindingMFile),
        ).existsSync()) {
          mFiles.add(bindingMFile);
        }
      }

      final objFiles = <String>[];
      for (final mFile in mFiles) {
        final useArc = !mFile.endsWith('ref_count_test.m');
        objFiles.add(
          await builder
              .buildObject(input.packageRoot.resolve(mFile).toFilePath(), [
                '-x',
                'objective-c',
                if (useArc) '-fobjc-arc',
                '-Wno-nullability-completeness',
              ]),
        );
      }

      // Add dart_api_dl.c from objective_c package
      final objectiveCRoot = input.packageRoot.resolve('../objective_c/');
      objFiles.add(
        await builder.buildObject(
          objectiveCRoot.resolve('src/include/dart_api_dl.c').toFilePath(),
          [],
        ),
      );

      final objcLib = input.outputDirectory.resolve('objc_test.dylib');
      await builder.linkLib(objFiles, objcLib.toFilePath(), [
        '-framework',
        'Foundation',
      ]);

      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: 'objc_test',
          file: objcLib,
          linkMode: DynamicLoadingBundled(),
        ),
      );
    }
  });
}

List<String> _getTestNames(Uri dir) {
  const configSuffix = '_config.yaml';
  final names = <String>[];
  final directory = Directory.fromUri(dir);
  if (directory.existsSync()) {
    for (final entity in directory.listSync()) {
      final filename = entity.uri.pathSegments.last;
      if (filename.endsWith(configSuffix)) {
        names.add(filename.substring(0, filename.length - configSuffix.length));
      }
    }
  }
  return names;
}

class Builder {
  final String _comp;
  final String _rootDir;
  final Uri _tempOutDir;
  Builder._(this._comp, this._rootDir, this._tempOutDir);

  static Future<Builder> create(BuildInput input, String rootDir) async {
    final resolver = CompilerResolver(
      codeConfig: input.config.code,
      logger: logger,
    );
    return Builder._(
      (await resolver.resolveCompiler()).uri.toFilePath(),
      rootDir,
      input.outputDirectory.resolve('obj/'),
    );
  }

  Future<String> buildObject(String input, List<String> flags) async {
    final relativeInput = p.relative(input, from: _rootDir);
    final output = '${_tempOutDir.resolve(relativeInput).toFilePath()}.o';
    File(output).parent.createSync(recursive: true);
    await _compile([
      ...flags,
      '-c',
      input,
      '-fpic',
      '-gline-tables-only',
    ], output);
    return output;
  }

  Future<void> linkLib(
    List<String> objects,
    String output,
    List<String> flags,
  ) => _compile(['-shared', ...flags, ...objects], output);

  Future<void> buildSwift(
    String input,
    String outputHeader,
    String outputLib, {
    List<String> extraObjects = const [],
  }) async {
    final args = [
      '-module-name',
      'swift_class_test',
      '-emit-library',
      input,
      ...extraObjects,
      '-emit-objc-header-path',
      outputHeader,
      '-o',
      outputLib,
    ];
    final process = await Process.start('swiftc', args);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception('swiftc failed: $exitCode');
    }
  }

  Future<void> _compile(List<String> flags, String output) async {
    final args = [...flags, '-o', output];
    final proc = await Process.run(_comp, args);
    if (proc.exitCode != 0) {
      throw Exception(
        'Command failed: $_comp ${args.join(" ")}\n'
        '${proc.stdout}\n${proc.stderr}',
      );
    }
  }
}
