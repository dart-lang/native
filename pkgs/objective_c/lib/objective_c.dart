// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'package:pub_semver/pub_semver.dart' show Version;
export 'src/block.dart';
export 'src/c_bindings_generated.dart'
    show
        DOBJC_Context,
        Dart_FinalizableHandle_,
        ObjCBlockDesc,
        ObjCBlockImpl,
        ObjCMethodDesc,
        ObjCObject,
        ObjCProtocol,
        ObjCSelector,
        blockRetain,
        objectRelease,
        objectRetain,
        signalWaiter;
export 'src/internal.dart'
    hide blockHasRegisteredClosure, isValidBlock, isValidClass, isValidObject;
export 'src/ns_data.dart';
export 'src/ns_date.dart';
export 'src/ns_input_stream.dart';
export 'src/ns_mutable_data.dart';
export 'src/ns_number.dart';
export 'src/ns_string.dart';
// Keep in sync with pkgs/objective_c/ffigen_objc.yaml.
export 'src/objective_c_bindings_generated.dart'
    show
        DartProtocol,
        DartProtocolBuilder,
        NSArray,
        NSBinarySearchingOptions,
        NSCharacterSet,
        NSCoder,
        NSCoding,
        NSComparisonResult,
        NSCopying,
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
        NSExtendedArray,
        NSExtendedData,
        NSExtendedDate,
        NSExtendedDictionary,
        NSExtendedEnumerator,
        NSExtendedMutableArray,
        NSExtendedMutableData,
        NSExtendedMutableDictionary,
        NSExtendedMutableOrderedSet,
        NSExtendedMutableSet,
        NSExtendedOrderedSet,
        NSExtendedSet,
        NSFastEnumeration,
        NSFastEnumerationState,
        NSIndexSet,
        NSInputStream,
        NSInvocation,
        NSItemProvider,
        NSItemProviderFileOptions,
        NSItemProviderReading,
        NSItemProviderRepresentationVisibility,
        NSItemProviderWriting,
        NSKeyValueChange,
        NSKeyValueObservingOptions,
        NSKeyValueSetMutationKind,
        NSLocale,
        NSMethodSignature,
        NSMutableArray,
        NSMutableCopying,
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
        NSObjectProtocol,
        NSOrderedCollectionDifference,
        NSOrderedCollectionDifferenceCalculationOptions,
        NSOrderedSet,
        NSOutputStream,
        NSRange,
        NSRunLoop,
        NSSecureCoding,
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
export 'src/os_version.dart';
export 'src/protocol_builder.dart';
export 'src/selector.dart';
