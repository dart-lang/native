// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import '../proto/usages_read.pb.dart' as pb;
import '../proto/usages_shared.pb.dart' as pb_shared;
import '../proto/usages_storage.pb.dart' as pb_storage;

extension UsagesExt on pb.Usages {
  Uint8List toBuffer() => _toStorage().writeToBuffer();
  String toDebugJson() =>
      const JsonEncoder.withIndent('  ').convert(_toStorage().writeToJsonMap());

  pb_storage.Usages _toStorage() {
    final usageList = [...calls, ...instances];
    final uris = usageList
        .expand((usage) => [
              usage.definition.identifier.uri,
              ...usage.references.map((reference) => reference.location.uri)
            ])
        .toSet()
        .toList();
    final definitions = usageList
        .map((usage) => usage.definition.toStorage(uris))
        .toSet()
        .toList();
    return pb_storage.Usages(
      metadata: metadata,
      definitions: definitions,
      uris: uris,
      instances:
          instances.map((instance) => instance.toStorage(definitions, uris)),
      calls: calls.map((call) => call.toStorage(definitions, uris)),
    );
  }
}

extension UsageExt on pb.Usage {
  pb_storage.Usage toStorage(
          List<pb_storage.Definition> definitions, List<String> uris) =>
      pb_storage.Usage(
        definition: definitions.indexOf(definition.toStorage(uris)),
        references: references.map((e) => e.toStorage(uris)),
      );
}

extension ReferenceExt on pb.Reference {
  pb_storage.Reference toStorage(List<String> uris) => pb_storage.Reference(
        arguments: hasArguments() ? arguments : null,
        fields: hasFields() ? fields : null,
        loadingUnit: loadingUnit,
        location: location.toStorage(uris),
      );
}

extension LocationExt on pb.Location {
  pb_storage.Location toStorage(List<String> uris) => pb_storage.Location(
        column: column,
        line: line,
        uri: uris.indexOf(uri),
      );
}

extension DefinitionExt on pb.Definition {
  pb_storage.Definition toStorage(List<String> uris) => pb_storage.Definition(
        identifier: identifier.toStorage(uris),
        column: column,
        line: line,
        loadingUnit: hasLoadingUnit() ? loadingUnit : null,
      );
}

extension IdentifierExt on pb.Identifier {
  pb_storage.Identifier toStorage(List<String> uris) => pb_storage.Identifier(
        name: name,
        parent: hasParent() ? parent : null,
        uri: uris.indexOf(uri),
      );
}

extension UsagesStorageExt on pb_storage.Usages {
  pb.Usages toApi() => pb.Usages(
        metadata: metadata,
        calls: calls.map((e) => e.toApi(definitions, uris)),
        instances: instances.map((e) => e.toApi(definitions, uris)),
      );
}

extension UsageStorageExt on pb_storage.Usage {
  pb.Usage toApi(List<pb_storage.Definition> definitions, List<String> uris) =>
      pb.Usage(
        definition: definitions[definition].toApi(uris),
        references: references.map((e) => e.toApi(uris)),
      );
}

extension ReferenceStorageExt on pb_storage.Reference {
  pb.Reference toApi(List<String> uris) => pb.Reference(
        arguments: hasArguments() ? arguments : null,
        fields: hasFields() ? fields : null,
        loadingUnit: loadingUnit,
        location: location.toApi(uris),
      );
}

extension LocationStorageExt on pb_storage.Location {
  pb.Location toApi(List<String> uris) => pb.Location(
        column: column,
        line: line,
        uri: uris[uri],
      );
}

extension DefinitionStorageExt on pb_storage.Definition {
  pb.Definition toApi(List<String> uris) => pb.Definition(
        identifier: identifier.toApi(uris),
        column: column,
        line: line,
        loadingUnit: hasLoadingUnit() ? loadingUnit : null,
      );
}

extension IdentifierStorageExt on pb_storage.Identifier {
  pb.Identifier toApi(List<String> uris) => pb.Identifier(
        name: name,
        parent: hasParent() ? parent : null,
        uri: uris[uri],
      );
}

extension FieldValueExt on pb_shared.FieldValue {
  Object toObject() => switch (whichValue()) {
        pb_shared.FieldValue_Value.mapValue =>
          mapValue.value.map((key, value) => MapEntry(key, value.toObject())),
        pb_shared.FieldValue_Value.listValue =>
          listValue.value.map((e) => e.toObject()),
        pb_shared.FieldValue_Value.intValue => intValue,
        pb_shared.FieldValue_Value.doubleValue => doubleValue,
        pb_shared.FieldValue_Value.boolValue => boolValue,
        pb_shared.FieldValue_Value.stringValue => stringValue,
        pb_shared.FieldValue_Value.nullValue => nullValue,
        pb_shared.FieldValue_Value.notSet => throw UnimplementedError(),
      };
}
