// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'utils/json.dart';

/// An encoding of a particular asset type.
final class EncodedAsset {
  /// The type of the asset (e.g. whether it's a code asset, data asset or ...)
  final String type;

  /// The json encoding of the asset.
  final Map<String, Object?> encoding;

  EncodedAsset(this.type, this.encoding);

  /// Decode an [EncodedAsset] from json.
  factory EncodedAsset.fromJson(Map<String, Object?> json) =>
      EncodedAsset(json.get<String>(_typeKey), {
        for (final key in json.keys)
          if (key != _typeKey) key: json[key],
      });

  /// Encode this [EncodedAsset] tojson.
  Map<String, Object?> toJson() =>
      {for (final key in encoding.keys) key: encoding[key], _typeKey: type}
        ..sortOnKey();

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
