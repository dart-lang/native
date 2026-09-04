// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getBaseConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/generated/base_gen.dart'),
      ),
      style: const DynamicLibraryBindings(
        wrapperName: 'NativeLibraryBase',
        wrapperDocComment: 'Bindings to `headers/base.h`.',
      ),
      symbolFile: SymbolFile(
        Uri.parse('package:shared_bindings/generated/base_gen.dart'),
        packageRoot.resolve('lib/generated/base_symbols.yaml'),
      ),
    ),
    input: Input(entryPoints: [packageRoot.resolve('headers/base.h')]),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) => node.isIncluded = true,
        union: (node) => node.isIncluded = true,
        enumClass: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = .always,
      ),
    ],
  );
}

FfiGenerator getAConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('lib/generated/a_gen.dart')),
      style: const DynamicLibraryBindings(
        wrapperName: 'NativeLibraryA',
        wrapperDocComment: 'Bindings to `headers/a.h`.',
      ),
    ),
    input: Input(entryPoints: [packageRoot.resolve('headers/a.h')]),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) => node.isIncluded = true,
        union: (node) => node.isIncluded = true,
        enumClass: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = .always,
      ),
    ],
  );
}

FfiGenerator getASharedBaseConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/generated/a_shared_b_gen.dart'),
      ),
      style: const DynamicLibraryBindings(
        wrapperName: 'NativeLibraryASharedB',
        wrapperDocComment:
            'Bindings to `headers/a.h` with shared definitions from `headers/base.h`.',
      ),
    ),
    input: Input(entryPoints: [packageRoot.resolve('headers/a.h')]),
    importType: (Declaration decl) {
      const baseImport = LibraryImport(
        'imp\$1',
        'package:shared_bindings/generated/base_gen.dart',
      );

      const baseSymbols = {
        'BaseEnum',
        'base_func1',
        'BaseStruct1',
        'BaseStruct2',
        'BaseUnion1',
        'BaseUnion2',
        'BaseTypedef1',
        'BaseTypedef2',
      };
      if (baseSymbols.contains(decl.originalName)) {
        return ImportedType(
          baseImport,
          decl.originalName,
          decl.originalName,
          decl.originalName,
          importedDartType: true,
        );
      }

      const baseNativeTypedefs = {
        'BaseNativeTypedef1': 'DartBaseNativeTypedef1',
        'BaseNativeTypedef2': 'DartBaseNativeTypedef1',
        'BaseNativeTypedef3': 'DartBaseNativeTypedef1',
      };
      if (baseNativeTypedefs.containsKey(decl.originalName)) {
        return ImportedType(
          baseImport,
          decl.originalName,
          baseNativeTypedefs[decl.originalName]!,
          decl.originalName,
          importedDartType: true,
        );
      }

      return null;
    },
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) => node.isIncluded = true,
        union: (node) => node.isIncluded = true,
        enumClass: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = .always,
      ),
    ],
  );
}

Future<void> main() async {
  await getBaseConfig().generate();
  await getAConfig().generate();
  await getASharedBaseConfig().generate();
}
