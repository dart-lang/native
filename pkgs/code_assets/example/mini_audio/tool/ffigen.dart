// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  FfiGenerator(
    headers: Headers(
      entryPoints: [packageRoot.resolve('third_party/miniaudio.h')],
    ),
    functions: Functions.includeSet({
      'ma_engine_init',
      'ma_engine_play_sound',
      'ma_engine_uninit',
    }),
    structs: Structs.includeSet({'ma_engine'}),
    enums: Enums(
      include: (declaration) =>
          {'ma_result'}.contains(declaration.originalName),
      silenceWarning: true,
    ),
    output: Output(
      dartFile: packageRoot.resolve('lib/src/third_party/miniaudio.g.dart'),
      preamble: '''
// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
// software, either in source code form or as a compiled binary, for any purpose,
// commercial or non-commercial, and by any means.
//
// In jurisdictions that recognize copyright laws, the author or authors of this
// software dedicate any and all copyright interest in the software to the public
// domain. We make this dedication for the benefit of the public at large and to
// the detriment of our heirs and successors. We intend this dedication to be an
// overt act of relinquishment in perpetuity of all present and future rights to
// this software under copyright law.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// For more information, please refer to <http://unlicense.org/>

// ignore_for_file: unused_field
''',
    ),
  ).generate();
}
