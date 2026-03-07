// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../../config_provider/external_versions.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

enum Availability { none, some, all }

class ApiAvailability {
  final bool alwaysDeprecated;
  final bool alwaysUnavailable;
  final PlatformAvailability? ios;
  final PlatformAvailability? macos;

  late final Availability availability;

  ApiAvailability({
    this.alwaysDeprecated = false,
    this.alwaysUnavailable = false,
    this.ios,
    this.macos,
    required ExternalVersions? externalVersions,
  }) {
    availability = _getAvailability(externalVersions);
  }

  static ApiAvailability fromCursor(
    clang_types.CXCursor cursor,
    Context context,
  ) {
    final platformsLength = clang.clang_getCursorPlatformAvailability(
      cursor,
      nullptr,
      nullptr,
      nullptr,
      nullptr,
      nullptr,
      0,
    );

    final alwaysDeprecated = calloc<Int>();
    final alwaysUnavailable = calloc<Int>();
    final platforms = calloc<clang_types.CXPlatformAvailability>(
      platformsLength,
    );

    clang.clang_getCursorPlatformAvailability(
      cursor,
      alwaysDeprecated,
      nullptr,
      alwaysUnavailable,
      nullptr,
      platforms,
      platformsLength,
    );

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
      externalVersions: context.config.objectiveC?.externalVersions,
    );

    for (var i = 0; i < platformsLength; ++i) {
      clang.clang_disposeCXPlatformAvailability(platforms + i);
    }
    calloc.free(alwaysDeprecated);
    calloc.free(alwaysUnavailable);
    calloc.free(platforms);

    return api;
  }

  Availability _getAvailability(ExternalVersions? externalVersions) {
    final macosVer = _normalizeVersions(externalVersions?.macos);
    final iosVer = _normalizeVersions(externalVersions?.ios);

    // If no versions are specified, everything is available.
    if (iosVer == null && macosVer == null) {
      return Availability.all;
    }

    if (alwaysDeprecated || alwaysUnavailable) {
      return Availability.none;
    }

    Availability? availability_;
    for (final (platform, version) in [(ios, iosVer), (macos, macosVer)]) {
      // If the user hasn't specified any versions for this platform, defer to
      // the other platforms.
      if (version == null) {
        continue;
      }
      // If the API is available on any platform, return that it's available.
      final platAvailability =
          platform?.getAvailability(version) ?? Availability.all;
      availability_ = _mergeAvailability(availability_, platAvailability);
    }
    return availability_ ?? Availability.none;
  }

  // If the min and max version are null, the versions object should be null.
  static Versions? _normalizeVersions(Versions? versions) =>
      versions?.min == null && versions?.max == null ? null : versions;

  static Availability _mergeAvailability(Availability? x, Availability y) =>
      x == null ? y : (x == y ? x : Availability.some);

  List<PlatformAvailability> get _platforms => [ios, macos].nonNulls.toList();

  String? get dartDoc {
    if (availability != Availability.some) return null;
    final platforms = _platforms;
    if (platforms.isEmpty) return null;
    return platforms.map((platform) => platform.dartDoc).join('\n');
  }

  String? runtimeCheck(String checkOsVersion, String apiName) {
    final platforms = _platforms;
    if (platforms.isEmpty) return null;
    final args = platforms.map((platform) => platform.checkArgs).join(', ');
    return "$checkOsVersion('$apiName', $args);";
  }

  /// Combines two [ApiAvailability] objects by taking the union of their
  /// availability.
  ///
  /// The resulting availability is the intersection of the sets of available
  /// versions. Use this when a construct depends on multiple other constructs,
  /// and is only available when *all* of them are available.
  static ApiAvailability union(ApiAvailability a, ApiAvailability b) {
    return ApiAvailability(
      alwaysDeprecated: a.alwaysDeprecated || b.alwaysDeprecated,
      alwaysUnavailable: a.alwaysUnavailable || b.alwaysUnavailable,
      ios: _unionPlatform(a.ios, b.ios),
      macos: _unionPlatform(a.macos, b.macos),
      externalVersions: null,
    );
  }

  static PlatformAvailability? _unionPlatform(
    PlatformAvailability? a,
    PlatformAvailability? b,
  ) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;

    return PlatformAvailability(
      name: a.name ?? b.name,
      introduced: _max(a.introduced, b.introduced),
      deprecated: _min(a.deprecated, b.deprecated),
      obsoleted: _min(a.obsoleted, b.obsoleted),
      unavailable: a.unavailable || b.unavailable,
    );
  }

  static Version? _max(Version? a, Version? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }

  static Version? _min(Version? a, Version? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a < b ? a : b;
  }

  String get attribute {
    final parts = <String>[];
    for (final platform in [ios, macos].nonNulls) {
      if (platform.unavailable) {
        parts.add('${platform.name!.toLowerCase()}(unavailable)');
        continue;
      }
      final versionParts = <String>[];
      if (platform.introduced != null) {
        versionParts.add('introduced=${platform.introduced}');
      }
      if (platform.deprecated != null) {
        versionParts.add('deprecated=${platform.deprecated}');
      }
      if (platform.obsoleted != null) {
        versionParts.add('obsoleted=${platform.obsoleted}');
      }
      if (versionParts.isNotEmpty) {
        parts.add('${platform.name!.toLowerCase()}(${versionParts.join(", ")})');
      }
    }
    if (parts.isEmpty) return '';
    return 'API_AVAILABLE(${parts.join(", ")})';
  }

  @override
  String toString() =>
      '''Availability {
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
  Availability getAvailability(Versions version) {
    if (unavailable) {
      return Availability.none;
    }

    // Note: _greaterThan treats null as Version(infinity). For lower bound
    // versions, null should be Version(0).
    final confMin = version.min ?? Version(0, 0, 0);
    final confMax = version.max;
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
      s.write(
        [
          if (introduced != null) 'introduced $introduced',
          if (deprecated != null) 'deprecated $deprecated',
          if (obsoleted != null) 'obsoleted $obsoleted',
        ].join(', '),
      );
    }
    return s.toString();
  }

  String get checkArgs => '$name: ($unavailable, ${_toRecord(introduced)})';
  String _toRecord(Version? v) =>
      v == null ? 'null' : '(${v.major}, ${v.minor}, ${v.patch})';

  @override
  String toString() =>
      'introduced: $introduced, deprecated: $deprecated, '
      'obsoleted: $obsoleted, unavailable: $unavailable';
}
