// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/declarations/typealias_declaration.dart';
import '../_core/utils.dart';
import '../generator.dart';

List<String> generateTypealias(TypealiasDeclaration declaration) {
  return [
    'public typealias ${declaration.name} = ${declaration.target.swiftType};',
  ];
}
