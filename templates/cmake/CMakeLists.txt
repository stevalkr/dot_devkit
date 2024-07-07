# ----------------------------------------------------------------------------
# Root CMake file for {{ project_name }}
# ----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.15)
project(
  {{ project_name }}
  LANGUAGES CXX
  VERSION 0.0.1)
include(cmake/macros.cmake)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif ()
message(STATUS "Build type: " ${CMAKE_BUILD_TYPE})

option(BUILD_TESTING "Build tests" ON)

# --------------------------------------------------------------------
# Find Package
# --------------------------------------------------------------------

find_package_and_export(doctest REQUIRED)

# --------------------------------------------------------------------
# Install Library
# --------------------------------------------------------------------

add_library({{ project_name }} INTERFACE)
add_library({{ project_name }}::{{ project_name }} ALIAS {{ project_name }})
target_include_directories(
  {{ project_name }} INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/modules>
                               $<INSTALL_INTERFACE:${INSTALL_INCLUDE_DIR}>)

install(
  TARGETS {{ project_name }}
  EXPORT ${EXPORTED_TARGETS_NAME}
  DESTINATION "${INSTALL_LIB_DIR}")

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/modules"
        DESTINATION "${INSTALL_INCLUDE_DIR}")

# --------------------------------------------------------------------
# Add subdirectory
# --------------------------------------------------------------------

add_subdirectory(tools)

if (BUILD_TESTING)
  message(STATUS "Building tests")
  enable_testing()
  add_subdirectory(tests)
endif ()

package()
