// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Runs the ffigen configs, then merges tool/data/extra_methods.dart.in and
// tool/data/extra_methods.dart.in into the Objective C bindings.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/src/executables/ffigen.dart' as ffigen;

const cConfig = 'ffigen_c.yaml';
const objcConfig = 'ffigen_objc.yaml';
const cBindings = 'lib/src/c_bindings_generated.dart';
const objcBindings = 'lib/src/objective_c_bindings_generated.dart';
const extraMethodsFile = 'tool/data/extra_methods.dart.in';
const extraClassesFile = 'tool/data/extra_classes.dart.in';

void dartCmd(List<String> args) {
  final exec = Platform.resolvedExecutable;
  final proc = Process.runSync(exec, args, runInShell: true);
  if (proc.exitCode != 0) {
    exitCode = proc.exitCode;
    print(proc.stdout);
    print(proc.stderr);
    throw Exception('Command failed: $exec ${args.join(" ")}');
  }
}

typedef ClassInfo = ({
  String cls,
  String? ext,
  List<String> mix,
  List<String> impl,
});
final _clsDecl = RegExp(
    r'^class (.*?)(?: extends (.*?))?(?: with (.*?))?(?: implements (.*?))? {');
ClassInfo? parseClassDecl(String line) {
  final match = _clsDecl.firstMatch(line);
  if (match == null) return null;
  return (
    cls: match[1]!,
    ext: match[2],
    mix: match[3]?.split(', ') ?? [],
    impl: match[4]?.split(', ') ?? []
  );
}

typedef ExtraMethods = ({List<String> impl, List<String> mix, String methods});
Map<String, ExtraMethods> parseExtraMethods(String filename) {
  final extraMethods = <String, ExtraMethods>{};
  String? currentClass;
  late List<String> impl;
  late List<String> mix;
  late StringBuffer methods;
  for (final line in File(filename).readAsLinesSync()) {
    if (currentClass == null) {
      final match = parseClassDecl(line);
      if (match != null) {
        currentClass = match.cls;
        impl = match.impl;
        mix = match.mix;
        methods = StringBuffer();
      }
    } else {
      if (line == '}') {
        extraMethods[currentClass] =
            (impl: impl, mix: mix, methods: methods.toString());
        currentClass = null;
      } else {
        methods.writeln(line);
      }
    }
  }
  return extraMethods;
}

void mergeExtras(String filename, Map<String, ExtraMethods> extraMethods,
    String extraClasses) {
  final out = StringBuffer();
  for (final line in File(filename).readAsLinesSync()) {
    final match = parseClassDecl(line);
    final extra = match == null ? null : extraMethods[match.cls];
    if (match == null || extra == null) {
      out.writeln(line);
    } else {
      out.write('class ${match.cls}');
      if (match.ext != null) out.write(' extends ${match.ext}');
      final mix = [...match.mix, ...extra.mix];
      if (mix.isNotEmpty) out.write(' with ${mix.join(', ')}');
      final impl = [...match.impl, ...extra.impl];
      if (impl.isNotEmpty) out.write(' implements ${impl.join(', ')}');
      out.writeln(' {');
      out.writeln(extra.methods);
    }
  }
  out.writeln(extraClasses);
  File(filename).writeAsStringSync(out.toString());
}

Future<void> run({required bool format}) async {
  print('Generating C bindings...');
  await ffigen.main(['--no-format', '-v', 'severe', '--config', cConfig]);

  print('Generating ObjC bindings...');
  await ffigen.main(['--no-format', '-v', 'severe', '--config', objcConfig]);
  mergeExtras(objcBindings, parseExtraMethods(extraMethodsFile),
      File(extraClassesFile).readAsStringSync());

  if (format) {
    print('Formatting bindings...');
    dartCmd(['format', cBindings, objcBindings]);
  }
}

Future<void> main(List<String> args) async {
  Directory.current = Platform.script.resolve('..').path;
  final argResults = (ArgParser()
        ..addFlag(
          'format',
          help: 'Format the generated code.',
          defaultsTo: true,
          negatable: true,
        ))
      .parse(args);
  await run(format: argResults.flag('format'));
}
