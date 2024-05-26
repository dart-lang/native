// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// Describes the signature of a struct method
struct StructMethodSyntax: StructMemberSyntax {
    var isMutating: Bool
    var isAsync: Bool
    var isThrowing: Bool
    
    var accessModifier: AccessModifier
    
    var name: String
    var parameters: [ParameterSyntax]
    var genericParameters: [GenericParameterSyntax]
    var returnType: TypeDeclarationSyntax
}




