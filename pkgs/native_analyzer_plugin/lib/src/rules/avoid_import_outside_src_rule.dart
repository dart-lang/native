// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

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
    var visitor = _Visitor(rule: this, context: context);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final RuleContext context;
  final AnalysisRule rule;

  _Visitor({required this.rule, required this.context});

  @override
  void visitImportDirective(ImportDirective node) {
    final importString = node.uri.stringValue;
    final importedUri = node.libraryImport?.importedLibrary?.uri;
    final importingFile = context.currentUnit?.file.toUri();

    if (importedUri == null || importingFile == null || importString == null) {
      return;
    }

    if (importString.startsWith('package')) {
      // Package imports are of no interest. Use prefer_relative_imports to
      // prevent package imports of the same package.
      return;
    }

    if (importString.startsWith('dart')) {
      return;
    }

    if (_isInSrcDirectory(importingFile)) {
      if (!_isInSrcDirectory(importedUri)) {
        rule.reportAtNode(node);
      }
    }
  }

  bool _isInSrcDirectory(Uri uri) {
    if (uri.scheme == 'package') {
      if (uri.path.contains('src/')) {
        return true;
      }
      return false;
    } else if (uri.scheme == 'file') {
      if (uri.toFilePath(windows: false).contains('lib/src/')) {
        return true;
      }
      if (uri.toFilePath(windows: false).contains('lib/')) {
        return false;
      }
    }
    return false;
  }
}
