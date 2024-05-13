//
//  File.swift
//  
//
//  Created by Mohammad Eid on 11/05/2024.
//

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




