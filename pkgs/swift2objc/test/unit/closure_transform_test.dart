// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/shared/parameter.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/members/method_declaration.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/_core/utils.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_function.dart';
import 'package:swift2objc/src/transformer/transformers/transform_referred_type.dart';
import 'package:test/test.dart';

void main() {
  test('transformReferredType preserves closure flags', () {
    final closure = ClosureType(
      parameters: [OptionalType(intType)],
      returnType: stringType,
      isEscaping: true,
      isSendable: true,
    );

    final state = TransformationState();
    final globalNamer = UniqueNamer();
    state.globalNamer = globalNamer;

    final transformed = transformReferredType(closure, globalNamer, state);

    expect(transformed, isA<ClosureType>());
    final transformedClosure = transformed as ClosureType;
    expect(transformedClosure.isEscaping, isTrue);
    expect(transformedClosure.isSendable, isTrue);
    expect(transformedClosure.returnType.sameAs(stringType), isTrue);
    expect(transformedClosure.parameters.single, isA<OptionalType>());
    expect(
      (transformedClosure.parameters.single as OptionalType).child,
      isA<DeclaredType>(),
    );
  });

  test('maybeWrapValue returns closure value unchanged', () {
    final closure = ClosureType(parameters: [intType], returnType: intType);

    final state = TransformationState();
    final globalNamer = UniqueNamer();
    state.globalNamer = globalNamer;

    final (wrappedValue, wrappedType) = maybeWrapValue(
      closure,
      'callback',
      globalNamer,
      state,
    );

    expect(wrappedValue, 'callback');
    expect(wrappedType.sameAs(closure), isTrue);
  });

  test('transformReferredType transforms nested closure tuple types', () {
    final closure = ClosureType(
      parameters: [
        TupleType([
          TupleElement(type: intType),
          TupleElement(type: stringType),
        ]),
      ],
      returnType: TupleType([
        TupleElement(type: intType),
        TupleElement(type: stringType),
      ]),
      isEscaping: true,
      isSendable: true,
      isAsync: true,
      isThrowing: true,
    );

    final state = TransformationState();
    final globalNamer = UniqueNamer();
    state.globalNamer = globalNamer;

    final transformed = transformReferredType(closure, globalNamer, state);

    expect(transformed, isA<ClosureType>());
    final transformedClosure = transformed as ClosureType;
    expect(transformedClosure.isEscaping, isTrue);
    expect(transformedClosure.isSendable, isTrue);
    expect(transformedClosure.isAsync, isTrue);
    expect(transformedClosure.isThrowing, isTrue);

    expect(transformedClosure.parameters.single is DeclaredType, isTrue);
    expect(transformedClosure.returnType is DeclaredType, isTrue);
    expect(state.tupleWrappers, isNotEmpty);
  });

  test('generateInvocationParams preserves @Sendable in adapted closures', () {
    final originalClosure = ClosureType(
      parameters: [intType],
      returnType: voidType,
      isSendable: true,
    );
    final transformedClosure = ClosureType(
      parameters: [intType],
      returnType: voidType,
    );

    final localNamer = UniqueNamer();
    final globalNamer = UniqueNamer();
    final state = TransformationState()..globalNamer = globalNamer;

    final invocation = generateInvocationParams(
      localNamer,
      [Parameter(name: 'callback', type: originalClosure)],
      [Parameter(name: 'callback', type: transformedClosure)],
      globalNamer,
      state,
    );

    expect(invocation, contains('@Sendable ('));
  });

  test(
    'generateInvocationParams skips closure thunk when closure types match',
    () {
      final closure = ClosureType(
        parameters: [intType],
        returnType: voidType,
        isSendable: true,
      );

      final localNamer = UniqueNamer();
      final globalNamer = UniqueNamer();
      final state = TransformationState()..globalNamer = globalNamer;

      final invocation = generateInvocationParams(
        localNamer,
        [Parameter(name: 'callback', type: closure)],
        [Parameter(name: 'callback', type: closure)],
        globalNamer,
        state,
      );

      expect(invocation, 'callback: callback');
    },
  );

  test(
    'generateInvocationParams adapts closure argument direction with wrap/unwrap',
    () {
      final originalClosure = ClosureType(
        parameters: [
          TupleType([TupleElement(type: intType)]),
        ],
        returnType: TupleType([TupleElement(type: intType)]),
      );

      final state = TransformationState();
      final globalNamer = UniqueNamer();
      state.globalNamer = globalNamer;
      final transformedClosure =
          transformReferredType(originalClosure, globalNamer, state)
              as ClosureType;

      final localNamer = UniqueNamer();
      final invocation = generateInvocationParams(
        localNamer,
        [Parameter(name: 'callback', type: originalClosure)],
        [Parameter(name: 'callback', type: transformedClosure)],
        globalNamer,
        state,
      );

      expect(invocation, contains('{ ('));
      expect(invocation, contains('wrappedInstance'));
    },
  );

  test('transformDeclaration accepts and returns closure', () {
    final originalClass = ClassDeclaration(
      id: 'Foo',
      name: 'Foo',
      source: null,
      availability: const [],
      methods: [
        MethodDeclaration(
          id: 'Foo.bar',
          name: 'bar',
          source: null,
          availability: const [],
          returnType: ClosureType(parameters: [intType], returnType: intType),
          params: [
            Parameter(
              name: 'callback',
              type: ClosureType(parameters: [intType], returnType: intType),
            ),
          ],
          isStatic: false,
        ),
      ],
    );

    final state = TransformationState();
    state.bindings.add(originalClass);
    final globalNamer = UniqueNamer();
    state.globalNamer = globalNamer;

    final transformed = transformDeclaration(originalClass, globalNamer, state);
    expect(transformed, isA<ClassDeclaration>());

    final transformedClass = transformed as ClassDeclaration;
    final transformedMethod = transformedClass.methods.singleWhere(
      (method) => method.name == 'bar',
    );

    expect(transformedMethod.params.single.type, isA<ClosureType>());
    expect(transformedMethod.returnType, isA<ClosureType>());
  });

  test(
    'generateInvocationParams does not emit @escaping for closure literals',
    () {
      final originalClosure = ClosureType(
        parameters: [intType],
        returnType: voidType,
        isEscaping: true,
        isSendable: true,
      );
      final transformedClosure = ClosureType(
        parameters: [intType],
        returnType: voidType,
        isSendable: true,
      );

      final localNamer = UniqueNamer();
      final globalNamer = UniqueNamer();
      final state = TransformationState()..globalNamer = globalNamer;

      final invocation = generateInvocationParams(
        localNamer,
        [Parameter(name: 'callback', type: originalClosure)],
        [Parameter(name: 'callback', type: transformedClosure)],
        globalNamer,
        state,
      );

      expect(invocation, isNot(contains('@escaping')));
      expect(invocation, contains('@Sendable ('));
    },
  );
}
