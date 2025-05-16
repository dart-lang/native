#import <Foundation/NSObject.h>

typedef NSString* MyString;

@interface NullableInterface  : NSObject {
}

+(BOOL) isNullWithNullableNSObjectArg:(nullable NSObject *)x;
+(BOOL) isNullWithNotNullableNSObjectPtrArg:(NSObject *)x;
+(BOOL) isNullWithExplicitNonNullableNSObjectPtrArg:(nonnull NSObject *)x;
+(nullable NSObject *) returnNil:(BOOL)r;
+(nullable MyString) returnNullableAlias:(BOOL)r;
+(nullable NSObject *) multipleNullableArgs:(nullable NSObject *)x
    y:(nullable NSObject *)y z:(nullable NSObject *)z;

@property (nullable, retain) NSObject *nullableObjectProperty;

@end

@implementation NullableInterface

+(BOOL) isNullWithNullableNSObjectArg:(nullable NSObject *)x {
  return x == NULL;
}

+(BOOL) isNullWithNotNullableNSObjectPtrArg:(NSObject *)x {
  return x == NULL;
}

+(BOOL) isNullWithExplicitNonNullableNSObjectPtrArg:(nonnull NSObject *)x {
  return x == NULL;
}

+(nullable NSObject *) returnNil:(BOOL)r {
  if (r) {
    return nil;
  } else {
    return [NSObject new];
  }
}

+(nullable MyString) returnNullableAlias:(BOOL)r {
  if (r) {
    return nil;
  } else {
    return @"Hi";
  }
}

+(nullable NSObject *) multipleNullableArgs:(nullable NSObject *)x
    y:(nullable NSObject *)y z:(nullable NSObject *)z {
  if (x != nil) return x;
  if (y != nil) return y;
  return z;
}

@end
