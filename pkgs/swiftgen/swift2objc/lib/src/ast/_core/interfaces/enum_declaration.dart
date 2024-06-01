// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'confomingable.dart';
import 'declaration.dart';
import 'genericable.dart';

abstract interface class EnumDeclaration implements Declaration, Genericable, Conformingable {
  abstract List<EnumCase> cases;
}

abstract interface class EnumCase implements Declaration {}