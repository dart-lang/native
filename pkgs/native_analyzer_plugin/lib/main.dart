// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/avoid_import_outside_src_rule.dart';

final plugin = NativeAnalyzerPlugin();

class NativeAnalyzerPlugin extends Plugin {
  @override
  String get name => 'native_analyzer_plugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(AvoidImportOutsideSrcRule());
  }
}