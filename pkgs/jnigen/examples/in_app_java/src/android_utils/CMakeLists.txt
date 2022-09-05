# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(android_utils VERSION 0.0.1 LANGUAGES C)

add_library(android_utils SHARED
  "./android_utils.c"
)

set_target_properties(android_utils PROPERTIES
  OUTPUT_NAME "android_utils"
)

target_compile_definitions(android_utils PUBLIC DART_SHARED_LIB)

if(WIN32)
	set_target_properties(${TARGET_NAME} PROPERTIES
		LINK_FLAGS "/DELAYLOAD:jvm.dll")
endif()

if (ANDROID)
	target_link_libraries(android_utils log)
else()
	find_package(Java REQUIRED)
	find_package(JNI REQUIRED)
	include_directories(${JNI_INCLUDE_DIRS})
	target_link_libraries(android_utils ${JNI_LIBRARIES})
endif()
