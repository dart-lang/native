// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import 'syntax.g.dart';

/// An asset bundled as data (String or bytes) with a Dart or Flutter
/// web application.
///
/// A web asset is accessible in a Dart or Flutter application. To retrieve an
/// asset at runtime, the [id] is used. This enables access to the asset
/// irrespective of how and where the application is run.
///
/// A web uri asset must provide a [WebUriAsset.file]. The Dart and Flutter SDK
/// will bundle its contents with the final application.
final class WebUriAsset({
  /// The file to be bundled with the Dart or Flutter web application.
  ///
  /// The path must be an absolute path. Prefer constructing the path via
  /// [HookInput.outputDirectoryShared] or [HookInput.outputDirectory] for files
  /// emitted during a hook, and via [HookInput.packageRoot] for files which are
  /// part of the package.
  required final Uri file,

  /// The name of this asset, which must be unique for the package.
  required final String name,

  /// The package which contains this asset.
  required final String package,
}) {
  /// The identifier for this web asset.
  ///
  /// A [WebUriAsset] has a string identifier called "asset id". Dart code that
  /// uses an asset references the asset using this asset id.
  ///
  /// An asset identifier consists of two elements, the `package` and `name`,
  /// which together make a library uri `package:<package>/<name>`. The package
  /// being part of the identifer prevents name collisions between assets of
  /// different packages.
  String get id => 'package:$package/$name';

  /// Constructs a [WebUriAsset] from an [EncodedAsset].
  factory WebUriAsset.fromEncoded(EncodedAsset asset) {
    assert(asset.isWebAsset);
    final syntaxNode = WebUriAssetEncodingSyntax.fromJson(
      asset.encoding,
      path: asset.encodingJsonPath ?? [],
    );
    return WebUriAsset(
      file: syntaxNode.file,
      name: syntaxNode.name,
      package: syntaxNode.package,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! WebUriAsset) {
      return false;
    }
    return other.package == package &&
        other.file.toFilePath() == file.toFilePath() &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(package, name, file.toFilePath());

  EncodedAsset encode() {
    final encoding = WebUriAssetEncodingSyntax(
      file: file,
      name: name,
      package: package,
    );
    return EncodedAsset(WebUriAssetType.type, encoding.json);
  }

  @override
  String toString() => 'WebAsset(${encode().encoding})';
}

extension WebUriAssetType on WebUriAsset {
  static const String type = WebAssetsWebAssetSyntax.typeValue;
}

/// Methods on [EncodedAsset] for [WebUriAsset]s.
extension EncodedWebUriAsset on EncodedAsset {
  bool get isWebAsset => type == WebUriAssetType.type;
  WebUriAsset get asWebUriAsset => .fromEncoded(this);
}
