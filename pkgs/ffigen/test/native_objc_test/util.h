// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef _TEST_UTIL_H_
#define _TEST_UTIL_H_

#include <mach/mach.h>
#include <mach/mach_vm.h>

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

bool isReadableMemory(void* ptr) {
  vm_map_t task = mach_task_self();
  mach_vm_address_t address = (mach_vm_address_t)ptr;
  mach_vm_size_t size = 0;
  vm_region_basic_info_data_64_t info;
  mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
  mach_port_t object_name;
  kern_return_t status =
      mach_vm_region(task, &address, &size, VM_REGION_BASIC_INFO_64,
                     (vm_region_info_t)&info, &count, &object_name);
  if (status != KERN_SUCCESS) return false;
  return ((mach_vm_address_t)ptr) >= address &&
         (info.protection & VM_PROT_READ);
}

#endif  // _TEST_UTIL_H_
