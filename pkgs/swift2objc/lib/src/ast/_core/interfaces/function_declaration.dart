// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../shared/referred_type.dart';
import 'declaration.dart';
import 'executable.dart';
import 'parameterizable.dart';
import 'type_parameterizable.dart';

/// Describes a function-like entity.
abstract interface class FunctionDeclaration
    implements Declaration, Parameterizable, Executable, TypeParameterizable {
  abstract final ReferredType returnType;
}
