// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/src/elements/elements.dart';
import 'package:jni_gen/src/config/wrapper_options.dart';

import 'bindings_writer.dart';

/// A writer for debugging purpose.
class CallbackWriter extends BindingsWriter {
  CallbackWriter(this.callback);
  Future<void> Function(Iterable<ClassDecl>, WrapperOptions) callback;

  @override
  Future<void> writeBindings(
      Iterable<ClassDecl> classes, WrapperOptions options) async {
    callback(classes, options);
  }
}
