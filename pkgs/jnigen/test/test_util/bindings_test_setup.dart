// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests on generated code.
//
// Both the simple java example & jackson core classes example have tests in
// same file, because the test runner will reuse the process, which leads to
// reuse of the old JVM with old classpath if we have separate tests with
// different classpaths.

// ignore_for_file: curly_braces_in_flow_control_structures, lines_longer_than_80_chars, prefer_const_declarations, omit_local_variable_types

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:jni/jni.dart';
import 'package:path/path.dart' hide equals;

import 'test_util.dart';

final simplePackageTest = join('test', 'simple_package_test');
final jacksonCoreTest = join('test', 'jackson_core_test');
final kotlinTest = join('test', 'kotlin_test');
final jniJar = join('build', 'jni_libs', 'jni.jar');

final simplePackageTestJava = join(simplePackageTest, 'java');
final kotlinTestKotlin = join(kotlinTest, 'kotlin');

late Directory tempClassDir;

Future<void> bindingsTestSetup() async {
  await runCommand('dart', [
    'run',
    'jni:setup',
  ]);
  tempClassDir =
      Directory.current.createTempSync('jnigen_runtime_test_classpath_');
  await compileJavaFiles(Directory(simplePackageTestJava), tempClassDir);
  await runCommand('dart', [
    'run',
    'jnigen:download_maven_jars',
    '--config',
    join(jacksonCoreTest, 'jnigen.yaml')
  ]);

  final jacksonJars = await getJarPaths(join(jacksonCoreTest, 'third_party'));

  await runCommand(
    'mvn',
    ['package'],
    workingDirectory: kotlinTestKotlin,
    runInShell: true,
  );
  // Jar including Kotlin runtime and dependencies.
  final kotlinTestJar =
      join(kotlinTestKotlin, 'target', 'kotlin_test-jar-with-dependencies.jar');

  // --- Configuration ---
  final jarFilePath = kotlinTestJar;
  // Path to the class file *inside* the JAR
  final classPathInJar = 'com/github/dart_lang/jnigen/Operators.class';
  // Temporary file for extracting the class
  final tempFilePath = 'Operators.class.tmp';
  // --- End Configuration ---

  print('--- Starting JAR Debug ---');
  print('Timestamp: ${DateTime.now()}');
  print('JAR File Path: $jarFilePath');
  print('Class Path in JAR: $classPathInJar');
  print('');

  final jarFile = File(jarFilePath);

  // 1. Check JAR File Existence
  print('1. Checking JAR file existence...');
  final jarExists = await jarFile.exists();
  print('   Exists: $jarExists');
  if (!jarExists) {
    print('   ERROR: JAR file not found at specified path. Aborting.');
    print('--- End JAR Debug ---');
    exit(1); // Exit with error
  }
  print('');

  // 2. Check if Operators.class is listed in JAR contents
  print('2. Checking if class is listed in JAR contents (using `jar tf`)...');
  bool classListed = false;
  try {
    // Ensure 'jar' command is available in PATH
    final listResult =
        await Process.run('jar', ['tf', jarFilePath], runInShell: true);

    if (listResult.exitCode == 0) {
      final output = utf8.decode(listResult.stdout as List<int>);
      if (output.contains(classPathInJar)) {
        classListed = true;
        print('   Class "$classPathInJar" IS listed in JAR contents.');
      } else {
        print(
            '   WARNING: Class "$classPathInJar" is NOT listed in JAR contents!');
        print(
            '   Full `jar tf` output:\n${output.substring(0, output.length > 1000 ? 1000 : output.length)}...'); // Print first 1000 chars
      }
    } else {
      print(
          '   ERROR: `jar tf` command failed with exit code ${listResult.exitCode}.');
      print('   Stderr: ${utf8.decode(listResult.stderr as List<int>)}');
    }
  } catch (e) {
    print(
        '   ERROR: Failed to run `jar tf`. Is `jar` (from JDK) in your PATH? Exception: $e');
  }
  print('');

  // 3. Extract Operators.class and get its info
  print('3. Attempting to extract class file using `unzip -p`...');
  final tempFile = File(tempFilePath);
  bool extractionAttempted = false;
  bool extractionSucceeded = false;
  int extractedSize = -1;
  String extractedSha256 = 'N/A';

  // Clean up potentially leftover temp file
  if (await tempFile.exists()) {
    await tempFile.delete();
  }

  try {
    // Ensure 'unzip' command is available in PATH
    // Use Process.start to pipe output to file, as `unzip -p` writes to stdout
    extractionAttempted = true;
    final process = await Process.start(
      'unzip',
      ['-p', jarFilePath, classPathInJar],
      runInShell: true, // May be needed depending on PATH setup
    );

    // Pipe stdout to the temporary file
    final fileSink = tempFile.openWrite();
    await process.stdout.pipe(fileSink);

    // Wait for the process to exit and check code
    final exitCode = await process.exitCode;

    if (exitCode == 0) {
      // Check if file was actually created and has content
      if (await tempFile.exists() && await tempFile.length() > 0) {
        extractionSucceeded = true;
        print(
            '   Extraction via `unzip -p` seems successful (exit code 0, file created).');

        // 4. Get Size
        final fileStat = await tempFile.stat();
        extractedSize = fileStat.size;
        print('   Extracted Size: $extractedSize bytes');

        // 5. Calculate Checksum
        final bytes = await tempFile.readAsBytes();
        final digest = sha256.convert(bytes);
        extractedSha256 = digest.toString();
        print('   Extracted SHA256: $extractedSha256');
      } else {
        print(
            '   WARNING: `unzip -p` exited with 0, but temp file "$tempFilePath" is missing or empty.');
        if (await tempFile.exists())
          await tempFile.delete(); // Clean up empty file
      }
    } else {
      print('   ERROR: `unzip -p` command failed with exit code $exitCode.');
      // Try to read stderr (might not capture much depending on how unzip fails)
      // Note: Reading stderr after piping stdout might be tricky / lose data.
      // Consider alternative extraction methods if this fails often.
    }
  } catch (e) {
    print(
        '   ERROR: Failed to run `unzip -p`. Is `unzip` in your PATH? Exception: $e');
  } finally {
    // 6. Clean up temp file
    if (await tempFile.exists()) {
      try {
        await tempFile.delete();
        print('   Temporary file "$tempFilePath" deleted.');
      } catch (e) {
        print(
            '   WARNING: Failed to delete temporary file "$tempFilePath". Exception: $e');
      }
    }
  }
  print('');

  print('--- Summary ---');
  print('JAR Exists: $jarExists');
  print('Class Listed in JAR: $classListed');
  print('Extraction Attempted: $extractionAttempted');
  print('Extraction Succeeded: $extractionSucceeded');
  print('Extracted Size: $extractedSize bytes');
  print('Extracted SHA256: $extractedSha256');
  print('--- End JAR Debug ---');

  if (!Platform.isAndroid) {
    Jni.spawn(dylibDir: join('build', 'jni_libs'), classPath: [
      jniJar,
      tempClassDir.path,
      ...jacksonJars,
      kotlinTestJar,
    ], jvmOptions: [
      '-Xcheck:jni',
    ]);
  }
}

void bindingsTestTeardown() {
  tempClassDir.deleteSync(recursive: true);
}
