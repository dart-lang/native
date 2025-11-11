// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:test/test.dart';

void main() {
  group('SDK variables', () {
    test('directories exist', () {
      expect(Directory(xcodePath).existsSync(), isTrue);
      expect(Directory(iosSdkPath).existsSync(), isTrue);
      expect(Directory(macSdkPath).existsSync(), isTrue);
    });

    test('URIs', () {
      expect(xcodeUri.path, '$xcodePath/');
      expect(iosSdkUri.path, '$iosSdkPath/');
      expect(macSdkUri.path, '$macSdkPath/');
    });
  });
}
