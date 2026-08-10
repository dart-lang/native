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
import 'package:path/path.dart' as path;
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
    bool randInclude(String kind, DeclNode declaration, [String? member]) =>
        fnvHash32('$seed.$kind.${declaration.usr}.$member') <
        ((1 << 32) * inclusionRatio);
    bool shouldIncludeNode(
      String kind,
      DeclNode declaration, [
      Set<String> forceIncludes = const {},
    ]) =>
        forceIncludes.contains(declaration.originalName) ||
        randInclude(kind, declaration);

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
      input: Input(
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
      objectiveC: ObjectiveC(
        interfaces: const Interfaces(includeTransitive: false),
        protocols: const Protocols(includeTransitive: false),
        categories: const Categories(includeTransitive: false),
        externalVersions: ExternalVersions(
          ios: Versions(min: Version(12, 0, 0)),
          macos: Versions(min: Version(10, 14, 0)),
        ),
      ),
      visitors: [
        Visitor(
          visitFunc: (node) {
            if (!shouldIncludeNode('functionDecl', node)) {
              node.isIncluded = false;
            }
          },
          visitStruct: (node) {
            if (!shouldIncludeNode('structDecl', node)) node.isIncluded = false;
          },
          visitUnion: (node) {
            if (!shouldIncludeNode('unionDecl', node)) node.isIncluded = false;
          },
          visitEnum: (node) {
            if (!shouldIncludeNode('enums', node)) node.isIncluded = false;
          },
          visitUnnamedEnumConstant: (node) {
            if (!shouldIncludeNode('unnamedEnumConstants', node)) {
              node.isIncluded = false;
            }
          },
          visitGlobal: (node) {
            if (!shouldIncludeNode('globals', node)) node.isIncluded = false;
          },
          visitTypealias: (node) {
            if (!shouldIncludeNode('typedefs', node)) node.isIncluded = false;
          },
          visitObjCInterface: (node) {
            if (!shouldIncludeNode('objcInterfaces', node)) {
              node.isIncluded = false;
            }
          },
          visitObjCProtocol: (node) {
            if (!shouldIncludeNode(
              'objcProtocols',
              node,
              forceIncludedProtocols,
            )) {
              node.isIncluded = false;
            }
          },
          visitObjCCategory: (node) {
            if (!shouldIncludeNode('objcCategories', node)) {
              node.isIncluded = false;
            }
          },
          visitObjCMethod: (node) {
            final kind = switch (node.parent) {
              ObjCInterface() => 'objcInterfaces',
              ObjCProtocol() => 'objcProtocols',
              ObjCCategory() => 'objcCategories',
              _ => null,
            };
            if (kind != null) {
              if (!randInclude('$kind.memb', node.parent, node.originalName)) {
                node.isIncluded = false;
              }
            }
          },
        ),
      ],
    );

    final timer = Stopwatch()..start();
    generator.generate(logger: createTestLogger());
    expect(File(outFile).existsSync(), isTrue);
    expect(File(outObjCFile).existsSync(), isTrue);

    printOnFailure('\n\t\tFfigen generation: ${timer.elapsed}\n');
    timer.reset();

    // Verify Dart bindings pass analysis.
    expectNoAnalysisErrors(outFile);

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
