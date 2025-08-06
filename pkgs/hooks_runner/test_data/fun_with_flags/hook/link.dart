// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:data_assets/data_assets.dart';
import 'package:fun_with_flags/src/hook.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) {
  link(args, (input, output) async {
    final usedFlags = input.fetchUsedCountries
        .map((country) => 'package:fun_with_flags/assets/$country.txt')
        .toSet();

    // Got `usedFlags` for linking. Checking against `input.assets.data``

    final usedFlagAssets = input.assets.data.where(
      (flagAsset) => usedFlags.contains(flagAsset.id),
    );

    // After filtering, got `usedFlagAssets`

    output.assets.data.addAll(usedFlagAssets);
  });
}
