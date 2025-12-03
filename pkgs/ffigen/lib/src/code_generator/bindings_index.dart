// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'binding.dart';
import '../header_parser/clang_bindings/clang_bindings.dart' as clang_types;
import '../header_parser/utils.dart';

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

  void fillBinding(Binding binding) {
    final entry = getOrInsert(binding.usr);
    assert(!entry.filled);
    entry.binding = binding;
    entry.filled = true;
  }

  Binding? cache(
    clang_types.CXCursor cursor,
    Binding? Function(clang_types.CXCursor cursor) builder,
  ) {
    final usr = cursor.usr();
    if (usr.isEmpty) return null;
    final entry = getOrInsert(usr);
    if (!entry.filled) {
      final binding = builder(entry.definition ?? cursor);
      if (binding != null) entry.binding = binding;
      entry.filled = true;
    }
    return entry.binding;
  }

  IndexEntry? operator [](String usr) => _entries[usr];
  IndexEntry getOrInsert(String usr) {
    assert(usr.isNotEmpty);
    return _entries[usr] ?? IndexEntry();
  }

  Set<Binding> get bindings =>
      _entries.values.map((e) => e.binding).nonNulls.toSet();
}

class IndexEntry {
  clang_types.CXCursor? definition;
  bool filled = false;
  Binding? binding;
  IndexEntry({this.definition});
}
