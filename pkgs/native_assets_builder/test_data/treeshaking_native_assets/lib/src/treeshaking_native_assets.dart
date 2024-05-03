// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'treeshaking_native_assets_bindings.dart' as bindings;

class MyMath {
  @ResourceIdentifier('add')
  static int add(int a, int b) => bindings.add(a, b);

  @ResourceIdentifier('multiply')
  static int multiply(int a, int b) => bindings.multiply(a, b);
}
