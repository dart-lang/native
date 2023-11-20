// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  final root = Platform.script.resolve('../../');
  final glob = Glob('**pubspec.yaml');
  final files = glob.listSync(root: root.toFilePath()).whereType<File>();
  for (final file in files) {
    final yamlEditor = YamlEditor(file.readAsStringSync());
    final yaml = yamlEditor.parseAt([]);
    if (yaml is! YamlMap) {
      continue;
    }
    final dependencies = yaml['dependencies'];
    if (dependencies is! YamlMap) {
      continue;
    }
    for (final package in dependencies.keys) {
      if (!packagesToPin.contains(package)) {
        continue;
      }
      yamlEditor.update(
        ['dependencies', package],
        {
          // Some packages contain full test projects that are copied in unit
          // tests. So, use absolute paths.
          'path':
              root.resolve('pkgs/$package/').toFilePath().replaceAll(r'\', '/'),
        },
      );
    }
    if (yamlEditor.edits.isEmpty) {
      continue;
    }
    yamlEditor.update(['publish_to'], 'none');
    file.writeAsStringSync(yamlEditor.toString());
  }
}

const packagesToPin = {
  'native_assets_builder',
  'native_assets_cli',
  'native_toolchain_c',
};
