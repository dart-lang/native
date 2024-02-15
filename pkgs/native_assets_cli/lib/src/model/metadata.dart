// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:yaml/yaml.dart';

import '../utils/map.dart';
import '../utils/yaml.dart';

// ignore: deprecated_member_use_from_same_package
class Metadata {
  final Map<String, Object> metadata;

  const Metadata(this.metadata);

  factory Metadata.fromYaml(YamlMap? yamlMap) =>
      Metadata(yamlMap?.formatCast<String, Object>() ?? {});

  factory Metadata.fromYamlString(String yaml) {
    final yamlObject = as<YamlMap>(loadYaml(yaml));
    return Metadata.fromYaml(yamlObject);
  }

  Map<String, Object> toYaml() => metadata..sortOnKey();

  String toYamlString() => yamlEncode(toYaml());

  @override
  bool operator ==(Object other) {
    if (other is! Metadata) {
      return false;
    }
    return const DeepCollectionEquality().equals(other.metadata, metadata);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(metadata);

  @override
  String toString() => 'Metadata(${toYaml()})';
}
