// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Typealias NativeFunc', () {
    test('creates companion Function typedef for NativeFunc', () {
      final funcType = FunctionType(
        returnType: voidType,
        parameters: [Parameter(type: intType, name: 'a', objCConsumed: false)],
      );
      final nativeFunc = NativeFunc(funcType);
      final typealias = Typealias(name: 'MyFunc', type: nativeFunc);

      expect(typealias.originalName, 'MyFunc');
      expect(typealias.type, isA<NativeFunc>());

      final newNativeFunc = typealias.type as NativeFunc;
      expect(newNativeFunc.innerType, isA<Typealias>());

      final companion = newNativeFunc.innerType as Typealias;
      expect(companion.originalName, 'MyFuncFunction');
      expect(companion.type, funcType);
    });

    test('creates companion Function typedef for Pointer<NativeFunc>', () {
      final funcType = FunctionType(
        returnType: voidType,
        parameters: [Parameter(type: intType, name: 'a', objCConsumed: false)],
      );
      final pointerType = PointerType(NativeFunc(funcType));
      final typealias = Typealias(name: 'MyFuncPtr', type: pointerType);

      expect(typealias.originalName, 'MyFuncPtr');
      expect(typealias.type, isA<PointerType>());

      final ptr = typealias.type as PointerType;
      expect(ptr.child, isA<NativeFunc>());

      final newNativeFunc = ptr.child as NativeFunc;
      expect(newNativeFunc.innerType, isA<Typealias>());

      final companion = newNativeFunc.innerType as Typealias;
      expect(companion.originalName, 'MyFuncPtrFunction');
      expect(companion.type, funcType);
    });

    test(
      'does not duplicate companion if NativeFunc already contains Typealias',
      () {
        final funcType = FunctionType(returnType: voidType, parameters: []);
        final firstAlias = Typealias(
          name: 'FirstFunc',
          type: NativeFunc(funcType),
        );
        final secondAlias = Typealias(name: 'SecondFunc', type: firstAlias);

        expect(secondAlias.originalName, 'SecondFunc');
        expect(secondAlias.type, firstAlias);
      },
    );
  });
}
