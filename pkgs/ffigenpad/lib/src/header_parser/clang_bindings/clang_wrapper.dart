// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// AUTO GENERATED FILE, DO NOT EDIT.
// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'clang_bindings.dart' as c;

class Clang {
  final clang_createIndex = c.clang_createIndex;
  final clang_disposeIndex = c.clang_disposeIndex;
  final clang_parseTranslationUnit = c.clang_parseTranslationUnit;
  final clang_disposeTranslationUnit = c.clang_disposeTranslationUnit;
  final clang_getNumDiagnostics = c.clang_getNumDiagnostics;
  final clang_getDiagnostic = c.clang_getDiagnostic;
  final clang_getDiagnosticSeverity = c.clang_getDiagnosticSeverity;
  final clang_disposeDiagnostic = c.clang_disposeDiagnostic;
  final clang_EvalResult_getKind = c.clang_EvalResult_getKind;
  final clang_EvalResult_getAsLongLong = c.clang_EvalResult_getAsLongLong;
  final clang_EvalResult_getAsDouble = c.clang_EvalResult_getAsDouble;
  final clang_EvalResult_getAsStr = c.clang_EvalResult_getAsStr;
  final clang_EvalResult_dispose = c.clang_EvalResult_dispose;
  final clang_getCString = c.clang_getCString_wrap;
  final clang_disposeString = c.clang_disposeString_wrap;
  final clang_getClangVersion = c.clang_getClangVersion_wrap;
  final clang_getCursorKind = c.clang_getCursorKind_wrap;
  final clang_getCursorDefinition = c.clang_getCursorDefinition_wrap;
  final clang_getCursorKindSpelling = c.clang_getCursorKindSpelling_wrap;
  final clang_getCursorType = c.clang_getCursorType_wrap;
  final clang_getTypeSpelling = c.clang_getTypeSpelling_wrap;
  final clang_getTypeKindSpelling = c.clang_getTypeKindSpelling_wrap;
  final clang_getResultType = c.clang_getResultType_wrap;
  final clang_getPointeeType = c.clang_getPointeeType_wrap;
  final clang_getCanonicalType = c.clang_getCanonicalType_wrap;
  final clang_Type_getModifiedType = c.clang_Type_getModifiedType_wrap;
  final clang_Type_getNullability = c.clang_Type_getNullability_wrap;
  final clang_Type_getNamedType = c.clang_Type_getNamedType_wrap;
  final clang_Type_getAlignOf = c.clang_Type_getAlignOf_wrap;
  final clang_getTypeDeclaration = c.clang_getTypeDeclaration_wrap;
  final clang_getTypedefName = c.clang_getTypedefName_wrap;
  final clang_getTypedefDeclUnderlyingType =
      c.clang_getTypedefDeclUnderlyingType_wrap;
  final clang_getCursorSpelling = c.clang_getCursorSpelling_wrap;
  final clang_getCursorUSR = c.clang_getCursorUSR_wrap;
  final clang_getTranslationUnitCursor = c.clang_getTranslationUnitCursor_wrap;
  final clang_formatDiagnostic = c.clang_formatDiagnostic_wrap;
  final clang_visitChildren = c.clang_visitChildren_wrap;
  final clang_getArgType = c.clang_getArgType_wrap;
  final clang_getNumArgTypes = c.clang_getNumArgTypes_wrap;
  final clang_getEnumConstantDeclValue = c.clang_getEnumConstantDeclValue_wrap;
  final clang_equalRanges = c.clang_equalRanges_wrap;
  final clang_Cursor_Evaluate = c.clang_Cursor_Evaluate_wrap;
  final clang_Cursor_getArgument = c.clang_Cursor_getArgument_wrap;
  final clang_Cursor_getNumArguments = c.clang_Cursor_getNumArguments_wrap;
  final clang_Cursor_getCommentRange = c.clang_Cursor_getCommentRange_wrap;
  final clang_Cursor_getRawCommentText = c.clang_Cursor_getRawCommentText_wrap;
  final clang_Cursor_getBriefCommentText =
      c.clang_Cursor_getBriefCommentText_wrap;
  final clang_Cursor_getStorageClass = c.clang_Cursor_getStorageClass_wrap;
  final clang_getFieldDeclBitWidth = c.clang_getFieldDeclBitWidth_wrap;
  final clang_Cursor_hasAttrs = c.clang_Cursor_hasAttrs_wrap;
  final clang_Cursor_isFunctionInlined = c.clang_Cursor_isFunctionInlined_wrap;
  final clang_Cursor_isAnonymous = c.clang_Cursor_isAnonymous_wrap;
  final clang_Cursor_isAnonymousRecordDecl =
      c.clang_Cursor_isAnonymousRecordDecl_wrap;
  final clang_Cursor_isNull = c.clang_Cursor_isNull_wrap;
  final clang_Cursor_isMacroFunctionLike =
      c.clang_Cursor_isMacroFunctionLike_wrap;
  final clang_Cursor_isMacroBuiltin = c.clang_Cursor_isMacroBuiltin_wrap;
  final clang_Cursor_getObjCPropertyAttributes =
      c.clang_Cursor_getObjCPropertyAttributes_wrap;
  final clang_Cursor_isObjCOptional = c.clang_Cursor_isObjCOptional_wrap;
  final clang_Cursor_getObjCPropertyGetterName =
      c.clang_Cursor_getObjCPropertyGetterName_wrap;
  final clang_Cursor_getObjCPropertySetterName =
      c.clang_Cursor_getObjCPropertySetterName_wrap;
  final clang_getCursorResultType = c.clang_getCursorResultType_wrap;
  final clang_isFunctionTypeVariadic = c.clang_isFunctionTypeVariadic_wrap;
  final clang_getCursorLocation = c.clang_getCursorLocation_wrap;
  final clang_getEnumDeclIntegerType = c.clang_getEnumDeclIntegerType_wrap;
  final clang_getFileLocation = c.clang_getFileLocation_wrap;
  final clang_getFileName = c.clang_getFileName_wrap;
  final clang_getNumElements = c.clang_getNumElements_wrap;
  final clang_getArrayElementType = c.clang_getArrayElementType_wrap;
  final clang_isConstQualifiedType = c.clang_isConstQualifiedType_wrap;
  final clang_Location_isInSystemHeader =
      c.clang_Location_isInSystemHeader_wrap;
  final getCXTypeKind = c.getCXTypeKind;
}
