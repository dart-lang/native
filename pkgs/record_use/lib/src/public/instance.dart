import 'package:collection/collection.dart';

// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Instance {
  final String className;
  final Map<String, Object?> fields;

  Instance({required this.className, required this.fields});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is Instance &&
        other.className == className &&
        mapEquals(other.fields, fields);
  }

  @override
  int get hashCode => Object.hash(className, fields);
}
