// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;

import 'dart_keywords.dart';
import 'pointer.dart';
import 'type.dart';
import 'writer.dart';

class UniqueNamer {
  final Set<String> _usedUpNames;

  /// Creates a UniqueNamer with given [usedUpNames] and Dart reserved keywords.
  UniqueNamer(Set<String> usedUpNames)
      : assert(keywords.intersection(usedUpNames).isEmpty),
        _usedUpNames = {...keywords, ...usedUpNames};

  /// Creates a UniqueNamer with given [usedUpNames] only.
  UniqueNamer._raw(this._usedUpNames);

  /// Returns a unique name by appending `<int>` to it if necessary.
  ///
  /// Adds the resulting name to the used names by default.
  String makeUnique(String name, [bool addToUsedUpNames = true]) {
    // For example, nested structures/unions may not have a name
    if (name.isEmpty) {
      name = 'unnamed';
    }

    var crName = name;
    var i = 1;
    while (_usedUpNames.contains(crName)) {
      crName = '$name$i';
      i++;
    }
    if (addToUsedUpNames) {
      _usedUpNames.add(crName);
    }
    return crName;
  }

  /// Adds a name to used names.
  ///
  /// Note: [makeUnique] also adds the name by default.
  void markUsed(String name) {
    _usedUpNames.add(name);
  }

  /// Returns true if a name has been used before.
  bool isUsed(String name) {
    return _usedUpNames.contains(name);
  }

  /// Returns true if a name has not been used before.
  bool isUnique(String name) {
    return !_usedUpNames.contains(name);
  }

  UniqueNamer clone() => UniqueNamer._raw({..._usedUpNames});
}

/// Converts [text] to a dart doc comment(`///`).
///
/// Comment is split on new lines only.
String makeDartDoc(String text) {
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
    args.add(('symbol', '"$nativeSymbolName"'));
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

/// The path to the Dart executable.
///
/// This is usually just Platform.resolvedExecutable. But when running flutter
/// tests, the resolvedExecutable will be flutter_tester, and Dart will be in a
/// directory a few levels up from it.
String findDart() {
  String path = Platform.resolvedExecutable;
  if (p.basenameWithoutExtension(path) == 'dart') return path;
  final dartExe = 'dart${p.extension(path)}';
  while (path.isNotEmpty) {
    path = p.dirname(path);
    final dartPath = p.join(path, dartExe);
    if (File(dartPath).existsSync()) return dartPath;
  }
  throw Exception(
      "Couldn't find Dart executable near ${Platform.resolvedExecutable}");
}
