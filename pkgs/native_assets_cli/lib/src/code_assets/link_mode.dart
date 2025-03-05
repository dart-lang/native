// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_asset.dart';

import 'syntax.g.dart' as syntax;

/// The link mode for a [CodeAsset].
///
/// Known linking modes:
///
/// * [StaticLinking]
/// * [DynamicLoading]
///   * [LookupInProcess]
///   * [LookupInExecutable]
///   * [DynamicLoadingBundled]
///   * [DynamicLoadingSystem]
///
/// See the documentation on the above classes.
abstract final class LinkMode {
  const LinkMode._();

  /// Constructs a [LinkMode] from the given [json].
  ///
  /// The json is expected to be valid encoding obtained via [LinkMode.toJson].
  factory LinkMode.fromJson(Map<String, Object?> json) =>
      LinkModeSyntax.fromSyntax(syntax.LinkMode.fromJson(json));

  /// The json representation of this [LinkMode].
  ///
  /// The returned json is stable and can be used in [LinkMode.fromJson] to
  /// obtain a [LinkMode] again.
  Map<String, Object?> toJson() => toSyntax().json;
}

extension LinkModeSyntax on LinkMode {
  syntax.LinkMode toSyntax() => switch (this) {
    StaticLinking() => syntax.StaticLinkMode(),
    LookupInProcess() => syntax.DynamicLoadingProcessLinkMode(),
    LookupInExecutable() => syntax.DynamicLoadingExecutableLinkMode(),
    DynamicLoadingBundled() => syntax.DynamicLoadingBundleLinkMode(),
    final DynamicLoadingSystem system => syntax.DynamicLoadingSystemLinkMode(
      uri: system.uri,
    ),
    _ => throw UnimplementedError('The link mode "$this" is not known'),
  };

  static LinkMode fromSyntax(syntax.LinkMode linkMode) => switch (linkMode) {
    _ when linkMode.isStaticLinkMode => StaticLinking(),
    _ when linkMode.isDynamicLoadingProcessLinkMode => LookupInProcess(),
    _ when linkMode.isDynamicLoadingExecutableLinkMode => LookupInExecutable(),
    _ when linkMode.isDynamicLoadingBundleLinkMode => DynamicLoadingBundled(),
    _ when linkMode.isDynamicLoadingSystemLinkMode => DynamicLoadingSystem(
      linkMode.asDynamicLoadingSystemLinkMode.uri,
    ),
    _ => throw FormatException('The link mode "${linkMode.type}" is not known'),
  };
}

/// The [CodeAsset] will be loaded at runtime.
///
/// Nothing happens at native code linking time.
///
/// Supported in the Dart and Flutter SDK.
///
/// Note: Dynamic loading is not equal to dynamic linking. Dynamic linking
/// would have to run the linker at compile-time, which is currently not
/// supported in the Dart and Flutter SDK.
abstract final class DynamicLoading extends LinkMode {
  DynamicLoading._() : super._();
}

/// The dynamic library is bundled by Dart/Flutter at build time.
///
/// At runtime, the dynamic library will be loaded and the symbols will be
/// looked up in this dynamic library.
///
/// An asset with this dynamic loading method must provide a
/// [CodeAsset.file]. The Dart and Flutter SDK will bundle this code in
/// the final application.
final class DynamicLoadingBundled extends DynamicLoading {
  DynamicLoadingBundled._() : super._();

  static final DynamicLoadingBundled _singleton = DynamicLoadingBundled._();

  factory DynamicLoadingBundled() => _singleton;

  @override
  String toString() => 'bundled';
}

/// The dynamic library is avaliable on the target system `PATH`.
///
/// At buildtime, nothing happens.
///
/// At runtime, the dynamic library will be loaded and the symbols will be
/// looked up in this dynamic library.
final class DynamicLoadingSystem extends DynamicLoading {
  /// The [Uri] of the
  final Uri uri;

  DynamicLoadingSystem(this.uri) : super._();

  static const _typeValue = 'dynamic_loading_system';

  @override
  int get hashCode => uri.hashCode;

  @override
  bool operator ==(Object other) =>
      other is DynamicLoadingSystem && uri == other.uri;

  @override
  String toString() => _typeValue;
}

/// The native code is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
final class LookupInProcess extends DynamicLoading {
  LookupInProcess._() : super._();

  static final LookupInProcess _singleton = LookupInProcess._();

  factory LookupInProcess() => _singleton;

  @override
  String toString() => 'process';
}

/// The native code is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
final class LookupInExecutable extends DynamicLoading {
  LookupInExecutable._() : super._();

  static final LookupInExecutable _singleton = LookupInExecutable._();

  factory LookupInExecutable() => _singleton;

  @override
  String toString() => 'executable';
}

/// Static linking.
///
/// At native linking time, native function names will be resolved to static
/// libraries.
///
/// Not yet supported in the Dart and Flutter SDK.
// TODO(https://github.com/dart-lang/sdk/issues/49418): Support static linking.
final class StaticLinking extends LinkMode {
  const StaticLinking._() : super._();
  factory StaticLinking() => _singleton;

  static const StaticLinking _singleton = StaticLinking._();

  @override
  String toString() => 'static';
}
