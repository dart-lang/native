// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:native_assets_cli/src/config.dart';
import 'package:native_assets_cli/src/utils/datetime.dart';
import 'package:test/test.dart';

void main() {
  test('LinkOutputBuilder->JSON->LinkOutput', () {
    final assets = [
      for (int i = 0; i < 3; i++)
        EncodedAsset('my-asset-type', {'a-$i': 'v-$i'})
    ];
    final uris = [
      for (int i = 0; i < 3; ++i) Uri.file('path$i'),
    ];
    final before = DateTime.now().roundDownToSeconds();
    final builder = LinkOutputBuilder();
    final after = DateTime.now().roundDownToSeconds();

    builder.addDependency(uris.take(1).single);
    builder.addDependencies(uris.skip(1).toList());

    builder.addEncodedAsset(assets.take(1).single);
    builder.addEncodedAssets(assets.skip(1).take(2).toList());

    final input = BuildOutput(builder.json);
    expect(input.timestamp.compareTo(before), greaterThanOrEqualTo(0));
    expect(input.timestamp.compareTo(after), lessThanOrEqualTo(0));
    expect(
        input.timestamp
            .isAtSameMomentAs(input.timestamp.roundDownToSeconds()),
        true);

    // The JSON format of the link output.
    <String, Object?>{
      'version': '1.6.0',
      'dependencies': ['path0', 'path1', 'path2'],
      'assets': [
        {'a-0': 'v-0', 'type': 'my-asset-type'},
        {'a-1': 'v-1', 'type': 'my-asset-type'},
        {'a-2': 'v-2', 'type': 'my-asset-type'}
      ]
    }.forEach((k, v) {
      expect(input.json[k], equals(v));
    });
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('LinkOutput version $version', () {
      expect(
        () => LinkOutput({'version': version}),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(latestVersion.toString()),
        )),
      );
    });
  }
}
