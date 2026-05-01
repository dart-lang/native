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

// All ObjC source files are compiled with ARC enabled except these.
const arcDisabledFiles = <String>{'ref_count_test.m'};

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

    // Build native_test.c. This is an ordinary build, so we can use CBuilder.
    await CBuilder.library(
      name: 'native_test',
      assetName: 'native_test',
      sources: [
        'test/native_test/native_test.c',
        if (input.config.code.targetOS == OS.windows)
          'test/native_test/native_test.def',
      ],
    ).run(input: input, output: output, logger: logger);

    if (input.config.code.targetOS == OS.macOS) {
      final builder = await Builder.create(
        input,
        input.packageRoot.toFilePath(),
      );

      // Build swift_class_test.swift. There's no swift compilation package, so
      // we have to use a custom Builder.
      final objcTestDir = input.packageRoot.resolve('test/native_objc_test/');
      const swiftModule = 'swift_class_test';
      final swiftFile = objcTestDir.resolve('swift_class_test.swift');
      final swiftHeader = objcTestDir.resolve('swift_class_test-Swift.h');
      final swiftLib = input.outputDirectory.resolve('$swiftModule.dylib');

      await builder.buildSwift(swiftFile, swiftModule, swiftHeader, swiftLib);
      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: swiftModule,
          file: swiftLib,
          linkMode: DynamicLoadingBundled(),
        ),
      );

      // Build all the ObjC files. Some of the files have different compile
      // flags, so we need to use the custom Builder again.
      final mFiles = _findFiles(objcTestDir, '.m');
      final hFiles = _findFiles(objcTestDir, '.h');

      final objFiles = <String>[];
      for (final mFile in mFiles) {
        final filename = mFile.pathSegments.last;
        final useArc = !arcDisabledFiles.contains(filename);
        final flags = [
          '-x',
          'objective-c',
          if (useArc) '-fobjc-arc',
          '-Wno-nullability-completeness',
          if (filename.startsWith('protocol_test')) '-DDISABLE_METHOD',
        ];
        objFiles.add(await builder.buildObject(mFile, flags));
      }

      // Add dart_api_dl.c from objective_c package.
      final dartApiDl = input.packageRoot.resolve(
        '../objective_c/src/include/dart_api_dl.c',
      );
      objFiles.add(await builder.buildObject(dartApiDl, []));

      const objcAsset = 'objc_test';
      final objcLib = input.outputDirectory.resolve('$objcAsset.dylib');
      await builder.linkLib(objFiles, objcLib, ['-framework', 'Foundation']);

      output.dependencies
        ..addAll(mFiles)
        ..addAll(hFiles)
        ..add(swiftFile)
        ..add(dartApiDl);

      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: objcAsset,
          file: objcLib,
          linkMode: DynamicLoadingBundled(),
        ),
      );
    }
  });
}

List<Uri> _findFiles(Uri dir, String suffix) => Directory.fromUri(dir)
    .listSync()
    .whereType<File>()
    .map((f) => f.uri)
    .where((uri) => uri.pathSegments.last.endsWith(suffix))
    .toList();

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

  Future<String> buildObject(Uri input, List<String> flags) async {
    assert(input.toFilePath().startsWith(_rootDir));
    final relativeInput = p.relative(input.toFilePath(), from: _rootDir);
    final output = '${_tempOutDir.resolve(relativeInput).toFilePath()}.o';
    File(output).parent.createSync(recursive: true);
    await _runClang([
      ...flags,
      '-c',
      input.toFilePath(),
      '-fpic',
      '-gline-tables-only',
    ], output);
    return output;
  }

  Future<void> linkLib(List<String> objects, Uri output, List<String> flags) =>
      _runClang(['-shared', ...flags, ...objects], output.toFilePath());

  Future<void> _runClang(List<String> flags, String output) =>
      _run(_comp, [...flags, '-o', output]);

  Future<void> buildSwift(
    Uri input,
    String moduleName,
    Uri outputHeader,
    Uri outputLib,
  ) async {
    final args = [
      '-c',
      input.toFilePath(),
      '-module-name',
      moduleName,
      '-emit-library',
      '-emit-objc-header-path',
      outputHeader.toFilePath(),
      '-o',
      outputLib.toFilePath(),
    ];
    await _run('swiftc', args);
  }

  Future<void> _run(String cmd, List<String> args) async {
    final proc = await Process.run(cmd, args);
    if (proc.exitCode != 0) {
      throw Exception(
        'Command failed: $cmd ${args.join(" ")}\n'
        '${proc.stdout}\n${proc.stderr}',
      );
    }
  }
}
