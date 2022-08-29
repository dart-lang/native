// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni_gen/src/bindings/bindings.dart';

import 'package:jni_gen/src/elements/elements.dart';
import 'package:jni_gen/src/config/config.dart';
import 'package:jni_gen/src/util/find_package.dart';

abstract class BindingsWriter {
  Future<void> writeBindings(Iterable<ClassDecl> classes);
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
  static const _initFileName = 'init.dart';

  FilesWriter(this.config);
  Config config;

  @override
  Future<void> writeBindings(Iterable<ClassDecl> classes) async {
    // If the file already exists, show warning.
    // sort classes so that all classes get written at once.
    final cRoot = config.cRoot;
    final dartRoot = config.dartRoot;
    final libraryName = config.libraryName;
    final preamble = config.preamble;

    final Map<String, List<ClassDecl>> packages = {};
    final Map<String, ClassDecl> classesByName = {};
    for (var c in classes) {
      classesByName.putIfAbsent(c.binaryName, () => c);
      packages.putIfAbsent(c.packageName!, () => <ClassDecl>[]);
      packages[c.packageName!]!.add(c);
    }
    final classNames = classesByName.keys.toSet();

    stderr.writeln('Creating dart init file ...');
    final initFileUri = dartRoot.resolve(_initFileName);
    final initFile = await File.fromUri(initFileUri).create(recursive: true);
    await initFile.writeAsString(DartPreludes.initFile(config.libraryName),
        flush: true);

    final cFile = await File.fromUri(cRoot.resolve('$libraryName.c'))
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
      stderr.writeln('Writing bindings for $packageName...');
      final dartFile = await File.fromUri(dartFileUri).create(recursive: true);
      final resolver = PackagePathResolver(
          config.importMap ?? const {}, packageName, classNames,
          predefined: {'java.lang.String': 'jni.JlString'});
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
        ..write(DartPreludes.bindingFileHeaders)
        ..write(resolver.getImportStrings().join('\n'))
        ..write('import "$initImportPath" show jlookup;\n\n');
      // write dart bindings only after all imports are figured out
      dartBindings.forEach(dartFileStream.write);
      cBindings.forEach(cFileStream.write);
      await dartFileStream.close();
    }
    await cFileStream.close();
    stderr.writeln('Running dart format...');
    final formatRes =
        await Process.run('dart', ['format', dartRoot.toFilePath()]);
    if (formatRes.exitCode != 0) {
      stderr.writeln('ERROR: dart format completed with '
          'exit code ${formatRes.exitCode}');
    }

    stderr.writeln('Copying auxiliary files...');
    await _copyFileFromPackage(
        'jni', 'src/dartjni.h', cRoot.resolve('dartjni.h'));
    await _copyFileFromPackage(
        'jni_gen', 'cmake/CMakeLists.txt.tmpl', cRoot.resolve('CMakeLists.txt'),
        transform: (s) => s.replaceAll('{{LIBRARY_NAME}}', libraryName));
    stderr.writeln('Completed.');
  }

  Future<void> _copyFileFromPackage(String package, String relPath, Uri target,
      {String Function(String)? transform}) async {
    final packagePath = await findPackageRoot(package);
    if (packagePath != null) {
      final sourceFile = File.fromUri(packagePath.resolve(relPath));
      final targetFile = await File.fromUri(target).create();
      var source = await sourceFile.readAsString();
      if (transform != null) {
        source = transform(source);
      }
      await targetFile.writeAsString(source);
    } else {
      stderr.writeln('package $package not found! '
          'skipped copying ${target.toFilePath()}');
    }
  }
}
