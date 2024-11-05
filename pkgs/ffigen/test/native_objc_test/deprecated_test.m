#import <Foundation/NSObject.h>

API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0))
@interface DeprecatedInterface : NSObject;
@end

API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0))
@protocol DeprecatedProtocol<NSObject>
@end

API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0))
@interface NSObject (DeprecatedCategory)
@end

@interface DeprecatedInterfaceMethods : NSObject;

-(int)normalMethod;

// If an API is available in either OS, it is code-genned normally. So the only
// method that is omitted is unavailableBoth.
-(int)unavailableMac API_UNAVAILABLE(macos);
-(int)unavailableIos API_UNAVAILABLE(ios);
-(int)unavailableBoth API_UNAVAILABLE(ios, macos);

// deprecated_config.yaml targets v2.5 for both APIs. For an API to be omitted
// it needs to be deprecated before that version in both OSs. Of the methods
// below, the only one that fits that condition is depIos2Mac2. The rest are
// code-genned normally.
-(int)depMac2 API_DEPRECATED("test", macos(1.0, 2.0));
-(int)depMac3 API_DEPRECATED("test", macos(1.0, 3.0));
-(int)depIos2 API_DEPRECATED("test", ios(1.0, 2.0));
-(int)depIos2Mac2 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));
-(int)depIos2Mac3 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 3.0));
-(int)depIos3 API_DEPRECATED("test", ios(1.0, 3.0));
-(int)depIos3Mac2 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 2.0));
-(int)depIos3Mac3 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 3.0));

// Methods deprecated/unavailable using __attribute__ set the alwaysDeprecated
// and alwaysUnavailable flags. These are always omitted, regardless of the
// min targeted versions.
-(int)alwaysDeprecated __attribute__((deprecated));
-(int)alwaysUnavailable __attribute__((unavailable));

@property int normalProperty;
@property int deprecatedProperty API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));

@end

@protocol DeprecatedProtocolMethods<NSObject>
-(int)protNormalMethod;
-(int)protUnavailableMac API_UNAVAILABLE(macos);
-(int)protUnavailableIos API_UNAVAILABLE(ios);
-(int)protUnavailableBoth API_UNAVAILABLE(ios, macos);
-(int)protDepMac2 API_DEPRECATED("test", macos(1.0, 2.0));
-(int)protDepMac3 API_DEPRECATED("test", macos(1.0, 3.0));
-(int)protDepIos2 API_DEPRECATED("test", ios(1.0, 2.0));
-(int)protDepIos2Mac2 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));
-(int)protDepIos2Mac3 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 3.0));
-(int)protDepIos3 API_DEPRECATED("test", ios(1.0, 3.0));
-(int)protDepIos3Mac2 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 2.0));
-(int)protDepIos3Mac3 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 3.0));
-(int)protAlwaysDeprecated __attribute__((deprecated));
-(int)protAlwaysUnavailable __attribute__((unavailable));
@property int protNormalProperty;
@property int protDeprecatedProperty API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));
@end

@interface NSObject (DeprecatedCategoryMethods)
-(int)catNormalMethod;
-(int)catUnavailableMac API_UNAVAILABLE(macos);
-(int)catUnavailableIos API_UNAVAILABLE(ios);
-(int)catUnavailableBoth API_UNAVAILABLE(ios, macos);
-(int)catDepMac2 API_DEPRECATED("test", macos(1.0, 2.0));
-(int)catDepMac3 API_DEPRECATED("test", macos(1.0, 3.0));
-(int)catDepIos2 API_DEPRECATED("test", ios(1.0, 2.0));
-(int)catDepIos2Mac2 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));
-(int)catDepIos2Mac3 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 3.0));
-(int)catDepIos3 API_DEPRECATED("test", ios(1.0, 3.0));
-(int)catDepIos3Mac2 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 2.0));
-(int)catDepIos3Mac3 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 3.0));
-(int)catAlwaysDeprecated __attribute__((deprecated));
-(int)catAlwaysUnavailable __attribute__((unavailable));
@property int catNormalProperty;
@property int catDeprecatedProperty API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));
@end

int normalFunction();
int deprecatedFunction() API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));

struct NormalStruct {
  int x;
};

struct DeprecatedStruct {
  int x;
} API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));

union NormalUnion {
  int x;
};

union DeprecatedUnion {
  int x;
} API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));

enum NormalEnum {
  x
};

enum DeprecatedEnum {
  y
} API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));

enum {
  normalUnnamedEnum,
  deprecatedUnnamedEnum API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0)),
};
