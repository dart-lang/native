// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  group('API availability', () {
    test('empty', () {
      final api = ApiAvailability();

      expect(api.isAvailable(const ExternalVersions()), true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(1, 2, 3)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3)),
            macos: Versions(min: Version(1, 2, 3)),
          )),
          true);
    });

    test('always deprecated', () {
      final api = ApiAvailability(alwaysDeprecated: true);

      expect(api.isAvailable(const ExternalVersions()), true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(1, 2, 3)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3)),
            macos: Versions(min: Version(1, 2, 3)),
          )),
          false);
    });

    test('always unavailable', () {
      final api = ApiAvailability(alwaysUnavailable: true);

      expect(api.isAvailable(const ExternalVersions()), true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(1, 2, 3)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 2, 3)),
            macos: Versions(min: Version(1, 2, 3)),
          )),
          false);
    });

    test('ios', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          introduced: Version(1, 2, 3),
          deprecated: Version(4, 5, 6),
          obsoleted: Version(7, 8, 9),
        ),
      );

      expect(api.isAvailable(const ExternalVersions()), true);

      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(5, 0, 0)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          false);

      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);

      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(5, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
    });

    test('ios, empty PlatformAvailability', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(),
      );

      expect(api.isAvailable(const ExternalVersions()), true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
    });

    test('ios, unavailable', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          unavailable: true,
        ),
      );

      expect(api.isAvailable(const ExternalVersions()), true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
    });

    test('macos', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(
          introduced: Version(1, 2, 3),
          deprecated: Version(4, 5, 6),
          obsoleted: Version(7, 8, 9),
        ),
      );

      expect(api.isAvailable(const ExternalVersions()), true);

      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(1, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(5, 0, 0)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          false);

      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);

      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(1, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(5, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
    });

    test('macos, empty PlatformAvailability', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(),
      );

      expect(api.isAvailable(const ExternalVersions()), true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
    });

    test('macos, unavailable', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(
          unavailable: true,
        ),
      );

      expect(api.isAvailable(const ExternalVersions()), true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            macos: Versions(min: Version(10, 0, 0)),
            ios: Versions(min: Version(10, 0, 0)),
          )),
          true);
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
          api.isAvailable(const ExternalVersions(
            ios: null,
            macos: null,
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: null,
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: null,
          )),
          false);

      expect(
          api.isAvailable(ExternalVersions(
            ios: null,
            macos: Versions(min: Version(1, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: Versions(min: Version(1, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(1, 0, 0)),
          )),
          true);

      expect(
          api.isAvailable(ExternalVersions(
            ios: null,
            macos: Versions(min: Version(10, 0, 0)),
          )),
          false);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(1, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          true);
      expect(
          api.isAvailable(ExternalVersions(
            ios: Versions(min: Version(10, 0, 0)),
            macos: Versions(min: Version(10, 0, 0)),
          )),
          false);
    });
  });
}
