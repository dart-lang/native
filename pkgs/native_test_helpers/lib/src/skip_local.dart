// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Returns a skip reason if the [condition] is met and we are running locally.
///
/// Returns `null` (forcing the test or expectation to run) if running on CI
/// (detected by the `GITHUB_ACTIONS` environment variable).
// ignore: avoid_positional_boolean_parameters
Object? skipLocal(bool condition, String reason) {
  // Disallow skips when running in CI environments, where all toolchains and
  // dependencies must be present.
  final isGithubActions = Platform.environment.containsKey('GITHUB_ACTIONS');

  // The Dart SDK's internal CI infrastructure (Buildbot / Swarming).
  final isDartSdkCI =
      Platform.environment.containsKey('BUILDBOT_BUILDERNAME') ||
      Platform.environment.containsKey('SWARMING_TASK_ID');

  final isCI = isGithubActions || isDartSdkCI;
  if (isCI) return null;
  return condition ? reason : null;
}
