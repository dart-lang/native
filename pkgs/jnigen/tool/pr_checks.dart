// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is a script to run a subset of CI checks on development machine before
// submitting PR. This prevents from accidentally forgetting to format or
// remove an unused import.

// This is rough around the edges. This script may give false positives such
// as some gitignore'd temporary files failing the comparison.

// On windows, please install 'diffutils' using your favorite package installer
// for this script to work correctly. Also ensure that clang-format is on your
// PATH.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'command_runner.dart';

// Flags
const _clone = 'clone';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      _clone,
      help: 'Run checks in a cloned copy of the project.',
      defaultsTo: true,
      negatable: true,
    );
  final argResults = parser.parse(arguments);
  final shouldClone = argResults[_clone] as bool;
  final gitRoot = getRepositoryRoot();

  // change to project root
  Directory.current = gitRoot.toFilePath();

  var tempDir = Directory.current;
  if (shouldClone) {
    tempDir = Directory.current.createTempSync('jnigen_checks_clone_');
    final gitClone = Runner("Clone jni", Directory.current.uri)
      ..chainCommand('git', ['clone', '.', tempDir.path]);
    await gitClone.run();
  }

  final jniPath = tempDir.uri.resolve("jni/");
  final jnigenPath = tempDir.uri.resolve("jnigen/");
  final pubGet = Runner("Pub get", tempDir.uri)
    ..chainCommand("flutter", ["pub", "get", "--offline"],
        workingDirectory: jniPath)
    ..chainCommand("dart", ["pub", "get", "--offline"],
        workingDirectory: jnigenPath);
  await pubGet.run();

  final jniAnalyze = Runner("Analyze JNI", jniPath);
  jniAnalyze
    ..chainCommand("dart", ["analyze", "--fatal-infos"])
    ..chainCommand(
        "dart", ["format", "--output=none", "--set-exit-if-changed", "."])
    ..chainCommand(
        "clang-format",
        [
          "--dry-run",
          "-Werror",
          "dartjni.c",
          "dartjni.h",
          "third_party/global_jni_env.c",
          "third_party/global_jni_env.h",
        ],
        workingDirectory: jniPath.resolve("src/"));
  final jniTest = Runner("Test JNI", jniPath)
    ..chainCommand("dart", ["run", "jni:setup"])
    ..chainCommand("dart", ["test", "-j", "1"]);
  unawaited(jniAnalyze.run().then((f) => jniTest.run()));

  final javaFiles = Directory.fromUri(jnigenPath.resolve("java/"))
      .listSync(recursive: true)
      .where((file) => file.path.endsWith(".java"))
      .map((file) => file.path)
      .toList();

  final checkJavaFormat = Runner("Check java format", jnigenPath)
    ..chainCommand(
        "google-java-format", ["-n", "--set-exit-if-changed", ...javaFiles]);

  unawaited(checkJavaFormat.run());

  final ffigenBindingsPath = getRepositoryRoot()
      .resolve("jni/lib/src/third_party/jni_bindings_generated.dart");
  final ffigenBindings = File.fromUri(ffigenBindingsPath);
  final oldBindingsText = ffigenBindings.readAsStringSync();
  final ffigenCompare = Runner("Generate & Compare FFIGEN bindings", jniPath)
    ..chainCommand("dart", ["run", "ffigen", "--config", "ffigen.yaml"])
    ..chainCallback("compare bindings", () async {
      final newBindingsText = await ffigenBindings.readAsString();
      if (newBindingsText != oldBindingsText) {
        await ffigenBindings.writeAsString(oldBindingsText);
        throw "new JNI.h bindings differ from old bindings";
      }
    });
  unawaited(ffigenCompare.run());

  final jnigenAnalyze = Runner("Analyze jnigen", jnigenPath)
    ..chainCommand("dart", ["analyze", "--fatal-infos"])
    ..chainCommand(
        "dart", ["format", "--output=none", "--set-exit-if-changed", "."])
    ..chainCommand("dart", ["run", "jnigen:setup"]);

  // Tests may need more time when running on systems with less cores.
  // So '--timeout 2x' is specified.
  final jnigenTest = Runner("Test jnigen", gitRoot.resolve("jnigen/"))
    ..chainCommand("dart", ["test", "--timeout", "2x"]);

  // Note: Running in_app_java and notification_plugin checks on source dir
  // itself, because running flutter build in cloned dir will take time.
  final compareInAppJavaBindings = Runner(
      "Generate & compare InAppJava bindings",
      gitRoot.resolve("jnigen/example/in_app_java"))
    ..chainCommand("dart", [
      "run",
      "jnigen",
      "--config",
      "jnigen.yaml",
      "-Doutput.c.path=src_temp/",
      "-Doutput.dart.path=_temp.dart",
    ])
    ..chainCommand("diff", ["lib/android_utils.dart", "_temp.dart"])
    ..chainCommand("diff", ["-qr", "src/android_utils/", "src_temp/"])
    ..chainCleanupCommand("rm", ["-r", "_temp.dart", "src_temp"]);

  final comparePdfboxBindings = Runner("Generate & compare PdfBox Bindings",
      gitRoot.resolve("jnigen/example/pdfbox_plugin"))
    ..chainCommand("dart", [
      "run",
      "jnigen",
      "--config",
      "jnigen.yaml",
      "-Doutput.c.path=src_temp/",
      "-Doutput.dart.path=lib_temp/",
    ])
    ..chainCommand("diff", ["-qr", "lib/src/third_party/", "lib_temp/"])
    ..chainCommand("diff", ["-qr", "src/", "src_temp/"])
    ..chainCleanupCommand("rm", ["-r", "lib_temp", "src_temp"]);

  final compareNotificationPluginBindings = Runner(
      "Generate & compare NotificationPlugin Bindings",
      gitRoot.resolve("jnigen/example/notification_plugin"))
    ..chainCommand("dart", [
      "run",
      "jnigen",
      "--config",
      "jnigen.yaml",
      "-Doutput.c.path=src_temp/",
      "-Doutput.dart.path=_temp.dart",
    ])
    ..chainCommand("diff", ["lib/notifications.dart", "_temp.dart"])
    ..chainCommand("diff", ["-qr", "src/", "src_temp/"])
    ..chainCleanupCommand("rm", ["-r", "_temp.dart", "src_temp"]);

  unawaited(jnigenAnalyze.run().then((_) {
    final test = jnigenTest.run();
    final inAppJava = compareInAppJavaBindings.run();
    final pdfBox = comparePdfboxBindings.run();
    final notificationPlugin = compareNotificationPluginBindings.run();
    return Future.wait([test, inAppJava, pdfBox, notificationPlugin]);
  }).then((_) {
    if (shouldClone) {
      tempDir.deleteSync(recursive: true);
    }
  }));
}
