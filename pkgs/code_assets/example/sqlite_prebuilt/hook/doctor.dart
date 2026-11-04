// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:sqlite_prebuilt/src/find_sqlite.dart';

void main(List<String> args) async {
  await doctor(args, (input, output) async {
    switch (OS.current) {
      case OS.windows:
        output.addValidation(
          DoctorValidationResult(
            title: 'SQLite3 (package:sqlite_prebuilt)',
            type: DoctorValidationType.success,
            messages: [
              DoctorValidationMessage(
                'Prebuilt sqlite3.dll is downloaded automatically during '
                'build.',
              ),
            ],
          ),
        );
      case OS.linux:
        final dylib = findLinuxLibsqlite3();
        if (dylib != null) {
          output.addValidation(
            DoctorValidationResult(
              title: 'SQLite3 (package:sqlite_prebuilt)',
              type: DoctorValidationType.success,
              messages: [
                DoctorValidationMessage(
                  'Found libsqlite3.so at ${dylib.toFilePath()}',
                ),
              ],
            ),
          );
        } else {
          output.addValidation(
            DoctorValidationResult(
              title: 'SQLite3 (package:sqlite_prebuilt)',
              type: DoctorValidationType.missing,
              messages: [
                DoctorValidationMessage.error(
                  'libsqlite3.so not found in default locations.',
                ),
                DoctorValidationMessage.hint(
                  'Install libsqlite3 (e.g. `sudo apt install '
                  'libsqlite3-dev`).',
                ),
              ],
            ),
          );
        }
      case OS.macOS:
        final brew = findBrew();
        final dylib = brew != null ? findMacOSLibsqlite3() : null;
        if (dylib != null) {
          output.addValidation(
            DoctorValidationResult(
              title: 'SQLite3 (package:sqlite_prebuilt)',
              type: DoctorValidationType.success,
              messages: [
                DoctorValidationMessage('Found brew at ${brew!.toFilePath()}'),
                DoctorValidationMessage(
                  'Found libsqlite3.dylib at ${dylib.toFilePath()}',
                ),
              ],
            ),
          );
        } else {
          output.addValidation(
            DoctorValidationResult(
              title: 'SQLite3 (package:sqlite_prebuilt)',
              type: DoctorValidationType.missing,
              messages: [
                if (brew == null) ...[
                  DoctorValidationMessage.error('brew not found on PATH.'),
                  DoctorValidationMessage.hint(
                    'Install Homebrew from https://brew.sh and run '
                    '`brew install sqlite`.',
                  ),
                ] else ...[
                  DoctorValidationMessage('Found brew at ${brew.toFilePath()}'),
                  DoctorValidationMessage.error(
                    'sqlite not found via Homebrew.',
                  ),
                  DoctorValidationMessage.hint('Run `brew install sqlite`.'),
                ],
              ],
            ),
          );
        }
    }
  });
}
