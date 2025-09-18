// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart_keywords.dart';

class Namespace {
  final _symbols = <Symbol>[];
  final _children = <Namespace>[];
  final Set<String> _extraKeywords;
  _Namer? _namer;

  Namespace._(this._extraKeywords);

  static Namespace createRoot() => Namespace._(const {});

  Namespace addNamespace({Set<String> extraKeywords = const {}}) {
    assert(!_filled);
    final ns = Namespace._(extraKeywords);
    _children.add(ns);
    return ns;
  }

  void add(Symbol symbol) {
    assert(!_filled);
    _symbols.add(symbol);
  }

  String addPrivate(String name) {
    assert(_filled);
    assert(name.startsWith('_'));
    return _namer!.add(name);
  }

  void fillNames() {
    _fillNames(_Namer._(Set<String>.of(_extraKeywords)));
  }

  void _fillNames(_Namer namer) {
    assert(!_filled);
    _namer = namer;
    for (final symbol in _symbols) {
      assert(symbol._name == null);
      symbol._name = namer.add(symbol.oldName);
    }
    for (final ns in _children) {
      ns._fillNames(_Namer._(namer._used.union(_extraKeywords)));
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
  final Set<String> _used;

  _Namer._(this._used);

  String add(String name) {
    if (name.isEmpty) name = 'unnamed';

    // TODO(https://github.com/dart-lang/native/issues/2054): Relax this.
    final isKeyword = keywords.contains(name);

    var newName = isKeyword ? '$name\$' : name;
    for (var i = 1; _used.contains(newName); ++i) {
      newName = '$name\$$i';
    }

    _used.add(newName);
    return newName;
  }
}

class Symbol {
  final String oldName;

  String? _name;
  String get name => _name!;

  Symbol(this.oldName);

  @override
  String toString() => _name ?? oldName;
}
