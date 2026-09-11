// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_buffer.dart';

/// Emits `visitors: [Visitor(...)]` based on declaration configs in YAML.
class VisitorEmitter {
  final Map<dynamic, dynamic> yamlMap;
  late final bool excludeAllByDefault;

  VisitorEmitter({required this.yamlMap}) {
    excludeAllByDefault = yamlMap['exclude-all-by-default'] == true;
  }

  void emitVisitor(CodeBuffer buffer) {
    final callbacks = <String, void Function(CodeBuffer)>{};

    if (_shouldEmitFunc) callbacks['func'] = _emitFunc;
    if (_shouldEmitStruct) callbacks['struct'] = _emitStruct;
    if (_shouldEmitUnion) callbacks['union'] = _emitUnion;
    if (_shouldEmitEnum) callbacks['enumClass'] = _emitEnumClass;
    if (_shouldEmitUnnamedEnum) {
      callbacks['unnamedEnumConstant'] = _emitUnnamedEnumConstant;
    }
    if (_shouldEmitGlobal) callbacks['global'] = _emitGlobal;
    if (_shouldEmitMacro) callbacks['macroConstant'] = _emitMacroConstant;
    if (_shouldEmitTypealias) callbacks['typealias'] = _emitTypealias;
    if (_shouldEmitObjCInterface) {
      callbacks['objCInterface'] = _emitObjCInterface;
    }
    if (_shouldEmitObjCProtocol) {
      callbacks['objCProtocol'] = _emitObjCProtocol;
    }
    if (_shouldEmitObjCCategory) {
      callbacks['objCCategory'] = _emitObjCCategory;
    }
    if (_shouldEmitCppClass) callbacks['cppClass'] = _emitCppClass;
    if (_shouldEmitObjCMethod) callbacks['objCMethod'] = _emitObjCMethod;
    if (_shouldEmitField) callbacks['field'] = _emitField;
    if (_shouldEmitParam) callbacks['param'] = _emitParam;
    if (_shouldEmitEnumConstant) callbacks['enumConstant'] = _emitEnumConstant;

    if (callbacks.isEmpty) {
      return;
    }

    buffer.writeln('visitors: [');
    buffer.indent();
    buffer.writeln('Visitor(');
    buffer.indent();

    for (final entry in callbacks.entries) {
      buffer.write('${entry.key}: (node) ');
      final bodyBuffer = CodeBuffer();
      entry.value(bodyBuffer);
      final body = bodyBuffer.toString().trimRight();
      if (body.startsWith('{')) {
        buffer.writeln('$body,');
      } else {
        buffer.writeln('=> $body,');
      }
    }

    buffer.dedent();
    buffer.writeln('),');
    buffer.dedent();
    buffer.writeln('],');
  }

  bool _hasSection(String key) =>
      yamlMap.containsKey(key) && yamlMap[key] != null;

  Map<dynamic, dynamic>? _section(String key) =>
      yamlMap[key] as Map<dynamic, dynamic>?;

  bool get _shouldEmitFunc {
    if (_hasSection('functions')) return true;
    return !excludeAllByDefault;
  }

  bool get _shouldEmitStruct {
    if (_hasSection('structs')) return true;
    return !excludeAllByDefault;
  }

  bool get _shouldEmitUnion {
    if (_hasSection('unions')) return true;
    return !excludeAllByDefault;
  }

  bool get _shouldEmitEnum {
    if (_hasSection('enums')) return true;
    if (yamlMap['silence-enum-warning'] == true) return true;
    return !excludeAllByDefault;
  }

  bool get _shouldEmitUnnamedEnum {
    if (_hasSection('unnamed-enums')) return true;
    return false;
  }

  bool get _shouldEmitGlobal {
    if (_hasSection('globals')) return true;
    return !excludeAllByDefault;
  }

  bool get _shouldEmitMacro {
    if (_hasSection('macros')) return true;
    return !excludeAllByDefault;
  }

  bool get _shouldEmitTypealias {
    if (_hasSection('typedefs')) return true;
    if (yamlMap['include-unused-typedefs'] == true) return true;
    return !excludeAllByDefault;
  }

  bool get _shouldEmitObjCInterface {
    if (_hasSection('objc-interfaces')) return true;
    if (yamlMap['include-transitive-objc-categories'] == false) return true;
    return false;
  }

  bool get _shouldEmitObjCProtocol {
    if (_hasSection('objc-protocols')) return true;
    return false;
  }

  bool get _shouldEmitObjCCategory {
    if (_hasSection('objc-categories')) return true;
    return false;
  }

  bool get _shouldEmitCppClass {
    final cpp = _section('cpp');
    return cpp != null && cpp.containsKey('cpp-classes');
  }

  bool get _shouldEmitObjCMethod {
    final ifaces = _section('objc-interfaces');
    if (ifaces != null &&
        (ifaces.containsKey('member-filter') ||
            ifaces.containsKey('member-rename'))) {
      return true;
    }
    final protos = _section('objc-protocols');
    if (protos != null &&
        (protos.containsKey('member-filter') ||
            protos.containsKey('member-rename'))) {
      return true;
    }
    final cats = _section('objc-categories');
    if (cats != null &&
        (cats.containsKey('member-filter') ||
            cats.containsKey('member-rename'))) {
      return true;
    }
    return false;
  }

  bool get _shouldEmitField {
    final structs = _section('structs');
    if (structs != null && structs.containsKey('member-rename')) return true;
    final unions = _section('unions');
    if (unions != null && unions.containsKey('member-rename')) return true;
    return false;
  }

  bool get _shouldEmitParam {
    final funcs = _section('functions');
    return funcs != null && funcs.containsKey('member-rename');
  }

  bool get _shouldEmitEnumConstant {
    final enums = _section('enums');
    return enums != null && enums.containsKey('member-rename');
  }

  void _emitFunc(CodeBuffer buffer) {
    final cfg = _section('functions') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAllByDefault,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    if (cfg.containsKey('leaf')) {
      final leaf = cfg['leaf'];
      if (leaf is bool) {
        statements.add('node.isLeaf = $leaf;');
      } else if (leaf is Map) {
        final leafExcludes = (leaf['exclude'] as List?)?.cast<String>();
        final leafIncludes = (leaf['include'] as List?)?.cast<String>();
        final cond = _buildInclusionCondition(
          leafIncludes,
          leafExcludes,
          'node.originalName',
        );
        if (cond == 'true') {
          statements.add('node.isLeaf = true;');
        } else if (cond != 'false') {
          statements.add('node.isLeaf = $cond;');
        }
      }
    }

    if (cfg.containsKey('symbol-address')) {
      final symAddr = cfg['symbol-address'] as Map? ?? {};
      final symInc = (symAddr['include'] as List?)?.cast<String>();
      if (symInc != null && symInc.isNotEmpty) {
        final cond = _buildInclusionCondition(
          symInc,
          null,
          'node.originalName',
        );
        statements.add('if ($cond) {\n  node.exposeSymbolAddress = true;\n}');
      }
    }

    if (cfg.containsKey('expose-typedefs')) {
      final exp = cfg['expose-typedefs'] as Map? ?? {};
      final expInc = (exp['include'] as List?)?.cast<String>();
      if (expInc != null && expInc.isNotEmpty) {
        final cond = _buildInclusionCondition(
          expInc,
          null,
          'node.originalName',
        );
        statements.add('if ($cond) {\n  node.generateTypedefs = true;\n}');
      }
    }

    _formatStatements(buffer, statements);
  }

  void _emitStruct(CodeBuffer buffer) {
    final cfg = _section('structs') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAllByDefault,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    if (cfg['dependency-only'] == 'opaque') {
      statements.add('node.dependencies = CompoundDependencies.opaque;');
    } else {
      statements.add('node.dependencies = CompoundDependencies.full;');
    }

    if (cfg.containsKey('pack')) {
      final packMap = cfg['pack'] as Map;
      for (final entry in packMap.entries) {
        final name = entry.key.toString();
        final val = entry.value;
        if (val == 'none') {
          statements.add(
            "if (node.originalName == '$name') {\n  node.pack = 0;\n}",
          );
        } else if (val is num) {
          statements.add(
            "if (node.originalName == '$name') {\n  node.pack = $val;\n}",
          );
        }
      }
    }

    _formatStatements(buffer, statements);
  }

  void _emitUnion(CodeBuffer buffer) {
    final cfg = _section('unions') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAllByDefault,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    if (cfg['dependency-only'] == 'opaque') {
      statements.add('node.dependencies = CompoundDependencies.opaque;');
    } else {
      statements.add('node.dependencies = CompoundDependencies.full;');
    }

    _formatStatements(buffer, statements);
  }

  void _emitEnumClass(CodeBuffer buffer) {
    final cfg = _section('enums') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAllByDefault,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    if (cfg.containsKey('as-int')) {
      final asInt = cfg['as-int'] as Map? ?? {};
      final asIntInc = (asInt['include'] as List?)?.cast<String>();
      if (asIntInc != null && asIntInc.isNotEmpty) {
        final cond = _buildInclusionCondition(
          asIntInc,
          null,
          'node.originalName',
        );
        statements.add(
          'if ($cond) {\n  node.style = EnumStyle.intConstants;\n}',
        );
      }
    }

    if (yamlMap['silence-enum-warning'] == true) {
      statements.add('node.silenceWarning = true;');
    }

    _formatStatements(buffer, statements);
  }

  void _emitUnnamedEnumConstant(CodeBuffer buffer) {
    final cfg = _section('unnamed-enums') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAllByDefault,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    _formatStatements(buffer, statements);
  }

  void _emitGlobal(CodeBuffer buffer) {
    final cfg = _section('globals') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAllByDefault,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    if (cfg.containsKey('symbol-address')) {
      final symAddr = cfg['symbol-address'] as Map? ?? {};
      final symInc = (symAddr['include'] as List?)?.cast<String>();
      if (symInc != null && symInc.isNotEmpty) {
        final cond = _buildInclusionCondition(
          symInc,
          null,
          'node.originalName',
        );
        statements.add('if ($cond) {\n  node.exposeSymbolAddress = true;\n}');
      }
    }

    _formatStatements(buffer, statements);
  }

  void _emitMacroConstant(CodeBuffer buffer) {
    final cfg = _section('macros') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: !excludeAllByDefault,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    _formatStatements(buffer, statements);
  }

  void _emitTypealias(CodeBuffer buffer) {
    final cfg = _section('typedefs') ?? {};
    final statements = <String>[];

    final includeUnused = yamlMap['include-unused-typedefs'] == true;
    final includes = (cfg['include'] as List?)?.cast<String>();
    final excludes = (cfg['exclude'] as List?)?.cast<String>();

    if (includes != null && includes.isNotEmpty) {
      final cond = _buildInclusionCondition(
        includes,
        excludes,
        'node.originalName',
      );
      final trueVal = includeUnused
          ? 'TypealiasInclude.always'
          : 'TypealiasInclude.ifUsed';
      statements.add(
        'node.isIncluded = ($cond) ? $trueVal : TypealiasInclude.never;',
      );
    } else if (excludes != null && excludes.isNotEmpty) {
      final cond = _buildInclusionCondition(
        null,
        excludes,
        'node.originalName',
      );
      final trueVal = includeUnused
          ? 'TypealiasInclude.always'
          : 'TypealiasInclude.ifUsed';
      statements.add(
        'node.isIncluded = ($cond) ? $trueVal : TypealiasInclude.never;',
      );
    } else if (includeUnused) {
      statements.add('node.isIncluded = TypealiasInclude.always;');
    } else if (!excludeAllByDefault) {
      statements.add('node.isIncluded = TypealiasInclude.ifUsed;');
    }

    _addRenames(cfg, statements, target: 'node.name');

    _formatStatements(buffer, statements);
  }

  void _emitObjCInterface(CodeBuffer buffer) {
    final cfg = _section('objc-interfaces') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    if (cfg.containsKey('module')) {
      final modules = cfg['module'] as Map;
      for (final entry in modules.entries) {
        statements.add(
          "if (node.originalName == '${entry.key}') {\n"
          "  node.module = '${entry.value}';\n"
          '}',
        );
      }
    }

    if (yamlMap['include-transitive-objc-categories'] == false) {
      statements.add('node.includeCategories = false;');
    }

    _formatStatements(buffer, statements);
  }

  void _emitObjCProtocol(CodeBuffer buffer) {
    final cfg = _section('objc-protocols') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    if (cfg.containsKey('module')) {
      final modules = cfg['module'] as Map;
      for (final entry in modules.entries) {
        statements.add(
          "if (node.originalName == '${entry.key}') {\n"
          "  node.module = '${entry.value}';\n"
          '}',
        );
      }
    }

    _formatStatements(buffer, statements);
  }

  void _emitObjCCategory(CodeBuffer buffer) {
    final cfg = _section('objc-categories') ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cfg,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) statements.add(inc);

    _addRenames(cfg, statements, target: 'node.name');

    _formatStatements(buffer, statements);
  }

  void _emitCppClass(CodeBuffer buffer) {
    final cpp = _section('cpp') ?? {};
    final cppClasses = cpp['cpp-classes'] as Map? ?? {};
    final statements = <String>[];

    final inc = _buildInclusionStatement(
      cppClasses,
      target: 'node.originalName',
      defaultInclude: false,
    );
    if (inc != null) statements.add(inc);

    _formatStatements(buffer, statements);
  }

  void _emitObjCMethod(CodeBuffer buffer) {
    final statements = <String>[];
    statements.add('final parent = node.parent;');

    void addSection(String key, String typeName) {
      final cfg = _section(key);
      if (cfg == null) return;
      final memberFilter = cfg['member-filter'] as Map?;
      final memberRename = cfg['member-rename'] as Map?;
      if (memberFilter == null && memberRename == null) return;

      final subStatements = <String>[];

      if (memberFilter != null) {
        for (final entry in memberFilter.entries) {
          final parentDecl = entry.key.toString();
          final filter = entry.value as Map;
          final incList = (filter['include'] as List?)?.cast<String>();
          final excList = (filter['exclude'] as List?)?.cast<String>();

          final parentCond = _isExactName(parentDecl)
              ? "parent.originalName == '$parentDecl'"
              : "RegExp(r'^$parentDecl\$').hasMatch(parent.originalName)";

          if (excList != null && incList == null) {
            if (excList.length == 1 && _isExactName(excList.first)) {
              subStatements.add(
                'if ($parentCond && '
                "node.selector == '${excList.first}') {\n"
                '  node.isIncluded = false;\n'
                '}',
              );
            } else {
              final cond = _buildInclusionCondition(
                null,
                excList,
                'node.selector',
              );
              subStatements.add(
                'if ($parentCond) {\n  node.isIncluded = $cond;\n}',
              );
            }
          } else if (incList != null) {
            final cond = _buildInclusionCondition(
              incList,
              excList,
              'node.selector',
            );
            subStatements.add(
              'if ($parentCond) {\n  node.isIncluded = $cond;\n}',
            );
          }
        }
      }

      if (memberRename != null) {
        for (final entry in memberRename.entries) {
          final parentDecl = entry.key.toString();
          final renames = entry.value as Map;
          final parentCond = _isExactName(parentDecl)
              ? "parent.originalName == '$parentDecl'"
              : "RegExp(r'^$parentDecl\$').hasMatch(parent.originalName)";

          for (final rentry in renames.entries) {
            final from = rentry.key.toString();
            final to = rentry.value.toString();
            if (_isExactName(from)) {
              subStatements.add(
                "if ($parentCond && node.selector == '$from') {\n"
                "  node.name = '$to';\n"
                '}',
              );
            } else {
              subStatements.add(
                'if ($parentCond && '
                "RegExp(r'^$from\$').hasMatch(node.selector)) {\n"
                "  node.name = '$to';\n"
                '}',
              );
            }
          }
        }
      }

      if (subStatements.isNotEmpty) {
        statements.add(
          'if (parent is $typeName) {\n  ${subStatements.join('\n  ')}\n}',
        );
      }
    }

    addSection('objc-interfaces', 'ObjCInterface');
    addSection('objc-protocols', 'ObjCProtocol');
    addSection('objc-categories', 'ObjCCategory');

    _formatStatements(buffer, statements);
  }

  void _emitField(CodeBuffer buffer) {
    final statements = <String>[];
    statements.add('final parent = node.parent;');

    void addSection(String key, String typeName) {
      final cfg = _section(key);
      if (cfg == null) return;
      final memberRename = cfg['member-rename'] as Map?;
      if (memberRename == null) return;

      for (final entry in memberRename.entries) {
        final parentDecl = entry.key.toString();
        final renames = entry.value as Map;
        for (final rentry in renames.entries) {
          final from = rentry.key.toString();
          final to = rentry.value.toString();
          statements.add(
            'if (parent is $typeName && '
            "parent.originalName == '$parentDecl' && "
            "node.originalName == '$from') {\n"
            "  node.name = '$to';\n"
            '}',
          );
        }
      }
    }

    addSection('structs', 'Struct');
    addSection('unions', 'Union');

    _formatStatements(buffer, statements);
  }

  void _emitParam(CodeBuffer buffer) {
    final statements = <String>[];
    statements.add('final parent = node.parent;');

    final cfg = _section('functions');
    if (cfg != null) {
      final memberRename = cfg['member-rename'] as Map?;
      if (memberRename != null) {
        for (final entry in memberRename.entries) {
          final parentDecl = entry.key.toString();
          final renames = entry.value as Map;
          for (final rentry in renames.entries) {
            final from = rentry.key.toString();
            final to = rentry.value.toString();
            statements.add(
              'if (parent is Func && '
              "parent.originalName == '$parentDecl' && "
              "node.originalName == '$from') {\n"
              "  node.name = '$to';\n"
              '}',
            );
          }
        }
      }
    }

    _formatStatements(buffer, statements);
  }

  void _emitEnumConstant(CodeBuffer buffer) {
    final statements = <String>[];
    statements.add('final parent = node.parent;');

    final cfg = _section('enums');
    if (cfg != null) {
      final memberRename = cfg['member-rename'] as Map?;
      if (memberRename != null) {
        for (final entry in memberRename.entries) {
          final parentDecl = entry.key.toString();
          final renames = entry.value as Map;
          for (final rentry in renames.entries) {
            final from = rentry.key.toString();
            final to = rentry.value.toString();
            statements.add(
              "if (parent.originalName == '$parentDecl' && "
              "node.originalName == '$from') {\n"
              "  node.name = '$to';\n"
              '}',
            );
          }
        }
      }
    }

    _formatStatements(buffer, statements);
  }

  String? _buildInclusionStatement(
    Map<dynamic, dynamic> cfg, {
    required String target,
    required bool defaultInclude,
  }) {
    final includes = (cfg['include'] as List?)?.cast<String>();
    final excludes = (cfg['exclude'] as List?)?.cast<String>();

    if (includes == null && excludes == null) {
      if (defaultInclude) {
        return 'node.isIncluded = true;';
      }
      return null;
    }

    final cond = _buildInclusionCondition(includes, excludes, target);
    return 'node.isIncluded = $cond;';
  }

  String _buildInclusionCondition(
    List<String>? includes,
    List<String>? excludes,
    String target,
  ) {
    String? incCond;
    if (includes != null && includes.isNotEmpty) {
      final exact = includes.where(_isExactName).toList();
      final regex = includes.where((s) => !_isExactName(s)).toList();

      final parts = <String>[];
      if (exact.length == 1) {
        parts.add("$target == '${exact.first}'");
      } else if (exact.length > 1) {
        parts.add('${_toSetLiteral(exact)}.contains($target)');
      }

      for (final r in regex) {
        if (r == '.*') {
          parts.add('true');
        } else if (r.endsWith('.*') &&
            _isExactName(r.substring(0, r.length - 2))) {
          parts.add("$target.startsWith('${r.substring(0, r.length - 2)}')");
        } else {
          final pat = r.startsWith('^') ? r.substring(1) : r;
          final finalPat = pat.endsWith('\$')
              ? pat.substring(0, pat.length - 1)
              : pat;
          parts.add("RegExp(r'^$finalPat\$').hasMatch($target)");
        }
      }

      if (parts.length == 1) {
        incCond = parts.first;
      } else {
        incCond = parts.join(' || ');
      }
    }

    String? excCond;
    if (excludes != null && excludes.isNotEmpty) {
      final exact = excludes.where(_isExactName).toList();
      final regex = excludes.where((s) => !_isExactName(s)).toList();

      final parts = <String>[];
      if (exact.length == 1) {
        parts.add("$target != '${exact.first}'");
      } else if (exact.length > 1) {
        parts.add('!${_toSetLiteral(exact)}.contains($target)');
      }

      for (final r in regex) {
        if (r.endsWith('.*') && _isExactName(r.substring(0, r.length - 2))) {
          parts.add("!$target.startsWith('${r.substring(0, r.length - 2)}')");
        } else {
          final pat = r.startsWith('^') ? r.substring(1) : r;
          final finalPat = pat.endsWith('\$')
              ? pat.substring(0, pat.length - 1)
              : pat;
          parts.add("!RegExp(r'^$finalPat\$').hasMatch($target)");
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

  void _addRenames(
    Map<dynamic, dynamic> cfg,
    List<String> statements, {
    required String target,
  }) {
    final rename = cfg['rename'] as Map?;
    if (rename == null || rename.isEmpty) return;

    final exact = <String, String>{};
    final regex = <String, String>{};

    for (final entry in rename.entries) {
      final from = entry.key.toString();
      final to = entry.value.toString();
      if (_isExactName(from)) {
        exact[from] = to;
      } else {
        regex[from] = to;
      }
    }

    if (exact.isNotEmpty) {
      if (exact.length == 1) {
        final k = exact.keys.first;
        final v = exact.values.first;
        statements.add("if ($target == '$k') {\n  $target = '$v';\n}");
      } else {
        final mapLit = CodeBuffer.toLiteral(exact);
        statements.add('const rename = $mapLit;');
        statements.add(
          'if (rename[$target] case final r?) {\n  $target = r;\n}',
        );
      }
    }

    for (final entry in regex.entries) {
      final from = entry.key;
      final to = entry.value;
      if (to == r'$1' &&
          from.startsWith('^') == false &&
          from.endsWith(r'(.*)')) {
        final prefix = from.substring(0, from.length - 4);
        statements.add(
          "$target = $target.replaceFirst(RegExp(r'^$prefix'), '');",
        );
      } else {
        final pat = from.startsWith('^') ? from.substring(1) : from;
        final finalPat = pat.endsWith('\$')
            ? pat.substring(0, pat.length - 1)
            : pat;
        statements.add('''
final match = RegExp(r'^$finalPat\$').firstMatch($target);
if (match != null) {
  $target = r'$to'.replaceAllMapped(RegExp(r'\\\$([0-9])'), (m) => match[int.parse(m[1]!)] ?? '');
}''');
      }
    }
  }

  void _formatStatements(CodeBuffer buffer, List<String> statements) {
    if (statements.isEmpty) {
      buffer.write('{}');
      return;
    }
    if (statements.length == 1 &&
        !statements.first.contains('\n') &&
        statements.first.endsWith(';') &&
        !statements.first.startsWith('if ') &&
        !statements.first.startsWith('if(') &&
        !statements.first.startsWith('const ') &&
        !statements.first.startsWith('final ')) {
      final s = statements.first;
      buffer.write(s.substring(0, s.length - 1));
      return;
    }

    buffer.writeln('{');
    buffer.indent();
    for (final s in statements) {
      buffer.writeln(s);
    }
    buffer.dedent();
    buffer.write('}');
  }

  static bool _isExactName(String s) => RegExp(r'^[a-zA-Z_0-9:]+$').hasMatch(s);

  static String _toSetLiteral(List<String> items) {
    return '{${items.map((i) => "'$i'").join(', ')}}';
  }
}
