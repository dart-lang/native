// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:yaml/yaml.dart';

import '../utils/file.dart';
import '../utils/uri.dart';
import '../utils/yaml.dart';

class Dependencies {
  final List<Uri> dependencies;

  Dependencies(this.dependencies);

  factory Dependencies.fromYamlString(String yamlString) {
    final yaml = loadYaml(yamlString);
    if (yaml is YamlList) {
      return Dependencies.fromYamlMap(yaml);
    }
    return Dependencies([]);
  }

  factory Dependencies.fromYamlMap(YamlList yamlList) => Dependencies([
        for (final dependency in yamlList)
          fileSystemPathToUri(dependency as String),
      ]);

  List<String> toYamlEncoding() => [
        for (final dependency in dependencies) dependency.path,
      ];

  String toYaml() => toYamlString(toYamlEncoding());

  @override
  String toString() => toYaml();

  Future<DateTime> lastModified() =>
      dependencies.map((u) => u.fileSystemEntity).lastModified();
}
