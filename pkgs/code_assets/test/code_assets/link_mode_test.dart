// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

void main() {
  test('LinkMode toString', () async {
    StaticLinking().toString();
  });

  test('CustomLinkMode json roundtrip', () async {
    final customJson = {
      'type': 'my_custom_link_mode',
      'extra_data': 'some_value',
    };
    final linkMode = LinkMode.fromJson(customJson);
    expect(linkMode, isA<CustomLinkMode>());
    final customLinkMode = linkMode as CustomLinkMode;
    expect(customLinkMode.type, 'my_custom_link_mode');
    expect(customLinkMode.json, customJson);

    expect(customLinkMode.toJson(), customJson);
    expect(
      customLinkMode,
      CustomLinkMode('my_custom_link_mode', {
        'type': 'my_custom_link_mode',
        'extra_data': 'some_value',
      }),
    );
  });

  test('Custom LinkModePreference', () async {
    final customPref1 = LinkModePreference.fromString('custom_pref');
    final customPref2 = LinkModePreference.fromString('custom_pref');
    expect(customPref1, customPref2);
    expect(customPref1.toString(), 'custom_pref');
  });
}
