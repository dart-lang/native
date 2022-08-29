// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni_gen/src/elements/elements.dart';

import 'yaml_reader.dart';
import 'filters.dart';

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
/// If [sdkRoot] is not provided, an attempt is made to discover it
/// using the environment variable `ANDROID_SDK_ROOT`, which will fail if the
/// environment variable is not set.
///
/// If [includeSources] is true, `jni_gen` searches for Android SDK sources
/// as well in the SDK directory and adds them to the source path.
class AndroidSdkConfig {
  AndroidSdkConfig(
      {required this.versions, this.sdkRoot, this.includeSources = false});
  List<int> versions;
  String? sdkRoot;
  bool includeSources;
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

class BindingExclusions {
  BindingExclusions({this.methods, this.fields, this.classes});
  MethodFilter? methods;
  FieldFilter? fields;
  ClassFilter? classes;
}

/// Configuration for jni_gen binding generation.
class Config {
  Config({
    required this.classes,
    required this.libraryName,
    required this.cRoot,
    required this.dartRoot,
    this.exclude,
    this.sourcePath,
    this.classPath,
    this.preamble,
    this.importMap,
    this.androidSdkConfig,
    this.mavenDownloads,
    this.summarizerOptions,
    this.dumpJsonTo,
  });

  /// List of classes or packages for which bindings have to be generated.
  ///
  /// The names must be fully qualified, and it's assumed that the directory
  /// structure corresponds to package naming. For example, com.abc.MyClass
  /// should be resolvable as `com/abc/MyClass.java` from one of the provided
  /// source paths. Same applies if ASM backend is used, except that the file
  /// name suffix is `.class`.
  List<String> classes;

  /// Name of generated library in CMakeLists.txt configuration.
  ///
  /// This will also determine the name of shared object file.
  String libraryName;

  /// Directory to write JNI C Bindings.
  Uri cRoot;

  /// Directory to write Dart bindings.
  Uri dartRoot;

  /// Methods and fields to be excluded from generated bindings.
  BindingExclusions? exclude;

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
  String? preamble;

  /// Additional java package -> dart package mappings (Experimental).
  Map<String, String>? importMap;

  /// Configuration to search for Android SDK libraries (Experimental).
  AndroidSdkConfig? androidSdkConfig;

  /// Configuration for auto-downloading JAR / source packages using maven,
  /// along with their transitive dependencies.
  MavenDownloads? mavenDownloads;

  /// Additional options for the summarizer component
  SummarizerOptions? summarizerOptions;

  String? dumpJsonTo;

  static Uri? _toDirUri(String? path) =>
      path != null ? Uri.directory(path) : null;
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

    MemberFilter<T>? regexFilter<T extends ClassMember>(String property) {
      final exclusions = prov.getStringList(property);
      if (exclusions == null) return null;
      final List<MemberFilter<T>> filters = [];
      for (var exclusion in exclusions) {
        final split = exclusion.split('#');
        if (split.length != 2) {
          throw FormatException('Error parsing exclusion: "$exclusion"; '
              'expected to be in binaryName#member format.');
        }
        filters.add(MemberNameFilter<T>.exclude(
          RegExp(split[0]),
          RegExp(split[1]),
        ));
      }
      return CombinedMemberFilter<T>(filters);
    }

    String getSdkRoot() {
      final root = prov.getString(_Props.androidSdkRoot) ??
          Platform.environment['ANDROID_SDK_ROOT'];
      if (root == null) {
        missingValues.add(_Props.androidSdkRoot);
        return '?';
      }
      return root;
    }

    final config = Config(
      sourcePath: _toUris(prov.getStringList(_Props.sourcePath)),
      classPath: _toUris(prov.getStringList(_Props.classPath)),
      classes: must(prov.getStringList, [], _Props.classes),
      summarizerOptions: SummarizerOptions(
        extraArgs: prov.getStringList(_Props.summarizerArgs) ?? const [],
        backend: prov.getString(_Props.backend),
        workingDirectory:
            _toDirUri(prov.getString(_Props.summarizerWorkingDir)),
      ),
      exclude: BindingExclusions(
        methods: regexFilter<Method>(_Props.excludeMethods),
        fields: regexFilter<Field>(_Props.excludeFields),
      ),
      cRoot: Uri.directory(must(prov.getString, '', _Props.cRoot)),
      dartRoot: Uri.directory(must(prov.getString, '', _Props.dartRoot)),
      preamble: prov.getString(_Props.preamble),
      libraryName: must(prov.getString, '', _Props.libraryName),
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
              versions: must<List<String>>(
                      prov.getStringList, [], _Props.androidSdkVersions)
                  .map(int.parse)
                  .toList(),
              sdkRoot: getSdkRoot(),
              includeSources:
                  prov.getBool(_Props.includeAndroidSources) ?? false,
            )
          : null,
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
  static const cRoot = 'c_root';
  static const dartRoot = 'dart_root';
  static const preamble = 'preamble';
  static const libraryName = 'library_name';

  static const mavenDownloads = 'maven_downloads';
  static const sourceDeps = '$mavenDownloads.source_deps';
  static const mavenSourceDir = '$mavenDownloads.source_dir';
  static const jarOnlyDeps = '$mavenDownloads.jar_only_deps';
  static const mavenJarDir = '$mavenDownloads.jar_dir';

  static const androidSdkConfig = 'android_sdk_config';
  static const androidSdkRoot = '$androidSdkConfig.sdk_root';
  static const androidSdkVersions = '$androidSdkConfig.versions';
  static const includeAndroidSources = '$androidSdkConfig.include_sources';
}
