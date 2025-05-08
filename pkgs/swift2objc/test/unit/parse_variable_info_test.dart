import 'dart:convert';

// import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
// import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_variable_declaration.dart';
import 'package:test/test.dart';

void main() {
  group('Variable Valid json', () {
    test('Variable with getter', () {
      final json = Json(jsonDecode('''[
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
                    "spelling": "id"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "Int",
                    "preciseIdentifier": "s:Si"
                },
                {
                    "kind": "text",
                    "spelling": " { get }"
                }
            ]'''));

      final info = parsePropertyInfo(json);

      expect(info.getter, isTrue);
    });

    test('Variable Computed', () {
      final json = Json(jsonDecode('''[
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
                    "spelling": "computedProperty"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "Int",
                    "preciseIdentifier": "s:Si"
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
                    "spelling": " }"
                }
            ]'''));

      final info = parsePropertyInfo(json);

      expect(info.getter, isTrue);
    });

    test('Variable with getter and setter', () {
      final json = Json(jsonDecode('''[
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
                    "spelling": "computedWithSet"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "Int",
                    "preciseIdentifier": "s:Si"
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

      final info = parsePropertyInfo(json);

      expect(info.getter, isTrue);
      expect(info.setter, isTrue);
    });

    test('Constant variable', () {});

    test('Async Get Variable', () {
      final json = Json(jsonDecode('''[
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
                    "spelling": "computedAsyncProperty"
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
                    "spelling": "async"
                },
                {
                    "kind": "text",
                    "spelling": " }"
                }
            ]'''));

      final info = parsePropertyInfo(json);

      expect(info.getter, isTrue);
      expect(info.async, isTrue);
    });

    test('Mutating Variable', () {
      final json = Json(jsonDecode('''[
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
                    "spelling": "computedWithSet"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "Int",
                    "preciseIdentifier": "s:Si"
                },
                {
                    "kind": "text",
                    "spelling": " { "
                },
                {
                    "kind": "keyword",
                    "spelling": "mutating"
                },
                {
                    "kind": "text",
                    "spelling": " "
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

      final info = parsePropertyInfo(json);

      expect(info.getter, isTrue);
      expect(info.mutating, isTrue);
      expect(info.setter, isTrue);
    });

    test('Async Throws Get Variable', () {
      final json = Json(jsonDecode('''
[
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
                    "spelling": "computedAsyncThrowProperty"
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
                    "spelling": "async"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "keyword",
                    "spelling": "throws"
                },
                {
                    "kind": "text",
                    "spelling": " }"
                }
            ]'''));

      final info = parsePropertyInfo(json);

      expect(info.getter, isTrue);
      expect(info.async, isTrue);
      expect(info.throws, isTrue);
    });
  });
}
