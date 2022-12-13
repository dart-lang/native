// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.Method;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeParam;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeUsage;
import org.objectweb.asm.signature.SignatureVisitor;

public class AsmMethodSignatureVisitor extends SignatureVisitor {
  private final Method method;
  private int paramIndex = -1;

  public AsmMethodSignatureVisitor(Method method) {
    super(AsmConstants.API);
    this.method = method;
  }

  @Override
  public void visitFormalTypeParameter(String name) {
    var typeParam = new TypeParam();
    typeParam.name = name;
    method.typeParams.add(typeParam);
  }

  @Override
  public SignatureVisitor visitClassBound() {
    var typeUsage = new TypeUsage();
    // Method initially has no type parameters. In visitFormalTypeParameter we add them
    // and sequentially visitClassBound and visitInterfaceBound.
    method.typeParams.get(method.typeParams.size() - 1).bounds.add(typeUsage);
    return new AsmTypeUsageSignatureVisitor(typeUsage);
  }

  @Override
  public SignatureVisitor visitInterfaceBound() {
    var typeUsage = new TypeUsage();
    method.typeParams.get(method.typeParams.size() - 1).bounds.add(typeUsage);
    return new AsmTypeUsageSignatureVisitor(typeUsage);
  }

  @Override
  public SignatureVisitor visitReturnType() {
    return new AsmTypeUsageSignatureVisitor(method.returnType);
  }

  @Override
  public SignatureVisitor visitParameterType() {
    paramIndex++;
    return new AsmTypeUsageSignatureVisitor(method.params.get(paramIndex).type);
  }

  @Override
  public SignatureVisitor visitExceptionType() {
    // Do nothing.
    return new AsmTypeUsageSignatureVisitor(new TypeUsage());
  }
}
