// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// jni_object library provides an easier interface to JNI's object references,
/// providing various helper methods for one-off uses.
///
/// It consists of generated methods to access java objects and call functions
/// on them, abstracting away most error checking and string conversions etc..
///
/// The important types are JniClass and JniObject, which are high level
/// wrappers around JClass and JObject.
///
/// Import this library along with `jni.dart`.
library jni_object;

export 'src/jni_class.dart';
export 'src/jni_object.dart';
