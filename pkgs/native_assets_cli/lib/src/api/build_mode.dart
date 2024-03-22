// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part '../model/build_mode.dart';

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
abstract final class BuildMode {
  /// The name for this build mode.
  String get name;

  /// The debug build mode.
  ///
  /// Used by the Flutter SDK in its debug mode.
  static const BuildMode debug = BuildModeImpl.debug;

  /// The release build mode.
  ///
  /// Used by the Flutter SDK in its release, profile, and jit release modes.
  ///
  /// Used by the Dart SDK for every build.
  static const BuildMode release = BuildModeImpl.release;

  /// All known build modes.
  static const values = <BuildMode>[
    debug,
    release,
  ];
}
