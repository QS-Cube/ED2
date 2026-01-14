#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([QS3], [2.0.0],[qsss.inquiry{at}gmail.com])
AC_CONFIG_SRCDIR([source/main.f90])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([foreign])

# Checks for compilers
AC_PROG_CC

FCFLAGS_PRESERVE=$FCFLAGS
AC_LANG(Fortran)
AC_PROG_FC(ifort gfortran)
FCFLAGS=$FCFLAGS_PRESERVE

## FCFLAGS:
case "$FC" in
  gfortran*)
    test -n "$FCFLAGS" || FCFLAGS="-fopenmp -Ofast"
    ;;
  ifort)
    test -n "$FCFLAGS" || FCFLAGS="-O3 -ipo -no-prec-div -fp-model fast=2 -xHost -parallel -qopenmp"
    ;;
esac

## LAPACK / BLAS
AC_ARG_WITH(lapack,[AS_HELP_STRING([--with-lapack=ARG],[LAPACK library.
                                     ARG must be one of
                                     lapack (default),
                                     mkl (Intel MKL).])])

case "$with_lapack" in
  lapack | yes | "")
    BLAS_FOUND=no

    AC_CHECK_LIB(openblas, dsymv,
      [AC_MSG_NOTICE([BLAS... found in -lopenblas])
       BLAS_LIBS="-lopenblas"
       BLAS_FOUND=yes],
      [AC_CHECK_LIB(blas, dsymv,
        [AC_MSG_NOTICE([BLAS... found in -lblas])
         BLAS_LIBS="-lblas"
         BLAS_FOUND=yes],
        [AC_CHECK_LIB(f77blas, dsymv,
          [AC_MSG_NOTICE([BLAS... found in -lf77blas])
           BLAS_LIBS="-lf77blas"
           BLAS_FOUND=yes],
          [BLAS_FOUND=no])])])

    # MKL fallback (only when FC=ifort)
    if test "x$BLAS_FOUND" = "xno" && echo "$FC" | grep -q '^ifort'; then
      AC_MSG_NOTICE([BLAS... not found; falling back to Intel MKL (-qmkl=parallel)])
      LIBS="$LIBS -qmkl=parallel"
      BLAS_FOUND=yes
      BLAS_LIBS=""
    fi

    if test "x$BLAS_FOUND" = "xno"; then
      AC_MSG_ERROR([BLAS library not found.
Try loading a BLAS module or re-run configure with explicit LIBS/LDFLAGS.])
    fi

    # LAPACK
    LAPACK_FOUND=no
    AC_CHECK_LIB(lapack, dsyevx,
      [AC_MSG_NOTICE([LAPACK... found in -llapack])
       LAPACK_LIBS="-llapack"
       LAPACK_FOUND=yes],
      [LAPACK_FOUND=no])

    # Assume MKL provides LAPACK if -qmkl=parallel is active
    if test "x$LAPACK_FOUND" = "xno" && echo "$LIBS" | grep -q -- '-qmkl=parallel'; then
      AC_MSG_NOTICE([LAPACK... assuming MKL provides LAPACK via -qmkl=parallel])
      LAPACK_FOUND=yes
      LAPACK_LIBS=""
    fi

    if test "x$LAPACK_FOUND" = "xno"; then
      AC_MSG_ERROR([LAPACK library not found.
Try loading a LAPACK module or re-run configure with explicit LIBS/LDFLAGS.])
    fi

    LIBS="$LAPACK_LIBS $BLAS_LIBS $LIBS"
    ;;
  mkl)
    case "$FC" in
      ifort)
        AC_MSG_NOTICE([Using Intel MKL via -qmkl=parallel])
        LIBS="$LIBS -qmkl=parallel"
        ;;
      *)
        AC_MSG_ERROR([--with-lapack=mkl requires Intel ifort compiler])
        ;;
    esac
    ;;
  *)
    AC_MSG_ERROR([Unknown LAPACK option: $with_lapack])
    ;;
esac

AC_CONFIG_FILES([Makefile
                 source/Makefile])
AC_OUTPUT
