// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/hook_config.dart';

abstract class HookConfigImpl implements HookConfig {
  Hook get hook;

  Uri get configFile => outputDirectory.resolve('../${hook.configName}');

  Uri get outputFile => outputDirectory.resolve(outputName);

  @override
  Uri get outputDirectory;

  // This is currently overriden by [BuildConfig], do account for older versions
  // still using a top-level build.dart.
  Uri get script => packageRoot.resolve('hook/').resolve(hook.scriptName);

  String toJsonString();

  @override
  String get packageName;

  @override
  Uri get packageRoot;

  String get outputName;

  Version get version;
}
