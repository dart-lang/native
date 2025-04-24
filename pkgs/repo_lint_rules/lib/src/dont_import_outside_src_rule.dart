// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class DontImportOutsideSrcRule extends DartLintRule {
  DontImportOutsideSrcRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_import_outside_src',
    problemMessage:
        "Avoid importing files outside 'lib/src/' from files within 'lib/src/'.",
    correctionMessage:
        "Files outside 'lib/src/' likely only export definitions from inside 'lib/src/'. "
        'Import the file with the definition directly.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final importedUri = node.uri.stringValue;
      if (importedUri == null) {
        return;
      }
      final importingFile = resolver.source.uri;

      if (importedUri.startsWith('package:')) {
        // Package imports are of no interest. Use prefer_relative_imports to
        // prevent package imports of the same package.
        return;
      }
      if (importedUri.startsWith('dart:')) {
        return;
      }
      final importedUriAbsolute = importingFile.resolve(importedUri);
      if (_isInSrcDirectory(importingFile)) {
        if (!_isInSrcDirectory(importedUriAbsolute)) {
          reporter.atNode(node, code);
        }
      }
    });
  }

  bool _isInSrcDirectory(Uri uri) {
    if (uri.toFilePath(windows: false).contains('lib/src/')) {
      return true;
    }
    if (uri.toFilePath(windows: false).contains('lib/')) {
      return false;
    }
    return false;
  }
}
