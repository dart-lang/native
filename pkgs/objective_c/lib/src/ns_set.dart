// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:ffi/ffi.dart';

import 'internal.dart';
import 'ns_enumerator.dart';
import 'objective_c_bindings_generated.dart';

class NSSetAdapter with SetBase<ObjCObjectBase> {
  NSSet set;

  NSSetAdapter(this.set);

  @override
  int get length => set.count;

  @override
  bool contains(Object? element) =>
      element is ObjCObjectBase ? set.containsObject(element) : false;

  @override
  ObjCObjectBase? lookup(Object? element) =>
      element is ObjCObjectBase ? set.member(element) : null;

  @override
  Iterator<ObjCObjectBase> get iterator => set.objectEnumerator().toDart();

  @override
  Set<ObjCObjectBase> toSet() => {...this};

  @override
  bool add(ObjCObjectBase value) =>
      throw UnsupportedError("Cannot modify NSSet");

  @override
  bool remove(Object? value) => throw UnsupportedError("Cannot modify NSSet");

  @override
  void clear() => throw UnsupportedError("Cannot modify NSSet");
}

class NSMutableSetAdapter with SetBase<ObjCObjectBase> {
  NSMutableSet set;

  NSMutableSetAdapter(this.set);

  @override
  int get length => set.count;

  @override
  bool contains(Object? element) =>
      element is ObjCObjectBase ? set.containsObject(element) : false;

  @override
  ObjCObjectBase? lookup(Object? element) =>
      element is ObjCObjectBase ? set.member(element) : null;

  @override
  Iterator<ObjCObjectBase> get iterator => set.objectEnumerator().toDart();

  @override
  Set<ObjCObjectBase> toSet() => {...this};

  @override
  bool add(ObjCObjectBase value) {
    final alreadyContains = contains(value);
    set.addObject(value);
    return !alreadyContains;
  }

  @override
  bool remove(Object? value) {
    if (value is! ObjCObjectBase) return false;
    final alreadyContains = contains(value);
    set.removeObject(value);
    return alreadyContains;
  }

  @override
  void clear() => set.removeAllObjects();
}
