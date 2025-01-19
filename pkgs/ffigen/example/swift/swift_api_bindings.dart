// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: camel_case_types, non_constant_identifier_names
// ignore_for_file: unused_element, unused_field, return_of_invalid_type
// ignore_for_file: void_checks, annotate_overrides
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: library_private_types_in_public_api

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'package:objective_c/objective_c.dart' as objc;
import 'dart:ffi' as ffi;

late final _class_SwiftClass = objc.getClass("swift_module.SwiftClass");
late final _sel_isKindOfClass_ = objc.registerName("isKindOfClass:");
final _objc_msgSend_19nvye5 = objc.msgSendPointer
    .cast<
        ffi.NativeFunction<
            ffi.Bool Function(
                ffi.Pointer<objc.ObjCObject>,
                ffi.Pointer<objc.ObjCSelector>,
                ffi.Pointer<objc.ObjCObject>)>>()
    .asFunction<
        bool Function(ffi.Pointer<objc.ObjCObject>,
            ffi.Pointer<objc.ObjCSelector>, ffi.Pointer<objc.ObjCObject>)>();
late final _sel_sayHello = objc.registerName("sayHello");
final _objc_msgSend_151sglz = objc.msgSendPointer
    .cast<
        ffi.NativeFunction<
            ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<objc.ObjCObject>,
                ffi.Pointer<objc.ObjCSelector>)>>()
    .asFunction<
        ffi.Pointer<objc.ObjCObject> Function(
            ffi.Pointer<objc.ObjCObject>, ffi.Pointer<objc.ObjCSelector>)>();
late final _sel_someField = objc.registerName("someField");
final _objc_msgSend_1hz7y9r = objc.msgSendPointer
    .cast<
        ffi.NativeFunction<
            ffi.Long Function(ffi.Pointer<objc.ObjCObject>,
                ffi.Pointer<objc.ObjCSelector>)>>()
    .asFunction<
        int Function(
            ffi.Pointer<objc.ObjCObject>, ffi.Pointer<objc.ObjCSelector>)>();
late final _sel_setSomeField_ = objc.registerName("setSomeField:");
final _objc_msgSend_4sp4xj = objc.msgSendPointer
    .cast<
        ffi.NativeFunction<
            ffi.Void Function(ffi.Pointer<objc.ObjCObject>,
                ffi.Pointer<objc.ObjCSelector>, ffi.Long)>>()
    .asFunction<
        void Function(ffi.Pointer<objc.ObjCObject>,
            ffi.Pointer<objc.ObjCSelector>, int)>();
typedef instancetype = ffi.Pointer<objc.ObjCObject>;
typedef Dartinstancetype = objc.ObjCObjectBase;
late final _sel_init = objc.registerName("init");
late final _sel_new = objc.registerName("new");
late final _sel_allocWithZone_ = objc.registerName("allocWithZone:");
final _objc_msgSend_1cwp428 = objc.msgSendPointer
    .cast<
        ffi.NativeFunction<
            ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<objc.ObjCObject>,
                ffi.Pointer<objc.ObjCSelector>, ffi.Pointer<objc.NSZone>)>>()
    .asFunction<
        ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<objc.ObjCObject>,
            ffi.Pointer<objc.ObjCSelector>, ffi.Pointer<objc.NSZone>)>();
late final _sel_alloc = objc.registerName("alloc");
late final _sel_self = objc.registerName("self");
ffi.Pointer<objc.ObjCObject> _ObjCBlock_objcObjCObject_ffiVoid_fnPtrTrampoline(
        ffi.Pointer<objc.ObjCBlockImpl> block, ffi.Pointer<ffi.Void> arg0) =>
    block.ref.target
        .cast<
            ffi.NativeFunction<
                ffi.Pointer<objc.ObjCObject> Function(
                    ffi.Pointer<ffi.Void> arg0)>>()
        .asFunction<
            ffi.Pointer<objc.ObjCObject> Function(
                ffi.Pointer<ffi.Void>)>()(arg0);
ffi.Pointer<ffi.Void> _ObjCBlock_objcObjCObject_ffiVoid_fnPtrCallable =
    ffi.Pointer.fromFunction<
                ffi.Pointer<objc.ObjCObject> Function(
                    ffi.Pointer<objc.ObjCBlockImpl>, ffi.Pointer<ffi.Void>)>(
            _ObjCBlock_objcObjCObject_ffiVoid_fnPtrTrampoline)
        .cast();
ffi.Pointer<objc.ObjCObject>
    _ObjCBlock_objcObjCObject_ffiVoid_closureTrampoline(
            ffi.Pointer<objc.ObjCBlockImpl> block,
            ffi.Pointer<ffi.Void> arg0) =>
        (objc.getBlockClosure(block) as ffi.Pointer<objc.ObjCObject> Function(
            ffi.Pointer<ffi.Void>))(arg0);
ffi.Pointer<ffi.Void> _ObjCBlock_objcObjCObject_ffiVoid_closureCallable =
    ffi.Pointer.fromFunction<
                ffi.Pointer<objc.ObjCObject> Function(
                    ffi.Pointer<objc.ObjCBlockImpl>, ffi.Pointer<ffi.Void>)>(
            _ObjCBlock_objcObjCObject_ffiVoid_closureTrampoline)
        .cast();

/// Construction methods for `objc.ObjCBlock<ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>`.
abstract final class ObjCBlock_objcObjCObject_ffiVoid {
  /// Returns a block that wraps the given raw block pointer.
  static objc
      .ObjCBlock<ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>
      castFromPointer(ffi.Pointer<objc.ObjCBlockImpl> pointer,
              {bool retain = false, bool release = false}) =>
          objc.ObjCBlock<
                  ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>(
              pointer,
              retain: retain,
              release: release);

  /// Creates a block from a C function pointer.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  static objc.ObjCBlock<ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>
      fromFunctionPointer(
              ffi.Pointer<
                      ffi.NativeFunction<
                          ffi.Pointer<objc.ObjCObject> Function(
                              ffi.Pointer<ffi.Void> arg0)>>
                  ptr) =>
          objc.ObjCBlock<ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>(
              objc.newPointerBlock(_ObjCBlock_objcObjCObject_ffiVoid_fnPtrCallable, ptr.cast()),
              retain: false,
              release: true);

  /// Creates a block from a Dart function.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  static objc
      .ObjCBlock<ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>
      fromFunction(objc.ObjCObjectBase Function(ffi.Pointer<ffi.Void>) fn) =>
          objc.ObjCBlock<
                  ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>(
              objc.newClosureBlock(
                  _ObjCBlock_objcObjCObject_ffiVoid_closureCallable,
                  (ffi.Pointer<ffi.Void> arg0) =>
                      fn(arg0).ref.retainAndAutorelease()),
              retain: false,
              release: true);
}

/// Call operator for `objc.ObjCBlock<ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)>`.
extension ObjCBlock_objcObjCObject_ffiVoid_CallExtension on objc
    .ObjCBlock<ffi.Pointer<objc.ObjCObject> Function(ffi.Pointer<ffi.Void>)> {
  objc.ObjCObjectBase call(ffi.Pointer<ffi.Void> arg0) => objc.ObjCObjectBase(
      ref.pointer.ref.invoke
          .cast<
              ffi.NativeFunction<
                  ffi.Pointer<objc.ObjCObject> Function(
                      ffi.Pointer<objc.ObjCBlockImpl> block,
                      ffi.Pointer<ffi.Void> arg0)>>()
          .asFunction<
              ffi.Pointer<objc.ObjCObject> Function(
                  ffi.Pointer<objc.ObjCBlockImpl>,
                  ffi.Pointer<ffi.Void>)>()(ref.pointer, arg0),
      retain: true,
      release: true);
}

late final _sel_retain = objc.registerName("retain");
late final _sel_autorelease = objc.registerName("autorelease");

/// SwiftClass
class SwiftClass extends objc.NSObject {
  SwiftClass._(ffi.Pointer<objc.ObjCObject> pointer,
      {bool retain = false, bool release = false})
      : super.castFromPointer(pointer, retain: retain, release: release);

  /// Constructs a [SwiftClass] that points to the same underlying object as [other].
  SwiftClass.castFrom(objc.ObjCObjectBase other)
      : this._(other.ref.pointer, retain: true, release: true);

  /// Constructs a [SwiftClass] that wraps the given raw object pointer.
  SwiftClass.castFromPointer(ffi.Pointer<objc.ObjCObject> other,
      {bool retain = false, bool release = false})
      : this._(other, retain: retain, release: release);

  /// Returns whether [obj] is an instance of [SwiftClass].
  static bool isInstance(objc.ObjCObjectBase obj) {
    return _objc_msgSend_19nvye5(
        obj.ref.pointer, _sel_isKindOfClass_, _class_SwiftClass);
  }

  /// sayHello
  objc.NSString sayHello() {
    final _ret = _objc_msgSend_151sglz(this.ref.pointer, _sel_sayHello);
    return objc.NSString.castFromPointer(_ret, retain: true, release: true);
  }

  /// someField
  int get someField {
    return _objc_msgSend_1hz7y9r(this.ref.pointer, _sel_someField);
  }

  /// setSomeField:
  set someField(int value) {
    _objc_msgSend_4sp4xj(this.ref.pointer, _sel_setSomeField_, value);
  }

  /// init
  SwiftClass init() {
    final _ret =
        _objc_msgSend_151sglz(this.ref.retainAndReturnPointer(), _sel_init);
    return SwiftClass.castFromPointer(_ret, retain: false, release: true);
  }

  /// new
  static SwiftClass new1() {
    final _ret = _objc_msgSend_151sglz(_class_SwiftClass, _sel_new);
    return SwiftClass.castFromPointer(_ret, retain: false, release: true);
  }

  /// allocWithZone:
  static SwiftClass allocWithZone_(ffi.Pointer<objc.NSZone> zone) {
    final _ret =
        _objc_msgSend_1cwp428(_class_SwiftClass, _sel_allocWithZone_, zone);
    return SwiftClass.castFromPointer(_ret, retain: false, release: true);
  }

  /// alloc
  static SwiftClass alloc() {
    final _ret = _objc_msgSend_151sglz(_class_SwiftClass, _sel_alloc);
    return SwiftClass.castFromPointer(_ret, retain: false, release: true);
  }

  /// self
  SwiftClass self() {
    final _ret = _objc_msgSend_151sglz(this.ref.pointer, _sel_self);
    return SwiftClass.castFromPointer(_ret, retain: true, release: true);
  }

  /// retain
  SwiftClass retain() {
    final _ret = _objc_msgSend_151sglz(this.ref.pointer, _sel_retain);
    return SwiftClass.castFromPointer(_ret, retain: true, release: true);
  }

  /// autorelease
  SwiftClass autorelease() {
    final _ret = _objc_msgSend_151sglz(this.ref.pointer, _sel_autorelease);
    return SwiftClass.castFromPointer(_ret, retain: true, release: true);
  }
}
