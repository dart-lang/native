// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../../objective_c/');
  final dartPath = outputDir != null
      ? outputDir.resolve('objective_c_bindings_generated.dart')
      : packageRoot.resolve('lib/src/objective_c_bindings_generated.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('objective_c_bindings_generated.m')
      : packageRoot.resolve('src/objective_c_bindings_generated.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const NativeExternalBindings(
        assetId: 'package:objective_c/objective_c.dylib',
      ),
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for package:objective_c's ObjC code and the Foundation framework.
// Regenerate bindings with `dart run tool/generate_code.dart`.

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
      externalVersions: ExternalVersions(
        ios: Versions(min: Version(12, 0, 0)),
        macos: Versions(min: Version(10, 14, 0)),
      ),
      generateForPackageObjectiveC: true,
    ),
    visitors: [
      Visitor(
        struct: (node) {
          node.isIncluded = {
            'AEDesc',
            '__CFRunLoop',
            '__CFString',
            'CGPoint',
            'CGRect',
            'CGSize',
            'NSEdgeInsets',
            'NSFastEnumerationState',
            '_NSRange',
            '_NSZone',
            'OpaqueAEDataStorageType',
          }.contains(node.originalName);
          const rename = {
            '__CFRunLoop': 'CFRunLoop',
            '__CFString': 'CFString',
            '_NSRange': 'NSRange',
            '_NSZone': 'NSZone',
          };
          if (rename[node.name] case final r?) {
            node.name = r;
          }
          node.dependencies = CompoundDependencies.full;
        },
        enumClass: (node) => node.isIncluded = {
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
        }.contains(node.originalName),
        typealias: (node) =>
            node.isIncluded = (node.originalName == 'CFStringRef')
            ? TypealiasInclude.ifUsed
            : TypealiasInclude.never,
        objCInterface: (node) {
          node.isIncluded = {
            'DOBJCDartInputStreamAdapter',
            'DOBJCDartInputStreamAdapterWeakHolder',
            'DOBJCObservation',
            'DOBJCDartProtocolBuilder',
            'DOBJCDartProtocol',
            'NSArray',
            'NSAttributedString',
            'NSAttributedStringMarkdownParsingOptions',
            'NSBundle',
            'NSCharacterSet',
            'NSCoder',
            'NSData',
            'NSDate',
            'NSDictionary',
            'NSEnumerator',
            'NSError',
            'NSIndexSet',
            'NSInputStream',
            'NSInvocation',
            'NSItemProvider',
            'NSLocale',
            'NSMethodSignature',
            'NSMutableArray',
            'NSMutableData',
            'NSMutableDictionary',
            'NSMutableIndexSet',
            'NSMutableOrderedSet',
            'NSMutableSet',
            'NSMutableString',
            'NSNotification',
            'NSNull',
            'NSNumber',
            'NSObject',
            'NSOutputStream',
            'NSOrderedCollectionChange',
            'NSOrderedCollectionDifference',
            'NSOrderedSet',
            'NSPort',
            'NSPortMessage',
            'NSProgress',
            'NSRunLoop',
            'NSSet',
            'NSStream',
            'NSString',
            'NSTimer',
            'NSURL',
            'NSURLHandle',
            'NSValue',
            'Protocol',
          }.contains(node.originalName);
          const rename = {
            'DOBJCDartInputStreamAdapter': 'DartInputStreamAdapter',
            'DOBJCDartInputStreamAdapterWeakHolder':
                'DartInputStreamAdapterWeakHolder',
            'DOBJCDartProtocolBuilder': 'DartProtocolBuilder',
            'DOBJCDartProtocol': 'DartProtocol',
          };
          if (rename[node.name] case final r?) {
            node.name = r;
          }
          node.includeCategories = false;
        },
        objCProtocol: (node) {
          node.isIncluded = {
            'NSCoding',
            'NSCopying',
            'NSFastEnumeration',
            'NSItemProviderReading',
            'NSItemProviderWriting',
            'NSMutableCopying',
            'NSObject',
            'NSPortDelegate',
            'NSSecureCoding',
            'NSStreamDelegate',
            'Observer',
          }.contains(node.originalName);
          if (node.name == 'NSObject') {
            node.name = 'NSObjectProtocol';
          }
        },
        objCCategory: (node) => node.isIncluded = {
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
        }.contains(node.originalName),
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface) {
            if (parent.originalName == 'NSBundle' &&
                node.selector ==
                    'localizedStringForKey:value:table:localizations:') {
              node.isIncluded = false;
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
