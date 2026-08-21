// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';

final config = FfiGenerator(
  input: Input(
    // The entryPoints are the files that FFIgen should scan to find the APIs
    // you want to generate bindings for. You can use the macSdkPath or
    // iosSdkPath getters to find the Apple SDKs.
    entryPoints: [
      Uri.file(
        '$macSdkPath/System/Library/Frameworks/AVFAudio.framework/Headers/AVAudioPlayer.h',
      ),
    ],
  ),

  // To tell FFIgen to generate Objective-C bindings, rather than C bindings,
  // set the objectiveC field to a non-null value.
  objectiveC: const ObjectiveC(),
  visitors: [
    Visitor(
      // The objCInterface function is invoked for each interface
      // discovered while parsing the entryPoints.
      objCInterface: (node) {
        if (node.name == 'AVAudioPlayer') {
          // API elements like interfaces are excluded from the generated
          // bindings by default. So choose the ones you want to include and set
          // .isIncluded to true.
          node.isIncluded = true;
        }
      },
    ),
  ],

  output: Output(
    // The Dart file where the bindings will be generated.
    dart: DartCodeOutput(
      path: Platform.script.resolve('avf_audio_bindings.dart'),
    ),

    // Preamble text to put at the top of the generated file.
    preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
  ),
);

Future<void> main() async {
  Logger.root.level = Level.SEVERE;
  await config.generate(logger: Logger.root);
}
