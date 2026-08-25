// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../elements/elements.dart';
import '../elements/j_elements.dart' as j_ast;
import '../logging/logging.dart';
import '../util/find_package.dart';
import 'config_exception.dart';
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
/// When passed as a parameter to [JniGenerator], the downloaded sources and
/// JAR files will be automatically added to source path and class path
/// respectively.
class MavenDownloads {
  static final defaultMavenSourceDir = Uri.directory('mvn_java');
  static final defaultMavenJarDir = Uri.directory('mvn_jar');

  MavenDownloads({
    this.sourceDeps = const [],
    // ASK: Should this be changed to a gitignore'd directory like build ?
    Uri? sourceDir,
    this.jarOnlyDeps = const [],
    Uri? jarDir,
  })  : sourceDir = sourceDir ?? defaultMavenSourceDir,
        jarDir = jarDir ?? defaultMavenJarDir;

  /// List of Maven dependencies to download sources for.
  List<String> sourceDeps;

  /// Directory where Maven sources are extracted.
  Uri sourceDir;

  /// List of Maven dependencies to download JARs for only.
  List<String> jarOnlyDeps;

  /// Directory where Maven JARs are stored.
  Uri jarDir;
}

/// Configuration for Android SDK sources and stub JAR files.
///
/// The SDK directories for platform stub JARs and sources are searched in the
/// same order in which [versions] are specified.
///
/// If [addGradleDeps] is true, a gradle stub is run in order to collect the
/// actual compile classpath of the `android/` subproject.
/// This may fail if a `clean` task was run either through flutter or gradle
/// wrapper. In such case, it's required to run `flutter pub get` & retry
/// running JNIgen.
///
/// A configuration is invalid if [versions] is unspecified or empty, and gradle
/// options are also false. If [sdkRoot] is not specified but versions is
/// specified, an attempt is made to find out SDK installation directory using
/// environment variable `ANDROID_SDK_ROOT` if it's defined, else an error
/// will be thrown.
class AndroidSdk {
  AndroidSdk({
    this.versions,
    this.sdkRoot,
    this.addGradleDeps = false,
    this.addGradleSources = false,
    Uri? androidExample,
  }) : androidExample = androidExample ?? Uri.directory('.') {
    if (versions != null && sdkRoot == null) {
      throw ConfigException('No SDK Root specified for finding Android SDK '
          'from version priority list $versions');
    }
    if (versions == null && !addGradleDeps && !addGradleSources) {
      throw ConfigException('Neither any SDK versions nor `addGradleDeps` '
          'is specified. Unable to find Android libraries.');
    }
  }

  /// Versions of Android SDK to search for, in decreasing order of preference.
  ///
  /// If `null`, Android SDK platform versions are not searched directly. Note
  /// that at least one of [versions], `addGradleDeps`, or `addGradleSources`
  /// must be provided, otherwise a [ConfigException] is thrown.
  List<int>? versions;

  /// Root of Android SDK installation.
  ///
  /// If `null`, JNIgen attempts to find the SDK directory using the
  /// `ANDROID_SDK_ROOT` environment variable. If [versions] is specified and
  /// [sdkRoot] remains `null` (and `ANDROID_SDK_ROOT` is unset), a
  /// [ConfigException] is thrown.
  Uri? sdkRoot;

  /// Attempt to determine exact compile time dependencies by running a gradle
  /// stub in android subproject of this project.
  ///
  /// If the flutter project is a plugin instead of application, it's not
  /// possible to determine the build classpath directly. Please provide
  /// [androidExample] pointing to an example application in that case.
  ///
  /// It is necessary to run `flutter pub get` on the application (or plugin's
  /// example app) before running JNIgen.
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
  /// the package.
  Uri androidExample;
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

/// File structure of the generated Dart bindings.
enum OutputStructure {
  /// Generate package structure with multiple files.
  packageStructure,

  /// Generate all Dart bindings into a single file.
  singleFile,
}

OutputStructure getOutputStructure(String? name, OutputStructure defaultVal) {
  return _getEnumValueFromString(
    OutputStructure.values.valuesMap(),
    name,
    defaultVal,
  );
}

/// Configuration for outputting generated Dart code.
class DartCodeOutput {
  DartCodeOutput({
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

/// Configuration for outputting generated symbols YAML file.
class SymbolsOutput {
  /// Path to write generated symbols YAML file.
  final Uri path;

  SymbolsOutput(this.path) {
    if (p.extension(path.toFilePath()) != '.yaml') {
      throw ConfigException('Symbol\'s output path must end with ".yaml".');
    }
  }
}

/// Configuration for importing symbol files (`symbols.yaml`) from other
/// packages.
final class SymbolImports {
  /// Symbol file URIs (`package:...` or file paths) to import.
  final List<Uri> symbolFiles;

  /// Concrete class names to hide/exclude from the imports.
  final List<String> hide;

  const SymbolImports({
    this.symbolFiles = const [],
    this.hide = const [],
  });
}

/// Custom nullability annotations configuration.
final class NullabilityAnnotations {
  /// Fully-qualified class names of custom `@NonNull` annotations.
  final List<String> nonNull;

  /// Fully-qualified class names of custom `@Nullable` annotations.
  final List<String> nullable;

  const NullabilityAnnotations({
    this.nonNull = const [],
    this.nullable = const [],
  });
}

/// Configuration for outputting generated Dart code and symbol files.
final class Output {
  /// Dart output configuration (path and layout structure).
  final DartCodeOutput dart;

  /// Symbol file output configuration (`symbols.yaml`).
  ///
  /// If `null`, symbol file generation (`symbols.yaml`) is skipped.
  final SymbolsOutput? symbols;

  /// Common header text prepended to generated Dart files.
  final String preamble;

  /// Whether to generate stubs for unincluded dependent classes.
  final bool generateStubs;

  /// Whether to format the generated Dart code with `dart format`.
  final bool format;

  const Output({
    required this.dart,
    this.symbols,
    this.preamble = '',
    this.generateStubs = true,
    this.format = true,
  });
}

/// Configuration for input Java source files, classpaths, and SDK dependencies.
final class Input {
  /// Directories to search for Java source files.
  final List<Uri> sourcePath;

  /// Classpaths/JARs to search for compiled Java classes and dependencies.
  final List<Uri> classPath;

  /// Fully-qualified class or package names to generate bindings for.
  List<String> classes;

  /// Extra arguments passed to the summarizer tool.
  final List<String> extraArgs;

  /// Working directory for running the summarizer tool.
  final Uri workingDirectory;

  /// Backend engine used to generate summaries.
  ///
  /// If `null`, the summarizer tool defaults to auto-detection (preferring
  /// `doclet` for source files and falling back to `asm` for compiled classes).
  final SummarizerBackend? backend;

  /// Configuration for downloading dependencies using Maven.
  ///
  /// If `null`, no dependencies are downloaded using Maven.
  final MavenDownloads? mavenDownloads;

  /// Configuration for Android SDK libraries and Gradle dependency resolution.
  ///
  /// If `null`, Android SDK library search and Gradle dependency resolution are
  /// disabled.
  final AndroidSdk? androidSdk;

  /// Command used to run the API summarizer.
  ///
  /// This should only be used if the system uses a prebuilt `ApiSummarizer.jar`
  /// file. If provided, building ApiSummarizer using Gradle is skipped and this
  /// command is used directly to invoke the summarizer.
  final String? summarizerCommand;

  Input({
    this.sourcePath = const [],
    this.classPath = const [],
    required this.classes,
    this.extraArgs = const [],
    Uri? workingDirectory,
    this.backend,
    this.mavenDownloads,
    this.androidSdk,
    this.summarizerCommand,
  }) : workingDirectory = workingDirectory ?? Uri.directory('.') {
    for (final className in classes) {
      _validateClassName(className);
    }
  }
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

/// Configuration for JNIgen binding generation.
final class JniGenerator {
  JniGenerator({
    required this.input,
    required this.output,
    this.imports = const SymbolImports(),
    this.nullability = const NullabilityAnnotations(),
    this.visitors = const [],
    this.customClassBody = const {},
  });

  /// Input source paths, classpaths, target classes, and SDK dependencies.
  final Input input;

  /// Output destination and file settings (Dart code, symbol files, preamble).
  final Output output;

  /// External symbol file imports for cross-package type sharing.
  final SymbolImports imports;

  /// Custom nullability annotation configuration.
  final NullabilityAnnotations nullability;

  /// AST visitors for filtering, renaming, and AST transformation passes.
  final List<j_ast.Visitor> visitors;

  /// Custom code that is added to the end of the class body with the specified
  /// binary name.
  ///
  /// Used for testing package:jnigen.
  final Map<String, String> customClassBody;

  late final Map<String, ClassDecl> _importedClasses;

  /// Directory containing the YAML configuration file.
  ///
  /// `null` if the configuration was not loaded from a YAML configuration file.
  Uri? get configRoot => _configRoot;
  Uri? _configRoot;

  static final _levels = Map.fromEntries(
      Level.LEVELS.map((l) => MapEntry(l.name.toLowerCase(), l)));

  static JniGenerator parseArgs(List<String> args) {
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

    Uri? getSdkRoot() {
      final root = prov.getPath(_Props.androidSdkRoot);
      if (root != null) return root;
      final envVar = Platform.environment['ANDROID_SDK_ROOT'];
      if (envVar != null) return Uri.directory(envVar);
      return null;
    }

    Level logLevelFromString(String? levelName) {
      if (levelName == null) return Level.INFO;
      final level = _levels[levelName.toLowerCase()];
      if (level == null) {
        throw ConfigException('Not a valid logging level: $levelName');
      }
      return level;
    }

    final logLevelName = prov.getOneOf(
      _Props.logLevel,
      _levels.keys.toSet(),
    );
    if (logLevelName != null) {
      setLoggingLevel(logLevelFromString(logLevelName));
    }

    final configRoot = prov.getConfigRoot();
    Uri resolveFromConfigRoot(Uri reference) =>
        configRoot?.resolveUri(reference) ?? reference;

    final config = JniGenerator(
      input: Input(
        sourcePath: prov.getPathList(_Props.sourcePath) ?? const [],
        classPath: prov.getPathList(_Props.classPath) ?? const [],
        classes: must(prov.getStringList, [], _Props.classes),
        extraArgs: prov.getStringList(_Props.summarizerArgs) ?? const [],
        backend: getSummarizerBackend(prov.getString(_Props.backend), null),
        workingDirectory: prov.getPath(_Props.summarizerWorkingDir),
        summarizerCommand: prov.getString(_Props.summarizerCommand),
        mavenDownloads: prov.hasValue(_Props.mavenDownloads)
            ? MavenDownloads(
                sourceDeps: prov.getStringList(_Props.sourceDeps) ?? const [],
                sourceDir: prov.getPath(_Props.mavenSourceDir) ??
                    resolveFromConfigRoot(MavenDownloads.defaultMavenSourceDir),
                jarOnlyDeps: prov.getStringList(_Props.jarOnlyDeps) ?? const [],
                jarDir: prov.getPath(_Props.mavenJarDir) ??
                    resolveFromConfigRoot(MavenDownloads.defaultMavenJarDir),
              )
            : null,
        androidSdk: prov.hasValue(_Props.androidSdkConfig)
            ? AndroidSdk(
                versions: prov
                    .getStringList(_Props.androidSdkVersions)
                    ?.map(int.parse)
                    .toList(),
                sdkRoot: getSdkRoot(),
                addGradleDeps: prov.getBool(_Props.addGradleDeps) ?? false,
                addGradleSources:
                    prov.getBool(_Props.addGradleSources) ?? false,
                androidExample: prov.getPath(_Props.androidExample) ??
                    resolveFromConfigRoot(Uri.directory('.')),
              )
            : null,
      ),
      output: Output(
        dart: DartCodeOutput(
          path: must(prov.getPath, Uri.parse('.'), _Props.dartRoot),
          structure: getOutputStructure(
            prov.getString(_Props.outputStructure),
            OutputStructure.packageStructure,
          ),
        ),
        symbols: prov.hasValue(_Props.symbolsOutputConfig)
            ? SymbolsOutput(
                must(prov.getPath, Uri.parse('.'), _Props.symbolsOutputConfig),
              )
            : null,
        preamble: prov.getString(_Props.preamble) ?? '',
        generateStubs: prov.getBool(_Props.generateStubs) ?? true,
        format: prov.getBool(_Props.format) ?? true,
      ),
      imports: SymbolImports(
        symbolFiles: prov.getPathList(_Props.import) ?? const [],
        hide: prov.getStringList(_Props.hide) ?? const [],
      ),
      nullability: NullabilityAnnotations(
        nonNull: prov.hasValue(_Props.nonNullAnnotations)
            ? (prov.getStringList(_Props.nonNullAnnotations) ?? const [])
            : const [],
        nullable: prov.hasValue(_Props.nullableAnnotations)
            ? (prov.getStringList(_Props.nullableAnnotations) ?? const [])
            : const [],
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

extension JniGeneratorInternal on JniGenerator {
  Map<String, ClassDecl> get importedClasses => _importedClasses;

  Future<void> importClasses() async {
    _importedClasses = {};
    for (final import in [
      // Implicitly importing package:jni symbols.
      Uri.parse('package:jni/jni_symbols.yaml'),
      ...imports.symbolFiles,
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
          if (imports.hide.contains(binaryName)) {
            continue;
          }
          final decl = classEntry.value as YamlMap;
          if (_importedClasses.containsKey(binaryName)) {
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
              final ReferredType type;
              if ((e.value as String) == 'DECLARED') {
                type = DeclaredType(binaryName: boundName);
              } else {
                type = TypeVar(name: boundName);
              }
              return type;
            }).toList();
            classDecl.allTypeParams.add(
              TypeParam(name: typeParamName, bounds: bounds),
            );
          }
          classDecl.methodNumsAfterRenaming =
              (decl['methods'] as YamlMap?)?.cast() ?? {};
          _importedClasses[binaryName] = classDecl;
        }
      }
    }
  }
}

class _Props {
  static const summarizer = 'summarizer';
  static const summarizerArgs = '$summarizer.extra_args';
  static const summarizerWorkingDir = '$summarizer.working_dir';
  static const summarizerCommand = '$summarizer.command';
  static const backend = '$summarizer.backend';

  static const sourcePath = 'source_path';
  static const classPath = 'class_path';
  static const classes = 'classes';

  static const import = 'import';
  static const hide = 'hide';
  static const outputConfig = 'output';
  static const dartCodeOutputConfig = '$outputConfig.dart';
  static const symbolsOutputConfig = '$outputConfig.symbols';
  static const dartRoot = '$dartCodeOutputConfig.path';
  static const outputStructure = '$dartCodeOutputConfig.structure';
  static const preamble = 'preamble';
  static const logLevel = 'log_level';
  static const generateStubs = 'generate_stubs';
  static const format = 'format';

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
