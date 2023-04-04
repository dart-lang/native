// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Packaging {
  final String name;

  const Packaging._(this.name);

  static const Packaging dynamic = Packaging._('dynamic');
  static const Packaging static = Packaging._('static');

  /// Known values for [Packaging].
  static const List<Packaging> values = [
    dynamic,
    static,
  ];

  factory Packaging.fromName(String name) =>
      values.where((element) => element.name == name).first;

  @override
  String toString() => name;
}
