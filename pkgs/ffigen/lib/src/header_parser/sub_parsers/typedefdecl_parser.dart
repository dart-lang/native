// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../type_extractor/extractor.dart';
import '../utils.dart';

/// Parses a typedef declaration.
///
/// Notes:
/// - Pointer to Typedefs structs are skipped if the struct is seen.
/// - If there are multiple typedefs for a declaration (struct/enum), the last
/// seen name is used.
/// - Typerefs are completely ignored.
///
/// Libclang marks them as following -
/// ```C
/// typedef struct A{
///   int a
/// } B, *pB; // Typedef(s).
///
/// typedef A D; // Typeref.
/// ```
Typealias parseTypedefDeclaration(
  Context context,
  clang_types.CXCursor cursor, {
  bool pointerReference = false,
}) {
  final logger = context.logger;
  final config = context.config;
  final bindingsIndex = context.bindingsIndex;
  final name = cursor.spelling();
  final usr = cursor.usr();

  final cachedType = bindingsIndex.getSeenTypealias(usr);
  if (cachedType != null) return cachedType;

  final decl = Declaration(usr: usr, originalName: name);
  final ct = clang.clang_getTypedefDeclUnderlyingType(cursor);
  final s = getCodeGenType(
    context,
    ct,
    pointerReference: pointerReference,
    originalCursor: cursor,
  );

  if (bindingsIndex.isSeenUnsupportedTypealias(usr)) {
    // Do not process unsupported typealiases again.
  } else if (s is UnimplementedType) {
    logger.fine(
      "Skipped Typedef '$name': "
      'Unimplemented type referred.',
    );
    bindingsIndex.addUnsupportedTypealiasToSeen(usr);
  } else if (s is Compound && s.originalName == name) {
    // Ignore typedef if it refers to a compound with the same original name.
    bindingsIndex.addUnsupportedTypealiasToSeen(usr);
    logger.fine(
      "Skipped Typedef '$name': "
      'Name matches with referred struct/union.',
    );
  } else if (s is EnumClass) {
    // Ignore typedefs to Enum.
    bindingsIndex.addUnsupportedTypealiasToSeen(usr);
    logger.fine("Skipped Typedef '$name': typedef to enum.");
  } else if (s is HandleType) {
    // Ignore typedefs to Handle.
    logger.fine("Skipped Typedef '$name': typedef to Dart Handle.");
    bindingsIndex.addUnsupportedTypealiasToSeen(usr);
  } else if (s is ConstantArray || s is IncompleteArray) {
    // Ignore typedefs to Constant Array.
    logger.fine("Skipped Typedef '$name': typedef to array.");
    bindingsIndex.addUnsupportedTypealiasToSeen(usr);
  } else if (s is BooleanType) {
    // Ignore typedefs to Boolean.
    logger.fine("Skipped Typedef '$name': typedef to bool.");
    bindingsIndex.addUnsupportedTypealiasToSeen(usr);
  } else {
    // Create typealias.
    final type = Typealias(
      usr: usr,
      originalName: name,
      name: config.typedefs.rename(decl),
      type: s,
      dartDoc: getCursorDocComment(context, cursor),
    );
    bindingsIndex.addTypealiasToSeen(usr, type);
    return type;
  }
  return Typealias.anonymous(usr: usr, name: name, type: s);
}
