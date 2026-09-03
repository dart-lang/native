// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('generated_bindings.dart')),
      style: const DynamicLibraryBindings(
        wrapperName: 'NativeLibrary',
        wrapperDocComment: 'Bindings to `headers/example.h`.',
      ),
    ),
    input: Input(entryPoints: [packageRoot.resolve('headers/example.h')]),
    visitors: [Visitor(func: (node) => node.isIncluded = true)],
  );
}

Future<void> main() async {
  await getConfig().generate();
}
