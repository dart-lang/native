// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

void main() {
  test('ObjCVersionCheck constants match pubspec', () {
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();
    final versionRegex = RegExp(
      r'^version:\s+(\d+)\.(\d+)\.\d+',
      multiLine: true,
    );
    final match = versionRegex.firstMatch(pubspecContent);
    expect(match, isNotNull);
    final major = int.parse(match!.group(1)!);
    final minor = int.parse(match.group(2)!);

    expect(ObjCVersionCheck.actualMajorVersion, major);
    expect(ObjCVersionCheck.actualMinorVersion, minor);
  });
}
