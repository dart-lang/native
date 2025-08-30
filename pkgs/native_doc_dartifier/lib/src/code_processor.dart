// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

class CodeProcessor {
  final Directory _tempDir;
  final String _dartifiedCodeFileName = 'dartified_code.dart';
  final String _helperCodeFileName = 'helper_code.dart';

  CodeProcessor() : _tempDir = Directory('${Directory.current.path}/temp') {
    if (!_tempDir.existsSync()) {
      _tempDir.createSync(recursive: true);
    }
  }

  Future<List<String>> analyzeCode(String mainCode, String helperCode) async {
    await _saveCodeToFile(mainCode, helperCode);
    final dartifiedFile = File('${_tempDir.path}/$_dartifiedCodeFileName');
    final analysisResult = await Process.run('dart', [
      'analyze',
      dartifiedFile.absolute.path,
    ], runInShell: true);

    final allLines = analysisResult.stdout.toString().trim().split('\n');
    final errorLines =
        allLines.where((line) => line.trim().startsWith('error -')).toList();

    await _cleanUp();
    return errorLines;
  }

  Future<void> _saveCodeToFile(String mainCode, String helperCode) async {
    try {
      final dartifiedFile = File('${_tempDir.path}/$_dartifiedCodeFileName');
      await dartifiedFile.writeAsString(mainCode);

      final helperFile = File('${_tempDir.path}/$_helperCodeFileName');
      await helperFile.writeAsString(helperCode);
    } catch (e) {
      print('Error saving code to file: $e');
    }
  }

  String addImports(String code, List<String> importedPackages) {
    final buffer = StringBuffer();
    for (final package in importedPackages) {
      buffer.writeln("import '$package';");
    }
    buffer.writeln("import '$_helperCodeFileName';");
    buffer.writeln();
    buffer.write(code);
    return buffer.toString();
  }

  String removeHelperCodeImport(String code) {
    final lines = code.split('\n');
    final filteredLines =
        lines
            .where(
              (line) => !line.startsWith('import \'$_helperCodeFileName\';'),
            )
            .toList();
    return filteredLines.join('\n');
  }

  Future<void> _cleanUp() async {
    try {
      if (await _tempDir.exists()) {
        final files = _tempDir.listSync().whereType<File>();
        for (final file in files) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up temporary directory: $e');
    }
  }
}
