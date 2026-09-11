// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;

/// Resolves paths, packageRoot, configDir, and output redirection for
/// migration.
class PathResolver {
  final File yamlConfigFile;
  final File outputDartFile;

  late final String origConfigPath;
  late final String configDir;
  late final Directory packageRoot;

  PathResolver({required this.yamlConfigFile, required this.outputDartFile}) {
    origConfigPath = _resolveConfigPath(yamlConfigFile.path);
    configDir = p.dirname(origConfigPath);
    packageRoot = _findPackageRoot(configDir);
  }

  /// Whether configDir is the same directory as packageRoot.
  bool get isConfigDirAtPackageRoot =>
      p.normalize(configDir) == p.normalize(packageRoot.path);

  String get _effectiveOutputDartDir {
    final normalizedYaml = p.normalize(p.absolute(yamlConfigFile.path));
    final parts = p.split(normalizedYaml);
    final migrateYamlIdx = _findSubsequence(parts, ['test', 'migrate', 'yaml']);
    if (migrateYamlIdx != -1) {
      final ffigenRoot = p.joinAll(parts.sublist(0, migrateYamlIdx));
      return p.join(ffigenRoot, 'test', 'migrate', 'dart');
    }
    return outputDartFile.parent.path;
  }

  /// Default expression for `packageRoot` in `getConfig`.
  String get packageRootDefaultExpr {
    final rel = p.relative(packageRoot.path, from: _effectiveOutputDartDir);
    final posixRel = p.posix.normalize(p.split(rel).join('/'));
    if (posixRel == '.' || posixRel.isEmpty) {
      return "Platform.script.resolve('./')";
    }
    return "Platform.script.resolve('$posixRel/')";
  }

  /// Expression for `configDir` relative to `packageRoot`.
  String get configDirExpr {
    if (isConfigDirAtPackageRoot) {
      return 'packageRoot';
    }
    final rel = p.relative(configDir, from: packageRoot.path);
    final posixRel = p.posix.normalize(p.split(rel).join('/'));
    return "packageRoot.resolve('$posixRel/')";
  }

  /// Emits a Dart expression evaluating to a `Uri` for a path in YAML.
  String emitPath(String rawPath) {
    if (rawPath.startsWith(r'$XCODE/')) {
      final sub = p.posix.normalize(p.split(rawPath.substring(7)).join('/'));
      return "xcodeUri.resolve('$sub')";
    }
    if (rawPath == r'$XCODE') return 'xcodeUri';
    if (rawPath.startsWith(r'$IOS_SDK/')) {
      final sub = p.posix.normalize(p.split(rawPath.substring(9)).join('/'));
      return "iosSdkUri.resolve('$sub')";
    }
    if (rawPath == r'$IOS_SDK') return 'iosSdkUri';
    if (rawPath.startsWith(r'$MACOS_SDK/')) {
      final sub = p.posix.normalize(p.split(rawPath.substring(11)).join('/'));
      return "macSdkUri.resolve('$sub')";
    }
    if (rawPath == r'$MACOS_SDK') return 'macSdkUri';

    if (rawPath.startsWith('package:')) {
      final uri = Uri.parse(rawPath);
      final rest = uri.pathSegments.skip(1).join('/');
      final localLibFile = File(p.join(packageRoot.path, 'lib', rest));
      if (localLibFile.existsSync()) {
        final posixRest = p.posix.normalize(p.split(rest).join('/'));
        return "packageRoot.resolve('lib/$posixRest')";
      }
      return "Uri.parse('$rawPath')";
    }
    if (rawPath.startsWith('http:') || rawPath.startsWith('https:')) {
      return "Uri.parse('$rawPath')";
    }
    if (p.isAbsolute(rawPath)) {
      return "Uri.file('$rawPath')";
    }
    final posixPath = p.posix.normalize(p.split(rawPath).join('/'));
    if (isConfigDirAtPackageRoot) {
      return "packageRoot.resolve('$posixPath')";
    }
    return "configDir.resolve('$posixPath')";
  }

  /// Emits a compiler option, resolving `-I` relative paths against configDir
  /// or packageRoot.
  String emitCompilerOption(String opt) {
    if (!opt.startsWith('-I')) {
      return "'$opt'";
    }
    final incPath = opt.substring(2);
    if (!p.isRelative(incPath)) {
      return "'$opt'";
    }

    final posixInc = p.posix.normalize(p.split(incPath).join('/'));
    final resolvedFromPackage = p.normalize(p.join(packageRoot.path, incPath));
    final resolvedFromConfig = p.normalize(p.join(configDir, incPath));

    final expr =
        isConfigDirAtPackageRoot ||
            (FileSystemEntity.typeSync(resolvedFromPackage) !=
                    FileSystemEntityType.notFound &&
                FileSystemEntity.typeSync(resolvedFromConfig) ==
                    FileSystemEntityType.notFound)
        ? "packageRoot.resolve('$posixInc').toFilePath()"
        : "configDir.resolve('$posixInc').toFilePath()";

    if ("'-I\${$expr}',".length + 8 > 80) {
      return "// ignore: lines_longer_than_80_chars\n'-I\${$expr}'";
    }
    return "'-I\${$expr}'";
  }

  static Directory _findPackageRoot(String startDir) {
    var dir = Directory(startDir);
    while (true) {
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return Directory(startDir);
  }

  static String _resolveConfigPath(String yamlFilePath) {
    final normalized = p.normalize(p.absolute(yamlFilePath));
    final parts = p.split(normalized);
    final migrateYamlIdx = _findSubsequence(parts, ['test', 'migrate', 'yaml']);
    if (migrateYamlIdx == -1) {
      return normalized;
    }

    final ffigenRoot = p.joinAll(parts.sublist(0, migrateYamlIdx));
    final repoRoot = p.normalize(p.join(ffigenRoot, '..', '..'));
    final fileName = p.basename(yamlFilePath);

    return _findOriginalTestPath(fileName, repoRoot, ffigenRoot);
  }

  static int _findSubsequence(List<String> list, List<String> sub) {
    for (var i = 0; i <= list.length - sub.length; i++) {
      var match = true;
      for (var j = 0; j < sub.length; j++) {
        if (list[i + j] != sub[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }

  static String _findOriginalTestPath(
    String fileName,
    String repoRoot,
    String ffigenRoot,
  ) {
    final baseName = fileName.replaceAll('.yaml', '');

    if (baseName.startsWith('example_shared_bindings_')) {
      final sub = baseName.replaceFirst('example_shared_bindings_', '');
      return p.join(
        ffigenRoot,
        'example',
        'shared_bindings',
        'ffigen_configs',
        '$sub.yaml',
      );
    }
    if (baseName.startsWith('example_')) {
      final sub = baseName.replaceFirst('example_', '').replaceAll('_', '-');
      final candidates = [
        p.join(
          ffigenRoot,
          'example',
          baseName.replaceFirst('example_', ''),
          'config.yaml',
        ),
        p.join(ffigenRoot, 'example', sub, 'config.yaml'),
      ];
      for (final c in candidates) {
        if (Directory(p.dirname(c)).existsSync()) return c;
      }
    }
    if (baseName.startsWith('header_parser_')) {
      final sub = baseName.replaceFirst('header_parser_', '');
      return p.join(ffigenRoot, 'test', 'header_parser_tests', '$sub.yaml');
    }
    if (baseName.startsWith('native_objc_')) {
      final sub = baseName.replaceFirst('native_objc_', '');
      return p.join(
        ffigenRoot,
        'test',
        'native_objc_test',
        '${sub}_config.yaml',
      );
    }
    if (baseName.startsWith('native_cpp_')) {
      final sub = baseName.replaceFirst('native_cpp_', '');
      return p.join(
        ffigenRoot,
        'test',
        'native_cpp_test',
        '${sub}_config.yaml',
      );
    }
    if (baseName == 'native_test_config') {
      return p.join(ffigenRoot, 'test', 'native_test', 'config.yaml');
    }
    if (baseName == 'tool_libclang') {
      return p.join(ffigenRoot, 'tool', 'libclang_config.yaml');
    }
    if (baseName.startsWith('objc_pkg_ffigen_')) {
      final sub = baseName.replaceFirst('objc_pkg_ffigen_', '');
      return p.join(repoRoot, 'pkgs', 'objective_c', '$sub.yaml');
    }
    if (baseName == 'jni_pkg_ffigen_exts') {
      return p.join(repoRoot, 'pkgs', 'jni', 'ffigen_exts.yaml');
    }
    if (baseName == 'jni_pkg_ffigen') {
      return p.join(repoRoot, 'pkgs', 'jni', 'ffigen.yaml');
    }
    if (baseName.startsWith('hooks_')) {
      final sub = baseName.replaceFirst('hooks_', '');
      return p.join(
        repoRoot,
        'pkgs',
        'hooks',
        'example',
        'build',
        sub,
        'ffigen.yaml',
      );
    }
    return p.join(ffigenRoot, 'test', 'migrate', 'yaml', fileName);
  }
}
