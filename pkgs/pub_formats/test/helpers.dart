// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:yaml/yaml.dart';

Map<String, Object?> convertYamlMapToJsonMap(YamlMap yamlMap) {
  final Map<String, Object?> jsonMap = {};
  yamlMap.forEach((key, value) {
    if (key is! String) {
      // Handle non-string keys if your YAML allows them, or throw an error.
      // For typical JSON conversion, keys are expected to be strings.
      throw ArgumentError('YAML map keys must be strings for JSON conversion.');
    }
    jsonMap[key] = _convertYamlValue(value);
  });
  return jsonMap;
}

Object? _convertYamlValue(dynamic yamlValue) {
  if (yamlValue is YamlMap) {
    return convertYamlMapToJsonMap(yamlValue);
  } else if (yamlValue is YamlList) {
    return yamlValue.map((e) => _convertYamlValue(e)).toList();
  } else {
    // For primitive types (String, int, double, bool, null)
    return yamlValue;
  }
}

Map<String, Object?> loadYamlAsJson(String relativePath) {
  final packageRoot = findPackageRoot('pub_formats');
  final pubspecFile = File.fromUri(packageRoot.resolve(relativePath));
  final json = convertYamlMapToJsonMap(
    loadYaml(pubspecFile.readAsStringSync()),
  );
  return json;
}
