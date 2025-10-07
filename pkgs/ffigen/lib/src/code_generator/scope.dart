// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../visitor/ast.dart';

/// Holds [Symbol]s and assigns unique names to them.
///
/// [Scope]s form a tree from a single root scope. The names assigned to symbols
/// avoid collisions with other names in the same scope, and the parent scopes.
///
/// Usage:
///  - Create a root scope with [createRoot]
///  - Use [addChild] to create child scopes
///  - [add] [Symbol]s to the scopes
///  - Call [fillNames] on the root scope to name all the [Symbol]s
///  - Use [addPrivate] to create ad-hoc names during code generation
class Scope {
  final String _debugName;
  final _symbols = <Symbol>{};
  final _children = <Scope>[];
  final Scope? _parent;
  final UsedNames _preUsedNames;
  Namer? _namer;

  Scope._(this._parent, this._debugName, this._preUsedNames);

  static Scope createRoot(String debugName) =>
      Scope._(null, debugName, const {});

  /// Create a new [Scope] as a child of this one.
  ///
  /// [fillNames] must not have been called yet.
  Scope addChild(String debugName, {UsedNames preUsedNames = const {}}) {
    assert(!_filled);
    final ns = Scope._(this, debugName, preUsedNames);
    _children.add(ns);
    return ns;
  }

  /// Add a [Symbol] to this [Scope].
  ///
  /// It's fine to add the [Symbol] to this [Scope] multiple times. It's
  /// also fine to add the [Symbol] to multiple [Scope]s, as long as one of
  /// the [Scope]s is an ancestor of all the others (this is checked during
  /// [fillNames]).
  ///
  /// [fillNames] must not have been called yet.
  void add(Symbol? symbol) {
    assert(!_filled);
    if (symbol != null) _symbols.add(symbol);
  }

  /// Add an ad-hoc name to the [Scope].
  ///
  /// This is meant to be used during code generation, for generating unique
  /// names for internal use only. It shouldn't be used for user visible names,
  /// or for names that need to be used in multiple disparate places throughout
  /// ffigen. If you're storing the name in a long term variable, you should
  /// probably be using a proper [Symbol].
  ///
  /// To help ensure correct use, only names beginning with '_' are allowed.
  /// [fillNames] must have been called already.
  String addPrivate(String name, {SymbolKind kind = SymbolKind.field}) {
    assert(_filled);
    assert(name.startsWith('_'));
    return _namer!.add(name, kind);
  }

  /// Fill in the names of all the [Symbol]s in this [Scope] and its children.
  void fillNames() {
    assert(_parent == null);
    _fillNames(const {});
  }

  void _fillNames(UsedNames parentUsedNames) {
    assert(!_filled);
    final namer = Namer(Namer._mergeUsed(parentUsedNames, _preUsedNames));
    _namer = namer;
    for (final symbol in _symbols) {
      if (symbol._name == null) {
        symbol._name = namer.add(symbol.oldName, symbol.kind);
      } else {
        // Symbol already has a name. This can happen if the symbol is in
        // multiple scopes. It's fine as long as the name isn't used by a
        // different symbol earlier in this scope.
        namer.markUsed(symbol._name!, symbol.kind);
        assert(
          !_symbols.any((s) => s != symbol && s._name == symbol._name),
          symbol.oldName,
        );
      }
    }
    for (final ns in _children) {
      ns._fillNames(namer._used);
    }
  }

  bool get _filled => _namer != null;

  void debugPrint([String depth = '']) {
    final newDepth = '  $depth';
    print('$depth$_debugName {');
    for (final s in _symbols) {
      print('$newDepth$s');
    }
    for (final ns in _children) {
      ns.debugPrint(newDepth);
    }
    print('$depth}');
  }

  int debugStackPrint() {
    final depth = _parent?.debugStackPrint() ?? 0;
    print('${'  ' * depth}$_debugName');
    return depth + 1;
  }

  @override
  String toString() => _debugName;
}

/// Assigns unique names, avoiding collisions with existing names and keywords,
/// by postfixing '$[int]' if there's a collision.
///
/// This class is used internally by [Scope] to name [Symbol]s, and 99% of the
/// time you should use those instead of this.
class Namer {
  final UsedNames _used;

  Namer(this._used);

  String add(String name, SymbolKind kind) {
    if (name.isEmpty) name = 'unnamed';

    var newName = _isUsed(_keywords, name, kind.mask) ? '$name\$' : name;
    for (var i = 1; isUsed(newName, kind); ++i) {
      newName = '$name\$$i';
    }

    markUsed(newName, kind);
    return newName;
  }

  bool isUsed(String name, SymbolKind kind) => _isUsed(_used, name, kind.mask);
  void markUsed(String name, SymbolKind kind) =>
      _markUsed(_used, name, kind.mask);

  /// Returns a version of [name] that can safely be used in C code. Not
  /// guaranteed to be unique.
  static String cSafeName(String name) => name.replaceAll('\$', '_');

  /// Returns a version of [name] suitable for inclusion in a string literal.
  static String stringLiteral(String name) => name.replaceAll('\$', '\\\$');

  static UsedNames _mergeUsed(UsedNames a, UsedNames b) {
    final c = UsedNames.from(a);
    for (final MapEntry(:key, :value) in b.entries) {
      _markUsed(c, key, value);
    }
    return c;
  }

  static bool _isUsed(UsedNames used, String name, Allowed allowed) =>
      ((used[name] ?? 0) & allowed) != 0;
  static void _markUsed(UsedNames used, String name, Allowed allowed) =>
      used[name] = (used[name] ?? 0) | allowed;
}

/// A renamable string used to assign names to variables, types, etc.
///
/// Add the [Symbol] to a [Scope], and it will be assigned a name during the
/// transformation phase.
class Symbol extends AstNode {
  final String oldName;
  final SymbolKind kind;
  String? _name;

  /// Only valid if [Scope.fillNames] has been called already.
  String get name => _name!;

  Symbol(this.oldName, this.kind);

  bool get isFilled => _name != null;

  @override
  String toString() => _name ?? oldName;

  @override
  void visit(Visitation visitation) => visitation.visitSymbol(this);

  void forceFillForTesting() => _name = oldName;
}

mixin HasLocalScope on AstNode {
  Scope? _localScope;
  Scope get localScope => _localScope!;
  set localScope(Scope ns) {
    assert(!localScopeFilled);
    _localScope = ns;
  }

  bool get localScopeFilled => _localScope != null;
}

typedef Allowed = int;
typedef UsedNames = Map<String, Allowed>;

class _Allowed {
  static const none = 0;
  static const fields = 1 << 0;
  static const methods = 1 << 1;
}

enum SymbolKind {
  field(_Allowed.fields),
  method(_Allowed.methods),
  klass(_Allowed.fields | _Allowed.methods),
  lib(_Allowed.fields | _Allowed.methods);

  const SymbolKind(this.mask);

  final Allowed mask;
}

// Source: https://dart.dev/guides/language/language-tour#keywords.
const _keywords = {
  '_': _Allowed.none,
  'abstract': _Allowed.fields | _Allowed.methods,
  'as': _Allowed.fields | _Allowed.methods,
  'assert': _Allowed.none,
  'await': _Allowed.none, // Cannot be used in async context
  'break': _Allowed.none,
  'case': _Allowed.none,
  'catch': _Allowed.none,
  'class': _Allowed.none,
  'const': _Allowed.none,
  'continue': _Allowed.none,
  'covariant': _Allowed.fields | _Allowed.methods,
  'default': _Allowed.none,
  'deferred': _Allowed.fields | _Allowed.methods,
  'do': _Allowed.none,
  'dynamic': _Allowed.fields | _Allowed.methods,
  'else': _Allowed.none,
  'enum': _Allowed.none,
  'export': _Allowed.fields | _Allowed.methods,
  'extends': _Allowed.none,
  'extension': _Allowed.fields | _Allowed.methods,
  'external': _Allowed.fields | _Allowed.methods,
  'factory': _Allowed.fields | _Allowed.methods,
  'false': _Allowed.none,
  'final': _Allowed.none,
  'finally': _Allowed.none,
  'for': _Allowed.none,
  'Function': _Allowed.fields | _Allowed.methods,
  'get': _Allowed.fields | _Allowed.methods,
  'if': _Allowed.none,
  'implements': _Allowed.fields | _Allowed.methods,
  'import': _Allowed.methods,
  'in': _Allowed.none,
  'interface': _Allowed.fields | _Allowed.methods,
  'is': _Allowed.none,
  'late': _Allowed.fields | _Allowed.methods,
  'library': _Allowed.fields | _Allowed.methods,
  'mixin': _Allowed.fields | _Allowed.methods,
  'new': _Allowed.none,
  'null': _Allowed.none,
  'operator': _Allowed.fields | _Allowed.methods,
  'part': _Allowed.fields | _Allowed.methods,
  'required': _Allowed.fields | _Allowed.methods,
  'rethrow': _Allowed.none,
  'return': _Allowed.none,
  'set': _Allowed.fields | _Allowed.methods,
  'static': _Allowed.fields | _Allowed.methods,
  'super': _Allowed.none,
  'switch': _Allowed.none,
  'this': _Allowed.none,
  'throw': _Allowed.none,
  'true': _Allowed.none,
  'try': _Allowed.none,
  'typedef': _Allowed.fields | _Allowed.methods,
  'var': _Allowed.none,
  'void': _Allowed.none,
  'while': _Allowed.none,
  'with': _Allowed.none,
  'yield': _Allowed.none, // Cannot be used in async context
};
