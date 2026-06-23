// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');

  // 1. Generate bindings for add.c
  FfiGenerator(
    headers: Headers(
      entryPoints: [packageRoot.resolve('src/add.c')],
    ),
    functions: Functions(
      include: (_) => true,
      recordUse: (_) => true,
    ),
    output: Output(
      preamble: '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
      dartFile: packageRoot.resolve('lib/src/add_bindings.dart'),
      recordUseMapping: packageRoot.resolve(
        'lib/src/add_record_use_mapping.dart',
      ),
      style: const NativeExternalBindings(
        assetId: 'package:treeshaking_dylib_record_use/add',
      ),
    ),
  ).generate();

  // 2. Generate bindings for multiply.c
  FfiGenerator(
    headers: Headers(
      entryPoints: [packageRoot.resolve('src/multiply.c')],
    ),
    functions: Functions(
      include: (_) => true,
      recordUse: (_) => true,
    ),
    output: Output(
      preamble: '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
      dartFile: packageRoot.resolve('lib/src/multiply_bindings.dart'),
      recordUseMapping: packageRoot.resolve(
        'lib/src/multiply_record_use_mapping.dart',
      ),
      style: const NativeExternalBindings(
        assetId: 'package:treeshaking_dylib_record_use/multiply',
      ),
    ),
  ).generate();
}
