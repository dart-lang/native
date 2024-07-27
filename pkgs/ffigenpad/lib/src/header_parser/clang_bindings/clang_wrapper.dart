// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// AUTO GENERATED FILE, DO NOT EDIT.
// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'clang_bindings.dart' as clang;

class Clang {
  final clang_getCString = clang.clang_getCString_wrap;
  final clang_disposeString = clang.clang_disposeString_wrap;
  final clang_getClangVersion = clang.clang_getClangVersion_wrap;
  final clang_getCursorKind = clang.clang_getCursorKind_wrap;
  final clang_getCursorDefinition = clang.clang_getCursorDefinition_wrap;
  final clang_getCursorKindSpelling = clang.clang_getCursorKindSpelling_wrap;
  final clang_getCursorType = clang.clang_getCursorType_wrap;
  final clang_getTypeSpelling = clang.clang_getTypeSpelling_wrap;
  final clang_getTypeKindSpelling = clang.clang_getTypeKindSpelling_wrap;
  final clang_getResultType = clang.clang_getResultType_wrap;
  final clang_getPointeeType = clang.clang_getPointeeType_wrap;
  final clang_getCanonicalType = clang.clang_getCanonicalType_wrap;
  final clang_Type_getNamedType = clang.clang_Type_getNamedType_wrap;
  final clang_Type_getAlignOf = clang.clang_Type_getAlignOf_wrap;
  final clang_getTypeDeclaration = clang.clang_getTypeDeclaration_wrap;
  final clang_getTypedefDeclUnderlyingType = clang.clang_getTypedefDeclUnderlyingType_wrap;
  final clang_getCursorSpelling = clang.clang_getCursorSpelling_wrap;
  final clang_getCursorUSR = clang.clang_getCursorUSR_wrap;
  final clang_getTranslationUnitCursor = clang.clang_getTranslationUnitCursor_wrap;
  final clang_formatDiagnostic = clang.clang_formatDiagnostic_wrap;
  final clang_visitChildren = clang.clang_visitChildren_wrap;
  final clang_getArgType = clang.clang_getArgType_wrap;
  final clang_getNumArgTypes = clang.clang_getNumArgTypes_wrap;
  final clang_getEnumConstantDeclValue = clang.clang_getEnumConstantDeclValue_wrap;
  final clang_equalRanges = clang.clang_equalRanges_wrap;
  final clang_Cursor_getNumArguments = clang.clang_Cursor_getNumArguments_wrap;
  final clang_Cursor_getArgument = clang.clang_Cursor_getArgument_wrap;
  final clang_Cursor_getCommentRange = clang.clang_Cursor_getCommentRange_wrap;
  final clang_Cursor_getRawCommentText = clang.clang_Cursor_getRawCommentText_wrap;
  final clang_Cursor_getBriefCommentText = clang.clang_Cursor_getBriefCommentText_wrap;
  final clang_Cursor_isNull = clang.clang_Cursor_isNull_wrap;
  final clang_getCursorLocation = clang.clang_getCursorLocation_wrap;
  final clang_Cursor_isAnonymousRecordDecl = clang.clang_Cursor_isAnonymousRecordDecl_wrap;
  final clang_getFileLocation = clang.clang_getFileLocation_wrap;
  final clang_getFileName = clang.clang_getFileName_wrap;
  final clang_getNumElements = clang.clang_getNumElements_wrap;
  final clang_getArrayElementType = clang.clang_getArrayElementType_wrap;
  final clang_isConstQualifiedType = clang.clang_isConstQualifiedType_wrap;
  final clang_Location_isInSystemHeader = clang.clang_Location_isInSystemHeader_wrap;
}