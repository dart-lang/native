// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'imports.dart';
import 'objc_built_in_functions.dart';
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
class EnumClass extends BindingType {
  /// Backing integer type for this enum.
  Type nativeType;

  /// The amount of indentation in every line.
  static const depth = '  ';

  /// A list of all the members of the native enum.
  final List<EnumConstant> enumConstants;

  /// Generates new names for all members that don't equal [name].
  final UniqueNamer namer;

  ObjCBuiltInFunctions? objCBuiltInFunctions;

  /// Whether this enum should be generated as a collection of integers.
  bool generateAsInt;

  EnumClass({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    Type? nativeType,
    List<EnumConstant>? enumConstants,
    this.objCBuiltInFunctions,
    this.generateAsInt = false,
  })  : nativeType = nativeType ?? intType,
        enumConstants = enumConstants ?? [],
        namer = UniqueNamer({name});

  /// The names of all the enum members generated by [namer].
  final Map<EnumConstant, String> enumNames = {};

  /// Maps all unique enum values to a list of their duplicates or aliases.
  ///
  /// See [scanForDuplicates] and [writeToStringOverride].
  final Map<EnumConstant, List<EnumConstant>> uniqueToDuplicates = {};

  /// Maps all duplicate enum members to the member who first had that value.
  ///
  /// See [scanForDuplicates] and [writeDuplicateMembers].
  final Map<EnumConstant, EnumConstant> duplicateToOriginal = {};

  /// A collection of all the enum members with unique values.
  ///
  /// See [scanForDuplicates] and [writeUniqueMembers].
  final Set<EnumConstant> uniqueMembers = {};

  /// Returns a string to declare the enum member and any documentation it may
  /// have had.
  String formatValue(EnumConstant ec, {bool asInt = false}) {
    final buffer = StringBuffer();
    final enumValueName = namer.makeUnique(ec.name);
    enumNames[ec] = enumValueName;
    if (ec.dartDoc != null) {
      buffer.write('$depth/// ');
      buffer.writeAll(ec.dartDoc!.split('\n'), '\n$depth/// ');
      buffer.write('\n');
    }
    if (asInt) {
      buffer.write('${depth}static const $enumValueName = ${ec.value};');
    } else {
      buffer.write('$depth$enumValueName(${ec.value})');
    }
    return buffer.toString();
  }

  /// Finds enum values that are duplicates of previous enum values.
  ///
  /// Since all enum values in Dart are distinct, these duplicates do not
  /// get their own values in Dart. Rather, they are aliases of the original
  /// value. For example, if a native enum has 2 constants with a value of 10,
  /// only one enum value will be generated in Dart, and the other will be set
  /// equal to it.
  void scanForDuplicates() {
    uniqueMembers.clear();
    uniqueToDuplicates.clear();
    duplicateToOriginal.clear();
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
  }

  void writeIntegerConstants(StringBuffer s) {
    s.writeAll(enumConstants.map((c) => formatValue(c, asInt: true)), '\n');
  }

  /// Writes the enum declarations for all unique members.
  ///
  /// Eg, C: `apple = 1`, Dart: `apple(1)`
  void writeUniqueMembers(StringBuffer s) {
    s.writeAll(uniqueMembers.map(formatValue), ',\n');
    if (uniqueMembers.isNotEmpty) s.write(';\n');
  }

  /// Writes alias declarations for all members with duplicate values.
  ///
  /// Eg, C: `banana = 10, yellow_fruit = 10`.
  /// Dart: `static const yellow_fruit = banana`.
  void writeDuplicateMembers(StringBuffer s) {
    if (duplicateToOriginal.isEmpty) return;
    for (final entry in duplicateToOriginal.entries) {
      final duplicate = entry.key;
      final original = entry.value;
      final duplicateName = namer.makeUnique(duplicate.name);
      // [!] Each original enum value was given a name in [writeUniqueMembers].
      final originalName = enumNames[original]!;
      enumNames[duplicate] = duplicateName;
      if (duplicate.dartDoc != null) {
        s.write('$depth/// ');
        s.writeAll(duplicate.dartDoc!.split('\n'), '\n$depth/// ');
        s.write('\n');
      }
      s.write('${depth}static const $duplicateName = $originalName;\n');
    }
  }

  /// Writes the constructor for the enum.
  ///
  /// Always accepts an integer value to match the native value.
  void writeConstructor(StringBuffer s) {
    s.write('${depth}final int value;\n');
    s.write('${depth}const $name(this.value);\n');
  }

  /// Overrides [Enum.toString] so all aliases are included, if any.
  ///
  /// If a native enum has two members with the same value, they are
  /// functionally identical, and should be represented as such. This method
  /// overrides [toString] to include all duplicate members in the same message.
  void writeToStringOverride(StringBuffer s) {
    if (duplicateToOriginal.isEmpty) return;
    s.write('$depth@override\n');
    s.write('${depth}String toString() {\n');
    for (final entry in uniqueToDuplicates.entries) {
      // [!] All enum values were given a name when their declarations were
      // generated.
      final unique = entry.key;
      final originalName = enumNames[unique]!;
      final duplicates = entry.value;
      if (duplicates.isEmpty) continue;
      final allDuplicates = [
        for (final duplicate in [unique] + duplicates)
          '$name.${enumNames[duplicate]!}',
      ].join(', ');
      s.write(
        '$depth$depth'
        'if (this == $originalName) return "$allDuplicates";\n',
      );
    }
    s.write('${depth * 2}return super.toString();\n');
    s.write('$depth}');
  }

  /// Writes the DartDoc string for this enum.
  void writeDartDoc(StringBuffer s) {
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
  }

  /// Writes a sealed class when no members exist, because Dart enums cannot be
  /// empty.
  void writeEmptyEnum(StringBuffer s) {
    s.write('sealed class $name { }\n');
  }

  /// Writes a static function that maps integers to enum values.
  void writeFromValue(StringBuffer s) {
    s.write('${depth}static $name fromValue(int value) => switch (value) {\n');
    for (final member in uniqueMembers) {
      final memberName = enumNames[member]!;
      s.write('$depth$depth${member.value} => $memberName,\n');
    }
    s.write(
      '$depth${depth}_ => '
      'throw ArgumentError("Unknown value for $name: \$value"),\n',
    );
    s.write('$depth};\n');
  }

  bool get _isBuiltIn =>
      objCBuiltInFunctions?.isBuiltInEnum(originalName) ?? false;

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    if (_isBuiltIn) {
      return const BindingString(type: BindingStringType.enum_, string: '');
    }
    scanForDuplicates();

    writeDartDoc(s);
    if (enumConstants.isEmpty) {
      writeEmptyEnum(s);
    } else if (generateAsInt) {
      s.write('sealed class $name {\n');
      writeIntegerConstants(s);
      s.write('}\n\n');
    } else {
      s.write('enum $name {\n');
      writeUniqueMembers(s);
      s.write('\n');
      writeDuplicateMembers(s);
      s.write('\n');
      writeConstructor(s);
      s.write('\n');
      writeFromValue(s);
      s.write('\n');
      writeToStringOverride(s);
      s.write('}\n\n');
    }

    return BindingString(
      type: BindingStringType.enum_,
      string: s.toString(),
    );
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this) || _isBuiltIn) return;
    dependencies.add(this);
  }

  @override
  String getCType(Writer w) {
    w.usedEnumCType = true;
    return nativeType.getCType(w);
  }

  @override
  String getFfiDartType(Writer w) => nativeType.getFfiDartType(w);

  @override
  String getDartType(Writer w) {
    if (_isBuiltIn) {
      return '${w.objcPkgPrefix}.$name';
    } else if (generateAsInt) {
      return nativeType.getDartType(w);
    } else {
      return name;
    }
  }

  @override
  String getNativeType({String varName = ''}) => '$originalName $varName';

  @override
  bool get sameFfiDartAndCType => nativeType.sameFfiDartAndCType;

  @override
  bool get sameDartAndFfiDartType => generateAsInt;

  @override
  String? getDefaultValue(Writer w) => '0';

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) =>
      sameDartAndFfiDartType ? value : '$value.value';

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      sameDartAndFfiDartType ? value : '${getDartType(w)}.fromValue($value)';
}

/// Represents a single value in an enum.
class EnumConstant {
  final String? originalName;
  final String? dartDoc;
  final String name;
  final int value;
  const EnumConstant({
    String? originalName,
    required this.name,
    required this.value,
    this.dartDoc,
  }) : originalName = originalName ?? name;
}
