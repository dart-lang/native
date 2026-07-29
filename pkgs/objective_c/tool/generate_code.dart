// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Re-compile trigger.

// Runs the FFIgen visitors, then merges tool/data/extra_methods.dart.in into the
// Objective C bindings.

import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart';

const runtimeBindings = 'lib/src/runtime_bindings_generated.dart';
const cBindings = 'lib/src/c_bindings_generated.dart';
const objcBindings = 'lib/src/objective_c_bindings_generated.dart';
const objcExports = 'lib/src/objective_c_bindings_exported.dart';
const extraMethodsFile = 'tool/data/extra_methods.dart.in';
const builtInTypes =
    '../ffigen/lib/src/code_generator/objc_built_in_types.dart';
const interfaceListTest = 'test/interface_lists_test.dart';

void dartCmd(List<String> args) {
  final exec = Platform.resolvedExecutable;
  final proc = Process.runSync(exec, args, runInShell: true);
  if (proc.exitCode != 0) {
    exitCode = proc.exitCode;
    print(proc.stdout);
    print(proc.stderr);
    throw Exception('Command failed: $exec ${args.join(" ")}');
  }
}

final _clsDecl = RegExp(r'^extension type (\w+)\W');
String? parseClassDecl(String line) => _clsDecl.firstMatch(line)?[1];

Map<String, String> parseExtraMethods(String filename) {
  final extraMethods = <String, String>{};
  String? currentClass;
  late StringBuffer methods;
  for (final line in File(filename).readAsLinesSync()) {
    if (currentClass == null) {
      final cls = parseClassDecl(line);
      if (cls != null) {
        currentClass = cls;
        methods = StringBuffer();
      }
    } else {
      if (line == '}') {
        extraMethods[currentClass] = methods.toString();
        currentClass = null;
      } else {
        methods.writeln(line);
      }
    }
  }
  return extraMethods;
}

void mergeExtraMethods(String filename, Map<String, String> extraMethods) {
  final out = StringBuffer();
  String? pendingClass;
  String? pendingExtra;

  for (final line in File(filename).readAsLinesSync()) {
    out.writeln(line);
    if (pendingClass != null) {
      if (line.contains('{')) {
        out.writeln(pendingExtra);
        pendingClass = null;
        pendingExtra = null;
      }
    } else {
      final cls = parseClassDecl(line);
      final extra = cls == null ? null : extraMethods[cls];
      if (cls != null && extra != null) {
        if (line.contains('{')) {
          out.writeln(extra);
          extraMethods.remove(cls);
        } else {
          pendingClass = cls;
          pendingExtra = extra;
          extraMethods.remove(cls);
        }
      }
    }
  }
  assert(extraMethods.isEmpty);

  File(filename).writeAsStringSync(out.toString());
}

class RuntimeBindingsVisitor extends Visitor {
  static const functions = {
    'object_getClass',
    'sel_registerName',
    'sel_getName',
    'protocol_getMethodDescription',
    'protocol_getName',
  };

  static const functionRenames = {
    'sel_registerName': 'registerName',
    'sel_getName': 'getName',
    'objc_getClass': 'getClass',
    'objc_retain': 'objectRetain',
    'objc_retainBlock': 'blockRetain',
    'objc_release': 'objectRelease',
    'objc_autorelease': 'objectAutorelease',
    'objc_msgSend': 'msgSend',
    'objc_msgSend_fpret': 'msgSendFpret',
    'objc_msgSend_stret': 'msgSendStret',
    'object_getClass': 'getObjectClass',
    'objc_copyClassList': 'copyClassList',
    'objc_getProtocol': 'getProtocol',
    'objc_autoreleasePoolPush': 'autoreleasePoolPush',
    'objc_autoreleasePoolPop': 'autoreleasePoolPop',
    'protocol_getMethodDescription': 'getMethodDescription',
    'protocol_getName': 'getProtocolName',
  };

  static const globals = {
    'NSKeyValueChangeIndexesKey',
    'NSKeyValueChangeKindKey',
    'NSKeyValueChangeNewKey',
    'NSKeyValueChangeNotificationIsPriorKey',
    'NSKeyValueChangeOldKey',
    'NSLocalizedDescriptionKey',
  };

  const RuntimeBindingsVisitor();

  @override
  void visitFunc(Func node) {
    final isObjc = node.originalName.startsWith('objc_');
    if (!isObjc && !functions.contains(node.originalName)) {
      node.isIncluded = false;
      return;
    }
    node.isIncluded = true;
    if (!node.originalName.startsWith('objc_msgSend')) {
      node.isLeaf = true;
    }
    final renamed = functionRenames[node.originalName];
    if (renamed != null) {
      node.name = renamed;
    }
  }

  @override
  void visitGlobal(Global node) {
    if (node.originalName.startsWith('_') &&
        node.originalName.endsWith('Block')) {
      node.isIncluded = true;
      node.name = node.originalName.substring(1);
    } else if (globals.contains(node.originalName)) {
      node.isIncluded = true;
      if (node.originalName.startsWith('_')) {
        node.name = node.originalName.substring(1);
      }
    } else {
      node.isIncluded = false;
    }
  }

  @override
  void visitStruct(Struct node) {
    if (node.originalName.startsWith('_ObjC')) {
      node.isIncluded = true;
      node.name = 'ObjC${node.originalName.substring(5)}';
    }
  }

  @override
  void visitEnum(EnumClass node) {
    node.isIncluded = false;
  }

  @override
  void visitMacroConstant(MacroConstant node) {
    node.isIncluded = false;
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {
    node.isIncluded = false;
  }

  @override
  void visitUnion(Union node) {
    node.isIncluded = false;
  }
}

class CBindingsVisitor extends Visitor {
  static const nonLeaf = {
    'DOBJC_deleteFinalizableHandle',
    'DOBJC_disposeObjCBlockWithClosure',
    'DOBJC_newFinalizableBool',
    'DOBJC_newFinalizableHandle',
    'DOBJC_awaitWaiter',
  };

  const CBindingsVisitor();

  @override
  void visitFunc(Func node) {
    final isDobjc = node.originalName.startsWith('DOBJC_');
    final isNewFinalizable = node.originalName == 'newFinalizableHandle';
    if (!isDobjc && !isNewFinalizable) {
      node.isIncluded = false;
      return;
    }
    node.isIncluded = true;
    if (!nonLeaf.contains(node.originalName)) {
      node.isLeaf = true;
    }
    if (isDobjc) {
      node.name = node.originalName.substring(6);
    }
  }

  @override
  void visitTypealias(Typealias node) {
    if (node.originalName == 'Dart_FinalizableHandle') {
      node.isIncluded = true;
    }
  }

  @override
  void visitStruct(Struct node) {
    if (node.originalName == '_DOBJC_Context') {
      node.isIncluded = true;
      node.name = 'DOBJC_Context';
    } else if (node.originalName == '_Dart_FinalizableHandle') {
      node.isIncluded = true;
      node.name = 'Dart_FinalizableHandle_';
    } else if (node.originalName.startsWith('_ObjC')) {
      node.isIncluded = true;
      node.name = 'ObjC${node.originalName.substring(5)}';
    }
  }

  @override
  void visitMacroConstant(MacroConstant node) {
    if (node.originalName == 'ILLEGAL_PORT') {
      node.isIncluded = true;
    } else {
      node.isIncluded = false;
    }
  }

  @override
  void visitEnum(EnumClass node) {
    node.isIncluded = false;
  }

  @override
  void visitGlobal(Global node) {
    node.isIncluded = false;
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {
    node.isIncluded = false;
  }

  @override
  void visitUnion(Union node) {
    node.isIncluded = false;
  }
}

class ObjCBindingsVisitor extends Visitor {
  static const interfaces = {
    'DOBJCDartInputStreamAdapter': 'DartInputStreamAdapter',
    'DOBJCDartInputStreamAdapterWeakHolder':
        'DartInputStreamAdapterWeakHolder',
    'DOBJCObservation': 'DOBJCObservation',
    'DOBJCDartProtocolBuilder': 'DartProtocolBuilder',
    'DOBJCDartProtocol': 'DartProtocol',
    'NSArray': 'NSArray',
    'NSAttributedString': 'NSAttributedString',
    'NSAttributedStringMarkdownParsingOptions':
        'NSAttributedStringMarkdownParsingOptions',
    'NSBundle': 'NSBundle',
    'NSCharacterSet': 'NSCharacterSet',
    'NSCoder': 'NSCoder',
    'NSData': 'NSData',
    'NSDate': 'NSDate',
    'NSDictionary': 'NSDictionary',
    'NSEnumerator': 'NSEnumerator',
    'NSError': 'NSError',
    'NSIndexSet': 'NSIndexSet',
    'NSInputStream': 'NSInputStream',
    'NSInvocation': 'NSInvocation',
    'NSItemProvider': 'NSItemProvider',
    'NSLocale': 'NSLocale',
    'NSMethodSignature': 'NSMethodSignature',
    'NSMutableArray': 'NSMutableArray',
    'NSMutableData': 'NSMutableData',
    'NSMutableDictionary': 'NSMutableDictionary',
    'NSMutableIndexSet': 'NSMutableIndexSet',
    'NSMutableOrderedSet': 'NSMutableOrderedSet',
    'NSMutableSet': 'NSMutableSet',
    'NSMutableString': 'NSMutableString',
    'NSNotification': 'NSNotification',
    'NSNull': 'NSNull',
    'NSNumber': 'NSNumber',
    'NSObject': 'NSObject',
    'NSOutputStream': 'NSOutputStream',
    'NSOrderedCollectionChange': 'NSOrderedCollectionChange',
    'NSOrderedCollectionDifference': 'NSOrderedCollectionDifference',
    'NSOrderedSet': 'NSOrderedSet',
    'NSPort': 'NSPort',
    'NSPortMessage': 'NSPortMessage',
    'NSProgress': 'NSProgress',
    'NSRunLoop': 'NSRunLoop',
    'NSSet': 'NSSet',
    'NSStream': 'NSStream',
    'NSString': 'NSString',
    'NSTimer': 'NSTimer',
    'NSURL': 'NSURL',
    'NSURLHandle': 'NSURLHandle',
    'NSValue': 'NSValue',
    'Protocol': 'Protocol',
  };

  static const protocols = {
    'NSCoding': 'NSCoding',
    'NSCopying': 'NSCopying',
    'NSFastEnumeration': 'NSFastEnumeration',
    'NSItemProviderReading': 'NSItemProviderReading',
    'NSItemProviderWriting': 'NSItemProviderWriting',
    'NSMutableCopying': 'NSMutableCopying',
    'NSObject': 'NSObjectProtocol',
    'NSPortDelegate': 'NSPortDelegate',
    'NSSecureCoding': 'NSSecureCoding',
    'NSStreamDelegate': 'NSStreamDelegate',
    'NSURLHandleClient': 'NSURLHandleClient',
    'Observer': 'Observer',
  };

  static const categories = {
    'NSDataCreation',
    'NSExtendedArray',
    'NSExtendedData',
    'NSExtendedDate',
    'NSExtendedDictionary',
    'NSExtendedEnumerator',
    'NSExtendedMutableArray',
    'NSExtendedMutableData',
    'NSExtendedMutableDictionary',
    'NSExtendedMutableOrderedSet',
    'NSExtendedMutableSet',
    'NSExtendedOrderedSet',
    'NSExtendedSet',
    'NSNumberCreation',
    'NSNumberIsFloat',
    'NSNumberIsBool',
    'NSStringExtensionMethods',
  };

  static const structs = {
    'AEDesc': 'AEDesc',
    '__CFRunLoop': 'CFRunLoop',
    '__CFString': 'CFString',
    'CGPoint': 'CGPoint',
    '_CGPoint': 'CGPoint',
    'CGRect': 'CGRect',
    '_CGRect': 'CGRect',
    'CGSize': 'CGSize',
    '_CGSize': 'CGSize',
    'NSEdgeInsets': 'NSEdgeInsets',
    '_NSEdgeInsets': 'NSEdgeInsets',
    'NSFastEnumerationState': 'NSFastEnumerationState',
    '_NSFastEnumerationState': 'NSFastEnumerationState',
    '_NSRange': 'NSRange',
    'NSRange': 'NSRange',
    '_NSZone': 'NSZone',
    'NSZone': 'NSZone',
    'OpaqueAEDataStorageType': 'OpaqueAEDataStorageType',
  };

  static const enums = {
    'NSAppleEventSendOptions',
    'NSAttributedStringEnumerationOptions',
    'NSAttributedStringFormattingOptions',
    'NSAttributedStringMarkdownInterpretedSyntax',
    'NSAttributedStringMarkdownParsingFailurePolicy',
    'NSBinarySearchingOptions',
    'NSCollectionChangeType',
    'NSComparisonResult',
    'NSDataBase64DecodingOptions',
    'NSDataBase64EncodingOptions',
    'NSDataCompressionAlgorithm',
    'NSDataReadingOptions',
    'NSDataSearchOptions',
    'NSDataWritingOptions',
    'NSDecodingFailurePolicy',
    'NSEnumerationOptions',
    'NSItemProviderFileOptions',
    'NSItemProviderRepresentationVisibility',
    'NSKeyValueChange',
    'NSKeyValueObservingOptions',
    'NSKeyValueSetMutationKind',
    'NSLinguisticTaggerOptions',
    'NSLocaleLanguageDirection',
    'NSOrderedCollectionDifferenceCalculationOptions',
    'NSPropertyListFormat',
    'NSQualityOfService',
    'NSSortOptions',
    'NSStreamEvent',
    'NSStreamStatus',
    'NSStringCompareOptions',
    'NSStringEncodingConversionOptions',
    'NSStringEnumerationOptions',
    'NSURLBookmarkCreationOptions',
    'NSURLBookmarkResolutionOptions',
    'NSURLHandleStatus',
  };

  const ObjCBindingsVisitor();

  @override
  void visitFunc(Func node) {
    node.isIncluded = false;
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    final renamed = interfaces[node.originalName];
    if (renamed != null) {
      node.isIncluded = true;
      node.name = renamed;
    }
    if (node.originalName == 'NSBundle') {
      for (final method in node.methods) {
        if (method.originalName ==
            'localizedStringForKey:value:table:localizations:') {
          method.isIncluded = false;
        }
      }
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    final renamed = protocols[node.originalName];
    if (renamed != null) {
      node.isIncluded = true;
      node.name = renamed;
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    if (categories.contains(node.originalName)) {
      node.isIncluded = true;
    } else {
      node.isIncluded = false;
    }
  }

  @override
  void visitStruct(Struct node) {
    if (node.originalName.isEmpty) {
      node.isIncluded = false;
      return;
    }
    final renamed = structs[node.originalName];
    if (renamed != null) {
      node.isIncluded = true;
      node.name = renamed;
    }
  }

  @override
  void visitEnum(EnumClass node) {
    if (enums.contains(node.originalName)) {
      node.isIncluded = true;
    } else {
      node.isIncluded = false;
    }
  }

  @override
  void visitTypealias(Typealias node) {
    if (node.originalName == 'CFStringRef') {
      node.isIncluded = true;
    }
  }

  @override
  void visitGlobal(Global node) {
    node.isIncluded = false;
  }

  @override
  void visitMacroConstant(MacroConstant node) {
    node.isIncluded = false;
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {
    node.isIncluded = false;
  }

  @override
  void visitUnion(Union node) {
    node.isIncluded = false;
  }
}

List<String> writeBuiltInTypes(String out, String bindingsFile) {
  final bindingsLines = File(bindingsFile).readAsLinesSync();
  Set<String> findBindings(RegExp re) =>
      bindingsLines.map(re.firstMatch).nonNulls.map((match) => match[1]!).toSet();

  final genInterfaces = findBindings(
    RegExp(r'^extension type ([^_]\w*)\._\( *objc\.ObjCObject '),
  ).toList()..sort();
  final genStructs = findBindings(
    RegExp(r'^final class (\w+) extends ffi\.(Struct|Opaque)'),
  ).toList()..sort();
  final genEnums = findBindings(
    RegExp(r'^(?:enum|sealed class) (\w+) {'),
  ).toList()..sort();
  final genProtocols = findBindings(
    RegExp(r'^extension type ([^_]\w*)\._\(objc\.ObjCProtocol '),
  ).toList()..sort();
  final genCategories = findBindings(
    RegExp(r'^extension (\w+) on \w+ {'),
  ).toList()..sort();

  final interfacesMap = {
    for (final name in genInterfaces)
      (ObjCBindingsVisitor.interfaces.entries
          .firstWhere((e) => e.value == name, orElse: () => MapEntry(name, name))
          .key): name,
  };
  final structsMap = {
    for (final name in genStructs)
      (ObjCBindingsVisitor.structs.entries
          .firstWhere((e) => e.value == name, orElse: () => MapEntry(name, name))
          .key): name,
  };
  final protocolsMap = {
    for (final name in genProtocols)
      (ObjCBindingsVisitor.protocols.entries
          .firstWhere((e) => e.value == name, orElse: () => MapEntry(name, name))
          .key): name,
  };

  final s = StringBuffer();
  final exports = <String>{};

  s.write('''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generated by package:objective_c's tool/generate_code.dart.
''');

  void writeDecls(
    String name,
    Map<String, String> namesMap, [
    Iterable<String>? namesIterable,
  ]) {
    final keys = namesIterable ?? namesMap.keys;
    final map =
        namesIterable != null
            ? {for (final k in keys) k: k}
            : Map<String, String>.from(namesMap);
    exports.addAll(map.values);
    final anyRenames = map.entries.any((kv) => kv.key != kv.value);
    final elements =
        anyRenames
            ? map.entries.map((kv) => "  '${kv.key}': '${kv.value}',")
            : map.keys.map((key) => "  '$key',");

    s.write('''

const $name = {
${elements.join('\n')}
};
''');
  }

  writeDecls('objCBuiltInInterfaces', interfacesMap);
  exports.addAll([
    for (final name in interfacesMap.values) '$name\$Methods',
  ]);
  writeDecls('objCBuiltInCompounds', structsMap);
  writeDecls('objCBuiltInEnums', {}, genEnums);
  writeDecls('objCBuiltInProtocols', protocolsMap);
  exports.addAll([
    for (final name in protocolsMap.values) '$name\$Methods',
  ]);
  exports.addAll([
    for (final name in protocolsMap.values) '$name\$Builder',
  ]);
  writeDecls('objCBuiltInCategories', {}, genCategories);

  File(out).writeAsStringSync(s.toString());

  return exports.toList()..sort();
}

void writeExports(List<String> exports, String out) {
  File(out).writeAsStringSync('''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generated by package:objective_c's tool/generate_code.dart.

export 'objective_c_bindings_generated.dart'
    show
        ${exports.join(',\n        ')};
''');
}

Future<void> run({required bool format}) async {
  final pkgUri = await Isolate.resolvePackageUri(
    Uri.parse('package:objective_c/objective_c.dart'),
  );
  final root = (pkgUri ?? Platform.script).resolve('../');

  print('Generating runtime bindings...');
  FfiGenerator(
    headers: Headers(entryPoints: [root.resolve('src/objective_c_runtime.h')]),
    visitors: [const RuntimeBindingsVisitor()],
    output: Output(
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c_runtime.h`.
// Regenerate bindings with `dart run tool/generate_code.dart`.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_element
// coverage:ignore-file
''',
      style: const NativeExternalBindings(),
      dartFile: root.resolve(runtimeBindings),
    ),
  ).generate();

  print('Generating C bindings...');
  FfiGenerator(
    headers: Headers(
      entryPoints: [
        root.resolve('src/include/dart_api_dl.h'),
        root.resolve('src/objective_c.h'),
        root.resolve('src/os_version.h'),
      ],
    ),
    visitors: [const CBindingsVisitor()],
    output: Output(
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c.h` etc.
// Regenerate bindings with `dart run tool/generate_code.dart`.

// coverage:ignore-file
''',
      style: const NativeExternalBindings(
        assetId: 'package:objective_c/objective_c.dylib',
      ),
      dartFile: root.resolve(cBindings),
    ),
  ).generate();

  print('Generating ObjC bindings...');
  FfiGenerator(
    headers: Headers(
      entryPoints: [
        root.resolve('src/foundation.h'),
        root.resolve('src/input_stream_adapter.h'),
        root.resolve('src/ns_number.h'),
        root.resolve('src/observer.h'),
        root.resolve('src/protocol.h'),
      ],
    ),
    structs: const Structs(dependencies: CompoundDependencies.opaque),
    objectiveC: const ObjectiveC(
      generateForPackageObjectiveC: true,
      categories: Categories(includeTransitive: false),
    ),
    visitors: [const ObjCBindingsVisitor()],
    output: Output(
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for package:objective_c's ObjC code and the Foundation framework.
// Regenerate bindings with `dart run tool/generate_code.dart`.

// coverage:ignore-file
''',
      format: false,
      style: const NativeExternalBindings(
        assetId: 'package:objective_c/objective_c.dylib',
      ),
      dartFile: root.resolve(objcBindings),
      objectiveCFile: root.resolve('src/objective_c_bindings_generated.m'),
    ),
  ).generate();

  mergeExtraMethods(objcBindings, parseExtraMethods(extraMethodsFile));

  print('Generating objc_built_in_types.dart...');
  final exports = writeBuiltInTypes(builtInTypes, objcBindings);

  print('Generating objc_bindings_exported.dart...');
  writeExports(exports, objcExports);

  if (format) {
    print('Formatting bindings...');
    dartCmd([
      'format',
      runtimeBindings,
      cBindings,
      objcBindings,
      builtInTypes,
      objcExports,
    ]);
  }

  print('Running tests...');
  dartCmd(['test', interfaceListTest]);
}

Future<void> main(List<String> args) async {
  Directory.current = Platform.script.resolve('..').path;
  final argResults =
      (ArgParser()..addFlag(
            'format',
            help: 'Format the generated code.',
            defaultsTo: true,
            negatable: true,
          ))
          .parse(args);
  await run(format: argResults.flag('format'));
}
