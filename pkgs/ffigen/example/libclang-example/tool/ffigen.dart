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

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  final libclangInclude = packageRoot
      .resolve('../../third_party/libclang/include')
      .toFilePath();
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('generated_bindings.dart')),
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
        '-I$libclangInclude',
        if (Platform.isMacOS)
          '-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/',
      ],
    ),
    importType: importType,
    visitors: [
      Visitor(
        func: (node) {
          if (node.name.startsWith('clang_')) {
            node.isIncluded = true;
            node.exposeSymbolAddress = true;
            node.generateTypedefs = true;
          }
        },
        struct: (node) {
          node.dependencies = CompoundDependencies.full;
          if (node.name.startsWith('CX')) {
            node.isIncluded = true;
          }
        },
        enumClass: (node) {
          if (node.name == 'CXTypeKind' || node.name == 'CXGlobalOptFlags') {
            node.isIncluded = true;
          }
        },
        typealias: (node) => node.isIncluded = .ifUsed,
        macroConstant: (node) => node.isIncluded = true,
      ),
    ],
  );
}

Future<void> main() async {
  await getConfig().generate();
}
