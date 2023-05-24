if (CMAKE_HOST_WIN32)
    cmake_minimum_required(VERSION 3.21)
else()
    cmake_minimum_required(VERSION 3.16)
endif()
cmake_policy(SET CMP0079 NEW)
project(
  pygdma
  VERSION 2.3.3  # SYNC WITH `project(gdma VERSION <>)` in <top_level>/CMakeLists.txt
  LANGUAGES CXX
  )
set(pygdma_AUTHORS      "Anthony J. Stone")
set(pygdma_DESCRIPTION  "Gaussian Distributed Multipole Analysis")
set(pygdma_URL          "https://www-stone.ch.cam.ac.uk/pub/gdma/")
set(pygdma_LICENSE      "GNU General Public License, version 3")

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../cmake)

################################### Options ####################################
include(psi4OptionsTools)
option_with_default(CMAKE_BUILD_TYPE "Build type (Release or Debug)" Release)
option_with_default(PYMOD_INSTALL_LIBDIR "Location within CMAKE_INSTALL_LIBDIR to which python modules are installed" /)
option_with_default(gdma_INSTALL_CMAKEDIR "Directory to which gdma CMake config files installed." share/cmake/gdma)

################################# Main Project #################################
include(autocmake_safeguards)
include(GNUInstallDirs)
set(CMAKECONFIG_INSTALL_DIR "${gdma_INSTALL_CMAKEDIR}")

set(Python_ADDITIONAL_VERSIONS 3.11 3.10 3.9 3.8 3.7)  # adjust with CMake minimum FindPythonInterp
find_package(Python 3.7 COMPONENTS Interpreter Development REQUIRED)
message(STATUS "Found Python ${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}: ${Python_EXECUTABLE} (found version ${Python_VERSION})")

if (NOT TARGET pybind11::pybind11)
    find_package(pybind11 CONFIG REQUIRED)
endif()

if (APPLE)
    set(base "@loader_path")
else()
    set(base "$ORIGIN")
endif()
file(RELATIVE_PATH relDir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}${PYMOD_INSTALL_LIBDIR}
                          ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_INSTALL_RPATH ${base} ${base}/${relDir})

message(STATUS "pygdma rpath: ${CMAKE_INSTALL_RPATH}")

configure_file(bindings.cc.cmake.in bindings.cc @ONLY)  # bake in version string
pybind11_add_module(pygdma MODULE bindings.cc)
target_compile_features(pygdma PRIVATE "cxx_std_17")
add_library(gdma::pygdma ALIAS pygdma)

if(NOT TARGET gdma::gdma)
    find_package(gdma CONFIG REQUIRED)
endif()
target_link_libraries(pygdma PRIVATE gdma::gdma)

if(MSVC)
    target_compile_definitions(pygdma PUBLIC _USE_MATH_DEFINES)
    target_compile_options(pygdma PUBLIC "/EHsc")
    set_target_properties(
      pygdma
      PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS ON
      )
endif()

set(export_properties
  "gdma_VERSION"
  "gdma_PYMOD"
  )

set_target_properties(
  pygdma
  PROPERTIES
    OUTPUT_NAME gdma
    EXPORT_NAME pygdma
    INSTALL_RPATH "${CMAKE_INSTALL_RPATH}"
    # below two are covered by pb11. Use pybind11_add_module(... NO_EXTRAS) to experiment here.
    # CXX_VISIBILITY_PRESET "hidden"
    # VISIBILITY_INLINES_HIDDEN 1
    gdma_VERSION ${pygdma_VERSION}
    gdma_PYMOD "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}${PYMOD_INSTALL_LIBDIR}"
    EXPORT_PROPERTIES "${export_properties}"
  )

# It's not clear whether Python bindings should get a Config.cmake file and/or a separate project().
#   See https://github.com/jturney/ambit/blob/master/pyambit/CMakeLists.txt#L88 for discussion, esp. for packagers.

install(
  TARGETS
    pygdma
  EXPORT
    python_interface
  LIBRARY DESTINATION
    ${CMAKE_INSTALL_LIBDIR}${PYMOD_INSTALL_LIBDIR}
  )

install(
  EXPORT
    python_interface
  FILE
    "gdmaTargets-Python.cmake"
  NAMESPACE
    "gdma::"
  DESTINATION
    ${CMAKECONFIG_INSTALL_DIR}
  )

