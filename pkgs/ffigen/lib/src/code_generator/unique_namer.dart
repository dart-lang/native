// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart_keywords.dart';

class UniqueNamer {
  final Set<String> _used;

  /// Creates a UniqueNamer including all the [parent]'s names.
  UniqueNamer({UniqueNamer? parent}) : _used = parent?._used.toSet() ?? {};

  /// Creates a unique version of [name] and adds it to the set of used names.
  String makeUnique(String name) {
    if (name.isEmpty) {
      // For example, nested structures/unions may not have a name.
      name = 'unnamed';
    }

    // If the name is a keyword, append a '$'. Note that this extra '$' is
    // dropped if we start doing numbered renames below.
    var newName = name;
    if (keywords.contains(newName)) {
      newName = '$newName\$';
    }

    // Append '$i' until we find an i that hasn't been used.
    var i = 1;
    while (_used.contains(newName)) {
      newName = '$name\$$i';
      ++i;
    }

    _used.add(newName);
    return newName;
  }

  /// Adds a [name] to used names.
  void markUsed(String name) => _used.add(name);

  /// Adds all the [names] to the used names.
  void markAllUsed(Iterable<String> names) => names.forEach(markUsed);

  /// Returns true if a [name] has been used before.
  bool isUsed(String name) => _used.contains(name);

  /// Returns a version of [name] that can safely be used in C code. Not
  /// guaranteed to be unique.
  static String cSafeName(String name) => name.replaceAll('\$', '_');
}
