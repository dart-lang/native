// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

const makefilesGenerator = 'make';
const ninjaGenerator = 'ninja';

const cmakeGeneratorNames = {
  makefilesGenerator: 'Unix Makefiles',
  ninjaGenerator: 'Ninja',
};

void runCommand(String exec, List<String> args, String workingDirectory) {
  stderr.writeln('+ $exec ${args.join(" ")}');
  final process =
      Process.runSync(exec, args, workingDirectory: workingDirectory);
  if (process.exitCode != 0) {
    stdout.writeln(process.stdout);
    stderr.writeln(process.stderr);
    stderr.writeln("command failed with exit code ${process.exitCode}");
    exit(-1);
  }
}

void main(List<String> arguments) {
  final argParser = ArgParser()
    ..addOption(
      "generator",
      abbr: 'G',
      help: 'Generator to pass to CMake. (Either "ninja" or "make").',
      allowed: [ninjaGenerator, makefilesGenerator],
      defaultsTo: Platform.isWindows ? ninjaGenerator : makefilesGenerator,
    )
    ..addFlag('help', abbr: 'h', help: 'Show this usage information.');
  final argResults = argParser.parse(arguments);
  if (argResults.rest.isNotEmpty || argResults['help'] as bool) {
    stderr.writeln('This script generates compile_commands.json for '
        'C source files in src/');
    stderr.writeln(argParser.usage);
    exitCode = 1;
    return;
  }
  final generator = cmakeGeneratorNames[argResults['generator']];
  final tempDir = Directory.current.createTempSync("clangd_setup_temp_");
  final src = Directory.current.uri.resolve("src/");
  try {
    runCommand(
        "cmake",
        [
          "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
          src.toFilePath(),
          "-G",
          generator!,
        ],
        tempDir.path);
    final createdFile = tempDir.uri.resolve("compile_commands.json");
    final target = src.resolve("compile_commands.json");
    File.fromUri(createdFile).renameSync(target.toFilePath());
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}
