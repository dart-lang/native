// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:swift2objc/swift2objc.dart';
import 'package:test/test.dart';

void main() {
  test('Finding SDKs', () async {
    expect((await hostSdk).path, contains('MacOS'));
    expect(Directory((await hostSdk).path).existsSync(), isTrue);
    expect((await macOSSdk).path, contains('MacOS'));
    expect(Directory((await macOSSdk).path).existsSync(), isTrue);
    expect((await iOSSdk).path, contains('iPhoneOS'));
    expect(Directory((await iOSSdk).path).existsSync(), isTrue);
  });

  test('Finding triples', () async {
    expect(await iOSArmTargetTripleLatest, matches(r'arm-apple-ios[0-9]+'));
    expect(await iOSArm64TargetTripleLatest, matches(r'arm64-apple-ios[0-9]+'));
    expect(await iOSX64TargetTripleLatest, matches(r'x86_64-apple-ios[0-9]+'));
    expect(
      await macOSArm64TargetTripleLatest,
      matches(r'arm64-apple-macosx[0-9]+'),
    );
    expect(
      await macOSX64TargetTripleLatest,
      matches(r'x86_64-apple-macosx[0-9]+'),
    );
  });
}
