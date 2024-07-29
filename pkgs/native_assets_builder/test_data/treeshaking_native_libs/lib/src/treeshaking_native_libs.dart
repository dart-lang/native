// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'treeshaking_native_libs_bindings_generated.dart' as bindings;

int add(int a, int b) => bindings.add(a, b);
int multiply(int a, int b) => bindings.multiply(a, b);
