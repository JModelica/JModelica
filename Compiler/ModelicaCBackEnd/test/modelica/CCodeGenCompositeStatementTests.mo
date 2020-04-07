/*
    Copyright (C) 20019 Modelon AB

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


package CCodeGenCompositeStatementTests

    model RecordStmt1
        record R
            Real x;
        end R;
        
        function f
            input R r;
            constant R c(x=1);
            output R[:] y = {c, r};
        algorithm
        end f;
        
        R[:] r = f(R(time));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordStmt1",
        description="",
        template="
$C_functions$
",
        generatedCode="
void func_CCodeGenCompositeStatementTests_RecordStmt1_f_def0(R_0_r* r_v, R_0_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, y_an, 2, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, y_an, 2, 1, 2)
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, temp_1_a, 2, 1, 2)
    *jmi_array_rec_1(temp_1_a, 1) = *JMI_GLOBAL(CCodeGenCompositeStatementTests_RecordStmt1_f_c);
    *jmi_array_rec_1(temp_1_a, 2) = *r_v;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_rec_1(y_a, i1_0i)->x = jmi_array_rec_1(temp_1_a, i1_0i)->x;
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
    end RecordStmt1;

    model RecordStmt2
        record R
            Real[1] x;
        end R;
        
        function f
            input R r;
            constant R c(x={1});
            output R[:] y = {c, r};
        algorithm
        end f;
        
        R[:] r = f(R({time}));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordStmt2",
        description="",
        template="
$C_functions$
",
        generatedCode="
void func_CCodeGenCompositeStatementTests_RecordStmt2_f_def0(R_0_r* r_v, R_0_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, y_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, y_an, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
        jmi_array_rec_1(y_an, 1)->x = tmp_1;
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
        jmi_array_rec_1(y_an, 2)->x = tmp_2;
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, temp_1_a, 2, 1, 2)
    *jmi_array_rec_1(temp_1_a, 1) = *JMI_GLOBAL(CCodeGenCompositeStatementTests_RecordStmt2_f_c);
    *jmi_array_rec_1(temp_1_a, 2) = *r_v;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        i2_1in = 0;
        i2_1ie = floor((1) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_ref_1(jmi_array_rec_1(y_a, i1_0i)->x, i2_1i) = jmi_array_val_1(jmi_array_rec_1(temp_1_a, i1_0i)->x, i2_1i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
    end RecordStmt2;

    model RecordStmt3
        
        record R1
            Real[1] x;
        end R1;
        
        record R2
            R1 r;
            Real x = 0;
        end R2;
        
        record R3
            R2 r;
        end R3;
        
        function f
            input R3 r;
            R3 c(r(r(x={1})));
            output R3[:] y = {c, r};
        algorithm
        end f;
        
        R3[:] r = f(R3(R2(R1({time}))));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordStmt3",
        description="",
        template="
$C_functions$
",
        generatedCode="
void func_CCodeGenCompositeStatementTests_RecordStmt3_f_def0(R3_2_r* r_v, R3_2_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R3_2_r, c_v)
    JMI_RECORD_STATIC(R2_1_r, tmp_1)
    JMI_RECORD_STATIC(R1_0_r, tmp_2)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARR(STACK, R3_2_r, R3_2_ra, y_an, 2, 1)
    JMI_RECORD_STATIC(R2_1_r, tmp_4)
    JMI_RECORD_STATIC(R1_0_r, tmp_5)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 1, 1)
    JMI_RECORD_STATIC(R2_1_r, tmp_7)
    JMI_RECORD_STATIC(R1_0_r, tmp_8)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_9, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 1)
    JMI_ARR(STACK, R3_2_r, R3_2_ra, temp_2_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    jmi_real_t i2_3i;
    jmi_int_t i2_3ie;
    jmi_int_t i2_3in;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    tmp_2->x = tmp_3;
    tmp_1->r = tmp_2;
    c_v->r = tmp_1;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 1, 1)
    jmi_array_ref_1(temp_1_a, 1) = 1;
    i1_0in = 0;
    i1_0ie = floor((1) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(c_v->r->r->x, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    c_v->r->x = 0;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R3_2_r, R3_2_ra, y_an, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 1, 1, 1)
        tmp_5->x = tmp_6;
        tmp_4->r = tmp_5;
        jmi_array_rec_1(y_an, 1)->r = tmp_4;
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_9, 1, 1, 1)
        tmp_8->x = tmp_9;
        tmp_7->r = tmp_8;
        jmi_array_rec_1(y_an, 2)->r = tmp_7;
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, R3_2_r, R3_2_ra, temp_2_a, 2, 1, 2)
    jmi_array_rec_1(temp_2_a, 1)->r = jmi_dynamic_function_pool_alloc(&dyn_mem, 1*sizeof(R2_1_r), TRUE);
    jmi_array_rec_1(temp_2_a, 1)->r->r = jmi_dynamic_function_pool_alloc(&dyn_mem, 1*sizeof(R1_0_r), TRUE);
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, jmi_array_rec_1(temp_2_a, 1)->r->r->x, 1, 1, 1)
    i1_1in = 0;
    i1_1ie = floor((1) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(jmi_array_rec_1(temp_2_a, 1)->r->r->x, i1_1i) = jmi_array_val_1(c_v->r->r->x, i1_1i);
    }
    jmi_array_rec_1(temp_2_a, 1)->r->x = c_v->r->x;
    *jmi_array_rec_1(temp_2_a, 2) = *r_v;
    i1_2in = 0;
    i1_2ie = floor((2) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        i2_3in = 0;
        i2_3ie = floor((1) - (1));
        for (i2_3i = 1; i2_3in <= i2_3ie; i2_3i = 1 + (++i2_3in)) {
            jmi_array_ref_1(jmi_array_rec_1(y_a, i1_2i)->r->r->x, i2_3i) = jmi_array_val_1(jmi_array_rec_1(temp_2_a, i1_2i)->r->r->x, i2_3i);
        }
        jmi_array_rec_1(y_a, i1_2i)->r->x = jmi_array_rec_1(temp_2_a, i1_2i)->r->x;
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
    end RecordStmt3;

    model RecordStmt4
        
        record R1
            Real[1] x;
        end R1;
        
        function f
            input Real x;
            constant Real[:] c = {1};
            output R1[:] y = {R1(c)};
        algorithm
            annotation(Inline=false);
        end f;
        
        R1[:] y = f(time);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordStmt4",
        description="Primitive array in record array initialization",
        template="
$C_functions$
",
        generatedCode="
void func_CCodeGenCompositeStatementTests_RecordStmt4_f_def0(jmi_real_t x_v, R1_0_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R1_0_r, R1_0_ra, y_an, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STACK, R1_0_r, R1_0_ra, temp_1_a, 1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R1_0_r, R1_0_ra, y_an, 1, 1, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
        jmi_array_rec_1(y_an, 1)->x = tmp_1;
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, R1_0_r, R1_0_ra, temp_1_a, 1, 1, 1)
    jmi_array_rec_1(temp_1_a, 1)->x = JMI_GLOBAL(CCodeGenCompositeStatementTests_RecordStmt4_f_c);
    i1_0in = 0;
    i1_0ie = floor((1) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        i2_1in = 0;
        i2_1ie = floor((1) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_ref_1(jmi_array_rec_1(y_a, i1_0i)->x, i2_1i) = jmi_array_val_1(jmi_array_rec_1(temp_1_a, i1_0i)->x, i2_1i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
    end RecordStmt4;
    
    model RecordStmt5
        
        record R1
            Real[1] x;
        end R1;
        
        record R2
            R1[1] r1;
        end R2;
        
        function f
            input Real x;
            constant Real[:] c = {1};
            output R2[:] y = {R2({R1(c)})};
        algorithm
            annotation(Inline=false);
        end f;
        
        R2[:] y = f(time);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RecordStmt5",
        description="Record array in record array initialization",
        template="
$C_functions$
",
        generatedCode="
void func_CCodeGenCompositeStatementTests_RecordStmt5_f_def0(jmi_real_t x_v, R2_1_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R2_1_r, R2_1_ra, y_an, 1, 1)
    JMI_ARR(STACK, R1_0_r, R1_0_ra, tmp_1, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARR(STACK, R2_1_r, R2_1_ra, temp_1_a, 1, 1)
    JMI_ARR(STACK, R1_0_r, R1_0_ra, temp_2_a, 1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    jmi_real_t i3_2i;
    jmi_int_t i3_2ie;
    jmi_int_t i3_2in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R2_1_r, R2_1_ra, y_an, 1, 1, 1)
        JMI_ARRAY_INIT_1(STACK, R1_0_r, R1_0_ra, tmp_1, 1, 1, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
        jmi_array_rec_1(tmp_1, 1)->x = tmp_2;
        jmi_array_rec_1(y_an, 1)->r1 = tmp_1;
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, R2_1_r, R2_1_ra, temp_1_a, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, R1_0_r, R1_0_ra, temp_2_a, 1, 1, 1)
    jmi_array_rec_1(temp_2_a, 1)->x = JMI_GLOBAL(CCodeGenCompositeStatementTests_RecordStmt5_f_c);
    jmi_array_rec_1(temp_1_a, 1)->r1 = temp_2_a;
    i1_0in = 0;
    i1_0ie = floor((1) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        i2_1in = 0;
        i2_1ie = floor((1) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            i3_2in = 0;
            i3_2ie = floor((1) - (1));
            for (i3_2i = 1; i3_2in <= i3_2ie; i3_2i = 1 + (++i3_2in)) {
                jmi_array_ref_1(jmi_array_rec_1(jmi_array_rec_1(y_a, i1_0i)->r1, i2_1i)->x, i3_2i) = jmi_array_val_1(jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i1_0i)->r1, i2_1i)->x, i3_2i);
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
    end RecordStmt5;

end CCodeGenCompositeStatementTests;
