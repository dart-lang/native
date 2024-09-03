// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

class Arguments extends Equatable {
  final ConstArguments constArguments;
  final NonConstArguments nonConstArguments;

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
  List<Object?> get props => [constArguments, nonConstArguments];
}

class ConstArguments extends Equatable {
  final Map<int, dynamic> positional;
  final Map<String, dynamic> named;

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
  List<Object?> get props => [positional, named];
}

class NonConstArguments extends Equatable {
  final List<int> positional;
  final List<String> named;

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
  List<Object?> get props => [positional, named];
}
