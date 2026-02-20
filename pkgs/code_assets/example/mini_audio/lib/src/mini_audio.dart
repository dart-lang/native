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
    final result = ma_engine_init(nullptr, _engine);
    if (result != .MA_SUCCESS) {
      throw MiniAudioException(
        'Failed to initialize miniaudio engine: ${result.name}.',
      );
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
    final result = ma_engine_play_sound(_engine, filePath_.cast(), nullptr);
    if (result != .MA_SUCCESS) {
      throw MiniAudioException('Failed to play audio: ${result.name}}.');
    }
  });
}

/// An exception that is thrown when an error occurs in the mini_audio library.
final class MiniAudioException implements Exception {
  /// The error message.
  final String message;

  /// Creates a new instance of the exception.
  MiniAudioException(this.message);
}
