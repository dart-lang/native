// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'constant.dart';
import 'definition.dart';
import 'helper.dart';
import 'serialization_context.dart';
import 'syntax.g.dart';

/// A reference to *something*.
///
/// The something might be a call or an instance, matching a [CallReference] or
/// an [InstanceReference].
/// All references have in common that they occur in a [loadingUnit], which we
/// record to be able to piece together which loading units are "related", for
/// example all needing the same asset.
sealed class Reference {
  final String? loadingUnit;

  const Reference({required this.loadingUnit});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reference && other.loadingUnit == loadingUnit;
  }

  @override
  int get hashCode => loadingUnit.hashCode;

  bool _semanticEqualsShared(
    Reference other, {
    String Function(String)? uriMapping,
    String Function(String)? loadingUnitMapping,
  }) =>
      (loadingUnit == null || loadingUnitMapping == null
          ? loadingUnit
          : loadingUnitMapping(loadingUnit!)) ==
      other.loadingUnit;
}

/// A reference to a call to some [Definition].
///
/// This might be an actual call, in which case we record the arguments, or a
/// tear-off, in which case we can't record the arguments.
sealed class CallReference extends Reference {
  const CallReference({required super.loadingUnit});

  static CallReference _fromSyntax(
    CallSyntax syntax,
    DeserializationContext context,
  ) => switch (syntax) {
    TearoffCallSyntax() => CallTearoff(
      loadingUnit: context.loadingUnits[syntax.loadingUnitIndices.first],
    ),
    WithArgumentsCallSyntax(
      :final named,
      :final positional,
      :final loadingUnitIndices,
    ) =>
      CallWithArguments(
        positionalArguments: (positional ?? [])
            .map((index) => _argumentFromSyntax(index, context))
            .toList(),
        namedArguments: (named ?? {}).map(
          (name, index) => MapEntry(name, _argumentFromSyntax(index, context)),
        ),
        loadingUnit: context.loadingUnits[loadingUnitIndices.first],
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
}

/// A reference to a call to some [Definition] with [positionalArguments] and
/// [namedArguments].
final class CallWithArguments extends CallReference {
  final List<MaybeConstant> positionalArguments;
  final Map<String, MaybeConstant> namedArguments;

  const CallWithArguments({
    required this.positionalArguments,
    required this.namedArguments,
    required super.loadingUnit,
  });

  @override
  WithArgumentsCallSyntax _toSyntax(SerializationContext context) {
    final namedArgs = <String, int?>{};
    for (final entry in namedArguments.entries) {
      namedArgs[entry.key] = switch (entry.value) {
        final Constant c => context.constants[c],
        NonConstant() => null,
      };
    }

    return WithArgumentsCallSyntax(
      loadingUnitIndices: [context.loadingUnits[loadingUnit!]!],
      named: namedArgs.isNotEmpty ? namedArgs : null,
      positional: positionalArguments.isEmpty
          ? null
          : positionalArguments
                .map(
                  (argument) => switch (argument) {
                    final Constant c => context.constants[c],
                    NonConstant() => null,
                  },
                )
                .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is CallWithArguments &&
        deepEquals(other.positionalArguments, positionalArguments) &&
        deepEquals(other.namedArguments, namedArguments);
  }

  @override
  int get hashCode => Object.hash(
    deepHash(positionalArguments),
    deepHash(namedArguments),
    super.hashCode,
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
        return _semanticEqualsShared(
          other,
          uriMapping: uriMapping,
          loadingUnitMapping: loadingUnitMapping,
        );
      case CallTearoff():
        return allowTearoffToStaticPromotion;
    }
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
    if (loadingUnit != null) {
      parts.add('loadingUnit: $loadingUnit');
    }
    return 'CallWithArguments(${parts.join(', ')})';
  }
}

/// A reference to a tear-off use of the [Definition]. This means that we can't
/// record the arguments possibly passed to the method somewhere else.
final class CallTearoff extends CallReference {
  const CallTearoff({required super.loadingUnit});

  @override
  TearoffCallSyntax _toSyntax(SerializationContext context) =>
      TearoffCallSyntax(
        loadingUnitIndices: [context.loadingUnits[loadingUnit!]!],
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
        return _semanticEqualsShared(
          other,
          uriMapping: uriMapping,
          loadingUnitMapping: loadingUnitMapping,
        );
    }
  }
}

sealed class InstanceReference extends Reference {
  const InstanceReference({required super.loadingUnit});

  static InstanceReference _fromSyntax(
    InstanceSyntax syntax,
    DeserializationContext context,
  ) => switch (syntax) {
    ConstantInstanceSyntax(
      :final constantIndex,
      :final loadingUnitIndices,
    ) =>
      InstanceConstantReference(
        instanceConstant: context.constants[constantIndex] as InstanceConstant,
        loadingUnit: context.loadingUnits[loadingUnitIndices.first],
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
        loadingUnit: context.loadingUnits[loadingUnitIndices.first],
      ),
    TearoffInstanceSyntax(:final loadingUnitIndices) =>
      ConstructorTearoffReference(
        loadingUnit: context.loadingUnits[loadingUnitIndices.first],
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
  final InstanceConstant instanceConstant;

  const InstanceConstantReference({
    required this.instanceConstant,
    required super.loadingUnit,
  });

  @override
  ConstantInstanceSyntax _toSyntax(SerializationContext context) =>
      ConstantInstanceSyntax(
        constantIndex: context.constants[instanceConstant]!,
        loadingUnitIndices: [context.loadingUnits[loadingUnit!]!],
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is InstanceConstantReference &&
        other.instanceConstant == instanceConstant;
  }

  @override
  int get hashCode => Object.hash(instanceConstant, super.hashCode);

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
}

final class InstanceCreationReference extends InstanceReference {
  final List<MaybeConstant> positionalArguments;
  final Map<String, MaybeConstant> namedArguments;

  const InstanceCreationReference({
    required this.positionalArguments,
    required this.namedArguments,
    required super.loadingUnit,
  });

  @override
  CreationInstanceSyntax _toSyntax(SerializationContext context) {
    final namedArgs = <String, int?>{};
    for (final entry in namedArguments.entries) {
      namedArgs[entry.key] = switch (entry.value) {
        final Constant c => context.constants[c],
        NonConstant() => null,
      };
    }

    return CreationInstanceSyntax(
      loadingUnitIndices: [context.loadingUnits[loadingUnit!]!],
      named: namedArgs.isNotEmpty ? namedArgs : null,
      positional: positionalArguments.isEmpty
          ? null
          : positionalArguments
                .map(
                  (argument) => switch (argument) {
                    final Constant c => context.constants[c],
                    NonConstant() => null,
                  },
                )
                .toList(),
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
  int get hashCode => Object.hash(
    deepHash(positionalArguments),
    deepHash(namedArguments),
    super.hashCode,
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
}

final class ConstructorTearoffReference extends InstanceReference {
  const ConstructorTearoffReference({required super.loadingUnit});

  @override
  TearoffInstanceSyntax _toSyntax(SerializationContext context) =>
      TearoffInstanceSyntax(
        loadingUnitIndices: [context.loadingUnits[loadingUnit!]!],
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
}

/// Package private (protected) methods for [CallReference].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension CallReferenceProtected on CallReference {
  CallSyntax toSyntax(SerializationContext context) => _toSyntax(context);

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

  static InstanceReference fromSyntax(
    InstanceSyntax syntax,
    DeserializationContext context,
  ) => InstanceReference._fromSyntax(syntax, context);
}
