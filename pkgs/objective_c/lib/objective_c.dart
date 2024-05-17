// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'src/internal.dart' hide blockHasRegisteredClosure;
export 'src/ns_data.dart';
export 'src/ns_string.dart';
export 'src/c_bindings_generated.dart'
    show
        ObjCSelector,
        ObjCObject,
        ObjCBlock,
        objectRetain,
        objectRelease,
        blockCopy,
        blockRelease;

// Keep in sync with pkgs/objective_c/ffigen_objc.yaml.
export 'src/objective_c_bindings_generated.dart'
    show
        DartProxy,
        DartProxyBuilder,
        NSArray,
        NSCharacterSet,
        NSCoder,
        NSData,
        NSDate,
        NSDictionary,
        NSEnumerator,
        NSError,
        NSIndexSet,
        NSInvocation,
        NSItemProvider,
        NSLocale,
        NSMethodSignature,
        NSMutableArray,
        NSMutableData,
        NSMutableDictionary,
        NSMutableSet,
        NSMutableString,
        NSNotification,
        NSNumber,
        NSObject,
        NSProgress,
        NSProxy,
        NSSet,
        NSString,
        NSURL,
        NSURLHandle,
        NSValue,
        Protocol;
