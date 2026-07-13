// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Generates Dart source code for a `FfiGenerator` script that's equivalent
/// to a legacy YAML ffigen configuration.
///
/// This is a best-effort, syntactic translation performed directly on the raw
/// YAML: exact strings (header globs, include/exclude patterns, renames,
/// paths, etc.) are preserved rather than going through `YamlConfig`'s
/// validation/extraction pipeline. Constructs that don't map cleanly onto the
/// public `FfiGenerator` Dart API are emitted as `// TODO(ffigen migration):`
/// comments so that nothing from the original config is silently dropped.
library;

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import 'spec_utils.dart' show compilerOptsToList, headersExtractor;
import 'utils.dart' show normalizePath;

/// Generates a Dart script equivalent to [yaml], a parsed legacy ffigen YAML
/// configuration.
///
/// [configFilename] is the path to the YAML file (or `pubspec.yaml`) that
/// [yaml] was loaded from. It's used to resolve relative paths the same way
/// the legacy YAML config does.
///
/// [outputFilePath] is the path the generated Dart script will be written to.
/// It's used to compute paths in the generated script that are relative to
/// the script itself (using `Platform.script`), so the script keeps working
/// if the whole package is moved or checked out elsewhere.
String emitDartConfig(
  YamlMap yaml, {
  String? configFilename,
  required String outputFilePath,
}) {
  return _YamlToDartEmitter(
    yaml,
    configFilename: configFilename,
    outputFilePath: outputFilePath,
  ).emit();
}

class _NamePattern {
  final Set<String> full;
  final List<String> regex;
  _NamePattern(this.full, this.regex);
  bool get isEmpty => full.isEmpty && regex.isEmpty;
}

bool _isFullDeclarationName(String s) => RegExp(r'^[a-zA-Z_0-9]*$').hasMatch(s);

const _sdkVars = {
  r'$XCODE': 'xcodePath',
  r'$IOS_SDK': 'iosSdkPath',
  r'$MACOS_SDK': 'macSdkPath',
};

bool _hasSdkVar(String s) => _sdkVars.keys.any(s.contains);

/// Whether [s] contains any special characters of `package:glob`'s syntax.
bool _containsGlobChars(String s) => s.contains(RegExp(r'[*?\[\]{}]'));

const _builtInLibraryImportPaths = {
  'ffi': 'dart:ffi',
  'pkg_ffi': 'package:ffi/ffi.dart',
  'meta': 'package:meta/meta.dart',
  'objc': 'package:objective_c/objective_c.dart',
  'self': '',
};

class _YamlToDartEmitter {
  final YamlMap yaml;
  final String? configFilename;
  final String outputFilePath;

  final List<String> todos = [];
  bool needsIncluderHelpers = false;
  bool needsRenameHelpers = false;
  bool needsModuleHelper = false;
  bool needsPackingHelper = false;
  bool needsLogger = false;

  late final bool excludeAllByDefault =
      yaml[strings.excludeAllByDefault] == true;
  late final bool isObjC =
      (yaml[strings.language] as String?) == strings.langObjC;
  late final String _configDirPath = configFilename != null
      ? p.dirname(p.absolute(configFilename!))
      : p.absolute('.');
  late final String _outputDirPath = p.dirname(p.absolute(outputFilePath));
  late final Map<String, String> _libraryImportPaths = {
    for (final e
        in (yaml[strings.libraryImports] as YamlMap?)?.entries ??
            const <MapEntry<dynamic, dynamic>>[])
      e.key.toString(): e.value.toString(),
  };

  final _logger = Logger('ffigen.migrate');

  _YamlToDartEmitter(
    this.yaml, {
    required this.configFilename,
    required this.outputFilePath,
  });

  static const _knownTopLevelKeys = {
    strings.excludeAllByDefault,
    strings.llvmPath,
    strings.output,
    strings.language,
    strings.headers,
    strings.ignoreSourceErrors,
    strings.compilerOpts,
    strings.compilerOptsAuto,
    strings.libraryImports,
    strings.functions,
    strings.structs,
    strings.unions,
    strings.enums,
    strings.unnamedEnums,
    strings.globals,
    strings.macros,
    strings.typedefs,
    strings.objcInterfaces,
    strings.objcProtocols,
    strings.objcCategories,
    strings.import,
    strings.typeMap,
    strings.includeUnusedTypedefs,
    strings.includeTransitiveObjCInterfaces,
    strings.includeTransitiveObjCProtocols,
    strings.includeTransitiveObjCCategories,
    strings.generateForPackageObjectiveC,
    strings.sort,
    strings.useSupportedTypedefs,
    strings.comments,
    strings.name,
    strings.description,
    strings.preamble,
    strings.ffiNative,
    strings.silenceEnumWarning,
    strings.externalVersions,
  };

  String emit() {
    for (final key in yaml.keys) {
      final keyStr = key.toString();
      if (!_knownTopLevelKeys.contains(keyStr)) {
        todos.add("Unhandled top-level key '$keyStr' was not migrated.");
      }
    }

    if (yaml[strings.sort] == true) {
      todos.add(
        "'${strings.sort}: true' has no equivalent in the Dart API and "
        'was dropped.',
      );
    }

    final llvmPathRaw = yaml[strings.llvmPath];
    if (llvmPathRaw != null) {
      todos.add(
        "'${strings.llvmPath}: $llvmPathRaw' has no direct equivalent. "
        'Pass a resolved path to the `libclangDylib` parameter of '
        '`generate()` instead, e.g. '
        "generator.generate(libclangDylib: Uri.file('/path/to/libclang.so'))",
      );
    }
    if (yaml.containsKey(strings.import)) {
      final symbolFiles =
          (yaml[strings.import] as YamlMap?)?[strings.symbolFilesImport];
      if (symbolFiles != null) {
        todos.add(
          "'${strings.import} -> ${strings.symbolFilesImport}: "
          '$symbolFiles\' was not migrated. Symbol file imports need to be '
          'ported to `FfiGenerator.importedTypesByUsr` by hand.',
        );
      }
    }
    if ((yaml[strings.unnamedEnums] as YamlMap?)?.containsKey(
          strings.enumAsInt,
        ) ==
        true) {
      todos.add(
        "'${strings.unnamedEnums} -> ${strings.enumAsInt}' has no "
        'equivalent in the Dart API (`UnnamedEnums` has no int-style '
        'option) and was dropped.',
      );
    }
    for (final section in [strings.functions]) {
      final varArgs = (yaml[section] as YamlMap?)?[strings.varArgFunctions];
      if (varArgs != null) {
        todos.add(
          "'$section -> ${strings.varArgFunctions}: $varArgs' was not "
          'migrated. Variadic function overrides need to be ported to '
          '`Functions.varArgs` by hand (the `Type` hierarchy used to '
          'build `VarArgFunction`s is not yet part of the public API).',
        );
      }
    }

    final headers = _buildHeaders();
    final output = _buildOutput();

    final ctorParams = <String, String>{'headers': headers, 'output': output};

    void addSection(String param, String? expr) {
      if (expr != null) ctorParams[param] = expr;
    }

    addSection('functions', _buildFunctions());
    addSection('structs', _buildStructsOrUnions(strings.structs, 'Structs'));
    addSection('unions', _buildStructsOrUnions(strings.unions, 'Unions'));
    addSection('enums', _buildEnums());
    addSection(
      'unnamedEnums',
      _buildDeclSection(strings.unnamedEnums, 'UnnamedEnums'),
    );
    addSection('globals', _buildGlobals());
    addSection('macros', _buildDeclSection(strings.macros, 'Macros'));
    addSection('typedefs', _buildTypedefs());
    addSection('integers', _buildIntegers());
    if (isObjC) ctorParams['objectiveC'] = _buildObjectiveC();

    final buf = StringBuffer();
    if (todos.isNotEmpty) {
      buf.writeln('// TODO(ffigen migration): review the following before');
      buf.writeln('// relying on this generated script:');
      for (final todo in todos) {
        for (final line in _wrapComment(todo)) {
          buf.writeln('// $line');
        }
      }
      buf.writeln();
    }
    buf.writeln("import 'dart:io';");
    buf.writeln();
    buf.writeln("import 'package:ffigen/ffigen.dart';");
    buf.writeln();

    if (needsIncluderHelpers ||
        needsRenameHelpers ||
        needsModuleHelper ||
        needsPackingHelper) {
      buf.writeln(_helperSource());
    }

    buf.writeln('void main() {');
    buf.writeln(
      "  final packageRoot = Platform.script.resolve('$_packageRootRelPath');",
    );
    if (needsLogger) {
      buf.writeln("  final logger = Logger('ffigen');");
    }
    buf.writeln('  FfiGenerator(');
    for (final entry in ctorParams.entries) {
      buf.writeln('    ${entry.key}: ${entry.value},');
    }
    buf.writeln('  ).generate();');
    buf.writeln('}');

    return buf.toString();
  }

  String get _packageRootRelPath {
    final rel = p.relative(_configDirPath, from: _outputDirPath);
    return '${_toPosix(rel)}/';
  }

  // ---------------------------------------------------------------------
  // headers
  // ---------------------------------------------------------------------

  String _buildHeaders() {
    final headers = yaml[strings.headers] as YamlMap;
    final entryPointsRaw = (headers[strings.entryPoints] as YamlList)
        .map((e) => e.toString())
        .toList();

    final entryExprs = <String>[];
    for (final raw in entryPointsRaw) {
      if (_hasSdkVar(raw)) {
        entryExprs.add('Uri.file(${_interpolated(raw)})');
        if (raw.contains('*') || raw.contains('?')) {
          todos.add(
            "Header entry point '$raw' contains an SDK variable and a "
            'glob pattern; globs are not supported once SDK variables are '
            'involved, so it was kept as a single literal path. Expand it '
            'manually if needed.',
          );
        }
      } else if (_containsGlobChars(raw)) {
        // Globs can only be expanded against the filesystem, so this is done
        // at migration time; the expansion is frozen into the script.
        final resolved = headersExtractor(_logger, {
          strings.entryPoints: [raw],
        }, configFilename);
        if (resolved.entryPoints.isEmpty) {
          todos.add(
            "Header entry point glob '$raw' matched no files when this "
            'script was generated, so no entry points were emitted for it. '
            'Add the resolved header paths manually.',
          );
        }
        for (final uri in resolved.entryPoints) {
          entryExprs.add(_pathExprForAbsolute(uri.toFilePath()));
        }
      } else {
        // A plain path: emit it as-is, without checking that it exists, so
        // that migration works even when the headers aren't present (e.g. a
        // fresh checkout).
        entryExprs.add(
          _pathExprForAbsolute(normalizePath(raw, configFilename)),
        );
      }
    }

    final params = <String>['entryPoints: [${entryExprs.join(', ')}]'];

    final includeDirectives = headers[strings.includeDirectives] as YamlList?;
    if (includeDirectives != null && includeDirectives.isNotEmpty) {
      final globExprs = includeDirectives
          .map((raw) {
            final s = raw.toString();
            if (_hasSdkVar(s)) return _interpolated(s);
            return _q(normalizePath(s, configFilename));
          })
          .join(', ');
      params.add('include: Headers.includeGlobs([$globExprs])');
    }

    final compilerOptions = _buildCompilerOptions();
    if (compilerOptions != null) {
      params.add('compilerOptions: $compilerOptions');
    }

    if (yaml[strings.ignoreSourceErrors] == true) {
      params.add('ignoreSourceErrors: true');
    }

    return 'Headers(${params.join(',\n')})';
  }

  String? _buildCompilerOptions() {
    final opts = <String>[];
    final raw = yaml[strings.compilerOpts];
    if (raw is String) {
      opts.addAll(compilerOptsToList(raw).map(_interpolatedOrLiteral));
    } else if (raw is YamlList) {
      opts.addAll(
        raw
            .map((e) => e.toString())
            .expand(compilerOptsToList)
            .map(_interpolatedOrLiteral),
      );
    }

    final auto = yaml[strings.compilerOptsAuto] as YamlMap?;
    String? autoExpr;
    if (auto != null) {
      final macIncludeStdLib =
          (auto[strings.macos] as YamlMap?)?[strings.includeCStdLib];
      needsLogger = true;
      autoExpr = macIncludeStdLib == false
          ? 'defaultCompilerOpts(logger, macIncludeStdLib: false)'
          : 'defaultCompilerOpts(logger)';
    }

    if (opts.isEmpty && autoExpr == null) return null;
    final items = <String>[if (autoExpr != null) '...$autoExpr', ...opts];
    return '[${items.join(', ')}]';
  }

  // ---------------------------------------------------------------------
  // output
  // ---------------------------------------------------------------------

  String _buildOutput() {
    final params = <String>[];
    final outputRaw = yaml[strings.output];
    if (outputRaw is String) {
      params.add('dartFile: ${_pathExpr(outputRaw)}');
    } else {
      final map = outputRaw as YamlMap;
      params.add('dartFile: ${_pathExpr(map[strings.bindings] as String)}');
      final objcBindings = map[strings.objCBindings] as String?;
      if (objcBindings != null) {
        params.add('objectiveCFile: ${_pathExpr(objcBindings)}');
      }
      final symbolFile = map[strings.symbolFile] as YamlMap?;
      if (symbolFile != null) {
        final importExpr = _pathExpr(symbolFile[strings.importPath] as String);
        final outExpr = _pathExpr(symbolFile[strings.output] as String);
        params.add('symbolFile: SymbolFile($importExpr, $outExpr)');
      }
    }

    final commentExpr = _buildCommentType();
    if (commentExpr != null) params.add('commentType: $commentExpr');

    final preamble = yaml[strings.preamble] as String?;
    if (preamble != null) params.add('preamble: ${_q(preamble)}');

    params.add('style: ${_buildBindingStyle()}');

    return 'Output(${params.join(',\n')})';
  }

  String? _buildCommentType() {
    if (!yaml.containsKey(strings.comments)) return null;
    final val = yaml[strings.comments];
    if (val is bool) {
      return val ? 'const CommentType.def()' : 'const CommentType.none()';
    }
    final map = val as YamlMap;
    final styleVal = map[strings.style] as String?;
    final lengthVal = map[strings.length] as String?;
    final style = styleVal == strings.any
        ? 'CommentStyle.any'
        : 'CommentStyle.doxygen';
    final length = lengthVal == strings.brief
        ? 'CommentLength.brief'
        : 'CommentLength.full';
    return 'CommentType($style, $length)';
  }

  String _buildBindingStyle() {
    if (yaml.containsKey(strings.ffiNative) &&
        yaml[strings.ffiNative] != null) {
      final map = yaml[strings.ffiNative] as YamlMap;
      final assetId =
          (map[strings.ffiNativeAsset] ?? map['assetId']) as String?;
      if (assetId != null) {
        return 'NativeExternalBindings(assetId: ${_q(assetId)})';
      }
      return 'const NativeExternalBindings()';
    }
    // Either `ffi-native` is absent, or explicitly `ffi-native: null`
    // (disabled): the legacy default is dynamic-library bindings, which
    // differs from the Dart API's own default (native `@Native` bindings).
    final name = (yaml[strings.name] as String?) ?? 'NativeLibrary';
    final description = yaml[strings.description] as String?;
    final params = ['wrapperName: ${_q(name)}'];
    if (description != null) {
      params.add('wrapperDocComment: ${_q(description)}');
    }
    return 'DynamicLibraryBindings(${params.join(', ')})';
  }

  // ---------------------------------------------------------------------
  // declaration sections
  // ---------------------------------------------------------------------

  /// Builds a `Functions`/`UnnamedEnums`/`Macros`/`Typedefs`-shaped section
  /// (include/exclude + rename, no member-rename).
  String? _buildDeclSection(
    String yamlKey,
    String className, {
    bool withMemberRename = false,
  }) {
    final section = yaml[yamlKey] as YamlMap?;
    final params = <String, String>{};
    final includeExpr = _buildInclude(section);
    if (includeExpr != 'Declarations.excludeAll') {
      params['include'] = includeExpr;
    }
    final renameExpr = _buildRename(section?[strings.rename] as YamlMap?);
    if (renameExpr != null) params['rename'] = renameExpr;
    if (withMemberRename) {
      final memberRenameExpr = _buildMemberRename(
        section?[strings.memberRename] as YamlMap?,
      );
      if (memberRenameExpr != null) params['renameMember'] = memberRenameExpr;
    }
    if (params.isEmpty) return null;
    return '$className(${_paramsToString(params)})';
  }

  String? _buildFunctions() {
    final section = yaml[strings.functions] as YamlMap?;
    final params = <String, String>{};
    final includeExpr = _buildInclude(section);
    if (includeExpr != 'Declarations.excludeAll') {
      params['include'] = includeExpr;
    }
    final renameExpr = _buildRename(section?[strings.rename] as YamlMap?);
    if (renameExpr != null) params['rename'] = renameExpr;
    final memberRenameExpr = _buildMemberRename(
      section?[strings.memberRename] as YamlMap?,
    );
    if (memberRenameExpr != null) params['renameMember'] = memberRenameExpr;
    final symbolAddrExpr = _buildSimpleIncluder(
      section?[strings.symbolAddress] as YamlMap?,
    );
    if (symbolAddrExpr != null) params['includeSymbolAddress'] = symbolAddrExpr;
    final exposeExpr = _buildSimpleIncluder(
      section?[strings.exposeFunctionTypedefs] as YamlMap?,
    );
    if (exposeExpr != null) params['includeTypedef'] = exposeExpr;
    final leafExpr = _buildSimpleIncluder(
      section?[strings.leafFunctions] as YamlMap?,
    );
    if (leafExpr != null) params['isLeaf'] = leafExpr;
    if (params.isEmpty) return null;
    return 'Functions(${_paramsToString(params)})';
  }

  String? _buildStructsOrUnions(String yamlKey, String className) {
    final section = yaml[yamlKey] as YamlMap?;
    final params = <String, String>{};
    final includeExpr = _buildInclude(section);
    if (includeExpr != 'Declarations.excludeAll') {
      params['include'] = includeExpr;
    }
    final renameExpr = _buildRename(section?[strings.rename] as YamlMap?);
    if (renameExpr != null) params['rename'] = renameExpr;
    final memberRenameExpr = _buildMemberRename(
      section?[strings.memberRename] as YamlMap?,
    );
    if (memberRenameExpr != null) params['renameMember'] = memberRenameExpr;

    // Legacy default is `full`, Dart default is `opaque`: always emit.
    final dependencyOnly = section?[strings.dependencyOnly] as String?;
    params['dependencies'] =
        dependencyOnly == strings.opaqueCompoundDependencies
        ? 'CompoundDependencies.opaque'
        : 'CompoundDependencies.full';

    if (yamlKey == strings.structs) {
      final packExpr = _buildPackingOverride(
        section?[strings.structPack] as YamlMap?,
      );
      if (packExpr != null) params['packingOverride'] = packExpr;
    }

    final importedExpr = _buildImportedTypeList(
      (yaml[strings.typeMap] as YamlMap?)?[yamlKey == strings.structs
              ? strings.typeMapStructs
              : strings.typeMapUnions]
          as YamlMap?,
    );

    final extra = <String>[
      if (importedExpr != null)
        '// ignore: deprecated_member_use\n    imported: $importedExpr',
    ];
    return '$className(${_buildParamsList(params, extra: extra)})';
  }

  String? _buildPackingOverride(YamlMap? packMap) {
    if (packMap == null || packMap.isEmpty) return null;
    needsPackingHelper = true;
    final entries = packMap.entries
        .map((e) {
          final value = e.value;
          final packingValue = value == 'none' ? 'null' : value.toString();
          final pattern = _rawStringLiteral(e.key.toString());
          return 'MapEntry(RegExp($pattern, dotAll: true), $packingValue)';
        })
        .join(', ');
    return '''
(Declaration decl) {
      final overrides = <MapEntry<RegExp, int?>>[$entries];
      for (final e in overrides) {
        if (_fullRegexMatch(e.key, decl.originalName)) {
          return PackingValue(e.value);
        }
      }
      return null;
    }''';
  }

  /// Joins [params] (rendered as `key: value`) with any pre-rendered [extra]
  /// argument strings (which may include their own leading comments).
  String _buildParamsList(
    Map<String, String> params, {
    List<String> extra = const [],
  }) {
    final parts = [
      for (final e in params.entries) '${e.key}: ${e.value}',
      ...extra,
    ];
    return parts.join(',\n    ');
  }

  String? _buildEnums() {
    final section = yaml[strings.enums] as YamlMap?;
    final params = <String, String>{};
    final includeExpr = _buildInclude(section);
    if (includeExpr != 'Declarations.excludeAll') {
      params['include'] = includeExpr;
    }
    final renameExpr = _buildRename(section?[strings.rename] as YamlMap?);
    if (renameExpr != null) params['rename'] = renameExpr;
    final memberRenameExpr = _buildMemberRename(
      section?[strings.memberRename] as YamlMap?,
    );
    if (memberRenameExpr != null) params['renameMember'] = memberRenameExpr;

    if (section?.containsKey(strings.enumAsInt) == true) {
      final asIntExpr = _buildSimpleIncluder(
        section![strings.enumAsInt] as YamlMap?,
      );
      params['style'] =
          '(Declaration decl, EnumStyle? suggestedStyle) {\n'
          '      if (suggestedStyle != null) return suggestedStyle;\n'
          '      return (${asIntExpr ?? 'Declarations.excludeAll'})(decl)\n'
          '          ? EnumStyle.intConstants\n'
          '          : EnumStyle.dartEnum;\n'
          '    }';
    }

    final silence = _buildSilenceWarning();
    if (silence != null) params['silenceWarning'] = silence;

    if (params.isEmpty) return null;
    return 'Enums(${_paramsToString(params)})';
  }

  String? _buildSilenceWarning() {
    final explicit = yaml[strings.silenceEnumWarning] as bool?;
    final legacyDefault = isObjC;
    final value = explicit ?? legacyDefault;
    return value ? 'true' : null;
  }

  String? _buildGlobals() {
    final section = yaml[strings.globals] as YamlMap?;
    final params = <String, String>{};
    final includeExpr = _buildInclude(section);
    if (includeExpr != 'Declarations.excludeAll') {
      params['include'] = includeExpr;
    }
    final renameExpr = _buildRename(section?[strings.rename] as YamlMap?);
    if (renameExpr != null) params['rename'] = renameExpr;
    final symbolAddrExpr = _buildSimpleIncluder(
      section?[strings.symbolAddress] as YamlMap?,
    );
    if (symbolAddrExpr != null) params['includeSymbolAddress'] = symbolAddrExpr;
    if (params.isEmpty) return null;
    return 'Globals(${_paramsToString(params)})';
  }

  String? _buildTypedefs() {
    final section = yaml[strings.typedefs] as YamlMap?;
    final params = <String, String>{};
    final includeExpr = _buildInclude(section);
    if (includeExpr != 'Declarations.excludeAll') {
      params['include'] = includeExpr;
    }
    final renameExpr = _buildRename(section?[strings.rename] as YamlMap?);
    if (renameExpr != null) params['rename'] = renameExpr;
    if (yaml[strings.includeUnusedTypedefs] == true) {
      params['includeUnused'] = 'true';
    }
    if (yaml[strings.useSupportedTypedefs] == false) {
      params['useSupportedTypedefs'] = 'false';
    }
    final importedExpr = _buildImportedTypeList(
      (yaml[strings.typeMap] as YamlMap?)?[strings.typeMapTypedefs] as YamlMap?,
    );
    final extra = <String>[
      if (importedExpr != null)
        '// ignore: deprecated_member_use\n    imported: $importedExpr',
    ];
    if (params.isEmpty && extra.isEmpty) return null;
    return 'Typedefs(${_buildParamsList(params, extra: extra)})';
  }

  String? _buildIntegers() {
    final importedExpr = _buildImportedTypeList(
      (yaml[strings.typeMap] as YamlMap?)?[strings.typeMapNativeTypes]
          as YamlMap?,
    );
    if (importedExpr == null) return null;
    return 'Integers(\n'
        '    // ignore: deprecated_member_use\n'
        '    imported: $importedExpr,\n'
        '  )';
  }

  String? _buildImportedTypeList(YamlMap? categoryMap) {
    if (categoryMap == null || categoryMap.isEmpty) return null;
    final items = <String>[];
    for (final entry in categoryMap.entries) {
      final nativeType = entry.key.toString();
      final v = entry.value as YamlMap;
      final lib = v[strings.lib] as String;
      final cType = v[strings.cType] as String;
      final dartType = v[strings.dartType] as String;
      items.add(
        'ImportedType(${_libraryImportExpr(lib)}, ${_q(cType)}, '
        '${_q(dartType)}, ${_q(nativeType)})',
      );
    }
    return '[${items.join(', ')}]';
  }

  String _libraryImportExpr(String libName) {
    final path =
        _builtInLibraryImportPaths[libName] ?? _libraryImportPaths[libName];
    if (path == null) {
      todos.add(
        "Unknown library '$libName' referenced from 'type-map'; please fix "
        'the generated `LibraryImport` manually.',
      );
      return 'LibraryImport(${_q(libName)}, ${_q('')})';
    }
    return 'LibraryImport(${_q(libName)}, ${_q(path)})';
  }

  // ---------------------------------------------------------------------
  // Objective-C
  // ---------------------------------------------------------------------

  String _buildObjectiveC() {
    final params = <String>[];

    final interfacesTransitive =
        yaml[strings.includeTransitiveObjCInterfaces] == true ? 'true' : null;
    final protocolsTransitive =
        yaml[strings.includeTransitiveObjCProtocols] == true ? 'true' : null;
    final categoriesTransitiveRaw =
        yaml[strings.includeTransitiveObjCCategories] as bool?;
    final categoriesTransitive = categoriesTransitiveRaw == false
        ? 'false'
        : null;

    final interfaces = _buildObjcClassExpr(
      strings.objcInterfaces,
      'Interfaces',
      includeModule: true,
      transitiveParam: interfacesTransitive,
    );
    if (interfaces != null) params.add('interfaces: $interfaces');

    final protocols = _buildObjcClassExpr(
      strings.objcProtocols,
      'Protocols',
      includeModule: true,
      transitiveParam: protocolsTransitive,
    );
    if (protocols != null) params.add('protocols: $protocols');

    final categories = _buildObjcClassExpr(
      strings.objcCategories,
      'Categories',
      includeModule: false,
      transitiveParam: categoriesTransitive,
    );
    if (categories != null) params.add('categories: $categories');

    final extVersions = _buildExternalVersions();
    if (extVersions != null) params.add('externalVersions: $extVersions');

    if (yaml[strings.generateForPackageObjectiveC] == true) {
      params.add(
        '// ignore: deprecated_member_use\n    generateForPackageObjectiveC: true',
      );
    }

    return 'ObjectiveC(${params.join(',\n')})';
  }

  String? _buildObjcClassExpr(
    String sectionKey,
    String className, {
    required bool includeModule,
    String? transitiveParam,
  }) {
    final section = yaml[sectionKey] as YamlMap?;
    final params = <String, String>{};
    final includeExpr = _buildInclude(section);
    if (includeExpr != 'Declarations.excludeAll') {
      params['include'] = includeExpr;
    }
    final renameExpr = _buildRename(section?[strings.rename] as YamlMap?);
    if (renameExpr != null) params['rename'] = renameExpr;
    final memberRenameExpr = _buildMemberRename(
      section?[strings.memberRename] as YamlMap?,
    );
    if (memberRenameExpr != null) params['renameMember'] = memberRenameExpr;
    final memberFilterExpr = _buildMemberFilter(
      section?[strings.memberFilter] as YamlMap?,
    );
    if (memberFilterExpr != null) params['includeMember'] = memberFilterExpr;
    if (includeModule) {
      final moduleExpr = _buildModule(section?[strings.objcModule] as YamlMap?);
      if (moduleExpr != null) params['module'] = moduleExpr;
    }
    if (transitiveParam != null) params['includeTransitive'] = transitiveParam;
    if (params.isEmpty) return null;
    return '$className(${_paramsToString(params)})';
  }

  String? _buildModule(YamlMap? moduleMap) {
    if (moduleMap == null || moduleMap.isEmpty) return null;
    needsModuleHelper = true;
    final entries = moduleMap.entries
        .map(
          (e) =>
              'MapEntry(${_rawStringLiteral(e.key.toString())}, '
              '${_q(e.value.toString())})',
        )
        .join(', ');
    return '_moduleMatcher([$entries])';
  }

  String? _buildExternalVersions() {
    final ext = yaml[strings.externalVersions] as YamlMap?;
    if (ext == null || ext.isEmpty) return null;
    final parts = <String>[];
    for (final plat in strings.externalVersionsPlatforms) {
      final platMap = ext[plat] as YamlMap?;
      final min = platMap?[strings.externalVersionsMin] as String?;
      final max = platMap?[strings.externalVersionsMax] as String?;
      final args = [
        if (min != null) 'min: Version.parse(${_q(min)})',
        if (max != null) 'max: Version.parse(${_q(max)})',
      ];
      if (args.isNotEmpty) {
        parts.add('$plat: Versions(${args.join(', ')})');
      }
    }
    if (parts.isEmpty) return null;
    return 'ExternalVersions(${parts.join(', ')})';
  }

  // ---------------------------------------------------------------------
  // include/exclude filters
  // ---------------------------------------------------------------------

  List<String> _asStringList(dynamic node) {
    if (node == null) return const [];
    return (node as YamlList).map((e) => e.toString()).toList();
  }

  _NamePattern _splitNamePattern(List<String> items) {
    final full = <String>{};
    final regex = <String>[];
    for (final s in items) {
      if (_isFullDeclarationName(s)) {
        full.add(s);
      } else {
        regex.add(s);
      }
    }
    return _NamePattern(full, regex);
  }

  /// Builds the `include:` expression (a `bool Function(Declaration)`) for a
  /// declaration section.
  ///
  /// The result is always a fully-formed expression (e.g.
  /// `Declarations.includeAll`, `Declarations.includeSet({...})`, or a
  /// fallback lambda), so callers can compare it against
  /// `'Declarations.excludeAll'` to decide whether it can be omitted (i.e.
  /// whether it already matches the Dart API's own default for that field).
  String _buildInclude(YamlMap? section) {
    final hasIncludeKey =
        section != null && section.containsKey(strings.include);
    final includeList = _asStringList(section?[strings.include]);
    final excludeList = _asStringList(section?[strings.exclude]);

    if (hasIncludeKey && includeList.isEmpty) {
      return 'Declarations.excludeAll';
    }

    final include = _splitNamePattern(includeList);
    final exclude = _splitNamePattern(excludeList);

    if (include.regex.isEmpty && exclude.isEmpty) {
      if (include.full.isNotEmpty) {
        return 'Declarations.includeSet({${_setLiteral(include.full)}})';
      }
      return excludeAllByDefault
          ? 'Declarations.excludeAll'
          : 'Declarations.includeAll';
    }

    needsIncluderHelpers = true;
    return '_declarationIncluder(${_includeArgsString(include, exclude)})';
  }

  /// Builds a `bool Function(Declaration)` expression for the simple
  /// include/exclude objects used by `symbol-address`, `leaf`,
  /// `expose-typedefs` and `as-int`. These all default to "exclude
  /// everything" when absent, matching `Declarations.excludeAll`.
  String? _buildSimpleIncluder(YamlMap? obj) {
    if (obj == null) return null;
    final includeList = _asStringList(obj[strings.include]);
    final excludeList = _asStringList(obj[strings.exclude]);
    if (includeList.isEmpty && excludeList.isEmpty) return null;

    final include = _splitNamePattern(includeList);
    final exclude = _splitNamePattern(excludeList);

    if (include.regex.isEmpty && exclude.isEmpty && include.full.isNotEmpty) {
      return 'Declarations.includeSet({${_setLiteral(include.full)}})';
    }

    needsIncluderHelpers = true;
    return '_declarationIncluder(${_includeArgsString(include, exclude)})';
  }

  String _includeArgsString(_NamePattern include, _NamePattern exclude) {
    final parts = <String>[];
    if (include.full.isNotEmpty) {
      parts.add('includeNames: {${_setLiteral(include.full)}}');
    }
    if (include.regex.isNotEmpty) {
      parts.add('includePatterns: [${_regexListLiteral(include.regex)}]');
    }
    if (exclude.full.isNotEmpty) {
      parts.add('excludeNames: {${_setLiteral(exclude.full)}}');
    }
    if (exclude.regex.isNotEmpty) {
      parts.add('excludePatterns: [${_regexListLiteral(exclude.regex)}]');
    }
    if (excludeAllByDefault) parts.add('excludeAllByDefault: true');
    return parts.join(', ');
  }

  // ---------------------------------------------------------------------
  // rename / member-rename / member-filter
  // ---------------------------------------------------------------------

  String? _buildRename(YamlMap? renameMap) {
    if (renameMap == null || renameMap.isEmpty) return null;
    final full = <String, String>{};
    final regex = <MapEntry<String, String>>[];
    for (final e in renameMap.entries) {
      final key = e.key.toString();
      final value = e.value.toString();
      if (_isFullDeclarationName(key)) {
        full[key] = value;
      } else {
        regex.add(MapEntry(key, value));
      }
    }
    if (regex.isEmpty) {
      return 'Declarations.renameWithMap({${_mapLiteral(full)}})';
    }
    needsRenameHelpers = true;
    final buf = StringBuffer('(Declaration decl) {\n');
    buf.writeln('      final name = decl.originalName;');
    if (full.isNotEmpty) {
      buf.writeln('      const renameMap = {${_mapLiteral(full)}};');
      buf.writeln(
        '      if (renameMap.containsKey(name)) return renameMap[name]!;',
      );
    }
    for (final e in regex) {
      buf.writeln('      {');
      buf.writeln(
        '        final result = _tryRegexRename(name, '
        'RegExp(${_rawStringLiteral(e.key)}, dotAll: true), ${_q(e.value)});',
      );
      buf.writeln('        if (result != null) return result;');
      buf.writeln('      }');
    }
    buf.writeln('      return name;');
    buf.write('    }');
    return buf.toString();
  }

  String? _buildMemberRename(YamlMap? memberRenameMap) {
    if (memberRenameMap == null || memberRenameMap.isEmpty) return null;

    final declFull = <String, YamlMap>{};
    final declRegex = <MapEntry<String, YamlMap>>[];
    for (final e in memberRenameMap.entries) {
      final key = e.key.toString();
      final value = e.value as YamlMap;
      if (_isFullDeclarationName(key)) {
        declFull[key] = value;
      } else {
        declRegex.add(MapEntry(key, value));
      }
    }

    final allClean =
        declRegex.isEmpty &&
        declFull.values.every(
          (m) => m.keys.every((mk) => _isFullDeclarationName(mk.toString())),
        );
    if (allClean) {
      final entries = declFull.entries
          .map((e) {
            final memberMap = {
              for (final me in e.value.entries)
                me.key.toString(): me.value.toString(),
            };
            return '${_q(e.key)}: {${_mapLiteral(memberMap)}}';
          })
          .join(', ');
      return 'Declarations.renameMemberWithMap({$entries})';
    }

    needsRenameHelpers = true;
    final buf = StringBuffer('(Declaration decl, String member) {\n');
    buf.writeln('      final name = decl.originalName;');
    for (final e in declFull.entries) {
      buf.writeln('      if (name == ${_q(e.key)}) {');
      buf.write(_memberRenameBody(e.value));
      buf.writeln('      }');
    }
    for (final e in declRegex) {
      buf.writeln(
        '      if (_fullRegexMatch(RegExp(${_rawStringLiteral(e.key)}, '
        'dotAll: true), name)) {',
      );
      buf.write(_memberRenameBody(e.value));
      buf.writeln('      }');
    }
    buf.writeln('      return member;');
    buf.write('    }');
    return buf.toString();
  }

  String _memberRenameBody(YamlMap memberMap) {
    final full = <String, String>{};
    final regex = <MapEntry<String, String>>[];
    for (final e in memberMap.entries) {
      final key = e.key.toString();
      final value = e.value.toString();
      if (_isFullDeclarationName(key)) {
        full[key] = value;
      } else {
        regex.add(MapEntry(key, value));
      }
    }
    final buf = StringBuffer();
    if (full.isNotEmpty) {
      buf.writeln('        const memberMap = {${_mapLiteral(full)}};');
      buf.writeln(
        '        if (memberMap.containsKey(member)) return memberMap[member]!;',
      );
    }
    for (final e in regex) {
      buf.writeln('        {');
      buf.writeln(
        '          final result = _tryRegexRename(member, '
        'RegExp(${_rawStringLiteral(e.key)}, dotAll: true), ${_q(e.value)});',
      );
      buf.writeln('          if (result != null) return result;');
      buf.writeln('        }');
    }
    buf.writeln('        return member;');
    return buf.toString();
  }

  String? _buildMemberFilter(YamlMap? memberFilterMap) {
    if (memberFilterMap == null || memberFilterMap.isEmpty) return null;

    final declFull = <String, YamlMap>{};
    final declRegex = <MapEntry<String, YamlMap>>[];
    for (final e in memberFilterMap.entries) {
      final key = e.key.toString();
      final value = e.value as YamlMap;
      if (_isFullDeclarationName(key)) {
        declFull[key] = value;
      } else {
        declRegex.add(MapEntry(key, value));
      }
    }

    needsIncluderHelpers = true;
    if (declRegex.isNotEmpty) needsRenameHelpers = true; // for _fullRegexMatch

    final buf = StringBuffer('(Declaration decl, String member) {\n');
    buf.writeln('      final name = decl.originalName;');
    for (final e in declFull.entries) {
      buf.writeln(
        '      if (name == ${_q(e.key)}) return _includeName(member, '
        '${_memberFilterArgs(e.value)});',
      );
    }
    for (final e in declRegex) {
      buf.writeln(
        '      if (_fullRegexMatch(RegExp(${_rawStringLiteral(e.key)}, '
        'dotAll: true), name)) {',
      );
      buf.writeln(
        '        return _includeName(member, ${_memberFilterArgs(e.value)});',
      );
      buf.writeln('      }');
    }
    buf.writeln('      return true;');
    buf.write('    }');
    return buf.toString();
  }

  String _memberFilterArgs(YamlMap obj) {
    final include = _splitNamePattern(_asStringList(obj[strings.include]));
    final exclude = _splitNamePattern(_asStringList(obj[strings.exclude]));
    final args = _includeArgsStringNoDefault(include, exclude);
    return args;
  }

  String _includeArgsStringNoDefault(
    _NamePattern include,
    _NamePattern exclude,
  ) {
    final parts = <String>[];
    if (include.full.isNotEmpty) {
      parts.add('includeNames: {${_setLiteral(include.full)}}');
    }
    if (include.regex.isNotEmpty) {
      parts.add('includePatterns: [${_regexListLiteral(include.regex)}]');
    }
    if (exclude.full.isNotEmpty) {
      parts.add('excludeNames: {${_setLiteral(exclude.full)}}');
    }
    if (exclude.regex.isNotEmpty) {
      parts.add('excludePatterns: [${_regexListLiteral(exclude.regex)}]');
    }
    return parts.join(', ');
  }

  // ---------------------------------------------------------------------
  // Path helpers
  // ---------------------------------------------------------------------

  String _pathExpr(String raw) {
    if (Uri.parse(raw).scheme == 'package') {
      return 'Uri.parse(${_q(raw)})';
    }
    if (_hasSdkVar(raw)) {
      return 'Uri.file(${_interpolated(raw)})';
    }
    final absolute = normalizePath(raw, configFilename);
    return _pathExprForAbsolute(absolute);
  }

  String _pathExprForAbsolute(String absolutePath) {
    final rel = p.relative(absolutePath, from: _configDirPath);
    return 'packageRoot.resolve(${_q(_toPosix(rel))})';
  }

  String _toPosix(String path) => path.replaceAll(r'\', '/');

  // ---------------------------------------------------------------------
  // Literal helpers
  // ---------------------------------------------------------------------

  String _q(String s) {
    final escaped = s
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll(r'$', r'\$')
        .replaceAll('\n', r'\n');
    return "'$escaped'";
  }

  String _rawStringLiteral(String s) {
    if (!s.contains("'")) return "r'$s'";
    if (!s.contains('"')) return 'r"$s"';
    return _q(s);
  }

  String _interpolated(String raw) {
    var s = raw;
    for (final entry in _sdkVars.entries) {
      s = s.replaceAll(entry.key, '\${${entry.value}}');
    }
    final escaped = s.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    return '"$escaped"';
  }

  String _interpolatedOrLiteral(String raw) =>
      _hasSdkVar(raw) ? _interpolated(raw) : _q(raw);

  String _setLiteral(Set<String> names) => names.map(_q).join(', ');

  String _mapLiteral(Map<String, String> map) =>
      map.entries.map((e) => '${_q(e.key)}: ${_q(e.value)}').join(', ');

  String _regexListLiteral(List<String> patterns) => patterns
      .map((p) => 'RegExp(${_rawStringLiteral(p)}, dotAll: true)')
      .join(', ');

  String _paramsToString(Map<String, String> params) =>
      params.entries.map((e) => '${e.key}: ${e.value}').join(',\n    ');

  List<String> _wrapComment(String text) {
    const width = 76;
    final words = text.split(' ');
    final lines = <String>[];
    var current = StringBuffer();
    for (final word in words) {
      if (current.isNotEmpty && current.length + word.length + 1 > width) {
        lines.add(current.toString());
        current = StringBuffer();
      }
      if (current.isNotEmpty) current.write(' ');
      current.write(word);
    }
    if (current.isNotEmpty) lines.add(current.toString());
    return lines;
  }

  String _helperSource() {
    final buf = StringBuffer();
    buf.writeln('''
/// Migrated from FFIgen's legacy YAML `include`/`exclude`/`rename` semantics.
bool _fullRegexMatch(RegExp re, String s) {
  final m = re.matchAsPrefix(s);
  return m != null && m.end == s.length;
}
''');
    if (needsIncluderHelpers) {
      buf.writeln('''
bool _matchesAny(String name, Set<String> names, List<RegExp> patterns) {
  if (names.contains(name)) return true;
  return patterns.any((p) => _fullRegexMatch(p, name));
}

bool _includeName(
  String name, {
  Set<String> includeNames = const {},
  List<RegExp> includePatterns = const [],
  Set<String> excludeNames = const {},
  List<RegExp> excludePatterns = const [],
  bool excludeAllByDefault = false,
}) {
  if (_matchesAny(name, excludeNames, excludePatterns)) return false;
  if (_matchesAny(name, includeNames, includePatterns)) return true;
  if (includeNames.isNotEmpty || includePatterns.isNotEmpty) return false;
  return !excludeAllByDefault;
}

bool Function(Declaration) _declarationIncluder({
  Set<String> includeNames = const {},
  List<RegExp> includePatterns = const [],
  Set<String> excludeNames = const {},
  List<RegExp> excludePatterns = const [],
  bool excludeAllByDefault = false,
}) {
  return (Declaration decl) => _includeName(
    decl.originalName,
    includeNames: includeNames,
    includePatterns: includePatterns,
    excludeNames: excludeNames,
    excludePatterns: excludePatterns,
    excludeAllByDefault: excludeAllByDefault,
  );
}
''');
    }
    if (needsRenameHelpers) {
      buf.writeln('''
String? _tryRegexRename(String name, RegExp pattern, String replacement) {
  final match = pattern.matchAsPrefix(name);
  if (match == null || match.end != name.length) return null;
  return replacement.replaceAllMapped(RegExp(r'\\\$([0-9])'), (m) {
    final group = int.parse(m.group(1)!);
    return (group == 0 ? match.group(0) : match.group(group)) ?? '';
  });
}
''');
    }
    if (needsModuleHelper) {
      buf.writeln('''
String? Function(Declaration) _moduleMatcher(
  List<MapEntry<String, String>> patterns,
) {
  final compiled = [
    for (final e in patterns) MapEntry(RegExp(e.key, dotAll: true), e.value),
  ];
  return (Declaration decl) {
    for (final e in compiled) {
      if (_fullRegexMatch(e.key, decl.originalName)) return e.value;
    }
    return null;
  };
}
''');
    }
    return buf.toString();
  }
}
