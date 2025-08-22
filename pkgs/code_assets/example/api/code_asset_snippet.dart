// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=76

// snippet-start
import 'dart:ffi';

void main() {
  final result = add(14, 28);
  print(result);
}

@Native<Int Function(Int, Int)>(assetId: 'package:my_package/add.dart')
external int add(int a, int b);

// snippet-end
