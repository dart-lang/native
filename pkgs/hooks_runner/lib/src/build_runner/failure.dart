// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'build_runner.dart';

/// A failure that occurred during a [NativeAssetsBuildRunner] `build` or
/// `link`.
enum HooksRunnerFailure {
  /// Issues related to the execution of a build/link hook or its output.
  ///
  /// Typically fixed by the hook author or end-user adjusting
  /// dependencies/assets.
  hookRun,

  /// A hook reported an infra failure.
  ///
  /// Typically fixed by investigating infra reliability.
  infra,

  /// Issues related to the Dart project's configuration.
  ///
  /// Typically fixed by the end-user in the `pubspec.yaml`.
  projectConfig,

  /// Internal errors within the build runner itself.
  ///
  /// These might indicate a bug in the Dart/Flutter SDK.
  internal,
}
