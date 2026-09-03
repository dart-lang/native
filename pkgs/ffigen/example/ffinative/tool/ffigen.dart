// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/generated_bindings.dart'),
      ),
      style: const NativeExternalBindings(
        assetId: 'package:ffinative_example/generated_bindings.dart',
      ),
      preamble: '''
// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
    ),
    input: Input(entryPoints: [packageRoot.resolve('headers/example.h')]),
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded = true;
          if (node.name == 'sum') {
            node.exposeSymbolAddress = true;
          }
        },
        global: (node) {
          node.isIncluded = true;
          if (node.name == 'library_version') {
            node.exposeSymbolAddress = true;
          }
        },
        struct: (node) => node.isIncluded = true,
        union: (node) => node.isIncluded = true,
        enumClass: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = TypealiasInclude.always,
      ),
    ],
  );
}

Future<void> main() async {
  await getConfig().generate();
}
