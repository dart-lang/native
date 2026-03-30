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
  /// Each set defines a group of dimensions where every combination of values
  /// between those dimensions must be covered at least once in the selected
  /// suite.
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
    final requirementsList = <_Requirement>[];
    final requirementsSet = <_Requirement>{};

    void addRequirement(_Requirement req) {
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

    final interactionGroupDimIndices =
        sortedInteractionGroups.map((group) {
          return group.map(_dimensionTypes.indexOf).toList();
        }).toList();

    final groupsByDim = <int, List<List<int>>>{};
    for (final dimIndices in interactionGroupDimIndices) {
      for (final d in dimIndices) {
        (groupsByDim[d] ??= []).add(dimIndices);
      }
    }

    // 1. Identify all combinations that need to be covered based on interaction
    // groups.
    for (final dimIndices in interactionGroupDimIndices) {
      final valuesLengths =
          dimIndices
              .map((d) => dimensions[_dimensionTypes[d]]!.length)
              .toList();

      void generate(int index, List<int> currentIndices) {
        if (index == dimIndices.length) {
          final packed = <int>[];
          for (var i = 0; i < dimIndices.length; i++) {
            packed.add(_pack(dimIndices[i], currentIndices[i]));
          }
          addRequirement(_Requirement(packed));
          return;
        }
        for (var v = 0; v < valuesLengths[index]; v++) {
          currentIndices[index] = v;
          generate(index + 1, currentIndices);
        }
      }

      generate(0, List<int>.filled(dimIndices.length, 0));
    }

    // 2. Ensure all individual values are covered at least once.
    for (var d = 0; d < _dimensionTypes.length; d++) {
      final values = dimensions[_dimensionTypes[d]]!;
      for (var v = 0; v < values.length; v++) {
        addRequirement(_Requirement([_pack(d, v)]));
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
              if (requirementsSet.contains(_Requirement([_pack(d, v)]))) {
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
              groupsByDim,
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

              final score = _calculateScore(
                candidate,
                d,
                v,
                requirementsSet,
                groupsByDim,
              );
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

        final score = _calculateTotalCoverageScore(
          candidate,
          requirementsSet,
          interactionGroupDimIndices,
        );
        if (score > bestCandidateScore) {
          bestCandidateScore = score;
          bestCandidate = Map.of(candidate);
        }
      }

      if (bestCandidate != null && bestCandidateScore > 0) {
        testSuite.add(TestCase(_toValues(bestCandidate)));
        _markCovered(
          requirementsSet,
          requirementsList,
          bestCandidate,
          interactionGroupDimIndices,
        );
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

  int _calculateTotalCoverageScore(
    Map<int, int> candidate,
    Set<_Requirement> requirements,
    List<List<int>> interactionGroupDimIndices,
  ) {
    var score = 0;
    candidate.forEach((d, v) {
      if (requirements.contains(_Requirement([_pack(d, v)]))) {
        score += 1;
      }
    });

    for (final dimIndices in interactionGroupDimIndices) {
      final packed = <int>[];
      for (final d in dimIndices) {
        packed.add(_pack(d, candidate[d]!));
      }
      if (requirements.contains(_Requirement(packed))) {
        score += 100;
      }
    }
    return score;
  }

  int _calculateScore(
    Map<int, int> candidate,
    int dimChanged,
    int newVal,
    Set<_Requirement> requirements,
    Map<int, List<List<int>>> groupsByDim,
  ) {
    var score = 0;

    // Reward covering a new individual value.
    if (requirements.contains(_Requirement([_pack(dimChanged, newVal)]))) {
      score += 1;
    }

    // Reward covering new interaction groups.
    final groups = groupsByDim[dimChanged] ?? [];
    for (final group in groups) {
      final packedValues = <int>[];
      for (final d in group) {
        packedValues.add(_pack(d, d == dimChanged ? newVal : candidate[d]!));
      }
      if (requirements.contains(_Requirement(packedValues))) {
        score += 100;
      }
    }
    return score;
  }

  // Packs (dimIndex, valIndex) into 31 bits.
  static int _pack(int dim, int val) {
    assert(dim < (1 << 16));
    assert(val < (1 << 15));
    return (dim << 15) | val;
  }

  void _markCovered(
    Set<_Requirement> requirementsSet,
    List<_Requirement> requirementsList,
    Map<int, int> candidate,
    List<List<int>> interactionGroupDimIndices,
  ) {
    void remove(_Requirement req) {
      if (requirementsSet.remove(req)) {
        requirementsList.remove(req);
      }
    }

    candidate.forEach((d, v) {
      remove(_Requirement([_pack(d, v)]));
    });

    for (final dimIndices in interactionGroupDimIndices) {
      final packedValues = <int>[];
      for (final d in dimIndices) {
        packedValues.add(_pack(d, candidate[d]!));
      }
      remove(_Requirement(packedValues));
    }
  }
}

class _Requirement {
  final List<int> packedValues;
  final int _hashCode;

  _Requirement(this.packedValues) : _hashCode = Object.hashAll(packedValues);

  @override
  bool operator ==(Object other) {
    if (other is! _Requirement) return false;
    final otherPacked = other.packedValues;
    if (packedValues.length != otherPacked.length) return false;
    for (var i = 0; i < packedValues.length; i++) {
      if (packedValues[i] != otherPacked[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => _hashCode;
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
