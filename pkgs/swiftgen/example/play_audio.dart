// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';

import 'avf_audio_bindings.dart';

const _dylibPath =
    '/System/Library/Frameworks/AVFAudio.framework/Versions/Current/AVFAudio';

const _wrapperDylib = 'avf_audio_wrapper.dylib';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart play_audio.dart file1.wav file2.mp3 ...');
    return;
  }

  DynamicLibrary.open(_dylibPath);
  DynamicLibrary.open(Platform.script.resolve(_wrapperDylib).toFilePath());
  for (final file in args) {
    final fileStr = NSString(file);
    print('Loading ${fileStr.toDartString()}');
    final fileUrl = NSURL.fileURLWithPath(fileStr);
    final player = AVAudioPlayerWrapper.alloc().initWithContentsOf(
      fileUrl,
    );
    if (player == null) {
      print('Failed to load audio');
      continue;
    }
    final durationSeconds = player.duration.ceil();
    print('$durationSeconds sec');
    final status = player.play();
    if (status) {
      print('Playing...');
      await Future<void>.delayed(Duration(seconds: durationSeconds));
    } else {
      print('Failed to play audio.');
    }
  }
}
