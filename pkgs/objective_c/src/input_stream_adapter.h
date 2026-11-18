// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/dart_api_dl.h"

#import <Foundation/NSObject.h>
#import <Foundation/NSStream.h>

/// Helper class to adapt a Dart stream into a `NSInputStream`.
@interface DOBJCDartInputStreamAdapter : NSInputStream <NSStreamDelegate>

/// Creates the adapter.
/// @param sendPort A port that will receive two types of messages:
/// -1 => The `NSInputStream` has been closed and the port can be closed.
/// _  => The `NSInputStream` wants more data for a `read:maxLength:` call
///       that is waiting, or, if it is scheduled in a run loop, for its next
///       read. The value is the number of bytes wanted, but is only a hint.
///       The stream repeats the request while it waits for data.
+ (instancetype)inputStreamWithPort:(Dart_Port)sendPort;

- (NSUInteger)addData:(NSData *)data;
- (void)setDone;
- (void)setError:(NSError *)error;
@end

/// Helper class that contains a weak reference to a `DOBJCDartInputStreamAdapter`.
@interface DOBJCDartInputStreamAdapterWeakHolder : NSObject

+ (instancetype)holderWithInputStreamAdapter:(DOBJCDartInputStreamAdapter *)adapter;
@property(nonatomic, readonly, weak) DOBJCDartInputStreamAdapter* adapter;

@end
