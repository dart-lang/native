// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'syntax.g.dart';

/// An Apple operating-system deployment version.
///
/// The version consists of numeric [major], [minor], and [patch] components.
/// Consumers must format these components for the tool they invoke, rather
/// than use [toString] as a compiler or linker argument.
///
/// The protocol requires all three components. The constructor's zero defaults
/// for [minor] and [patch] are serialized explicitly.
final class AppleVersion implements Comparable<AppleVersion> {
  final AppleVersionSyntax _syntax;

  AppleVersion._(this._syntax);

  /// The major version component.
  int get major => _syntax.major;

  /// The minor version component, defaulting to zero.
  int get minor => _syntax.minor;

  /// The patch version component, defaulting to zero.
  int get patch => _syntax.patch;

  /// Constructs an Apple deployment version, such as
  /// `AppleVersion(17, minor: 2, patch: 1)`.
  ///
  /// Each component must be between 0 and 2147483647. This bound prevents
  /// silent truncation by native toolchains, which may still reject smaller
  /// unsupported deployment versions.
  /// Throws [ArgumentError] if a component is outside that range.
  AppleVersion(int major, {int minor = 0, int patch = 0})
    : _syntax = AppleVersionSyntax(major: major, minor: minor, patch: patch);

  /// Compares versions in major, minor, then patch order.
  @override
  int compareTo(AppleVersion other) {
    final majorComparison = major.compareTo(other.major);
    if (majorComparison != 0) return majorComparison;
    final minorComparison = minor.compareTo(other.minor);
    if (minorComparison != 0) return minorComparison;
    return patch.compareTo(other.patch);
  }

  @override
  bool operator ==(Object other) =>
      other is AppleVersion &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  /// A diagnostic representation of the version.
  ///
  /// This is not a deployment-target string for native tools.
  @override
  String toString() => 'AppleVersion($major, minor: $minor, patch: $patch)';
}

/// Conversion between [AppleVersion] and the hook protocol.
extension AppleVersionSyntaxExtension on AppleVersion {
  /// Converts this version to its protocol representation.
  AppleVersionSyntax toSyntax() => _syntax;

  /// Wraps a protocol version, validating each field when it is accessed.
  static AppleVersion fromSyntax(AppleVersionSyntax syntax) =>
      AppleVersion._(syntax);
}
