// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';

final config = FfiGenerator(
  headers: Headers(
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
  objectiveC: ObjectiveC(
    // The interfaces field is used to tell FFIgen which interfaces to generate
    // bindings for. There's also a protocols and a categories field.
    interfaces: Interfaces.includeSet({'AVAudioPlayer'}),
  ),

  output: Output(
    // The Dart file where the bindings will be generated.
    dartFile: Uri.file('avf_audio_bindings.dart'),

    // Preamble text to put at the top of the generated file.
    preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
  ),
);

void main() {
  Logger.root.level = Level.SEVERE;
  config.generate(logger: Logger.root);
}
