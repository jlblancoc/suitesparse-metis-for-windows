if (MKL_INCLUDE_DIRS AND MKL_LIBRARIES AND MKL_INTERFACE_LIBRARY AND
    MKL_SEQUENTIAL_LAYER_LIBRARY AND MKL_CORE_LIBRARY)
  set (MKL_FIND_QUIETLY TRUE)
endif()
if(NOT MKL_SHARED_LIBS)
  if(WIN32)
      if(CMAKE_SIZEOF_VOID_P EQUAL 8)
          set(SEQ_LIB "mkl_sequential.lib")
          set(INT_LIB  "mkl_intel_lp64.lib")
          set(COR_LIB "mkl_core.lib")
      else()
          set(SEQ_LIB "mkl_sequential.lib")
          set(INT_LIB  "mkl_intel_c.lib")
          set(COR_LIB "mkl_core.lib")
      endif()
  else()
      set(SEQ_LIB "libmkl_sequential.a")
      set(INT_LIB "libmkl_intel_lp64.a")
      set(COR_LIB "libmkl_core.a")
  endif()
else()
   if(WIN32)
      if(CMAKE_SIZEOF_VOID_P EQUAL 8)
         set(SEQ_LIB "mkl_sequential_dll.lib")
         set(INT_LIB "mkl_intel_lp64_dll.lib")
         set(COR_LIB "mkl_core_dll.lib")
      else()
         set(SEQ_LIB "mkl_sequential_dll.lib")
	     set(INT_LIB "mkl_intel_c_dll.lib")
	     set(COR_LIB "mkl_core_dll.lib")
      endif()
   else()
      set(SEQ_LIB "libmkl_sequential.so")
      set(INT_LIB "libmkl_intel_lp64.so")
      set(COR_LIB "libmkl_core.so")
   endif()
endif()
find_path(MKL_INCLUDE_DIR NAMES mkl.h HINTS $ENV{MKLROOT}/include)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    find_library(MKL_SEQUENTIAL_LAYER_LIBRARY
                 NAMES ${SEQ_LIB}
                 PATHS $ENV{MKLROOT}/lib
                       $ENV{MKLROOT}/lib/intel64
                       $ENV{INTEL}/mkl/lib/intel64
                 NO_DEFAULT_PATH)

    find_library(MKL_CORE_LIBRARY
                 NAMES ${COR_LIB}
                 PATHS $ENV{MKLROOT}/lib
                       $ENV{MKLROOT}/lib/intel64
                       $ENV{INTEL}/mkl/lib/intel64
                 NO_DEFAULT_PATH)

     find_library(MKL_INTERFACE_LIBRARY
                 NAMES ${INT_LIB}
                 PATHS $ENV{MKLROOT}/lib
                       $ENV{MKLROOT}/lib/intel64
                       $ENV{INTEL}/mkl/lib/intel64
                 NO_DEFAULT_PATH)

else()
    find_library(MKL_SEQUENTIAL_LAYER_LIBRARY
                 NAMES ${SEQ_LIB}
                 PATHS $ENV{MKLROOT}/lib
                       $ENV{MKLROOT}/lib/ia32
                       $ENV{INTEL}/mkl/lib/ia32
                 NO_DEFAULT_PATH)

    find_library(MKL_CORE_LIBRARY
                 NAMES ${COR_LIB}
                 PATHS $ENV{MKLROOT}/lib
                       $ENV{MKLROOT}/lib/ia32
                       $ENV{INTEL}/mkl/lib/ia32
                 NO_DEFAULT_PATH)

     find_library(MKL_INTERFACE_LIBRARY
                 NAMES ${INT_LIB}
                 PATHS $ENV{MKLROOT}/lib
                       $ENV{MKLROOT}/lib/ia32
                       $ENV{INTEL}/mkl/lib/ia32
                 NO_DEFAULT_PATH)
endif()
set(MKL_INCLUDE_DIRS ${MKL_INCLUDE_DIR})
set(MKL_LIBRARIES ${MKL_SEQUENTIAL_LAYER_LIBRARY} ${MKL_INTERFACE_LIBRARY} ${MKL_CORE_LIBRARY})

if (MKL_INCLUDE_DIR AND
    MKL_INTERFACE_LIBRARY AND
    MKL_SEQUENTIAL_LAYER_LIBRARY AND
    MKL_CORE_LIBRARY)

else()

  set(MKL_INCLUDE_DIRS "")
  set(MKL_LIBRARIES "")
  set(MKL_SEQUENTIAL_LAYER_LIBRARY "")
  set(MKL_CORE_LIBRARY "")

endif()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(MKL DEFAULT_MSG MKL_LIBRARIES MKL_INCLUDE_DIRS  MKL_SEQUENTIAL_LAYER_LIBRARY MKL_CORE_LIBRARY MKL_INTERFACE_LIBRARY)

MARK_AS_ADVANCED(MKL_INCLUDE_DIRS MKL_LIBRARIES MKL_SEQUENTIAL_LAYER_LIBRARY MKL_CORE_LIBRARY MKL_INTERFACE_LIBRARY)
