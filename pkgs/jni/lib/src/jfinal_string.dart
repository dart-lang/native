// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'jreference.dart';
import 'lang/jstring.dart';
import 'third_party/generated_bindings.dart';

/// Used for `static final` Java strings, where the constant string is
/// available.
///
/// If only its value is used using [toDartString], the [reference] is never
/// populated, saving a method call.
class JFinalString extends JString with JLazyReference {
  @override
  final JObjectPtr Function() lazyReference;

  final String string;

  JFinalString(this.lazyReference, this.string) : super.fromRef(nullptr);

  @override
  String toDartString({bool releaseOriginal = false}) {
    if (releaseOriginal) {
      release();
    }
    return string;
  }
}
