cmake_minimum_required(VERSION 3.0)
project(gdma LANGUAGES Fortran C)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

################################### Options ####################################
include(Psi4Macros)
option_with_default(CMAKE_BUILD_TYPE "Build type" Release)
option_with_print(BUILD_SHARED_LIBS "Build final library as shared, not static" OFF)
option_with_default(BUILD_FPIC "Libraries will be compiled with position independent code" ON)
if(${BUILD_SHARED_LIBS} AND NOT ${BUILD_FPIC})
    message(FATAL_ERROR "BUILD_SHARED_LIBS ON and BUILD_FPIC OFF are incompatible, as shared library requires position independent code")
endif()
option_with_print(ENABLE_GENERIC "Enable mostly static linking in shared library" OFF)
option_with_flags(ENABLE_XHOST "Enable processor-specific optimization" ON
                    "-xHost" "-march=native")
# CODE_COVERAGE should be tested and probably propagated to external projects
#option_with_flags(ENABLE_CODE_COVERAGE "Enables details on code coverage" OFF
#                    "-ftest-coverage")

######################### Process & Validate Options ###########################
include(autocmake_safeguards)
include(autocmake_static_library)

################################# Main Project #################################
include(GNUInstallDirs)
include(FortranCInterface)
include(CMakePackageConfigHelpers)

set(PN ${PROJECT_NAME})

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

# STATIC/SHARED on below governed by BUILD_SHARED_LIBS
add_library(gdma ${sources_list})
set_target_properties(gdma PROPERTIES POSITION_INDEPENDENT_CODE ${BUILD_FPIC})
if(${BUILD_SHARED_LIBS})
    target_link_libraries(gdma PRIVATE ${LIBC_INTERJECT})
endif()

# <<<  Install  >>>

install(FILES ${CMAKE_BINARY_DIR}/GDMA_MANGLE.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/GDMA)
install(TARGETS gdma
        EXPORT "${PN}Targets"
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

# <<<  Export Interface  >>>

target_compile_definitions(gdma INTERFACE USING_${PN})
target_include_directories(gdma INTERFACE
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

# <<<  Export Config  >>>

    # explicit "share" not "DATADIR" for CMake search path
set(CMAKECONFIG_INSTALL_DIR "share/cmake/${PN}")
configure_package_config_file(${PN}Config.cmake.in
                              "${CMAKE_CURRENT_BINARY_DIR}/${PN}Config.cmake"
                              INSTALL_DESTINATION ${CMAKECONFIG_INSTALL_DIR})
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/${PN}ConfigVersion.cmake
                                 VERSION 2.2.06
                                 COMPATIBILITY SameMajorVersion)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PN}Config.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/${PN}ConfigVersion.cmake
        DESTINATION ${CMAKECONFIG_INSTALL_DIR})
install(EXPORT "${PN}Targets"
        NAMESPACE "${PN}::"
        DESTINATION ${CMAKECONFIG_INSTALL_DIR})

