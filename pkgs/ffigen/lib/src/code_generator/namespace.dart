// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart_keywords.dart';

mixin Symbol {
  final Namespace namespace;
  String _name;
  bool _filled = false;

  String get name => _name;
  void set name(String newName) {
    assert(!_filled);
    _filled = true;
    _name = newName;
  }

  Symbol(this.namespace, this._name) {
    namespace._symbols.add(this);
  }

  @override
  String toString() => name;
}

typedef AdHocSymbol = Symbol;

class Namespace {
  final _symbols = <Symbol>[];
  final Namespace? _parent;
  final _children = <Namespace>[];
  bool _filled = false;

  Namespace._(this._parent);

  static Namespace root() => Namespace._(null);

  Namespace addNamespace() {
    assert(!_filled);
    final ns = Namespace(this);
    _children.add(ns);
    return ns;
  }

  AdHocSymbol addSymbol(String name) => AdHocSymbol(this, name);

  // Name name(String start, [Name? middle, String end = '']) {
  //   assert(!_filled);
  //   assert(middle == null || _validMiddle(middle));
  //   final name = Name(this, start, middle, end);
  //   _names.add(name);
  //   return name;
  // }

  void fillNames() {
    assert(_parent == null); // Must call fillNames on the root.
    _fillNames({});
  }

  void _fillNames(Map<String, int> used) {
    assert(!_filled);
    for (final n in _symbols) {
      var candidate = n.name;

      // TODO(https://github.com/dart-lang/native/issues/2054): Relax this.
      final isKeyword = keywords.contains(candidate);

      int count = used[candidate] ?? 0;
      used[candidate] = count + 1;

      n.name = [
        candidate,
        if (isKeyword || count > 0) '\$',
        if (count > 0) count.toString(),
      ].join('');
    }
    for (final ns in _children) {
      ns._fillNames(Map.from(used));
    }
    _filled = true;
  }

  /// Returns a version of [name] that can safely be used in C code. Not
  /// guaranteed to be unique.
  static String cSafeName(String name) => name.replaceAll('\$', '_');

  /// Returns a version of [name] suitable for inclusion in a string literal.
  static String stringLiteral(String name) => name.replaceAll('\$', '\\\$');
}

// class Name {
//   final Namespace _namespace;
//   final String _start;
//   final Name? _middle;
//   final String _end;

//   // Only valid after Namespace.fillNames() has been called.
//   String? name;

//   Name._(this._namespace, this._start, this._middle, this._end);

//   @override
//   String toString() {
//     if (name != null) return name;
//     final built = '$_start${_middle?.toString() ?? ''}$_end';
//     return built.isEmpty ? 'unnamed' : built;
//   }
// }
