// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/diagnostic/diagnostic.dart' // ignore: implementation_imports
    as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:native_analyzer_plugin/src/rules/avoid_import_outside_src_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidImportOutsideSrcRuleTest);
  });
}

@reflectiveTest
class AvoidImportOutsideSrcRuleTest extends AnalysisRuleTest {
  @override
  List<DiagnosticCode> get ignoredDiagnosticCodes => [
    ...super.ignoredDiagnosticCodes,
    diag.unusedImport,
  ];

  @override
  void setUp() {
    rule = AvoidImportOutsideSrcRule();
    super.setUp();
  }

  @override
  String get testFileName => 'src/test.dart';

  Future<void> test_importOutsideSrcFromInsideSrc() async {
    newFile('$testPackageLibPath/foo.dart', '');
    await assertDiagnostics(
      r'''
import '../foo.dart';
''',
      [lint(7, 13)],
    );
  }

  Future<void> test_importInsideSrcFromInsideSrc() async {
    newFile('$testPackageLibPath/src/bar.dart', '');
    await assertNoDiagnostics(r'''
import 'bar.dart';
''');
  }
}
