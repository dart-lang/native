// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// For an iOS target, a build is either done for the device or the simulator.
final class IOSSdk {
  final String xcodebuildSdk;

  const IOSSdk._(this.xcodebuildSdk);

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

  factory IOSSdk.fromString(String target) =>
      values.firstWhere((e) => e.xcodebuildSdk == target);

  @override
  String toString() => xcodebuildSdk;
}
