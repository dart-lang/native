// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import 'syntax.g.dart';

/// An asset bundled as data (String or bytes) with a Dart or Flutter
/// web application.
///
/// A data asset is accessible in a Dart or Flutter application. To retrieve an
/// asset at runtime, the [id] is used. This enables access to the asset
/// irrespective of how and where the application is run.
///
/// A data asset must provide a [WebAsset.file]. The Dart and Flutter SDK will
/// bundle this code in the final application.
final class WebAsset {
  /// The file to be bundled with the Dart or Flutter web application.
  ///
  /// The path must be an absolute path. Prefer constructing the path via
  /// [HookInput.outputDirectoryShared] or [HookInput.outputDirectory] for files
  /// emitted during a hook, and via [HookInput.packageRoot] for files which are
  /// part of the package.
  final Uri file;

  /// The name of this asset, which must be unique for the package.
  final String name;

  /// The package which contains this asset.
  final String package;

  /// The identifier for this web asset.
  ///
  /// A [WebAsset] has a string identifier called "asset id". Dart code that
  /// uses an asset references the asset using this asset id.
  ///
  /// An asset identifier consists of two elements, the `package` and `name`,
  /// which together make a library uri `package:<package>/<name>`. The package
  /// being part of the identifer prevents name collisions between assets of
  /// different packages.
  String get id => 'package:$package/$name';

  WebAsset({required this.file, required this.name, required this.package});

  /// Constructs a [WebAsset] from an [EncodedAsset].
  factory WebAsset.fromEncoded(EncodedAsset asset) {
    assert(asset.isWebAsset);
    final syntaxNode = WebAssetEncodingSyntax.fromJson(
      asset.encoding,
      path: asset.encodingJsonPath ?? [],
    );
    return WebAsset(
      file: syntaxNode.file,
      name: syntaxNode.name,
      package: syntaxNode.package,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! WebAsset) {
      return false;
    }
    return other.package == package &&
        other.file.toFilePath() == file.toFilePath() &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(package, name, file.toFilePath());

  EncodedAsset encode() {
    final encoding = WebAssetEncodingSyntax(
      file: file,
      name: name,
      package: package,
    );
    return EncodedAsset(WebAssetType.type, encoding.json);
  }

  @override
  String toString() => 'WebAsset(${encode().encoding})';
}

extension WebAssetType on WebAsset {
  static const String type = WebAssetsWebAssetSyntax.typeValue;
}

/// Methods on [EncodedAsset] for [WebAsset]s.
extension EncodedWebAsset on EncodedAsset {
  bool get isWebAsset => type == WebAssetType.type;
  WebAsset get asDataAsset => .fromEncoded(this);
}
