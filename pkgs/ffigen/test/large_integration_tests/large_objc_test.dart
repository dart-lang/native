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
import 'package:ffigen/src/public_ast/public_ast.dart';
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

class _RandomIncludeVisitor extends Visitor {
  static const inclusionRatio = 0.1;
  static const seed = 1234;
  static const forceIncludedProtocols = {'NSTextLocation'};

  bool _randInclude(String kind, String usr, [String? member]) =>
      fnvHash32('$seed.$kind.$usr.$member') < ((1 << 32) * inclusionRatio);

  @override
  void visitFunc(Func node) {
    if (!_randInclude('functionDecl', node.usr)) node.isIncluded = false;
  }

  @override
  void visitStruct(Struct node) {
    if (!_randInclude('structDecl', node.usr)) node.isIncluded = false;
  }

  @override
  void visitUnion(Union node) {
    if (!_randInclude('unionDecl', node.usr)) node.isIncluded = false;
  }

  @override
  void visitEnum(EnumClass node) {
    if (!_randInclude('enums', node.usr)) node.isIncluded = false;
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {
    if (!_randInclude('unnamedEnumConstants', node.usr)) node.isIncluded = false;
  }

  @override
  void visitGlobal(Global node) {
    if (!_randInclude('globals', node.usr)) node.isIncluded = false;
  }

  @override
  void visitTypealias(Typealias node) {
    if (!_randInclude('typedefs', node.usr)) node.isIncluded = false;
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (!_randInclude('objcInterfaces', node.usr)) node.isIncluded = false;
    for (final m in node.methods) {
      if (!_randInclude('objcInterfaces.memb', node.usr, m.originalName)) {
        m.isIncluded = false;
      }
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    if (!forceIncludedProtocols.contains(node.originalName) &&
        !_randInclude('objcProtocols', node.usr)) {
      node.isIncluded = false;
    }
    for (final m in node.methods) {
      if (!_randInclude('objcProtocols.memb', node.usr, m.originalName)) {
        m.isIncluded = false;
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    if (!_randInclude('objcCategories', node.usr)) node.isIncluded = false;
    for (final m in node.methods) {
      if (!_randInclude('objcCategories.memb', node.usr, m.originalName)) {
        m.isIncluded = false;
      }
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
