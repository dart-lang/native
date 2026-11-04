// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74
// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:io';

// snippet-start
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await doctor(args, (input, output) async {
    final clang = await findClang();
    if (clang != null) {
      output.addValidation(
        DoctorValidationResult(
          title: 'C Compiler',
          type: DoctorValidationType.success,
          messages: [
            DoctorValidationMessage('Found at ${clang.toFilePath()}'),
          ],
        ),
      );
    } else {
      output.addValidation(
        DoctorValidationResult(
          title: 'C Compiler',
          type: DoctorValidationType.missing,
          messages: [
            DoctorValidationMessage.error('clang not found on PATH.'),
            DoctorValidationMessage.hint(
              'Install Clang and add it to PATH.',
            ),
          ],
        ),
      );
    }
  });
}

// snippet-end

/// Shared between `hook/doctor.dart` and `hook/build.dart`.
Future<Uri?> findClang() async {
  final which = Platform.isWindows ? 'where.exe' : 'which';
  final result = await Process.run(which, ['clang']);
  if (result.exitCode != 0) {
    return null;
  }
  final firstLine = LineSplitter.split(result.stdout as String).first;
  return File(firstLine).uri;
}
