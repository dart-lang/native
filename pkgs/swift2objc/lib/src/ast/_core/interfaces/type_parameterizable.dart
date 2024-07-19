// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../shared/referred_type.dart';

/// An interface to describe a Swift entity's ability to
/// have generic parameters.
abstract interface class TypeParameterizable {
  abstract final List<GenericType> typeParams;
}
