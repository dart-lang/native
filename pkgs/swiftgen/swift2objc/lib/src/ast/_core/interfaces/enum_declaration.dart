// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'protocol_conformable.dart';
import 'declaration.dart';
import 'type_parameterizable.dart';

/// An interface for describing the declaration of a Swift enum. See `NormalEnumDeclaration`,
/// `AssociatedValueEnumDeclaration` and `RawValueEnumDeclaration` for concrete implementations.
abstract interface class EnumDeclaration
    implements Declaration, TypeParameterizable, ProtocolConformable {
  abstract List<EnumCase> cases;
}

/// An interface describing an enum case. See `NormalEnumCase`, `AssociatedValueEnumCase` 
/// and `RawValueEnumCase` for concrete implementations.
abstract interface class EnumCase implements Declaration {}
