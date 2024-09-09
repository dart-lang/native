// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    final dataAssets = config.assets.whereType<DataAsset>();
    print('''
Received ${dataAssets.length} assets: ${dataAssets.map((e) => '${e.package} ${e.name}')}.
''');
    output.addAssets(dataAssets.where((asset) => asset.name.endsWith('add')));
    print('''
Keeping only ${dataAssets.map((e) => '${e.package} ${e.name}')}.
''');
    output.addDependency(config.packageRoot.resolve('hook/link.dart'));
  });
}
