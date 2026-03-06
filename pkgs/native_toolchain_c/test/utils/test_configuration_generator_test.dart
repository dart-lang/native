// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import 'test_configuration_generator.dart';

void main() {
  group('TestConfigurationGenerator', () {
    test('covers all values and specified interaction pairs', () {
      final architectures = [
        Architecture.arm,
        Architecture.arm64,
        Architecture.x64,
      ];
      const optimizationLevels = OptimizationLevel.values;

      final configurations = TestConfigurationGenerator(
        dimensions: {
          Architecture: architectures,
          OptimizationLevel: optimizationLevels,
        },
        interactionGroups: [
          {Architecture, OptimizationLevel},
        ],
      ).generate();

      // Verify all individual values are covered.
      for (final arch in architectures) {
        expect(
          configurations.any((c) => c.get<Architecture>() == arch),
          isTrue,
          reason: 'Architecture $arch should be covered',
        );
      }
      for (final level in optimizationLevels) {
        expect(
          configurations.any((c) => c.get<OptimizationLevel>() == level),
          isTrue,
          reason: 'OptimizationLevel $level should be covered',
        );
      }

      // Verify all interaction pairs are covered.
      for (final arch in architectures) {
        for (final level in optimizationLevels) {
          expect(
            configurations.any(
              (c) =>
                  c.get<Architecture>() == arch &&
                  c.get<OptimizationLevel>() == level,
            ),
            isTrue,
            reason: 'Pair ($arch, $level) should be covered',
          );
        }
      }

      // Since we requested a full cartesian product for the only group,
      // it should match the size (3 architectures * 6 optimization levels).
      expect(configurations.length, 18);
    });

    test('reduces configurations when interaction groups are partial', () {
      final configurations = TestConfigurationGenerator(
        dimensions: {
          Architecture: [
            Architecture.arm,
            Architecture.arm64,
            Architecture.x64,
          ],
          OptimizationLevel: OptimizationLevel.values,
          OS: [OS.android, OS.iOS, OS.linux],
        },
        interactionGroups: [
          {Architecture, OptimizationLevel},
          {Architecture, OS},
        ],
      ).generate();

      // Verify all interaction pairs from the first group are covered.
      for (final arch in [
        Architecture.arm,
        Architecture.arm64,
        Architecture.x64,
      ]) {
        for (final level in OptimizationLevel.values) {
          expect(
            configurations.any(
              (c) =>
                  c.get<Architecture>() == arch &&
                  c.get<OptimizationLevel>() == level,
            ),
            isTrue,
          );
        }
      }

      // Verify all interaction pairs from the second group are covered.
      for (final arch in [
        Architecture.arm,
        Architecture.arm64,
        Architecture.x64,
      ]) {
        for (final os in [OS.android, OS.iOS, OS.linux]) {
          expect(
            configurations.any(
              (c) => c.get<Architecture>() == arch && c.get<OS>() == os,
            ),
            isTrue,
          );
        }
      }

      // The full product would be 3 * 6 * 3 = 54.
      // Pairwise should be much less.
      expect(configurations.length, lessThan(54));
      // At minimum it should cover the largest group
      // (Architecture x OptimizationLevel = 18).
      expect(configurations.length, greaterThanOrEqualTo(18));
    });

    test('respects isValid predicate', () {
      final configurations = TestConfigurationGenerator(
        dimensions: {
          Architecture: [Architecture.arm64, Architecture.x64],
          OS: [OS.android, OS.iOS],
        },
        interactionGroups: [
          {Architecture, OS},
        ],
        isValid: (config) {
          // Say x64 is only valid on iOS.
          if (config.get<Architecture>() == Architecture.x64 &&
              config.get<OS>() == OS.android) {
            return false;
          }
          return true;
        },
      ).generate();

      expect(configurations, isNotEmpty);
      for (final config in configurations) {
        final arch = config.get<Architecture>();
        final os = config.get<OS>();
        if (arch == Architecture.x64) {
          expect(os, OS.iOS);
        }
      }
      // Should cover (arm64, android), (arm64, iOS), (x64, iOS).
      // (x64, android) is skipped because it's invalid.
      expect(configurations.length, 3);
    });

    test('throws ArgumentError for missing types', () {
      final configurations = TestConfigurationGenerator(
        dimensions: {
          Architecture: [Architecture.arm],
        },
        interactionGroups: [],
      ).generate();

      expect(() => configurations.first.get<int>(), throwsArgumentError);
    });
  });
}
