import 'dart:io';
import 'package:path/path.dart' as path;
import '../../ast/_core/shared/parameter.dart';

String generateParameters(List<Parameter> params) {
  return params.map((param) {
    final String labels;
    if (param.internalName != null) {
      labels = '${param.name} ${param.internalName}';
    } else {
      labels = param.name;
    }

    return '$labels: ${param.type.name}';
  }).join(', ');
}

extension Indentation on String {
  String indent([int count = 1]) {
    assert(count > 0);
    final lines = split('\n');
    final indentation = List.filled(count, '  ').join();
    return lines.map((line) => '$indentation$line').join('\n');
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
