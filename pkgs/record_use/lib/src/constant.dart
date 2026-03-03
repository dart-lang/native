// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:meta/meta.dart';

import 'canonicalization_context.dart';
import 'definition.dart';
import 'helper.dart';
import 'serialization_context.dart';
import 'syntax.g.dart';

/// A value recorded during compilation.
sealed class MaybeConstant {
  const MaybeConstant();

  /// The maximum depth of the constant tree.
  ///
  /// Used for fast-path optimization in `operator ==`. Not included in
  /// `hashCode` because it is implicitly covered by the content-based hash.
  int get _depth;

  /// The total number of nodes in the constant tree.
  ///
  /// Used for fast-path optimization in `operator ==`. Not included in
  /// `hashCode` because it is implicitly covered by the content-based hash.
  int get _size;

  /// Canonicalizes this [MaybeConstant].
  MaybeConstant _canonicalizeChildren(CanonicalizationContext context);

  /// Returns a new [MaybeConstant] that only contains information allowed
  /// by the provided criteria.
  ///
  /// If [definitionPackageName] is provided, constants that are instances of
  /// classes or enums from other packages are replaced with an
  /// [UnsupportedConstant].
  MaybeConstant _filter({String? definitionPackageName});

  /// Compares this [MaybeConstant] with [other] for stable sorting.
  int _compareTo(MaybeConstant other) {
    if (identical(this, other)) return 0;
    // By comparing the depth first, the serialization order of constants
    // always has the children serialized before the parents.
    var compare = _depth.compareTo(other._depth);
    if (compare != 0) return compare;
    compare = _orderingTypePriority.compareTo(other._orderingTypePriority);
    if (compare != 0) return compare;
    compare = _size.compareTo(other._size);
    if (compare != 0) return compare;
    return _compareToSameType(other);
  }

  /// Internal comparison for objects of the same type.
  @protected
  int _compareToSameType(covariant MaybeConstant other);

  /// A stable priority for this type.
  @protected
  int get _orderingTypePriority;

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
    SymbolConstantSyntax(:final name, :final libraryUri) => SymbolConstant(
      name,
      libraryUri: libraryUri,
    ),
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
    EnumConstantSyntax(
      value: final value,
      :final definitionIndex,
      :final index,
      :final name,
    ) =>
      EnumConstant(
        definition: context.definitions[definitionIndex],
        index: index,
        name: name,
        fields: (value ?? {}).map(
          (key, index) {
            final constant = context.constants[index];
            if (constant is! Constant) {
              throw FormatException(
                'Enum constant field $key at index $index is not '
                'a constant',
              );
            }
            return MapEntry(key, constant);
          },
        ),
      ),
    RecordConstantSyntax(:final positional, :final named) => RecordConstant(
      positional: (positional ?? const []).map((i) {
        final constant = context.constants[i];
        if (constant is! Constant) {
          throw FormatException(
            'Record constant positional field at index $i is not '
            'a constant',
          );
        }
        return constant;
      }).toList(),
      named: (named ?? const {}).map(
        (key, index) {
          final constant = context.constants[index];
          if (constant is! Constant) {
            throw FormatException(
              'Record constant named field $key at index $index is not '
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
  int get _depth => 1;

  @override
  int get _size => 1;

  @override
  MaybeConstant _canonicalizeChildren(CanonicalizationContext context) => this;

  @override
  MaybeConstant _filter({String? definitionPackageName}) => this;

  @override
  int get hashCode => 0x4e6f6e43;

  @override
  int get _orderingTypePriority => 0;

  @override
  int _compareToSameType(NonConstant other) => 0;

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
  Constant _canonicalizeChildren(CanonicalizationContext context);

  @override
  Constant _filter({String? definitionPackageName});

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
  int get _depth => 1;

  @override
  int get _size => 1;

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) => this;

  @override
  Constant _filter({String? definitionPackageName}) => this;

  @override
  int get hashCode => 0x4e756c6c;

  @override
  int get _orderingTypePriority => 2;

  @override
  int _compareToSameType(NullConstant other) => 0;

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
  int get _depth => 1;

  @override
  int get _size => 1;

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) => this;

  @override
  Constant _filter({String? definitionPackageName}) => this;

  @override
  int get hashCode => message.hashCode;

  @override
  int get _orderingTypePriority => 1;

  @override
  int _compareToSameType(UnsupportedConstant other) =>
      message.compareTo(other.message);

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
  int get _depth => 1;

  @override
  int get _size => 1;

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) => this;

  @override
  Constant _filter({String? definitionPackageName}) => this;

  @override
  bool operator ==(Object other) =>
      other is BoolConstant && other.value == value;

  @override
  int get _orderingTypePriority => 3;

  @override
  int _compareToSameType(BoolConstant other) {
    if (value == other.value) return 0;
    return value ? 1 : -1;
  }

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
  int get _depth => 1;

  @override
  int get _size => 1;

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) => this;

  @override
  Constant _filter({String? definitionPackageName}) => this;

  @override
  bool operator ==(Object other) =>
      other is IntConstant && other.value == value;

  @override
  int get _orderingTypePriority => 4;

  @override
  int _compareToSameType(IntConstant other) => value.compareTo(other.value);

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
  int get _depth => 1;

  @override
  int get _size => 1;

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) => this;

  @override
  Constant _filter({String? definitionPackageName}) => this;

  @override
  bool operator ==(Object other) =>
      other is StringConstant && other.value == value;

  @override
  int get _orderingTypePriority => 5;

  @override
  int _compareToSameType(StringConstant other) => value.compareTo(other.value);

  @override
  String toString() => 'StringConstant($value)';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) => other is StringConstant && other.value == value;
}

/// A constant symbol value.
final class SymbolConstant extends Constant {
  /// The name of the symbol.
  final String name;

  /// The library URI if this is a private symbol (starts with '_').
  /// Null for public symbols.
  final String? libraryUri;

  /// Creates a [SymbolConstant] object with the given [name] and optional
  /// [libraryUri].
  const SymbolConstant(this.name, {this.libraryUri});

  @override
  SymbolConstantSyntax _toSyntax(SerializationContext context) =>
      SymbolConstantSyntax(name: name, libraryUri: libraryUri);

  @override
  int get hashCode => Object.hash(name, libraryUri);

  @override
  int get _depth => 1;

  @override
  int get _size => 1;

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) => this;

  @override
  Constant _filter({String? definitionPackageName}) => this;

  @override
  bool operator ==(Object other) =>
      other is SymbolConstant &&
      other.name == name &&
      other.libraryUri == libraryUri;

  @override
  int get _orderingTypePriority => 6;

  @override
  int _compareToSameType(SymbolConstant other) {
    final nameCompare = name.compareTo(other.name);
    if (nameCompare != 0) return nameCompare;
    if (libraryUri == null) return other.libraryUri == null ? 0 : -1;
    if (other.libraryUri == null) return 1;
    return libraryUri!.compareTo(other.libraryUri!);
  }

  @override
  String toString() {
    if (libraryUri == null) {
      return '#$name';
    }
    return '$libraryUri::#$name';
  }

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) =>
      other is SymbolConstant &&
      other.name == name &&
      other.libraryUri == libraryUri;
}

/// A constant list of [Constant] values.
final class ListConstant extends Constant {
  /// The underlying list of constant values.
  final List<Constant> value;

  /// Creates a [ListConstant] object with the given list of [value]s.
  const ListConstant(this.value);

  @override
  int get hashCode => cacheHashCode(() => deepHash(value));

  @override
  int get _depth => cacheDepth(() {
    var depth = 0;
    for (final constant in value) {
      depth = max(depth, constant._depth);
    }
    return 1 + depth;
  });

  @override
  int get _size => cacheSize(() {
    var size = 0;
    for (final constant in value) {
      size += constant._size;
    }
    return 1 + size;
  });

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) =>
      ListConstant([
        for (final c in value) context.canonicalizeConstant(c) as Constant,
      ]);

  @override
  Constant _filter({String? definitionPackageName}) => ListConstant([
    for (final c in value)
      c._filter(definitionPackageName: definitionPackageName),
  ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListConstant &&
        other._depth == _depth &&
        other._size == _size &&
        deepEquals(other.value, value);
  }

  @override
  ListConstantSyntax _toSyntax(SerializationContext context) =>
      ListConstantSyntax(
        value: [for (final constant in value) context.constants[constant]!],
      );

  @override
  int get _orderingTypePriority => 7;

  @override
  int _compareToSameType(ListConstant other) {
    final lengthCompare = value.length.compareTo(other.value.length);
    if (lengthCompare != 0) return lengthCompare;
    for (var i = 0; i < value.length; i++) {
      final itemCompare = value[i]._compareTo(other.value[i]);
      if (itemCompare != 0) return itemCompare;
    }
    return 0;
  }

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
  int get hashCode => cacheHashCode(
    () => Object.hashAll(
      entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  int get _depth => cacheDepth(() {
    var depth = 0;
    for (final entry in entries) {
      depth = max(depth, max(entry.key._depth, entry.value._depth));
    }
    return 1 + depth;
  });

  @override
  int get _size => cacheSize(() {
    var size = 0;
    for (final entry in entries) {
      size += entry.key._size + entry.value._size;
    }
    return 1 + size;
  });

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) {
    final canonEntries = [
      for (final e in entries)
        MapEntry(
          context.canonicalizeConstant(e.key) as Constant,
          context.canonicalizeConstant(e.value) as Constant,
        ),
    ];
    canonEntries.sort((a, b) => a.key._compareTo(b.key));
    return MapConstant(canonEntries);
  }

  @override
  Constant _filter({String? definitionPackageName}) => MapConstant([
    for (final entry in entries)
      MapEntry(
        entry.key._filter(definitionPackageName: definitionPackageName),
        entry.value._filter(definitionPackageName: definitionPackageName),
      ),
  ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! MapConstant) return false;
    if (other._depth != _depth || other._size != _size) return false;
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
        value: [
          for (final entry in entries)
            MapEntrySyntax(
              key: context.constants[entry.key]!,
              value: context.constants[entry.value]!,
            ),
        ],
      );

  @override
  int get _orderingTypePriority => 8;

  @override
  int _compareToSameType(MapConstant other) {
    final lengthCompare = entries.length.compareTo(other.entries.length);
    if (lengthCompare != 0) return lengthCompare;
    for (var i = 0; i < entries.length; i++) {
      final keyCompare = entries[i].key._compareTo(other.entries[i].key);
      if (keyCompare != 0) return keyCompare;
      final valueCompare = entries[i].value._compareTo(other.entries[i].value);
      if (valueCompare != 0) return valueCompare;
    }
    return 0;
  }

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
            ? JsonObjectSyntax.fromJson({
                for (final entry in fields.entries)
                  entry.key: context.constants[entry.value]!,
              })
            : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InstanceConstant &&
        other._depth == _depth &&
        other._size == _size &&
        other.definition == definition &&
        deepEquals(other.fields, fields);
  }

  @override
  int get hashCode =>
      cacheHashCode(() => Object.hash(definition, deepHash(fields)));

  @override
  int get _depth => cacheDepth(() {
    var depth = 0;
    for (final field in fields.values) {
      depth = max(depth, field._depth);
    }
    return 1 + depth;
  });

  @override
  int get _size => cacheSize(() {
    var size = 0;
    for (final field in fields.values) {
      size += field._size;
    }
    return 1 + size;
  });

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) {
    final sortedEntries = fields.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return InstanceConstant(
      definition: context.canonicalizeDefinition(definition),
      fields: {
        for (final e in sortedEntries)
          e.key: context.canonicalizeConstant(e.value) as Constant,
      },
    );
  }

  @override
  Constant _filter({String? definitionPackageName}) {
    if (definitionPackageName != null &&
        !definition.library.startsWith('package:$definitionPackageName/')) {
      return UnsupportedConstant(
        'Instance of $definition from other package is not supported.',
      );
    }
    return InstanceConstant(
      definition: definition,
      fields: fields.map(
        (key, value) => MapEntry(
          key,
          value._filter(definitionPackageName: definitionPackageName),
        ),
      ),
    );
  }

  @override
  int get _orderingTypePriority => 11;

  @override
  int _compareToSameType(InstanceConstant other) {
    final definitionCompare = definition.toString().compareTo(
      other.definition.toString(),
    );
    if (definitionCompare != 0) return definitionCompare;
    final lengthCompare = fields.length.compareTo(other.fields.length);
    if (lengthCompare != 0) return lengthCompare;
    final sortedKeys = fields.keys.toList()..sort();
    final otherSortedKeys = other.fields.keys.toList()..sort();
    for (var i = 0; i < sortedKeys.length; i++) {
      final keyCompare = sortedKeys[i].compareTo(otherSortedKeys[i]);
      if (keyCompare != 0) return keyCompare;
      final valueCompare = fields[sortedKeys[i]]!._compareTo(
        other.fields[otherSortedKeys[i]]!,
      );
      if (valueCompare != 0) return valueCompare;
    }
    return 0;
  }

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

/// A constant enum value.
final class EnumConstant extends Constant {
  /// The definition of the enum class of this value.
  final Definition definition;

  /// The index of the enum member.
  final int index;

  /// The name of the enum member.
  final String name;

  /// The fields of this instance, mapped from field name to [Constant] value.
  ///
  /// This includes additional fields from enhanced enums.
  final Map<String, Constant> fields;

  /// Creates an [EnumConstant] object with the given [definition], [index],
  /// [name], and [fields].
  const EnumConstant({
    required this.definition,
    required this.index,
    required this.name,
    this.fields = const {},
  });

  @override
  EnumConstantSyntax _toSyntax(SerializationContext context) =>
      EnumConstantSyntax(
        definitionIndex: context.definitions[definition]!,
        index: index,
        name: name,
        value: fields.isNotEmpty
            ? {
                for (final entry in fields.entries)
                  entry.key: context.constants[entry.value]!,
              }
            : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EnumConstant &&
        other._depth == _depth &&
        other._size == _size &&
        other.definition == definition &&
        other.index == index &&
        other.name == name &&
        deepEquals(other.fields, fields);
  }

  @override
  int get hashCode => cacheHashCode(
    () => Object.hash(definition, index, name, deepHash(fields)),
  );

  @override
  int get _depth => cacheDepth(() {
    var depth = 0;
    for (final field in fields.values) {
      depth = max(depth, field._depth);
    }
    return 1 + depth;
  });

  @override
  int get _size => cacheSize(() {
    var size = 0;
    for (final field in fields.values) {
      size += field._size;
    }
    return 1 + size;
  });

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) {
    final sortedEntries = fields.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return EnumConstant(
      definition: context.canonicalizeDefinition(definition),
      index: index,
      name: name,
      fields: {
        for (final e in sortedEntries)
          e.key: context.canonicalizeConstant(e.value) as Constant,
      },
    );
  }

  @override
  Constant _filter({String? definitionPackageName}) {
    if (definitionPackageName != null &&
        !definition.library.startsWith('package:$definitionPackageName/')) {
      return UnsupportedConstant(
        'Instance of $definition from other package is not supported.',
      );
    }
    return EnumConstant(
      definition: definition,
      index: index,
      name: name,
      fields: fields.map(
        (key, value) => MapEntry(
          key,
          value._filter(definitionPackageName: definitionPackageName),
        ),
      ),
    );
  }

  @override
  int get _orderingTypePriority => 10;

  @override
  int _compareToSameType(EnumConstant other) {
    final definitionCompare = definition.toString().compareTo(
      other.definition.toString(),
    );
    if (definitionCompare != 0) return definitionCompare;
    final indexCompare = index.compareTo(other.index);
    if (indexCompare != 0) return indexCompare;
    final lengthCompare = fields.length.compareTo(other.fields.length);
    if (lengthCompare != 0) return lengthCompare;
    final sortedKeys = fields.keys.toList()..sort();
    final otherSortedKeys = other.fields.keys.toList()..sort();
    for (var i = 0; i < sortedKeys.length; i++) {
      final keyCompare = sortedKeys[i].compareTo(otherSortedKeys[i]);
      if (keyCompare != 0) return keyCompare;
      final valueCompare = fields[sortedKeys[i]]!._compareTo(
        other.fields[otherSortedKeys[i]]!,
      );
      if (valueCompare != 0) return valueCompare;
    }
    return 0;
  }

  @override
  String toString() =>
      'EnumConstant($definition, index: $index, name: $name, fields: {'
      '${fields.entries.map((e) => '${e.key}: ${e.value}').join(', ')}})';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) {
    if (other is! EnumConstant) return false;
    // ignore: invalid_use_of_visible_for_testing_member
    if (!definition.semanticEquals(other.definition)) return false;
    if (index != other.index || name != other.name) return false;
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

/// A constant record value.
final class RecordConstant extends Constant {
  /// The positional fields of this record.
  final List<Constant> positional;

  /// The named fields of this record.
  final Map<String, Constant> named;

  /// Creates a [RecordConstant] object with the given [positional] and [named]
  /// fields.
  const RecordConstant({
    this.positional = const [],
    this.named = const {},
  });

  @override
  RecordConstantSyntax _toSyntax(SerializationContext context) =>
      RecordConstantSyntax(
        positional: positional.isNotEmpty
            ? [for (final c in positional) context.constants[c]!]
            : null,
        named: named.isNotEmpty
            ? {
                for (final entry in named.entries)
                  entry.key: context.constants[entry.value]!,
              }
            : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecordConstant &&
        other._depth == _depth &&
        other._size == _size &&
        deepEquals(other.positional, positional) &&
        deepEquals(other.named, named);
  }

  @override
  int get hashCode => cacheHashCode(
    () => Object.hash(deepHash(positional), deepHash(named)),
  );

  @override
  int get _depth => cacheDepth(() {
    var depth = 0;
    for (final constant in positional) {
      depth = max(depth, constant._depth);
    }
    for (final constant in named.values) {
      depth = max(depth, constant._depth);
    }
    return 1 + depth;
  });

  @override
  int get _size => cacheSize(() {
    var size = 0;
    for (final constant in positional) {
      size += constant._size;
    }
    for (final constant in named.values) {
      size += constant._size;
    }
    return 1 + size;
  });

  @override
  Constant _canonicalizeChildren(CanonicalizationContext context) {
    final sortedNamedEntries = named.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return RecordConstant(
      positional: [
        for (final c in positional) context.canonicalizeConstant(c) as Constant,
      ],
      named: {
        for (final e in sortedNamedEntries)
          e.key: context.canonicalizeConstant(e.value) as Constant,
      },
    );
  }

  @override
  Constant _filter({String? definitionPackageName}) => RecordConstant(
    positional: [
      for (final c in positional)
        c._filter(definitionPackageName: definitionPackageName),
    ],
    named: named.map(
      (key, value) => MapEntry(
        key,
        value._filter(definitionPackageName: definitionPackageName),
      ),
    ),
  );

  @override
  int get _orderingTypePriority => 9;

  @override
  int _compareToSameType(RecordConstant other) {
    var compare = positional.length.compareTo(other.positional.length);
    if (compare != 0) return compare;
    compare = named.length.compareTo(other.named.length);
    if (compare != 0) return compare;
    for (var i = 0; i < positional.length; i++) {
      compare = positional[i]._compareTo(other.positional[i]);
      if (compare != 0) return compare;
    }
    final sortedKeys = named.keys.toList()..sort();
    final otherSortedKeys = other.named.keys.toList()..sort();
    for (var i = 0; i < sortedKeys.length; i++) {
      compare = sortedKeys[i].compareTo(otherSortedKeys[i]);
      if (compare != 0) return compare;
      compare = named[sortedKeys[i]]!._compareTo(
        other.named[otherSortedKeys[i]]!,
      );
      if (compare != 0) return compare;
    }
    return 0;
  }

  @override
  String toString() =>
      'RecordConstant('
      '${positional.join(', ')}'
      '${positional.isNotEmpty && named.isNotEmpty ? ', ' : ''}'
      '${named.entries.map((e) => '${e.key}: ${e.value}').join(', ')})';

  @override
  bool _semanticEqualsInternal(
    MaybeConstant other,
    bool allowPromotionOfUnsupported,
  ) {
    if (other is! RecordConstant) return false;
    if (positional.length != other.positional.length) return false;
    if (named.length != other.named.length) return false;
    for (var i = 0; i < positional.length; i++) {
      if (!positional[i].semanticEquals(
        other.positional[i],
        allowPromotionOfUnsupported: allowPromotionOfUnsupported,
      )) {
        return false;
      }
    }
    for (final entry in named.entries) {
      final otherField = other.named[entry.key];
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

  MaybeConstant canonicalizeChildren(CanonicalizationContext context) =>
      _canonicalizeChildren(context);

  MaybeConstant filter({String? definitionPackageName}) =>
      _filter(definitionPackageName: definitionPackageName);

  int compareTo(MaybeConstant other) => _compareTo(other);

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
