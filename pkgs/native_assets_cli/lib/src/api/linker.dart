// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../config.dart';
import 'builder.dart';

/// A linker to be run during a link hook.
///
/// [Linker]s should be used to shrink or omit assets based on tree-shaking
/// information. [Linker]s have access to tree-shaking information in some build
/// modes. However, due to the tree-shaking information being an input to link
/// hooks, link hooks are re-run more often than [Builder]s. A link hook is
/// rerun when its declared [BuildOutput.dependencies] or its [LinkConfig] tree
/// shaking information changes.
///
/// A package to be used in link hooks should implement this interface. The
/// typical pattern of link hooks should be a declarative specification of one
/// or more linkers (constructor calls), followed by [run]ning these linkers.
///
/// The linker is designed to immediately operate on [LinkConfig]. If a linker
/// should deviate behavior from the build config, this should be configurable
/// through a constructor parameter.
///
/// The linker is designed to immediately operate on [LinkOutput]. If a linker
/// should output something else than standard, it should be configurable
/// through a constructor parameter.
// TODO(dacoharkes): Add a doc comment reference when tree shaking info is
// available.
abstract interface class Linker {
  /// Runs this linker.
  ///
  /// Reads the config from [config], streams output to [output], and streams
  /// logs to [logger].
  Future<void> run({
    required LinkConfig config,
    required LinkOutputBuilder output,
    required Logger? logger,
  });
}
