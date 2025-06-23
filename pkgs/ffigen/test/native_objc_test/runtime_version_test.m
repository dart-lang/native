#import <Foundation/NSObject.h>

API_DEPRECATED("test", ios(1000.0, 1001.0), macos(1000.0, 1001.0))
@interface FutureAPIInterface : NSObject;
@end

@implementation FutureAPIInterface : NSObject;
@end

@interface FutureAPIMethods : NSObject;
-(int)unavailableMac API_UNAVAILABLE(macos);
-(int)unavailableIos API_UNAVAILABLE(ios);
-(int)unavailableBoth API_UNAVAILABLE(ios, macos);
-(int)futureMethodMac API_DEPRECATED("test", macos(1000.0, 1001.0));
-(int)futureMethodIos API_DEPRECATED("test", ios(1000.0, 1001.0));
-(int)futureMethodBoth API_DEPRECATED("test", macos(1000.0, 1001.0), ios(1000.0, 1001.0));
@end

@implementation FutureAPIMethods;
-(int)unavailableMac { return 1; }
-(int)unavailableIos { return 2; }
-(int)unavailableBoth { return 3; }
-(int)futureMethodMac { return 4; }
-(int)futureMethodIos { return 5; }
-(int)futureMethodBoth { return 6; }
@end

@interface NSObject (FutureAPICategoryMethods)
-(int)catUnavailableMac API_UNAVAILABLE(macos);
-(int)catUnavailableIos API_UNAVAILABLE(ios);
-(int)catUnavailableBoth API_UNAVAILABLE(ios, macos);
-(int)catFutureMethodMac API_DEPRECATED("test", macos(1000.0, 1001.0));
-(int)catFutureMethodIos API_DEPRECATED("test", ios(1000.0, 1001.0));
-(int)catFutureMethodBoth API_DEPRECATED("test", macos(1000.0, 1001.0), ios(1000.0, 1001.0));
@end

@implementation NSObject (FutureAPICategoryMethods)
-(int)catUnavailableMac { return 1; }
-(int)catUnavailableIos { return 2; }
-(int)catUnavailableBoth { return 3; }
-(int)catFutureMethodMac { return 4; }
-(int)catFutureMethodIos { return 5; }
-(int)catFutureMethodBoth { return 6; }
@end
