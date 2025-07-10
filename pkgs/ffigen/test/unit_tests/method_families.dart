// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/objc_methods.dart';
import 'package:test/test.dart';

void main() {
  group('Method families', () {
    test('parsing', () {
      expect(ObjCMethodFamily.parse(''), null);
      expect(ObjCMethodFamily.parse('askljfha'), null);
      expect(ObjCMethodFamily.parse('myMethod'), null);

      expect(ObjCMethodFamily.parse('alloc'), ObjCMethodFamily.alloc);
      expect(ObjCMethodFamily.parse('init'), ObjCMethodFamily.init);
      expect(ObjCMethodFamily.parse('new'), ObjCMethodFamily.new_);
      expect(ObjCMethodFamily.parse('copy'), ObjCMethodFamily.copy);
      expect(
          ObjCMethodFamily.parse('mutableCopy'), ObjCMethodFamily.mutableCopy);

      expect(ObjCMethodFamily.parse('______alloc'), ObjCMethodFamily.alloc);
      expect(ObjCMethodFamily.parse('allocFoo'), ObjCMethodFamily.alloc);
      expect(ObjCMethodFamily.parse('_allocFooBar'), ObjCMethodFamily.alloc);

      expect(ObjCMethodFamily.parse('______mutableCopy'),
          ObjCMethodFamily.mutableCopy);
      expect(ObjCMethodFamily.parse('mutableCopyFoo'),
          ObjCMethodFamily.mutableCopy);
      expect(ObjCMethodFamily.parse('_mutableCopyFooBar'),
          ObjCMethodFamily.mutableCopy);

      expect(ObjCMethodFamily.parse('allocate'), null);
      expect(ObjCMethodFamily.parse('mutableCo'), null);
      expect(ObjCMethodFamily.parse('mutableCopyy'), null);

      expect(ObjCMethodFamily.parse('alloc123'), ObjCMethodFamily.alloc);
      expect(ObjCMethodFamily.parse('alloc_abc'), ObjCMethodFamily.alloc);
      expect(ObjCMethodFamily.parse('123alloc'), null);
      expect(ObjCMethodFamily.parse('abc_alloc'), null);
    });
  });
}
