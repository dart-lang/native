// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Maintainer CLI utilities for precompiling release binaries and generating
/// SHA-256 hash manifests.
library;

export 'package:args/command_runner.dart' show UsageException;

export 'src/tools/precompile_binaries.dart';
export 'src/tools/regenerate_hashes.dart';
