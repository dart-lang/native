// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'config.dart';
import 'encoded_asset.dart';
import 'hooks/syntax.g.dart' as syntax;

class Metadata {
  final UnmodifiableMapView<String, Object?> metadata;

  Metadata(Map<String, Object?> metadata)
    : metadata = UnmodifiableMapView(
        // It would be better if `jsonMap` would be deep copied.
        // https://github.com/dart-lang/native/issues/2045
        Map.of(metadata),
      );

  Map<String, Object?> toJson() => metadata;

  @override
  bool operator ==(Object other) {
    if (other is! Metadata) {
      return false;
    }
    return const DeepCollectionEquality().equals(other.metadata, metadata);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(metadata);

  @override
  String toString() => 'Metadata(${toJson()})';
}

/// An asset that contains metadata.
///
/// Should only be used with [ToLinker] and [ToBuildHooks].
//
// Note: not exported to public API. The public API only contains a way to read
// and write metadata, it doesn't expose the underlying mechanism.
final class MetadataAsset {
  final String key;

  final Object? value;

  MetadataAsset({required this.key, required this.value});

  factory MetadataAsset.fromEncoded(EncodedAsset asset) {
    assert(asset.type == _type);
    final syntaxNode = syntax.MetadataAssetEncoding.fromJson(
      asset.encoding,
      path: asset.jsonPath ?? [],
    );
    return MetadataAsset(key: syntaxNode.key, value: syntaxNode.value);
  }

  @override
  bool operator ==(Object other) {
    if (other is! MetadataAsset) {
      return false;
    }
    return other.key == key &&
        const DeepCollectionEquality().equals(value, other.value);
  }

  @override
  int get hashCode =>
      Object.hash(key, const DeepCollectionEquality().hash(value));

  EncodedAsset encode() => EncodedAsset(_type, {'key': key, 'value': value});

  @override
  String toString() => 'MetadataAsset(${encode().encoding})';

  static const _type = 'hooks/metadata';
}

extension EncodedMetadataAsset on EncodedAsset {
  bool get isMetadataAsset => type == MetadataAsset._type;
  MetadataAsset get asMetadataAsset => MetadataAsset.fromEncoded(this);
}
