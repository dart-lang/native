// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// === Interfaces ===

@interface DoublyTransitive {}
-(double)doubleMethod;
@end

@interface TransitiveSuper {}
-(int)transitiveSuperMethod;
@end

@interface Transitive : TransitiveSuper {}
-(DoublyTransitive*)transitiveMethod;
@end

@interface SuperSuperType {}
-(int)superSuperMethod;
@end

@interface DoublySuperTransitive {}
-(double)doublySuperMethod;
@end

@interface SuperTransitive {}
-(DoublySuperTransitive*)superTransitiveMethod;
@end

@interface SuperType : SuperSuperType {}
-(SuperTransitive*)superMethod;
@end

@interface DirectlyIncluded : SuperType {}
-(Transitive*)directMethod;
@end

@interface NotIncludedSuperType {}
-(int)notIncludedSuperMethod;
@end

@interface NotIncludedTransitive {}
-(int)notIncludedTransitiveMethod;
@end

@interface NotIncluded : NotIncludedSuperType {}
-(NotIncludedTransitive*)notIncludedMethod;
@end


// === Protocols ===

@protocol DoublyTransitiveProtocol
-(double)doubleProtoMethod;
@end

@protocol TransitiveSuperProtocol
-(int)transitiveSuperProtoMethod;
@end

@protocol TransitiveProtocol<TransitiveSuperProtocol>
-(id<DoublyTransitiveProtocol>)transitiveProtoMethod;
@end

@protocol SuperSuperProtocol
-(int)superSuperProtoMethod;
@end

@protocol DoublySuperTransitiveProtocol
-(double)doublySuperProtoMethod;
@end

@protocol SuperTransitiveProtocol
-(id<DoublySuperTransitiveProtocol>)superTransitiveProtoMethod;
@end

@protocol SuperProtocol<SuperSuperProtocol>
-(id<SuperTransitiveProtocol>)superProtoMethod;
@end

@protocol AnotherSuperProtocol
-(int)anotherSuperProtoMethod;
@end

@protocol DirectlyIncludedProtocol<SuperProtocol, AnotherSuperProtocol>
-(id<TransitiveProtocol>)directProtoMethod;
@end

@protocol NotIncludedSuperProtocol
-(int)notIncludedSuperProtoMethod;
@end

@protocol NotIncludedTransitiveProtocol
-(int)notIncludedTransitiveProtoMethod;
@end

@protocol NotIncludedProtocol<NotIncludedSuperProtocol>
-(id<NotIncludedTransitiveProtocol>)notIncludedProtoMethod;
@end

@protocol SuperFromInterfaceProtocol
-(int)superFromInterfaceProtoMethod;
@end

@protocol TransitiveFromInterfaceProtocol
-(int)transitiveFromInterfaceProtoMethod;
@end

@interface DirectlyIncludedWithProtocol<SuperFromInterfaceProtocol> {}
-(id<TransitiveFromInterfaceProtocol>)directlyIncludedWithProtoMethod;
@end
