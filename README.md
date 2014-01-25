CMake scripts for painless usage of Tim Davis' [SuiteSparse](http://www.cise.ufl.edu/research/sparse/SuiteSparse/) (CHOLMOD,UMFPACK,AMD,LDL,SPQR,...) and [METIS](http://glaros.dtc.umn.edu/gkhome/views/metis) from Visual Studio and the rest of Windows/Linux/OSX IDEs supported by CMake. The project includes precompiled BLAS/LAPACK DLLs for easy use with Visual C++.

The goal is using one single CMake code to build against *SuiteSparse* in standard Linux package systems (e.g. `libsuitesparse-dev`) and in manual compilations under Windows.

**Credits:** Jose Luis Blanco (Universidad de Almeria); Jerome Esnault (INRIA).

![logo](https://raw2.github.com/jlblancoc/suitesparse-metis-for-windows/master/docs/logo.png)

1. Instructions
-------------------------------------------------------


  * (1) Install [CMake](http://www.cmake.org/).
  * (2) Only for Linux/Mac: Install LAPACK & BLAS. In Debian/Ubuntu: `sudo apt-get install liblapack-dev libblas-dev`
  * (3) You can now either download a copy of the entire `SuiteSparse` sources+METIS sources+CMake build system or download the separate source packages independently. I recommend the latter, but will also offer the first option for the impatient.
    * **1st way: All-in-one package (faster)**. Download and extract anywhere in your disk (say, `SP_ROOT`):
      * `SuiteSparse-CMake+AllSources` ([ZIP](https://github.com/jlblancoc/suitesparse-metis-for-windows/releases/download/v1.1.0/suitesparse-metis-for-windows-1.1.0.all_sources.zip)). Included versions: `SuiteSparse` 4.02+METIS 5.0.2. I don't plan to keep this archive up-to-date to future releases of `SuiteSparse` or METIS, so refer to the following instructions instead if you need newer versions.
    * **2nd way: Do it yourself**.
      * Download `SuiteSparse-CMake` (this project) ([ZIP](https://github.com/jlblancoc/suitesparse-metis-for-windows/releases/download/v1.1.0/suitesparse-metis-for-windows-1.1.0.zip), [TAR.GZ](https://github.com/jlblancoc/suitesparse-metis-for-windows/releases/download/v1.1.0/suitesparse-metis-for-windows-1.1.0.tar.gz)) and extract it somewhere in your disk, say `SP_ROOT`.
      * Populate the directories within `SP_ROOT` with the original sources from each project:
        * *`SuiteSparse`:* 
          * Download [SuiteSparse-X.Y.Z.tar.gz](http://www.cise.ufl.edu/research/sparse/SuiteSparse/) from Tim Davis' webpage. 
          * Extract it.
          * Merge (e.g. copy and paste from Windows Explorer) the tree `SuiteSparse/*` into `SP_ROOT/SuiteSparse/*`.
          * Make sure of **looking for patches** in [the original webpage](http://www.cise.ufl.edu/research/sparse/SuiteSparse/) and apply them to prevent build errors.
        * *`METIS`:* 
          * Download [metis-X.Y.Z.tar.gz](http://glaros.dtc.umn.edu/gkhome/metis/metis/download).
          * Extract it.
          * Merge the tree `metis-X.Y.Z/*` into `SP_ROOT/metis/*`.

  * (4) **Run CMake** (cmake-gui) and set the "Source code" directory to `SP_ROOT` and the "Build" directory to any empty directory. Press "Configure", change anything (if needed) and finally press "Generate".
    * **IMPORTANT!**: I recommend changing `CMAKE_INSTALL_PREFIX` to some other directory different than "Program Files" or "/usr/local" so the INSTALL command does not require Admin privileges.
    * Apparently only for Linux: if you have an error like: "Cannot find source file: GKlib/conf/check_thread_storage.c", then manually adjust `GKLIB_PATH` to the correct path `SP_ROOT/metis/GKlib`.
  * (5) **Compile:** 
    * In Visual Studio, open `SuiteSparseProject.sln` and build all in Debug & Release, as needed. You may get hundreds of warnings, but it's ok.
    * In Unix: Just execute `make`.

  * (6) **Install:** To copy all required headers and libraries under `CMAKE_INSTALL_PREFIX`.
    * In Visual Studio, select `Release` configuration and build the `INSTALL` target. Then select the `Debug` configuration and build `INSTALL` again.
    * In Unix: Execute `make install`, or `sudo make install`, as needed.
 
  * (7) Notice that a file `SuiteSparseConfig.cmake` should be located in your install directory. It will be required for your programs to correctly build and link against `SuiteSparse`.

  * (8) Only for Windows: You will have to append `CMAKE_INSTALL_PREFIX\lib*\lapack_blas_windows\` and `CMAKE_INSTALL_PREFIX\lib*` to the environment variable `PATH` before executing any program, for Windows to localize the required BLAS/Fortran libraries (`.DLL`s).


2. Test program
-------------------------------------------------------

Example CMake programs are provided for testing, based on Tim Davis' code in his manual:
  * [example-projects](https://github.com/jlblancoc/suitesparse-metis-for-windows/tree/master/example-projects)


3. Integration in your code (unique code for Windows/Linux)
-------------------------------------------------------

  * Copy this **[FindSuiteSparse.cmake](https://github.com/jlblancoc/suitesparse-metis-for-windows/blob/master/example-projects/FindSuiteSparse.cmake)** file.
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
