// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:meta/meta.dart';

import 'canonicalization_context.dart';
import 'constant.dart';
import 'definition.dart';
import 'helper.dart';
import 'loading_unit.dart';
import 'reference.dart';
import 'serialization_context.dart';
import 'syntax.g.dart';

/// Holds all information recorded during compilation.
///
/// Associate [Definition]s annotated with `@RecordUse()` from `package:meta`
/// with their corresponding recorded usages.
///
/// The definition annotated with `@RecordUse()` must be inside the `lib/`
/// directory of the package. If the definition is a member of a class (e.g. a
/// static method), the class must be in the `lib/` directory.
///
/// The class uses a normalized JSON format, allowing the reuse of constants
/// across multiple recordings to optimize storage.
class Recordings {
  /// The collected [CallReference]s for each [DefinitionWithStaticCalls].
  ///
  /// Recorded when `@RecordUse()` is placed on a static member (top-level
  /// functions, static methods, getters, setters, or operators) in any
  /// container (library, class, mixin, enum, extension, or extension type).
  ///
  /// For example, to record calls to a static method:
  ///
  /// <!-- file://./../../example/api/usage.dart#static-call -->
  /// ```dart
  /// abstract class PirateTranslator {
  ///   @RecordUse()
  ///   static String speak(String english) => 'Ahoy $english';
  /// }
  /// ```
  ///
  /// Supported Locations:
  /// - Top-level function / getter / setter.
  /// - Static method / getter / setter in a class, mixin, or enum.
  /// - Extension/Extension type method / getter / setter / operator (both
  ///   static and instance).
  ///
  /// What is Recorded:
  /// - [CallWithArguments]: Recorded for direct invocations.
  ///   - [CallWithArguments.positionalArguments] and
  ///     [CallWithArguments.namedArguments]: Captured if they are constant;
  ///     otherwise recorded as [NonConstant]. Any non-provided arguments with
  ///     default values will have their default values filled in.
  ///   - [CallReference.receiver]: For extension instance members, the receiver
  ///     is captured if it is a constant.
  /// - [CallTearoff]: Recorded for method tear-offs.
  /// - Getters/Setters: Simple access is recorded as a [CallWithArguments]. For
  ///   setters, the assigned value is captured as a positional argument.
  ///
  /// Supported Constants:
  /// - [NullConstant]: The `null` literal.
  /// - [BoolConstant]: `true` and `false`.
  /// - [IntConstant]: All constant integer values.
  /// - [StringConstant]: All constant string values.
  /// - [SymbolConstant]: Both public (e.g. `#mySymbol`) and private (e.g.
  ///   `#_myPrivateSymbol`). Private symbols include the library URI in the
  ///   recording to ensure they are unambiguous.
  /// - [ListConstant]: Constant lists where every element is also a
  ///   supported constant.
  /// - [MapConstant]: Constant maps where every key and value is a
  ///   supported constant.
  /// - [RecordConstant]: Constant records (positional and named fields)
  ///   containing supported constants.
  /// - [EnumConstant]: Constants of an enum type, provided the enum itself is
  ///   annotated with `@RecordUse()`. The recording includes the index, name,
  ///   and any field values (for enhanced enums).
  /// - [InstanceConstant]: `const` instances of a `final` class, provided the
  ///   class is annotated with `@RecordUse()`. The recording includes all
  ///   constant field values.
  ///
  /// Unsupported Constants:
  /// The following types are explicitly not supported and will be recorded as
  /// an [UnsupportedConstant] with a descriptive message if encountered:
  /// - Doubles: Double literals are currently excluded from recording to avoid
  ///   precision/portability issues across different platforms (VM vs JS).
  /// - Sets: Constant sets are currently not supported (they are handled
  ///   differently than Lists/Maps in the compiler backends).
  /// - Type Literals: Passing a type itself (e.g. `MyClass`) as a constant
  ///   argument is not supported.
  ///   https://github.com/dart-lang/native/issues/3199
  /// - Function/Method Tear-offs: While the tool records the fact that a
  ///   method was torn off (as a usage), passing a method tear-off as a
  ///   constant value into another recorded call is not supported (it will not
  ///   be recorded as a constant value).
  ///
  /// Usage in a link hook:
  ///
  /// <!-- file://./../../example/api/usage_link.dart#static-call -->
  /// ```dart
  /// final calls = uses.calls[methodId] ?? [];
  /// for (final call in calls) {
  ///   switch (call) {
  ///     case CallWithArguments(
  ///       positionalArguments: [StringConstant(value: final english), ...],
  ///     ):
  ///       // Shrink a translations file based on all the different translation
  ///       // keys.
  ///       print('Translating to pirate: $english');
  ///     case _:
  ///       print('Cannot determine which translations are used.');
  ///   }
  /// }
  /// ```
  ///
  /// Notes:
  /// - Type Arguments: Intentionally not recorded (e.g., `myMethod<int>()`),
  ///   as we don't currently have a serialization format for types.
  ///   https://github.com/dart-lang/native/issues/3198
  /// - Non-redirecting Factory Constructors: Not yet supported for static
  ///   calls, because they can be the target of redirecting constructors.
  ///   https://github.com/dart-lang/native/issues/3192
  final Map<DefinitionWithStaticCalls, List<CallReference>> calls;

  /// The collected [InstanceReference]s for each [DefinitionWithInstances].
  ///
  /// Recorded when `@RecordUse()` is placed on a `final class` or `enum` to
  /// track the lifecycle of instances.
  ///
  /// For example, to record instances of a class:
  ///
  /// <!-- file://./../../example/api/usage.dart#const-instance -->
  /// ```dart
  /// @RecordUse()
  /// final class PirateShip {
  ///   final String name;
  ///   final int cannons;
  ///
  ///   const PirateShip(this.name, this.cannons);
  /// }
  /// ```
  ///
  /// Supported Locations:
  /// - `final class` (must be `final` to ensure all creation points are known).
  /// - `enum` (implicitly `final`).
  ///
  /// What is Recorded:
  /// - [InstanceConstantReference]: Recorded for constant instances and enum
  ///   elements.
  ///   - [InstanceConstantReference.instanceConstant]: The captured constant
  ///     value.
  /// - [InstanceCreationReference]: Recorded for generative constructor
  ///   invocations (non-const).
  ///   - [InstanceCreationReference.positionalArguments] and
  ///     [InstanceCreationReference.namedArguments]: Captured if they are
  ///     constant; otherwise recorded as [NonConstant]. Any non-provided
  ///     arguments with default values will have their default values
  ///     filled in.
  /// - [ConstructorTearoffReference]: Recorded for constructor tear-offs.
  /// - Redirecting Factories (`=`): Resolved to the effective target class and
  ///   recorded as an instance creation, constant, or tear-off of that class.
  /// - Typedefs: Resolved back to the underlying class.
  /// - Redirecting Generative Constructors (`: this.`): Recorded at the entry
  ///   point only.
  ///
  /// Supported Constants:
  /// - [NullConstant]: The `null` literal.
  /// - [BoolConstant]: `true` and `false`.
  /// - [IntConstant]: All constant integer values.
  /// - [StringConstant]: All constant string values.
  /// - [SymbolConstant]: Both public (e.g. `#mySymbol`) and private (e.g.
  ///   `#_myPrivateSymbol`). Private symbols include the library URI in the
  ///   recording to ensure they are unambiguous.
  /// - [ListConstant]: Constant lists where every element is also a
  ///   supported constant.
  /// - [MapConstant]: Constant maps where every key and value is a
  ///   supported constant.
  /// - [RecordConstant]: Constant records (positional and named fields)
  ///   containing supported constants.
  /// - [EnumConstant]: Constants of an enum type, provided the enum itself is
  ///   annotated with `@RecordUse()`. The recording includes the index, name,
  ///   and any field values (for enhanced enums).
  /// - [InstanceConstant]: `const` instances of a `final` class, provided the
  ///   class is annotated with `@RecordUse()`. The recording includes all
  ///   constant field values.
  ///
  /// Unsupported Constants:
  /// The following types are explicitly not supported and will be recorded as
  /// an [UnsupportedConstant] with a descriptive message if encountered:
  /// - Doubles: Double literals are currently excluded from recording to avoid
  ///   precision/portability issues across different platforms (VM vs JS).
  /// - Sets: Constant sets are currently not supported (they are handled
  ///   differently than Lists/Maps in the compiler backends).
  /// - Type Literals: Passing a type itself (e.g. `MyClass`) as a constant
  ///   argument is not supported.
  ///   https://github.com/dart-lang/native/issues/3199
  /// - Function/Method Tear-offs: While the tool records the fact that a
  ///   method was torn off (as a usage), passing a method tear-off as a
  ///   constant value into another recorded call is not supported (it will not
  ///   be recorded as a constant value).
  ///
  /// Usage in a link hook:
  ///
  /// <!-- file://./../../example/api/usage_link.dart#const-instance -->
  /// ```dart
  /// final ships = uses.instances[classId] ?? [];
  /// for (final ship in ships) {
  ///   switch (ship) {
  ///     case InstanceConstantReference(
  ///       instanceConstant: InstanceConstant(
  ///         fields: {'name': StringConstant(value: final name)},
  ///       ),
  ///     ):
  ///       // Include the 3d model for this ship in the application but not
  ///       // bundle the other ships.
  ///       print('Pirate ship found: $name');
  ///     case _:
  ///       print('Cannot determine which ships are used.');
  ///   }
  /// }
  /// ```
  ///
  /// Notes:
  /// - Type Arguments: Intentionally not recorded (e.g., `MyClass<int>()`),
  ///   as we don't currently have a serialization format for types.
  ///   https://github.com/dart-lang/native/issues/3198
  /// - Non-redirecting Factories: Invocations of non-redirecting factories are
  ///   NOT recorded as instances. Instead, the body of the factory is analyzed
  ///   like a static method, and any generative constructor calls inside the
  ///   body are recorded as instances of the class.
  /// - Non-final classes: This is not (yet) supported due to the extra
  ///   complexity with reasoning about instances of subtypes. If we ever
  ///   support this we will likely not allow type hierarchies to cross package
  ///   boundaries due to the ambiguity of to which packages' link hook the
  ///   information should be sent.
  ///   https://github.com/dart-lang/native/issues/3200
  final Map<DefinitionWithInstances, List<InstanceReference>> instances;

  Recordings({
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

    final callsForDefinition =
        <DefinitionWithStaticCalls, List<CallReference>>{};
    final instancesForDefinition =
        <DefinitionWithInstances, List<InstanceReference>>{};

    final uses = syntax.uses;
    if (uses != null) {
      for (final callRecording in uses.staticCalls ?? <CallRecordingSyntax>[]) {
        final definition =
            context.definitions[callRecording.definitionIndex]
                as DefinitionWithStaticCalls;
        final callSyntaxes = callRecording.uses;
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
      for (final instanceRecording
          in uses.instances ?? <InstanceRecordingSyntax>[]) {
        final definition =
            context.definitions[instanceRecording.definitionIndex]
                as DefinitionWithInstances;
        final instanceSyntaxes = instanceRecording.uses;
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
      calls: callsForDefinition,
      instances: instancesForDefinition,
    );
  }

  Recordings _canonicalizeChildren(CanonicalizationContext context) =>
      Recordings(
        calls: _canonicalizeReferences(context, calls),
        instances: _canonicalizeReferences(context, instances),
      );

  Map<K, List<R>>
  _canonicalizeReferences<K extends Definition, R extends Reference>(
    CanonicalizationContext context,
    Map<K, List<R>> references,
  ) {
    final map = <K, Set<R>>{};
    for (final entry in references.entries) {
      final definition = context.canonicalizeDefinition(entry.key);
      final set = map.putIfAbsent(definition, () => {});
      for (final reference in entry.value) {
        set.add(reference.canonicalizeChildren(context) as R);
      }
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => a.compareTo(b));
    return <K, List<R>>{
      for (final key in sortedKeys)
        key: map[key]!.toList()..sort((a, b) => a.compareTo(b)),
    };
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
    final constants = <MaybeConstant>[];
    // Create a context that includes an empty list for the constants. This
    // list will be populated by [_deserializeConstants], providing the
    // self-referential access needed to resolve recursive constants (e.g.
    // list and map constants).
    final context = DeserializationContext.fromPrevious(
      definitionContext,
      constants,
    );
    for (final constantSyntax in syntax.constants ?? <ConstantSyntax>[]) {
      final constant = MaybeConstantProtected.fromSyntax(
        constantSyntax,
        context,
      );
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
    final canonContext = CanonicalizationContext();
    final canon = _canonicalizeChildren(canonContext);

    final sortedLoadingUnits = canonContext.loadingUnits.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final sortedDefinitions = canonContext.definitions.toList()
      ..sort((a, b) => a.compareTo(b));
    final sortedConstants = canonContext.constants.toList()
      ..sort((a, b) => a.compareTo(b));

    final context = SerializationContext(
      loadingUnits: sortedLoadingUnits.asMapToIndices,
      definitions: sortedDefinitions.asMapToIndices,
      constants: sortedConstants.asMapToIndices,
    );

    final callRecordings = <CallRecordingSyntax>[];
    for (final entry in canon.calls.entries) {
      callRecordings.add(
        CallRecordingSyntax(
          definitionIndex: context.definitions[entry.key]!,
          uses: entry.value.map((call) => call.toSyntax(context)).toList(),
        ),
      );
    }
    final instanceRecordings = <InstanceRecordingSyntax>[];
    for (final entry in canon.instances.entries) {
      instanceRecordings.add(
        InstanceRecordingSyntax(
          definitionIndex: context.definitions[entry.key]!,
          uses: entry.value
              .map((instance) => instance.toSyntax(context))
              .toList(),
        ),
      );
    }

    final uses = (callRecordings.isEmpty && instanceRecordings.isEmpty)
        ? null
        : UsesSyntax(
            staticCalls: callRecordings.isEmpty ? null : callRecordings,
            instances: instanceRecordings.isEmpty ? null : instanceRecordings,
          );

    return RecordedUsesSyntax(
      constants: sortedConstants.isEmpty
          ? null
          : [
              for (final constant in sortedConstants)
                constant.toSyntax(context),
            ],
      loadingUnits: sortedLoadingUnits.isEmpty
          ? null
          : [
              for (final unit in sortedLoadingUnits)
                LoadingUnitSyntax(name: unit.name),
            ],
      definitions: sortedDefinitions.isEmpty
          ? null
          : [
              for (final definition in sortedDefinitions) definition.toSyntax(),
            ],
      uses: uses,
    );
  }

  @override
  bool operator ==(covariant Recordings other) {
    if (identical(this, other)) return true;

    return deepEquals(other.calls, calls) &&
        deepEquals(other.instances, instances);
  }

  @override
  int get hashCode => cacheHashCode(
    () => Object.hash(
      deepHash(calls),
      deepHash(instances),
    ),
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
  @visibleForTesting
  bool semanticEquals(
    Recordings expected, {
    bool expectedIsSubset = false,
    bool allowDeadCodeElimination = false,
    bool allowTearoffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
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
  static bool _compareUsageMap<K extends Definition, R extends Reference>({
    required Map<K, List<R>> actual,
    required Map<K, List<R>> expected,
    required bool expectedIsSubset,
    required bool allowDeadCodeElimination,
    required bool Function(K, K) definitionMatches,
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
      final uri = definition.library.uri;
      return uri.startsWith('package:$definitionPackageName/');
    }

    final newCallsForDefinition = {
      for (final entry in calls.entries)
        if (belongsToPackage(entry.key))
          entry.key: [
            for (final call in entry.value)
              call.filter(definitionPackageName: definitionPackageName),
          ],
    };

    final newInstancesForDefinition = {
      for (final entry in instances.entries)
        if (belongsToPackage(entry.key))
          entry.key: [
            for (final instance in entry.value)
              instance.filter(definitionPackageName: definitionPackageName),
          ],
    };

    return Recordings(
      calls: newCallsForDefinition,
      instances: newInstancesForDefinition,
    );
  }
}

extension RecordingsProtected on Recordings {
  Recordings canonicalizeChildren(CanonicalizationContext context) =>
      _canonicalizeChildren(context);
}

extension MapifyIterableExtension<T> on Iterable<T> {
  /// Transform list to map, faster than using list.indexOf
  Map<T, int> get asMapToIndices {
    var i = 0;
    return {for (final element in this) element: i++};
  }
}
