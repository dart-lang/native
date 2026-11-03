// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  late Uri outFile;
  late String packageName;
  late Uri packageRootUri;
  late Map<String, Object?> inputJson;

  setUp(() {
    final tempUri = Directory.systemTemp.uri;
    outFile = tempUri.resolve('output.json');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');

    inputJson = {
      'out_file': outFile.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
    };
  });

  test('DoctorInputBuilder->JSON->DoctorInput', () {
    final inputBuilder = DoctorInputBuilder()
      ..setupDoctor(
        packageName: packageName,
        packageRoot: packageRootUri,
        outputFile: outFile,
      );
    final input = inputBuilder.build();

    expect(input.json, inputJson);
    expect(json.decode(input.toString()), inputJson);

    expect(input.outputFile, outFile);
    expect(input.packageName, packageName);
    expect(input.packageRoot, packageRootUri);
  });

  test('DoctorInput FormatException package_name', () {
    final input = Map<String, Object?>.of(inputJson)..remove('package_name');
    expect(
      () => DoctorInput(input).packageName,
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains("No value was provided for 'package_name'."),
        ),
      ),
    );
  });
}
