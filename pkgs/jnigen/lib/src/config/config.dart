// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/src/elements/elements.dart';

import 'yaml_reader.dart';
import 'filters.dart';

import 'package:logging/logging.dart';

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
/// If [includeSources] is true, `jnigen` searches for Android SDK sources
/// as well in the SDK directory and adds them to the source path.
///
/// If [addGradleDeps] is true, a gradle stub is run in order to collect the
/// actual compile classpath of the `android/` subproject.
/// This will fail if there was no previous build of the project, or if a
/// `clean` task was run either through flutter or gradle wrapper. In such case,
/// it's required to run `flutter build apk` & retry running `jnigen`.
///
/// A configuration is invalid if [versions] is unspecified or empty, and
/// [addGradleDeps] is also false. If [sdkRoot] is not specified but versions is
/// specified, an attempt is made to find out SDK installation directory using
/// environment variable `ANDROID_SDK_ROOT` if it's defined, else an error
/// will be thrown.
class AndroidSdkConfig {
  AndroidSdkConfig({
    this.versions,
    this.sdkRoot,
    this.includeSources = false,
    this.addGradleDeps = false,
    this.androidExample,
  }) {
    if (versions != null && sdkRoot == null) {
      throw ArgumentError("No SDK Root specified for finding Android SDK "
          "from version priority list $versions");
    }
    if (versions == null && !addGradleDeps) {
      throw ArgumentError('Neither any SDK versions nor `addGradleDeps` '
          'is specified. Unable to find Android libraries.');
    }
  }

  /// Versions of android SDK to search for, in decreasing order of preference.
  List<int>? versions;

  /// Root of Android SDK installation, this should be normally given on
  /// command line or by setting `ANDROID_SDK_ROOT`, since this varies from
  /// system to system.
  String? sdkRoot;

  /// Include downloaded android SDK sources in source path.
  bool includeSources;

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

  /// Relative path to example application which will be used to determine
  /// compile time classpath using a gradle stub. For most Android plugin
  /// packages, 'example' will be the name of example application created inside
  /// the package. This example should be built once before using this option,
  /// so that gradle would have resolved all the dependencies.
  String? androidExample;
}

/// Additional options to pass to the summary generator component.
class SummarizerOptions {
  SummarizerOptions(
      {this.extraArgs = const [], this.workingDirectory, this.backend});
  List<String> extraArgs;
  Uri? workingDirectory;
  String? backend;
}

/// Backend for reading summary of Java libraries
enum SummarizerBackend {
  /// Generate Java API summaries using JARs in provided `classPath`s.
  asm,

  /// Generate Java API summaries using source files in provided `sourcePath`s.
  doclet,
}

class CCodeOutputConfig {
  CCodeOutputConfig({
    required this.path,
    required this.libraryName,
    this.subdir,
  });

  /// Directory to write JNI C Bindings, in C+Dart mode.
  ///
  /// Strictly speaking, this is the root to place the `CMakeLists.txt` file
  /// for the generated C bindings. It may be desirable to use the [subdir]
  /// options to write C files to a subdirectory of [path]. For instance,
  /// when generated code is required to be in `third_party` directory.
  Uri path;

  /// Name of generated library in CMakeLists.txt configuration.
  ///
  /// This will also determine the name of shared object file.
  String libraryName;

  /// Subfolder relative to [path] to write generated C code.
  String? subdir;
}

class DartCodeOutputConfig {
  // TODO(#90): Support output_structure = single_file | package_structure.

  DartCodeOutputConfig({required this.path});

  /// Path to write generated Dart bindings.
  Uri path;
}

class OutputConfig {
  // TODO(#60): Add bindings_type = dart_only | c_based.

  OutputConfig({required this.cConfig, required this.dartConfig});
  DartCodeOutputConfig dartConfig;
  CCodeOutputConfig cConfig;
}

class BindingExclusions {
  BindingExclusions({this.methods, this.fields, this.classes});
  MethodFilter? methods;
  FieldFilter? fields;
  ClassFilter? classes;
}

/// Configuration for jnigen binding generation.
class Config {
  Config({
    required this.outputConfig,
    required this.classes,
    this.exclude,
    this.sourcePath,
    this.classPath,
    this.preamble,
    this.importMap,
    this.androidSdkConfig,
    this.mavenDownloads,
    this.summarizerOptions,
    this.logLevel = Level.INFO,
    this.dumpJsonTo,
  });

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

  /// Methods and fields to be excluded from generated bindings.
  final BindingExclusions? exclude;

  /// Paths to search for java source files.
  ///
  /// If a source package is downloaded through [mavenDownloads] option,
  /// the corresponding source folder is automatically added and does not
  /// need to be explicitly specified.
  List<Uri>? sourcePath;

  /// class path for scanning java libraries. If [backend] is `asm`, the
  /// specified classpath is used to search for [classes], otherwise it's
  /// merely used by the doclet API to find transitively referenced classes,
  /// but not the specified classes / packages themselves.
  List<Uri>? classPath;

  /// Common text to be pasted on top of generated C and Dart files.
  final String? preamble;

  /// Additional java package -> dart package mappings (Experimental).
  ///
  /// a mapping com.abc.package -> 'package:my_package.dart/my_import.dart'
  /// in this configuration suggests that any reference to a type from
  /// com.abc.package shall resolve to an import of 'package:my_package.dart'.
  ///
  /// This can be as granular
  /// `com.abc.package.Class -> 'package:abc/abc.dart'`
  /// or coarse
  /// `com.abc.package` -> 'package:abc/abc.dart'`
  final Map<String, String>? importMap;

  /// Configuration to search for Android SDK libraries (Experimental).
  final AndroidSdkConfig? androidSdkConfig;

  /// Configuration for auto-downloading JAR / source packages using maven,
  /// along with their transitive dependencies.
  final MavenDownloads? mavenDownloads;

  /// Additional options for the summarizer component
  final SummarizerOptions? summarizerOptions;

  /// Log verbosity. The possible values in decreasing order of verbosity
  /// are verbose > debug > info > warning > error. Defaults to [LogLevel.info]
  Level logLevel = Level.INFO;

  /// File to which JSON summary is written before binding generation.
  final String? dumpJsonTo;

  static final _levels = Map.fromEntries(
      Level.LEVELS.map((l) => MapEntry(l.name.toLowerCase(), l)));
  static List<Uri>? _toUris(List<String>? paths) =>
      paths?.map(Uri.file).toList();

  static Config parseArgs(List<String> args) {
    final prov = YamlReader.parseArgs(args);
    final List<String> missingValues = [];
    T must<T>(T? Function(String) f, T ifNull, String property) {
      final res = f(property);
      if (res == null) {
        missingValues.add(property);
        return ifNull;
      }
      return res;
    }

    Uri? directoryUri(String? path) =>
        path != null ? Uri.directory(path) : null;

    MemberFilter<T>? regexFilter<T extends ClassMember>(String property) {
      final exclusions = prov.getStringList(property);
      if (exclusions == null) return null;
      final List<MemberFilter<T>> filters = [];
      for (var exclusion in exclusions) {
        final split = exclusion.split('#');
        if (split.length != 2) {
          throw FormatException('Error parsing exclusion: "$exclusion": '
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
        throw ConfigError('Not a valid logging level: $levelName');
      }
      return level;
    }

    final config = Config(
      sourcePath: _toUris(prov.getStringList(_Props.sourcePath)),
      classPath: _toUris(prov.getStringList(_Props.classPath)),
      classes: must(prov.getStringList, [], _Props.classes),
      summarizerOptions: SummarizerOptions(
        extraArgs: prov.getStringList(_Props.summarizerArgs) ?? const [],
        backend: prov.getString(_Props.backend),
        workingDirectory:
            directoryUri(prov.getString(_Props.summarizerWorkingDir)),
      ),
      exclude: BindingExclusions(
        methods: regexFilter<Method>(_Props.excludeMethods),
        fields: regexFilter<Field>(_Props.excludeFields),
      ),
      outputConfig: OutputConfig(
        cConfig: CCodeOutputConfig(
          libraryName: must(prov.getString, '', _Props.libraryName),
          path: Uri.directory(must(prov.getString, '.', _Props.cRoot)),
          subdir: prov.getString(_Props.cSubdir),
        ),
        dartConfig: DartCodeOutputConfig(
          path: Uri.directory(must(prov.getString, '.', _Props.dartRoot)),
        ),
      ),
      preamble: prov.getString(_Props.preamble),
      importMap: prov.getStringMap(_Props.importMap),
      mavenDownloads: prov.hasValue(_Props.mavenDownloads)
          ? MavenDownloads(
              sourceDeps: prov.getStringList(_Props.sourceDeps) ?? const [],
              sourceDir: prov.getString(_Props.mavenSourceDir) ??
                  MavenDownloads.defaultMavenSourceDir,
              jarOnlyDeps: prov.getStringList(_Props.jarOnlyDeps) ?? const [],
              jarDir: prov.getString(_Props.mavenJarDir) ??
                  MavenDownloads.defaultMavenJarDir,
            )
          : null,
      androidSdkConfig: prov.hasValue(_Props.androidSdkConfig)
          ? AndroidSdkConfig(
              versions: prov
                  .getStringList(_Props.androidSdkVersions)
                  ?.map(int.parse)
                  .toList(),
              sdkRoot: getSdkRoot(),
              includeSources:
                  prov.getBool(_Props.includeAndroidSources) ?? false,
              addGradleDeps: prov.getBool(_Props.addGradleDeps) ?? false,
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

  static const importMap = 'import_map';
  static const outputConfig = 'output';
  static const cCodeOutputConfig = '$outputConfig.c';
  static const dartCodeOutputConfig = '$outputConfig.dart';
  static const cRoot = '$cCodeOutputConfig.path';
  static const cSubdir = '$cCodeOutputConfig.subdir';
  static const dartRoot = '$dartCodeOutputConfig.path';
  static const libraryName = '$cCodeOutputConfig.library_name';
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
  static const includeAndroidSources = '$androidSdkConfig.include_sources';
  static const addGradleDeps = '$androidSdkConfig.add_gradle_deps';
  static const androidExample = '$androidSdkConfig.android_example';
}
