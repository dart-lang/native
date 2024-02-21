// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  test('OS current', () async {
    final current = OS.current;
    expect(current.toString(), Abi.current().toString().split('_').first);
  });

  test('Architecture current', () async {
    final current = Architecture.current;
    expect(current.toString(), Abi.current().toString().split('_')[1]);
  });
}
