package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.throws, MemberName: MemberName.setFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.list
public class TestClass13<T>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public <S extends Number> List<S>[] setFoo() throws Exception { return null; }
  public enum NestedEnum { V1 }

}
