// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>


@interface Polygon : NSObject {}
-(NSString*)name;
@end
@implementation Polygon
-(NSString*)name { return @"Polygon"; }
@end

@interface Triangle : Polygon {}
-(NSString*)name;
@end
@implementation Triangle
-(NSString*)name { return @"Triangle"; }
@end

@interface Rectangle : Polygon {}
-(NSString*)name;
@end
@implementation Rectangle
-(NSString*)name { return @"Rectangle"; }
@end

@interface Square : Rectangle {}
-(NSString*)name;
@end
@implementation Square
-(NSString*)name { return @"Square"; }
@end



@interface BadOverrideBase : NSObject {}
-(Square*)contravariantReturn;
@end

@implementation BadOverrideBase
-(Square*)contravariantReturn { return [Square new]; }
@end

@interface BadOverrideChild : BadOverrideBase {}
-(Rectangle*)contravariantReturn;
@end

@implementation BadOverrideChild
-(Rectangle*)contravariantReturn { return [Rectangle new]; }
@end
