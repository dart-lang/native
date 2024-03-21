// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library exports the methods meant for use by generated code only, and
/// not to be used directly.
library internal_helpers_for_jnigen;

export 'src/accessors.dart';
export 'src/jni.dart' show ProtectedJniExtensions;
export 'src/types.dart' show referenceType;
export 'src/jreference.dart';
export 'src/method_invocation.dart';
