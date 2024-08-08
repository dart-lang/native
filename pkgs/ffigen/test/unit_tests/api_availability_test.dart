// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/sub_parsers/objcinterfacedecl_parser.dart';
import 'package:test/test.dart';

void main() {
  group('API availability', () {
    test('empty', () {
      final api = ApiAvailability();

      expect(api.isAvailable(const ObjCTargetVersion()), true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1, 2, 3),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(1, 2, 3),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1, 2, 3),
            macos: VersionTriple(1, 2, 3),
          )),
          true);
    });

    test('always deprecated', () {
      final api = ApiAvailability(alwaysDeprecated: true);

      expect(api.isAvailable(const ObjCTargetVersion()), false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1, 2, 3),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(1, 2, 3),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1, 2, 3),
            macos: VersionTriple(1, 2, 3),
          )),
          false);
    });

    test('always unavailable', () {
      final api = ApiAvailability(alwaysUnavailable: true);

      expect(api.isAvailable(const ObjCTargetVersion()), false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1, 2, 3),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(1, 2, 3),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1, 2, 3),
            macos: VersionTriple(1, 2, 3),
          )),
          false);
    });

    test('ios', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          introduced: const VersionTriple(1, 2, 3),
          deprecated: const VersionTriple(4, 5, 6),
          obsoleted: const VersionTriple(7, 8, 9),
        ),
      );

      expect(api.isAvailable(const ObjCTargetVersion()), true);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(5),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
          )),
          false);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
          )),
          true);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1),
            macos: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(5),
            macos: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
            macos: VersionTriple(10),
          )),
          true);
    });

    test('ios, empty PlatformAvailability', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(),
      );

      expect(api.isAvailable(const ObjCTargetVersion()), true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
            macos: VersionTriple(10),
          )),
          true);
    });

    test('ios, unavailable', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          unavailable: true,
        ),
      );

      expect(api.isAvailable(const ObjCTargetVersion()), true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
            macos: VersionTriple(10),
          )),
          true);
    });

    test('macos', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(
          introduced: const VersionTriple(1, 2, 3),
          deprecated: const VersionTriple(4, 5, 6),
          obsoleted: const VersionTriple(7, 8, 9),
        ),
      );

      expect(api.isAvailable(const ObjCTargetVersion()), true);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(1),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(5),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
          )),
          false);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
          )),
          true);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(1),
            ios: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(5),
            ios: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
            ios: VersionTriple(10),
          )),
          true);
    });

    test('macos, empty PlatformAvailability', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(),
      );

      expect(api.isAvailable(const ObjCTargetVersion()), true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
            ios: VersionTriple(10),
          )),
          true);
    });

    test('macos, unavailable', () {
      final api = ApiAvailability(
        macos: PlatformAvailability(
          unavailable: true,
        ),
      );

      expect(api.isAvailable(const ObjCTargetVersion()), true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            macos: VersionTriple(10),
            ios: VersionTriple(10),
          )),
          true);
    });

    test('both', () {
      final api = ApiAvailability(
        ios: PlatformAvailability(
          introduced: const VersionTriple(1, 2, 3),
          deprecated: const VersionTriple(4, 5, 6),
          obsoleted: const VersionTriple(7, 8, 9),
        ),
        macos: PlatformAvailability(
          introduced: const VersionTriple(2, 3, 4),
          deprecated: const VersionTriple(5, 6, 7),
          obsoleted: const VersionTriple(8, 9, 10),
        ),
      );

      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: null,
            macos: null,
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1),
            macos: null,
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
            macos: null,
          )),
          false);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: null,
            macos: VersionTriple(1),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1),
            macos: VersionTriple(1),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
            macos: VersionTriple(1),
          )),
          true);

      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: null,
            macos: VersionTriple(10),
          )),
          false);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(1),
            macos: VersionTriple(10),
          )),
          true);
      expect(
          api.isAvailable(const ObjCTargetVersion(
            ios: VersionTriple(10),
            macos: VersionTriple(10),
          )),
          false);
    });
  });
}
