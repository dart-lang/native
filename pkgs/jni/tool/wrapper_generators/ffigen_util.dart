// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/writer.dart';
import 'package:ffigen/src/code_generator.dart';

final dummyWriter = Writer(
  lookUpBindings: [],
  ffiNativeBindings: [],
  noLookUpBindings: [],
  className: 'unused',
);

/// Find compound having [name] in [library].
Compound findCompound(library, String name) {
  return library.bindings.firstWhere((element) => element.name == name)
      as Compound;
}

const preamble = '''
// Auto generated file. Do not edit.

// This is generated from JNI header in Android NDK. License for the same is
// provided below.

/*
 * Copyright (C) 2006 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * JNI specification, as defined by Sun:
 * http://java.sun.com/javase/6/docs/technotes/guides/jni/spec/jniTOC.html
 *
 * Everything here is expected to be VM-neutral.
 */

''';
