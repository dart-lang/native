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
        path: packageRoot.resolve('cjson_generated_bindings.dart'),
      ),
      style: const DynamicLibraryBindings(
        wrapperName: 'CJson',
        wrapperDocComment: 'Holds bindings to cJSON.',
      ),
      commentType: const CommentType.none(),
      preamble: '''
// Copyright (c) 2009-2017 Dave Gamble and cJSON contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
''',
    ),
    input: Input(
      entryPoints: [
        packageRoot.resolve('../../third_party/cjson_library/cJSON.h'),
      ],
      include: (uri) => uri.path.endsWith('cJSON.h'),
    ),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) => node.isIncluded = true,
        union: (node) => node.isIncluded = true,
        enumClass: (node) => node.isIncluded = true,
        global: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = .always,
      ),
    ],
  );
}

Future<void> main() async {
  await getConfig().generate();
}
