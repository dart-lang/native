// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

struct StructMethodSyntax: StructMemberSyntax {
    let isMutating: Bool
    let isAsync: Bool
    let isThrowing: Bool
    
    let accessModifier: AccessModifier
    
    let name: String
    let parameters: [ParameterSyntax]
    let genericParameters: [GenericParameterSyntax]
    let returnType: TypeSyntax
}




