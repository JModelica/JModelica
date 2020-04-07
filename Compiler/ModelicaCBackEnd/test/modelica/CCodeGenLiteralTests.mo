/*
    Copyright (C) 2019 Modelon AB

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


package CCodeGenLiteralTests

model CCodeGenLiteralTest1
    function f
        input Integer[:] x;
        output Integer y = max(x);
    algorithm
    end f;

    Real min_explicit = -2147483648;
    Real max_explicit = 2147483647;
    Real y = f({1});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenLiteralTest1",
        description="",
        variability_propagation=false,
        inline_functions="none",
        template="
$C_ode_derivatives$
$C_functions$
",
        generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    _min_explicit_0 = -2.147483648E9;
    _max_explicit_1 = INT_MAX;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    _y_2 = func_CCodeGenLiteralTests_CCodeGenLiteralTest1_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenLiteralTests_CCodeGenLiteralTest1_f_def0(jmi_array_t* x_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, y_v)
    JMI_DEF(INT, temp_1_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    temp_1_v = INT_MIN;
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        temp_1_v = COND_EXP_EQ(COND_EXP_GT(temp_1_v, jmi_array_val_1(x_a, i1_0i), JMI_TRUE, JMI_FALSE), JMI_TRUE, temp_1_v, jmi_array_val_1(x_a, i1_0i));
    }
    y_v = temp_1_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenLiteralTests_CCodeGenLiteralTest1_f_exp0(jmi_array_t* x_a) {
    JMI_DEF(INT, y_v)
    func_CCodeGenLiteralTests_CCodeGenLiteralTest1_f_def0(x_a, &y_v);
    return y_v;
}
")})));
end CCodeGenLiteralTest1;

end CCodeGenLiteralTests;
