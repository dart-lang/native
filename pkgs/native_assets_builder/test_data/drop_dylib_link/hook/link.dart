// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    print('''
Received ${config.assets.length} assets: ${config.assets.map((e) => e.id)}.
''');
    output.addAssets(config.assets.where((asset) => asset.id.endsWith('add')));
    print('''
Keeping only ${output.assets.map((e) => e.id)}.
''');
    output.addDependency(config.packageRoot.resolve('hook/link.dart'));
  });
}
