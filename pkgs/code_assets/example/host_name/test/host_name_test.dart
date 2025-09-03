// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:host_name/host_name.dart';
import 'package:test/test.dart';

void main() {
  test('test host name', () {
    expect(getHostName(), isNotNull);
    expect(getHostName(), isNotEmpty);
  });
}
