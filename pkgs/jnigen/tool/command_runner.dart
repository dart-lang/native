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
  final Uri workingDirectory;

  @override
  Future<void> run() async {
    final result = await Process.run(
      exec,
      args,
      workingDirectory: workingDirectory.toFilePath(),
      runInShell: true,
    );
    if (result.exitCode != 0) {
      printError(result.stdout);
      printError(result.stderr);
      final commandString = "$exec ${args.join(" ")}";
      stderr.writeln('failure executing command: $commandString');
      throw StepFailure(commandString);
    }
  }
}

class Runner {
  static final gitRoot = getRepositoryRoot();
  Runner(this.name, this.defaultWorkingDir);
  String name;
  Uri defaultWorkingDir;
  final steps = <Step>[];
  final cleanupSteps = <Step>[];

  void chainCommand(String exec, List<String> args, {Uri? workingDirectory}) =>
      _addCommand(steps, exec, args, workingDirectory: workingDirectory);

  void chainCleanupCommand(String exec, List<String> args,
          {Uri? workingDirectory}) =>
      _addCommand(cleanupSteps, exec, args, workingDirectory: workingDirectory);

  void _addCommand(List<Step> list, String exec, List<String> args,
      {Uri? workingDirectory}) {
    list.add(Command(exec, args, (workingDirectory ?? defaultWorkingDir)));
  }

  void chainCallback(String name, Future<void> Function() callback) {
    steps.add(Callback(name, callback));
  }

  Future<void> run() async {
    stderr.writeln('started: $name');
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
        printError('ERROR: $e');
      }
    }
  }
}

Uri getRepositoryRoot() {
  final gitCommand = Process.runSync('git', ['rev-parse', '--show-toplevel']);
  final output = gitCommand.stdout as String;
  return Uri.directory(output.trim());
}
