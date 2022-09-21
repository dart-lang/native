// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/src/tools/tools.dart';

void main(List<String> args) async {
  bool force = false;
  if (args.isNotEmpty) {
    if (args.length != 1 || args[0] != '-f') {
      stderr.writeln('usage: dart run jnigen:setup [-f]');
      stderr.writeln('* -f\trebuild ApiSummarizer jar even if it already '
          'exists.');
    } else {
      force = true;
    }
  }
  await buildSummarizerIfNotExists(force: force);
}
