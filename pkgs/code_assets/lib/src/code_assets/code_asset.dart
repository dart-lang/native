// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import 'config.dart';
import 'link_mode.dart';
import 'os.dart';
import 'syntax.g.dart';

/// An asset containing executable code which respects the native application
/// binary interface (ABI).
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
/// * Dynamic libraries bundled into the application ([DynamicLoadingBundled]).
///   These assets must provide a [file] to be bundled.
///
/// An application is compiled to run on a specific target [CodeConfig.targetOS]
/// and [CodeConfig.targetArchitecture]. Different targets require different
/// assets, so the package developer must specify which asset to bundle for
/// which target.
///
/// An asset has different ways of being accessible in the final application. It
/// is either brought in "manually" by having the package developer specify a
/// [file] path of the asset on the current system, it can be part of the Dart
/// or Flutter SDK ([LookupInProcess]), or it can be already present in the
/// target system ([DynamicLoadingSystem]). If the asset is bundled "manually",
/// the Dart or Flutter SDK will take care of copying the asset [file] from its
/// specified location on the current system into the application bundle.
final class CodeAsset {
  /// The id of this code asset.
  final String id;

  /// The link mode for this native code.
  ///
  /// Either dynamic loading or static linking.
  final LinkMode linkMode;

  /// The file to be bundled with the Dart or Flutter application.
  ///
  /// If the [linkMode] is [DynamicLoadingBundled], the file must be provided
  /// and exist.
  ///
  /// If the [linkMode] is [DynamicLoadingSystem], the file must be provided,
  /// and not exist.
  ///
  /// If the [linkMode] is [LookupInProcess], or [LookupInExecutable] the file
  /// must be omitted in the [BuildOutput].
  final Uri? file;

  /// Constructs a native code asset.
  ///
  /// The [id] of this asset is a uri `package:<package>/<name>` from [package]
  /// and [name].
  CodeAsset({
    required String package,
    required String name,
    required LinkMode linkMode,
    Uri? file,
  }) : this._(id: 'package:$package/$name', linkMode: linkMode, file: file);

  CodeAsset._({required this.id, required this.linkMode, required this.file});

  /// Creates a [CodeAsset] from an [EncodedAsset].
  factory CodeAsset.fromEncoded(EncodedAsset asset) {
    assert(asset.isCodeAsset);
    final syntaxNode = NativeCodeAssetEncodingSyntax.fromJson(
      asset.encoding,
      path: asset.encodingJsonPath ?? [],
    );
    return CodeAsset._(
      id: syntaxNode.id,
      linkMode: LinkModeSyntaxExtension.fromSyntax(syntaxNode.linkMode),
      file: syntaxNode.file,
    );
  }

  /// Creates a copy of this [CodeAsset] with the given fields replaced.
  CodeAsset copyWith({LinkMode? linkMode, String? id, Uri? file}) =>
      CodeAsset._(
        id: id ?? this.id,
        linkMode: linkMode ?? this.linkMode,
        file: file ?? this.file,
      );

  @override
  bool operator ==(Object other) {
    if (other is! CodeAsset) {
      return false;
    }
    return other.id == id && other.linkMode == linkMode && other.file == file;
  }

  @override
  int get hashCode => Object.hash(id, linkMode, file);

  /// Encodes this [CodeAsset] into an [EncodedAsset].
  EncodedAsset encode() {
    final encoding = NativeCodeAssetEncodingSyntax(
      file: file,
      id: id,
      linkMode: linkMode.toSyntax(),
    );
    return EncodedAsset(CodeAssetType.type, encoding.json);
  }
}

/// Extension for identifying the type of a [CodeAsset].
extension CodeAssetType on CodeAsset {
  /// The type identifier for [CodeAsset]s in a hook input or output.
  static const String type = NativeCodeAssetNewSyntax.typeValue;
}

/// Methods on [EncodedAsset] for [CodeAsset]s.
extension EncodedCodeAsset on EncodedAsset {
  /// Whether this [EncodedAsset] represents a [CodeAsset].
  bool get isCodeAsset => type == CodeAssetType.type;

  /// Converts this [EncodedAsset] to a [CodeAsset].
  CodeAsset get asCodeAsset => CodeAsset.fromEncoded(this);
}

/// Provides OS-specific library naming conventions.
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
