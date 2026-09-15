// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:ffigen/ffigen.dart';
import 'package:package_config/package_config.dart';

void symbolFilesExample(PackageConfig? packageConfig) {
  // snippet-start#import_from_symbol_files
  final config = FfiGenerator(
    output: Output(dart: DartOutput(path: Uri.file('lib/bindings.dart'))),
    importType: importFromSymbolFiles([
      Uri.file('path/to/symbols1.yaml'),
      Uri.parse('package:other_pkg/symbols2.yaml'),
    ], packageConfig: packageConfig),
  );
  // snippet-end#import_from_symbol_files
}

void symbolFileExample() {
  // snippet-start#import_from_symbol_file
  final config = FfiGenerator(
    output: Output(dart: DartOutput(path: Uri.file('lib/bindings.dart'))),
    importType: importFromSymbolFile(Uri.file('path/to/symbols.yaml')),
  );
  // snippet-end#import_from_symbol_file
}
