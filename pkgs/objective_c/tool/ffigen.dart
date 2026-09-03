// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Runs the FFIgen configs, then merges tool/data/extra_methods.dart.in into the
// Objective C bindings.

import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';

const assetId = 'package:objective_c/objective_c.dylib';
const runtimeBindings = 'lib/src/runtime_bindings_generated.dart';
const cBindings = 'lib/src/c_bindings_generated.dart';
const objcBindings = 'lib/src/objective_c_bindings_generated.dart';

const objcInterfaces = {
  'DOBJCDartInputStreamAdapter': 'DartInputStreamAdapter',
  'DOBJCDartInputStreamAdapterWeakHolder': 'DartInputStreamAdapterWeakHolder',
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

const objcProtocols = {
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
  'Observer': 'Observer',
};

const objcCategories = {
  'NSArrayCreation',
  'NSAttributedStringCreateFromMarkdown',
  'NSAttributedStringFormatting',
  'NSDataBase64Encoding',
  'NSDataCompression',
  'NSDataCreation',
  'NSDateCreation',
  'NSDictionaryCreation',
  'NSExtendedArray',
  'NSExtendedAttributedString',
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
  'NSInputStreamExtensions',
  'NSLocaleCreation',
  'NSMutableArrayCreation',
  'NSMutableDataCreation',
  'NSMutableDictionaryCreation',
  'NSMutableOrderedSetCreation',
  'NSMutableSetCreation',
  'NSNotificationCreation',
  'NSNumberCreation',
  'NSNumberIsBool',
  'NSNumberIsFloat',
  'NSOrderedSetCreation',
  'NSOutputStreamExtensions',
  'NSSetCreation',
  'NSStringExtensionMethods',
};

const objcStructs = {
  'AEDesc': 'AEDesc',
  '__CFRunLoop': 'CFRunLoop',
  '__CFString': 'CFString',
  'CGPoint': 'CGPoint',
  'CGRect': 'CGRect',
  'CGSize': 'CGSize',
  'NSEdgeInsets': 'NSEdgeInsets',
  'NSFastEnumerationState': 'NSFastEnumerationState',
  '_NSRange': 'NSRange',
  '_NSZone': 'NSZone',
  'OpaqueAEDataStorageType': 'OpaqueAEDataStorageType',
};

const objcEnums = {
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

Future<void> main(List<String> args) async {
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

Future<void> run({required bool format, Uri? packageRoot}) async {
  packageRoot ??= _defaultPackageRoot();
  final logger = Logger.root;
  logger.level = Level.SEVERE;

  final runtimeBindingsPath = packageRoot.resolve(runtimeBindings).toFilePath();
  final cBindingsPath = packageRoot.resolve(cBindings).toFilePath();
  final objcBindingsPath = packageRoot.resolve(objcBindings).toFilePath();
  final objcExportsPath = packageRoot
      .resolve('lib/src/objective_c_bindings_exported.dart')
      .toFilePath();
  final extraMethodsFilePath = packageRoot
      .resolve('tool/data/extra_methods.dart.in')
      .toFilePath();
  final builtInTypesPath = packageRoot
      .resolve('../ffigen/lib/src/code_generator/objc_built_in_types.dart')
      .toFilePath();
  final interfaceListTestPath = packageRoot
      .resolve('test/interface_lists_test.dart')
      .toFilePath();

  print('Generating runtime bindings...');
  await getRuntimeConfig(packageRoot).generate(logger: logger);

  print('Generating C bindings...');
  await getCConfig(packageRoot).generate(logger: logger);

  print('Generating ObjC bindings...');
  await getObjCConfig(packageRoot).generate(logger: logger);
  mergeExtraMethods(objcBindingsPath, parseExtraMethods(extraMethodsFilePath));

  print('Generating objc_built_in_types.dart...');
  final exports = writeBuiltInTypes(builtInTypesPath);

  print('Generating objc_bindings_exported.dart...');
  writeExports(exports, objcExportsPath);

  if (format) {
    print('Formatting bindings...');
    dartCmd([
      'format',
      runtimeBindingsPath,
      cBindingsPath,
      objcBindingsPath,
      builtInTypesPath,
      objcExportsPath,
    ], workingDir: packageRoot.toFilePath());
  }

  print('Running tests...');
  dartCmd([
    'test',
    interfaceListTestPath,
  ], workingDir: packageRoot.toFilePath());
}

List<String> writeBuiltInTypes(String out) {
  final s = StringBuffer();
  final exports = <String>{};

  s.write('''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generated by package:objective_c's tool/ffigen.dart.
''');

  void writeMap(String name, Map<String, String> map) {
    exports.addAll(map.values);
    s.write('''

const $name = {
${map.entries.map((e) => "  '${e.key}': '${e.value}',").join('\n')}
};
''');
  }

  void writeSet(String name, Set<String> set) {
    exports.addAll(set);
    s.write('''

const $name = {
${set.map((e) => "  '$e',").join('\n')}
};
''');
  }

  writeMap('objCBuiltInInterfaces', objcInterfaces);
  exports.addAll([for (final name in objcInterfaces.values) '$name\$Methods']);
  writeMap('objCBuiltInCompounds', objcStructs);
  writeSet('objCBuiltInEnums', objcEnums);
  writeMap('objCBuiltInProtocols', objcProtocols);
  exports.addAll([for (final name in objcProtocols.values) '$name\$Methods']);
  exports.addAll([for (final name in objcProtocols.values) '$name\$Builder']);
  writeSet('objCBuiltInCategories', objcCategories);

  File(out).writeAsStringSync(s.toString());

  return exports.toList()..sort();
}

void writeExports(List<String> exports, String out) {
  File(out).writeAsStringSync('''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generated by package:objective_c's tool/ffigen.dart.

export 'objective_c_bindings_generated.dart'
    show
        ${exports.join(',\n        ')};
''');
}

FfiGenerator getRuntimeConfig([Uri? packageRoot]) {
  packageRoot ??= _defaultPackageRoot();

  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve(runtimeBindings)),
      style: const NativeExternalBindings(),
      format: false,
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c_runtime.h`.
// Regenerate bindings with `dart run tool/ffigen.dart`.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_element
// coverage:ignore-file
''',
    ),
    input: Input(
      entryPoints: [packageRoot.resolve('src/objective_c_runtime.h')],
    ),
    objectiveC: const ObjectiveC(
      // ignore: deprecated_member_use, deprecated_member_use_from_same_package
      generateForPackageObjectiveC: true,
    ),
    visitors: [
      Visitor(
        func: (node) {
          const funcRenames = {
            'objc_autorelease': 'objectAutorelease',
            'objc_autoreleasePoolPop': 'autoreleasePoolPop',
            'objc_autoreleasePoolPush': 'autoreleasePoolPush',
            'objc_copyClassList': 'copyClassList',
            'objc_getClass': 'getClass',
            'objc_getProtocol': 'getProtocol',
            'objc_msgSend': 'msgSend',
            'objc_msgSend_fpret': 'msgSendFpret',
            'objc_msgSend_stret': 'msgSendStret',
            'objc_release': 'objectRelease',
            'objc_retain': 'objectRetain',
            'objc_retainBlock': 'blockRetain',
            'object_getClass': 'getObjectClass',
            'protocol_getMethodDescription': 'getMethodDescription',
            'protocol_getName': 'getProtocolName',
            'sel_getName': 'getName',
            'sel_registerName': 'registerName',
          };
          if (funcRenames[node.name] case final renamed?) {
            node.isIncluded = true;
            node.name = renamed;
          }
          node.isLeaf = !node.originalName.startsWith('objc_msgSend');
        },
        global: (node) {
          const included = {
            'NSKeyValueChangeIndexesKey',
            'NSKeyValueChangeKindKey',
            'NSKeyValueChangeNewKey',
            'NSKeyValueChangeNotificationIsPriorKey',
            'NSKeyValueChangeOldKey',
            'NSLocalizedDescriptionKey',
          };
          node.isIncluded =
              included.contains(node.name) ||
              (node.name.startsWith('_NSConcrete') &&
                  node.name.endsWith('Block'));
          if (node.name.startsWith('_')) {
            node.name = node.name.substring(1);
          }
        },
        struct: (node) {
          if (node.name.startsWith('_ObjC')) {
            node.isIncluded = true;
            node.name = node.name.substring(1);
          }
        },
      ),
    ],
  );
}

FfiGenerator getCConfig([Uri? packageRoot]) {
  packageRoot ??= _defaultPackageRoot();

  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve(cBindings)),
      style: const NativeExternalBindings(assetId: assetId),
      format: false,
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c.h` etc.
// Regenerate bindings with `dart run tool/ffigen.dart`.

// coverage:ignore-file
''',
    ),
    input: Input(
      entryPoints: [
        packageRoot.resolve('src/include/dart_api_dl.h'),
        packageRoot.resolve('src/objective_c.h'),
        packageRoot.resolve('src/os_version.h'),
      ],
    ),
    objectiveC: const ObjectiveC(
      // ignore: deprecated_member_use, deprecated_member_use_from_same_package
      generateForPackageObjectiveC: true,
    ),
    visitors: [
      Visitor(
        func: (node) {
          if (node.name.startsWith('DOBJC_')) {
            node.isIncluded = true;
            node.name = node.name.substring(6);
          } else if (node.name == 'newFinalizableHandle') {
            node.isIncluded = true;
          }
          const nonLeaf = {
            'DOBJC_deleteFinalizableHandle',
            'DOBJC_disposeObjCBlockWithClosure',
            'DOBJC_newFinalizableBool',
            'DOBJC_newFinalizableHandle',
            'DOBJC_awaitWaiter',
            'DOBJC_invokeListenerPortBlock',
            'DOBJC_invokeBlockingPortBlock',
          };
          node.isLeaf = !nonLeaf.contains(node.originalName);
        },
        typealias: (node) {
          if (node.name == 'Dart_FinalizableHandle') {
            node.isIncluded = TypealiasInclude.always;
          }
        },
        struct: (node) {
          node.dependencies = CompoundDependencies.opaque;
          const included = {'_ObjCBlockImpl', '_ObjCBlockDesc', '_Version'};
          node.isIncluded = included.contains(node.name);
          if (node.name == '_Dart_FinalizableHandle') {
            node.name = 'Dart_FinalizableHandle_';
          } else if (node.name.startsWith('_')) {
            node.name = node.name.substring(1);
          }
        },
        macroConstant: (node) {
          node.isIncluded = node.name == 'ILLEGAL_PORT';
        },
      ),
    ],
  );
}

FfiGenerator getObjCConfig([Uri? packageRoot]) {
  packageRoot ??= _defaultPackageRoot();
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve(objcBindings)),
      objectiveCFile: packageRoot.resolve(
        'src/objective_c_bindings_generated.m',
      ),
      style: const NativeExternalBindings(assetId: assetId),
      format: false,
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for package:objective_c's ObjC code and the Foundation framework.
// Regenerate bindings with `dart run tool/ffigen.dart`.

// coverage:ignore-file
''',
    ),
    input: Input(
      entryPoints: [
        packageRoot.resolve('src/foundation.h'),
        packageRoot.resolve('src/input_stream_adapter.h'),
        packageRoot.resolve('src/ns_number.h'),
        packageRoot.resolve('src/observer.h'),
        packageRoot.resolve('src/protocol.h'),
      ],
    ),
    objectiveC: ObjectiveC(
      // ignore: deprecated_member_use, deprecated_member_use_from_same_package
      generateForPackageObjectiveC: true,
      externalVersions: ExternalVersions(
        ios: Versions(min: Version(12, 0, 0)),
        macos: Versions(min: Version(10, 14, 0)),
      ),
    ),
    visitors: [
      Visitor(
        objCInterface: (node) {
          node.includeCategories = false;
          if (objcInterfaces[node.originalName] case final renamed?) {
            node.isIncluded = true;
            node.name = renamed;
          }
        },
        objCProtocol: (node) {
          if (objcProtocols[node.originalName] case final renamed?) {
            node.isIncluded = true;
            node.name = renamed;
          }
        },
        objCCategory: (node) {
          if (objcCategories.contains(node.originalName)) {
            node.isIncluded = true;
          }
        },
        struct: (node) {
          if (objcStructs[node.originalName] case final renamed?) {
            node.isIncluded = true;
            node.name = renamed;
          }
        },
        enumClass: (node) {
          if (objcEnums.contains(node.originalName)) {
            node.isIncluded = true;
          }
        },
        typealias: (node) {
          const included = {'CFStringRef'};
          node.isIncluded = included.contains(node.originalName)
              ? TypealiasInclude.always
              : TypealiasInclude.never;
        },
        objCMethod: (node) {
          if (node.parent.originalName == 'NSBundle' &&
              node.originalName ==
                  'localizedStringForKey:value:table:localizations:') {
            node.isIncluded = false;
          }
        },
      ),
    ],
  );
}

Uri _defaultPackageRoot() {
  if (Platform.script.isScheme('file')) {
    final scriptFile = File.fromUri(Platform.script);
    var dir = scriptFile.parent;
    while (dir.path != dir.parent.path) {
      final pubspec = File('${dir.path}/pubspec.yaml');
      if (pubspec.existsSync()) {
        if (pubspec.readAsStringSync().contains('name: objective_c\n') ||
            pubspec.readAsStringSync().contains('name: objective_c\r\n')) {
          return dir.uri;
        }
      }
      dir = dir.parent;
    }
  }
  return Directory.current.uri;
}

void dartCmd(List<String> args, {String? workingDir}) {
  final exec = Platform.resolvedExecutable;
  final proc = Process.runSync(
    exec,
    args,
    runInShell: true,
    workingDirectory: workingDir,
  );
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
  for (final line in File(filename).readAsLinesSync()) {
    out.writeln(line);
    final cls = parseClassDecl(line);
    final extra = cls == null ? null : extraMethods[cls];
    if (cls != null && extra != null) {
      out.writeln(extra);
      extraMethods.remove(cls);
    }
  }
  assert(extraMethods.isEmpty);

  File(filename).writeAsStringSync(out.toString());
}
