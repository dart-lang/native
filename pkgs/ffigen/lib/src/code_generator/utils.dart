// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'pointer.dart';
import 'type.dart';
import 'unique_namer.dart';
import 'writer.dart';

/// Converts [text] to a dart doc comment(`///`).
///
/// Comment is split on new lines only.
String makeDartDoc(String? text) {
  if (text == null) return '';
  final s = StringBuffer();
  s.write('/// ');
  s.writeAll(text.split('\n'), '\n/// ');
  s.write('\n');

  return s.toString();
}

/// Converts [text] to a dart comment (`//`).
///
/// Comment is split on new lines only.
String makeDoc(String text) {
  final s = StringBuffer();
  s.write('// ');
  s.writeAll(text.split('\n'), '\n// ');
  s.write('\n');

  return s.toString();
}

String makeNativeAnnotation(
  Writer w, {
  required String? nativeType,
  required String dartName,
  required String nativeSymbolName,
  bool isLeaf = false,
}) {
  final args = <(String, String)>[];
  if (dartName != nativeSymbolName) {
    args.add(('symbol', "'${UniqueNamer.stringLiteral(nativeSymbolName)}'"));
  }
  if (isLeaf) {
    args.add(('isLeaf', 'true'));
  }

  final combinedArgs = args.map((e) => '${e.$1}: ${e.$2}').join(', ');
  return '@${w.ffiLibraryPrefix}.Native<$nativeType>($combinedArgs)';
}

String makeArrayAnnotation(Writer w, ConstantArray arrayType) {
  final dimensions = <int>[];
  Type type = arrayType;
  while (type is ConstantArray) {
    dimensions.add(type.length);
    type = type.child;
  }

  return '@${w.ffiLibraryPrefix}.Array.multi([${dimensions.join(', ')}])';
}

/// 32-bit FNV-1a hash function.
int fnvHash32(String input) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(input)) {
    hash = ((hash ^ byte) * 0x1000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// The path to the Dart executable.
///
/// This is usually just Platform.resolvedExecutable. But when running flutter
/// tests, the resolvedExecutable will be flutter_tester, and Dart will be in a
/// directory a few levels up from it.
String findDart() {
  var path = Platform.resolvedExecutable;
  if (p.basenameWithoutExtension(path) == 'dart') return path;
  final dartExe = 'dart${p.extension(path)}';
  while (path.isNotEmpty) {
    path = p.dirname(path);
    final dartPath = p.normalize(p.join(path, dartExe));
    if (File(dartPath).existsSync()) return dartPath;
  }
  throw Exception(
      "Couldn't find Dart executable near ${Platform.resolvedExecutable}");
}

/// Attempts to parse an absolute path to an ObjC framework header. Returns an
/// importable path if successful, otherwise returns null.
String? parseObjCFrameworkHeader(String path) {
  final match = _frameworkHeaderRegex.firstMatch(path);

  if (match == null) {
    return null;
  }

  return '${match[1]}/${match[2]}';
}

final _frameworkHeaderRegex = RegExp(
    r'.*/Library(?:/.*/|/)Frameworks/([^/]+)\.framework(?:/.*/|/)Headers/(.*)');
