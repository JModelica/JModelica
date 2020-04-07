#include "useModelicaError.h"
#include <ModelicaUtilities.h>

double func_with_ModelicaError(double x) {
    if (x > 2.0)
    	ModelicaFormatError("X is too high: %f.", x);
    if (x > 1.0)
    	ModelicaFormatMessage("X is a bit high: %f.", x);
    return x;
}
