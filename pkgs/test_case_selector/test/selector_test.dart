// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_case_selector/test_case_selector.dart';

enum VehicleType { bicycle, motorcycle, car, semiTruck }

enum PaintColor { crimsonRed, stealthBlack, arcticWhite }

enum WeightClass { ultraLight, light, medium, heavy }

void main() {
  group('TestCaseSelector (Vehicle Configurator)', () {
    test('covers all colors and vehicle types', () {
      final vehicles = VehicleType.values;
      final colors = PaintColor.values;

      final configurations =
          TestCaseSelector(
            dimensions: {
              VehicleType: vehicles,
              PaintColor: colors,
            },
            interactionGroups: [
              {VehicleType, PaintColor},
            ],
          ).select();

      // Verify all individual values are covered.
      for (final v in vehicles) {
        expect(configurations.any((tc) => tc.get<VehicleType>() == v), isTrue);
      }
      for (final c in colors) {
        expect(configurations.any((tc) => tc.get<PaintColor>() == c), isTrue);
      }

      // Verify all interaction pairs (Cartesian product since it's one group).
      for (final v in vehicles) {
        for (final c in colors) {
          expect(
            configurations.any(
              (tc) => tc.get<VehicleType>() == v && tc.get<PaintColor>() == c,
            ),
            isTrue,
          );
        }
      }

      expect(configurations.length, 12); // 4 types * 3 colors
    });

    test('reduces configurations with multiple interaction groups', () {
      final configurations =
          TestCaseSelector(
            dimensions: {
              VehicleType: VehicleType.values,
              PaintColor: PaintColor.values,
              WeightClass: WeightClass.values,
            },
            interactionGroups: [
              {VehicleType, WeightClass},
              {VehicleType, PaintColor},
            ],
          ).select();

      // Verify interaction pairs from both groups are covered.
      for (final v in VehicleType.values) {
        for (final w in WeightClass.values) {
          expect(
            configurations.any(
              (c) => c.get<VehicleType>() == v && c.get<WeightClass>() == w,
            ),
            isTrue,
          );
        }
        for (final p in PaintColor.values) {
          expect(
            configurations.any(
              (c) => c.get<VehicleType>() == v && c.get<PaintColor>() == p,
            ),
            isTrue,
          );
        }
      }

      // Full product: 4 * 3 * 4 = 48.
      // Pairwise should be much lower (around 16).
      expect(configurations.length, lessThan(30));
      expect(configurations.length, greaterThanOrEqualTo(16));
    });

    test('respects vehicle weight constraints (isValid)', () {
      final configurations =
          TestCaseSelector(
            dimensions: {
              VehicleType: VehicleType.values,
              WeightClass: WeightClass.values,
            },
            interactionGroups: [
              {VehicleType, WeightClass},
            ],
            isValid: (tc) {
              final type = tc.get<VehicleType>();
              final weight = tc.get<WeightClass>();

              if (type == VehicleType.bicycle) {
                return weight == WeightClass.ultraLight;
              }
              if (type == VehicleType.semiTruck) {
                return weight == WeightClass.heavy;
              }
              if (type == VehicleType.motorcycle) {
                return weight != WeightClass.heavy;
              }
              return true;
            },
          ).select();

      for (final tc in configurations) {
        final type = tc.get<VehicleType>();
        final weight = tc.get<WeightClass>();

        if (type == VehicleType.bicycle) {
          expect(weight, WeightClass.ultraLight);
        } else if (type == VehicleType.semiTruck) {
          expect(weight, WeightClass.heavy);
        } else if (type == VehicleType.motorcycle) {
          expect(weight, isNot(WeightClass.heavy));
        }
      }
    });
  });
}
