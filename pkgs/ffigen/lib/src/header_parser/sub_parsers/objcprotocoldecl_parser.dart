// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import 'objcinterfacedecl_parser.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.objcprotocoldecl_parser');

BindingType? parseObjCProtocolDeclaration(clang_types.CXCursor cursor) {
  // ObjCProtocolDecl
  //   ObjCProtocolRef
  //   ObjCInstanceMethodDecl
  final name = cursor.spelling();

  cursor.visitChildren((child) {
    if (name == "MyProtocol") {
      print("");
      child.printAst(5);
    }
  });
  return null;
}
