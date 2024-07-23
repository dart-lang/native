// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library to invoke the native C compiler installed on the host machine.
library;

export 'src/cbuilder/cbuilder.dart' show CBuilder;
export 'src/cbuilder/clinker.dart' show CLinker, LinkerOptions;
export 'src/cbuilder/language.dart' show Language;
export 'src/cbuilder/output_type.dart' show OutputType;
export 'src/utils/env_from_bat.dart';
