// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../generator/_core/utils.dart';
import '../generator/generator.dart';
import '../parser/parser.dart';
import '../transformer/transform.dart';

/// To generate symbolgraph, run `swiftc source.swift -emit-module -emit-symbol-graph -emit-symbol-graph-dir .` in `temp_test/symbolgraph/` directory
const pathToSymbolgraph = 'lib/src/temp_test/symbolgraph/source.symbols.json';

void main() {
  final declarations = parseAst(pathToSymbolgraph);
  final transformedDeclarations = transform(declarations);
  final generatedCode = generate(transformedDeclarations);
  outputNextToFile(filePath: pathToSymbolgraph, content: generatedCode);
}
