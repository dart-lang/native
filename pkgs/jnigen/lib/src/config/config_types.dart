// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../logging/logging.dart';
import '../transformers/graph.dart' show Visitor;
import 'config_exception.dart';
import 'experiments.dart';
import 'yaml_reader.dart';

/// Configuration for dependencies to be downloaded using maven.
///
/// Dependency names should be listed in groupId:artifactId:version format.
/// For [sourceDeps], sources will be unpacked to [sourceDir] root and JAR files
/// will also be downloaded. For the packages in jarOnlyDeps, only JAR files
/// will be downloaded.
///
/// When passed as a parameter to [Config], the downloaded sources and
/// JAR files will be automatically added to source path and class path
/// respectively.
class MavenDownloads {
  static const defaultMavenSourceDir = 'mvn_java';
  static const defaultMavenJarDir = 'mvn_jar';

  MavenDownloads({
    this.sourceDeps = const [],
    // ASK: Should this be changed to a gitignore'd directory like build ?
    this.sourceDir = defaultMavenSourceDir,
    this.jarOnlyDeps = const [],
    this.jarDir = defaultMavenJarDir,
  });
  List<String> sourceDeps;
  String sourceDir;
  List<String> jarOnlyDeps;
  String jarDir;
}

/// Configuration for Android SDK sources and stub JAR files.
///
/// The SDK directories for platform stub JARs and sources are searched in the
/// same order in which [versions] are specified.
///
/// If [addGradleDeps] is true, a gradle stub is run in order to collect the
/// actual compile classpath of the `android/` subproject.
/// This will fail if there was no previous build of the project, or if a
/// `clean` task was run either through flutter or gradle wrapper. In such case,
/// it's required to run `flutter build apk` & retry running `jnigen`.
///
/// A configuration is invalid if [versions] is unspecified or empty, and gradle
/// options are also false. If [sdkRoot] is not specified but versions is
/// specified, an attempt is made to find out SDK installation directory using
/// environment variable `ANDROID_SDK_ROOT` if it's defined, else an error
/// will be thrown.
class AndroidSdkConfig {
  AndroidSdkConfig({
    this.versions,
    this.sdkRoot,
    this.addGradleDeps = false,
    this.addGradleSources = false,
    this.androidExample,
  }) {
    if (versions != null && sdkRoot == null) {
      throw ConfigException('No SDK Root specified for finding Android SDK '
          'from version priority list $versions');
    }
    if (versions == null && !addGradleDeps && !addGradleSources) {
      throw ConfigException('Neither any SDK versions nor `addGradleDeps` '
          'is specified. Unable to find Android libraries.');
    }
  }

  /// Versions of android SDK to search for, in decreasing order of preference.
  List<int>? versions;

  /// Root of Android SDK installation, this should be normally given on
  /// command line or by setting `ANDROID_SDK_ROOT`, since this varies from
  /// system to system.
  String? sdkRoot;

  /// Attempt to determine exact compile time dependencies by running a gradle
  /// stub in android subproject of this project.
  ///
  /// An Android build must have happened before we are able to obtain classpath
  /// of Gradle dependencies. Run `flutter build apk` before running a jnigen
  /// script with this option.
  ///
  /// For the same reason, if the flutter project is a plugin instead of
  /// application, it's not possible to determine the build classpath directly.
  /// Please provide [androidExample] pointing to an example application in
  /// that case.
  bool addGradleDeps;

  /// Similar to [addGradleDeps], runs a stub to obtain source dependencies of
  /// the Android project.
  ///
  /// This may cause additional source JAR artifacts to be downloaded. Like the
  /// [addGradleDeps] option, plugins cannot be built so an example should be
  /// specified.
  bool addGradleSources;

  /// Relative path to example application which will be used to determine
  /// compile time classpath using a gradle stub. For most Android plugin
  /// packages, 'example' will be the name of example application created inside
  /// the package. This example should be built once before using this option,
  /// so that gradle would have resolved all the dependencies.
  String? androidExample;
}

extension on String {
  /// Converts the enum name from camelCase to snake_case.
  String toSnakeCase() {
    return splitMapJoin(
      RegExp('[A-Z]'),
      onMatch: (p) => '_${p[0]!.toLowerCase()}',
    );
  }
}

extension<T extends Enum> on Iterable<T> {
  Map<String, T> valuesMap() {
    return Map.fromEntries(map((e) => MapEntry(e.name.toSnakeCase(), e)));
  }
}

T _getEnumValueFromString<T>(
    Map<String, T> values, String? name, T defaultVal) {
  if (name == null) return defaultVal;
  final value = values[name];
  if (value == null) {
    throw ConfigException('Got: $name, allowed: ${values.keys}');
  }
  return value;
}

/// Additional options to pass to the summary generator component.
class SummarizerOptions {
  SummarizerOptions(
      {this.extraArgs = const [], this.workingDirectory, this.backend});
  List<String> extraArgs;
  Uri? workingDirectory;
  SummarizerBackend? backend;
}

/// Backend for reading summary of Java libraries
enum SummarizerBackend {
  /// Generate Java API summaries using JARs in provided `classPath`s.
  asm,

  /// Generate Java API summaries using source files in provided `sourcePath`s.
  doclet,
}

SummarizerBackend? getSummarizerBackend(
  String? name,
  SummarizerBackend? defaultVal,
) {
  return _getEnumValueFromString(
    SummarizerBackend.values.valuesMap(),
    name,
    defaultVal,
  );
}

void _ensureIsDirectory(String name, Uri path) {
  if (!path.toFilePath().endsWith(Platform.pathSeparator)) {
    throw ConfigException('$name must be a directory path. If using YAML '
        'config, please ensure the path ends with a slash (/).');
  }
}

enum OutputStructure { packageStructure, singleFile }

OutputStructure getOutputStructure(String? name, OutputStructure defaultVal) {
  return _getEnumValueFromString(
    OutputStructure.values.valuesMap(),
    name,
    defaultVal,
  );
}

class DartCodeOutputConfig {
  DartCodeOutputConfig({
    required this.path,
    this.structure = OutputStructure.packageStructure,
  }) {
    if (structure == OutputStructure.singleFile) {
      if (p.extension(path.toFilePath()) != '.dart') {
        throw ConfigException(
            'Dart\'s output path must end with ".dart" in single file mode.');
      }
    } else {
      _ensureIsDirectory('Dart output path', path);
    }
  }

  /// Path to write generated Dart bindings.
  Uri path;

  /// File structure of the generated Dart bindings.
  OutputStructure structure;
}

class SymbolsOutputConfig {
  /// Path to write generated Dart bindings.
  final Uri path;

  SymbolsOutputConfig(this.path) {
    if (p.extension(path.toFilePath()) != '.json') {
      throw ConfigException('Symbol\'s output path must end with ".json".');
    }
  }
}

class OutputConfig {
  OutputConfig({
    required this.dartConfig,
    this.symbolsConfig,
  });

  DartCodeOutputConfig dartConfig;
  SymbolsOutputConfig? symbolsConfig;
}

bool _isCapitalized(String s) {
  final firstLetter = s.substring(0, 1);
  return firstLetter == firstLetter.toUpperCase();
}

void _validateClassName(String className) {
  final parts = className.split('.');
  assert(parts.isNotEmpty);
  const nestedClassesInfo =
      'Nested classes cannot be specified separately. Specifying the '
      'parent class will pull the nested classes.';
  if (parts.length > 1 && _isCapitalized(parts[parts.length - 2])) {
    // Try to detect possible nested classes specified using dot notation eg:
    // `com.package.Class.NestedClass` and emit a warning.
    log.warning('It appears a nested class $className is specified in the '
        'config. $nestedClassesInfo');
  }
  if (className.contains('\$')) {
    throw ConfigException(
        'Nested class $className not allowed. $nestedClassesInfo');
  }
}

/// Configuration for jnigen binding generation.
class Config {
  Config({
    required this.outputConfig,
    required this.classes,
    this.experiments,
    this.sourcePath,
    this.classPath,
    this.preamble,
    this.customClassBody,
    this.androidSdkConfig,
    this.mavenDownloads,
    this.summarizerOptions,
    this.nonNullAnnotations,
    this.nullableAnnotations,
    this.logLevel = Level.INFO,
    this.dumpJsonTo,
    this.imports,
    this.visitors,
  }) {
    for (final className in classes) {
      _validateClassName(className);
    }
  }

  /// Output configuration for generated bindings
  OutputConfig outputConfig;

  /// List of classes or packages for which bindings have to be generated.
  ///
  /// The names must be fully qualified, and it's assumed that the directory
  /// structure corresponds to package naming. For example, com.abc.MyClass
  /// should be resolvable as `com/abc/MyClass.java` from one of the provided
  /// source paths. Same applies if ASM backend is used, except that the file
  /// name suffix is `.class`.
  List<String> classes;

  Set<Experiment?>? experiments;

  /// Paths to search for java source files.
  ///
  /// If a source package is downloaded through [mavenDownloads] option,
  /// the corresponding source folder is automatically added and does not
  /// need to be explicitly specified.
  List<Uri>? sourcePath;

  /// class path for scanning java libraries. If `backend` is `asm`, the
  /// specified classpath is used to search for [classes], otherwise it's
  /// merely used by the doclet API to find transitively referenced classes,
  /// but not the specified classes / packages themselves.
  List<Uri>? classPath;

  /// Common text to be pasted on top of generated C and Dart files.
  final String? preamble;

  /// Configuration to search for Android SDK libraries (Experimental).
  final AndroidSdkConfig? androidSdkConfig;

  /// Configuration for auto-downloading JAR / source packages using maven,
  /// along with their transitive dependencies.
  final MavenDownloads? mavenDownloads;

  /// Additional options for the summarizer component.
  SummarizerOptions? summarizerOptions;

  /// List of dependencies.
  final List<Uri>? imports;

  /// Annotations specifying that this type is nullable.
  final List<String>? nullableAnnotations;

  /// Annotations specifying that this type is non-nullable.
  final List<String>? nonNullAnnotations;

  /// Custom code that is added to the end of the class body with the specified
  /// binary name.
  ///
  /// Used for testing package:jnigen.
  final Map<String, String>? customClassBody;

  /// User-provided visitors used to transform the generated bindings.
  List<Visitor>? visitors;

  /// Directory containing the YAML configuration file, if any.
  Uri? get configRoot => _configRoot;
  Uri? _configRoot;

  /// Log verbosity. The possible values in decreasing order of verbosity
  /// are verbose > debug > info > warning > error.
  ///
  /// Defaults to [Level.INFO].
  Level logLevel = Level.INFO;

  /// File to which JSON summary is written before binding generation.
  final String? dumpJsonTo;

  static final _levels = Map.fromEntries(
      Level.LEVELS.map((l) => MapEntry(l.name.toLowerCase(), l)));

  static Config parseArgs(List<String> args) {
    final prov = YamlReader.parseArgs(args);

    final missingValues = <String>[];

    T must<T>(T? Function(String) f, T ifNull, String property) {
      final res = f(property);
      if (res == null) {
        missingValues.add(property);
        return ifNull;
      }
      return res;
    }

    String? getSdkRoot() {
      final root = prov.getString(_Props.androidSdkRoot) ??
          Platform.environment['ANDROID_SDK_ROOT'];
      return root;
    }

    Level logLevelFromString(String? levelName) {
      if (levelName == null) return Level.INFO;
      final level = _levels[levelName.toLowerCase()];
      if (level == null) {
        throw ConfigException('Not a valid logging level: $levelName');
      }
      return level;
    }

    final configRoot = prov.getConfigRoot();
    String resolveFromConfigRoot(String reference) =>
        configRoot?.resolve(reference).toFilePath() ?? reference;

    final config = Config(
      sourcePath: prov.getPathList(_Props.sourcePath),
      classPath: prov.getPathList(_Props.classPath),
      classes: must(prov.getStringList, [], _Props.classes),
      summarizerOptions: SummarizerOptions(
        extraArgs: prov.getStringList(_Props.summarizerArgs) ?? const [],
        backend: getSummarizerBackend(prov.getString(_Props.backend), null),
        workingDirectory: prov.getPath(_Props.summarizerWorkingDir),
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: must(prov.getPath, Uri.parse('.'), _Props.dartRoot),
          structure: getOutputStructure(
            prov.getString(_Props.outputStructure),
            OutputStructure.packageStructure,
          ),
        ),
        symbolsConfig: prov.hasValue(_Props.symbolsOutputConfig)
            ? SymbolsOutputConfig(
                must(prov.getPath, Uri.parse('.'), _Props.symbolsOutputConfig),
              )
            : null,
      ),
      preamble: prov.getString(_Props.preamble),
      experiments: prov
          .getStringList(_Props.experiments)
          ?.map(
            Experiment.fromString,
          )
          .toSet(),
      imports: prov.getPathList(_Props.import),
      nonNullAnnotations: prov.hasValue(_Props.nonNullAnnotations)
          ? prov.getStringList(_Props.nonNullAnnotations)
          : null,
      nullableAnnotations: prov.hasValue(_Props.nullableAnnotations)
          ? prov.getStringList(_Props.nullableAnnotations)
          : null,
      mavenDownloads: prov.hasValue(_Props.mavenDownloads)
          ? MavenDownloads(
              sourceDeps: prov.getStringList(_Props.sourceDeps) ?? const [],
              sourceDir: prov.getPath(_Props.mavenSourceDir)?.toFilePath() ??
                  resolveFromConfigRoot(MavenDownloads.defaultMavenSourceDir),
              jarOnlyDeps: prov.getStringList(_Props.jarOnlyDeps) ?? const [],
              jarDir: prov.getPath(_Props.mavenJarDir)?.toFilePath() ??
                  resolveFromConfigRoot(MavenDownloads.defaultMavenJarDir),
            )
          : null,
      androidSdkConfig: prov.hasValue(_Props.androidSdkConfig)
          ? AndroidSdkConfig(
              versions: prov
                  .getStringList(_Props.androidSdkVersions)
                  ?.map(int.parse)
                  .toList(),
              sdkRoot: getSdkRoot(),
              addGradleDeps: prov.getBool(_Props.addGradleDeps) ?? false,
              addGradleSources: prov.getBool(_Props.addGradleSources) ?? false,
              // Leaving this as getString instead of getPath, because
              // it's resolved later in android_sdk_tools.
              androidExample: prov.getString(_Props.androidExample),
            )
          : null,
      logLevel: logLevelFromString(
        prov.getOneOf(
          _Props.logLevel,
          _levels.keys.toSet(),
        ),
      ),
    );
    if (missingValues.isNotEmpty) {
      stderr.write('Following config values are required but not provided\n'
          'Please provide these properties through YAML '
          'or use the command line switch -D<property_name>=<value>.\n');
      for (var missing in missingValues) {
        stderr.writeln('* $missing');
      }
      if (missingValues.contains(_Props.androidSdkRoot)) {
        stderr.writeln('Please specify ${_Props.androidSdkRoot} through '
            'command line or ensure that the ANDROID_SDK_ROOT environment '
            'variable is set.');
      }
      exit(1);
    }
    config._configRoot = configRoot;
    return config;
  }
}

class _Props {
  static const summarizer = 'summarizer';
  static const summarizerArgs = '$summarizer.extra_args';
  static const summarizerWorkingDir = '$summarizer.working_dir';
  static const backend = '$summarizer.backend';

  static const sourcePath = 'source_path';
  static const classPath = 'class_path';
  static const classes = 'classes';

  static const experiments = 'enable_experiment';
  static const import = 'import';
  static const outputConfig = 'output';
  static const dartCodeOutputConfig = '$outputConfig.dart';
  static const symbolsOutputConfig = '$outputConfig.symbols';
  static const dartRoot = '$dartCodeOutputConfig.path';
  static const outputStructure = '$dartCodeOutputConfig.structure';
  static const preamble = 'preamble';
  static const logLevel = 'log_level';

  static const nonNullAnnotations = 'non_null_annotations';
  static const nullableAnnotations = 'nullable_annotations';

  static const mavenDownloads = 'maven_downloads';
  static const sourceDeps = '$mavenDownloads.source_deps';
  static const mavenSourceDir = '$mavenDownloads.source_dir';
  static const jarOnlyDeps = '$mavenDownloads.jar_only_deps';
  static const mavenJarDir = '$mavenDownloads.jar_dir';

  static const androidSdkConfig = 'android_sdk_config';
  static const androidSdkRoot = '$androidSdkConfig.sdk_root';
  static const androidSdkVersions = '$androidSdkConfig.versions';
  static const addGradleDeps = '$androidSdkConfig.add_gradle_deps';
  static const addGradleSources = '$androidSdkConfig.add_gradle_sources';
  static const androidExample = '$androidSdkConfig.android_example';
}
