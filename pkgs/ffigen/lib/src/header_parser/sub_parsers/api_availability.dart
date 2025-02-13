// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

enum Availability {
  none,
  some,
  all,
}

typedef ApiAvailabilityReport = ({
  Availability availability,
  String? dartDoc,
});

ApiAvailabilityReport getApiAvailability(clang_types.CXCursor cursor) {
  final api = ApiAvailability.fromCursor(cursor);
  final availability = api.getAvailability(config.externalVersions);
  return (
    availability: availability,
    dartDoc: availability == Availability.some ? api.dartDoc : null,
  );
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
          ios = platformAvailability..name = 'iOS';
          break;
        case 'macos':
          macos = platformAvailability..name = 'macOS';
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

  Availability getAvailability(ExternalVersions extVers) {
    final macosVer = _normalizeVersions(extVers.macos);
    final iosVer = _normalizeVersions(extVers.ios);

    // If no versions are specified, everything is available.
    if (iosVer == null && macosVer == null) {
      return Availability.all;
    }

    if (alwaysDeprecated || alwaysUnavailable) {
      return Availability.none;
    }

    Availability? availability;
    for (final (plat, ver) in [(ios, iosVer), (macos, macosVer)]) {
      // If the user hasn't specified any versions for this platform, defer to
      // the other platforms.
      if (ver == null) {
        continue;
      }
      // If the API is available on any platform, return that it's available.
      final platAvailability = plat?.getAvailability(ver) ?? Availability.all;
      availability = _mergeAvailability(availability, platAvailability);
    }
    return availability ?? Availability.none;
  }

  // If the min and max version are null, the versions object should be null.
  static Versions? _normalizeVersions(Versions? versions) =>
      versions?.min == null && versions?.max == null ? null : versions;

  static Availability _mergeAvailability(Availability? x, Availability y) =>
      x == null ? y : (x == y ? x : Availability.some);

  String get dartDoc =>
      [ios, macos].nonNulls.map((plat) => plat.dartDoc).join('\n');

  @override
  String toString() => '''Availability {
  alwaysDeprecated: $alwaysDeprecated
  alwaysUnavailable: $alwaysUnavailable
  ios: $ios
  macos: $macos
}''';
}

class PlatformAvailability {
  String? name;
  Version? introduced;
  Version? deprecated;
  Version? obsoleted;
  bool unavailable;

  PlatformAvailability({
    this.name,
    this.introduced,
    this.deprecated,
    this.obsoleted,
    this.unavailable = false,
  });

  @visibleForTesting
  Version? get deprecatedOrObsoleted {
    if (deprecated == null || obsoleted == null) {
      return deprecated ?? obsoleted;
    }
    return deprecated! < obsoleted! ? deprecated : obsoleted;
  }

  @visibleForTesting
  Availability getAvailability(Versions ver) {
    if (unavailable) {
      return Availability.none;
    }

    // Note: _greaterThan treats null as Version(infinity). For lower bound
    // versions, null should be Version(0).
    final confMin = ver.min ?? Version(0, 0, 0);
    final confMax = ver.max;
    final apiMin = introduced ?? Version(0, 0, 0);
    final apiMax = deprecatedOrObsoleted;
    if (_lessThanOrEqual(apiMin, confMin) && _greaterThan(apiMax, confMax)) {
      return Availability.all;
    }
    if (_lessThanOrEqual(apiMin, confMax) && _greaterThan(apiMax, confMin)) {
      return Availability.some;
    }
    return Availability.none;
  }

  static bool _lessThanOrEqual(Version? x, Version? y) => !_greaterThan(x, y);

  static bool _greaterThan(Version? x, Version? y) {
    if (x == null) return true;
    if (y == null) return false;
    return x > y;
  }

  String get dartDoc {
    final s = StringBuffer();
    s.write('$name: ');
    if (unavailable) {
      s.write('unavailable');
    } else {
      s.write([
        if (introduced != null) 'introduced $introduced',
        if (deprecated != null) 'deprecated $deprecated',
        if (obsoleted != null) 'obsoleted $obsoleted',
      ].join(', '));
    }
    return s.toString();
  }

  @override
  String toString() => 'introduced: $introduced, deprecated: $deprecated, '
      'obsoleted: $obsoleted, unavailable: $unavailable';
}
