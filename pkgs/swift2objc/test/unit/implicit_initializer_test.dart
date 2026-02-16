// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/members/initializer_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/members/property_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/struct_declaration.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_compound.dart';
import 'package:test/test.dart';

void main() {
  group('Implicit Initializer Generation', () {
    test('generates implicit init for struct with stored properties', () {
      final struct = StructDeclaration(
        id: 'TestStruct',
        name: 'Person',
        source: null,
        availability: [],
        properties: [
          PropertyDeclaration(
            id: 'TestStruct::name',
            name: 'name',
            lineNumber: 1,
            source: null,
            availability: [],
            type: stringType,
            hasSetter: true,
            isStatic: false,
          ),
          PropertyDeclaration(
            id: 'TestStruct::age',
            name: 'age',
            lineNumber: 2,
            source: null,
            availability: [],
            type: intType,
            hasSetter: true,
            isStatic: false,
          ),
        ],
        initializers: [],
      );

      final state = TransformationState();
      final result = transformCompound(struct, UniqueNamer(), state);

      expect(result.initializers.length, equals(1));
      expect(result.initializers.first.params.length, equals(2));
      expect(result.initializers.first.params[0].name, equals('name'));
      expect(result.initializers.first.params[1].name, equals('age'));
    });

    test('does not generate implicit init when explicit init exists', () {
      final struct = StructDeclaration(
        id: 'TestStruct',
        name: 'Person',
        source: null,
        availability: [],
        properties: [
          PropertyDeclaration(
            id: 'TestStruct::name',
            name: 'name',
            source: null,
            availability: [],
            type: stringType,
            hasSetter: true,
            isStatic: false,
          ),
        ],
        initializers: [
          // Has explicit initializer
          InitializerDeclaration(
            id: 'TestStruct::init',
            source: null,
            availability: [],
            params: [],
            hasObjCAnnotation: true,
            isOverriding: false,
            throws: false,
            async: false,
            isFailable: false,
          ),
        ],
      );

      final state = TransformationState();
      final result = transformCompound(struct, UniqueNamer(), state);

      expect(result.initializers.length, equals(1));
    });

    test('excludes static properties from implicit init', () {
      final struct = StructDeclaration(
        id: 'TestStruct',
        name: 'Config',
        source: null,
        availability: [],
        properties: [
          PropertyDeclaration(
            id: 'TestStruct::name',
            name: 'name',
            source: null,
            availability: [],
            type: stringType,
            hasSetter: true,
            isStatic: false,
          ),
          PropertyDeclaration(
            id: 'TestStruct::defaultName',
            name: 'defaultName',
            source: null,
            availability: [],
            type: stringType,
            hasSetter: true,
            isStatic: true,
          ),
        ],
        initializers: [],
      );

      final state = TransformationState();
      final result = transformCompound(struct, UniqueNamer(), state);

      expect(result.initializers.length, equals(1));
      expect(result.initializers.first.params.length, equals(1));
      expect(result.initializers.first.params[0].name, equals('name'));
    });

    test('excludes computed properties (no setter) from implicit init', () {
      final struct = StructDeclaration(
        id: 'TestStruct',
        name: 'Person',
        source: null,
        availability: [],
        properties: [
          PropertyDeclaration(
            id: 'TestStruct::firstName',
            name: 'firstName',
            source: null,
            availability: [],
            type: stringType,
            hasSetter: true,
            isStatic: false,
          ),
          PropertyDeclaration(
            id: 'TestStruct::fullName',
            name: 'fullName',
            source: null,
            availability: [],
            type: stringType,
            hasSetter: false,
            isStatic: false,
            hasExplicitGetter: true,
          ),
        ],
        initializers: [],
      );

      final state = TransformationState();
      final result = transformCompound(struct, UniqueNamer(), state);

      expect(result.initializers.length, equals(1));
      expect(result.initializers.first.params.length, equals(1));
      expect(result.initializers.first.params[0].name, equals('firstName'));
    });
  });
}
