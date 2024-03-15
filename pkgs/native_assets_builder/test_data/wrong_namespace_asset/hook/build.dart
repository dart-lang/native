// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    output.addAsset(
      NativeCodeAsset(
        package: 'other_package',
        name: 'foo',
        file: config.outputDirectory.resolve(
          OS.current.dylibFileName('foo'),
        ),
        linkMode: DynamicLoadingBundled(),
        os: OS.current,
        architecture: Architecture.current,
      ),
    );
  });
}
