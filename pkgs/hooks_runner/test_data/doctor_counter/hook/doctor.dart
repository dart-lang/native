// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await doctor(arguments, (input, output) async {
    final counterFile = File.fromUri(input.packageRoot.resolve('counter.txt'));
    final count = counterFile.existsSync()
        ? int.parse(counterFile.readAsStringSync()) + 1
        : 1;
    counterFile.writeAsStringSync(count.toString());
    output.addValidations([
      DoctorValidationResult(
        title: 'Counter Tool',
        type: DoctorValidationType.success,
        statusInfo: 'Run $count',
        messages: [DoctorValidationMessage('Counter tool found')],
      ),
    ]);
  });
}
