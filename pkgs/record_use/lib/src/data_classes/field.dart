// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Field {
  final String className;
  final String name;
  final Object? value;

  Field({
    required this.className,
    required this.name,
    required this.value,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Field &&
        other.className == className &&
        other.name == name &&
        other.value == value;
  }

  @override
  int get hashCode => className.hashCode ^ name.hashCode ^ value.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'name': name,
      'value': value,
    };
  }

  factory Field.fromJson(Map<String, dynamic> map) {
    return Field(
      className: map['className'] as String,
      name: map['name'] as String,
      value: map['value'],
    );
  }
}
