import 'header_parser/clang_bindings/clang_bindings.dart' as clang;
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
