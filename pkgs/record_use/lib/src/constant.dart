// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'helper.dart';
import 'syntax.g.dart';

/// A constant value that can be recorded and serialized.
///
/// This supports basic constants such as [bool]s or [int]s, as well as
/// [ListConstant], [MapConstant] or [InstanceConstant] for more complex
/// structures.
///
/// This follows the AST constant concept from the Dart SDK.
sealed class Constant {
  /// Creates a [Constant] object.
  const Constant();

  /// Converts this [Constant] object to a JSON representation.
  ///
  /// [constants] needs to be passed, as the [Constant]s are normalized and
  /// stored separately in the JSON.
  Map<String, Object?> toJson(Map<Constant, int> constants) =>
      _toSyntax(constants).json;

  /// Converts this [Constant] object to a syntax representation.
  ConstantSyntax _toSyntax(Map<Constant, int> constants);

  /// Converts this [Constant] to the value it represents.
  Object? toValue() => switch (this) {
    NullConstant() => null,
    final PrimitiveConstant p => p.value,
    final ListConstant<Constant> l => l.value.map((c) => c.toValue()).toList(),
    final MapConstant<Constant> m => m.value.map(
      (key, value) => MapEntry(key, value.toValue()),
    ),
    final InstanceConstant i => i.fields.map(
      (key, value) => MapEntry(key, value.toValue()),
    ),
  };

  /// Creates a [Constant] object from its JSON representation.
  ///
  /// [constants] needs to be passed, as the [Constant]s are normalized and
  /// stored separately in the JSON.
  static Constant fromJson(
    Map<String, Object?> value,
    List<Constant> constants,
  ) => _fromSyntax(ConstantSyntax.fromJson(value), constants);

  /// Creates a [Constant] object from its syntax representation.
  static Constant _fromSyntax(
    ConstantSyntax syntax,
    List<Constant> constants,
  ) => switch (syntax) {
    NullConstantSyntax() => const NullConstant(),
    BoolConstantSyntax(:final value) => BoolConstant(value),
    IntConstantSyntax(:final value) => IntConstant(value),
    StringConstantSyntax(:final value) => StringConstant(value),
    ListConstantSyntax(:final value) => ListConstant(
      value!.cast<int>().map((i) => constants[i]).toList(),
    ),
    MapConstantSyntax(:final value) => MapConstant(
      value.json.map((key, value) => MapEntry(key, constants[value as int])),
    ),
    InstanceConstantSyntax(value: final value) => InstanceConstant(
      fields: (value?.json ?? {}).map(
        (key, value) => MapEntry(key, constants[value as int]),
      ),
    ),
    _ => throw UnimplementedError(
      '"${syntax.type}" is not a supported constant type',
    ),
  };
}

/// Represents the `null` constant value.
final class NullConstant extends Constant {
  /// Creates a [NullConstant] object.
  const NullConstant() : super();

  @override
  NullConstantSyntax _toSyntax(Map<Constant, int> constants) =>
      NullConstantSyntax();

  @override
  bool operator ==(Object other) => other is NullConstant;

  @override
  int get hashCode => 0;
}

/// Represents a constant value of a primitive type.
sealed class PrimitiveConstant<T extends Object> extends Constant {
  /// The underlying value of this constant.
  final T value;

  /// Creates a [PrimitiveConstant] object with the given [value].
  const PrimitiveConstant(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrimitiveConstant<T> && other.value == value;
  }
}

/// Represents a constant boolean value.
final class BoolConstant extends PrimitiveConstant<bool> {
  /// Creates a [BoolConstant] object with the given boolean [value].
  // ignore: avoid_positional_boolean_parameters
  const BoolConstant(super.value);

  @override
  BoolConstantSyntax _toSyntax(Map<Constant, int> constants) =>
      BoolConstantSyntax(value: value);
}

/// Represents a constant integer value.
final class IntConstant extends PrimitiveConstant<int> {
  /// Creates an [IntConstant] object with the given integer [value].
  const IntConstant(super.value);

  @override
  IntConstantSyntax _toSyntax(Map<Constant, int> constants) =>
      IntConstantSyntax(value: value);
}

/// Represents a constant string value.
final class StringConstant extends PrimitiveConstant<String> {
  /// Creates a [StringConstant] object with the given string [value].
  const StringConstant(super.value);

  @override
  StringConstantSyntax _toSyntax(Map<Constant, int> constants) =>
      StringConstantSyntax(value: value);
}

/// Represents a constant list of [Constant] values.
final class ListConstant<T extends Constant> extends Constant {
  /// The underlying list of constant values.
  final List<T> value;

  /// Creates a [ListConstant] object with the given list of [value]s.
  const ListConstant(this.value);

  @override
  int get hashCode => deepHash(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListConstant && deepEquals(other.value, value);
  }

  @override
  ListConstantSyntax _toSyntax(Map<Constant, int> constants) =>
      ListConstantSyntax(
        value: value.map((constant) => constants[constant]).toList(),
      );
}

/// Represents a constant map from string keys to [Constant] values.
final class MapConstant<T extends Constant> extends Constant {
  /// The underlying map of constant values.
  final Map<String, T> value;

  /// Creates a [MapConstant] object with the given map of [value]s.
  const MapConstant(this.value);

  @override
  int get hashCode => deepHash(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapConstant && deepEquals(other.value, value);
  }

  @override
  MapConstantSyntax _toSyntax(Map<Constant, int> constants) =>
      MapConstantSyntax(
        value: JsonObjectSyntax.fromJson(
          value.map((key, constant) => MapEntry(key, constants[constant]!)),
        ),
      );
}

/// A constant instance of a class with its fields
///
/// Only as far as they can also be represented by constants. This is more or
/// less the same as a [MapConstant].
final class InstanceConstant extends Constant {
  /// The fields of this instance, mapped from field name to [Constant] value.
  final Map<String, Constant> fields;

  /// Creates an [InstanceConstant] object with the given [fields].
  const InstanceConstant({required this.fields});

  @override
  InstanceConstantSyntax _toSyntax(Map<Constant, int> constants) =>
      InstanceConstantSyntax(
        value: fields.isNotEmpty
            ? JsonObjectSyntax.fromJson(
                fields.map(
                  (name, constant) => MapEntry(name, constants[constant]!),
                ),
              )
            : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InstanceConstant && deepEquals(other.fields, fields);
  }

  @override
  int get hashCode => deepHash(fields);
}

/// Package private (protected) methods for [Constant].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension ConstantProtected on Constant {
  ConstantSyntax toSyntax(Map<Constant, int> constants) => _toSyntax(constants);

  static Constant fromSyntax(ConstantSyntax syntax, List<Constant> constants) =>
      Constant._fromSyntax(syntax, constants);
}
