// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface BadOverrideGrandparent : NSObject {}
@end
@implementation BadOverrideGrandparent
@end

@interface BadOverrideParent : BadOverrideGrandparent {}
-(int32_t)methodVsGetter;
@property (readonly) int32_t methodVsGetter;
@end
@implementation BadOverrideParent
-(int32_t)methodVsGetter { return 1; }
@end

@interface BadOverrideUncle : BadOverrideGrandparent {}
-(int32_t)methodVsGetter;
@end
@implementation BadOverrideUncle
-(int32_t)methodVsGetter { return 2; }
@end

@interface BadOverrideAunt : BadOverrideGrandparent {}
@end
@implementation BadOverrideAunt
@end

@interface BadOverrideChild : BadOverrideParent {}
@property (readonly) int32_t methodVsGetter;
@end
@implementation BadOverrideChild
-(int32_t)methodVsGetter { return 11; }
@end

@interface BadOverrideSibbling : BadOverrideParent {}
-(int32_t)methodVsGetter;
@end
@implementation BadOverrideSibbling
-(int32_t)methodVsGetter { return 12; }
@end

@interface BadOverrideGrandchild : BadOverrideParent {}
-(int32_t)methodVsGetter;
@end
@implementation BadOverrideGrandchild
-(int32_t)methodVsGetter { return 111; }
@end
