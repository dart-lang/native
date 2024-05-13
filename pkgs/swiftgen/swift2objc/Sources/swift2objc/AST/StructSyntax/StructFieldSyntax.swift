//
//  File.swift
//  
//
//  Created by Mohammad Eid on 13/05/2024.
//

import Foundation

struct StructFieldSyntax: StructMemberSyntax {
    let accessModifier: AccessModifier
    let isConstant: Bool
    let name: String
    let type: TypeSyntax
}
