// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

final _testDirectoryPath =
    path.join("test", "code_generator_tests", "ffigen_smart_regen");
final _configYamlPath = path.join(_testDirectoryPath, "config.yaml");
final _headerFiles = Directory(path.join(_testDirectoryPath, "headers"))
    .listSync()
    .map((e) => e.path)
    .where((e) => e.endsWith('.h') || e.endsWith('.c'));
final _configAndHeaders = [
  _configYamlPath,
  ..._headerFiles,
];

void main() {
  group('_inputHasBeenUpdated', () {
    test('should return true if file does not exist', () {
      _cleanUp();

      final fileToBeGenerated =
          File(path.join(_testDirectoryPath, "generated_bindings.dart"));

      final result = _inputHasBeenUpdated(fileToBeGenerated, _configAndHeaders);

      expect(result, isTrue);
    });

    test(
        'should return true if the config or any header file is newer than the generated file',
        () {
      _ensureGeneratedBindings();
      final fileToBeGenerated =
          File(path.join(_testDirectoryPath, "generated_bindings.dart"));

      // Set the last modified time of the generated file to be older than the header files
      fileToBeGenerated.setLastModifiedSync(DateTime(2022, 1, 1));

      // Set the last modified time of one of the header files to be newer than the generated file
      final headerFile =
          File(path.join(_testDirectoryPath, 'headers', 'header1.h'));
      headerFile.setLastModifiedSync(DateTime(2023, 1, 1));

      final result = _inputHasBeenUpdated(fileToBeGenerated, _configAndHeaders);

      expect(result, isTrue);
    });

    test('should return true if the config is newer than the generated file',
        () {
      _ensureGeneratedBindings();
      final fileToBeGenerated =
          File(path.join(_testDirectoryPath, "generated_bindings.dart"));

      // Set the last modified time of the generated file to be older than the header files
      fileToBeGenerated.setLastModifiedSync(DateTime(2022, 1, 1));

      // Set the last modified time of the config file to be newer than the generated file
      final configFile = File(_configYamlPath);
      configFile.setLastModifiedSync(DateTime(2023, 1, 1));

      final result = _inputHasBeenUpdated(fileToBeGenerated, _configAndHeaders);

      expect(result, isTrue);
    });

    test(
        'should return false if the config and header files are all older than the generated file',
        () {
      _ensureGeneratedBindings();
      final fileToBeGenerated =
          File(path.join(_testDirectoryPath, "generated_bindings.dart"));

      // Set the last modified time of the generated file to be older than the header files
      fileToBeGenerated.setLastModifiedSync(DateTime.now());

      final configFile = File(_configYamlPath);
      configFile.setLastModifiedSync(DateTime(2021, 1, 1));

      // Set the last modified time of the header files to be newer than the generated file
      final headerFile1 =
          File(path.join(_testDirectoryPath, 'headers', 'header1.h'));
      headerFile1.setLastModifiedSync(DateTime(2023, 1, 1));

      final headerFile2 =
          File(path.join(_testDirectoryPath, 'headers', 'file.c'));
      headerFile2.setLastModifiedSync(DateTime(2023, 1, 1));

      final result = _inputHasBeenUpdated(fileToBeGenerated, _configAndHeaders);

      expect(result, isFalse);
    });

    _cleanUp();
  });
}

/// Returns true if the file needs to be regenerated.

bool _inputHasBeenUpdated(
    File fileToBeGenerated, List<String> configAndHeaders) {
  // if file does not exist, consider it needs to be generated.
  if (!fileToBeGenerated.existsSync()) {
    return true;
  }

  for (final configOrHeader in configAndHeaders) {
    final headerMTime = File(configOrHeader).lastModifiedSync();

    if (fileToBeGenerated.existsSync() &&
        headerMTime.isAfter(fileToBeGenerated.lastModifiedSync())) {
      return true; // file needs to be regenerated.
    }
  }
  return false;
}

void _ensureGeneratedBindings() {
  final config = testConfigFromPath(path.join(
      'test', 'code_generator_tests', 'ffigen_smart_regen', 'config.yaml'));
  final library = parse(config);
  // Generate file for the parsed bindings.
  final fileToBeGenerated = File(config.output);

  library.generateFile(fileToBeGenerated);
}

void _cleanUp() {
  final genFile =
      File(path.join(_testDirectoryPath, "generated_bindings.dart"));
  if (genFile.existsSync()) {
    genFile.deleteSync();
  }
}
