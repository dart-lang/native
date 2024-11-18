// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface Mammal : NSObject {}
- (BOOL)laysEggs;
@end

@interface Platypus : Mammal {}
@end

typedef Mammal* (^ReturnMammal)();
typedef Platypus* (^ReturnPlatypus)();
typedef BOOL (^AcceptMammal)(Mammal*);
typedef BOOL (^AcceptPlatypus)(Platypus*);

// Note: Returns are covariant, args are contravariant.
// Platypus <: Mammal
// ReturnPlatypus <: ReturnMammal  (covariant)
// AcceptMammal <: AcceptPlatypus  (contravariant)

@interface BlockInheritTestBase : NSObject {}
// Returns are covariant, args are contravariant.
- (Mammal*) getAnimal ;
- (BOOL) acceptAnimal: (Platypus*)platypus;
- (ReturnMammal) getReturner ;
- (AcceptPlatypus) getAccepter ;
- (Mammal*) invokeReturner: (ReturnPlatypus)returner ;
- (BOOL) invokeAccepter: (AcceptMammal)accepter;
@end

@interface BlockInheritTestChild : BlockInheritTestBase {}
// Returns are covariant, args are contravariant.
- (Platypus*) getAnimal ;
- (BOOL) acceptAnimal: (Mammal*)mammal;
- (ReturnPlatypus) getReturner ;
- (AcceptMammal) getAccepter ;
- (Mammal*) invokeReturner: (ReturnMammal)returner ;
- (BOOL) invokeAccepter: (AcceptPlatypus)accepter;
@end
