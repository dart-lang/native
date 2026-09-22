// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:snippet_tool/snippet_tool.dart';

ArgParser createArgParser() => ArgParser()
  ..addFlag(
    'set-exit-if-changed',
    negatable: false,
    help: 'Return a non-zero exit code if any files were changed.',
  )
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show usage information.',
  );

void main(List<String> args) {
  final stopwatch = Stopwatch()..start();
  final parser = createArgParser();
  final ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln('Usage: snippet_tool [options] <directories-or-files...>');
    stderr.writeln(parser.usage);
    exit(1);
  }

  if (argResults['help'] as bool) {
    print('Usage: snippet_tool [options] <directories-or-files...>');
    print(parser.usage);
    exit(0);
  }

  final paths = argResults.rest;
  if (paths.isEmpty) {
    stderr.writeln('Error: No target directories or files specified.');
    stderr.writeln('Usage: snippet_tool [options] <directories-or-files...>');
    stderr.writeln(parser.usage);
    exit(1);
  }

  final setExitIfChanged = argResults['set-exit-if-changed'] as bool;

  final counts = Counts();
  final errors = <String>[];

  for (final targetPath in paths) {
    final type = FileSystemEntity.typeSync(targetPath);
    if (type == FileSystemEntityType.file) {
      updateSnippetsInFile(File(targetPath), counts, errors);
    } else if (type == FileSystemEntityType.directory) {
      updateSnippetsInDirectory(Directory(targetPath), counts, errors);
    } else if (type == FileSystemEntityType.notFound) {
      errors.add('Error: Path does not exist: $targetPath.');
    }
  }

  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds / 1000.0;
  print(
    'Processed ${counts.processed} files (${counts.changed} changed) in '
    '${duration.toStringAsFixed(2)} seconds.',
  );

  if (errors.isNotEmpty) {
    for (final error in errors) {
      print(error);
    }
    exit(1);
  }

  if (setExitIfChanged && counts.changed > 0) {
    exit(1);
  }
}
