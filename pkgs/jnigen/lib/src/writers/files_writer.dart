// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';

import 'package:jnigen/src/bindings/bindings.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/util/find_package.dart';
import 'package:jnigen/src/util/name_utils.dart';
import 'package:jnigen/src/writers/bindings_writer.dart';

/// Resolver for file-per-package mapping, in which the java package hierarchy
/// is mirrored.
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

/// Writer which executes custom callback on passed class elements.
///
/// This class is provided for debugging purposes.
class CallbackWriter implements BindingsWriter {
  CallbackWriter(this.callback);
  Future<void> Function(Iterable<ClassDecl>) callback;
  @override
  Future<void> writeBindings(Iterable<ClassDecl> classes) async {
    await callback(classes);
  }
}

/// Writer which takes writes C and Dart bindings to specified directories.
///
/// The structure of dart files is determined by package structure of java.
/// One dart file corresponds to one java package, and it's path is decided by
/// fully qualified name of the package.
///
/// Example:
/// `android.os` -> `$dartWrappersRoot`/`android/os.dart`
class FilesWriter extends BindingsWriter {
  static const _initFileName = '_init.dart';

  FilesWriter(this.config);
  Config config;

  @override
  Future<void> writeBindings(Iterable<ClassDecl> classes) async {
    final preamble = config.preamble;
    final Map<String, List<ClassDecl>> packages = {};
    final Map<String, ClassDecl> classesByName = {};
    for (var c in classes) {
      classesByName.putIfAbsent(c.binaryName, () => c);
      packages.putIfAbsent(c.packageName!, () => <ClassDecl>[]);
      packages[c.packageName!]!.add(c);
    }
    final classNames = classesByName.keys.toSet();

    if (config.bindingsType == BindingsType.packageStructured) {
      throw UnimplementedError(
          "Package structured bindings are not yet implemented");
    }

    final cRoot = config.cRoot!;
    log.info("Using c root = $cRoot");
    final dartRoot = config.dartRoot!;
    log.info("Using dart root = $dartRoot");
    final libraryName = config.libraryName!;

    log.info('Creating dart init file ...');
    final initFileUri = dartRoot.resolve(_initFileName);
    final initFile = await File.fromUri(initFileUri).create(recursive: true);
    var initCode = DartBindingsGenerator.initFile(libraryName);
    if (preamble != null) {
      initCode = '$preamble\n$initCode';
    }
    await initFile.writeAsString(initCode, flush: true);
    final subdir = config.cSubdir ?? '.';
    final cFileRelativePath = '$subdir/$libraryName.c';
    final cFile = await File.fromUri(cRoot.resolve(cFileRelativePath))
        .create(recursive: true);
    final cFileStream = cFile.openWrite();
    if (preamble != null) {
      cFileStream.writeln(preamble);
    }
    cFileStream.write(CPreludes.prelude);
    ApiPreprocessor.preprocessAll(classesByName, config);
    for (var packageName in packages.keys) {
      final relativeFileName = '${packageName.replaceAll('.', '/')}.dart';
      final dartFileUri = dartRoot.resolve(relativeFileName);
      log.fine('Writing bindings for $packageName...');
      final dartFile = await File.fromUri(dartFileUri).create(recursive: true);
      final resolver = PackagePathResolver(
          config.importMap ?? const {}, packageName, classNames,
          predefined: {'java.lang.String': 'jni.JniString'});
      final cgen = CBindingGenerator(config);
      final dgen = DartBindingsGenerator(config, resolver);

      final package = packages[packageName]!;
      final cBindings = package.map(cgen.generateBinding).toList();
      final dartBindings = package.map(dgen.generateBinding).toList();
      // write imports from bindings
      final dartFileStream = dartFile.openWrite();
      final initImportPath = ('../' *
              relativeFileName.codeUnits
                  .where((cu) => '/'.codeUnitAt(0) == cu)
                  .length) +
          _initFileName;
      if (preamble != null) {
        dartFileStream.writeln(preamble);
      }
      dartFileStream
        ..write(DartBindingsGenerator.bindingFileHeaders)
        ..write(resolver.getImportStrings().join('\n'))
        ..write('import "$initImportPath" show jniLookup;\n\n');
      // write dart bindings only after all imports are figured out
      dartBindings.forEach(dartFileStream.write);
      cBindings.forEach(cFileStream.write);
      await dartFileStream.close();
    }
    await cFileStream.close();
    await BindingsWriter.runDartFormat(dartRoot.toFilePath());
    log.info('Copying auxiliary files...');
    await _copyFileFromPackage(
        'jni', 'src/dartjni.h', cRoot.resolve('$subdir/dartjni.h'));
    await _copyFileFromPackage(
        'jnigen', 'cmake/CMakeLists.txt.tmpl', cRoot.resolve('CMakeLists.txt'),
        transform: (s) {
      return s
          .replaceAll('{{LIBRARY_NAME}}', libraryName)
          .replaceAll('{{SUBDIR}}', subdir);
    });
    log.info('Completed.');
  }

  Future<void> _copyFileFromPackage(String package, String relPath, Uri target,
      {String Function(String)? transform}) async {
    final packagePath = await findPackageRoot(package);
    if (packagePath != null) {
      final sourceFile = File.fromUri(packagePath.resolve(relPath));
      final targetFile = await File.fromUri(target).create(recursive: true);
      var source = await sourceFile.readAsString();
      if (transform != null) {
        source = transform(source);
      }
      await targetFile.writeAsString(source);
    } else {
      log.warning('package $package not found! '
          'skipped copying ${target.toFilePath()}');
    }
  }
}
