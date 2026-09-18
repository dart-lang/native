// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../');
  await FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('lib/native_add.dart')),
      preamble: '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
      commentType: const CommentType(CommentStyle.any, CommentLength.full),
    ),
    input: Input(entryPoints: [packageRoot.resolve('src/native_add.h')]),
    visitors: [Visitor(func: (node) => node.isIncluded = true)],
  ).generate();
}
