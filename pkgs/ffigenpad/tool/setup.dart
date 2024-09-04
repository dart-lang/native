// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Downloads required files needed to build ffigenpad

import 'dart:io';
import 'package:path/path.dart' as p;

const llvmCompiledRelease =
    'https://github.com/TheComputerM/libclang-wasm/releases/download/v0/llvm-build.tar.gz';

Future<void> main(List<String> args) async {
  final libclangDir = p.joinAll(
    [p.dirname(Platform.script.path), '..', 'third_party', 'libclang'],
  );
  final llvmDir = p.join(libclangDir, 'llvm-project');

  if (args.contains('-f') && await Directory(llvmDir).exists()) {
    await Directory(llvmDir).delete(recursive: true);
  }

  if (await Directory(llvmDir).exists()) {
    print('Compiled LLVM archives already exist.');
    print('Use `-f` to forcefully download archives.');
    return;
  }
  print('Downloading compiled LLVM archives');

  // Download .tar.gz file

  final tempFileName = 'llvm-build.tar.gz';
  final tempFile = File(p.join(libclangDir, tempFileName));

  final httpClient = HttpClient();
  final request = await httpClient.getUrl(Uri.parse(llvmCompiledRelease));
  final response = await request.close();
  final sink = tempFile.openWrite();
  await response.pipe(sink);
  await sink.flush();
  await sink.close();
  httpClient.close();

  print('Extracting LLVM archives to $llvmDir');

  // Extract file to Config.llvmDir

  await Directory(llvmDir).create(recursive: true);
  final result = await Process.run(
    'tar',
    ['-xzf', tempFileName, '-C', llvmDir],
    workingDirectory: libclangDir,
  );
  if (result.exitCode >= 0) {
    print('Archive files extracted successfully.');
  } else {
    print('Error: ${result.stderr}');
    return;
  }

  // remove temp .tar.gz file
  await tempFile.delete();
}
