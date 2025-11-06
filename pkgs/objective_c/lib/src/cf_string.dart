// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'ns_string.dart';
import 'objective_c_bindings_generated.dart';

extension CFStringRefConversions on CFStringRef {
  NSString toNSString() =>
      NSString.fromPointer(cast(), retain: true, release: true);

  String toDartString() => NSString.fromPointer(cast()).toDartString();
}
