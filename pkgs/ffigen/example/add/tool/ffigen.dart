// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  FfiGenerator(
    output: Output(dartFile: packageRoot.resolve('lib/add.g.dart')),
    headers: Headers(entryPoints: [packageRoot.resolve('src/add.h')]),
    functions: Functions.includeSet({'add'}),
  ).generate();
}
