// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import '../model/link_input.dart';
import '../model/pipeline_config.dart';
import 'asset.dart';
import 'build_config.dart';
import 'resources.dart';

abstract class LinkConfig extends PipelineConfig {
  /// Generate the [LinkConfig] from the input arguments to the linking script.
  static Future<LinkConfig> fromArgs(List<String> args) async {
    final argParser = ArgParser()..addOption('link_config');

    final results = argParser.parse(args);
    final yaml =
        loadYaml(File(results['link_config'] as String).readAsStringSync())
            as YamlMap;

    return LinkConfigArgs.fromYaml(yaml).fromArgs();
  }

  @override
  Uri get configFile;

  @override
  Uri get outDir;

  @override
  String get outputName;

  @override
  String get packageName;

  @override
  Uri get packageRoot;

  @override
  Map<String, Object> toYaml();

  @override
  Uri get script;

  List<Asset> get assets;
  BuildConfig get buildConfig;
  ResourceIdentifiers? get resourceIdentifiers;
}
