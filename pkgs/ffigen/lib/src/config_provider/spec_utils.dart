// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/pattern.dart' as quiver;
import 'package:yaml/yaml.dart';

import '../code_generator.dart';
import '../code_generator/scope.dart';
import '../header_parser/type_extractor/cxtypekindmap.dart';
import '../strings.dart' as strings;
import 'config.dart';
import 'config_types.dart';
import 'utils.dart';

Map<String, LibraryImport> libraryImportsExtractor(
  Map<String, String>? typeMap,
) {
  final resultMap = <String, LibraryImport>{};
  if (typeMap != null) {
    for (final kv in typeMap.entries) {
      resultMap[kv.key] = LibraryImport(kv.key, kv.value);
    }
  }
  return resultMap;
}

void loadImportedTypes(
  YamlMap fileConfig,
  Map<String, ImportedType> usrTypeMappings,
  LibraryImport libraryImport,
) {
  final symbols = fileConfig['symbols'] as YamlMap;
  for (final key in symbols.keys) {
    final usr = key as String;
    final value = symbols[usr]! as YamlMap;
    final name = value[strings.name] as String;
    final dartName = (value[strings.dartName] as String?) ?? name;
    usrTypeMappings[usr] = ImportedType(
      libraryImport,
      name,
      dartName,
      name,
      importedDartType: true,
    );
  }
}

Map<String, ImportedType> symbolFileImportExtractor(
  Logger logger,
  List<String> yamlConfig,
  Map<String, LibraryImport> libraryImports,
  String? configFileName,
  PackageConfig? packageConfig,
) {
  final uris = yamlConfig.map((item) {
    if (item.startsWith('package:')) {
      return Uri.parse(item);
    }
    return Uri.file(normalizePath(item, configFileName));
  });
  try {
    return _loadSymbolFiles(
      uris,
      packageConfig: packageConfig,
      libraryImports: libraryImports,
    );
  } on FormatException catch (e) {
    logger.severe(e.message);
    exit(1);
  }
}

Map<String, ImportedType> _loadSymbolFiles(
  Iterable<Uri> symbolFiles, {
  PackageConfig? packageConfig,
  Map<String, LibraryImport>? libraryImports,
}) {
  final libImports = libraryImports ?? <String, LibraryImport>{};
  final uniqueNamer = Namer({
    ...libImports.keys,
    strings.defaultSymbolFileImportPrefix,
  });
  for (final l in libImports.values) {
    uniqueNamer.markUsed(l.name);
  }
  final usrTypeMappings = <String, ImportedType>{};

  for (final uri in symbolFiles) {
    final File file;
    if (uri.isScheme('package')) {
      if (packageConfig == null) {
        throw ArgumentError(
          'packageConfig is required to resolve package: URIs.',
        );
      }
      final resolved = packageConfig.resolve(uri);
      if (resolved == null) {
        throw FormatException('Unable to resolve package URI: $uri');
      }
      file = File.fromUri(resolved);
    } else if (uri.isScheme('file') || !uri.hasScheme) {
      file = File.fromUri(uri);
    } else {
      throw FormatException('Unsupported URI scheme: ${uri.scheme}');
    }

    final yamlContent = file.readAsStringSync();
    final Object? yamlMap;
    try {
      yamlMap = loadYaml(yamlContent);
    } catch (e) {
      throw FormatException('Failed to parse YAML file $uri: $e');
    }
    if (yamlMap is! YamlMap) {
      throw FormatException('Symbol file $uri is not a valid YAML map.');
    }

    final formatVersion = yamlMap[strings.formatVersion];
    if (formatVersion is! String ||
        formatVersion.split('.')[0] !=
            strings.symbolFileFormatVersion.split('.')[0]) {
      throw FormatException(
        'Incompatible format versions for file $uri: '
        '${strings.symbolFileFormatVersion}(ours), $formatVersion(theirs).',
      );
    }

    final files = yamlMap[strings.files];
    if (files is YamlMap) {
      for (final file in files.keys) {
        final existingImports = libImports.values.where(
          (element) => element.importPath(false) == file,
        );
        if (existingImports.isEmpty) {
          final name = uniqueNamer.add(
            strings.defaultSymbolFileImportPrefix,
            SymbolKind.lib,
          );
          libImports[name] = LibraryImport(name, file as String);
        }
        final libraryImport = libImports.values.firstWhere(
          (element) => element.importPath(false) == file,
        );
        loadImportedTypes(
          files[file] as YamlMap,
          usrTypeMappings,
          libraryImport,
        );
      }
    }
  }

  return usrTypeMappings;
}

/// Returns a function suitable for use as [FfiGenerator.importType] that
/// imports declarations defined in the given [symbolFiles].
///
/// The [symbolFiles] can be `file:` URIs or `package:` URIs. [packageConfig]
/// must be provided if any of the [symbolFiles] are `package:` URIs.
///
/// Example:
///
/// ```dart
/// final config = FfiGenerator(
///   // ...
///   importType: importFromSymbolFiles([
///     Uri.file('path/to/symbols1.yaml'),
///     Uri.parse('package:other_pkg/symbols2.yaml'),
///   ], packageConfig: packageConfig),
/// );
/// ```
ImportedType? Function(Declaration) importFromSymbolFiles(
  Iterable<Uri> symbolFiles, {
  PackageConfig? packageConfig,
}) {
  final typeMap = _loadSymbolFiles(symbolFiles, packageConfig: packageConfig);
  return (Declaration decl) => decl.usr.isNotEmpty ? typeMap[decl.usr] : null;
}

/// Returns a function suitable for use as [FfiGenerator.importType] that
/// imports declarations defined in the given [symbolFile].
///
/// The [symbolFile] can be a `file:` URI or `package:` URI. [packageConfig]
/// if the [symbolFile] is a `package:` URI.
///
/// Example:
///
/// ```dart
/// final config = FfiGenerator(
///   // ...
///   importType: importFromSymbolFile(
///     Uri.file('path/to/symbols.yaml'),
///   ),
/// );
/// ```
ImportedType? Function(Declaration) importFromSymbolFile(
  Uri symbolFile, {
  PackageConfig? packageConfig,
}) => importFromSymbolFiles([symbolFile], packageConfig: packageConfig);

Map<String, List<String>> typeMapExtractor(Map<dynamic, dynamic>? yamlConfig) {
  // Key - type_name, Value - [lib, cType, dartType].
  final resultMap = <String, List<String>>{};
  final typeMap = yamlConfig;
  if (typeMap != null) {
    for (final typeName in typeMap.keys) {
      final typeConfigItem = typeMap[typeName] as Map;
      resultMap[typeName as String] = [
        typeConfigItem[strings.lib] as String,
        typeConfigItem[strings.cType] as String,
        typeConfigItem[strings.dartType] as String,
      ];
    }
  }
  return resultMap;
}

Map<String, ImportedType> makeImportTypeMapping(
  Map<String, List<String>> rawTypeMappings,
  Map<String, LibraryImport> libraryImportsMap,
) {
  final typeMappings = <String, ImportedType>{};
  for (final key in rawTypeMappings.keys) {
    final lib = rawTypeMappings[key]![0];
    final cType = rawTypeMappings[key]![1];
    final dartType = rawTypeMappings[key]![2];
    final nativeType = key;
    if (builtInLibraries.containsKey(lib)) {
      typeMappings[key] = ImportedType(
        builtInLibraries[lib]!,
        cType,
        dartType,
        nativeType,
      );
    } else if (libraryImportsMap.containsKey(lib)) {
      typeMappings[key] = ImportedType(
        libraryImportsMap[lib]!,
        cType,
        dartType,
        nativeType,
      );
    } else {
      throw Exception('Please declare $lib under library-imports.');
    }
  }
  return typeMappings;
}

Type makePointerToType(Type type, int pointerCount) {
  for (var i = 0; i < pointerCount; i++) {
    type = PointerType(type);
  }
  return type;
}

String makePostfixFromRawVarArgType(List<String> rawVarArgType) {
  return rawVarArgType
      .map(
        (e) => e
            .replaceAll('*', 'Ptr')
            .replaceAll(RegExp(r'_t$'), '')
            .replaceAll(' ', '')
            .replaceAll(RegExp('[^A-Za-z0-9_]'), ''),
      )
      .map((e) => e.length > 1 ? '${e[0].toUpperCase()}${e.substring(1)}' : e)
      .join('');
}

Type makeTypeFromRawVarArgType(
  String rawVarArgType,
  ImportedType? Function(Declaration declaration) importType,
) {
  final trimmed = rawVarArgType.trim();
  if (trimmed.isEmpty) {
    throw Exception('Cannot parse variadic argument type - $rawVarArgType.');
  }

  final firstStar = trimmed.indexOf('*');
  final String basePart;
  final int pointerCount;
  if (firstStar != -1) {
    if (!RegExp(r'^[*\s]+$').hasMatch(trimmed.substring(firstStar))) {
      throw Exception('Cannot parse variadic argument type - $rawVarArgType.');
    }
    basePart = trimmed.substring(0, firstStar).trim();
    if (basePart.isEmpty) {
      throw Exception('Cannot parse variadic argument type - $rawVarArgType.');
    }
    pointerCount = '*'.allMatches(trimmed.substring(firstStar)).length;
  } else {
    basePart = trimmed;
    pointerCount = 0;
  }

  final rawBaseType = basePart.replaceAll(RegExp(r'\s+'), ' ').trim();
  final baseType = makeBaseTypeFromRawVarArgType(rawBaseType, importType);

  return makePointerToType(baseType, pointerCount);
}

Type makeBaseTypeFromRawVarArgType(
  String rawBaseType,
  ImportedType? Function(Declaration declaration) importType,
) {
  final typeStringRegexp = RegExp(r'^[a-zA-Z0-9_ \.]+$');
  if (!typeStringRegexp.hasMatch(rawBaseType)) {
    throw Exception('Cannot parse variadic argument type - $rawBaseType.');
  }
  if (importType.call(Declaration(usr: '', originalName: rawBaseType))
      case final imported?) {
    return imported;
  } else if (cxTypeKindToImportedTypes[rawBaseType] case final type?) {
    return type;
  } else if (supportedTypedefToImportedType[rawBaseType] case final type?) {
    return type;
  } else if (suportedTypedefToSuportedNativeType[rawBaseType]
      case final type?) {
    return NativeType(type);
  } else {
    final rawVarArgTypeSplit = rawBaseType
        .split('.')
        .map((s) => s.trim())
        .toList();
    if (rawVarArgTypeSplit.any((s) => s.isEmpty)) {
      throw Exception('Cannot parse variadic argument type - $rawBaseType.');
    }
    if (rawVarArgTypeSplit.length == 1) {
      final typeName = rawVarArgTypeSplit[0];
      return SelfImportedType(typeName, typeName);
    } else if (rawVarArgTypeSplit.length == 2) {
      final lib = rawVarArgTypeSplit[0];
      final libraryImport = builtInLibraries[lib];
      if (libraryImport == null) {
        throw Exception(
          'Unknown library import: $lib. Valid built-in libraries are: '
          '${builtInLibraries.keys.join(', ')}.',
        );
      }
      final typeName = rawVarArgTypeSplit[1];
      return ImportedType(libraryImport, typeName, typeName, typeName);
    } else {
      throw Exception(
        'Invalid type $rawBaseType : Expected 0 or 1 .(dot) separators.',
      );
    }
  }
}

final _quoteMatcher = RegExp(r'''^["'](.*)["']$''', dotAll: true);
final _cmdlineArgMatcher = RegExp(r'''['"](\\"|[^"])*?['"]|[^ ]+''');
List<String> compilerOptsToList(String compilerOpts) {
  final list = <String>[];
  _cmdlineArgMatcher.allMatches(compilerOpts).forEach((element) {
    var match = element.group(0);
    if (match != null) {
      if (quiver.matchesFull(_quoteMatcher, match)) {
        match = _quoteMatcher.allMatches(match).first.group(1)!;
      }
      list.add(match);
    }
  });

  return list;
}

List<String> compilerOptsExtractor(List<String> value) {
  final list = <String>[];
  for (final el in value) {
    list.addAll(compilerOptsToList(el));
  }
  return list;
}

YamlHeaders headersExtractor(
  Logger logger,
  Map<dynamic, List<String>> yamlConfig,
  String? configFilename,
) {
  final entryPoints = <String>[];
  final includeGlobs = <quiver.Glob>[];
  for (final key in yamlConfig.keys) {
    if (key == strings.entryPoints) {
      for (final h in yamlConfig[key]!) {
        final headerGlob = normalizePath(substituteVars(h), configFilename);
        // Add file directly to header if it's not a Glob but a File.
        if (File(headerGlob).existsSync()) {
          final osSpecificPath = headerGlob;
          entryPoints.add(osSpecificPath);
          logger.fine('Adding header/file: $headerGlob');
        } else {
          final glob = Glob(headerGlob);
          for (final file in glob.listFileSystemSync(
            const LocalFileSystem(),
            followLinks: true,
          )) {
            final fixedPath = file.path;
            entryPoints.add(fixedPath);
            logger.fine('Adding header/file: $fixedPath');
          }
        }
      }
    }
    if (key == strings.includeDirectives) {
      for (final h in yamlConfig[key]!) {
        final headerGlob = normalizePath(substituteVars(h), configFilename);
        includeGlobs.add(quiver.Glob(headerGlob));
      }
    }
  }
  return YamlHeaders(
    entryPoints: entryPoints,
    includeFilter: GlobHeaderFilter(includeGlobs: includeGlobs),
  );
}

String? _findLibInConda() {
  final condaEnvPath = Platform.environment['CONDA_PREFIX'] ?? '';
  if (condaEnvPath.isNotEmpty) {
    final locations = [
      p.join(condaEnvPath, 'lib'),
      p.join(p.dirname(p.dirname(condaEnvPath)), 'lib'),
    ];
    for (final l in locations) {
      final k = findLibclangDylib(l);
      if (k != null) return k;
    }
  }
  return null;
}

/// Returns location of dynamic library by searching default locations. Logs
/// error and throws an Exception if not found.
String findDylibAtDefaultLocations(Logger logger) {
  for (final libclangPath in libclangOverridePaths) {
    final overridableLib = findLibclangDylib(libclangPath);
    if (overridableLib != null) return overridableLib;
  }

  // Assume clang in conda has a higher priority.
  final condaLib = _findLibInConda();
  if (condaLib != null) return condaLib;

  if (Platform.isLinux) {
    for (final l in strings.linuxDylibLocations) {
      final linuxLib = findLibclangDylib(l);
      if (linuxLib != null) return linuxLib;
    }
    final ldConfigResult = Process.runSync('ldconfig', ['-p']);
    if (ldConfigResult.exitCode == 0) {
      final lines = (ldConfigResult.stdout as String).split('\n');
      final paths = [
        for (final line in lines)
          if (line.contains('libclang')) line.split(' => ')[1],
      ];
      for (final location in paths) {
        if (File(location).existsSync()) {
          return location;
        }
      }
    }
  } else if (Platform.isWindows) {
    final dylibLocations = strings.windowsDylibLocations.toList();
    final userHome = Platform.environment['USERPROFILE'];
    if (userHome != null) {
      dylibLocations.add(
        p.join(userHome, 'scoop', 'apps', 'llvm', 'current', 'bin'),
      );
    }
    for (final l in dylibLocations) {
      final winLib = findLibclangDylib(l);
      if (winLib != null) return winLib;
    }
  } else if (Platform.isMacOS) {
    for (final l in strings.macOsDylibLocations) {
      final macLib = findLibclangDylib(l);
      if (macLib != null) return macLib;
    }
    final findLibraryResult = Process.runSync('xcodebuild', [
      '-find-library',
      'libclang.dylib',
    ]);
    if (findLibraryResult.exitCode == 0) {
      final location = (findLibraryResult.stdout as String).split('\n').first;
      if (File(location).existsSync()) {
        return location;
      }
    }
    final xcodePathResult = Process.runSync('xcode-select', ['-print-path']);
    if (xcodePathResult.exitCode == 0) {
      final xcodePath = (xcodePathResult.stdout as String).split('\n').first;
      final location = p.join(
        xcodePath,
        strings.xcodeDylibLocation,
        strings.dylibFileName,
      );
      if (File(location).existsSync()) {
        return location;
      }
    }
  } else {
    throw Exception('Unsupported Platform.');
  }

  final clangPrintFileNameResult = Process.runSync('clang', [
    '-print-file-name=${strings.dylibFileName}',
  ]);
  if (clangPrintFileNameResult.exitCode == 0) {
    final path = (clangPrintFileNameResult.stdout as String).trim();
    if (File(path).existsSync()) {
      return path;
    }
  }

  logger.severe("Couldn't find dynamic library in default locations.");
  logger.severe(
    "Please supply one or more path/to/llvm in ffigen's config under the key '${strings.llvmPath}'.",
  );
  throw Exception("Couldn't find dynamic library in default locations.");
}

String? findLibclangDylib(String parentFolder) {
  final location = p.join(parentFolder, strings.dylibFileName);
  if (File(location).existsSync()) {
    return location;
  } else {
    return null;
  }
}

String llvmPathExtractor(Logger logger, List<String> value) {
  // Extract libclang's dylib from user specified paths.
  for (final path in value) {
    final dylibPath = findLibclangDylib(
      p.join(path, strings.dynamicLibParentName),
    );
    if (dylibPath != null) {
      logger.fine('Found dynamic library at: $dylibPath');
      return dylibPath;
    }
    // Check if user has specified complete path to dylib.
    final completeDylibPath = path;
    if (p.extension(completeDylibPath).isNotEmpty &&
        File(completeDylibPath).existsSync()) {
      logger.info(
        'Using complete dylib path: $completeDylibPath from llvm-path.',
      );
      return completeDylibPath;
    }
  }
  logger.fine(
    "Couldn't find dynamic library under paths specified by "
    '${strings.llvmPath}.',
  );
  // Extract path from default locations.
  try {
    return findDylibAtDefaultLocations(logger);
  } catch (e) {
    final path = p.join(strings.dynamicLibParentName, strings.dylibFileName);
    logger.severe("Couldn't find $path in specified locations.");
    exit(1);
  }
}

OutputConfig outputExtractor(
  Logger logger,
  dynamic value,
  String? configFilename,
  PackageConfig? packageConfig,
) {
  if (value is String) {
    return OutputConfig(normalizePath(value, configFilename), null, null);
  }
  value = value as Map;
  return OutputConfig(
    normalizePath(value[strings.bindings] as String, configFilename),
    value.containsKey(strings.objCBindings)
        ? normalizePath(value[strings.objCBindings] as String, configFilename)
        : null,
    value.containsKey(strings.symbolFile)
        ? symbolFileOutputExtractor(
            logger,
            value[strings.symbolFile],
            configFilename,
            packageConfig,
          )
        : null,
  );
}

SymbolFile symbolFileOutputExtractor(
  Logger logger,
  dynamic value,
  String? configFilename,
  PackageConfig? packageConfig,
) {
  value = value as Map;
  var output = Uri.parse(value[strings.output] as String);
  if (output.scheme != 'package') {
    logger.warning(
      'Consider using a Package Uri for ${strings.symbolFile} -> '
      '${strings.output}: $output so that external packages can use it.',
    );
    output = Uri.file(normalizePath(output.toFilePath(), configFilename));
  } else {
    output = packageConfig!.resolve(output)!;
  }
  final importPath = Uri.parse(value[strings.importPath] as String);
  if (importPath.scheme != 'package') {
    logger.warning(
      'Consider using a Package Uri for ${strings.symbolFile} -> '
      '${strings.importPath}: $importPath so that external packages '
      'can use it.',
    );
  }
  return SymbolFile(importPath, output);
}

/// Returns true if [str] is not a full name.
///
/// E.g `abc` is a full name, `abc.*` is not.
bool isFullDeclarationName(String str) =>
    quiver.matchesFull(RegExp('[a-zA-Z_0-9]*'), str);

YamlIncluder extractIncluderFromYaml(Map<dynamic, dynamic> yamlMap) {
  final includeMatchers = <RegExp>[],
      includeFull = <String>{},
      excludeMatchers = <RegExp>[],
      excludeFull = <String>{};

  final include = yamlMap[strings.include] as List<String>?;
  if (include != null) {
    if (include.isEmpty) {
      return YamlIncluder.excludeByDefault();
    }
    for (final str in include) {
      if (isFullDeclarationName(str)) {
        includeFull.add(str);
      } else {
        includeMatchers.add(RegExp(str, dotAll: true));
      }
    }
  }

  final exclude = yamlMap[strings.exclude] as List<String>?;
  if (exclude != null) {
    for (final str in exclude) {
      if (isFullDeclarationName(str)) {
        excludeFull.add(str);
      } else {
        excludeMatchers.add(RegExp(str, dotAll: true));
      }
    }
  }

  return YamlIncluder(
    includeMatchers: includeMatchers,
    includeFull: includeFull,
    excludeMatchers: excludeMatchers,
    excludeFull: excludeFull,
  );
}

Map<String, List<VarArgFunction>> varArgFunctionConfigExtractor(
  Map<dynamic, dynamic> yamlMap,
) {
  final result = <String, List<VarArgFunction>>{};
  final configMap = yamlMap;
  for (final key in configMap.keys) {
    final vafuncs = <VarArgFunction>[];
    for (final rawVaFunc in configMap[key] as List) {
      if (rawVaFunc is List) {
        vafuncs.add(VarArgFunction(types: rawVaFunc.cast()));
      } else if (rawVaFunc is Map) {
        vafuncs.add(
          VarArgFunction(
            postfix: (rawVaFunc[strings.postfix] as String?) ?? '',
            types: (rawVaFunc[strings.types] as List).cast(),
          ),
        );
      } else {
        throw Exception('Unexpected type in variadic-argument config.');
      }
    }
    result[key as String] = vafuncs;
  }

  return result;
}

YamlDeclarationFilters declarationConfigExtractor(
  Map<dynamic, dynamic> yamlMap,
  bool excludeAllByDefault,
) {
  final renamePatterns = <RegExpRenamer>[];
  final renameFull = <String, String>{};
  final memberRenamePatterns = <RegExpMemberRenamer>[];
  final memberRenamerFull = <String, YamlRenamer>{};

  final includer = extractIncluderFromYaml(yamlMap);

  final symbolIncluder = yamlMap[strings.symbolAddress] as YamlIncluder?;

  final rename = yamlMap[strings.rename] as Map<dynamic, String>?;

  if (rename != null) {
    for (final key in rename.keys) {
      final str = key.toString();
      if (isFullDeclarationName(str)) {
        renameFull[str] = rename[str]!;
      } else {
        renamePatterns.add(
          RegExpRenamer(RegExp(str, dotAll: true), rename[str]!),
        );
      }
    }
  }

  final memberRename =
      yamlMap[strings.memberRename] as Map<dynamic, Map<dynamic, String>>?;
  if (memberRename != null) {
    for (final key in memberRename.keys) {
      final decl = key.toString();
      final renamePatterns = <RegExpRenamer>[];
      final renameFull = <String, String>{};

      final memberRenameMap = memberRename[decl]!;
      for (final member in memberRenameMap.keys) {
        final memberStr = member.toString();
        if (isFullDeclarationName(memberStr)) {
          renameFull[memberStr] = memberRenameMap[member]!;
        } else {
          renamePatterns.add(
            RegExpRenamer(
              RegExp(memberStr, dotAll: true),
              memberRenameMap[member]!,
            ),
          );
        }
      }
      if (isFullDeclarationName(decl)) {
        memberRenamerFull[decl] = YamlRenamer(
          renameFull: renameFull,
          renamePatterns: renamePatterns,
        );
      } else {
        memberRenamePatterns.add(
          RegExpMemberRenamer(
            RegExp(decl, dotAll: true),
            YamlRenamer(renameFull: renameFull, renamePatterns: renamePatterns),
          ),
        );
      }
    }
  }

  final memberIncluderMatchers = <(RegExp, YamlIncluder)>[];
  final memberIncluderFull = <String, YamlIncluder>{};
  final memberFilter =
      yamlMap[strings.memberFilter] as Map<dynamic, YamlIncluder>?;
  if (memberFilter != null) {
    for (final entry in memberFilter.entries) {
      final decl = entry.key.toString();
      if (isFullDeclarationName(decl)) {
        memberIncluderFull[decl] = entry.value;
      } else {
        memberIncluderMatchers.add((RegExp(decl, dotAll: true), entry.value));
      }
    }
  }

  return YamlDeclarationFilters(
    includer: includer,
    renamer: YamlRenamer(
      renameFull: renameFull,
      renamePatterns: renamePatterns,
    ),
    memberRenamer: YamlMemberRenamer(
      memberRenameFull: memberRenamerFull,
      memberRenamePattern: memberRenamePatterns,
    ),
    memberIncluder: YamlMemberIncluder(
      memberIncluderFull: memberIncluderFull,
      memberIncluderMatchers: memberIncluderMatchers,
    ),
    symbolAddressIncluder: symbolIncluder,
    excludeAllByDefault: excludeAllByDefault,
  );
}

StructPackingOverride structPackingOverrideExtractor(
  Map<dynamic, dynamic> value,
) {
  final matcherMap = <(RegExp, int?)>[];
  for (final key in value.keys) {
    matcherMap.add((
      RegExp(key as String, dotAll: true),
      strings.packingValuesMap[value[key]],
    ));
  }
  return StructPackingOverride(matcherMap);
}

FfiNativeConfig ffiNativeExtractor(Logger logger, dynamic yamlConfig) {
  final yamlMap = yamlConfig as Map?;

  // Use the old 'assetId' key if present but give a deprecation warning
  if (yamlMap != null &&
      !yamlMap.containsKey(strings.ffiNativeAsset) &&
      yamlMap.containsKey('assetId')) {
    logger.warning("DEPRECATION WARNING: use 'asset-id' instead of 'assetId'");
    return FfiNativeConfig(
      enabled: true,
      assetId: yamlMap['assetId'] as String?,
    );
  }

  return FfiNativeConfig(
    enabled: true,
    assetId: yamlMap?[strings.ffiNativeAsset] as String?,
  );
}

ExternalVersions externalVersionsExtractor(Map<dynamic, dynamic>? yamlConfig) =>
    ExternalVersions(
      ios: versionsExtractor(yamlConfig?[strings.ios]),
      macos: versionsExtractor(yamlConfig?[strings.macos]),
    );

Versions? versionsExtractor(dynamic yamlConfig) {
  final yamlMap = yamlConfig as Map?;
  if (yamlMap == null) return null;
  return Versions(
    min: versionExtractor(yamlMap[strings.externalVersionsMin]),
    max: versionExtractor(yamlMap[strings.externalVersionsMax]),
  );
}

Version? versionExtractor(dynamic yamlVersion) {
  final versionString = yamlVersion as String?;
  if (versionString == null) return null;
  return Version.parse(versionString);
}
