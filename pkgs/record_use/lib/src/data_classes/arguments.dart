// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

class Arguments {
  ConstArguments constArguments;
  NonConstArguments nonConstArguments;

  Arguments({
    ConstArguments? constArguments,
    NonConstArguments? nonConstArguments,
  })  : constArguments = constArguments ?? ConstArguments(),
        nonConstArguments = nonConstArguments ?? NonConstArguments();

  factory Arguments.fromJson(Map<String, dynamic> json) {
    final constJson = json['const'] as Map<String, dynamic>?;
    final nonConstJson = json['nonConst'] as Map<String, dynamic>?;
    return Arguments(
      constArguments:
          constJson != null ? ConstArguments.fromJson(constJson) : null,
      nonConstArguments: nonConstJson != null
          ? NonConstArguments.fromJson(nonConstJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final hasConst =
        constArguments.named.isNotEmpty || constArguments.positional.isNotEmpty;
    final hasNonConst = nonConstArguments.named.isNotEmpty ||
        nonConstArguments.positional.isNotEmpty;
    return {
      if (hasConst) 'const': constArguments.toJson(),
      if (hasNonConst) 'nonConst': nonConstArguments.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Arguments &&
        other.constArguments == constArguments &&
        other.nonConstArguments == nonConstArguments;
  }

  @override
  int get hashCode => constArguments.hashCode ^ nonConstArguments.hashCode;
}

class ConstArguments {
  Map<int, dynamic> positional;
  Map<String, dynamic> named;

  ConstArguments({Map<int, dynamic>? positional, Map<String, dynamic>? named})
      : named = named ?? {},
        positional = positional ?? {};

  factory ConstArguments.fromJson(Map<String, dynamic> json) => ConstArguments(
        positional: json['positional'] != null
            ? (json['positional'] as Map<String, dynamic>)
                .map((key, value) => MapEntry(int.parse(key), value))
            : {},
        named:
            json['named'] != null ? json['named'] as Map<String, dynamic> : {},
      );

  Map<String, dynamic> toJson() => {
        if (positional.isNotEmpty)
          'positional':
              positional.map((key, value) => MapEntry(key.toString(), value)),
        if (named.isNotEmpty) 'named': named,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is ConstArguments &&
        mapEquals(other.positional, positional) &&
        mapEquals(other.named, named);
  }

  @override
  int get hashCode => positional.hashCode ^ named.hashCode;
}

class NonConstArguments {
  List<int> positional;
  List<String> named; // Assuming named arguments are strings (keys)

  NonConstArguments({List<int>? positional, List<String>? named})
      : named = named ?? [],
        positional = positional ?? [];

  factory NonConstArguments.fromJson(Map<String, dynamic> json) =>
      NonConstArguments(
        positional:
            json['positional'] != null ? json['positional'] as List<int> : [],
        named: json['named'] != null ? json['named'] as List<String> : [],
      );

  Map<String, dynamic> toJson() => {
        if (positional.isNotEmpty) 'positional': positional,
        if (named.isNotEmpty) 'named': named,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is NonConstArguments &&
        listEquals(other.positional, positional) &&
        listEquals(other.named, named);
  }

  @override
  int get hashCode => positional.hashCode ^ named.hashCode;
}
