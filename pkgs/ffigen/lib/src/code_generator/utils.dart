// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'imports.dart';
import 'pointer.dart';
import 'scope.dart';
import 'type.dart';
import 'writer.dart';

/// The regex for line breaks (\r\n, \r, or \n).
final lineBreakRegex = RegExp(r'\r\n|\r|\n');

/// Converts [text] to a dart doc comment(`///`).
///
/// Comment is split on new lines (\r\n, \r, or \n).
String makeDartDoc(String? text, {String indent = ''}) {
  if (text == null) return '';
  final s = StringBuffer();
  s.write('$indent/// ');
  s.writeAll(text.split(lineBreakRegex), '\n$indent/// ');
  s.write('\n');

  return s.toString();
}

/// Converts [text] to a dart comment (`//`).
///
/// Comment is split on new lines (\r\n, \r, or \n).
String makeDoc(String text) {
  final s = StringBuffer();
  s.write('// ');
  s.writeAll(text.split(lineBreakRegex), '\n// ');
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
    args.add(('symbol', "'${Namer.stringLiteral(nativeSymbolName)}'"));
  }
  if (isLeaf) {
    args.add(('isLeaf', 'true'));
  }

  final combinedArgs = args.map((e) => '${e.$1}: ${e.$2}').join(', ');
  final ffiPrefix = w.context.libs.prefix(ffiImport);
  return '@$ffiPrefix.Native<$nativeType>($combinedArgs)';
}

String makeArrayAnnotation(Writer w, ConstantArray arrayType) {
  final dimensions = <int>[];
  Type type = arrayType;
  while (type is ConstantArray) {
    dimensions.add(type.length);
    type = type.child;
  }

  final ffiPrefix = w.context.libs.prefix(ffiImport);
  return '@$ffiPrefix.Array.multi([${dimensions.join(', ')}])';
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
final String dartExecutable = _findDart();

String _findDart() {
  final path = Platform.resolvedExecutable;
  if (p.basenameWithoutExtension(path) == 'dart') return path;
  final exeNames = Platform.isWindows
      ? const ['dart.exe', 'dart.bat']
      : const ['dart'];

  // Try walking up from Platform.resolvedExecutable (e.g. flutter_tester).
  var cur = path;
  while (true) {
    final parent = p.dirname(cur);
    if (parent == cur) break;
    cur = parent;
    for (final exe in exeNames) {
      final dartPath = p.normalize(p.join(cur, exe));
      if (File(dartPath).existsSync()) return dartPath;
    }
  }

  // Fallback 1: check DART_SDK environment variable.
  if (Platform.environment['DART_SDK'] case final sdk?) {
    for (final exe in exeNames) {
      final dartPath = p.normalize(p.join(sdk, 'bin', exe));
      if (File(dartPath).existsSync()) return dartPath;
    }
  }

  // Fallback 2: check PATH.
  final pathEnv = Platform.environment['PATH'];
  if (pathEnv != null) {
    final separator = Platform.isWindows ? ';' : ':';
    for (final dir in pathEnv.split(separator)) {
      if (dir.isEmpty) continue;
      // If dir is flutter/bin, check for embedded dart-sdk first.
      for (final exe in exeNames) {
        final embeddedDart = p.normalize(
          p.join(dir, 'cache', 'dart-sdk', 'bin', exe),
        );
        if (File(embeddedDart).existsSync()) return embeddedDart;
      }
      for (final exe in exeNames) {
        final candidate = p.normalize(p.join(dir, exe));
        if (File(candidate).existsSync()) return candidate;
      }
    }
  }

  throw Exception(
    "Couldn't find Dart executable near ${Platform.resolvedExecutable} "
    'or on PATH',
  );
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
  r'.*/Library(?:/.*/|/)Frameworks/([^/]+)\.framework(?:/.*/|/)Headers/(.*)',
);
