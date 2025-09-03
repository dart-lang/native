// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  final logger = Logger('swiftgen');
  logger.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.message}');
  });

  await SwiftGenerator(
    target: Target(
      triple: 'x86_64-apple-macosx14.0',
      sdk: Uri.directory(
        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
      ),
    ),
    inputs: [SwiftModuleInput(module: 'AVFAudio')],
    include: (d) => d.name == 'AVAudioPlayer',
    objcSwiftFile: Uri.file('avf_audio_wrapper.swift'),
    tempDirectory: Uri.directory('temp'),
    outputModule: 'AVFAudioWrapper',
    ffigen: FfiGenConfig(
      output: Uri.file('avf_audio_bindings.dart'),
      outputObjC: Uri.file('avf_audio_wrapper.m'),
      objectiveC: fg.ObjectiveC(
        externalVersions: fg.ExternalVersions(
          ios: fg.Versions(min: Version(12, 0, 0)),
          macos: fg.Versions(min: Version(10, 14, 0)),
        ),
        interfaces: fg.Interfaces(
          include: (decl) => decl.originalName == 'AVAudioPlayerWrapper',
        ),
      ),
      preamble: '''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// coverage:ignore-file
''',
    ),
  ).generate(logger: logger);

  final result = Process.runSync('swiftc', [
    '-emit-library',
    '-o',
    'avf_audio_wrapper.dylib',
    '-module-name',
    'AVFAudioWrapper',
    'avf_audio_wrapper.swift',
    '-framework',
    'AVFAudio',
    '-framework',
    'Foundation',
  ]);
  if (result.exitCode != 0) {
    print('Failed to build the swift wrapper library');
    print(result.stdout);
    print(result.stderr);
  }
}
