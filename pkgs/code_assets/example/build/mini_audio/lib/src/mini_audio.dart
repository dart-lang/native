// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'third_party/miniaudio.g.dart';

/// A wrapper around the miniaudio engine.
final class MiniAudio {
  late final Pointer<ma_engine> _engine;

  /// Initializes the miniaudio engine.
  MiniAudio() {
    _engine = malloc();
    final initResult = ma_engine_init(nullptr, _engine);
    if (initResult != ma_result.MA_SUCCESS) {
      throw Exception('Failed to initialize miniaudio engine: $initResult.');
    }
  }

  /// Uninitializes the miniaudio engine and frees resources.
  void uninit() {
    ma_engine_uninit(_engine);
    malloc.free(_engine);
  }

  /// Plays a sound from the given [filePath].
  void playSound(String filePath) => using((arena) {
    final filePath_ = filePath.toNativeUtf8(allocator: arena);
    ma_engine_play_sound(_engine, filePath_.cast(), nullptr);
  });
}
