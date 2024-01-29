// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// A collection of resources used by the application.
///
/// Asset bundles contain resources, such as images and strings, that can be
/// used by an application. Access to these resources is asynchronous so that
/// they can be transparently loaded over a network (e.g., from a
/// [NetworkAssetBundle]) or from the local file system without blocking the
/// application's user interface.
///
/// Applications have a [rootBundle], which contains the resources that were
/// packaged with the application when it was built. To add resources to the
/// [rootBundle] for your application, add them to the `assets` subsection of
/// the `flutter` section of your application's `pubspec.yaml` manifest.
///
/// For example:
///
/// ```yaml
/// name: my_awesome_application
/// flutter:
///   assets:
///    - images/hamilton.jpeg
///    - images/lafayette.jpeg
/// ```
///
/// Rather than accessing the [rootBundle] global static directly, consider
/// obtaining the [AssetBundle] for the current [BuildContext] using
/// [DefaultAssetBundle.of]. This layer of indirection lets ancestor widgets
/// substitute a different [AssetBundle] (e.g., for testing or localization) at
/// runtime rather than directly replying upon the [rootBundle] created at build
/// time. For convenience, the [WidgetsApp] or [MaterialApp] widget at the top
/// of the widget hierarchy configures the [DefaultAssetBundle] to be the
/// [rootBundle].
///
/// See also:
///
///  * [DefaultAssetBundle]
///  * [NetworkAssetBundle]
///  * [rootBundle]
abstract class AssetBundle {
  /// Retrieve a binary resource from the asset bundle as a data stream.
  ///
  /// Throws an exception if the asset is not found.
  ///
  /// The returned [ByteData] can be converted to a [Uint8List] (a list of bytes)
  /// using [Uint8List.sublistView]. Lists of bytes can be used with APIs that
  /// accept [Uint8List] objects, such as [decodeImageFromList], as well as any
  /// API that accepts a [List<int>], such as [File.writeAsBytes] or
  /// [Utf8Codec.decode] (accessible via [utf8]).
  Future<ByteData> load(String key);

  /// Retrieve a string from the asset bundle.
  ///
  /// Throws an exception if the asset is not found.
  ///
  /// If the `cache` argument is set to false, then the data will not be
  /// cached, and reading the data may bypass the cache. This is useful if the
  /// caller is going to be doing its own caching. (It might not be cached if
  /// it's set to true either, depending on the asset bundle implementation.)
  ///
  /// The function expects the stored string to be UTF-8-encoded as
  /// [Utf8Codec] will be used for decoding the string. If the string is
  /// larger than 50 KB, the decoding process is delegated to an
  /// isolate to avoid jank on the main thread.
  Future<String> loadString(String key, {bool cache = true});

  /// Retrieve a string from the asset bundle, parse it with the given function,
  /// and return that function's result.
  ///
  /// The result is not cached by the default implementation; the parser is run
  /// each time the resource is fetched. However, some subclasses may implement
  /// caching (notably, subclasses of [CachingAssetBundle]).
  Future<T> loadStructuredData<T>(
      String key, Future<T> Function(String value) parser) async {
    return parser(await loadString(key));
  }

  /// Retrieve [ByteData] from the asset bundle, parse it with the given function,
  /// and return that function's result.
  ///
  /// The result is not cached by the default implementation; the parser is run
  /// each time the resource is fetched. However, some subclasses may implement
  /// caching (notably, subclasses of [CachingAssetBundle]).
  Future<T> loadStructuredBinaryData<T>(
      String key, FutureOr<T> Function(ByteData data) parser) async {
    return parser(await load(key));
  }

  /// If this is a caching asset bundle, and the given key describes a cached
  /// asset, then evict the asset from the cache so that the next time it is
  /// loaded, the cache will be reread from the asset bundle.
  void evict(String key) {}

  /// If this is a caching asset bundle, clear all cached data.
  void clear() {}
}
