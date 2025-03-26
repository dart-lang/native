// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

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
