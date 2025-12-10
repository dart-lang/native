// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:swift2objc/swift2objc.dart' as swift2objc;
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
    inputs: const [SwiftModuleInput(module: 'AVFAudio')],
    include: (swift2objc.Declaration d) => d.name == 'AVAudioPlayer',
    output: Output(
      swiftWrapperFile: SwiftWrapperFile(
        path: Uri.file('avf_audio_wrapper.swift'),
      ),
      module: 'AVFAudioWrapper',
      dartFile: Uri.file('avf_audio_bindings.dart'),
      objectiveCFile: Uri.file('avf_audio_wrapper.m'),
      preamble: '''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// coverage:ignore-file
''',
    ),
    ffigen: FfiGeneratorOptions(
      objectiveC: fg.ObjectiveC(
        externalVersions: fg.ExternalVersions(
          ios: fg.Versions(min: Version(12, 0, 0)),
          macos: fg.Versions(min: Version(10, 14, 0)),
        ),
        interfaces: fg.Interfaces(
          include: (decl) => decl.originalName == 'AVAudioPlayerWrapper',
        ),
      ),
    ),
  ).generate(logger: logger, tempDirectory: Uri.directory('temp'));

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
