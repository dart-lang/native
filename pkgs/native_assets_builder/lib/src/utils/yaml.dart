// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

String yamlEncode(Object yamlEncoding) {
  final editor = YamlEditor('');
  editor.update(
    [],
    wrapAsYamlNode(
      yamlEncoding,
      collectionStyle: CollectionStyle.BLOCK,
    ),
  );
  return editor.toString();
}

T as<T>(Object? object) {
  if (object is T) {
    return object;
  }
  throw FormatException(
    "Unexpected value '$object' in YAML. Expected a $T.",
  );
}
