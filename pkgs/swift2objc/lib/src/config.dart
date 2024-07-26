const defaultTempDirPrefix = 'swift2objc_temp_';
const symbolgraphFileSuffix = '.symbols.json';
const defaultModuleName = 'symbolgraph_module';

class Config {
  final List<Uri> inputFiles;
  final Uri outputFile;
  final Uri? tempDir;
  final String moduleName;

  const Config({
    required this.inputFiles,
    required this.outputFile,
    this.moduleName = defaultModuleName,
    this.tempDir,
  });
}
