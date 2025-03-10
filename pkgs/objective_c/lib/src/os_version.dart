// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:pub_semver/pub_semver.dart';

import 'c_bindings_generated.dart' as c;

/// Returns the current MacOS/iOS version.
Version get osVersion => _osVersion;

Version _osVersion = () {
  final ver = c.getOsVesion();
  return Version(ver.major, ver.minor, ver.patch);
}();

/// Returns whether the current MacOS/iOS version is greater than or equal to
/// the given version.
///
/// The each platform's version is optional, and the function returns false if
/// no version is provided for the current platform.
bool checkOsVersion({Version? iOS, Version? macOS}) {
  if (Platform.isIOS) return _checkOsVersionImpl(iOS);
  if (Platform.isMacOS) return _checkOsVersionImpl(macOS);
  throw UnsupportedError('Only supported on iOS and macOS');
}

bool _checkOsVersionImpl(Version? version) {
  if (version == null) return false;
  return osVersion >= version;
}

final class OsVersionError implements Exception {
  final String apiName;
  final String message;
  OsVersionError(this.apiName, this.message);

  @override
  String toString() => '$runtimeType: $apiName $message.';
}

typedef PlatformAvailability = (bool unavailable, (int, int, int)? introduced);

/// Only for use by ffigen bindings.
void checkOsVersionInternal(
  String apiName, {
  PlatformAvailability? iOS,
  PlatformAvailability? macOS,
}) {
  if (Platform.isIOS) _checkOsVersionInternalImpl(apiName, 'iOS', iOS);
  if (Platform.isMacOS) _checkOsVersionInternalImpl(apiName, 'macOS', macOS);
}

void _checkOsVersionInternalImpl(
    String apiName, String osName, PlatformAvailability? availability) {
  if (availability == null) return;
  final (bool unavailable, (int, int, int)? introduced) = availability;
  if (unavailable) {
    throw OsVersionError(apiName, 'is not supported on $osName');
  }
  if (introduced != null && osVersion < _toVersion(introduced)) {
    throw OsVersionError(
        apiName,
        'is not supported on $osName before version $introduced.'
        'The current version is $osVersion');
  }
}

Version _toVersion((int, int, int) record) {
  final (int major, int minor, int patch) = record;
  return Version(major, minor, patch);
}
