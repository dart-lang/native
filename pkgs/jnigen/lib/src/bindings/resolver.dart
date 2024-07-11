// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import '../elements/elements.dart';
import '../logging/logging.dart';

class Resolver {
  /// Class corresponding to currently writing file.
  ///
  /// Is `null` when in single file mode.
  final String? currentClass;

  /// Explicit import mappings.
  final Map<String, ClassDecl> importedClasses;

  /// Names of all classes in input.
  final Set<String> inputClassNames;

  final List<String> _importStrings = [];

  final Set<String> _relativeImportedClasses = {};
  final Map<String, String> _importedNameToClass = {};
  final Map<String, String> _classToImportedName = {};

  Resolver({
    required this.importedClasses,
    required this.currentClass,
    this.inputClassNames = const {},
  });

  static String getFileClassName(String binaryName) {
    final dollarSign = binaryName.indexOf('\$');
    if (dollarSign != -1) {
      return binaryName.substring(0, dollarSign);
    }
    return binaryName;
  }

  /// splits [str] into 2 from last occurence of [sep]
  static List<String> cutFromLast(String str, String sep) {
    final li = str.lastIndexOf(sep);
    if (li == -1) {
      return ['', str];
    }
    return [str.substring(0, li), str.substring(li + 1)];
  }

  /// Get the prefix for the class
  String resolvePrefix(ClassDecl classDecl) {
    if (classDecl.path == 'package:jni/jni.dart') {
      // For package:jni we don't use a leading underscore.
      return 'jni.';
    }
    final binaryName = classDecl.binaryName;
    final target = getFileClassName(binaryName);

    // For classes we generate (inside [inputClassNames]) no import
    // (and therefore no prefix) is necessary when:
    // * Never necessary in single file mode
    // * In multi file mode if the target is the same as the current class
    if ((currentClass == null || target == currentClass) &&
        inputClassNames.contains(binaryName)) {
      return '';
    }

    if (_classToImportedName.containsKey(target)) {
      // This package was already resolved
      // but we still need to check if it was a relative import, in which case
      // the class not in inputClassNames cannot be mapped here.
      if (!_relativeImportedClasses.contains(target) ||
          inputClassNames.contains(binaryName)) {
        final importedName = _classToImportedName[target];
        return '$importedName.';
      }
    }

    final classImport = getImport(target, binaryName);
    log.finest('$target resolved to $classImport for $binaryName');
    if (classImport == null) {
      return '';
    }

    final pkgName = cutFromLast(target, '.')[1].toLowerCase();
    if (pkgName.isEmpty) {
      throw UnsupportedError('No package could be deduced from '
          'qualified binaryName');
    }

    // We always name imports with an underscore suffix, so that they can be
    // never shadowed by a parameter or local variable.
    var importedName = '${pkgName}_';
    var suffix = 0;
    while (_importedNameToClass.containsKey(importedName)) {
      suffix++;
      importedName = '$pkgName${suffix}_';
    }

    _importedNameToClass[importedName] = target;
    _classToImportedName[target] = importedName;
    _importStrings.add("import '$classImport' as $importedName;\n");
    return '$importedName.';
  }

  /// Returns import string for [classToResolve], or `null` if the class is not
  /// found.
  ///
  /// [binaryName] is the class name trying to be resolved. This parameter is
  /// requested so that classes included in current bindings can be resolved
  /// using relative path.
  String? getImport(String classToResolve, String binaryName) {
    final prefix = classToResolve;

    // short circuit if the requested class is specified directly in import map.
    if (importedClasses.containsKey(binaryName)) {
      return importedClasses[binaryName]!.path;
    }

    if (prefix.isEmpty) {
      throw UnsupportedError('unexpected: empty package name.');
    }

    final dest = classToResolve.split('.');
    final src = currentClass!.split('.');
    // Use relative import when the required class is included in current set
    // of bindings.
    if (inputClassNames.contains(binaryName)) {
      var common = 0;
      // find the common prefix path directory of current package, and directory
      // of target package
      // src.length - 1 simply corresponds to directory of the package.
      for (var i = 0; i < src.length - 1 && i < dest.length - 1; i++) {
        if (src[i] == dest[i]) {
          common++;
        } else {
          break;
        }
      }
      final pathToCommon = '../' * ((src.length - 1) - common);
      final pathToClass = dest.sublist(max(common, 0)).join('/');
      _relativeImportedClasses.add(classToResolve);
      return '$pathToCommon$pathToClass.dart';
    }

    return null;
  }

  List<String> get importStrings {
    return _importStrings..sort();
  }
}
