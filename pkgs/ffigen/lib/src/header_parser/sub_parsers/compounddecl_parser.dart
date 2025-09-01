// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../../strings.dart' as strings;
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';

/// Holds temporary information regarding [compound] while parsing.
class _ParsedCompound {
  final Context context;
  Compound compound;
  bool unimplementedMemberType = false;
  bool flexibleArrayMember = false;
  bool bitFieldMember = false;
  bool dartHandleMember = false;
  bool incompleteCompoundMember = false;

  _ParsedCompound(this.context, this.compound);

  bool get isIncomplete =>
      unimplementedMemberType ||
      flexibleArrayMember ||
      bitFieldMember ||
      (dartHandleMember && context.config.useDartHandle) ||
      incompleteCompoundMember ||
      alignment == clang_types.CXTypeLayoutError.CXTypeLayoutError_Incomplete;

  // A struct without any attribute is definitely not packed. #pragma pack(...)
  // also adds an attribute, but it's unexposed and cannot be travesed.
  bool hasAttr = false;

  // A struct which as a __packed__ attribute is definitely packed.
  bool hasPackedAttr = false;

  // Stores the maximum alignment from all the children.
  int maxChildAlignment = 0;

  // Alignment of this struct.
  int alignment = 0;

  bool get _isPacked {
    if (!hasAttr || isIncomplete) return false;
    if (hasPackedAttr) return true;

    return maxChildAlignment > alignment;
  }

  /// Returns pack value of a struct depending on config, returns null for no
  /// packing.
  int? get packValue {
    if (compound.isStruct && _isPacked && !isIncomplete) {
      if (strings.packingValuesMap.containsKey(alignment)) {
        return alignment;
      } else {
        context.logger.warning(
          'Unsupported pack value "$alignment" for Struct '
          '"${compound.name}".',
        );
        return null;
      }
    } else {
      return null;
    }
  }
}

/// Parses a compound declaration.
Compound? parseCompoundDeclaration(
  clang_types.CXCursor cursor,
  CompoundType compoundType,
  Context context, {

  /// To track if the declaration was used by reference(i.e T*). (Used to only
  /// generate these as opaque if `dependency-only` was set to opaque).
  bool pointerReference = false,
}) {
  // Set includer functions according to compoundType.
  final className = _compoundTypeDebugName(compoundType);
  final configDecl = switch (compoundType) {
    CompoundType.struct => context.config.structs,
    CompoundType.union => context.config.unions,
  };

  // Parse the cursor definition instead, if this is a forward declaration.
  final declUsr = cursor.usr();
  final String declName;

  // Only set name using USR if the type is not Anonymous (A struct is anonymous
  // if it has no name, is not inside any typedef and declared inline inside
  // another declaration).
  if (clang.clang_Cursor_isAnonymous(cursor) == 0) {
    // This gives the significant name, i.e name of the struct if defined or
    // name of the first typedef declaration that refers to it.
    declName = declUsr.split('@').last;
  } else {
    // Empty names are treated as inline declarations.
    declName = '';
  }

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    context.logger.info('Omitting deprecated $className $declName');
    return null;
  }

  final decl = Declaration(usr: declUsr, originalName: declName);
  if (declName.isEmpty) {
    cursor = context.cursorIndex.getDefinition(cursor);
    return Compound.fromType(
      type: compoundType,
      name: context.incrementalNamer.name('Unnamed$className'),
      usr: declUsr,
      dartDoc: getCursorDocComment(
        context,
        cursor,
        availability: apiAvailability.dartDoc,
      ),
      objCBuiltInFunctions: context.objCBuiltInFunctions,
      nativeType: cursor.type().spelling(),
    );
  } else {
    cursor = context.cursorIndex.getDefinition(cursor);
    context.logger.fine(
      '++++ Adding $className: Name: $declName, ${cursor.completeStringRepr()}',
    );
    return Compound.fromType(
      type: compoundType,
      usr: declUsr,
      originalName: declName,
      name: configDecl.rename(decl),
      dartDoc: getCursorDocComment(
        context,
        cursor,
        availability: apiAvailability.dartDoc,
      ),
      objCBuiltInFunctions: context.objCBuiltInFunctions,
      nativeType: cursor.type().spelling(),
    );
  }
}

void fillCompoundMembersIfNeeded(
  Compound compound,
  clang_types.CXCursor cursor,
  Context context, {

  /// To track if the declaration was used by reference(i.e T*). (Used to only
  /// generate these as opaque if `dependency-only` was set to opaque).
  bool pointerReference = false,
}) {
  if (compound.parsedDependencies) return;
  final compoundType = compound.compoundType;
  final logger = context.logger;

  cursor = context.cursorIndex.getDefinition(cursor);

  final parsed = _ParsedCompound(context, compound);
  final className = _compoundTypeDebugName(compoundType);
  parsed.hasAttr = clang.clang_Cursor_hasAttrs(cursor) != 0;
  parsed.alignment = cursor.type().alignment();
  compound.parsedDependencies = true; // Break cycles.

  cursor.visitChildren((cursor) => _compoundMembersVisitor(cursor, parsed));

  logger.finest(
    'Opaque: ${parsed.isIncomplete}, HasAttr: ${parsed.hasAttr}, '
    'AlignValue: ${parsed.alignment}, '
    'MaxChildAlignValue: ${parsed.maxChildAlignment}, '
    'PackValue: ${parsed.packValue}.',
  );
  compound.pack = parsed.packValue;

  if (parsed.unimplementedMemberType) {
    logger.fine(
      '---- Removed $className members, reason: member with '
      'unimplementedtype ${cursor.completeStringRepr()}',
    );
    logger.warning(
      'Removed All $className Members from ${compound.name}'
      '(${compound.originalName}), struct member has an unsupported type.',
    );
  } else if (parsed.flexibleArrayMember) {
    logger.fine(
      '---- Removed $className members, reason: incomplete array '
      'member ${cursor.completeStringRepr()}',
    );
    logger.warning(
      'Removed All $className Members from ${compound.name}'
      '(${compound.originalName}), Flexible array members not supported.',
    );
  } else if (parsed.bitFieldMember) {
    logger.fine(
      '---- Removed $className members, reason: bitfield members '
      '${cursor.completeStringRepr()}',
    );
    logger.warning(
      'Removed All $className Members from ${compound.name}'
      '(${compound.originalName}), Bit Field members not supported.',
    );
  } else if (parsed.dartHandleMember && context.config.useDartHandle) {
    logger.fine(
      '---- Removed $className members, reason: Dart_Handle member. '
      '${cursor.completeStringRepr()}',
    );
    logger.warning(
      'Removed All $className Members from ${compound.name}'
      '(${compound.originalName}), Dart_Handle member not supported.',
    );
  } else if (parsed.incompleteCompoundMember) {
    logger.fine(
      '---- Removed $className members, reason: Incomplete Nested Struct '
      'member. ${cursor.completeStringRepr()}',
    );
    logger.warning(
      'Removed All $className Members from ${compound.name}'
      '(${compound.originalName}), Incomplete Nested Struct member not '
      'supported.',
    );
  }

  // Clear all members if declaration is incomplete.
  if (parsed.isIncomplete) {
    compound.members.clear();
  }

  // C allows empty structs/union, but it's undefined behaviour at runtine.
  // So we need to mark a declaration incomplete if it has no members.
  compound.isIncomplete = parsed.isIncomplete || compound.members.isEmpty;
}

/// Visitor for the struct/union cursor
/// [clang_types.CXCursorKind.CXCursor_StructDecl]/
/// [clang_types.CXCursorKind.CXCursor_UnionDecl].
///
/// Child visitor invoked on struct/union cursor.
void _compoundMembersVisitor(
  clang_types.CXCursor cursor,
  _ParsedCompound parsed,
) {
  final context = parsed.context;
  final config = context.config;
  final compoundConf = switch (parsed.compound.compoundType) {
    CompoundType.struct => config.structs,
    CompoundType.union => config.unions,
  };
  final decl = Declaration(
    usr: parsed.compound.usr,
    originalName: parsed.compound.originalName,
  );
  try {
    switch (cursor.kind) {
      case clang_types.CXCursorKind.CXCursor_FieldDecl:
        context.logger.finer('===== member: ${cursor.completeStringRepr()}');

        // Set maxChildAlignValue.
        final align = cursor.type().alignment();
        if (align > parsed.maxChildAlignment) {
          parsed.maxChildAlignment = align;
        }

        final mt = cursor.toCodeGenType(context);
        if (mt is IncompleteArray) {
          // TODO(https://github.com/dart-lang/ffigen/issues/68): Structs with
          // flexible Array Members are not supported.
          parsed.flexibleArrayMember = true;
        }
        if (clang.clang_getFieldDeclBitWidth(cursor) != -1) {
          // TODO(https://github.com/dart-lang/ffigen/issues/84): Struct with
          // bitfields are not suppoorted.
          parsed.bitFieldMember = true;
        }
        if (mt is HandleType) {
          parsed.dartHandleMember = true;
        }
        if (mt.isIncompleteCompound) {
          parsed.incompleteCompoundMember = true;
        }
        if (mt.baseType is UnimplementedType) {
          parsed.unimplementedMemberType = true;
        }
        parsed.compound.members.add(
          CompoundMember(
            dartDoc: getCursorDocComment(
              context,
              cursor,
              indent: nesting.length + commentPrefix.length,
            ),
            originalName: cursor.spelling(),
            name: compoundConf.renameMember(decl, cursor.spelling()),
            type: mt,
          ),
        );

        break;

      case clang_types.CXCursorKind.CXCursor_PackedAttr:
        parsed.hasPackedAttr = true;

        break;
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
      case clang_types.CXCursorKind.CXCursor_StructDecl:
        // If the union/struct are anonymous, then we need to add them now,
        // otherwise they will be added in the next iteration.
        if (!cursor.isAnonymousRecordDecl()) break;

        final mt = cursor.toCodeGenType(context);
        if (mt.isIncompleteCompound) {
          parsed.incompleteCompoundMember = true;
        }

        // Anonymous members are always unnamed. To avoid environment-
        // dependent naming issues with the generated code, we explicitly
        // use the empty string as spelling.
        final spelling = '';

        parsed.compound.members.add(
          CompoundMember(
            dartDoc: getCursorDocComment(
              context,
              cursor,
              indent: nesting.length + commentPrefix.length,
            ),
            originalName: spelling,
            name: compoundConf.renameMember(decl, spelling),
            type: mt,
          ),
        );

        break;
    }
  } catch (e, s) {
    context.logger.severe(e);
    context.logger.severe(s);
    rethrow;
  }
}

String _compoundTypeDebugName(CompoundType compoundType) {
  return compoundType == CompoundType.struct ? 'Struct' : 'Union';
}
