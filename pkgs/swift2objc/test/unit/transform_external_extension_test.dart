// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/extension_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/members/method_declaration.dart';
import 'package:swift2objc/src/config.dart';
import 'package:swift2objc/src/context.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/parse_declarations.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_extension.dart';
import 'package:test/test.dart';

void main() {
  test('external extension methods become static helper methods', () {
    const string = BuiltInDeclaration(id: 'String', name: 'String');
    const source = FilesInputConfig(files: []);
    final extension = ExtensionDeclaration(
      id: 'String-extension',
      name: 'String',
      source: source,
      availability: const [],
      extendedType: const DeclaredType(id: 'String', declaration: string),
      methods: [
        MethodDeclaration(
          id: 'String-isEmail',
          name: 'isEmail',
          source: null,
          availability: const [],
          returnType: boolType,
          params: const [],
        ),
      ],
    );
    final state = TransformationState()..globalNamer = UniqueNamer();

    final helper = transformExtension(extension, state.globalNamer, state);

    expect(helper, isA<ClassDeclaration>());
    final helperClass = helper! as ClassDeclaration;
    expect(helperClass.name, 'StringExtensions');
    expect(helperClass.wrappedInstance, isNull);
    final method = helperClass.methods.single;
    expect(method.isStatic, isTrue);
    expect(method.params.single.name, '_');
    expect(method.params.single.internalName, 'instance');
    expect(method.params.single.type.swiftType, 'String');
    expect(method.statements, ['return instance.isEmail()']);
  });

  test('built-in extension methods are ignored', () {
    const string = BuiltInDeclaration(id: 'String', name: 'String');
    final extension = ExtensionDeclaration(
      id: 'String-foundation-extension',
      name: 'String',
      source: builtInInputConfig,
      availability: const [],
      extendedType: const DeclaredType(id: 'String', declaration: string),
      methods: [
        MethodDeclaration(
          id: 'String-foundation-method',
          name: 'description',
          source: builtInInputConfig,
          availability: const [],
          returnType: stringType,
          params: const [],
        ),
      ],
    );
    final state = TransformationState()..globalNamer = UniqueNamer();

    expect(transformExtension(extension, state.globalNamer, state), isNull);
  });

  test(
    'external static extension methods do not receive an instance parameter',
    () {
      const string = BuiltInDeclaration(id: 'String', name: 'String');
      const source = FilesInputConfig(files: []);
      final extension = ExtensionDeclaration(
        id: 'String-static-extension',
        name: 'String',
        source: source,
        availability: const [],
        extendedType: const DeclaredType(id: 'String', declaration: string),
        methods: [
          MethodDeclaration(
            id: 'String-makeEmpty',
            name: 'makeEmpty',
            source: source,
            availability: const [],
            returnType: stringType,
            params: const [],
            isStatic: true,
          ),
        ],
      );
      final state = TransformationState()..globalNamer = UniqueNamer();

      final helper =
          transformExtension(extension, state.globalNamer, state)!
              as ClassDeclaration;
      final method = helper.methods.single;

      expect(method.params, isEmpty);
      expect(method.statements, ['return String.makeEmpty()']);
    },
  );

  test('external extension operators are ignored', () {
    const string = BuiltInDeclaration(id: 'String', name: 'String');
    const source = FilesInputConfig(files: []);
    final extension = ExtensionDeclaration(
      id: 'String-operator-extension',
      name: 'String',
      source: source,
      availability: const [],
      extendedType: const DeclaredType(id: 'String', declaration: string),
      methods: [
        MethodDeclaration(
          id: 'String-add',
          name: '+',
          source: source,
          availability: const [],
          returnType: stringType,
          params: const [],
          isOperator: true,
        ),
      ],
    );
    final state = TransformationState()..globalNamer = UniqueNamer();

    expect(transformExtension(extension, state.globalNamer, state), isNull);
  });

  test('parseDeclarations extracts extensions on built-in types', () {
    const inputConfig = FilesInputConfig(files: []);
    final methodSymbol = ParsedSymbol(
      source: inputConfig,
      json: Json(<String, dynamic>{
        'identifier': {'precise': 's:SS18symbolgraph_moduleE7isEmailSbyF'},
        'names': {
          'title': 'isEmail()',
          'subHeading': [
            {'kind': 'identifier', 'spelling': 'isEmail'},
          ],
        },
        'pathComponents': ['String', 'isEmail()'],
        'kind': {'identifier': 'swift.method'},
        'swiftExtension': {'extendedModule': 'Swift'},
        'declarationFragments': [
          {'kind': 'keyword', 'spelling': 'func'},
          {'kind': 'text', 'spelling': ' '},
          {'kind': 'identifier', 'spelling': 'isEmail'},
          {'kind': 'text', 'spelling': '() -> '},
          {
            'kind': 'typeIdentifier',
            'spelling': 'Bool',
            'preciseIdentifier': 's:Sb',
          },
        ],
        'functionSignature': {
          'returns': [
            {
              'kind': 'typeIdentifier',
              'preciseIdentifier': 's:Sb',
              'spelling': 'Bool',
            },
          ],
          'parameters': <dynamic>[],
        },
      }),
    );
    final symbolgraph = ParsedSymbolgraph(
      symbols: {
        ...ParsedSymbolgraph.builtInSymbolsMap(),
        's:SS18symbolgraph_moduleE7isEmailSbyF': methodSymbol,
      },
      relations: {
        's:SS': {
          'r1': ParsedRelation(
            source: inputConfig,
            kind: ParsedRelationKind.memberOf,
            sourceId: 's:SS18symbolgraph_moduleE7isEmailSbyF',
            targetId: 's:SS',
            json: Json(<String, dynamic>{}),
          ),
        },
      },
    );

    final context = Context(Logger.detached('test')..level = Level.OFF);
    final decls = parseDeclarations(context, symbolgraph);
    expect(decls.whereType<ExtensionDeclaration>(), isNotEmpty);
    final extDecl = decls.whereType<ExtensionDeclaration>().single;
    expect(extDecl.name, 'String');
    expect(extDecl.methods.single.name, 'isEmail');
  });
}
