/*
 * Copyright 1997, Regents of the University of Minnesota
 *
 * metis.h
 *
 * This file includes all necessary header files
 *
 * Started 8/27/94
 * George
 *
 * $Id: metislib.h 10655 2011-08-02 17:38:11Z benjamin $
 */

#ifndef _LIBMETIS_METISLIB_H_
#define _LIBMETIS_METISLIB_H_

#include <GKlib.h>

#if defined(ENABLE_OPENMP)
  #include <omp.h>
#endif


#include <metis.h>
#include <rename.h>
#include <gklib_defs.h>

#include <defs.h>
#include <struct.h>
#include <macros.h>
#include <proto.h>

#include <math.h>  // rint()
#if defined(_MSC_VER) && (_MSC_VER < 1800)
#define rint(x) ((int)((x)+0.5))  
#endif

#endif
