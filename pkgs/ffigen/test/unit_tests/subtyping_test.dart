// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('subtyping', () {
    final builtInFunctions = ObjCBuiltInFunctions('', false);

    ObjCInterface makeInterface(String name, ObjCInterface? superType,
        [List<ObjCMethod> methods = const []]) {
      final itf = ObjCInterface(
        usr: name,
        originalName: name,
        builtInFunctions: builtInFunctions,
      );
      if (superType != null) {
        itf.superType = superType;
        superType.subtypes.add(itf);
      }
      for (final m in methods) {
        itf.addMethod(m);
      }
      itf.filled = true;
      return itf;
    }

    final grandparent = makeInterface('Grandparent', null);
    final parent = makeInterface('Parent', grandparent);
    final uncle = makeInterface('Uncle', grandparent);
    final child = makeInterface('Child', parent);

    group('ObjCInterface', () {
      test('subtype', () {
        expect(parent.isSubtypeOf(parent), isTrue);
        expect(child.isSubtypeOf(child), isTrue);

        expect(parent.isSubtypeOf(grandparent), isTrue);
        expect(grandparent.isSubtypeOf(parent), isFalse);

        expect(child.isSubtypeOf(grandparent), isTrue);
        expect(grandparent.isSubtypeOf(child), isFalse);

        expect(child.isSubtypeOf(uncle), isFalse);
        expect(uncle.isSubtypeOf(child), isFalse);
      });

      test('supertype', () {
        expect(parent.isSupertypeOf(parent), isTrue);
        expect(child.isSupertypeOf(child), isTrue);

        expect(parent.isSupertypeOf(grandparent), isFalse);
        expect(grandparent.isSupertypeOf(parent), isTrue);

        expect(child.isSupertypeOf(grandparent), isFalse);
        expect(grandparent.isSupertypeOf(child), isTrue);

        expect(child.isSupertypeOf(uncle), isFalse);
        expect(uncle.isSupertypeOf(child), isFalse);
      });
    });

    group('FunctionType', () {
      FunctionType makeFunc(Type returnType, List<Type> argTypes) =>
          FunctionType(returnType: returnType, parameters: [
            for (final t in argTypes) Parameter(type: t, objCConsumed: false),
          ]);

      test('covariant returns', () {
        // Return types are covariant. S Function() <: T Function() if S <: T.
        final returnsParent = makeFunc(parent, []);
        final returnsChild = makeFunc(child, []);

        expect(returnsParent.isSubtypeOf(returnsParent), isTrue);
        expect(returnsChild.isSubtypeOf(returnsChild), isTrue);
        expect(returnsChild.isSubtypeOf(returnsParent), isTrue);
        expect(returnsParent.isSubtypeOf(returnsChild), isFalse);
      });

      test('contravariant args', () {
        // Arg types are contravariant. Function(S) <: Function(T) if T <: S.
        final acceptsParent = makeFunc(voidType, [parent]);
        final acceptsChild = makeFunc(voidType, [child]);

        expect(acceptsParent.isSubtypeOf(acceptsParent), isTrue);
        expect(acceptsChild.isSubtypeOf(acceptsChild), isTrue);
        expect(acceptsChild.isSubtypeOf(acceptsParent), isFalse);
        expect(acceptsParent.isSubtypeOf(acceptsChild), isTrue);
      });

      test('multiple args', () {
        expect(
            makeFunc(voidType, [parent, parent])
                .isSubtypeOf(makeFunc(voidType, [parent, parent])),
            isTrue);
        expect(
            makeFunc(voidType, [parent, parent])
                .isSubtypeOf(makeFunc(voidType, [child, child])),
            isTrue);
        expect(
            makeFunc(voidType, [child, child])
                .isSubtypeOf(makeFunc(voidType, [parent, parent])),
            isFalse);
        expect(
            makeFunc(voidType, [child, parent])
                .isSubtypeOf(makeFunc(voidType, [parent, child])),
            isFalse);
        expect(
            makeFunc(voidType, [parent, parent, parent])
                .isSubtypeOf(makeFunc(voidType, [child, child])),
            isFalse);
        expect(
            makeFunc(voidType, [parent])
                .isSubtypeOf(makeFunc(voidType, [child, child])),
            isFalse);
      });

      test('args and returns', () {
        expect(makeFunc(child, [parent]).isSubtypeOf(makeFunc(parent, [child])),
            isTrue);
        expect(makeFunc(parent, [parent]).isSubtypeOf(makeFunc(child, [child])),
            isFalse);
        expect(makeFunc(child, [child]).isSubtypeOf(makeFunc(parent, [parent])),
            isFalse);
        expect(makeFunc(parent, [child]).isSubtypeOf(makeFunc(child, [parent])),
            isFalse);
      });

      test('NativeFunc', () {
        final returnsParent = NativeFunc(makeFunc(parent, []));
        final returnsChild = NativeFunc(makeFunc(child, []));

        expect(returnsParent.isSubtypeOf(returnsParent), isTrue);
        expect(returnsChild.isSubtypeOf(returnsChild), isTrue);
        expect(returnsChild.isSubtypeOf(returnsParent), isTrue);
        expect(returnsParent.isSubtypeOf(returnsChild), isFalse);
      });
    });

    group('ObjCBlock', () {
      ObjCBlock makeBlock(Type returnType, List<Type> argTypes) => ObjCBlock(
          returnType: returnType,
          params: [
            for (final t in argTypes) Parameter(type: t, objCConsumed: false),
          ],
          returnsRetained: false,
          builtInFunctions: builtInFunctions);

      test('covariant returns', () {
        // Return types are covariant. S Function() <: T Function() if S <: T.
        final returnsParent = makeBlock(parent, []);
        final returnsChild = makeBlock(child, []);

        expect(returnsParent.isSubtypeOf(returnsParent), isTrue);
        expect(returnsChild.isSubtypeOf(returnsChild), isTrue);
        expect(returnsChild.isSubtypeOf(returnsParent), isTrue);
        expect(returnsParent.isSubtypeOf(returnsChild), isFalse);
      });

      test('contravariant args', () {
        // Arg types are contravariant. Function(S) <: Function(T) if T <: S.
        final acceptsParent = makeBlock(voidType, [parent]);
        final acceptsChild = makeBlock(voidType, [child]);

        expect(acceptsParent.isSubtypeOf(acceptsParent), isTrue);
        expect(acceptsChild.isSubtypeOf(acceptsChild), isTrue);
        expect(acceptsChild.isSubtypeOf(acceptsParent), isFalse);
        expect(acceptsParent.isSubtypeOf(acceptsChild), isTrue);
      });

      test('multiple args', () {
        expect(
            makeBlock(voidType, [parent, parent])
                .isSubtypeOf(makeBlock(voidType, [parent, parent])),
            isTrue);
        expect(
            makeBlock(voidType, [parent, parent])
                .isSubtypeOf(makeBlock(voidType, [child, child])),
            isTrue);
        expect(
            makeBlock(voidType, [child, child])
                .isSubtypeOf(makeBlock(voidType, [parent, parent])),
            isFalse);
        expect(
            makeBlock(voidType, [child, parent])
                .isSubtypeOf(makeBlock(voidType, [parent, child])),
            isFalse);
        expect(
            makeBlock(voidType, [parent, parent, parent])
                .isSubtypeOf(makeBlock(voidType, [child, child])),
            isFalse);
        expect(
            makeBlock(voidType, [parent])
                .isSubtypeOf(makeBlock(voidType, [child, child])),
            isFalse);
      });

      test('args and returns', () {
        expect(
            makeBlock(child, [parent]).isSubtypeOf(makeBlock(parent, [child])),
            isTrue);
        expect(
            makeBlock(parent, [parent]).isSubtypeOf(makeBlock(child, [child])),
            isFalse);
        expect(
            makeBlock(child, [child]).isSubtypeOf(makeBlock(parent, [parent])),
            isFalse);
        expect(
            makeBlock(parent, [child]).isSubtypeOf(makeBlock(child, [parent])),
            isFalse);
      });
    });

    test('ObjCNullable', () {
      expect(ObjCNullable(parent).isSubtypeOf(ObjCNullable(parent)), isTrue);
      expect(ObjCNullable(child).isSubtypeOf(ObjCNullable(parent)), isTrue);
      expect(ObjCNullable(parent).isSubtypeOf(ObjCNullable(child)), isFalse);
      expect(parent.isSubtypeOf(ObjCNullable(parent)), isTrue);
      expect(ObjCNullable(parent).isSubtypeOf(parent), isFalse);
      expect(child.isSubtypeOf(ObjCNullable(parent)), isTrue);
      expect(ObjCNullable(child).isSubtypeOf(parent), isFalse);
      expect(ObjCNullable(parent).isSubtypeOf(child), isFalse);
      expect(parent.isSubtypeOf(ObjCNullable(child)), isFalse);
    });

    test('Typealias', () {
      Typealias makeTypealias(Type t) => Typealias(name: '', type: t);
      expect(makeTypealias(parent).isSubtypeOf(makeTypealias(parent)), isTrue);
      expect(makeTypealias(child).isSubtypeOf(makeTypealias(parent)), isTrue);
      expect(makeTypealias(parent).isSubtypeOf(makeTypealias(child)), isFalse);
      expect(parent.isSubtypeOf(makeTypealias(parent)), isTrue);
      expect(makeTypealias(parent).isSubtypeOf(parent), isTrue);
      expect(child.isSubtypeOf(makeTypealias(parent)), isTrue);
      expect(makeTypealias(child).isSubtypeOf(parent), isTrue);
      expect(makeTypealias(parent).isSubtypeOf(child), isFalse);
      expect(parent.isSubtypeOf(makeTypealias(child)), isFalse);
    });
  });
}
