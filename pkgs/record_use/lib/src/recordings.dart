// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:meta/meta.dart';

import 'constant.dart';
import 'definition.dart';
import 'helper.dart';
import 'identifier.dart';
import 'location.dart';
import 'metadata.dart';
import 'reference.dart';
import 'syntax.g.dart';

/// [Recordings] combines recordings of calls and instances with metadata.
///
/// This class acts as the top-level container for recorded usage information.
/// The metadata provides context for the recording, such as version and
/// commentary. The [callsForDefinition] and [instancesForDefinition] store the
/// core data, associating each [Definition] with its corresponding [Reference]
/// details.
///
/// The class uses a normalized JSON format, allowing the reuse of locations and
/// constants across multiple recordings to optimize storage.
class Recordings {
  /// [Metadata] such as the recording protocol version.
  final Metadata metadata;

  /// The collected [CallReference]s for each [Definition].
  final Map<Definition, List<CallReference>> callsForDefinition;

  late final Map<Identifier, List<CallReference>> calls = callsForDefinition
      .map((definition, calls) => MapEntry(definition.identifier, calls));

  /// The collected [InstanceReference]s for each [Definition].
  final Map<Definition, List<InstanceReference>> instancesForDefinition;

  late final Map<Identifier, List<InstanceReference>> instances =
      instancesForDefinition.map(
        (definition, instances) => MapEntry(definition.identifier, instances),
      );

  Recordings({
    required this.metadata,
    required this.callsForDefinition,
    required this.instancesForDefinition,
  });

  /// Decodes a JSON representation into a [Recordings] object.
  ///
  /// The format is specifically designed to reduce redundancy and improve
  /// efficiency. Identifiers and constants are stored in separate tables,
  /// allowing them to be referenced by index in the `recordings` map.
  factory Recordings.fromJson(Map<String, Object?> json) {
    try {
      final syntax = RecordedUsesSyntax.fromJson(json);
      return Recordings._fromSyntax(syntax);
    } on FormatException catch (e) {
      throw FormatException('''
Invalid JSON format for Recordings:
${const JsonEncoder.withIndent('  ').convert(json)}
Error: $e
''');
    }
  }

  factory Recordings._fromSyntax(RecordedUsesSyntax syntax) {
    final constants = <Constant>[];
    for (final constantSyntax in syntax.constants ?? <ConstantSyntax>[]) {
      final constant = ConstantProtected.fromSyntax(constantSyntax, constants);
      if (!constants.contains(constant)) {
        constants.add(constant);
      }
    }

    final locations = <Location>[];
    for (final locationSyntax in syntax.locations ?? <LocationSyntax>[]) {
      final location = LocationProtected.fromSyntax(locationSyntax);
      if (!locations.contains(location)) {
        locations.add(location);
      }
    }

    final callsForDefinition = <Definition, List<CallReference>>{};
    final instancesForDefinition = <Definition, List<InstanceReference>>{};

    for (final recordingSyntax in syntax.recordings ?? <RecordingSyntax>[]) {
      final definition = DefinitionProtected.fromSyntax(
        recordingSyntax.definition,
      );
      if (recordingSyntax.calls case final callSyntaxes?) {
        final callReferences = callSyntaxes
            .map<CallReference>(
              (callSyntax) => CallReferenceProtected.fromSyntax(
                callSyntax,
                constants,
                locations,
              ),
            )
            .toList();
        callsForDefinition[definition] = callReferences;
      }
      if (recordingSyntax.instances case final instanceSyntaxes?) {
        final instanceReferences = instanceSyntaxes
            .map<InstanceReference>(
              (instanceSyntax) => InstanceReferenceProtected.fromSyntax(
                instanceSyntax,
                constants,
                locations,
              ),
            )
            .toList();
        instancesForDefinition[definition] = instanceReferences;
      }
    }

    return Recordings(
      metadata: MetadataProtected.fromSyntax(syntax.metadata),
      callsForDefinition: callsForDefinition,
      instancesForDefinition: instancesForDefinition,
    );
  }

  /// Encodes this object into a JSON representation.
  ///
  /// This method normalizes identifiers and constants for storage efficiency.
  Map<String, Object?> toJson() => _toSyntax().json;

  RecordedUsesSyntax _toSyntax() {
    final constantsIndex = {
      ...callsForDefinition.values
          .expand((calls) => calls)
          .whereType<CallWithArguments>()
          .expand(
            (call) => [
              ...call.positionalArguments,
              ...call.namedArguments.values,
            ],
          )
          .nonNulls,
      ...instancesForDefinition.values
          .expand((instances) => instances)
          .expand(
            (instance) => {
              ...instance.instanceConstant.fields.values,
              instance.instanceConstant,
            },
          ),
    }.flatten().asMapToIndices;

    final locationsIndex = {
      ...callsForDefinition.values
          .expand((calls) => calls)
          .map((call) => call.location)
          .nonNulls,
      ...instancesForDefinition.values
          .expand((instances) => instances)
          .map((instance) => instance.location)
          .nonNulls,
    }.asMapToIndices;

    final recordings = <RecordingSyntax>[];
    if (callsForDefinition.isNotEmpty) {
      recordings.addAll(
        callsForDefinition.entries.map(
          (entry) => RecordingSyntax(
            definition: entry.key.toSyntax(),
            calls: entry.value
                .map((call) => call.toSyntax(constantsIndex, locationsIndex))
                .toList(),
          ),
        ),
      );
    }
    if (instancesForDefinition.isNotEmpty) {
      recordings.addAll(
        instancesForDefinition.entries.map(
          (entry) => RecordingSyntax(
            definition: entry.key.toSyntax(),
            instances: entry.value
                .map(
                  (instance) =>
                      instance.toSyntax(constantsIndex, locationsIndex),
                )
                .toList(),
          ),
        ),
      );
    }

    return RecordedUsesSyntax(
      metadata: metadata.toSyntax(),
      constants: constantsIndex.isEmpty
          ? null
          : constantsIndex.keys
                .map((constant) => constant.toSyntax(constantsIndex))
                .toList(),
      locations: locationsIndex.isEmpty
          ? null
          : locationsIndex.keys.map((location) => location.toSyntax()).toList(),
      recordings: recordings.isEmpty ? null : recordings,
    );
  }

  @override
  bool operator ==(covariant Recordings other) {
    if (identical(this, other)) return true;

    return other.metadata == metadata &&
        deepEquals(other.callsForDefinition, callsForDefinition) &&
        deepEquals(other.instancesForDefinition, instancesForDefinition);
  }

  @override
  int get hashCode => Object.hash(
    metadata.hashCode,
    deepHash(callsForDefinition),
    deepHash(instancesForDefinition),
  );

  /// Compares this set of usages ('actual') with the [expected] set
  /// ('expected') for semantic equality.
  ///
  /// This method performs a configurable semantic comparison that can account
  /// for variations in compiler optimizations. Its behavior is controlled by
  /// the named parameters.
  ///
  /// Note that this method is quadratic in input size.
  ///
  /// If [expectedIsSubset] is `true`, performs a subsumption check instead of a
  /// strict one-to-one equality check.
  ///
  /// The [uriMapping] is a function to map URIs before comparison. Useful when
  /// compilers use different schemes (e.g., `package:` vs `file:`).
  ///
  /// The [loadingUnitMapping] is a function to align loading unit identifiers
  /// between two sets of recordings.
  ///
  /// If [allowDeadCodeElimination] is `true`, the comparison will pass even if
  /// a usage from [expected] cannot be found in `this`, simulating the effect
  /// of a compiler optimizing away a call entirely.
  ///
  /// If [allowTearOffToStaticPromotion] is `true`, allows an [expected]
  /// function tear-off to match an `actual` static call.
  ///
  /// If [allowLocationNull] is `true`, having a `null` in one and a column and
  /// line number in the other is considered semantically equal. Useful for if
  /// one compiler does not provide source locations but the other does.
  ///
  /// If [allowDefinitionLoadingUnitNull] is `true`, allows a definition's
  /// loading unit to be `null` in one set but not the other. This handles
  /// cases where a compiler might not emit loading unit information for all
  ///   definitions.
  ///
  /// If [allowMoreConstArguments] is `true`, `null` arguments in an `expected`
  /// call are ignored during comparison. This can be used to accommodate
  /// differences in how compilers handle default or optional arguments.
  ///
  /// If [allowMetadataMismatch] is `true`, the [metadata] does not need to
  /// match.
  @visibleForTesting
  bool semanticEquals(
    Recordings expected, {
    bool expectedIsSubset = false,
    bool allowDeadCodeElimination = false,
    bool allowTearOffToStaticPromotion = false,
    bool allowLocationNull = false,
    bool allowDefinitionLoadingUnitNull = false,
    bool allowMoreConstArguments = false,
    bool allowMetadataMismatch = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    if (!allowMetadataMismatch && metadata != expected.metadata) {
      return false;
    }
    // ignore: invalid_use_of_visible_for_testing_member
    bool definitionMatches(Definition a, Definition b) => a.semanticEquals(
      b,
      allowLoadingUnitNull: allowDefinitionLoadingUnitNull,
      uriMapping: uriMapping,
      loadingUnitMapping: loadingUnitMapping,
    );

    if (!_compareUsageMap(
      actual: callsForDefinition,
      expected: expected.callsForDefinition,
      expectedIsSubset: expectedIsSubset,
      allowDeadCodeElimination: allowDeadCodeElimination,
      definitionMatches: definitionMatches,
      // ignore: invalid_use_of_visible_for_testing_member
      referenceMatches: (CallReference a, CallReference b) => a.semanticEquals(
        b,
        allowTearOffToStaticPromotion: allowTearOffToStaticPromotion,
        allowLocationNull: allowLocationNull,
        allowMoreConstArguments: allowMoreConstArguments,
        uriMapping: uriMapping,
        loadingUnitMapping: loadingUnitMapping,
      ),
    )) {
      return false;
    }

    if (!_compareUsageMap(
      actual: instancesForDefinition,
      expected: expected.instancesForDefinition,
      expectedIsSubset: expectedIsSubset,
      allowDeadCodeElimination: allowDeadCodeElimination,
      definitionMatches: definitionMatches,
      referenceMatches: (InstanceReference a, InstanceReference b) =>
          // ignore: invalid_use_of_visible_for_testing_member
          a.semanticEquals(
            b,
            allowLocationNull: allowLocationNull,
            uriMapping: uriMapping,
            loadingUnitMapping: loadingUnitMapping,
          ),
    )) {
      return false;
    }

    return true;
  }

  /// Returns true if [expected] is a semantic subset of [actual].
  static bool _compareUsageMap<R extends Reference>({
    required Map<Definition, List<R>> actual,
    required Map<Definition, List<R>> expected,
    required bool expectedIsSubset,
    required bool allowDeadCodeElimination,
    required bool Function(Definition, Definition) definitionMatches,
    required bool Function(R, R) referenceMatches,
  }) {
    final actualUsages = actual.entries.toList();
    final expectedUsages = expected.entries.toList();

    if (!expectedIsSubset &&
        !allowDeadCodeElimination &&
        actualUsages.length != expectedUsages.length) {
      return false;
    }

    final matchedActualIndices = <int>{};

    for (final expectedUsage in expectedUsages) {
      int? foundMatchIndex;
      for (var i = 0; i < actualUsages.length; i++) {
        if (matchedActualIndices.contains(i)) {
          continue;
        }

        final actualUsage = actualUsages[i];

        if (definitionMatches(
          actualUsage.key,
          expectedUsage.key,
        )) {
          // Definitions match semantically. Now check the references.
          // The list of references for this definition must be an exact
          // semantic match.
          final referencesMatch = _matchReferences(
            actual: actualUsage.value,
            expected: expectedUsage.value,
            allowDeadCodeElimination: allowDeadCodeElimination,
            matches: referenceMatches,
          );

          if (referencesMatch) {
            foundMatchIndex = i;
            break;
          }
        }
      }

      if (foundMatchIndex != null) {
        matchedActualIndices.add(foundMatchIndex);
      } else if (!allowDeadCodeElimination) {
        // No match found for this expected usage, and DCE not allowed.
        return false;
      }
    }

    // In one-to-one mode, all actual usages must have been matched.
    if (!expectedIsSubset &&
        matchedActualIndices.length != actualUsages.length) {
      return false;
    }

    return true;
  }

  /// Tries to find a pairing for each [expected] item from the [actual] items.
  ///
  /// Each item from [actual] can be matched at most once.
  static bool _matchReferences<R extends Reference>({
    required List<R> actual,
    required List<R> expected,
    required bool Function(R, R) matches,
    required bool allowDeadCodeElimination,
  }) {
    if (!allowDeadCodeElimination && actual.length != expected.length) {
      return false;
    }
    if (actual.length < expected.length) {
      return false;
    }

    final matchedActualIndices = <int>{};

    for (final expectedItem in expected) {
      int? foundMatchIndex;
      for (var i = 0; i < actual.length; i++) {
        if (matchedActualIndices.contains(i)) {
          continue;
        }
        if (matches(actual[i], expectedItem)) {
          foundMatchIndex = i;
          break;
        }
      }

      if (foundMatchIndex != null) {
        matchedActualIndices.add(foundMatchIndex);
      } else {
        return false; // No match for expectedItem.
      }
    }

    return true;
  }

  /// Returns a new [Recordings] that only contains usages of definitions
  /// filtered by the provided criteria.
  ///
  /// If [definitionPackageName] is provided, only usages of definitions
  /// defined in that package are included.
  Recordings filter({String? definitionPackageName}) {
    bool belongsToPackage(Definition definition) {
      if (definitionPackageName == null) return true;
      final uri = definition.identifier.importUri;
      return uri.startsWith('package:$definitionPackageName/');
    }

    final newCallsForDefinition = {
      for (final entry in callsForDefinition.entries)
        if (belongsToPackage(entry.key)) entry.key: entry.value,
    };

    final newInstancesForDefinition = {
      for (final entry in instancesForDefinition.entries)
        if (belongsToPackage(entry.key)) entry.key: entry.value,
    };

    return Recordings(
      metadata: metadata,
      callsForDefinition: newCallsForDefinition,
      instancesForDefinition: newInstancesForDefinition,
    );
  }
}

extension FlattenConstantsExtension on Iterable<Constant> {
  Set<Constant> flatten() {
    final constants = <Constant>{};
    for (final constant in this) {
      depthFirstSearch(constant, constants);
    }
    return constants;
  }

  void depthFirstSearch(Constant constant, Set<Constant> collected) {
    final children = switch (constant) {
      ListConstant<Constant>() => constant.value,
      MapConstant<Constant, Constant>() => constant.entries.expand(
        (e) => [e.key, e.value],
      ),
      InstanceConstant() => constant.fields.values,
      _ => <Constant>[],
    };
    for (final child in children) {
      if (!collected.contains(child)) {
        depthFirstSearch(child, collected);
      }
    }
    collected.add(constant);
  }
}

extension MapifyIterableExtension<T> on Iterable<T> {
  /// Transform list to map, faster than using list.indexOf
  Map<T, int> get asMapToIndices {
    var i = 0;
    return {for (final element in this) element: i++};
  }
}
