// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../visitor/ast.dart';

import 'writer.dart';

/// Type class for return types, variable types, etc.
///
/// Implementers should extend either Type, or BindingType if the type is also a
/// binding, and override at least getCType and toString.
abstract class Type extends AstNode {
  const Type();

  /// Get base type for any type.
  ///
  /// E.g int** has base [Type] of int.
  /// double[2][3] has base [Type] of double.
  Type get baseType => this;

  /// Get base Array type.
  ///
  /// Returns itself if it's not an Array Type.
  Type get baseArrayType => this;

  /// Get base typealias type.
  ///
  /// Returns itself if it's not a Typealias.
  Type get typealiasType => this;

  /// Returns true if the type is a [Compound] and is incomplete.
  bool get isIncompleteCompound => false;

  /// Returns true if this is a subtype of [other]. That is this <: other.
  ///
  /// The behavior of this function should mirror Dart's subtyping logic, not
  /// Objective-C's. It's used to detect and fix cases where the generated
  /// bindings would fail `dart analyze` due to Dart's subtyping rules.
  ///
  /// Note: Implementers should implement [isSupertypeOf].
  bool isSubtypeOf(Type other) => other.isSupertypeOf(this);

  /// Returns true if this is a supertype of [other]. That is this :> other.
  bool isSupertypeOf(Type other) => typealiasType == other.typealiasType;

  /// Returns the C type of the Type. This is the FFI compatible type that is
  /// passed to native code.
  String getCType(Writer w) =>
      throw UnsupportedError('No mapping for type: $this');

  /// Returns the Dart type of the Type. This is the type that is passed from
  /// FFI to Dart code.
  String getFfiDartType(Writer w) => getCType(w);

  /// Returns the user type of the Type. This is the type that is presented to
  /// users by the ffigened API to users. For C bindings this is always the same
  /// as getFfiDartType. For ObjC bindings this refers to the wrapper object.
  String getDartType(Writer w) => getFfiDartType(w);

  /// Returns the type to be used if this type appears in an ObjC block
  /// signature. By default it's the same as [getCType]. But for some types
  /// that's not enough to distinguish them (eg all ObjC objects have a C type
  /// of `Pointer<objc.ObjCObject>`), so we use [getDartType] instead.
  String getObjCBlockSignatureType(Writer w) => getCType(w);

  /// Returns the C/ObjC type of the Type. This is the type as it appears in
  /// C/ObjC source code. It should not be used in Dart source code.
  ///
  /// This method takes a [varName] arg because some C/ObjC types embed the
  /// variable name inside the type. Eg, to pass an ObjC block as a function
  /// argument, the syntax is `int (^arg)(int)`, where arg is the [varName].
  String getNativeType({String varName = ''}) =>
      throw UnsupportedError('No native mapping for type: $this');

  /// Returns whether the FFI dart type and C type string are same.
  bool get sameFfiDartAndCType;

  /// Returns whether the dart type and C type string are same.
  bool get sameDartAndCType => sameFfiDartAndCType;

  /// Returns whether the dart type and FFI dart type string are same.
  bool get sameDartAndFfiDartType => true;

  /// Returns generated Dart code that converts the given value from its
  /// DartType to its FfiDartType.
  ///
  /// [value] is the value to be converted. If [objCRetain] is true, the ObjC
  /// object will be reained (ref count incremented) during conversion.
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) =>
      value;

  /// Returns generated Dart code that converts the given value from its
  /// FfiDartType to its DartType.
  ///
  /// [value] is the value to be converted. If [objCRetain] is true, the ObjC
  /// wrapper object will retain (ref count increment) the wrapped object
  /// pointer. If this conversion is occuring in the context of an ObjC class,
  /// then [objCEnclosingClass] should be the name of the Dart wrapper class
  /// (this is used by instancetype).
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      value;

  /// Returns generated ObjC code that retains a reference to the given value.
  /// Returns null if the Type does not need to be retained.
  String? generateRetain(String value) => null;

  /// Returns a human readable string representation of the Type. This is mostly
  /// just for debugging, but it may also be used for non-functional code (eg to
  /// name a variable or type in generated code).
  @override
  String toString();

  /// Cache key used in various places to dedupe Types. By default this is just
  /// the hash of the Type, but in many cases this does not dedupe sufficiently.
  /// So Types that may be duplicated should override this to return a more
  /// specific key. Types that are already deduped don't need to override this.
  /// toString() is not a valid cache key as there may be name collisions.
  String cacheKey() => hashCode.toRadixString(36);

  /// Returns a string of code that creates a default value for this type. For
  /// example, for int types this returns the string '0'. A null return means
  /// that default values aren't supported for this type, eg void.
  String? getDefaultValue(Writer w) => null;

  @override
  void visit(Visitation visitation) => visitation.visitType(this);

  // Helper for [isSupertypeOf] that applies variance rules.
  static bool isSupertypeOfVariance({
    List<Type> covariantLeft = const [],
    List<Type> covariantRight = const [],
    List<Type> contravariantLeft = const [],
    List<Type> contravariantRight = const [],
  }) =>
      isSupertypeOfCovariance(left: covariantLeft, right: covariantRight) &&
      isSupertypeOfCovariance(
          left: contravariantRight, right: contravariantLeft);

  static bool isSupertypeOfCovariance({
    required List<Type> left,
    required List<Type> right,
  }) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; ++i) {
      if (!left[i].isSupertypeOf(right[i])) return false;
    }
    return true;
  }
}

/// Base class for all Type bindings.
///
/// Since Dart doesn't have multiple inheritance, this type exists so that we
/// don't have to reimplement the default methods in all the classes that want
/// to extend both NoLookUpBinding and Type.
abstract class BindingType extends NoLookUpBinding implements Type {
  BindingType({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    super.isInternal,
  });

  @override
  Type get baseType => this;

  @override
  Type get baseArrayType => this;

  @override
  Type get typealiasType => this;

  @override
  bool get isIncompleteCompound => false;

  @override
  bool isSubtypeOf(Type other) => other.isSupertypeOf(this);

  @override
  bool isSupertypeOf(Type other) => typealiasType == other.typealiasType;

  @override
  String getFfiDartType(Writer w) => getCType(w);

  @override
  String getDartType(Writer w) => getFfiDartType(w);

  @override
  String getObjCBlockSignatureType(Writer w) => getCType(w);

  @override
  String getNativeType({String varName = ''}) =>
      throw UnsupportedError('No native mapping for type: $this');

  @override
  bool get sameDartAndCType => sameFfiDartAndCType;

  @override
  bool get sameDartAndFfiDartType => true;

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) =>
      value;

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      value;

  @override
  String? generateRetain(String value) => null;

  @override
  String toString() => originalName;

  @override
  String cacheKey() => hashCode.toRadixString(36);

  @override
  String? getDefaultValue(Writer w) => null;

  @override
  bool get isObjCImport => false;

  @override
  void visit(Visitation visitation) => visitation.visitBindingType(this);
}

/// Represents an unimplemented type. Used as a marker, so that declarations
/// having these can exclude them.
class UnimplementedType extends Type {
  String reason;
  UnimplementedType(this.reason);

  @override
  String toString() => '(Unimplemented: $reason)';

  @override
  bool get sameFfiDartAndCType => true;
}
