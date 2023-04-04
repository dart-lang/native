// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'package:cli_config/cli_config.dart' as cli_config;

import 'config_exception.dart';

/// YAML Reader which enables to override specific values from command line.
class YamlReader {
  final cli_config.Config _config;

  final Uri? _configRoot;

  YamlReader.of(this._config, this._configRoot);

  /// Parses the provided command line arguments and returns a [YamlReader].
  ///
  /// This is a utility function which does all things a program would do when
  /// parsing command line arguments, including exiting from the program when
  /// arguments are invalid.
  static YamlReader parseArgs(List<String> args,
      {bool allowYamlConfig = true}) {
    final parser = ArgParser();
    parser.addFlag('help', abbr: 'h', help: 'Show this help.');

    // Sometimes it's required to change a config value for a single invocation,
    // then this option can be used. Conventionally in -D switch is used in
    // C to set preprocessor variable & in java to override a config property.

    parser.addMultiOption('override',
        abbr: 'D',
        help: 'Override or assign a config property from command line.');
    if (allowYamlConfig) {
      parser.addOption('config', abbr: 'c', help: 'Path to YAML config.');
    }

    final results = parser.parse(args);
    if (results['help']) {
      stderr.writeln(parser.usage);
      exit(1);
    }
    final configFilePath = results['config'] as String?;
    String? configFileContents;
    Uri? configFileUri;
    if (configFilePath != null) {
      try {
        configFileContents = File(configFilePath).readAsStringSync();
        configFileUri = File(configFilePath).uri;
      } on Exception catch (e) {
        stderr.writeln('Cannot read $configFilePath: $e.');
      }
    }
    final regex = RegExp('([a-z-_.]+)=(.+)');
    final properties = <String, String>{};
    for (var prop in results['override']) {
      final match = regex.matchAsPrefix(prop as String);
      if (match != null && match.group(0) == prop) {
        final propertyName = match.group(1);
        final propertyValue = match.group(2);
        properties[propertyName!] = propertyValue!;
      } else {
        throw ConfigException('override does not match expected pattern');
      }
    }
    final config = cli_config.Config.fromConfigFileContents(
      commandLineDefines: results['override'],
      workingDirectory: Directory.current.uri,
      environment: Platform.environment,
      fileContents: configFileContents,
      fileSourceUri: configFileUri,
    );
    return YamlReader.of(
      config,
      configFileUri?.resolve('.'),
    );
  }

  bool? getBool(String property) => _config.optionalBool(property);

  String? getString(String property) => _config.optionalString(property);

  /// Same as [getString] but path is resolved relative to YAML config if it's
  /// from YAML config.
  String? getPath(String property) =>
      _config.optionalPath(property)?.toFilePath();

  List<String>? getStringList(String property) => _config.optionalStringList(
        property,
        splitCliPattern: ';',
        combineAllConfigs: false,
      );

  List<String>? getPathList(String property) {
    final configResult = _config.optionalPathList(
      property,
      combineAllConfigs: false,
      splitCliPattern: ';',
    );
    return configResult?.map((e) => e.path).toList();
  }

  String? getOneOf(String property, Set<String> values) =>
      _config.optionalString(property, validValues: values);

  Map<String, String>? getStringMap(String property) {
    final value = _config.valueOf<YamlMap?>(property);
    return value?.cast<String, String>();
  }

  bool hasValue(String property) => _config.valueOf<dynamic>(property) != null;

  /// Returns URI of the directory containing YAML config.
  Uri? getConfigRoot() => _configRoot;
}
