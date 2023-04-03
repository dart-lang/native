// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:yaml/yaml.dart';

import '../utils/list.dart';
import '../utils/map.dart';
import '../utils/yaml.dart';
import 'asset.dart';

class BuiltInfo {
  final DateTime timestamp;
  final List<Asset> assets;

  BuiltInfo({
    required this.timestamp,
    required this.assets,
  });

  static const _timestampKey = 'timestamp';
  static const _assetsKey = 'assets';

  factory BuiltInfo.fromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml) as YamlMap;
    return BuiltInfo.fromYamlMap(yamlObject);
  }

  factory BuiltInfo.fromYamlMap(YamlMap yamlMap) => BuiltInfo(
      timestamp: DateTime.parse(yamlMap[_timestampKey] as String),
      assets: Asset.listFromYamlList(yamlMap[_assetsKey] as YamlList));

  Map<String, Object> toYamlEncoding() => {
        _timestampKey: timestamp.toString(),
        _assetsKey: assets.toYamlEncoding(),
      }..sortOnKey();

  String toYaml() => toYamlString(toYamlEncoding());

  @override
  String toString() => toYaml();

  @override
  bool operator ==(Object other) {
    if (other is! BuiltInfo) {
      return false;
    }
    return other.timestamp == timestamp && other.assets.elementEquals(assets);
  }

  @override
  int get hashCode => timestamp.hashCode ^ assets.elementHashCode;
}
