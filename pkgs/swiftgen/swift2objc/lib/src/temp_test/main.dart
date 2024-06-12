// swiftc source.swift -emit-module -emit-symbol-graph -emit-symbol-graph-dir .
import '../parser/parser.dart';

void main() {
  final parser = Parser("lib/src/temp_test/symbolgraph/source.symbols.json");
  final bindings = parser.parse();
  print(bindings);
}
