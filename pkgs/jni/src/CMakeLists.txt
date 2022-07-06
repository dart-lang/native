# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(jni_library VERSION 0.0.1 LANGUAGES C)

add_library(jni SHARED
  "jni.c"
)

set_target_properties(jni PROPERTIES
  PUBLIC_HEADER jni.h
  OUTPUT_NAME "jni"
)

target_compile_definitions(jni PUBLIC DART_SHARED_LIB)
