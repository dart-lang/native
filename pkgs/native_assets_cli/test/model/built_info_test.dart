// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  final builtInfo = BuiltInfo(
    timestamp: DateTime.parse('2022-11-10 13:25:01.372257'),
    assets: [
      Asset(
        name: 'foo',
        path: AssetAbsolutePath(Uri(path: 'path/to/libfoo.so')),
        target: Target.androidX64,
        packaging: Packaging.dynamic,
      ),
      Asset(
        name: 'foo2',
        path: AssetRelativePath(Uri(path: 'path/to/libfoo2.so')),
        target: Target.androidX64,
        packaging: Packaging.dynamic,
      ),
    ],
  );

  const yamlEncoding = '''timestamp: 2022-11-10 13:25:01.372257
assets:
  - name: foo
    packaging: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_x64
  - name: foo2
    packaging: dynamic
    path:
      path_type: relative
      uri: path/to/libfoo2.so
    target: android_x64''';

  test('built info yaml', () {
    final yaml = builtInfo.toYaml().replaceAll('\\', '/');
    expect(yaml, yamlEncoding);
    final builtInfo2 = BuiltInfo.fromYamlString(yaml);
    expect(builtInfo, builtInfo2);
  });
}
