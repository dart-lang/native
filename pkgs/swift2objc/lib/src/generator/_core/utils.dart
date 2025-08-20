// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:path/path.dart' as path;
import '../../ast/_core/interfaces/availability.dart';
import '../../ast/_core/interfaces/can_async.dart';
import '../../ast/_core/interfaces/can_throw.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';

String generateParameters(List<Parameter> params) {
  return params.map((param) {
    final String labels;
    if (param.internalName != null) {
      labels = '${param.name} ${param.internalName}';
    } else {
      labels = param.name;
    }

    return '$labels: ${param.type.swiftType}';
  }).join(', ');
}

extension Indentation on Iterable<String> {
  Iterable<String> indent([int count = 1]) {
    assert(count >= 0);
    final indentation = '  ' * count;
    return map((line) => line.isEmpty ? '' : '$indentation$line');
  }
}

void outputNextToFile({
  required String filePath,
  required String content,
}) {
  final segments = path.split(filePath);
  segments.removeLast();
  segments.add('output.swift');
  final outputPath = path.joinAll(segments);

  File(outputPath).writeAsStringSync(content);
}

String generateAnnotations(Declaration decl) {
  final annotations = StringBuffer();
  if (decl is CanAsync && (decl as CanAsync).async) {
    annotations.write('async ');
  }
  if (decl is CanThrow && (decl as CanThrow).throws) {
    annotations.write('throws ');
  }
  return annotations.toString();
}

List<String> generateAvailability(Declaration decl) =>
    decl.availability.map(_generateAvailabilityInfo).toList();

String _generateAvailabilityInfo(AvailabilityInfo info) =>
    '@available(${_generateAvailabilityInfoList(info).join(', ')})';

Iterable<String> _generateAvailabilityInfoList(AvailabilityInfo info) => [
      info.domain,
      info.unavailable ? 'unavailable' : null,
      _generateAvailabilityVersion(info.introduced, 'introduced'),
      _generateAvailabilityVersion(info.deprecated, 'deprecated'),
      _generateAvailabilityVersion(info.obsoleted, 'obsoleted'),
    ].nonNulls;

String? _generateAvailabilityVersion(AvailabilityVersion? v, String key) =>
    v == null ? null : '$key: $v';
