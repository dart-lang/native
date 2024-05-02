// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "objective_c.h"

#include <mach/mach.h>
#include <mach/mach_vm.h>
#include <stdlib.h>

#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

// Dispose helper for ObjC blocks that wrap a Dart closure. For these blocks,
// the target is an int ID, and the dispose_port is listening for these IDs.
void disposeObjCBlockWithClosure(ObjCBlock* block) {
  Dart_PostInteger_DL(block->dispose_port, (int64_t)block->target);
}

bool isValidBlock(ObjCBlock* block) {
  if (block == NULL) return false;
  void* isa = block->isa;
  return isa == &_NSConcreteStackBlock || isa == &_NSConcreteMallocBlock ||
         isa == &_NSConcreteAutoBlock || isa == &_NSConcreteFinalizingBlock ||
         isa == &_NSConcreteGlobalBlock || isa == &_NSConcreteWeakBlockVariable;
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
