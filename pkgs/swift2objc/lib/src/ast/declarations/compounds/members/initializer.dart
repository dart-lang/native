// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../_core/interfaces/executable.dart';
import '../../../_core/interfaces/parameterizable.dart';
import '../../../_core/shared/parameter.dart';

/// Describes an initializer for a Swift compound entity (e.g, class, structs)
class Initializer implements Executable, Parameterizable {
  @override
  List<Parameter> params;

  @override
  List<String> statements;

  Initializer({
    required this.params,
    required this.statements,
  });
}
