// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// Describes a parameter accepted by any function-like entity (e.g classes & structs initializers, methods, etc.)
struct ParameterSyntax {
    /// The outer name of the parameter. In case a parameter is positional (i.e outer name is `_` in declaration), this field will be `nil`
    let name: String?
    let innerName: String
    let type: TypeSyntax
}
