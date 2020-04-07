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

void jmi_ad_divide_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]);

void jmi_ad_divide_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]);

void jmi_ad_divide(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]);

void jmi_ad_sqrt_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sqrt_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sqrt(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_asin_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_asin_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_asin(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_acos_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_acos_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_acos(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_atan2_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_atan2_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_atan2(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_pow_function(const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]);

void jmi_ad_pow_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]);

void jmi_ad_pow(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t y, jmi_real_t dx, jmi_real_t dy, jmi_real_t *v, jmi_real_t *d, const char msg[]);

void jmi_ad_exp_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_exp_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_exp(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_log_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_log_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_log(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_log10_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_log10_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_log10(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sinh_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sinh_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sinh(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_cosh_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_cosh_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_cosh(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_tan_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_tan_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_tan(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sin_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sin_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_sin(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_cos_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_cos_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_cos(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_atan_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_atan_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_atan(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_tanh_function(const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_tanh_equation(jmi_t *jmi, jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);

void jmi_ad_tanh(jmi_t *jmi, const char func_name[], jmi_real_t x, jmi_real_t dx, jmi_real_t* v, jmi_real_t* d, const char msg[]);
