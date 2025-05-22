cmake_minimum_required(VERSION 3.10)

#====================================================
# Policy
#====================================================
if(CMAKE_VERSION VERSION_GREATER 3.15)
  # enable CMAKE_MSVC_RUNTIME_LIBRARY
  cmake_policy(SET CMP0091 NEW)
  # enable <LIB>_ROOT
  cmake_policy(SET CMP0074 NEW)
endif()
#====================================================
# Extract version
#====================================================
include(cmake/colorer_extract_version.cmake)
colorer_extract_version()

#====================================================
# main project
#====================================================
project(colorer VERSION ${COLORER_VERSION} LANGUAGES CXX)
message(STATUS "Build Colorer library: ${COLORER_VERSION}")

#====================================================
# Set default build type
#====================================================
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type, one of: Release, Debug" FORCE)
endif()
set(CMAKE_CONFIGURATION_TYPES "${CMAKE_BUILD_TYPE}" CACHE STRING "" FORCE)
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

#====================================================
# global library settings
#====================================================
# build options
option(COLORER_USE_VCPKG "Use dependencies installed via vcpkg" ON)
option(COLORER_BUILD_TOOLS "Build colorer tools" ON)
option(COLORER_BUILD_TEST "Build tests" OFF)
option(COLORER_BUILD_INSTALL "Make targets for install" ON)
set(COLORER_BUILD_ARCH x64 CACHE STRING "Build architecture")
option(COLORER_BUILD_HARD_WARNINGS "Compiler warnings as error on Release build" ON)
option(COLORER_BUILD_OLD_COMPILERS "Use own implementation for standard library" OFF)

# library features
option(COLORER_USE_ZIPINPUTSOURCE "Use zip inputsource for schemes" ON)
option(COLORER_USE_DEEPTRACE "Use trace logging" OFF)
option(COLORER_USE_ICU_STRINGS "Use ICU library for strings" ON)

#====================================================
# global compilation settings
#====================================================
if(MSVC)
  # set global Visual C++ runtime
  if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDebug")
  else()
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")
  endif()
endif()

#====================================================
# load modules
#====================================================
if(NOT COLORER_USE_VCPKG)
  # this line need for find_package
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
endif()

#====================================================
# find dependencies
#====================================================
# core library
if(COLORER_USE_ICU_STRINGS)
  find_package(ICU COMPONENTS uc data REQUIRED)
endif()

find_package(LibXml2 REQUIRED)

if(COLORER_USE_ZIPINPUTSOURCE)
  find_package(ZLIB REQUIRED)
  if(COLORER_USE_VCPKG)
    find_package(unofficial-minizip REQUIRED)
  else()
    find_package(minizip REQUIRED)
  endif()
endif()

#====================================================
# colorer library
#====================================================
add_subdirectory(./src)

#====================================================
# colorer tool
#====================================================
if(COLORER_BUILD_TOOLS)
  add_subdirectory(./tools/colorer)
endif()

#====================================================
# Tests
#====================================================
if(COLORER_BUILD_TEST)
  add_subdirectory(./tests/unit)
  add_subdirectory(./tests)
endif()

#====================================================
# install
#====================================================
if(COLORER_BUILD_INSTALL)
  include(GNUInstallDirs)

  install(TARGETS colorer_lib
      EXPORT colorerTargets
      LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
      ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )

  install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/colorer
      DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
      FILES_MATCHING PATTERN "*.h"
  )
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/src/colorer/common/Features.h"
      DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/colorer/common")

  install(EXPORT colorerTargets
      FILE colorerTargets.cmake
      DESTINATION lib/cmake/colorer
      NAMESPACE colorer::
  )

  configure_file("${CMAKE_CURRENT_LIST_DIR}/cmake/colorerConfig.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake/colorerConfig.cmake" @ONLY)

  include(CMakePackageConfigHelpers)
  write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/colorerConfigVersion.cmake" COMPATIBILITY SameMajorVersion)
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/cmake/colorerConfig.cmake"
      "${CMAKE_CURRENT_BINARY_DIR}/colorerConfigVersion.cmake"
      DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/colorer")

  if(COLORER_BUILD_TOOLS)
    install(TARGETS consoletools RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
  endif()

  #====================================================
  # cpack
  #====================================================
  if("${COLORER_BUILD_ARCH}" STREQUAL "x64")
    set(PACKAGE_FILE_NAME "${PROJECT_NAME}.v${COLORER_VERSION}.x64")
  else()
    set(PACKAGE_FILE_NAME "${PROJECT_NAME}.v${COLORER_VERSION}.x86")
  endif()
  set(CPACK_GENERATOR "ZIP" CACHE STRING "Generators to support. semi-colon delimited list")
  set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY 0)
  set(CPACK_PACKAGE_FILE_NAME "${PACKAGE_FILE_NAME}")

  include(CPack)
endif()