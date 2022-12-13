// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';

import 'package:jnigen/src/bindings/bindings.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/util/name_utils.dart';
import 'package:jnigen/src/writers/bindings_writer.dart';

String getFileClassName(String binaryName) {
  final dollarSign = binaryName.indexOf('\$');
  if (dollarSign != -1) {
    return binaryName.substring(0, dollarSign);
  }
  return binaryName;
}

/// Resolver for file-per-package mapping, in which the java package hierarchy
/// is mirrored.
class FilePathResolver implements SymbolResolver {
  FilePathResolver({
    this.classes = const {},
    this.importMap = const {},
    required this.currentClass,
    this.inputClassNames = const {},
  });

  static const Map<String, String> predefined = {
    'java.lang.String': 'jni.JString',
  };

  static final predefinedClasses = {
    'java.lang.String': ClassDecl(
      binaryName: 'java.lang.String',
      packageName: 'java.lang',
      simpleName: 'String',
    )
      ..isIncluded = true
      ..isPreprocessed = true,
  };

  /// A map of all classes by their names
  final Map<String, ClassDecl> classes;

  /// Class corresponding to currently writing file.
  final String currentClass;

  /// Explicit import mappings.
  final Map<String, String> importMap;

  /// Names of all classes in input.
  final Set<String> inputClassNames;

  final List<String> importStrings = [];

  final Set<String> _relativeImportedClasses = {};

  final Map<String, String> _importedNameToClass = {};
  final Map<String, String> _classToImportedName = {};

  /// Returns the dart name of the [binaryName] in current translation context,
  /// or `null` if the name cannot be resolved.
  @override
  String? resolve(String binaryName) {
    if (predefined.containsKey(binaryName)) {
      return predefined[binaryName];
    }
    final target = getFileClassName(binaryName);
    final parts = cutFromLast(binaryName, '.');
    final typename = parts[1];
    final simpleTypeName = typename.replaceAll('\$', '_');

    if (target == currentClass && inputClassNames.contains(binaryName)) {
      return simpleTypeName;
    }

    if (_classToImportedName.containsKey(target)) {
      // This package was already resolved
      // but we still need to check if it was a relative import, in which case
      // the class not in inputClassNames cannot be mapped here.
      if (!_relativeImportedClasses.contains(target) ||
          inputClassNames.contains(binaryName)) {
        final importedName = _classToImportedName[target];
        return '$importedName.$simpleTypeName';
      }
    }

    final classImport = getImport(target, binaryName);
    log.finest('$target resolved to $classImport for $binaryName');
    if (classImport == null) {
      return null;
    }

    final pkgName = cutFromLast(target, '.')[1].toLowerCase();
    if (pkgName.isEmpty) {
      throw UnsupportedError('No package could be deduced from '
          'qualified binaryName');
    }

    // We always name imports with an underscore suffix, so that they can be
    // never shadowed by a parameter or local variable.
    var importedName = '${pkgName}_';
    int suffix = 0;
    while (_importedNameToClass.containsKey(importedName)) {
      suffix++;
      importedName = '$pkgName${suffix}_';
    }

    _importedNameToClass[importedName] = target;
    _classToImportedName[target] = importedName;
    importStrings.add('import "$classImport" as $importedName;\n');
    return '$importedName.$simpleTypeName';
  }

  /// Returns import string for [classToResolve], or `null` if the class is not
  /// found.
  ///
  /// [binaryName] is the class name trying to be resolved. This parameter is
  /// requested so that classes included in current bindings can be resolved
  /// using relative path.
  String? getImport(String classToResolve, String binaryName) {
    var prefix = classToResolve;

    // short circuit if the requested class is specified directly in import map.
    if (importMap.containsKey(binaryName)) {
      return importMap[binaryName]!;
    }

    if (prefix.isEmpty) {
      throw UnsupportedError('unexpected: empty package name.');
    }

    final dest = classToResolve.split('.');
    final src = currentClass.split('.');
    // Use relative import when the required class is included in current set
    // of bindings.
    if (inputClassNames.contains(binaryName)) {
      int common = 0;
      // find the common prefix path directory of current package, and directory
      // of target package
      // src.length - 1 simply corresponds to directory of the package.
      for (int i = 0; i < src.length - 1 && i < dest.length - 1; i++) {
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

    while (prefix.isNotEmpty) {
      final split = cutFromLast(prefix, '.');
      final left = split[0];
      if (importMap.containsKey(prefix)) {
        return importMap[prefix]!;
      }
      prefix = left;
    }
    return null;
  }

  @override
  List<String> getImportStrings() {
    return importStrings;
  }

  @override
  ClassDecl? resolveClass(String binaryName) {
    if (predefinedClasses.containsKey(binaryName)) {
      return predefinedClasses[binaryName];
    }
    return classes[binaryName];
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
  Future<void> writeBindings(List<ClassDecl> classes) async {
    final cBased = config.outputConfig.bindingsType == BindingsType.cBased;
    final preamble = config.preamble;
    final Map<String, List<ClassDecl>> files = {};
    final Map<String, ClassDecl> classesByName = {};
    final Map<String, Set<String>> packages = {};
    for (var c in classes) {
      classesByName.putIfAbsent(c.binaryName, () => c);
      final fileClass = getFileClassName(c.binaryName);

      files.putIfAbsent(fileClass, () => <ClassDecl>[]);
      files[fileClass]!.add(c);

      packages.putIfAbsent(c.packageName, () => {});
      packages[c.packageName]!.add(fileClass.split('.').last);
    }

    final classNames = classesByName.keys.toSet();
    ApiPreprocessor.preprocessAll(classesByName, config);

    final dartRoot = config.outputConfig.dartConfig.path;
    log.info("Using dart root = $dartRoot");
    final generator = cBased
        ? CBasedDartBindingsGenerator(config)
        : PureDartBindingsGenerator(config);

    if (cBased) {
      await writeCBindings(config, classes);
    }

    // Write init file
    final initFileUri = dartRoot.resolve("_init.dart");
    var initCode = generator.getInitFileContents();
    if (initCode.isNotEmpty) {
      if (preamble != null) {
        initCode = '$preamble\n$initCode';
      }
      final initFile = File.fromUri(initFileUri);
      await initFile.create(recursive: true);
      await initFile.writeAsString(initCode);
    }

    for (var fileClassName in files.keys) {
      final relativeFileName = '${fileClassName.replaceAll('.', '/')}.dart';
      final dartFileUri = dartRoot.resolve(relativeFileName);
      final dartFile = await File.fromUri(dartFileUri).create(recursive: true);
      log.fine('$fileClassName -> ${dartFile.path}');
      final resolver = FilePathResolver(
        classes: classesByName,
        importMap: config.importMap ?? const {},
        currentClass: fileClassName,
        inputClassNames: classNames,
      );

      final classesInFile = files[fileClassName]!;
      final dartBindings = classesInFile
          .map((decl) => generator.generateBindings(decl, resolver))
          .toList();
      final dartFileStream = dartFile.openWrite();
      if (preamble != null) {
        dartFileStream.writeln(preamble);
      }

      final initFilePath = ('../' *
              relativeFileName.codeUnits
                  .where((cu) => '/'.codeUnitAt(0) == cu)
                  .length) +
          _initFileName;

      dartFileStream
        ..write(generator.getPreImportBoilerplate(initFilePath))
        ..write(resolver.getImportStrings().join('\n'))
        ..write(generator.getPostImportBoilerplate(initFilePath));

      // write dart bindings only after all imports are figured out
      dartBindings.forEach(dartFileStream.write);
      await dartFileStream.close();
    }

    // write _package.dart export files
    for (var package in packages.keys) {
      final dirUri = dartRoot.resolve('${package.replaceAll('.', '/')}/');
      final exportFileUri = dirUri.resolve("_package.dart");
      final exportFile = File.fromUri(exportFileUri);
      exportFile.createSync(recursive: true);
      final exports =
          packages[package]!.map((cls) => 'export "$cls.dart";').join('\n');
      exportFile.writeAsStringSync(exports);
    }

    await runDartFormat(dartRoot.toFilePath());
    log.info('Completed.');
  }
}
