// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart' show LinkOutputBuilder;

const prefix = 'used_flags_';

extension FlagsUsed on LinkOutputBuilder {
  /// Register a list of flags to be kept from treeshaking.
  ///
  /// This uses the [callerPackageName] with the [prefix] to make a unique
  /// identifier for this list - that's how we avoid overwriting other
  /// packages flags.
  void registerFlagUse(String callerPackageName, List<String> countries) =>
      metadata.add('fun_with_flags', '$prefix$callerPackageName', countries);
}
