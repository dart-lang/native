// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../shared/parameter.dart';

/// An interface to describe a Swift entity's ability to have parameters (e.g functions).
abstract interface class Parameterizable {
  abstract List<Parameter> params;
}
