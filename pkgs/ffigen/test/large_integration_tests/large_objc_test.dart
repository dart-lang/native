// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

// This is a slow test.
@Timeout(Duration(minutes: 5))
library;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

Future<int> run(String exe, List<String> args) async {
  final process =
      await Process.start(exe, args, mode: ProcessStartMode.inheritStdio);
  return await process.exitCode;
}

void main() {
  test('Large ObjC integration test', () async {
    // Reducing the bindings to a random subset so that the test completes in a
    // reasonable amount of time.
    // TODO(https://github.com/dart-lang/sdk/issues/56247): Remove this.
    const inclusionRatio = 0.1;
    final rand = Random(1234);
    bool randInclude([_, __]) => rand.nextDouble() < inclusionRatio;
    final randomFilter = DeclarationFilters(
      shouldInclude: randInclude,
      shouldIncludeMember: randInclude,
    );

    const outFile = 'test/large_integration_tests/large_objc_bindings.dart';
    const outObjCFile = 'test/large_integration_tests/large_objc_bindings.m';
    final config = Config(
      wrapperName: 'LargeObjCLibrary',
      language: Language.objc,
      output: Uri.file(outFile),
      outputObjC: Uri.file(outObjCFile),
      entryPoints: [Uri.file('test/large_integration_tests/large_objc_test.h')],
      formatOutput: false,
      includeTransitiveObjCInterfaces: false,
      includeTransitiveObjCProtocols: false,
      includeTransitiveObjCCategories: false,
      functionDecl: randomFilter,
      structDecl: randomFilter,
      unionDecl: randomFilter,
      enumClassDecl: randomFilter,
      unnamedEnumConstants: randomFilter,
      globals: randomFilter,
      typedefs: randomFilter,
      objcInterfaces: randomFilter,
      objcProtocols: randomFilter,
      objcCategories: randomFilter,
      externalVersions: ExternalVersions(
        ios: Versions(min: Version(12, 0, 0)),
        macos: Versions(min: Version(10, 14, 0)),
      ),
      preamble: '''
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unused_element
// ignore_for_file: unused_field
''',
    );

    final timer = Stopwatch()..start();
    FfiGen(logLevel: Level.SEVERE).run(config);
    expect(File(outFile).existsSync(), isTrue);
    expect(File(outObjCFile).existsSync(), isTrue);
    stderr.writeln('\n\n\n\n\nZZZZZZZZ\n\n\n\n');
    stderr.writeln(File(outFile).readAsStringSync());
    stderr.writeln('\n\n\n\n\nZZZZZZZZ\n\n\n\n');

    print('\n\t\tFfigen generation: ${timer.elapsed}\n');
    timer.reset();

    // Verify Dart bindings pass analysis.
    expect(await run('dart', ['analyze', outFile]), 0);

    print('\n\t\tAnalyze dart: ${timer.elapsed}\n');
    timer.reset();

    // Verify ObjC bindings compile.
    expect(
        await run('clang', [
          '-x',
          'objective-c',
          outObjCFile,
          '-fpic',
          '-fobjc-arc',
          '-shared',
          '-framework',
          'Foundation',
          '-o',
          '/dev/null',
        ]),
        0);

    print('\n\t\tCompile ObjC: ${timer.elapsed}\n');
    timer.reset();
  });
}
