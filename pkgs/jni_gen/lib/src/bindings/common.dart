// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/src/elements/elements.dart';

String mangledClassName(ClassDecl decl) =>
    decl.binaryName.replaceAll('.', '_').replaceAll('\$', '__');

String memberNameInC(ClassDecl decl, String name) =>
    "${mangledClassName(decl)}_$name";

String cType(String binaryName) {
  switch (binaryName) {
    case "void":
      return "void";
    case "byte":
      return "int8_t";
    case "char":
      return "char";
    case "double":
      return "double";
    case "float":
      return "float";
    case "int":
      return "int32_t";
    case "long":
      return "int64_t";
    case "short":
      return "int16_t";
    case "boolean":
      return "uint8_t";
    default:
      return "jobject";
  }
}

bool isPrimitive(TypeUsage t) => t.kind == Kind.primitive;

bool isStaticField(Field f) => f.modifiers.contains('static');
bool isStaticMethod(Method m) => m.modifiers.contains('static');

bool isFinalField(Field f) => f.modifiers.contains('final');
bool isFinalMethod(Method m) => m.modifiers.contains('final');

bool isCtor(Method m) => m.name == '<init>';
bool hasSelfParam(Method m) => !isStaticMethod(m) && !isCtor(m);

bool isObjectField(Field f) => !isPrimitive(f.type);
bool isObjectMethod(Method m) => !isPrimitive(m.returnType);

const ctorNameC = 'new';
const ctorNameDart = 'ctor';

// Marker exception when a method or class cannot be translated
// The inner functions may not know how much context has to be skipped in case
// of an error or unknown element. They throw SkipException.
class SkipException implements Exception {
  SkipException(this.message, [this.element]);
  String message;
  dynamic element;

  @override
  String toString() {
    return '$message;';
  }
}
