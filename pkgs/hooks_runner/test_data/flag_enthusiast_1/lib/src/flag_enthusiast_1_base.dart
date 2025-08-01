// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:fun_with_flags/fun_with_flags.dart';
import 'package:meta/meta.dart' show RecordUse;

class SingleFlag {
  @RecordUse()
  static String loadFlag(String country) => FlagLoader.load(country);
}
