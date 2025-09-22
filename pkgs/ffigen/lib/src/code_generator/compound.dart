// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider.dart';
import '../context.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'namespace.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding for Compound type - Struct/Union.
abstract class Compound extends BindingType with HasLocalNamespace {
  /// Marker for if a struct definition is complete.
  ///
  /// A function can be safely pass this struct by value if it's complete.
  bool isIncomplete;

  final List<CompoundMember> members;

  bool get isOpaque => members.isEmpty;

  /// Value for `@Packed(X)` annotation. Can be null (no packing), 1, 2, 4, 8,
  /// or 16.
  int? get pack;

  /// Marker for checking if the dependencies are parsed.
  bool parsedDependencies = false;

  final Context context;

  /// The way the native type is written in C source code. This isn't always the
  /// same as the originalName, because the type may need to be prefixed with
  /// `struct` or `union`, depending on whether the declaration is a typedef.
  final String nativeType;

  Compound({
    super.usr,
    super.originalName,
    required super.name,
    this.isIncomplete = false,
    super.dartDoc,
    List<CompoundMember>? members,
    super.isInternal,
    required this.context,
    String? nativeType,
  }) : members = members ?? [],
       nativeType = nativeType ?? originalName ?? name;

  String _getInlineArrayTypeString(Type type, Writer w) {
    if (type is ConstantArray) {
      return '${context.libs.prefix(ffiImport)}.Array<'
          '${_getInlineArrayTypeString(type.child, w)}>';
    }
    return type.getCType(context);
  }

  @override
  bool get isObjCImport =>
      context.objCBuiltInFunctions.getBuiltInCompoundName(originalName) != null;

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final enclosingClassName = name;
    s.write(makeDartDoc(dartDoc));

    /// Write @Packed(X) annotation if struct is packed.
    final ffiPrefix = context.libs.prefix(ffiImport);
    if (pack != null) {
      s.write('@$ffiPrefix.Packed($pack)\n');
    }
    final dartClassName = isOpaque
        ? 'Opaque'
        : this is Struct
        ? 'Struct'
        : 'Union';
    // Write class declaration.
    s.write('final class $enclosingClassName extends ');
    s.write('$ffiPrefix.$dartClassName{\n');
    const depth = '  ';
    for (final m in members) {
      if (m.dartDoc != null) {
        s.write('$depth/// ');
        s.writeAll(m.dartDoc!.split('\n'), '\n$depth/// ');
        s.write('\n');
      }
      if (m.type case final ConstantArray arrayType) {
        s.writeln(makeArrayAnnotation(w, arrayType));
        s.write('${depth}external ${_getInlineArrayTypeString(m.type, w)} ');
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
      if (m.type case EnumClass(
        :final style,
      ) when style == EnumStyle.dartEnum) {
        final enumName = m.type.getDartType(context);
        final memberName = m.name;
        s.write(
          '$enumName get $memberName => '
          '$enumName.fromValue(${memberName}AsInt);\n\n',
        );
      }
    }
    s.write('}\n\n');

    final bindingType = this is Struct
        ? BindingStringType.struct
        : BindingStringType.union;
    return BindingString(type: bindingType, string: s.toString());
  }

  @override
  bool get isIncompleteCompound => isIncomplete;

  @override
  String getCType(Context context) {
    final builtInName = context.objCBuiltInFunctions.getBuiltInCompoundName(
      originalName,
    );
    return builtInName != null
        ? '${context.libs.prefix(objcPkgImport)}.$builtInName'
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
    visitor.visit(ffiImport);
    if (isObjCImport) visitor.visit(objcPkgImport);
  }

  @override
  void visit(Visitation visitation) => visitation.visitCompound(this);
}

class CompoundMember extends AstNode {
  final String? dartDoc;
  final String originalName;
  final Type type;

  final Symbol _symbol;
  String get name => _symbol.name;

  CompoundMember({
    String? originalName,
    required String name,
    required this.type,
    this.dartDoc,
  }) : originalName = originalName ?? name,
       _symbol = Symbol(name);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(_symbol);
    visitor.visit(type);
  }
}
