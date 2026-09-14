// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

const customLibImport = LibraryImport(
  'custom_lib',
  'package:custom_lib/custom_lib.dart',
);

ImportedType? importType(Declaration declaration) {
  if (declaration.originalName == 'mapped_typedef_t') {
    return ImportedType(customLibImport, 'Int32', 'int', 'mapped_typedef_t');
  }
  return null;
}

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/migrate/yaml/');
  final dartPath = outputDir != null
      ? outputDir.resolve('comprehensive_bindings.dart')
      : configDir.resolve('comprehensive_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('comprehensive_bindings.m')
      : configDir.resolve('comprehensive_bindings.m');
  final symbolFilePath = outputDir != null
      ? outputDir.resolve('comprehensive_symbols.yaml')
      : configDir.resolve('comprehensive_symbols.yaml');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      symbolFile: SymbolFile(
        Uri.parse('comprehensive_bindings.dart'),
        symbolFilePath,
      ),
      style: const DynamicLibraryBindings(
        wrapperName: 'Comprehensive',
        wrapperDocComment: 'Comprehensive bindings',
      ),
      commentType: const CommentType(CommentStyle.any, CommentLength.full),
      preamble: '''
// Comprehensive test preamble
''',
    ),
    input: Input(
      entryPoints: [configDir.resolve('comprehensive.h')],
      include: (uri) => uri.path.endsWith('comprehensive.h'),
      compilerOptions: [
        '-Wno-nullability-completeness',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
      ignoreSourceErrors: true,
    ),
    objectiveC: ObjectiveC(
      externalVersions: ExternalVersions(
        ios: Versions(min: Version(12, 0, 0)),
        macos: Versions(min: Version(10, 14, 0)),
      ),
    ),
    importType: importType,
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded =
              node.originalName != 'func_exclude' &&
              !node.originalName.startsWith('regex_exclude_');
          if (node.name == 'old_func') {
            node.name = 'new_func';
          }
          if (RegExp(r'^prefix_func_.*$').hasMatch(node.name)) {
            node.name = 'new_prefix';
          }
          node.name = node.name.replaceFirst(RegExp(r'^strip_'), '');
          if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.name)
              case final match?) {
            node.name = r'$2_$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
          node.isLeaf =
              node.originalName == 'leaf_func' ||
              node.originalName.startsWith('leaf_regex_');
          if (node.originalName == 'sym_addr_func' ||
              node.originalName.startsWith('sym_addr_regex_')) {
            node.exposeSymbolAddress = true;
          }
          if (node.originalName == 'exp_typedef_func' ||
              node.originalName.startsWith('exp_typedef_regex_')) {
            node.generateTypedefs = true;
          }
        },
        struct: (node) {
          node.isIncluded =
              !{
                'ExcludedStruct',
                'OpaqueDepStruct',
              }.contains(node.originalName) &&
              !node.originalName.startsWith('RegexExcludedStruct');
          if (node.name == 'StructRenameNoGroup') {
            node.name = 'RenamedStructNoGroup';
          }
          if (RegExp(r'^RegexStructNoGroup_.*$').hasMatch(node.name)) {
            node.name = 'RenamedRegexStruct';
          }
          node.name = node.name.replaceFirst(RegExp(r'^StripStruct_'), '');
          if (RegExp(r'^Swap_Struct_(.*)_(.*)$').firstMatch(node.name)
              case final match?) {
            node.name = r'$2_$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
          node.dependencies = CompoundDependencies.opaque;
          if (node.originalName == 'Pack1Struct') {
            node.pack = 1;
          }
          if (node.originalName == 'Pack2Struct') {
            node.pack = 2;
          }
          if (node.originalName == 'Pack4Struct') {
            node.pack = 4;
          }
          if (node.originalName == 'Pack8Struct') {
            node.pack = 8;
          }
          if (node.originalName == 'Pack16Struct') {
            node.pack = 16;
          }
          if (node.originalName == 'PackNoneStruct') {
            node.pack = null;
          }
        },
        union: (node) {
          node.isIncluded =
              !{
                'ExcludedUnion',
                'OpaqueDepUnion',
              }.contains(node.originalName) &&
              !node.originalName.startsWith('RegexExcludedUnion');
          if (node.name == 'UnionOld') {
            node.name = 'UnionNew';
          }
          node.dependencies = CompoundDependencies.opaque;
        },
        enumClass: (node) {
          node.isIncluded =
              node.originalName != 'ExcludedEnum' &&
              !node.originalName.startsWith('RegexExcludedEnum');
          if (node.name == 'EnumOld') {
            node.name = 'EnumNew';
          }
          if (node.originalName == 'AsIntEnum' ||
              node.originalName.startsWith('AsIntRegex')) {
            node.style = EnumStyle.intConstants;
          }
          node.silenceWarning = true;
        },
        unnamedEnumConstant: (node) {
          node.isIncluded =
              node.originalName != 'UNNAMED_EXCLUDED' &&
              !node.originalName.startsWith('UNNAMED_REGEX_EXCLUDED_');
          if (node.name == 'UNNAMED_OLD_CONST') {
            node.name = 'UNNAMED_NEW_CONST';
          }
          final match = RegExp(r'^UNNAMED_PREFIX_(.*)$').firstMatch(node.name);
          if (match != null) {
            node.name = r'UNNAMED_STRIP_$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
        },
        global: (node) {
          node.isIncluded =
              node.originalName != 'excluded_global' &&
              !node.originalName.startsWith('regex_excluded_');
          if (node.name == 'prefix_global_test') {
            node.name = 'renamed_global_test';
          }
          final match = RegExp(r'^prefix_global_(.*)$').firstMatch(node.name);
          if (match != null) {
            node.name = r'global_$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
          if (node.originalName == 'sym_addr_global' ||
              node.originalName.startsWith('sym_addr_regex_')) {
            node.exposeSymbolAddress = true;
          }
        },
        macroConstant: (node) {
          node.isIncluded =
              node.originalName != 'MACRO_EXCLUDE' &&
              !node.originalName.startsWith('MACRO_REGEX_EXCLUDE_');
          if (node.name == 'MACRO_EXACT') {
            node.name = 'MACRO_NEW_EXACT';
          }
          final match = RegExp(r'^MACRO_PREFIX_(.*)$').firstMatch(node.name);
          if (match != null) {
            node.name = r'MACRO_STRIP_$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
        },
        typealias: (node) {
          node.isIncluded =
              (node.originalName != 'excluded_typedef' &&
                  !node.originalName.startsWith('regex_excluded_'))
              ? TypealiasInclude.always
              : TypealiasInclude.never;
          if (node.name == 'old_typedef_t') {
            node.name = 'new_typedef_t';
          }
          final match = RegExp(r'^regex_prefix_(.*)$').firstMatch(node.name);
          if (match != null) {
            node.name = r'regex_strip_$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
        },
        objCInterface: (node) {
          node.isIncluded =
              node.originalName != 'ExcludedInterface' &&
              !node.originalName.startsWith('RegexExcludedInterface');
          if (node.name == 'InterfaceOld') {
            node.name = 'InterfaceNew';
          }
          if (node.originalName == 'ComprehensiveInterface') {
            node.module = 'ComprehensiveModule';
          }
          node.includeCategories = false;
        },
        objCProtocol: (node) {
          node.isIncluded =
              node.originalName != 'ExcludedProtocol' &&
              !node.originalName.startsWith('RegexExcludedProtocol');
          if (node.name == 'ProtocolOld') {
            node.name = 'ProtocolNew';
          }
          if (node.originalName == 'ComprehensiveProtocol') {
            node.module = 'ComprehensiveModule';
          }
        },
        objCCategory: (node) {
          node.isIncluded =
              node.originalName != 'ExcludedCategory' &&
              !node.originalName.startsWith('RegexExcludedCategory');
          if (node.name == 'CategoryOld') {
            node.name = 'CategoryNew';
          }
        },
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface) {
            if (parent.originalName == 'ComprehensiveInterface') {
              node.isIncluded =
                  node.selector != 'filteredMethod' &&
                  !node.selector.startsWith('regexFiltered');
            }
            if (parent.originalName == 'ComprehensiveInterface' &&
                node.selector == 'oldMethodName') {
              node.name = 'newMethodName';
            }
            if (parent.originalName == 'ComprehensiveInterface' &&
                RegExp(r'^prefixMethod_.*$').hasMatch(node.selector)) {
              node.name = 'newPrefixMethod';
            }
            if (parent.originalName == 'ComprehensiveInterface') {
              if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.selector)
                  case final match?) {
                node.name = r'$2_$1'.replaceAllMapped(
                  RegExp(r'\$([0-9])'),
                  (m) => match[int.parse(m[1]!)] ?? '',
                );
              }
            }
          }
          if (parent is ObjCProtocol) {
            if (parent.originalName == 'ComprehensiveProtocol') {
              node.isIncluded =
                  node.selector != 'protoFilteredMethod' &&
                  !node.selector.startsWith('protoRegexFiltered');
            }
          }
          if (parent is ObjCCategory) {
            if (parent.originalName == 'ComprehensiveCategory') {
              node.isIncluded =
                  node.selector != 'catFilteredMethod' &&
                  !node.selector.startsWith('catRegexFiltered');
            }
            if (parent.originalName == 'ComprehensiveCategory' &&
                node.selector == 'catOldMethodName') {
              node.name = 'catNewMethodName';
            }
            if (parent.originalName == 'ComprehensiveCategory' &&
                RegExp(r'^catPrefixMethod_.*$').hasMatch(node.selector)) {
              node.name = 'catNewPrefixMethod';
            }
          }
        },
        field: (node) {
          final parent = node.parent;
          if (parent is Struct &&
              parent.originalName == 'FieldRenameStruct' &&
              node.originalName == 'old_field') {
            node.name = 'new_field';
          }
          if (parent is Struct &&
              parent.originalName == 'RegexFieldStruct' &&
              RegExp(r'^prefix_field_.*$').hasMatch(node.originalName)) {
            node.name = 'renamed_field';
          }
          if (parent is Struct && parent.originalName == 'RegexFieldStruct') {
            if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.originalName)
                case final match?) {
              node.name = r'$2_$1'.replaceAllMapped(
                RegExp(r'\$([0-9])'),
                (m) => match[int.parse(m[1]!)] ?? '',
              );
            }
          }
          if (parent is Union &&
              parent.originalName == 'FieldRenameUnion' &&
              node.originalName == 'old_field') {
            node.name = 'new_field';
          }
          if (parent is Union &&
              parent.originalName == 'FieldRenameUnion' &&
              RegExp(r'^prefix_field_.*$').hasMatch(node.originalName)) {
            node.name = 'renamed_field';
          }
          if (parent is Union && parent.originalName == 'FieldRenameUnion') {
            if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.originalName)
                case final match?) {
              node.name = r'$2_$1'.replaceAllMapped(
                RegExp(r'\$([0-9])'),
                (m) => match[int.parse(m[1]!)] ?? '',
              );
            }
          }
        },
        param: (node) {
          final parent = node.parent;
          if (parent is Func &&
              parent.originalName == 'func_param_rename' &&
              node.originalName == 'old_param') {
            node.name = 'new_param';
          }
          if (parent is Func &&
              parent.originalName == 'func_regex_param_rename' &&
              RegExp(r'^prefix_param_.*$').hasMatch(node.originalName)) {
            node.name = 'new_param';
          }
          if (parent is Func &&
              parent.originalName == 'func_regex_param_rename') {
            if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.originalName)
                case final match?) {
              node.name = r'$2_$1'.replaceAllMapped(
                RegExp(r'\$([0-9])'),
                (m) => match[int.parse(m[1]!)] ?? '',
              );
            }
          }
        },
        enumConstant: (node) {
          final parent = node.parent;
          if (parent.originalName == 'MemberRenameEnum' &&
              node.originalName == 'OLD_CONST') {
            node.name = 'NEW_CONST';
          }
          if (parent.originalName == 'RegexMemberRenameEnum' &&
              RegExp(r'^OLD_PREFIX_.*$').hasMatch(node.originalName)) {
            node.name = 'NEW_PREFIX';
          }
          if (parent.originalName == 'RegexMemberRenameEnum') {
            if (RegExp(r'^SWAP_(.*)_(.*)$').firstMatch(node.originalName)
                case final match?) {
              node.name = r'$2_$1'.replaceAllMapped(
                RegExp(r'\$([0-9])'),
                (m) => match[int.parse(m[1]!)] ?? '',
              );
            }
          }
        },
      ),
    ],
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty
      ? Uri.directory(args.first)
      : Platform.environment['OUTPUT_DIR'] != null
      ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
      : null;
  await getConfig(outputDir: outputDir).generate();
}
