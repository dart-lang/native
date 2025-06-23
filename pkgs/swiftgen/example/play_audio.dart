// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'package:objective_c/objective_c.dart';
import 'avf_audio_bindings.dart';

// TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
import '../../objective_c/test/setup.dart' as objCSetup;

const _dylibPath =
    '/System/Library/Frameworks/AVFAudio.framework/Versions/Current/AVFAudio';

const _wrapperDylib = 'avf_audio_wrapper.dylib';

void main(List<String> args) async {
  if (args.length == 0) {
    print("Usage: dart play_audio.dart file1.wav file2.mp3 ...");
    return;
  }

  objCSetup.main([]);
  DynamicLibrary.open(_dylibPath);
  DynamicLibrary.open(Platform.script.resolve(_wrapperDylib).toFilePath());
  for (final file in args) {
    final fileStr = NSString(file);
    print('Loading $fileStr');
    final fileUrl = NSURL.fileURLWithPath_(fileStr);
    final player = AVAudioPlayerWrapper.alloc()
        .initWithContentsOf_error_(fileUrl, nullptr);
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
