// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part '../model/ios_sdk.dart';

/// For an iOS target, a build is either done for the device or the simulator.
abstract final class IOSSdk {
  /// The iphoneos SDK in Xcode.
  ///
  /// The SDK location can be found on the host machine with
  /// `xcrun --sdk iphoneos --show-sdk-path`.
  static const IOSSdk iPhoneOS = IOSSdkImpl.iPhoneOS;

  /// The iphonesimulator SDK in Xcode.
  ///
  /// The SDK location can be found on the host machine with
  /// `xcrun --sdk iphonesimulator --show-sdk-path`.
  static const IOSSdk iPhoneSimulator = IOSSdkImpl.iPhoneSimulator;

  /// All known values for [IOSSdk].
  static const values = <IOSSdk>[
    iPhoneOS,
    iPhoneSimulator,
  ];
}
