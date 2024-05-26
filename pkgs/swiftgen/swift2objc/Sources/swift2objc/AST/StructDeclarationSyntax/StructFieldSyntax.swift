// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// Describes a struct field (i.e, a field that stores an actual value, not just a getter)
struct StructFieldSyntax: StructMemberSyntax {
    var accessModifier: AccessModifier
    var isConstant: Bool
    var name: String
    var type: TypeDeclarationSyntax
}
