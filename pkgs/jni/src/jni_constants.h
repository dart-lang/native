// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file re-exports some JNI constants as enum, because they are not
// currently being included when they are in macro form.
#pragma once

#include "jni.h"

typedef enum JniBooleanValues {
  FALSE = JNI_FALSE,
  TRUE = JNI_TRUE
} JniBooleanValues;

typedef enum JniVersions {
  VERSION_1_1 = JNI_VERSION_1_1,
  VERSION_1_2 = JNI_VERSION_1_2,
  VERSION_1_4 = JNI_VERSION_1_4,
  VERSION_1_6 = JNI_VERSION_1_6,
} JniVersions;

typedef enum JniErrorCode {
  // Error codes from JNI
  OK = JNI_OK,               /* no error */
  ERR = JNI_ERR,             /* generic error */
  EDETACHED = JNI_EDETACHED, /* thread detached from the VM */
  EVERSION = JNI_EVERSION,   /* JNI version error */
  ENOMEM = JNI_ENOMEM,       /* Out of memory */
  EEXIST = JNI_EEXIST,       /* VM already created */
  EINVAL = JNI_EINVAL,       /* Invalid argument */
  SINGLETON_EXISTS = -99,
} JniErrorCode;

typedef enum JniBufferWriteBack {
  COMMIT = JNI_COMMIT, /* copy content, do not free buffer */
  ABORT = JNI_ABORT,   /* free buffer w/o copying back */
} JniBufferWriteBack;
