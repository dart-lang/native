// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:test/test.dart';
import 'package:use_dart_api/use_dart_api.dart';

void main() {
  InitDartApiDL(NativeApi.initializeApiDLData);

  test('use dart_api_dl.h', () {
    const x = 42;
    final persistentHandle = NewPersistentHandle(x);
    HandleFromPersistent(persistentHandle);
  });
}
