// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../type_extractor/cxtypekindmap.dart';
import '../utils.dart';
import 'api_availability.dart';
import 'unnamed_enumdecl_parser.dart';

/// Parses an enum declaration. Returns (enumClass, nativeType). enumClass
/// is null for anonymous enums.
(EnumClass? enumClass, Type nativeType) parseEnumDeclaration(
  clang_types.CXCursor cursor,
  Context context,
) {
  final config = context.config;
  final logger = context.logger;
  EnumClass? enumClass;
  // Parse the cursor definition instead, if this is a forward declaration.
  cursor = context.cursorIndex.getDefinition(cursor);

  final enumUsr = cursor.usr();
  final String enumName;
  // Only set name using USR if the type is not Anonymous (i.e not inside
  // any typedef and declared inplace inside another type).
  if (clang.clang_Cursor_isAnonymous(cursor) == 0) {
    // This gives the significant name, i.e name of the enum if defined or
    // name of the first typedef declaration that refers to it.
    enumName = enumUsr.split('@').last;
  } else {
    enumName = '';
  }
  var nativeType = clang
      .clang_getEnumDeclIntegerType(cursor)
      .toCodeGenType(context);
  // Change to unsigned type by default.
  nativeType = signedToUnsignedNativeIntType[nativeType] ?? nativeType;
  var hasNegativeEnumConstants = false;

  // An enum declared with NS_OPTIONS.
  var isNSOptions = false;

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    logger.info('Omitting deprecated enum $enumName');
    return (null, nativeType);
  }

  final decl = Declaration(usr: enumUsr, originalName: enumName);
  if (enumName.isEmpty) {
    logger.fine('Saving anonymous enum.');
    final addedConstants = saveUnNamedEnum(context, cursor);
    hasNegativeEnumConstants = addedConstants
        .where((c) => c.rawValue.startsWith('-'))
        .isNotEmpty;
  } else {
    logger.fine('++++ Adding Enum: ${cursor.completeStringRepr()}');
    enumClass = EnumClass(
      usr: enumUsr,
      dartDoc: getCursorDocComment(
        context,
        cursor,
        availability: apiAvailability.dartDoc,
      ),
      originalName: enumName,
      name: config.enums.rename(decl),
      nativeType: nativeType,
      objCBuiltInFunctions: context.objCBuiltInFunctions,
    );
    cursor.visitChildren((clang_types.CXCursor child) {
      try {
        logger.finest('  enumCursorVisitor: ${child.completeStringRepr()}');
        switch (clang.clang_getCursorKind(child)) {
          case clang_types.CXCursorKind.CXCursor_EnumConstantDecl:
            final enumIntValue = clang.clang_getEnumConstantDeclValue(child);
            enumClass!.enumConstants.add(
              EnumConstant(
                dartDoc: getCursorDocComment(
                  context,
                  child,
                  indent: nesting.length + commentPrefix.length,
                ),
                originalName: child.spelling(),
                name: config.enums.renameMember(decl, child.spelling()),
                value: enumIntValue,
              ),
            );
            if (enumIntValue < 0) {
              hasNegativeEnumConstants = true;
            }
            break;
          case clang_types.CXCursorKind.CXCursor_FlagEnum:
            isNSOptions = true;
            break;
          case clang_types.CXCursorKind.CXCursor_UnexposedAttr:
            // Ignore.
            break;
          default:
            logger.fine('invalid enum constant');
        }
      } catch (e, s) {
        logger.severe(e);
        logger.severe(s);
        rethrow;
      }
    });
    final suggestedStyle = isNSOptions ? EnumStyle.intConstants : null;
    enumClass.style = config.enums.style(decl, suggestedStyle);
  }

  if (hasNegativeEnumConstants) {
    // Change enum native type to signed type.
    logger.fine(
      'For enum $enumUsr - using signed type for $nativeType : '
      '${unsignedToSignedNativeIntType[nativeType]}',
    );
    nativeType = unsignedToSignedNativeIntType[nativeType] ?? nativeType;
    enumClass?.nativeType = nativeType;
  }

  return (enumClass, nativeType);
}
