package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.isFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public abstract interface TestClass70<T, U>  extends DiamondLeft, DiamondRight {
  <S extends Number> long[] isFoo(long[] p1);
  public enum NestedEnum { V1 }

}
