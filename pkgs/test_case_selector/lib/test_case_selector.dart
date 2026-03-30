// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A utility for selecting a minimized suite of test cases that ensures
/// specific interactions between different test dimensions are covered.
///
/// This implements a greedy algorithm for "interaction pairs" (pairwise
/// testing) to reduce the total number of tests while maintaining high
/// confidence.
///
/// The selected test cases are automatically documented as a Markdown table
/// in a doc comment within the source file.
///
/// Example:
///
/// ```dart
/// enum VehicleType { bicycle, motorcycle, car, semiTruck }
/// enum PaintColor { crimsonRed, stealthBlack, arcticWhite }
/// enum WeightClass { ultraLight, light, medium, heavy }
///
/// /// This comment is generated. To regenerate, run:
/// /// `REGENERATE_TEST_CONFIGS=true dart test`
/// ///
/// /// | #   | Vehicle Type | Paint Color  | Weight Class |
/// /// |-----|--------------|--------------|--------------|
/// /// | 1   | bicycle      | arcticWhite  | ultraLight   |
/// /// | 2   | bicycle      | crimsonRed   | ultraLight   |
/// /// | 3   | bicycle      | stealthBlack | ultraLight   |
/// /// | 4   | motorcycle   | arcticWhite  | light        |
/// /// | 5   | motorcycle   | crimsonRed   | medium       |
/// /// | 6   | semiTruck    | stealthBlack | heavy        |
/// final configurations = TestCaseSelector(
///   dimensions: {
///     VehicleType: VehicleType.values,
///     PaintColor: PaintColor.values,
///     WeightClass: WeightClass.values,
///   },
///   interactionGroups: [
///     {VehicleType, PaintColor},
///     {VehicleType, WeightClass},
///   ],
///   isValid: (tc) {
///     final type = tc.get<VehicleType>();
///     final weight = tc.get<WeightClass>();
///     if (type == VehicleType.bicycle) {
///       return weight == WeightClass.ultraLight;
///     }
///     if (type == VehicleType.semiTruck) return weight == WeightClass.heavy;
///     return true;
///   },
/// ).selectAndValidate(
///   tableUri: packageUri.resolve('test/my_test.dart'),
/// );
///
/// void main() {
///   for (final config in configurations) {
///     final type = config.get<VehicleType>();
///     // ...
///   }
/// }
/// ```
library;

import 'src/markdown_renderer.dart';
import 'src/selector.dart';
import 'src/source_updater.dart';
import 'src/test_case.dart';

export 'src/selector.dart';
export 'src/test_case.dart';

extension TestCaseSelectorExtension on TestCaseSelector {
  /// Selects test cases and ensures the Markdown table in the source file
  /// is up-to-date.
  ///
  /// The [tableUri] must point to the `.dart` file where the `configurations`
  /// assignment is located.
  ///
  /// If the `REGENERATE_TEST_CONFIGS` environment variable is set to `true`,
  /// the file at [tableUri] will be updated with the new table. Otherwise,
  /// a test will be run to ensure the table is up-to-date.
  List<TestCase> selectAndValidate({
    required Uri tableUri,
    bool? update,
  }) {
    final testCases = select();
    final renderer = MarkdownRenderer(
      testCases: testCases,
      dimensionTypes: displayDimensionTypes,
      prefix: '/// ',
    );
    final table = renderer.render();

    SourceUpdater(
      tableUri: tableUri,
      newTable: table,
    ).updateOrValidate(update: update);

    return testCases;
  }
}
