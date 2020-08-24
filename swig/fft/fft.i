/* fft.i */
%module fft
%{
#define SWIG_FILE_WITH_INIT
#include "fft.h"
%}

%include "fft.h"
%include "carrays.i"
%array_functions(float, floatArray);
