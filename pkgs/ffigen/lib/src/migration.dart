// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Migrates a YAML configuration file to a Dart configuration script.
///
/// Reads [yamlConfig] (or file at [yamlPath]) and writes a Dart configuration
/// script to [outputDart] (or file at [outputPath]).
void migrate({
  File? yamlConfig,
  File? outputDart,
  String? yamlPath,
  String? outputPath,
}) {
  final configFile = yamlConfig ?? (yamlPath != null ? File(yamlPath) : null);
  final dartFile = outputDart ?? (outputPath != null ? File(outputPath) : null);

  if (configFile == null) {
    throw ArgumentError('Either yamlConfig or yamlPath must be provided.');
  }
  if (dartFile == null) {
    throw ArgumentError('Either outputDart or outputPath must be provided.');
  }

  if (!configFile.existsSync()) {
    throw FileSystemException(
      'YAML config file does not exist',
      configFile.path,
    );
  }

  final yamlContent = configFile.readAsStringSync();
  final yamlMap = loadYaml(yamlContent) as YamlMap;

  final resolver = _PathResolver(
    yamlConfigFile: configFile,
    outputDartFile: dartFile,
  );

  final buf = StringBuffer();

  // License header
  buf.writeln(
    '// Copyright (c) 2026, the Dart project authors. Please see the '
    'AUTHORS file\n'
    '// for details. All rights reserved. Use of this source code is '
    'governed by a\n'
    '// BSD-style license that can be found in the LICENSE file.\n',
  );

  // Static imports block
  buf.writeln('// ignore_for_file: unused_import');
  buf.writeln("import 'dart:io';");
  buf.writeln("import 'package:ffigen/ffigen.dart';");
  buf.writeln("import 'package:glob/glob.dart';\n");

  // Top-level declarations (type-map)
  _emitTopLevelDeclarations(buf, yamlMap);

  // getConfig function
  buf.writeln('FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {');
  buf.writeln('packageRoot ??= ${resolver.packageRootDefaultExpr};');
  if (!resolver.isConfigDirAtPackageRoot) {
    buf.writeln('final configDir = ${resolver.configDirExpr};');
  }

  // Path redirections
  _emitPathRedirections(buf, yamlMap, resolver);

  buf.writeln('return FfiGenerator(');

  // Output
  _emitOutput(buf, yamlMap, resolver);

  // Input
  _emitInput(buf, yamlMap, resolver);

  // Objective-C
  _emitObjectiveC(buf, yamlMap);

  // C++
  if (yamlMap.containsKey('cpp')) {
    buf.writeln('cpp: const Cpp(),');
  }

  // ImportType
  _emitImportTypeArgument(buf, yamlMap, resolver);

  // Visitors
  final visitors = _emitVisitors(yamlMap);
  if (visitors != null) {
    buf.write(visitors);
  }

  buf.writeln(');');
  buf.writeln('}\n');

  // main function
  buf.writeln('''Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty
      ? Uri.directory(args.first)
      : Platform.environment['OUTPUT_DIR'] != null
          ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
          : null;
  await getConfig(outputDir: outputDir).generate();
}
''');

  final parentDir = dartFile.parent;
  if (!parentDir.existsSync()) {
    parentDir.createSync(recursive: true);
  }
  dartFile.writeAsStringSync(buf.toString());

  Process.runSync(Platform.resolvedExecutable, [
    'format',
    dartFile.absolute.path,
  ], workingDirectory: dartFile.parent.absolute.path);
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
String _strMap(Map<String, String> m) =>
    '{${m.entries.map((e) => "${_str(e.key)}: ${_str(e.value)}").join(', ')}}';

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
  final usedLibs = <String>{};

  for (final section in typeMap.values) {
    if (section is Map) {
      for (final entry in section.values) {
        if (entry is Map && entry.containsKey('lib')) {
          usedLibs.add(entry['lib'] as String);
        }
      }
    }
  }

  for (final lib in usedLibs) {
    final varName = _libImportVarName(lib);
    if (lib == 'ffi') {
      buf.writeln("const $varName = LibraryImport('ffi', 'dart:ffi');");
    } else if (libImports.containsKey(lib)) {
      final importPath = libImports[lib] as String;
      buf.writeln("const $varName = LibraryImport('$lib', '$importPath');");
    } else {
      buf.writeln("const $varName = LibraryImport('$lib', '$lib');");
    }
  }

  buf.writeln('\nImportedType? importType(Declaration declaration) {');
  for (final section in typeMap.values) {
    if (section is Map) {
      for (final entry in section.entries) {
        final typeName = entry.key as String;
        final typeInfo = entry.value as Map;
        final lib = typeInfo['lib'] as String? ?? 'ffi';
        final cType = typeInfo['c-type'] as String? ?? typeName;
        final dartType = typeInfo['dart-type'] as String? ?? typeName;
        final libVar = _libImportVarName(lib);

        buf.writeln(
          "if (declaration.originalName == '$typeName') {"
          "return ImportedType($libVar, '$cType', '$dartType', '$typeName');"
          '}',
        );
      }
    }
  }
  buf.writeln('return null;\n}\n');
}

String _libImportVarName(String lib) {
  if (lib == 'ffi') return 'ffiImport';
  final parts = lib.split(RegExp(r'[-_]'));
  final camel =
      parts.first.toLowerCase() +
      parts
          .skip(1)
          .map(
            (p) => p.isEmpty
                ? ''
                : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}',
          )
          .join();
  return camel.toLowerCase().endsWith('import') ? camel : '${camel}Import';
}

void _emitPathRedirections(
  StringBuffer buf,
  YamlMap yamlMap,
  _PathResolver resolver,
) {
  final hasObjc = yamlMap['language'] == 'objc';
  final hasCpp = yamlMap.containsKey('cpp');
  final output = yamlMap['output'];

  String rawDart;
  String? rawObjc;
  String? rawSymbol;

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
      rawSymbol = (output['symbol-file'] as Map)['output'] as String;
    }
  } else {
    throw ArgumentError('Invalid output: $output');
  }

  final dartFileName = p.basename(rawDart);
  final normalDart = resolver.emitPath(rawDart);
  buf.writeln(
    'final dartPath = outputDir != null ? '
    "outputDir.resolve('$dartFileName') : $normalDart;",
  );
  if (rawObjc != null) {
    final objcFileName = p.basename(rawObjc);
    final normalObjc = resolver.emitPath(rawObjc);
    buf.writeln(
      'final objcPath = outputDir != null ? '
      "outputDir.resolve('$objcFileName') : $normalObjc;",
    );
  }
  if (hasCpp) {
    final cppFileName = '${p.basename(rawDart)}.cpp';
    final normalCpp = resolver.emitPath('$rawDart.cpp');
    buf.writeln(
      'final cppPath = outputDir != null ? '
      "outputDir.resolve('$cppFileName') : $normalCpp;",
    );
  }
  if (rawSymbol != null) {
    final symFileName = p.basename(rawSymbol);
    final normalSym = resolver.emitPath(rawSymbol);
    buf.writeln(
      'final symbolFilePath = outputDir != null ? '
      "outputDir.resolve('$symFileName') : $normalSym;",
    );
  }
}

void _emitOutput(StringBuffer buf, YamlMap yamlMap, _PathResolver resolver) {
  final hasObjc = yamlMap['language'] == 'objc';
  final hasCpp = yamlMap.containsKey('cpp');
  final output = yamlMap['output'];

  String? rawObjc;
  String? rawSymbolOutput;
  String? rawSymbolImport;

  if (output is String) {
    rawObjc = hasObjc ? '$output.m' : null;
  } else if (output is Map) {
    if (output.containsKey('objc-bindings')) {
      rawObjc = output['objc-bindings'] as String;
    } else if (hasObjc) {
      rawObjc = '${output['bindings']}.m';
    }
    if (output.containsKey('symbol-file')) {
      final sym = output['symbol-file'] as Map;
      rawSymbolOutput = sym['output'] as String;
      rawSymbolImport = sym['import-path'] as String;
    }
  }

  buf.writeln('output: Output(');
  buf.writeln('dart: DartOutput(path: dartPath),');
  if (rawObjc != null) {
    buf.writeln('objectiveCFile: objcPath,');
  }
  if (hasCpp) {
    buf.writeln('cppFile: cppPath,');
  }
  if (rawSymbolOutput != null) {
    buf.writeln(
      "symbolFile: SymbolFile(Uri.parse('$rawSymbolImport'), symbolFilePath),",
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

void _emitInput(StringBuffer buf, YamlMap yamlMap, _PathResolver resolver) {
  buf.writeln('input: Input(');

  final headers = yamlMap['headers'] as Map?;
  if (headers != null) {
    final entryPoints = headers['entry-points'] as List?;
    if (entryPoints != null && entryPoints.isNotEmpty) {
      buf.writeln('entryPoints: [');
      for (final ep in entryPoints) {
        buf.writeln('${resolver.emitPath(ep.toString())},');
      }
      buf.writeln('],');
    }

    final includeDirectives = headers['include-directives'] as List?;
    if (includeDirectives != null && includeDirectives.isNotEmpty) {
      final globChecks = includeDirectives
          .map(
            (p) =>
                'Glob(${_str(_globPattern(p.toString()))}).matches(uri.path)',
          )
          .join(' || ');
      buf.writeln('include: (uri) => $globChecks,');
    }
  }

  final compilerOpts = yamlMap['compiler-opts'];
  if (compilerOpts != null) {
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

    if (opts.isNotEmpty) {
      final auto = yamlMap['compiler-opts-automatic'] as Map?;
      final macAuto = auto?['macos'] as Map?;
      final includeMacStdLib = macAuto?['include-c-standard-library'] != false;
      final hasSysroot = opts.any(
        (o) => o.contains('-isysroot') || o.contains('MacOSX.sdk'),
      );

      buf.writeln('compilerOptions: [');
      for (final opt in opts) {
        buf.writeln('${resolver.emitCompilerOption(opt)},');
      }
      if (includeMacStdLib && !hasSysroot) {
        buf.writeln("if (Platform.isMacOS) ...['-isysroot', macSdkPath],");
      }
      buf.writeln('],');
    }
  }

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
  _PathResolver resolver,
) {
  final typeMap = yamlMap['type-map'];
  final hasTypeMap = typeMap is Map && typeMap.isNotEmpty;

  final importMap = yamlMap['import'];
  final syms = importMap is Map
      ? (importMap['symbol-files'] as List?)?.cast<String>()
      : null;
  final hasSymbolFiles = syms != null && syms.isNotEmpty;

  if (hasSymbolFiles && !hasTypeMap) {
    if (syms.length == 1) {
      final pathExpr = resolver.emitPath(syms.first);
      buf.writeln('importType: importFromSymbolFile($pathExpr),');
    } else {
      final exprs = syms.map(resolver.emitPath).join(', ');
      buf.writeln('importType: importFromSymbolFiles([$exprs]),');
    }
  } else if (hasTypeMap) {
    buf.writeln('importType: importType,');
  }
}

String? _emitVisitors(Map<dynamic, dynamic> yamlMap) {
  final excludeAll = yamlMap['exclude-all-by-default'] == true;
  bool has(String k) => yamlMap.containsKey(k) && yamlMap[k] != null;
  Map<dynamic, dynamic>? sec(String k) => yamlMap[k] as Map<dynamic, dynamic>?;

  final callbacks = <String, String>{};

  // func
  if (has('functions') || !excludeAll) {
    final cfg = sec('functions') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAll,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    if (cfg.containsKey('leaf')) {
      final leaf = cfg['leaf'];
      if (leaf is bool) {
        stmts.add('node.isLeaf = $leaf;');
      } else if (leaf is Map) {
        final cond = _buildCondition(
          (leaf['include'] as List?)?.cast<String>(),
          (leaf['exclude'] as List?)?.cast<String>(),
          'node.originalName',
        );
        if (cond == 'true') {
          stmts.add('node.isLeaf = true;');
        } else if (cond != 'false') {
          stmts.add('node.isLeaf = $cond;');
        }
      }
    }
    final symAddr = cfg['symbol-address'] as Map?;
    final symInc = (symAddr?['include'] as List?)?.cast<String>();
    if (symInc != null && symInc.isNotEmpty) {
      final cond = _buildCondition(symInc, null, 'node.originalName');
      stmts.add('if ($cond) { node.exposeSymbolAddress = true; }');
    }
    final expTypedefs = cfg['expose-typedefs'] as Map?;
    final expInc = (expTypedefs?['include'] as List?)?.cast<String>();
    if (expInc != null && expInc.isNotEmpty) {
      final cond = _buildCondition(expInc, null, 'node.originalName');
      stmts.add('if ($cond) { node.generateTypedefs = true; }');
    }
    callbacks['func'] = _formatCallback(stmts);
  }

  // struct
  if (has('structs') || !excludeAll) {
    final cfg = sec('structs') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAll,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    final depOnly = cfg['dependency-only'] == 'opaque' ? 'opaque' : 'full';
    stmts.add('node.dependencies = CompoundDependencies.$depOnly;');
    if (cfg['pack'] is Map) {
      for (final entry in (cfg['pack'] as Map).entries) {
        final cond = _nameCond('node.originalName', entry.key.toString());
        final val = entry.value == 'none' ? 'null' : entry.value.toString();
        stmts.add('if ($cond) { node.pack = $val; }');
      }
    }
    callbacks['struct'] = _formatCallback(stmts);
  }

  // union
  if (has('unions') || !excludeAll) {
    final cfg = sec('unions') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAll,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    final depOnly = cfg['dependency-only'] == 'opaque' ? 'opaque' : 'full';
    stmts.add('node.dependencies = CompoundDependencies.$depOnly;');
    callbacks['union'] = _formatCallback(stmts);
  }

  // enumClass
  if (has('enums') || yamlMap['silence-enum-warning'] == true || !excludeAll) {
    final cfg = sec('enums') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAll,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    final asInt = cfg['as-int'] as Map?;
    final asIntInc = (asInt?['include'] as List?)?.cast<String>();
    if (asIntInc != null && asIntInc.isNotEmpty) {
      final cond = _buildCondition(asIntInc, null, 'node.originalName');
      stmts.add('if ($cond) { node.style = EnumStyle.intConstants; }');
    }
    if (yamlMap['silence-enum-warning'] == true) {
      stmts.add('node.silenceWarning = true;');
    }
    callbacks['enumClass'] = _formatCallback(stmts);
  }

  // unnamedEnumConstant
  if (has('unnamed-enums')) {
    final cfg = sec('unnamed-enums') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAll,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    callbacks['unnamedEnumConstant'] = _formatCallback(stmts);
  }

  // global
  if (has('globals') || !excludeAll) {
    final cfg = sec('globals') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAll,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    final symAddr = cfg['symbol-address'] as Map?;
    final symInc = (symAddr?['include'] as List?)?.cast<String>();
    if (symInc != null && symInc.isNotEmpty) {
      final cond = _buildCondition(symInc, null, 'node.originalName');
      stmts.add('if ($cond) { node.exposeSymbolAddress = true; }');
    }
    callbacks['global'] = _formatCallback(stmts);
  }

  // macroConstant
  if (has('macros') || !excludeAll) {
    final cfg = sec('macros') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAll,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    callbacks['macroConstant'] = _formatCallback(stmts);
  }

  // typealias
  if (has('typedefs') ||
      yamlMap['include-unused-typedefs'] == true ||
      !excludeAll) {
    final cfg = sec('typedefs') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final includeUnused = yamlMap['include-unused-typedefs'] == true;
    final incList = (cfg['include'] as List?)?.cast<String>();
    final excList = (cfg['exclude'] as List?)?.cast<String>();
    if ((incList != null && incList.isNotEmpty) ||
        (excList != null && excList.isNotEmpty)) {
      final cond = _buildCondition(incList, excList, 'node.originalName');
      final trueVal = includeUnused
          ? 'TypealiasInclude.always'
          : 'TypealiasInclude.ifUsed';
      stmts.add(
        'node.isIncluded = ($cond) ? $trueVal : TypealiasInclude.never;',
      );
    } else if (includeUnused) {
      stmts.add('node.isIncluded = TypealiasInclude.always;');
    } else if (!excludeAll) {
      stmts.add('node.isIncluded = TypealiasInclude.ifUsed;');
    }
    _addRenames(cfg, stmts, target: 'node.name');
    callbacks['typealias'] = _formatCallback(stmts);
  }

  // objCInterface
  if (has('objc-interfaces') ||
      yamlMap['include-transitive-objc-categories'] == false) {
    final cfg = sec('objc-interfaces') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    if (cfg['module'] is Map) {
      for (final entry in (cfg['module'] as Map).entries) {
        stmts.add(
          'if (node.originalName == ${_str(entry.key.toString())}) '
          '{ node.module = ${_str(entry.value.toString())}; }',
        );
      }
    }
    if (yamlMap['include-transitive-objc-categories'] == false) {
      stmts.add('node.includeCategories = false;');
    }
    callbacks['objCInterface'] = _formatCallback(stmts);
  }

  // objCProtocol
  if (has('objc-protocols')) {
    final cfg = sec('objc-protocols') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    if (cfg['module'] is Map) {
      for (final entry in (cfg['module'] as Map).entries) {
        stmts.add(
          'if (node.originalName == ${_str(entry.key.toString())}) '
          '{ node.module = ${_str(entry.value.toString())}; }',
        );
      }
    }
    callbacks['objCProtocol'] = _formatCallback(stmts);
  }

  // objCCategory
  if (has('objc-categories')) {
    final cfg = sec('objc-categories') ?? const <dynamic, dynamic>{};
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) stmts.add(inc);
    _addRenames(cfg, stmts, target: 'node.name');
    callbacks['objCCategory'] = _formatCallback(stmts);
  }

  // cppClass
  final cpp = sec('cpp');
  final cppClasses = cpp?['cpp-classes'] as Map<dynamic, dynamic>?;
  if (cppClasses != null) {
    final stmts = <String>[];
    final inc = _buildInclusionStatement(
      cppClasses,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) stmts.add(inc);
    callbacks['cppClass'] = _formatCallback(stmts);
  }

  // objCMethod
  final hasObjCMethod = ['objc-interfaces', 'objc-protocols', 'objc-categories']
      .any(
        (k) =>
            sec(k)?['member-filter'] != null ||
            sec(k)?['member-rename'] != null,
      );
  if (hasObjCMethod) {
    final stmts = ['final parent = node.parent;'];
    for (final (k, type) in [
      ('objc-interfaces', 'ObjCInterface'),
      ('objc-protocols', 'ObjCProtocol'),
      ('objc-categories', 'ObjCCategory'),
    ]) {
      final c = sec(k);
      if (c != null) {
        _emitMemberSection(
          stmts,
          parentType: type,
          filterMap: c['member-filter'] as Map<dynamic, dynamic>?,
          renameMap: c['member-rename'] as Map<dynamic, dynamic>?,
          nameProp: 'node.selector',
        );
      }
    }
    callbacks['objCMethod'] = _formatCallback(stmts);
  }

  // field
  final hasField = [
    'structs',
    'unions',
  ].any((k) => sec(k)?['member-rename'] != null);
  if (hasField) {
    final stmts = ['final parent = node.parent;'];
    for (final (k, type) in [('structs', 'Struct'), ('unions', 'Union')]) {
      final c = sec(k);
      if (c != null) {
        _emitMemberSection(
          stmts,
          parentType: type,
          renameMap: c['member-rename'] as Map<dynamic, dynamic>?,
          nameProp: 'node.originalName',
        );
      }
    }
    callbacks['field'] = _formatCallback(stmts);
  }

  // param
  final funcCfg = sec('functions');
  if (funcCfg?['member-rename'] != null) {
    final stmts = ['final parent = node.parent;'];
    _emitMemberSection(
      stmts,
      parentType: 'Func',
      renameMap: funcCfg!['member-rename'] as Map<dynamic, dynamic>?,
      nameProp: 'node.originalName',
    );
    callbacks['param'] = _formatCallback(stmts);
  }

  // enumConstant
  final enumCfg = sec('enums');
  if (enumCfg?['member-rename'] != null) {
    final stmts = ['final parent = node.parent;'];
    _emitMemberSection(
      stmts,
      parentType: null,
      renameMap: enumCfg!['member-rename'] as Map<dynamic, dynamic>?,
      nameProp: 'node.originalName',
    );
    callbacks['enumConstant'] = _formatCallback(stmts);
  }

  if (callbacks.isEmpty) return null;

  final buf = StringBuffer('visitors: [Visitor(\n');
  for (final entry in callbacks.entries) {
    buf.writeln('${entry.key}: ${entry.value},');
  }
  buf.writeln(')],');
  return buf.toString();
}

void _emitMemberSection(
  List<String> stmts, {
  String? parentType,
  Map<dynamic, dynamic>? filterMap,
  Map<dynamic, dynamic>? renameMap,
  required String nameProp,
}) {
  final sub = <String>[];
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
        sub.add(
          'if ($parentCond && $nameProp == ${_str(exc.first)}) '
          '{ node.isIncluded = false; }',
        );
      } else {
        final cond = _buildCondition(inc, exc, nameProp);
        sub.add('if ($parentCond) { node.isIncluded = $cond; }');
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
          sub.add(
            'if ($parentCond && $nameProp == ${_str(from)}) '
            '{ node.name = ${_str(to)}; }',
          );
        } else if (!to.contains(r'$')) {
          final pat = _regexPat(from);
          sub.add(
            'if ($parentCond && RegExp(r\'^$pat\$\').hasMatch($nameProp)) '
            '{ node.name = ${_str(to)}; }',
          );
        } else {
          final pat = _regexPat(from);
          sub.add(
            'if ($parentCond) { '
            'if (RegExp(r\'^$pat\$\').firstMatch($nameProp) '
            'case final match?) { '
            'node.name = r\'$to\'.replaceAllMapped(RegExp(r\'\\\$([0-9])\'), '
            '(m) => match[int.parse(m[1]!)] ?? \'\'); } }',
          );
        }
      }
    }
  }
  if (sub.isEmpty) return;
  if (parentType != null) {
    stmts.add('if (parent is $parentType) {\n${sub.join('\n')}\n}');
  } else {
    stmts.addAll(sub);
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
    if (parts.contains('true')) {
      incCond = 'true';
    } else if (parts.length == 1) {
      incCond = parts.first;
    } else {
      incCond = parts.join(' || ');
    }
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
    if (parts.length == 1) {
      excCond = parts.first;
    } else {
      excCond = parts.join(' && ');
    }
  }

  if (incCond != null && excCond != null) {
    if (incCond == 'true') return excCond;
    final parenInc = incCond.contains(' || ') ? '($incCond)' : incCond;
    return '$excCond && $parenInc';
  }
  if (incCond != null) return incCond;
  if (excCond != null) return excCond;
  return 'true';
}

String? _buildInclusionStatement(
  Map<dynamic, dynamic> cfg, {
  required String target,
  required bool defaultInclude,
}) {
  final includes = (cfg['include'] as List?)?.cast<String>();
  final excludes = (cfg['exclude'] as List?)?.cast<String>();
  if (includes == null && excludes == null) {
    return defaultInclude ? 'node.isIncluded = true;' : null;
  }
  final cond = _buildCondition(includes, excludes, target);
  return 'node.isIncluded = $cond;';
}

void _addRenames(
  Map<dynamic, dynamic> cfg,
  List<String> stmts, {
  required String target,
}) {
  final rename = cfg['rename'] as Map?;
  if (rename == null || rename.isEmpty) return;
  final exact = <String, String>{};
  final regex = <String, String>{};
  for (final entry in rename.entries) {
    final from = entry.key.toString();
    final to = entry.value.toString();
    if (_isExact(from)) {
      exact[from] = to;
    } else {
      regex[from] = to;
    }
  }
  if (exact.isNotEmpty) {
    if (exact.length == 1) {
      stmts.add(
        'if ($target == ${_str(exact.keys.first)}) '
        '{ $target = ${_str(exact.values.first)}; }',
      );
    } else {
      stmts.add('const rename = ${_strMap(exact)};');
      stmts.add('if (rename[$target] case final r?) { $target = r; }');
    }
  }
  final multiRegex = regex.length > 1;
  for (final entry in regex.entries) {
    final from = entry.key;
    final to = entry.value;
    if (to == r'$1' && !from.startsWith('^') && from.endsWith(r'(.*)')) {
      final prefix = from.substring(0, from.length - 4);
      stmts.add("$target = $target.replaceFirst(RegExp(r'^$prefix'), '');");
    } else if (!to.contains(r'$')) {
      final pat = _regexPat(from);
      stmts.add(
        'if (RegExp(r\'^$pat\$\').hasMatch($target)) '
        '{ $target = ${_str(to)}; }',
      );
    } else {
      final pat = _regexPat(from);
      if (multiRegex) {
        stmts.add(
          'if (RegExp(r\'^$pat\$\').firstMatch($target) '
          'case final match?) { '
          'node.name = r\'$to\'.replaceAllMapped(RegExp(r\'\\\$([0-9])\'), '
          '(m) => match[int.parse(m[1]!)] ?? \'\'); }',
        );
      } else {
        stmts.add(
          'final match = RegExp(r\'^$pat\$\').firstMatch($target);\n'
          'if (match != null) { '
          'node.name = r\'$to\'.replaceAllMapped(RegExp(r\'\\\$([0-9])\'), '
          '(m) => match[int.parse(m[1]!)] ?? \'\'); }',
        );
      }
    }
  }
}

String _formatCallback(List<String> statements) {
  if (statements.isEmpty) return '(node) {}';
  if (statements.length == 1 &&
      !statements.first.contains('\n') &&
      statements.first.endsWith(';') &&
      !statements.first.startsWith('if ') &&
      !statements.first.startsWith('if(') &&
      !statements.first.startsWith('const ') &&
      !statements.first.startsWith('final ')) {
    final s = statements.first;
    return '(node) => ${s.substring(0, s.length - 1)}';
  }
  return '(node) {\n${statements.join('\n')}\n}';
}

class _PathResolver {
  final File yamlConfigFile;
  final File outputDartFile;

  late final String origConfigPath;
  late final String configDir;
  late final Directory packageRoot;

  _PathResolver({required this.yamlConfigFile, required this.outputDartFile}) {
    origConfigPath = _resolveConfigPath(yamlConfigFile.path);
    configDir = p.dirname(origConfigPath);
    packageRoot = _findPackageRoot(configDir);
  }

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

  String get packageRootDefaultExpr {
    final rel = p.relative(packageRoot.path, from: _effectiveOutputDartDir);
    final posixRel = p.posix.normalize(p.split(rel).join('/'));
    if (posixRel == '.' || posixRel.isEmpty) {
      return "Platform.script.resolve('./')";
    }
    return "Platform.script.resolve('$posixRel/')";
  }

  String get configDirExpr {
    if (isConfigDirAtPackageRoot) return 'packageRoot';
    final rel = p.relative(configDir, from: packageRoot.path);
    final posixRel = p.posix.normalize(p.split(rel).join('/'));
    return "packageRoot.resolve('$posixRel/')";
  }

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

  String emitCompilerOption(String opt) {
    if (!opt.startsWith('-I')) {
      return _str(opt);
    }
    final incPath = opt.substring(2);
    if (!p.isRelative(incPath)) {
      return _str(opt);
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

    final optStr = "'-I\${$expr}'";
    if (optStr.length + 10 > 80) {
      return '// ignore: lines_longer_than_80_chars\n$optStr';
    }
    return optStr;
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
