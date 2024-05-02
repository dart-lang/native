// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef _TEST_UTIL_H_
#define _TEST_UTIL_H_

typedef struct {
  void* isa;
  int flags;
  // There are other fields, but we just need the flags and isa.
} BlockRefCountExtractor;

uint64_t getBlockRetainCount(BlockRefCountExtractor* block) {
  // The ref count is stored in the lower bits of the flags field, but skips the
  // 0x1 bit.
  return (block->flags & 0xFFFF) >> 1;
}

typedef struct {
  uint64_t header;
} ObjectRefCountExtractor;

uint64_t getObjectRetainCount(ObjectRefCountExtractor* object) {
  // The object ref count is stored in the largest byte of the object header,
  // for counts up to 255. Higher counts do something more complicated.
  return object->header >> 56;
}

#endif  // _TEST_UTIL_H_
