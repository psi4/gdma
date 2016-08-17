# gdma
Anthony Stone's GDMA (http://www-stone.ch.cam.ac.uk/programs.html) wrapped in CMake for Psi4 (https://github.com/psi4/psi4)

### History

This is the GDMA project (http://www-stone.ch.cam.ac.uk/programs.html) by
Prof. Anthony J. Stone of Cambridge University.

GDMA is written in Fortran. It has source and manual are available at the above
website and, as distributed, builds with `make`.

### This Repository

GDMA has been in the *ab initio* quantum chemistry package Psi4
(http://psicode.org/, https://github.com/psi4/psi4) since March 2016. In Psi4,
it builds with `cmake` and has an interface to C++ and Psi4 internals designed
by @andysim. Manual for GDMA+Psi4 at http://psicode.org/psi4manual/master/gdma.html.
This repository is GDMA wrapped up nicely in CMake.






#### Version

This codebase was copied from upstream (above website) at 2.2.06.

#### Building

```bash
cmake -H. -Bobjdir
cd objdir && make
make install
```

The build is also responsive to

* static/shared toggle `BUILD_SHARED_LIBS`
* install location `CMAKE_INSTALL_PREFIX`
* of course, `CMAKE_Fortran_COMPILER`, `CMAKE_C_COMPILER`, and `CMAKE_Fortran_FLAGS`

See [CMakeLists.txt](CMakeLists.txt) for options details. All these build options should be passed as `cmake -DOPTION`.

#### Detecting

This project installs with `gdmaConfig.cmake`, `gdmaConfigVersion.cmake`, and `gdmaTargets.cmake` files suitable for use with CMake [`find_package()`](https://cmake.org/cmake/help/v3.2/command/find_package.html) in `CONFIG` mode.

* `find_package(gdma)` - find any gdma libraries and headers
* `find_package(gdma 2.2.06 EXACT CONFIG REQUIRED COMPONENTS static)` - find gdma exactly version 2.2.06 built with static libraries or die trying

See [gdmaConfig.cmake.in](gdmaConfig.cmake.in) for details of how to detect the Config file and what CMake variables and targets are exported to your project.

#### Using

After `find_package(gdma ...)`,

* test if package found with `if(${gdma_FOUND})` or `if(TARGET gdma::gdma)`
* link to library (establishes dependency), including header and definitions configuration with `target_link_libraries(mytarget gdma::gdma)`
* include header files using `target_include_directories(mytarget PRIVATE $<TARGET_PROPERTY:gdma::gdma,INTERFACE_INCLUDE_DIRECTORIES>)`
* compile target applying `-DUSING_gdma` definition using `target_compile_definitions(mytarget PRIVATE $<TARGET_PROPERTY:gdma::gdma,INTERFACE_COMPILE_DEFINITIONS>)`
