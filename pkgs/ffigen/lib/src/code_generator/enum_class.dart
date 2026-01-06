// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import '../config_provider.dart';
import '../context.dart';
import '../visitor/ast.dart';
import 'binding_string.dart';
import 'imports.dart';
import 'scope.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding for enums in C.
///
/// For a C enum -
/// ```c
/// enum Fruits {apple, banana = 10, yellow_fruit = 10};
/// ```
/// The generated dart code is
///
/// ```dart
/// enum Fruits {
///   apple(0),
///   banana(10);
///
///   static const yellow_fruit = banana;
///
///   final int value;
///   const Fruit(this.value);
///
///   @override
///   String toString() {
///     if (this == banana) return "Fruits.banana, Fruits.yellow_fruit";
///     return super.toString();
///   }
/// }
/// ```
class EnumClass extends BindingType with HasLocalScope {
  /// Backing integer type for this enum.
  Type nativeType;

  /// A list of all the members of the native enum.
  final List<EnumConstant> enumConstants;

  Context context;

  /// Whether this enum should be generated as a collection of integers.
  EnumStyle style;

  bool isAnonymous;

  EnumClass({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    Type? nativeType,
    List<EnumConstant>? enumConstants,
    required this.context,
    this.style = EnumStyle.dartEnum,
    this.isAnonymous = false,
  }) : nativeType = nativeType ?? intType,
       enumConstants = enumConstants ?? [];

  /// Returns a string to declare the enum member and any documentation it may
  /// have had.
  String _formatValue(EnumConstant ec, {bool asInt = false}) {
    final buffer = StringBuffer();
    if (ec.dartDoc != null) {
      buffer.write('  /// ');
      buffer.writeAll(ec.dartDoc!.split('\n'), '\n  /// ');
      buffer.write('\n');
    }
    if (asInt) {
      buffer.write('  static const ${ec.name} = ${ec.value};');
    } else {
      buffer.write('  ${ec.name}(${ec.value})');
    }
    return buffer.toString();
  }

  void _writeIntegerConstants(StringBuffer s) {
    s.writeAll(enumConstants.map((c) => _formatValue(c, asInt: true)), '\n');
  }

  /// Writes the enum declarations for all unique members.
  ///
  /// Eg, C: `apple = 1`, Dart: `apple(1)`
  void _writeUniqueMembers(StringBuffer s, Set<EnumConstant> uniqueMembers) {
    s.writeAll(uniqueMembers.map(_formatValue), ',\n');
    if (uniqueMembers.isNotEmpty) s.write(';\n');
  }

  /// Writes alias declarations for all members with duplicate values.
  ///
  /// Eg, C: `banana = 10, yellow_fruit = 10`.
  /// Dart: `static const yellow_fruit = banana`.
  void _writeDuplicateMembers(
    StringBuffer s,
    Map<EnumConstant, EnumConstant> duplicateToOriginal,
  ) {
    if (duplicateToOriginal.isEmpty) return;
    for (final entry in duplicateToOriginal.entries) {
      final duplicate = entry.key;
      final original = entry.value;
      if (duplicate.dartDoc != null) {
        s.write('  /// ');
        s.writeAll(duplicate.dartDoc!.split('\n'), '\n  /// ');
        s.write('\n');
      }
      s.write('  static const ${duplicate.name} = ${original.name};\n');
    }
  }

  /// Writes the constructor for the enum.
  ///
  /// Always accepts an integer value to match the native value.
  void _writeConstructor(StringBuffer s) {
    s.write('  final int value;\n');
    s.write('  const $name(this.value);\n');
  }

  /// Overrides [Enum.toString] so all aliases are included, if any.
  ///
  /// If a native enum has two members with the same value, they are
  /// functionally identical, and should be represented as such. This method
  /// overrides [toString] to include all duplicate members in the same message.
  void _writeToStringOverride(
    StringBuffer s,
    Map<EnumConstant, List<EnumConstant>> uniqueToDuplicates,
    Map<EnumConstant, EnumConstant> duplicateToOriginal,
  ) {
    if (duplicateToOriginal.isEmpty) return;
    s.write('  @override\n');
    s.write('  String toString() {\n');
    for (final entry in uniqueToDuplicates.entries) {
      // [!] All enum values were given a name when their declarations were
      // generated.
      final unique = entry.key;
      final duplicates = entry.value;
      if (duplicates.isEmpty) continue;
      final allDuplicates = [
        for (final duplicate in [unique] + duplicates)
          '$name.${duplicate.name}',
      ].join(', ');
      s.write(
        '    '
        'if (this == ${unique.name}) return "$allDuplicates";\n',
      );
    }
    s.write('    return super.toString();\n');
    s.write('  }');
  }

  /// Writes the DartDoc string for this enum.
  void _writeDartDoc(StringBuffer s) {
    s.write(makeDartDoc(dartDoc));
  }

  /// Writes a sealed class when no members exist, because Dart enums cannot be
  /// empty.
  void _writeEmptyEnum(StringBuffer s) {
    s.write('sealed class $name { }\n');
  }

  /// Writes a static function that maps integers to enum values.
  void _writeFromValue(StringBuffer s, Set<EnumConstant> uniqueMembers) {
    s.write('  static $name fromValue(int value) => switch (value) {\n');
    for (final member in uniqueMembers) {
      s.write('    ${member.value} => ${member.name},\n');
    }
    s.write(
      '    _ => throw ArgumentError('
      "'Unknown value for ${Namer.stringLiteral(name)}: \$value'),\n",
    );
    s.write('  };\n');
  }

  @override
  bool get isObjCImport =>
      context.objCBuiltInFunctions.isBuiltInEnum(originalName);

  @override
  BindingString toBindingString(Writer w) {
    assert(!isAnonymous);
    final s = StringBuffer();

    final uniqueToDuplicates = <EnumConstant, List<EnumConstant>>{};
    final duplicateToOriginal = <EnumConstant, EnumConstant>{};
    final uniqueMembers = <EnumConstant>{};
    for (final ec in enumConstants) {
      final original = uniqueMembers.firstWhereOrNull(
        (other) => other.value == ec.value,
      );
      if (original == null) {
        // This is a unique entry
        uniqueMembers.add(ec);
        uniqueToDuplicates[ec] = [];
      } else {
        // This is a duplicate of a previous entry
        duplicateToOriginal[ec] = original;
        uniqueToDuplicates[original]!.add(ec);
      }
    }

    _writeDartDoc(s);
    if (enumConstants.isEmpty) {
      _writeEmptyEnum(s);
    } else if (style == EnumStyle.intConstants) {
      s.write('sealed class $name {\n');
      _writeIntegerConstants(s);
      s.write('}\n\n');
    } else {
      s.write('enum $name {\n');
      _writeUniqueMembers(s, uniqueMembers);
      s.write('\n');
      _writeDuplicateMembers(s, duplicateToOriginal);
      s.write('\n');
      _writeConstructor(s);
      s.write('\n');
      _writeFromValue(s, uniqueMembers);
      s.write('\n');
      _writeToStringOverride(s, uniqueToDuplicates, duplicateToOriginal);
      s.write('}\n\n');
    }

    return BindingString(type: BindingStringType.enum_, string: s.toString());
  }

  @override
  String getCType(Context context) => nativeType.getCType(context);

  @override
  String getFfiDartType(Context context) => nativeType.getFfiDartType(context);

  @override
  String getDartType(Context context) {
    if (style == EnumStyle.intConstants) {
      return nativeType.getDartType(context);
    } else if (isObjCImport) {
      return '${context.libs.prefix(objcPkgImport)}.$name';
    } else {
      return name;
    }
  }

  @override
  String getNativeType({String varName = ''}) => '$originalName $varName';

  @override
  bool get sameFfiDartAndCType => nativeType.sameFfiDartAndCType;

  @override
  bool get sameDartAndFfiDartType => style == EnumStyle.intConstants;

  @override
  String? getDefaultValue(Context context) => '0';

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) => sameDartAndFfiDartType ? value : '$value.value';

  @override
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => sameDartAndFfiDartType
      ? value
      : '${getDartType(context)}.fromValue($value)';

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(nativeType);
    visitor.visitAll(enumConstants);
    if (isObjCImport) visitor.visit(objcPkgImport);
  }

  @override
  void visit(Visitation visitation) => visitation.visitEnumClass(this);
}

/// Represents a single value in an enum.
class EnumConstant extends AstNode {
  final String? originalName;
  final String? dartDoc;
  final int value;

  final Symbol _symbol;
  String get name => _symbol.name;

  EnumConstant({
    String? originalName,
    required String name,
    required this.value,
    this.dartDoc,
  }) : originalName = originalName ?? name,
       _symbol = Symbol(name, SymbolKind.field);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(_symbol);
  }
}
