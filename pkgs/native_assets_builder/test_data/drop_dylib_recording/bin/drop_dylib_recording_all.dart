// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drop_dylib_recording/drop_dylib_recording.dart';
import 'package:meta/meta.dart';

void main(List<String> arguments) {
  getMathMethod(arguments.first);
}

@RecordUse()
void getMathMethod(String symbol) {
  if (symbol == 'add') {
    print('Hello world: ${MyMath.add(3, 4)}!');
  } else if (symbol == 'multiply') {
    print('Hello world: ${MyMath.multiply(3, 4)}!');
  } else {
    throw ArgumentError('Must pass either "add" or "multiply"');
  }
}
