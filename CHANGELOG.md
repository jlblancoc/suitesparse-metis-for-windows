# Release 1.6.0: December 3rd, 2022
- Add option WITH_OPENBLAS to replace generic BLAS and LAPACK (See README for details)
- Hunter: update to v0.24.9 for OpenBLAS v0.3.21
- Options to use TBB and to build shared libraries
- Update all cmake commands to lowercase
- Automatically set the LAPACK_DIR in Windows
- Use Hunter by default in Windows


# Release 1.5.0: August 30th, 2019
- New bundled versions: SuiteSparse 5.4.0 + Metis 5.1.0
- fix windows shared install using CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS
- Use C++11 by default.
- Allow user to override install prefix
- Deletion of FindSuiteSparse.cmake module. All is not based on "modern" CMake exported targets. Refer to example CMake files [here](https://github.com/jlblancoc/suitesparse-metis-for-windows/tree/master/example-projects).