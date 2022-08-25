// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library exports a high level programmatic API to jni_gen, the entry
/// point of which is runJniGenTask function, which takes run configuration as
/// a JniGenTask.
library jni_gen;

export 'src/elements/elements.dart';
export 'src/config/config.dart';
export 'src/writers/writers.dart';
