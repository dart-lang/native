// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:mini_audio/mini_audio.dart';
import 'package:test/test.dart';

void main() {
  test('start and stop engine', () {
    // We don't want to commit a wav file or want to play a wav file when a
    // developer runs unit tests. So, only test starting and stopping the
    // engine. This should cover that the build hook works and the functions in
    // the dylib are visible and can be invoked.
    final engine = MiniAudio();
    engine.uninit();
  });
}
