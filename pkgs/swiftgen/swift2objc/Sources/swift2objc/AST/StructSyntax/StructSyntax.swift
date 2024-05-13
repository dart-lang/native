//
//  File.swift
//  
//
//  Created by Mohammad Eid on 11/05/2024.
//

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
