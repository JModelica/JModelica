/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


package CCodeGenExternalTests

model ExtStmtInclude1
    function extFunc
         external "C" annotation(Include="#include \"extFunc.h\"");
    end extFunc;
    algorithm
        extFunc();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExtStmtInclude1",
            description="Test that include statement is inserted properly.",
            variability_propagation=false,
            template="$external_func_includes$",
            generatedCode="
#include \"extFunc.h\"
")})));
end ExtStmtInclude1;

model ExtStmtInclude2
    function extFunc1
         external "C" annotation(Include="#include \"extFunc1.h\"");
    end extFunc1;
    function extFunc2
        external "C" annotation(Include="#include \"extFunc2.h\"");
    end extFunc2;
    algorithm
        extFunc1();
        extFunc2();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExtStmtInclude2",
            description="Test that include statements are inserted properly.",
            variability_propagation=false,
            template="$external_func_includes$",
            generatedCode="
#include \"extFunc1.h\"
#include \"extFunc2.h\"
")})));
end ExtStmtInclude2;

model SimpleExternal1
    Real a_in=1;
    Real b_out;
    function f
        input Real a;
        output Real b;
        external;
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal1",
            description="External C function (undeclared), one scalar input, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal1_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal1_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternal1_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double f(double);
    b_v = f(a_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal1_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_SimpleExternal1_f_def0(a_v, &b_v);
    return b_v;
}


")})));
end SimpleExternal1;

model SimpleExternal2
    Real a_in=1;
    Real b_in=2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external "C";
    end f;
    equation
        c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal2",
            description="External C function (undeclared), two scalar inputs, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal2_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal2_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternal2_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    extern double f(double, double);
    c_v = f(a_v, b_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal2_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternal2_f_def0(a_v, b_v, &c_v);
    return c_v;
}


")})));
end SimpleExternal2;

model SimpleExternal3
    Real a_in=1;
    Real b_out;
    function f
        input Real a;
        output Real b;
        external b = my_f(a);
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal3",
            description="External C function (declared with return), one scalar input, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal3_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal3_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternal3_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double my_f(double);
    b_v = my_f(a_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal3_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_SimpleExternal3_f_def0(a_v, &b_v);
    return b_v;
}


")})));
end SimpleExternal3;

model SimpleExternal4
    Real a_in=1;
    Real b_out;
    function f
        input Real a;
        output Real b;
        external my_f(a, b);
    end f;
    equation
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal4",
            description="External C function (declared without return), one scalar input, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal4_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal4_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternal4_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern void my_f(double, double*);
    my_f(a_v, &b_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal4_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_SimpleExternal4_f_def0(a_v, &b_v);
    return b_v;
}


")})));
end SimpleExternal4;

model SimpleExternal5
    Real a_in=1;
    function f
        input Real a;
        external;
    end f;
    equation
        f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal5",
            description="External C function (undeclared), scalar input, no output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal5_f_def0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternal5_f_def0(jmi_real_t a_v) {
    JMI_DYNAMIC_INIT()
    extern void f(double);
    f(a_v);
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end SimpleExternal5;

model SimpleExternal6
    Real a_in=1;
    function f
        input Real a;
        external my_f(a);
    end f;
    equation
        f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal6",
            description="External C function (declared), scalar input, no output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal6_f_def0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternal6_f_def0(jmi_real_t a_v) {
    JMI_DYNAMIC_INIT()
    extern void my_f(double);
    my_f(a_v);
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end SimpleExternal6;

model SimpleExternal7
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external my_f(a,c,b);
    end f;
    equation
        c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal7",
            description="External C function (declared without return), two scalar inputs, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal7_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal7_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternal7_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    extern void my_f(double, double*, double);
    my_f(a_v, &c_v, b_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal7_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternal7_f_def0(a_v, b_v, &c_v);
    return c_v;
}


")})));
end SimpleExternal7;

model SimpleExternal8
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    Real d_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        output Real d;
        external my_f(a,c,b,d);
    end f;
    equation
        (c_out, d_out) = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal8",
            description="External C function (declared without return), two scalar inputs, two scalar outputs.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal8_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal8_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternal8_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    JMI_DEF(REA, d_v)
    extern void my_f(double, double*, double, double*);
    my_f(a_v, &c_v, b_v, &d_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal8_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternal8_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}


")})));
end SimpleExternal8;

model SimpleExternal9
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    Real d_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        output Real d;
        external d = my_f(a,b,c);
    end f;
    equation
        (c_out, d_out) = f(a_in, b_in); 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal9",
            description="External C function (declared with return), two scalar inputs, two scalar outputs (one in return stmt, one in fcn stmt).",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal9_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal9_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternal9_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    JMI_DEF(REA, d_v)
    extern double my_f(double, double, double*);
    d_v = my_f(a_v, b_v, &c_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal9_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternal9_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}


")})));
end SimpleExternal9;

model SimpleExternal10
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    Real d_out;
    Real e_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        output Real d;
        output Real e;
        external d = my_f(a,c,b,e);
    end f;
    equation
        (c_out, d_out, e_out) = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal10",
            description="External C function (declared with return), two scalar inputs, three scalar outputs (one in return stmt, two in fcn stmt).",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal10_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o, jmi_real_t* e_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal10_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternal10_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o, jmi_real_t* e_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    JMI_DEF(REA, d_v)
    JMI_DEF(REA, e_v)
    extern double my_f(double, double*, double, double*);
    d_v = my_f(a_v, &c_v, b_v, &e_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_RET(GEN, e_o, e_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal10_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternal10_f_def0(a_v, b_v, &c_v, NULL, NULL);
    return c_v;
}


")})));
end SimpleExternal10;

model SimpleExternal11
    function f
        output String s;
        external;
    end f;
    function strlen
        input String s;
        output Integer n;
        external;
    end strlen;
    function fw
        input Real x;
        output Real y = x + strlen(f());
        algorithm
        annotation(Inline=false);
    end fw;
    Real y = fw(time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal11",
            description="External C function returning string",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternal11_fw_def0(jmi_real_t x_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal11_fw_exp0(jmi_real_t x_v);
void func_CCodeGenExternalTests_SimpleExternal11_strlen_def1(jmi_string_t s_v, jmi_real_t* n_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternal11_strlen_exp1(jmi_string_t s_v);
void func_CCodeGenExternalTests_SimpleExternal11_f_def2(jmi_string_t* s_o);
jmi_string_t func_CCodeGenExternalTests_SimpleExternal11_f_exp2();

void func_CCodeGenExternalTests_SimpleExternal11_fw_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(STR, tmp_1)
    tmp_1 = func_CCodeGenExternalTests_SimpleExternal11_f_exp2();
    y_v = x_v + func_CCodeGenExternalTests_SimpleExternal11_strlen_exp1(tmp_1);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal11_fw_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenExternalTests_SimpleExternal11_fw_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenExternalTests_SimpleExternal11_strlen_def1(jmi_string_t s_v, jmi_real_t* n_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, n_v)
    extern int strlen(const char*);
    n_v = strlen(s_v);
    JMI_RET(GEN, n_o, n_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternal11_strlen_exp1(jmi_string_t s_v) {
    JMI_DEF(INT, n_v)
    func_CCodeGenExternalTests_SimpleExternal11_strlen_def1(s_v, &n_v);
    return n_v;
}

void func_CCodeGenExternalTests_SimpleExternal11_f_def2(jmi_string_t* s_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(STR, s_v)
    extern const char* f();
    JMI_INI(STR, s_v)
    s_v = f();
    JMI_RET(STR, s_o, s_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_string_t func_CCodeGenExternalTests_SimpleExternal11_f_exp2() {
    JMI_DEF(STR, s_v)
    func_CCodeGenExternalTests_SimpleExternal11_f_def2(&s_v);
    return s_v;
}


")})));
end SimpleExternal11;

model IntegerExternal1
    Integer a_in=1;
    Real b_out;
    function f
        input Integer a;
        output Real b;
        external;
    end f;
    equation
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal1",
            description="External C function (undeclared), one scalar Integer input, one scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternal1_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternal1_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_IntegerExternal1_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_DEF(INT_EXT, tmp_1)
    extern double f(int);
    tmp_1 = (int)a_v;
    b_v = f(tmp_1);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternal1_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_IntegerExternal1_f_def0(a_v, &b_v);
    return b_v;
}


")})));
end IntegerExternal1;

model IntegerExternal2
    Integer a_in=1;
    Integer b_out;
    function f
        input Real a;
        output Integer b;
        external;
    end f;
    equation
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal2",
            description="External C function (undeclared), one scalar Real input, one scalar Integer output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternal2_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternal2_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_IntegerExternal2_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, b_v)
    extern int f(double);
    b_v = f(a_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternal2_f_exp0(jmi_real_t a_v) {
    JMI_DEF(INT, b_v)
    func_CCodeGenExternalTests_IntegerExternal2_f_def0(a_v, &b_v);
    return b_v;
}


")})));
end IntegerExternal2;

model IntegerExternal3
    Integer a_in=1;
    Integer b_out;
    function f
        input Real a;
        output Integer b;
        external my_f(a, b);
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal3",
            description="External C function (declared), one scalar Real input, one scalar Integer output in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternal3_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternal3_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_IntegerExternal3_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, b_v)
    JMI_DEF(INT_EXT, tmp_1)
    extern void my_f(double, int*);
    tmp_1 = (int)b_v;
    my_f(a_v, &tmp_1);
    b_v = tmp_1;
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternal3_f_exp0(jmi_real_t a_v) {
    JMI_DEF(INT, b_v)
    func_CCodeGenExternalTests_IntegerExternal3_f_def0(a_v, &b_v);
    return b_v;
}


")})));
end IntegerExternal3;

model IntegerExternal4
    Integer a_in = 1;
    Integer b_in = 2;
    Integer c_out;
    Integer d_out;
    function f
        input Integer a;
        input Integer b;
        output Integer c;
        output Integer d;
        external d = my_f(a,b,c);
    end f;
    equation
        (c_out, d_out) = f(a_in, b_in); 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal4",
            description="External C function (declared), two scalar Integer inputs, two scalar Integer outputs (one in return, one in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternal4_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternal4_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_IntegerExternal4_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, c_v)
    JMI_DEF(INT, d_v)
    JMI_DEF(INT_EXT, tmp_1)
    JMI_DEF(INT_EXT, tmp_2)
    JMI_DEF(INT_EXT, tmp_3)
    extern int my_f(int, int, int*);
    tmp_1 = (int)a_v;
    tmp_2 = (int)b_v;
    tmp_3 = (int)c_v;
    d_v = my_f(tmp_1, tmp_2, &tmp_3);
    c_v = tmp_3;
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternal4_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(INT, c_v)
    func_CCodeGenExternalTests_IntegerExternal4_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}


")})));
end IntegerExternal4;

model RecordExternal1
    record R
        Real x;
        Integer i;
    end R;
    
    function f
        input R r;
        output R y;
        external;
    end f;
    
    R r = f(R(time, 1));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordExternal1",
            description="External C function with record",
            template="
$C_records$
$C_function_headers$
$C_functions$
",
            generatedCode="
typedef struct R_0_r_ R_0_r;
struct R_0_r_ {
    jmi_real_t x;
    jmi_real_t i;
};
JMI_ARRAY_TYPE(R_0_r, R_0_ra)

typedef struct R_0_r_ext_ R_0_r_ext;
struct R_0_r_ext_ {
    jmi_real_t x;
    jmi_int_t i;
};


void func_CCodeGenExternalTests_RecordExternal1_f_def0(R_0_r* r_v, R_0_r* y_v);

void func_CCodeGenExternalTests_RecordExternal1_f_def0(R_0_r* r_v, R_0_r* y_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, y_vn)
    JMI_RECORD_STATIC(R_0_r_ext, tmp_1)
    JMI_RECORD_STATIC(R_0_r_ext, tmp_2)
    extern R_0_r* f(R_0_r*);
    if (y_v == NULL) {
        y_v = y_vn;
    }
    tmp_1->x = (double)r_v->x;
    tmp_1->i = (int)r_v->i;
    *tmp_2 = f(tmp_1);
    y_v->x = tmp_2->x;
    y_v->i = tmp_2->i;
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end RecordExternal1;

model RecordExternal2
    record R1
        Real x;
    end R1;
    
    record R2
        R1 r1;
    end R2;
    
    function f
        input R2 r;
        output R2 y;
        external;
    end f;
    
    R2 r2 = f(R2(R1(time)));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordExternal2",
            description="External C function with record",
            template="
$C_records$
$C_function_headers$
$C_functions$
",
            generatedCode="
typedef struct R1_0_r_ R1_0_r;
struct R1_0_r_ {
    jmi_real_t x;
};
JMI_ARRAY_TYPE(R1_0_r, R1_0_ra)

typedef struct R1_0_r_ext_ R1_0_r_ext;
struct R1_0_r_ext_ {
    jmi_real_t x;
};

typedef struct R2_1_r_ R2_1_r;
struct R2_1_r_ {
    R1_0_r* r1;
};
JMI_ARRAY_TYPE(R2_1_r, R2_1_ra)

typedef struct R2_1_r_ext_ R2_1_r_ext;
struct R2_1_r_ext_ {
    R1_0_r_ext r1;
};


void func_CCodeGenExternalTests_RecordExternal2_f_def0(R2_1_r* r_v, R2_1_r* y_v);

void func_CCodeGenExternalTests_RecordExternal2_f_def0(R2_1_r* r_v, R2_1_r* y_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R2_1_r, y_vn)
    JMI_RECORD_STATIC(R1_0_r, tmp_1)
    JMI_RECORD_STATIC(R2_1_r_ext, tmp_2)
    JMI_RECORD_STATIC(R2_1_r_ext, tmp_3)
    extern R2_1_r* f(R2_1_r*);
    if (y_v == NULL) {
        y_vn->r1 = tmp_1;
        y_v = y_vn;
    }
    tmp_2->r1.x = (double)r_v->r1->x;
    *tmp_3 = f(tmp_2);
    y_v->r1->x = tmp_3->r1.x;
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end RecordExternal2;

model RecordExternal3
    record R1
        Real x;
        String s;
    end R1;
    
    record R2
        R1 r1;
    end R2;
    
    function f
        input R2 r;
        output Real y;
        external;
    end f;
    
    Real y = f(R2(R1(time, "str")));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordExternal3",
            description="External C function with record",
            template="
$C_records$
$C_function_headers$
$C_functions$
",
            generatedCode="
typedef struct R1_0_r_ R1_0_r;
struct R1_0_r_ {
    jmi_real_t x;
    jmi_string_t s;
};
JMI_ARRAY_TYPE(R1_0_r, R1_0_ra)

typedef struct R1_0_r_ext_ R1_0_r_ext;
struct R1_0_r_ext_ {
    jmi_real_t x;
    jmi_string_t s;
};

typedef struct R2_1_r_ R2_1_r;
struct R2_1_r_ {
    R1_0_r* r1;
};
JMI_ARRAY_TYPE(R2_1_r, R2_1_ra)

typedef struct R2_1_r_ext_ R2_1_r_ext;
struct R2_1_r_ext_ {
    R1_0_r_ext r1;
};


void func_CCodeGenExternalTests_RecordExternal3_f_def0(R2_1_r* r_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenExternalTests_RecordExternal3_f_exp0(R2_1_r* r_v);

void func_CCodeGenExternalTests_RecordExternal3_f_def0(R2_1_r* r_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RECORD_STATIC(R2_1_r_ext, tmp_1)
    extern double f(R2_1_r*);
    tmp_1->r1.x = (double)r_v->r1->x;
    JMI_ASG(STR, tmp_1->r1.s, r_v->r1->s)
    y_v = f(tmp_1);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_RecordExternal3_f_exp0(R2_1_r* r_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenExternalTests_RecordExternal3_f_def0(r_v, &y_v);
    return y_v;
}


")})));
end RecordExternal3;


model ExternalLiteral1
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external my_f(a,b,10);
    end f;
    equation
        c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalLiteral1",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalLiteral1_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o);
jmi_real_t func_CCodeGenExternalTests_ExternalLiteral1_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_ExternalLiteral1_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    extern void my_f(double, double, int);
    my_f(a_v, b_v, 10);
    JMI_RET(GEN, c_o, c_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalLiteral1_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_ExternalLiteral1_f_def0(a_v, b_v, &c_v);
    return c_v;
}


")})));
end ExternalLiteral1;

model ExternalLiteral2
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external my_f(a,20,b,10);
    end f;
    equation
        c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalLiteral2",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalLiteral2_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o);
jmi_real_t func_CCodeGenExternalTests_ExternalLiteral2_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_ExternalLiteral2_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    extern void my_f(double, int, double, int);
    my_f(a_v, 20, b_v, 10);
    JMI_RET(GEN, c_o, c_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalLiteral2_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_ExternalLiteral2_f_def0(a_v, b_v, &c_v);
    return c_v;
}


")})));
end ExternalLiteral2;

model ExternalLiteral3
    Real c_out;
    function f
        output Real c;
        external my_f(10,20,30);
    end f;
    equation
        c_out = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalLiteral3",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalLiteral3_f_def0(jmi_real_t* c_o);
jmi_real_t func_CCodeGenExternalTests_ExternalLiteral3_f_exp0();

void func_CCodeGenExternalTests_ExternalLiteral3_f_def0(jmi_real_t* c_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    extern void my_f(int, int, int);
    my_f(10, 20, 30);
    JMI_RET(GEN, c_o, c_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalLiteral3_f_exp0() {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_ExternalLiteral3_f_def0(&c_v);
    return c_v;
}


")})));
end ExternalLiteral3;

model ExternalArray1
    Real a_in[2]={1,1};
    Real b_out;
    function f
        input Real a[2];
        output Real b;
        external;
    end f;
    equation
        b_out = f(a_in);


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray1",
            description="External C function (undeclared) with one dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArray1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_ExternalArray1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_ExternalArray1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double f(double*, size_t);
    b_v = f(a_a->var, jmi_array_size(a_a, 0));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalArray1_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_ExternalArray1_f_def0(a_a, &b_v);
    return b_v;
}


")})));
end ExternalArray1;

model ExternalArray2
    Real a_in[2,2]={{1,1},{1,1}};
    Real b_out;
    function f
        input Real a[2,2];
        output Real b;
        external;
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray2",
            description="External C function (undeclared) with two dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArray2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_ExternalArray2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_ExternalArray2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double f(double*, size_t, size_t);
    b_v = f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalArray2_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_ExternalArray2_f_def0(a_a, &b_v);
    return b_v;
}


")})));
end ExternalArray2;

model ExternalArray3
    Real a_in[2,2];
    Real b_out;
    function f
        input Real a[:,:];
        output Real b;
        external;
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray3",
            description="External C function (undeclared) with two dim and unknown no of elements array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArray3_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_ExternalArray3_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_ExternalArray3_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double f(double*, size_t, size_t);
    b_v = f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalArray3_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_ExternalArray3_f_def0(a_a, &b_v);
    return b_v;
}


")})));
end ExternalArray3;

model ExternalArray4
    Real a_in[2];
    Real b_out[2];
    function f
        input Real a[2];
        output Real b[2];
        external;
    end f;
    equation
        a_in[1] = 1;
        a_in[2] = 2;
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray4",
            description="External C function (undeclared) with one dim array input, one dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_ExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1)
    extern void f(double*, size_t, double*, size_t);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    f(a_a->var, jmi_array_size(a_a, 0), b_a->var, jmi_array_size(b_a, 0));
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end ExternalArray4;

model ExternalArray5
    Real a_in[2,2];
    Real b_out[2,2];
    function f
        input Real a[2,2];
        output Real b[2,2];
        external;
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray5",
            description="External C function (undeclared) with two dim array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArray5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_ExternalArray5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2)
    extern void f(double*, size_t, size_t, double*, size_t, size_t);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1), b_a->var, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1));
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end ExternalArray5;

model ExternalArray6
    Real a_in[2,2];
    Real b_out[2,2];
    function f
        input Real a[:,:];
        output Real b[size(a,1),size(a,2)];
        external;
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray6",
            description="External C function (undeclared) with two dim and unknown no of elements array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArray6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_ExternalArray6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, b_an, -1, 2)
    extern void f(double*, size_t, size_t, double*, size_t, size_t);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, b_an, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
        b_a = b_an;
    }
    f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1), b_a->var, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1));
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end ExternalArray6;

model IntegerExternalArray1
    Integer a_in[2]={1,1};
    Real b_out;
    function f
        input Integer a[2];
        output Real b;
        external;
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray1",
            description="External C function (undeclared) with one dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArray1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalArray1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_IntegerExternalArray1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 1)
    extern double f(int*, size_t);
    JMI_ARRAY_INIT_1(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(a_a, 0), 1, jmi_array_size(a_a, 0))
    jmi_copy_matrix_to_int(a_a, a_a->var, tmp_1->var);
    b_v = f(tmp_1->var, jmi_array_size(a_a, 0));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalArray1_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_IntegerExternalArray1_f_def0(a_a, &b_v);
    return b_v;
}


")})));
end IntegerExternalArray1;

model IntegerExternalArray2
    Integer a_in[2,2]={{1,1},{1,1}};
    Real b_out;
    function f
        input Integer a[2,2];
        output Real b;
        external;
    end f;
    equation
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray2",
            description="External C function (undeclared) with two dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArray2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalArray2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_IntegerExternalArray2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 2)
    extern double f(int*, size_t, size_t);
    JMI_ARRAY_INIT_2(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_copy_matrix_to_int(a_a, a_a->var, tmp_1->var);
    b_v = f(tmp_1->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalArray2_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_IntegerExternalArray2_f_def0(a_a, &b_v);
    return b_v;
}


")})));
end IntegerExternalArray2;

model IntegerExternalArray3
    discrete Real a_in = 1;
    Integer b_out[2];
    function f
        input Real a;
        output Integer b[2];
        external;
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray3",
            description="External C function (undeclared) with one scalar Real input, one dim array Integer output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArray3_f_def0(jmi_real_t a_v, jmi_array_t* b_a);

void func_CCodeGenExternalTests_IntegerExternalArray3_f_def0(jmi_real_t a_v, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 1)
    extern void f(double, int*, size_t);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(b_a, 0), 1, jmi_array_size(b_a, 0))
    jmi_copy_matrix_to_int(b_a, b_a->var, tmp_1->var);
    f(a_v, tmp_1->var, jmi_array_size(b_a, 0));
    jmi_copy_matrix_from_int(b_a, tmp_1->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end IntegerExternalArray3;

model IntegerExternalArray4
    Integer a_in[2,2];
    Integer b_out[2,2];
    function f
        input Integer a[2,2];
        output Integer b[2,2];
        external;
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray4",
            description="External C function (undeclared) with one 2-dim Integer array input, one 2-dim Integer array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_IntegerExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 2)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_2, -1, 2)
    extern void f(int*, size_t, size_t, int*, size_t, size_t);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_copy_matrix_to_int(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(HEAP, jmi_int_t, jmi_int_array_t, tmp_2, jmi_array_size(b_a, 0) * jmi_array_size(b_a, 1), 2, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1))
    jmi_copy_matrix_to_int(b_a, b_a->var, tmp_2->var);
    f(tmp_1->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1), tmp_2->var, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1));
    jmi_copy_matrix_from_int(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}


")})));
end IntegerExternalArray4;

model SimpleExternalFortran1

    Real a_in=1;
    Real b_out;
    
    function f
        input Real a;
        output Real b;
        external "FORTRAN 77";
    end f;
    
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran1",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran1_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran1_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternalFortran1_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double f_(double*);
    b_v = f_(&a_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran1_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_SimpleExternalFortran1_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternalFortran1;

model SimpleExternalFortran2
    Real a_in=1;
    Real b_in=2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external "FORTRAN 77";
    end f;
    equation
        c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran2",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran2_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran2_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternalFortran2_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    extern double f_(double*, double*);
    c_v = f_(&a_v, &b_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran2_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternalFortran2_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end SimpleExternalFortran2;

model SimpleExternalFortran3
    Real a_in=1;
    Real b_out;
    function f
        input Real a;
        output Real b;
        external "FORTRAN 77" b = my_f(a);
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran3",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran3_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran3_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternalFortran3_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double my_f_(double*);
    b_v = my_f_(&a_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran3_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_SimpleExternalFortran3_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternalFortran3;

model SimpleExternalFortran4
    Real a_in=1;
    Real b_out;
    function f
        input Real a;
        output Real b;
        external "FORTRAN 77" my_f(a, b);
    end f;
    equation
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran4",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran4_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran4_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternalFortran4_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern void my_f_(double*, double*);
    my_f_(&a_v, &b_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran4_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_SimpleExternalFortran4_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternalFortran4;

model SimpleExternalFortran5
    Real a_in=1;
    function f
        input Real a;
        external "FORTRAN 77";
    end f;
    equation
        f(a_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran5",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran5_f_def0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternalFortran5_f_def0(jmi_real_t a_v) {
    JMI_DYNAMIC_INIT()
    extern void f_(double*);
    f_(&a_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end SimpleExternalFortran5;

model SimpleExternalFortran6
    Real a_in=1;
    function f
        input Real a;
        external "FORTRAN 77" my_f(a);
    end f;
    equation
        f(a_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran6",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran6_f_def0(jmi_real_t a_v);

void func_CCodeGenExternalTests_SimpleExternalFortran6_f_def0(jmi_real_t a_v) {
    JMI_DYNAMIC_INIT()
    extern void my_f_(double*);
    my_f_(&a_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end SimpleExternalFortran6;

model SimpleExternalFortran7
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external "FORTRAN 77" my_f(a,c,b);
    end f;
    equation
        c_out = f(a_in, b_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran7",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran7_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran7_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternalFortran7_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    extern void my_f_(double*, double*, double*);
    my_f_(&a_v, &c_v, &b_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran7_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternalFortran7_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end SimpleExternalFortran7;

model SimpleExternalFortran8
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    Real d_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        output Real d;
        external "FORTRAN 77" my_f(a,c,b,d);
    end f;
    equation
        (c_out, d_out) = f(a_in, b_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran8",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran8_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran8_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternalFortran8_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    JMI_DEF(REA, d_v)
    extern void my_f_(double*, double*, double*, double*);
    my_f_(&a_v, &c_v, &b_v, &d_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran8_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternalFortran8_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end SimpleExternalFortran8;

model SimpleExternalFortran9
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    Real d_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        output Real d;
        external "FORTRAN 77" d = my_f(a,b,c);
    end f;
    equation
        (c_out, d_out) = f(a_in, b_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran9",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran9_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran9_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternalFortran9_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    JMI_DEF(REA, d_v)
    extern double my_f_(double*, double*, double*);
    d_v = my_f_(&a_v, &b_v, &c_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran9_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternalFortran9_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end SimpleExternalFortran9;

model SimpleExternalFortran10
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    Real d_out;
    Real e_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        output Real d;
        output Real e;
        external "FORTRAN 77" d = my_f(a,c,b,e);
    end f;
    equation
        (c_out, d_out, e_out) = f(a_in, b_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran10",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_SimpleExternalFortran10_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o, jmi_real_t* e_o);
jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran10_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_SimpleExternalFortran10_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o, jmi_real_t* e_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, c_v)
    JMI_DEF(REA, d_v)
    JMI_DEF(REA, e_v)
    extern double my_f_(double*, double*, double*, double*);
    d_v = my_f_(&a_v, &c_v, &b_v, &e_v);
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_RET(GEN, e_o, e_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_SimpleExternalFortran10_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(REA, c_v)
    func_CCodeGenExternalTests_SimpleExternalFortran10_f_def0(a_v, b_v, &c_v, NULL, NULL);
    return c_v;
}

")})));
end SimpleExternalFortran10;

model IntegerExternalFortran1
    Integer a_in=1;
    Real b_out;
    function f
        input Integer a;
        output Real b;
        external "FORTRAN 77";
    end f;
    equation
        b_out = f(a_in);        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran1",
            description="External Fortran function, one scalar Integer input, one scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalFortran1_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran1_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_IntegerExternalFortran1_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_DEF(INT_EXT, tmp_1)
    extern double f_(int*);
    tmp_1 = (int)a_v;
    b_v = f_(&tmp_1);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran1_f_exp0(jmi_real_t a_v) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_IntegerExternalFortran1_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternalFortran1;

model IntegerExternalFortran2
    Integer a_in=1;
    Integer b_out;
    function f
        input Real a;
        output Integer b;
        external "FORTRAN 77";
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran2",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalFortran2_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran2_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_IntegerExternalFortran2_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, b_v)
    extern int f_(double*);
    b_v = f_(&a_v);
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran2_f_exp0(jmi_real_t a_v) {
    JMI_DEF(INT, b_v)
    func_CCodeGenExternalTests_IntegerExternalFortran2_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternalFortran2;

model IntegerExternalFortran3
    Integer a_in=1;
    Integer b_out;
    function f
        input Real a;
        output Integer b;
        external "FORTRAN 77" my_f(a, b);
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran3",
            description="External Fortran function (declared), one scalar Real input, one scalar Integer output in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalFortran3_f_def0(jmi_real_t a_v, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran3_f_exp0(jmi_real_t a_v);

void func_CCodeGenExternalTests_IntegerExternalFortran3_f_def0(jmi_real_t a_v, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, b_v)
    JMI_DEF(INT_EXT, tmp_1)
    extern void my_f_(double*, int*);
    tmp_1 = (int)b_v;
    my_f_(&a_v, &tmp_1);
    b_v = tmp_1;
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran3_f_exp0(jmi_real_t a_v) {
    JMI_DEF(INT, b_v)
    func_CCodeGenExternalTests_IntegerExternalFortran3_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternalFortran3;

model IntegerExternalFortran4
    Integer a_in = 1;
    Integer b_in = 2;
    Integer c_out;
    Integer d_out;
    function f
        input Integer a;
        input Integer b;
        output Integer c;
        output Integer d;
        external "FORTRAN 77" d = my_f(a,b,c);
    end f;
    equation
        (c_out, d_out) = f(a_in, b_in);     

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran4",
            description="External Fortran function (declared), two scalar Integer inputs, two scalar Integer outputs (one in return, one in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalFortran4_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran4_f_exp0(jmi_real_t a_v, jmi_real_t b_v);

void func_CCodeGenExternalTests_IntegerExternalFortran4_f_def0(jmi_real_t a_v, jmi_real_t b_v, jmi_real_t* c_o, jmi_real_t* d_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, c_v)
    JMI_DEF(INT, d_v)
    JMI_DEF(INT_EXT, tmp_1)
    JMI_DEF(INT_EXT, tmp_2)
    JMI_DEF(INT_EXT, tmp_3)
    extern int my_f_(int*, int*, int*);
    tmp_1 = (int)a_v;
    tmp_2 = (int)b_v;
    tmp_3 = (int)c_v;
    d_v = my_f_(&tmp_1, &tmp_2, &tmp_3);
    c_v = tmp_3;
    JMI_RET(GEN, c_o, c_v)
    JMI_RET(GEN, d_o, d_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalFortran4_f_exp0(jmi_real_t a_v, jmi_real_t b_v) {
    JMI_DEF(INT, c_v)
    func_CCodeGenExternalTests_IntegerExternalFortran4_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end IntegerExternalFortran4;

model StringExternalFortran1
    Real[1] a = Modelica.Math.Matrices.LAPACK.dgeev({{1}});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="StringExternalFortran1",
        description="External Fortran function, scalar string input",
        variability_propagation=false,
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_Modelica_Math_Matrices_LAPACK_dgeev_def0(jmi_array_t* A_a, jmi_array_t* eigenReal_a, jmi_array_t* eigenImag_a, jmi_array_t* eigenVectors_a, jmi_real_t* info_o);

void func_Modelica_Math_Matrices_LAPACK_dgeev_def0(jmi_array_t* A_a, jmi_array_t* eigenReal_a, jmi_array_t* eigenImag_a, jmi_array_t* eigenVectors_a, jmi_real_t* info_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, eigenReal_an, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, eigenImag_an, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, eigenVectors_an, -1, 2)
    JMI_DEF(INT, info_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, dummy_a, 1, 2)
    JMI_DEF(INT, n_v)
    JMI_DEF(INT, lwork_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, Awork_a, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, work_a, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    JMI_DEF(STR_EXT, tmp_1)
    JMI_DEF(STR_EXT, tmp_2)
    JMI_DEF(INT_EXT, tmp_3)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_4, -1, 2)
    JMI_DEF(INT_EXT, tmp_5)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_6, -1, 2)
    JMI_DEF(INT_EXT, tmp_7)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_8, -1, 2)
    JMI_DEF(INT_EXT, tmp_9)
    JMI_DEF(INT_EXT, tmp_10)
    extern void dgeev_(const char*, const char*, int*, double*, int*, double*, double*, double*, int*, double*, int*, double*, int*, int*);
    if (eigenReal_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, eigenReal_an, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
        eigenReal_a = eigenReal_an;
    }
    if (eigenImag_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, eigenImag_an, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
        eigenImag_a = eigenImag_an;
    }
    if (eigenVectors_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, eigenVectors_an, jmi_array_size(A_a, 0) * jmi_array_size(A_a, 0), 2, jmi_array_size(A_a, 0), jmi_array_size(A_a, 0))
        eigenVectors_a = eigenVectors_an;
    }
    JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, dummy_a, 1, 2, 1, 1)
    n_v = jmi_array_size(A_a, 0);
    lwork_v = 12 * n_v;
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, Awork_a, jmi_array_size(A_a, 0) * jmi_array_size(A_a, 0), 2, jmi_array_size(A_a, 0), jmi_array_size(A_a, 0))
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(A_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        i2_1in = 0;
        i2_1ie = floor((jmi_array_size(A_a, 0)) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_ref_2(Awork_a, i1_0i, i2_1i) = jmi_array_val_2(A_a, i1_0i, i2_1i);
        }
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, work_a, 12 * jmi_array_size(A_a, 0), 1, 12 * jmi_array_size(A_a, 0))
    JMI_ASG(STR, tmp_1, \"N\")
    JMI_ASG(STR, tmp_2, \"V\")
    tmp_3 = (int)n_v;
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_4, jmi_array_size(Awork_a, 0) * jmi_array_size(Awork_a, 1), 2, jmi_array_size(Awork_a, 0), jmi_array_size(Awork_a, 1))
    jmi_matrix_to_fortran_real(Awork_a, Awork_a->var, tmp_4->var);
    tmp_5 = (int)n_v;
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_6, jmi_array_size(dummy_a, 0) * jmi_array_size(dummy_a, 1), 2, jmi_array_size(dummy_a, 0), jmi_array_size(dummy_a, 1))
    jmi_matrix_to_fortran_real(dummy_a, dummy_a->var, tmp_6->var);
    tmp_7 = (int)1;
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_8, jmi_array_size(eigenVectors_a, 0) * jmi_array_size(eigenVectors_a, 1), 2, jmi_array_size(eigenVectors_a, 0), jmi_array_size(eigenVectors_a, 1))
    jmi_matrix_to_fortran_real(eigenVectors_a, eigenVectors_a->var, tmp_8->var);
    tmp_9 = (int)n_v;
    tmp_10 = (int)info_v;
    dgeev_(tmp_1, tmp_2, &tmp_9, tmp_4->var, &tmp_9, eigenReal_a->var, eigenImag_a->var, tmp_6->var, &tmp_7, tmp_8->var, &tmp_9, work_a->var, &jmi_array_size(work_a, 0), &tmp_10);
    jmi_matrix_from_fortran_real(eigenVectors_a, tmp_8->var, eigenVectors_a->var);
    info_v = tmp_10;
    JMI_RET(GEN, info_o, info_v)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end StringExternalFortran1;

model ExternalArrayFortran1
    Real a_in[2]={1,1};
    Real b_out;
    function f
        input Real a[2];
        output Real b;
        external "FORTRAN 77";
    end f;
    equation
        b_out = f(a_in);


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran1",
            description="External Fortan function with one dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_ExternalArrayFortran1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_ExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    extern double f_(double*, int*);
    b_v = f_(a_a->var, &jmi_array_size(a_a, 0));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalArrayFortran1_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_ExternalArrayFortran1_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArrayFortran1;

model ExternalArrayFortran2
    Real a_in[2,2]={{1,1},{1,1}};
    Real b_out;
    function f
        input Real a[2,2];
        output Real b;
        external "FORTRAN 77";
    end f;
    equation
        b_out = f(a_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran2",
            description="External Fortan function with two dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_ExternalArrayFortran2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_ExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 2)
    extern double f_(double*, int*, int*);
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalArrayFortran2_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_ExternalArrayFortran2_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArrayFortran2;

model ExternalArrayFortran3
    Real a_in[2,2];
    Real b_out;
    function f
        input Real a[:,:];
        output Real b;
        external "FORTRAN 77";
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran3",
            description="External Fortran function with two dim and unknown no of elements array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArrayFortran3_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_ExternalArrayFortran3_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_ExternalArrayFortran3_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 2)
    extern double f_(double*, int*, int*);
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_ExternalArrayFortran3_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_ExternalArrayFortran3_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArrayFortran3;

model ExternalArrayFortran4
    Real a_in[2];
    Real b_out[2];
    function f
        input Real a[2];
        output Real b[2];
        external "FORTRAN 77";
    end f;
    equation
        a_in[1] = 1;
        a_in[2] = 2;
        b_out = f(a_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran4",
            description="External Fortran function with one dim array input, one dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_ExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1)
    extern void f_(double*, int*, double*, int*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    f_(a_a->var, &jmi_array_size(a_a, 0), b_a->var, &jmi_array_size(b_a, 0));
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArrayFortran4;

model ExternalArrayFortran5
    Real a_in[2,2];
    Real b_out[2,2];
    function f
        input Real a[2,2];
        output Real b[2,2];
        external "FORTRAN 77";
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran5",
            description="External Fortran function with two dim array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArrayFortran5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_ExternalArrayFortran5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_2, -1, 2)
    extern void f_(double*, int*, int*, double*, int*, int*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_2, jmi_array_size(b_a, 0) * jmi_array_size(b_a, 1), 2, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1))
    jmi_matrix_to_fortran_real(b_a, b_a->var, tmp_2->var);
    f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1), tmp_2->var, &jmi_array_size(b_a, 0), &jmi_array_size(b_a, 1));
    jmi_matrix_from_fortran_real(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArrayFortran5;

model ExternalArrayFortran6
    Real a_in[2,2];
    Real b_out[2,2];
    function f
        input Real a[:,:];
        output Real b[size(a,1),size(a,2)];
        external "FORTRAN 77";
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);
        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran6",
            description="External Fortran function with two dim and unknown no of elements array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_ExternalArrayFortran6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_ExternalArrayFortran6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, b_an, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_2, -1, 2)
    extern void f_(double*, int*, int*, double*, int*, int*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, b_an, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_2, jmi_array_size(b_a, 0) * jmi_array_size(b_a, 1), 2, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1))
    jmi_matrix_to_fortran_real(b_a, b_a->var, tmp_2->var);
    f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1), tmp_2->var, &jmi_array_size(b_a, 0), &jmi_array_size(b_a, 1));
    jmi_matrix_from_fortran_real(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArrayFortran6;

model IntegerExternalArrayFortran1
    Integer a_in[2]={1,1};
    Real b_out;
    function f
        input Integer a[2];
        output Real b;
        external "FORTRAN 77";
    end f;
    equation
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran1",
            description="External Fortran function (undeclared) with one dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalArrayFortran1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_IntegerExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 1)
    extern double f_(int*, int*);
    JMI_ARRAY_INIT_1(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(a_a, 0), 1, jmi_array_size(a_a, 0))
    jmi_matrix_to_fortran_int(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalArrayFortran1_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_IntegerExternalArrayFortran1_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end IntegerExternalArrayFortran1;

model IntegerExternalArrayFortran2
    Integer a_in[2,2]={{1,1},{1,1}};
    Real b_out;
    function f
        input Integer a[2,2];
        output Real b;
        external "FORTRAN 77";
    end f;
    equation
        b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran2",
            description="External Fortran function (undeclared) with two dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o);
jmi_real_t func_CCodeGenExternalTests_IntegerExternalArrayFortran2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenExternalTests_IntegerExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, b_v)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 2)
    extern double f_(int*, int*, int*);
    JMI_ARRAY_INIT_2(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_int(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1));
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_IntegerExternalArrayFortran2_f_exp0(jmi_array_t* a_a) {
    JMI_DEF(REA, b_v)
    func_CCodeGenExternalTests_IntegerExternalArrayFortran2_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end IntegerExternalArrayFortran2;

model IntegerExternalArrayFortran3
    Integer a_in = 1;
    Integer b_out[2];
    function f
        input Real a;
        output Integer b[2];
        external "FORTRAN 77";
    end f;
    equation
        b_out = f(a_in);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran3",
            description="External Fortran function (undeclared) with one scalar Real input, one dim array Integer output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArrayFortran3_f_def0(jmi_real_t a_v, jmi_array_t* b_a);

void func_CCodeGenExternalTests_IntegerExternalArrayFortran3_f_def0(jmi_real_t a_v, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 1)
    extern void f_(double*, int*, int*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(b_a, 0), 1, jmi_array_size(b_a, 0))
    jmi_matrix_to_fortran_int(b_a, b_a->var, tmp_1->var);
    f_(&a_v, tmp_1->var, &jmi_array_size(b_a, 0));
    jmi_matrix_from_fortran_int(b_a, tmp_1->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end IntegerExternalArrayFortran3;

model IntegerExternalArrayFortran4
    Integer a_in[2,2];
    Integer b_out[2,2];
    function f
        input Integer a[2,2];
        output Integer b[2,2];
        external "FORTRAN 77";
    end f;
    equation
        a_in = {{1,1},{2,2}};
        b_out = f(a_in);        

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran4",
            description="External Fortran function (undeclared) with one 2-dim Integer array input, one 2-dim Integer array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenExternalTests_IntegerExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenExternalTests_IntegerExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, -1, 2)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_2, -1, 2)
    extern void f_(int*, int*, int*, int*, int*, int*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_int(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(HEAP, jmi_int_t, jmi_int_array_t, tmp_2, jmi_array_size(b_a, 0) * jmi_array_size(b_a, 1), 2, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1))
    jmi_matrix_to_fortran_int(b_a, b_a->var, tmp_2->var);
    f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1), tmp_2->var, &jmi_array_size(b_a, 0), &jmi_array_size(b_a, 1));
    jmi_matrix_from_fortran_int(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end IntegerExternalArrayFortran4;

class ExtObject
    extends ExternalObject;
    
    function constructor
        output ExtObject eo;
        external "C" eo = init_myEO();
    end constructor;
    
    function destructor
        input ExtObject eo;
        external "C" close_myEO(eo);
    end destructor;
end ExtObject;

class ExtObjectwInput
    extends ExternalObject;
    
    function constructor
        input Real i;
        output ExtObjectwInput eo;
        external "C" eo = init_myEO(i);
    end constructor;
    
    function destructor
        input ExtObjectwInput eo;
        external "C" close_myEO(eo);
    end destructor;
end ExtObjectwInput;

function useMyEO
    input ExtObject eo;
    output Real r;
    external "C" r = useMyEO(eo);
end useMyEO;

function useMyEOI
    input ExtObjectwInput eo;
    output Real r;
    external "C" r = useMyEO(eo);
end useMyEOI;

model TestExtObject1
    ExtObject myEO = ExtObject();
    Real y;
equation
    y = useMyEO(myEO);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject1",
            description="",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="
$C_variable_aliases$
$C_function_headers$
$C_functions$
$C_destruct_external_object$
",
            generatedCode="
#define _y_1 ((*(jmi->z))[0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _myEO_0 ((jmi->ext_objs)[0])

void func_CCodeGenExternalTests_ExtObject_destructor_def0(jmi_extobj_t eo_v);
void func_CCodeGenExternalTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o);
jmi_extobj_t func_CCodeGenExternalTests_ExtObject_constructor_exp1();
void func_CCodeGenExternalTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_real_t* r_o);
jmi_real_t func_CCodeGenExternalTests_useMyEO_exp2(jmi_extobj_t eo_v);

void func_CCodeGenExternalTests_ExtObject_destructor_def0(jmi_extobj_t eo_v) {
    JMI_DYNAMIC_INIT()
    extern void close_myEO(void*);
    close_myEO(eo_v);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenExternalTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(EXO, eo_v)
    extern void* init_myEO();
    eo_v = init_myEO();
    JMI_RET(GEN, eo_o, eo_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_extobj_t func_CCodeGenExternalTests_ExtObject_constructor_exp1() {
    JMI_DEF(EXO, eo_v)
    func_CCodeGenExternalTests_ExtObject_constructor_def1(&eo_v);
    return eo_v;
}

void func_CCodeGenExternalTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_real_t* r_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, r_v)
    extern double useMyEO(void*);
    r_v = useMyEO(eo_v);
    JMI_RET(GEN, r_o, r_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_useMyEO_exp2(jmi_extobj_t eo_v) {
    JMI_DEF(REA, r_v)
    func_CCodeGenExternalTests_useMyEO_def2(eo_v, &r_v);
    return r_v;
}


    if (_myEO_0 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEO_0);
        _myEO_0 = NULL;
    }

")})));
end TestExtObject1;

model TestExtObject2
    ExtObject myEO = ExtObject();
    ExtObject myEO2 = ExtObject();
    Real y;
equation
    y = useMyEO(myEO) + useMyEO(myEO2); 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject2",
            description="",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="
$C_variable_aliases$
$C_function_headers$
$C_functions$
$C_destruct_external_object$
",
            generatedCode="
#define _y_2 ((*(jmi->z))[0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _myEO_0 ((jmi->ext_objs)[0])
#define _myEO2_1 ((jmi->ext_objs)[1])

void func_CCodeGenExternalTests_ExtObject_destructor_def0(jmi_extobj_t eo_v);
void func_CCodeGenExternalTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o);
jmi_extobj_t func_CCodeGenExternalTests_ExtObject_constructor_exp1();
void func_CCodeGenExternalTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_real_t* r_o);
jmi_real_t func_CCodeGenExternalTests_useMyEO_exp2(jmi_extobj_t eo_v);

void func_CCodeGenExternalTests_ExtObject_destructor_def0(jmi_extobj_t eo_v) {
    JMI_DYNAMIC_INIT()
    extern void close_myEO(void*);
    close_myEO(eo_v);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenExternalTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(EXO, eo_v)
    extern void* init_myEO();
    eo_v = init_myEO();
    JMI_RET(GEN, eo_o, eo_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_extobj_t func_CCodeGenExternalTests_ExtObject_constructor_exp1() {
    JMI_DEF(EXO, eo_v)
    func_CCodeGenExternalTests_ExtObject_constructor_def1(&eo_v);
    return eo_v;
}

void func_CCodeGenExternalTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_real_t* r_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, r_v)
    extern double useMyEO(void*);
    r_v = useMyEO(eo_v);
    JMI_RET(GEN, r_o, r_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_useMyEO_exp2(jmi_extobj_t eo_v) {
    JMI_DEF(REA, r_v)
    func_CCodeGenExternalTests_useMyEO_def2(eo_v, &r_v);
    return r_v;
}


    if (_myEO_0 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEO_0);
        _myEO_0 = NULL;
    }
    if (_myEO2_1 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEO2_1);
        _myEO2_1 = NULL;
    }

")})));
end TestExtObject2;

model TestExtObject3
    ExtObject myEO1 = ExtObject();
    ExtObject myEO2 = ExtObject();
    ExtObjectwInput myEO3 = ExtObjectwInput(z1);
    ExtObjectwInput myEO4 = ExtObjectwInput(z1);
    Real y1;
    Real y2;
    Real y3;
    Real y4;
    parameter Real z1 = 5;
equation
    y1 = useMyEO(myEO1);
    y2 = useMyEO(myEO2);
    y3 = useMyEOI(myEO3);
    y4 = useMyEOI(myEO4);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject3",
            description="",
            variability_propagation=false,
            template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_parameters$
$C_destruct_external_object$
",
            generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _z1_8 = (5);
    _myEO1_0 = (func_CCodeGenExternalTests_ExtObject_constructor_exp1());
    _myEO2_1 = (func_CCodeGenExternalTests_ExtObject_constructor_exp1());
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (_myEO3_2 != NULL) {
        func_CCodeGenExternalTests_ExtObjectwInput_destructor_def2(_myEO3_2);
        _myEO3_2 = NULL;
    }
    _myEO3_2 = (func_CCodeGenExternalTests_ExtObjectwInput_constructor_exp3(_z1_8));
    if (_myEO4_3 != NULL) {
        func_CCodeGenExternalTests_ExtObjectwInput_destructor_def2(_myEO4_3);
        _myEO4_3 = NULL;
    }
    _myEO4_3 = (func_CCodeGenExternalTests_ExtObjectwInput_constructor_exp3(_z1_8));
    JMI_DYNAMIC_FREE()
    return ef;
}

    if (_myEO1_0 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEO1_0);
        _myEO1_0 = NULL;
    }
    if (_myEO2_1 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEO2_1);
        _myEO2_1 = NULL;
    }
    if (_myEO3_2 != NULL) {
        func_CCodeGenExternalTests_ExtObjectwInput_destructor_def2(_myEO3_2);
        _myEO3_2 = NULL;
    }
    if (_myEO4_3 != NULL) {
        func_CCodeGenExternalTests_ExtObjectwInput_destructor_def2(_myEO4_3);
        _myEO4_3 = NULL;
    }

")})));
end TestExtObject3;


model TestExtObject4
    constant Integer N = 3;
    ExtObject myEOs[N] = fill(ExtObject(), N);
    Real y[N];
equation
    for i in 1:N loop
        y[i] = useMyEO(myEOs[i]);
    end for;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject4",
            description="Arrays of external objects",
            variability_propagation=false,
            template="$C_destruct_external_object$",
            generatedCode="
    if (_myEOs_1_1 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEOs_1_1);
        _myEOs_1_1 = NULL;
    }
    if (_myEOs_2_2 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEOs_2_2);
        _myEOs_2_2 = NULL;
    }
    if (_myEOs_3_3 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEOs_3_3);
        _myEOs_3_3 = NULL;
    }
")})));
end TestExtObject4;
    

model TestExtObject5
    ExtObject a = ExtObject();
    ExtObject b = a; 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject5",
            description="Test that destructor calls are only generated for external objects with constructor calls",
            variability_propagation=false,
            template="$C_destruct_external_object$",
            generatedCode="
    if (_a_0 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_a_0);
        _a_0 = NULL;
    }
")})));
end TestExtObject5;


model TestExtObject6
    ExtObject eo1 = ExtObject();
    ExtObject myEOs[2] = { ExtObject(), eo1 };
    Real y[2];
equation
    for i in 1:2 loop
        y[i] = useMyEO(myEOs[i]);
    end for;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject6",
            description="Test that destructor calls are only generated for external objects with constructor calls",
            variability_propagation=false,
            template="$C_destruct_external_object$",
            generatedCode="
    if (_eo1_0 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_eo1_0);
        _eo1_0 = NULL;
    }
    if (_myEOs_1_1 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_myEOs_1_1);
        _myEOs_1_1 = NULL;
    }
")})));
end TestExtObject6;

model TestExtObject7
    record R
        parameter ExtObject eo = ExtObject();
        parameter ExtObject[2] eos = {ExtObject(), ExtObject()};
    end R;
    R r;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject7",
            description="Test that constructor and destructor calls are generated for external objects in records.",
            variability_propagation=false,
            template="
$C_model_init_eval_independent_start$
$C_destruct_external_object$
",
            generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _r_eo_0 = (func_CCodeGenExternalTests_ExtObject_constructor_exp1());
    _r_eos_1_1 = (func_CCodeGenExternalTests_ExtObject_constructor_exp1());
    _r_eos_2_2 = (func_CCodeGenExternalTests_ExtObject_constructor_exp1());
    JMI_DYNAMIC_FREE()
    return ef;
}

    if (_r_eo_0 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_r_eo_0);
        _r_eo_0 = NULL;
    }
    if (_r_eos_1_1 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_r_eos_1_1);
        _r_eos_1_1 = NULL;
    }
    if (_r_eos_2_2 != NULL) {
        func_CCodeGenExternalTests_ExtObject_destructor_def0(_r_eos_2_2);
        _r_eos_2_2 = NULL;
    }
")})));
end TestExtObject7;

model TestExtObject8
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    record R
        parameter EO eo;
    end r;
    
    parameter Real x;
    parameter EO eo = EO(x);
    R r(eo=eo);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject8",
            description="Test that constructor and destructor calls are generated for external objects in records.",
            variability_propagation=false,
            template="
$C_model_init_eval_dependent_parameters$
$C_destruct_external_object$
",
            generatedCode="

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (_eo_1 != NULL) {
        func_CCodeGenExternalTests_TestExtObject8_EO_destructor_def0(_eo_1);
        _eo_1 = NULL;
    }
    _eo_1 = (func_CCodeGenExternalTests_TestExtObject8_EO_constructor_exp1(_x_0));
    _r_eo_2 = (_eo_1);
    JMI_DYNAMIC_FREE()
    return ef;
}

    if (_eo_1 != NULL) {
        func_CCodeGenExternalTests_TestExtObject8_EO_destructor_def0(_eo_1);
        _eo_1 = NULL;
    }
")})));
end TestExtObject8;

model TestExtObject9
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    function f
        input EO eo;
        output Real y;
        external;
    end f;
    
    parameter Real x(fixed=false);
    parameter EO eo = EO(x);
    parameter Real y = f(eo);
    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject9",
            description="",
            template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$
$C_ode_initialization$
$C_dae_init_blocks_residual_functions$
$C_destruct_external_object$
",
            generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _eo_1 = (NULL);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = 0.0;
    _eo_1 = func_CCodeGenExternalTests_TestExtObject9_EO_constructor_exp1(_x_0);
    _y_2 = func_CCodeGenExternalTests_TestExtObject9_f_exp2(_eo_1);
    JMI_DYNAMIC_FREE()
    return ef;
}


    if (_eo_1 != NULL) {
        func_CCodeGenExternalTests_TestExtObject9_EO_destructor_def0(_eo_1);
        _eo_1 = NULL;
    }

")})));
end TestExtObject9;

model TestExtObjectArray1
    ExtObject myEOs[2] = { ExtObject(), ExtObject() };
    Real z;

 function get_y
    input ExtObject eos[:];
    output Real y;
 algorithm
    y := useMyEO(eos[1]);
 end get_y;
 
equation
    z = get_y(myEOs);    

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestExtObjectArray1",
        description="",
        template="
$C_variable_aliases$
$C_model_init_eval_dependent_parameters$
$C_functions$
",
        generatedCode="
#define _z_2 ((*(jmi->z))[0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _myEOs_1_0 ((jmi->ext_objs)[0])
#define _myEOs_2_1 ((jmi->ext_objs)[1])


int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_extobj_t, jmi_extobj_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_extobj_t, jmi_extobj_array_t, tmp_1, 2, 1, 2)
    memcpy(&jmi_array_ref_1(tmp_1, 1), &_myEOs_1_0, 2 * sizeof(jmi_extobj_t));
    _z_2 = (func_CCodeGenExternalTests_TestExtObjectArray1_get_y_exp2(tmp_1));
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenExternalTests_ExtObject_destructor_def0(jmi_extobj_t eo_v) {
    JMI_DYNAMIC_INIT()
    extern void close_myEO(void*);
    close_myEO(eo_v);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenExternalTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(EXO, eo_v)
    extern void* init_myEO();
    eo_v = init_myEO();
    JMI_RET(GEN, eo_o, eo_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_extobj_t func_CCodeGenExternalTests_ExtObject_constructor_exp1() {
    JMI_DEF(EXO, eo_v)
    func_CCodeGenExternalTests_ExtObject_constructor_def1(&eo_v);
    return eo_v;
}

void func_CCodeGenExternalTests_TestExtObjectArray1_get_y_def2(jmi_extobj_array_t* eos_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = func_CCodeGenExternalTests_useMyEO_exp3(jmi_array_val_1(eos_a, 1));
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_TestExtObjectArray1_get_y_exp2(jmi_extobj_array_t* eos_a) {
    JMI_DEF(REA, y_v)
    func_CCodeGenExternalTests_TestExtObjectArray1_get_y_def2(eos_a, &y_v);
    return y_v;
}

void func_CCodeGenExternalTests_useMyEO_def3(jmi_extobj_t eo_v, jmi_real_t* r_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, r_v)
    extern double useMyEO(void*);
    r_v = useMyEO(eo_v);
    JMI_RET(GEN, r_o, r_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenExternalTests_useMyEO_exp3(jmi_extobj_t eo_v) {
    JMI_DEF(REA, r_v)
    func_CCodeGenExternalTests_useMyEO_def3(eo_v, &r_v);
    return r_v;
}

")})));
end TestExtObjectArray1;


end CCodeGenExternalTests;
