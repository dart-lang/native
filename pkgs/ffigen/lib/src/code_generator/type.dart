// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';
import 'scope.dart';

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
  String getCType(Context context) =>
      throw UnsupportedError('No mapping for type: $this');

  /// Returns the Dart type of the Type. This is the type that is passed from
  /// FFI to Dart code.
  String getFfiDartType(Context context) => getCType(context);

  /// Returns the user type of the Type. This is the type that is presented to
  /// users by the ffigened API to users. For C bindings this is always the same
  /// as getFfiDartType. For ObjC bindings this refers to the wrapper object.
  String getDartType(Context context) => getFfiDartType(context);



  /// Returns the type to be used if this type appears in an ObjC block
  /// signature. By default it's the same as [getCType]. But for some types
  /// that's not enough to distinguish them (eg all ObjC objects have a C type
  /// of `Pointer<objc.ObjCObject>`), so we use [getDartType] instead.
  String getObjCBlockSignatureType(Context context) => getCType(context);

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
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) => value;

  /// Returns generated Dart code that converts the given value from its
  /// FfiDartType to its DartType.
  ///
  /// [value] is the value to be converted. If [objCRetain] is true, the ObjC
  /// wrapper object will retain (ref count increment) the wrapped object
  /// pointer. If this conversion is occuring in the context of an ObjC class,
  /// then [objCEnclosingClass] should be the name of the Dart wrapper class
  /// (this is used by instancetype).
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => value;

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
  String? getDefaultValue(Context context) => null;

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
        left: contravariantRight,
        right: contravariantLeft,
      );

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
    required String name,
    super.dartDoc,
    super.isInternal,
  }) : super(symbol: Symbol(name, SymbolKind.klass));

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
  String getFfiDartType(Context context) => getCType(context);

  @override
  String getDartType(Context context) => getFfiDartType(context);

  @override
  String getObjCBlockSignatureType(Context context) => getCType(context);

  @override
  String getNativeType({String varName = ''}) =>
      throw UnsupportedError('No native mapping for type: $this');

  @override
  bool get sameDartAndCType => sameFfiDartAndCType;

  @override
  bool get sameDartAndFfiDartType => true;

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) => value;

  @override
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => value;

  @override
  String? generateRetain(String value) => null;

  @override
  String toString() => originalName;

  @override
  String cacheKey() => hashCode.toRadixString(36);

  @override
  String? getDefaultValue(Context context) => null;

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

/// Represents the `void` type.
final voidType = NativeType(SupportedNativeType.voidType);

/// Represents the `char` type.
final charType = NativeType(SupportedNativeType.char);

/// Represents the `signed char` type.
final signedCharType = NativeType(SupportedNativeType.int8);

/// Represents the `unsigned char` type.
final unsignedCharType = NativeType(SupportedNativeType.uint8);

/// Represents the `short` type.
final shortType = NativeType(SupportedNativeType.int16);

/// Represents the `unsigned short` type.
final unsignedShortType = NativeType(SupportedNativeType.uint16);

/// Represents the `int` type.
final intType = NativeType(SupportedNativeType.int32);

/// Represents the `unsigned int` type.
final unsignedIntType = NativeType(SupportedNativeType.uint32);

/// Represents the `long` type.
final longType = NativeType(SupportedNativeType.int64);

/// Represents the `unsigned long` type.
final unsignedLongType = NativeType(SupportedNativeType.uint64);

/// Represents the `long long` type.
final longLongType = NativeType(SupportedNativeType.int64);

/// Represents the `unsigned long long` type.
final unsignedLongLongType = NativeType(SupportedNativeType.uint64);

/// Represents the `float` type.
final floatType = NativeType(SupportedNativeType.float);

/// Represents the `double` type.
final doubleType = NativeType(SupportedNativeType.double);

/// Represents the `size_t` type.
final sizeType = NativeType(SupportedNativeType.intPtr);

/// Represents the `wchar_t` type.
final wCharType = NativeType(SupportedNativeType.int32);

/// Represents the `intptr_t` type.
final intPtrType = NativeType(SupportedNativeType.intPtr);

/// Represents the `uintptr_t` type.
final uintPtrType = NativeType(SupportedNativeType.uintPtr);

/// Represents the `id` type.
final objCObjectType = ObjCObjectType();

/// Represents the `void (^)(void)` type.
///
/// This is used as a placeholder for any block type.
final objCBlockType = ObjCBlockType();

class ObjCObjectType extends Type {
  const ObjCObjectType();

  @override
  String getCType(Context context) =>
      ObjCBuiltInFunctions.objectBase.gen(context);

  @override
  String getFfiDartType(Context context) => getCType(context);

  @override
  String getNativeType({String varName = ''}) => 'id $varName';

  @override
  bool get sameFfiDartAndCType => true;

  @override
  String toString() => 'id';

  @override
  String cacheKey() => 'id';

  @override
  bool get sameDartAndFfiDartType => true;

  @override
  bool get sameDartAndCType => true;

  @override
  String convertDartTypeToFfiDartType(Context context, String value, {required bool objCRetain, required bool objCAutorelease}) => value;

  @override
  String convertFfiDartTypeToDartType(Context context, String value, {required bool objCRetain, String? objCEnclosingClass}) => value;

  @override
  String? generateRetain(String value) => null;
}

class ObjCBlockType extends Type {
  const ObjCBlockType();

  @override
  String getCType(Context context) =>
      ObjCBuiltInFunctions.blockType.gen(context);

  @override
  String getFfiDartType(Context context) => getCType(context);

  @override
  String getNativeType({String varName = ''}) => 'void (^$varName)(void)';

  @override
  bool get sameFfiDartAndCType => true;

  @override
  String toString() => 'Block';

  @override
  String cacheKey() => 'Block';

  @override
  bool get sameDartAndFfiDartType => true;

  @override
  bool get sameDartAndCType => true;

  @override
  String convertDartTypeToFfiDartType(Context context, String value, {required bool objCRetain, required bool objCAutorelease}) => value;

  @override
  String convertFfiDartTypeToDartType(Context context, String value, {required bool objCRetain, String? objCEnclosingClass}) => value;

  @override
  String? generateRetain(String value) => null;
}
