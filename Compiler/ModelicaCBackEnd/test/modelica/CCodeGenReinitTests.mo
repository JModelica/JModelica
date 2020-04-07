/*
    Copyright (C) 2009-2018 Modelon AB

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


package CCodeGenReinitTests

model ReinitCTest1
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest1",
        description="",
        variability_propagation=false,
        relational_time_events=false,
        template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t tmp_1;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    _der_x_3 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_3 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = 0.0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = 1.0;
                if (JMI_GLOBAL(tmp_1) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_1);
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


-----
")})));
end ReinitCTest1;


model ReinitCTest2
    Real x,y;
equation
    der(x) = 1;
	der(y) = 2;
    when y > 2 then
        reinit(x, 1);
    end when;
    when x > 2 then
        reinit(y, 1);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest2",
        description="",
        variability_propagation=false,
        template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _y_1;
    _der_x_6 = 1;
    _der_y_7 = 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _y_1 - (2), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (2), _sw(1), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_6 = 1;
    _der_y_7 = 2;
    _y_1 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _y_1 - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    _x_0 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (2), _sw(1), JMI_REL_GT);
    }
    _temp_2_3 = _sw(1);
    pre_temp_1_2 = JMI_FALSE;
    pre_temp_2_3 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _y_1 - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_2 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = 1.0;
                if (JMI_GLOBAL(tmp_1) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_1);
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

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _x_0 - (2), _sw(1), JMI_REL_GT);
            }
            _temp_2_3 = _sw(1);
        }
        if (LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_2) = 1.0;
                if (JMI_GLOBAL(tmp_2) != _y_1) {
                    _y_1 = JMI_GLOBAL(tmp_2);
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


-----
")})));
end ReinitCTest2;

model ReinitCTest3
    Real x,y;
equation
    der(x) = 1;
    der(y) = 2;
    when time > 2 then
        reinit(x, 1);
    elsewhen time > 1 then
        reinit(y, 1);
    end when;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest3",
        description="",
        variability_propagation=false,
        relational_time_events=false,
        template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _y_1;
    _der_x_6 = 1;
    _der_y_7 = 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _time - (1), _sw(1), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_6 = 1;
    _der_y_7 = 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _time - (1), _sw(1), JMI_REL_GT);
    }
    _temp_2_3 = _sw(1);
    _x_0 = 0.0;
    _y_1 = 0.0;
    pre_temp_1_2 = JMI_FALSE;
    pre_temp_2_3 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
        x[1] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
        x[1] = 536870919;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _time - (1), _sw(1), JMI_REL_GT);
            }
            _temp_2_3 = _sw(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_2 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = 1.0;
                if (JMI_GLOBAL(tmp_1) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_1);
                    jmi->reinit_triggered = 1;
                }
            }
        } else {
            if (LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3))) {
                if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                    JMI_GLOBAL(tmp_2) = 1.0;
                    if (JMI_GLOBAL(tmp_2) != _y_1) {
                        _y_1 = JMI_GLOBAL(tmp_2);
                        jmi->reinit_triggered = 1;
                    }
                }
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


-----
")})));
end ReinitCTest3;

model ReinitCTest4
    function f
        input Real[:] x;
        output Real y = sum(x);
        algorithm
        annotation(Inline=false);
    end f;

    Real x;
equation
    der(x) = f({time});
    when time > 2 then
        reinit(x, f({1}));
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest4",
        description="",
        variability_propagation=false,
        relational_time_events=false,
        template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    int tmp_2_computed;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    jmi_array_ref_1(tmp_3, 1) = _time;
    _der_x_3 = func_CCodeGenReinitTests_ReinitCTest4_f_exp0(tmp_3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    dae_block_0_set_up(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    jmi_array_ref_1(tmp_3, 1) = _time;
    _der_x_3 = func_CCodeGenReinitTests_ReinitCTest4_f_exp0(tmp_3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = 0.0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
void dae_block_0_set_up(jmi_t* jmi) {
    JMI_GLOBAL(tmp_2_computed) = 0;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1, 1)
            jmi_array_ref_1(tmp_4, 1) = 1.0;
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = JMI_CACHED(tmp_2, func_CCodeGenReinitTests_ReinitCTest4_f_exp0(tmp_4));
                if (JMI_GLOBAL(tmp_1) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_1);
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


-----
")})));
end ReinitCTest4;

//TODO: The result in this test isn't ideal since the reinit operator is
// handled in the original system as well even though it won't be triggered.
// This is however not the fault of reinit but when initial()...
model ReinitCTest5
    Real x;
equation
    der(x) = time;
    when initial() then
        reinit(x, 1);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest5",
        description="Test the reinit operator in the initial system",
        template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_2) = _x_0;
    _der_x_1 = _time;
    if (_atInitial) {
        JMI_GLOBAL(tmp_2) = 1.0;
        if (JMI_GLOBAL(tmp_2) != _x_0) {
            _x_0 = JMI_GLOBAL(tmp_2);
            jmi->reinit_triggered = 1;
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    _der_x_1 = _time;
    _x_0 = 0.0;
    JMI_GLOBAL(tmp_1) = 1.0;
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

-----
")})));
end ReinitCTest5;

model ReinitCTest6
    Real x;
equation
    der(x) = time;
    when {initial(), time > 2} then
        reinit(x, 1);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest6",
        description="Test the reinit operator in the initial system",
        template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_2) = _x_0;
    _der_x_3 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    _der_x_3 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_1_1 = _sw(0);
    _x_0 = 0.0;
    JMI_GLOBAL(tmp_1) = 1.0;
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1)))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_2) = 1.0;
                if (JMI_GLOBAL(tmp_2) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_2);
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


-----
")})));
end ReinitCTest6;


model ReinitCTest7
    Real x(start = 1);
equation
    der(x) = -x;
  when x < 0.9 then
    reinit(x, 0.8);
  elsewhen x < 0.7 then
    reinit(x, 0.4);
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest7",
            description="Reinit of same var in different elsewhen branches",
            template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_dae_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _x_0;
    _der_x_5 = - _x_0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.9), _sw(0), JMI_REL_LT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
        x[1] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
        x[1] = 536870917;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
            }
            _temp_2_2 = _sw(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.9), _sw(0), JMI_REL_LT);
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = 0.8;
                if (JMI_GLOBAL(tmp_1) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_1);
                    jmi->reinit_triggered = 1;
                }
            }
        } else {
            if (LOG_EXP_AND(_temp_2_2, LOG_EXP_NOT(pre_temp_2_2))) {
                if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                    JMI_GLOBAL(tmp_2) = 0.4;
                    if (JMI_GLOBAL(tmp_2) != _x_0) {
                        _x_0 = JMI_GLOBAL(tmp_2);
                        jmi->reinit_triggered = 1;
                    }
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
end ReinitCTest7;


model ReinitCTest8
    Real x(start = 1);
    Real y(start = 2);
    Real z(start = 3);
equation
    der(x) = -x;
    der(y) = -y;
    der(z) = -z;
  when x < 0.9 then
    reinit(x, 0.8);
    reinit(y, 1.8);
  elsewhen x < 0.7 then
    reinit(z, 2.4);
    reinit(x, 0.4);
  elsewhen x < 0.5 then
    reinit(z, 2.1);
    reinit(x, 0.1);
    reinit(y, 1.1);
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest8",
            description="Reinit of same var in different elsewhen branches, check grouping of several sets of reinits",
            template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_dae_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    jmi_real_t tmp_3;
    jmi_real_t tmp_4;
    jmi_real_t tmp_5;
    jmi_real_t tmp_6;
    jmi_real_t tmp_7;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _y_1;
    JMI_GLOBAL(tmp_3) = _z_2;
    JMI_GLOBAL(tmp_4) = _x_0;
    JMI_GLOBAL(tmp_5) = _z_2;
    JMI_GLOBAL(tmp_6) = _x_0;
    JMI_GLOBAL(tmp_7) = _y_1;
    _der_x_9 = - _x_0;
    _der_y_10 = - _y_1;
    _der_z_11 = - _z_2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_0 - (0.5), _sw(2), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.9), _sw(0), JMI_REL_LT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870922;
        x[1] = 536870921;
        x[2] = 536870920;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
        x[1] = 536870921;
        x[2] = 536870922;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch(jmi, _x_0 - (0.5), _sw(2), JMI_REL_LT);
            }
            _temp_3_5 = _sw(2);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
            }
            _temp_2_4 = _sw(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.9), _sw(0), JMI_REL_LT);
            }
            _temp_1_3 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = 0.8;
                if (JMI_GLOBAL(tmp_1) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_1);
                    jmi->reinit_triggered = 1;
                }
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_2) = 1.8;
                if (JMI_GLOBAL(tmp_2) != _y_1) {
                    _y_1 = JMI_GLOBAL(tmp_2);
                    jmi->reinit_triggered = 1;
                }
            }
        } else {
            if (LOG_EXP_AND(_temp_2_4, LOG_EXP_NOT(pre_temp_2_4))) {
                if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                    JMI_GLOBAL(tmp_3) = 2.4;
                    if (JMI_GLOBAL(tmp_3) != _z_2) {
                        _z_2 = JMI_GLOBAL(tmp_3);
                        jmi->reinit_triggered = 1;
                    }
                }
                if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                    JMI_GLOBAL(tmp_4) = 0.4;
                    if (JMI_GLOBAL(tmp_4) != _x_0) {
                        _x_0 = JMI_GLOBAL(tmp_4);
                        jmi->reinit_triggered = 1;
                    }
                }
            } else {
                if (LOG_EXP_AND(_temp_3_5, LOG_EXP_NOT(pre_temp_3_5))) {
                    if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                        JMI_GLOBAL(tmp_5) = 2.1;
                        if (JMI_GLOBAL(tmp_5) != _z_2) {
                            _z_2 = JMI_GLOBAL(tmp_5);
                            jmi->reinit_triggered = 1;
                        }
                    }
                    if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                        JMI_GLOBAL(tmp_6) = 0.1;
                        if (JMI_GLOBAL(tmp_6) != _x_0) {
                            _x_0 = JMI_GLOBAL(tmp_6);
                            jmi->reinit_triggered = 1;
                        }
                    }
                    if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                        JMI_GLOBAL(tmp_7) = 1.1;
                        if (JMI_GLOBAL(tmp_7) != _y_1) {
                            _y_1 = JMI_GLOBAL(tmp_7);
                            jmi->reinit_triggered = 1;
                        }
                    }
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
end ReinitCTest8;

model ReinitCTest9
    Real x;
    Boolean y,z;
equation
    der(x) = 1;
    y = time > 1;
    z = y <> pre(y);
    if z then
        when z then
            reinit(x, 1);
        end when;
    end if;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest9",
        description="",
        template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t tmp_1;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    _der_x_5 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_5 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _y_1 = _sw(0);
    pre_y_1 = JMI_FALSE;
    _z_2 = COND_EXP_EQ(_y_1, pre_y_1, JMI_FALSE, JMI_TRUE);
    _x_0 = 0.0;
    pre_z_2 = JMI_FALSE;
    if (_z_2) {
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
        x[1] = 536870917;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _y_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _z_2 = COND_EXP_EQ(_y_1, pre_y_1, JMI_FALSE, JMI_TRUE);
        }
        if (_z_2) {
            if (LOG_EXP_AND(_z_2, LOG_EXP_NOT(pre_z_2))) {
                if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                    JMI_GLOBAL(tmp_1) = 1.0;
                    if (JMI_GLOBAL(tmp_1) != _x_0) {
                        _x_0 = JMI_GLOBAL(tmp_1);
                        jmi->reinit_triggered = 1;
                    }
                }
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


-----
")})));
end ReinitCTest9;

model ReinitCTest10
    Boolean b = true;
    Real x;
equation
    der(x) = 2;
    when b then
        reinit(x, 1);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Reinit_ReinitCTest10",
        description="",
        template="
$C_ode_derivatives$
",
        generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_1;
    _der_x_2 = 2;
    if (JMI_FALSE) {
        JMI_GLOBAL(tmp_1) = 1.0;
        if (JMI_GLOBAL(tmp_1) != _x_1) {
            _x_1 = JMI_GLOBAL(tmp_1);
            jmi->reinit_triggered = 1;
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end ReinitCTest10;

model ReinitCTestDerAlias1
    Boolean g;
    Real x;
    Real y;
    Real v;
equation
    der(v) = time;
    der(y) = v;
    when g then
        reinit(v, 0);
    end when;
algorithm 
    g := v > 0;
    when {g} then
        x := 0;
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="ReinitCTestDerAlias1",
        description="Test reinit of derivative alias",
        template="
$C_dae_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(BOO, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 6;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 6;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        tmp_1 = _g_0;
        tmp_2 = _x_1;
        _x_1 = pre_x_1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch(jmi, _der_y_7 - (0), _sw(0), JMI_REL_GT);
        }
        _g_0 = _sw(0);
        if (LOG_EXP_AND(_g_0, LOG_EXP_NOT(pre_g_0))) {
            _x_1 = 0;
        }
        JMI_SWAP(GEN, _g_0, tmp_1)
        JMI_SWAP(GEN, _x_1, tmp_2)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _g_0 = (tmp_1);
        }
        if (LOG_EXP_AND(_g_0, LOG_EXP_NOT(pre_g_0))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_3) = 0.0;
                if (JMI_GLOBAL(tmp_3) != _v_3) {
                    _v_3 = JMI_GLOBAL(tmp_3);
                    _der_y_7 = JMI_GLOBAL(tmp_3);
                    jmi->reinit_triggered = 1;
                }
            }
        }
        _x_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end ReinitCTestDerAlias1;

end CCodeGenReinitTests;
