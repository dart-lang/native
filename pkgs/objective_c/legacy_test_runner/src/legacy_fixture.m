// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "legacy_fixture.h"

#import <stdatomic.h>

const int32_t kLegacyMagicNumber = 42;

int32_t legacyAddInts(int32_t a, int32_t b) {
  return a + b;
}

static _Atomic int32_t sNextId = 1;
static NSMutableSet<NSNumber *> *sDeallocatedIds = nil;
static int32_t sSharedCounter = 0;

@interface LegacyObjCDelegate ()
@property (nonatomic) int32_t multiplier;
@property (nonatomic, readwrite, nullable, copy) NSString *lastMessage;
@end

@implementation LegacyObjCDelegate

- (instancetype)initWithMultiplier:(int32_t)multiplier {
  self = [super init];
  if (self) {
    _multiplier = multiplier;
  }
  return self;
}

- (int32_t)computeWithInput:(int32_t)input {
  return input * self.multiplier;
}

- (void)notifyMessage:(NSString *)message {
  self.lastMessage = message;
}

- (NSString *)optionalGreeting {
  return [NSString stringWithFormat:@"Hello x%d", self.multiplier];
}

@end

@implementation LegacyBase

- (instancetype)init {
  return [self initWithValue:0];
}

- (instancetype)initWithValue:(int32_t)value {
  self = [super init];
  if (self) {
    _readOnlyId = atomic_fetch_add(&sNextId, 1);
    _value = value;
  }
  return self;
}

- (void)dealloc {
  @synchronized (LegacyBase.class) {
    if (sDeallocatedIds == nil) {
      sDeallocatedIds = [NSMutableSet set];
    }
    [sDeallocatedIds addObject:@(_readOnlyId)];
  }
}

+ (instancetype)createWithValue:(int32_t)value {
  return [[self alloc] initWithValue:value];
}

+ (int32_t)sharedCounter {
  return sSharedCounter;
}

+ (void)setSharedCounter:(int32_t)sharedCounter {
  sSharedCounter = sharedCounter;
}

- (int32_t)addA:(int32_t)a toB:(int32_t)b {
  return a + b + self.value;
}

- (NSString * _Nullable)echoNullable:(NSString * _Nullable)input {
  return input;
}

+ (int32_t)multiplyA:(int32_t)a byB:(int32_t)b {
  return a * b;
}

+ (int32_t)invokeComputeOnDelegate:(id<LegacyDelegate>)delegate
                         withInput:(int32_t)input {
  return [delegate computeWithInput:input];
}

+ (void)invokeNotifyAsyncOnDelegate:(id<LegacyDelegate>)delegate
                            message:(NSString *)message {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    [delegate notifyMessage:message];
  });
}

+ (void)invokeNotifyBlockingOnBackgroundQueue:(id<LegacyDelegate>)delegate
                                      message:(NSString *)message
                                       onDone:(LegacyVoidBlock)onDone {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    [delegate notifyMessage:message];
    onDone(@"after-protocol-blocking");
  });
}

+ (NSString * _Nullable)invokeOptionalGreetingOnDelegate:
    (id<LegacyDelegate>)delegate {
  if ([delegate respondsToSelector:@selector(optionalGreeting)]) {
    return [delegate optionalGreeting];
  }
  return nil;
}

+ (LegacyIntBlock)makeAdderBlock:(int32_t)delta {
  return ^int32_t(int32_t value) {
    return value + delta;
  };
}

+ (int32_t)callIntBlock:(LegacyIntBlock)block withValue:(int32_t)value {
  return block(value);
}

+ (void)callVoidBlockAsync:(LegacyVoidBlock)block
               withMessage:(NSString *)message {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    block(message);
  });
}

+ (void)callVoidBlockBlockingOnBackgroundQueue:(LegacyVoidBlock)block
                                       message:(NSString *)message
                                        onDone:(LegacyVoidBlock)onDone {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    block(message);
    onDone(@"after-block-blocking");
  });
}

+ (BOOL)validatePositive:(int32_t)value
                   error:(NSError * _Nullable * _Nullable)error {
  if (value > 0) {
    return YES;
  }
  if (error != NULL) {
    *error = [NSError errorWithDomain:@"LegacyErrorDomain"
                                 code:1001
                             userInfo:@{
      NSLocalizedDescriptionKey : @"Value must be positive",
    }];
  }
  return NO;
}

+ (NSString * _Nullable)checkedGreeting:(BOOL)shouldFail
                                  error:(NSError * _Nullable * _Nullable)error {
  if (!shouldFail) {
    return @"ok";
  }
  if (error != NULL) {
    *error = [NSError errorWithDomain:@"LegacyErrorDomain"
                                 code:1002
                             userInfo:@{
      NSLocalizedDescriptionKey : @"Greeting failed",
    }];
  }
  return nil;
}

+ (LegacyPoint)translatePoint:(LegacyPoint)point
                           dx:(int32_t)dx
                           dy:(int32_t)dy {
  LegacyPoint result = {point.x + dx, point.y + dy};
  return result;
}

+ (NSString *)describeColor:(LegacyColor)color flags:(LegacyFlags)flags {
  NSString *colorName = @"unknown";
  switch (color) {
    case LegacyColorRed:
      colorName = @"red";
      break;
    case LegacyColorGreen:
      colorName = @"green";
      break;
    case LegacyColorBlue:
      colorName = @"blue";
      break;
  }
  return [NSString stringWithFormat:@"%@:%u", colorName, (unsigned int)flags];
}

+ (NSArray<NSString *> *)uppercasedArray:(NSArray<NSString *> *)items {
  NSMutableArray<NSString *> *result =
      [NSMutableArray arrayWithCapacity:items.count];
  for (NSString *item in items) {
    [result addObject:[item uppercaseString]];
  }
  return result;
}

+ (NSDictionary<NSString *, NSNumber *> *)wordLengths:
    (NSArray<NSString *> *)words {
  NSMutableDictionary<NSString *, NSNumber *> *result =
      [NSMutableDictionary dictionaryWithCapacity:words.count];
  for (NSString *word in words) {
    result[word] = @(word.length);
  }
  return result;
}

+ (NSSet<NSString *> *)uniqueItems:(NSArray<NSString *> *)items {
  return [NSSet setWithArray:items];
}

+ (NSData *)reverseData:(NSData *)data {
  NSUInteger len = data.length;
  NSMutableData *reversed = [NSMutableData dataWithLength:len];
  const uint8_t *src = (const uint8_t *)data.bytes;
  uint8_t *dst = (uint8_t *)reversed.mutableBytes;
  for (NSUInteger i = 0; i < len; i++) {
    dst[i] = src[len - 1 - i];
  }
  return reversed;
}

+ (NSNumber *)sumNumbers:(NSArray<NSNumber *> *)numbers {
  int64_t total = 0;
  for (NSNumber *num in numbers) {
    total += num.longLongValue;
  }
  return @(total);
}

+ (BOOL)wasDeallocated:(int32_t)instanceId {
  @synchronized (LegacyBase.class) {
    return [sDeallocatedIds containsObject:@(instanceId)];
  }
}

@end

@implementation LegacyChild

- (instancetype)initWithValue:(int32_t)value tag:(NSString *)tag {
  self = [super initWithValue:value];
  if (self) {
    _childTag = [tag copy];
  }
  return self;
}

@end

@implementation LegacyBase (LegacyExtra)

- (int32_t)doubledValue {
  return self.value * 2;
}

@end

@implementation NSString (LegacyStringExtra)

- (NSString *)legacyReversed {
  NSMutableString *reversed =
      [NSMutableString stringWithCapacity:self.length];
  for (NSInteger i = (NSInteger)self.length - 1; i >= 0; i--) {
    [reversed appendFormat:@"%C", [self characterAtIndex:(NSUInteger)i]];
  }
  return reversed;
}

@end
