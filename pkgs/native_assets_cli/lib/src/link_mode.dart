// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'api/asset.dart';
import 'api/build_config.dart';

/// The link mode for a [NativeCodeAsset].
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
sealed class LinkMode {
  const LinkMode();

  factory LinkMode.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    return switch (type) {
      'static' => StaticLinking._singleton,
      'dynamic_loading_process' => LookupInProcess._singleton,
      'dynamic_loading_executable' => LookupInExecutable._singleton,
      'dynamic_loading_bundle' => DynamicLoadingBundled._singleton,
      'dynamic_loading_system' =>
        DynamicLoadingSystem(Uri.parse(json['uri'] as String)),
      _ => throw FormatException('The link mode "$type" is not known'),
    };
  }

  Map<String, Object?> toJson() => switch (this) {
        StaticLinking() => {'type': 'static'},
        LookupInProcess() => {'type': 'dynamic_loading_process'},
        LookupInExecutable() => {'type': 'dynamic_loading_executable'},
        DynamicLoadingBundled() => {'type': 'dynamic_loading_bundle'},
        final DynamicLoadingSystem system => {
            'type': 'dynamic_loading_system',
            'uri': system.uri.toFilePath(),
          },
      };
}

/// The [NativeCodeAsset] will be loaded at runtime.
///
/// Nothing happens at native code linking time.
///
/// Supported in the Dart and Flutter SDK.
///
/// Note: Dynamic loading is not equal to dynamic linking. Dynamic linking
/// would have to run the linker at compile-time, which is currently not
/// supported in the Dart and Flutter SDK.
sealed class DynamicLoading extends LinkMode {}

/// The dynamic library is bundled by Dart/Flutter at build time.
///
/// At runtime, the dynamic library will be loaded and the symbols will be
/// looked up in this dynamic library.
///
/// An asset with this dynamic loading method must provide a
/// [NativeCodeAsset.file]. The Dart and Flutter SDK will bundle this code in
/// the final application.
///
/// During a [BuildConfig.dryRun], the [NativeCodeAsset.file] can be a file name
/// instead of a the full path. The file does not have to exist during a dry
/// run.
final class DynamicLoadingBundled extends DynamicLoading {
  DynamicLoadingBundled._();

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
  final Uri uri;

  DynamicLoadingSystem(this.uri);

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
  LookupInProcess._();

  static final LookupInProcess _singleton = LookupInProcess._();

  factory LookupInProcess() => _singleton;

  @override
  String toString() => 'process';
}

/// The native code is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
final class LookupInExecutable extends DynamicLoading {
  LookupInExecutable._();

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
  const StaticLinking._();
  factory StaticLinking() => _singleton;

  static const StaticLinking _singleton = StaticLinking._();

  @override
  String toString() => 'static';
}
