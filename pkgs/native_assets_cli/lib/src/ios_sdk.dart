// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// For an iOS target, a build is either done for the device or the simulator.
final class IOSSdk {
  final String type;

  const IOSSdk._(this.type);

  /// The iphoneos SDK in Xcode.
  ///
  /// The SDK location can be found on the host machine with
  /// `xcrun --sdk iphoneos --show-sdk-path`.
  static const iPhoneOS = IOSSdk._('iphoneos');

  /// The iphonesimulator SDK in Xcode.
  ///
  /// The SDK location can be found on the host machine with
  /// `xcrun --sdk iphonesimulator --show-sdk-path`.
  static const iPhoneSimulator = IOSSdk._('iphonesimulator');

  /// All known values for [IOSSdk].
  static const values = [
    iPhoneOS,
    iPhoneSimulator,
  ];

  /// The type of this [IOSSdk].
  ///
  /// This returns a stable string that can be used to construct a
  /// [IOSSdk] via [IOSSdk.fromString].
  factory IOSSdk.fromString(String type) =>
      values.firstWhere((e) => e.type == type);

  /// The type of this [IOSSdk].
  ///
  /// This returns a stable string that can be used to construct a
  /// [IOSSdk] via [IOSSdk.fromString].
  @override
  String toString() => type;
}
