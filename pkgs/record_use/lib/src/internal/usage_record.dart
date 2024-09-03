// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

import '../public/identifier.dart';
import '../public/metadata.dart';
import '../public/reference.dart';
import 'usage.dart';

class UsageRecord extends Equatable {
  final Metadata metadata;
  final List<Usage<CallReference>> calls;
  final List<Usage<InstanceReference>> instances;

  UsageRecord({
    required this.metadata,
    required this.calls,
    required this.instances,
  });

  factory UsageRecord.fromJson(Map<String, dynamic> json) {
    final uris = json['uris'] as List<String>;
    final identifiers = (json['ids'] as List)
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => Identifier.fromJson(e, uris),
        )
        .toList();
    return UsageRecord(
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      calls: (json['calls'] as List?)
              ?.map((x) => Usage.fromJson(
                    x as Map<String, dynamic>,
                    identifiers,
                    uris,
                    CallReference.fromJson,
                  ))
              .toList() ??
          [],
      instances: (json['instances'] as List?)
              ?.map((x) => Usage.fromJson(
                    x as Map<String, dynamic>,
                    identifiers,
                    uris,
                    InstanceReference.fromJson,
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    final identifiers = <Identifier>{
      ...calls.map((call) => call.definition.identifier),
      ...instances.map((instance) => instance.definition.identifier),
    }.toList();
    final uris = <String>{
      ...identifiers.map((e) => e.uri),
      ...calls.expand((call) => [
            call.definition.location.uri,
            ...call.references.map((reference) => reference.location.uri),
          ]),
      ...instances.expand((instance) => [
            instance.definition.location.uri,
            ...instance.references.map((reference) => reference.location.uri),
          ]),
    }.toList();
    return {
      'metadata': metadata.toJson(),
      'uris': uris,
      'ids': identifiers.map((identifier) => identifier.toJson(uris)).toList(),
      if (calls.isNotEmpty)
        'calls': calls
            .map((reference) => reference.toJson(identifiers, uris))
            .toList(),
      if (instances.isNotEmpty)
        'instances': instances
            .map((reference) => reference.toJson(identifiers, uris))
            .toList(),
    };
  }

  @override
  List<Object?> get props => [metadata, calls, instances];
}
