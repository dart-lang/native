// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// Describes a struct initializer
struct StructInitializerSyntax {
    var accessModifier: AccessModifier;
    var parameters: [ParameterSyntax]
    var genericParameters: [GenericParameterSyntax]
}
