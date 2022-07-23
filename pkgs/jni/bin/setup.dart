import 'dart:io';

import 'package:args/args.dart';
import 'package:package_config/package_config.dart';

const _buildDir = "build-dir";
const _srcDir = "source-dir";
const _verbose = "verbose";
const _cmakeArgs = "cmake-args";
const _clean = "clean";

// Sets up input output channels and maintains state.
class CommandRunner {
  CommandRunner({this.printCmds = false});
  bool printCmds = false;
  int? time;
  // TODO: time commands
  // TODO: Run all commands in single shell instance
  // IssueRef: https://github.com/dart-lang/jni_gen/issues/14
  Future<CommandRunner> run(
      String exec, List<String> args, String workingDir) async {
    if (printCmds) {
      final cmd = "$exec ${args.join(" ")}";
      stderr.writeln("\n+ [$workingDir] $cmd");
    }
    final process = await Process.start(exec, args,
        workingDirectory: workingDir,
        runInShell: Platform.isWindows,
        mode: ProcessStartMode.inheritStdio);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      stderr.writeln("command exited with $exitCode");
    }
    return this;
  }
}

class Options {
  Options(ArgResults arg)
      : buildDir = arg[_buildDir],
        srcDir = arg[_srcDir],
        cmakeArgs = arg[_cmakeArgs],
        verbose = arg[_verbose] ?? false,
        clean = arg[_clean] ?? false;

  String? buildDir, srcDir, cmakeArgs;
  bool verbose, clean;
}

late Options options;
void log(String msg) {
  if (options.verbose) {
    stderr.writeln(msg);
  }
}

/// tries to find package:jni's source folder in pub cache
/// if not possible, returns null.
Future<String?> findSources() async {
  final packageConfig = await findPackageConfig(Directory.current);
  if (packageConfig == null) {
    return null;
  }
  final packages = packageConfig.packages;
  for (var package in packages) {
    if (package.name == 'jni') {
      return package.root.resolve("src/").toFilePath();
    }
  }
  return null;
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(_buildDir,
        abbr: 'B', help: 'Directory to place built artifacts')
    ..addOption(_srcDir,
        abbr: 'S', help: 'alternative path to package:jni sources')
    ..addFlag(_verbose, abbr: 'v', help: 'Enable verbose output')
    ..addFlag(_clean,
        negatable: false,
        abbr: 'C',
        help: 'Clear built artifacts instead of running a build')
    ..addOption(_cmakeArgs,
        abbr: 'm',
        help: 'additional space separated arguments to pass to CMake');
  final cli = parser.parse(arguments);
  options = Options(cli);
  final rest = cli.rest;

  if (rest.isNotEmpty) {
    stderr.writeln("one or more unrecognized arguments: $rest");
    stderr.writeln("usage: dart run jni:setup <options>");
    stderr.writeln(parser.usage);
    exitCode = 1;
    return;
  }

  final srcPath = options.srcDir ?? await findSources();

  if (srcPath == null) {
    stderr.writeln("No sources specified and current directory is not a "
        "package root.");
    exitCode = 1;
    return;
  }

  final srcDir = Directory(srcPath);
  if (!await srcDir.exists() && !options.clean) {
    throw 'Directory $srcPath does not exist';
  }

  log("srcPath: $srcPath");

  final currentDirUri = Uri.file(".");
  final buildPath =
      options.buildDir ?? currentDirUri.resolve("src/build").toFilePath();
  final buildDir = Directory(buildPath);
  await buildDir.create(recursive: true);
  log("buildPath: $buildPath");

  if (buildDir.absolute.uri == srcDir.absolute.uri) {
    stderr.writeln("Please build in a directory different than source.");
    exit(2);
  }

  if (options.clean) {
    await cleanup(options, srcDir.absolute.path, buildDir.absolute.path);
  } else {
    // pass srcDir absolute path because it will be passed to CMake as arg
    // which will be running in different directory
    await build(options, srcDir.absolute.path, buildDir.path);
  }
}

Future<void> build(Options options, String srcPath, String buildPath) async {
  final runner = CommandRunner(printCmds: true);
  final cmakeArgs = <String>[];
  if (options.cmakeArgs != null) {
    cmakeArgs.addAll(options.cmakeArgs!.split(" "));
  }
  cmakeArgs.add(srcPath);
  await runner.run("cmake", cmakeArgs, buildPath);
  await runner.run("cmake", ["--build", "."], buildPath);
  if (Platform.isWindows) {
    await runner.run("move", ["Debug\\dartjni.dll", "."], buildPath);
  }
}

Future<void> cleanup(Options options, String srcPath, String buildPath) async {
  if (srcPath == buildPath) {
    stderr.writeln('Error: build path is same as source path.');
  }

  stderr.writeln("deleting $buildPath");

  try {
    await Directory(buildPath).delete(recursive: true);
  } catch (e) {
    stderr.writeln("Error: cannot be deleted");
    stderr.writeln(e);
  }
}
