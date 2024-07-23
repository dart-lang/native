// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  generate(Config(
    target: Target(
      triple: 'x86_64-apple-ios17.0-simulator',
      sdk: Uri.directory('/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk'),
    ),
    input: SwiftModuleInput(
      module: 'AVFoundation',
    ),
    tempDir: Uri.directory('temp'),
    outputModule: 'AVFoundationWrapper',
    objcSwiftFile: Uri.file('AVFoundationWrapper.swift'),
    outputDartFile: Uri.file('AVFoundationWrapper.dart'),
  ));
}
