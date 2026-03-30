// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jni_flutter/jni_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('androidApplicationContext does not throw', (tester) async {
    if (Platform.isAndroid) {
      // This will only work on a real device or emulator
      expect(() => androidApplicationContext, returnsNormally);
    }
  });
}
