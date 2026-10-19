// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:hooks/src/args_parser.dart';

void main(List<String> args) async {
  final inputPath = getInputArgument(args);
  final doctorInput = DoctorInput(
    json.decode(File(inputPath).readAsStringSync()) as Map<String, Object?>,
  );
  await File.fromUri(doctorInput.outputFile).writeAsString('{not valid json');
}
