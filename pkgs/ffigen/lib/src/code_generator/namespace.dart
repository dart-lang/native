// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart_keywords.dart';

class Namespace {
  final _symbols = <Symbol>[];
  final Namespace? _parent;
  final _children = <Namespace>[];
  Map<String, int>? _used;

  Namespace._(this._parent);

  static Namespace root() => Namespace._(null);

  Namespace addNamespace() {
    assert(!_filled);
    final ns = Namespace(this);
    _children.add(ns);
    return ns;
  }

  Symbol add(String name) {
    assert(!_filled);
    final symbol = Symbol(name);
    _symbols.add(symbol);
    return symbol;
  }

  void fillNames() {
    assert(!_filled);
    assert(_parent?._filled ?? true);
    final used = _parent != null ? Map.from(_parent._used!) : {};
    _used = used;
    for (final symbol in _symbols) {
      assert(symbol._name == null);
      final oldName = symbol._oldName;

      // TODO(https://github.com/dart-lang/native/issues/2054): Relax this.
      final isKeyword = keywords.contains(oldName);

      int count = used[oldName] ?? 0;
      used[oldName] = count + 1;

      symbol._name = [
        oldName,
        if (isKeyword || count > 0) '\$',
        if (count > 0) count.toString(),
      ].join('');
    }
  }

  bool get _filled => _used != null;

  /// Returns a version of [name] that can safely be used in C code. Not
  /// guaranteed to be unique.
  static String cSafeName(String name) => name.replaceAll('\$', '_');

  /// Returns a version of [name] suitable for inclusion in a string literal.
  static String stringLiteral(String name) => name.replaceAll('\$', '\\\$');
}

class Symbol {
  final String _oldName;

  String? _name;
  String get name => _name!;

  Symbol._(String oldName) : _oldName = oldName.isEmpty ? 'unnamed' : oldName;

  @override
  String toString() => _name ?? _oldName;
}
