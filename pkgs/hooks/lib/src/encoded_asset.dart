// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'hooks/syntax.g.dart';

/// An encoded asset.
///
/// Use a protocol extension such as `package:code_assets` or
/// `package:data_assets` to encode and decode assets.
final class EncodedAsset {
  /// The type of the asset (e.g. whether it's a code asset, data asset or ...)
  final String type;

  /// The json encoding of the asset.
  final UnmodifiableMapView<String, Object?> encoding;

  /// The path of the [encoding] in a larger JSON.
  ///
  /// If provided, used for more precise error messages.
  final List<Object>? encodingJsonPath;

  /// Creates an [EncodedAsset].
  EncodedAsset(
    this.type,
    Map<String, Object?> encoding, {
    this.encodingJsonPath,
  }) : encoding = UnmodifiableMapView(
         // It would be better if `encoding` would be deep copied.
         // https://github.com/dart-lang/native/issues/2045
         Map.of(encoding),
       );

  /// Decode an [EncodedAsset] from json.
  factory EncodedAsset.fromJson(
    Map<String, Object?> json, [
    List<Object>? path,
  ]) => EncodedAssetSyntaxExtension.fromSyntax(
    AssetSyntax.fromJson(json, path: path ?? []),
  );

  /// Encode this [EncodedAsset] tojson.
  Map<String, Object?> toJson() => toSyntax().json;

  @override
  String toString() => 'EncodedAsset($type, $encoding)';

  @override
  int get hashCode => Object.hash(type, const DeepCollectionEquality().hash);

  @override
  bool operator ==(Object other) =>
      other is EncodedAsset &&
      type == other.type &&
      const DeepCollectionEquality().equals(encoding, other.encoding);
}

/// Extension methods for [EncodedAsset] to convert to and from syntax
/// nodes.
extension EncodedAssetSyntaxExtension on EncodedAsset {
  /// Creates a [EncodedAsset] from a [AssetSyntax] node.
  static EncodedAsset fromSyntax(AssetSyntax syntaxNode) => EncodedAsset(
    syntaxNode.type,
    syntaxNode.encoding?.json ?? {},
    encodingJsonPath: syntaxNode.encoding?.path,
  );

  /// Converts this [EncodedAsset] to a [AssetSyntax] node.
  AssetSyntax toSyntax() {
    final path = switch (encodingJsonPath) {
      // Remove the last element from the encoding path.
      final List<Object> l => l.sublist(0, l.length - 1),
      null => <Object>[],
    };
    return AssetSyntax(
      encoding: JsonObjectSyntax.fromJson(Map.of(encoding)),
      type: type,
      path: path,
    );
  }
}
