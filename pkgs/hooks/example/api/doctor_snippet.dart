// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74
// ignore_for_file: experimental_member_use

// snippet-start
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await doctor(args, (input, output) async {
    output.addValidation(
      DoctorValidationResult(
        title: 'C Compiler',
        type: DoctorValidationType.success,
        statusInfo: 'Clang 17.0.0',
        messages: [DoctorValidationMessage('Found at /usr/bin/clang')],
      ),
    );
  });
}

// snippet-end
