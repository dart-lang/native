// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni;

import java.lang.reflect.*;

public class PortProxy implements InvocationHandler {
  static {
    System.loadLibrary("dartjni");
  }

  private final long port;
  private final long threadId;
  private final long functionPtr;

  private PortProxy(long port, long threadId, long functionPtr) {
    this.port = port;
    this.threadId = threadId;
    this.functionPtr = functionPtr;
  }

  private static String getDescriptor(Method method) {
    StringBuilder descriptor = new StringBuilder();
    descriptor.append(method.getName()).append("(");
    Class<?>[] parameterTypes = method.getParameterTypes();
    for (Class<?> paramType : parameterTypes) {
      appendType(descriptor, paramType);
    }
    descriptor.append(")");
    appendType(descriptor, method.getReturnType());
    return descriptor.toString();
  }

  private static void appendType(StringBuilder descriptor, Class<?> type) {
    if (type == void.class) {
      descriptor.append("V");
    } else if (type == boolean.class) {
      descriptor.append("Z");
    } else if (type == byte.class) {
      descriptor.append("B");
    } else if (type == char.class) {
      descriptor.append("C");
    } else if (type == short.class) {
      descriptor.append("S");
    } else if (type == int.class) {
      descriptor.append("I");
    } else if (type == long.class) {
      descriptor.append("J");
    } else if (type == float.class) {
      descriptor.append("F");
    } else if (type == double.class) {
      descriptor.append("D");
    } else if (type.isArray()) {
      descriptor.append('[');
      appendType(descriptor, type.getComponentType());
    } else {
      descriptor.append("L").append(type.getName().replace('.', '/')).append(";");
    }
  }

  public static Object newInstance(String binaryName, long port, long threadId, long functionPtr)
      throws ClassNotFoundException {
    Class<?> clazz = Class.forName(binaryName);
    return Proxy.newProxyInstance(
        clazz.getClassLoader(), new Class[] {clazz}, new PortProxy(port, threadId, functionPtr));
  }

  @Override
  public Object invoke(Object proxy, Method method, Object[] args) {
    Object[] result = _invoke(port, threadId, functionPtr, proxy, getDescriptor(method), args);
    _cleanUp((Long) result[0]);
    return result[1];
  }

  /// Returns an array with two objects:
  /// [0]: The address of the result pointer used for the clean-up.
  /// [1]: The result of the invocation.
  private native Object[] _invoke(
      long port,
      long threadId,
      long functionPtr,
      Object proxy,
      String methodDescriptor,
      Object[] args);

  private native void _cleanUp(long resultPtr);
}
