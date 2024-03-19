// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';

import '../utils/file.dart';
import '../utils/json.dart';
import '../utils/uri.dart';

class Dependencies {
  /// The dependencies a build relied on.
  final List<Uri> dependencies;

  const Dependencies(this.dependencies);

  factory Dependencies.fromJson(List<Object?>? jsonList) => Dependencies([
        if (jsonList != null)
          for (final dependency in jsonList)
            fileSystemPathToUri(as<String>(dependency)),
      ]);

  List<String> toJson() => [
        for (final dependency in dependencies) dependency.toFilePath(),
      ];

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  Future<DateTime> lastModified() =>
      dependencies.map((u) => u.fileSystemEntity).lastModified();

  @override
  bool operator ==(Object other) {
    if (other is! Dependencies) {
      return false;
    }
    return const ListEquality<Uri>().equals(other.dependencies, dependencies);
  }

  @override
  int get hashCode => const ListEquality<Uri>().hash(dependencies);
}
