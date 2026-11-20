// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:cli_tool/src/find_git.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await doctor(args, (input, output) async {
    final git = await findGit();
    if (git != null) {
      output.addValidation(
        DoctorValidationResult(
          title: 'Git (package:cli_tool)',
          type: DoctorValidationType.success,
          messages: [
            DoctorValidationMessage('Found git at ${git.toFilePath()}'),
          ],
        ),
      );
    } else {
      output.addValidation(
        DoctorValidationResult(
          title: 'Git (package:cli_tool)',
          type: DoctorValidationType.missing,
          messages: [
            DoctorValidationMessage.error('git not found on PATH.'),
            DoctorValidationMessage.hint(
              'Install Git and ensure it is available on PATH.',
              contextUrl: 'https://git-scm.com/downloads',
            ),
          ],
        ),
      );
    }
  });
}
