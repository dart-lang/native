// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';
import 'api_availability.dart';
import 'objcinterfacedecl_parser.dart';

final _logger = Logger('ffigen.header_parser.objcprotocoldecl_parser');

ObjCProtocol? parseObjCProtocolDeclaration(clang_types.CXCursor cursor) {
  if (cursor.kind != clang_types.CXCursorKind.CXCursor_ObjCProtocolDecl) {
    return null;
  }

  final usr = cursor.usr();
  final name = cursor.spelling();

  final decl = Declaration(usr: usr, originalName: name);

  final cachedProtocol = bindingsIndex.getSeenObjCProtocol(usr);
  if (cachedProtocol != null) {
    return cachedProtocol;
  }

  // There's a strange shape in the AST for protocols seen in certain contexts,
  // where instead of the AST looking like (decl -> methods/etc), it looks like
  // (stubDecl --superProto-> decl -> methods/etc). If we try and parse the stub
  // in this case, we'll be left with an empty protocol with itself as its super
  // protocol. The USR is the same for both the stub and the real decl, so at
  // least this case is easy to detect and fix.
  final selfSuperCursor = cursor.findChildWhere((child) {
    if (child.kind == clang_types.CXCursorKind.CXCursor_ObjCProtocolRef) {
      return clang.clang_getCursorDefinition(child).usr() == usr;
    }
    return false;
  });
  if (selfSuperCursor != null) {
    cursor = clang.clang_getCursorDefinition(selfSuperCursor);
  }

  final report = getApiAvailability(cursor);

  _logger.fine('++++ Adding ObjC protocol: '
      'Name: $name, ${cursor.completeStringRepr()}');

  final protocol = ObjCProtocol(
    usr: usr,
    originalName: name,
    name: config.objcProtocols.rename(decl),
    lookupName: applyModulePrefix(name, config.protocolModule(decl)),
    dartDoc: getCursorDocComment(cursor,
        fallbackComment: name, availability: report.dartDoc),
    builtInFunctions: objCBuiltInFunctions,
    unavailable: report.availability == Availability.none,
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
        final superProtocol = parseObjCProtocolDeclaration(declCursor);
        if (superProtocol != null) {
          protocol.superProtocols.add(superProtocol);
        }
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
        final (getter, setter) =
            parseObjCProperty(child, decl, config.objcProtocols);
        protocol.addMethod(getter);
        protocol.addMethod(setter);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        protocol.addMethod(parseObjCMethod(child, decl, config.objcProtocols));
        break;
    }
  });
  return protocol;
}
