package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.final_, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.customInterface
public final class TestClass161<T, U>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public final <S extends Number> CustomInterface<S> myMethod() { return null; }
  public enum NestedEnum { V1 }

}
