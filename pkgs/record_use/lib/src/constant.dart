// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'definition.dart';
import 'helper.dart';
import 'serialization_context.dart';
import 'syntax.g.dart';

/// A value recorded during compilation.
sealed class MaybeConstant {
  const MaybeConstant();

  /// Compares this [MaybeConstant] with [other] for semantic equality.
  ///
  /// If [allowPromotionOfUnsupported] is true, an [UnsupportedConstant] in
  /// [other] matches any [Constant] in this.
  @visibleForTesting
  bool semanticEquals(
    MaybeConstant other, {
    bool allowPromotionOfUnsupported = false,
  });

  /// Converts this [MaybeConstant] object to a syntax representation.
  ConstantSyntax _toSyntax(SerializationContext context);

  /// Creates a [MaybeConstant] object from its syntax representation.
  static MaybeConstant _fromSyntax(
    ConstantSyntax syntax,
    DeserializationContext context,
  ) => switch (syntax) {
    NonConstantConstantSyntax() => const NonConstant(),
    NullConstantSyntax() => const NullConstant(),
    BoolConstantSyntax(:final value) => BoolConstant(value),
    IntConstantSyntax(:final value) => IntConstant(value),
    StringConstantSyntax(:final value) => StringConstant(value),
    ListConstantSyntax(:final value) => ListConstant(
      value!.cast<int>().map((i) {
        final constant = context.constants[i];
        if (constant is! Constant) {
          throw FormatException(
            'List constant element at index $i is not a constant',
          );
        }
        return constant;
      }).toList(),
    ),
    MapConstantSyntax(:final value) => MapConstant(
      value.map(
        (e) {
          final key = context.constants[e.key];
          if (key is! Constant) {
            throw FormatException(
              'Map constant key at index ${e.key} is not a constant',
            );
          }
          final value = context.constants[e.value];
          if (value is! Constant) {
            throw FormatException(
              'Map constant value at index ${e.value} is not a constant',
            );
          }
          return MapEntry(key, value);
        },
      ).toList(),
    ),
    InstanceConstantSyntax(value: final value, :final definitionIndex) =>
      InstanceConstant(
        definition: context.definitions[definitionIndex],
        fields: (value?.json ?? {}).map(
          (key, index) {
            final constant = context.constants[index as int];
            if (constant is! Constant) {
              throw FormatException(
                'Instance constant field $key at index $index is not '
                'a constant',
              );
            }
            return MapEntry(key, constant);
          },
        ),
      ),
    UnsupportedConstantSyntax(:final message) => UnsupportedConstant(message),
    _ => throw UnimplementedError(
      '"${syntax.type}" is not a supported constant type',
    ),
  };
}

/// A value that is not a constant.
final class NonConstant extends MaybeConstant {
  const NonConstant();

  @override
  NonConstantConstantSyntax _toSyntax(SerializationContext context) =>
      NonConstantConstantSyntax();

  @override
  bool operator ==(Object other) => other is NonConstant;

  @override
  int get hashCode => 0x4e6f6e43;

  @override
  String toString() => 'NonConstant()';

  @override
  @visibleForTesting
  bool semanticEquals(
    MaybeConstant other, {
    bool allowPromotionOfUnsupported = false,
  }) => other is NonConstant;
}

/// A constant value that can be recorded and serialized.
///
/// This follows the AST constant concept from the Dart SDK.
///
/// This class is intentionally not sealed. Adding new subtypes of [Constant]
/// should not be a breaking change for users of this package. Users should
/// use a wildcard pattern or a default case when switching over [Constant].
abstract class Constant extends MaybeConstant {
  /// Creates a [Constant] object.
  const Constant();

  @override
  @visibleForTesting
  bool semanticEquals(
    MaybeConstant other, {
    bool allowPromotionOfUnsupported = false,
  }) {
    if (this == other) return true;
    if (allowPromotionOfUnsupported && other is UnsupportedConstant) {
      return true;
    }
    return _semanticEqualsInternal(other, allowPromotionOfUnsupported);
  }

  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  );
}

/// The `null` constant value.
final class NullConstant extends Constant {
  /// Creates a [NullConstant] object.
  const NullConstant() : super();

  @override
  NullConstantSyntax _toSyntax(SerializationContext context) =>
      NullConstantSyntax();

  @override
  bool operator ==(Object other) => other is NullConstant;

  @override
  int get hashCode => 0x4e756c6c;

  @override
  String toString() => 'NullConstant()';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) => other is NullConstant;
}

/// A constant value in Dart but not supported in `package:record_use`.
final class UnsupportedConstant extends Constant {
  /// The reason why this constant is unsupported.
  final String message;

  /// Creates an [UnsupportedConstant] object with the given [message].
  const UnsupportedConstant(this.message);

  @override
  UnsupportedConstantSyntax _toSyntax(SerializationContext context) =>
      UnsupportedConstantSyntax(message: message);

  @override
  bool operator ==(Object other) =>
      other is UnsupportedConstant && other.message == message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'UnsupportedConstant($message)';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) => other is UnsupportedConstant && other.message == message;
}

/// A constant boolean value.
final class BoolConstant extends Constant {
  /// The underlying value of this constant.
  final bool value;

  /// Creates a [BoolConstant] object with the given boolean [value].
  // ignore: avoid_positional_boolean_parameters
  const BoolConstant(this.value);

  @override
  BoolConstantSyntax _toSyntax(SerializationContext context) =>
      BoolConstantSyntax(value: value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is BoolConstant && other.value == value;

  @override
  String toString() => 'BoolConstant($value)';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) => other is BoolConstant && other.value == value;
}

/// A constant integer value.
final class IntConstant extends Constant {
  /// The underlying value of this constant.
  final int value;

  /// Creates an [IntConstant] object with the given integer [value].
  const IntConstant(this.value);

  @override
  IntConstantSyntax _toSyntax(SerializationContext context) =>
      IntConstantSyntax(value: value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is IntConstant && other.value == value;

  @override
  String toString() => 'IntConstant($value)';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) => other is IntConstant && other.value == value;
}

/// A constant string value.
final class StringConstant extends Constant {
  /// The underlying value of this constant.
  final String value;

  /// Creates a [StringConstant] object with the given string [value].
  const StringConstant(this.value);

  @override
  StringConstantSyntax _toSyntax(SerializationContext context) =>
      StringConstantSyntax(value: value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is StringConstant && other.value == value;

  @override
  String toString() => 'StringConstant($value)';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) => other is StringConstant && other.value == value;
}

/// A constant list of [Constant] values.
final class ListConstant extends Constant {
  /// The underlying list of constant values.
  final List<Constant> value;

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
  ListConstantSyntax _toSyntax(SerializationContext context) =>
      ListConstantSyntax(
        value: value.map((constant) => context.constants[constant]!).toList(),
      );

  @override
  String toString() => 'ListConstant([${value.join(', ')}])';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) {
    if (other is! ListConstant) return false;
    if (value.length != other.value.length) return false;
    for (var i = 0; i < value.length; i++) {
      if (!value[i].semanticEquals(
        other.value[i],
        allowPromotionOfUnsupported: allowPromotionOfUnsupported,
      )) {
        return false;
      }
    }
    return true;
  }
}

/// A constant map from [Constant] keys to [Constant] values.
final class MapConstant extends Constant {
  /// The underlying map of constant values.
  final List<MapEntry<Constant, Constant>> entries;

  /// Creates a [MapConstant] object with the given map of entries.
  const MapConstant(this.entries);

  @override
  int get hashCode => Object.hashAll(
    entries.map((e) => Object.hash(e.key, e.value)),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! MapConstant) return false;
    if (other.entries.length != entries.length) return false;
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].key != other.entries[i].key ||
          entries[i].value != other.entries[i].value) {
        return false;
      }
    }
    return true;
  }

  @override
  MapConstantSyntax _toSyntax(SerializationContext context) =>
      MapConstantSyntax(
        value: entries
            .map(
              (entry) => MapEntrySyntax(
                key: context.constants[entry.key]!,
                value: context.constants[entry.value]!,
              ),
            )
            .toList(),
      );

  @override
  String toString() =>
      'MapConstant({${entries.map((e) => '${e.key}: ${e.value}').join(', ')}})';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) {
    if (other is! MapConstant) return false;
    if (entries.length != other.entries.length) return false;
    for (var i = 0; i < entries.length; i++) {
      if (!entries[i].key.semanticEquals(
            other.entries[i].key,
            allowPromotionOfUnsupported: allowPromotionOfUnsupported,
          ) ||
          !entries[i].value.semanticEquals(
            other.entries[i].value,
            allowPromotionOfUnsupported: allowPromotionOfUnsupported,
          )) {
        return false;
      }
    }
    return true;
  }
}

/// A constant instance of a class with its fields
///
/// Only as far as they can also be represented by constants. This is more or
/// less the same as a [MapConstant].
final class InstanceConstant extends Constant {
  /// The definition of the class of this instance.
  final Definition definition;

  /// The fields of this instance, mapped from field name to [Constant] value.
  final Map<String, Constant> fields;

  /// Creates an [InstanceConstant] object with the given [definition] and
  /// [fields].
  const InstanceConstant({required this.definition, required this.fields});

  @override
  InstanceConstantSyntax _toSyntax(SerializationContext context) =>
      InstanceConstantSyntax(
        definitionIndex: context.definitions[definition]!,
        value: fields.isNotEmpty
            ? JsonObjectSyntax.fromJson(
                fields.map(
                  (name, constant) =>
                      MapEntry(name, context.constants[constant]!),
                ),
              )
            : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InstanceConstant &&
        other.definition == definition &&
        deepEquals(other.fields, fields);
  }

  @override
  int get hashCode => Object.hash(definition, deepHash(fields));

  @override
  String toString() =>
      'InstanceConstant($definition, {'
      '${fields.entries.map((e) => '${e.key}: ${e.value}').join(', ')}})';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) {
    if (other is! InstanceConstant) return false;
    // ignore: invalid_use_of_visible_for_testing_member
    if (!definition.semanticEquals(other.definition)) return false;
    if (fields.length != other.fields.length) return false;
    for (final entry in fields.entries) {
      final otherField = other.fields[entry.key];
      if (otherField == null ||
          !entry.value.semanticEquals(
            otherField,
            allowPromotionOfUnsupported: allowPromotionOfUnsupported,
          )) {
        return false;
      }
    }
    return true;
  }
}

/// Package private (protected) methods for [MaybeConstant].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension MaybeConstantProtected on MaybeConstant {
  ConstantSyntax toSyntax(SerializationContext context) => _toSyntax(context);

  static MaybeConstant fromSyntax(
    ConstantSyntax syntax,
    DeserializationContext context,
  ) => MaybeConstant._fromSyntax(syntax, context);

  @visibleForTesting
  bool semanticEquals(
    MaybeConstant other, {
    bool allowPromotionOfUnsupported = false,
  }) => this.semanticEquals(
    other,
    allowPromotionOfUnsupported: allowPromotionOfUnsupported,
  );
}
