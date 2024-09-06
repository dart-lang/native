// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';
import 'api_availability.dart';
import 'objcinterfacedecl_parser.dart';

final _logger = Logger('ffigen.header_parser.objcprotocoldecl_parser');

ObjCProtocol? parseObjCProtocolDeclaration(clang_types.CXCursor cursor,
    {bool ignoreFilter = false}) {
  if (cursor.kind != clang_types.CXCursorKind.CXCursor_ObjCProtocolDecl) {
    return null;
  }

  final usr = cursor.usr();
  final cachedProtocol = bindingsIndex.getSeenObjCProtocol(usr);
  if (cachedProtocol != null) {
    return cachedProtocol;
  }

  final name = cursor.spelling();

  final decl = Declaration(usr: usr, originalName: name);
  if (!ignoreFilter && !shouldIncludeObjCProtocol(decl)) {
    return null;
  }

  if (!isApiAvailable(cursor)) {
    _logger.info('Omitting deprecated protocol $name');
    return null;
  }

  _logger.fine('++++ Adding ObjC protocol: '
      'Name: $name, ${cursor.completeStringRepr()}');

  final protocol = ObjCProtocol(
    usr: usr,
    originalName: name,
    name: config.objcProtocols.rename(decl),
    lookupName: applyModulePrefix(name, config.protocolModule(decl)),
    dartDoc: getCursorDocComment(cursor),
    builtInFunctions: objCBuiltInFunctions,
  );

  // Make sure to add the protocol to the index before parsing the AST, to break
  // cycles.
  bindingsIndex.addObjCProtocolToSeen(usr, protocol);

  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCProtocolRef:
        final declCursor = clang.clang_getCursorDefinition(child);
        _logger.fine(
            '       > Super protocol: ${declCursor.completeStringRepr()}');
        final superProtocol =
            parseObjCProtocolDeclaration(declCursor, ignoreFilter: true);
        if (superProtocol != null) {
          protocol.superProtocols.add(superProtocol);
        }
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        final method = parseObjCMethod(child, decl, config.objcProtocols);
        if (method != null) {
          protocol.addMethod(method);
        }
        break;
    }
  });
  return protocol;
}
