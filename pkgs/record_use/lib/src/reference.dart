// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'canonicalization_context.dart';
import 'constant.dart';
import 'definition.dart';
import 'helper.dart';
import 'loading_unit.dart';
import 'serialization_context.dart';
import 'syntax.g.dart';

/// A reference to a [Definition] from a [LoadingUnit].
///
/// The reference might be a call or an instance, matching a [CallReference] or
/// an [InstanceReference].
///
/// All references have in common that they occur in a [loadingUnit], which we
/// record to be able to piece together which loading units are "related", for
/// example all needing the same asset.
sealed class Reference {
  final LoadingUnit loadingUnit;

  const Reference({required this.loadingUnit});

  /// Canonicalizes this [Reference].
  Reference _canonicalizeChildren(CanonicalizationContext context);

  /// Returns a new [Reference] that only contains information allowed
  /// by the provided criteria.
  Reference _filter({String? definitionPackageName});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reference && other.loadingUnit == loadingUnit;
  }

  @override
  int get hashCode => cacheHashCode(() => loadingUnit.hashCode);

  int _compareTo(Reference other) {
    var result = loadingUnit.name.compareTo(other.loadingUnit.name);
    if (result != 0) return result;
    result = _orderingTypePriority.compareTo(other._orderingTypePriority);
    if (result != 0) return result;
    return _compareToInternal(other);
  }

  int _compareToInternal(covariant Reference other);

  /// A stable priority for this type.
  @protected
  int get _orderingTypePriority;

  bool _semanticEqualsShared(
    Reference other, {
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    final unit = loadingUnit.name;
    final otherUnit = other.loadingUnit.name;
    final mappedUnit = loadingUnitMapping == null
        ? unit
        : loadingUnitMapping(unit);
    return mappedUnit == otherUnit;
  }

  @override
  String toString() => loadingUnit.name;
}

mixin _HasArguments {
  List<MaybeConstant> get positionalArguments;
  Map<String, MaybeConstant> get namedArguments;

  int _compareToArguments(covariant _HasArguments other) {
    if (positionalArguments.length != other.positionalArguments.length) {
      return positionalArguments.length.compareTo(
        other.positionalArguments.length,
      );
    }
    for (var i = 0; i < positionalArguments.length; i++) {
      final result = positionalArguments[i].compareTo(
        other.positionalArguments[i],
      );
      if (result != 0) return result;
    }
    if (namedArguments.length != other.namedArguments.length) {
      return namedArguments.length.compareTo(other.namedArguments.length);
    }
    final thisSorted = namedArguments.keys.toList()..sort();
    final otherSorted = other.namedArguments.keys.toList()..sort();
    for (var i = 0; i < thisSorted.length; i++) {
      var result = thisSorted[i].compareTo(otherSorted[i]);
      if (result != 0) return result;
      result = namedArguments[thisSorted[i]]!.compareTo(
        other.namedArguments[otherSorted[i]]!,
      );
      if (result != 0) return result;
    }
    return 0;
  }

  List<MaybeConstant> _canonicalizePositional(
    CanonicalizationContext context,
  ) => [for (final c in positionalArguments) context.canonicalizeConstant(c)];

  Map<String, MaybeConstant> _canonicalizeNamed(
    CanonicalizationContext context,
  ) {
    final sortedNamedArgs = namedArguments.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return {
      for (final e in sortedNamedArgs)
        e.key: context.canonicalizeConstant(e.value),
    };
  }

  List<MaybeConstant> _filterPositional({String? definitionPackageName}) => [
    for (final c in positionalArguments)
      c.filter(definitionPackageName: definitionPackageName),
  ];

  Map<String, MaybeConstant> _filterNamed({String? definitionPackageName}) =>
      namedArguments.map(
        (key, value) => MapEntry(
          key,
          value.filter(definitionPackageName: definitionPackageName),
        ),
      );

  bool _semanticEqualsArguments(
    _HasArguments other, {
    required bool allowMoreConstArguments,
    required bool allowPromotionOfUnsupported,
  }) {
    if (positionalArguments.length != other.positionalArguments.length) {
      return false;
    }
    for (final (index, argument) in other.positionalArguments.indexed) {
      if (argument is NonConstant && allowMoreConstArguments) {
        continue;
      }
      // ignore: invalid_use_of_visible_for_testing_member
      if (!positionalArguments[index].semanticEquals(
        argument,
        allowPromotionOfUnsupported: allowPromotionOfUnsupported,
      )) {
        return false;
      }
    }
    for (final entry in other.namedArguments.entries) {
      final name = entry.key;
      final argument = entry.value;
      if (argument is NonConstant && allowMoreConstArguments) {
        continue;
      }
      // ignore: invalid_use_of_visible_for_testing_member
      if (!namedArguments[name]!.semanticEquals(
        argument,
        allowPromotionOfUnsupported: allowPromotionOfUnsupported,
      )) {
        return false;
      }
    }
    return true;
  }
}

/// A reference to a call to some [Definition].
///
/// This might be an actual call, in which case we record the arguments, or a
/// tear-off, in which case we can't record the arguments.
sealed class CallReference extends Reference {
  /// The argument in the receiver position.
  ///
  /// Is `null` for static (extension) methods.
  final MaybeConstant? receiver;

  const CallReference({required super.loadingUnit, this.receiver});

  @override
  int _compareToInternal(covariant CallReference other) {
    if (receiver != null && other.receiver != null) {
      final result = receiver!.compareTo(other.receiver!);
      if (result != 0) return result;
    } else if (receiver != null) {
      return 1;
    } else if (other.receiver != null) {
      return -1;
    }
    return _compareToCallInternal(other);
  }

  int _compareToCallInternal(covariant CallReference other);

  static CallReference _fromSyntax(
    CallSyntax syntax,
    DeserializationContext context,
  ) => switch (syntax) {
    TearoffCallSyntax(:final receiver) => CallTearoff(
      loadingUnit: context.loadingUnits[syntax.loadingUnitIndex],
      receiver: receiver != null ? context.constants[receiver] : null,
    ),
    WithArgumentsCallSyntax(
      :final named,
      :final positional,
      :final loadingUnitIndex,
      :final receiver,
    ) =>
      CallWithArguments(
        positionalArguments: (positional ?? [])
            .map((index) => _argumentFromSyntax(index, context))
            .toList(),
        namedArguments: (named ?? {}).map(
          (name, index) => MapEntry(name, _argumentFromSyntax(index, context)),
        ),
        loadingUnit: context.loadingUnits[loadingUnitIndex],
        receiver: receiver != null ? context.constants[receiver] : null,
      ),
    _ => throw UnimplementedError('Unknown CallSyntax type'),
  };

  static MaybeConstant _argumentFromSyntax(
    int? index,
    DeserializationContext context,
  ) {
    if (index == null) return const NonConstant();
    return context.constants[index];
  }

  CallSyntax _toSyntax(SerializationContext context);

  @override
  CallReference _filter({String? definitionPackageName});

  /// Compares this [CallWithArguments] with [other] for semantic equality.
  ///
  /// If [allowTearoffToStaticPromotion] is true, this may be equal to a
  /// [CallTearoff].
  ///
  /// If [allowMoreConstArguments] is true, `NonConstantArgument` in [other]
  /// are ignored during comparison.
  ///
  /// The loading unit can be mapped with [loadingUnitMapping].
  ///
  /// The URI in the location can be mapped with [uriMapping].
  @visibleForTesting
  bool semanticEquals(
    CallReference other, {
    bool allowTearoffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  });

  bool _semanticEqualsCall(
    CallReference other, {
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    if (!_semanticEqualsShared(
      other,
      uriMapping: uriMapping,
      loadingUnitMapping: loadingUnitMapping,
    )) {
      return false;
    }
    final otherReceiver = other.receiver;
    if (receiver == null) {
      return otherReceiver == null;
    }
    if (otherReceiver == null) return false;
    // ignore: invalid_use_of_visible_for_testing_member
    return receiver!.semanticEquals(
      otherReceiver,
      allowPromotionOfUnsupported: allowPromotionOfUnsupported,
    );
  }
}

/// A reference to a call to some [Definition] with [positionalArguments] and
/// [namedArguments].
///
/// Any non-provided arguments with default values will have their default
/// values filled in.
final class CallWithArguments extends CallReference with _HasArguments {
  @override
  final List<MaybeConstant> positionalArguments;
  @override
  final Map<String, MaybeConstant> namedArguments;

  const CallWithArguments({
    required this.positionalArguments,
    required this.namedArguments,
    required super.loadingUnit,
    super.receiver,
  });

  @override
  int get _orderingTypePriority => 0;

  @override
  int _compareToCallInternal(covariant CallWithArguments other) =>
      _compareToArguments(other);

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      CallWithArguments(
        loadingUnit: context.canonicalizeLoadingUnit(loadingUnit),
        receiver: receiver != null
            ? context.canonicalizeConstant(receiver!)
            : null,
        positionalArguments: _canonicalizePositional(context),
        namedArguments: _canonicalizeNamed(context),
      );

  @override
  CallReference _filter({String? definitionPackageName}) => CallWithArguments(
    loadingUnit: loadingUnit,
    receiver: receiver?.filter(definitionPackageName: definitionPackageName),
    positionalArguments: _filterPositional(
      definitionPackageName: definitionPackageName,
    ),
    namedArguments: _filterNamed(definitionPackageName: definitionPackageName),
  );

  @override
  WithArgumentsCallSyntax _toSyntax(SerializationContext context) {
    final namedArgs = <String, int>{};
    for (final entry in namedArguments.entries) {
      namedArgs[entry.key] = context.constants[entry.value]!;
    }

    return WithArgumentsCallSyntax(
      loadingUnitIndex: context.loadingUnits[loadingUnit]!,
      named: namedArgs.isNotEmpty ? namedArgs : null,
      positional: positionalArguments.isEmpty
          ? null
          : [
              for (final argument in positionalArguments)
                context.constants[argument]!,
            ],
      receiver: receiver != null ? context.constants[receiver!] : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is CallWithArguments &&
        deepEquals(other.positionalArguments, positionalArguments) &&
        deepEquals(other.namedArguments, namedArguments) &&
        receiver == other.receiver;
  }

  @override
  int get hashCode => cacheHashCode(
    () => Object.hash(
      deepHash(positionalArguments),
      deepHash(namedArguments),
      receiver,
      super.hashCode,
    ),
  );

  @override
  @visibleForTesting
  bool semanticEquals(
    CallReference other, {
    bool allowTearoffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    switch (other) {
      case CallWithArguments():
        if (!_semanticEqualsArguments(
          other,
          allowMoreConstArguments: allowMoreConstArguments,
          allowPromotionOfUnsupported: allowPromotionOfUnsupported,
        )) {
          return false;
        }
        return _semanticEqualsCall(
          other,
          uriMapping: uriMapping,
          loadingUnitMapping: loadingUnitMapping,
          allowMoreConstArguments: allowMoreConstArguments,
          allowPromotionOfUnsupported: allowPromotionOfUnsupported,
        );
      case CallTearoff():
        return allowTearoffToStaticPromotion;
    }
  }

  @override
  String toString() {
    final parts = <String>[];
    if (receiver != null) {
      parts.add('receiver: $receiver');
    }
    if (positionalArguments.isNotEmpty) {
      parts.add('positional: ${positionalArguments.join(', ')}');
    }
    if (namedArguments.isNotEmpty) {
      final namedString = namedArguments.entries
          .map((e) => '${e.key}=${e.value}')
          .join(', ');
      parts.add(
        'named: $namedString',
      );
    }
    parts.add('loadingUnit: ${loadingUnit.name}');
    return 'CallWithArguments(${parts.join(', ')})';
  }
}

/// A reference to a tear-off use of the [Definition]. This means that we can't
/// record the arguments possibly passed to the method somewhere else.
final class CallTearoff extends CallReference {
  const CallTearoff({required super.loadingUnit, super.receiver});

  @override
  int get _orderingTypePriority => 1;

  @override
  int _compareToCallInternal(covariant CallTearoff other) => 0;

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      CallTearoff(
        loadingUnit: context.canonicalizeLoadingUnit(loadingUnit),
        receiver: receiver != null
            ? context.canonicalizeConstant(receiver!)
            : null,
      );

  @override
  CallReference _filter({String? definitionPackageName}) => CallTearoff(
    loadingUnit: loadingUnit,
    receiver: receiver?.filter(definitionPackageName: definitionPackageName),
  );

  @override
  TearoffCallSyntax _toSyntax(SerializationContext context) =>
      TearoffCallSyntax(
        loadingUnitIndex: context.loadingUnits[loadingUnit]!,
        receiver: receiver != null ? context.constants[receiver!] : null,
      );

  @override
  @visibleForTesting
  bool semanticEquals(
    CallReference other, {
    bool allowTearoffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    switch (other) {
      case CallWithArguments():
        return false;
      case CallTearoff():
        return _semanticEqualsCall(
          other,
          uriMapping: uriMapping,
          loadingUnitMapping: loadingUnitMapping,
          allowMoreConstArguments: allowMoreConstArguments,
          allowPromotionOfUnsupported: allowPromotionOfUnsupported,
        );
    }
  }

  @override
  String toString() {
    final parts = <String>[];
    if (receiver != null) {
      parts.add('receiver: $receiver');
    }
    parts.add('loadingUnit: ${loadingUnit.name}');
    return 'CallTearoff(${parts.join(', ')})';
  }
}

// TODO(https://github.com/dart-lang/native/issues/2908): Support enum
// constant instances here as well. Enums cannot have constructor calls or
// constructor tearoffs though. So how to do the type hierarchy here?
// TODO(https://github.com/dart-lang/native/issues/3057): Extension type const
// instances?
//
sealed class InstanceReference extends Reference {
  const InstanceReference({required super.loadingUnit});

  @override
  int _compareToInternal(covariant InstanceReference other) =>
      _compareToInstanceInternal(other);

  int _compareToInstanceInternal(covariant InstanceReference other);

  static InstanceReference _fromSyntax(
    InstanceSyntax syntax,
    DeserializationContext context,
  ) => switch (syntax) {
    ConstantInstanceSyntax(
      :final constantIndex,
      :final loadingUnitIndex,
    ) =>
      InstanceConstantReference(
        instanceConstant: context.constants[constantIndex] as Constant,
        loadingUnit: context.loadingUnits[loadingUnitIndex],
      ),
    CreationInstanceSyntax(
      :final named,
      :final positional,
      :final loadingUnitIndex,
      :final definitionIndex,
    ) =>
      InstanceCreationReference(
        definition: context.definitions[definitionIndex],
        positionalArguments: (positional ?? [])
            .map((index) => CallReference._argumentFromSyntax(index, context))
            .toList(),
        namedArguments: (named ?? {}).map(
          (name, index) => MapEntry(
            name,
            CallReference._argumentFromSyntax(index, context),
          ),
        ),
        loadingUnit: context.loadingUnits[loadingUnitIndex],
      ),
    TearoffInstanceSyntax(
      :final loadingUnitIndex,
      :final definitionIndex,
    ) =>
      ConstructorTearoffReference(
        definition: context.definitions[definitionIndex],
        loadingUnit: context.loadingUnits[loadingUnitIndex],
      ),
    _ => throw UnimplementedError('Unknown InstanceSyntax type'),
  };

  InstanceSyntax _toSyntax(SerializationContext context);

  @override
  InstanceReference _filter({String? definitionPackageName});

  /// Compares this [InstanceReference] with [other] for semantic equality.
  ///
  /// The loading unit can be mapped with [loadingUnitMapping].
  ///
  /// The URI in the location can be mapped with [uriMapping].
  @visibleForTesting
  bool semanticEquals(
    InstanceReference other, {
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
  });
}

final class InstanceConstantReference extends InstanceReference {
  final Constant instanceConstant;

  const InstanceConstantReference({
    required this.instanceConstant,
    required super.loadingUnit,
  });

  @override
  int get _orderingTypePriority => 2;

  @override
  int _compareToInstanceInternal(covariant InstanceConstantReference other) =>
      instanceConstant.compareTo(other.instanceConstant);

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      InstanceConstantReference(
        loadingUnit: context.canonicalizeLoadingUnit(loadingUnit),
        instanceConstant: context.canonicalizeConstant(instanceConstant),
      );

  @override
  InstanceReference _filter({String? definitionPackageName}) =>
      InstanceConstantReference(
        loadingUnit: loadingUnit,
        instanceConstant:
            instanceConstant.filter(
                  definitionPackageName: definitionPackageName,
                )
                as Constant,
      );

  @override
  ConstantInstanceSyntax _toSyntax(SerializationContext context) =>
      ConstantInstanceSyntax(
        constantIndex: context.constants[instanceConstant]!,
        loadingUnitIndex: context.loadingUnits[loadingUnit]!,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is InstanceConstantReference &&
        other.instanceConstant == instanceConstant;
  }

  @override
  int get hashCode =>
      cacheHashCode(() => Object.hash(instanceConstant, super.hashCode));

  @override
  @visibleForTesting
  bool semanticEquals(
    InstanceReference other, {
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
  }) {
    if (other is! InstanceConstantReference) return false;
    // ignore: invalid_use_of_visible_for_testing_member
    if (!instanceConstant.semanticEquals(
      other.instanceConstant,
      allowPromotionOfUnsupported: allowPromotionOfUnsupported,
    )) {
      return false;
    }
    return _semanticEqualsShared(
      other,
      uriMapping: uriMapping,
      loadingUnitMapping: loadingUnitMapping,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    parts.add('instanceConstant: $instanceConstant');
    parts.add('loadingUnit: ${loadingUnit.name}');
    return 'InstanceConstantReference(${parts.join(', ')})';
  }
}

/// Recorded for generative constructor invocations (non-const).
///
/// Any non-provided arguments with default values will have their default
/// values filled in.
final class InstanceCreationReference extends InstanceReference
    with _HasArguments {
  final Definition definition;
  @override
  final List<MaybeConstant> positionalArguments;
  @override
  final Map<String, MaybeConstant> namedArguments;

  const InstanceCreationReference({
    required this.definition,
    required this.positionalArguments,
    required this.namedArguments,
    required super.loadingUnit,
  });

  @override
  int get _orderingTypePriority => 3;

  @override
  int _compareToInstanceInternal(covariant InstanceCreationReference other) {
    final result = definition.compareTo(other.definition);
    if (result != 0) return result;
    return _compareToArguments(other);
  }

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      InstanceCreationReference(
        definition: context.canonicalizeDefinition(definition),
        loadingUnit: context.canonicalizeLoadingUnit(loadingUnit),
        positionalArguments: _canonicalizePositional(context),
        namedArguments: _canonicalizeNamed(context),
      );

  @override
  InstanceReference _filter({String? definitionPackageName}) =>
      InstanceCreationReference(
        definition: definition,
        loadingUnit: loadingUnit,
        positionalArguments: _filterPositional(
          definitionPackageName: definitionPackageName,
        ),
        namedArguments: _filterNamed(
          definitionPackageName: definitionPackageName,
        ),
      );

  @override
  CreationInstanceSyntax _toSyntax(SerializationContext context) {
    final namedArgs = <String, int>{};
    for (final entry in namedArguments.entries) {
      namedArgs[entry.key] = context.constants[entry.value]!;
    }

    return CreationInstanceSyntax(
      definitionIndex: context.definitions[definition]!,
      loadingUnitIndex: context.loadingUnits[loadingUnit]!,
      named: namedArgs.isNotEmpty ? namedArgs : null,
      positional: positionalArguments.isEmpty
          ? null
          : [
              for (final argument in positionalArguments)
                context.constants[argument]!,
            ],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is InstanceCreationReference &&
        other.definition == definition &&
        deepEquals(other.positionalArguments, positionalArguments) &&
        deepEquals(other.namedArguments, namedArguments);
  }

  @override
  int get hashCode => cacheHashCode(
    () => Object.hash(
      definition,
      deepHash(positionalArguments),
      deepHash(namedArguments),
      super.hashCode,
    ),
  );

  @override
  @visibleForTesting
  bool semanticEquals(
    InstanceReference other, {
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
  }) {
    if (other is! InstanceCreationReference) return false;
    // ignore: invalid_use_of_visible_for_testing_member
    if (!definition.semanticEquals(other.definition, uriMapping: uriMapping)) {
      return false;
    }
    if (!_semanticEqualsArguments(
      other,
      allowMoreConstArguments: allowMoreConstArguments,
      allowPromotionOfUnsupported: allowPromotionOfUnsupported,
    )) {
      return false;
    }
    return _semanticEqualsShared(
      other,
      uriMapping: uriMapping,
      loadingUnitMapping: loadingUnitMapping,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    parts.add('definition: $definition');
    if (positionalArguments.isNotEmpty) {
      parts.add('positional: ${positionalArguments.join(', ')}');
    }
    if (namedArguments.isNotEmpty) {
      final namedString = namedArguments.entries
          .map((e) => '${e.key}=${e.value}')
          .join(', ');
      parts.add(
        'named: $namedString',
      );
    }
    parts.add('loadingUnit: ${loadingUnit.name}');
    return 'InstanceCreationReference(${parts.join(', ')})';
  }
}

final class ConstructorTearoffReference extends InstanceReference {
  final Definition definition;

  const ConstructorTearoffReference({
    required this.definition,
    required super.loadingUnit,
  });

  @override
  int get _orderingTypePriority => 4;

  @override
  int _compareToInstanceInternal(covariant ConstructorTearoffReference other) =>
      definition.compareTo(other.definition);

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      ConstructorTearoffReference(
        definition: context.canonicalizeDefinition(definition),
        loadingUnit: context.canonicalizeLoadingUnit(loadingUnit),
      );

  @override
  InstanceReference _filter({String? definitionPackageName}) => this;

  @override
  TearoffInstanceSyntax _toSyntax(SerializationContext context) =>
      TearoffInstanceSyntax(
        definitionIndex: context.definitions[definition]!,
        loadingUnitIndex: context.loadingUnits[loadingUnit]!,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is ConstructorTearoffReference &&
        other.definition == definition;
  }

  @override
  int get hashCode =>
      cacheHashCode(() => Object.hash(definition, super.hashCode));

  @override
  @visibleForTesting
  bool semanticEquals(
    InstanceReference other, {
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
    bool allowMoreConstArguments = false,
    bool allowPromotionOfUnsupported = false,
  }) {
    if (other is! ConstructorTearoffReference) return false;
    // ignore: invalid_use_of_visible_for_testing_member
    if (!definition.semanticEquals(other.definition, uriMapping: uriMapping)) {
      return false;
    }
    return _semanticEqualsShared(
      other,
      uriMapping: uriMapping,
      loadingUnitMapping: loadingUnitMapping,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    parts.add('definition: $definition');
    parts.add('loadingUnit: ${loadingUnit.name}');
    return 'ConstructorTearoffReference(${parts.join(', ')})';
  }
}

/// Package private (protected) methods for [Reference].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension ReferenceProtected on Reference {
  Reference canonicalizeChildren(CanonicalizationContext context) =>
      _canonicalizeChildren(context);

  Reference filter({String? definitionPackageName}) =>
      _filter(definitionPackageName: definitionPackageName);

  int compareTo(Reference other) => _compareTo(other);
}

/// Package private (protected) methods for [CallReference].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension CallReferenceProtected on CallReference {
  CallSyntax toSyntax(SerializationContext context) => _toSyntax(context);

  CallReference canonicalizeChildren(CanonicalizationContext context) =>
      _canonicalizeChildren(context) as CallReference;

  CallReference filter({String? definitionPackageName}) =>
      _filter(definitionPackageName: definitionPackageName);

  int compareTo(Reference other) => _compareTo(other);

  static CallReference fromSyntax(
    CallSyntax syntax,
    DeserializationContext context,
  ) => CallReference._fromSyntax(syntax, context);
}

/// Package private (protected) methods for [InstanceReference].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension InstanceReferenceProtected on InstanceReference {
  InstanceSyntax toSyntax(SerializationContext context) => _toSyntax(context);

  InstanceReference canonicalizeChildren(CanonicalizationContext context) =>
      _canonicalizeChildren(context) as InstanceReference;

  InstanceReference filter({String? definitionPackageName}) =>
      _filter(definitionPackageName: definitionPackageName);

  int compareTo(Reference other) => _compareTo(other);

  static InstanceReference fromSyntax(
    InstanceSyntax syntax,
    DeserializationContext context,
  ) => InstanceReference._fromSyntax(syntax, context);
}
