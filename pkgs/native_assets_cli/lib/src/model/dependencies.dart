// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:yaml/yaml.dart';

import '../utils/file.dart';
import '../utils/uri.dart';
import '../utils/yaml.dart';

class Dependencies {
  final List<Uri> dependencies;

  const Dependencies(this.dependencies);

  factory Dependencies.fromYamlString(String yamlString) {
    final yaml = loadYaml(yamlString);
    if (yaml is YamlList) {
      return Dependencies.fromYaml(yaml);
    }
    return Dependencies([]);
  }

  factory Dependencies.fromYaml(YamlList? yamlList) => Dependencies([
        if (yamlList != null)
          for (final dependency in yamlList)
            fileSystemPathToUri(as<String>(dependency)),
      ]);

  List<String> toYaml() => [
        for (final dependency in dependencies) dependency.toFilePath(),
      ];

  String toYamlString() => yamlEncode(toYaml());

  @override
  String toString() => toYamlString();

  Future<DateTime> lastModified() =>
      dependencies.map((u) => u.fileSystemEntity).lastModified();

  @override
  bool operator ==(Object other) {
    if (other is! Dependencies) {
      return false;
    }
    return ListEquality<Uri>().equals(other.dependencies, dependencies);
  }

  @override
  int get hashCode => ListEquality<Uri>().hash(dependencies);
}
