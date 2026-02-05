// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';
import 'objcinterfacedecl_parser.dart';

ObjCProtocol? parseObjCProtocolDeclaration(
  Context context,
  clang_types.CXCursor cursor,
) {
  final logger = context.logger;
  final config = context.config;
  final bindingsIndex = context.bindingsIndex;
  if (cursor.kind != clang_types.CXCursorKind.CXCursor_ObjCProtocolDecl) {
    return null;
  }

  final objcProtocols = config.objectiveC?.protocols;
  if (objcProtocols == null) {
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

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);

  logger.fine(
    '++++ Adding ObjC protocol: '
    'Name: $name, ${cursor.completeStringRepr()}',
  );

  final protocol = ObjCProtocol(
    context: context,
    usr: usr,
    originalName: name,
    name: objcProtocols.rename(decl),
    lookupName: applyModulePrefix(name, objcProtocols.module(decl)),
    dartDoc: getCursorDocComment(
      context,
      cursor,
      fallbackComment: name,
      availability: apiAvailability.dartDoc,
    ),
    apiAvailability: apiAvailability,
  );

  // Make sure to add the protocol to the index before parsing the AST, to break
  // cycles.
  bindingsIndex.addObjCProtocolToSeen(usr, protocol);

  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCProtocolRef:
        final declCursor = clang.clang_getCursorDefinition(child);
        logger.fine(
          '       > Super protocol: ${declCursor.completeStringRepr()}',
        );
        final superProtocol = parseObjCProtocolDeclaration(context, declCursor);
        if (superProtocol != null) {
          protocol.superProtocols.add(superProtocol);
        }
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
        final (getter, setter) = parseObjCProperty(
          context,
          child,
          decl,
          objcProtocols,
        );
        protocol.addMethod(getter);
        protocol.addMethod(setter);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        protocol.addMethod(
          parseObjCMethod(context, child, decl, objcProtocols),
        );
        break;
    }
  });
  return protocol;
}
