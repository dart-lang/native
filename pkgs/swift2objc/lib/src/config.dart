import 'package:path/path.dart' as path;

const defaultTempDirPrefix = 'swift2objc_temp_';
const symbolgraphFileSuffix = '.symbols.json';
const defaultModuleName = 'symbolgraph_module';

class Command {
  final String executable;
  final List<String> args;

  Command({
    required this.executable,
    required this.args,
  });
}

abstract class Config {
  final Uri outputFile;
  final Uri? tempDir;
  final String moduleName;

  const Config({
    required this.outputFile,
    this.moduleName = defaultModuleName,
    this.tempDir,
  });

  Command get symbolgraphCommand;
}

class FilesInputConfig extends Config {
  final List<Uri> files;

  FilesInputConfig({
    required this.files,
    required super.outputFile,
    super.moduleName,
    super.tempDir,
  });

  @override
  Command get symbolgraphCommand => Command(
        executable: 'swiftc',
        args: [
          ...files.map((uri) => path.absolute(uri.path)),
          '-emit-module',
          '-emit-symbol-graph',
          '-emit-symbol-graph-dir',
          '.',
          '-module-name',
          moduleName
        ],
      );
}

class ModuleInputConfig extends Config {
  final Uri target;
  final Uri sdk;

  ModuleInputConfig({
    required this.target,
    required this.sdk,
    required super.outputFile,
    super.moduleName,
    super.tempDir,
  });

  @override
  Command get symbolgraphCommand => Command(
        executable: 'swiftc',
        args: [
          'symbolgraph-extract',
          '-module-name',
          moduleName,
          '-target',
          path.absolute(target.path),
          '-sdk',
          path.absolute(sdk.path),
          '-output-dir',
          '.',
        ],
      );
}
