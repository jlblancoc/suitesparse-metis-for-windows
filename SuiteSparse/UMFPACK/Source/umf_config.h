//------------------------------------------------------------------------------
// UMFPACK/Source/umf_config.h: compile-time configuration of UMFPACK
//------------------------------------------------------------------------------

// UMFPACK, Copyright (c) 2005-2023, Timothy A. Davis, All Rights Reserved.
// SPDX-License-Identifier: GPL-2.0+

//------------------------------------------------------------------------------

/*
    This file controls the compile-time configuration of UMFPACK.
    All of these options, except for the timer, are for accessing the BLAS.

	-DNRECIPROCAL

	    This option controls a tradeoff between speed and accuracy.  Using
	    -DNRECIPROCAL can lead to more accurate results, but with perhaps
	    some cost in performance, particularly if floating-point division
	    is much more costly than floating-point multiplication.

	    This option determines the method used to scale the pivot column.
	    If set, or if the absolute value of the pivot is < 1e-12 (or is a
	    NaN), then the pivot column is divided by the pivot value.
	    Otherwise, the reciprocal of the pivot value is computed, and the
	    pivot column is multiplied by (1/pivot).  Multiplying by the
	    reciprocal can be slightly less accurate than dividing by the
	    pivot, but it is often faster.  See umf_scale.c.

	    This has a small effect on the performance of UMFPACK, at least on
	    a Pentium 4M.  It may have a larger effect on other architectures
	    where floating-point division is much more costly than floating-
	    point multiplication.  The RS 6000 is one such example.

	    By default, the method chosen is to multiply by the reciprocal
	    (sacrificing accuracy for speed), except when compiling UMFPACK
	    as a built-in routine in MATLAB, or when gcc is being used.

	    When MATHWORKS is defined, -DNRECIPROCAL is forced on, and the pivot
	    column is divided by the pivot value.  The only way of using the
	    other method in this case is to edit this file.

	    If -DNRECIPROCAL is enabled, then the row scaling factors are always
	    applied by dividing each row by the scale factor, rather than
	    multiplying by the reciprocal.  If -DNRECIPROCAL is not enabled
	    (the default case), then the scale factors are normally applied by
	    multiplying by the reciprocal.  If, however, the smallest scale
	    factor is tiny, then the scale factors are applied via division.

	-DNO_DIVIDE_BY_ZERO

	    If the pivot is zero, and this flag is set, then no divide-by-zero
	    occurs.

    The following options are controlled by umf_internal.h:

	-DMATLAB_MEX_FILE

	    This flag is turned on when compiling the umfpack mexFunction for
	    use in MATLAB.  The -DNRECIPROCAL flag is forced on (more accurate,
	    slightly slower).  The umfpack mexFunction always returns
	    L*U = P*(R\A)*Q.

	-DMATHWORKS

	    This flag is turned on when compiling umfpack as a built-in routine
	    in MATLAB.  The -DNRECIPROCAL flag is forced on.

	-DNDEBUG

	    Debugging mode (if NDEBUG is not defined).  The default, of course,
	    is no debugging.  Turning on debugging takes some work (see below).
	    If you do not edit this file, then debugging is turned off anyway,
	    regardless of whether or not -DNDEBUG is specified in your compiler
	    options.
*/

/* ========================================================================== */
/* === AMD configuration ==================================================== */
/* ========================================================================== */

#define PRINTF(params) SUITESPARSE_PRINTF(params)

/* ========================================================================== */
/* === reciprocal option ==================================================== */
/* ========================================================================== */

/* Force the definition NRECIPROCAL when MATHWORKS or MATLAB_MEX_FILE
 * are defined.  Do not multiply by the reciprocal in those cases. */

#ifndef NRECIPROCAL
#if defined (MATHWORKS) || defined (MATLAB_MEX_FILE)
#define NRECIPROCAL
#endif
#endif

/* ========================================================================== */
/* === Microsoft Windows configuration ====================================== */
/* ========================================================================== */

#if defined (UMF_WINDOWS) || defined (UMF_MINGW)
/* Windows isn't Unix.  Profound. */
#define NPOSIX
#endif

/* ========================================================================== */
/* === 0-based or 1-based printing ========================================== */
/* ========================================================================== */

#if defined (MATLAB_MEX_FILE) && defined (NDEBUG)
/* In MATLAB, matrices are 1-based to the user, but 0-based internally. */
/* One is added to all row and column indices when printing matrices */
/* for the MATLAB user.  The +1 shift is turned off when debugging. */
#define INDEX(i) ((i)+1)
#else
/* In ANSI C, matrices are 0-based and indices are reported as such. */
/* This mode is also used for debug mode, and if MATHWORKS is defined rather */
/* than MATLAB_MEX_FILE. */
#define INDEX(i) (i)
#endif


/* ========================================================================== */
/* === BLAS ================================================================= */
/* ========================================================================== */

/* -------------------------------------------------------------------------- */
/* DGEMM */
/* -------------------------------------------------------------------------- */

/* C = C - A*B', where:
 * A is m-by-k with leading dimension ldac
 * B is k-by-n with leading dimension ldb
 * C is m-by-n with leading dimension ldac */
#ifdef COMPLEX
#define BLAS_GEMM(m,n,k,A,B,ldb,C,ldac,ok) \
{ \
    double alpha [2] = {-1,0}, beta [2] = {1,0} ; \
    SUITESPARSE_BLAS_zgemm ("N", "T", m, n, k, alpha, A, ldac, B, ldb, \
        beta, C, ldac, ok) ; \
}
#else
#define BLAS_GEMM(m,n,k,A,B,ldb,C,ldac,ok) \
{ \
    double alpha = -1, beta = 1 ; \
    SUITESPARSE_BLAS_dgemm ("N", "T", m, n, k, &alpha, A, ldac, B, ldb, \
        &beta, C, ldac, ok) ; \
}
#endif


/* -------------------------------------------------------------------------- */
/* GER */
/* -------------------------------------------------------------------------- */

/* A = A - x*y', where:
 * A is m-by-n with leading dimension d
   x is a column vector with stride 1
   y is a column vector with stride 1 */
#ifdef COMPLEX
#define BLAS_GER(m,n,x,y,A,d,ok) \
{ \
    double alpha [2] = {-1,0} ; \
    SUITESPARSE_BLAS_zgeru (m, n, alpha, x, 1, y, 1, A, d, ok) ; \
}
#else
#define BLAS_GER(m,n,x,y,A,d,ok) \
{ \
    double alpha = -1 ; \
    SUITESPARSE_BLAS_dger (m, n, &alpha, x, 1, y, 1, A, d, ok) ; \
}
#endif


/* -------------------------------------------------------------------------- */
/* GEMV */
/* -------------------------------------------------------------------------- */

/* y = y - A*x, where A is m-by-n with leading dimension d,
   x is a column vector with stride 1
   y is a column vector with stride 1 */
#ifdef COMPLEX
#define BLAS_GEMV(m,n,A,x,y,d,ok) \
{ \
    double alpha [2] = {-1,0}, beta [2] = {1,0} ; \
    SUITESPARSE_BLAS_zgemv ("N", m, n, alpha, A, d, x, 1, beta, y, 1, ok) ; \
}
#else
#define BLAS_GEMV(m,n,A,x,y,d,ok) \
{ \
    double alpha = -1, beta = 1 ; \
    SUITESPARSE_BLAS_dgemv ("N", m, n, &alpha, A, d, x, 1, &beta, y, 1, ok) ; \
}
#endif


/* -------------------------------------------------------------------------- */
/* TRSV */
/* -------------------------------------------------------------------------- */

/* solve Lx=b, where:
 * B is a column vector (m-by-1) with leading dimension d
 * A is m-by-m with leading dimension d */
#ifdef COMPLEX
#define BLAS_TRSV(m,A,b,d,ok) \
{ \
    SUITESPARSE_BLAS_ztrsv ("L", "N", "U", m, A, d, b, 1, ok) ; \
}
#else
#define BLAS_TRSV(m,A,b,d,ok) \
{ \
    SUITESPARSE_BLAS_dtrsv ("L", "N", "U", m, A, d, b, 1, ok) ; \
}
#endif


/* -------------------------------------------------------------------------- */
/* TRSM */
/* -------------------------------------------------------------------------- */

/* solve XL'=B where:
 * B is m-by-n with leading dimension ldb
 * A is n-by-n with leading dimension lda */
#ifdef COMPLEX
#define BLAS_TRSM_RIGHT(m,n,A,lda,B,ldb,ok) \
{ \
    double alpha [2] = {1,0} ; \
    SUITESPARSE_BLAS_ztrsm ("R", "L", "T", "U", m, n, alpha, A, \
        lda, B, ldb, ok) ; \
}
#else
#define BLAS_TRSM_RIGHT(m,n,A,lda,B,ldb,ok) \
{ \
    double alpha = 1 ; \
    SUITESPARSE_BLAS_dtrsm ("R", "L", "T", "U", m, n, &alpha, A, \
        lda, B, ldb, ok) ; \
}
#endif


/* -------------------------------------------------------------------------- */
/* SCAL */
/* -------------------------------------------------------------------------- */

/* x = s*x, where x is a stride-1 vector of length n */
#ifdef COMPLEX
#define BLAS_SCAL(n,s,x,ok) \
{ \
    double alpha [2] ; \
    alpha [0] = REAL_COMPONENT (s) ; \
    alpha [1] = IMAG_COMPONENT (s) ; \
    SUITESPARSE_BLAS_zscal (n, alpha, x, 1, ok) ; \
}
#else
#define BLAS_SCAL(n,s,x,ok) \
{ \
    double alpha = REAL_COMPONENT (s) ; \
    SUITESPARSE_BLAS_dscal (n, &alpha, x, 1, ok) ; \
}
#endif
