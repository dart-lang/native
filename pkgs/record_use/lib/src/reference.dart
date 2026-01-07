// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'constant.dart';
import 'helper.dart';
import 'identifier.dart';
import 'location.dart' show Location;
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
  final Location? location;

  const Reference({required this.loadingUnit, required this.location});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reference &&
        other.loadingUnit == loadingUnit &&
        other.location == location;
  }

  @override
  int get hashCode => Object.hash(loadingUnit, location);

  Map<String, Object?> toJson(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  ) => _toSyntax(constants, locations).json;

  JsonObjectSyntax _toSyntax(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  );

  bool _semanticEqualsShared(
    Reference other,
    Map<String, String>? loadingUnitMapping,
    String Function(String)? uriMapping,
    bool allowLocationNull,
  ) {
    final mappedLoadingUnit = loadingUnit == null || loadingUnitMapping == null
        ? loadingUnit
        : loadingUnitMapping[loadingUnit];
    if (other.loadingUnit != mappedLoadingUnit) {
      return false;
    }
    if ((location == null) != (other.location == null)) {
      return false;
    }
    if (location != null &&
        other.location != null &&
        // ignore: invalid_use_of_visible_for_testing_member
        !location!.semanticEquals(
          other.location!,
          uriMapping: uriMapping,
          allowLocationNull: allowLocationNull,
        )) {
      return false;
    }
    return true;
  }
}

/// A reference to a call to some [Identifier].
///
/// This might be an actual call, in which case we record the arguments, or a
/// tear-off, in which case we can't record the arguments.
sealed class CallReference extends Reference {
  const CallReference({required super.loadingUnit, required super.location});

  static CallReference fromJson(
    Map<String, Object?> json,
    List<Constant> constants,
    List<Location> locations,
  ) => _fromSyntax(CallSyntax.fromJson(json), constants, locations);

  static CallReference _fromSyntax(
    CallSyntax syntax,
    List<Constant> constants,
    List<Location> locations,
  ) {
    final locationIndex = syntax.at;
    final location = locationIndex == null ? null : locations[locationIndex];
    return switch (syntax) {
      TearoffCallSyntax() => CallTearOff(
        loadingUnit: syntax.loadingUnit,
        location: location,
      ),
      WithArgumentsCallSyntax(
        :final named,
        :final positional,
        :final loadingUnit,
      ) =>
        CallWithArguments(
          positionalArguments: (positional ?? [])
              .map(
                (constantsIndex) =>
                    constantsIndex != null ? constants[constantsIndex] : null,
              )
              .toList(),
          namedArguments: (named ?? {}).map(
            (name, constantsIndex) => MapEntry(name, constants[constantsIndex]),
          ),
          loadingUnit: loadingUnit,
          location: location,
        ),
      _ => throw UnimplementedError('Unknown CallSyntax type'),
    };
  }

  @override
  CallSyntax _toSyntax(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  );

  @visibleForTesting
  bool semanticEquals(
    CallReference other, {
    bool allowTearOffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    Map<String, String>? loadingUnitMapping,
    String Function(String)? uriMapping,
    bool allowLocationNull = false,
  });
}

/// A reference to a call to some [Identifier] with [positionalArguments] and
/// [namedArguments].
final class CallWithArguments extends CallReference {
  final List<Constant?> positionalArguments;
  final Map<String, Constant?> namedArguments;

  const CallWithArguments({
    required this.positionalArguments,
    required this.namedArguments,
    required super.loadingUnit,
    required super.location,
  });

  @override
  WithArgumentsCallSyntax _toSyntax(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  ) {
    final namedArgs = <String, int>{};
    for (final entry in namedArguments.entries) {
      if (entry.value != null) {
        final index = constants[entry.value!];
        if (index != null) {
          namedArgs[entry.key] = index;
        }
      }
    }

    return WithArgumentsCallSyntax(
      at: locations[location]!,
      loadingUnit: loadingUnit!,
      named: namedArgs.isNotEmpty ? namedArgs : null,
      positional: positionalArguments.isEmpty
          ? null
          : positionalArguments.map((constant) => constants[constant]).toList(),
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
    bool allowTearOffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    Map<String, String>? loadingUnitMapping,
    String Function(String)? uriMapping,
    bool allowLocationNull = false,
  }) {
    switch (other) {
      case CallWithArguments():
        for (final (index, argument) in other.positionalArguments.indexed) {
          if (argument == null && allowMoreConstArguments) {
            continue;
          }
          if (argument != positionalArguments[index]) {
            return false;
          }
        }
        for (final entry in other.namedArguments.entries) {
          final name = entry.key;
          final argument = entry.value;
          if (argument == null && allowMoreConstArguments) {
            continue;
          }
          if (argument != namedArguments[name]) {
            return false;
          }
        }
        return _semanticEqualsShared(
          other,
          loadingUnitMapping,
          uriMapping,
          allowLocationNull,
        );
      case CallTearOff():
        return allowTearOffToStaticPromotion;
    }
  }
}

/// A reference to a tear-off use of the [Identifier]. This means that we can't
/// record the arguments possibly passed to the method somewhere else.
final class CallTearOff extends CallReference {
  const CallTearOff({required super.loadingUnit, required super.location});

  @override
  TearoffCallSyntax _toSyntax(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  ) => TearoffCallSyntax(at: locations[location]!, loadingUnit: loadingUnit!);

  @override
  @visibleForTesting
  bool semanticEquals(
    CallReference other, {
    bool allowTearOffToStaticPromotion = false,
    bool allowMoreConstArguments = false,
    Map<String, String>? loadingUnitMapping,
    String Function(String)? uriMapping,
    bool allowLocationNull = false,
  }) {
    switch (other) {
      case CallWithArguments():
        return false;
      case CallTearOff():
        return _semanticEqualsShared(
          other,
          loadingUnitMapping,
          uriMapping,
          allowLocationNull,
        );
    }
  }
}

final class InstanceReference extends Reference {
  final InstanceConstant instanceConstant;

  const InstanceReference({
    required this.instanceConstant,
    required super.loadingUnit,
    required super.location,
  });

  factory InstanceReference.fromJson(
    Map<String, Object?> json,
    List<Constant> constants,
    List<Location> locations,
  ) => _fromSyntax(InstanceSyntax.fromJson(json), constants, locations);

  static InstanceReference _fromSyntax(
    InstanceSyntax syntax,
    List<Constant> constants,
    List<Location> locations,
  ) {
    final locationIndex = syntax.at;
    final location = locationIndex == null ? null : locations[locationIndex];
    return InstanceReference(
      instanceConstant: constants[syntax.constantIndex] as InstanceConstant,
      loadingUnit: syntax.loadingUnit,
      location: location,
    );
  }

  @override
  InstanceSyntax _toSyntax(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  ) => InstanceSyntax(
    at: locations[location]!,
    constantIndex: constants[instanceConstant]!,
    loadingUnit: loadingUnit!,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is InstanceReference &&
        other.instanceConstant == instanceConstant;
  }

  @override
  int get hashCode => Object.hash(instanceConstant, super.hashCode);

  @visibleForTesting
  bool semanticEquals(
    InstanceReference other, {
    Map<String, String>? loadingUnitMapping,
    String Function(String)? uriMapping,
    bool allowLocationNull = false,
  }) {
    if (!deepEquals(instanceConstant, other.instanceConstant)) {
      return false;
    }
    return _semanticEqualsShared(
      other,
      loadingUnitMapping,
      uriMapping,
      allowLocationNull,
    );
  }
}

/// Package private (protected) methods for [CallReference].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension CallReferenceProtected on CallReference {
  CallSyntax toSyntax(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  ) => _toSyntax(constants, locations);

  static CallReference fromSyntax(
    CallSyntax syntax,
    List<Constant> constants,
    List<Location> locations,
  ) => CallReference._fromSyntax(syntax, constants, locations);
}

/// Package private (protected) methods for [InstanceReference].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension InstanceReferenceProtected on InstanceReference {
  InstanceSyntax toSyntax(
    Map<Constant, int> constants,
    Map<Location, int> locations,
  ) => _toSyntax(constants, locations);

  static InstanceReference fromSyntax(
    InstanceSyntax syntax,
    List<Constant> constants,
    List<Location> locations,
  ) => InstanceReference._fromSyntax(syntax, constants, locations);
}
