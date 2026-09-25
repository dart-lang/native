// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/logging/logging.dart';

void main(List<String> args) async {
  enableLoggingToFile();
  JniGenerator config;
  try {
    config = JniGenerator.parseArgs(args);
  } on ConfigException catch (e) {
    log.fatal(e);
  } on FormatException catch (e) {
    log.fatal(e);
  }
  log.warning(
    'The YAML configuration format is deprecated and will be removed in a '
    'future release. Please migrate to the programmatic Dart generator API. '
    'See skills/jnigen-migrate-yaml-to-dart for migration instructions.',
  );
  await config.generate(logger: log);
}
