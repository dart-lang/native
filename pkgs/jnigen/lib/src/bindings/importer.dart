// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../config/config_types.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import '../util/find_package.dart';
import 'visitor.dart';

/// Modify this when symbols file format changes according to pub_semver.
final jsonVersion = Version(1, 0, 0);

/// Imports the stability information from the previous runs of JNIgen from this
/// and other packages.
class Importer extends ElementVisitor<Classes, Future<void>>
    with TopLevelVisitor {
  @override
  final stage = GenerationStage.importer;

  final Config config;

  Importer(this.config);

  @override
  Future<void> visit(Classes node) async {
    for (final import in [
      // Implicitly importing package:jni symbols.
      Uri.parse('package:jni/jni_symbols.yaml'),
      ...?config.imports,
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
      if (!VersionConstraint.compatibleWith(jsonVersion).allows(version)) {
        log.fatal('"$import" is version "$version" which is not compatible with'
            'the current JNIgen symbols version $jsonVersion');
      }
      final files = yaml['files'] as YamlMap;
      for (final entry in files.entries) {
        final filePath = entry.key as String;
        final dartFile = DartFile('$importPath/$filePath', {});
        final classes = entry.value as YamlMap;
        for (final classEntry in classes.entries) {
          final binaryName = classEntry.key as String;
          final decl = classEntry.value as YamlMap;
          if (node.importedClasses.containsKey(binaryName)) {
            log.fatal(
              'Re-importing "$binaryName" in "$import".\n'
              'Try hiding the class in import.',
            );
          }
          final classDecl = ClassDecl(
            declKind: DeclKind.classKind,
            binaryName: binaryName,
          )
            ..isImported = true
            ..file = dartFile
            ..finalName = decl['name'] as String
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
          node.importedClasses[binaryName] = classDecl;
        }
      }

      if (node.importedClasses.keys
          .toSet()
          .intersection(node.decls.keys.toSet())
          .isNotEmpty) {
        log.fatal(
          'Trying to re-import the generated classes.\n'
          'Try hiding the class(es) in import.',
        );
      }

      for (final className in node.importedClasses.keys) {
        log.finest('Imported $className successfully.');
      }
    }
  }
}
