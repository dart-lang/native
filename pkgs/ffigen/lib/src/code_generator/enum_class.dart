// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'native_type.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

// Only uniques
// duplicate --> original
// unique --> all duplicates
// typedef UniqueAndDuplicates = ({EnumConstant unique, List<EnumConstant> duplicates});
// typedef DuplicateAndOriginal = ({EnumConstant duplicate, })

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
  static final nativeType = NativeType(SupportedNativeType.Int32);

  final List<EnumConstant> enumConstants;

  /// Avoids naming members with [name] because dart doesn't allow values to
  /// have the same name as the class.
  final UniqueNamer namer;

  final Map<EnumConstant, String> enumNames = {};

  static const depth = '  ';

  final Map<EnumConstant, List<EnumConstant>> uniqueToDuplicates = {};
  final Map<EnumConstant, EnumConstant> duplicateToOriginal = {};
  final Set<EnumConstant> uniqueMembers = {};

  String formatValue(EnumConstant ec) {
    final buffer = StringBuffer();
    final enumValueName = namer.makeUnique(ec.name);
    enumNames[ec] = enumValueName;
    if (ec.dartDoc != null) {
      buffer.write('$depth/// ');
      buffer.writeAll(ec.dartDoc!.split('\n'), '\n$depth/// ');
      buffer.write('\n');
    }
    buffer.write('$depth$enumValueName(${ec.value})');
    return buffer.toString();
  }

  void scanForDuplicates() {
    uniqueMembers.clear();
    uniqueToDuplicates.clear();
    duplicateToOriginal.clear();
    for (final ec in enumConstants) {
      final original = uniqueMembers.firstWhereOrNull((other) => other.value == ec.value);
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

  EnumClass({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    List<EnumConstant>? enumConstants,
  }) : 
    enumConstants = enumConstants ?? [],
    namer = UniqueNamer({name})
  { 
    scanForDuplicates();
  }

  void writeUniqueMembers(StringBuffer s) {
    s.write("$depth// ===== Unique members =====\n");
    s.writeAll(uniqueMembers.map(formatValue), ",\n");
    if (uniqueMembers.isNotEmpty) s.write('$depth;\n\n');
  }

  void writeDuplicateMembers(StringBuffer s) {
    s.write("$depth// ===== Aliases =====\n");
    for (final entry in duplicateToOriginal.entries) {
      final duplicate = entry.key;
      final original = entry.value;
      final duplicateName = namer.makeUnique(duplicate.name);
      enumNames[duplicate] = duplicateName;
      // [!] Each original enum value was given a name in [writeUniqueMembers].
      final originalName = enumNames[original]!;
      s.write("${depth}static const $duplicateName = $originalName;\n");
    }
    s.write("\n");
  }

  void writeConstructor(StringBuffer s) {
    s.write("$depth// ===== Constructor =====\n");
    s.write("${depth}final int value;\n");
    s.write("${depth}const $name(this.value);\n\n");
  }

  void writeToStringOverride(StringBuffer s) {
    s.write("$depth// ===== Override toString() for aliases =====\n");
    s.write("$depth@override\n");
    s.write("${depth}String toString() {\n");
    for (final entry in uniqueToDuplicates.entries) {
      // [!] All enum values were given a name when their declarations were generated
      final unique = entry.key;
      final originalName = enumNames[unique]!;      
      final duplicates = entry.value;
      if (duplicates.isEmpty) continue;
      final allDuplicates = [
        for (final duplicate in [unique] + duplicates)
          "$name.${enumNames[duplicate]!}",
      ].join(", ");
      s.write('${depth * 2}if (this == $originalName) return "$allDuplicates";\n');
    }
    s.write("${depth * 2}return super.toString();\n");
    s.write("$depth}\n");
  }

  void writeDartDoc(StringBuffer s) {
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
  }

  void writeEmptyEnum(StringBuffer s) {
    s.write("sealed class $name { }\n");
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    scanForDuplicates();

    // Print the dartdoc.
    writeDartDoc(s);
    if (enumConstants.isEmpty) {
      writeEmptyEnum(s);
    } else {
      s.write('enum $name {\n');
        writeUniqueMembers(s);
        writeDuplicateMembers(s);
        writeConstructor(s);
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
    if (dependencies.contains(this)) return;

    dependencies.add(this);
  }

  @override
  String getCType(Writer w) => nativeType.getCType(w);

  @override
  String getFfiDartType(Writer w) => nativeType.getFfiDartType(w);

  @override
  bool get sameFfiDartAndCType => nativeType.sameFfiDartAndCType;

  @override
  bool get sameDartAndCType => nativeType.sameDartAndCType;

  @override
  String? getDefaultValue(Writer w) => '0';
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
