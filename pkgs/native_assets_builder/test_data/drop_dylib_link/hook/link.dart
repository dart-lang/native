// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    print('''
Received ${config.codeAssets.all.length} encodedAssets: ${config.codeAssets.all.map((e) => e.id)}.
''');
    output.codeAssets.addAll(
        config.codeAssets.all.where((asset) => asset.id.endsWith('add')));
    print('''
Keeping only ${output.codeAssets.all.map((e) => e.id)}.
''');
    output.addDependency(config.packageRoot.resolve('hook/link.dart'));
  });
}
