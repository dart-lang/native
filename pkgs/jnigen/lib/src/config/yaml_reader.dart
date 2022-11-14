// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'config_exception.dart';

/// YAML Reader which enables to override specific values from command line.
class YamlReader {
  YamlReader.of(this.cli, this.yaml, this.yamlFile);
  Map<String, String> cli;
  Map<dynamic, dynamic> yaml;
  File? yamlFile;

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
    final configFile = results['config'] as String?;
    Map<dynamic, dynamic> yamlMap = {};
    if (configFile != null) {
      try {
        final yamlInput = loadYaml(File(configFile).readAsStringSync(),
            sourceUrl: Uri.file(configFile));
        if (yamlInput is Map) {
          yamlMap = yamlInput;
        } else {
          throw ConfigException('YAML config must be set of key value pairs');
        }
      } on Exception catch (e) {
        stderr.writeln('cannot read $configFile: $e');
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
    return YamlReader.of(
        properties, yamlMap, configFile != null ? File(configFile) : null);
  }

  bool? getBool(String property) {
    if (cli.containsKey(property)) {
      final v = cli[property]!;
      if (v == 'true') {
        return true;
      }
      if (v == 'false') {
        return false;
      }
      throw ConfigException('expected boolean value for $property, got $v');
    }
    return getYamlValue<bool>(property);
  }

  String? getString(String property) {
    final configValue = cli[property] ?? getYamlValue<String>(property);
    return configValue;
  }

  /// Same as [getString] but path is resolved relative to YAML config if it's
  /// from YAML config.
  String? getPath(String property) {
    final cliOverride = cli[property];
    if (cliOverride != null) return cliOverride;
    final path = getYamlValue<String>(property);
    if (path == null) return null;
    // In (very unlikely) case YAML config didn't come from a file,
    // do not try to resolve anything.
    if (yamlFile == null) return path;
    final yamlDir = yamlFile!.parent;
    return yamlDir.uri.resolve(path).toFilePath();
  }

  List<String>? getStringList(String property) {
    final configValue = cli[property]?.split(';') ??
        getYamlValue<YamlList>(property)?.cast<String>();
    return configValue;
  }

  List<String>? getPathList(String property) {
    final cliOverride = cli[property]?.split(';');
    if (cliOverride != null) return cliOverride;
    final paths = getYamlValue<YamlList>(property)?.cast<String>();
    if (paths == null) return null;
    // In (very unlikely) case YAML config didn't come from a file.
    if (yamlFile == null) return paths;
    final yamlDir = yamlFile!.parent;
    return paths.map((path) => yamlDir.uri.resolve(path).toFilePath()).toList();
  }

  String? getOneOf(String property, Set<String> values) {
    final value = cli[property] ?? getYamlValue<String>(property);
    if (value == null || values.contains(value)) {
      return value;
    }
    throw ConfigException('expected one of $values for $property');
  }

  Map<String, String>? getStringMap(String property) {
    final value = getYamlValue<YamlMap>(property);
    return value?.cast<String, String>();
  }

  bool hasValue(String property) => getYamlValue<dynamic>(property) != null;

  T? getYamlValue<T>(String property) {
    final path = property.split('.');
    dynamic cursor = yaml;
    String current = '';
    for (var i in path) {
      if (cursor is YamlMap || cursor is Map) {
        cursor = cursor[i];
      } else {
        throw ConfigException('expected $current to be a YAML map');
      }
      current = [if (current != '') current, i].join('.');
      if (cursor == null) {
        return null;
      }
    }
    if (cursor is! T) {
      throw ConfigException(
          'expected $T for $property, got ${cursor.runtimeType}');
    }
    return cursor;
  }

  /// Returns URI of the directory containing YAML config.
  Uri? getConfigRoot() => yamlFile?.parent.uri;
}
