// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/data_assets.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final value1 = input.userDefines['user_define_key'];
    if (value1 != 'user_define_value') {
      throw Exception(
        'User-define user_define_key does not have the right value.',
      );
    }
    final value2 = input.userDefines['user_define_key2'];
    final dataAsset = DataAsset(
      file: input.outputDirectoryShared.resolve('my_asset.json'),
      name: 'my_asset',
      package: input.packageName,
    );
    File.fromUri(dataAsset.file).writeAsStringSync(jsonEncode(value2));
    output.assets.data.add(dataAsset);
  });
}
