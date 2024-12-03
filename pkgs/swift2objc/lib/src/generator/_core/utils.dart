import 'dart:io';
import 'package:path/path.dart' as path;
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
    annotations.write(' async');
  }
  if (decl is CanThrow && (decl as CanThrow).throws) {
    annotations.write(' throws');
  }
  return annotations.toString();
}
