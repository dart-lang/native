// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

typedef _LocaleCanonicalizeNative =
    IntPtr Function(Pointer<Uint8>, Size, Pointer<Uint8>, Size);
typedef _LocaleCanonicalizeDart =
    int Function(Pointer<Uint8>, int, Pointer<Uint8>, int);
typedef _MallocNative = Pointer<Uint8> Function(Size);
typedef _MallocDart = Pointer<Uint8> Function(int);
typedef _FreeNative = Void Function(Pointer<Uint8>);
typedef _FreeDart = void Function(Pointer<Uint8>);

String _callCanonicalize(_LocaleCanonicalizeDart canonicalize, String input) {
  final processLib = DynamicLibrary.process();
  final malloc = processLib.lookupFunction<_MallocNative, _MallocDart>(
    'malloc',
  );
  final free = processLib.lookupFunction<_FreeNative, _FreeDart>('free');
  final inputBytes = utf8.encode(input);
  final inputPtr = malloc(inputBytes.length);
  final outPtr = malloc(64);
  try {
    inputPtr.asTypedList(inputBytes.length).setAll(0, inputBytes);
    final written = canonicalize(inputPtr, inputBytes.length, outPtr, 64);
    expect(written, greaterThan(0));
    return utf8.decode(outPtr.asTypedList(written));
  } finally {
    free(inputPtr);
    free(outPtr);
  }
}

String _clangTargetTriple(
  OS targetOS,
  Architecture architecture, {
  int? androidTargetNdkApi,
  int? macOSTargetVersion,
  int? iOSTargetVersion,
  IOSSdk? iOSTargetSdk,
}) => switch ((targetOS, architecture)) {
  (OS.linux, Architecture.x64) => 'x86_64-unknown-linux-gnu',
  (OS.linux, Architecture.arm64) => 'aarch64-unknown-linux-gnu',
  (OS.linux, Architecture.arm) => 'armv7-unknown-linux-gnueabihf',
  (OS.linux, Architecture.ia32) => 'i686-unknown-linux-gnu',
  (OS.linux, Architecture.riscv64) => 'riscv64-unknown-linux-gnu',
  (OS.android, Architecture.arm64) =>
    'aarch64-linux-android${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.arm) =>
    'armv7a-linux-androideabi${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.x64) =>
    'x86_64-linux-android${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.ia32) =>
    'i686-linux-android${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.riscv64) =>
    'riscv64-linux-android${androidTargetNdkApi ?? 35}',
  (OS.macOS, Architecture.arm64) =>
    'arm64-apple-macosx${macOSTargetVersion ?? 13}.0',
  (OS.macOS, Architecture.x64) =>
    'x86_64-apple-macosx${macOSTargetVersion ?? 13}.0',
  (OS.iOS, Architecture.arm64) =>
    iOSTargetSdk == IOSSdk.iPhoneSimulator
        ? 'arm64-apple-ios${iOSTargetVersion ?? 16}.0-simulator'
        : 'arm64-apple-ios${iOSTargetVersion ?? 16}.0',
  (OS.iOS, Architecture.x64) =>
    'x86_64-apple-ios${iOSTargetVersion ?? 16}.0-simulator',
  (OS.windows, Architecture.x64) => 'x86_64-pc-windows-msvc',
  (OS.windows, Architecture.arm64) => 'aarch64-pc-windows-msvc',
  _ => throw UnsupportedError('Unsupported ($targetOS, $architecture)'),
};

/// Generates a multi-megabyte C static archive modeling `icu4x` with 5 separate
/// compilation units and large `.rodata` Unicode data tables.
Future<Uri> _buildCrossPlatformIcu4xArchive(
  Uri tempUri,
  OS targetOS,
  Architecture architecture, {
  int? androidTargetNdkApi,
  int? macOSTargetVersion,
  int? iOSTargetVersion,
  IOSSdk? iOSTargetSdk,
}) async {
  final llvmReadobjUri = await resolveLlvmReadobj();
  if (llvmReadobjUri == null) {
    throw StateError('llvm-readobj/clang/llvm-ar not found in buildtools');
  }
  final clangUri = llvmReadobjUri.resolve(
    OS.current.executableFileName('clang'),
  );
  final llvmArUri = llvmReadobjUri.resolve(
    OS.current.executableFileName('llvm-ar'),
  );

  final srcDir = tempUri.resolve('icu4x_src/');
  await Directory.fromUri(srcDir).create(recursive: true);

  // Module 1: icu4x_locale.c (small kept module with ASCII canonicalization).
  await File.fromUri(srcDir.resolve('icu4x_locale.c')).writeAsString('''
#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

typedef unsigned char uint8_t;
typedef __SIZE_TYPE__ size_t;
typedef __PTRDIFF_TYPE__ ssize_t;

extern void *memcpy(void *dst, const void *src, size_t n);

FFI_EXPORT ssize_t icu4x_locale_canonicalize(
    const uint8_t *input,
    size_t input_len,
    uint8_t *output,
    size_t output_cap) {
  if (input_len > output_cap) {
    return -3;
  }
  for (size_t i = 0; i < input_len; i++) {
    uint8_t c = input[i];
    if (c == '_') {
      output[i] = '-';
    } else if (i < 2 && c >= 'A' && c <= 'Z') {
      output[i] = (uint8_t)(c + ('a' - 'A'));
    } else {
      output[i] = c;
    }
  }
  return (ssize_t)input_len;
}
''');

  // Modules 2..5: Heavy unused ICU4X modules (~512 KB .rodata each -> ~2 MB).
  const heavyModules = [
    ('icu4x_collator', 'icu4x_collator_compare'),
    ('icu4x_normalizer', 'icu4x_normalizer_is_nfc'),
    ('icu4x_segmenter', 'icu4x_segmenter_count_graphemes'),
    ('icu4x_datetime', 'icu4x_datetime_format'),
  ];
  const tableEntries = 131072; // 131072 * 4 bytes = 512 KiB per module.
  final objFiles = <String>[];
  final triple = _clangTargetTriple(
    targetOS,
    architecture,
    androidTargetNdkApi: androidTargetNdkApi,
    macOSTargetVersion: macOSTargetVersion,
    iOSTargetVersion: iOSTargetVersion,
    iOSTargetSdk: iOSTargetSdk,
  );

  final localeObj = srcDir.resolve(
    'icu4x_locale${targetOS == OS.windows ? '.obj' : '.o'}',
  );
  final localeCompile = await runProcess(
    executable: clangUri,
    arguments: [
      '--target=$triple',
      '-nostdinc',
      '-O2',
      '-ffunction-sections',
      '-fdata-sections',
      if (targetOS != OS.windows) '-fPIC',
      '-c',
      srcDir.resolve('icu4x_locale.c').toFilePath(),
      '-o',
      localeObj.toFilePath(),
    ],
    logger: logger,
    processManager: const LocalProcessManager(),
  );
  expect(localeCompile.exitCode, 0, reason: localeCompile.stderr);
  objFiles.add(localeObj.toFilePath());

  for (var m = 0; m < heavyModules.length; m++) {
    final (moduleName, fnName) = heavyModules[m];
    final sb = StringBuffer()
      ..writeln('#if _WIN32')
      ..writeln('#define FFI_EXPORT __declspec(dllexport)')
      ..writeln('#else')
      ..writeln('#define FFI_EXPORT')
      ..writeln('#endif')
      ..writeln('typedef unsigned int uint32_t;')
      ..writeln('typedef __SIZE_TYPE__ size_t;')
      ..writeln('static const uint32_t ${moduleName}_trie[$tableEntries] = {');
    for (var i = 0; i < tableEntries; i++) {
      final val = ((i * 2654435761) + m) & 0xFFFFFFFF;
      sb.write('$val,');
      if ((i & 15) == 15) sb.writeln();
    }
    sb
      ..writeln('};')
      ..writeln('FFI_EXPORT uint32_t $fnName(size_t idx) {')
      ..writeln(
        '  return ${moduleName}_trie[idx % $tableEntries] + (uint32_t)idx;',
      )
      ..writeln('}');
    final cFile = srcDir.resolve('$moduleName.c');
    await File.fromUri(cFile).writeAsString(sb.toString());
    final objUri = srcDir.resolve(
      '$moduleName${targetOS == OS.windows ? '.obj' : '.o'}',
    );
    final res = await runProcess(
      executable: clangUri,
      arguments: [
        '--target=$triple',
        '-nostdinc',
        '-O2',
        '-ffunction-sections',
        '-fdata-sections',
        if (targetOS != OS.windows) '-fPIC',
        '-c',
        cFile.toFilePath(),
        '-o',
        objUri.toFilePath(),
      ],
      logger: logger,
      processManager: const LocalProcessManager(),
    );
    expect(res.exitCode, 0, reason: res.stderr);
    objFiles.add(objUri.toFilePath());
  }

  final archiveUri = tempUri.resolve(targetOS.staticlibFileName('icu4x_capi'));
  final arRes = await runProcess(
    executable: llvmArUri,
    arguments: ['rc', archiveUri.toFilePath(), ...objFiles],
    logger: logger,
    processManager: const LocalProcessManager(),
  );
  expect(arRes.exitCode, 0, reason: arRes.stderr);
  return archiveUri;
}

Future<CodeAsset> _linkArchiveWithRestrictedPath({
  required Uri tempUri,
  required Uri tempUri2,
  required Uri archiveUri,
  required OS targetOS,
  required Architecture targetArchitecture,
  required List<String>? symbolsToKeep,
  int? androidTargetNdkApi,
  int? macOSTargetVersion,
  int? iOSTargetVersion,
  IOSSdk? iOSTargetSdk,
}) async {
  final linkInputBuilder = LinkInputBuilder()
    ..setupShared(
      packageName: 'icu4x_test',
      packageRoot: tempUri,
      outputFile: tempUri.resolve('output.json'),
      outputDirectoryShared: tempUri2,
    )
    ..setupLink(assets: [], recordedUsesFile: null, assetsFromLinking: [])
    ..addExtension(
      CodeAssetExtension(
        targetOS: targetOS,
        targetArchitecture: targetArchitecture,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: null,
        android: androidTargetNdkApi != null
            ? AndroidCodeConfig(targetNdkApi: androidTargetNdkApi)
            : null,
        macOS: macOSTargetVersion != null
            ? MacOSCodeConfig(targetVersion: macOSTargetVersion)
            : null,
        iOS: iOSTargetVersion != null && iOSTargetSdk != null
            ? IOSCodeConfig(
                targetSdk: iOSTargetSdk,
                targetVersion: iOSTargetVersion,
              )
            : null,
      ),
    );
  final linkInput = linkInputBuilder.build();
  final linkOutputBuilder = LinkOutputBuilder();

  await runWithEnvironment(const {'PATH': ''}, () async {
    await CLinker.library(
      name: 'icu4x_capi',
      assetName: 'icu4x_capi',
      sources: [archiveUri.toFilePath()],
      linkerOptions: LinkerOptions.treeshake(symbolsToKeep: symbolsToKeep),
    ).run(input: linkInput, output: linkOutputBuilder, logger: logger);
  });

  final linkOutput = linkOutputBuilder.build();
  expect(linkOutput.assets.code, hasLength(1));
  return linkOutput.assets.code.first;
}

void main() {
  test(
    'Real 60.4 MB Rust ICU4X 1.5.0 static archive tree-shakes >80% with '
    'direct lld and executes via FFI',
    timeout: const Timeout(Duration(minutes: 5)),
    () async {
      if (!Platform.isLinux || Architecture.current != Architecture.x64) {
        return;
      }
      final home = Platform.environment['HOME'] ?? '';
      final cargoRegistryDir = Directory(
        '$home/.cargo/registry/src/index.crates.io-6f17d22bba15001f/icu_locid-1.5.0',
      );
      final cargoFile = File('/usr/bin/cargo');
      if (!await cargoFile.exists() || !await cargoRegistryDir.exists()) {
        markTestSkipped('Rust cargo or cached ICU4X 1.5.0 crates unavailable');
        return;
      }

      final tempUri = await tempDirForTest();
      final cargoHome = tempUri.resolve('cargo_home/');
      for (final kind in ['index', 'cache', 'src']) {
        final dir = Directory.fromUri(cargoHome.resolve('registry/$kind/'));
        await dir.create(recursive: true);
        final target =
            '$home/.cargo/registry/$kind/index.crates.io-6f17d22bba15001f';
        for (final hash in [
          'index.crates.io-6f17d22bba15001f',
          'index.crates.io-1949cf8c6b5b557f',
        ]) {
          await Link.fromUri(
            cargoHome.resolve('registry/$kind/$hash'),
          ).create(target);
        }
      }

      final crateDir = tempUri.resolve('icu_capi_crate/');
      final srcDir = crateDir.resolve('src/');
      await Directory.fromUri(srcDir).create(recursive: true);

      await File.fromUri(crateDir.resolve('Cargo.toml')).writeAsString('''
[package]
name = "icu_capi_test"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["staticlib"]

[dependencies]
icu_locid = "=1.5.0"
icu_locid_transform = { version = "=1.5.0", features = ["compiled_data"] }
icu_normalizer = { version = "=1.5.0", features = ["compiled_data"] }
icu_properties = { version = "=1.5.1", features = ["compiled_data"] }
icu_segmenter = { version = "=1.5.0", features = ["compiled_data"] }
writeable = "=0.5.5"
''');

      await File.fromUri(srcDir.resolve('lib.rs')).writeAsString('''
use icu_locid::Locale;
use icu_locid_transform::LocaleCanonicalizer;
use icu_normalizer::ComposingNormalizer;
use icu_properties::{maps, sets};
use icu_segmenter::GraphemeClusterSegmenter;
use writeable::Writeable;

#[no_mangle]
pub unsafe extern "C" fn icu4x_locale_canonicalize(
    input_ptr: *const u8,
    input_len: usize,
    output_ptr: *mut u8,
    output_cap: usize,
) -> isize {
    let input = core::slice::from_raw_parts(input_ptr, input_len);
    let Ok(s) = core::str::from_utf8(input) else { return -1 };
    let Ok(mut locale) = Locale::try_from_bytes(s.as_bytes()) else { return -2 };
    let lc = LocaleCanonicalizer::new();
    lc.canonicalize(&mut locale);
    let canonical = locale.write_to_string();
    let bytes = canonical.as_bytes();
    if bytes.len() > output_cap {
        return -3;
    }
    core::ptr::copy_nonoverlapping(bytes.as_ptr(), output_ptr, bytes.len());
    bytes.len() as isize
}

#[no_mangle]
pub unsafe extern "C" fn icu4x_normalizer_is_nfc(
    input_ptr: *const u8,
    input_len: usize,
) -> i32 {
    let input = core::slice::from_raw_parts(input_ptr, input_len);
    let Ok(s) = core::str::from_utf8(input) else { return -1 };
    let normalizer = ComposingNormalizer::new_nfc();
    if normalizer.is_normalized(s) { 1 } else { 0 }
}

#[no_mangle]
pub unsafe extern "C" fn icu4x_segmenter_count_graphemes(
    input_ptr: *const u8,
    input_len: usize,
) -> usize {
    let input = core::slice::from_raw_parts(input_ptr, input_len);
    let Ok(s) = core::str::from_utf8(input) else { return 0 };
    let segmenter = GraphemeClusterSegmenter::new();
    segmenter.segment_str(s).count()
}

#[no_mangle]
pub extern "C" fn icu4x_char_bidi_class(cp: u32) -> u8 {
    let data = maps::bidi_class();
    let set = sets::alphabetic();
    let offset = if set.contains32(cp) { 100 } else { 0 };
    data.get32(cp).0 + offset
}
''');

      final cargoResult = await runProcess(
        executable: cargoFile.uri,
        arguments: ['build', '--release', '--offline'],
        workingDirectory: crateDir,
        environment: {'CARGO_HOME': cargoHome.toFilePath()},
        logger: logger,
        processManager: const LocalProcessManager(),
      );
      expect(cargoResult.exitCode, 0, reason: cargoResult.stderr);

      final archiveUri = crateDir.resolve('target/release/libicu_capi_test.a');
      final archiveBytes = await File.fromUri(archiveUri).length();
      expect(archiveBytes, greaterThan(10 * 1024 * 1024));

      final keepAllDir = await tempDirForTest();
      final keepAllShared = await tempDirForTest();
      final keepAllAsset = await _linkArchiveWithRestrictedPath(
        tempUri: keepAllDir,
        tempUri2: keepAllShared,
        archiveUri: archiveUri,
        targetOS: OS.linux,
        targetArchitecture: Architecture.x64,
        symbolsToKeep: null,
      );

      final shakenDir = await tempDirForTest();
      final shakenShared = await tempDirForTest();
      final shakenAsset = await _linkArchiveWithRestrictedPath(
        tempUri: shakenDir,
        tempUri2: shakenShared,
        archiveUri: archiveUri,
        targetOS: OS.linux,
        targetArchitecture: Architecture.x64,
        symbolsToKeep: const ['icu4x_locale_canonicalize'],
      );

      final keepAllBytes = await File.fromUri(keepAllAsset.file!).length();
      final shakenBytes = await File.fromUri(shakenAsset.file!).length();

      // Verify >80% reduction compared to static archive and >70% reduction
      // compared to un-treeshaken shared library.
      expect(shakenBytes, lessThan((archiveBytes * 0.2).round()));
      expect(shakenBytes, lessThan((keepAllBytes * 0.3).round()));

      // Verify DT_VERNEED GLIBC_2.* symbol versioning via llvm-readobj -V.
      final llvmReadobjUri = (await resolveLlvmReadobj())!;
      final verneedResult = await runProcess(
        executable: llvmReadobjUri,
        arguments: ['-V', shakenAsset.file!.toFilePath()],
        logger: logger,
        processManager: const LocalProcessManager(),
      );
      expect(verneedResult.exitCode, 0);
      expect(
        verneedResult.stdout,
        anyOf(contains('VersionRequirements ['), contains('VersionNeeds [')),
      );
      expect(verneedResult.stdout, contains('Name: GLIBC_2.'));

      // Verify exported symbol table via llvm-readobj --dyn-symbols.
      await expectSymbols(
        asset: shakenAsset,
        targetOS: OS.linux,
        symbols: const ['icu4x_locale_canonicalize'],
        symbolsNotToContain: const [
          'icu4x_normalizer_is_nfc',
          'icu4x_segmenter_count_graphemes',
          'icu4x_char_bidi_class',
        ],
      );

      // Load via DynamicLibrary.open and verify FFI execution + symbol lookup.
      final dylib = openDynamicLibraryForTest(shakenAsset.file!.toFilePath());
      expect(dylib.providesSymbol('icu4x_locale_canonicalize'), isTrue);
      expect(dylib.providesSymbol('icu4x_normalizer_is_nfc'), isFalse);
      expect(dylib.providesSymbol('icu4x_segmenter_count_graphemes'), isFalse);
      expect(dylib.providesSymbol('icu4x_char_bidi_class'), isFalse);

      final canonicalize = dylib
          .lookupFunction<_LocaleCanonicalizeNative, _LocaleCanonicalizeDart>(
            'icu4x_locale_canonicalize',
          );
      expect(
        _callCanonicalize(canonicalize, 'en_Latn_US_POSIX'),
        'en-Latn-US-posix',
      );
      expect(_callCanonicalize(canonicalize, 'iw_Latn_IL'), 'he-Latn-IL');
    },
  );

  final crossTargets =
      <
        ({
          String label,
          OS os,
          Architecture arch,
          int? androidApi,
          int? macOSVer,
          int? iOSVer,
          IOSSdk? iOSSdk,
        })
      >[
        for (final arch in [
          Architecture.x64,
          Architecture.arm64,
          Architecture.arm,
          Architecture.riscv64,
        ])
          (
            label: 'linux ($arch)',
            os: OS.linux,
            arch: arch,
            androidApi: null,
            macOSVer: null,
            iOSVer: null,
            iOSSdk: null,
          ),
        for (final arch in [
          Architecture.arm64,
          Architecture.arm,
          Architecture.x64,
        ])
          (
            label: 'android ($arch)',
            os: OS.android,
            arch: arch,
            androidApi: AndroidApiLevel.flutterLowestSupported.value,
            macOSVer: null,
            iOSVer: null,
            iOSSdk: null,
          ),
        for (final arch in [Architecture.arm64, Architecture.x64])
          (
            label: 'macOS ($arch)',
            os: OS.macOS,
            arch: arch,
            androidApi: null,
            macOSVer: defaultMacOSVersion,
            iOSVer: null,
            iOSSdk: null,
          ),
        for (final (sdk, arch) in [
          (IOSSdk.iPhoneOS, Architecture.arm64),
          (IOSSdk.iPhoneSimulator, Architecture.arm64),
          (IOSSdk.iPhoneSimulator, Architecture.x64),
        ])
          (
            label: 'iOS $sdk ($arch)',
            os: OS.iOS,
            arch: arch,
            androidApi: null,
            macOSVer: null,
            iOSVer: IOSVersion.flutterHighestSupported.value,
            iOSSdk: sdk,
          ),
        for (final arch in [Architecture.x64, Architecture.arm64])
          (
            label: 'windows ($arch)',
            os: OS.windows,
            arch: arch,
            androidApi: null,
            macOSVer: null,
            iOSVer: null,
            iOSSdk: null,
          ),
      ];

  for (final target in crossTargets) {
    test(
      'Cross-platform icu4x static archive tree-shakes >80% with restricted '
      'PATH on ${target.label}',
      () async {
        final tempUri = await tempDirForTest();
        final archiveUri = await _buildCrossPlatformIcu4xArchive(
          tempUri,
          target.os,
          target.arch,
          androidTargetNdkApi: target.androidApi,
          macOSTargetVersion: target.macOSVer,
          iOSTargetVersion: target.iOSVer,
          iOSTargetSdk: target.iOSSdk,
        );
        final archiveBytes = await File.fromUri(archiveUri).length();
        expect(archiveBytes, greaterThan(1500 * 1024));

        final keepAllDir = await tempDirForTest();
        final keepAllShared = await tempDirForTest();
        final keepAllAsset = await _linkArchiveWithRestrictedPath(
          tempUri: keepAllDir,
          tempUri2: keepAllShared,
          archiveUri: archiveUri,
          targetOS: target.os,
          targetArchitecture: target.arch,
          symbolsToKeep: null,
          androidTargetNdkApi: target.androidApi,
          macOSTargetVersion: target.macOSVer,
          iOSTargetVersion: target.iOSVer,
          iOSTargetSdk: target.iOSSdk,
        );

        final shakenDir = await tempDirForTest();
        final shakenShared = await tempDirForTest();
        final shakenAsset = await _linkArchiveWithRestrictedPath(
          tempUri: shakenDir,
          tempUri2: shakenShared,
          archiveUri: archiveUri,
          targetOS: target.os,
          targetArchitecture: target.arch,
          symbolsToKeep: const ['icu4x_locale_canonicalize'],
          androidTargetNdkApi: target.androidApi,
          macOSTargetVersion: target.macOSVer,
          iOSTargetVersion: target.iOSVer,
          iOSTargetSdk: target.iOSSdk,
        );

        final keepAllBytes = await File.fromUri(keepAllAsset.file!).length();
        final shakenBytes = await File.fromUri(shakenAsset.file!).length();

        expect(shakenBytes, lessThan((archiveBytes * 0.2).round()));
        expect(shakenBytes, lessThan((keepAllBytes * 0.2).round()));

        await expectMachineArchitecture(
          shakenAsset.file!,
          target.arch,
          target.os,
        );
        await expectSymbols(
          asset: shakenAsset,
          targetOS: target.os,
          symbols: const ['icu4x_locale_canonicalize'],
          symbolsNotToContain: const [
            'icu4x_collator_compare',
            'icu4x_normalizer_is_nfc',
            'icu4x_segmenter_count_graphemes',
            'icu4x_datetime_format',
          ],
        );

        if (target.os == OS.current && target.arch == Architecture.current) {
          final dylib = openDynamicLibraryForTest(
            shakenAsset.file!.toFilePath(),
          );
          expect(dylib.providesSymbol('icu4x_locale_canonicalize'), isTrue);
          expect(dylib.providesSymbol('icu4x_collator_compare'), isFalse);
          final canonicalize = dylib
              .lookupFunction<
                _LocaleCanonicalizeNative,
                _LocaleCanonicalizeDart
              >('icu4x_locale_canonicalize');
          expect(_callCanonicalize(canonicalize, 'EN_US'), 'en-US');
        }
      },
    );
  }
}
