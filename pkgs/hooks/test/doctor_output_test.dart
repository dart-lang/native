// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  test('DoctorOutputBuilder->JSON->DoctorOutput', () {
    final builder = DoctorOutputBuilder();
    builder.addValidation(
      DoctorValidationResult(
        title: 'C toolchain (package:my_package)',
        type: .success,
        statusInfo: 'Clang 16.0.0',
        messages: [
          DoctorValidationMessage(
            'Clang found at /usr/bin/clang',
            contextUrl: 'https://example.com',
            piiStrippedMessage: 'Clang found at <path>',
          ),
          DoctorValidationMessage.hint('Consider upgrading to Clang 17'),
        ],
      ),
    );
    builder.addValidations([
      DoctorValidationResult(
        title: 'CMake (package:my_package)',
        type: .missing,
        messages: [DoctorValidationMessage.error('CMake not found on PATH')],
      ),
      DoctorValidationResult(
        title: 'Visual Studio (package:my_package)',
        type: .notAvailable,
      ),
    ]);

    final output = builder.build();
    expect(json.decode(output.toString()), output.json);

    expect(output.validations, hasLength(3));

    final first = output.validations[0];
    expect(first.title, 'C toolchain (package:my_package)');
    expect(first.type, DoctorValidationType.success);
    expect(first.statusInfo, 'Clang 16.0.0');
    expect(first.messages, hasLength(2));
    expect(first.messages[0].type, DoctorValidationMessageType.information);
    expect(first.messages[0].message, 'Clang found at /usr/bin/clang');
    expect(first.messages[0].contextUrl, 'https://example.com');
    expect(first.messages[0].piiStrippedMessage, 'Clang found at <path>');
    expect(first.messages[0].toString(), 'Clang found at /usr/bin/clang');
    expect(first.messages[1].type, DoctorValidationMessageType.hint);
    expect(first.messages[1].message, 'Consider upgrading to Clang 17');
    expect(
      first.messages[1].piiStrippedMessage,
      'Consider upgrading to Clang 17',
    );

    final second = output.validations[1];
    expect(second.title, 'CMake (package:my_package)');
    expect(second.type, DoctorValidationType.missing);
    expect(second.statusInfo, isNull);
    expect(second.messages.single.type, DoctorValidationMessageType.error);
    expect(second.messages.single.message, 'CMake not found on PATH');

    final third = output.validations[2];
    expect(third.title, 'Visual Studio (package:my_package)');
    expect(third.type, DoctorValidationType.notAvailable);
    expect(third.type.toString(), 'not_available');
    expect(third.messages, isEmpty);
    expect(
      third,
      DoctorValidationResult(
        title: 'Visual Studio (package:my_package)',
        type: .notAvailable,
      ),
    );
    expect(
      third.hashCode,
      DoctorValidationResult(
        title: 'Visual Studio (package:my_package)',
        type: .notAvailable,
      ).hashCode,
    );
    expect(
      second.messages.single,
      DoctorValidationMessage.error('CMake not found on PATH'),
    );
    expect(
      second.messages.single.hashCode,
      DoctorValidationMessage.error('CMake not found on PATH').hashCode,
    );
  });
}
