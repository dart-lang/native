// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'declaration.dart';
import '../../declarations/protocol_declaration.dart';
import 'genericable.dart';
import '../shared/parameter.dart';
import '../shared/referred_type.dart';

abstract interface class CompoundDeclaration
    implements Declaration, Genericable {
  abstract List<CompoundPropertyDeclaration> properties;
  abstract List<CompoundMethodDeclaration> methods;
  abstract List<ProtocolDeclaration> conformedProtocols;
}

abstract interface class CompoundPropertyDeclaration implements Declaration {
  abstract bool hasSetter;
  abstract ReferredType type;
}

abstract interface class CompoundMethodDeclaration
    implements Declaration, Genericable {
  abstract List<Parameter> params;
  abstract ReferredType returnType;
}
