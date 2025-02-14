// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:pub_semver/pub_semver.dart';

import 'c_bindings_generated.dart' as c;

Version get osVersion => _osVersion;

Version _osVersion = () {
  final ver = c.getOsVesion();
  return Version(ver.major, ver.minor, ver.patch);
}();

final class OsVersionError implements Exception {
  final String apiName;
  final String message;
  OsVersionError(this.apiName, this.message);

  @override
  String toString() => '$runtimeType: $apiName $message.';
}

typedef PlatformAvailability = (bool unavailable, (int, int, int)? introduced);

void checkOsVersion(
  String apiName, {
  PlatformAvailability? iOS,
  PlatformAvailability? macOS,
}) {
  if (Platform.isIOS) _checkOsVersionImpl(apiName, 'iOS', iOS);
  if (Platform.isMacOS) _checkOsVersionImpl(apiName, 'macOS', macOS);
}

void _checkOsVersionImpl(
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
