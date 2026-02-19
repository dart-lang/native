// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:meta/meta.dart';

import 'constant.dart';
import 'definition.dart';
import 'helper.dart';
import 'loading_unit.dart';
import 'metadata.dart';
import 'reference.dart';
import 'serialization_context.dart';
import 'syntax.g.dart';

/// [Recordings] combines recordings of calls and instances with metadata.
///
/// This class acts as the top-level container for recorded usage information.
/// The metadata provides context for the recording, such as version and
/// commentary. The [calls] and [instances] store the core data, associating
/// each [Definition] with its corresponding [Reference] details.
///
/// The class uses a normalized JSON format, allowing the reuse of constants
/// across multiple recordings to optimize storage.
class Recordings {
  /// [Metadata] such as the recording protocol version.
  final Metadata metadata;

  /// The collected [CallReference]s for each [Definition].
  final Map<Definition, List<CallReference>> calls;

  /// The collected [InstanceReference]s for each [Definition].
  final Map<Definition, List<InstanceReference>> instances;

  Recordings({
    required this.metadata,
    required this.calls,
    required this.instances,
  });

  /// Decodes a JSON representation into a [Recordings] object.
  ///
  /// The format is specifically designed to reduce redundancy and improve
  /// efficiency. Definitions and constants are stored in separate tables,
  /// allowing them to be referenced by index in the `recordings` map.
  factory Recordings.fromJson(Map<String, Object?> json) {
    try {
      final syntax = RecordedUsesSyntax.fromJson(json);
      final syntaxErrors = syntax.validate();
      if (syntaxErrors.isNotEmpty) {
        final errorsString = syntaxErrors.map((e) => ' - $e').join('\n');
        throw FormatException(
          'Validation errors for record use file:\n$errorsString\n',
        );
      }
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
    final loadingUnitContext = _deserializeLoadingUnits(syntax);
    final definitionContext = _deserializeDefinitions(
      syntax,
      loadingUnitContext,
    );
    final context = _deserializeConstants(syntax, definitionContext);

    final callsForDefinition = <Definition, List<CallReference>>{};
    final instancesForDefinition = <Definition, List<InstanceReference>>{};

    for (final recordingSyntax in syntax.recordings ?? <RecordingSyntax>[]) {
      final definition = context.definitions[recordingSyntax.definitionIndex];
      if (recordingSyntax.calls case final callSyntaxes?) {
        final callReferences = callSyntaxes
            .map<CallReference>(
              (callSyntax) => CallReferenceProtected.fromSyntax(
                callSyntax,
                context,
              ),
            )
            .toList();
        callsForDefinition
            .putIfAbsent(definition, () => [])
            .addAll(callReferences);
      }
      if (recordingSyntax.instances case final instanceSyntaxes?) {
        final instanceReferences = instanceSyntaxes
            .map<InstanceReference>(
              (instanceSyntax) => InstanceReferenceProtected.fromSyntax(
                instanceSyntax,
                context,
              ),
            )
            .toList();
        instancesForDefinition
            .putIfAbsent(definition, () => [])
            .addAll(instanceReferences);
      }
    }

    return Recordings(
      metadata: MetadataProtected.fromSyntax(syntax.metadata),
      calls: callsForDefinition,
      instances: instancesForDefinition,
    );
  }

  static LoadingUnitDeserializationContext _deserializeLoadingUnits(
    RecordedUsesSyntax syntax,
  ) {
    final loadingUnits = <LoadingUnit>[];
    for (final unit in syntax.loadingUnits ?? <LoadingUnitSyntax>[]) {
      loadingUnits.add(LoadingUnit(unit.name));
    }
    return LoadingUnitDeserializationContext(loadingUnits);
  }

  static DefinitionDeserializationContext _deserializeDefinitions(
    RecordedUsesSyntax syntax,
    LoadingUnitDeserializationContext loadingUnitContext,
  ) {
    final definitions = <Definition>[];
    for (final definitionSyntax in syntax.definitions ?? <DefinitionSyntax>[]) {
      definitions.add(DefinitionProtected.fromSyntax(definitionSyntax));
    }
    return DefinitionDeserializationContext.fromPrevious(
      loadingUnitContext,
      definitions,
    );
  }

  static DeserializationContext _deserializeConstants(
    RecordedUsesSyntax syntax,
    DefinitionDeserializationContext definitionContext,
  ) {
    final constants = <Constant>[];
    // Create a context that includes an empty list for the constants. This
    // list will be populated by [_deserializeConstants], providing the
    // self-referential access needed to resolve recursive constants (e.g.
    // list and map constants).
    final context = DeserializationContext.fromPrevious(
      definitionContext,
      constants,
    );
    for (final constantSyntax in syntax.constants ?? <ConstantSyntax>[]) {
      final constant = ConstantProtected.fromSyntax(constantSyntax, context);
      if (!constants.contains(constant)) {
        constants.add(constant);
      }
    }
    return context;
  }

  /// Encodes this object into a JSON representation.
  ///
  /// This method normalizes identifiers and constants for storage efficiency.
  Map<String, Object?> toJson() => _toSyntax().json;

  RecordedUsesSyntax _toSyntax() {
    final allConstants = _collectConstants();
    final allLoadingUnits = _collectLoadingUnits();
    final loadingUnitContext = _serializeLoadingUnits(allLoadingUnits);
    final definitionContext = _serializeDefinitions(
      allConstants,
      loadingUnitContext,
    );
    final (context, constantSyntax) = _serializeConstants(
      allConstants,
      definitionContext,
    );

    final recordings = <RecordingSyntax>[];
    for (final definition in context.definitions.keys) {
      final callsForDefinition = calls[definition];
      final instancesForDefinition = instances[definition];
      recordings.add(
        RecordingSyntax(
          definitionIndex: context.definitions[definition]!,
          calls: callsForDefinition
              ?.map((call) => call.toSyntax(context))
              .toList(),
          instances: instancesForDefinition
              ?.map((instance) => instance.toSyntax(context))
              .toList(),
        ),
      );
    }

    return RecordedUsesSyntax(
      metadata: metadata.toSyntax(),
      constants: constantSyntax.isEmpty ? null : constantSyntax,
      loadingUnits: allLoadingUnits.isEmpty
          ? null
          : allLoadingUnits
                .map((unit) => LoadingUnitSyntax(name: unit.name))
                .toList(),
      definitions: context.definitions.isEmpty
          ? null
          : context.definitions.keys
                .map(
                  (definition) => definition.toSyntax(),
                )
                .toList(),
      recordings: recordings.isEmpty ? null : recordings,
    );
  }

  Iterable<Constant> _collectConstants() => {
    ...calls.values
        .expand((calls) => calls)
        .whereType<CallWithArguments>()
        .expand(
          (call) => [
            ...call.positionalArguments,
            ...call.namedArguments.values,
          ],
        )
        .expand(
          (argument) => switch (argument) {
            final Constant c => [c],
            NonConstant() => <Constant>[],
          },
        ),
    ...instances.values
        .expand((instances) => instances)
        .expand(
          (instance) => switch (instance) {
            InstanceConstantReference(:final instanceConstant) => {
              ...instanceConstant.fields.values,
              instanceConstant,
            },
            InstanceCreationReference(
              :final positionalArguments,
              :final namedArguments,
            ) =>
              [...positionalArguments, ...namedArguments.values].expand(
                (argument) => switch (argument) {
                  final Constant c => [c],
                  NonConstant() => <Constant>[],
                },
              ),
            ConstructorTearoffReference() => <Constant>[],
          },
        ),
  }.flatten();

  Iterable<LoadingUnit> _collectLoadingUnits() => {
    ...calls.values
        .expand((calls) => calls)
        .expand((call) => call.loadingUnits),
    ...instances.values
        .expand((instances) => instances)
        .expand((instance) => instance.loadingUnits),
  };

  LoadingUnitSerializationContext _serializeLoadingUnits(
    Iterable<LoadingUnit> allLoadingUnits,
  ) => LoadingUnitSerializationContext(
    allLoadingUnits.asMapToIndices,
  );

  DefinitionSerializationContext _serializeDefinitions(
    Iterable<Constant> allConstants,
    LoadingUnitSerializationContext loadingUnitContext,
  ) {
    final allDefinitions = {
      ...calls.keys,
      ...instances.keys,
      ...allConstants.whereType<InstanceConstant>().map((c) => c.definition),
    };
    return DefinitionSerializationContext.fromPrevious(
      loadingUnitContext,
      allDefinitions.asMapToIndices,
    );
  }

  (SerializationContext, List<ConstantSyntax>) _serializeConstants(
    Iterable<Constant> allConstants,
    DefinitionSerializationContext definitionContext,
  ) {
    final constantsMap = allConstants.asMapToIndices;
    final context = SerializationContext.fromPrevious(
      definitionContext,
      constantsMap,
    );
    final constantSyntax = [
      for (final constant in allConstants) constant.toSyntax(context),
    ];
    return (context, constantSyntax);
  }

  @override
  bool operator ==(covariant Recordings other) {
    if (identical(this, other)) return true;

    return other.metadata == metadata &&
        deepEquals(other.calls, calls) &&
        deepEquals(other.instances, instances);
  }

  @override
  int get hashCode => Object.hash(
    metadata.hashCode,
    deepHash(calls),
    deepHash(instances),
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
  /// If [allowTearoffToStaticPromotion] is `true`, allows an [expected]
  /// function tear-off to match an `actual` static call.
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
    bool allowTearoffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
    bool allowMetadataMismatch = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    if (!allowMetadataMismatch && metadata != expected.metadata) {
      return false;
    }
    bool definitionMatches(Definition a, Definition b) =>
        // ignore: invalid_use_of_visible_for_testing_member
        a.semanticEquals(b, uriMapping: uriMapping);

    if (!_compareUsageMap(
      actual: calls,
      expected: expected.calls,
      expectedIsSubset: expectedIsSubset,
      allowDeadCodeElimination: allowDeadCodeElimination,
      definitionMatches: definitionMatches,
      referenceMatches: (CallReference a, CallReference b) =>
          // ignore: invalid_use_of_visible_for_testing_member
          a.semanticEquals(
            b,
            allowTearoffToStaticPromotion: allowTearoffToStaticPromotion,
            allowMoreConstArguments: allowMoreConstArguments,
            allowPromotionOfUnsupported: allowPromotionOfUnsupported,
            uriMapping: uriMapping,
            loadingUnitMapping: loadingUnitMapping,
          ),
    )) {
      return false;
    }

    if (!_compareUsageMap(
      actual: instances,
      expected: expected.instances,
      expectedIsSubset: expectedIsSubset,
      allowDeadCodeElimination: allowDeadCodeElimination,
      definitionMatches: definitionMatches,
      referenceMatches: (InstanceReference a, InstanceReference b) =>
          // ignore: invalid_use_of_visible_for_testing_member
          a.semanticEquals(
            b,
            uriMapping: uriMapping,
            loadingUnitMapping: loadingUnitMapping,
            allowMoreConstArguments: allowMoreConstArguments,
            allowPromotionOfUnsupported: allowPromotionOfUnsupported,
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

        if (definitionMatches(actualUsage.key, expectedUsage.key)) {
          // Definitions match semantically. Now check the references.
          // The list of references for this identifier must be an exact
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
      final uri = definition.library;
      return uri.startsWith('package:$definitionPackageName/');
    }

    final newCallsForDefinition = {
      for (final entry in calls.entries)
        if (belongsToPackage(entry.key)) entry.key: entry.value,
    };

    final newInstancesForDefinition = {
      for (final entry in instances.entries)
        if (belongsToPackage(entry.key)) entry.key: entry.value,
    };

    return Recordings(
      metadata: metadata,
      calls: newCallsForDefinition,
      instances: newInstancesForDefinition,
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
      ListConstant() => constant.value,
      MapConstant() => constant.entries.expand(
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
