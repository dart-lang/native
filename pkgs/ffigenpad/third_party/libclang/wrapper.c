// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Heavily adapted from
// https://github.com/dart-archive/ffigen/blob/46ddca94b6f623590fe9f2ad7202cef250e554e2/tool/wrapped_libclang/wrapper.c

#include "clang-c/Index.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// utility.
#define aloc(T) ((T *)malloc(sizeof(T)))
CXCursor *ptrToCXCursor(CXCursor t) {
  CXCursor *c = aloc(CXCursor);
  *c = t;
  return c;
}
CXString *ptrToCXString(CXString t) {
  CXString *c = aloc(CXString);
  *c = t;
  return c;
}
CXType *ptrToCXType(CXType t) {
  CXType *c = aloc(CXType);
  *c = t;
  return c;
}
CXSourceLocation *ptrToCXSourceLocation(CXSourceLocation t) {
  CXSourceLocation *c = aloc(CXSourceLocation);
  *c = t;
  return c;
}
CXSourceRange *ptrToCXSourceRange(CXSourceRange t) {
  CXSourceRange *c = aloc(CXSourceRange);
  *c = t;
  return c;
}

// START ===== WRAPPER FUNCTIONS =====================

CXString *clang_getClangVersion_wrap() {
  return ptrToCXString(clang_getClangVersion());
}

const char *clang_getCString_wrap(CXString *string) {
  const char *a = clang_getCString(*string);

  return a;
}

void clang_disposeString_wrap(CXString *string) {
  clang_disposeString(*string);
  free(string);
  return;
}

enum CXCursorKind clang_getCursorKind_wrap(CXCursor *cursor) {
  return clang_getCursorKind(*cursor);
}

CXCursor *clang_getCursorDefinition_wrap(CXCursor *cursor) {
  return ptrToCXCursor(clang_getCursorDefinition(*cursor));
}

CXString *clang_getCursorKindSpelling_wrap(enum CXCursorKind kind) {
  return ptrToCXString(clang_getCursorKindSpelling(kind));
}

CXType *clang_getCursorType_wrap(CXCursor *cursor) {
  return ptrToCXType(clang_getCursorType(*cursor));
}

CXString *clang_getTypeSpelling_wrap(CXType *type) {
  return ptrToCXString(clang_getTypeSpelling(*type));
}

CXString *clang_getTypeKindSpelling_wrap(enum CXTypeKind typeKind) {
  return ptrToCXString(clang_getTypeKindSpelling(typeKind));
}

CXType *clang_getResultType_wrap(CXType *functionType) {
  return ptrToCXType(clang_getResultType(*functionType));
}

CXType *clang_getPointeeType_wrap(CXType *pointerType) {
  return ptrToCXType(clang_getPointeeType(*pointerType));
}

CXType *clang_getCanonicalType_wrap(CXType *typerefType) {
  return ptrToCXType(clang_getCanonicalType(*typerefType));
}

enum CXTypeKind getCXTypeKind(CXType *cxtype) {
  return cxtype->kind;
}

CXType *clang_Type_getModifiedType_wrap(CXType *type) {
  return ptrToCXType(clang_Type_getModifiedType(*type));
}

enum CXTypeNullabilityKind clang_Type_getNullability_wrap(CXType *type) {
  return clang_Type_getNullability(*type);
}

CXType *clang_Type_getNamedType_wrap(CXType *elaboratedType) {
  return ptrToCXType(clang_Type_getNamedType(*elaboratedType));
}

long long clang_Type_getAlignOf_wrap(CXType *cxtype) {
  return clang_Type_getAlignOf(*cxtype);
}

CXCursor *clang_getTypeDeclaration_wrap(CXType *cxtype) {
  return ptrToCXCursor(clang_getTypeDeclaration(*cxtype));
}

CXString *clang_getTypedefName_wrap(CXType *cxtype) {
  return ptrToCXString(clang_getTypedefName(*cxtype));
}

CXType *clang_getTypedefDeclUnderlyingType_wrap(CXCursor *cxcursor) {
  return ptrToCXType(clang_getTypedefDeclUnderlyingType(*cxcursor));
}

/** The name of parameter, struct, typedef. */
CXString *clang_getCursorSpelling_wrap(CXCursor *cursor) {
  return ptrToCXString(clang_getCursorSpelling(*cursor));
}

CXString *clang_getCursorUSR_wrap(CXCursor *cursor) {
  return ptrToCXString(clang_getCursorUSR(*cursor));
}

CXCursor *clang_getTranslationUnitCursor_wrap(CXTranslationUnit tu) {
  return ptrToCXCursor(clang_getTranslationUnitCursor(tu));
}

CXString *clang_formatDiagnostic_wrap(CXDiagnostic diag, int opts) {
  return ptrToCXString(clang_formatDiagnostic(diag, opts));
}

// Alternative typedef for [CXCursorVisitor] using pointer for passing cursor
// and parent instead of passing by value
typedef enum CXChildVisitResult (*ModifiedCXCursorVisitor)(
    CXCursor *cursor, CXCursor *parent, CXClientData client_data);

// Do not write binding for this function.
// used by [clang_visitChildren_wrap].
enum CXChildVisitResult _visitorwrap(CXCursor cursor, CXCursor parent,
                                     CXClientData clientData) {
  uintptr_t loc = *((uintptr_t *) clientData);
  ModifiedCXCursorVisitor visitor = (ModifiedCXCursorVisitor) loc;
  return visitor(&cursor, &parent, NULL);
}
/** Visitor is a function pointer with parameters having pointers to cxcursor
 * instead of cxcursor by default. */
unsigned clang_visitChildren_wrap(CXCursor *parent, uintptr_t _modifiedVisitor) {
  return clang_visitChildren(*parent, _visitorwrap, &_modifiedVisitor);
}

int clang_getNumArgTypes_wrap(CXType *cxtype) {
  return clang_getNumArgTypes(*cxtype);
}

CXType *clang_getArgType_wrap(CXType *cxtype, unsigned i) {
  return ptrToCXType(clang_getArgType(*cxtype, i));
}

long long clang_getEnumConstantDeclValue_wrap(CXCursor *cursor) {
  return clang_getEnumConstantDeclValue(*cursor);
}

/** Returns non-zero if the ranges are the same, zero if they differ. */
unsigned clang_equalRanges_wrap(CXSourceRange *c1, CXSourceRange *c2) {
  return clang_equalRanges(*c1, *c2);
}

CXEvalResult clang_Cursor_Evaluate_wrap(CXCursor *cursor) {
  return clang_Cursor_Evaluate(*cursor);
}

CXCursor *clang_Cursor_getArgument_wrap(CXCursor *cursor, unsigned i) {
  return ptrToCXCursor(clang_Cursor_getArgument(*cursor, i));
}

int clang_Cursor_getNumArguments_wrap(CXCursor *cursor) {
  return clang_Cursor_getNumArguments(*cursor);
}

/** Returns the comment range. */
CXSourceRange *clang_Cursor_getCommentRange_wrap(CXCursor *cursor) {
  return ptrToCXSourceRange(clang_Cursor_getCommentRange(*cursor));
}

/** Returns the raw comment. */
CXString *clang_Cursor_getRawCommentText_wrap(CXCursor *cursor) {
  return ptrToCXString(clang_Cursor_getRawCommentText(*cursor));
}

/** Returns the first paragraph of doxygen doc comment. */
CXString *clang_Cursor_getBriefCommentText_wrap(CXCursor *cursor) {
  return ptrToCXString(clang_Cursor_getBriefCommentText(*cursor));
}

enum CX_StorageClass clang_Cursor_getStorageClass_wrap(CXCursor *cursor) {
  return clang_Cursor_getStorageClass(*cursor);
}

int clang_getFieldDeclBitWidth_wrap(CXCursor *C) {
  return clang_getFieldDeclBitWidth(*C);
}

unsigned clang_Cursor_hasAttrs_wrap(CXCursor *C) {
  return clang_Cursor_hasAttrs(*C);
}

unsigned clang_Cursor_isFunctionInlined_wrap(CXCursor *cursor) {
  return clang_Cursor_isFunctionInlined(*cursor);
}

unsigned clang_Cursor_isAnonymous_wrap(CXCursor *cursor) {
  return clang_Cursor_isAnonymous(*cursor);
}

unsigned clang_Cursor_isAnonymousRecordDecl_wrap(CXCursor *cursor) {
  return clang_Cursor_isAnonymousRecordDecl(*cursor);
}

int clang_Cursor_isNull_wrap(CXCursor *cursor) {
  return clang_Cursor_isNull(*cursor);
}

unsigned clang_Cursor_isMacroFunctionLike_wrap(CXCursor *cursor) {
  return clang_Cursor_isMacroFunctionLike(*cursor);
}

unsigned clang_Cursor_isMacroBuiltin_wrap(CXCursor *cursor) {
  return clang_Cursor_isMacroBuiltin(*cursor);
}

unsigned clang_Cursor_getObjCPropertyAttributes_wrap(CXCursor *cursor, unsigned reserved) {
  return clang_Cursor_getObjCPropertyAttributes(*cursor, reserved);
}

unsigned clang_Cursor_isObjCOptional_wrap(CXCursor *cursor) {
  return clang_Cursor_isObjCOptional(*cursor);
}

CXString *clang_Cursor_getObjCPropertyGetterName_wrap(CXCursor *C) {
  return ptrToCXString(clang_Cursor_getObjCPropertyGetterName(*C));
}

CXString *clang_Cursor_getObjCPropertySetterName_wrap(CXCursor *C) {
  return ptrToCXString(clang_Cursor_getObjCPropertySetterName(*C));
}

CXType *clang_getCursorResultType_wrap(CXCursor *C) {
  return ptrToCXType(clang_getCursorResultType(*C));
}

unsigned clang_isFunctionTypeVariadic_wrap(CXType *type) {
  return clang_isFunctionTypeVariadic(*type);
}

CXSourceLocation *clang_getCursorLocation_wrap(CXCursor *cursor) {
  return ptrToCXSourceLocation(clang_getCursorLocation(*cursor));
}

CXType *clang_getEnumDeclIntegerType_wrap(CXCursor *cursor) {
  return ptrToCXType(clang_getEnumDeclIntegerType(*cursor));
}

void clang_getFileLocation_wrap(CXSourceLocation *location, CXFile *file,
                                unsigned *line, unsigned *column,
                                unsigned *offset) {
  return clang_getFileLocation(*location, file, line, column, offset);
}

CXString *clang_getFileName_wrap(CXFile SFile) {
  return ptrToCXString(clang_getFileName(SFile));
}

unsigned long long clang_getNumElements_wrap(CXType *cxtype) {
  return clang_getNumElements(*cxtype);
}

CXType *clang_getArrayElementType_wrap(CXType *cxtype) {
  return ptrToCXType(clang_getArrayElementType(*cxtype));
}

unsigned clang_isConstQualifiedType_wrap(CXType *cxtype) {
  return clang_isConstQualifiedType(*cxtype);
}

int clang_Location_isInSystemHeader_wrap(CXSourceLocation *location) {
  return clang_Location_isInSystemHeader(*location);
}
// END ===== WRAPPER FUNCTIONS =====================
