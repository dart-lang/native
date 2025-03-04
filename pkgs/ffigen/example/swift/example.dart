// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:objective_c/objective_c.dart';
import 'swift_api_bindings.dart';

// TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
import '../../../objective_c/test/setup.dart' as objCSetup;

void main() {
  objCSetup.main([]);

  // TODO(https://github.com/dart-lang/ffigen/issues/443): Add a test for this.
  DynamicLibrary.open('libswiftapi.dylib');
  final object = SwiftClass.new1();
  print(object.sayHello().toDartString());
  print('field = ${object.someField}');
  object.someField = 456;
  print('field = ${object.someField}');
}
