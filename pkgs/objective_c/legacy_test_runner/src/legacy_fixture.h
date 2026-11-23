// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 10. C Function & Global
extern const int32_t kLegacyMagicNumber;
int32_t legacyAddInts(int32_t a, int32_t b);

// 7. Structs & Enums
typedef struct {
  int32_t x;
  int32_t y;
} LegacyPoint;

typedef NS_ENUM(int32_t, LegacyColor) {
  LegacyColorRed = 0,
  LegacyColorGreen = 1,
  LegacyColorBlue = 2,
};

typedef NS_OPTIONS(uint32_t, LegacyFlags) {
  LegacyFlagNone = 0,
  LegacyFlagRead = 1 << 0,
  LegacyFlagWrite = 1 << 1,
  LegacyFlagExec = 1 << 2,
};

// 5. Blocks
typedef int32_t (^LegacyIntBlock)(int32_t value);
typedef void (^LegacyVoidBlock)(NSString *message);

// 4. Protocols
@protocol LegacyDelegate <NSObject>
- (int32_t)computeWithInput:(int32_t)input;
- (void)notifyMessage:(NSString *)message;
@optional
- (NSString *)optionalGreeting;
@end

@interface LegacyObjCDelegate : NSObject <LegacyDelegate>
- (instancetype)initWithMultiplier:(int32_t)multiplier;
@property (nonatomic, readonly, nullable, copy) NSString *lastMessage;
@end

// 1 & 2. Classes, Lifecycle, Methods & Properties
@interface LegacyBase : NSObject
- (instancetype)init;
- (instancetype)initWithValue:(int32_t)value;
+ (instancetype)createWithValue:(int32_t)value;

@property (nonatomic, readonly) int32_t readOnlyId;
@property (nonatomic) int32_t value;
@property (nonatomic, nullable, copy) NSString *label;
@property (class, nonatomic) int32_t sharedCounter;

- (int32_t)addA:(int32_t)a toB:(int32_t)b;
- (NSString * _Nullable)echoNullable:(NSString * _Nullable)input;
+ (int32_t)multiplyA:(int32_t)a byB:(int32_t)b;

// 4. Protocol helpers
+ (int32_t)invokeComputeOnDelegate:(id<LegacyDelegate>)delegate
                         withInput:(int32_t)input;
+ (void)invokeNotifyAsyncOnDelegate:(id<LegacyDelegate>)delegate
                            message:(NSString *)message;
+ (void)invokeNotifyBlockingOnBackgroundQueue:(id<LegacyDelegate>)delegate
                                      message:(NSString *)message
                                       onDone:(LegacyVoidBlock)onDone;
+ (NSString * _Nullable)invokeOptionalGreetingOnDelegate:
    (id<LegacyDelegate>)delegate;

// 5. Block helpers
+ (LegacyIntBlock)makeAdderBlock:(int32_t)delta;
+ (int32_t)callIntBlock:(LegacyIntBlock)block withValue:(int32_t)value;
+ (void)callVoidBlockAsync:(LegacyVoidBlock)block
               withMessage:(NSString *)message;
+ (void)callVoidBlockBlockingOnBackgroundQueue:(LegacyVoidBlock)block
                                       message:(NSString *)message
                                        onDone:(LegacyVoidBlock)onDone;

// 6. Errors (NSError**)
+ (BOOL)validatePositive:(int32_t)value
                   error:(NSError * _Nullable * _Nullable)error;
+ (NSString * _Nullable)checkedGreeting:(BOOL)shouldFail
                                  error:(NSError * _Nullable * _Nullable)error;

// 7. Struct & Enum helpers
+ (LegacyPoint)translatePoint:(LegacyPoint)point
                           dx:(int32_t)dx
                           dy:(int32_t)dy;
+ (NSString *)describeColor:(LegacyColor)color flags:(LegacyFlags)flags;

// 8. Foundation Built-ins
+ (NSArray<NSString *> *)uppercasedArray:(NSArray<NSString *> *)items;
+ (NSDictionary<NSString *, NSNumber *> *)wordLengths:
    (NSArray<NSString *> *)words;
+ (NSSet<NSString *> *)uniqueItems:(NSArray<NSString *> *)items;
+ (NSData *)reverseData:(NSData *)data;
+ (NSNumber *)sumNumbers:(NSArray<NSNumber *> *)numbers;

// 9. Memory Management & ARC
+ (BOOL)wasDeallocated:(int32_t)instanceId;
@end

@interface LegacyChild : LegacyBase
- (instancetype)initWithValue:(int32_t)value tag:(NSString *)tag;
@property (nonatomic, readonly, copy) NSString *childTag;
@end

// 3. Categories
@interface LegacyBase (LegacyExtra)
- (int32_t)doubledValue;
@end

@interface NSString (LegacyStringExtra)
- (NSString *)legacyReversed;
@end

NS_ASSUME_NONNULL_END
