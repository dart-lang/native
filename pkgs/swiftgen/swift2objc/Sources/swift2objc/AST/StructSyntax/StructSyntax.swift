// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

struct StructSyntax {
    let accessModifier: AccessModifier
    let name: String
    let genericParameters: [GenericParameterSyntax]
    let conformedProtocols: [String]
    
    let fields: [StructFieldSyntax]
    let properties: [StructPropertySyntax]
    let methods: [StructMethodSyntax]
    
    let initializers: [StructInitializerSyntax]
}
