// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/genericable.dart';
import '../../_core/interfaces/paramable.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';

/// A container for globally defined values (i.e variables & constants) and functions.
class Globals {
  List<GlobalFunction> functions;
  List<GlobalValue> values;

  Globals({
    required this.functions,
    required this.values,
  });
}

/// Describes a globally defined function.
class GlobalFunction implements Declaration, Paramable, Genericable {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  @override
  List<GenericType> genericParams;

  ReferredType returnType;

  GlobalFunction({
    required this.id,
    required this.name,
    required this.params,
    required this.genericParams,
    required this.returnType,
  });
}

/// Describes a globally defined values (i.e variable/constant).
class GlobalValue implements Declaration {
  @override
  String id;

  @override
  String name;

  DeclaredType type;

  bool isConstant;

  GlobalValue({
    required this.id,
    required this.name,
    required this.type,
    required this.isConstant,
  });
}
