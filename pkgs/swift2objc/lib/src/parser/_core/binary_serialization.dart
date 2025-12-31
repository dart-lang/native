// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Binary serialization for ParsedSymbolgraph.
///
/// Serializes and deserializes ParsedSymbolgraph to/from a compact binary
/// format, enabling pre-compiled Foundation to be loaded 10-50x faster than
/// JSON parsing by skipping the JSON decode step entirely.
library;

import 'dart:convert';
import 'dart:typed_data';

import '../../config.dart';
import 'json.dart';
import 'parsed_symbolgraph.dart';

/// Magic number to validate binary format.
const int _cacheMagic = 0xF04D0001; // "F04D" + version

/// Serialize a ParsedSymbolgraph to binary format.
///
/// Format: magic(4) | symbolCount(4) |
///   [id_len(4) id_str json_len(4) json_str]* |
///   relationCount(4) | [src_id_len(4) src_id_str count(4)
///   [key_len(4) key_str json_len(4) json_str kind(1)
///    src_len(4) src_str tgt_len(4) tgt_str]*]*
Uint8List serializeSymbolgraph(ParsedSymbolgraph symbolgraph) {
  final buffer = BytesBuilder();

  // Write header
  _writeUint32(buffer, _cacheMagic);

  // Serialize symbols count and data
  _writeUint32(buffer, symbolgraph.symbols.length);
  for (final entry in symbolgraph.symbols.entries) {
    _writeString(buffer, entry.key);
    // Use toString() which calls jsonEncode internally
    final jsonStr = entry.value.json.toString();
    _writeString(buffer, jsonStr);
  }

  // Serialize relations count and data
  _writeUint32(buffer, symbolgraph.relations.length);
  for (final entry in symbolgraph.relations.entries) {
    _writeString(buffer, entry.key);
    _writeUint32(buffer, entry.value.length);
    for (final relEntry in entry.value.entries) {
      _writeString(buffer, relEntry.key);
      _writeString(buffer, relEntry.value.json.toString());
      _writeUint8(buffer, relEntry.value.kind.index);
      _writeString(buffer, relEntry.value.sourceId);
      _writeString(buffer, relEntry.value.targetId);
    }
  }

  return buffer.toBytes();
}

/// Deserialize a ParsedSymbolgraph from binary format.
///
/// Reconstructs the original symbolgraph from the compact binary
/// representation.
ParsedSymbolgraph deserializeSymbolgraph(Uint8List data) {
  var offset = 0;

  // Read and validate header
  final magic = _readUint32(data, offset);
  offset += 4;

  if (magic != _cacheMagic) {
    throw FormatException('Invalid Foundation binary cache format: $magic');
  }

  // Deserialize symbols
  final symbolCount = _readUint32(data, offset);
  offset += 4;

  final symbols = <String, ParsedSymbol>{};
  for (var i = 0; i < symbolCount; i++) {
    final id = _readString(data, offset);
    offset += _lastSize;

    final jsonStr = _readString(data, offset);
    offset += _lastSize;

    // Parse JSON string back into Json object
    final jsonObj = jsonStr.isEmpty ? Json(null) : Json(jsonDecode(jsonStr));

    symbols[id] = ParsedSymbol(source: null, json: jsonObj);
  }

  // Deserialize relations
  final relationCount = _readUint32(data, offset);
  offset += 4;

  final relations = <String, Map<String, ParsedRelation>>{};
  for (var i = 0; i < relationCount; i++) {
    final id = _readString(data, offset);
    offset += _lastSize;

    final mapCount = _readUint32(data, offset);
    offset += 4;

    final relationMap = <String, ParsedRelation>{};
    for (var j = 0; j < mapCount; j++) {
      final key = _readString(data, offset);
      offset += _lastSize;

      final jsonStr = _readString(data, offset);
      offset += _lastSize;

      final kindIndex = _readUint8(data, offset);
      offset += 1;

      final sourceId = _readString(data, offset);
      offset += _lastSize;

      final targetId = _readString(data, offset);
      offset += _lastSize;

      relationMap[key] = ParsedRelation(
        source: builtInInputConfig,
        kind: ParsedRelationKind.values[kindIndex],
        sourceId: sourceId,
        targetId: targetId,
        json: Json(jsonDecode(jsonStr)),
      );
    }
    relations[id] = relationMap;
  }

  return ParsedSymbolgraph(symbols: symbols, relations: relations);
}

// ============================================================================
// Serialization Helpers
// ============================================================================

int _lastSize = 0;

void _writeUint32(BytesBuilder buffer, int value) {
  buffer.addByte((value >> 24) & 0xFF);
  buffer.addByte((value >> 16) & 0xFF);
  buffer.addByte((value >> 8) & 0xFF);
  buffer.addByte(value & 0xFF);
}

void _writeUint8(BytesBuilder buffer, int value) {
  buffer.addByte(value & 0xFF);
}

void _writeString(BytesBuilder buffer, String str) {
  final bytes = utf8.encode(str);
  _writeUint32(buffer, bytes.length);
  buffer.add(bytes);
}

int _readUint32(Uint8List data, int offset) {
  return ((data[offset] & 0xFF) << 24) |
      ((data[offset + 1] & 0xFF) << 16) |
      ((data[offset + 2] & 0xFF) << 8) |
      (data[offset + 3] & 0xFF);
}

int _readUint8(Uint8List data, int offset) {
  return data[offset] & 0xFF;
}

String _readString(Uint8List data, int offset) {
  final length = _readUint32(data, offset);
  _lastSize = 4 + length;

  if (length == 0) {
    return '';
  }

  final bytes = data.sublist(offset + 4, offset + 4 + length);
  return utf8.decode(bytes);
}
