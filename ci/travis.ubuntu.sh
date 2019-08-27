#!/bin/bash
set -e
set -x

uname -a

if [ "$LAPACK_DIR" != "" ]; then
	LAPACK_DIR_FLAG="-DLAPACK_DIR=${LAPACK_DIR}"
fi
cmake -H. -B_build_${TOOLCHAIN} -DCMAKE_INSTALL_PREFIX=${PWD}/_install_${TOOLCHAIN} -DCMAKE_TOOLCHAIN_FILE="${PWD}/ci/toolchains/${TOOLCHAIN}.cmake" -DBUILD_METIS=${BUILD_METIS} ${LAPACK_DIR_FLAG}
cmake --build _build_${TOOLCHAIN} --target install -- -j4

if [ "$RUN_TESTS" = true ]; then
	case "$TOOLCHAIN" in linux-mingw*)
		echo "copy runtime libraries needed for tests into build directory"
		cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll /usr/lib/gcc/x86_64-w64-mingw32/7.3-win32/{libstdc++-6.dll,libgcc_s_seh-1.dll} _build_${TOOLCHAIN}
	esac
	CTEST_OUTPUT_ON_FAILURE=1 cmake --build _build_${TOOLCHAIN} --target test
fi

# get the SuiteSparse-config.cmake directory expanding the version number wildcard
SuiteSparse_DIR=$(echo "${PWD}/_install_${TOOLCHAIN}/lib/cmake/suitesparse-"*/)

echo "build example-projects/cholmod"
cmake -Hexample-projects/cholmod -B_build_example_cholmod_${TOOLCHAIN} -DSuiteSparse_DIR=${SuiteSparse_DIR} -DCMAKE_TOOLCHAIN_FILE="${PWD}/ci/toolchains/${TOOLCHAIN}.cmake" ${LAPACK_DIR_FLAG}
cmake --build _build_example_cholmod_${TOOLCHAIN}

echo "build example-projects/spqr"
cmake -Hexample-projects/spqr -B_build_example_spqr_${TOOLCHAIN} -DSuiteSparse_DIR=${SuiteSparse_DIR} -DCMAKE_TOOLCHAIN_FILE="${PWD}/ci/toolchains/${TOOLCHAIN}.cmake" ${LAPACK_DIR_FLAG}
cmake --build _build_example_cholmod_${TOOLCHAIN}
