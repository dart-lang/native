package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.implements_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.enum_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public enum TestClass211  implements Runnable {
  VALUE1, VALUE2;
  public void run() {}
  public <S extends Number> Map.Entry<S, S> getFoo(Map.Entry<S, S> p1, int p2) { return null; }
  public enum NestedEnum { V1 }

}
