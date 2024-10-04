// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../api/build_config.dart';
import '../api/build_output.dart';
import '../api/link_config.dart';
import '../architecture.dart';
import '../encoded_asset.dart';
import '../json_utils.dart';
import '../link_mode.dart';
import '../os.dart';
import '../utils/json.dart';
import '../utils/map.dart';

/// A code asset which respects the native application binary interface (ABI).
///
/// Typical languages which produce code assets that respect the native ABI
/// include C, C++ (with `extern "C"`), Rust (with `extern "C"`), and a subset
/// of language features of Objective-C.
///
/// Native code assets can be accessed at runtime through native external
/// functions via their asset [id]:
///
/// ```dart
/// import 'dart:ffi';
///
/// void main() {
///   final result = add(14, 28);
///   print(result);
/// }
///
/// @Native<Int Function(Int, Int)>(assetId: 'package:my_package/add.dart')
/// external int add(int a, int b);
/// ```
///
/// There are several types of native code assets:
/// * Assets which designate symbols present in the target system
///   ([DynamicLoadingSystem]), process ([LookupInProcess]), or executable
///   ([LookupInExecutable]). These assets do not have a [file].
/// * Dynamic libraries bundled into the application
///   ([DynamicLoadingBundled]). These assets must provide a [file] to be
///   bundled.
///
/// An application is compiled to run on a specific target [os] and
/// [architecture]. Different targets require different assets, so the package
/// developer must specify which asset to bundle for which target.
///
/// An asset has different ways of being accessible in the final application. It
/// is either brought in "manually" by having the package developer specify a
/// [file] path of the asset on the current system, it can be part of the Dart
/// or Flutter SDK ([LookupInProcess]), or it can be already present in the
/// target system ([DynamicLoadingSystem]). If the asset is bundled
/// "manually", the Dart or Flutter SDK will take care of copying the asset
/// [file] from its specified location on the current system into the
/// application bundle.
final class CodeAsset {
  /// The id of this code asset.
  final String id;

  /// The operating system this asset can run on.
  final OS os;

  /// The architecture this asset can run on.
  ///
  /// Not available during a [BuildConfig.dryRun].
  final Architecture? architecture;

  /// The link mode for this native code.
  ///
  /// Either dynamic loading or static linking.
  final LinkMode linkMode;

  /// The file to be bundled with the Dart or Flutter application.
  ///
  /// If the [linkMode] is [DynamicLoadingBundled], the file name must be
  /// provided in the [BuildOutput] for [BuildConfig.dryRun]. Supplying a file
  /// name instead of an absolute path is enough for [BuildConfig.dryRun]. The
  /// file does not have to exist on disk during a dry run.
  ///
  /// If the [linkMode] is [DynamicLoadingSystem], [LookupInProcess], or
  /// [LookupInExecutable] the file must be omitted in the [BuildOutput] for
  /// [BuildConfig.dryRun].
  final Uri? file;

  /// Constructs a native code asset.
  ///
  /// The [id] of this asset is a uri `package:<package>/<name>` from [package]
  /// and [name].
  CodeAsset({
    required String package,
    required String name,
    required LinkMode linkMode,
    required OS os,
    Uri? file,
    Architecture? architecture,
  }) : this._(
          id: 'package:$package/$name',
          linkMode: linkMode,
          os: os,
          file: file,
          architecture: architecture,
        );

  CodeAsset._({
    required this.id,
    required this.linkMode,
    required this.os,
    required this.file,
    required this.architecture,
  });

  factory CodeAsset.fromEncoded(EncodedAsset asset) {
    assert(asset.type == CodeAsset.type);
    final jsonMap = asset.encoding;

    final linkMode =
        LinkMode.fromJson(as<Map<String, Object?>>(jsonMap[_linkModeKey]));
    final fileString = jsonMap.optionalString(_fileKey);
    final Uri? file;
    if (fileString != null) {
      file = Uri.file(fileString);
    } else {
      file = null;
    }
    final Architecture? architecture;
    final os = OS.fromString(jsonMap.string(_osKey));
    final architectureString = jsonMap.optionalString(_architectureKey);
    if (architectureString != null) {
      architecture = Architecture.fromString(architectureString);
    } else {
      architecture = null;
    }

    return CodeAsset._(
      id: jsonMap.string(_idKey),
      os: os,
      architecture: architecture,
      linkMode: linkMode,
      file: file,
    );
  }

  CodeAsset copyWith({
    LinkMode? linkMode,
    String? id,
    OS? os,
    Architecture? architecture,
    Uri? file,
  }) =>
      CodeAsset._(
        id: id ?? this.id,
        linkMode: linkMode ?? this.linkMode,
        os: os ?? this.os,
        architecture: architecture ?? this.architecture,
        file: file ?? this.file,
      );

  @override
  bool operator ==(Object other) {
    if (other is! CodeAsset) {
      return false;
    }
    return other.id == id &&
        other.linkMode == linkMode &&
        other.architecture == architecture &&
        other.os == os &&
        other.file == file;
  }

  @override
  int get hashCode => Object.hash(
        id,
        linkMode,
        architecture,
        os,
        file,
      );

  EncodedAsset encode() => EncodedAsset(
      CodeAsset.type,
      <String, Object>{
        if (architecture != null) _architectureKey: architecture.toString(),
        if (file != null) _fileKey: file!.toFilePath(),
        _idKey: id,
        _linkModeKey: linkMode.toJson(),
        _osKey: os.toString(),
      }..sortOnKey());

  static const String type = 'native_code';
}

/// Build output extension for code assets.
extension CodeAssetsBuildOutput on BuildOutput {
  BuildOutputCodeAssets get codeAssets => BuildOutputCodeAssets(this);
}

class BuildOutputCodeAssets {
  final BuildOutput _output;

  BuildOutputCodeAssets(this._output);

  void add(CodeAsset asset, {String? linkInPackage}) =>
      _output.addEncodedAsset(asset.encode(), linkInPackage: linkInPackage);

  void addAll(Iterable<CodeAsset> assets, {String? linkInPackage}) {
    for (final asset in assets) {
      add(asset, linkInPackage: linkInPackage);
    }
  }

  Iterable<CodeAsset> get all => _output.encodedAssets
      .where((e) => e.type == CodeAsset.type)
      .map(CodeAsset.fromEncoded);
}

/// Link output extension for code assets.
extension CodeAssetsLinkConfig on LinkConfig {
  LinkConfigCodeAssets get codeAssets => LinkConfigCodeAssets(this);
}

class LinkConfigCodeAssets {
  final LinkConfig _config;

  LinkConfigCodeAssets(this._config);

  Iterable<CodeAsset> get all => _config.encodedAssets
      .where((e) => e.type == CodeAsset.type)
      .map(CodeAsset.fromEncoded);
}

/// Link output extension for code assets.
extension CodeAssetsLinkOutput on LinkOutput {
  LinkOutputCodeAssets get codeAssets => LinkOutputCodeAssets(this);
}

class LinkOutputCodeAssets {
  final LinkOutput _output;

  LinkOutputCodeAssets(this._output);

  void add(CodeAsset asset) => _output.addEncodedAsset(asset.encode());

  void addAll(Iterable<CodeAsset> assets) => assets.forEach(add);

  Iterable<CodeAsset> get all => _output.encodedAssets
      .where((e) => e.type == CodeAsset.type)
      .map(CodeAsset.fromEncoded);
}

extension OSLibraryNaming on OS {
  /// The default dynamic library file name on this os.
  String dylibFileName(String name) {
    final prefix = _dylibPrefix[this]!;
    final extension = _dylibExtension[this]!;
    return '$prefix$name.$extension';
  }

  /// The default static library file name on this os.
  String staticlibFileName(String name) {
    final prefix = _staticlibPrefix[this]!;
    final extension = _staticlibExtension[this]!;
    return '$prefix$name.$extension';
  }

  /// The default library file name on this os.
  String libraryFileName(String name, LinkMode linkMode) {
    if (linkMode is DynamicLoading) {
      return dylibFileName(name);
    }
    assert(linkMode is StaticLinking);
    return staticlibFileName(name);
  }

  /// The default executable file name on this os.
  String executableFileName(String name) {
    final extension = _executableExtension[this]!;
    final dot = extension.isNotEmpty ? '.' : '';
    return '$name$dot$extension';
  }
}

/// The default name prefix for dynamic libraries per [OS].
const _dylibPrefix = {
  OS.android: 'lib',
  OS.fuchsia: 'lib',
  OS.iOS: 'lib',
  OS.linux: 'lib',
  OS.macOS: 'lib',
  OS.windows: '',
};

/// The default extension for dynamic libraries per [OS].
const _dylibExtension = {
  OS.android: 'so',
  OS.fuchsia: 'so',
  OS.iOS: 'dylib',
  OS.linux: 'so',
  OS.macOS: 'dylib',
  OS.windows: 'dll',
};

/// The default name prefix for static libraries per [OS].
const _staticlibPrefix = _dylibPrefix;

/// The default extension for static libraries per [OS].
const _staticlibExtension = {
  OS.android: 'a',
  OS.fuchsia: 'a',
  OS.iOS: 'a',
  OS.linux: 'a',
  OS.macOS: 'a',
  OS.windows: 'lib',
};

/// The default extension for executables per [OS].
const _executableExtension = {
  OS.android: '',
  OS.fuchsia: '',
  OS.iOS: '',
  OS.linux: '',
  OS.macOS: '',
  OS.windows: 'exe',
};

const _idKey = 'id';
const _linkModeKey = 'link_mode';
const _fileKey = 'file';
const _osKey = 'os';
const _architectureKey = 'architecture';
