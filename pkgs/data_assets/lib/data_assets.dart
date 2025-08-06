// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'src/data_assets/config.dart';
/// @docImport 'src/data_assets/data_asset.dart';

/// Data asset support for hook authors.
///
/// Data assets can be added in a build hook as follows:
///
/// ```dart
/// import 'package:data_assets/data_assets.dart';
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     final packageName = input.packageName;
///     final assetPath = input.outputDirectory.resolve('...');
///
///     output.assets.data.add(
///       DataAsset(
///         package: packageName,
///         name: '...',
///         file: assetPath,
///       ),
///     );
///   });
/// }
/// ```
///
/// See [DataAsset] and [BuildOutputDataAssetsBuilder.add] for more details.
///
/// For more documentation of hooks, refer to the API docs of
/// [`package:hooks`](https://pub.dev/packages/hooks).
library;

export 'src/data_assets/config.dart'
    show
        BuildOutputAssetsBuilderData,
        BuildOutputBuilderAddDataAssetsDirectories,
        BuildOutputDataAssets,
        BuildOutputDataAssetsBuilder,
        HookConfigDataConfig,
        LinkInputDataAssets,
        LinkOutputAssetsBuilderData,
        LinkOutputDataAssets,
        LinkOutputDataAssetsBuilder;
export 'src/data_assets/data_asset.dart' show DataAsset, EncodedDataAsset;
export 'src/data_assets/extension.dart';
