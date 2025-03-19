// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.

// ignore_for_file: unused_element

import 'dart:io';

class AndroidCodeConfig {
  final Map<String, Object?> json;

  AndroidCodeConfig.fromJson(this.json);

  AndroidCodeConfig({int? targetNdkApi}) : json = {} {
    _targetNdkApi = targetNdkApi;
    json.sortOnKey();
  }

  int? get targetNdkApi => json.get<int?>('target_ndk_api');

  set _targetNdkApi(int? value) {
    if (value == null) {
      json.remove('target_ndk_api');
    } else {
      json['target_ndk_api'] = value;
    }
  }

  @override
  String toString() => 'AndroidCodeConfig($json)';
}

class Architecture {
  final String name;

  const Architecture._(this.name);

  static const arm = Architecture._('arm');

  static const arm64 = Architecture._('arm64');

  static const ia32 = Architecture._('ia32');

  static const js = Architecture._('js');

  static const riscv32 = Architecture._('riscv32');

  static const riscv64 = Architecture._('riscv64');

  static const wasm = Architecture._('wasm');

  static const x64 = Architecture._('x64');

  static const List<Architecture> values = [
    arm,
    arm64,
    ia32,
    js,
    riscv32,
    riscv64,
    wasm,
    x64,
  ];

  static final Map<String, Architecture> _byName = {
    for (final value in values) value.name: value,
  };

  Architecture.unknown(this.name) : assert(!_byName.keys.contains(name));

  factory Architecture.fromJson(String name) {
    final knownValue = _byName[name];
    if (knownValue != null) {
      return knownValue;
    }
    return Architecture.unknown(name);
  }

  bool get isKnown => _byName[name] != null;

  @override
  String toString() => name;
}

class Asset {
  final Map<String, Object?> json;

  Asset.fromJson(this.json);

  Asset({String? type}) : json = {} {
    _type = type;
    json.sortOnKey();
  }

  String? get type => json.get<String?>('type');

  set _type(String? value) {
    if (value == null) {
      json.remove('type');
    } else {
      json['type'] = value;
    }
  }

  @override
  String toString() => 'Asset($json)';
}

class NativeCodeAsset extends Asset {
  NativeCodeAsset.fromJson(super.json) : super.fromJson();

  NativeCodeAsset({
    Architecture? architecture,
    Uri? file,
    required String id,
    required LinkMode linkMode,
    required OS os,
  }) : super(type: 'native_code') {
    _architecture = architecture;
    _file = file;
    _id = id;
    _linkMode = linkMode;
    _os = os;
    json.sortOnKey();
  }

  /// Setup all fields for [NativeCodeAsset] that are not in
  /// [Asset].
  void setup({
    Architecture? architecture,
    Uri? file,
    required String id,
    required LinkMode linkMode,
    required OS os,
  }) {
    _architecture = architecture;
    _file = file;
    _id = id;
    _linkMode = linkMode;
    _os = os;
    json.sortOnKey();
  }

  Architecture? get architecture {
    final string = json.get<String?>('architecture');
    if (string == null) return null;
    return Architecture.fromJson(string);
  }

  set _architecture(Architecture? value) {
    if (value == null) {
      json.remove('architecture');
    } else {
      json['architecture'] = value.name;
    }
  }

  Uri? get file => json.optionalPath('file');

  set _file(Uri? value) {
    if (value == null) {
      json.remove('file');
    } else {
      json['file'] = value.toFilePath();
    }
  }

  String get id => json.get<String>('id');

  set _id(String value) {
    json['id'] = value;
  }

  LinkMode get linkMode => LinkMode.fromJson(json.map$('link_mode'));

  set _linkMode(LinkMode value) => json['link_mode'] = value.json;

  OS get os => OS.fromJson(json.get<String>('os'));

  set _os(OS value) {
    json['os'] = value.name;
  }

  @override
  String toString() => 'NativeCodeAsset($json)';
}

extension NativeCodeAssetExtension on Asset {
  bool get isNativeCodeAsset => type == 'native_code';

  NativeCodeAsset get asNativeCodeAsset => NativeCodeAsset.fromJson(json);
}

class CCompilerConfig {
  final Map<String, Object?> json;

  CCompilerConfig.fromJson(this.json);

  CCompilerConfig({
    required Uri ar,
    required Uri cc,
    Uri? envScript,
    List<String>? envScriptArguments,
    required Uri ld,
    Windows? windows,
  }) : json = {} {
    _ar = ar;
    _cc = cc;
    _envScript = envScript;
    _envScriptArguments = envScriptArguments;
    _ld = ld;
    _windows = windows;
    json.sortOnKey();
  }

  Uri get ar => json.path('ar');

  set _ar(Uri value) {
    json['ar'] = value.toFilePath();
  }

  Uri get cc => json.path('cc');

  set _cc(Uri value) {
    json['cc'] = value.toFilePath();
  }

  Uri? get envScript => json.optionalPath('env_script');

  set _envScript(Uri? value) {
    if (value == null) {
      json.remove('env_script');
    } else {
      json['env_script'] = value.toFilePath();
    }
  }

  List<String>? get envScriptArguments =>
      json.optionalStringList('env_script_arguments');

  set _envScriptArguments(List<String>? value) {
    if (value == null) {
      json.remove('env_script_arguments');
    } else {
      json['env_script_arguments'] = value;
    }
  }

  Uri get ld => json.path('ld');

  set _ld(Uri value) {
    json['ld'] = value.toFilePath();
  }

  Windows? get windows {
    final map_ = json.optionalMap('windows');
    if (map_ == null) {
      return null;
    }
    return Windows.fromJson(map_);
  }

  set _windows(Windows? value) {
    if (value == null) {
      json.remove('windows');
    } else {
      json['windows'] = value.json;
    }
  }

  @override
  String toString() => 'CCompilerConfig($json)';
}

class Windows {
  final Map<String, Object?> json;

  Windows.fromJson(this.json);

  Windows({DeveloperCommandPrompt? developerCommandPrompt}) : json = {} {
    _developerCommandPrompt = developerCommandPrompt;
    json.sortOnKey();
  }

  DeveloperCommandPrompt? get developerCommandPrompt {
    final map_ = json.optionalMap('developer_command_prompt');
    if (map_ == null) {
      return null;
    }
    return DeveloperCommandPrompt.fromJson(map_);
  }

  set _developerCommandPrompt(DeveloperCommandPrompt? value) {
    if (value == null) {
      json.remove('developer_command_prompt');
    } else {
      json['developer_command_prompt'] = value.json;
    }
  }

  @override
  String toString() => 'Windows($json)';
}

class DeveloperCommandPrompt {
  final Map<String, Object?> json;

  DeveloperCommandPrompt.fromJson(this.json);

  DeveloperCommandPrompt({required List<String> arguments, required Uri script})
    : json = {} {
    _arguments = arguments;
    _script = script;
    json.sortOnKey();
  }

  List<String> get arguments => json.stringList('arguments');

  set _arguments(List<String> value) {
    json['arguments'] = value;
  }

  Uri get script => json.path('script');

  set _script(Uri value) {
    json['script'] = value.toFilePath();
  }

  @override
  String toString() => 'DeveloperCommandPrompt($json)';
}

class CodeConfig {
  final Map<String, Object?> json;

  CodeConfig.fromJson(this.json);

  CodeConfig({
    AndroidCodeConfig? android,
    CCompilerConfig? cCompiler,
    IOSCodeConfig? iOS,
    required LinkModePreference linkModePreference,
    MacOSCodeConfig? macOS,
    required Architecture targetArchitecture,
    required OS targetOs,
  }) : json = {} {
    _android = android;
    _cCompiler = cCompiler;
    _iOS = iOS;
    _linkModePreference = linkModePreference;
    _macOS = macOS;
    _targetArchitecture = targetArchitecture;
    _targetOs = targetOs;
    json.sortOnKey();
  }

  AndroidCodeConfig? get android {
    final map_ = json.optionalMap('android');
    if (map_ == null) {
      return null;
    }
    return AndroidCodeConfig.fromJson(map_);
  }

  set _android(AndroidCodeConfig? value) {
    if (value == null) {
      json.remove('android');
    } else {
      json['android'] = value.json;
    }
  }

  CCompilerConfig? get cCompiler {
    final map_ = json.optionalMap('c_compiler');
    if (map_ == null) {
      return null;
    }
    return CCompilerConfig.fromJson(map_);
  }

  set _cCompiler(CCompilerConfig? value) {
    if (value == null) {
      json.remove('c_compiler');
    } else {
      json['c_compiler'] = value.json;
    }
  }

  IOSCodeConfig? get iOS {
    final map_ = json.optionalMap('ios');
    if (map_ == null) {
      return null;
    }
    return IOSCodeConfig.fromJson(map_);
  }

  set _iOS(IOSCodeConfig? value) {
    if (value == null) {
      json.remove('ios');
    } else {
      json['ios'] = value.json;
    }
  }

  LinkModePreference get linkModePreference =>
      LinkModePreference.fromJson(json.get<String>('link_mode_preference'));

  set _linkModePreference(LinkModePreference value) {
    json['link_mode_preference'] = value.name;
  }

  MacOSCodeConfig? get macOS {
    final map_ = json.optionalMap('macos');
    if (map_ == null) {
      return null;
    }
    return MacOSCodeConfig.fromJson(map_);
  }

  set _macOS(MacOSCodeConfig? value) {
    if (value == null) {
      json.remove('macos');
    } else {
      json['macos'] = value.json;
    }
  }

  Architecture get targetArchitecture =>
      Architecture.fromJson(json.get<String>('target_architecture'));

  set _targetArchitecture(Architecture value) {
    json['target_architecture'] = value.name;
  }

  OS get targetOs => OS.fromJson(json.get<String>('target_os'));

  set _targetOs(OS value) {
    json['target_os'] = value.name;
  }

  @override
  String toString() => 'CodeConfig($json)';
}

class Config {
  final Map<String, Object?> json;

  Config.fromJson(this.json);

  Config({CodeConfig? code}) : json = {} {
    this.code = code;
    json.sortOnKey();
  }

  CodeConfig? get code {
    final map_ = json.optionalMap('code');
    if (map_ == null) {
      return null;
    }
    return CodeConfig.fromJson(map_);
  }

  set code(CodeConfig? value) {
    if (value == null) {
      json.remove('code');
    } else {
      json['code'] = value.json;
    }
    json.sortOnKey();
  }

  @override
  String toString() => 'Config($json)';
}

class IOSCodeConfig {
  final Map<String, Object?> json;

  IOSCodeConfig.fromJson(this.json);

  IOSCodeConfig({String? targetSdk, int? targetVersion}) : json = {} {
    _targetSdk = targetSdk;
    _targetVersion = targetVersion;
    json.sortOnKey();
  }

  String? get targetSdk => json.get<String?>('target_sdk');

  set _targetSdk(String? value) {
    if (value == null) {
      json.remove('target_sdk');
    } else {
      json['target_sdk'] = value;
    }
  }

  int? get targetVersion => json.get<int?>('target_version');

  set _targetVersion(int? value) {
    if (value == null) {
      json.remove('target_version');
    } else {
      json['target_version'] = value;
    }
  }

  @override
  String toString() => 'IOSCodeConfig($json)';
}

class LinkMode {
  final Map<String, Object?> json;

  LinkMode.fromJson(this.json);

  LinkMode({required String type}) : json = {} {
    _type = type;
    json.sortOnKey();
  }

  String get type => json.get<String>('type');

  set _type(String value) {
    json['type'] = value;
  }

  @override
  String toString() => 'LinkMode($json)';
}

class DynamicLoadingBundleLinkMode extends LinkMode {
  DynamicLoadingBundleLinkMode.fromJson(super.json) : super.fromJson();

  DynamicLoadingBundleLinkMode() : super(type: 'dynamic_loading_bundle');

  @override
  String toString() => 'DynamicLoadingBundleLinkMode($json)';
}

extension DynamicLoadingBundleLinkModeExtension on LinkMode {
  bool get isDynamicLoadingBundleLinkMode => type == 'dynamic_loading_bundle';

  DynamicLoadingBundleLinkMode get asDynamicLoadingBundleLinkMode =>
      DynamicLoadingBundleLinkMode.fromJson(json);
}

class DynamicLoadingExecutableLinkMode extends LinkMode {
  DynamicLoadingExecutableLinkMode.fromJson(super.json) : super.fromJson();

  DynamicLoadingExecutableLinkMode()
    : super(type: 'dynamic_loading_executable');

  @override
  String toString() => 'DynamicLoadingExecutableLinkMode($json)';
}

extension DynamicLoadingExecutableLinkModeExtension on LinkMode {
  bool get isDynamicLoadingExecutableLinkMode =>
      type == 'dynamic_loading_executable';

  DynamicLoadingExecutableLinkMode get asDynamicLoadingExecutableLinkMode =>
      DynamicLoadingExecutableLinkMode.fromJson(json);
}

class DynamicLoadingProcessLinkMode extends LinkMode {
  DynamicLoadingProcessLinkMode.fromJson(super.json) : super.fromJson();

  DynamicLoadingProcessLinkMode() : super(type: 'dynamic_loading_process');

  @override
  String toString() => 'DynamicLoadingProcessLinkMode($json)';
}

extension DynamicLoadingProcessLinkModeExtension on LinkMode {
  bool get isDynamicLoadingProcessLinkMode => type == 'dynamic_loading_process';

  DynamicLoadingProcessLinkMode get asDynamicLoadingProcessLinkMode =>
      DynamicLoadingProcessLinkMode.fromJson(json);
}

class DynamicLoadingSystemLinkMode extends LinkMode {
  DynamicLoadingSystemLinkMode.fromJson(super.json) : super.fromJson();

  DynamicLoadingSystemLinkMode({required Uri uri})
    : super(type: 'dynamic_loading_system') {
    _uri = uri;
    json.sortOnKey();
  }

  /// Setup all fields for [DynamicLoadingSystemLinkMode] that are not in
  /// [LinkMode].
  void setup({required Uri uri}) {
    _uri = uri;
    json.sortOnKey();
  }

  Uri get uri => json.path('uri');

  set _uri(Uri value) {
    json['uri'] = value.toFilePath();
  }

  @override
  String toString() => 'DynamicLoadingSystemLinkMode($json)';
}

extension DynamicLoadingSystemLinkModeExtension on LinkMode {
  bool get isDynamicLoadingSystemLinkMode => type == 'dynamic_loading_system';

  DynamicLoadingSystemLinkMode get asDynamicLoadingSystemLinkMode =>
      DynamicLoadingSystemLinkMode.fromJson(json);
}

class StaticLinkMode extends LinkMode {
  StaticLinkMode.fromJson(super.json) : super.fromJson();

  StaticLinkMode() : super(type: 'static');

  @override
  String toString() => 'StaticLinkMode($json)';
}

extension StaticLinkModeExtension on LinkMode {
  bool get isStaticLinkMode => type == 'static';

  StaticLinkMode get asStaticLinkMode => StaticLinkMode.fromJson(json);
}

class LinkModePreference {
  final String name;

  const LinkModePreference._(this.name);

  static const dynamic = LinkModePreference._('dynamic');

  static const preferDynamic = LinkModePreference._('prefer-dynamic');

  static const preferStatic = LinkModePreference._('prefer-static');

  static const static = LinkModePreference._('static');

  static const List<LinkModePreference> values = [
    dynamic,
    preferDynamic,
    preferStatic,
    static,
  ];

  static final Map<String, LinkModePreference> _byName = {
    for (final value in values) value.name: value,
  };

  LinkModePreference.unknown(this.name) : assert(!_byName.keys.contains(name));

  factory LinkModePreference.fromJson(String name) {
    final knownValue = _byName[name];
    if (knownValue != null) {
      return knownValue;
    }
    return LinkModePreference.unknown(name);
  }

  bool get isKnown => _byName[name] != null;

  @override
  String toString() => name;
}

class MacOSCodeConfig {
  final Map<String, Object?> json;

  MacOSCodeConfig.fromJson(this.json);

  MacOSCodeConfig({int? targetVersion}) : json = {} {
    _targetVersion = targetVersion;
    json.sortOnKey();
  }

  int? get targetVersion => json.get<int?>('target_version');

  set _targetVersion(int? value) {
    if (value == null) {
      json.remove('target_version');
    } else {
      json['target_version'] = value;
    }
  }

  @override
  String toString() => 'MacOSCodeConfig($json)';
}

class OS {
  final String name;

  const OS._(this.name);

  static const android = OS._('android');

  static const iOS = OS._('ios');

  static const linux = OS._('linux');

  static const macOS = OS._('macos');

  static const web = OS._('web');

  static const windows = OS._('windows');

  static const List<OS> values = [android, iOS, linux, macOS, web, windows];

  static final Map<String, OS> _byName = {
    for (final value in values) value.name: value,
  };

  OS.unknown(this.name) : assert(!_byName.keys.contains(name));

  factory OS.fromJson(String name) {
    final knownValue = _byName[name];
    if (knownValue != null) {
      return knownValue;
    }
    return OS.unknown(name);
  }

  bool get isKnown => _byName[name] != null;

  @override
  String toString() => name;
}

extension on Map<String, Object?> {
  T get<T extends Object?>(String key) {
    final value = this[key];
    if (value is T) return value;
    if (value == null) {
      throw FormatException('No value was provided for required key: $key');
    }
    throw FormatException(
      'Unexpected value \'$value\' for key \'.$key\'. '
      'Expected a $T.',
    );
  }

  List<T> list<T extends Object?>(String key) =>
      _castList<T>(get<List<Object?>>(key), key);

  List<T>? optionalList<T extends Object?>(String key) =>
      switch (get<List<Object?>?>(key)?.cast<T>()) {
        null => null,
        final l => _castList<T>(l, key),
      };

  /// [List.cast] but with [FormatException]s.
  static List<T> _castList<T extends Object?>(List<Object?> list, String key) {
    for (final value in list) {
      if (value is! T) {
        throw FormatException(
          'Unexpected value \'$list\' (${list.runtimeType}) for key \'.$key\'. '
          'Expected a ${List<T>}.',
        );
      }
    }
    return list.cast();
  }

  Map<String, T> map$<T extends Object?>(String key) =>
      _castMap<T>(get<Map<String, Object?>>(key), key);

  Map<String, T>? optionalMap<T extends Object?>(String key) =>
      switch (get<Map<String, Object?>?>(key)) {
        null => null,
        final m => _castMap<T>(m, key),
      };

  /// [Map.cast] but with [FormatException]s.
  static Map<String, T> _castMap<T extends Object?>(
    Map<String, Object?> map_,
    String key,
  ) {
    for (final value in map_.values) {
      if (value is! T) {
        throw FormatException(
          'Unexpected value \'$map_\' (${map_.runtimeType}) for key \'.$key\'.'
          'Expected a ${Map<String, T>}.',
        );
      }
    }
    return map_.cast();
  }

  List<String>? optionalStringList(String key) => optionalList<String>(key);

  List<String> stringList(String key) => list<String>(key);

  Uri path(String key) => _fileSystemPathToUri(get<String>(key));

  Uri? optionalPath(String key) {
    final value = get<String?>(key);
    if (value == null) return null;
    return _fileSystemPathToUri(value);
  }

  List<Uri>? optionalPathList(String key) {
    final strings = optionalStringList(key);
    if (strings == null) {
      return null;
    }
    return [for (final string in strings) _fileSystemPathToUri(string)];
  }

  static Uri _fileSystemPathToUri(String path) {
    if (path.endsWith(Platform.pathSeparator)) {
      return Uri.directory(path);
    }
    return Uri.file(path);
  }
}

extension on List<Uri> {
  List<String> toJson() => [for (final uri in this) uri.toFilePath()];
}

extension<K extends Comparable<K>, V extends Object?> on Map<K, V> {
  void sortOnKey() {
    final result = <K, V>{};
    final keysSorted = keys.toList()..sort();
    for (final key in keysSorted) {
      result[key] = this[key] as V;
    }
    clear();
    addAll(result);
  }
}
