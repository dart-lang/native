// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../../config_provider/config_types.dart';
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
  final ExternalVersions? _externalVersions;

  static final alwaysAvailable = ApiAvailability(externalVersions: null);

  ApiAvailability({
    this.alwaysDeprecated = false,
    this.alwaysUnavailable = false,
    this.ios,
    this.macos,
    ExternalVersions? externalVersions,
  }) : _externalVersions = externalVersions {
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

  ApiAvailability merge(ApiAvailability other) {
    if (this == alwaysAvailable) return other;
    if (other == alwaysAvailable) return this;

    return ApiAvailability(
      alwaysDeprecated: alwaysDeprecated || other.alwaysDeprecated,
      alwaysUnavailable: alwaysUnavailable || other.alwaysUnavailable,
      ios: PlatformAvailability.merge(ios, other.ios),
      macos: PlatformAvailability.merge(macos, other.macos),
      externalVersions: _externalVersions ?? other._externalVersions,
    );
  }

  String? get apiAvailableMacro {
    if (alwaysUnavailable) return '__attribute__((unavailable))';
    if (alwaysDeprecated) return '__attribute__((deprecated))';

    final platforms = _platforms;
    if (platforms.isEmpty) return null;

    final attributes = <String>[];
    for (final platform in platforms) {
      if (platform.unavailable) {
        attributes.add(
          'availability(${platform.name!.toLowerCase()}, unavailable)',
        );
      } else {
        final platformAttrs = <String>[];
        if (platform.introduced != null) {
          platformAttrs.add('introduced=${platform.introduced}');
        }
        if (platform.deprecated != null) {
          platformAttrs.add('deprecated=${platform.deprecated}');
        }
        if (platform.obsoleted != null) {
          platformAttrs.add('obsoleted=${platform.obsoleted}');
        }
        if (platformAttrs.isNotEmpty) {
          attributes.add(
            // ignore: lines_longer_than_80_chars
            'availability(${platform.name!.toLowerCase()},${platformAttrs.join(',')})',
          );
        } else {
          attributes.add('availability(${platform.name!.toLowerCase()})');
        }
      }
    }
    if (attributes.isEmpty) return null;
    return attributes.map((a) => '__attribute__(($a))').join(' ');
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

  static PlatformAvailability? merge(
    PlatformAvailability? a,
    PlatformAvailability? b,
  ) {
    if (a == null) return b;
    if (b == null) return a;

    Version? newIntroduced;
    if (a.introduced == null) {
      newIntroduced = b.introduced;
    } else if (b.introduced == null) {
      newIntroduced = a.introduced;
    } else {
      newIntroduced = a.introduced! > b.introduced!
          ? a.introduced
          : b.introduced;
    }

    Version? newDeprecated;
    if (a.deprecated == null) {
      newDeprecated = b.deprecated;
    } else if (b.deprecated == null) {
      newDeprecated = a.deprecated;
    } else {
      newDeprecated = a.deprecated! < b.deprecated!
          ? a.deprecated
          : b.deprecated;
    }

    Version? newObsoleted;
    if (a.obsoleted == null) {
      newObsoleted = b.obsoleted;
    } else if (b.obsoleted == null) {
      newObsoleted = a.obsoleted;
    } else {
      newObsoleted = a.obsoleted! < b.obsoleted! ? a.obsoleted : b.obsoleted;
    }

    return PlatformAvailability(
      name: a.name ?? b.name,
      introduced: newIntroduced,
      deprecated: newDeprecated,
      obsoleted: newObsoleted,
      unavailable: a.unavailable || b.unavailable,
    );
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
