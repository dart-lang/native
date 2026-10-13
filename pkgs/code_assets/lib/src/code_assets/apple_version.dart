// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'syntax.g.dart';

/// Largest Apple deployment-version component supported by the protocol.
const maxAppleVersionComponent = 0x7fffffff;

/// An Apple operating-system deployment version.
///
/// The version consists of numeric [major], [minor], and [patch] components.
/// Consumers must format these components for the tool they invoke, rather
/// than use [toString] as a compiler or linker argument.
///
/// The protocol requires all three components. The constructor's zero defaults
/// for [minor] and [patch] are serialized explicitly.
final class AppleVersion {
  /// The major version component.
  final int major;

  /// The minor version component, defaulting to zero.
  final int minor;

  /// The patch version component, defaulting to zero.
  final int patch;

  /// Constructs an Apple deployment version, such as
  /// `AppleVersion(17, minor: 2, patch: 1)`.
  ///
  /// Each component must be between 0 and 2147483647. This bound prevents
  /// silent truncation by native toolchains, which may still reject smaller
  /// unsupported deployment versions.
  /// Throws [ArgumentError] if a component is outside that range.
  AppleVersion(this.major, {this.minor = 0, this.patch = 0}) {
    for (final (name, value) in [
      ('major', major),
      ('minor', minor),
      ('patch', patch),
    ]) {
      if (!_isValidComponent(value)) {
        throw ArgumentError.value(
          value,
          name,
          'Expected an integer between 0 and $maxAppleVersionComponent.',
        );
      }
    }
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
  AppleVersionSyntax toSyntax() =>
      AppleVersionSyntax(major: major, minor: minor, patch: patch);

  /// Reads and validates the numeric components of a protocol version.
  static AppleVersion fromSyntax(AppleVersionSyntax syntax) {
    final major = syntax.major;
    final minor = syntax.minor;
    final patch = syntax.patch;
    for (final (name, value) in [
      ('major', major),
      ('minor', minor),
      ('patch', patch),
    ]) {
      if (!_isValidComponent(value)) {
        throw FormatException(
          'Invalid Apple deployment version $name: $value. '
          'Expected an integer between 0 and $maxAppleVersionComponent.',
        );
      }
    }
    return AppleVersion(major, minor: minor, patch: patch);
  }
}

bool _isValidComponent(int value) =>
    value >= 0 && value <= maxAppleVersionComponent;
