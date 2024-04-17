// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli.dart' show OS;
import 'package:native_toolchain_c/src/native_toolchain/android_ndk.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/gcc.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/native_toolchain/recognizer.dart';
import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  final tests = [
    RecognizerTest(appleAr, ArchiverRecognizer.new),
    RecognizerTest(appleClang, CompilerRecognizer.new),
    RecognizerTest(appleLd, (uri) => LinkerRecognizer(uri, OS.macOS)),
    RecognizerTest(aarch64LinuxGnuGcc, CompilerRecognizer.new),
    RecognizerTest(aarch64LinuxGnuGccAr, ArchiverRecognizer.new),
    RecognizerTest(aarch64LinuxGnuLd, (uri) => LinkerRecognizer(uri, OS.linux)),
    RecognizerTest(androidNdkClang, CompilerRecognizer.new),
    RecognizerTest(androidNdkLld, (uri) => LinkerRecognizer(uri, OS.android)),
    RecognizerTest(androidNdkLlvmAr, ArchiverRecognizer.new),
    RecognizerTest(armLinuxGnueabihfGcc, CompilerRecognizer.new),
    RecognizerTest(armLinuxGnueabihfGccAr, ArchiverRecognizer.new),
    RecognizerTest(
        armLinuxGnueabihfLd, (uri) => LinkerRecognizer(uri, OS.linux)),
    RecognizerTest(cl, CompilerRecognizer.new),
    RecognizerTest(clang, CompilerRecognizer.new),
    RecognizerTest(clang, (uri) => LinkerRecognizer(uri, OS.current)),
    RecognizerTest(i686LinuxGnuGcc, CompilerRecognizer.new),
    RecognizerTest(i686LinuxGnuGccAr, ArchiverRecognizer.new),
    RecognizerTest(i686LinuxGnuLd, (uri) => LinkerRecognizer(uri, OS.linux)),
    RecognizerTest(lib, ArchiverRecognizer.new),
    RecognizerTest(link, (uri) => LinkerRecognizer(uri, OS.windows)),
    RecognizerTest(lld, (uri) => LinkerRecognizer(uri, OS.current)),
    RecognizerTest(llvmAr, ArchiverRecognizer.new),
    RecognizerTest(riscv64LinuxGnuGcc, CompilerRecognizer.new),
    RecognizerTest(riscv64LinuxGnuGccAr, ArchiverRecognizer.new),
    RecognizerTest(riscv64LinuxGnuLd, (uri) => LinkerRecognizer(uri, OS.linux)),
    RecognizerTest(x86_64LinuxGnuGcc, CompilerRecognizer.new),
    RecognizerTest(x86_64LinuxGnuGccAr, ArchiverRecognizer.new),
    RecognizerTest(x86_64LinuxGnuLd, (uri) => LinkerRecognizer(uri, OS.linux)),
  ];

  for (final test in tests) {
    await test.setUp();
  }

  for (final test in tests) {
    test.addTest();
  }

  test('compiler does not exist', () async {
    final tempUri = await tempDirForTest();
    final recognizer = CompilerRecognizer(tempUri.resolve('asdf'));
    final result = await recognizer.resolve(logger: logger);
    expect(result, <ToolInstance>[]);
  });

  test('linker does not exist', () async {
    final tempUri = await tempDirForTest();
    final recognizer = LinkerRecognizer(tempUri.resolve('asdf'), OS.current);
    final result = await recognizer.resolve(logger: logger);
    expect(result, <ToolInstance>[]);
  });

  test('archiver does not exist', () async {
    final tempUri = await tempDirForTest();
    final recognizer = ArchiverRecognizer(tempUri.resolve('asdf'));
    final result = await recognizer.resolve(logger: logger);
    expect(result, <ToolInstance>[]);
  });
}

class RecognizerTest {
  final Tool tool;
  final ToolResolver Function(Uri) recognizer;
  late final ToolInstance? toolInstance;

  RecognizerTest(this.tool, this.recognizer);

  Future<void> setUp() async {
    toolInstance = (await tool.defaultResolver!.resolve(
      logger: null /* no printOnFailure support in setup. */,
    ))
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
