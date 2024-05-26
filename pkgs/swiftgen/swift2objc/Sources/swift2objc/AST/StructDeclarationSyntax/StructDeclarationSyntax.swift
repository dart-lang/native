// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// Describes a struct
class StructDeclarationSyntax: TypeDeclarationSyntax {
    var accessModifier: AccessModifier
    var name: String
    var genericParameters: [GenericParameterSyntax]
    var conformedProtocols: [String]
    
    var fields: [StructFieldSyntax]
    var properties: [StructPropertySyntax]
    var methods: [StructMethodSyntax]
    
    var initializers: [StructInitializerSyntax]
    
    init(
        accessModifier: AccessModifier,
        name: String,
        genericParameters: [GenericParameterSyntax],
        conformedProtocols: [String],
        fields: [StructFieldSyntax],
        properties: [StructPropertySyntax],
        methods: [StructMethodSyntax],
        initializers: [StructInitializerSyntax]
    ) {
        self.accessModifier = accessModifier
        self.name = name
        self.genericParameters = genericParameters
        self.conformedProtocols = conformedProtocols
        self.fields = fields
        self.properties = properties
        self.methods = methods
        self.initializers = initializers
    }
}

