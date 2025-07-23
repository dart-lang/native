// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart' show LinkInput, LinkOutputBuilder;

const _prefix = 'used_flags_';

extension FlagsUsedWrite on LinkOutputBuilder {
  /// Register a list of flags to be kept from treeshaking.
  ///
  /// This uses the [callerPackageName] with the [_prefix] to make a unique
  /// identifier for this list - that's how we avoid overwriting other
  /// packages flags.
  void registerCountryUse(String callerPackageName, List<String> countries) =>
      metadata.add('fun_with_flags', '$_prefix$callerPackageName', countries);
}

extension FlagsUsedRead on LinkInput {
  Iterable<String> get fetchUsedCountries => metadata.entries
      .where((entry) => entry.key.startsWith(_prefix))
      .expand((e) => e.value as List)
      .map((e) => e as String);
}
