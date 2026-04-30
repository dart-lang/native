package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.native, MemberName: MemberName.setFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customObject
public interface TestClass225<T, U>  extends DiamondLeft, DiamondRight {
  <S> ArrayList<S>[] setFoo(ArrayList<S>[] p1, int p2);
  public enum NestedEnum { V1 }

}
