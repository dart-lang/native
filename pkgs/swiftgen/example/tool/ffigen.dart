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
  final packageRoot = Platform.script.resolve('../');
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
        path: packageRoot.resolve('avf_audio_wrapper.swift'),
      ),
      module: 'AVFAudioWrapper',
      dartFile: packageRoot.resolve('avf_audio_bindings.dart'),
      objectiveCFile: packageRoot.resolve('avf_audio_wrapper.m'),
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
      ),
      visitors: [
        fg.Visitor(
          objCInterface: (node) {
            if (node.name == 'AVAudioPlayerWrapper') {
              node.isIncluded = true;
            }
          },
        ),
      ],
    ),
  ).generate(logger: logger, tempDirectory: packageRoot.resolve('temp/'));

  final result = Process.runSync('swiftc', [
    '-emit-library',
    '-o',
    packageRoot.resolve('avf_audio_wrapper.dylib').toFilePath(),
    '-module-name',
    'AVFAudioWrapper',
    packageRoot.resolve('avf_audio_wrapper.swift').toFilePath(),
    '-framework',
    'AVFAudio',
    '-framework',
    'Foundation',
  ], workingDirectory: packageRoot.toFilePath());
  if (result.exitCode != 0) {
    print('Failed to build the swift wrapper library');
    print(result.stdout);
    print(result.stderr);
  }
}
