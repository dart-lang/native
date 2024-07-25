import 'dart:io';

final defaultTempDir = Directory.systemTemp.uri;
const defaultTempDirPrefix = 'swift2objc_temp_';
const symbolgraphFileSuffix = '.symbols.json';
const defaultModuleName = 'symbolgraph_module';

class Config {
  final List<Uri> inputFiles;
  final Uri outputFile;
  final Uri? tempDir;
  final String moduleName;
  final bool deleteTempAfterDone;

  const Config({
    required this.inputFiles,
    required this.outputFile,
    this.moduleName = defaultModuleName,
    this.deleteTempAfterDone = true,
    this.tempDir,
  });
}
