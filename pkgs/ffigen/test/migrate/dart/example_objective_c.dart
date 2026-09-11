// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../example/objective_c/');
  final dartPath = outputDir != null
      ? outputDir.resolve('avf_audio_bindings.dart')
      : packageRoot.resolve('avf_audio_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('avf_audio_bindings.dart.m')
      : packageRoot.resolve('avf_audio_bindings.dart.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const DynamicLibraryBindings(
        wrapperName: 'AVFAudio',
        wrapperDocComment: 'Bindings for AVFAudio.',
      ),
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: camel_case_types, non_constant_identifier_names, unused_element, unused_field, void_checks, annotate_overrides, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api
''',
    ),
    input: Input(
      entryPoints: [
        Uri.file(
          '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/AVFAudio.framework/Headers/AVAudioPlayer.h',
        ),
      ],
    ),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) =>
            node.isIncluded = node.originalName == 'AVAudioPlayer',
      ),
    ],
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty
      ? Uri.directory(args.first)
      : Platform.environment['OUTPUT_DIR'] != null
      ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
      : null;
  await getConfig(outputDir: outputDir).generate();
}
