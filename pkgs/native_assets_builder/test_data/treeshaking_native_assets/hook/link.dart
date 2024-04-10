// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'treeshaking_native_assets';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    final usedSymbols =
        config.resources.map((resource) => resource.metadata.toString());
    final dynamicLibrary = config.assets.firstWhere(
        (asset) => asset.id.endsWith('src/${packageName}_bindings.dart'));
    final staticLibrary =
        config.assets.firstWhere((asset) => asset.id.endsWith('staticlib'));

    final linkerScript = await _writeLinkerScript(usedSymbols);
    await _treeshakeStaticLibrary(
      usedSymbols,
      linkerScript,
      dynamicLibrary,
      staticLibrary,
    );
    output.linkAsset(dynamicLibrary);
    output.addDependency(config.packageRoot.resolve('hook/link.dart'));
  });
}

Future<void> _treeshakeStaticLibrary(
  Iterable<String> symbols,
  Uri symbolsUri,
  LinkableAsset dynamicLibrary,
  LinkableAsset staticLibrary,
) async {
  final arguments = [
    '-fPIC',
    '-shared',
    ...symbols.map((symbol) => ['-u', symbol]).expand((e) => e),
    '--version-script=${symbolsUri.toFilePath()}',
    '--gc-sections',
    '--strip-debug',
    ...['-o', (dynamicLibrary.file!.toFilePath())],
    staticLibrary.file!.toFilePath(),
  ];
  await Process.run('ld', arguments);
}

Future<Uri> _writeLinkerScript(Iterable<String> symbols) async {
  final tempDir = await Directory.systemTemp.createTemp();
  const symbolsFile = 'symbols.lds';
  final symbolsUri = tempDir.uri.resolve(symbolsFile);
  final linkerScript = File.fromUri(symbolsUri)..createSync();
  final contents = '''{
  global:
${symbols.map((symbol) => '    ' + symbol + ';').join('\n')}
  local:
    *;
};
''';
  linkerScript.writeAsStringSync(contents);
  return symbolsUri;
}
