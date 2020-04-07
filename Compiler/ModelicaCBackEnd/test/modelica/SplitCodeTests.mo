/*
    Copyright (C) 2016 Modelon AB

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


package SplitCodeTests

model BlockSetupSplit1
    function f
        input Real[:] x;
        output Real y = sum(x);
        algorithm
        annotation(Inline=false);
    end f;

    Real x;
    Real y;
    Real z[100];
equation
    der(x) = f({time});
    der(y) = f({time+1});
    when time > 2 then
        reinit(x, f({1}));
    end when;
    when time > 3 then
        reinit(y, f({2}));
    end when;
    der(z) = -ones(100);
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockSetupSplit1",
        description="Test setup block headers not generated when spliting disable by option",
        cc_split_element_limit=0,
        relational_time_events=false,
        variability_propagation=false,
        template="
$C_function_headers$
$CAD_function_headers$
$C_dae_blocks_residual_functions$
",
        generatedCode="
void func_SplitCodeTests_BlockSetupSplit1_f_def0(jmi_array_t* x_a, jmi_real_t* y_o);
jmi_real_t func_SplitCodeTests_BlockSetupSplit1_f_exp0(jmi_array_t* x_a);


void dae_block_0_set_up(jmi_t* jmi) {
    JMI_GLOBAL(tmp_1_computed) = 0;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871118;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871118;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_102 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_102, LOG_EXP_NOT(pre_temp_1_102))) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
            jmi_array_ref_1(tmp_2, 1) = 1.0;
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_3) = JMI_CACHED(tmp_1, func_SplitCodeTests_BlockSetupSplit1_f_exp0(tmp_2));
                if (JMI_GLOBAL(tmp_3) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_3);
                    jmi->reinit_triggered = 1;
                }
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

void dae_block_1_set_up(jmi_t* jmi) {
    JMI_GLOBAL(tmp_4_computed) = 0;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 1, 1)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871119;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871119;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _time - (3), _sw(1), JMI_REL_GT);
            }
            _temp_2_103 = _sw(1);
        }
        if (LOG_EXP_AND(_temp_2_103, LOG_EXP_NOT(pre_temp_2_103))) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 1, 1, 1)
            jmi_array_ref_1(tmp_5, 1) = 2.0;
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_6) = JMI_CACHED(tmp_4, func_SplitCodeTests_BlockSetupSplit1_f_exp0(tmp_5));
                if (JMI_GLOBAL(tmp_6) != _y_1) {
                    _y_1 = JMI_GLOBAL(tmp_6);
                    jmi->reinit_triggered = 1;
                }
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockSetupSplit1;


model BlockSetupSplit2
    function f
        input Real[:] x;
        output Real y = sum(x);
        algorithm
        annotation(Inline=false);
    end f;

    Real x;
    Real y;
    Real z[100];
equation
    der(x) = f({time});
    der(y) = f({time+1});
    when time > 2 then
        reinit(x, f({1}));
    end when;
    when time > 3 then
        reinit(y, f({2}));
    end when;
    der(z) = -ones(100);
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockSetupSplit2",
        description="Test setup block spliting with element limit",
        cc_split_element_limit=1,
        relational_time_events=false,
        variability_propagation=false,
        template="
$C_function_headers$
$CAD_function_headers$
$C_dae_blocks_residual_functions$
",
        generatedCode="
void func_SplitCodeTests_BlockSetupSplit2_f_def0(jmi_array_t* x_a, jmi_real_t* y_o);
jmi_real_t func_SplitCodeTests_BlockSetupSplit2_f_exp0(jmi_array_t* x_a);
extern void dae_block_0_set_up(jmi_t* jmi);
extern void dae_block_1_set_up(jmi_t* jmi);


void dae_block_0_set_up(jmi_t* jmi) {
    JMI_GLOBAL(tmp_1_computed) = 0;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871118;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871118;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_102 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_102, LOG_EXP_NOT(pre_temp_1_102))) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
            jmi_array_ref_1(tmp_2, 1) = 1.0;
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_3) = JMI_CACHED(tmp_1, func_SplitCodeTests_BlockSetupSplit2_f_exp0(tmp_2));
                if (JMI_GLOBAL(tmp_3) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_3);
                    jmi->reinit_triggered = 1;
                }
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

void dae_block_1_set_up(jmi_t* jmi) {
    JMI_GLOBAL(tmp_4_computed) = 0;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 1, 1)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871119;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536871119;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _time - (3), _sw(1), JMI_REL_GT);
            }
            _temp_2_103 = _sw(1);
        }
        if (LOG_EXP_AND(_temp_2_103, LOG_EXP_NOT(pre_temp_2_103))) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 1, 1, 1)
            jmi_array_ref_1(tmp_5, 1) = 2.0;
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_6) = JMI_CACHED(tmp_4, func_SplitCodeTests_BlockSetupSplit2_f_exp0(tmp_5));
                if (JMI_GLOBAL(tmp_6) != _y_1) {
                    _y_1 = JMI_GLOBAL(tmp_6);
                    jmi->reinit_triggered = 1;
                }
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockSetupSplit2;

model SplitCodeTest1
  parameter Real[:] p = {1,2};
  Real[:] x = p .+ time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTest1",
            description="Test negative split options",
            cc_split_element_limit=0,
            template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p_1_0 = (1);
    _p_2_1 = (2);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTest1;

model SplitCodeTest2
  parameter Real[:] p = {1,2};
  Real[:] x = p .+ time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTest2",
            description="Test negative split options",
            cc_split_element_limit=1,
            cc_split_function_limit=-1,
            template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
int model_init_eval_independent_start_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p_1_0 = (1);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_independent_start_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p_2_1 = (2);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_init_eval_independent_start_0(jmi_t* jmi);
int model_init_eval_independent_start_1(jmi_t* jmi);

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_init_eval_independent_start_0(jmi);
    ef |= model_init_eval_independent_start_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_0(jmi_t* jmi);
int model_ode_initialize_1(jmi_t* jmi);

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_initialize_0(jmi);
    ef |= model_ode_initialize_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTest2;

model SplitCodeTest3
  Real[:] x = (1:11) .+ time;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SplitCodeTest3",
        description="Test split options",
        cc_split_element_limit=2,
        cc_split_function_limit=2,
        template="$C_ode_derivatives$",
        generatedCode="
int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_0 = 1 + _time;
    _x_2_1 = _x_1_0 + 1;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_3_2 = _x_2_1 + 1;
    _x_4_3 = _x_2_1 + 2;
    JMI_DYNAMIC_FREE()
    return ef;
}

/*** SPLIT FILE ***/

int model_ode_derivatives_2(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_5_4 = _x_2_1 + 3;
    _x_6_5 = _x_2_1 + 4;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_3(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_7_6 = _x_2_1 + 5;
    _x_8_7 = _x_2_1 + 6;
    JMI_DYNAMIC_FREE()
    return ef;
}

/*** SPLIT FILE ***/

int model_ode_derivatives_4(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_9_8 = _x_2_1 + 7;
    _x_10_9 = _x_2_1 + 8;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_5(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_11_10 = _x_2_1 + 9;
    JMI_DYNAMIC_FREE()
    return ef;
}

/*** SPLIT FILE ***/

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);
int model_ode_derivatives_2(jmi_t* jmi);
int model_ode_derivatives_3(jmi_t* jmi);
int model_ode_derivatives_4(jmi_t* jmi);
int model_ode_derivatives_5(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    ef |= model_ode_derivatives_2(jmi);
    ef |= model_ode_derivatives_3(jmi);
    ef |= model_ode_derivatives_4(jmi);
    ef |= model_ode_derivatives_5(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTest3;

model SplitCodeTestFunctionCallAlgorithm1
    Real[2] y1;
    Real[2] y2;
algorithm
    y1 := 1:2;
algorithm
    y2 := 1:2;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTestFunctionCallAlgorithm1",
            description="Split with temporaries, algorithms",
            cc_split_element_limit=2,
            common_subexp_elim=false,
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y1_1_0 = 1;
    _y1_2_1 = 2;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y2_1_2 = 1;
    _y2_2_3 = 2;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTestFunctionCallAlgorithm1;

model SplitCodeTestFunctionCallInput1
    function f
        input Real[:] x;
        output Real y = sum(x);
    algorithm
        annotation(Inline=false);
    end f;
    
    Real y1 = f({time,time});
    Real y2 = f({time,time});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTestFunctionCallInput1",
            description="Split with temporaries, function call input",
            cc_split_element_limit=4,
            common_subexp_elim=false,
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _time;
    jmi_array_ref_1(tmp_1, 2) = _time;
    _y1_0 = func_SplitCodeTests_SplitCodeTestFunctionCallInput1_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _time;
    jmi_array_ref_1(tmp_2, 2) = _time;
    _y2_1 = func_SplitCodeTests_SplitCodeTestFunctionCallInput1_f_exp0(tmp_2);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTestFunctionCallInput1;

model SplitCodeTestFunctionCallLeft1
    function f
        input Real[:] x;
        output Real[:] y = x;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real[:] y1 = f({time, time});
    Real[:] y2 = f({time, time});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTestFunctionCallLeft1",
            description="Split with temporaries, function call left",
            cc_split_element_limit=11,
            common_subexp_elim=false,
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _time;
    jmi_array_ref_1(tmp_2, 2) = _time;
    func_SplitCodeTests_SplitCodeTestFunctionCallLeft1_f_def0(tmp_2, tmp_1);
    memcpy(&_y1_1_0, &jmi_array_val_1(tmp_1, 1), 2 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1, 2)
    jmi_array_ref_1(tmp_4, 1) = _time;
    jmi_array_ref_1(tmp_4, 2) = _time;
    func_SplitCodeTests_SplitCodeTestFunctionCallLeft1_f_def0(tmp_4, tmp_3);
    memcpy(&_y2_1_2, &jmi_array_val_1(tmp_3, 1), 2 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTestFunctionCallLeft1;


model SplitCodeTestSubscriptedExp1
    Integer i = integer(time);
    Real[:] x = 1:2;
    Real y1 = x[i];
    Real y2 = x[i];

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SplitCodeTestSubscriptedExp1",
        description="Split with temporaries, subscripted exp",
        cc_split_element_limit=2,
        common_subexp_elim=false,
        template="$C_ode_derivatives$",
        generatedCode="
int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre_i_0), _sw(0), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (pre_i_0 + 1.0), _sw(1), JMI_REL_GEQ);
    }
    _i_0 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_time), pre_i_0);
    pre_i_0 = _i_0;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    _y1_3 = jmi_array_val_1(tmp_1, _i_0);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_2(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = 1.0;
    jmi_array_ref_1(tmp_2, 2) = 2.0;
    _y2_4 = jmi_array_val_1(tmp_2, _i_0);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);
int model_ode_derivatives_2(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    ef |= model_ode_derivatives_2(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTestSubscriptedExp1;

model SplitCodeTestStartValueZero
  parameter Real[:] p1 = {1,0};
  parameter Real[:] p2 = {3,4};

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTestStartValueZero",
            description="Test split with start values that are zero",
            cc_split_element_limit=2,
            template="
$C_model_init_eval_independent_start$
",
            generatedCode="
int model_init_eval_independent_start_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p1_1_0 = (1);
    _p2_1_2 = (3);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_independent_start_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p2_2_3 = (4);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_independent_start_0(jmi_t* jmi);
int model_init_eval_independent_start_1(jmi_t* jmi);

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_init_eval_independent_start_0(jmi);
    ef |= model_init_eval_independent_start_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTestStartValueZero;

model SplitCodeTestGlobals1
    record R
        Real[4] a;
    end R;
    
    constant R[2] c = {R(1:4), R(5:8)};
    
    function f
        input Real x;
        input Integer i;
        output Real y = x + c[i].a[i];
    algorithm
        annotation(Inline=false);
    end f;

    Real y = f(time, 1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SplitCodeTestGlobals1",
        description="Test code splitting of globals, splitting files between functions",
        cc_split_function_limit_globals=2,
        template="$C_model_init_eval_independent_globals$",
        generatedCode="
jmi_array_t* jmi_global_tmp_1(jmi_t* jmi) {
    static jmi_real_t tmp_1_var[4] = {1.0,2.0,3.0,4.0,};
    JMI_ARR(DATA, jmi_real_t, jmi_array_t, tmp_1, 4, 1)
    JMI_ARRAY_INIT_1(DATA, jmi_real_t, jmi_array_t, tmp_1, 4, 1, 4)
    return tmp_1;
}

jmi_array_t* jmi_global_tmp_2(jmi_t* jmi) {
    static jmi_real_t tmp_2_var[4] = {5.0,6.0,7.0,8.0,};
    JMI_ARR(DATA, jmi_real_t, jmi_array_t, tmp_2, 4, 1)
    JMI_ARRAY_INIT_1(DATA, jmi_real_t, jmi_array_t, tmp_2, 4, 1, 4)
    return tmp_2;
}

/*** SPLIT FILE ***/

jmi_array_t* jmi_global_tmp_1(jmi_t* jmi);
jmi_array_t* jmi_global_tmp_2(jmi_t* jmi);

R_0_ra* jmi_global_tmp_3(jmi_t* jmi) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, R_0_r, R_0_ra, tmp_3, -1, 1)
    JMI_GLOBALS_INIT()
    JMI_ARRAY_INIT_1(HEAP, R_0_r, R_0_ra, tmp_3, 2, 1, 2)
    jmi_array_rec_1(tmp_3, 1)->a = jmi_global_tmp_1(jmi);
    jmi_array_rec_1(tmp_3, 2)->a = jmi_global_tmp_2(jmi);
    JMI_GLOBALS_FREE()
    JMI_DYNAMIC_FREE()
    return tmp_3;
}

int model_init_eval_independent_globals_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(SplitCodeTests_SplitCodeTestGlobals1_c) = jmi_global_tmp_3(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

/*** SPLIT FILE ***/

jmi_array_t* jmi_global_tmp_1(jmi_t* jmi);
jmi_array_t* jmi_global_tmp_2(jmi_t* jmi);
R_0_ra* jmi_global_tmp_3(jmi_t* jmi);

int model_init_eval_independent_globals_0(jmi_t* jmi);

int model_init_eval_independent_globals(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_init_eval_independent_globals_0(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end SplitCodeTestGlobals1;

model SplitCodeTestGlobals2
    record R
        Real[4] a;
    end R;
    
    constant R[1] c = {R(1:4)};
    
    function f
        input Real x;
        input Integer i;
        output Real y = x + c[i].a[i];
    algorithm
        annotation(Inline=false);
    end f;

    Real y = f(time, 1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SplitCodeTestGlobals2",
        description="Test code splitting of globals, splitting arrays into multiple functions",
        cc_split_function_limit_globals=2,
        cc_split_element_limit=2,
        template="$C_model_init_eval_independent_globals$",
        generatedCode="
jmi_array_t* jmi_global_tmp_1(jmi_t* jmi) {
    static jmi_real_t tmp_1_var[4] = {1.0,2.0,3.0,4.0,};
    JMI_ARR(DATA, jmi_real_t, jmi_array_t, tmp_1, 4, 1)
    JMI_ARRAY_INIT_1(DATA, jmi_real_t, jmi_array_t, tmp_1, 4, 1, 4)
    return tmp_1;
}

R_0_ra* jmi_global_tmp_2(jmi_t* jmi) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, R_0_r, R_0_ra, tmp_2, -1, 1)
    JMI_GLOBALS_INIT()
    JMI_ARRAY_INIT_1(HEAP, R_0_r, R_0_ra, tmp_2, 1, 1, 1)
    jmi_array_rec_1(tmp_2, 1)->a = jmi_global_tmp_1(jmi);
    JMI_GLOBALS_FREE()
    JMI_DYNAMIC_FREE()
    return tmp_2;
}

/*** SPLIT FILE ***/

jmi_array_t* jmi_global_tmp_1(jmi_t* jmi);
R_0_ra* jmi_global_tmp_2(jmi_t* jmi);

int model_init_eval_independent_globals_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(SplitCodeTests_SplitCodeTestGlobals2_c) = jmi_global_tmp_2(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_independent_globals_0(jmi_t* jmi);

int model_init_eval_independent_globals(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_init_eval_independent_globals_0(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end SplitCodeTestGlobals2;

model SplitCodeTestGlobals3
    
    constant Real[4] c = 0:3;
    
    function f
        input Real x;
        input Integer i;
        output Real y = x + c[i];
    algorithm
        annotation(Inline=false);
    end f;

    Real y = f(time, 1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SplitCodeTestGlobals3",
        description="Test code splitting of globals, splitting array with a zero",
        cc_split_element_limit=1,
        template="$C_model_init_eval_independent_globals$",
        generatedCode="
jmi_array_t* jmi_global_tmp_1(jmi_t* jmi) {
    static jmi_real_t tmp_1_var[4] = {0,1,2,3,};
    JMI_ARR(DATA, jmi_real_t, jmi_array_t, tmp_1, 4, 1)
    JMI_ARRAY_INIT_1(DATA, jmi_real_t, jmi_array_t, tmp_1, 4, 1, 4)
    return tmp_1;
}

int model_init_eval_independent_globals_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(SplitCodeTests_SplitCodeTestGlobals3_c) = jmi_global_tmp_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_independent_globals_0(jmi_t* jmi);

int model_init_eval_independent_globals(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_init_eval_independent_globals_0(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTestGlobals3;

end SplitCodeTests;
