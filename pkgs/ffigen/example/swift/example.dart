// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'swift_api_bindings.dart';

void main() {
  // TODO(https://github.com/dart-lang/ffigen/issues/443): Add a test for this.
  DynamicLibrary.open('libswiftapi.dylib');
  final object = SwiftClass.new1();
  print(object.sayHello());
  print('field = ${object.someField}');
  object.someField = 456;
  print('field = ${object.someField}');
}
