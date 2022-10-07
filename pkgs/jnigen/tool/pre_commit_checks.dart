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

const ansiRed = '\x1b[31m';
const ansiDefault = '\x1b[39;49m';

void printError(Object? message) {
  if (stderr.supportsAnsiEscapes) {
    message = '$ansiRed$message$ansiDefault';
  }
  stderr.writeln(message);
}

class StepFailure implements Exception {
  StepFailure(this.name);
  String name;
  @override
  String toString() => 'step failed: $name';
}

abstract class Step {
  /// Runs this step, raises an exception if something fails.
  Future<void> run();
}

class Callback implements Step {
  Callback(this.name, this.function);
  String name;
  Future<void> Function() function;
  @override
  Future<void> run() => function();
}

class Command implements Step {
  Command(this.exec, this.args, this.workingDirectory);
  final String exec;
  final List<String> args;
  final String workingDirectory;

  @override
  Future<void> run() async {
    final result =
        await Process.run(exec, args, workingDirectory: workingDirectory);
    if (result.exitCode != 0) {
      printError(result.stdout);
      printError(result.stderr);
      final commandString = "$exec ${args.join(" ")}";
      stderr.writeln("failure executing command: $commandString");
      throw StepFailure(commandString);
    }
  }
}

class Runner {
  static final gitRoot = getRepositoryRoot();
  Runner(this.name, this.defaultWorkingDir);
  String name;
  String defaultWorkingDir;
  final steps = <Step>[];
  final cleanupSteps = <Step>[];

  void chainCommand(String exec, List<String> args,
          {String? workingDirectory}) =>
      _addCommand(steps, exec, args, workingDirectory: workingDirectory);

  void chainCleanupCommand(String exec, List<String> args,
          {String? workingDirectory}) =>
      _addCommand(cleanupSteps, exec, args, workingDirectory: workingDirectory);

  void _addCommand(List<Step> list, String exec, List<String> args,
      {String? workingDirectory}) {
    final resolvedWorkingDirectory =
        gitRoot.resolve(workingDirectory ?? defaultWorkingDir);
    list.add(Command(exec, args, resolvedWorkingDirectory.toFilePath()));
  }

  void chainCallback(String name, Future<void> Function() callback) {
    steps.add(Callback(name, callback));
  }

  Future<void> run() async {
    stderr.writeln("started: $name");
    var error = false;
    for (var step in steps) {
      try {
        await step.run();
      } on StepFailure catch (e) {
        stderr.writeln(e);
        error = true;
        exitCode = 1;
        break;
      }
    }
    stderr.writeln('${error ? "failed" : "complete"}: $name');
    for (var step in cleanupSteps) {
      try {
        await step.run();
      } on Exception catch (e) {
        printError("ERROR: $e");
      }
    }
  }
}

Uri getRepositoryRoot() {
  final gitCommand = Process.runSync("git", ["rev-parse", "--show-toplevel"]);
  final output = gitCommand.stdout as String;
  return Uri.directory(output.trim());
}

void main() async {
  final jniAnalyze = Runner("Analyze JNI", "jni");
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
        workingDirectory: "jni/src");
  final jniTest = Runner("Test JNI", "jni")
    ..chainCommand("dart", ["run", "jni:setup"])
    ..chainCommand("dart", ["test", "-j", "1"]);
  unawaited(jniAnalyze.run().then((f) => jniTest.run()));
  final ffigenBindingsPath = getRepositoryRoot()
      .resolve("jni/lib/src/third_party/jni_bindings_generated.dart");
  final ffigenBindings = File.fromUri(ffigenBindingsPath);
  final oldBindingsText = ffigenBindings.readAsStringSync();
  final ffigenCompare = Runner("Generate & Compare FFIGEN bindings", "jni")
    ..chainCommand("dart", ["run", "ffigen", "--config", "ffigen.yaml"])
    ..chainCallback("compare bindings", () async {
      final newBindingsText = await ffigenBindings.readAsString();
      if (newBindingsText != oldBindingsText) {
        await ffigenBindings.writeAsString(oldBindingsText);
        throw "new JNI.h bindings differ from old bindings";
      }
    });
  unawaited(ffigenCompare.run());

  final jnigenAnalyze = Runner("Analyze jnigen", "jnigen")
    ..chainCommand("dart", ["analyze", "--fatal-infos"])
    ..chainCommand(
        "dart", ["format", "--output=none", "--set-exit-if-changed", "."])
    ..chainCommand("dart", ["run", "jnigen:setup"]);
  final jnigenTest = Runner("Test jnigen", "jnigen")
    ..chainCommand("dart", ["test"]);
  final compareInAppJavaBindings = Runner(
      "Generate & compare InAppJava bindings", "jnigen/example/in_app_java")
    ..chainCommand("dart", [
      "run",
      "jnigen",
      "--config",
      "jnigen.yaml",
      "-Dc_root=src_temp",
      "-Ddart_root=lib_temp",
    ])
    ..chainCommand("diff", ["-qr", "lib/android_utils/", "lib_temp/"])
    ..chainCommand("diff", ["-qr", "src/android_utils/", "src_temp/"])
    ..chainCleanupCommand("rm", ["-r", "lib_temp", "src_temp"]);
  final comparePdfboxBindings = Runner(
      "Generate & compare PdfBox Bindings", "jnigen/example/pdfbox_plugin")
    ..chainCommand("dart", [
      "run",
      "jnigen",
      "--config",
      "jnigen.yaml",
      "-Dc_root=src_temp",
      "-Ddart_root=lib_temp",
    ])
    ..chainCommand("diff", ["-qr", "lib/src/third_party/", "lib_temp/"])
    ..chainCommand("diff", ["-qr", "src/", "src_temp/"])
    ..chainCleanupCommand("rm", ["-r", "lib_temp", "src_temp"]);
  final compareNotificationPluginBindings = Runner(
      "Generate & compare NotificationPlugin Bindings",
      "jnigen/example/notification_plugin")
    ..chainCommand("dart", [
      "run",
      "jnigen",
      "--config",
      "jnigen.yaml",
      "-Dc_root=src_temp",
      "-Ddart_root=lib_temp",
    ])
    ..chainCommand("diff", ["-qr", "lib/", "lib_temp/"])
    ..chainCommand("diff", ["-qr", "src/", "src_temp/"])
    ..chainCleanupCommand("rm", ["-r", "lib_temp", "src_temp"]);
  unawaited(jnigenAnalyze.run().then((_) {
    jnigenTest.run();
    compareInAppJavaBindings.run();
    comparePdfboxBindings.run();
    compareNotificationPluginBindings.run();
  }));
}
