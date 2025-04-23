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
  String name,
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
    name: match[1]!,
    ext: match[2],
    mix: match[3]?.split(', ') ?? [],
    impl: match[4]?.split(', ') ?? []
  );
}

typedef ExtraMethods = ({ClassInfo cls, String methods});
Map<String, ExtraMethods> parseExtraMethods(String filename) {
  final extraMethods = <String, ExtraMethods>{};
  ClassInfo? currentClass;
  late StringBuffer methods;
  for (final line in File(filename).readAsLinesSync()) {
    if (currentClass == null) {
      final cls = parseClassDecl(line);
      if (cls != null) {
        currentClass = cls;
        methods = StringBuffer();
      }
    } else {
      if (line == '}') {
        extraMethods[currentClass.name] =
            (cls: currentClass, methods: methods.toString());
        currentClass = null;
      } else {
        methods.writeln(line);
      }
    }
  }
  return extraMethods;
}

String classDecl(
        String name, String? ext, List<String> mix, List<String> impl) =>
    [
      'class $name',
      if (ext != null) 'extends $ext',
      if (mix.isNotEmpty) 'with ${mix.join(', ')}',
      if (impl.isNotEmpty) 'implements ${impl.join(', ')}',
      '{',
    ].join(' ');

void mergeExtraMethods(
    String filename, Map<String, ExtraMethods> extraMethods) {
  final out = StringBuffer();
  for (final line in File(filename).readAsLinesSync()) {
    final cls = parseClassDecl(line);
    final extra = cls == null ? null : extraMethods[cls.name];
    if (cls == null || extra == null) {
      out.writeln(line);
    } else {
      out.writeln(classDecl(
          cls.name,
          extra.cls.ext ?? cls.ext,
          [...cls.mix, ...extra.cls.mix],
          [...cls.impl, ...extra.cls.impl]));
      out.writeln(extra.methods);
      extraMethods.remove(cls.name);
    }
  }

  // Matching classes have been removed from extraMethods. Write all the
  // remaining classes separately.
  for (final extra in extraMethods.values) {
    out.writeln('\n');
    out.writeln(classDecl(
        extra.cls.name, extra.cls.ext, extra.cls.mix, extra.cls.impl));
    out.writeln(extra.methods);
    out.writeln('}');
  }

  File(filename).writeAsStringSync(out.toString());
}

Future<void> run(List<String> args) async {
  final argResults = (ArgParser()
        ..addFlag(
          'format',
          help: 'Format the generated code.',
          defaultsTo: true,
          negatable: true,
        ))
      .parse(args);

  print('Generating C bindings...');
  await ffigen.main(['--no-format', '-v', 'severe', '--config', cConfig]);

  print('Generating ObjC bindings...');
  await ffigen.main(['--no-format', '-v', 'severe', '--config', objcConfig]);
  mergeExtraMethods(objcBindings, parseExtraMethods(extraMethodsFile));

  if (argResults.flag('format')) {
    print('Formatting bindings...');
    dartCmd(['format', cBindings, objcBindings]);
  }
}

Future<void> main(List<String> args) async {
  Directory.current = Platform.script.resolve('..').path;
  await run(args);
}
