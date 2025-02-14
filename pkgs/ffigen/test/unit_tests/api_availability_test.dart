// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('PlatformAvailability.deprecatedOrObsoleted', () {
    expect(PlatformAvailability().deprecatedOrObsoleted, null);
    expect(
        PlatformAvailability(deprecated: Version(1, 2, 3))
            .deprecatedOrObsoleted,
        Version(1, 2, 3));
    expect(
        PlatformAvailability(obsoleted: Version(1, 2, 3)).deprecatedOrObsoleted,
        Version(1, 2, 3));
    expect(
        PlatformAvailability(
                deprecated: Version(1, 2, 3), obsoleted: Version(4, 5, 6))
            .deprecatedOrObsoleted,
        Version(1, 2, 3));
    expect(
        PlatformAvailability(
                deprecated: Version(4, 5, 6), obsoleted: Version(1, 2, 3))
            .deprecatedOrObsoleted,
        Version(1, 2, 3));
  });

  test('PlatformAvailability.getAvailability', () {
    expect(
        PlatformAvailability(unavailable: true)
            .getAvailability(const Versions()),
        Availability.none);

    Availability getAvailability(Version? apiMin, Version? apiMax,
            Version? confMin, Version? confMax) =>
        PlatformAvailability(introduced: apiMin, deprecated: apiMax)
            .getAvailability(Versions(min: confMin, max: confMax));

    final v1 = Version(1, 0, 0);
    final v2 = Version(2, 0, 0);
    final v3 = Version(3, 0, 0);
    final v4 = Version(4, 0, 0);
    final v5 = Version(5, 0, 0);
    final v6 = Version(6, 0, 0);
    final v7 = Version(7, 0, 0);
    final v8 = Version(8, 0, 0);

    expect(getAvailability(null, null, null, null), Availability.all);
    expect(getAvailability(null, null, null, v2), Availability.all);
    expect(getAvailability(null, null, v1, null), Availability.all);
    expect(getAvailability(null, null, v1, v2), Availability.all);

    expect(getAvailability(v3, null, null, null), Availability.some);
    expect(getAvailability(v3, null, null, v2), Availability.none);
    expect(getAvailability(v3, null, null, v3), Availability.some);
    expect(getAvailability(v3, null, null, v5), Availability.some);
    expect(getAvailability(v3, null, v1, null), Availability.some);
    expect(getAvailability(v3, null, v1, v2), Availability.none);
    expect(getAvailability(v3, null, v1, v3), Availability.some);
    expect(getAvailability(v3, null, v1, v5), Availability.some);
    expect(getAvailability(v3, null, v3, null), Availability.all);
    expect(getAvailability(v3, null, v3, v5), Availability.all);
    expect(getAvailability(v3, null, v4, null), Availability.all);
    expect(getAvailability(v3, null, v4, v5), Availability.all);

    expect(getAvailability(null, v3, null, null), Availability.some);
    expect(getAvailability(null, v3, null, v2), Availability.all);
    expect(getAvailability(null, v3, null, v3), Availability.some);
    expect(getAvailability(null, v3, null, v5), Availability.some);
    expect(getAvailability(null, v3, v1, null), Availability.some);
    expect(getAvailability(null, v3, v1, v2), Availability.all);
    expect(getAvailability(null, v3, v1, v3), Availability.some);
    expect(getAvailability(null, v3, v1, v5), Availability.some);
    expect(getAvailability(null, v3, v3, null), Availability.none);
    expect(getAvailability(null, v3, v3, v5), Availability.none);
    expect(getAvailability(null, v3, v4, null), Availability.none);
    expect(getAvailability(null, v3, v4, v5), Availability.none);

    expect(getAvailability(v3, v6, null, null), Availability.some);
    expect(getAvailability(v3, v6, null, v2), Availability.none);
    expect(getAvailability(v3, v6, null, v3), Availability.some);
    expect(getAvailability(v3, v6, null, v5), Availability.some);
    expect(getAvailability(v3, v6, null, v6), Availability.some);
    expect(getAvailability(v3, v6, null, v8), Availability.some);
    expect(getAvailability(v3, v6, v1, null), Availability.some);
    expect(getAvailability(v3, v6, v1, v2), Availability.none);
    expect(getAvailability(v3, v6, v1, v3), Availability.some);
    expect(getAvailability(v3, v6, v1, v5), Availability.some);
    expect(getAvailability(v3, v6, v1, v6), Availability.some);
    expect(getAvailability(v3, v6, v1, v8), Availability.some);
    expect(getAvailability(v3, v6, v3, null), Availability.some);
    expect(getAvailability(v3, v6, v3, v5), Availability.all);
    expect(getAvailability(v3, v6, v3, v6), Availability.some);
    expect(getAvailability(v3, v6, v3, v8), Availability.some);
    expect(getAvailability(v3, v6, v5, null), Availability.some);
    expect(getAvailability(v3, v6, v5, v6), Availability.some);
    expect(getAvailability(v3, v6, v5, v8), Availability.some);
    expect(getAvailability(v3, v6, v6, null), Availability.none);
    expect(getAvailability(v3, v6, v6, v8), Availability.none);
    expect(getAvailability(v3, v6, v7, null), Availability.none);
    expect(getAvailability(v3, v6, v7, v8), Availability.none);
  });

  group('Availability.getAvailability', () {
    test('empty', () {
      expect(
          ApiAvailability(externalVersions: const ExternalVersions())
              .availability,
          Availability.all);
      expect(
          ApiAvailability(
              externalVersions: ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )).availability,
          Availability.all);
      expect(
          ApiAvailability(
              externalVersions: ExternalVersions(
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )).availability,
          Availability.all);
      expect(
          ApiAvailability(
              externalVersions: ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )).availability,
          Availability.all);
    });

    test('always deprecated', () {
      expect(
          ApiAvailability(
                  alwaysDeprecated: true,
                  externalVersions: const ExternalVersions())
              .availability,
          Availability.all);
      expect(
          ApiAvailability(
              alwaysDeprecated: true,
              externalVersions: ExternalVersions(
                ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
              )).availability,
          Availability.none);
      expect(
          ApiAvailability(
              alwaysDeprecated: true,
              externalVersions: ExternalVersions(
                macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
              )).availability,
          Availability.none);
      expect(
          ApiAvailability(
              alwaysDeprecated: true,
              externalVersions: ExternalVersions(
                ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
                macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
              )).availability,
          Availability.none);
    });

    test('always unavailable', () {
      expect(
          ApiAvailability(
                  alwaysUnavailable: true,
                  externalVersions: const ExternalVersions())
              .availability,
          Availability.all);
      expect(
          ApiAvailability(
              alwaysUnavailable: true,
              externalVersions: ExternalVersions(
                ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
              )).availability,
          Availability.none);
      expect(
          ApiAvailability(
              alwaysUnavailable: true,
              externalVersions: ExternalVersions(
                macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
              )).availability,
          Availability.none);
      expect(
          ApiAvailability(
              alwaysUnavailable: true,
              externalVersions: ExternalVersions(
                ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
                macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
              )).availability,
          Availability.none);
    });

    test('versions', () {
      final v1 = Version(1, 0, 0);
      final v2 = Version(2, 0, 0);
      final v3 = Version(3, 0, 0);
      final v4 = Version(4, 0, 0);
      final v5 = Version(5, 0, 0);
      final v6 = Version(6, 0, 0);

      final plat = PlatformAvailability(introduced: v1, deprecated: v4);
      final verInside = Versions(min: v2, max: v3);
      final verOverlap = Versions(min: v2, max: v6);
      final verOutside = Versions(min: v5, max: v6);
      final verEmpty = const Versions();

      Availability getAvail(
              PlatformAvailability? iosAvail,
              PlatformAvailability? macosAvail,
              Versions? iosVer,
              Versions? macosVer) =>
          ApiAvailability(
                  ios: iosAvail,
                  macos: macosAvail,
                  externalVersions:
                      ExternalVersions(ios: iosVer, macos: macosVer))
              .availability;

      expect(getAvail(null, null, null, null), Availability.all);
      expect(getAvail(null, null, verEmpty, verEmpty), Availability.all);
      expect(getAvail(plat, plat, null, null), Availability.all);
      expect(getAvail(plat, plat, verEmpty, verEmpty), Availability.all);

      expect(getAvail(plat, plat, null, verInside), Availability.all);
      expect(getAvail(plat, plat, null, verOverlap), Availability.some);
      expect(getAvail(plat, plat, null, verOutside), Availability.none);
      expect(getAvail(plat, plat, verInside, null), Availability.all);
      expect(getAvail(plat, plat, verOverlap, null), Availability.some);
      expect(getAvail(plat, plat, verOutside, null), Availability.none);

      expect(getAvail(plat, plat, verEmpty, verInside), Availability.all);
      expect(getAvail(plat, plat, verEmpty, verOverlap), Availability.some);
      expect(getAvail(plat, plat, verEmpty, verOutside), Availability.none);
      expect(getAvail(plat, plat, verInside, verEmpty), Availability.all);
      expect(getAvail(plat, plat, verOverlap, verEmpty), Availability.some);
      expect(getAvail(plat, plat, verOutside, verEmpty), Availability.none);

      expect(getAvail(plat, plat, verInside, verInside), Availability.all);
      expect(getAvail(plat, plat, verInside, verOverlap), Availability.some);
      expect(getAvail(plat, plat, verInside, verOutside), Availability.some);
      expect(getAvail(plat, plat, verOverlap, verInside), Availability.some);
      expect(getAvail(plat, plat, verOverlap, verOverlap), Availability.some);
      expect(getAvail(plat, plat, verOverlap, verOutside), Availability.some);
      expect(getAvail(plat, plat, verOutside, verInside), Availability.some);
      expect(getAvail(plat, plat, verOutside, verOverlap), Availability.some);
      expect(getAvail(plat, plat, verOutside, verOutside), Availability.none);

      expect(getAvail(null, plat, verInside, verInside), Availability.all);
      expect(getAvail(null, plat, verInside, verOverlap), Availability.some);
      expect(getAvail(null, plat, verInside, verOutside), Availability.some);
      expect(getAvail(null, plat, verOverlap, verInside), Availability.all);
      expect(getAvail(null, plat, verOverlap, verOverlap), Availability.some);
      expect(getAvail(null, plat, verOverlap, verOutside), Availability.some);
      expect(getAvail(null, plat, verOutside, verInside), Availability.all);
      expect(getAvail(null, plat, verOutside, verOverlap), Availability.some);
      expect(getAvail(null, plat, verOutside, verOutside), Availability.some);

      expect(getAvail(plat, null, verInside, verInside), Availability.all);
      expect(getAvail(plat, null, verInside, verOverlap), Availability.all);
      expect(getAvail(plat, null, verInside, verOutside), Availability.all);
      expect(getAvail(plat, null, verOverlap, verInside), Availability.some);
      expect(getAvail(plat, null, verOverlap, verOverlap), Availability.some);
      expect(getAvail(plat, null, verOverlap, verOutside), Availability.some);
      expect(getAvail(plat, null, verOutside, verInside), Availability.some);
      expect(getAvail(plat, null, verOutside, verOverlap), Availability.some);
      expect(getAvail(plat, null, verOutside, verOutside), Availability.some);
    });
  });

  test('ApiAvailability.dartDoc', () {
    expect(
        ApiAvailability(
          ios: PlatformAvailability(
            name: 'iOS',
            introduced: Version(1, 2, 3),
            deprecated: Version(4, 5, 6),
            obsoleted: Version(7, 8, 9),
          ),
          macos: PlatformAvailability(
            name: 'macOS',
            deprecated: Version(10, 11, 12),
          ),
          externalVersions: const ExternalVersions(),
        ).dartDoc,
        isNull);

    expect(
        ApiAvailability(
          ios: PlatformAvailability(
            name: 'iOS',
            introduced: Version(1, 2, 3),
            deprecated: Version(4, 5, 6),
            obsoleted: Version(7, 8, 9),
          ),
          macos: PlatformAvailability(
            name: 'macOS',
            deprecated: Version(10, 11, 12),
          ),
          externalVersions: ExternalVersions(
            ios: Versions(max: Version(1, 0, 0)),
          ),
        ).dartDoc,
        isNull);

    expect(
        ApiAvailability(
          ios: PlatformAvailability(
            name: 'iOS',
            introduced: Version(1, 2, 3),
            deprecated: Version(4, 5, 6),
            obsoleted: Version(7, 8, 9),
          ),
          macos: PlatformAvailability(
            name: 'macOS',
            deprecated: Version(10, 11, 12),
          ),
          externalVersions: ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(1, 3, 5)),
            macos: Versions(max: Version(4, 5, 6)),
          ),
        ).dartDoc,
        isNull);

    expect(
        ApiAvailability(
          ios: PlatformAvailability(
            name: 'iOS',
            introduced: Version(1, 2, 3),
            deprecated: Version(4, 5, 6),
            obsoleted: Version(7, 8, 9),
          ),
          macos: PlatformAvailability(
            name: 'macOS',
            deprecated: Version(10, 11, 12),
          ),
          externalVersions: ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(1, 3, 5)),
            macos: Versions(max: Version(11, 12, 13)),
          ),
        ).dartDoc,
        '''
iOS: introduced 1.2.3, deprecated 4.5.6, obsoleted 7.8.9
macOS: deprecated 10.11.12''');

    expect(
        ApiAvailability(
          ios: PlatformAvailability(
            name: 'iOS',
            introduced: Version(1, 2, 3),
            obsoleted: Version(4, 5, 6),
          ),
          externalVersions:
              ExternalVersions(ios: Versions(max: Version(2, 3, 4))),
        ).dartDoc,
        'iOS: introduced 1.2.3, obsoleted 4.5.6');

    expect(
        ApiAvailability(
          ios: PlatformAvailability(
            name: 'macOS',
            unavailable: true,
          ),
          externalVersions: ExternalVersions(
              ios: Versions(max: Version(1, 2, 3)),
              macos: Versions(max: Version(2, 3, 4))),
        ).dartDoc,
        'macOS: unavailable');

    expect(
        ApiAvailability(externalVersions: ExternalVersions(ios: Versions()))
            .dartDoc,
        isNull);
  });
}
