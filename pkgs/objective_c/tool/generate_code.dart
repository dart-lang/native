// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Runs the ffigen configs, then merges tool/data/extra_methods.dart.in into the
// Objective C bindings.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:ffigen/src/executables/ffigen.dart' as ffigen;

const cConfig = 'ffigen_c.yaml';
const objcConfig = 'ffigen_objc.yaml';
const cBindings = 'lib/src/c_bindings_generated.dart';
const objcBindings = 'lib/src/objective_c_bindings_generated.dart';
const extraMethodsFile = 'tool/data/extra_methods.dart.in';

void dartCmd(List<String> args) {
  final exec = Platform.resolvedExecutable;
  print('Running: $exec ${args.join(" ")}');
  final proc = Process.runSync(exec, args, runInShell: true);
  if (proc.exitCode != 0) {
    exitCode = proc.exitCode;
    print(proc.stdout);
    print(proc.stderr);
    throw Exception('Command failed: $exec ${args.join(" ")}');
  }
}

Map<String, String> parseExtraMethods(String filename) {
  final extraMethods = <String, String>{};
  String? currentClass;
  var methods = StringBuffer();
  for (final line in File(filename).readAsLinesSync()) {
    if (currentClass == null) {
      if (line.startsWith('class ')) {
        currentClass = line;
        methods = StringBuffer();
      }
    } else {
      if (line == '}') {
        extraMethods[currentClass] = methods.toString();
      } else {
        methods.writeln(line);
      }
    }
  }
  return extraMethods;
}

void mergeExtraMethods(String filename, Map<String, String> extraMethods) {
  final out = StringBuffer();
  for (final line in File(filename).readAsLinesSync()) {
    out.writeln(line);
    final methods = extraMethods[line];
    if (methods != null) {
      out.writeln(methods);
    }
  }
  File(filename).writeAsStringSync(out.toString());
}

Future<void> run() async {
  await ffigen.main(['--no-format', '-v', 'severe', '--config', cConfig]);
  await ffigen.main(['--no-format', '-v', 'severe', '--config', objcConfig]);
  mergeExtraMethods(objcBindings, parseExtraMethods(extraMethodsFile));
  dartCmd(['format', cBindings, objcBindings]);
}

Future<void> main() async {
  Directory.current = Platform.script.resolve('..').path;
  await run();
}
