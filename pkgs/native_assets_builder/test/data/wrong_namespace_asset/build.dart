// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  final buildConfig = await BuildConfig.fromArgs(args);
  final buildOutput = BuildOutput(
    assets: [
      Asset(
        id: 'package:other_package/foo',
        linkMode: LinkMode.dynamic,
        target: Target.current,
        path: AssetAbsolutePath(
          buildConfig.outDir.resolve(
            Target.current.os.dylibFileName('foo'),
          ),
        ),
      ),
    ],
  );
  await buildOutput.writeToFile(
    outDir: buildConfig.outDir,
    step: const BuildStep(),
  );
}
