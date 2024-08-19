// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Downloads required files needed to build ffigenpad

import "dart:io";
import 'package:path/path.dart' as p;

class Config {
  static final libclangDir = p.joinAll(
    [p.dirname(Platform.script.path), '..', 'third_party', 'libclang'],
  );
  static const llvmCompiledRelease =
      "https://github.com/TheComputerM/libclang-wasm/releases/download/v0/llvm-build.tar.gz";
  static final llvmDir = p.join(libclangDir, 'llvm-project');
}

Future<void> main() async {
  setupLLVM();
}

Future<void> setupLLVM() async {
  if (await Directory(Config.llvmDir).exists()) {
    print("Compiled LLVM archives already exist");
    return;
  }
  print("Downloading compiled LLVM archives");

  // Download .tar.gz file

  final tempFileName = 'llvm-build.tar.gz';
  final tempFile = File(p.join(Config.libclangDir, tempFileName));

  final httpClient = HttpClient();
  final request =
      await httpClient.getUrl(Uri.parse(Config.llvmCompiledRelease));
  final response = await request.close();
  final sink = tempFile.openWrite();
  await response.pipe(sink);
  sink.flush();
  sink.close();
  httpClient.close();

  print("Extracting LLVM archives to ${Config.llvmDir}");
  // Extract file to Config.llvmDir
  await Directory(Config.llvmDir).create(recursive: true);
  final result = await Process.run(
    'tar',
    ['-xzf', tempFileName, '-C', Config.llvmDir],
    workingDirectory: Config.libclangDir,
  );
  if (result.exitCode >= 0) {
    print("Archive files extracted successfully.");
  } else {
    print("Error: ${result.stderr}");
  }

  // remove temp .tar.gz file
  await tempFile.delete();
}
