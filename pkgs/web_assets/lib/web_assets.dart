// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'src/web_assets/config.dart';
/// @docImport 'src/web_assets/web_asset.dart';
/// Web asset support for hook authors.
///
/// A web asset is an asset bundled as a URI with a Dart or Flutter web
/// application.
///
/// Web assets can be added in a build hook as follows:
///
/// <!-- file://./../example/api/web_assets_snippet.dart -->
/// ```dart
/// import 'package:hooks/hooks.dart';
/// import 'package:web_assets/web_assets.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildWebAssets) {
///       final packageName = input.packageName;
///       final assetPathInPackage = input.packageRoot.resolve('...');
///       final assetPathDownload = input.outputDirectoryShared.resolve('...');
///
///       output.assets.web.add(
///         WebAsset(
///           package: packageName,
///           name: '...',
///           file: assetPathInPackage,
///         ),
///       );
///     }
///   });
/// }
/// ```
///
/// See [WebAsset] and [BuildOutputWebAssetsBuilder.add] for more details.
///
/// For more documentation of hooks, refer to the API docs of
/// [`package:hooks`](https://pub.dev/packages/hooks).
library;

export 'src/web_assets/config.dart'
    show
        BuildOutputAssetsBuilderWeb,
        BuildOutputWebAssets,
        BuildOutputWebAssetsBuilder,
        HookConfigWebConfig,
        LinkInputWebAssets,
        LinkOutputAssetsBuilderWeb,
        LinkOutputWebAssets,
        LinkOutputWebAssetsBuilder;
export 'src/web_assets/extension.dart';
export 'src/web_assets/web_asset.dart' show EncodedWebAsset, WebAsset;
