// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:yaml/yaml.dart';

Map<String, Object?> loadJson(String relativePath) {
  final packageRoot = findPackageRoot('pub_formats');
  final pubspecFile = File.fromUri(packageRoot.resolve(relativePath));
  final json = jsonDecode(pubspecFile.readAsStringSync());
  return json as Map<String, Object?>;
}

Map<String, Object?> loadYamlAsJson(String relativePath) {
  final packageRoot = findPackageRoot('pub_formats');
  final pubspecFile = File.fromUri(packageRoot.resolve(relativePath));
  final json = convertYamlMapToJsonMap(
    loadYaml(pubspecFile.readAsStringSync()),
  );
  return json;
}
