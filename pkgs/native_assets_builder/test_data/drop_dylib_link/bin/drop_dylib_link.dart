// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drop_dylib_link/drop_dylib_link.dart';

void main(List<String> arguments) {
  if (arguments.first == 'add') {
    print('Hello world: ${MyMath.add(3, 4)}!');
  } else if (arguments.first == 'multiply') {
    print('Hello world: ${MyMath.multiply(3, 4)}!');
  } else {
    throw ArgumentError('Must pass either "add" or "multiply"');
  }
}
