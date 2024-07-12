import 'dart:io';

import 'package:swift2objc/src/ast/_core/shared/parameter.dart';

String generateParameters(List<Parameter> params) {
  return params.map((param) {
    final String labels;
    if (param.internalName != null) {
      labels = "${param.name} ${param.internalName}";
    } else {
      labels = param.name;
    }

    return "${labels}: ${param.type.name}";
  }).join(", ");
}

extension Indentation on String {
  String indent([int count = 1]) {
    assert(count > 0);
    final lines = split("\n");
    final indentation = List.filled(count, "  ").join();
    return lines.map((line) => "$indentation$line").join("\n");
  }
}

extension PathSegments on String {
  String removePathSegment() {
    final delimIndex = lastIndexOf("/");
    if (delimIndex == -1) return "";
    return substring(0, delimIndex);
  }
  String addPathSegment(String segment) {
    return "$this/$segment";
  }
}

void outputNextToFile({
  required String filePath,
  required String content,
}) {
  final segments = filePath.split("/");
  segments.removeLast();
  segments.removeLast();
  File(
    (filePath.split("/")
          ..removeLast()
          ..add("output.swift"))
        .join("/"),
  ).writeAsStringSync(content);
}
