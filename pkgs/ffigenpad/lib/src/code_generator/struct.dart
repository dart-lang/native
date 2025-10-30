// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'compound.dart';

/// A binding for C Struct.
///
/// For a C structure -
/// ```c
/// struct C {
///   int a;
///   double b;
///   int c;
/// };
/// ```
/// The generated dart code is -
/// ```dart
/// final class Struct extends ffi.Struct {
///  @ffi.Int32()
///  int a;
///
///  @ffi.Double()
///  double b;
///
///  @ffi.Uint8()
///  int c;
///
/// }
/// ```
class Struct extends Compound {
  Struct({
    super.usr,
    super.originalName,
    required super.name,
    super.isIncomplete,
    super.pack,
    super.dartDoc,
    super.members,
    super.isInternal,
    super.objCBuiltInFunctions,
    super.nativeType,
  }) : super(compoundType: CompoundType.struct);
}
