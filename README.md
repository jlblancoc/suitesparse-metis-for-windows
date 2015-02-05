CMake scripts for painless usage of Tim Davis' [SuiteSparse](http://www.cise.ufl.edu/research/sparse/SuiteSparse/) (CHOLMOD,UMFPACK,AMD,LDL,SPQR,...) and [METIS](http://glaros.dtc.umn.edu/gkhome/views/metis) from Visual Studio and the rest of Windows/Linux/OSX IDEs supported by CMake. The project includes precompiled BLAS/LAPACK DLLs for easy use with Visual C++.

The goal is using one single CMake code to build against *SuiteSparse* in standard Linux package systems (e.g. `libsuitesparse-dev`) and in manual compilations under Windows.

**Credits:** Jose Luis Blanco (Universidad de Almeria); Jerome Esnault (INRIA).

![logo](https://raw.githubusercontent.com/jlblancoc/suitesparse-metis-for-windows/master/docs/logo.png)

1. Instructions
-------------------------------------------------------

  * (1) Install [CMake](http://www.cmake.org/).
  * (2) Only for Linux/Mac: Install LAPACK & BLAS. In Debian/Ubuntu: `sudo apt-get install liblapack-dev libblas-dev`
  * (3) Clone or download this project ([latest release](https://github.com/jlblancoc/suitesparse-metis-for-windows/releases)) and extract it somewhere in your disk, say `SP_ROOT`.
	  * (OPTIONAL) CMake will download SuiteSparse sources automatically for you (skip to step 4), but you may do it manually if preferred: 
        * Populate the directories within `SP_ROOT` with the original sources from each project:
          * *`SuiteSparse`:* 
            * Download [SuiteSparse-X.Y.Z.tar.gz](http://www.cise.ufl.edu/research/sparse/SuiteSparse/) from Tim Davis' webpage. 
            * Extract it.
            * Merge (e.g. copy and paste from Windows Explorer) the tree `SuiteSparse/*` into `SP_ROOT/SuiteSparse/*`.
            * Make sure of **looking for patches** in [the original webpage](http://www.cise.ufl.edu/research/sparse/SuiteSparse/) and apply them to prevent build errors.
          * *`METIS`:*  (Optional, only if need METIS for partitioning)
            * Download [metis-X.Y.Z.tar.gz](http://glaros.dtc.umn.edu/gkhome/metis/metis/download).
            * Extract it.
            * Merge the tree `metis-X.Y.Z/*` into `SP_ROOT/metis/*`.
            * Add the command `cmake_policy(SET CMP0022 NEW)` right after the line `project(METIS)` in `metis/CMakeLists.txt`.

  * (4) **Run CMake** (cmake-gui), then: 
      * Set the "Source code" directory to `SP_ROOT` 
	  * Set the "Build" directory to any empty directory, typically `SP_ROOT/build`
	  * Press "Configure", change anything (if needed)
      * **Important**: I recommend setting the `CMAKE_INSTALL_PREFIX` or (in Windows) `SUITESPARSE_INSTALL_PREFIX` to some other directory different than "Program Files" or "/usr/local" so the INSTALL command does not require Admin privileges.
      * Apparently only for Linux: if you have an error like: "Cannot find source file: GKlib/conf/check_thread_storage.c", then manually adjust `GKLIB_PATH` to the correct path `SP_ROOT/metis/GKlib`.
	  * Press "Generate".
      * `HAVE_COMPLEX` is OFF by default to avoid errors related to complex numbers in some compilers. 
  * (5) **Compile and install:** 
    * In Visual Studio, open `SuiteSparseProject.sln` and build the `INSTALL` project in Debug and Release. You may get hundreds of warnings, but it's ok.
    * In Unix: Just execute `make install` or `sudo make install` if you did set the install prefix to `/usr/*`

  * (6) Notice that a file `SuiteSparseConfig.cmake` should be located in your install directory. It will be required for your programs to correctly build and link against `SuiteSparse`.

  * (7) Only for Windows: You will have to append `CMAKE_INSTALL_PREFIX\lib*\lapack_blas_windows\` and `CMAKE_INSTALL_PREFIX\lib*` to the environment variable `PATH` before executing any program, for Windows to localize the required BLAS/Fortran libraries (`.DLL`s).


2. Test program
-------------------------------------------------------

Example CMake programs are provided for testing, based on Tim Davis' code in his manual:
  * [example-projects](https://github.com/jlblancoc/suitesparse-metis-for-windows/tree/master/example-projects)


3. Integration in your code (unique code for Windows/Linux)
-------------------------------------------------------

  * Copy this **[FindSuiteSparse.cmake](https://github.com/jlblancoc/suitesparse-metis-for-windows/blob/master/cmakemodule/FindSuiteSparse.cmake)** file.
  * Add a block like this to your CMake code (see complete [example](https://github.com/jlblancoc/suitesparse-metis-for-windows/blob/master/example-projects/cholmod/CMakeLists.txt)):
   
  
    ```
    #...
    
    # ------------------------------------------------------------------
    # Detect SuiteSparse libraries:
    # If not found automatically, set SuiteSparse_DIR in CMake to the 
    # directory where SuiteSparse was built.
    # ------------------------------------------------------------------
    LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/..") # Add the directory where FindSuiteSparse.cmake module can be found.
    
    set(SuiteSparse_USE_LAPACK_BLAS ON)
    find_package(SuiteSparse QUIET NO_MODULE)  # 1st: Try to locate the *config.cmake file.
    if(NOT SuiteSparse_FOUND)
            set(SuiteSparse_VERBOSE ON)
            find_package(SuiteSparse REQUIRED) # 2nd: Use FindSuiteSparse.cmake module
            include_directories(${SuiteSparse_INCLUDE_DIRS})
    else()
            message(STATUS "Find SuiteSparse : include(${USE_SuiteSparse})")
            include(${USE_SuiteSparse})
    endif()
    MESSAGE(STATUS "SuiteSparse_LIBS: ${SuiteSparse_LIBRARIES}")
    # ------------------------------------------------------------------
    #   End of SuiteSparse detection
    # ------------------------------------------------------------------
    
    #...
    
    #TARGET_LINK_LIBRARIES(MY_PROGRAM ${SuiteSparse_LIBRARIES})
    ```


Remember to set **`SuiteSparse_DIR` to the install directory**, if CMake does not find it automatically. This will not be required when suitesparse is available as a system library in a Unix/Linux environment.



4. Why did you create this project?
-------------------------------------------------------


Porting `SuiteSparse` to CMake wasn't trivial because this package makes extensive usage of a _one-source-multiple-objects_ philosophy by compiling the same sources with different compiler flags, and this ain't directly possible to CMake's design.

My workaround to this limitation includes auxiliary Python scripts and dummy source files, so the whole thing became large enough to be worth publishing online so many others may benefit.
