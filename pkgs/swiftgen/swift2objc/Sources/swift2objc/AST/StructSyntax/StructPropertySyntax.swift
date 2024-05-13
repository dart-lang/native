//
//  File.swift
//  
//
//  Created by Mohammad Eid on 13/05/2024.
//

import Foundation

struct StructPropertySyntax: StructMemberSyntax {
    let accessModifier: AccessModifier
    let name: String
    let type: TypeSyntax
    let hasGetterOnly: Bool
}
