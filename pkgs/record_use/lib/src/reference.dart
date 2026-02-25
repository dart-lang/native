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

/// A reference to *something*.
///
/// The something might be a call or an instance, matching a [CallReference] or
/// an [InstanceReference].
/// All references have in common that they occur in [loadingUnits], which we
/// record to be able to piece together which loading units are "related", for
/// example all needing the same asset.
sealed class Reference {
  final List<LoadingUnit> loadingUnits;

  const Reference({required this.loadingUnits});

  /// Canonicalizes this [Reference].
  Reference _canonicalizeChildren(CanonicalizationContext context);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reference && deepEquals(other.loadingUnits, loadingUnits);
  }

  @override
  int get hashCode => cacheHashCode(() => deepHash(loadingUnits));

  bool _semanticEqualsShared(
    Reference other, {
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) {
    if (loadingUnits.length != other.loadingUnits.length) return false;
    for (var i = 0; i < loadingUnits.length; i++) {
      final unit = loadingUnits[i].name;
      final otherUnit = other.loadingUnits[i].name;
      final mappedUnit = loadingUnitMapping == null
          ? unit
          : loadingUnitMapping(unit);
      if (mappedUnit != otherUnit) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    if (loadingUnits.isEmpty) return '[]';
    return loadingUnits.map((u) => u.name).join(', ');
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

  const CallReference({required super.loadingUnits, this.receiver});

  static CallReference _fromSyntax(
    CallSyntax syntax,
    DeserializationContext context,
  ) => switch (syntax) {
    TearoffCallSyntax(:final receiver) => CallTearoff(
      loadingUnits: syntax.loadingUnitIndices
          .map((index) => context.loadingUnits[index])
          .toList(),
      receiver: receiver != null ? context.constants[receiver] : null,
    ),
    WithArgumentsCallSyntax(
      :final named,
      :final positional,
      :final loadingUnitIndices,
      :final receiver,
    ) =>
      CallWithArguments(
        positionalArguments: (positional ?? [])
            .map((index) => _argumentFromSyntax(index, context))
            .toList(),
        namedArguments: (named ?? {}).map(
          (name, index) => MapEntry(name, _argumentFromSyntax(index, context)),
        ),
        loadingUnits: loadingUnitIndices
            .map((index) => context.loadingUnits[index])
            .toList(),
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
final class CallWithArguments extends CallReference {
  final List<MaybeConstant> positionalArguments;
  final Map<String, MaybeConstant> namedArguments;

  const CallWithArguments({
    required this.positionalArguments,
    required this.namedArguments,
    required super.loadingUnits,
    super.receiver,
  });

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) {
    final sortedNamedArgs = namedArguments.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return CallWithArguments(
      loadingUnits: [
        for (final u in loadingUnits) context.canonicalizeLoadingUnit(u),
      ],
      receiver: receiver != null
          ? context.canonicalizeConstant(receiver!)
          : null,
      positionalArguments: [
        for (final c in positionalArguments) context.canonicalizeConstant(c),
      ],
      namedArguments: {
        for (final e in sortedNamedArgs)
          e.key: context.canonicalizeConstant(e.value),
      },
    );
  }

  @override
  WithArgumentsCallSyntax _toSyntax(SerializationContext context) {
    final namedArgs = <String, int>{};
    for (final entry in namedArguments.entries) {
      namedArgs[entry.key] = context.constants[entry.value]!;
    }

    return WithArgumentsCallSyntax(
      loadingUnitIndices: [
        for (final unit in loadingUnits) context.loadingUnits[unit]!,
      ],
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
    if (loadingUnits.isNotEmpty) {
      parts.add('loadingUnits: ${loadingUnits.map((u) => u.name).join(', ')}');
    }
    return 'CallWithArguments(${parts.join(', ')})';
  }
}

/// A reference to a tear-off use of the [Definition]. This means that we can't
/// record the arguments possibly passed to the method somewhere else.
final class CallTearoff extends CallReference {
  const CallTearoff({required super.loadingUnits, super.receiver});

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      CallTearoff(
        loadingUnits: [
          for (final u in loadingUnits) context.canonicalizeLoadingUnit(u),
        ],
        receiver: receiver != null
            ? context.canonicalizeConstant(receiver!)
            : null,
      );

  @override
  TearoffCallSyntax _toSyntax(SerializationContext context) =>
      TearoffCallSyntax(
        loadingUnitIndices: [
          for (final unit in loadingUnits) context.loadingUnits[unit]!,
        ],
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
    if (loadingUnits.isNotEmpty) {
      parts.add('loadingUnits: ${loadingUnits.map((u) => u.name).join(', ')}');
    }
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
  const InstanceReference({required super.loadingUnits});

  static InstanceReference _fromSyntax(
    InstanceSyntax syntax,
    DeserializationContext context,
  ) => switch (syntax) {
    ConstantInstanceSyntax(
      :final constantIndex,
      :final loadingUnitIndices,
    ) =>
      InstanceConstantReference(
        instanceConstant: context.constants[constantIndex] as Constant,
        loadingUnits: loadingUnitIndices
            .map((index) => context.loadingUnits[index])
            .toList(),
      ),
    CreationInstanceSyntax(
      :final named,
      :final positional,
      :final loadingUnitIndices,
    ) =>
      InstanceCreationReference(
        positionalArguments: (positional ?? [])
            .map((index) => CallReference._argumentFromSyntax(index, context))
            .toList(),
        namedArguments: (named ?? {}).map(
          (name, index) => MapEntry(
            name,
            CallReference._argumentFromSyntax(index, context),
          ),
        ),
        loadingUnits: loadingUnitIndices
            .map((index) => context.loadingUnits[index])
            .toList(),
      ),
    TearoffInstanceSyntax(:final loadingUnitIndices) =>
      ConstructorTearoffReference(
        loadingUnits: loadingUnitIndices
            .map((index) => context.loadingUnits[index])
            .toList(),
      ),
    _ => throw UnimplementedError('Unknown InstanceSyntax type'),
  };

  InstanceSyntax _toSyntax(SerializationContext context);

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
    required super.loadingUnits,
  });

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      InstanceConstantReference(
        loadingUnits: [
          for (final u in loadingUnits) context.canonicalizeLoadingUnit(u),
        ],
        instanceConstant:
            context.canonicalizeConstant(instanceConstant) as Constant,
      );

  @override
  ConstantInstanceSyntax _toSyntax(SerializationContext context) =>
      ConstantInstanceSyntax(
        constantIndex: context.constants[instanceConstant]!,
        loadingUnitIndices: [
          for (final unit in loadingUnits) context.loadingUnits[unit]!,
        ],
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
    if (loadingUnits.isNotEmpty) {
      parts.add('loadingUnits: ${loadingUnits.map((u) => u.name).join(', ')}');
    }
    return 'InstanceConstantReference(${parts.join(', ')})';
  }
}

final class InstanceCreationReference extends InstanceReference {
  final List<MaybeConstant> positionalArguments;
  final Map<String, MaybeConstant> namedArguments;

  const InstanceCreationReference({
    required this.positionalArguments,
    required this.namedArguments,
    required super.loadingUnits,
  });

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) {
    final sortedNamedArgs = namedArguments.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return InstanceCreationReference(
      loadingUnits: [
        for (final u in loadingUnits) context.canonicalizeLoadingUnit(u),
      ],
      positionalArguments: [
        for (final c in positionalArguments) context.canonicalizeConstant(c),
      ],
      namedArguments: {
        for (final e in sortedNamedArgs)
          e.key: context.canonicalizeConstant(e.value),
      },
    );
  }

  @override
  CreationInstanceSyntax _toSyntax(SerializationContext context) {
    final namedArgs = <String, int>{};
    for (final entry in namedArguments.entries) {
      namedArgs[entry.key] = context.constants[entry.value]!;
    }

    return CreationInstanceSyntax(
      loadingUnitIndices: [
        for (final unit in loadingUnits) context.loadingUnits[unit]!,
      ],
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
        deepEquals(other.positionalArguments, positionalArguments) &&
        deepEquals(other.namedArguments, namedArguments);
  }

  @override
  int get hashCode => cacheHashCode(
    () => Object.hash(
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
    return _semanticEqualsShared(
      other,
      uriMapping: uriMapping,
      loadingUnitMapping: loadingUnitMapping,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
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
    if (loadingUnits.isNotEmpty) {
      parts.add('loadingUnits: ${loadingUnits.map((u) => u.name).join(', ')}');
    }
    return 'InstanceCreationReference(${parts.join(', ')})';
  }
}

final class ConstructorTearoffReference extends InstanceReference {
  const ConstructorTearoffReference({required super.loadingUnits});

  @override
  Reference _canonicalizeChildren(CanonicalizationContext context) =>
      ConstructorTearoffReference(
        loadingUnits: [
          for (final u in loadingUnits) context.canonicalizeLoadingUnit(u),
        ],
      );

  @override
  TearoffInstanceSyntax _toSyntax(SerializationContext context) =>
      TearoffInstanceSyntax(
        loadingUnitIndices: [
          for (final unit in loadingUnits) context.loadingUnits[unit]!,
        ],
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
    if (other is! ConstructorTearoffReference) return false;
    return _semanticEqualsShared(
      other,
      uriMapping: uriMapping,
      loadingUnitMapping: loadingUnitMapping,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    if (loadingUnits.isNotEmpty) {
      parts.add('loadingUnits: ${loadingUnits.map((u) => u.name).join(', ')}');
    }
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
}

/// Package private (protected) methods for [CallReference].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension CallReferenceProtected on CallReference {
  CallSyntax toSyntax(SerializationContext context) => _toSyntax(context);

  CallReference canonicalizeChildren(CanonicalizationContext context) =>
      _canonicalizeChildren(context) as CallReference;

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

  static InstanceReference fromSyntax(
    InstanceSyntax syntax,
    DeserializationContext context,
  ) => InstanceReference._fromSyntax(syntax, context);
}
