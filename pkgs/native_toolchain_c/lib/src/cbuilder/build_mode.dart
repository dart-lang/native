// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The build mode for compiling native code assets.
///
/// The Dart SDK does not have build modes. All build hook invocations are
/// invoked with [release].
///
/// The Flutter SDK build modes map as the following to build hook build modes:
/// * Flutter debug -> [debug].
/// * Flutter release -> [release].
/// * Flutter profile -> [release].
/// * Flutter jit release -> [release].
final class BuildMode {
  /// The name for this build mode.
  final String name;

  const BuildMode._(this.name);

  /// The debug build mode.
  ///
  /// Used by the Flutter SDK in its debug mode.
  static const debug = BuildMode._('debug');

  /// The release build mode.
  ///
  /// Used by the Flutter SDK in its release, profile, and jit release modes.
  ///
  /// Used by the Dart SDK for every build.
  static const release = BuildMode._('release');

  /// All known build modes.
  static const values = [
    debug,
    release,
  ];

  /// The name of this [BuildMode].
  ///
  /// This returns a stable string that can be used to construct a
  /// [BuildMode] via [BuildMode.fromString].
  factory BuildMode.fromString(String target) =>
      values.firstWhere((e) => e.name == target);

  /// The name of this [BuildMode].
  ///
  /// This returns a stable string that can be used to construct a
  /// [BuildMode] via [BuildMode.fromString].
  @override
  String toString() => name;
}
