// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart' as internal_for_testing
    show blockHasRegisteredClosure;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_annotation_bindings.dart';
import 'util.dart';

enum Type { object, block }
enum Definition { objC, fromFunction, listener }
enum Invocation { dart, objCSync, objCAsync }

void main() {
  late final BlockAnnotationTestLibrary lib;

  group('Block annotations', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/block_annotation_test.dylib');
      verifySetupFile(dylib);
      lib = BlockAnnotationTestLibrary(DynamicLibrary.open(dylib.absolute.path));

      // generateBindingsForCoverage('block_annotation');
    });

    // Set A: ((Block/Object arg) * (consumed/not consumed))
    // Set R: ((Block/Object ret) * (retained/not retained))
    // Set D: ((Dart fromFunction/ObjC) * (Set A/R)) + ((Dart listener) * (Set A))
    // Set I: (Invoked from (ObjC sync/async)/Dart) * Set D

    // Due to https://github.com/dart-lang/native/issues/1490 we can't directly
    // write blocks that return retain or consume args. Instead we create them
    // by writing a protocol with methods that retain or consume. Since
    // protocol methods are implemented as blocks, this implicitly generates
    // blocks with the same signatures. Unfortunately this means there's an
    // extra void* arg that we don't use, but we can just ignore it.
    //
    // This is also why the ObjC block creation functions need casts to the
    // correct block type.

    ObjCBlock<EmptyObject Function(Pointer<Void>)> newObjectProducer(
        Definition definition) {
      switch (definition) {
        case Definition.objC:
          return BlockAnnotationTest.newObjectProducer();
        case Definition.fromFunction:
          return ObjCBlock_EmptyObject_ffiVoid.fromFunction(
                  (Pointer<Void> _) => EmptyObject.alloc().init());
        default:
          throw UnsupportedError("Producers can't be listeners");
      }
    }

    ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> newObjectProducerRetained(
        Definition definition) {
      switch (definition) {
        case Definition.objC:
          return ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)>(BlockAnnotationTest.newObjectProducerRetained().pointer, retain: true, release: true);
        case Definition.fromFunction:
          return ObjCBlock_EmptyObject_ffiVoid1.fromFunction(
                  (Pointer<Void> _) => EmptyObject.alloc().init());
        default:
          throw UnsupportedError("Producers can't be listeners");
      }
    }

    ObjCBlock<EmptyBlock Function(Pointer<Void>)> newBlockProducer(
        Definition definition) {
      switch (definition) {
        case Definition.objC:
          return BlockAnnotationTest.newBlockProducer();
        case Definition.fromFunction:
          return ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
                  (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        default:
          throw UnsupportedError("Producers can't be listeners");
      }
    }

    ObjCBlock<Retained<EmptyBlock> Function(Pointer<Void>)> newBlockProducerRetained(
        Definition definition) {
      switch (definition) {
        case Definition.objC:
          return ObjCBlock<Retained<EmptyBlock> Function(Pointer<Void>)>(BlockAnnotationTest.newBlockProducerRetained().pointer, retain: true, release: true);
        case Definition.fromFunction:
          return ObjCBlock_EmptyBlock_ffiVoid1.fromFunction(
                  (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        default:
          throw UnsupportedError("Producers can't be listeners");
      }
    }

    ObjCBlock newProducer(Definition definition, Type type, bool retained) {
      switch (type) {
        case Type.object:
          return retained ?
              newObjectProducerRetained(definition) :
              newObjectProducer(definition);
        case Type.block:
          return retained ?
              newBlockProducerRetained(definition) :
              newBlockProducer(definition);
      }
    }

    void runProducerTest<T>(Definition definition, Type type, bool retained, Invocation invocation) {
      test('', () {
        final pool = lib.objc_autoreleasePoolPush();
        final block = newProducer(definition, type, retained);
        T? obj = block(nullptr) as T;
        final obj1raw = obj.pointer;
        lib.objc_autoreleasePoolPop(pool);
        doGC();
        expect(objectRetainCount(obj1raw), 1);
        expect(obj, isNotNull);
        obj = null;
        doGC();
        expect(objectRetainCount(obj1raw), 0);
      });
    }

    // Producer tests.
    for (final definition in [Definition.objC, Definition.fromFunction]) {
      for (final invocation in [Invocation.dart, Invocation.objCSync]) {
        runProducerTest<ObjCBlock<EmptyObject Function(Pointer<Void>)>>(definition, Type.object, false, invocation);
        runProducerTest<ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)>>(definition, Type.object, true, invocation);
        runProducerTest<ObjCBlock<EmptyBlock Function(Pointer<Void>)>>(definition, Type.block, false, invocation);
        runProducerTest<ObjCBlock<Retained<EmptyBlock> Function(Pointer<Void>)>>(definition, Type.block, true, invocation);
      }
    }

    test('Object producer, no retain, fromFunction created, Dart invoked', () {
      final pool = lib.objc_autoreleasePoolPush();
      final block = ObjCBlock_EmptyObject_ffiVoid.fromFunction(
          (Pointer<Void> _) => EmptyObject.alloc().init());
      EmptyObject? obj = block(nullptr);
      final obj1raw = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(obj1raw), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(obj1raw), 0);
    });

    test('Object producer, no retain, fromFunction created, ObjC sync invoked', () {
      final pool = lib.objc_autoreleasePoolPush();
      final block = ObjCBlock_EmptyObject_ffiVoid.fromFunction(
          (Pointer<Void> _) => EmptyObject.alloc().init());
      EmptyObject? obj = block(nullptr);
      final obj1raw = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(obj1raw), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(obj1raw), 0);
    });

    test('Object producer, no retain, ObjC created, Dart invoked', () {
      final pool = lib.objc_autoreleasePoolPush();
      final block = BlockAnnotationTest.newObjectProducer();
      EmptyObject? obj = block(nullptr);
      final obj1raw = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(obj1raw), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(obj1raw), 0);
    });
  });
}
