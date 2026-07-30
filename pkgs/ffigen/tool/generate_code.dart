// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:ffigen/ffigen.dart';

class LibClangVisitor extends Visitor {
  const LibClangVisitor();
  static const enums = {
    'CXChildVisitResult',
    'CXCursorKind',
    'CXTypeKind',
    'CXDiagnosticDisplayOptions',
    'CXTranslationUnit_Flags',
    'CXEvalResultKind',
    'CXObjCPropertyAttrKind',
    'CXTypeNullabilityKind',
    'CXTypeLayoutError',
    'CXDiagnosticSeverity',
  };

  static const structs = {
    'CXCursor',
    'CXType',
    'CXSourceLocation',
    'CXString',
    'CXTranslationUnitImpl',
    'CXUnsavedFile',
    'CXSourceRange',
    'CXPlatformAvailability',
    'CXVersion',
  };

  static const functions = {
    'clang_createIndex',
    'clang_disposeIndex',
    'clang_getNumDiagnostics',
    'clang_getDiagnostic',
    'clang_getDiagnosticSeverity',
    'clang_disposeDiagnostic',
    'clang_parseTranslationUnit',
    'clang_disposeTranslationUnit',
    'clang_EvalResult_getKind',
    'clang_EvalResult_getAsInt',
    'clang_EvalResult_getAsLongLong',
    'clang_EvalResult_getAsDouble',
    'clang_EvalResult_getAsStr',
    'clang_EvalResult_dispose',
    'clang_getCString',
    'clang_disposeString',
    'clang_getCursorKind',
    'clang_getCursorKindSpelling',
    'clang_getCursorType',
    'clang_getTypeSpelling',
    'clang_getTypeKindSpelling',
    'clang_getResultType',
    'clang_getTypedefName',
    'clang_getPointeeType',
    'clang_getCanonicalType',
    'clang_Type_getNamedType',
    'clang_Type_getAlignOf',
    'clang_getTypeDeclaration',
    'clang_getTypedefDeclUnderlyingType',
    'clang_getCursorSpelling',
    'clang_getTranslationUnitCursor',
    'clang_formatDiagnostic',
    'clang_visitChildren',
    'clang_Cursor_getNumArguments',
    'clang_Cursor_getArgument',
    'clang_getNumArgTypes',
    'clang_getArgType',
    'clang_isConstQualifiedType',
    'clang_isFunctionTypeVariadic',
    'clang_Cursor_getStorageClass',
    'clang_getCursorResultType',
    'clang_getCursorExtent',
    'clang_getEnumConstantDeclValue',
    'clang_getEnumDeclIntegerType',
    'clang_equalRanges',
    'clang_Cursor_getCommentRange',
    'clang_Cursor_getRawCommentText',
    'clang_Cursor_getBriefCommentText',
    'clang_getCursorLocation',
    'clang_getRangeStart',
    'clang_getRangeEnd',
    'clang_getFileLocation',
    'clang_getFileName',
    'clang_getNumElements',
    'clang_getArrayElementType',
    'clang_Cursor_isMacroFunctionLike',
    'clang_Cursor_isMacroBuiltin',
    'clang_Cursor_Evaluate',
    'clang_Cursor_isAnonymous',
    'clang_Cursor_isAnonymousRecordDecl',
    'clang_getCursorUSR',
    'clang_getFieldDeclBitWidth',
    'clang_Cursor_isFunctionInlined',
    'clang_getCursorDefinition',
    'clang_isCursorDefinition',
    'clang_CXXMethod_isConst',
    'clang_CXXMethod_isStatic',
    'clang_getCursorAvailability',
    'clang_getCursorPlatformAvailability',
    'clang_disposeCXPlatformAvailability',
    'clang_Cursor_isNull',
    'clang_Cursor_hasAttrs',
    'clang_Type_getObjCObjectBaseType',
    'clang_Cursor_getObjCPropertyAttributes',
    'clang_Cursor_getObjCPropertyGetterName',
    'clang_Cursor_getObjCPropertySetterName',
    'clang_Cursor_isObjCOptional',
    'clang_Type_getNullability',
    'clang_Type_getModifiedType',
    'clang_Location_isInSystemHeader',
    'clang_getClangVersion',
    'clang_Type_getNumObjCProtocolRefs',
    'clang_Type_getObjCProtocolDecl',
  };

  @override
  void visitEnum(EnumClass node) {
    node.style = EnumStyle.intConstants;
    if (node.originalName.isNotEmpty && !enums.contains(node.originalName)) {
      node.isIncluded = false;
    }
  }

  @override
  void visitStruct(Struct node) {
    node.dependencies = CompoundDependencies.full;
    if (node.originalName.isNotEmpty &&
        !structs.contains(node.originalName) &&
        !node.originalName.contains('Version') &&
        !node.originalName.contains('PlatformAvailability')) {
      node.isIncluded = false;
    }
  }

  @override
  void visitFunc(Func node) {
    if (!functions.contains(node.originalName)) {
      node.isIncluded = false;
    }
  }

  @override
  void visitTypealias(Typealias node) {
    node.includeUnused = true;
    if (RegExp(r'.*time(64)?_t$').hasMatch(node.originalName)) {
      node.isIncluded = false;
    }
  }
}

void main() {
  final root = Platform.script.resolve('../');
  FfiGenerator(
    input: Input(
      entryPoints: [
        root.resolve('third_party/libclang/include/clang-c/Index.h'),
      ],
      compilerOptions: ['-Ithird_party/libclang/include'],
      ignoreSourceErrors: true,
      include: (Uri header) =>
          header.path.endsWith('wrapper.c') ||
          header.path.endsWith('Index.h') ||
          header.path.endsWith('CXString.h'),
    ),
    visitors: [const LibClangVisitor()],
    output: Output(
      preamble: '''
// Part of the LLVM Project, under the Apache License v2.0 with LLVM
// Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
''',
      style: const DynamicLibraryBindings(
        wrapperName: 'Clang',
        wrapperDocComment: 'Holds bindings to LibClang.',
      ),
      dartFile: root.resolve(
        'lib/src/header_parser/clang_bindings/clang_bindings.dart',
      ),
    ),
  ).generate();
}
