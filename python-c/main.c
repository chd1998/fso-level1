//main.c
#include <Python.h>
#include "great_module.h"

int main(int argc, char *argv[]) {
    PyObject *tuple;
    Py_Initialize();
    initgreat_module();
    printf("%s\n",PyString_AsString(
                great_function(
                    PyString_FromString("hello"),
                    PyInt_FromLong(1)
                )
            ));
    tuple = Py_BuildValue("(iis)", 1, 2, "three");
    printf("%d\n",PyInt_AsLong(
                great_function(
                    tuple,
                    PyInt_FromLong(1)
                )
            ));
    printf("%s\n",PyString_AsString(
                great_function(
                    tuple,
                    PyInt_FromLong(2)
                )
            ));
    Py_Finalize();
}