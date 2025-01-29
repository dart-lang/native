// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These methods are inserted into ffigen's unformatted output, to make the
// insertion sites easier to find. That means this file must remain unformatted.
// dart format off

// Extra methods inserted into NSString by tool/generate_code.dart.
class NSString extends NSObject implements NSCopying, NSMutableCopying, NSSecureCoding {
  factory NSString(String str) {
    final cstr = str.toNativeUtf16();
    final nsstr = stringWithCharacters_length_(cstr.cast(), str.length);
    pkg_ffi.calloc.free(cstr);
    return nsstr;
  }
}
