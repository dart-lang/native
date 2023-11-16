// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file re-exports some JNI constants as enum, because they are not
// currently being included when they are in macro form.

enum JniBooleanValues { JNI_FALSE = 0, JNI_TRUE = 1 };

enum JniVersions {
  JNI_VERSION_1_1 = 0x00010001,
  JNI_VERSION_1_2 = 0x00010002,
  JNI_VERSION_1_4 = 0x00010004,
  JNI_VERSION_1_6 = 0x00010006,
};

enum JniErrorCode {
  // Error codes from JNI
  JNI_OK = 0,         /* no error */
  JNI_ERR = -1,       /* generic error */
  JNI_EDETACHED = -2, /* thread detached from the VM */
  JNI_EVERSION = -3,  /* JNI version error */
  JNI_ENOMEM = -4,    /* Out of memory */
  JNI_EEXIST = -5,    /* VM already created */
  JNI_EINVAL = -6,    /* Invalid argument */
};

enum JniBufferWriteBack {
  JNI_COMMIT = 1, /* copy content, do not free buffer */
  JNI_ABORT = 2,  /* free buffer w/o copying back */
};
