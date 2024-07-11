// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library exports a high level programmatic API to jnigen, the entry
/// point of which is runJniGenTask function, which takes run configuration as
/// a JniGenTask.
library jnigen;

export 'src/config/config.dart';
export 'src/config/filters.dart';
export 'src/elements/elements.dart';
export 'src/generate_bindings.dart';
