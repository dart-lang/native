// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#if _WIN32
#define MYLIB_EXPORT __declspec(dllexport)
#else
#define MYLIB_EXPORT
#endif

MYLIB_EXPORT char* buildTime;
