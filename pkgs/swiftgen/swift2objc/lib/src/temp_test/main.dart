// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/generator/generator.dart';
import 'package:swift2objc/src/transformer/transform.dart';

import '../parser/parser.dart';

/// To generate symbolgraph, run `swiftc source.swift -emit-module -emit-symbol-graph -emit-symbol-graph-dir .` in `temp_test/symbolgraph/` directory
const pathToSymbolgraph = "lib/src/temp_test/symbolgraph/source.symbols.json";

void main() {
  final declarations = parseAst(pathToSymbolgraph);
  final transformedDeclarations = transform(declarations);
  final generatedCode = generate(transformedDeclarations);
  print(generatedCode);
}
