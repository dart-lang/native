// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:pub_semver/pub_semver.dart';

class Metadata extends Equatable {
  final String? comment;
  final Version version;

  Metadata({
    this.comment,
    required this.version,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        comment: json['comment'] as String?,
        version: Version.parse(json['version'] as String),
      );

  Map<String, dynamic> toJson() => {
        if (comment != null) 'comment': comment,
        'version': version.toString(),
      };

  @override
  String toString() {
    return '''
Metadata(
  comment: $comment,
  version: $version,
)
''';
  }

  @override
  List<Object?> get props => [comment, version];
}
