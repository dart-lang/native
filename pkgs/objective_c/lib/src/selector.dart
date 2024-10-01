// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'c_bindings_generated.dart' as c;
import 'internal.dart';

extension StringToSelector on String {
  /// Returns an Objective-C selector (aka `SEL`) for this [String].
  ///
  /// This is equivalent to the Objective-C `@selector()` directive, or the
  /// `NSSelectorFromString` function.
  Pointer<c.ObjCSelector> toSelector() => registerName(this);
}

extension SelectorToString on Pointer<c.ObjCSelector> {
  /// Returns the string that this Objective-C selector represents.
  ///
  /// This is equivalent to the Objective-C `NSSelectorFromString` function.
  String toDartString() => c.getName(this).cast<Utf8>().toDartString();
}
