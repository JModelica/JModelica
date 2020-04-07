/*
    Copyright (C) 2016 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include "jmi.h"
#include "jmi_math.h"
#include "jmi_math_ad.h"
#include <float.h>

/*
* FDotDivExp / FSqrtExp / FAcosExp / FAsinExp / FAtan2Exp / FDotPowExp /
* FLogExp / FLog10Exp / FSinhExp / FCoshExp -> Use the AD callbacks defined below
*/

void jmi_ad_divide_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    jmi_ad_divide(NULL, func_name, x, y, dx, dy, v, d, msg);
}

void jmi_ad_divide_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    jmi_ad_divide(jmi, NULL, x, y, dx, dy, v, d, msg);
}

void jmi_ad_divide(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    jmi_real_t num = 0.0;
    *v = jmi_divide(jmi, func_name, x, y, msg);
    if (dx == 0.0) {
        num = (-x * dy);
    } else if (dy == 0.0) {
        num = (dx*y);
    } else if (dx == 0.0 && dy == 0.0) {
        *d = 0.0;
        return;
    } else {
        num = (dx*y - x * dy);
    }
    
    *d = jmi_divide(jmi, func_name, num, (y*y), msg);

    if (*d != *d) {
        if (JMI_ABS(y) > DBL_MAX && num == num) {
            *d = 0.0;
        }
    }
}

void jmi_ad_sqrt_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sqrt(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_sqrt_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sqrt(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_sqrt(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_sqrt(jmi, func_name, x, msg);
    
    if (x <= 0.0) {
        *d = 0.0;
    } else {
        *d = jmi_divide(jmi, func_name, dx, ( 2 * (*v)), msg);
    }
}


void jmi_ad_asin_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_asin(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_asin_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_asin(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_asin(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_asin(jmi, func_name, x, msg);
    
    if (x <= -1.0 || x >= 1.0) {
        *d = 0.0;
    } else {
        *d = jmi_divide(jmi, func_name, dx, sqrt(1 - x*x), msg);
    }
}

void jmi_ad_acos_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_acos(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_acos_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_acos(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_acos(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_acos(jmi, func_name, x, msg);
    
    if (x <= -1.0 || x >= 1.0) {
        *d = 0.0;
    } else {
        *d = jmi_divide(jmi, func_name, -dx, sqrt(1 - x*x), msg);
    }
}


void jmi_ad_atan2_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_atan2(NULL, func_name, x, y, dx, dy, v, d, msg);
}

void jmi_ad_atan2_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_atan2(jmi, NULL, x, y, dx, dy, v, d, msg);
}

void jmi_ad_atan2(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_atan2(jmi, func_name, x, y, msg);
    
    if (x == 0 && y == 0) {
        *d = 0.0;
    } else {
        *d = jmi_divide(jmi, func_name, (dx*y - x*dy), (x*x + y*y), msg);
    }
}

void jmi_ad_pow_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    jmi_ad_pow(NULL, func_name, x, y, dx, dy, v, d, msg);
}

void jmi_ad_pow_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    jmi_ad_pow(jmi, NULL, x, y, dx, dy, v, d, msg);
}

void jmi_ad_pow(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]) {
    *v = jmi_pow(jmi, func_name, x, y, msg);
    
    if (x == 0.0) {
        if (y == 1.0 ) {
            *d = dx;
        } else {
            *d = 0.0;
        }
    } else {
        *d = *v * (dx * jmi_divide(jmi, func_name, y, x, msg) + dy*jmi_log(jmi, func_name, jmi_abs(x), msg));
    }
}

void jmi_ad_exp_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_exp(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_exp_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_exp(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_exp(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_exp(jmi, func_name, x, msg);

    if (dx == 0.0) {
        *d = 0.0;
    } else {
        *d = dx * (*v);
    }
}

void jmi_ad_log_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_log(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_log_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_log(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_log(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_log(jmi, func_name, x, msg);
    *d = jmi_divide(jmi, func_name, dx, x, msg);
}

void jmi_ad_log10_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_log10(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_log10_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_log10(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_log10(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_log10(jmi, func_name, x, msg);
    *d = jmi_divide(jmi, func_name, dx * jmi_log10(jmi, func_name, exp(1.0), msg), x, msg);
}

void jmi_ad_sinh_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sinh(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_sinh_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sinh(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_sinh(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_sinh(jmi, func_name, x, msg);
    *d = dx * jmi_cosh(jmi, func_name, x, msg);
}

void jmi_ad_cosh_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_cosh(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_cosh_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_cosh(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_cosh(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_cosh(jmi, func_name, x, msg);
    *d = dx * jmi_sinh(jmi, func_name, x, msg);
}

void jmi_ad_tan_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_tan(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_tan_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_tan(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_tan(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_tan(jmi, func_name, x, msg);
    *d = jmi_divide(jmi, func_name, dx, (cos(x)*cos(x)), msg);
}

void jmi_ad_sin_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sin(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_sin_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_sin(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_sin(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_sin(jmi, func_name, x, msg);
    *d = dx * cos(x);
}

void jmi_ad_cos_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_cos(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_cos_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_cos(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_cos(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_cos(jmi, func_name, x, msg);
    *d = dx * -sin(x);
}

void jmi_ad_atan_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_atan(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_atan_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_atan(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_atan(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_atan(jmi, func_name, x, msg);
    *d = jmi_divide(jmi, func_name, dx, (1 + x*x), msg);
}

void jmi_ad_tanh_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_tanh(NULL, func_name, x, dx, v, d, msg);
}

void jmi_ad_tanh_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    jmi_ad_tanh(jmi, NULL, x, dx, v, d, msg);
}

void jmi_ad_tanh(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]) {
    *v = jmi_tanh(jmi, func_name, x, msg);
    *d = dx * (1 - (*v) * (*v));
}
