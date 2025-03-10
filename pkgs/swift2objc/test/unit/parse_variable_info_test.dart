import 'dart:convert';

import 'package:swift2objc/src/ast/_core/shared/parameter.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_function_declaration.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_variable_declaration.dart';
import 'package:test/test.dart';

void main() {
  final parsedSymbols = {
    for (final decl in builtInDeclarations)
      decl.id: ParsedSymbol(json: Json(null), declaration: decl)
  };
  final emptySymbolgraph = ParsedSymbolgraph(parsedSymbols, {});

  group('Variable Valid json', () {
    
    test('Weak Variable', () {
      final json = Json(jsonDecode('''[
                {
                    "kind": "keyword",
                    "spelling": "weak"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "keyword",
                    "spelling": "var"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "identifier",
                    "spelling": "dorm"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "Dorm",
                    "preciseIdentifier": "s:24funcs_symbolgraph_module4DormC"
                },
                {
                    "kind": "text",
                    "spelling": "?"
                }
            ]'''));
      
      final info  = parsePropertyInfo(json);

      expect(info.weak, isTrue);
      expect(info.constant, isFalse);
    });

    test('Unowned Variable', () {
      final json = Json(jsonDecode('''[
                {
                    "kind": "keyword",
                    "spelling": "unowned"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "keyword",
                    "spelling": "var"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "identifier",
                    "spelling": "school"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "School",
                    "preciseIdentifier": "s:24funcs_symbolgraph_module6SchoolC"
                }
            ]'''));

      final info  = parsePropertyInfo(json);

      expect(info.unowned, isTrue);
      expect(info.constant, isFalse);
    });

    test('Unowned Constant variable', () {
      final json = Json(jsonDecode('''[
                {
                    "kind": "keyword",
                    "spelling": "unowned"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "keyword",
                    "spelling": "let"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "identifier",
                    "spelling": "almaMatter"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "School",
                    "preciseIdentifier": "s:24funcs_symbolgraph_module6SchoolC"
                }
            ]'''));
      
      final info  = parsePropertyInfo(json);

      expect(info.unowned, isTrue);
      expect(info.constant, isTrue);
    });

    test('Lazy Variable', () {
      final json = Json(jsonDecode('''[
                {
                    "kind": "keyword",
                    "spelling": "lazy"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "keyword",
                    "spelling": "var"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "identifier",
                    "spelling": "description"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "String",
                    "preciseIdentifier": "s:SS"
                },
                {
                    "kind": "text",
                    "spelling": " { "
                },
                {
                    "kind": "keyword",
                    "spelling": "get"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "keyword",
                    "spelling": "set"
                },
                {
                    "kind": "text",
                    "spelling": " }"
                }
            ]'''));
      
      final info  = parsePropertyInfo(json);

      expect(info.lazy, isTrue);
      expect(info.constant, isFalse);
    });
  });
}