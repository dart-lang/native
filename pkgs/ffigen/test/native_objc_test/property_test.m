#import <Foundation/NSObject.h>

@class UndefinedTemplate<ObjectType>;

typedef struct {
  double x;
  double y;
  double z;
  double w;
} Vec4;

@interface PropertyInterface : NSObject {
}

@property (readonly) int32_t readOnlyProperty;
@property int32_t readWriteProperty;
@property (class, readonly, copy) UndefinedTemplate<NSString *> *regressGH436;
@property (class, readonly) int32_t classReadOnlyProperty;
@property (class) int32_t classReadWriteProperty;
@property float floatProperty;
@property double doubleProperty;
@property Vec4 structProperty;

// An instance property and a static property with the same name.
// https://github.com/dart-lang/native/issues/1136
@property(readonly) int32_t instStaticSameName;
@property(class, readonly) int32_t instStaticSameName;

@end

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

@end
