/// Wraps every opaque struct in a pointer for similartiy with ffigen codebase.
library clang_types;

import 'clang_bindings.dart' as clang;
import 'dart:ffi';

export 'clang_bindings.dart' show CXTypeKind, CXChildVisitResult, CXCursorKind;

typedef CXString = Pointer<clang.CXString>;
typedef CXUnsavedFile = Pointer<clang.CXUnsavedFile>;
typedef CXTranslationUnitImpl = Pointer<clang.CXTranslationUnitImpl>;
typedef CXCursor = Pointer<clang.CXCursor>;
typedef CXType = Pointer<clang.CXType>;
typedef CXSourceRange = Pointer<clang.CXSourceRange>;
typedef CXSourceLocation = Pointer<clang.CXSourceLocation>;
