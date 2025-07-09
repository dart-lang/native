// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:logging/logging.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

/// Returns a suffix for a test that is parameterized.
///
/// [tags] represent the current configuration of the test. Each element
/// is converted to a string by calling [Object.toString].
///
/// ## Example
///
/// The instances of the test below will have the following descriptions:
///
/// - `My test (debug)`
/// - `My test (release)`
///
/// ```dart
/// void main() {
///   for (final buildMode in BuildMode.values) {
///     final suffix = testSuffix([buildMode]);
///
///     test('My test$suffix', () {});
///   }
/// }
/// ```
String testSuffix(List<Object> tags) => switch (tags) {
  [] => '',
  _ => ' (${tags.join(', ')})',
};

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<Uri> tempDirForTest({String? prefix, bool keepTemp = false}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  // Deal with Windows temp folder aliases.
  final tempUri = Directory(
    await tempDir.resolveSymbolicLinks(),
  ).uri.normalizePath();
  if ((!Platform.environment.containsKey(keepTempKey) ||
          Platform.environment[keepTempKey]!.isEmpty) &&
      !keepTemp) {
    addTearDown(() => tempDir.delete(recursive: true));
  } else {
    addTearDown(() => print('$keepTempKey $tempUri'));
  }
  return tempUri;
}

/// Logger that outputs the full trace when a test fails.
Logger get logger => _logger ??= () {
  // A new logger is lazily created for each test so that the messages
  // captured by printOnFailure are scoped to the correct test.
  addTearDown(() => _logger = null);
  return _createTestLogger();
}();

Logger? _logger;

Logger createCapturingLogger(List<String> capturedMessages) =>
    _createTestLogger(capturedMessages: capturedMessages);

Logger _createTestLogger({List<String>? capturedMessages}) =>
    Logger.detached('')
      ..level = Level.ALL
      ..onRecord.listen((record) {
        printOnFailure(
          '${record.level.name}: ${record.time}: ${record.message}',
        );
        capturedMessages?.add(record.message);
      });

Uri packageUri = findPackageRoot('native_toolchain_c');

/// Archiver provided by the environment.
///
/// Provided on Dart CI.
final Uri? _ar = Platform.environment['DART_HOOK_TESTING_C_COMPILER__AR']
    ?.asFileUri();

/// Compiler provided by the environment.
///
/// Provided on Dart CI.
final Uri? _cc = Platform.environment['DART_HOOK_TESTING_C_COMPILER__CC']
    ?.asFileUri();

/// Linker provided by the environment.
///
/// Provided on Dart CI.
final Uri? _ld = Platform.environment['DART_HOOK_TESTING_C_COMPILER__LD']
    ?.asFileUri();

/// Path to script that sets environment variables for [_cc], [_ld], and [_ar].
///
/// Provided on Dart CI.
final Uri? _envScript = Platform
    .environment['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT']
    ?.asFileUri();

/// Arguments for [_envScript] provided by environment.
///
/// Provided on Dart CI.
final List<String>? _envScriptArgs = Platform
    .environment['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT_ARGUMENTS']
    ?.split(' ');

/// Configuration for the native toolchain.
///
/// Provided on Dart CI.
final cCompiler = (_cc == null || _ar == null || _ld == null)
    ? null
    : CCompilerConfig(
        compiler: _cc!,
        archiver: _ar!,
        linker: _ld!,
        windows: WindowsCCompilerConfig(
          developerCommandPrompt: _envScript == null
              ? null
              : DeveloperCommandPrompt(
                  script: _envScript!,
                  arguments: _envScriptArgs ?? [],
                ),
        ),
      );

extension on String {
  Uri asFileUri() => Uri.file(this);
}

/// Looks up the install name of a dynamic library at [libraryUri].
///
/// Because `otool` output multiple names, [libraryName] as search parameter.
Future<String> runOtoolInstallName(Uri libraryUri, String libraryName) async {
  final otoolUri = (await otool.defaultResolver!.resolve(
    logger: logger,
  )).first.uri;
  final otoolResult = await runProcess(
    executable: otoolUri,
    arguments: ['-l', libraryUri.path],
    logger: logger,
  );
  expect(otoolResult.exitCode, 0);
  // Leading space on purpose to differentiate from other types of names.
  const installNameName = ' name ';
  final installName = otoolResult.stdout
      .split('\n')
      .firstWhere((e) => e.contains(installNameName) && e.contains(libraryName))
      .trim()
      .split(' ')[1];
  return installName;
}

/// Opens the [DynamicLibrary] at [path] and register a tear down hook to close
/// it when the current test is done.
DynamicLibrary openDynamicLibraryForTest(String path) {
  final library = DynamicLibrary.open(path);
  addTearDown(library.close);
  return library;
}

extension UnescapePath on String {
  String unescape() => replaceAll('\\', '/');
}

Future<String> readelfMachine(String path) async {
  final result = await readelf(path, 'h');
  return result.split('\n').firstWhere((e) => e.contains('Machine:'));
}

const readElfMachine = {
  Architecture.arm: 'ARM',
  Architecture.arm64: 'AArch64',
  Architecture.ia32: 'Intel 80386',
  Architecture.x64: 'Advanced Micro Devices X86-64',
  Architecture.riscv64: 'RISC-V',
};

Future<String> readelf(String filePath, String flags) async {
  final result = await runProcess(
    executable: Uri.file('readelf'),
    arguments: ['-$flags', filePath],
    logger: logger,
  );

  expect(result.exitCode, 0);
  return result.stdout;
}

List<String> nmParameterFor(OS targetOS) => switch (targetOS) {
  OS.macOS || OS.iOS => const [],
  OS() => ['-D'],
};

/// Returns null if the tool to extract the symbols is not available.
Future<String?> readSymbols(CodeAsset asset, OS targetOS) async {
  final assetUri = asset.file!;
  switch (targetOS) {
    case OS.windows:
      final result = await _runDumpbin(['/EXPORTS'], asset.file!);
      if (result == null) {
        return null;
      }
      expect(result.exitCode, 0);
      return result.stdout;
    case OS():
      final result = await runProcess(
        executable: Uri(path: 'nm'),
        arguments: [...nmParameterFor(targetOS), assetUri.toFilePath()],
        logger: logger,
      );
      expect(result.exitCode, 0);
      return result.stdout;
  }
}

/// Returns null if the dumpbin tool is not available.
Future<RunProcessResult?> _runDumpbin(
  List<String> arguments,
  Uri libUri,
) async {
  final dumpbinTools = await dumpbin.defaultResolver!.resolve(logger: logger);
  if (dumpbinTools.isEmpty) {
    logger.info('Unable to locate dumpbin tool. Some expects may be skipped.');
    return null;
  }
  return await runProcess(
    executable: dumpbinTools.first.uri,
    arguments: [...arguments, libUri.toFilePath()],
    logger: logger,
  );
}

Future<int> textSectionAddress(Uri dylib) async {
  if (Platform.isMacOS) {
    // Find the line in the objdump output that looks like:
    //  11 .text               00000046 00000000000045a0 TEXT
    final result = await runProcess(
      executable: Uri.file('objdump'),
      arguments: ['--headers', dylib.toFilePath()],
      logger: logger,
    );
    expect(result.exitCode, 0);
    final textSection = result.stdout
        .split('\n')
        .firstWhere((e) => e.contains('.text'));
    final parsed = textSection.split(' ').where((e) => e.isNotEmpty).toList();
    expect(parsed[1], '.text');
    expect(parsed[4], 'TEXT');
    final vma = int.parse(parsed[3], radix: 16);
    return vma;
  }
  if (Platform.isLinux) {
    // Find the line in the readelf output that looks like:
    // [11] .text             PROGBITS   00004328 000328 000064 00  AX  0   0  4
    final result = await readelf(dylib.toFilePath(), 'S');
    final textSection = result
        .split('\n')
        .firstWhere((e) => e.contains('.text'));
    final parsed = textSection.split(' ').where((e) => e.isNotEmpty).toList();
    expect(parsed[1], '.text');
    expect(parsed[2], 'PROGBITS');
    final addr = int.parse(parsed[3], radix: 16);
    return addr;
  }
  throw UnimplementedError();
}

Future<void> expectPageSize(Uri dylib, int pageSize) async {
  if (Platform.isMacOS || Platform.isLinux) {
    // If page size is 16kb, the `.text` section address should be
    // above 0x4000. With smaller page sizes it's above 0x1000.
    final vma = await textSectionAddress(dylib);
    expect(vma, greaterThanOrEqualTo(pageSize));
  }
}

int defaultMacOSVersion = 13;

/// From https://docs.flutter.dev/reference/supported-platforms.
const flutterAndroidNdkVersionLowestSupported = 21;

/// From https://docs.flutter.dev/reference/supported-platforms.
const flutterAndroidNdkVersionHighestSupported = 34;

/// File-format strings used by the `objdump` tool for Android binaries that
/// run on a given architecture.
const objdumpFileFormatAndroid = {
  Architecture.arm: 'elf32-littlearm',
  Architecture.arm64: 'elf64-littleaarch64',
  Architecture.ia32: 'elf32-i386',
  Architecture.x64: 'elf64-x86-64',
  Architecture.riscv64: 'elf64-littleriscv',
};

const objdumpFileFormatMacOS = {
  Architecture.arm64: 'mach-o arm64',
  Architecture.x64: 'mach-o 64-bit x86-64',
};

// Don't include 'mach-o' or 'Mach-O', different spelling is used.
const objdumpFileFormatIOS = {
  Architecture.arm64: 'arm64',
  Architecture.x64: '64-bit x86-64',
};

const targetOSToObjdumpFileFormat = {
  OS.android: objdumpFileFormatAndroid,
  OS.macOS: objdumpFileFormatMacOS,
  OS.iOS: objdumpFileFormatMacOS,
};

const dumpbinFileFormat = {
  Architecture.arm64: 'ARM64',
  Architecture.ia32: 'x86',
  Architecture.x64: 'x64',
};

/// Checks that the provided [libUri] binary has the correct format to be
/// executed on the provided [targetArch] architecture.
///
/// On Linux, the format of the binary is determined by `readelf`. On MacOS,
/// the `objdump` tool is used. On Windows, `dumpbin` is used.
Future<void> expectMachineArchitecture(
  Uri libUri,
  Architecture targetArch,
  OS targetOS,
) async {
  if (Platform.isLinux) {
    final machine = await readelfMachine(libUri.path);
    expect(machine, contains(readElfMachine[targetArch]));
  } else if (Platform.isMacOS) {
    final result = await runProcess(
      executable: Uri.file('objdump'),
      arguments: ['-T', libUri.path],
      logger: logger,
    );
    expect(result.exitCode, 0);
    final machine = result.stdout
        .split('\n')
        .firstWhere((e) => e.contains('file format'));
    expect(
      machine,
      contains(targetOSToObjdumpFileFormat[targetOS]![targetArch]),
    );
  } else if (Platform.isWindows && targetOS == OS.windows) {
    final result = await _runDumpbin(['/HEADERS'], libUri);
    final skipReason = result == null
        ? 'tool to determine binary architecture unavailable'
        : false;
    expect(result?.exitCode, 0, skip: skipReason);
    final machine = result?.stdout
        .split('\n')
        .firstWhere((e) => e.contains('machine'));
    expect(machine, contains(dumpbinFileFormat[targetArch]), skip: skipReason);
  }
}

List<Architecture> supportedArchitecturesFor(OS targetOS) => switch (targetOS) {
  OS.macOS || OS.iOS => [Architecture.arm64, Architecture.x64],
  OS.windows => [
    // TODO(https://github.com/dart-lang/native/issues/170): Support arm64.
    // Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
  ],
  OS() => [
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
    Architecture.riscv64,
  ],
};

List<Architecture> iOSSupportedArchitecturesFor(IOSSdk iosSdk) =>
    switch (iosSdk) {
      IOSSdk.iPhoneOS => supportedArchitecturesFor(
        OS.iOS,
      )..remove(Architecture.x64),
      IOSSdk.iPhoneSimulator => supportedArchitecturesFor(OS.iOS),
      IOSSdk() => throw UnimplementedError(),
    };

const flutteriOSHighestBestEffort = 16;
const flutteriOSHighestSupported = 17;
