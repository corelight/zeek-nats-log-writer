# This file is maintained by zkg. Do not edit.
# Put required additional cmake functionality into plugin.cmake.
cmake_minimum_required(VERSION 3.15.0 FATAL_ERROR)

project(ZeekNATS)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(LibNATS REQUIRED)

message(STATUS "LIBNATS libraries: ${LIBNATS_LIBRARIES}")
message(STATUS "LIBNATS include: ${LIBNATS_INCLUDE_DIRS}")

include_directories(BEFORE ${LIBNATS_INCLUDE_DIRS})

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
zeek_plugin_link_library(${LIBNATS_LIBRARIES})

zeek_plugin_dist_files(README.md CHANGES COPYING VERSION)
zeek_plugin_end()

if ("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    # Allows building rpm/deb packages via "make package" in build dir.
    include(ConfigurePackaging)
    ConfigurePackaging(${VERSION})
endif ()
