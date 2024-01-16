// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../api/ios_sdk.dart' as api;

/// For an iOS target, a build is either done for the device or the simulator.
///
/// Only fat binaries or xcframeworks can contain both targets.
class IOSSdk implements api.IOSSdk {
  final String xcodebuildSdk;

  const IOSSdk._(this.xcodebuildSdk);

  static const iPhoneOs = IOSSdk._('iphoneos');
  static const iPhoneSimulator = IOSSdk._('iphonesimulator');

  static const values = [
    iPhoneOs,
    iPhoneSimulator,
  ];

  factory IOSSdk.fromString(String target) =>
      values.firstWhere((e) => e.xcodebuildSdk == target);

  /// The `package:config` key preferably used.
  static const String configKey = 'target_ios_sdk';

  @override
  String toString() => xcodebuildSdk;
}
