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

// Reducing the bindings to a random subset so that the test completes in a
// reasonable amount of time.
// TODO(https://github.com/dart-lang/sdk/issues/56247): Remove this.
class _RandomIncludeVisitor extends Visitor {
  _RandomIncludeVisitor();

  static const inclusionRatio = 0.1;
  static const seed = 1234;
  static const forceIncludedProtocols = {'NSTextLocation'};

  bool _randInclude(String kind, String usr, [String? member]) =>
      fnvHash32('$seed.$kind.$usr.$member') < ((1 << 32) * inclusionRatio);

  @override
  void visitFunc(Func node) {
    node.isIncluded = _randInclude('functionDecl', node.usr);
  }

  @override
  void visitStruct(Struct node) {
    node.isIncluded = _randInclude('structDecl', node.usr);
  }

  @override
  void visitUnion(Union node) {
    node.isIncluded = _randInclude('unionDecl', node.usr);
  }

  @override
  void visitEnum(EnumClass node) {
    node.isIncluded = _randInclude('enums', node.usr);
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {
    node.isIncluded = _randInclude('unnamedEnumConstants', node.usr);
  }

  @override
  void visitGlobal(Global node) {
    node.isIncluded = _randInclude('globals', node.usr);
  }

  @override
  void visitTypealias(Typealias node) {
    node.isIncluded = _randInclude('typedefs', node.usr);
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    node.isIncluded = _randInclude('objcInterfaces', node.usr);
    for (final m in node.methods) {
      m.isIncluded = _randInclude(
        'objcInterfaces.memb',
        node.usr,
        m.originalName,
      );
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    node.isIncluded =
        forceIncludedProtocols.contains(node.originalName) ||
        _randInclude('objcProtocols', node.usr);
    for (final m in node.methods) {
      m.isIncluded = _randInclude(
        'objcProtocols.memb',
        node.usr,
        m.originalName,
      );
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    node.isIncluded = _randInclude('objcCategories', node.usr);
    for (final m in node.methods) {
      m.isIncluded = _randInclude(
        'objcCategories.memb',
        node.usr,
        m.originalName,
      );
    }
  }
}

void main() {
  test('Large ObjC integration test', () async {
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

    final generator = FfiGenerator(
      visitors: [_RandomIncludeVisitor()],
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
        externalVersions: ExternalVersions(
          ios: Versions(min: Version.parse('12.0.0')),
          macos: Versions(min: Version.parse('10.14.0')),
        ),
      ),
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
