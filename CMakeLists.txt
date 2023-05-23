cmake_policy(SET CMP0048 NEW)  # project_VERSION* variables populated from project(... VERSION x.x.x) string
cmake_minimum_required(VERSION 3.0)
project(gdma
        VERSION 2.3.3
        LANGUAGES C Fortran)
set(gdma_AUTHORS      "Anthony J. Stone")
set(gdma_DESCRIPTION  "Gaussian Distributed Multipole Analysis")
set(gdma_URL          "http://www-stone.ch.cam.ac.uk/programs.html")
set(gdma_LICENSE      "GNU General Public License, version 2 or later")

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

################################### Options ####################################
include(psi4OptionsTools)
option_with_default(CMAKE_BUILD_TYPE "Build type" Release)
option_with_print(BUILD_SHARED_LIBS "Build final library as shared, not static" OFF)
option_with_default(BUILD_FPIC "Compile static libraries with position independent code" ON)
option_with_print(ENABLE_OPENMP "Enable threadsafe linking to OpenMP parallelized programs." ON)
option_with_default(CMAKE_INSTALL_LIBDIR "Directory to which libraries installed" lib)
option_with_default(PYMOD_INSTALL_LIBDIR "If gdma_ENABLE_PYTHON, location within CMAKE_INSTALL_LIBDIR to which python modules are installed" /)
option_with_print(ENABLE_GENERIC "Enable mostly static linking in shared library" OFF)
option_with_flags(ENABLE_XHOST "Enable processor-specific optimization" ON
                    "-xHost" "-march=native")
option_with_default(ENABLE_GENERIC "Enables mostly static linking of system and math libraries for shared library" OFF)
option_with_default(gdma_INSTALL_CMAKEDIR "Directory to which ambit CMake config files installed." share/cmake/gdma)
option_with_print(gdma_ENABLE_PYTHON "Build Python bindings (requires Python and Pybind11)" OFF)

######################### Process & Validate Options ###########################
include(autocmake_safeguards)
include(autocmake_omp)
include(custom_static_library)

set(CMAKECONFIG_INSTALL_DIR "${gdma_INSTALL_CMAKEDIR}")

################################# Main Project #################################
include(GNUInstallDirs)
include(FortranCInterface)
include(CMakePackageConfigHelpers)

set(gdma ${PROJECT_NAME})

# <<<  Build  >>>

FortranCInterface_HEADER(GDMA_MANGLE.h
                         MACRO_NAMESPACE "GDMA_MANGLE_"
                         SYMBOL_NAMESPACE "GDMA_MANGLE_")
set(raw_sources_list atom_grids.f90
                     dma.f90
                     gdma.f90
                     input.F90
                     timing.F90)
set(src_prefix "src/")
string(REGEX REPLACE "([^;]+)" "${src_prefix}\\1" sources_list "${raw_sources_list}")

find_package(Python COMPONENTS Interpreter REQUIRED)
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/version.f90
  #COMMAND ${Python_EXECUTABLE} version.py ../VERSION ${CMAKE_CURRENT_BINARY_DIR}/version.f90 ${CMAKE_Fortran_COMPILER}
  COMMAND ${Python_EXECUTABLE} version.py ../VERSION ${CMAKE_CURRENT_BINARY_DIR}/version.f90 "Fortran"  # TODO
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src
  COMMENT "Generating version info"
  )

# STATIC/SHARED on below governed by BUILD_SHARED_LIBS
add_library(gdma ${sources_list} ${CMAKE_CURRENT_BINARY_DIR}/version.f90)
add_library(gdma::gdma ALIAS gdma)
#add_executable(gdmaexe ${sources_list})
set_target_properties(gdma PROPERTIES POSITION_INDEPENDENT_CODE ${BUILD_FPIC})
if(${BUILD_SHARED_LIBS})
    target_link_libraries(gdma PRIVATE ${LIBC_INTERJECT})

    if(APPLE)
        set_target_properties(gdma PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
    endif()
endif()

# Python directory
if (gdma_ENABLE_PYTHON)
    add_subdirectory(pygdma)
endif()

# <<<  Install  >>>

install(FILES ${CMAKE_BINARY_DIR}/GDMA_MANGLE.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/GDMA)
install(
  TARGETS
    gdma
  EXPORT
    library_interface
  RUNTIME DESTINATION
    ${CMAKE_INSTALL_BINDIR}
  ARCHIVE DESTINATION
    ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION
    ${CMAKE_INSTALL_LIBDIR}
  PUBLIC_HEADER DESTINATION
    ${CMAKE_INSTALL_INCLUDEDIR}
  )

# <<<  Export Interface  >>>

target_compile_definitions(gdma INTERFACE USING_${gdma})
target_include_directories(gdma INTERFACE
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

# <<<  Export Config  >>>

configure_package_config_file(cmake/${gdma}Config.cmake.in
                              "${CMAKE_CURRENT_BINARY_DIR}/${gdma}Config.cmake"
                              INSTALL_DESTINATION ${CMAKECONFIG_INSTALL_DIR})
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/${gdma}ConfigVersion.cmake
                                 VERSION ${${gdma}_VERSION}
                                 COMPATIBILITY SameMajorVersion)
install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${gdma}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${gdma}ConfigVersion.cmake
  DESTINATION
    ${CMAKECONFIG_INSTALL_DIR}
  )

install(
  EXPORT
    library_interface
  FILE
    "${PROJECT_NAME}Targets-lib.cmake"
  NAMESPACE
    "${PROJECT_NAME}::"
  DESTINATION
    ${CMAKECONFIG_INSTALL_DIR}
  )

