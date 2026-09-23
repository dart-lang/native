// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:ffigen/ffigen.dart';

void faqVisitorExamples(Uri packageRoot, Uri symbolFileUri) {
  // snippet-start#remove_underscores
  Visitor(
    struct: (node) {
      if (node.name.startsWith('_')) {
        node.name = node.name.substring(1);
      }
    },
  )
  // snippet-end#remove_underscores
  ;

  // snippet-start#header_filter
  Input(
    entryPoints: [packageRoot.resolve('path/to/my_header.h')],
    include: (header) => header.path.endsWith('my_header.h'),
  )
  // snippet-end#header_filter
  ;

  // snippet-start#filter_by_name
  Visitor(
    func: (node) {
      // Include all functions starting with clang.
      node.isIncluded = node.name.startsWith('clang');
    },
  )
  // snippet-end#filter_by_name
  ;

  // snippet-start#unnamed_enums
  Visitor(
    unnamedEnumConstant: (node) {
      node.isIncluded = node.originalName.startsWith('CX');
      if (node.name.startsWith('CXType_')) {
        node.name = node.name.replaceFirst('CXType_', '');
      }
    },
  )
  // snippet-end#unnamed_enums
  ;

  // snippet-start#enum_int_constants
  Visitor(
    enumClass: (node) {
      if (node.name == 'MyIntegerEnum') {
        node.style = EnumStyle.intConstants;
      }
    },
  )
  // snippet-end#enum_int_constants
  ;

  // snippet-start#compound_dependencies
  Visitor(
    struct: (node) {
      // You can set the opaque option for all nodes.
      node.dependencies = CompoundDependencies.opaque;
    },
    union: (node) {
      // Or for specific nodes.
      if (node.name == 'MyOpaqueUnion') {
        node.dependencies = CompoundDependencies.opaque;
      }
    },
  )
  // snippet-end#compound_dependencies
  ;

  // snippet-start#expose_symbol_address
  Visitor(
    func: (node) {
      if (node.name == 'someFunc') {
        node.exposeSymbolAddress = true;
      }
    },
  )
  // snippet-end#expose_symbol_address
  ;

  // snippet-start#generate_typedefs
  Visitor(
    func: (node) {
      if (node.name == 'hello') {
        node.generateTypedefs = true;
      }
    },
  )
  // snippet-end#generate_typedefs
  ;

  // snippet-start#generate_symbol_file
  Output(
    dart: DartOutput(path: packageRoot.resolve('lib/base.dart')),
    symbolFile: SymbolFile(
      Uri.parse('package:my_pkg/base.dart'),
      packageRoot.resolve('lib/symbols.yaml'),
    ),
  )
  // snippet-end#generate_symbol_file
  ;

  // snippet-start#import_from_symbol_file
  final generator = FfiGenerator(
    output: Output(dart: DartOutput(path: Uri.file('lib/bindings.dart'))),
    importType: importFromSymbolFile(symbolFileUri),
  );
  // snippet-end#import_from_symbol_file
}
