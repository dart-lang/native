// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// End-to-end integration tests that:
// 1. Precompile a real C library into static (.a/.lib) and dynamic
//    (.so/.dylib/.dll) binaries via `PrebuiltLibrary.buildStandalone` (once,
//    in `setUpAll`).
// 2. Serve the binaries over a local HTTP server (simulating GitHub
//    Releases), as a `good` artifact set and a `corrupt-static` artifact set
//    whose static library is not a valid archive.
// 3. Per test, create a fresh consumer package using `PrebuiltLibrary` in
//    `hook/build.dart` and `hook/link.dart` with `@RecordUse` + `@Native`,
//    with `hashes.dart` generated via `runRegenerateHashesCli`.
// 4. Run `dart run` / `dart build cli` in the fetch, build and local build
//    modes and with the different treeshake modes.
//
// Tests don't share consumer packages, hook caches, or artifacts that they
// modify, so they can run in any order and on their own.
@TestOn('linux || mac-os || windows')
@Timeout(Duration(minutes: 5))
library;

import 'dart:ffi';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:prebuilt_code_assets/prebuilt_code_assets.dart';
import 'package:prebuilt_code_assets/tools.dart';
import 'package:test/test.dart';

/// Single-quoted YAML scalar: backslashes (Windows paths) are literal, and
/// single quotes are escaped by doubling them.
String yamlString(String value) => "'${value.replaceAll("'", "''")}'";

// Only the DLL marks functions with `__declspec(dllexport)`. In a static
// library, the directive makes the linker export (and so keep) the unused
// functions of an object file that is linked for a used one.
const _cSource = '''
#if defined(_WIN32) && defined(MATH_LIB_DLL)
#define EXPORT __declspec(dllexport)
#elif defined(_WIN32)
#define EXPORT
#else
#define EXPORT __attribute__((visibility("default")))
#endif

EXPORT int math_add(int a, int b) {
  return a + b;
}

EXPORT int math_unused_multiply(int a, int b) {
  return a * b;
}
''';

const _bindings = '''
@ffi.DefaultAsset('package:math_pkg/math_pkg.dart')
library;

import 'dart:ffi' as ffi;
import 'package:meta/meta.dart' as meta;

@meta.RecordUse()
@ffi.Native<ffi.Int32 Function(ffi.Int32, ffi.Int32)>(symbol: 'math_add')
external int mathAdd(int a, int b);

@meta.RecordUse()
@ffi.Native<ffi.Int32 Function(ffi.Int32, ffi.Int32)>(
  symbol: 'math_unused_multiply',
)
external int mathUnusedMultiply(int a, int b);
''';

const _buildHook = '''
import 'package:hooks/hooks.dart';
import 'package:math_pkg/library.dart';

Future<void> main(List<String> args) async {
  await build(args, (input, output) async {
    await mathLibrary.build(input: input, output: output);
  });
}
''';

const _linkHook = '''
import 'package:hooks/hooks.dart';
import 'package:math_pkg/library.dart';

Future<void> main(List<String> args) async {
  await link(args, (input, output) async {
    await mathLibrary.link(input: input, output: output);
  });
}
''';

const _main = '''
import 'package:math_pkg/bindings.dart';

void main() {
  print('Result: \${mathAdd(20, 22)}');
}
''';

/// Artifact set whose binaries are all valid.
const _good = 'good';

/// Artifact set whose static library is not a valid archive, so that linking
/// it fails.
const _corruptStatic = 'corrupt-static';

void main() {
  late Directory workspaceDir;
  late Directory artifactsDir;
  late HttpServer server;
  late Uri serverBaseUri;

  final packageRoot = findPackageRoot('prebuilt_code_assets');
  final currentOS = OS.current;
  final currentArch = Architecture.current;
  final triple = targetTripleFor(currentOS, currentArch);
  final dylibFileName = currentOS.dylibFileName('math_lib');
  final staticFileName = currentOS.staticlibFileName('math_lib');
  final dylibAssetName = 'math_lib-$triple-$dylibFileName';
  final staticAssetName = 'math_lib-$triple-$staticFileName';
  final exeName = 'bin/main${Platform.isWindows ? '.exe' : ''}';

  Directory artifactSetDir(String artifactSet) =>
      Directory.fromUri(artifactsDir.uri.resolve('$artifactSet/'));

  PrebuiltReleaseConfig makeReleaseConfig(
    String artifactSet,
    String version,
  ) => PrebuiltReleaseConfig(
    version: version,
    fileHashes: const {},
    resolveDownloadUri: (ver, assetName) =>
        Uri.parse('$serverBaseUri/$artifactSet/$ver/$assetName'),
    resolveAssetName: (os, arch, {iosSdk, required static}) {
      final t = targetTripleFor(os, arch, iosSdk: iosSdk);
      final file = static
          ? os.staticlibFileName('math_lib')
          : os.dylibFileName('math_lib');
      return 'math_lib-$t-$file';
    },
    resolveLibraryFileName: (os, {required static}) => static
        ? os.staticlibFileName('math_lib')
        : os.dylibFileName('math_lib'),
  );

  String libraryDart(String artifactSet) =>
      '''
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:prebuilt_code_assets/prebuilt_code_assets.dart';
import 'package:record_use/record_use.dart' as record_use;

import 'hashes.dart';

const recordUseMapping = <String, String>{
  'mathAdd': 'math_add',
  'mathUnusedMultiply': 'math_unused_multiply',
};

final mathLibrary = PrebuiltLibrary(
  name: 'math_lib',
  packageName: 'math_pkg',
  assetName: 'math_pkg.dart',
  fallbackToBuildOnFetchFailure: false,
  releaseConfig: PrebuiltReleaseConfig(
    version: version,
    fileHashes: fileHashes,
    resolveDownloadUri: (ver, assetName) =>
        Uri.parse('$serverBaseUri/$artifactSet/\$ver/\$assetName'),
    resolveAssetName: (os, arch, {iosSdk, required static}) {
      final triple = targetTripleFor(os, arch, iosSdk: iosSdk);
      final file = static
          ? os.staticlibFileName('math_lib')
          : os.dylibFileName('math_lib');
      return 'math_lib-\$triple-\$file';
    },
    resolveLibraryFileName: (os, {required static}) =>
        static ? os.staticlibFileName('math_lib') : os.dylibFileName('math_lib'),
  ),
  buildFromSource: (input, output, {required static, checkoutPath}) async {
    final tempOutput = BuildOutputBuilder();
    await CBuilder.library(
      name: 'math_lib',
      assetName: 'math_pkg.dart',
      sources: const ['src/math_lib.c'],
      defines: {if (!static) 'MATH_LIB_DLL': null},
      linkModePreference: static
          ? LinkModePreference.static
          : LinkModePreference.dynamic,
    ).run(input: input, output: tempOutput);
    final built = BuildOutput(tempOutput.json);
    output.dependencies.addAll(built.dependencies);
    return built.assets.code.single.file!;
  },
  usedSymbols: SymbolsResolvers.fromRecordUseMapping(
    const record_use.Library('package:math_pkg/bindings.dart'),
    recordUseMapping,
  ),
);
''';

  String pubspec({String? buildMode, String? treeshake, String? localPath}) {
    final defines = {
      'buildMode': ?buildMode,
      'treeshake': ?treeshake,
      'localPath': ?localPath,
    };
    final buffer = StringBuffer('''
name: math_pkg
version: 0.1.0
publish_to: none

environment:
  sdk: ^3.13.0

dependencies:
  code_assets: any
  hooks: any
  meta: any
  native_toolchain_c: any
  prebuilt_code_assets:
    path: ${yamlString(packageRoot.toFilePath())}
  record_use: any

dependency_overrides:
  native_toolchain_c:
    path: ${yamlString(packageRoot.resolve('../native_toolchain_c/').toFilePath())}
''');
    if (defines.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('hooks:')
        ..writeln('  user_defines:')
        ..writeln('    math_pkg:');
      for (final MapEntry(:key, :value) in defines.entries) {
        buffer.writeln('      $key: ${yamlString(value)}');
      }
    }
    return buffer.toString();
  }

  Future<void> writeFile(Directory dir, String path, String contents) async {
    final file = File.fromUri(dir.uri.resolve(path));
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  Future<ProcessResult> runDart(Directory dir, List<String> args) =>
      Process.run(
        Platform.resolvedExecutable,
        args,
        workingDirectory: dir.path,
      );

  /// Creates a fresh consumer package that fetches from [artifactSet] with the
  /// given user-defines.
  Future<Directory> createPackage({
    String artifactSet = _good,
    String? buildMode,
    String? treeshake,
    String? localPath,
  }) async {
    final pkgDir = await workspaceDir.createTemp('math_pkg_');
    await writeFile(
      pkgDir,
      'pubspec.yaml',
      pubspec(buildMode: buildMode, treeshake: treeshake, localPath: localPath),
    );
    await writeFile(pkgDir, 'src/math_lib.c', _cSource);
    await writeFile(pkgDir, 'lib/bindings.dart', _bindings);
    await writeFile(pkgDir, 'lib/library.dart', libraryDart(artifactSet));
    await writeFile(pkgDir, 'hook/build.dart', _buildHook);
    await writeFile(pkgDir, 'hook/link.dart', _linkHook);
    await writeFile(pkgDir, 'bin/main.dart', _main);

    await runRegenerateHashesCli(
      ['0.1.0', artifactSetDir(artifactSet).path],
      defaultVersion: '0.1.0',
      releaseConfigForVersion: (version) =>
          makeReleaseConfig(artifactSet, version),
      hashesFilePath: pkgDir.uri.resolve('lib/hashes.dart').toFilePath(),
      versionFilePath: null,
      targets: [(currentOS, currentArch, null)],
    );

    // `setUpAll` already populated the pub cache.
    final pubGet = await runDart(pkgDir, ['pub', 'get', '--offline']);
    expect(pubGet.exitCode, 0, reason: '${pubGet.stdout}\n${pubGet.stderr}');
    return pkgDir;
  }

  /// Runs `dart build cli` in [pkgDir] and returns the bundle directory.
  Future<Uri> buildCli(Directory pkgDir) async {
    final outDir = Directory.fromUri(pkgDir.uri.resolve('out/'));
    final build = await runDart(pkgDir, [
      'build',
      'cli',
      '--target',
      'bin/main.dart',
      '--output',
      outDir.path,
    ]);
    expect(build.exitCode, 0, reason: '${build.stdout}\n${build.stderr}');
    return outDir.uri.resolve('bundle/');
  }

  /// Runs the executable in [bundle] and opens its bundled dynamic library.
  Future<DynamicLibrary> runBundle(Uri bundle) async {
    final result = await Process.run(bundle.resolve(exeName).toFilePath(), []);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('Result: 42'));

    final bundledDylib = File.fromUri(bundle.resolve('lib/$dylibFileName'));
    expect(bundledDylib.existsSync(), isTrue);
    final dylib = DynamicLibrary.open(bundledDylib.path);
    addTearDown(dylib.close);
    expect(dylib.providesSymbol('math_add'), isTrue);
    return dylib;
  }

  setUpAll(() async {
    workspaceDir = await Directory.systemTemp.createTemp(
      'prebuilt_code_assets_e2e_',
    );
    artifactsDir = Directory.fromUri(workspaceDir.uri.resolve('artifacts/'));

    // 1. Precompile both static and dynamic libraries using
    //    `PrebuiltLibrary.buildStandalone`.
    final precompileDir = Directory.fromUri(
      workspaceDir.uri.resolve('precompile/'),
    );
    await writeFile(precompileDir, 'src/math_lib.c', _cSource);
    final precompileSpec = PrebuiltLibrary(
      name: 'math_lib',
      packageName: 'math_pkg',
      assetName: 'math_pkg.dart',
      buildFromSource: (input, output, {required static, checkoutPath}) async {
        final tempOutput = BuildOutputBuilder();
        await CBuilder.library(
          name: 'math_lib',
          assetName: 'math_pkg.dart',
          sources: const ['src/math_lib.c'],
          defines: {if (!static) 'MATH_LIB_DLL': null},
          linkModePreference: static
              ? LinkModePreference.static
              : LinkModePreference.dynamic,
        ).run(input: input, output: tempOutput);
        final built = BuildOutput(tempOutput.json);
        return built.assets.code.single.file!;
      },
    );
    final builtDylib = await precompileSpec.buildStandalone(
      targetOS: currentOS,
      targetArchitecture: currentArch,
      static: false,
      packageRoot: precompileDir.uri,
    );
    final builtStatic = await precompileSpec.buildStandalone(
      targetOS: currentOS,
      targetArchitecture: currentArch,
      static: true,
      packageRoot: precompileDir.uri,
    );

    // 2. Lay out the artifact sets.
    for (final artifactSet in [_good, _corruptStatic]) {
      await artifactSetDir(artifactSet).create(recursive: true);
    }
    final good = artifactSetDir(_good).uri;
    final corrupt = artifactSetDir(_corruptStatic).uri;
    await File.fromUri(
      builtDylib,
    ).copy(good.resolve(dylibAssetName).toFilePath());
    await File.fromUri(
      builtStatic,
    ).copy(good.resolve(staticAssetName).toFilePath());
    await File.fromUri(
      builtDylib,
    ).copy(corrupt.resolve(dylibAssetName).toFilePath());
    await File.fromUri(
      corrupt.resolve(staticAssetName),
    ).writeAsString('not-a-valid-static-archive');

    // 3. Serve `/<artifact set>/<version>/<asset>` over a local HTTP server.
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    serverBaseUri = Uri.parse('http://127.0.0.1:${server.port}');
    server.listen((request) async {
      final segments = request.uri.pathSegments;
      final file = segments.length == 3
          ? File.fromUri(
              artifactSetDir(segments.first).uri.resolve(segments.last),
            )
          : null;
      if (file != null && file.existsSync()) {
        request.response.statusCode = 200;
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });

    // 4. Populate the pub cache, so that `createPackage` can resolve offline.
    final warmUpDir = Directory.fromUri(workspaceDir.uri.resolve('warm_up/'));
    await writeFile(warmUpDir, 'pubspec.yaml', pubspec());
    final pubGet = await runDart(warmUpDir, ['pub', 'get']);
    expect(pubGet.exitCode, 0, reason: '${pubGet.stdout}\n${pubGet.stderr}');
  });

  tearDownAll(() async {
    await server.close(force: true);
    await workspaceDir.delete(recursive: true);
  });

  test(
    'runRegenerateHashesCli generates hashes.dart for static and dynamic '
    'binaries',
    () async {
      final pkgDir = await createPackage();
      final hashesContent = await File.fromUri(
        pkgDir.uri.resolve('lib/hashes.dart'),
      ).readAsString();
      expect(hashesContent, contains(dylibAssetName));
      expect(hashesContent, contains(staticAssetName));
    },
  );

  test(
    'dart run downloads dynamic library, verifies hash, and calls FFI',
    () async {
      final pkgDir = await createPackage(buildMode: 'fetch');
      final result = await runDart(pkgDir, ['run', 'bin/main.dart']);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      expect(result.stdout, contains('Result: 42'));
    },
  );

  test(
    'dart build cli downloads static library and tree-shakes unused symbols '
    'in hook/link.dart',
    () async {
      final pkgDir = await createPackage(buildMode: 'fetch');
      final dylib = await runBundle(await buildCli(pkgDir));
      expect(
        dylib.providesSymbol('math_unused_multiply'),
        isFalse,
        reason:
            'Unused symbol math_unused_multiply must be tree-shaken by '
            'hook/link.dart',
      );
    },
  );

  test(
    'dart build cli bundles no library if the application uses none of its '
    'functions, even with treeshake: on',
    () async {
      final pkgDir = await createPackage(buildMode: 'fetch', treeshake: 'on');
      await writeFile(pkgDir, 'bin/main.dart', '''
void main() {
  print('No FFI calls');
}
''');
      final bundle = await buildCli(pkgDir);
      final result = await Process.run(
        bundle.resolve(exeName).toFilePath(),
        [],
      );
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      expect(result.stdout, contains('No FFI calls'));
      expect(
        File.fromUri(bundle.resolve('lib/$dylibFileName')).existsSync(),
        isFalse,
      );
    },
  );

  test(
    'treeshake: off bundles the dynamic library without tree-shaking',
    () async {
      final pkgDir = await createPackage(buildMode: 'fetch', treeshake: 'off');
      final dylib = await runBundle(await buildCli(pkgDir));
      expect(
        dylib.providesSymbol('math_unused_multiply'),
        isTrue,
        reason: 'treeshake: off must not strip unused symbols',
      );
    },
  );

  test(
    'treeshake: auto falls back to the prebuilt dynamic library when linking '
    'fails',
    () async {
      final pkgDir = await createPackage(
        artifactSet: _corruptStatic,
        buildMode: 'fetch',
        treeshake: 'auto',
      );
      final dylib = await runBundle(await buildCli(pkgDir));
      expect(
        dylib.providesSymbol('math_unused_multiply'),
        isTrue,
        reason:
            'Fallback prebuilt dynamic library contains all symbols '
            '(un-treeshaken)',
      );
    },
  );

  test('treeshake: on fails when linking fails', () async {
    final pkgDir = await createPackage(
      artifactSet: _corruptStatic,
      buildMode: 'fetch',
      treeshake: 'on',
    );
    final build = await runDart(pkgDir, [
      'build',
      'cli',
      '--target',
      'bin/main.dart',
      '--output',
      pkgDir.uri.resolve('out/').toFilePath(),
    ]);
    expect(
      build.exitCode,
      isNonZero,
      reason: 'treeshake: on must fail when linking fails',
    );
  });

  test('dart run in buildMode: build compiles from source', () async {
    final pkgDir = await createPackage(buildMode: 'build');
    final result = await runDart(pkgDir, ['run', 'bin/main.dart']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('Result: 42'));
  });

  test(
    'dart run in buildMode: local bundles the local dynamic library',
    () async {
      final pkgDir = await createPackage(
        buildMode: 'local',
        localPath: artifactSetDir(
          _good,
        ).uri.resolve(dylibAssetName).toFilePath(),
      );
      final result = await runDart(pkgDir, ['run', 'bin/main.dart']);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      expect(result.stdout, contains('Result: 42'));
    },
  );
}
