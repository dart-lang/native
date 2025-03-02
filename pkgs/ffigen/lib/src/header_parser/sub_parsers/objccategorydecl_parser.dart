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
import 'objcprotocoldecl_parser.dart';

final _logger = Logger('ffigen.header_parser.objccategorydecl_parser');

ObjCCategory? parseObjCCategoryDeclaration(clang_types.CXCursor cursor) {
  final usr = cursor.usr();
  final name = cursor.spelling();

  final decl = Declaration(usr: usr, originalName: name);

  final cachedCategory = bindingsIndex.getSeenObjCCategory(usr);
  if (cachedCategory != null) {
    return cachedCategory;
  }

  final apiAvailability = ApiAvailability.fromCursor(cursor);
  if (apiAvailability.availability == Availability.none) {
    _logger.info('Omitting deprecated category $name');
    return null;
  }

  _logger.fine('++++ Adding ObjC category: '
      'Name: $name, ${cursor.completeStringRepr()}');

  final itfCursor =
      cursor.findChildWithKind(clang_types.CXCursorKind.CXCursor_ObjCClassRef);
  if (itfCursor == null) {
    _logger.severe('Category $name has no interface.');
    return null;
  }

  final parentInterface = itfCursor.type().toCodeGenType();
  if (parentInterface is! ObjCInterface) {
    _logger.severe('Interface of category $name is $parentInterface, '
        'which is not a valid interface.');
    return null;
  }

  final category = ObjCCategory(
    usr: usr,
    originalName: name,
    name: config.objcCategories.rename(decl),
    parent: parentInterface,
    dartDoc: getCursorDocComment(cursor,
        fallbackComment: name, availability: apiAvailability.dartDoc),
    builtInFunctions: objCBuiltInFunctions,
  );

  bindingsIndex.addObjCCategoryToSeen(usr, category);

  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCProtocolRef:
        final protoCursor = clang.clang_getCursorDefinition(child);
        category.addProtocol(parseObjCProtocolDeclaration(protoCursor));
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
        final (getter, setter) =
            parseObjCProperty(child, decl, config.objcCategories);
        category.addMethod(getter);
        category.addMethod(setter);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        category.addMethod(parseObjCMethod(child, decl, config.objcCategories));
        break;
    }
  });

  _logger.fine('++++ Finished ObjC category: '
      'Name: $name, ${cursor.completeStringRepr()}');

  parentInterface.categories.add(category);
  return category;
}
