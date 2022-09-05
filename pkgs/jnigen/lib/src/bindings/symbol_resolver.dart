// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A symbol resolver is useful mainly to convert a fully qualified name to
// a locally meaningful name, when creating dart bindings

import 'dart:math';

import 'package:jnigen/src/logging/logging.dart';

import 'package:jnigen/src/util/name_utils.dart';

abstract class SymbolResolver {
  /// Resolve the binary name to a String which can be used in dart code.
  String? resolve(String binaryName);
  List<String> getImportStrings();
}

class PackagePathResolver implements SymbolResolver {
  PackagePathResolver(this.importMap, this.currentPackage, this.inputClassNames,
      {this.predefined = const {}});

  final String currentPackage;
  final Map<String, String> importMap;
  final Map<String, String> predefined;
  final Set<String> inputClassNames;

  final List<String> importStrings = [];

  final Set<String> relativeImportedPackages = {};

  final Map<String, String> _importedNameToPackage = {};
  final Map<String, String> _packageToImportedName = {};

  /// Returns the dart name of the [binaryName] in current translation context,
  /// or `null` if the name cannot be resolved.
  @override
  String? resolve(String binaryName) {
    if (predefined.containsKey(binaryName)) {
      return predefined[binaryName];
    }
    final parts = cutFromLast(binaryName, '.');
    final package = parts[0];
    final typename = parts[1];
    final simpleTypeName = typename.replaceAll('\$', '_');

    if (package == currentPackage && inputClassNames.contains(binaryName)) {
      return simpleTypeName;
    }

    if (_packageToImportedName.containsKey(package)) {
      // This package was already resolved
      // but we still need to check if it was a relative import, in which case
      // the class not in inputClassNames cannot be mapped here.
      if (!relativeImportedPackages.contains(package) ||
          inputClassNames.contains(binaryName)) {
        final importedName = _packageToImportedName[package];
        return '$importedName.$simpleTypeName';
      }
    }

    final packageImport = getImport(package, binaryName);
    log.finest('$package resolved to $packageImport for $binaryName');
    if (packageImport == null) {
      return null;
    }

    final pkgName = cutFromLast(package, '.')[1];
    if (pkgName.isEmpty) {
      throw UnsupportedError('No package could be deduced from '
          'qualified binaryName');
    }

    // We always name imports with an underscore suffix, so that they can be
    // never shadowed by a parameter or local variable.
    var importedName = '${pkgName}_';
    int suffix = 0;
    while (_importedNameToPackage.containsKey(importedName)) {
      suffix++;
      importedName = '$pkgName${suffix}_';
    }

    _importedNameToPackage[importedName] = package;
    _packageToImportedName[package] = importedName;
    importStrings.add('import "$packageImport" as $importedName;\n');
    return '$importedName.$simpleTypeName';
  }

  /// Returns import string, or `null` if package not found.
  String? getImport(String packageToResolve, String binaryName) {
    final right = <String>[];
    var prefix = packageToResolve;

    if (prefix.isEmpty) {
      throw UnsupportedError('unexpected: empty package name.');
    }

    final dest = packageToResolve.split('.');
    final src = currentPackage.split('.');
    if (inputClassNames.contains(binaryName)) {
      int common = 0;
      for (int i = 0; i < src.length && i < dest.length; i++) {
        if (src[i] == dest[i]) {
          common++;
        }
      }
      // a.b.c => a/b/c.dart
      // from there
      // a/b.dart => ../b.dart
      // a.b.d => d.dart
      // a.b.c.d => c/d.dart
      var pathToCommon = '';
      if (common < src.length) {
        pathToCommon = '../' * (src.length - common);
      }
      final pathToPackage = dest.skip(max(common - 1, 0)).join('/');
      relativeImportedPackages.add(packageToResolve);
      return '$pathToCommon$pathToPackage.dart';
    }

    while (prefix.isNotEmpty) {
      final split = cutFromLast(prefix, '.');
      final left = split[0];
      right.add(split[1]);
      // eg: packages[org.apache.pdfbox]/org/apache/pdfbox.dart
      if (importMap.containsKey(prefix)) {
        final sub = packageToResolve.replaceAll('.', '/');
        final pkg = _suffix(importMap[prefix]!, '/');
        return '$pkg$sub.dart';
      }
      prefix = left;
    }
    return null;
  }

  String _suffix(String str, String suffix) {
    if (str.endsWith(suffix)) {
      return str;
    }
    return str + suffix;
  }

  @override
  List<String> getImportStrings() {
    return importStrings;
  }
}
