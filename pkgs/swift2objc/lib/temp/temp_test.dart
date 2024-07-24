import 'dart:io';

import 'package:path/path.dart' as path;
import '../swift2objc.dart';

void main() {
  final inputFile1 = path.join(
    Directory.current.path,
    'lib/temp/symbolgraph/input_1.swift',
  );
  final inputFile2 = path.join(
    Directory.current.path,
    'lib/temp/symbolgraph/input_2.swift',
  );
  final outputFile = path.join(
    Directory.current.path,
    'lib/temp/symbolgraph/test_output.swift',
  );
  generateWrapperSync(Config(
    inputFiles: [
      inputFile1,
      inputFile2,
    ],
    outputFile: outputFile,
  ));
}
