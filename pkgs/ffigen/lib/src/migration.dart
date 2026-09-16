// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'code_generator/imports.dart' show builtInLibraries;

/// Migrates a YAML configuration file to a Dart configuration script.
///
/// Reads [yamlConfig] and writes a Dart configuration script to [outputDart].
void migrate({required File yamlConfig, required File outputDart}) {
  if (!yamlConfig.existsSync()) {
    throw FileSystemException(
      'YAML config file does not exist',
      yamlConfig.path,
    );
  }

  final yamlContent = yamlConfig.readAsStringSync();
  final yamlMap = loadYaml(yamlContent) as YamlMap;

  final configDirectory = yamlConfig.parent.absolute;
  var rootDir = configDirectory;
  while (!File(p.join(rootDir.path, 'pubspec.yaml')).existsSync()) {
    final parent = rootDir.parent;
    if (parent.path == rootDir.path) break;
    rootDir = parent;
  }
  final packageRoot = rootDir;
  final isAtRoot =
      p.normalize(configDirectory.path) == p.normalize(packageRoot.path);
  final configDir = isAtRoot ? null : configDirectory;

  final outputDir = yamlConfig.path.contains(p.join('test', 'migrate', 'yaml'))
      ? p.join(packageRoot.path, 'test', 'migrate', 'dart')
      : outputDart.parent.path;
  final relToPkg = p.posix.normalize(
    p.relative(packageRoot.path, from: outputDir).replaceAll(r'\', '/'),
  );
  final packageRootExpr = (relToPkg == '.' || relToPkg.isEmpty)
      ? "Platform.script.resolve('./')"
      : "Platform.script.resolve('$relToPkg/')";

  String resolvePath(String rawPath) {
    if (rawPath.startsWith(r'$XCODE/')) {
      return "xcodeUri.resolve('${p.posix.normalize(rawPath.substring(7))}')";
    }
    if (rawPath == r'$XCODE') return 'xcodeUri';
    if (rawPath.startsWith(r'$IOS_SDK/')) {
      return "iosSdkUri.resolve('${p.posix.normalize(rawPath.substring(9))}')";
    }
    if (rawPath == r'$IOS_SDK') return 'iosSdkUri';
    if (rawPath.startsWith(r'$MACOS_SDK/')) {
      return "macSdkUri.resolve('${p.posix.normalize(rawPath.substring(11))}')";
    }
    if (rawPath == r'$MACOS_SDK') return 'macSdkUri';

    if (rawPath.startsWith('package:')) {
      final uri = Uri.parse(rawPath);
      final rest = uri.pathSegments.skip(1).join('/');
      if (File(p.join(packageRoot.path, 'lib', rest)).existsSync()) {
        return "packageRoot.resolve('lib/$rest')";
      }
      final pkgName = uri.pathSegments.first;
      if (File(
        p.join(packageRoot.path, 'example', pkgName, 'lib', rest),
      ).existsSync()) {
        return "packageRoot.resolve('example/$pkgName/lib/$rest')";
      }
      return "Uri.parse('$rawPath')";
    }
    if (rawPath.startsWith('http:') || rawPath.startsWith('https:')) {
      return "Uri.parse('$rawPath')";
    }
    if (p.isAbsolute(rawPath)) {
      return "Uri.file('$rawPath')";
    }
    final posixPath = p.posix.normalize(rawPath.replaceAll(r'\', '/'));
    return configDir == null
        ? "packageRoot.resolve('$posixPath')"
        : "configDir.resolve('$posixPath')";
  }

  String resolveCompilerOption(String opt) {
    if (!opt.startsWith('-I')) return _str(opt);
    final incPath = opt.substring(2);
    if (!p.isRelative(incPath)) return _str(opt);

    final posixInc = p.posix.normalize(incPath.replaceAll(r'\', '/'));
    final fromPkg = p.normalize(p.join(packageRoot.path, incPath));
    final fromCfg = configDir != null
        ? p.normalize(p.join(configDir.path, incPath))
        : fromPkg;

    final expr =
        configDir == null ||
            (FileSystemEntity.typeSync(fromPkg) !=
                    FileSystemEntityType.notFound &&
                FileSystemEntity.typeSync(fromCfg) ==
                    FileSystemEntityType.notFound)
        ? "packageRoot.resolve('$posixInc').toFilePath()"
        : "configDir.resolve('$posixInc').toFilePath()";

    final optStr = "'-I\${$expr}'";
    return optStr.length + 10 > 80
        ? '// ignore: lines_longer_than_80_chars\n$optStr'
        : optStr;
  }

  final buf = StringBuffer();

  // Static imports block
  buf.writeln('// ignore_for_file: unused_import');
  buf.writeln("import 'dart:io';");
  buf.writeln("import 'package:ffigen/ffigen.dart';");
  buf.writeln("import 'package:glob/glob.dart';\n");

  _emitTopLevelDeclarations(buf, yamlMap);

  buf.writeln('Future<void> main() async {');
  buf.writeln('final packageRoot = $packageRootExpr;');
  if (configDir != null) {
    final relConfig = p.posix.normalize(
      p.relative(configDir.path, from: packageRoot.path).replaceAll(r'\', '/'),
    );
    buf.writeln("final configDir = packageRoot.resolve('$relConfig/');");
  }

  buf.writeln('await FfiGenerator(');

  _emitOutput(buf, yamlMap, resolvePath);
  _emitInput(buf, yamlMap, resolvePath, resolveCompilerOption);
  _emitObjectiveC(buf, yamlMap);

  if (yamlMap.containsKey('cpp')) {
    buf.writeln('cpp: const Cpp(),');
  }

  _emitImportTypeArgument(buf, yamlMap, resolvePath);
  _emitVisitors(buf, yamlMap);

  buf.writeln(').generate();');
  buf.writeln('}\n');

  final parentDir = outputDart.parent;
  if (!parentDir.existsSync()) {
    parentDir.createSync(recursive: true);
  }
  outputDart.writeAsStringSync(buf.toString());

  Process.runSync(Platform.resolvedExecutable, [
    'format',
    outputDart.absolute.path,
  ], workingDirectory: outputDart.parent.absolute.path);
}

String _str(String s) {
  if (s.contains('\n')) {
    final escaped = s
        .replaceAll(r'\', r'\\')
        .replaceAll("'''", r"\'\'\'")
        .replaceAll(r'$', r'\$');
    return "'''\n$escaped'''";
  }
  final escaped = s
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$');
  return "'$escaped'";
}

String _strSet(Iterable<String> s) => '{${s.map(_str).join(', ')}}';

bool _isExact(String s) => RegExp(r'^[a-zA-Z_0-9:]+$').hasMatch(s);

String _regexPat(String s) {
  final pat = s.startsWith('^') ? s.substring(1) : s;
  return pat.endsWith(r'$') ? pat.substring(0, pat.length - 1) : pat;
}

String _nameCond(String target, String name) {
  if (_isExact(name)) return '$target == ${_str(name)}';
  final pat = _regexPat(name);
  return 'RegExp(r\'^$pat\$\').hasMatch($target)';
}

void _emitTopLevelDeclarations(StringBuffer buf, YamlMap yamlMap) {
  final typeMap = yamlMap['type-map'];
  if (typeMap is! Map || typeMap.isEmpty) return;

  final libImports = yamlMap['library-imports'] as Map? ?? {};

  String libImportPath(String lib) {
    if (builtInLibraries.containsKey(lib)) {
      return builtInLibraries[lib]!.importPath(false);
    }
    return libImports[lib]?.toString() ?? lib;
  }

  buf.writeln('final _importedTypes = <String, ImportedType>{');
  for (final section in typeMap.values) {
    if (section is Map) {
      for (final entry in section.entries) {
        final typeName = entry.key as String;
        final typeInfo = entry.value as Map;
        final lib = typeInfo['lib'] as String? ?? 'ffi';
        final cType = typeInfo['c-type'] as String? ?? typeName;
        final dartType = typeInfo['dart-type'] as String? ?? typeName;
        final importPath = libImportPath(lib);

        buf.writeln(
          "'$typeName': ImportedType("
          "const LibraryImport('$lib', '$importPath'), "
          "'$cType', "
          "'$dartType', "
          "'$typeName',"
          '),',
        );
      }
    }
  }
  buf.writeln('};\n');
  buf.writeln(
    'ImportedType? importType(Declaration declaration) => '
    '_importedTypes[declaration.originalName];\n',
  );
}

void _emitOutput(
  StringBuffer buf,
  YamlMap yamlMap,
  String Function(String) resolvePath,
) {
  final hasObjc = yamlMap['language'] == 'objc';
  final hasCpp = yamlMap.containsKey('cpp');
  final output = yamlMap['output'];

  String rawDart;
  String? rawObjc;
  String? rawSymbolOutput;
  String? rawSymbolImport;

  if (output is String) {
    rawDart = output;
    rawObjc = hasObjc ? '$output.m' : null;
  } else if (output is Map) {
    rawDart = output['bindings'] as String;
    if (output.containsKey('objc-bindings')) {
      rawObjc = output['objc-bindings'] as String;
    } else if (hasObjc) {
      rawObjc = '$rawDart.m';
    }
    if (output.containsKey('symbol-file')) {
      final sym = output['symbol-file'] as Map;
      rawSymbolOutput = sym['output'] as String;
      rawSymbolImport = sym['import-path'] as String;
    }
  } else {
    throw ArgumentError('Invalid output: $output');
  }

  buf.writeln('output: Output(');
  buf.writeln('dart: DartOutput(path: ${resolvePath(rawDart)}),');
  if (rawObjc != null) {
    buf.writeln('objectiveCFile: ${resolvePath(rawObjc)},');
  }
  if (hasCpp) {
    buf.writeln('cppFile: ${resolvePath('$rawDart.cpp')},');
  }
  if (rawSymbolOutput != null) {
    buf.writeln(
      'symbolFile: SymbolFile('
      "Uri.parse('$rawSymbolImport'), "
      '${resolvePath(rawSymbolOutput)}'
      '),',
    );
  }

  if (yamlMap.containsKey('ffi-native')) {
    final ffiNative = yamlMap['ffi-native'];
    final assetId = ffiNative is Map
        ? (ffiNative['asset-id'] ?? ffiNative['assetId'])
        : null;
    if (assetId != null) {
      buf.writeln("style: const NativeExternalBindings(assetId: '$assetId'),");
    } else {
      buf.writeln('style: const NativeExternalBindings(),');
    }
  } else {
    final name = yamlMap['name'] as String?;
    final description = yamlMap['description'] as String?;
    if (name != null || description != null) {
      buf.writeln('style: const DynamicLibraryBindings(');
      if (name != null) buf.writeln("wrapperName: '$name',");
      if (description != null) {
        buf.writeln('wrapperDocComment: ${_str(description)},');
      }
      buf.writeln('),');
    }
  }

  final comments = yamlMap['comments'];
  if (comments == false) {
    buf.writeln('commentType: const CommentType.none(),');
  } else if (comments is Map) {
    final length = comments['length'];
    final style = comments['style'];
    if (length == 'none') {
      buf.writeln('commentType: const CommentType.none(),');
    } else if (length == 'brief') {
      buf.writeln(
        'commentType: const CommentType('
        "CommentStyle.${style ?? 'doxygen'}, CommentLength.brief),",
      );
    } else if (style == 'any') {
      buf.writeln(
        'commentType: const CommentType(CommentStyle.any, CommentLength.full),',
      );
    }
  }

  final preamble = yamlMap['preamble'] as String?;
  if (preamble != null && preamble.isNotEmpty) {
    buf.writeln('preamble: ${_str(preamble)},');
  }

  if (yamlMap['format'] == false) {
    buf.writeln('format: false,');
  }

  buf.writeln('),');
}

String _globPattern(String p) {
  if (p.startsWith('/**')) return p;
  if (p.startsWith('**')) return '/$p';
  if (p.startsWith('/')) return p;
  return '/**/$p';
}

void _emitHeaders(
  StringBuffer buf,
  Map<dynamic, dynamic>? headers,
  String Function(String) resolvePath,
) {
  if (headers == null) return;
  final entryPoints = headers['entry-points'] as List?;
  if (entryPoints != null && entryPoints.isNotEmpty) {
    buf.writeln('entryPoints: [');
    for (final ep in entryPoints) {
      buf.writeln('${resolvePath(ep.toString())},');
    }
    buf.writeln('],');
  }

  final includeDirectives = headers['include-directives'] as List?;
  if (includeDirectives != null && includeDirectives.isNotEmpty) {
    final globChecks = includeDirectives
        .map((p) => "Glob('${_globPattern(p.toString())}').matches(uri.path)")
        .join(' || ');
    buf.writeln('include: (uri) => $globChecks,');
  }
}

void _emitCompilerOptions(
  StringBuffer buf,
  YamlMap yamlMap,
  String Function(String) resolveCompilerOption,
) {
  final compilerOpts = yamlMap['compiler-opts'];
  if (compilerOpts == null) return;

  final List<String> opts;
  if (compilerOpts is String) {
    opts = compilerOpts
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  } else if (compilerOpts is List) {
    opts = compilerOpts.map((e) => e.toString()).toList();
  } else {
    opts = const [];
  }

  if (opts.isEmpty) return;

  final auto = yamlMap['compiler-opts-automatic'] as Map?;
  final macAuto = auto?['macos'] as Map?;
  final includeMacStdLib = macAuto?['include-c-standard-library'] != false;
  final hasSysroot = opts.any(
    (o) => o.contains('-isysroot') || o.contains('MacOSX.sdk'),
  );

  buf.writeln('compilerOptions: [');
  for (final opt in opts) {
    buf.writeln('${resolveCompilerOption(opt)},');
  }
  if (includeMacStdLib && !hasSysroot) {
    buf.writeln("if (Platform.isMacOS) ...['-isysroot', macSdkPath],");
  }
  buf.writeln('],');
}

void _emitInput(
  StringBuffer buf,
  YamlMap yamlMap,
  String Function(String) resolvePath,
  String Function(String) resolveCompilerOption,
) {
  buf.writeln('input: Input(');
  _emitHeaders(buf, yamlMap['headers'] as Map?, resolvePath);
  _emitCompilerOptions(buf, yamlMap, resolveCompilerOption);
  if (yamlMap['ignore-source-errors'] == true) {
    buf.writeln('ignoreSourceErrors: true,');
  }
  buf.writeln('),');
}

void _emitObjectiveC(StringBuffer buf, YamlMap yamlMap) {
  final genPkgObjC = yamlMap['generate-for-package-objective-c'] == true;
  if (yamlMap['language'] != 'objc' && !genPkgObjC) return;

  final extVersions = yamlMap['external-versions'] as Map?;
  if (extVersions != null) {
    buf.writeln('objectiveC: ObjectiveC(');
    buf.writeln('externalVersions: ExternalVersions(');
    if (extVersions.containsKey('ios')) {
      final iosMin = (extVersions['ios'] as Map)['min'].toString();
      buf.writeln('ios: Versions(min: ${_formatVersion(iosMin)}),');
    }
    if (extVersions.containsKey('macos')) {
      final macosMin = (extVersions['macos'] as Map)['min'].toString();
      buf.writeln('macos: Versions(min: ${_formatVersion(macosMin)}),');
    }
    buf.writeln('),');
    if (genPkgObjC) {
      buf.writeln('generateForPackageObjectiveC: true,');
    }
    buf.writeln('),');
  } else if (genPkgObjC) {
    buf.writeln(
      'objectiveC: const ObjectiveC(generateForPackageObjectiveC: true),',
    );
  } else {
    buf.writeln('objectiveC: const ObjectiveC(),');
  }
}

String _formatVersion(String v) {
  final parts = v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  while (parts.length < 3) {
    parts.add(0);
  }
  return 'Version(${parts[0]}, ${parts[1]}, ${parts[2]})';
}

void _emitImportTypeArgument(
  StringBuffer buf,
  YamlMap yamlMap,
  String Function(String) resolvePath,
) {
  final typeMap = yamlMap['type-map'];
  final hasTypeMap = typeMap is Map && typeMap.isNotEmpty;

  final importMap = yamlMap['import'];
  final syms = importMap is Map
      ? (importMap['symbol-files'] as List?)?.cast<String>()
      : null;

  if (syms != null && syms.isNotEmpty && !hasTypeMap) {
    if (syms.length == 1) {
      buf.writeln(
        'importType: importFromSymbolFile(${resolvePath(syms.first)}),',
      );
    } else {
      final exprs = syms.map(resolvePath).join(', ');
      buf.writeln('importType: importFromSymbolFiles([$exprs]),');
    }
  } else if (hasTypeMap) {
    buf.writeln('importType: importType,');
  }
}

void _emitDeclarationFilter(
  StringBuffer buf,
  Map<dynamic, dynamic>? cfg, {
  String target = 'node.originalName',
  bool defaultInclude = false,
}) {
  if (cfg == null) {
    if (defaultInclude) buf.writeln('node.isIncluded = true;');
    return;
  }
  final includes = (cfg['include'] as List?)?.cast<String>();
  final excludes = (cfg['exclude'] as List?)?.cast<String>();
  if (includes == null && excludes == null) {
    if (defaultInclude) buf.writeln('node.isIncluded = true;');
    return;
  }
  final cond = _buildCondition(includes, excludes, target);
  buf.writeln('node.isIncluded = $cond;');
}

void _emitRenames(
  StringBuffer buf,
  Map<dynamic, dynamic>? cfg, {
  String target = 'node.name',
}) {
  final rename = cfg?['rename'] as Map?;
  if (rename == null || rename.isEmpty) return;
  for (final entry in rename.entries) {
    final from = entry.key.toString();
    final to = entry.value.toString();
    if (_isExact(from)) {
      buf.writeln("if ($target == '$from') { $target = '$to'; }");
    } else if (!to.contains(r'$')) {
      final pat = _regexPat(from);
      buf.writeln(
        "if (RegExp(r'^$pat\$').hasMatch($target)) { $target = '$to'; }",
      );
    } else {
      final pat = _regexPat(from);
      buf.writeln('''
if (RegExp(r'^$pat\$').firstMatch($target) case final match?) {
  node.name = r'$to'.replaceAllMapped(RegExp(r'\\\$([0-9])'), (m) => match[int.parse(m[1]!)] ?? '');
}''');
    }
  }
}

void _emitFuncVisitor(StringBuffer buf, YamlMap yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  if (!yamlMap.containsKey('functions') && excludeAll) return;
  final cfg = yamlMap['functions'] as Map?;

  buf.writeln('func: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: !excludeAll);
  _emitRenames(buf, cfg);

  if (cfg != null) {
    final leaf = cfg['leaf'];
    if (leaf is bool) {
      buf.writeln('node.isLeaf = $leaf;');
    } else if (leaf is Map) {
      final cond = _buildCondition(
        (leaf['include'] as List?)?.cast<String>(),
        (leaf['exclude'] as List?)?.cast<String>(),
        'node.originalName',
      );
      if (cond == 'true') {
        buf.writeln('node.isLeaf = true;');
      } else if (cond != 'false') {
        buf.writeln('node.isLeaf = $cond;');
      }
    }

    final symAddr = cfg['symbol-address'] as Map?;
    final symInc = (symAddr?['include'] as List?)?.cast<String>();
    if (symInc != null && symInc.isNotEmpty) {
      final cond = _buildCondition(symInc, null, 'node.originalName');
      buf.writeln('if ($cond) { node.exposeSymbolAddress = true; }');
    }

    final expTypedefs = cfg['expose-typedefs'] as Map?;
    final expInc = (expTypedefs?['include'] as List?)?.cast<String>();
    if (expInc != null && expInc.isNotEmpty) {
      final cond = _buildCondition(expInc, null, 'node.originalName');
      buf.writeln('if ($cond) { node.generateTypedefs = true; }');
    }
  }
  buf.writeln('},');
}

void _emitStructVisitor(StringBuffer buf, YamlMap yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  if (!yamlMap.containsKey('structs') && excludeAll) return;
  final cfg = yamlMap['structs'] as Map?;

  buf.writeln('struct: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: !excludeAll);
  _emitRenames(buf, cfg);
  final depOnly = cfg?['dependency-only'] == 'opaque' ? 'opaque' : 'full';
  buf.writeln('node.dependencies = CompoundDependencies.$depOnly;');
  if (cfg?['pack'] is Map) {
    for (final entry in (cfg!['pack'] as Map).entries) {
      final cond = _nameCond('node.originalName', entry.key.toString());
      final val = entry.value == 'none' ? 'null' : entry.value.toString();
      buf.writeln('if ($cond) { node.pack = $val; }');
    }
  }
  buf.writeln('},');
}

void _emitUnionVisitor(StringBuffer buf, YamlMap yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  if (!yamlMap.containsKey('unions') && excludeAll) return;
  final cfg = yamlMap['unions'] as Map?;

  buf.writeln('union: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: !excludeAll);
  _emitRenames(buf, cfg);
  final depOnly = cfg?['dependency-only'] == 'opaque' ? 'opaque' : 'full';
  buf.writeln('node.dependencies = CompoundDependencies.$depOnly;');
  buf.writeln('},');
}

void _emitEnumVisitor(StringBuffer buf, YamlMap yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  final silenceWarn = yamlMap['silence-enum-warning'] == true;
  if (!yamlMap.containsKey('enums') && !silenceWarn && excludeAll) return;
  final cfg = yamlMap['enums'] as Map?;

  buf.writeln('enumClass: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: !excludeAll);
  _emitRenames(buf, cfg);
  final asInt = cfg?['as-int'] as Map?;
  final asIntInc = (asInt?['include'] as List?)?.cast<String>();
  if (asIntInc != null && asIntInc.isNotEmpty) {
    final cond = _buildCondition(asIntInc, null, 'node.originalName');
    buf.writeln('if ($cond) { node.style = EnumStyle.intConstants; }');
  }
  if (silenceWarn) {
    buf.writeln('node.silenceWarning = true;');
  }
  buf.writeln('},');
}

void _emitUnnamedEnumVisitor(StringBuffer buf, YamlMap yamlMap) {
  if (!yamlMap.containsKey('unnamed-enums')) return;
  final cfg = yamlMap['unnamed-enums'] as Map?;

  buf.writeln('unnamedEnumConstant: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: false);
  _emitRenames(buf, cfg);
  buf.writeln('},');
}

void _emitGlobalVisitor(StringBuffer buf, YamlMap yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  if (!yamlMap.containsKey('globals') && excludeAll) return;
  final cfg = yamlMap['globals'] as Map?;

  buf.writeln('global: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: !excludeAll);
  _emitRenames(buf, cfg);
  final symAddr = cfg?['symbol-address'] as Map?;
  final symInc = (symAddr?['include'] as List?)?.cast<String>();
  if (symInc != null && symInc.isNotEmpty) {
    final cond = _buildCondition(symInc, null, 'node.originalName');
    buf.writeln('if ($cond) { node.exposeSymbolAddress = true; }');
  }
  buf.writeln('},');
}

void _emitMacroVisitor(StringBuffer buf, YamlMap yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  if (!yamlMap.containsKey('macros') && excludeAll) return;
  final cfg = yamlMap['macros'] as Map?;

  buf.writeln('macroConstant: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: !excludeAll);
  _emitRenames(buf, cfg);
  buf.writeln('},');
}

void _emitTypealiasVisitor(StringBuffer buf, YamlMap yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  final includeUnused = yamlMap['include-unused-typedefs'] == true;
  if (!yamlMap.containsKey('typedefs') && !includeUnused && excludeAll) return;
  final cfg = yamlMap['typedefs'] as Map?;

  buf.writeln('typealias: (node) {');
  final incList = (cfg?['include'] as List?)?.cast<String>();
  final excList = (cfg?['exclude'] as List?)?.cast<String>();
  if ((incList != null && incList.isNotEmpty) ||
      (excList != null && excList.isNotEmpty)) {
    final cond = _buildCondition(incList, excList, 'node.originalName');
    final trueVal = includeUnused
        ? 'TypealiasInclude.always'
        : 'TypealiasInclude.ifUsed';
    buf.writeln(
      'node.isIncluded = ($cond) ? $trueVal : TypealiasInclude.never;',
    );
  } else if (includeUnused) {
    buf.writeln('node.isIncluded = TypealiasInclude.always;');
  } else if (!excludeAll) {
    buf.writeln('node.isIncluded = TypealiasInclude.ifUsed;');
  }
  _emitRenames(buf, cfg);
  buf.writeln('},');
}

void _emitObjCInterfaceVisitor(StringBuffer buf, YamlMap yamlMap) {
  if (!yamlMap.containsKey('objc-interfaces') &&
      yamlMap['include-transitive-objc-categories'] != false) {
    return;
  }
  final cfg = yamlMap['objc-interfaces'] as Map?;

  buf.writeln('objCInterface: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: false);
  _emitRenames(buf, cfg);
  if (cfg?['module'] is Map) {
    for (final entry in (cfg!['module'] as Map).entries) {
      buf.writeln(
        "if (node.originalName == '${entry.key}') "
        "{ node.module = '${entry.value}'; }",
      );
    }
  }
  if (yamlMap['include-transitive-objc-categories'] == false) {
    buf.writeln('node.includeCategories = false;');
  }
  buf.writeln('},');
}

void _emitObjCProtocolVisitor(StringBuffer buf, YamlMap yamlMap) {
  if (!yamlMap.containsKey('objc-protocols')) return;
  final cfg = yamlMap['objc-protocols'] as Map?;

  buf.writeln('objCProtocol: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: false);
  _emitRenames(buf, cfg);
  if (cfg?['module'] is Map) {
    for (final entry in (cfg!['module'] as Map).entries) {
      buf.writeln(
        "if (node.originalName == '${entry.key}') "
        "{ node.module = '${entry.value}'; }",
      );
    }
  }
  buf.writeln('},');
}

void _emitObjCCategoryVisitor(StringBuffer buf, YamlMap yamlMap) {
  if (!yamlMap.containsKey('objc-categories')) return;
  final cfg = yamlMap['objc-categories'] as Map?;

  buf.writeln('objCCategory: (node) {');
  _emitDeclarationFilter(buf, cfg, defaultInclude: false);
  _emitRenames(buf, cfg);
  buf.writeln('},');
}

void _emitCppClassVisitor(StringBuffer buf, YamlMap yamlMap) {
  final cpp = yamlMap['cpp'] as Map?;
  final cppClasses = cpp?['cpp-classes'] as Map?;
  if (cppClasses == null) return;

  buf.writeln('cppClass: (node) {');
  _emitDeclarationFilter(buf, cppClasses, defaultInclude: false);
  buf.writeln('},');
}

void _emitObjCMethodVisitor(StringBuffer buf, YamlMap yamlMap) {
  final keys = [
    ('objc-interfaces', 'ObjCInterface'),
    ('objc-protocols', 'ObjCProtocol'),
    ('objc-categories', 'ObjCCategory'),
  ];
  final hasAny = keys.any((k) {
    final c = yamlMap[k.$1] as Map?;
    return c?['member-filter'] != null || c?['member-rename'] != null;
  });
  if (!hasAny) return;

  buf.writeln('objCMethod: (node) {');
  buf.writeln('final parent = node.parent;');
  for (final (key, type) in keys) {
    final c = yamlMap[key] as Map?;
    if (c == null) continue;
    _emitMemberSection(
      buf,
      parentType: type,
      filterMap: c['member-filter'] as Map?,
      renameMap: c['member-rename'] as Map?,
      nameProp: 'node.selector',
    );
  }
  buf.writeln('},');
}

void _emitFieldVisitor(StringBuffer buf, YamlMap yamlMap) {
  final keys = [('structs', 'Struct'), ('unions', 'Union')];
  final hasAny = keys.any(
    (k) => (yamlMap[k.$1] as Map?)?['member-rename'] != null,
  );
  if (!hasAny) return;

  buf.writeln('field: (node) {');
  buf.writeln('final parent = node.parent;');
  for (final (key, type) in keys) {
    final c = yamlMap[key] as Map?;
    if (c == null) continue;
    _emitMemberSection(
      buf,
      parentType: type,
      renameMap: c['member-rename'] as Map?,
      nameProp: 'node.originalName',
    );
  }
  buf.writeln('},');
}

void _emitParamVisitor(StringBuffer buf, YamlMap yamlMap) {
  final funcCfg = yamlMap['functions'] as Map?;
  if (funcCfg?['member-rename'] == null) return;

  buf.writeln('param: (node) {');
  buf.writeln('final parent = node.parent;');
  _emitMemberSection(
    buf,
    parentType: 'Func',
    renameMap: funcCfg!['member-rename'] as Map?,
    nameProp: 'node.originalName',
  );
  buf.writeln('},');
}

void _emitEnumConstantVisitor(StringBuffer buf, YamlMap yamlMap) {
  final enumCfg = yamlMap['enums'] as Map?;
  if (enumCfg?['member-rename'] == null) return;

  buf.writeln('enumConstant: (node) {');
  buf.writeln('final parent = node.parent;');
  _emitMemberSection(
    buf,
    renameMap: enumCfg!['member-rename'] as Map?,
    nameProp: 'node.originalName',
  );
  buf.writeln('},');
}

void _emitMemberSection(
  StringBuffer buf, {
  String? parentType,
  Map<dynamic, dynamic>? filterMap,
  Map<dynamic, dynamic>? renameMap,
  required String nameProp,
}) {
  final sBuf = StringBuffer();
  if (filterMap != null) {
    for (final entry in filterMap.entries) {
      final parentDecl = entry.key.toString();
      final filter = entry.value as Map;
      final inc = (filter['include'] as List?)?.cast<String>();
      final exc = (filter['exclude'] as List?)?.cast<String>();
      final parentCond = _nameCond('parent.originalName', parentDecl);
      if (exc != null &&
          inc == null &&
          exc.length == 1 &&
          _isExact(exc.first)) {
        sBuf.writeln(
          'if ($parentCond && $nameProp == '
          "'${exc.first}') { node.isIncluded = false; }",
        );
      } else {
        final cond = _buildCondition(inc, exc, nameProp);
        sBuf.writeln('if ($parentCond) { node.isIncluded = $cond; }');
      }
    }
  }
  if (renameMap != null) {
    for (final entry in renameMap.entries) {
      final parentDecl = entry.key.toString();
      final renames = entry.value as Map;
      final parentCond = _nameCond('parent.originalName', parentDecl);
      for (final rentry in renames.entries) {
        final from = rentry.key.toString();
        final to = rentry.value.toString();
        if (_isExact(from)) {
          sBuf.writeln(
            "if ($parentCond && $nameProp == '$from') { node.name = '$to'; }",
          );
        } else if (!to.contains(r'$')) {
          final pat = _regexPat(from);
          sBuf.writeln(
            'if ($parentCond && RegExp(r\'^$pat\$\').hasMatch($nameProp)) '
            "{ node.name = '$to'; }",
          );
        } else {
          final pat = _regexPat(from);
          sBuf.writeln('''
if ($parentCond) {
  if (RegExp(r'^$pat\$').firstMatch($nameProp) case final match?) {
    node.name = r'$to'.replaceAllMapped(RegExp(r'\\\$([0-9])'), (m) => match[int.parse(m[1]!)] ?? '');
  }
}''');
        }
      }
    }
  }
  if (sBuf.isEmpty) return;
  if (parentType != null) {
    buf.writeln('if (parent is $parentType) {\n$sBuf}');
  } else {
    buf.write(sBuf);
  }
}

void _emitVisitors(StringBuffer buf, YamlMap yamlMap) {
  final vBuf = StringBuffer();
  _emitFuncVisitor(vBuf, yamlMap);
  _emitStructVisitor(vBuf, yamlMap);
  _emitUnionVisitor(vBuf, yamlMap);
  _emitEnumVisitor(vBuf, yamlMap);
  _emitUnnamedEnumVisitor(vBuf, yamlMap);
  _emitGlobalVisitor(vBuf, yamlMap);
  _emitMacroVisitor(vBuf, yamlMap);
  _emitTypealiasVisitor(vBuf, yamlMap);
  _emitObjCInterfaceVisitor(vBuf, yamlMap);
  _emitObjCProtocolVisitor(vBuf, yamlMap);
  _emitObjCCategoryVisitor(vBuf, yamlMap);
  _emitCppClassVisitor(vBuf, yamlMap);
  _emitObjCMethodVisitor(vBuf, yamlMap);
  _emitFieldVisitor(vBuf, yamlMap);
  _emitParamVisitor(vBuf, yamlMap);
  _emitEnumConstantVisitor(vBuf, yamlMap);

  if (vBuf.isNotEmpty) {
    buf.writeln('visitors: [Visitor(');
    buf.write(vBuf);
    buf.writeln(')],');
  }
}

String _buildCondition(
  List<String>? includes,
  List<String>? excludes,
  String target,
) {
  String? incCond;
  if (includes != null && includes.isNotEmpty) {
    final exact = includes.where(_isExact).toList();
    final regex = includes.where((s) => !_isExact(s)).toList();
    final parts = <String>[];
    if (exact.length == 1) {
      parts.add('$target == ${_str(exact.first)}');
    } else if (exact.length > 1) {
      parts.add('${_strSet(exact)}.contains($target)');
    }
    for (final r in regex) {
      if (r == '.*') {
        parts.add('true');
      } else if (r.endsWith('.*') && _isExact(r.substring(0, r.length - 2))) {
        parts.add('$target.startsWith(${_str(r.substring(0, r.length - 2))})');
      } else {
        final pat = _regexPat(r);
        parts.add('RegExp(r\'^$pat\$\').hasMatch($target)');
      }
    }
    incCond = parts.contains('true') ? 'true' : parts.join(' || ');
  }

  String? excCond;
  if (excludes != null && excludes.isNotEmpty) {
    final exact = excludes.where(_isExact).toList();
    final regex = excludes.where((s) => !_isExact(s)).toList();
    final parts = <String>[];
    if (exact.length == 1) {
      parts.add('$target != ${_str(exact.first)}');
    } else if (exact.length > 1) {
      parts.add('!${_strSet(exact)}.contains($target)');
    }
    for (final r in regex) {
      if (r.endsWith('.*') && _isExact(r.substring(0, r.length - 2))) {
        parts.add('!$target.startsWith(${_str(r.substring(0, r.length - 2))})');
      } else {
        final pat = _regexPat(r);
        parts.add('!RegExp(r\'^$pat\$\').hasMatch($target)');
      }
    }
    excCond = parts.join(' && ');
  }

  if (incCond != null && excCond != null) {
    if (incCond == 'true') return excCond;
    final parenInc = incCond.contains(' || ') ? '($incCond)' : incCond;
    return '$excCond && $parenInc';
  }
  return incCond ?? excCond ?? 'true';
}
