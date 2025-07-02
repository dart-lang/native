// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'internal.dart';
import 'runtime_bindings_generated.dart' as r;

extension StringToSelector on String {
  /// Returns an Objective-C selector (aka `SEL`) for this [String].
  ///
  /// This is equivalent to the Objective-C `@selector()` directive, or the
  /// `NSSelectorFromString` function.
  Pointer<r.ObjCSelector> toSelector() => registerName(this);
}

extension SelectorToString on Pointer<r.ObjCSelector> {
  /// Returns the string that this Objective-C selector represents.
  ///
  /// This is equivalent to the Objective-C `NSSelectorFromString` function.
  String toDartString() => r.getName(this).cast<Utf8>().toDartString();
}
