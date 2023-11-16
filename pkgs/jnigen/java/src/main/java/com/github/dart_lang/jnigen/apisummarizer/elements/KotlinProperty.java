// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlinx.metadata.KmProperty;
import kotlinx.metadata.jvm.JvmExtensionsKt;

public class KotlinProperty {
  public String fieldName;
  public String fieldDescriptor;

  /** Getter's name in the byte code. */
  public String getterName;

  public String getterDescriptor;

  /** Setter's name in the byte code. */
  public String setterName;

  public String setterDescriptor;

  /** Name in the Kotlin's metadata. */
  public String kotlinName;

  public KotlinType returnType;
  public KotlinType receiverParameterType;
  public List<KotlinType> contextReceiverTypes;
  public int jvmFlags;
  public int flags;
  public int setterFlags;
  public int getterFlags;
  public List<KotlinTypeParameter> typeParameters;
  public KotlinValueParameter setterParameter;

  public static KotlinProperty fromKmProperty(KmProperty p) {
    var prop = new KotlinProperty();
    var fieldSignature = JvmExtensionsKt.getFieldSignature(p);
    prop.fieldDescriptor = fieldSignature == null ? null : fieldSignature.getDesc();
    prop.fieldName = fieldSignature == null ? null : fieldSignature.getName();
    var getterSignature = JvmExtensionsKt.getGetterSignature(p);
    prop.getterDescriptor = getterSignature == null ? null : getterSignature.getDesc();
    prop.getterName = getterSignature == null ? null : getterSignature.getName();
    var setterSignature = JvmExtensionsKt.getSetterSignature(p);
    prop.setterDescriptor = setterSignature == null ? null : setterSignature.getDesc();
    prop.setterName = setterSignature == null ? null : setterSignature.getName();
    prop.kotlinName = p.getName();
    prop.returnType = KotlinType.fromKmType(p.getReturnType());
    prop.receiverParameterType = KotlinType.fromKmType(p.getReceiverParameterType());
    prop.contextReceiverTypes =
        p.getContextReceiverTypes().stream()
            .map(KotlinType::fromKmType)
            .collect(Collectors.toList());
    prop.jvmFlags = JvmExtensionsKt.getJvmFlags(p);
    prop.flags = p.getFlags();
    prop.setterFlags = p.getSetterFlags();
    prop.getterFlags = p.getGetterFlags();
    prop.typeParameters =
        p.getTypeParameters().stream()
            .map(KotlinTypeParameter::fromKmTypeParameter)
            .collect(Collectors.toList());
    prop.setterParameter = KotlinValueParameter.fromKmValueParameter(p.getSetterParameter());
    return prop;
  }
}
