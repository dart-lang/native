// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'src/block.dart';
export 'src/c_bindings_generated.dart'
    show
        ObjCBlockImpl,
        ObjCObject,
        ObjCSelector,
        blockRetain,
        objectRelease,
        objectRetain;
export 'src/internal.dart'
    hide
        ObjCBlockBase,
        blockHasRegisteredClosure,
        isValidBlock,
        isValidClass,
        isValidObject;
export 'src/ns_data.dart';
export 'src/ns_input_stream.dart';
export 'src/ns_mutable_data.dart';
export 'src/ns_string.dart';
// Keep in sync with pkgs/objective_c/ffigen_objc.yaml.
export 'src/objective_c_bindings_generated.dart'
    show
        DartProxy,
        DartProxyBuilder,
        NSArray,
        NSBinarySearchingOptions,
        NSCharacterSet,
        NSCoder,
        NSComparisonResult,
        NSData,
        NSDataBase64DecodingOptions,
        NSDataBase64EncodingOptions,
        NSDataCompressionAlgorithm,
        NSDataReadingOptions,
        NSDataSearchOptions,
        NSDataWritingOptions,
        NSDate,
        NSDictionary,
        NSEnumerationOptions,
        NSEnumerator,
        NSError,
        NSFastEnumerationState,
        NSIndexSet,
        NSInputStream,
        NSInvocation,
        NSItemProvider,
        NSItemProviderFileOptions,
        NSItemProviderRepresentationVisibility,
        NSKeyValueChange,
        NSKeyValueObservingOptions,
        NSKeyValueSetMutationKind,
        NSLocale,
        NSMethodSignature,
        NSMutableArray,
        NSMutableData,
        NSMutableDictionary,
        NSMutableIndexSet,
        NSMutableOrderedSet,
        NSMutableSet,
        NSMutableString,
        NSNotification,
        NSNumber,
        NSObject,
        NSOrderedCollectionDifferenceCalculationOptions,
        NSOrderedSet,
        NSOutputStream,
        NSProxy,
        NSRange,
        NSRunLoop,
        NSSet,
        NSSortOptions,
        NSStream,
        NSStreamDelegate,
        NSStreamEvent,
        NSStreamStatus,
        NSString,
        NSStringCompareOptions,
        NSStringEncodingConversionOptions,
        NSStringEnumerationOptions,
        NSURL,
        NSURLBookmarkCreationOptions,
        NSURLBookmarkResolutionOptions,
        NSURLHandle,
        NSURLHandleStatus,
        NSValue,
        Protocol;
export 'src/protocol_builder.dart';
export 'src/selector.dart';
