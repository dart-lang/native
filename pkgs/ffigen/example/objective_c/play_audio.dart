// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:objective_c/objective_c.dart';
import 'avf_audio_bindings.dart';

const _dylibPath =
    '/System/Library/Frameworks/AVFAudio.framework/Versions/Current/AVFAudio';

void main(List<String> args) async {
  DynamicLibrary.open(_dylibPath);
  for (final file in args) {
    final fileStr = NSString(file);
    print('Loading $fileStr');
    final fileUrl = NSURL.fileURLWithPath_(fileStr);
    final player =
        AVAudioPlayer.alloc().initWithContentsOfURL_error_(fileUrl, nullptr);
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
