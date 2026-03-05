// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/_core/utils.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_referred_type.dart';
import 'package:test/test.dart';

void main() {
  test('transformReferredType keeps closure type unchanged', () {
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

    expect(transformed.sameAs(closure), isTrue);
    expect(transformed, isA<ClosureType>());
    final transformedClosure = transformed as ClosureType;
    expect(transformedClosure.isEscaping, isTrue);
    expect(transformedClosure.isSendable, isTrue);
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

}
