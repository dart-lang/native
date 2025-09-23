// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../visitor/ast.dart';
import 'dart_keywords.dart';

class Namespace {
  final _symbols = <Symbol>[];
  final _children = <Namespace>[];
  final Set<String> _preUsedNames;
  Namer? _namer;

  Namespace._(this._preUsedNames);

  static Namespace createRoot() => Namespace._(const {});

  Namespace addNamespace({Set<String> preUsedNames = const {}}) {
    assert(!_filled);
    final ns = Namespace._(preUsedNames);
    _children.add(ns);
    return ns;
  }

  void add(Symbol? symbol) {
    assert(!_filled);
    if (symbol != null) _symbols.add(symbol);
  }

  String addPrivate(String name) {
    assert(_filled);
    assert(name.startsWith('_'));
    return _namer!.add(name);
  }

  void fillNames() => _fillNames(const {});

  void _fillNames(Set<String> parentUsedNames) {
    assert(!_filled);
    final namer = Namer(parentUsedNames.union(_preUsedNames));
    _namer = namer;
    for (final symbol in _symbols) {
      if (symbol._name == null) {
        symbol._name = namer.add(symbol.oldName);
      } else {
        // Symbol already has a name. This can happen if the symbol is in
        // multiple namespaces, or in the same namespace more than once. It's
        // fine as long as the name isn't used by a different symbol earlier in
        // this namespace.
        namer.markUsed(symbol._name!);
        assert(!_symbols.any((s) => s != symbol && s._name == symbol._name));
      }
    }
    for (final ns in _children) {
      ns._fillNames(namer._used);
    }
  }

  bool get _filled => _namer != null;

  /// Returns a version of [name] that can safely be used in C code. Not
  /// guaranteed to be unique.
  static String cSafeName(String name) => name.replaceAll('\$', '_');

  /// Returns a version of [name] suitable for inclusion in a string literal.
  static String stringLiteral(String name) => name.replaceAll('\$', '\\\$');
}

class Namer {
  final Set<String> _used;

  Namer(this._used);

  String add(String name) {
    if (name.isEmpty) name = 'unnamed';

    // TODO(https://github.com/dart-lang/native/issues/2054): Relax this.
    final isKeyword = keywords.contains(name);

    var newName = isKeyword ? '$name\$' : name;
    for (var i = 1; _used.contains(newName); ++i) {
      newName = '$name\$$i';
    }

    markUsed(newName);
    return newName;
  }

  void markUsed(String name) => _used.add(name);
}

class Symbol extends AstNode {
  final String oldName;

  String? _name;
  String get name => _name!;

  Symbol(this.oldName);

  bool get isFilled => _name != null;

  @override
  String toString() => _name ?? oldName;

  @override
  void visit(Visitation visitation) => visitation.visitSymbol(this);
}

mixin HasLocalNamespace on AstNode {
  Namespace? _localNamespace;
  Namespace get localNamespace => _localNamespace!;
  set localNamespace(Namespace ns) {
    assert(!localNamespaceFilled);
    _localNamespace = ns;
  }

  bool get localNamespaceFilled => _localNamespace != null;
}
