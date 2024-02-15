// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Library defining the `native_assets.yaml` format for embedding in a Dart
/// kernel file.
///
/// The `native_assets.yaml` embedded in a kernel file has a different format
/// from the assets passed in the `build_output.yaml` from individual native
/// assets builds. This library defines the format of the former so that it
/// can be reused in `package:dartdev` and `package:flutter_tools`.
///
/// The format should be consistent with `pkg/vm/lib/native_assets/` in the
/// Dart SDK.
library kernel_native_assets;

import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../utils/yaml.dart';

class KernelAssets {
  final List<KernelAsset> _assets;

  KernelAssets([Iterable<KernelAsset>? assets]) : _assets = [...?assets];

  String toNativeAssetsFile() {
    final assetsPerTarget = <Target, List<KernelAsset>>{};
    for (final asset in _assets) {
      final assets = assetsPerTarget[asset.target] ?? [];
      assets.add(asset);
      assetsPerTarget[asset.target] = assets;
    }

    final yamlContents = {
      'format-version': [1, 0, 0],
      'native-assets': {
        for (final entry in assetsPerTarget.entries)
          entry.key.toString(): {
            for (final e in entry.value) e.id: e.path.toYaml(),
          }
      },
    };

    return yamlEncode(yamlContents);
  }
}

class KernelAsset {
  final String id;
  final Target target;
  final KernelAssetPath path;

  KernelAsset({
    required this.id,
    required this.target,
    required this.path,
  });
}

abstract class KernelAssetPath {
  List<String> toYaml();
}

/// Asset at absolute path [uri] on the target device where Dart is run.
class KernelAssetAbsolutePath implements KernelAssetPath {
  final Uri uri;

  KernelAssetAbsolutePath(this.uri);

  static const _pathTypeValue = 'absolute';

  @override
  List<String> toYaml() => [_pathTypeValue, uri.toFilePath()];
}

/// Asset at relative path [uri], relative to the 'dart file' executed.
///
/// The 'dart file' executed can be one of the following:
///
/// 1. The `.dart` file when executing `dart path/to/script.dart`.
/// 2. The `.kernel` file when executing from a kernel file.
/// 3. The `.aotsnapshot` file when executing from an AOT snapshot with the Dart
///    AOT runtime.
/// 4. The executable when executing a Dart app compiled with `dart compile exe`
///    to a single file.
///
/// Note when writing your own embedder, make sure the `Dart_CreateIsolateGroup`
/// or similar calls set up the `script_uri` parameter correctly to ensure
/// relative path resolution works.
class KernelAssetRelativePath implements KernelAssetPath {
  final Uri uri;

  KernelAssetRelativePath(this.uri);

  static const _pathTypeValue = 'relative';

  @override
  List<String> toYaml() => [_pathTypeValue, uri.toFilePath()];
}

/// Asset is avaliable on the system `PATH`.
///
/// [uri] only contains a file name.
class KernelAssetSystemPath implements KernelAssetPath {
  final Uri uri;

  KernelAssetSystemPath(this.uri);

  static const _pathTypeValue = 'system';

  @override
  List<String> toYaml() => [_pathTypeValue, uri.toFilePath()];
}

/// Asset is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
class KernelAssetInProcess implements KernelAssetPath {
  KernelAssetInProcess._();

  static final KernelAssetInProcess _singleton = KernelAssetInProcess._();

  factory KernelAssetInProcess() => _singleton;

  static const _pathTypeValue = 'process';

  @override
  List<String> toYaml() => [_pathTypeValue];
}

/// Asset is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
class KernelAssetInExecutable implements KernelAssetPath {
  KernelAssetInExecutable._();

  static final KernelAssetInExecutable _singleton = KernelAssetInExecutable._();

  factory KernelAssetInExecutable() => _singleton;

  static const _pathTypeValue = 'executable';

  @override
  List<String> toYaml() => [_pathTypeValue];
}
