// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation

/// An enum of possible Swift access modifiers that controls the visibility of an entity (e.g classes, methods, properties, etc.)
enum AccessModifier {
    case `open`
    case `public`
    case `internal`
    case `fileprivate`
    case `private`
}
