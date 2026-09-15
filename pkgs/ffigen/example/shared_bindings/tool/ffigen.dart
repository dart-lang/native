// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

// ignore: avoid_relative_lib_imports
import '../lib/generated/base_symbols.dart' as base_symbols;

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
        packageRoot.resolve('lib/generated/base_symbols.dart'),
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

FfiGenerator getASharedBaseConfig([
  Uri? packageRoot,
  FfigenSymbols? baseSymbols,
]) {
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
    importType: importFromSymbols(baseSymbols ?? base_symbols.symbols),
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
  final baseResult = await getBaseConfig().generate();
  await getAConfig().generate();
  await getASharedBaseConfig(null, baseResult.symbols).generate();
}
