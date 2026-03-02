// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A utility for generating a minimized suite of test configurations that
/// ensures specific interactions between different test dimensions are covered.
///
/// This implements a greedy algorithm for "interaction pairs" (pairwise
/// testing) to reduce the total number of tests while maintaining high
/// confidence.
library;

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:test/test.dart';

/// A single generated test configuration.
///
/// Provides type-safe access to values for each dimension via [get].
///
/// Example:
/// ```dart
/// final arch = config.get<Architecture>();
/// final mode = config.get<LinkMode>();
/// ```
class TestConfiguration {
  final Map<Type, Object> _values;

  TestConfiguration(this._values);

  /// Returns the value for a specific dimension type [T].
  ///
  /// Throws an [ArgumentError] if the type is not present in the configuration.
  T get<T>() {
    final value = _values[T];
    if (value == null) {
      throw ArgumentError('Dimension type $T not found in this configuration.');
    }
    return value as T;
  }

  @override
  String toString() => _values.entries
      .map((e) => '${e.key.toString().split('.').last}: ${e.value}')
      .join(', ');
}

/// Generator for test configurations that ensures coverage of interaction
/// pairs.
///
/// For pairwise testing see https://en.wikipedia.org/wiki/All-pairs_testing.
///
/// This specific implementation follows "Variable Strength Covering Array".
///
/// Example:
/// ```dart
/// final generator = TestConfigurationGenerator(
///   dimensions: {
///     Architecture: Architecture.values,
///     LinkMode: [StaticLinking(), DynamicLoadingBundled()],
///     OptimizationLevel: OptimizationLevel.values,
///   },
///   interactionGroups: [
///     {Architecture, LinkMode},
///     {LinkMode, OptimizationLevel},
///   ],
///   isValid: (config) {
///     // iOS on x64 is only valid for the simulator.
///     if (config.get<IOSSdk>() == IOSSdk.iPhoneOS &&
///         config.get<Architecture>() == Architecture.x64) {
///       return false;
///     }
///     return true;
///   },
/// );
/// final configurations = generator.generateAndValidate(
///   tableUri: packageUri.resolve('test/my_test.md'),
/// );
/// ```
class TestConfigurationGenerator {
  /// Maps a Type (representing a dimension like `Architecture`) to a list of
  /// possible values for that dimension.
  final Map<Type, List<Object>> dimensions;

  /// A list of sets of Types.
  ///
  /// Each set defines a group of dimensions where every pair of values between
  /// those dimensions must be covered at least once in the generated suite.
  final List<Set<Type>> interactionGroups;

  /// An optional predicate to filter out invalid combinations.
  ///
  /// The generator will ensure that every [TestConfiguration] in the resulting
  /// suite satisfies this predicate.
  final bool Function(TestConfiguration)? isValid;

  /// Creates a generator with the provided [dimensions] and
  /// [interactionGroups].
  TestConfigurationGenerator({
    required this.dimensions,
    required this.interactionGroups,
    this.isValid,
  });

  /// Generates a list of [TestConfiguration]s based on the provided
  /// [dimensions], [interactionGroups], and [isValid] predicate.
  @visibleForTesting
  List<TestConfiguration> generate() {
    final dimensionTypes = dimensions.keys.toList();
    final requirementsList = <int>[];
    final requirementsSet = <int>{};

    void addRequirement(int req) {
      if (requirementsSet.add(req)) {
        requirementsList.add(req);
      }
    }

    // 1. Identify all pairs that need to be covered based on interaction
    // groups.
    for (final group in interactionGroups) {
      final groupTypes = group.toList();
      for (var i = 0; i < groupTypes.length; i++) {
        for (var j = i + 1; j < groupTypes.length; j++) {
          final type1 = groupTypes[i];
          final type2 = groupTypes[j];
          final dim1 = dimensionTypes.indexOf(type1);
          final dim2 = dimensionTypes.indexOf(type2);
          final values1 = dimensions[type1]!;
          final values2 = dimensions[type2]!;
          for (var v1 = 0; v1 < values1.length; v1++) {
            for (var v2 = 0; v2 < values2.length; v2++) {
              addRequirement(_pairRequirement(dim1, v1, dim2, v2));
            }
          }
        }
      }
    }

    // 2. Ensure all individual values are covered at least once.
    for (var d = 0; d < dimensionTypes.length; d++) {
      final values = dimensions[dimensionTypes[d]]!;
      for (var v = 0; v < values.length; v++) {
        addRequirement(_valueRequirement(d, v));
      }
    }

    final testSuite = <TestConfiguration>[];
    final random = _StableRandom(42); // Seeded for reproducibility.

    // 3. Greedily build configurations until all requirements are covered.
    while (requirementsSet.isNotEmpty) {
      Map<int, int>? bestCandidate;
      var bestCandidateScore = -1;

      // Try a few different starting candidates and pick the one that results
      // in the best coverage.
      for (var attempt = 0; attempt < 50; attempt++) {
        final candidate = <int, int>{};
        for (var d = 0; d < dimensionTypes.length; d++) {
          final numValues = dimensions[dimensionTypes[d]]!.length;
          if (attempt == 0) {
            // First attempt: try a random value for each dimension.
            candidate[d] = random.nextInt(numValues);
          } else {
            // Other attempts: prioritize dimensions that have uncovered values.
            final uncoveredForDim = <int>[];
            for (var v = 0; v < numValues; v++) {
              if (requirementsSet.contains(_valueRequirement(d, v))) {
                uncoveredForDim.add(v);
              }
            }

            if (uncoveredForDim.isNotEmpty) {
              candidate[d] =
                  uncoveredForDim[random.nextInt(uncoveredForDim.length)];
            } else {
              candidate[d] = random.nextInt(numValues);
            }
          }
        }

        // If the starting point is invalid, try to nudge it towards validity.
        if (isValid != null &&
            !isValid!(TestConfiguration(_toValues(candidate)))) {
          _nudgeToValid(candidate, dimensionTypes.length);
        }

        // If it's still invalid after nudging, skip this attempt.
        if (isValid != null &&
            !isValid!(TestConfiguration(_toValues(candidate)))) {
          continue;
        }

        // Hill-climbing approach to improve the candidate.
        var improved = true;
        while (improved) {
          improved = false;
          for (var d = 0; d < dimensionTypes.length; d++) {
            final numValues = dimensions[dimensionTypes[d]]!.length;
            var bestVal = candidate[d]!;
            var maxScore = _calculateScore(
              candidate,
              d,
              bestVal,
              requirementsSet,
            );

            for (var v = 0; v < numValues; v++) {
              if (v == candidate[d]) continue;

              // Check if changing this dimension would make the configuration
              // invalid.
              final originalVal = candidate[d]!;
              candidate[d] = v;
              final valid =
                  isValid == null ||
                  isValid!(TestConfiguration(_toValues(candidate)));
              if (!valid) {
                candidate[d] = originalVal;
                continue;
              }

              final score = _calculateScore(candidate, d, v, requirementsSet);
              if (score > maxScore) {
                maxScore = score;
                bestVal = v;
                improved = true;
              } else {
                candidate[d] = originalVal;
              }
            }
            candidate[d] = bestVal;
          }
        }

        final score = _calculateTotalCoverageScore(candidate, requirementsSet);
        if (score > bestCandidateScore) {
          bestCandidateScore = score;
          bestCandidate = Map.of(candidate);
        }
      }

      if (bestCandidate != null && bestCandidateScore > 0) {
        testSuite.add(TestConfiguration(_toValues(bestCandidate)));
        _markCovered(requirementsSet, requirementsList, bestCandidate);
      } else {
        // If we can't cover anything new, we might be trying to cover
        // impossible pairs or values.
        // Try to identify one and remove it.
        final first = requirementsList.first;
        requirementsSet.remove(first);
        requirementsList.removeAt(0);
      }

      // Circuit breaker to prevent infinite loops in case of logic errors.
      if (testSuite.length > 1000) break;
    }

    return testSuite;
  }

  static const _regenerateEnvVar = 'REGENERATE_TEST_CONFIGS';

  /// Generates configurations and ensures the Markdown table at [tableUri] is
  /// up-to-date.
  ///
  /// If [update] is true, the table is written to [tableUri].
  /// If [update] is false, an error is thrown if the table is not up-to-date.
  /// If [update] is null (default), it checks the REGENERATE_TEST_CONFIGS
  /// environment variable.
  List<TestConfiguration> generateAndValidate({
    required Uri tableUri,
    Map<Type, String>? headers,
    bool? update,
  }) {
    final configurations = generate();
    final newTable = _generateMarkdownTable(configurations, headers: headers);
    final file = File.fromUri(tableUri);

    final shouldUpdate =
        update ?? Platform.environment[_regenerateEnvVar] == 'true';

    if (shouldUpdate) {
      file.writeAsStringSync(newTable);
    } else {
      test('Test configuration table up-to-date', () {
        expect(
          file.existsSync() ? file.readAsStringSync() : '',
          newTable,
          reason:
              'The test configurations table at $tableUri is not up-to-date. '
              'Please run the tests with $_regenerateEnvVar=true to regenerate'
              ' it.',
        );
      });
    }

    return configurations;
  }

  /// Generates a Markdown table representing the [configurations].
  String _generateMarkdownTable(
    List<TestConfiguration> configurations, {
    Map<Type, String>? headers,
  }) {
    if (configurations.isEmpty) return '';

    final types = dimensions.keys.toList();

    // 1. Gather all strings for the table.
    final headerStrings = [
      '#',
      ...types.map((t) {
        if (headers != null && headers.containsKey(t)) {
          return headers[t]!;
        }
        // Default: split CamelCase into spaces (e.g., AndroidApiLevel ->
        // Android Api Level).
        return t
            .toString()
            .split('.')
            .last
            .replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'),
              (match) => '${match.group(1)} ${match.group(2)}',
            );
      }),
    ];
    final rowStrings = configurations
        .map(
          (config) => types.map((t) => config._values[t]!.toString()).toList(),
        )
        .toList();

    // 2. Sort rows alphabetically based on the first column.
    rowStrings.sort((a, b) {
      for (var i = 0; i < a.length; i++) {
        final cmp = a[i].compareTo(b[i]);
        if (cmp != 0) return cmp;
      }
      return 0;
    });

    // 3. Add numbering.
    for (var i = 0; i < rowStrings.length; i++) {
      rowStrings[i].insert(0, (i + 1).toString());
    }

    // 4. Calculate max width for each column.
    final numColumns = types.length + 1;
    final columnWidths = List<int>.filled(numColumns, 0);
    for (var i = 0; i < numColumns; i++) {
      columnWidths[i] = headerStrings[i].length;
      for (final row in rowStrings) {
        if (row[i].length > columnWidths[i]) {
          columnWidths[i] = row[i].length;
        }
      }
      // Ensure a minimum width for the separator (---)
      if (columnWidths[i] < 3) columnWidths[i] = 3;
    }

    // 5. Format rows with padding.
    String formatRow(List<String> cells) {
      final paddedCells = <String>[];
      for (var i = 0; i < cells.length; i++) {
        paddedCells.add(cells[i].padRight(columnWidths[i]));
      }
      return '| ${paddedCells.join(' | ')} |';
    }

    final header = formatRow(headerStrings);
    final separator = formatRow(
      List<String>.filled(
        numColumns,
        '---',
      ).map((s) => s.substring(0, 3)).toList(),
    ).replaceAll(' ', '-'); // Make separator look like | --- | --- |

    final rows = rowStrings.map(formatRow);

    return [
      'This file is generated. To regenerate, run:',
      '`$_regenerateEnvVar=true dart test`',
      '',
      header,
      separator,
      ...rows,
    ].join('\n');
  }

  /// Attempts to find a valid configuration by changing one dimension at a
  /// time.
  void _nudgeToValid(Map<int, int> candidate, int numDimensions) {
    if (isValid == null) return;
    for (var d = 0; d < numDimensions; d++) {
      final numValues = dimensions[dimensions.keys.elementAt(d)]!.length;
      for (var v = 0; v < numValues; v++) {
        final originalVal = candidate[d]!;
        candidate[d] = v;
        if (isValid!(TestConfiguration(_toValues(candidate)))) return;
        candidate[d] = originalVal;
      }
    }
  }

  Map<Type, Object> _toValues(Map<int, int> candidate) {
    final values = <Type, Object>{};
    candidate.forEach((dimIndex, valIndex) {
      final type = dimensions.keys.elementAt(dimIndex);
      values[type] = dimensions[type]![valIndex];
    });
    return values;
  }

  static int _calculateTotalCoverageScore(
    Map<int, int> candidate,
    Set<int> requirements,
  ) {
    var score = 0;
    candidate.forEach((d, v) {
      if (requirements.contains(_valueRequirement(d, v))) {
        score += 1;
      }
    });

    final dims = candidate.keys.toList();
    for (var i = 0; i < dims.length; i++) {
      for (var j = i + 1; j < dims.length; j++) {
        final d1 = dims[i];
        final d2 = dims[j];
        if (requirements.contains(
          _pairRequirement(d1, candidate[d1]!, d2, candidate[d2]!),
        )) {
          score += 100;
        }
      }
    }
    return score;
  }

  static int _calculateScore(
    Map<int, int> candidate,
    int dimChanged,
    int newVal,
    Set<int> requirements,
  ) {
    var score = 0;

    // Reward covering a new individual value.
    if (requirements.contains(_valueRequirement(dimChanged, newVal))) {
      score += 1;
    }

    // Reward covering new pairs.
    candidate.forEach((d, v) {
      if (d == dimChanged) return;
      if (requirements.contains(_pairRequirement(dimChanged, newVal, d, v))) {
        score += 100;
      }
    });
    return score;
  }

  // Packs (dimIndex, valIndex) into 31 bits.
  static int _pack(int dim, int val) => (dim << 15) | val;

  // Packed value requirement (size 1). Bit 62 is 0.
  static int _valueRequirement(int dim, int val) => _pack(dim, val);

  // Packed pair requirement (size 2). Bit 62 is 1.
  static int _pairRequirement(int dim1, int val1, int dim2, int val2) {
    final v1 = _pack(dim1, val1);
    final v2 = _pack(dim2, val2);
    final low = v1 < v2 ? v1 : v2;
    final high = v1 < v2 ? v2 : v1;
    return (1 << 62) | (low << 31) | high;
  }

  static void _markCovered(
    Set<int> requirementsSet,
    List<int> requirementsList,
    Map<int, int> candidate,
  ) {
    void remove(int req) {
      if (requirementsSet.remove(req)) {
        requirementsList.remove(req);
      }
    }

    candidate.forEach((d, v) {
      remove(_valueRequirement(d, v));
    });

    final dims = candidate.keys.toList();
    for (var i = 0; i < dims.length; i++) {
      for (var j = i + 1; j < dims.length; j++) {
        remove(
          _pairRequirement(
            dims[i],
            candidate[dims[i]]!,
            dims[j],
            candidate[dims[j]]!,
          ),
        );
      }
    }
  }
}

/// A simple linear congruential generator for stable random numbers.
class _StableRandom {
  int _state;

  _StableRandom(this._state);

  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7FFFFFFF;
    return (_state >> 16) % max;
  }
}
