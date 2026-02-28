// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/src/cbuilder/compiler_resolver.dart';

const assetName = 'objective_c_helper.dylib';

final logger = Logger('')
  ..level = Level.INFO
  ..onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    final codeConfig = input.config.code;
    final os = codeConfig.targetOS;

    // util.c only compiles on macOS (uses macOS-specific memory functions).
    if (os != OS.macOS) {
      return;
    }

    if (codeConfig.linkModePreference == LinkModePreference.static) {
      throw UnsupportedError('LinkModePreference.static is not supported.');
    }

    final packageName = input.packageName;
    final assetPath = input.outputDirectory.resolve(assetName);
    final srcDir = Directory.fromUri(input.packageRoot.resolve('lib/src/'));
    final target = toTargetTriple(codeConfig);

    final cFiles = <String>[];
    for (final file in srcDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.c')) {
        cFiles.add(file.path);
      }
    }

    final sysroot = sdkPath(codeConfig);
    final minVersion = minOSVersion(codeConfig);
    final cFlags = <String>[
      '-isysroot',
      sysroot,
      '-target',
      target,
      minVersion,
    ];

    final builder = await Builder.create(input, input.packageRoot.toFilePath());
    final objectFiles = await Future.wait([
      for (final src in cFiles) builder.buildObject(src, cFlags),
    ]);
    await builder.linkLib(objectFiles, assetPath.toFilePath(), cFlags);

    output.dependencies.addAll(cFiles.map(Uri.file));
    output.assets.code.add(
      CodeAsset(
        package: packageName,
        name: assetName,
        file: assetPath,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  });
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
    assert(input.startsWith(_rootDir));
    final relativeInput = input.substring(_rootDir.length);
    final output = '${_tempOutDir.resolve(relativeInput).toFilePath()}.o';
    File(output).parent.createSync(recursive: true);
    await _compile([...flags, '-c', input, '-fpic', '-I', 'src'], output);
    return output;
  }

  Future<void> linkLib(
    List<String> objects,
    String output,
    List<String> flags,
  ) => _compile([
    '-shared',
    '-Wl,-encryptable',
    '-undefined',
    'dynamic_lookup',
    ...flags,
    ...objects,
  ], output);

  Future<void> _compile(List<String> flags, String output) async {
    final args = [...flags, '-o', output];
    logger.info('Running: $_comp ${args.join(" ")}');
    final proc = await Process.run(_comp, args);
    logger.info(proc.stdout);
    logger.info(proc.stderr);
    if (proc.exitCode != 0) {
      exitCode = proc.exitCode;
      throw Exception('Command failed: $_comp ${args.join(" ")}');
    }
    logger.info('Generated $output');
  }
}

String sdkPath(CodeConfig codeConfig) {
  assert(codeConfig.targetOS == OS.macOS);
  return firstLineOfStdout('xcrun', ['--show-sdk-path', '--sdk', 'macosx']);
}

String firstLineOfStdout(String cmd, List<String> args) {
  final result = Process.runSync(cmd, args);
  assert(result.exitCode == 0);
  return (result.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .first;
}

String minOSVersion(CodeConfig codeConfig) {
  assert(codeConfig.targetOS == OS.macOS);
  final targetVersion = codeConfig.macOS.targetVersion;
  return '-mmacos-version-min=$targetVersion';
}

String toTargetTriple(CodeConfig codeConfig) {
  assert(codeConfig.targetOS == OS.macOS);
  return appleClangMacosTargetFlags[codeConfig.targetArchitecture]!;
}

const appleClangMacosTargetFlags = {
  Architecture.arm64: 'arm64-apple-darwin',
  Architecture.x64: 'x86_64-apple-darwin',
};
