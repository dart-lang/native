// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'src/block.dart';
export 'src/c_bindings_generated.dart'
    show
        Dart_FinalizableHandle_,
        ObjCBlockDesc,
        ObjCBlockImpl,
        ObjCObject,
        ObjCMethodDesc,
        ObjCProtocol,
        ObjCSelector,
        blockRetain,
        objectRelease,
        objectRetain,
        signalWaiter;
export 'src/internal.dart'
    hide
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
        NSDataCreation,
        NSDataReadingOptions,
        NSDataSearchOptions,
        NSDataWritingOptions,
        NSDate,
        NSDictionary,
        NSEnumerationOptions,
        NSEnumerator,
        NSError,
        NSExtendedMutableData,
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
        NSNumberCreation,
        NSObject,
        NSOrderedCollectionDifference,
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
        NSStringExtensionMethods,
        NSURL,
        NSURLBookmarkCreationOptions,
        NSURLBookmarkResolutionOptions,
        NSURLHandle,
        NSURLHandleStatus,
        NSValue,
        NSZone,
        Protocol;
export 'src/protocol_builder.dart';
export 'src/selector.dart';
