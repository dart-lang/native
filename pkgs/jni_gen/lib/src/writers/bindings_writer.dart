// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/src/elements/elements.dart';
import 'package:jni_gen/src/config/wrapper_options.dart';

abstract class BindingsWriter {
  Future<void> writeBindings(
      Iterable<ClassDecl> classes, WrapperOptions options);
}
