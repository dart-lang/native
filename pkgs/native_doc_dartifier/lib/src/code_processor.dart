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

  Future<String> analyzeCode(String mainCode, String helperCode) async {
    await _saveCodeToFile(mainCode, helperCode);
    final dartifiedFile = File('${_tempDir.path}/$_dartifiedCodeFileName');
    final analysisResult = await Process.run('dart', [
      'analyze',
      dartifiedFile.absolute.path,
    ], runInShell: true);

    var errorMessage = '';
    if (analysisResult.exitCode != 0) {
      print('Dart analysis found issues:');
      final allLines = analysisResult.stdout.toString().trim().split('\n');
      final errorLines =
          allLines.where((line) => line.trim().startsWith('error -')).toList();

      errorMessage = errorLines.join('\n');
      print(errorMessage);
    } else {
      print('Dart analysis completed successfully with no errors.');
    }
    await _cleanUp();
    return errorMessage;
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

  String addImports(String code, List<String> imports) {
    final buffer = StringBuffer();
    for (final import in imports) {
      buffer.writeln("import '$import';");
    }
    buffer.writeln("import '$_helperCodeFileName';");
    buffer.writeln();
    buffer.write(code);
    return buffer.toString();
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
