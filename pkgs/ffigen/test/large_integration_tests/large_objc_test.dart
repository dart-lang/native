// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
// This is a slow test.
@Timeout(Duration(minutes: 5))
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator/utils.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future<int> run(String exe, List<String> args) async {
  final process = await Process.start(exe, args).then((process) {
    process.stdout
        .transform(utf8.decoder)
        .forEach((s) => printOnFailure('  $s'));
    process.stderr
        .transform(utf8.decoder)
        .forEach((s) => printOnFailure('  $s'));
    return process;
  });
  return await process.exitCode;
}

void main() {
  test('Large ObjC integration test', () async {
    // Reducing the bindings to a random subset so that the test completes in a
    // reasonable amount of time.
    // TODO(https://github.com/dart-lang/sdk/issues/56247): Remove this.
    const inclusionRatio = 0.1;
    const seed = 1234;
    bool randInclude(String kind, Declaration clazz, [String? method]) =>
        fnvHash32('$seed.$kind.${clazz.usr}.$method') <
        ((1 << 32) * inclusionRatio);
    DeclarationFilters randomFilter(
      String kind, [
      Set<String> forceIncludes = const {},
    ]) => DeclarationFilters(
      shouldInclude: (Declaration clazz) =>
          forceIncludes.contains(clazz.originalName) ||
          randInclude(kind, clazz),
      shouldIncludeMember: (Declaration clazz, String method) =>
          randInclude('$kind.memb', clazz, method),
    );

    final outFile = path.join(
      packagePathForTests,
      'test',
      'large_integration_tests',
      'large_objc_bindings.dart',
    );
    final outObjCFile = path.join(
      packagePathForTests,
      'test',
      'large_integration_tests',
      'large_objc_bindings.m',
    );

    // TODO(https://github.com/dart-lang/native/issues/2517): Remove this.
    const forceIncludedProtocols = {'NSTextLocation'};

    final generator = FfiGenerator(
      bindingStyle: const DynamicLibraryBindings(
        wrapperName: 'LargeObjCLibrary',
      ),
      language: Language.objc,
      headers: Headers(
        entryPoints: [
          Uri.file(
            path.join(
              packagePathForTests,
              'test',
              'large_integration_tests',
              'large_objc_test.h',
            ),
          ),
        ],
      ),
      output: Output(
        dartFile: Uri.file(outFile),
        objectiveCFile: Uri.file(outObjCFile),
        format: false,
        preamble: '''
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unused_element
// ignore_for_file: unused_field
''',
      ),
      includeTransitiveObjCInterfaces: false,
      includeTransitiveObjCProtocols: false,
      includeTransitiveObjCCategories: false,
      functions: () {
        final filter = randomFilter('functionDecl');
        return Functions(
          shouldInclude: filter.shouldInclude,
          shouldIncludeMember: filter.shouldIncludeMember,
        );
      }(),
      structs: () {
        final filter = randomFilter('structDecl');
        return Structs(
          shouldInclude: filter.shouldInclude,
          shouldIncludeMember: filter.shouldIncludeMember,
        );
      }(),
      unionDecl: randomFilter('unionDecl'),
      enums: () {
        final filter = randomFilter('enums');
        return Enums(
          shouldInclude: filter.shouldInclude,
          shouldIncludeMember: filter.shouldIncludeMember,
        );
      }(),
      unnamedEnumConstants: randomFilter('unnamedEnumConstants'),
      globals: randomFilter('globals'),
      typedefs: randomFilter('typedefs'),
      objcInterfaces: randomFilter('objcInterfaces'),
      objcProtocols: randomFilter('objcProtocols', forceIncludedProtocols),
      objcCategories: randomFilter('objcCategories'),
      externalVersions: ExternalVersions(
        ios: Versions(min: Version(12, 0, 0)),
        macos: Versions(min: Version(10, 14, 0)),
      ),
    );

    final timer = Stopwatch()..start();
    generator.generate(
      logger: Logger.root
        ..level = Level.SEVERE
        ..onRecord.listen((record) {
          printOnFailure('${record.level.name.padRight(8)}: ${record.message}');
        }),
    );
    expect(File(outFile).existsSync(), isTrue);
    expect(File(outObjCFile).existsSync(), isTrue);

    printOnFailure('\n\t\tFfigen generation: ${timer.elapsed}\n');
    timer.reset();

    // Verify Dart bindings pass analysis.
    expect(await run('dart', ['analyze', outFile]), 0);

    printOnFailure('\n\t\tAnalyze dart: ${timer.elapsed}\n');
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
      0,
    );

    printOnFailure('\n\t\tCompile ObjC: ${timer.elapsed}\n');
    timer.reset();
  });
}
