# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(objective_c_library VERSION 0.0.1 LANGUAGES C)

add_library(objective_c SHARED
  "objective_c.c"
)

set_target_properties(objective_c PROPERTIES
  PUBLIC_HEADER objective_c.h
  OUTPUT_NAME "objective_c"
)

target_compile_definitions(objective_c PUBLIC DART_SHARED_LIB)
