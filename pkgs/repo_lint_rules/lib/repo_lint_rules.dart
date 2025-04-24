// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/dont_import_outside_src_rule.dart';

PluginBase createPlugin() => _MyLintRulesPlugin();

class _MyLintRulesPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    DontImportOutsideSrcRule(),
  ];
}
