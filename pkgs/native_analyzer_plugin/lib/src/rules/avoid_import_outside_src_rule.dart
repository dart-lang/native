// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:path/path.dart' as path;

class AvoidImportOutsideSrcRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_import_outside_src',
    "Avoid importing files outside 'lib/src/' from files within 'lib/src/'.",
    correctionMessage:
        "Files outside 'lib/src/' likely only export definitions from inside 'lib/src/'. "
        'Import the file with the definition directly.',
  );

  AvoidImportOutsideSrcRule()
    : super(
        name: 'avoid_import_outside_src',
        description:
            "Avoid importing files outside 'lib/src/' from files within 'lib/src/'.",
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    if (!context.isInLibDir) return;

    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;

    final package = context.package;
    if (package == null) return;

    final packageRoot = package.root.path;
    final libSrcDir = path.join(packageRoot, 'lib', 'src');

    final currentPath = currentUnit.file.path;
    if (!path.isWithin(libSrcDir, currentPath)) {
      return;
    }

    final importedLibrary = node.libraryImport?.importedLibrary;
    if (importedLibrary == null) return;

    final importedSource = importedLibrary.firstFragment.source;
    if (!package.contains(importedSource)) return;

    final importedPath = importedSource.fullName;
    final libDir = path.join(packageRoot, 'lib');

    if (path.isWithin(libDir, importedPath) &&
        !path.isWithin(libSrcDir, importedPath)) {
      rule.reportAtNode(node.uri);
    }
  }
}
