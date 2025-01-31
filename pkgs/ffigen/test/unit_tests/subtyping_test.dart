// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('subtyping', () {
    final builtInFunctions = ObjCBuiltInFunctions('', false);

    ObjCInterface makeInterface(
        String name, ObjCInterface? superType, List<ObjCProtocol> protocols) {
      final itf = ObjCInterface(
        usr: name,
        originalName: name,
        builtInFunctions: builtInFunctions,
      );
      if (superType != null) {
        itf.superType = superType;
        superType.subtypes.add(itf);
      }
      for (final p in protocols) {
        itf.addProtocol(p);
      }
      itf.filled = true;
      return itf;
    }

    ObjCProtocol makeProtocol(String name, List<ObjCProtocol> superProtocols) {
      final proto = ObjCProtocol(
        usr: name,
        originalName: name,
        builtInFunctions: builtInFunctions,
      );
      proto.superProtocols.addAll(superProtocols);
      return proto;
    }

    final proto1 = makeProtocol('Proto1', []);
    final proto2 = makeProtocol('Proto2', []);
    final proto3 = makeProtocol('Proto3', []);
    final proto4 = makeProtocol('Proto4', []);
    final protoSub1 = makeProtocol('ProtoSub1', [proto1]);
    final protoSub12 = makeProtocol('ProtoSub12', [protoSub1, proto2]);

    final grandparent = makeInterface('Grandparent', null, [protoSub12]);
    final parent = makeInterface('Parent', grandparent, [protoSub1, proto3]);
    final uncle = makeInterface('Uncle', grandparent, [proto1, proto3]);
    final child = makeInterface('Child', parent, [proto1, proto4]);

    ObjCBlock makeBlock(Type returnType, List<Type> argTypes) => ObjCBlock(
        returnType: returnType,
        params: [
          for (final t in argTypes) Parameter(type: t, objCConsumed: false),
        ],
        returnsRetained: false,
        builtInFunctions: builtInFunctions);

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

    group('ObjCProtocol', () {
      test('subtype', () {
        expect(protoSub1.isSubtypeOf(protoSub1), isTrue);
        expect(proto3.isSubtypeOf(proto3), isTrue);

        expect(protoSub12.isSubtypeOf(protoSub1), isTrue);
        expect(protoSub1.isSubtypeOf(protoSub12), isFalse);

        expect(protoSub12.isSubtypeOf(proto1), isTrue);
        expect(proto1.isSubtypeOf(protoSub12), isFalse);

        expect(protoSub12.isSubtypeOf(proto2), isTrue);
        expect(proto2.isSubtypeOf(protoSub12), isFalse);

        expect(protoSub1.isSubtypeOf(proto2), isFalse);
        expect(proto2.isSubtypeOf(protoSub1), isFalse);

        expect(proto1.isSubtypeOf(proto3), isFalse);
        expect(proto3.isSubtypeOf(proto1), isFalse);
      });

      test('supertype', () {
        expect(protoSub1.isSupertypeOf(protoSub1), isTrue);
        expect(proto3.isSupertypeOf(proto3), isTrue);

        expect(protoSub12.isSupertypeOf(protoSub1), isFalse);
        expect(protoSub1.isSupertypeOf(protoSub12), isTrue);

        expect(protoSub12.isSupertypeOf(proto1), isFalse);
        expect(proto1.isSupertypeOf(protoSub12), isTrue);

        expect(protoSub12.isSupertypeOf(proto2), isFalse);
        expect(proto2.isSupertypeOf(protoSub12), isTrue);

        expect(protoSub1.isSupertypeOf(proto2), isFalse);
        expect(proto2.isSupertypeOf(protoSub1), isFalse);

        expect(proto1.isSupertypeOf(proto3), isFalse);
        expect(proto3.isSupertypeOf(proto1), isFalse);
      });

      test('loop', () {
        final loop = ObjCProtocol(
          usr: 'Loop',
          originalName: 'Loop',
          builtInFunctions: builtInFunctions,
        );
        loop.superProtocols.add(loop);

        expect(loop.isSupertypeOf(loop), isTrue);
        expect(loop.isSupertypeOf(proto1), isFalse);
        expect(proto1.isSupertypeOf(loop), isFalse);
      });

      test('vs ObjCInterface', () {
        expect(grandparent.isSubtypeOf(protoSub12), isTrue);
        expect(grandparent.isSubtypeOf(protoSub1), isTrue);
        expect(grandparent.isSubtypeOf(proto1), isTrue);
        expect(grandparent.isSubtypeOf(proto2), isTrue);
        expect(grandparent.isSubtypeOf(proto3), isFalse);
        expect(grandparent.isSubtypeOf(proto4), isFalse);

        expect(parent.isSubtypeOf(protoSub12), isTrue);
        expect(parent.isSubtypeOf(protoSub1), isTrue);
        expect(parent.isSubtypeOf(proto1), isTrue);
        expect(parent.isSubtypeOf(proto2), isTrue);
        expect(parent.isSubtypeOf(proto3), isTrue);
        expect(parent.isSubtypeOf(proto4), isFalse);

        expect(uncle.isSubtypeOf(protoSub12), isTrue);
        expect(uncle.isSubtypeOf(protoSub1), isTrue);
        expect(uncle.isSubtypeOf(proto1), isTrue);
        expect(uncle.isSubtypeOf(proto2), isTrue);
        expect(uncle.isSubtypeOf(proto3), isTrue);
        expect(uncle.isSubtypeOf(proto4), isFalse);

        expect(child.isSubtypeOf(protoSub12), isTrue);
        expect(child.isSubtypeOf(protoSub1), isTrue);
        expect(child.isSubtypeOf(proto1), isTrue);
        expect(child.isSubtypeOf(proto2), isTrue);
        expect(child.isSubtypeOf(proto3), isTrue);
        expect(child.isSubtypeOf(proto4), isTrue);

        // Protocols are never subtypes of interfaces.
        expect(protoSub12.isSubtypeOf(grandparent), isFalse);
        expect(protoSub1.isSubtypeOf(grandparent), isFalse);
        expect(proto1.isSubtypeOf(grandparent), isFalse);
        expect(proto2.isSubtypeOf(grandparent), isFalse);
        expect(proto3.isSubtypeOf(grandparent), isFalse);
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

    test('ObjCObjectPointer', () {
      expect(ObjCObjectPointer().isSubtypeOf(ObjCObjectPointer()), isTrue);
      expect(parent.isSubtypeOf(ObjCObjectPointer()), isTrue);
      expect(ObjCObjectPointer().isSubtypeOf(parent), isFalse);

      final block = makeBlock(voidType, []);
      expect(block.isSubtypeOf(ObjCObjectPointer()), isTrue);
      expect(ObjCObjectPointer().isSubtypeOf(block), isFalse);
    });

    test('ObjCBlockPointer', () {
      expect(ObjCBlockPointer().isSubtypeOf(ObjCBlockPointer()), isTrue);
      expect(parent.isSubtypeOf(ObjCBlockPointer()), isFalse);
      expect(ObjCBlockPointer().isSubtypeOf(parent), isFalse);

      final block = makeBlock(voidType, []);
      expect(block.isSubtypeOf(ObjCBlockPointer()), isTrue);
      expect(ObjCBlockPointer().isSubtypeOf(block), isFalse);
    });

    test('ObjCObjectPointerWithProtocols', () {
      final idP1 = ObjCObjectPointerWithProtocols([proto1]);
      final idP2 = ObjCObjectPointerWithProtocols([proto2]);
      final idP1P2 = ObjCObjectPointerWithProtocols([proto1, proto2]);
      final idP2P1 = ObjCObjectPointerWithProtocols([proto2, proto1]);
      final idPSub1 = ObjCObjectPointerWithProtocols([protoSub1]);
      final idPSub12 = ObjCObjectPointerWithProtocols([protoSub12]);

      expect(idP1.isSubtypeOf(idP1), isTrue);
      expect(idP1.isSubtypeOf(idP2), isFalse);
      expect(idP2.isSubtypeOf(idP1), isFalse);

      expect(idP1P2.isSubtypeOf(idP1), isTrue);
      expect(idP1.isSubtypeOf(idP1P2), isTrue);
      expect(idP1P2.isSubtypeOf(idP2), isFalse);
      expect(idP1P2.isSubtypeOf(idP2P1), isFalse);
      expect(idP2P1.isSubtypeOf(idP2), isTrue);
      expect(idP2.isSubtypeOf(idP2P1), isTrue);

      expect(idPSub1.isSubtypeOf(idP1), isTrue);
      expect(idP1.isSubtypeOf(idPSub1), isFalse);
      expect(idPSub12.isSubtypeOf(idP1), isTrue);
      expect(idPSub12.isSubtypeOf(idP2), isTrue);
      expect(idP1.isSubtypeOf(idPSub12), isFalse);
      expect(idP2.isSubtypeOf(idPSub12), isFalse);

      expect(ObjCObjectPointer().isSubtypeOf(idP1), isFalse);
      expect(idP1.isSubtypeOf(ObjCObjectPointer()), isTrue);
    });
  });
}
