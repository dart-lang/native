// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('tool/');
  final dartPath = outputDir != null
      ? outputDir.resolve('clang_bindings.dart')
      : configDir.resolve(
          '../lib/src/header_parser/clang_bindings/clang_bindings.dart',
        );
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
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
        configDir.resolve('../third_party/libclang/include/clang-c/Index.h'),
      ],
      include: (uri) =>
          Glob('/**wrapper.c').matches(uri.path) ||
          Glob('/**Index.h').matches(uri.path) ||
          Glob('/**CXString.h').matches(uri.path),
      compilerOptions: [
        // ignore: lines_longer_than_80_chars
        '-I${packageRoot.resolve('third_party/libclang/include').toFilePath()}',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = {
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
        }.contains(node.originalName),
        struct: (node) {
          node.isIncluded = {
            'CXCursor',
            'CXType',
            'CXSourceLocation',
            'CXString',
            'CXTranslationUnitImpl',
            'CXUnsavedFile',
            'CXSourceRange',
          }.contains(node.originalName);
          node.dependencies = CompoundDependencies.full;
        },
        union: (node) {
          node.isIncluded = true;
          node.dependencies = CompoundDependencies.full;
        },
        enumClass: (node) {
          node.isIncluded = {
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
          }.contains(node.originalName);
          if (true) {
            node.style = EnumStyle.intConstants;
          }
        },
        global: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded =
            (!RegExp(r'^.*time(64)?_t$').hasMatch(node.originalName))
            ? TypealiasInclude.ifUsed
            : TypealiasInclude.never,
      ),
    ],
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty
      ? Uri.directory(args.first)
      : Platform.environment['OUTPUT_DIR'] != null
      ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
      : null;
  await getConfig(outputDir: outputDir).generate();
}
