// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'converter.dart';
import 'internal.dart';
import 'ns_enumerator.dart';
import 'objective_c_bindings_generated.dart';

class _NSSetAdapter with SetBase<ObjCObjectBase> {
  final NSSet _set;

  _NSSetAdapter(this._set);

  @override
  int get length => _set.count;

  @override
  bool contains(Object? element) =>
      element is ObjCObjectBase ? _set.containsObject(element) : false;

  @override
  ObjCObjectBase? lookup(Object? element) =>
      element is ObjCObjectBase ? _set.member(element) : null;

  @override
  Iterator<ObjCObjectBase> get iterator => _set.objectEnumerator().toDart();

  @override
  Set<ObjCObjectBase> toSet() => {...this};

  @override
  bool add(ObjCObjectBase value) =>
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
  Set<ObjCObjectBase> toDart() => _NSSetAdapter(this);
}

class _NSMutableSetAdapter with SetBase<ObjCObjectBase> {
  final NSMutableSet _set;

  _NSMutableSetAdapter(this._set);

  @override
  int get length => _set.count;

  @override
  bool contains(Object? element) =>
      element is ObjCObjectBase ? _set.containsObject(element) : false;

  @override
  ObjCObjectBase? lookup(Object? element) =>
      element is ObjCObjectBase ? _set.member(element) : null;

  @override
  Iterator<ObjCObjectBase> get iterator => _set.objectEnumerator().toDart();

  @override
  Set<ObjCObjectBase> toSet() => {...this};

  @override
  bool add(ObjCObjectBase value) {
    final alreadyContains = contains(value);
    _set.addObject(value);
    return !alreadyContains;
  }

  @override
  bool remove(Object? value) {
    if (value is! ObjCObjectBase) return false;
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
  Set<ObjCObjectBase> toDart() => _NSMutableSetAdapter(this);
}
