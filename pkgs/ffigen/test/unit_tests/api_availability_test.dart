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

  group('API availability', () {
    test('empty', () {
      final api = ApiAvailability();

      expect(api.getAvailability(const ExternalVersions()), Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.all);
    });

    test('always deprecated', () {
      final api = ApiAvailability(alwaysDeprecated: true);

      expect(api.getAvailability(const ExternalVersions()), Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.none);
    });

    test('always unavailable', () {
      final api = ApiAvailability(alwaysUnavailable: true);

      expect(api.getAvailability(const ExternalVersions()), Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
            macos: Versions(min: Version(1, 2, 3), max: Version(4, 5, 6)),
          )),
          Availability.none);
    });

    test('ios', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          introduced: Version(1, 2, 3),
          deprecated: Version(4, 5, 6),
          obsoleted: Version(7, 8, 9),
        ),
      );

      expect(api.getAvailability(const ExternalVersions()), Availability.all);

      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(5, 0, 0)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.none);

      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);

      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(5, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
    });

    test('ios, empty PlatformAvailability', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(),
      );

      expect(api.getAvailability(const ExternalVersions()), Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
    });

    test('ios, unavailable', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          unavailable: true,
        ),
      );

      expect(api.getAvailability(const ExternalVersions()), Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
    });

    test('macos', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(
          introduced: Version(1, 2, 3),
          deprecated: Version(4, 5, 6),
          obsoleted: Version(7, 8, 9),
        ),
      );

      expect(api.getAvailability(const ExternalVersions()), Availability.all);

      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(1, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(5, 0, 0)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.none);

      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);

      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(1, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(5, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
    });

    test('macos, empty PlatformAvailability', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(),
      );

      expect(api.getAvailability(const ExternalVersions()), Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
    });

    test('macos, unavailable', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(
          unavailable: true,
        ),
      );

      expect(api.getAvailability(const ExternalVersions()), Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
    });

    test('both', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          introduced: Version(1, 2, 3),
          deprecated: Version(4, 5, 6),
          obsoleted: Version(7, 8, 9),
        ),
        macos: PlatformAvailability(
          introduced: Version(2, 3, 4),
          deprecated: Version(5, 6, 7),
          obsoleted: Version(8, 9, 10),
        ),
      );

      expect(
          api.getAvailability(const ExternalVersions(
            ios: null,
            macos: null,
          )),
          Availability.all);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: null,
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: null,
          )),
          Availability.none);

      expect(
          api.getAvailability(ExternalVersions(
            ios: null,
            macos: Versions(min: Version(1, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: Versions(min: Version(1, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(1, 0, 0)),
          )),
          Availability.some);

      expect(
          api.getAvailability(ExternalVersions(
            ios: null,
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.none);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.some);
      expect(
          api.getAvailability(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          Availability.none);
    });
  });
}
