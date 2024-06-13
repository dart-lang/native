// swiftc source.swift -emit-module -emit-symbol-graph -emit-symbol-graph-dir .
import '../parser/parser.dart';

void main() {
  final ast = parseAst("lib/src/temp_test/symbolgraph/source.symbols.json");
  print(ast);
}
