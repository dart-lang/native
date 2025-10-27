// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:fun_with_flags/fun_with_flags.dart';
import 'package:meta/meta.dart' show RecordUse;

class MultiFlag {
  @RecordUse()
  static List<String> loadFlags(Iterable<String> countries) =>
      countries.map(FlagLoader.load).toList();
}
