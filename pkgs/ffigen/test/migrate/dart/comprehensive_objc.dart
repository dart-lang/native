// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

final _importedTypes = <String, ImportedType>{
  'mapped_typedef_t': ImportedType(
    const LibraryImport('custom_lib', 'package:custom_lib/custom_lib.dart'),
    'Int32',
    'int',
    'mapped_typedef_t',
  ),
};

ImportedType? importType(Declaration declaration) =>
    _importedTypes[declaration.originalName];

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/migrate/yaml/');
  await FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: configDir.resolve('comprehensive_objc_bindings.dart'),
      ),
      objectiveCFile: configDir.resolve('comprehensive_objc_bindings.m'),
      style: const DynamicLibraryBindings(
        wrapperName: 'ComprehensiveObjC',
        wrapperDocComment: 'Comprehensive ObjC bindings',
      ),
      commentType: const CommentType(CommentStyle.any, CommentLength.full),
      preamble: '''
// Comprehensive test preamble
''',
    ),
    input: Input(
      entryPoints: [configDir.resolve('comprehensive_objc.h')],
      include: (uri) => Glob('/**comprehensive_objc.h').matches(uri.path),
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
          if (RegExp(r'^strip_(.*)$').firstMatch(node.name) case final match?) {
            node.name = r'$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
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
          if (RegExp(r'^StripStruct_(.*)$').firstMatch(node.name)
              case final match?) {
            node.name = r'$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
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
          if (RegExp(r'^UNNAMED_PREFIX_(.*)$').firstMatch(node.name)
              case final match?) {
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
          if (RegExp(r'^prefix_global_(.*)$').firstMatch(node.name)
              case final match?) {
            node.name = r'global_$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
          if ({
            'sym_addr_global',
            'sym_addr_regex_global',
          }.contains(node.originalName)) {
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
          if (RegExp(r'^MACRO_PREFIX_(.*)$').firstMatch(node.name)
              case final match?) {
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
          if (RegExp(r'^regex_prefix_(.*)$').firstMatch(node.name)
              case final match?) {
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
              node.isIncluded = !{
                'filteredMethod',
                'regexFilteredMethod',
              }.contains(node.selector);
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
              node.isIncluded = !{
                'protoFilteredMethod',
                'protoRegexFilteredMethod',
              }.contains(node.selector);
            }
          }
          if (parent is ObjCCategory) {
            if (parent.originalName == 'ComprehensiveCategory') {
              node.isIncluded = !{
                'catFilteredMethod',
                'catRegexFilteredMethod',
              }.contains(node.selector);
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
          if (parent is Struct) {
            if (parent.originalName == 'FieldRenameStruct' &&
                node.originalName == 'old_field') {
              node.name = 'new_field';
            }
            if (parent.originalName == 'RegexFieldStruct' &&
                RegExp(r'^prefix_field_.*$').hasMatch(node.originalName)) {
              node.name = 'renamed_field';
            }
            if (parent.originalName == 'RegexFieldStruct') {
              if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.originalName)
                  case final match?) {
                node.name = r'$2_$1'.replaceAllMapped(
                  RegExp(r'\$([0-9])'),
                  (m) => match[int.parse(m[1]!)] ?? '',
                );
              }
            }
          }
          if (parent is Union) {
            if (parent.originalName == 'FieldRenameUnion' &&
                node.originalName == 'old_field') {
              node.name = 'new_field';
            }
            if (parent.originalName == 'FieldRenameUnion' &&
                RegExp(r'^prefix_field_.*$').hasMatch(node.originalName)) {
              node.name = 'renamed_field';
            }
            if (parent.originalName == 'FieldRenameUnion') {
              if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.originalName)
                  case final match?) {
                node.name = r'$2_$1'.replaceAllMapped(
                  RegExp(r'\$([0-9])'),
                  (m) => match[int.parse(m[1]!)] ?? '',
                );
              }
            }
          }
        },
        param: (node) {
          final parent = node.parent;
          if (parent is Func) {
            if (parent.originalName == 'func_param_rename' &&
                node.originalName == 'old_param') {
              node.name = 'new_param';
            }
            if (parent.originalName == 'func_regex_param_rename' &&
                RegExp(r'^prefix_param_.*$').hasMatch(node.originalName)) {
              node.name = 'new_param';
            }
            if (parent.originalName == 'func_regex_param_rename') {
              if (RegExp(r'^swap_(.*)_(.*)$').firstMatch(node.originalName)
                  case final match?) {
                node.name = r'$2_$1'.replaceAllMapped(
                  RegExp(r'\$([0-9])'),
                  (m) => match[int.parse(m[1]!)] ?? '',
                );
              }
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
  ).generate();
}
