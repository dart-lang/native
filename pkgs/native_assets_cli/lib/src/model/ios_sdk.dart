// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/ios_sdk.dart';

/// For an iOS target, a build is either done for the device or the simulator.
///
/// Only fat binaries or xcframeworks can contain both targets.
class IOSSdkImpl implements IOSSdk {
  final String xcodebuildSdk;

  const IOSSdkImpl._(this.xcodebuildSdk);

  static const iPhoneOs = IOSSdkImpl._('iphoneos');
  static const iPhoneSimulator = IOSSdkImpl._('iphonesimulator');

  static const values = [
    iPhoneOs,
    iPhoneSimulator,
  ];

  factory IOSSdkImpl.fromString(String target) =>
      values.firstWhere((e) => e.xcodebuildSdk == target);

  /// The `package:config` key preferably used.
  static const String configKey = 'target_ios_sdk';

  @override
  String toString() => xcodebuildSdk;
}
