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
    final codeConfig = input.config.code;

    final cFlags = codeConfig.targetOS == OS.macOS
        ? <String>[
            '-isysroot',
            sdkPath(codeConfig),
            if (codeConfig.targetArchitecture == Architecture.arm64) ...[
              '-arch',
              'arm64e',
            ] else ...[
              '-target',
              toTargetTriple(codeConfig),
            ],
            minOSVersion(codeConfig),
          ]
        : <String>[];

    // Build native_test.c. This is an ordinary build, so we can use CBuilder.
    await CBuilder.library(
      name: 'native_test',
      assetName: 'native_test',
      sources: [
        'test/native_test/native_test.c',
        if (codeConfig.targetOS == OS.windows)
          'test/native_test/native_test.def',
      ],
      flags: cFlags,
    ).run(input: input, output: output, logger: logger);

    // Build all C++ test files. Works on all platforms.
    final cppTestDir = input.packageRoot.resolve('test/native_cpp_test/');
    final cppFiles = _findFiles(cppTestDir, '.cpp')
        .map(
          (uri) => p.relative(
            uri.toFilePath(),
            from: input.packageRoot.toFilePath(),
          ),
        )
        .toList();
    await CBuilder.library(
      name: 'cpp_test',
      assetName: 'cpp_test',
      sources: cppFiles,
      language: Language.cpp,
      flags: cFlags,
    ).run(input: input, output: output, logger: logger);

    if (codeConfig.targetOS == OS.macOS) {
      final builder = await CustomBuilder.create(
        input,
        input.packageRoot.toFilePath(),
      );

      // Build swift_class_test.swift. There's no swift compilation package, so
      // we have to use a CustomBuilder.
      final objcTestDir = input.packageRoot.resolve('test/native_objc_test/');
      const swiftModule = 'swift_class_test';
      final swiftFile = objcTestDir.resolve('swift_class_test.swift');
      final swiftHeader = objcTestDir.resolve('swift_class_test-Swift.h');
      final swiftLib = input.outputDirectory.resolve('$swiftModule.dylib');

      final swiftBindingM = objcTestDir.resolve('swift_class_test_bindings.m');
      final extraObjects = <String>[];
      if (File.fromUri(swiftBindingM).existsSync()) {
        extraObjects.add(
          await builder.buildObject(swiftBindingM, [
            '-x',
            'objective-c',
            '-fobjc-arc',
            '-Wno-nullability-completeness',
          ]),
        );
        output.dependencies.add(swiftBindingM);
      }

      await builder.buildSwift(
        swiftFile,
        swiftModule,
        swiftHeader,
        swiftLib,
        extraObjects: extraObjects,
      );
      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: swiftModule,
          file: swiftLib,
          linkMode: DynamicLoadingBundled(),
        ),
      );

      // Build all the ObjC files. Some of the files have different compile
      // flags, so we need to use the CustomBuilder again.
      final mFiles = _findFiles(objcTestDir, '.m')
          .where((uri) => !uri.pathSegments.last.contains('swift_class_test'))
          .toList();
      final hFiles = _findFiles(objcTestDir, '.h');

      final objFiles = <String>[];
      for (final mFile in mFiles) {
        final useArc = !arcDisabledFiles.contains(mFile.pathSegments.last);
        objFiles.add(
          await builder.buildObject(mFile, [
            ...cFlags,
            '-x',
            'objective-c',
            if (useArc) '-fobjc-arc',
            '-Wno-nullability-completeness',
            '-DDISABLE_METHOD',
          ]),
        );
      }

      // Add dart_api_dl.c from objective_c package.
      final dartApiDl = input.packageRoot.resolve(
        '../objective_c/src/include/dart_api_dl.c',
      );
      objFiles.add(await builder.buildObject(dartApiDl, cFlags));

      const objcAsset = 'objc_test';
      final objcLib = input.outputDirectory.resolve('$objcAsset.dylib');
      await builder.linkLib(objFiles, objcLib, [
        ...cFlags,
        '-framework',
        'Foundation',
      ]);

      output.dependencies.addAll([...mFiles, ...hFiles, swiftFile, dartApiDl]);

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

String sdkPath(CodeConfig codeConfig) {
  final String target;
  if (codeConfig.targetOS == OS.iOS) {
    if (codeConfig.iOS.targetSdk == IOSSdk.iPhoneOS) {
      target = 'iphoneos';
    } else {
      target = 'iphonesimulator';
    }
  } else {
    assert(codeConfig.targetOS == OS.macOS);
    target = 'macosx';
  }
  return firstLineOfStdout('xcrun', ['--show-sdk-path', '--sdk', target]);
}

String firstLineOfStdout(String cmd, List<String> args) {
  final result = Process.runSync(cmd, args);
  if (result.exitCode != 0) {
    throw Exception(
      'Command failed: $cmd ${args.join(" ")}\n'
      '${result.stdout}\n${result.stderr}',
    );
  }
  return (result.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .first;
}

String minOSVersion(CodeConfig codeConfig) {
  if (codeConfig.targetOS == OS.iOS) {
    final targetVersion = codeConfig.iOS.targetVersion;
    return '-mios-version-min=$targetVersion';
  }
  assert(codeConfig.targetOS == OS.macOS);
  final targetVersion = codeConfig.macOS.targetVersion;
  return '-mmacos-version-min=$targetVersion';
}

String toTargetTriple(CodeConfig codeConfig) {
  final architecture = codeConfig.targetArchitecture;
  if (codeConfig.targetOS == OS.iOS) {
    return appleClangIosTargetFlags[architecture]![codeConfig.iOS.targetSdk]!;
  }
  assert(codeConfig.targetOS == OS.macOS);
  return appleClangMacosTargetFlags[architecture]!;
}

const appleClangMacosTargetFlags = {
  Architecture.arm64: 'arm64-apple-darwin',
  Architecture.x64: 'x86_64-apple-darwin',
};

const appleClangIosTargetFlags = {
  Architecture.arm64: {
    IOSSdk.iPhoneOS: 'arm64-apple-ios',
    IOSSdk.iPhoneSimulator: 'arm64-apple-ios-simulator',
  },
  Architecture.x64: {IOSSdk.iPhoneSimulator: 'x86_64-apple-ios-simulator'},
};

List<Uri> _findFiles(Uri dir, String suffix) => Directory.fromUri(dir)
    .listSync()
    .whereType<File>()
    .map((f) => f.uri)
    .where((uri) => uri.pathSegments.last.endsWith(suffix))
    .toList();

class CustomBuilder {
  final String _comp;
  final String _rootDir;
  final Uri _tempOutDir;
  final CodeConfig _codeConfig;
  CustomBuilder._(
    this._comp,
    this._rootDir,
    this._tempOutDir,
    this._codeConfig,
  );

  static Future<CustomBuilder> create(BuildInput input, String rootDir) async {
    final resolver = CompilerResolver(
      codeConfig: input.config.code,
      logger: logger,
    );
    return CustomBuilder._(
      (await resolver.resolveCompiler()).uri.toFilePath(),
      rootDir,
      input.outputDirectory.resolve('obj/'),
      input.config.code,
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
    Uri outputLib, {
    List<String> extraObjects = const [],
  }) async {
    final baseArgs = [
      '-c',
      input.toFilePath(),
      ...extraObjects,
      '-module-name',
      moduleName,
      '-emit-library',
    ];

    final String target;
    if (_codeConfig.targetOS == OS.iOS) {
      final version = _codeConfig.iOS.targetVersion;
      final arch = _codeConfig.targetArchitecture == Architecture.x64
          ? 'x86_64'
          : 'arm64';
      final sdk = _codeConfig.iOS.targetSdk == IOSSdk.iPhoneOS
          ? 'ios'
          : 'ios-simulator';
      target = '$arch-apple-$sdk$version';
    } else {
      final version = _codeConfig.macOS.targetVersion;
      final arch = _codeConfig.targetArchitecture == Architecture.x64
          ? 'x86_64'
          : 'arm64';
      target = '$arch-apple-macosx$version';
    }

    if (_codeConfig.targetOS == OS.macOS &&
        _codeConfig.targetArchitecture == Architecture.arm64) {
      final version = _codeConfig.macOS.targetVersion;
      await _run('swiftc', [
        ...baseArgs,
        '-emit-objc-header-path',
        outputHeader.toFilePath(),
        '-target',
        'arm64e-apple-macosx$version',
        '-o',
        outputLib.toFilePath(),
      ]);
    } else {
      await _run('swiftc', [
        ...baseArgs,
        '-emit-objc-header-path',
        outputHeader.toFilePath(),
        '-target',
        target,
        '-o',
        outputLib.toFilePath(),
      ]);
    }
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
