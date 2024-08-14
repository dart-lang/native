// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'header_parser/clang_bindings/clang_types.dart' as clang;
import 'package:ffigen/src/strings.dart';

export 'package:ffigen/src/strings.dart';

final sizemapNativeMapping = <String, int>{
  sChar: clang.CXTypeKind.CXType_SChar,
  uChar: clang.CXTypeKind.CXType_UChar,
  short: clang.CXTypeKind.CXType_Short,
  uShort: clang.CXTypeKind.CXType_UShort,
  intType: clang.CXTypeKind.CXType_Int,
  uInt: clang.CXTypeKind.CXType_UInt,
  long: clang.CXTypeKind.CXType_Long,
  uLong: clang.CXTypeKind.CXType_ULong,
  longLong: clang.CXTypeKind.CXType_LongLong,
  uLongLong: clang.CXTypeKind.CXType_ULongLong,
  enumType: clang.CXTypeKind.CXType_Enum
};

/// A path to a unique temporary directory that should be used for files meant
/// to be discarded after the current execution is finished.
String get tmpDir {
  return "/tmp";
}
