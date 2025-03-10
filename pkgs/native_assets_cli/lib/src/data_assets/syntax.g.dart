// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.

import '../hook/syntax.g.dart';
import '../utils/json.dart';

class DataAsset extends Asset {
  DataAsset.fromJson(super.json) : super.fromJson();

  DataAsset({required Uri file, required String name, required String package})
    : super(type: 'data') {
    _file = file;
    _name = name;
    _package = package;
    json.sortOnKey();
  }

  /// Setup all fields for [DataAsset] that are not in
  /// [Asset].
  void setup({
    required Uri file,
    required String name,
    required String package,
  }) {
    _file = file;
    _name = name;
    _package = package;
    json.sortOnKey();
  }

  Uri get file => json.path('file');

  set _file(Uri value) {
    json['file'] = value.toFilePath();
  }

  String get name => json.string('name');

  set _name(String value) {
    json['name'] = value;
  }

  String get package => json.string('package');

  set _package(String value) {
    json['package'] = value;
  }

  @override
  String toString() => 'DataAsset($json)';
}

extension DataAssetExtension on Asset {
  bool get isDataAsset => type == 'data';

  DataAsset get asDataAsset => DataAsset.fromJson(json);
}
