// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drop_dylib_link/drop_dylib_link.dart';

const debug = false;

void main(List<String> arguments) {
  if (!debug) {
    print('Hello world: ${MyMath.add(3, 4)}!');
  } else if (debug) {
    print('Hello world: ${MyMath.multiply(3, 4)}!');
  }
}
