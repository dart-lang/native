// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'referred_type.dart';

class Parameter {
  String name;
  String? internalName;
  ReferredType type;

  Parameter({
    required this.name,
    required this.internalName,
    required this.type,
  });
}
