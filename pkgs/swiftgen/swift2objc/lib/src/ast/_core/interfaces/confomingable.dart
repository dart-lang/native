// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../declarations/compounds/protocol_declaration.dart';
import '../shared/referred_type.dart';

/// An interface to describe a Swift entity's ability to confom to protocols.
abstract interface class Conformingable {
  abstract List<DeclaredType<ProtocolDeclaration>> conformedProtocols;
}
