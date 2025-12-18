// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

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
    } on Exception catch (e) {
      throw ArgumentError('''
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
      constants: constantsIndex.keys
          .map((constant) => constant.toSyntax(constantsIndex))
          .toList(),
      locations: locationsIndex.keys
          .map((location) => location.toSyntax())
          .toList(),
      recordings: recordings,
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
      MapConstant<Constant>() => constant.value.values,
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
