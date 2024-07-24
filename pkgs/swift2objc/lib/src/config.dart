import 'dart:io';

final defaultTempDir = Directory.systemTemp;
const defaultTempDirPrefix = 'swift2objc_temp_';
const symbolgraphFileSuffix = '.symbols.json';

class Config {
  final List<String> inputFiles;
  final String outputFile;
  final Directory? tempDir;
  final bool deleteTempAfterDone;

  const Config({
    required this.inputFiles,
    required this.outputFile,
    this.deleteTempAfterDone = true,
    this.tempDir,
  });
}
