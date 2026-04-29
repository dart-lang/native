// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlin.metadata.Attributes;
import kotlin.metadata.KmFunction;
import kotlin.metadata.Visibility;
import kotlin.metadata.jvm.JvmExtensionsKt;

public class KotlinFunction {
  /** Name in the byte code. */
  public String name;

  public String descriptor;

  /** Name in the Kotlin's metadata. */
  public String kotlinName;

  public List<KotlinValueParameter> valueParameters;
  public KotlinType returnType;
  public KotlinType receiverParameterType;
  public List<KotlinType> contextReceiverTypes;
  public List<KotlinTypeParameter> typeParameters;
  public boolean isSuspend;
  public boolean isOperator;
  public boolean isPublic;
  public boolean isPrivate;
  public boolean isProtected;
  public boolean isInternal;

  public static KotlinFunction fromKmFunction(KmFunction f) {
    var fun = new KotlinFunction();
    var signature = JvmExtensionsKt.getSignature(f);
    fun.descriptor = signature == null ? null : signature.getDescriptor();
    fun.name = signature == null ? null : signature.getName();
    fun.kotlinName = f.getName();
    // Processing the information needed from the flags.
    fun.isSuspend = Attributes.isSuspend(f);
    fun.isOperator = Attributes.isOperator(f);
    fun.valueParameters =
        f.getValueParameters().stream()
            .map(KotlinValueParameter::fromKmValueParameter)
            .collect(Collectors.toList());
    fun.returnType = KotlinType.fromKmType(f.getReturnType());
    fun.receiverParameterType = KotlinType.fromKmType(f.getReceiverParameterType());
    fun.contextReceiverTypes =
        f.getContextReceiverTypes().stream()
            .map(KotlinType::fromKmType)
            .collect(Collectors.toList());
    fun.typeParameters =
        f.getTypeParameters().stream()
            .map(KotlinTypeParameter::fromKmTypeParameter)
            .collect(Collectors.toList());
    var visibility = Attributes.getVisibility(f);
    fun.isPublic = visibility == Visibility.PUBLIC;
    fun.isPrivate = visibility == Visibility.PRIVATE;
    fun.isProtected = visibility == Visibility.PROTECTED;
    fun.isInternal = visibility == Visibility.INTERNAL;
    return fun;
  }
}
