// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/extension_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/members/method_declaration.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_extension.dart';
import 'package:test/test.dart';

void main() {
  test('external extension methods become static helper methods', () {
    const string = BuiltInDeclaration(id: 'String', name: 'String');
    final extension = ExtensionDeclaration(
      id: 'String-extension',
      name: 'String',
      source: null,
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
}
