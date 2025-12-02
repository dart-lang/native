// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class BindingsIndex {
  final _entries = <String, IndexEntry>{};

  void addDefinition(clang_types.CXCursor cursor) {
    if (!cursor.isDefinition) {
      cursor = cursor.definition;
    }
    if (cursor.isNull) return;
    final usr = cursor.usr();
    if (usr.isEmpty) return;
    _entries[usr] ??= IndexEntry(cursor);
  }

  IndexEntry? operator [](String usr) => _entries[usr];

  Iterable<Binding> get bindings =>
      _entries.values.map((e) => e.binding).nonNulls;
}

class IndexEntry {
  clang_types.CXCursor definition;
  bool filled = false;
  Binding? binding;
  IndexEntry(this.definition);
}
