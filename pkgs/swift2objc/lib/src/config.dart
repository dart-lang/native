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

/// Used to configure Swift2ObjC wrapper generation.
/// See `FilesInputConfig` and `ModuleInputConfig`;
sealed class Config {
  /// Specify where the wrapper swift file will be output.
  final Uri outputFile;

  /// Specify where to output the intermidiate files (i.g the symbolgraph json).
  /// If this is null, a teemp directory will be generated in the system temp
  /// directory (using `Directory.systemTemp`) and then deleted.
  /// Specifying a temp directory would prevent the tool from deleting the
  /// intermediate files after generating the wrapper
  final Uri? tempDir;

  const Config({
    required this.outputFile,
    this.tempDir,
  });

  /// The command used to generate the symbolgraph json file.
  Command get symbolgraphCommand;
}

/// Used to generate a objc wrapper for one or more swift files
class FilesInputConfig extends Config {
  /// The swift file(s) to generate a wrapper for
  final List<Uri> files;

  FilesInputConfig({
    required this.files,
    required super.outputFile,
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
          defaultModuleName
        ],
      );
}

/// Used to generate a objc wrapper for a built-in swift module
/// (e.g, AVFoundation)
class ModuleInputConfig extends Config {
  /// The swift module to generate a wrapper for
  final String module;

  /// The target to generate code for
  /// (e.g `x86_64-apple-ios17.0-simulator`)
  final String target;

  /// The sdk to compile against
  /// (e.g `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sd`)
  final Uri sdk;

  ModuleInputConfig({
    required this.module,
    required this.target,
    required this.sdk,
    required super.outputFile,
    super.tempDir,
  });

  @override
  Command get symbolgraphCommand => Command(
        executable: 'swiftc',
        args: [
          'symbolgraph-extract',
          '-module-name',
          module,
          '-target',
          target,
          '-sdk',
          path.absolute(sdk.path),
          '-output-dir',
          '.',
        ],
      );
}
