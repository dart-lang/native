// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:ffi";
import "package:jni/internal_helpers_for_jnigen.dart";

final Pointer<T> Function<T extends NativeType>(String sym) jniLookup =
    ProtectedJniExtensions.initGeneratedLibrary("notification_plugin");
