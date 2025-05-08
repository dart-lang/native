// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_toolchain_c/src/cbuilder/compiler_resolver.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';

const objCFlags = ['-x', 'objective-c', '-fobjc-arc'];

const assetName = 'objective_c.dylib';
final packageAssetPath = Uri.file('assets/$assetName');

const extraCFiles = ['test/util.c'];

final logger = Logger('')
  ..level = Level.INFO
  ..onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.code.linkModePreference == LinkModePreference.static) {
      throw UnsupportedError('LinkModePreference.static is not supported.');
    }

    final packageName = input.packageName;
    final assetPath = input.outputDirectory.resolve(assetName);
    final assetSourcePath = input.packageRoot.resolveUri(packageAssetPath);
    final srcDir = Directory.fromUri(input.packageRoot.resolve('src/'));

    List<String> cFiles = [];
    List<String> mFiles = [];
    List<String> hFiles = [];
    for (final file in srcDir.listSync(recursive: true)) {
      if (file is File) {
        final path = file.path;
        if (path.endsWith('.c')) cFiles.add(path);
        if (path.endsWith('.m')) mFiles.add(path);
        if (path.endsWith('.h')) hFiles.add(path);
      }
    }

    cFiles.addAll(extraCFiles.map((f) => input.packageRoot.resolve(f).path));

    final cFlags = [if (true) '-DNO_MAIN_THREAD_DISPATCH'];
    final mFlags = [...cFlags, ...objCFlags];

    final builder = await Builder.create(input, input.packageRoot.path);

    final objectFiles = await Future.wait(<Future<String>>[
      for (final src in cFiles) builder.buildObject(src, cFlags),
      for (final src in mFiles) builder.buildObject(src, mFlags),
    ]);
    await builder.linkLib(objectFiles, assetPath.toFilePath());

    output.addDependencies(cFiles.map(Uri.file));
    output.addDependencies(mFiles.map(Uri.file));
    output.addDependencies(hFiles.map(Uri.file));

    output.assets.code.add(
      CodeAsset(
        package: packageName,
        name: assetName,
        file: assetPath,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  });
}

class Builder {
  final String _comp;
  final String _rootDir;
  final Uri _tempOutDir;
  Builder._(this._comp, this._rootDir, this._tempOutDir);

  static Future<Builder> create(BuildInput input, String rootDir) async {
    final resolver = CompilerResolver(
      codeConfig: input.config.code,
      logger: logger,
    );
    return Builder._(
      (await resolver.resolveCompiler()).uri.toFilePath(),
      rootDir,
      input.outputDirectory.resolve('obj/'),
    );
  }

  Future<String> buildObject(
    String input,
    List<String> flags,
  ) async {
    assert(input.startsWith(_rootDir));
    final relativeInput = input.substring(_rootDir.length);
    final output = '${_tempOutDir.resolve(relativeInput).path}.o';
    File(output).parent.createSync(recursive: true);
    stderr.writeln(output);
    await _compile([
      ...flags,
      '-c',
      input,
      '-fpic',
      '-I',
      'src',
    ], output);
    return output;
  }

  Future<void> linkLib(List<String> objects, String output) =>
      _compile([
        '-shared',
        '-undefined',
        'dynamic_lookup',
        ...objects,
      ], output);

  Future<void> _compile(
    List<String> flags,
    String output,
  ) async {
    final args = [...flags, '-o', output];
    const exec = 'clang';
    logger.info('Running: $_comp ${args.join(" ")}');
    final proc = await Process.run(_comp, args);
    logger.info(proc.stdout);
    logger.info(proc.stderr);
    if (proc.exitCode != 0) {
      exitCode = proc.exitCode;
      throw Exception('Command failed: $_comp ${args.join(" ")}');
    }
    logger.info('Generated $output');
  }
}
