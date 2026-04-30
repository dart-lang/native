package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.implements_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.throws, MemberName: MemberName.setFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.record, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.list
public record TestClass206<T extends Number>(List<T> field)  implements Runnable {
  public void run() {}
}
