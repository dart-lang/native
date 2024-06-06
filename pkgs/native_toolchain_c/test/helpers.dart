// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
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
/// - `My test`
/// - `My test (dry_run)`
///
/// ```dart
/// void main() {
///   for (final dryRun in [true, false]) {
///     final suffix = testSuffix([if (dryRun) 'dry_run']);
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
  final tempUri =
      Directory(await tempDir.resolveSymbolicLinks()).uri.normalizePath();
  if ((!Platform.environment.containsKey(keepTempKey) ||
          Platform.environment[keepTempKey]!.isEmpty) &&
      !keepTemp) {
    addTearDown(() => tempDir.delete(recursive: true));
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
            '${record.level.name}: ${record.time}: ${record.message}');
        capturedMessages?.add(record.message);
      });

/// Test files are run in a variety of ways, find this package root in all.
///
/// Test files can be run from source from any working directory. The Dart SDK
/// `tools/test.py` runs them from the root of the SDK for example.
///
/// Test files can be run from dill from the root of package. `package:test`
/// does this.
///
/// https://github.com/dart-lang/test/issues/110
Uri findPackageRoot(String packageName) {
  final script = Platform.script;
  final fileName = script.name;
  if (fileName.endsWith('_test.dart')) {
    // We're likely running from source.
    var directory = script.resolve('.');
    while (true) {
      final dirName = directory.name;
      if (dirName == packageName) {
        return directory;
      }
      final parent = directory.resolve('..');
      if (parent == directory) break;
      directory = parent;
    }
  } else if (fileName.endsWith('.dill')) {
    final cwd = Directory.current.uri;
    final dirName = cwd.name;
    if (dirName == packageName) {
      return cwd;
    }
  }
  throw StateError("Could not find package root for package '$packageName'. "
      'Tried finding the package root via Platform.script '
      "'${Platform.script.toFilePath()}' and Directory.current "
      "'${Directory.current.uri.toFilePath()}'.");
}

Uri packageUri = findPackageRoot('native_toolchain_c');

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}

String unparseKey(String key) => key.replaceAll('.', '__').toUpperCase();

/// Archiver provided by the environment.
///
/// Provided on Dart CI.
final Uri? ar = Platform.environment[unparseKey('c_compiler.ar')]?.asFileUri();

/// Compiler provided by the environment.
///
/// Provided on Dart CI.
final Uri? cc = Platform.environment[unparseKey('c_compiler.cc')]?.asFileUri();

/// Linker provided by the environment.
///
/// Provided on Dart CI.
final Uri? ld = Platform.environment[unparseKey('c_compiler.ld')]?.asFileUri();

/// Path to script that sets environment variables for [cc], [ld], and [ar].
///
/// Provided on Dart CI.
final Uri? envScript =
    Platform.environment[unparseKey('c_compiler.env_script')]?.asFileUri();

/// Arguments for [envScript] provided by environment.
///
/// Provided on Dart CI.
final List<String>? envScriptArgs = Platform
    .environment[unparseKey('c_compiler.env_script_arguments')]
    ?.split(' ');

extension on String {
  Uri asFileUri() => Uri.file(this);
}

/// Looks up the install name of a dynamic library at [libraryUri].
///
/// Because `otool` output multiple names, [libraryName] as search parameter.
Future<String> runOtoolInstallName(Uri libraryUri, String libraryName) async {
  final otoolUri =
      (await otool.defaultResolver!.resolve(logger: logger)).first.uri;
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
