/*
    Copyright (C) 2017 Modelon AB

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


package CCodeGenStringTests

model CCodeGenString1
    parameter String s0 = "";
    parameter Real t(fixed=false);
    parameter String s1 = String(t);
    parameter String s2 = s1;
initial equation
    t = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenString1",
            description="Code generated for strings",
            eliminate_alias_variables=false,
            template="
$C_variable_aliases$
$C_z_offsets_strings$
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$

$C_dae_init_blocks_residual_functions$
$C_ode_initialization$

$C_dae_blocks_residual_functions$
$C_ode_derivatives$

",
            generatedCode="
#define _t_1 ((*(jmi->z))[0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_pi_s0_0 (jmi->z_t.strings.values[0])
#define _s_pd_s1_2 (jmi->z_t.strings.values[1])
#define _s_pd_s2_3 (jmi->z_t.strings.values[2])

z->offs.ci = 0;
z->nums.ci = 0;
z->offs.cd = 0;
z->nums.cd = 0;
z->offs.pi = 0;
z->nums.pi = 1;
z->offs.ps = 1;
z->nums.ps = 0;
z->offs.pf = 1;
z->nums.pf = 0;
z->offs.pe = 1;
z->nums.pe = 0;
z->offs.pd = 1;
z->nums.pd = 2;
z->offs.w = 3;
z->nums.w = 0;
z->offs.wp = 3;
z->nums.wp = 0;
z->n = 3;

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_pi_s0_0, (\"\"));
    JMI_ASG(STR_Z, _s_pd_s1_2, (\"\"));
    JMI_ASG(STR_Z, _s_pd_s2_3, (\"\"));
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
    JMI_DEF_STR_STAT(tmp_1, 13)
    _t_1 = _time;
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _t_1);
    JMI_ASG(STR_Z, _s_pd_s1_2, tmp_1)
    JMI_ASG(STR_Z, _s_pd_s2_3, _s_pd_s1_2)
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenString1;

model CCodeGenString2
    parameter String s0 = "";
    String s1;
    String s2;
equation
    s1 = String(time);
    s2 = s1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenString2",
            description="Code generated for strings",
            eliminate_alias_variables=false,
            template="
$C_variable_aliases$
$C_z_offsets_strings$
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$
$C_dae_init_blocks_residual_functions$
$C_ode_initialization$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
            generatedCode="
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_pi_s0_0 (jmi->z_t.strings.values[0])
#define _s_w_s1_1 (jmi->z_t.strings.values[1])
#define _s_w_s2_2 (jmi->z_t.strings.values[2])
#define pre_s1_1 (jmi->z_t.strings.values[jmi->z_t.strings.offs.wp+0])
#define pre_s2_2 (jmi->z_t.strings.values[jmi->z_t.strings.offs.wp+1])

z->offs.ci = 0;
z->nums.ci = 0;
z->offs.cd = 0;
z->nums.cd = 0;
z->offs.pi = 0;
z->nums.pi = 1;
z->offs.ps = 1;
z->nums.ps = 0;
z->offs.pf = 1;
z->nums.pf = 0;
z->offs.pe = 1;
z->nums.pe = 0;
z->offs.pd = 1;
z->nums.pd = 0;
z->offs.w  = 1;
z->nums.w  = 2;
z->offs.wp = 3;
z->nums.wp = 2;
z->n = 5;

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_pi_s0_0, (\"\"));
    JMI_ASG(STR_Z, _s_w_s1_1, (\"\"));
    JMI_ASG(STR_Z, _s_w_s2_2, (\"\"));
    JMI_ASG(STR_Z, pre_s1_1, (\"\"));
    JMI_ASG(STR_Z, pre_s2_2, (\"\"));
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
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_ASG(STR_Z, _s_w_s2_2, _s_w_s1_1)
    JMI_ASG(STR_Z, pre_s1_1, \"\")
    JMI_ASG(STR_Z, pre_s2_2, \"\")
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_ASG(STR_Z, pre_s1_1, _s_w_s1_1)
    JMI_ASG(STR_Z, _s_w_s2_2, _s_w_s1_1)
    JMI_ASG(STR_Z, pre_s2_2, _s_w_s2_2)
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenString2;

model CCodeGenString3
    parameter String s0 = "";
    String s1;
    String s2;
equation
    s1 = String(time);
    s2 = s1 + s1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenString3",
            description="Code generated for strings. Add in solved equation.",
            template="
$C_ode_initialization$
$C_ode_derivatives$
",
            generatedCode="
int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s1_1) + JMI_LEN(_s_w_s1_1))
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    JMI_ASG(STR_Z, _s_w_s2_2, tmp_2)
    JMI_ASG(STR_Z, pre_s1_1, \"\")
    JMI_ASG(STR_Z, pre_s2_2, \"\")
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_ASG(STR_Z, pre_s1_1, _s_w_s1_1)
    JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s1_1) + JMI_LEN(_s_w_s1_1))
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    JMI_ASG(STR_Z, _s_w_s2_2, tmp_2)
    JMI_ASG(STR_Z, pre_s2_2, _s_w_s2_2)
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenString3;

model CCodeGenString4
    parameter String s0 = "";
    String s1;
    String s2;
equation
    s1 = String(time);
    when time > 1 then
        s2 = s1 + s1;
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenString4",
        description="Code generated for strings. Add in solved equation.",
        template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_initialization$
$C_dae_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="



int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_1_3 = _sw(0);
    JMI_ASG(STR_Z, pre_s2_2, \"\")
    JMI_ASG(STR_Z, _s_w_s2_2, pre_s2_2)
    pre_temp_1_3 = JMI_FALSE;
    JMI_ASG(STR_Z, pre_s1_1, \"\")
    JMI_DYNAMIC_FREE()
    return ef;
}

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 0, 0, 0, 1, 0, 0, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(tmp_2)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870914;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_STRING_VALUE_REFERENCE) {
        x[0] = 805306370;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_3 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3))) {
                JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s1_1) + JMI_LEN(_s_w_s1_1))
                snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
                snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
            } else {
            }
            JMI_ASG(STR_Z, _s_w_s2_2, COND_EXP_EQ(LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3)), JMI_TRUE, tmp_2, pre_s2_2))
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_ASG(STR_Z, pre_s1_1, _s_w_s1_1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenString4;

model CCodeGenStringInput1
    input String x;
    output String y = x + x;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenStringInput1",
            description="Code generated for strings. Input.",
            template="
$C_variable_aliases$
$C_z_offsets_strings$
$C_dae_init_add_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_initialization$
$C_dae_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
            generatedCode="
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_w_y_1 (jmi->z_t.strings.values[0])
#define _s_w_x_0 (jmi->z_t.strings.values[1])
#define pre_y_1 (jmi->z_t.strings.values[jmi->z_t.strings.offs.wp+0])
#define pre_x_0 (jmi->z_t.strings.values[jmi->z_t.strings.offs.wp+0])

z->offs.ci = 0;
z->nums.ci = 0;
z->offs.cd = 0;
z->nums.cd = 0;
z->offs.pi = 0;
z->nums.pi = 0;
z->offs.ps = 0;
z->nums.ps = 0;
z->offs.pf = 0;
z->nums.pf = 0;
z->offs.pe = 0;
z->nums.pe = 0;
z->offs.pd = 0;
z->nums.pd = 0;
z->offs.w = 0;
z->nums.w = 2;
z->offs.wp = 2;
z->nums.wp = 2;
z->n = 4;

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(tmp_1)
    JMI_INI_STR_DYNA(tmp_1, JMI_LEN(_s_w_x_0) + JMI_LEN(_s_w_x_0))
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", _s_w_x_0);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", _s_w_x_0);
    JMI_ASG(STR_Z, _s_w_y_1, tmp_1)
    JMI_ASG(STR_Z, pre_y_1, \"\")
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(tmp_1)
    JMI_INI_STR_DYNA(tmp_1, JMI_LEN(_s_w_x_0) + JMI_LEN(_s_w_x_0))
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", _s_w_x_0);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", _s_w_x_0);
    JMI_ASG(STR_Z, _s_w_y_1, tmp_1)
    JMI_ASG(STR_Z, pre_y_1, _s_w_y_1)
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end CCodeGenStringInput1;

model TestStringBlockInitial1
    parameter Real t(fixed=false);
    parameter String s1 = String(t);
initial equation
    t = Modelica.Utilities.Strings.scanReal(s1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestStringBlockInitial1",
        description="Code generated for strings. Add in solved equation.",
        template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_initialization$
",
        generatedCode="
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 1, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_STRING_VALUE_REFERENCE) {
        x[0] = 805306368;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _t_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _t_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            JMI_INI_STR_STAT(tmp_1)
            snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _t_0);
            JMI_ASG(STR_Z, _s_pd_s1_1, tmp_1)
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = func_Modelica_Utilities_Strings_scanReal_exp0(_s_pd_s1_1, 1.0, JMI_FALSE, \"\") - (_t_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestStringBlockInitial1;

model TestStringBlockEvent1
    String s1,s2,s3;
equation
    s1 = String(time);
    
    if time > 1 then
        s2 = s1 + s1;
    else
        s2 = s1 + "msg";
    end if;
    
    if not pre(s2) == s2 then
        s3 = pre(s1) + s2;
    else
        s3 = pre(s3);
    end if;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestStringBlockEvent1",
        description="Code generated for strings. Add in solved equation.",
        template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_initialization$
$C_dae_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="



int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_DEF_STR_DYNA(tmp_3)
    JMI_DEF_STR_DYNA(tmp_4)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_0, tmp_1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s1_0) + JMI_LEN(_s_w_s1_0))
        snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_0);
        snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_0);
    } else {
        JMI_INI_STR_DYNA(tmp_3, JMI_LEN(_s_w_s1_0) + 3)
        snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), \"%s\", _s_w_s1_0);
        snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), \"%s\", \"msg\");
    }
    JMI_ASG(STR_Z, _s_w_s2_1, COND_EXP_EQ(_sw(0), JMI_TRUE, tmp_2, tmp_3))
    JMI_ASG(STR_Z, pre_s2_1, \"\")
    JMI_ASG(STR_Z, pre_s1_0, \"\")
    JMI_ASG(STR_Z, pre_s3_2, \"\")
    if (LOG_EXP_NOT(strcmp(pre_s2_1, _s_w_s2_1) == 0)) {
        JMI_INI_STR_DYNA(tmp_4, JMI_LEN(pre_s1_0) + JMI_LEN(_s_w_s2_1))
        snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", pre_s1_0);
        snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", _s_w_s2_1);
    } else {
    }
    JMI_ASG(STR_Z, _s_w_s3_2, COND_EXP_EQ(LOG_EXP_NOT(strcmp(pre_s2_1, _s_w_s2_1) == 0), JMI_TRUE, tmp_4, pre_s3_2))
    JMI_DYNAMIC_FREE()
    return ef;
}

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 3, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_DEF_STR_DYNA(tmp_3)
    JMI_DEF_STR_DYNA(tmp_4)
    if (evaluation_mode == JMI_BLOCK_SOLVED_STRING_VALUE_REFERENCE) {
        x[0] = 805306368;
        x[1] = 805306369;
        x[2] = 805306370;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            JMI_INI_STR_STAT(tmp_1)
            snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
            JMI_ASG(STR_Z, _s_w_s1_0, tmp_1)
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            if (_sw(0)) {
                JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s1_0) + JMI_LEN(_s_w_s1_0))
                snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_0);
                snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_0);
            } else {
                JMI_INI_STR_DYNA(tmp_3, JMI_LEN(_s_w_s1_0) + 3)
                snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), \"%s\", _s_w_s1_0);
                snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), \"%s\", \"msg\");
            }
            JMI_ASG(STR_Z, _s_w_s2_1, COND_EXP_EQ(_sw(0), JMI_TRUE, tmp_2, tmp_3))
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (LOG_EXP_NOT(strcmp(pre_s2_1, _s_w_s2_1) == 0)) {
                JMI_INI_STR_DYNA(tmp_4, JMI_LEN(pre_s1_0) + JMI_LEN(_s_w_s2_1))
                snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", pre_s1_0);
                snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", _s_w_s2_1);
            } else {
            }
            JMI_ASG(STR_Z, _s_w_s3_2, COND_EXP_EQ(LOG_EXP_NOT(strcmp(pre_s2_1, _s_w_s2_1) == 0), JMI_TRUE, tmp_4, pre_s3_2))
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestStringBlockEvent1;

model TestStringBlockEvent2
    String s1;
    String s2(start="s2");
equation
    s1 = String(time);
    when {time > 1, time >= 1} then
        s2 = pre(s2) + s1;
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestStringBlockEvent2",
        description="Code generated for strings. Add in solved equation.",
        template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_initialization$
$C_dae_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="



int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_0, tmp_1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_1_2 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (1), _sw(1), JMI_REL_GEQ);
    }
    _temp_2_3 = _sw(1);
    JMI_ASG(STR_Z, pre_s2_1, \"s2\")
    JMI_ASG(STR_Z, _s_w_s2_1, pre_s2_1)
    pre_temp_1_2 = JMI_FALSE;
    pre_temp_2_3 = JMI_FALSE;
    JMI_ASG(STR_Z, pre_s1_0, \"\")
    JMI_DYNAMIC_FREE()
    return ef;
}

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 0, 0, 0, 2, 0, 0, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(tmp_2)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
        x[1] = 536870914;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_STRING_VALUE_REFERENCE) {
        x[0] = 805306369;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch_time(jmi, _time - (1), _sw(1), JMI_REL_GEQ);
            }
            _temp_2_3 = _sw(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_2 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (LOG_EXP_OR(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3)))) {
                JMI_INI_STR_DYNA(tmp_2, JMI_LEN(pre_s2_1) + JMI_LEN(_s_w_s1_0))
                snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", pre_s2_1);
                snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_0);
            } else {
            }
            JMI_ASG(STR_Z, _s_w_s2_1, COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3))), JMI_TRUE, tmp_2, pre_s2_1))
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_0, tmp_1)
    JMI_ASG(STR_Z, pre_s1_0, _s_w_s1_0)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (1), _sw(1), JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestStringBlockEvent2;

package Functions

model TestStringRecord1
    record R
        String s = "str";
    end R;

    function f
        input Real x;
        output Real y = x;
        R r;
    algorithm
        annotation(Inline=false);
    end f;

    Real y = f(time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestStringRecord1",
            description="Code generated for strings. Add in solved equation.",
            template="
$C_functions$
",
            generatedCode="
void func_CCodeGenStringTests_Functions_TestStringRecord1_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RECORD_STATIC(R_0_r, r_v)
    JMI_INI(STR, r_v->s)
    y_v = x_v;
    JMI_ASG(STR, r_v->s, \"str\")
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenStringTests_Functions_TestStringRecord1_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenStringTests_Functions_TestStringRecord1_f_def0(x_v, &y_v);
    return y_v;
}
")})));
end TestStringRecord1;

end Functions;

end CCodeGenStringTests;
