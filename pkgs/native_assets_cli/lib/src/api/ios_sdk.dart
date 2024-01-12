// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/ios_sdk.dart' as model;

/// For an iOS target, a build is either done for the device or the simulator.
///
/// Only fat binaries or xcframeworks can contain both targets.
abstract class IOSSdk {
  static const IOSSdk iPhoneOs = model.IOSSdk.iPhoneOs;
  static const IOSSdk iPhoneSimulator = model.IOSSdk.iPhoneSimulator;

  static const values = <IOSSdk>[
    iPhoneOs,
    iPhoneSimulator,
  ];
}
