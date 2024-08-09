// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

bool isApiAvailable(clang_types.CXCursor cursor) {
  final api = ApiAvailability.fromCursor(cursor);
  return api.isAvailable(config.objCMinTargetVersion);
}

class ApiAvailability {
  final bool alwaysDeprecated;
  final bool alwaysUnavailable;
  PlatformAvailability? ios;
  PlatformAvailability? macos;

  ApiAvailability({
    this.alwaysDeprecated = false,
    this.alwaysUnavailable = false,
    this.ios,
    this.macos,
  });

  static ApiAvailability fromCursor(clang_types.CXCursor cursor) {
    final platformsLength = clang.clang_getCursorPlatformAvailability(
        cursor, nullptr, nullptr, nullptr, nullptr, nullptr, 0);

    final alwaysDeprecated = calloc<Int>();
    final alwaysUnavailable = calloc<Int>();
    final platforms =
        calloc<clang_types.CXPlatformAvailability>(platformsLength);

    clang.clang_getCursorPlatformAvailability(cursor, alwaysDeprecated, nullptr,
        alwaysUnavailable, nullptr, platforms, platformsLength);

    PlatformAvailability? ios;
    PlatformAvailability? macos;

    for (var i = 0; i < platformsLength; ++i) {
      final platform = platforms[i];
      final platformAvailability = PlatformAvailability(
        introduced: platform.Introduced.triple,
        deprecated: platform.Deprecated.triple,
        obsoleted: platform.Obsoleted.triple,
        unavailable: platform.Unavailable != 0,
      );
      switch (platform.Platform.string()) {
        case 'ios':
          ios = platformAvailability;
          break;
        case 'macos':
          macos = platformAvailability;
          break;
      }
    }

    final api = ApiAvailability(
      alwaysDeprecated: alwaysDeprecated.value != 0,
      alwaysUnavailable: alwaysUnavailable.value != 0,
      ios: ios,
      macos: macos,
    );

    for (var i = 0; i < platformsLength; ++i) {
      clang.clang_disposeCXPlatformAvailability(platforms + i);
    }
    calloc.free(alwaysDeprecated);
    calloc.free(alwaysUnavailable);
    calloc.free(platforms);

    return api;
  }

  bool isAvailable(ObjCTargetVersion minVers) {
    // If no minimum versions are specified, everything is available.
    if (minVers.ios == null && minVers.macos == null) {
      return true;
    }

    if (alwaysDeprecated || alwaysUnavailable) {
      return false;
    }

    for (final (plat, minVer) in [(ios, minVers.ios), (macos, minVers.macos)]) {
      // If the user hasn't specified a minimum version for this platform, defer
      // to the other platforms.
      if (minVer == null) {
        continue;
      }
      // If the API is available on any platform, return that it's available.
      if (_platformAvailable(plat, minVer)) {
        return true;
      }
    }
    // The API is not available on any of the platforms the user cares about.
    return false;
  }

  bool _platformAvailable(PlatformAvailability? plat, VersionTriple minVer) {
    if (plat == null) {
      // Clang's availability info has nothing to say about the given platform,
      // so assume the API is available.
      return true;
    }
    if (plat.unavailable) {
      return false;
    }
    if (minVer >= plat.deprecated || minVer >= plat.obsoleted) {
      return false;
    }
    return true;
  }

  @override
  String toString() => '''Availability {
  alwaysDeprecated: $alwaysDeprecated
  alwaysUnavailable: $alwaysUnavailable
  ios: $ios
  macos: $macos
}''';
}

class PlatformAvailability {
  VersionTriple? introduced;
  VersionTriple? deprecated;
  VersionTriple? obsoleted;
  bool unavailable;

  PlatformAvailability({
    this.introduced,
    this.deprecated,
    this.obsoleted,
    this.unavailable = false,
  });

  @override
  String toString() => 'introduced: $introduced, deprecated: $deprecated, '
      'obsoleted: $obsoleted, unavailable: $unavailable';
}
