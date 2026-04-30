package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.setFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customObject
public abstract class TestClass107<T extends Number>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public abstract <S, V> CustomObject<S> setFoo(CustomObject<S> p1);
  public enum NestedEnum { V1 }

}
