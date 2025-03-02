// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_builder/src/build_runner/build_runner.dart';
import 'package:test/test.dart';

void main() {
  test('parseDepFileInputs', () {
    expect(
      parseDepFileInputs(
        r'C:\\Program\ Files\\foo.dill: C:\\Program\ Files\\foo.dart C:\\Program\ Files\\bar.dart',
      ),
      [r'C:\Program Files\foo.dart', r'C:\Program Files\bar.dart'],
    );
  });
}
