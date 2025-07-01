// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:native_doc_dartifier/src/dartify_code.dart';
import '../test/dartiy_simple_cases/java/java_snippets.dart';

const workingDir = 'test/dartiy_simple_cases';
const javaPath = '$workingDir/java';
const compileDirName = 'compiled';
const dartifiedSnippetsDir = 'dartified_snippets';
const bindingsPath = '$workingDir/bindings.dart';

void generateBindings() {
  final setup = Process.runSync('flutter', ['pub', 'run', 'jni:setup']);
  if (setup.exitCode != 0) {
    throw Exception('Failed to run jni:setup: ${setup.stderr}');
  }

  final runJnigen = Process.runSync('flutter', [
    'pub',
    'run',
    'jnigen',
    '--config',
    '$workingDir/jnigen.yaml',
  ], workingDirectory: workingDir);
  if (runJnigen.exitCode != 0) {
    throw Exception('Failed to run jnigen: ${runJnigen.stderr}');
  }
}

void compileJavaPackage() {
  final directory = Directory(workingDir);
  if (!directory.existsSync()) {
    throw Exception('Directory does not exist: $workingDir');
  }

  final outputDir = Directory('$workingDir/compiled');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final javaFiles =
      Directory(javaPath)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.java'))
          .map((file) => file.absolute.path)
          .toList();

  final processResult = Process.runSync('javac', [
    '-d',
    compileDirName,
    ...javaFiles,
  ], workingDirectory: workingDir);

  if (processResult.exitCode == 0) {
    print('Compilation successful.');
  } else {
    throw Exception('Compilation Java Package failed: ${processResult.stderr}');
  }
}

void generateDartSnippets() async {
  for (final snippet in snippets) {
    final sourceCode = snippet['code'] as String;
    final dartCode = await dartifyNativeCode(sourceCode, bindingsPath);
    final fileName = snippet['fileName'];
    final outputFile = File('$workingDir/$dartifiedSnippetsDir/$fileName');
    if (!outputFile.parent.existsSync()) {
      outputFile.parent.createSync(recursive: true);
    }
    outputFile.writeAsStringSync('import \'../bindings.dart\';\n\n$dartCode');
  }
}

void main() {
  try {
    print('Generating bindings...');
    generateBindings();
    print('Compiling Java package...');
    compileJavaPackage();
    print('Generating Dart snippets...');
    generateDartSnippets();
  } catch (e) {
    throw Exception('An error occurred: $e');
  }
}
