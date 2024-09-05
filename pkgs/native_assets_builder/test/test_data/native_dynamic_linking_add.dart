// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

void main(List<String> arguments) {
  final addLibraryPath = arguments[0];
  final a = int.parse(arguments[1]);
  final b = int.parse(arguments[2]);
  final addLibrary = DynamicLibrary.open(addLibraryPath);
  final add = addLibrary.lookupFunction<Int32 Function(Int32, Int32),
      int Function(int, int)>('add');
  print(add(a, b));
}
