// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'confomingable.dart';
import 'declaration.dart';
import 'genericable.dart';
import '../shared/referred_type.dart';
import 'paramable.dart';

abstract interface class CompoundDeclaration
    implements Declaration, Genericable, Conformingable {
  abstract List<CompoundPropertyDeclaration> properties;
  abstract List<CompoundMethodDeclaration> methods;
}

abstract interface class CompoundPropertyDeclaration implements Declaration {
  abstract bool hasSetter;
  abstract ReferredType type;
}

abstract interface class CompoundMethodDeclaration
    implements Declaration, Genericable, Paramable {
  abstract ReferredType returnType;
}
