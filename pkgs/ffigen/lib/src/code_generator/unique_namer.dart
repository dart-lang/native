// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart_keywords.dart';

class UniqueNamer {
  final Set<String> _used;

  /// Creates a UniqueNamer with given Dart reserved keywords.
  ///
  /// If [parent] is provided, also includes all the parent's names.
  UniqueNamer({UniqueNamer? parent})
      : _used = {
          ...keywords,
          if (parent != null) ...parent._used,
        };

  /// Returns a unique name by appending `<int>` to it if necessary.
  ///
  /// Adds the resulting name to the used names.
  String makeUnique(String name) {
    // For example, nested structures/unions may not have a name
    if (name.isEmpty) {
      name = 'unnamed';
    }

    var crName = name;
    var i = 1;
    while (_used.contains(crName)) {
      crName = '$name$i';
      i++;
    }
    _usedUpNames.add(crName);
    return crName;
  }

  /// Adds a name to used names.
  ///
  /// Note: [makeUnique] also adds the name by default.
  void markUsed(String name) => _used.add(name);

  void markAllUsed(Iterable<String> names) => names.forEach(markUsed);

  /// Returns true if a name has been used before.
  bool isUsed(String name) => _used.contains(name);
}
