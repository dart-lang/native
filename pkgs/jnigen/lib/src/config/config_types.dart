// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../elements/elements.dart';
import '../logging/logging.dart';
import '../util/find_package.dart';
import 'config_exception.dart';
import 'experiments.dart';
import 'filters.dart';
import 'yaml_reader.dart';

/// Modify this when symbols file format changes according to pub_semver.
final _currentVersion = Version(1, 0, 0);

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
    if (p.extension(path.toFilePath()) != '.yaml') {
      throw ConfigException('Symbol\'s output path must end with ".yaml".');
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

class BindingExclusions {
  BindingExclusions({this.methods, this.fields, this.classes});
  MethodFilter? methods;
  FieldFilter? fields;
  ClassFilter? classes;
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
    this.exclude,
    this.sourcePath,
    this.classPath,
    this.preamble,
    this.customClassBody,
    this.androidSdkConfig,
    this.mavenDownloads,
    this.summarizerOptions,
    this.logLevel = Level.INFO,
    this.dumpJsonTo,
    this.imports,
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

  /// Methods and fields to be excluded from generated bindings.
  final BindingExclusions? exclude;

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

  /// Call [importClasses] before using this.
  late final Map<String, ClassDecl> importedClasses;

  /// Custom code that is added to the end of the class body with the specified
  /// binary name.
  ///
  /// Used for testing package:jnigen.
  final Map<String, String>? customClassBody;

  Future<void> importClasses() async {
    importedClasses = {};
    for (final import in [
      // Implicitly importing package:jni symbols.
      Uri.parse('package:jni/jni_symbols.yaml'),
      ...?imports,
    ]) {
      // Getting the actual uri in case of package uris.
      final Uri yamlUri;
      final String importPath;
      if (import.scheme == 'package') {
        final packageName = import.pathSegments.first;
        final packageRoot = await findPackageRoot(packageName);
        if (packageRoot == null) {
          log.fatal('package:$packageName was not found.');
        }
        yamlUri = packageRoot
            .resolve('lib/')
            .resolve(import.pathSegments.sublist(1).join('/'));
        importPath = 'package:$packageName';
      } else {
        yamlUri = import;
        importPath = ([...import.pathSegments]..removeLast()).join('/');
      }
      log.finest('Parsing yaml file in url $yamlUri.');
      final YamlMap yaml;
      try {
        final symbolsFile = File.fromUri(yamlUri);
        final content = symbolsFile.readAsStringSync();
        yaml = loadYaml(content, sourceUrl: yamlUri) as YamlMap;
      } catch (e, s) {
        log.warning(e);
        log.warning(s);
        log.fatal('Error while parsing yaml file "$import".');
      }
      final version = Version.parse(yaml['version'] as String);
      if (!VersionConstraint.compatibleWith(_currentVersion).allows(version)) {
        log.fatal('"$import" is version "$version" which is not compatible with'
            'the current JNIgen symbols version $_currentVersion');
      }
      final files = yaml['files'] as YamlMap;
      for (final entry in files.entries) {
        final filePath = entry.key as String;
        final classes = entry.value as YamlMap;
        for (final classEntry in classes.entries) {
          final binaryName = classEntry.key as String;
          final decl = classEntry.value as YamlMap;
          if (importedClasses.containsKey(binaryName)) {
            log.fatal(
              'Re-importing "$binaryName" in "$import".\n'
              'Try hiding the class in import.',
            );
          }
          final classDecl = ClassDecl(
            declKind: DeclKind.classKind,
            binaryName: binaryName,
          )
            ..path = '$importPath/$filePath'
            ..finalName = decl['name'] as String
            ..typeClassName = decl['type_class'] as String
            ..nullableTypeClassName = decl['nullable_type_class'] as String
            ..superCount = decl['super_count'] as int
            ..allTypeParams = []
            // TODO(https://github.com/dart-lang/native/issues/746): include
            // outerClass in the interop information.
            ..outerClass = null;
          for (final typeParamEntry
              in (decl['type_params'] as YamlMap?)?.entries ??
                  <MapEntry<dynamic, dynamic>>[]) {
            final typeParamName = typeParamEntry.key as String;
            final bounds = (typeParamEntry.value as YamlMap).entries.map((e) {
              final boundName = e.key as String;
              // Can only be DECLARED or TYPE_VARIABLE
              if (!['DECLARED', 'TYPE_VARIABLE'].contains(e.value)) {
                log.fatal(
                  'Unsupported bound kind "${e.value}" for bound "$boundName" '
                  'in type parameter "$typeParamName" '
                  'of "$binaryName".',
                );
              }
              final boundKind = (e.value as String) == 'DECLARED'
                  ? Kind.declared
                  : Kind.typeVariable;
              final ReferredType type;
              if (boundKind == Kind.declared) {
                type = DeclaredType(binaryName: boundName);
              } else {
                type = TypeVar(name: boundName);
              }
              return TypeUsage(
                shorthand: binaryName,
                kind: boundKind,
                typeJson: {},
              )..type = type;
            }).toList();
            classDecl.allTypeParams.add(
              TypeParam(name: typeParamName, bounds: bounds),
            );
          }
          classDecl.methodNumsAfterRenaming =
              (decl['methods'] as YamlMap?)?.cast() ?? {};
          importedClasses[binaryName] = classDecl;
        }
      }
    }
  }

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

    MemberFilter<T>? regexFilter<T extends ClassMember>(String property) {
      final exclusions = prov.getStringList(property);
      if (exclusions == null) return null;
      final filters = <MemberFilter<T>>[];
      for (var exclusion in exclusions) {
        final split = exclusion.split('#');
        if (split.length != 2) {
          throw ConfigException('Error parsing exclusion: "$exclusion": '
              'expected to be in binaryName#member format.');
        }
        filters.add(MemberNameFilter<T>.exclude(
          RegExp(split[0]),
          RegExp(split[1]),
        ));
      }
      return CombinedMemberFilter<T>(filters);
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
      exclude: BindingExclusions(
        methods: regexFilter<Method>(_Props.excludeMethods),
        fields: regexFilter<Field>(_Props.excludeFields),
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
  static const exclude = 'exclude';
  static const excludeMethods = '$exclude.methods';
  static const excludeFields = '$exclude.fields';

  static const experiments = 'enable_experiment';
  static const import = 'import';
  static const outputConfig = 'output';
  static const dartCodeOutputConfig = '$outputConfig.dart';
  static const symbolsOutputConfig = '$outputConfig.symbols';
  static const dartRoot = '$dartCodeOutputConfig.path';
  static const outputStructure = '$dartCodeOutputConfig.structure';
  static const preamble = 'preamble';
  static const logLevel = 'log_level';

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
