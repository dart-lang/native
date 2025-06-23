// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeParam;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeUsage;
import org.objectweb.asm.signature.SignatureVisitor;

public class AsmClassSignatureVisitor extends SignatureVisitor {
  private final ClassDecl decl;
  private int interfaceIndex = -1;

  public AsmClassSignatureVisitor(ClassDecl decl) {
    super(AsmConstants.API);
    this.decl = decl;
  }

  @Override
  public void visitFormalTypeParameter(String name) {
    var typeParam = new TypeParam();
    typeParam.name = name;
    decl.typeParams.add(typeParam);
    super.visitFormalTypeParameter(name);
  }

  @Override
  public SignatureVisitor visitClassBound() {
    var typeUsage = new TypeUsage();
    // ClassDecl initially has no type parameters. In visitFormalTypeParameter we add them
    // and sequentially visitClassBound and visitInterfaceBound.
    decl.typeParams.get(decl.typeParams.size() - 1).bounds.add(typeUsage);
    return new AsmTypeUsageSignatureVisitor(typeUsage);
  }

  @Override
  public SignatureVisitor visitInterfaceBound() {
    var typeUsage = new TypeUsage();
    decl.typeParams.get(decl.typeParams.size() - 1).bounds.add(typeUsage);
    return new AsmTypeUsageSignatureVisitor(typeUsage);
  }

  @Override
  public SignatureVisitor visitSuperclass() {
    return new AsmTypeUsageSignatureVisitor(decl.superclass);
  }

  @Override
  public SignatureVisitor visitInterface() {
    interfaceIndex++;
    return new AsmTypeUsageSignatureVisitor(decl.interfaces.get(interfaceIndex));
  }
}
