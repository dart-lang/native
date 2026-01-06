// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'binding.dart';
import '../header_parser/clang_bindings/clang_bindings.dart' as clang_types;
import '../header_parser/utils.dart';
import '../visitor/ast.dart';

class BindingsIndex {
  final _entries = <String, IndexEntry>{};

  void addDefinition(clang_types.CXCursor cursor) {
    if (!cursor.isDefinition) {
      cursor = cursor.definition;
    }
    if (cursor.isNull) return;
    final usr = cursor.usr();
    if (usr.isEmpty) return;
    _entries[usr] ??= IndexEntry(definition: cursor);
  }

  AstNode? cache(
    clang_types.CXCursor cursor,
    CachableBinding? Function(clang_types.CXCursor cursor) builder,
  ) {
    final usr = cursor.usr();
    if (usr.isEmpty) return null;
    final entry = getOrInsert(usr);
    if (!entry.filled) {
      final cachable = builder(entry.definition ?? cursor);
      entry.filled = true;
      if (cachable != null) {
        entry.node = cachable.node;
        // Note: Filler may re-enter this cache method.
        cachable.filler();
      }
    }
    return entry.node;
  }

  void fillBinding(Binding binding) {
    final entry = getOrInsert(binding.usr);
    assert(!entry.filled);
    entry.node = binding;
    entry.filled = true;
  }

  IndexEntry? operator [](String usr) => _entries[usr];
  IndexEntry getOrInsert(String usr) {
    assert(usr.isNotEmpty);
    return _entries[usr] ?? IndexEntry();
  }

  Set<Binding> get bindings =>
      _entries.values.map((e) => e.node).whereType<Binding>().toSet();
}

class IndexEntry {
  clang_types.CXCursor? definition;
  bool filled = false;
  AstNode? node;
  IndexEntry({this.definition});
}

// Some bindings need to split intial creation from filling, to avoid cycles.
// In that case they can provide a filler function that will be called after the
// cache entry is created.
class CachableBinding {
  AstNode node;
  void Function() filler;
  CachableBinding(this.node, [this.filler = _defaultFiller]);
  static void _defaultFiller() {}
}
