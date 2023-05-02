## Parent CMake for Android native build target. This will build
## all C bindings from tests.

cmake_minimum_required(VERSION 3.10)

project(simple_package VERSION 0.0.1 LANGUAGES C)

add_subdirectory(../../../test/jackson_core_test/third_party/c_based/c_bindings jackson_core_test_build)
add_subdirectory(../../../test/simple_package_test/c_based/c_bindings simple_package_test_build)
add_subdirectory(../../../test/kotlin_test/c_based/c_bindings kotlin_test_build)
