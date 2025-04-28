#import <Foundation/NSObject.h>

@class UndefinedTemplate<ObjectType>;
@class NSString;
@class NSArray<ObjectType>;

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
@property (class, readonly, copy) NSArray<NSString *> *regressGH1268;

// An instance property and a static property with the same name.
// https://github.com/dart-lang/native/issues/1136
@property(readonly) int32_t instStaticSameName;
@property(class, readonly) int32_t instStaticSameName;

@end
