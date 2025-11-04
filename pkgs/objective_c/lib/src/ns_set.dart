// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'converter.dart';
import 'internal.dart';
import 'ns_enumerator.dart';
import 'objective_c_bindings_generated.dart';

class _NSSetAdapter with SetBase<ObjCObject> {
  final NSSet _set;

  _NSSetAdapter(this._set);

  @override
  int get length => _set.count;

  @override
  bool contains(Object? element) =>
      element is ObjCObject ? _set.containsObject(element) : false;

  @override
  ObjCObject? lookup(Object? element) =>
      element is ObjCObject ? _set.member(element) : null;

  @override
  Iterator<ObjCObject> get iterator => _set.objectEnumerator().toDart();

  @override
  Set<ObjCObject> toSet() => {...this};

  @override
  bool add(ObjCObject value) =>
      throw UnsupportedError('Cannot modify NSSet');

  @override
  bool remove(Object? value) => throw UnsupportedError('Cannot modify NSSet');

  @override
  void clear() => throw UnsupportedError('Cannot modify NSSet');
}

extension NSSetToAdapter on NSSet {
  /// Wraps this [NSSet] in an adapter that implements an immutable [Set].
  ///
  /// This is not a conversion, doesn't create a new set, or change the
  /// elements. For deep conversion, use [toDartSet].
  Set<ObjCObject> toDart() => _NSSetAdapter(this);
}

class _NSMutableSetAdapter with SetBase<ObjCObject> {
  final NSMutableSet _set;

  _NSMutableSetAdapter(this._set);

  @override
  int get length => _set.count;

  @override
  bool contains(Object? element) =>
      element is ObjCObject ? _set.containsObject(element) : false;

  @override
  ObjCObject? lookup(Object? element) =>
      element is ObjCObject ? _set.member(element) : null;

  @override
  Iterator<ObjCObject> get iterator => _set.objectEnumerator().toDart();

  @override
  Set<ObjCObject> toSet() => {...this};

  @override
  bool add(ObjCObject value) {
    final alreadyContains = contains(value);
    _set.addObject(value);
    return !alreadyContains;
  }

  @override
  bool remove(Object? value) {
    if (value is! ObjCObject) return false;
    final alreadyContains = contains(value);
    _set.removeObject(value);
    return alreadyContains;
  }

  @override
  void clear() => _set.removeAllObjects();
}

extension NSMutableSetToAdapter on NSMutableSet {
  /// Wraps this [NSMutableSet] in an adapter that implements [Set].
  ///
  /// This is not a conversion, doesn't create a new set, or change the
  /// elements. For deep conversion, use [toDartSet].
  Set<ObjCObject> toDart() => _NSMutableSetAdapter(this);
}
