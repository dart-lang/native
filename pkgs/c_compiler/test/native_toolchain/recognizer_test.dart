// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:c_compiler/src/native_toolchain/android_ndk.dart';
import 'package:c_compiler/src/native_toolchain/clang.dart';
import 'package:c_compiler/src/native_toolchain/gcc.dart';
import 'package:c_compiler/src/native_toolchain/recognizer.dart';
import 'package:c_compiler/src/tool/tool.dart';
import 'package:c_compiler/src/tool/tool_instance.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  void recognizeCompilerTest(String name, Tool tool) {
    test('recognize compiler $name', () async {
      final toolInstance = (await tool.defaultResolver!.resolve(logger: logger))
          .where((element) => element.tool == tool)
          .first;
      final recognizer = CompilerRecognizer(toolInstance.uri);
      final toolInstanceAgain =
          (await recognizer.resolve(logger: logger)).first;
      expect(toolInstanceAgain, toolInstance);
    });
  }

  recognizeCompilerTest('aarch64LinuxGnuGcc', aarch64LinuxGnuGcc);
  recognizeCompilerTest('androidNdkClang', androidNdkClang);
  recognizeCompilerTest('armLinuxGnueabihfGcc', armLinuxGnueabihfGcc);
  recognizeCompilerTest('clang', clang);
  recognizeCompilerTest('i686LinuxGnuGcc', i686LinuxGnuGcc);

  test('compiler does not exist', () async {
    await inTempDir((tempUri) async {
      final recognizer = CompilerRecognizer(tempUri.resolve('asdf'));
      final result = await recognizer.resolve(logger: logger);
      expect(result, <ToolInstance>[]);
    });
  });

  void recognizeLinkerTest(String name, Tool tool) {
    test('recognize compiler $name', () async {
      final toolInstance = (await tool.defaultResolver!.resolve(logger: logger))
          .where((element) => element.tool == tool)
          .first;
      final recognizer = LinkerRecognizer(toolInstance.uri);
      final toolInstanceAgain =
          (await recognizer.resolve(logger: logger)).first;
      expect(toolInstanceAgain, toolInstance);
    });
  }

  recognizeLinkerTest('aarch64LinuxGnuLd', aarch64LinuxGnuLd);
  recognizeLinkerTest('androidNdkLld', androidNdkLld);
  recognizeLinkerTest('armLinuxGnueabihfLd', armLinuxGnueabihfLd);
  recognizeLinkerTest('i686LinuxGnuLd', i686LinuxGnuLd);
  recognizeLinkerTest('lld', lld);

  test('linker does not exist', () async {
    await inTempDir((tempUri) async {
      final recognizer = LinkerRecognizer(tempUri.resolve('asdf'));
      final result = await recognizer.resolve(logger: logger);
      expect(result, <ToolInstance>[]);
    });
  });

  void recognizeArchiverTest(String name, Tool tool) {
    test('recognize compiler $name', () async {
      final toolInstance = (await tool.defaultResolver!.resolve(logger: logger))
          .where((element) => element.tool == tool)
          .first;
      final recognizer = ArchiverRecognizer(toolInstance.uri);
      final toolInstanceAgain =
          (await recognizer.resolve(logger: logger)).first;
      expect(toolInstanceAgain, toolInstance);
    });
  }

  recognizeArchiverTest('aarch64LinuxGnuGccAr', aarch64LinuxGnuGccAr);
  recognizeArchiverTest('androidNdkLlvmAr', androidNdkLlvmAr);
  recognizeArchiverTest('armLinuxGnueabihfGccAr', armLinuxGnueabihfGccAr);
  recognizeArchiverTest('i686LinuxGnuGccAr', i686LinuxGnuGccAr);
  recognizeArchiverTest('llvmAr', llvmAr);

  test('archiver does not exist', () async {
    await inTempDir((tempUri) async {
      final recognizer = ArchiverRecognizer(tempUri.resolve('asdf'));
      final result = await recognizer.resolve(logger: logger);
      expect(result, <ToolInstance>[]);
    });
  });
}
