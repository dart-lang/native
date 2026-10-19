// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use, unnecessary_statements

import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await doctor(args, (input, output) async {
    input.packageName;
    input.packageRoot;
    input.outputFile;

    output.addValidation(
      DoctorValidationResult(
        title: 'title',
        type: DoctorValidationType.success,
        statusInfo: 'status',
        messages: [
          DoctorValidationMessage('info'),
          DoctorValidationMessage.hint('hint'),
          DoctorValidationMessage.error('error'),
        ],
      ),
    );
  });
}
