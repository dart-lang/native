// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart_keywords.dart';

class Namespace {
  final _symbols = <Symbol>[];
  final Namespace? _parent;
  final _children = <Namespace>[];
  _Namer? _namer;

  Namespace._(this._parent);

  static Namespace createRoot() => Namespace._(null);

  Namespace addNamespace() {
    assert(!_filled);
    final ns = Namespace._(this);
    _children.add(ns);
    return ns;
  }

  Symbol add(String name) {
    assert(!_filled);
    final symbol = Symbol._(name);
    _symbols.add(symbol);
    return symbol;
  }

  String addPrivate(String name) {
    assert(_filled);
    assert(name.startsWith('_'));
    return _namer!.add(name);
  }

  void fillNames() {
    assert(_parent == null); // Must call fillNames on the root.
    _fillNames(_Namer._());
  }

  void _fillNames(_Namer namer) {
    assert(!_filled);
    _namer = namer;
    for (final symbol in _symbols) {
      assert(symbol._name == null);
      symbol._name = namer.add(symbol.oldName);
    }
    for (final ns in _children) {
      ns._fillNames(_Namer._(namer));
    }
  }

  bool get _filled => _namer != null;

  /// Returns a version of [name] that can safely be used in C code. Not
  /// guaranteed to be unique.
  static String cSafeName(String name) => name.replaceAll('\$', '_');

  /// Returns a version of [name] suitable for inclusion in a string literal.
  static String stringLiteral(String name) => name.replaceAll('\$', '\\\$');
}

class _Namer {
  final Map<String, int> _used;

  _Namer._([_Namer? parent])
    : _used = parent != null ? Map.from(parent._used) : {};

  String add(String name) {
    // TODO(https://github.com/dart-lang/native/issues/2054): Relax this.
    final isKeyword = keywords.contains(name);

    final count = _used[name] ?? 0;
    _used[name] = count + 1;

    return [
      name,
      if (isKeyword || count > 0) '\$',
      if (count > 0) count.toString(),
    ].join('');
  }
}

class Symbol {
  final String oldName;

  String? _name;
  String get name => _name!;

  Symbol._(String _oldName) : oldName = _oldName.isEmpty ? 'unnamed' : _oldName;

  @override
  String toString() => _name ?? oldName;
}
