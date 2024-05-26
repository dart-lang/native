// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

protocol TypeDeclarationSyntax {
    var name: String { get set }
    var accessModifier: AccessModifier { get set }
    var conformedProtocols: [String] { get set }
    
    var properties: [TypePropertySyntax] { get set }
    var methods: [TypeMethodSyntax] { get set }
}

struct TypePropertySyntax {
    var accessModifier: AccessModifier
    var name: String
    var type: ReferredType
    var hasGetterOnly: Bool
}

struct TypeMethodSyntax {
    var isAsync: Bool
    var isThrowing: Bool
    
    var accessModifier: AccessModifier
    
    var name: String
    var parameters: [ParameterSyntax]
    var genericParameters: [GenericParameterSyntax]
    var returnType: ReferredType
}



protocol ReferredType {
    var name: String { get set };
}

class DeclaredType: ReferredType {
    var name: String;
    var declaration: TypeDeclarationSyntax;
    var typeParameters: [ReferredType]
    
    init(name: String, declaration: TypeDeclarationSyntax, typeParameters: [ReferredType]) {
        self.name = name
        self.declaration = declaration
        self.typeParameters = typeParameters
    }
}

class BuiltInType: ReferredType {
    var name: String;
    
    init(name: String) {
        self.name = name
    }
}
