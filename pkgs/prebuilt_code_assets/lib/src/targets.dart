// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';

/// A target tuple consisting of [OS], [Architecture], and optional [IOSSdk].
typedef TargetSpec = (OS os, Architecture arch, IOSSdk? iosSdk);

/// Canonical list of supported native targets across mobile and desktop
/// platforms.
const List<TargetSpec> supportedTargets = [
  (OS.android, Architecture.arm, null),
  (OS.android, Architecture.arm64, null),
  (OS.android, Architecture.ia32, null),
  (OS.android, Architecture.riscv64, null),
  (OS.android, Architecture.x64, null),
  (OS.iOS, Architecture.arm64, IOSSdk.iPhoneOS),
  (OS.iOS, Architecture.arm64, IOSSdk.iPhoneSimulator),
  (OS.iOS, Architecture.x64, IOSSdk.iPhoneSimulator),
  (OS.linux, Architecture.arm, null),
  (OS.linux, Architecture.arm64, null),
  (OS.linux, Architecture.ia32, null),
  (OS.linux, Architecture.riscv64, null),
  (OS.linux, Architecture.x64, null),
  (OS.macOS, Architecture.arm64, null),
  (OS.macOS, Architecture.x64, null),
  (OS.windows, Architecture.arm64, null),
  (OS.windows, Architecture.ia32, null),
  (OS.windows, Architecture.x64, null),
];

/// Formats a canonical target identifier, including [iosSdk] when targeting iOS
/// so device (`iphoneos`) and simulator (`iphonesimulator`) binaries do not
/// collide on `ios-arm64`.
String targetTripleFor(OS os, Architecture arch, {IOSSdk? iosSdk}) {
  if (os == OS.iOS && iosSdk != null) {
    return '${os.name}-${arch.name}-${iosSdk.type}';
  }
  return '${os.name}-${arch.name}';
}

/// Formats the canonical target identifier for [code].
String targetTripleForConfig(CodeConfig code) {
  final targetOS = code.targetOS;
  final iosSdk = targetOS == OS.iOS ? code.iOS.targetSdk : null;
  return targetTripleFor(targetOS, code.targetArchitecture, iosSdk: iosSdk);
}
