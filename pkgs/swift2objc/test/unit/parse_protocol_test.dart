import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:swift2objc/src/ast/declarations/compounds/protocol_declaration.dart';
import 'package:swift2objc/src/config.dart';
import 'package:swift2objc/src/generate_wrapper.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/_core/utils.dart';
import 'package:swift2objc/src/parser/parsers/parse_declarations.dart';
import 'package:swift2objc/src/parser/parsers/parse_relations_map.dart';
import 'package:swift2objc/src/parser/parsers/parse_symbols_map.dart';
import 'package:test/test.dart';

void main() {
  group('Protocol Testing', () {
    final jsonFile =
        p.join('test', 'unit', 'json', 'parse_protocol_symbol.json');
    final inputJson = readJsonFile(jsonFile);
    final symbolgraph = ParsedSymbolgraph(
      parseSymbolsMap(inputJson),
      parseRelationsMap(inputJson),
    );
    final declarations = parseDeclarations(symbolgraph);

    test('Basic Protocols', () {
      final declOne = declarations.firstWhere((t) => t.name == 'Greetable')
          as ProtocolDeclaration;

      expect(declOne.properties, hasLength(1));
      expect(declOne.methods, hasLength(1));

      expect(declOne.properties.single.name, equalsIgnoringCase('name'));

      var declMethod = declOne.methods.single;
      expect(declMethod.name, equalsIgnoringCase('greet'));
      expect(declMethod.returnType.swiftType, equalsIgnoringCase('String'));
    });

    test('Protocols with Static Properties and Methods', () {
      final testDecl = declarations.firstWhere((t) => t.name == 'User')
          as ProtocolDeclaration;

      expect(testDecl.properties, hasLength(4));
      expect(testDecl.methods, hasLength(2));

      expect(testDecl.methods.where((m) => m.isStatic), hasLength(1));
      expect(testDecl.properties.where((m) => m.isStatic), hasLength(1));

      final declProp = testDecl.properties.where((m) => m.isStatic).single;
      final declMethod = testDecl.methods.where((m) => m.isStatic).single;

      expect(declProp.name, equalsIgnoringCase('configurationName'));
    });

    test('Nested Protocols', () {
      final testDecl = declarations.firstWhere((t) => t.name == 'User')
          as ProtocolDeclaration;

      expect(testDecl.conformedProtocols, hasLength(1));

      final conformedProtocol = testDecl.conformedProtocols.single.declaration;

      expect(conformedProtocol.name, equalsIgnoringCase('Identifiable'));
      expect(conformedProtocol.properties, hasLength(1));

      var conformedProtocolProp = conformedProtocol.properties.single;
      expect(conformedProtocolProp.name, equalsIgnoringCase('id'));
    });

    test('Protocols with associated types', () {
      final testDecl = declarations.firstWhere((t) => t.name == 'Stackable')
          as ProtocolDeclaration;

      expect(testDecl.associatedTypes, hasLength(1));
      expect(testDecl.methods.map((m) => m.name), contains('push'));

      expect(
          testDecl.methods
              .firstWhere((m) => m.name == 'push')
              .returnType
              .swiftType,
          equalsIgnoringCase('Void'));
    });

    test('Protocols with associated types that conform', () {
      final testDecl =
          declarations.firstWhere((t) => t.name == 'PrintableStackable')
              as ProtocolDeclaration;

      expect(testDecl.associatedTypes, hasLength(1));

      final associatedType = testDecl.associatedTypes.single;

      expect(associatedType.name, equalsIgnoringCase('Element'));
      expect(associatedType.conformedProtocols, hasLength(1));

      final associatedTypeConformedProtocol =
          associatedType.conformedProtocols.single.declaration;

      expect(associatedTypeConformedProtocol.name,
          equalsIgnoringCase('Identifiable'));
    });
  });
}
