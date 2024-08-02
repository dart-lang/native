// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart_keywords.dart';
import 'pointer.dart';
import 'type.dart';
import 'writer.dart';

export 'package:ffigen/src/code_generator/utils.dart'
    show makeDartDoc, makeDoc, parseObjCFrameworkHeader;

class UniqueNamer {
  final Set<String> _usedUpNames;

  /// Creates a UniqueNamer with given [usedUpNames] and Dart reserved keywords.
  ///
  /// If [parent] is provided, also includes all the parent's names.
  UniqueNamer(Set<String> usedUpNames, {UniqueNamer? parent})
      : _usedUpNames = {
          ...keywords,
          ...usedUpNames,
          ...parent?._usedUpNames ?? {},
        };

  /// Creates a UniqueNamer with given [_usedUpNames] only.
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
