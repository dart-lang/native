// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'hooks/syntax.g.dart' as syntax;
import 'utils/json.dart';

/// An encoding of a particular asset type.
final class EncodedAsset {
  /// The type of the asset (e.g. whether it's a code asset, data asset or ...)
  final String type;

  /// The json encoding of the asset.
  final UnmodifiableMapView<String, Object?> encoding;

  /// The path of this object in a larger JSON.
  ///
  /// If provided, used for more precise error messages.
  final List<Object>? jsonPath;

  EncodedAsset._(this.type, this.encoding, {this.jsonPath});

  EncodedAsset(this.type, Map<String, Object?> encoding, {this.jsonPath})
    : encoding = UnmodifiableMapView(
        // It would be better if `encoding` would be deep copied.
        // https://github.com/dart-lang/native/issues/2045
        Map.of(encoding),
      );

  /// Decode an [EncodedAsset] from json.
  factory EncodedAsset.fromJson(
    Map<String, Object?> json, [
    List<Object>? path,
  ]) {
    final syntax_ = syntax.Asset.fromJson(json, path: path ?? []);
    final encoding = Map<String, Object?>.of(syntax_.encoding?.json ?? {});
    final path_ = syntax_.encoding != null ? [...?path, 'encoding'] : path;

    return EncodedAsset._(
      syntax_.type,
      UnmodifiableMapView(encoding),
      jsonPath: path_,
    );
  }

  /// Encode this [EncodedAsset] tojson.
  Map<String, Object?> toJson() =>
      {'encoding': Map.of(encoding)..sortOnKey(), _typeKey: type}..sortOnKey();

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

const String _typeKey = 'type';
