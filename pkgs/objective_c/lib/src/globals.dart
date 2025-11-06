// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'objective_c_bindings_generated.dart';
import 'runtime_bindings_generated.dart' as r;


NSString get NSKeyValueChangeIndexesKey => NSString.fromPointer(
  r.NSKeyValueChangeIndexesKey,
  retain: true,
  release: true,
);

NSString get NSKeyValueChangeKindKey => NSString.fromPointer(
  r.NSKeyValueChangeKindKey,
  retain: true,
  release: true,
);

NSString get NSKeyValueChangeNewKey => NSString.fromPointer(
  r.NSKeyValueChangeNewKey,
  retain: true,
  release: true,
);

NSString get NSKeyValueChangeNotificationIsPriorKey => NSString.fromPointer(
  r.NSKeyValueChangeNotificationIsPriorKey,
  retain: true,
  release: true,
);

NSString get NSKeyValueChangeOldKey => NSString.fromPointer(
  r.NSKeyValueChangeOldKey,
  retain: true,
  release: true,
);

NSString get NSLocalizedDescriptionKey => NSString.fromPointer(
  r.NSLocalizedDescriptionKey,
  retain: true,
  release: true,
);
