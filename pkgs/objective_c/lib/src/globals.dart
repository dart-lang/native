// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: non_constant_identifier_names

import 'objective_c_bindings_generated.dart';
import 'runtime_bindings_generated.dart' as r;

/// Key in a key-value observing change dictionary for the index set of changed
/// objects.
NSString get NSKeyValueChangeIndexesKey => NSString.fromPointer(
  r.NSKeyValueChangeIndexesKey,
  retain: true,
  release: true,
);

/// Key in a key-value observing change dictionary for the kind of change.
NSString get NSKeyValueChangeKindKey => NSString.fromPointer(
  r.NSKeyValueChangeKindKey,
  retain: true,
  release: true,
);

/// Key in a key-value observing change dictionary for the new property value.
NSString get NSKeyValueChangeNewKey =>
    NSString.fromPointer(r.NSKeyValueChangeNewKey, retain: true, release: true);

/// Key in a key-value observing change dictionary indicating whether the
/// notification is sent prior to the change.
NSString get NSKeyValueChangeNotificationIsPriorKey => NSString.fromPointer(
  r.NSKeyValueChangeNotificationIsPriorKey,
  retain: true,
  release: true,
);

/// Key in a key-value observing change dictionary for the old property value.
NSString get NSKeyValueChangeOldKey =>
    NSString.fromPointer(r.NSKeyValueChangeOldKey, retain: true, release: true);

/// Key in an [NSError] `userInfo` dictionary for the localized description
/// string.
NSString get NSLocalizedDescriptionKey => NSString.fromPointer(
  r.NSLocalizedDescriptionKey,
  retain: true,
  release: true,
);
