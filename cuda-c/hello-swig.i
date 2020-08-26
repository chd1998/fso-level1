%module helloswig

%{
#include "hello-swig.h"
%}

%include "hello-swig.h"
int hello();
