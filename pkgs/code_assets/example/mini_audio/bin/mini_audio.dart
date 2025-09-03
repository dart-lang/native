// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:mini_audio/src/mini_audio.dart';

void main(List<String> args) async {
  final engine = MiniAudio();
  if (args.isEmpty) {
    print('Provide a path to a .wav file.');
    return;
  }

  engine.playSound(args.first);

  print('Press Enter to quit...');
  stdin.readLineSync();
  engine.uninit();
}
