// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../bindings/c_bindings.dart';
import '../config/config.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import '../util/find_package.dart';

/// Run dart format command on [path].
Future<void> runDartFormat(String path) async {
  log.info('Running dart format...');
  final formatRes = await Process.run('dart', ['format', path]);
  // if negative exit code, likely due to an interrupt.
  if (formatRes.exitCode > 0) {
    log.fatal('Dart format completed with exit code ${formatRes.exitCode} '
        'This usually means there\'s a syntax error in bindings.\n'
        'Please look at the generated files and report a bug.');
  }
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

Future<void> writeCBindings(Config config, List<ClassDecl> classes) async {
  // write C file and init file
  final cConfig = config.outputConfig.cConfig!;
  final cRoot = cConfig.path;
  final preamble = config.preamble;
  log.info("Using c root = $cRoot");
  final libraryName = cConfig.libraryName;
  log.info('Creating dart init file ...');
  // Create C file
  final subdir = cConfig.subdir ?? '.';
  final cFileRelativePath = '$subdir/$libraryName.c';
  final cFile = await File.fromUri(cRoot.resolve(cFileRelativePath))
      .create(recursive: true);
  final cFileStream = cFile.openWrite();
  // Write C Bindings
  if (preamble != null) {
    cFileStream.writeln(preamble);
  }
  cFileStream.write(CPreludes.prelude);
  final cgen = CBindingGenerator(config);
  final cBindings = classes.map(cgen.generateBinding).toList();
  log.info('writing c bindings to $cFile');
  cBindings.forEach(cFileStream.write);
  await cFileStream.close();
  log.info('Copying auxiliary files...');
  await _copyFileFromPackage(
      'jni', 'src/dartjni.h', cRoot.resolve('$subdir/dartjni.h'));
  await _copyFileFromPackage(
      'jni', 'src/.clang-format', cRoot.resolve('$subdir/.clang-format'));
  await _copyFileFromPackage(
      'jnigen', 'cmake/CMakeLists.txt.tmpl', cRoot.resolve('CMakeLists.txt'),
      transform: (s) {
    return s
        .replaceAll('{{LIBRARY_NAME}}', libraryName)
        .replaceAll('{{SUBDIR}}', subdir);
  });
  log.info('Running clang-format on C bindings');
  try {
    final clangFormat = Process.runSync('clang-format', ['-i', cFile.path]);
    if (clangFormat.exitCode != 0) {
      printError(clangFormat.stderr);
      log.warning('clang-format exited with ${clangFormat.exitCode}');
    }
  } on ProcessException catch (e) {
    log.warning('cannot run clang-format: $e');
  }
}
