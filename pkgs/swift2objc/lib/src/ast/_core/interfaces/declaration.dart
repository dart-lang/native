// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../shared/referred_type.dart';

/// A common interface for all Swift entities declarations.
abstract interface class Declaration {
  abstract final String id;
  abstract final String name;
}

extension AsDeclaredType<T extends Declaration> on T {
  DeclaredType<T> get asDeclaredType => DeclaredType(id: id, declaration: this);
}
