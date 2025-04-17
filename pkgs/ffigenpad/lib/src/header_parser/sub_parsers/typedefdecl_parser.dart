// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_types.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../type_extractor/extractor.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.typedefdecl_parser');

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
///
/// Returns `null` if the typedef could not be generated or has been excluded
/// by the config.
Typealias? parseTypedefDeclaration(
  clang_types.CXCursor cursor, {
  bool pointerReference = false,
}) {
  final typedefName = cursor.spelling();
  final typedefUsr = cursor.usr();
  final decl = Declaration(usr: typedefUsr, originalName: typedefName);
  if (shouldIncludeTypealias(decl)) {
    final ct = clang.clang_getTypedefDeclUnderlyingType(cursor);
    final s = getCodeGenType(ct,
        pointerReference: pointerReference, originalCursor: cursor);

    if (bindingsIndex.isSeenUnsupportedTypealias(typedefUsr)) {
      // Do not process unsupported typealiases again.
    } else if (s is UnimplementedType) {
      _logger.fine("Skipped Typedef '$typedefName': "
          'Unimplemented type referred.');
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else if (s is Compound && s.originalName == typedefName) {
      // Ignore typedef if it refers to a compound with the same original name.
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
      _logger.fine("Skipped Typedef '$typedefName': "
          'Name matches with referred struct/union.');
    } else if (s is EnumClass) {
      // Ignore typedefs to Enum.
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
      _logger.fine("Skipped Typedef '$typedefName': typedef to enum.");
    } else if (s is HandleType) {
      // Ignore typedefs to Handle.
      _logger.fine("Skipped Typedef '$typedefName': typedef to Dart Handle.");
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else if (s is ConstantArray || s is IncompleteArray) {
      // Ignore typedefs to Constant Array.
      _logger.fine("Skipped Typedef '$typedefName': typedef to array.");
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else if (s is BooleanType) {
      // Ignore typedefs to Boolean.
      _logger.fine("Skipped Typedef '$typedefName': typedef to bool.");
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else {
      // Create typealias.
      return Typealias(
        usr: typedefUsr,
        originalName: typedefName,
        name: config.typedefs.rename(decl),
        type: s,
        dartDoc: getCursorDocComment(cursor),
      );
    }
  }
  return null;
}
