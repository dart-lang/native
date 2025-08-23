// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'unique_namer.dart';
import 'utils.dart';
import 'writer.dart';

enum CompoundType { struct, union }

/// A binding for Compound type - Struct/Union.
abstract class Compound extends BindingType {
  /// Marker for if a struct definition is complete.
  ///
  /// A function can be safely pass this struct by value if it's complete.
  bool isIncomplete;

  List<CompoundMember> members;

  bool get isOpaque => members.isEmpty;

  /// Value for `@Packed(X)` annotation. Can be null (no packing), 1, 2, 4, 8,
  /// or 16.
  ///
  /// Only supported for [CompoundType.struct].
  int? pack;

  /// Marker for checking if the dependencies are parsed.
  bool parsedDependencies = false;

  CompoundType compoundType;
  bool get isStruct => compoundType == CompoundType.struct;
  bool get isUnion => compoundType == CompoundType.union;

  final Context context;

  /// The way the native type is written in C source code. This isn't always the
  /// same as the originalName, because the type may need to be prefixed with
  /// `struct` or `union`, depending on whether the declaration is a typedef.
  final String nativeType;

  Compound({
    super.usr,
    super.originalName,
    required super.name,
    required this.compoundType,
    this.isIncomplete = false,
    this.pack,
    super.dartDoc,
    List<CompoundMember>? members,
    super.isInternal,
    required this.context,
    String? nativeType,
  }) : members = members ?? [],
       nativeType = nativeType ?? originalName ?? name;

  factory Compound.fromType({
    required CompoundType type,
    String? usr,
    String? originalName,
    required String name,
    bool isIncomplete = false,
    int? pack,
    String? dartDoc,
    List<CompoundMember>? members,
    required Context context,
    String? nativeType,
  }) {
    switch (type) {
      case CompoundType.struct:
        return Struct(
          usr: usr,
          originalName: originalName,
          name: name,
          isIncomplete: isIncomplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
          context: context,
          nativeType: nativeType,
        );
      case CompoundType.union:
        return Union(
          usr: usr,
          originalName: originalName,
          name: name,
          isIncomplete: isIncomplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
          context: context,
          nativeType: nativeType,
        );
    }
  }

  String _getInlineArrayTypeString(Type type) {
    if (type is ConstantArray) {
      return '${context.libs.ffiLibraryPrefix}.Array<'
          '${_getInlineArrayTypeString(type.child)}>';
    }
    return type.getCType(context);
  }

  @override
  bool get isObjCImport =>
      context.objCBuiltInFunctions.getBuiltInCompoundName(originalName) != null;

  @override
  BindingString toBindingString(Writer w) {
    final bindingType = isStruct
        ? BindingStringType.struct
        : BindingStringType.union;

    final s = StringBuffer();
    final enclosingClassName = name;
    s.write(makeDartDoc(dartDoc));

    /// Adding [enclosingClassName] because dart doesn't allow class member
    /// to have the same name as the class.
    final localUniqueNamer = UniqueNamer()..markUsed(enclosingClassName);

    /// Marking type names because dart doesn't allow class member to have the
    /// same name as a type name used internally.
    for (final m in members) {
      localUniqueNamer.markUsed(m.type.getFfiDartType(context));
    }

    /// Write @Packed(X) annotation if struct is packed.
    final prefix = context.libs.ffiLibraryPrefix;
    if (isStruct && pack != null) {
      s.write('@$prefix.Packed($pack)\n');
    }
    final dartClassName = isStruct ? 'Struct' : 'Union';
    // Write class declaration.
    s.write('final class $enclosingClassName extends ');
    s.write('$prefix.${isOpaque ? 'Opaque' : dartClassName}{\n');
    const depth = '  ';
    for (final m in members) {
      m.name = localUniqueNamer.makeUnique(m.name);
      if (m.dartDoc != null) {
        s.write('$depth/// ');
        s.writeAll(m.dartDoc!.split('\n'), '\n$depth/// ');
        s.write('\n');
      }
      if (m.type case final ConstantArray arrayType) {
        s.writeln(makeArrayAnnotation(w, arrayType));
        s.write('${depth}external ${_getInlineArrayTypeString(m.type)} ');
        s.write('${m.name};\n\n');
      } else {
        if (!m.type.sameFfiDartAndCType) {
          s.write('$depth@${m.type.getCType(context)}()\n');
        }
        final memberName = m.type.sameDartAndFfiDartType
            ? m.name
            : '${m.name}AsInt';
        s.write(
          '${depth}external ${m.type.getFfiDartType(context)} $memberName;\n\n',
        );
      }
      if (m.type case EnumClass(:final generateAsInt) when !generateAsInt) {
        final enumName = m.type.getDartType(context);
        final memberName = m.name;
        s.write(
          '$enumName get $memberName => '
          '$enumName.fromValue(${memberName}AsInt);\n\n',
        );
      }
    }
    s.write('}\n\n');

    return BindingString(type: bindingType, string: s.toString());
  }

  @override
  bool get isIncompleteCompound => isIncomplete;

  @override
  String getCType(Context _) {
    final builtInName = context.objCBuiltInFunctions.getBuiltInCompoundName(
      originalName,
    );
    return builtInName != null
        ? '${context.libs.objcPkgPrefix}.$builtInName'
        : name;
  }

  @override
  String getNativeType({String varName = ''}) => '$nativeType $varName';

  @override
  bool get sameFfiDartAndCType => true;

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(members);
  }

  @override
  void visit(Visitation visitation) => visitation.visitCompound(this);
}

class CompoundMember extends AstNode {
  final String? dartDoc;
  final String originalName;
  String name;
  final Type type;

  CompoundMember({
    String? originalName,
    required this.name,
    required this.type,
    this.dartDoc,
  }) : originalName = originalName ?? name;

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(type);
  }
}
