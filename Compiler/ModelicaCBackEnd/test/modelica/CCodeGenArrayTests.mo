/*
    Copyright (C) 2016-2017 Modelon AB

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


package CCodeGenArrayTests

model VectorLength1
    function f
        input Real x[:];
        output Real y;
      algorithm
        y := sqrt(x*x);
        annotation(Inline=false);
    end f;

    Real y = f({time});
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VectorLength1",
        description="",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenArrayTests_VectorLength1_f_def0(jmi_array_t* x_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(REA, temp_1_v)
    JMI_DEF(REA, temp_2_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    temp_2_v = 0.0;
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        temp_2_v = temp_2_v + jmi_array_val_1(x_a, i1_0i) * jmi_array_val_1(x_a, i1_0i);
    }
    temp_1_v = temp_2_v;
    y_v = sqrt(temp_1_v);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenArrayTests_VectorLength1_f_exp0(jmi_array_t* x_a) {
    JMI_DEF(REA, y_v)
    func_CCodeGenArrayTests_VectorLength1_f_def0(x_a, &y_v);
    return y_v;
}

")})));
end VectorLength1;

model UnknownSizeInEquation1
    function mysum
        input Real[:] x;
        output Real y;
        external;
    end mysum;
    
    function f
        input Real x;
        output Real[integer(x)] y;
        external;
    end f;
    
    Real y = mysum(f(time));
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="UnknownSizeInEquation1",
        description="",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 1)
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_1, (floor(_time)), 1, (floor(_time)))
    func_CCodeGenArrayTests_UnknownSizeInEquation1_f_def1(_time, tmp_1);
    _y_0 = func_CCodeGenArrayTests_UnknownSizeInEquation1_mysum_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end UnknownSizeInEquation1;

model UnknownSizeInEquation2
    function mysum
        input Real[:] x;
        output Real y;
        external;
    end mysum;
    
    function f
        input Real x;
        output Real[integer(x)] y;
        external;
    end f;
    
    Real y = mysum(if time > 2 then f(time) else f(time+1));
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="UnknownSizeInEquation2",
        description="",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_2, -1, 1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (2.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_1, (floor(_time)), 1, (floor(_time)))
        func_CCodeGenArrayTests_UnknownSizeInEquation2_f_def1(_time, tmp_1);
    } else {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_2, (floor(_time + 1.0)), 1, (floor(_time + 1.0)))
        func_CCodeGenArrayTests_UnknownSizeInEquation2_f_def1(_time + 1.0, tmp_2);
    }
    _y_0 = func_CCodeGenArrayTests_UnknownSizeInEquation2_mysum_exp0(COND_EXP_EQ(_sw(0), JMI_TRUE, tmp_1, tmp_2));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end UnknownSizeInEquation2;

model UnknownSizeInEquation3
    model M
        function mysum
            input Real[:] x;
            output Real y;
            external;
        end mysum;
        
        function f
            input Real x;
            output Real[integer(x)] y;
            external;
        end f;
        
        Real t = time;
        Real y = mysum(f(t));
    end M;
    
    M m;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="UnknownSizeInEquation3",
        description="Flattening and scalarization of function call sizes",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 1)
    _m_t_0 = _time;
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_1, (floor(_m_t_0)), 1, (floor(_m_t_0)))
    func_CCodeGenArrayTests_UnknownSizeInEquation3_m_f_def1(_m_t_0, tmp_1);
    _m_y_1 = func_CCodeGenArrayTests_UnknownSizeInEquation3_m_mysum_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end UnknownSizeInEquation3;

model UnknownSizeInEquation4
    function mysum
        input Real[:] x;
        output Real y;
        external;
    end mysum;
    
    function f
        input Real x;
        output Real[integer(x)] y;
        external;
    end f;
    
    parameter Real p = 1;
    Real y = mysum(f(p));
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="UnknownSizeInEquation4",
        description="",
        inline_functions="none",
        template="$C_model_init_eval_dependent_parameters$",
        generatedCode="

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 1)
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_1, (floor(_p_0)), 1, (floor(_p_0)))
    func_CCodeGenArrayTests_UnknownSizeInEquation4_f_def1(_p_0, tmp_1);
    _y_1 = (func_CCodeGenArrayTests_UnknownSizeInEquation4_mysum_exp0(tmp_1));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end UnknownSizeInEquation4;

model RecordArray1
    record R
        parameter Integer n = 3;
        Real[n] x = 1:3;
    end R;
    
    function f
        input Real x;
        output Real y = x;
    protected
        R r;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real y = f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordArray1",
            description="",
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenArrayTests_RecordArray1_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RECORD_STATIC(R_0_r, r_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    r_v->x = tmp_1;
    y_v = x_v;
    r_v->n = 3;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(r_v->x, i1_0i) = i1_0i;
    }
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenArrayTests_RecordArray1_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenArrayTests_RecordArray1_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end RecordArray1;

model RecordArray2
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    Real y = f({R({1,2}),R({time})});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray2",
        description="Test for bug in #5346",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 1)->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    jmi_array_rec_1(tmp_1, 2)->x = tmp_3;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 1)->x, 1) = 1.0;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 1)->x, 2) = 2.0;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 2)->x, 1) = _time;
    _y_0 = func_CCodeGenArrayTests_RecordArray2_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray2;

model RecordArray3
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    function g
        input Real[:] x;
        output Real[:] y = x;
        algorithm
    end g;
    
    Real y = f({R(g({1,2})),R(g({time}))});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray3",
        description="Test for bug in #5346",
        inline_functions="none",
        variability_propagation=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_5, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_7, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = 1.0;
    jmi_array_ref_1(tmp_2, 2) = 2.0;
    func_CCodeGenArrayTests_RecordArray3_g_def1(tmp_2, tmp_1);
    memcpy(&_temp_1_1_1, &jmi_array_val_1(tmp_1, 1), 2 * sizeof(jmi_real_t));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1, 1)
    jmi_array_ref_1(tmp_4, 1) = _time;
    func_CCodeGenArrayTests_RecordArray3_g_def1(tmp_4, tmp_3);
    _temp_2_1_3 = (jmi_array_val_1(tmp_3, 1));
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, tmp_5, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1, 2)
    jmi_array_rec_1(tmp_5, 1)->x = tmp_6;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_7, 1, 1, 1)
    jmi_array_rec_1(tmp_5, 2)->x = tmp_7;
    memcpy(&jmi_array_ref_1(jmi_array_rec_1(tmp_5, 1)->x, 1), &_temp_1_1_1, 2 * sizeof(jmi_real_t));
    jmi_array_ref_1(jmi_array_rec_1(tmp_5, 2)->x, 1) = _temp_2_1_3;
    _y_0 = func_CCodeGenArrayTests_RecordArray3_f_exp0(tmp_5);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray3;

model RecordArray4
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    function g
        input Real x;
        output Real y = x;
        algorithm
    end g;
    
    Real y = f({R(g({1,2})),R(g({time}))});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray4",
        description="Test for bug in #5346",
        inline_functions="none",
        variability_propagation=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 1)->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    jmi_array_rec_1(tmp_1, 2)->x = tmp_3;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 1)->x, 1) = func_CCodeGenArrayTests_RecordArray4_g_exp1(1.0);
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 1)->x, 2) = func_CCodeGenArrayTests_RecordArray4_g_exp1(2.0);
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 2)->x, 1) = func_CCodeGenArrayTests_RecordArray4_g_exp1(_time);
    _y_0 = func_CCodeGenArrayTests_RecordArray4_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray4;

model RecordArray5
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    function g
        input Real x1;
        input Real[:] x2;
        output Real y = x1 + sum(x2);
        algorithm
    end g;
    
    Real y = f({R(g({1,2}, {1,2,time})),R(g({time}, {1,2,3,time}))});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray5",
        description="Test for bug in #5346",
        inline_functions="none",
        variability_propagation=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 4, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_4, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = _time;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1, 3)
    jmi_array_ref_1(tmp_2, 1) = 1.0;
    jmi_array_ref_1(tmp_2, 2) = 2.0;
    jmi_array_ref_1(tmp_2, 3) = _time;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 4, 1, 4)
    jmi_array_ref_1(tmp_3, 1) = 1.0;
    jmi_array_ref_1(tmp_3, 2) = 2.0;
    jmi_array_ref_1(tmp_3, 3) = 3.0;
    jmi_array_ref_1(tmp_3, 4) = _time;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, tmp_4, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1, 2)
    jmi_array_rec_1(tmp_4, 1)->x = tmp_5;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 1, 1, 1)
    jmi_array_rec_1(tmp_4, 2)->x = tmp_6;
    jmi_array_ref_1(jmi_array_rec_1(tmp_4, 1)->x, 1) = func_CCodeGenArrayTests_RecordArray5_g_exp1(1.0, tmp_1);
    jmi_array_ref_1(jmi_array_rec_1(tmp_4, 1)->x, 2) = func_CCodeGenArrayTests_RecordArray5_g_exp1(2.0, tmp_2);
    jmi_array_ref_1(jmi_array_rec_1(tmp_4, 2)->x, 1) = func_CCodeGenArrayTests_RecordArray5_g_exp1(_time, tmp_3);
    _y_0 = func_CCodeGenArrayTests_RecordArray5_f_exp0(tmp_4);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray5;

model RecordArray6
    record R1
        Real[:] x;
    end R1;
    
    record R2
        R1[:] r1;
    end R2;
    
    function f
        input R2 r2;
        output Real y;
    algorithm
        for i in 1:size(r2.r1,1) loop
            y := y + sum(r2.r1[i].x);
        end for;
    end f;
    
    Real y = f(R2({R1({1,2}),R1({time})}));
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray6",
        description="Test for bug in #5346",
        inline_functions="none",
        variability_propagation=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R2_1_r, tmp_1)
    JMI_ARR(STACK, R1_0_r, R1_0_ra, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1)
    JMI_ARRAY_INIT_1(STACK, R1_0_r, R1_0_ra, tmp_2, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_rec_1(tmp_2, 1)->x = tmp_3;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1, 1)
    jmi_array_rec_1(tmp_2, 2)->x = tmp_4;
    tmp_1->r1 = tmp_2;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1->r1, 1)->x, 1) = 1.0;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1->r1, 1)->x, 2) = 2.0;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1->r1, 2)->x, 1) = _time;
    _y_0 = func_CCodeGenArrayTests_RecordArray6_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray6;

model RecordArray7
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    input Boolean b;
    Real y = f(if b then {R({1,2}),R({time})} else {R({1}),R({time, 2})});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray7",
        description="Test for bug in #5346",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_4, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1)
    if (_b_0) {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, tmp_1, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
        jmi_array_rec_1(tmp_1, 1)->x = tmp_2;
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
        jmi_array_rec_1(tmp_1, 2)->x = tmp_3;
        jmi_array_ref_1(jmi_array_rec_1(tmp_1, 1)->x, 1) = 1.0;
        jmi_array_ref_1(jmi_array_rec_1(tmp_1, 1)->x, 2) = 2.0;
        jmi_array_ref_1(jmi_array_rec_1(tmp_1, 2)->x, 1) = _time;
    } else {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, tmp_4, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 1, 1, 1)
        jmi_array_rec_1(tmp_4, 1)->x = tmp_5;
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1, 2)
        jmi_array_rec_1(tmp_4, 2)->x = tmp_6;
        jmi_array_ref_1(jmi_array_rec_1(tmp_4, 1)->x, 1) = 1.0;
        jmi_array_ref_1(jmi_array_rec_1(tmp_4, 2)->x, 1) = _time;
        jmi_array_ref_1(jmi_array_rec_1(tmp_4, 2)->x, 2) = 2.0;
    }
    _y_1 = func_CCodeGenArrayTests_RecordArray7_f_exp0(COND_EXP_EQ(_b_0, JMI_TRUE, tmp_1, tmp_4));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray7;

model RecordArray8
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    parameter Boolean b = false;
    Real y = f({if b then R({1,2}) else R({1}), if b then R({time}) else R({time, 2})});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray8",
        description="Test for bug in #5346",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_rec_1(tmp_1, 1)->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 2)->x = tmp_3;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 1)->x, 1) = 1.0;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 2)->x, 1) = _time;
    jmi_array_ref_1(jmi_array_rec_1(tmp_1, 2)->x, 2) = 2.0;
    _y_1 = func_CCodeGenArrayTests_RecordArray8_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray8;

model RecordArray9
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:,:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            for j in 1:size(r,2) loop
                y := y + sum(r[i, j].x);
            end for;
        end for;
    end f;
    
    parameter Boolean b = false;
    Real y = f({if b then {R({1,2}), R({3})} else {R({1})}, if b then {R({time}), R({time})} else {R({time, 2})}});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray9",
        description="Test for bug in #5346",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, tmp_1, 2, 2)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARRAY_INIT_2(STACK, R_0_r, R_0_ra, tmp_1, 2, 2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_rec_2(tmp_1, 1,1)->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_rec_2(tmp_1, 2,1)->x = tmp_3;
    jmi_array_ref_1(jmi_array_rec_2(tmp_1, 1,1)->x, 1) = 1.0;
    jmi_array_ref_1(jmi_array_rec_2(tmp_1, 2,1)->x, 1) = _time;
    jmi_array_ref_1(jmi_array_rec_2(tmp_1, 2,1)->x, 2) = 2.0;
    _y_1 = func_CCodeGenArrayTests_RecordArray9_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray9;

model RecordArray10
    record R
        Real[:] x;
        String[:] s;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    function g
        input Real x;
        input String s;
        output Real y = f({R({1,2}, {s}),R({time}, {s + "s2", s + "s3"})});
        algorithm
    end g;
    
    Real y = g(time, "s1");
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray10",
        description="Test for bug in #5346",
        inline_functions="none",
        template="
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
void func_CCodeGenArrayTests_RecordArray10_g_def0(jmi_real_t x_v, jmi_string_t s_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_ARR(STACK, R_0_r, R_0_ra, temp_1_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_2_a, 2, 1)
    JMI_ARR(STACK, jmi_string_t, jmi_string_array_t, temp_3_a, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_4_a, 1, 1)
    JMI_ARR(STACK, jmi_string_t, jmi_string_array_t, temp_5_a, 2, 1)
    JMI_DEF_STR_DYNA(tmp_1)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, temp_1_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_2_a, 2, 1, 2)
    jmi_array_ref_1(temp_2_a, 1) = 1;
    jmi_array_ref_1(temp_2_a, 2) = 2;
    JMI_ARRAY_INIT_1(STACK, jmi_string_t, jmi_string_array_t, temp_3_a, 1, 1, 1)
    JMI_ASG(STR, jmi_array_ref_1(temp_3_a, 1), s_v)
    jmi_array_rec_1(temp_1_a, 1)->x = temp_2_a;
    JMI_ASG(STR_ARR, jmi_array_rec_1(temp_1_a, 1)->s, temp_3_a)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_4_a, 1, 1, 1)
    jmi_array_ref_1(temp_4_a, 1) = _time;
    JMI_ARRAY_INIT_1(STACK, jmi_string_t, jmi_string_array_t, temp_5_a, 2, 1, 2)
    JMI_INI_STR_DYNA(tmp_1, JMI_LEN(s_v) + 2)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", s_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"s2\");
    JMI_ASG(STR, jmi_array_ref_1(temp_5_a, 1), tmp_1)
    JMI_INI_STR_DYNA(tmp_2, JMI_LEN(s_v) + 2)
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", s_v);
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", \"s3\");
    JMI_ASG(STR, jmi_array_ref_1(temp_5_a, 2), tmp_2)
    jmi_array_rec_1(temp_1_a, 2)->x = temp_4_a;
    JMI_ASG(STR_ARR, jmi_array_rec_1(temp_1_a, 2)->s, temp_5_a)
    y_v = func_CCodeGenArrayTests_RecordArray10_f_exp1(temp_1_a);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenArrayTests_RecordArray10_g_exp0(jmi_real_t x_v, jmi_string_t s_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenArrayTests_RecordArray10_g_def0(x_v, s_v, &y_v);
    return y_v;
}

void func_CCodeGenArrayTests_RecordArray10_f_def1(R_0_ra* r_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    i_0in = 0;
    i_0ie = floor((jmi_array_size(r_a, 0)) - (1));
    for (i_0i = 1; i_0in <= i_0ie; i_0i = 1 + (++i_0in)) {
        temp_1_v = 0.0;
        i1_1in = 0;
        i1_1ie = floor((jmi_array_size(jmi_array_rec_1(r_a, i_0i)->x, 0)) - (1));
        for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
            temp_1_v = temp_1_v + jmi_array_val_1(jmi_array_rec_1(r_a, i_0i)->x, i1_1i);
        }
        y_v = y_v + temp_1_v;
    }
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenArrayTests_RecordArray10_f_exp1(R_0_ra* r_a) {
    JMI_DEF(REA, y_v)
    func_CCodeGenArrayTests_RecordArray10_f_def1(r_a, &y_v);
    return y_v;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = func_CCodeGenArrayTests_RecordArray10_g_exp0(_time, \"s1\");
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end RecordArray10;

model RecordArray11
    record R
        Boolean b;
    end R;
    
    R[1] r2 = {R(time>1)};
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray11",
        description="Test for bug in #5487",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _r2_1_b_0 = _sw(0);
    pre_r2_1_b_0 = _r2_1_b_0;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray11;

model RecordArray12
    record R
        Boolean[:] b;
    end R;
    
    R r2 = if time > 1 then R({time>1}) else R({time>2});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray12",
        description="Test for bug in #5487",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
        }
    } else {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - (2.0), _sw(1), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
        }
    }
    _r2_b_1_0 = COND_EXP_EQ(_sw(0), JMI_TRUE, _sw(0), _sw(1));
    pre_r2_b_1_0 = _r2_b_1_0;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray12;

model RecordArray13
    record R
        Boolean[:] b;
    end R;
    
    R[:] r2 = if time > 1 then {R({time>1})} else {R({time>2})};
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordArray13",
        description="Test for bug in #5487",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
        }
    } else {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - (2.0), _sw(1), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
        }
    }
    _r2_1_b_1_0 = COND_EXP_EQ(_sw(0), JMI_TRUE, _sw(0), _sw(1));
    pre_r2_1_b_1_0 = _r2_1_b_1_0;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RecordArray13;

end CCodeGenArrayTests;
