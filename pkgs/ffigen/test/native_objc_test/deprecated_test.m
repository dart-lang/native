#import <Foundation/NSObject.h>

API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0))
@interface DeprecatedInterface : NSObject;
@end

API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0))
@protocol DeprecatedProtocol<NSObject>
@end

@interface DeprecatedInterfaceMethods : NSObject;

-(int32_t)normalMethod;

// If an API is available in either OS, it is code-genned normally. So the only
// method that is omitted is unavailableBoth.
-(int32_t)unavailableMac API_UNAVAILABLE(macos);
-(int32_t)unavailableIos API_UNAVAILABLE(ios);
-(int32_t)unavailableBoth API_UNAVAILABLE(ios, macos);

// deprecated_config.yaml targets v2.5 for both APIs. For an API to be omitted
// it needs to be deprecated before that version in both OSs. Of the methods
// below, the only one that fits that condition is depIos2Mac2. The rest are
// code-genned normally.
-(int32_t)depMac2 API_DEPRECATED("test", macos(1.0, 2.0));
-(int32_t)depMac3 API_DEPRECATED("test", macos(1.0, 3.0));
-(int32_t)depIos2 API_DEPRECATED("test", ios(1.0, 2.0));
-(int32_t)depIos2Mac2 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));
-(int32_t)depIos2Mac3 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 3.0));
-(int32_t)depIos3 API_DEPRECATED("test", ios(1.0, 3.0));
-(int32_t)depIos3Mac2 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 2.0));
-(int32_t)depIos3Mac3 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 3.0));

// Methods deprecated/unavailable using __attribute__ set the alwaysDeprecated
// and alwaysUnavailable flags. These are always omitted, regardless of the
// min targeted versions.
-(int32_t)alwaysDeprecated __attribute__((deprecated));
-(int32_t)alwaysUnavailable __attribute__((unavailable));

@end

@protocol DeprecatedProtocolMethods<NSObject>
-(int32_t)protNormalMethod;
-(int32_t)protUnavailableMac API_UNAVAILABLE(macos);
-(int32_t)protUnavailableIos API_UNAVAILABLE(ios);
-(int32_t)protUnavailableBoth API_UNAVAILABLE(ios, macos);
-(int32_t)protDepMac2 API_DEPRECATED("test", macos(1.0, 2.0));
-(int32_t)protDepMac3 API_DEPRECATED("test", macos(1.0, 3.0));
-(int32_t)protDepIos2 API_DEPRECATED("test", ios(1.0, 2.0));
-(int32_t)protDepIos2Mac2 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 2.0));
-(int32_t)protDepIos2Mac3 API_DEPRECATED("test", ios(1.0, 2.0), macos(1.0, 3.0));
-(int32_t)protDepIos3 API_DEPRECATED("test", ios(1.0, 3.0));
-(int32_t)protDepIos3Mac2 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 2.0));
-(int32_t)protDepIos3Mac3 API_DEPRECATED("test", ios(1.0, 3.0), macos(1.0, 3.0));
-(int32_t)protAlwaysDeprecated __attribute__((deprecated));
-(int32_t)protAlwaysUnavailable __attribute__((unavailable));
@end
