// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@class Sendable;

typedef void (^Listener)(int32_t);
typedef void (^ListenerWithSendable)(Sendable *);

@interface Sendable : NSObject {}
@property int32_t value;
+ (Listener)dummyMethodToForceGenerationOfListener;
+ (ListenerWithSendable)dummyMethodToForceGenerationOfListenerWithSendable;
@end
