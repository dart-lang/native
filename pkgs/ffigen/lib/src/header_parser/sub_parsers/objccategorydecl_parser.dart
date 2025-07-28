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
import 'objcprotocoldecl_parser.dart';

ObjCCategory? parseObjCCategoryDeclaration(
  Context context,
  clang_types.CXCursor cursor,
) {
  final config = context.config;
  final logger = context.logger;
  final usr = cursor.usr();
  final name = cursor.spelling();

  final decl = Declaration(usr: usr, originalName: name);

  final cachedCategory = context.bindingsIndex.getSeenObjCCategory(usr);
  if (cachedCategory != null) {
    return cachedCategory;
  }

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    logger.info('Omitting deprecated category $name');
    return null;
  }

  logger.fine(
    '++++ Adding ObjC category: '
    'Name: $name, ${cursor.completeStringRepr()}',
  );

  final itfCursor = cursor.findChildWithKind(
    clang_types.CXCursorKind.CXCursor_ObjCClassRef,
  );
  if (itfCursor == null) {
    logger.severe('Category $name has no interface.');
    return null;
  }

  final parentInterface = itfCursor.type().toCodeGenType(context);
  if (parentInterface is! ObjCInterface) {
    logger.severe(
      'Interface of category $name is $parentInterface, '
      'which is not a valid interface.',
    );
    return null;
  }

  final category = ObjCCategory(
    usr: usr,
    originalName: name,
    name: config.objcCategories.rename(decl),
    parent: parentInterface,
    dartDoc: getCursorDocComment(
      context,
      cursor,
      fallbackComment: name,
      availability: apiAvailability.dartDoc,
    ),
    context: context,
  );

  context.bindingsIndex.addObjCCategoryToSeen(usr, category);

  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCProtocolRef:
        final protoCursor = clang.clang_getCursorDefinition(child);
        category.addProtocol(
          parseObjCProtocolDeclaration(context, protoCursor),
        );
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
        final (getter, setter) = parseObjCProperty(
          context,
          child,
          decl,
          config.objcCategories,
        );
        category.addMethod(getter);
        category.addMethod(setter);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        category.addMethod(
          parseObjCMethod(context, child, decl, config.objcCategories),
        );
        break;
    }
  });

  logger.fine(
    '++++ Finished ObjC category: '
    'Name: $name, ${cursor.completeStringRepr()}',
  );

  parentInterface.categories.add(category);
  return category;
}
