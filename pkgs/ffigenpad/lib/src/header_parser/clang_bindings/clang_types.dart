// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Wraps every opaque struct in a pointer for similartiy with ffigen codebase.
library;

import 'dart:ffi';

import 'clang_bindings.dart' as clang;

export 'clang_bindings.dart'
    show
        CXChildVisitResult,
        CXCursorKind,
        CXDiagnostic,
        CXDiagnosticDisplayOptions,
        CXDiagnosticSeverity,
        CXEvalResult,
        CXEvalResultKind,
        CXFile,
        CXIndex,
        CXObjCPropertyAttrKind,
        CXTranslationUnit,
        CXTranslationUnit_Flags,
        CXTypeKind,
        CXTypeLayoutError,
        CXTypeNullabilityKind,
        CX_StorageClass;

typedef CXString = Pointer<clang.CXString>;
typedef CXUnsavedFile = Pointer<clang.CXUnsavedFile>;
typedef CXCursor = Pointer<clang.CXCursor>;
typedef CXType = Pointer<clang.CXType>;
typedef CXSourceRange = Pointer<clang.CXSourceRange>;
typedef CXSourceLocation = Pointer<clang.CXSourceLocation>;
