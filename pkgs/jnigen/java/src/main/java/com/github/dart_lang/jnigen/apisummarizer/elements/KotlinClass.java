// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlinx.metadata.KmClass;
import kotlinx.metadata.jvm.JvmExtensionsKt;

public class KotlinClass {
  public String name;
  public String moduleName;
  public List<KotlinFunction> functions;
  public List<KotlinProperty> properties;
  public List<KotlinConstructor> constructors;
  public List<KotlinTypeParameter> typeParameters;
  public List<KotlinType> contextReceiverTypes;
  public List<KotlinType> superTypes;
  public List<String> nestedClasses;
  public List<String> enumEntries;
  public List<String> sealedClasses;
  public String companionObject;
  public String inlineClassUnderlyingPropertyName;
  public KotlinType inlineClassUnderlyingType;
  public int flags;
  public int jvmFlags;

  public static KotlinClass fromKmClass(KmClass c) {
    var klass = new KotlinClass();
    klass.name = c.getName();
    klass.moduleName = JvmExtensionsKt.getModuleName(c);
    klass.functions =
        c.getFunctions().stream().map(KotlinFunction::fromKmFunction).collect(Collectors.toList());
    klass.properties =
        c.getProperties().stream().map(KotlinProperty::fromKmProperty).collect(Collectors.toList());
    klass.constructors =
        c.getConstructors().stream()
            .map(KotlinConstructor::fromKmConstructor)
            .collect(Collectors.toList());
    klass.typeParameters =
        c.getTypeParameters().stream()
            .map(KotlinTypeParameter::fromKmTypeParameter)
            .collect(Collectors.toList());
    klass.contextReceiverTypes =
        c.getContextReceiverTypes().stream()
            .map(KotlinType::fromKmType)
            .collect(Collectors.toList());
    klass.superTypes =
        c.getSupertypes().stream().map(KotlinType::fromKmType).collect(Collectors.toList());
    klass.enumEntries = c.getEnumEntries();
    klass.flags = c.getFlags();
    klass.jvmFlags = JvmExtensionsKt.getJvmFlags(c);
    klass.nestedClasses = c.getNestedClasses();
    klass.companionObject = c.getCompanionObject();
    klass.inlineClassUnderlyingPropertyName = c.getInlineClassUnderlyingPropertyName();
    klass.inlineClassUnderlyingType = KotlinType.fromKmType(c.getInlineClassUnderlyingType());
    klass.sealedClasses = c.getSealedSubclasses();
    return klass;
  }
}
