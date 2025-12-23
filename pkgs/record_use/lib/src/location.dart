// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'syntax.g.dart';

class Location {
  final String uri;
  final int? line;
  final int? column;

  const Location({required this.uri, this.line, this.column});

  factory Location.fromJson(Map<String, Object?> map) =>
      Location._fromSyntax(LocationSyntax.fromJson(map));

  factory Location._fromSyntax(LocationSyntax syntax) =>
      Location(uri: syntax.uri, line: syntax.line, column: syntax.column);

  Map<String, Object?> toJson() => _toSyntax().json;

  LocationSyntax _toSyntax() =>
      LocationSyntax(uri: uri, line: line, column: column);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Location &&
        other.uri == uri &&
        other.line == line &&
        other.column == column;
  }

  @override
  int get hashCode => Object.hash(uri, line, column);
}

/// Package private (protected) methods for [Location].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension LocationProtected on Location {
  LocationSyntax toSyntax() => _toSyntax();

  static Location fromSyntax(LocationSyntax syntax) =>
      Location._fromSyntax(syntax);
}
