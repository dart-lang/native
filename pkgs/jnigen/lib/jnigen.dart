// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library exports a high level programmatic API to jnigen, the entry
/// point of which is runJniGenTask function, which takes run configuration as
/// a JniGenTask.
/// {@category Java Differences}
/// {@category Lifecycle}
/// {@category Threading}
/// {@category Interface Implementation}
library;

export 'src/config/config.dart';
export 'src/elements/elements.dart';
export 'src/generate_bindings.dart';
