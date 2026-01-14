// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:ffi';

import 'package:test/test.dart';
import 'package:objective_c/objective_c.dart';

import 'protocols_bindings.dart';
import 'util.dart';

void main() {
  group('Protocols', () {
    setUpAll(() async {
      final gen = TestGenerator('protocols');
      await gen.generateAndVerifyBindings();
      DynamicLibrary.open(gen.dylibFile);
    });

    test('protocol', () async {
      final result = Completer<String>();
      final delegate = TestWeatherServiceDelegate$Builder.implementAsListener(
        didUpdateWeather_: (NSString msg) {
          result.complete(msg.toDartString());
        }
      );
      TestWeatherService.fetchWeatherWithDelegate(delegate);
      expect(await result.future, "Sunny, 25°C");
    });
  });
}
