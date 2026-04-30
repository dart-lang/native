package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customInterface
public interface TestClass171<T, U>  extends DiamondLeft, DiamondRight {
  CustomInterface<T>[] getFoo(CustomInterface<T>[] p1, int p2);
}
