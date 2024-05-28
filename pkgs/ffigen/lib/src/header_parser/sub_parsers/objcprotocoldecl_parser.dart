// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../includer.dart';
import '../utils.dart';
import 'objcinterfacedecl_parser.dart';

final _logger = Logger('ffigen.header_parser.objcprotocoldecl_parser');

ObjCProtocol? parseObjCProtocolDeclaration(clang_types.CXCursor cursor,
    {bool ignoreFilter = false}) {
  if (cursor.kind != clang_types.CXCursorKind.CXCursor_ObjCProtocolDecl) {
    return null;
  }

  final usr = cursor.usr();
  final cachedProto = bindingsIndex.getSeenObjCProto(usr);
  if (cachedProto != null) {
    return cachedProto;
  }

  final name = cursor.spelling();

  if (!ignoreFilter && !shouldIncludeObjCProtocol(usr, name)) {
    return null;
  }

  _logger.fine('++++ Adding ObjC protocol: '
      'Name: $name, ${cursor.completeStringRepr()}');

  final proto = ObjCProtocol(
    usr: usr,
    originalName: name,
    name: config.objcProtocols.renameUsingConfig(name),
    lookupName: config.objcProtocolModulePrefixer.applyPrefix(name),
    dartDoc: getCursorDocComment(cursor),
    builtInFunctions: objCBuiltInFunctions,
  );

  // Make sure to add the proto to the index before parsing the AST, to break
  // cycles.
  bindingsIndex.addObjCProtoToSeen(usr, proto);

  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCProtocolRef:
        final decl = clang.clang_getCursorDefinition(child);
        _logger.fine('       > Super protocol: ${decl.completeStringRepr()}');
        final superProto =
            parseObjCProtocolDeclaration(decl, ignoreFilter: true);
        if (superProto != null) {
          proto.superProtos.add(superProto);
        }
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        final method = parseObjCMethod(child, name);
        if (method != null) {
          proto.addMethod(method);
        }
        break;
    }
  });
  return proto;
}
