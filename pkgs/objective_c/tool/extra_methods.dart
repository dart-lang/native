// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Extra methods inserted into NSString by generate_code.dart.
class NSString extends NSObject {
  factory NSString(String str) {
    final cstr = str.toNativeUtf16();
    final nsstr = stringWithCharacters_length_(cstr.cast(), str.length);
    pkg_ffi.calloc.free(cstr);
    return nsstr;
  }

  @override
  String toString() {
    final data = dataUsingEncoding_(
        0x94000100 /* NSUTF16LittleEndianStringEncoding */);
    return data!.bytes.cast<pkg_ffi.Utf16>().toDartString(length: length);
  }
}
