// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// Describes the shared components of a all struct members (i.e, methods, properties, and fields)
protocol StructMemberSyntax {
    var accessModifier: AccessModifier { get }
    var name: String { get }
}
