// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import 'helper.dart';
import 'syntax.g.dart';

/// Metadata attached to a recorded usages file.
///
/// Whatever [Metadata] should be added to the usage recording. Care should be
/// applied to not include non-deterministic or dynamic data such as timestamps,
/// as this would mess with the usage recording caching.
class Metadata {
  final MetadataSyntax _syntax;

  const Metadata._(this._syntax);

  factory Metadata({
    required Version version,
    required String comment,
    Map<String, Object?>? extension,
  }) {
    final syntax = MetadataSyntax(
      comment: comment,
      version: version.toString(),
    );
    // TODO(https://github.com/dart-lang/native/issues/2984): Nest extension
    // fields.
    return Metadata._(
      MetadataSyntax.fromJson({...syntax.json, ...?extension}),
    );
  }

  /// The underlying data.
  ///
  /// This makes the metadata extensible by the user implementing the recording.
  /// For example, dart2js might want to store different metadata than the Dart
  /// VM.
  Map<String, Object?> get json => _syntax.json;

  Version get version => Version.parse(_syntax.version);

  String get comment => _syntax.comment;

  Map<String, Object?>? get extension {
    // TODO(https://github.com/dart-lang/native/issues/2984): Nest extension
    // fields.
    final dummy = MetadataSyntax(comment: comment, version: version.toString());
    return {
      for (final entry in _syntax.json.entries)
        if (!dummy.json.keys.contains(entry.key)) entry.key: entry.value,
    };
  }

  @override
  bool operator ==(covariant Metadata other) {
    if (identical(this, other)) return true;

    return deepEquals(other.json, json);
  }

  @override
  int get hashCode => deepHash(json);
}

/// Package private (protected) methods for [Metadata].
///
/// This avoids bloating the public API and public API docs and prevents
/// internal types from leaking from the API.
extension MetadataProtected on Metadata {
  MetadataSyntax toSyntax() => _syntax;

  static Metadata fromSyntax(MetadataSyntax syntax) => Metadata._(syntax);
}
