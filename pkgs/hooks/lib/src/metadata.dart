// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'config.dart';
import 'encoded_asset.dart';
import 'hooks/syntax.g.dart';

/// An asset that contains metadata.
///
/// Should only be used with [ToLinkHook] and [ToBuildHooks].
//
// Note: not exported to public API. The public API only contains a way to read
// and write metadata, it doesn't expose the underlying mechanism.
final class MetadataAsset {
  /// The key for the metadata.
  final String key;

  /// The value of the metadata.
  final Object? value;

  /// Creates a [MetadataAsset].
  MetadataAsset({required this.key, required this.value});

  /// Creates a [MetadataAsset] from an [EncodedAsset].
  factory MetadataAsset.fromEncoded(EncodedAsset asset) {
    assert(asset.type == _type);
    final syntaxNode = MetadataAssetEncodingSyntax.fromJson(
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

  /// Encodes this [MetadataAsset] into an [EncodedAsset].
  EncodedAsset encode() => EncodedAsset(_type, {'key': key, 'value': value});

  @override
  String toString() => 'MetadataAsset(${encode().encoding})';

  static const _type = 'hooks/metadata';
}

/// Extension methods for [EncodedAsset] to handle metadata.
extension EncodedMetadataAsset on EncodedAsset {
  /// Whether this asset is a metadata asset.
  bool get isMetadataAsset => type == MetadataAsset._type;

  /// Converts this asset to a [MetadataAsset].
  ///
  /// Requires [isMetadataAsset] to be true.
  MetadataAsset get asMetadataAsset => MetadataAsset.fromEncoded(this);
}
