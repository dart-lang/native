// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';

String getPackageName(String binaryName) => cutFromLast(binaryName, '.')[0];

/// splits [str] into 2 from last occurence of [sep]
List<String> cutFromLast(String str, String sep) {
  final li = str.lastIndexOf(sep);
  if (li == -1) {
    return ['', str];
  }
  return [str.substring(0, li), str.substring(li + 1)];
}

String getLastName(String binaryName) => binaryName.split('.').last;

String getSimpleNameOf(ClassDecl cls) => cls.simpleName;

/// Returns class name as useful in dart.
///
/// Eg -> a.b.X.Y -> X_Y
String simplifiedClassName(String binaryName) =>
    getLastName(binaryName).replaceAll('\$', '_');

// Utilities to operate on package names.

List<String> getComponents(String packageName) => packageName.split('.');
