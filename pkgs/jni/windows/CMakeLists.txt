# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "jni")
project(${PROJECT_NAME} LANGUAGES CXX)

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

if (TARGET jni)
  set(jni_bundled_libraries
    $<TARGET_FILE:jni>
    PARENT_SCOPE
  )
else()
  set(jni_bundled_libraries
    ""
    PARENT_SCOPE
  )
endif()
