// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffi/ffi.dart';
import 'objective_c_bindings_generated.dart';

extension StringToNSString on String {
  NSString toNSString() => NSString(this);
}

extension NSStringToString on NSString {
  String toDartString() {
    final data =
        dataUsingEncoding_(0x94000100 /* NSUTF16LittleEndianStringEncoding */);
    return data!.bytes.cast<Utf16>().toDartString(length: length);
  }
}
