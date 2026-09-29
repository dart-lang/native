// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:ffigen/ffigen.dart';

void appleApisExample() {
  // snippet-start#apple_apis
  final generator = FfiGenerator(
    input: Input(
      entryPoints: [
        // Use macSdkUri to resolve headers within the macOS SDK.
        macSdkUri.resolve(
          'System/Library/Frameworks/Foundation.framework/Headers/NSDate.h',
        ),
      ],
    ),
    output: Output(dart: DartOutput(path: Uri.file('nsdate.dart'))),
  );
  // snippet-end#apple_apis
}
