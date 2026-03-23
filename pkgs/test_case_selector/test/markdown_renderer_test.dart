// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_case_selector/src/markdown_renderer.dart';
import 'package:test_case_selector/src/test_case.dart';

class VehicleType {
  final String name;
  VehicleType(this.name);
  @override
  String toString() => name;
  static final bicycle = VehicleType('bicycle');
  static final semiTruck = VehicleType('semiTruck');
}

class PaintColor {
  final String name;
  PaintColor(this.name);
  @override
  String toString() => name;
  static final arcticWhite = PaintColor('arcticWhite');
  static final crimsonRed = PaintColor('crimsonRed');
}

void main() {
  group('MarkdownRenderer', () {
    test('renders a simple table', () {
      final testCases = [
        TestCase({
          VehicleType: VehicleType.bicycle,
          PaintColor: PaintColor.arcticWhite,
        }),
        TestCase({
          VehicleType: VehicleType.semiTruck,
          PaintColor: PaintColor.crimsonRed,
        }),
      ];
      final renderer = MarkdownRenderer(
        testCases: testCases,
        dimensionTypes: [VehicleType, PaintColor],
        prefix: '/// ',
      );

      final output = renderer.render();

      expect(output, contains('| #   | Vehicle Type | Paint Color |'));
      expect(output, contains('|-----|--------------|-------------|'));
      expect(output, contains('| 1   | bicycle      | arcticWhite |'));
      expect(output, contains('| 2   | semiTruck    | crimsonRed  |'));
      expect(output, startsWith('/// This comment is generated.'));
    });
  });
}
