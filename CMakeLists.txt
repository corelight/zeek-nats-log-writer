# This file is maintained by zkg. Do not edit.
# Put required additional cmake functionality into plugin.cmake.
cmake_minimum_required(VERSION 3.15.0 FATAL_ERROR)

project(ZeekNATS)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)


# THIS IS TOTAL HACK.
# We try to statically link libprotobuf-c and nats.c
# with the plugin for reasons where this was meant to
# be deployed initially.
set(BUILD_PROTOC OFF CACHE BOOL "disable protoc")
add_subdirectory(./3rdparty/protobuf-c/build-cmake)

set(NATS_BUILD_EXAMPLES OFF)
set(NATS_BUILD_LIB_SHARED OFF)
set(NATS_PROTOBUF_DIR 3rdparty/protobuf-c)
set(NATS_PROTOBUF_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/protobuf-c)
set(NATS_PROTOBUF_LIBRARY $<TARGET_FILE:protobuf-c>)

add_subdirectory(./3rdparty/nats.c)
add_dependencies(nats_static protobuf-c)

# Establish version numbers in config.h
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" VERSION LIMIT_COUNT 1)

string(REGEX REPLACE "[.-]" " " version_numbers ${VERSION})
separate_arguments(version_numbers)
list(GET version_numbers 0 VERSION_MAJOR)
list(GET version_numbers 1 VERSION_MINOR)
list(GET version_numbers 2 VERSION_PATCH)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/src/config.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/config.h" @ONLY)

# Process any package-specific customizations
include(plugin.cmake OPTIONAL)

include(ZeekPlugin)

zeek_plugin_begin(Zeek NATS)
zeek_plugin_cc(src/Plugin.cc)
zeek_plugin_cc(src/NATS.cc)
zeek_plugin_link_library(nats_static)

zeek_plugin_dist_files(README.md CHANGES COPYING VERSION)
zeek_plugin_end()

target_compile_options(Zeek_NATS PRIVATE -fno-omit-frame-pointer -gdwarf)

if ("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    # Allows building rpm/deb packages via "make package" in build dir.
    include(ConfigurePackaging)
    ConfigurePackaging(${VERSION})
endif ()
