// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.

// ignore_for_file: unused_element

import 'dart:io';

class AndroidCodeConfig {
  final Map<String, Object?> json;

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  AndroidCodeConfig.fromJson(this.json, {this.path = const []});

  AndroidCodeConfig({int? targetNdkApi}) : json = {}, path = const [] {
    _targetNdkApi = targetNdkApi;
    json.sortOnKey();
  }

  int? get targetNdkApi => _reader.get<int?>('target_ndk_api');

  set _targetNdkApi(int? value) {
    json.setOrRemove('target_ndk_api', value);
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

  static const riscv32 = Architecture._('riscv32');

  static const riscv64 = Architecture._('riscv64');

  static const x64 = Architecture._('x64');

  static const List<Architecture> values = [
    arm,
    arm64,
    ia32,
    riscv32,
    riscv64,
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

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  Asset.fromJson(this.json, {this.path = const []});

  Asset({String? type}) : json = {}, path = const [] {
    _type = type;
    json.sortOnKey();
  }

  String? get type => _reader.get<String?>('type');

  set _type(String? value) {
    json.setOrRemove('type', value);
  }

  @override
  String toString() => 'Asset($json)';
}

class NativeCodeAsset extends Asset {
  NativeCodeAsset.fromJson(super.json, {super.path}) : super.fromJson();

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
    final jsonValue = _reader.get<String?>('architecture');
    if (jsonValue == null) return null;
    return Architecture.fromJson(jsonValue);
  }

  set _architecture(Architecture? value) {
    json.setOrRemove('architecture', value?.name);
  }

  Uri? get file => _reader.optionalPath('file');

  set _file(Uri? value) {
    json.setOrRemove('file', value?.toFilePath());
  }

  String get id => _reader.get<String>('id');

  set _id(String value) {
    json.setOrRemove('id', value);
  }

  LinkMode get linkMode {
    final jsonValue = _reader.map$('link_mode');
    return LinkMode.fromJson(jsonValue, path: [...path, 'link_mode']);
  }

  set _linkMode(LinkMode value) {
    json['link_mode'] = value.json;
  }

  OS get os {
    final jsonValue = _reader.get<String>('os');
    return OS.fromJson(jsonValue);
  }

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

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  CCompilerConfig.fromJson(this.json, {this.path = const []});

  CCompilerConfig({
    required Uri ar,
    required Uri cc,
    Uri? envScript,
    List<String>? envScriptArguments,
    required Uri ld,
    Windows? windows,
  }) : json = {},
       path = const [] {
    _ar = ar;
    _cc = cc;
    _envScript = envScript;
    _envScriptArguments = envScriptArguments;
    _ld = ld;
    _windows = windows;
    json.sortOnKey();
  }

  Uri get ar => _reader.path$('ar');

  set _ar(Uri value) {
    json['ar'] = value.toFilePath();
  }

  Uri get cc => _reader.path$('cc');

  set _cc(Uri value) {
    json['cc'] = value.toFilePath();
  }

  Uri? get envScript => _reader.optionalPath('env_script');

  set _envScript(Uri? value) {
    json.setOrRemove('env_script', value?.toFilePath());
  }

  List<String>? get envScriptArguments =>
      _reader.optionalStringList('env_script_arguments');

  set _envScriptArguments(List<String>? value) {
    json.setOrRemove('env_script_arguments', value);
  }

  Uri get ld => _reader.path$('ld');

  set _ld(Uri value) {
    json['ld'] = value.toFilePath();
  }

  Windows? get windows {
    final jsonValue = _reader.optionalMap('windows');
    if (jsonValue == null) return null;
    return Windows.fromJson(jsonValue, path: [...path, 'windows']);
  }

  set _windows(Windows? value) {
    json.setOrRemove('windows', value?.json);
  }

  @override
  String toString() => 'CCompilerConfig($json)';
}

class Windows {
  final Map<String, Object?> json;

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  Windows.fromJson(this.json, {this.path = const []});

  Windows({DeveloperCommandPrompt? developerCommandPrompt})
    : json = {},
      path = const [] {
    _developerCommandPrompt = developerCommandPrompt;
    json.sortOnKey();
  }

  DeveloperCommandPrompt? get developerCommandPrompt {
    final jsonValue = _reader.optionalMap('developer_command_prompt');
    if (jsonValue == null) return null;
    return DeveloperCommandPrompt.fromJson(
      jsonValue,
      path: [...path, 'developer_command_prompt'],
    );
  }

  set _developerCommandPrompt(DeveloperCommandPrompt? value) {
    json.setOrRemove('developer_command_prompt', value?.json);
  }

  @override
  String toString() => 'Windows($json)';
}

class DeveloperCommandPrompt {
  final Map<String, Object?> json;

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  DeveloperCommandPrompt.fromJson(this.json, {this.path = const []});

  DeveloperCommandPrompt({required List<String> arguments, required Uri script})
    : json = {},
      path = const [] {
    _arguments = arguments;
    _script = script;
    json.sortOnKey();
  }

  List<String> get arguments => _reader.stringList('arguments');

  set _arguments(List<String> value) {
    json['arguments'] = value;
  }

  Uri get script => _reader.path$('script');

  set _script(Uri value) {
    json['script'] = value.toFilePath();
  }

  @override
  String toString() => 'DeveloperCommandPrompt($json)';
}

class CodeConfig {
  final Map<String, Object?> json;

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  CodeConfig.fromJson(this.json, {this.path = const []});

  CodeConfig({
    AndroidCodeConfig? android,
    CCompilerConfig? cCompiler,
    IOSCodeConfig? iOS,
    required LinkModePreference linkModePreference,
    MacOSCodeConfig? macOS,
    required Architecture targetArchitecture,
    required OS targetOs,
  }) : json = {},
       path = const [] {
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
    final jsonValue = _reader.optionalMap('android');
    if (jsonValue == null) return null;
    return AndroidCodeConfig.fromJson(jsonValue, path: [...path, 'android']);
  }

  set _android(AndroidCodeConfig? value) {
    json.setOrRemove('android', value?.json);
  }

  CCompilerConfig? get cCompiler {
    final jsonValue = _reader.optionalMap('c_compiler');
    if (jsonValue == null) return null;
    return CCompilerConfig.fromJson(jsonValue, path: [...path, 'c_compiler']);
  }

  set _cCompiler(CCompilerConfig? value) {
    json.setOrRemove('c_compiler', value?.json);
  }

  IOSCodeConfig? get iOS {
    final jsonValue = _reader.optionalMap('ios');
    if (jsonValue == null) return null;
    return IOSCodeConfig.fromJson(jsonValue, path: [...path, 'ios']);
  }

  set _iOS(IOSCodeConfig? value) {
    json.setOrRemove('ios', value?.json);
  }

  LinkModePreference get linkModePreference {
    final jsonValue = _reader.get<String>('link_mode_preference');
    return LinkModePreference.fromJson(jsonValue);
  }

  set _linkModePreference(LinkModePreference value) {
    json['link_mode_preference'] = value.name;
  }

  MacOSCodeConfig? get macOS {
    final jsonValue = _reader.optionalMap('macos');
    if (jsonValue == null) return null;
    return MacOSCodeConfig.fromJson(jsonValue, path: [...path, 'macos']);
  }

  set _macOS(MacOSCodeConfig? value) {
    json.setOrRemove('macos', value?.json);
  }

  Architecture get targetArchitecture {
    final jsonValue = _reader.get<String>('target_architecture');
    return Architecture.fromJson(jsonValue);
  }

  set _targetArchitecture(Architecture value) {
    json['target_architecture'] = value.name;
  }

  OS get targetOs {
    final jsonValue = _reader.get<String>('target_os');
    return OS.fromJson(jsonValue);
  }

  set _targetOs(OS value) {
    json['target_os'] = value.name;
  }

  @override
  String toString() => 'CodeConfig($json)';
}

class Config {
  final Map<String, Object?> json;

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  Config.fromJson(this.json, {this.path = const []});

  Config({CodeConfig? code}) : json = {}, path = const [] {
    this.code = code;
    json.sortOnKey();
  }

  CodeConfig? get code {
    final jsonValue = _reader.optionalMap('code');
    if (jsonValue == null) return null;
    return CodeConfig.fromJson(jsonValue, path: [...path, 'code']);
  }

  set code(CodeConfig? value) {
    json.setOrRemove('code', value?.json);
    json.sortOnKey();
  }

  @override
  String toString() => 'Config($json)';
}

class IOSCodeConfig {
  final Map<String, Object?> json;

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  IOSCodeConfig.fromJson(this.json, {this.path = const []});

  IOSCodeConfig({String? targetSdk, int? targetVersion})
    : json = {},
      path = const [] {
    _targetSdk = targetSdk;
    _targetVersion = targetVersion;
    json.sortOnKey();
  }

  String? get targetSdk => _reader.get<String?>('target_sdk');

  set _targetSdk(String? value) {
    json.setOrRemove('target_sdk', value);
  }

  int? get targetVersion => _reader.get<int?>('target_version');

  set _targetVersion(int? value) {
    json.setOrRemove('target_version', value);
  }

  @override
  String toString() => 'IOSCodeConfig($json)';
}

class LinkMode {
  final Map<String, Object?> json;

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  LinkMode.fromJson(this.json, {this.path = const []});

  LinkMode({required String type}) : json = {}, path = const [] {
    _type = type;
    json.sortOnKey();
  }

  String get type => _reader.get<String>('type');

  set _type(String value) {
    json.setOrRemove('type', value);
  }

  @override
  String toString() => 'LinkMode($json)';
}

class DynamicLoadingBundleLinkMode extends LinkMode {
  DynamicLoadingBundleLinkMode.fromJson(super.json, {super.path})
    : super.fromJson();

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
  DynamicLoadingExecutableLinkMode.fromJson(super.json, {super.path})
    : super.fromJson();

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
  DynamicLoadingProcessLinkMode.fromJson(super.json, {super.path})
    : super.fromJson();

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
  DynamicLoadingSystemLinkMode.fromJson(super.json, {super.path})
    : super.fromJson();

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

  Uri get uri => _reader.path$('uri');

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
  StaticLinkMode.fromJson(super.json, {super.path}) : super.fromJson();

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

  final List<Object> path;

  JsonReader get _reader => JsonReader(json, path);

  MacOSCodeConfig.fromJson(this.json, {this.path = const []});

  MacOSCodeConfig({int? targetVersion}) : json = {}, path = const [] {
    _targetVersion = targetVersion;
    json.sortOnKey();
  }

  int? get targetVersion => _reader.get<int?>('target_version');

  set _targetVersion(int? value) {
    json.setOrRemove('target_version', value);
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

  static const windows = OS._('windows');

  static const List<OS> values = [android, iOS, linux, macOS, windows];

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

class JsonReader {
  /// The JSON Object this reader is reading.
  final Map<String, Object?> json;

  /// The path traversed by readers of the surrounding JSON.
  ///
  /// Contains [String] property keys and [int] indices.
  ///
  /// This is used to give more precise error messages.
  final List<Object> path;

  JsonReader(this.json, this.path);

  T get<T extends Object?>(String key) {
    final value = json[key];
    if (value is T) return value;
    final pathString = _jsonPathToString([key]);
    if (value == null) {
      throw FormatException("No value was provided for '$pathString'.");
    }
    throwFormatException(value, T, [key]);
  }

  List<T> list<T extends Object?>(String key) =>
      _castList<T>(get<List<Object?>>(key), key);

  List<T>? optionalList<T extends Object?>(String key) =>
      switch (get<List<Object?>?>(key)?.cast<T>()) {
        null => null,
        final l => _castList<T>(l, key),
      };

  /// [List.cast] but with [FormatException]s.
  List<T> _castList<T extends Object?>(List<Object?> list, String key) {
    var index = 0;
    for (final value in list) {
      if (value is! T) {
        throwFormatException(value, T, [key, index]);
      }
      index++;
    }
    return list.cast();
  }

  List<T>? optionalListParsed<T extends Object?>(
    String key,
    T Function(Object?) elementParser,
  ) {
    final jsonValue = optionalList(key);
    if (jsonValue == null) return null;
    return [for (final element in jsonValue) elementParser(element)];
  }

  Map<String, T> map$<T extends Object?>(String key) =>
      _castMap<T>(get<Map<String, Object?>>(key), key);

  Map<String, T>? optionalMap<T extends Object?>(String key) =>
      switch (get<Map<String, Object?>?>(key)) {
        null => null,
        final m => _castMap<T>(m, key),
      };

  /// [Map.cast] but with [FormatException]s.
  Map<String, T> _castMap<T extends Object?>(
    Map<String, Object?> map_,
    String parentKey,
  ) {
    for (final MapEntry(:key, :value) in map_.entries) {
      if (value is! T) {
        throwFormatException(value, T, [parentKey, key]);
      }
    }
    return map_.cast();
  }

  List<String>? optionalStringList(String key) => optionalList<String>(key);

  List<String> stringList(String key) => list<String>(key);

  Uri path$(String key) => _fileSystemPathToUri(get<String>(key));

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

  String _jsonPathToString(List<Object> pathEnding) =>
      [...path, ...pathEnding].join('.');

  Never throwFormatException(
    Object? value,
    Type expectedType,
    List<Object> pathExtension,
  ) {
    final pathString = _jsonPathToString(pathExtension);
    throw FormatException(
      "Unexpected value '$value' (${value.runtimeType}) for '$pathString'. "
      'Expected a $expectedType.',
    );
  }
}

extension on Map<String, Object?> {
  void setOrRemove(String key, Object? value) {
    if (value == null) {
      remove(key);
    } else {
      this[key] = value;
    }
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
