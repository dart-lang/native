// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  // TODO: Should swiftgen have an internal notion of working dir?
  Directory.current = Platform.script.resolve('.').toFilePath();

  // TODO: swiftgen needs a way of setting up logging. Then remove this.
  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.message}');
  });

  await generate(Config(
    target: Target(
      triple: 'x86_64-apple-macosx14.0',
      sdk: Uri.directory(
          '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk'),
    ),
    input: ObjCCompatibleSwiftFileInput(
        module: 'AVFAudio', files: [Uri.file('avf_audio_wrapper.swift')]),
    tempDirectory: Uri.directory('temp'),
    outputModule: 'AVFAudioWrapper',
    ffigen: FfiGenConfig(
      output: Uri.file('avf_audio_bindings.dart'),
      outputObjC: Uri.file('avf_audio_wrapper.m'),
      externalVersions: ffigen.ExternalVersions(
        ios: ffigen.Versions(min: Version(12, 0, 0)),
        macos: ffigen.Versions(min: Version(10, 14, 0)),
      ),
      objcInterfaces: ffigen.DeclarationFilters(
        shouldInclude: (decl) => decl.originalName == 'AVAudioPlayerWrapper',
      ),
    ),
  ));

  final result = Process.runSync(
    'swiftc',
    [
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
    ],
  );
  if (result.exitCode != 0) {
    print('Failed to build the swift wrapper library');
    print(result.stdout);
    print(result.stderr);
  }
}
