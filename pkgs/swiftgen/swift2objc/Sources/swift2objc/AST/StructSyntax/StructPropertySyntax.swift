// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// Describes a struct property (i.e, a member with a getter/setter)
struct StructPropertySyntax: StructMemberSyntax {
    let accessModifier: AccessModifier
    let name: String
    let type: TypeSyntax
    let hasGetterOnly: Bool
}
