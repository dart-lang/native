// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

const ffiImport = LibraryImport('ffi', 'dart:ffi');
const customImport = LibraryImport('custom_import', 'custom_import.dart');

ImportedType? importType(Declaration declaration) {
  if (declaration.originalName == 'time_t') {
    return ImportedType(ffiImport, 'Int64', 'int', 'time_t');
  }
  if (declaration.originalName == 'CXCursorSetImpl') {
    return ImportedType(
      customImport,
      'CXCursorSetImpl',
      'CXCursorSetImpl',
      'CXCursorSetImpl',
    );
  }
  return null;
}

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../example/libclang-example/');
  final dartPath = outputDir != null
      ? outputDir.resolve('generated_bindings.dart')
      : packageRoot.resolve('generated_bindings.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const DynamicLibraryBindings(
        wrapperName: 'LibClang',
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
        packageRoot.resolve(
          '../../third_party/libclang/include/clang-c/Index.h',
        ),
      ],
      include: (uri) =>
          uri.path.endsWith('CXString.h') || uri.path.endsWith('Index.h'),
      compilerOptions: [
        // ignore: lines_longer_than_80_chars
        '-I${packageRoot.resolve('../../third_party/libclang/include').toFilePath()}',
        '-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/',
      ],
    ),
    importType: importType,
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded = node.originalName.startsWith('clang_');
          if (node.originalName.startsWith('clang_')) {
            node.exposeSymbolAddress = true;
          }
          if (node.originalName.startsWith('clang_')) {
            node.generateTypedefs = true;
          }
        },
        struct: (node) {
          node.isIncluded = node.originalName.startsWith('CX');
          node.dependencies = CompoundDependencies.full;
        },
        union: (node) {
          node.isIncluded = true;
          node.dependencies = CompoundDependencies.full;
        },
        enumClass: (node) => node.isIncluded = {
          'CXTypeKind',
          'CXGlobalOptFlags',
        }.contains(node.originalName),
        global: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = TypealiasInclude.ifUsed,
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
