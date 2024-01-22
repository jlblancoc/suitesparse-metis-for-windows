# Unreleased
- Update SuiteSparse to 7.5.1 with embedded Metis [#125](https://github.com/jlblancoc/suitesparse-metis-for-windows/pull/125)
  - fixes Metis based segmentation fault [#123](https://github.com/jlblancoc/suitesparse-metis-for-windows/issues/123)
  - remove `SuiteSparse::metis` target as Metis is now a private dependency of `CHOLMOD` module
  - remove option `METIS_DIR`
  - always compile `SuiteSparse_config` with `-DNTIMER` disabling tic-toc support
  - compile `CXSparse` without complex support
  - remove SourceWrappers for `CHOLMOD` and `CXSparse` modules

# unreleased
- More generic `OpenBLAS` linkage [#122](https://github.com/jlblancoc/suitesparse-metis-for-windows/pull/122)

# Release 1.8.0: October 25th, 2023
- Increase minimum required CMake version to v3.5 to prevent deprecation warnings [#117](https://github.com/jlblancoc/suitesparse-metis-for-windows/issues/117).
- Add option `METIS_IDXTYPEWIDTH` with default `64` to override the index type used for `metis.h` [#116](https://github.com/jlblancoc/suitesparse-metis-for-windows/issues/116).

# Release 1.7.0: December 21st, 2022
- If `BUILD_METIS=ON` extract and provide `SuiteSparse_METIS_VERSION` in generated config [#109](https://github.com/jlblancoc/suitesparse-metis-for-windows/issues/109)
- Fix `METIS_DIR` not used for `add_subdirectory()` call [#110](https://github.com/jlblancoc/suitesparse-metis-for-windows/issues/110)
- Fix `@WITH_OPENBLAS` substitution in generated cmake-config file [#113](https://github.com/jlblancoc/suitesparse-metis-for-windows/pull/113)

# Release 1.6.1: December 5th, 2022
- update copy of HunterGate to v0.9.2 to fix Hunter build [#108](https://github.com/jlblancoc/suitesparse-metis-for-windows/pull/108)

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