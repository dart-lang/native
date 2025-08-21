// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// snippet-start
import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    output.assets.code.add(
      CodeAsset(
        name: 'my_code',
        file: Uri.file('path/to/file'),
        package: input.packageName,
        linkMode: DynamicLoadingBundled(),
      ),
    );
    output.assets.data.add(
      DataAsset(
        name: 'my_data',
        file: Uri.file('path/to/file'),
        package: input.packageName,
      ),
    );
  });
}

// snippet-end
