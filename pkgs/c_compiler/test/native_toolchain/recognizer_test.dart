// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:c_compiler/src/native_toolchain/android_ndk.dart';
import 'package:c_compiler/src/native_toolchain/apple_clang.dart';
import 'package:c_compiler/src/native_toolchain/clang.dart';
import 'package:c_compiler/src/native_toolchain/gcc.dart';
import 'package:c_compiler/src/native_toolchain/msvc.dart';
import 'package:c_compiler/src/native_toolchain/recognizer.dart';
import 'package:c_compiler/src/tool/tool.dart';
import 'package:c_compiler/src/tool/tool_instance.dart';
import 'package:c_compiler/src/tool/tool_resolver.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  final tests = [
    RecognizerTest(appleAr, ArchiverRecognizer.new),
    RecognizerTest(appleClang, CompilerRecognizer.new),
    RecognizerTest(appleLd, LinkerRecognizer.new),
    RecognizerTest(aarch64LinuxGnuGcc, CompilerRecognizer.new),
    RecognizerTest(aarch64LinuxGnuGccAr, ArchiverRecognizer.new),
    RecognizerTest(aarch64LinuxGnuLd, LinkerRecognizer.new),
    RecognizerTest(androidNdkClang, CompilerRecognizer.new),
    RecognizerTest(androidNdkLld, LinkerRecognizer.new),
    RecognizerTest(androidNdkLlvmAr, ArchiverRecognizer.new),
    RecognizerTest(armLinuxGnueabihfGcc, CompilerRecognizer.new),
    RecognizerTest(armLinuxGnueabihfGccAr, ArchiverRecognizer.new),
    RecognizerTest(armLinuxGnueabihfLd, LinkerRecognizer.new),
    RecognizerTest(cl, CompilerRecognizer.new),
    RecognizerTest(clang, CompilerRecognizer.new),
    RecognizerTest(i686LinuxGnuGcc, CompilerRecognizer.new),
    RecognizerTest(i686LinuxGnuGccAr, ArchiverRecognizer.new),
    RecognizerTest(i686LinuxGnuLd, LinkerRecognizer.new),
    RecognizerTest(lld, LinkerRecognizer.new),
    RecognizerTest(llvmAr, ArchiverRecognizer.new),
  ];

  for (final test in tests) {
    await test.setUp();
  }

  for (final test in tests) {
    test.addTest();
  }

  test('compiler does not exist', () async {
    await inTempDir((tempUri) async {
      final recognizer = CompilerRecognizer(tempUri.resolve('asdf'));
      final result = await recognizer.resolve(logger: logger);
      expect(result, <ToolInstance>[]);
    });
  });

  test('linker does not exist', () async {
    await inTempDir((tempUri) async {
      final recognizer = LinkerRecognizer(tempUri.resolve('asdf'));
      final result = await recognizer.resolve(logger: logger);
      expect(result, <ToolInstance>[]);
    });
  });

  test('archiver does not exist', () async {
    await inTempDir((tempUri) async {
      final recognizer = ArchiverRecognizer(tempUri.resolve('asdf'));
      final result = await recognizer.resolve(logger: logger);
      expect(result, <ToolInstance>[]);
    });
  });
}

class RecognizerTest {
  final Tool tool;
  final ToolResolver Function(Uri) recognizer;
  late final ToolInstance? toolInstance;

  RecognizerTest(this.tool, this.recognizer);

  Future<void> setUp() async {
    toolInstance = (await tool.defaultResolver!.resolve())
        .where((element) => element.tool == tool)
        .firstOrNull;
  }

  void addTest() {
    if (toolInstance == null) {
      // We only want to test if we would recognize the tool again if it exists
      // on the host. Skipping pollutes the stdout, so just don't run the test
      // at all.
      return;
    }

    test(
      'recognize ${tool.name}',
      () async {
        final recognizer_ = recognizer(toolInstance!.uri);
        final toolInstanceAgain =
            (await recognizer_.resolve(logger: logger)).first;
        expect(toolInstanceAgain, toolInstance);
      },
    );
  }
}
