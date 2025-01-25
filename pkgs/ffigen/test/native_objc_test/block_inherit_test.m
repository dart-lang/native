// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

#include "block_inherit_test.h"

@implementation Mammal
- (BOOL)laysEggs { return NO; }
@end

@implementation Platypus
- (BOOL)laysEggs { return YES; }
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
