#import "property_test.h"

#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>

@implementation PropertyInterface

static int32_t _classReadWriteProperty = 0;

- (int32_t)readOnlyProperty {
  return 7;
}

+ (int32_t)classReadOnlyProperty {
  return 42;
}

+ (int32_t)classReadWriteProperty {
  return _classReadWriteProperty;
}

+ (void)setClassReadWriteProperty:(int32_t)x {
  _classReadWriteProperty = x;
}

- (int32_t)instStaticSameName {
  return 123;
}

+ (int32_t)instStaticSameName {
  return 456;
}

+ (NSArray<NSString *> *)regressGH1268 {
  return @[@"hello"];
}

@end
