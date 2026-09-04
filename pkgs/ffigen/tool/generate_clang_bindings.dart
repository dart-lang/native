// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Uri.directory(Directory.current.path);

  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve(
          'lib/src/header_parser/clang_bindings/clang_bindings.dart',
        ),
      ),
      style: const DynamicLibraryBindings(
        wrapperName: 'Clang',
        wrapperDocComment: 'Holds bindings to LibClang.',
      ),
      preamble: '''
// Part of the LLVM Project, under the Apache License v2.0 with LLVM
// Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
''',
    ),
    input: Input(
      entryPoints: [
        packageRoot.resolve('third_party/libclang/include/clang-c/Index.h'),
      ],
      compilerOptions: [
        '-I${packageRoot.resolve('third_party/libclang/include').toFilePath()}',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
      include: (header) {
        final path = header.toFilePath();
        return path.endsWith('wrapper.c') ||
            path.endsWith('Index.h') ||
            path.endsWith('CXString.h');
      },
    ),
    visitors: [
      Visitor(
        enumClass: (node) {
          const included = {
            'CXChildVisitResult',
            'CXCursorKind',
            'CXTypeKind',
            'CXDiagnosticDisplayOptions',
            'CXTranslationUnit_Flags',
            'CXEvalResultKind',
            'CXObjCPropertyAttrKind',
            'CXTypeNullabilityKind',
            'CXTypeLayoutError',
            'CX_CXXAccessSpecifier',
          };
          node.isIncluded = included.contains(node.name);
          node.style = .intConstants;
        },
        struct: (node) {
          const included = {
            'CXCursor',
            'CXType',
            'CXSourceLocation',
            'CXString',
            'CXTranslationUnitImpl',
            'CXUnsavedFile',
            'CXSourceRange',
          };
          node.isIncluded = included.contains(node.name);
        },
        func: (node) {
          const included = {
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
            'clang_Type_getSizeOf',
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
            'clang_getCXXAccessSpecifier',
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
            'clang_Type_getNumTemplateArguments',
            'clang_Type_getTemplateArgumentAsType',
          };
          node.isIncluded = included.contains(node.name);
        },
        typealias: (node) {
          if (!RegExp(r'.*time(64)?_t').hasMatch(node.name)) {
            node.isIncluded = .ifUsed;
          }
        },
      ),
    ],
  );
}

Future<void> main() async {
  await getConfig().generate();
}
