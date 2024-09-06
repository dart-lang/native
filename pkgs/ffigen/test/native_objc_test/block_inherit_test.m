// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface Mammal : NSObject {}
- (BOOL)laysEggs;
@end
@implementation Mammal
- (BOOL)laysEggs { return NO; }
@end

@interface Platypus : Mammal {}
@end
@implementation Platypus
- (BOOL)laysEggs { return YES; }
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
@implementation BlockInheritTestBase
- (Mammal*) getAnimal { return [Mammal new]; }
- (BOOL) acceptAnimal: (Platypus*)platypus { return [platypus laysEggs]; }

- (ReturnMammal) getReturner {
  return [^Mammal*() { return [Mammal new]; } copy];
}

- (AcceptPlatypus) getAccepter {
  return [^BOOL (Platypus* platypus) { return [platypus laysEggs]; } copy];
}

- (Mammal*) invokeReturner: (ReturnPlatypus)returner {
  return returner();
}

- (BOOL) invokeAccepter: (AcceptMammal)accepter {
  Mammal* mammal = [Mammal new];
  return accepter(mammal);
}
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
@implementation BlockInheritTestChild
- (Platypus*) getAnimal { return [Platypus new]; }
- (BOOL) acceptAnimal: (Mammal*)mammal { return [mammal laysEggs]; }

- (ReturnPlatypus) getReturner {
  return [^Platypus*() { return [Platypus new]; } copy];
}

- (AcceptMammal) getAccepter {
  return [^BOOL (Mammal* mammal) { return [mammal laysEggs]; } copy];
}

- (Mammal*) invokeReturner: (ReturnMammal)returner {
  return returner();
}

- (BOOL) invokeAccepter: (AcceptPlatypus)accepter {
  Platypus* platypus = [Platypus new];
  return accepter(platypus);
}
@end
