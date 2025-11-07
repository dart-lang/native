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
    bool randInclude(String kind, Declaration declaration, [String? member]) =>
        fnvHash32('$seed.$kind.${declaration.usr}.$member') <
        ((1 << 32) * inclusionRatio);
    bool Function(Declaration clazz) includeRandom(
      String kind, [
      Set<String> forceIncludes = const {},
    ]) =>
        (Declaration declaration) =>
            forceIncludes.contains(declaration.originalName) ||
            randInclude(kind, declaration);
    bool Function(Declaration declaration, String member) includeMemberRandom(
      String kind,
    ) =>
        (Declaration clazz, String method) =>
            randInclude('$kind.memb', clazz, method);

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
        style: const DynamicLibraryBindings(wrapperName: 'LargeObjCLibrary'),
        preamble: '''
// ignore_for_file: unused_element
// ignore_for_file: unused_field
''',
      ),
      functions: () {
        return Functions(include: includeRandom('functionDecl'));
      }(),
      structs: () {
        return Structs(include: includeRandom('structDecl'));
      }(),
      unions: () {
        return Unions(include: includeRandom('unionDecl'));
      }(),
      enums: () {
        return Enums(include: includeRandom('enums'));
      }(),
      unnamedEnums: () {
        return UnnamedEnums(include: includeRandom('unnamedEnumConstants'));
      }(),
      globals: Globals(include: includeRandom('globals')),
      typedefs: Typedefs(include: includeRandom('typedefs')),
      objectiveC: ObjectiveC(
        interfaces: Interfaces(
          include: includeRandom('objcInterfaces'),
          includeMember: includeMemberRandom('objcInterfaces'),
          includeTransitive: false,
        ),
        protocols: Protocols(
          include: includeRandom('objcProtocols', forceIncludedProtocols),
          includeMember: includeMemberRandom('objcProtocols'),
          includeTransitive: false,
        ),
        categories: Categories(
          include: includeRandom('objcCategories'),
          includeMember: includeMemberRandom('objcCategories'),
          includeTransitive: false,
        ),
        externalVersions: ExternalVersions(
          ios: Versions(min: Version(12, 0, 0)),
          macos: Versions(min: Version(10, 14, 0)),
        ),
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
