// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'test_case.dart';

/// Example:
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
/// ```
class TestCaseSelector {
  /// Maps a Type (representing a dimension like `Architecture`) to a list of
  /// possible values for that dimension.
  final Map<Type, List<Object>> dimensions;

  /// A list of sets of Types.
  ///
  /// Each set defines a group of dimensions where every pair of values between
  /// those dimensions must be covered at least once in the selected suite.
  final List<Set<Type>> interactionGroups;

  /// An optional predicate to filter out invalid combinations.
  ///
  /// The selector will ensure that every [TestCase] in the resulting
  /// suite satisfies this predicate.
  final bool Function(TestCase)? isValid;

  /// The dimension types in the order they were provided in the [dimensions]
  /// map.
  final List<Type> _displayDimensionTypes;

  /// The dimension types sorted alphabetically to ensure deterministic
  /// requirement ordering.
  final List<Type> _dimensionTypes;

  /// Creates a selector with the provided [dimensions] and [interactionGroups].
  TestCaseSelector({
    required this.dimensions,
    required this.interactionGroups,
    this.isValid,
  }) : _displayDimensionTypes = dimensions.keys.toList(),
       _dimensionTypes =
           dimensions.keys.toList()
             ..sort((a, b) => a.toString().compareTo(b.toString()));

  List<Type> get displayDimensionTypes => _displayDimensionTypes;

  /// Selects a list of [TestCase]s based on the provided [dimensions],
  /// [interactionGroups], and [isValid] predicate.
  List<TestCase> select() {
    final requirementsList = <int>[];
    final requirementsSet = <int>{};

    void addRequirement(int req) {
      if (requirementsSet.add(req)) {
        requirementsList.add(req);
      }
    }

    // Sort interaction groups to ensure deterministic requirement ordering.
    final sortedInteractionGroups =
        interactionGroups.map((group) {
          final sortedGroup = group.toList();
          sortedGroup.sort((a, b) => a.toString().compareTo(b.toString()));
          return sortedGroup;
        }).toList();
    sortedInteractionGroups.sort((a, b) => a.join(',').compareTo(b.join(',')));

    // 1. Identify all pairs that need to be covered based on interaction
    // groups.
    for (final groupTypes in sortedInteractionGroups) {
      for (var i = 0; i < groupTypes.length; i++) {
        for (var j = i + 1; j < groupTypes.length; j++) {
          final type1 = groupTypes[i];
          final type2 = groupTypes[j];
          final dim1 = _dimensionTypes.indexOf(type1);
          final dim2 = _dimensionTypes.indexOf(type2);
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
    for (var d = 0; d < _dimensionTypes.length; d++) {
      final values = dimensions[_dimensionTypes[d]]!;
      for (var v = 0; v < values.length; v++) {
        addRequirement(_valueRequirement(d, v));
      }
    }

    final testSuite = <TestCase>[];
    final random = _StableRandom(42); // Seeded for reproducibility.

    // 3. Greedily build configurations until all requirements are covered.
    while (requirementsSet.isNotEmpty) {
      Map<int, int>? bestCandidate;
      var bestCandidateScore = -1;

      // Try a few different starting candidates and pick the one that results
      // in the best coverage.
      for (var attempt = 0; attempt < 50; attempt++) {
        final candidate = <int, int>{};
        for (var d = 0; d < _dimensionTypes.length; d++) {
          final numValues = dimensions[_dimensionTypes[d]]!.length;
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
        if (isValid != null && !isValid!(TestCase(_toValues(candidate)))) {
          _nudgeToValid(candidate, _dimensionTypes.length);
        }

        // If it's still invalid after nudging, skip this attempt.
        if (isValid != null && !isValid!(TestCase(_toValues(candidate)))) {
          continue;
        }

        // Hill-climbing approach to improve the candidate.
        var improved = true;
        while (improved) {
          improved = false;
          for (var d = 0; d < _dimensionTypes.length; d++) {
            final numValues = dimensions[_dimensionTypes[d]]!.length;
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
                  isValid == null || isValid!(TestCase(_toValues(candidate)));
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
        testSuite.add(TestCase(_toValues(bestCandidate)));
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

  /// Attempts to find a valid configuration by changing one dimension at a
  /// time.
  void _nudgeToValid(Map<int, int> candidate, int numDimensions) {
    if (isValid == null) return;
    for (var d = 0; d < numDimensions; d++) {
      final numValues = dimensions[_dimensionTypes[d]]!.length;
      for (var v = 0; v < numValues; v++) {
        final originalVal = candidate[d]!;
        candidate[d] = v;
        if (isValid!(TestCase(_toValues(candidate)))) return;
        candidate[d] = originalVal;
      }
    }
  }

  Map<Type, Object> _toValues(Map<int, int> candidate) {
    final values = <Type, Object>{};
    candidate.forEach((dimIndex, valIndex) {
      final type = _dimensionTypes[dimIndex];
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
