/*
    Copyright (C) 2009-2019 Modelon AB

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


package CCodeGenDynamicStatesTests

        model ThreeDSOneEq
            // a1 a2 a3
            // +  +  +
            Real a1;
            Real a2;
            Real a3;
            Real b;
        equation
            der(a1) = b;
            der(a2) = b;
            der(a3) = b;
            a1 * a2 * a3 = 1;

        annotation(__JModelica(UnitTesting(tests={
            CCodeGenTestCase(
                name="DynamicStates_ThreeDSOneEq",
                description="Test code gen for dynamic state model with three states in one equation",
                dynamic_states=true,
                template="
n_real_x = $n_real_x$
n_dynamic_sets = $dynamic_state_n_sets$
$C_dynamic_state_coefficients$
$C_dynamic_state_add_call$
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
                generatedCode="
n_real_x = 2
n_dynamic_sets = 1
static void ds_coefficients_0(jmi_t* jmi, jmi_real_t* res) {
    memset(res, 0, 3 * sizeof(jmi_real_t));
    res[0] = _a1_0 * _a3_2;
    res[1] = _a1_0 * _a2_1;
    res[2] = _a2_1 * _a3_2;
}


    {
        int* ds_var_value_refs = calloc(3, sizeof(int));
        int* ds_state_value_refs = calloc(2, sizeof(int));
        int* ds_algebraic_value_refs = calloc(1, sizeof(int));
        ds_var_value_refs[0] = 5; /* a2 */
        ds_var_value_refs[1] = 6; /* a3 */
        ds_var_value_refs[2] = 4; /* a1 */
        ds_state_value_refs[0] = 2; /* _ds.1.s1 */
        ds_state_value_refs[1] = 3; /* _ds.1.s2 */
        ds_algebraic_value_refs[0] = 8; /* _ds.1.a1 */
        jmi_dynamic_state_add_set(*jmi, 0, 3, 2, ds_var_value_refs, ds_state_value_refs, ds_algebraic_value_refs, ds_coefficients_0);
        free(ds_var_value_refs);
        free(ds_state_value_refs);
        free(ds_algebraic_value_refs);
    }


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (jmi->atInitial || jmi->atEvent) {
        jmi_dynamic_state_update_states(jmi, 0);
    }
    if (jmi_dynamic_state_check_is_state(jmi, 0, 6, 4)) {
        _a3_2 = __ds_1_s1_5;
        _a1_0 = __ds_1_s2_6;
        _a2_1 = jmi_divide_equation(jmi, 1, (_a1_0 * _a3_2), \"1 / (ds(1, a1) * ds(1, a3))\");
        __ds_1_a1_4 = _a2_1;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5, 4)) {
        _a2_1 = __ds_1_s1_5;
        _a1_0 = __ds_1_s2_6;
        _a3_2 = jmi_divide_equation(jmi, 1, (_a1_0 * _a2_1), \"1 / (ds(1, a1) * ds(1, a2))\");
        __ds_1_a1_4 = _a3_2;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5, 6)) {
        _a2_1 = __ds_1_s1_5;
        _a3_2 = __ds_1_s2_6;
        _a1_0 = jmi_divide_equation(jmi, 1, (_a2_1 * _a3_2), \"1 / (ds(1, a2) * ds(1, a3))\");
        __ds_1_a1_4 = _a1_0;
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (jmi_dynamic_state_check_is_state(jmi, 0, 6, 4)) {
        tmp_1 = _der_a3_11;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5, 4)) {
        tmp_1 = _der_a2_10;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5, 6)) {
        tmp_1 = _der_a2_10;
    }
    _der__ds_1_s1_7 = tmp_1;
    if (jmi_dynamic_state_check_is_state(jmi, 0, 6, 4)) {
        tmp_2 = _der_a1_9;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5, 4)) {
        tmp_2 = _der_a1_9;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5, 6)) {
        tmp_2 = _der_a3_11;
    }
    _der__ds_1_s2_8 = tmp_2;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 11;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 10;
        x[2] = 9;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _der_a3_11;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(3, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(3, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 3;
            int n2 = 1;
            Q1[0] = 1.0;
            for (i = 0; i < 3; i += 3) {
                Q1[i + 0] = (Q1[i + 0]) / (-1.0);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (1.0);
                Q1[i + 2] = (Q1[i + 2] - (-1.0) * Q1[i + 0]) / (1.0);
            }
            Q2[1] = _a1_0 * _a3_2;
            Q2[2] = _a2_1 * _a3_2;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = _a1_0 * _a2_1;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _der_a3_11 = x[0];
        }
        _b_3 = _der_a3_11;
        _der_a2_10 = _b_3;
        _der_a1_9 = _b_3;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 0 - (_a1_0 * _a2_1 * _der_a3_11 + (_a1_0 * _der_a2_10 + _der_a1_9 * _a2_1) * _a3_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
        end ThreeDSOneEq;
        
        model ThreeDSTwoEqWithConstantCoefficients
            // a1 a2 a3
            // +  +  *
            // *  +  +
            Real a1;
            Real a2;
            Real a3;
            Real b;
        equation
            der(a1) = b;
            der(a2) + der(a3) = b;
            a1^2 + a2^2 + a3 = 1;
            a1 + a2^2 + a3^2 = 1;

        annotation(__JModelica(UnitTesting(tests={
            CCodeGenTestCase(
                name="DynamicStates_ThreeDSTwoEqWithConstantCoefficients",
                description="Test code gen for dynamic state model with three states in two equation with some constant coefficients",
                eliminate_linear_equations=false,
                dynamic_states=true,
                template="
n_real_x = $n_real_x$
n_dynamic_sets = $dynamic_state_n_sets$
$C_dynamic_state_coefficients$
$C_dynamic_state_add_call$
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
                generatedCode="
n_real_x = 1
n_dynamic_sets = 1
static void ds_coefficients_0(jmi_t* jmi, jmi_real_t* res) {
    memset(res, 0, 6 * sizeof(jmi_real_t));
    res[0] = 1.0;
    res[2] = 2 * _a2_1;
    res[4] = 2 * _a1_0;
    res[1] = 2 * _a3_2;
    res[3] = 2 * _a2_1;
    res[5] = 1.0;
}


    {
        int* ds_var_value_refs = calloc(3, sizeof(int));
        int* ds_state_value_refs = calloc(1, sizeof(int));
        int* ds_algebraic_value_refs = calloc(2, sizeof(int));
        ds_var_value_refs[0] = 4; /* a3 */
        ds_var_value_refs[1] = 3; /* a2 */
        ds_var_value_refs[2] = 2; /* a1 */
        ds_state_value_refs[0] = 1; /* _ds.1.s1 */
        ds_algebraic_value_refs[0] = 6; /* _ds.1.a1 */
        ds_algebraic_value_refs[1] = 7; /* _ds.1.a2 */
        jmi_dynamic_state_add_set(*jmi, 0, 3, 1, ds_var_value_refs, ds_state_value_refs, ds_algebraic_value_refs, ds_coefficients_0);
        free(ds_var_value_refs);
        free(ds_state_value_refs);
        free(ds_algebraic_value_refs);
    }


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    if (jmi->atInitial || jmi->atEvent) {
        jmi_dynamic_state_update_states(jmi, 0);
    }
    if (jmi_dynamic_state_check_is_state(jmi, 0, 2)) {
        _a1_0 = __ds_1_s1_6;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
        __ds_1_a1_4 = _a3_2;
        __ds_1_a2_5 = _a2_1;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 3)) {
        _a2_1 = __ds_1_s1_6;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        __ds_1_a1_4 = _a3_2;
        __ds_1_a2_5 = _a1_0;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 4)) {
        _a3_2 = __ds_1_s1_6;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[2]);
        __ds_1_a1_4 = _a2_1;
        __ds_1_a2_5 = _a1_0;
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[3]);
    if (jmi_dynamic_state_check_is_state(jmi, 0, 2)) {
        tmp_1 = _der_a1_8;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 3)) {
        tmp_1 = _der_a2_9;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 4)) {
        tmp_1 = _der_a3_10;
    }
    _der__ds_1_s1_7 = tmp_1;
    _b_3 = _der_a1_8;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(a1).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a2_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a2_1 = x[0];
        }
        _a3_2 = - (1.0 * (_a1_0) * (_a1_0)) + (- (1.0 * (_a2_1) * (_a2_1))) + 1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 1 - (_a1_0 + (1.0 * (_a2_1) * (_a2_1)) + (1.0 * (_a3_2) * (_a3_2)));
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(a2).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a3_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a3_2 = x[0];
        }
        _a1_0 = - (1.0 * (_a2_1) * (_a2_1)) + (- (1.0 * (_a3_2) * (_a3_2))) + 1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 1 - ((1.0 * (_a1_0) * (_a1_0)) + (1.0 * (_a2_1) * (_a2_1)) + _a3_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(a3).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a2_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a2_1 = x[0];
        }
        _a1_0 = - (1.0 * (_a2_1) * (_a2_1)) + (- (1.0 * (_a3_2) * (_a3_2))) + 1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 1 - ((1.0 * (_a1_0) * (_a1_0)) + (1.0 * (_a2_1) * (_a2_1)) + _a3_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 9;
        x[1] = 8;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 10;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _der_a2_9;
        x[1] = _der_a1_8;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(2, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(2, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 1;
            int n2 = 2;
            Q1[0] = 2 * _a2_1;
            Q1[1] = 2 * _a1_0;
            for (i = 0; i < 2; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            Q2[0] = 1.0;
            Q2[1] = 2 * _a3_2;
            memset(Q3, 0, 4 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            Q3[1] = 2 * _a2_1;
            Q3[2] = -1.0;
            Q3[3] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _der_a2_9 = x[0];
            _der_a1_8 = x[1];
        }
        _der_a3_10 = - 2 * _a1_0 * _der_a1_8 + (- 2 * _a2_1 * _der_a2_9);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _der_a1_8 - (_der_a2_9 + _der_a3_10);
            (*res)[1] = 0 - (_der_a1_8 + 2 * _a2_1 * _der_a2_9 + 2 * _a3_2 * _der_a3_10);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
        end ThreeDSTwoEqWithConstantCoefficients;
        
        model Pendulum
            parameter Real L = 1 "Pendulum length";
            parameter Real g = 9.81 "Acceleration due to gravity";
            Real x "Cartesian x coordinate";
            Real y "Cartesian x coordinate";
            Real vx "Velocity in x coordinate";
            Real vy "Velocity in y coordinate";
            Real lambda "Lagrange multiplier";
        equation
            der(x) = vx;
            der(y) = vy;
            der(vx) = lambda*x;
            der(vy) = lambda*y - g;
            x^2 + y^2 = L;

        annotation(__JModelica(UnitTesting(tests={
            CCodeGenTestCase(
                name="DynamicStates_Pendulum",
                description="Test code gen for dynamic state related parts of the pendulum model",
                dynamic_states=true,
                template="
n_real_x = $n_real_x$
n_dynamic_sets = $dynamic_state_n_sets$
$C_dynamic_state_coefficients$
$C_dynamic_state_add_call$
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
                generatedCode="
n_real_x = 2
n_dynamic_sets = 2
static void ds_coefficients_0(jmi_t* jmi, jmi_real_t* res) {
    memset(res, 0, 2 * sizeof(jmi_real_t));
    res[0] = 2 * _x_2;
    res[1] = 2 * _y_3;
}

static void ds_coefficients_1(jmi_t* jmi, jmi_real_t* res) {
    memset(res, 0, 2 * sizeof(jmi_real_t));
    res[0] = 2 * _y_3;
    res[1] = 2 * _x_2;
}


    {
        int* ds_var_value_refs = calloc(2, sizeof(int));
        int* ds_state_value_refs = calloc(1, sizeof(int));
        int* ds_algebraic_value_refs = calloc(1, sizeof(int));
        ds_var_value_refs[0] = 13; /* _der_x */
        ds_var_value_refs[1] = 14; /* _der_y */
        ds_state_value_refs[0] = 4; /* _ds.1.s1 */
        ds_algebraic_value_refs[0] = 15; /* _ds.1.a1 */
        jmi_dynamic_state_add_set(*jmi, 0, 2, 1, ds_var_value_refs, ds_state_value_refs, ds_algebraic_value_refs, ds_coefficients_0);
        free(ds_var_value_refs);
        free(ds_state_value_refs);
        free(ds_algebraic_value_refs);
    }
    {
        int* ds_var_value_refs = calloc(2, sizeof(int));
        int* ds_state_value_refs = calloc(1, sizeof(int));
        int* ds_algebraic_value_refs = calloc(1, sizeof(int));
        ds_var_value_refs[0] = 7; /* y */
        ds_var_value_refs[1] = 6; /* x */
        ds_state_value_refs[0] = 5; /* _ds.2.s1 */
        ds_algebraic_value_refs[0] = 16; /* _ds.2.a1 */
        jmi_dynamic_state_add_set(*jmi, 1, 2, 1, ds_var_value_refs, ds_state_value_refs, ds_algebraic_value_refs, ds_coefficients_1);
        free(ds_var_value_refs);
        free(ds_state_value_refs);
        free(ds_algebraic_value_refs);
    }


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (jmi->atInitial || jmi->atEvent) {
        jmi_dynamic_state_update_states(jmi, 1);
    }
    if (jmi_dynamic_state_check_is_state(jmi, 1, 6)) {
        _x_2 = __ds_2_s1_14;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
        __ds_2_a1_13 = _y_3;
    } else if (jmi_dynamic_state_check_is_state(jmi, 1, 7)) {
        _y_3 = __ds_2_s1_14;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        __ds_2_a1_13 = _x_2;
    }
    if (jmi->atInitial || jmi->atEvent) {
        jmi_dynamic_state_update_states(jmi, 0);
    }
    if (jmi_dynamic_state_check_is_state(jmi, 0, 14)) {
        __der_y_10 = __ds_1_s1_12;
        _der_y_18 = __der_y_10;
        _der_x_17 = jmi_divide_equation(jmi, (- 2 * _y_3 * _der_y_18), (2 * _x_2), \"(- 2 * ds(2, y) * dynDer(y)) / (2 * ds(2, x))\");
        __der_x_9 = _der_x_17;
        __ds_1_a1_11 = __der_x_9;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 13)) {
        __der_x_9 = __ds_1_s1_12;
        _der_x_17 = __der_x_9;
        _der_y_18 = jmi_divide_equation(jmi, (- 2 * _x_2 * _der_x_17), (2 * _y_3), \"(- 2 * ds(2, x) * dynDer(x)) / (2 * ds(2, y))\");
        __der_y_10 = _der_y_18;
        __ds_1_a1_11 = __der_y_10;
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[2]);
    if (jmi_dynamic_state_check_is_state(jmi, 0, 14)) {
        tmp_1 = _der__der_y_20;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 13)) {
        tmp_1 = _der__der_x_19;
    }
    _der__ds_1_s1_15 = tmp_1;
    if (jmi_dynamic_state_check_is_state(jmi, 1, 6)) {
        tmp_2 = _der_x_17;
    } else if (jmi_dynamic_state_check_is_state(jmi, 1, 7)) {
        tmp_2 = _der_y_18;
    }
    _der__ds_2_s1_16 = tmp_2;
    _vx_4 = _der_x_17;
    _vy_5 = _der_y_18;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(x).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 7;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(1.0, 1.0), jmi_abs(_L_0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_3;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_3 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _L_0 - ((1.0 * (_x_2) * (_x_2)) + (1.0 * (_y_3) * (_y_3)));
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(y).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(1.0, 1.0), jmi_abs(_L_0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _L_0 - ((1.0 * (_x_2) * (_x_2)) + (1.0 * (_y_3) * (_y_3)));
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 3 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 20;
        x[2] = 11;
        x[3] = 19;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _lambda_6;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(4, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(4, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 4;
            int n2 = 1;
            Q1[0] = - _y_3;
            Q1[2] = (- _x_2);
            for (i = 0; i < 4; i += 4) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (1.0);
                Q1[i + 2] = (Q1[i + 2]) / (1.0);
                Q1[i + 3] = (Q1[i + 3] - (-1.0) * Q1[i + 2]) / (1.0);
            }
            Q2[1] = 2 * _y_3;
            Q2[3] = 2 * _x_2;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _lambda_6 = x[0];
        }
        _der_vy_8 = _lambda_6 * _y_3 + (- _g_1);
        _der__der_y_20 = _der_vy_8;
        _der_vx_7 = _lambda_6 * _x_2;
        _der__der_x_19 = _der_vx_7;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 0.0 - (2 * _x_2 * _der__der_x_19 + 2 * _der_x_17 * _der_x_17 + (2 * _y_3 * _der__der_y_20 + 2 * _der_y_18 * _der_y_18));
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
        end Pendulum;
        model TwoDSSetSameBlock
            /*
            a1 a2 a3 a4 a5 a6 a7 a8 a9
            +  +        *     *     * 
            +  +           *     *  * 
                  +  +  *     *     * 
                  +  +     *     *  * 
                                    * 
                        *     *       
                           *     *    
            */
            Real a1;
            Real a2;
            Real a3;
            Real a4;
            Real a5;
            Real a6;
            Real a7;
            Real a8;
            Real a9;
        equation
            der(a1) + der(a4) + der(a5) + der(a8) + der(a9) = 0;
            der(a2) + der(a3) + der(a7) + der(a6) = 0;
            a1 * a2 - 1 = a5 + a7 + a9 + 1;
            a1 * a2 + 1 = a6 + a8 + a9 + 3;
            a3 * a4 - 1 = a5 + a7 + a9 + 2;
            a3 * a4 + 1 = a6 + a8 + a9 + 4;
            a7 = time;
            a5 + a7 = 1;
            a6 - a8 = time;

        annotation(__JModelica(UnitTesting(tests={
            CCodeGenTestCase(
                name="DynamicStates_TwoDSSetSameBlock",
                description="Test code gen for two dynamic state sets in the same DAE bock",
                template="
n_real_x = $n_real_x$
n_dynamic_sets = $dynamic_state_n_sets$
$C_dynamic_state_coefficients$
$C_dynamic_state_add_call$
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
                generatedCode="
n_real_x = 2
n_dynamic_sets = 2
static void ds_coefficients_0(jmi_t* jmi, jmi_real_t* res) {
    memset(res, 0, 2 * sizeof(jmi_real_t));
    res[0] = _a1_0;
    res[1] = _a2_1;
}

static void ds_coefficients_1(jmi_t* jmi, jmi_real_t* res) {
    memset(res, 0, 2 * sizeof(jmi_real_t));
    res[0] = _a4_3;
    res[1] = _a3_2;
}


    {
        int* ds_var_value_refs = calloc(2, sizeof(int));
        int* ds_state_value_refs = calloc(1, sizeof(int));
        int* ds_algebraic_value_refs = calloc(1, sizeof(int));
        ds_var_value_refs[0] = 5; /* a2 */
        ds_var_value_refs[1] = 4; /* a1 */
        ds_state_value_refs[0] = 2; /* _ds.1.s1 */
        ds_algebraic_value_refs[0] = 17; /* _ds.1.a1 */
        jmi_dynamic_state_add_set(*jmi, 0, 2, 1, ds_var_value_refs, ds_state_value_refs, ds_algebraic_value_refs, ds_coefficients_0);
        free(ds_var_value_refs);
        free(ds_state_value_refs);
        free(ds_algebraic_value_refs);
    }
    {
        int* ds_var_value_refs = calloc(2, sizeof(int));
        int* ds_state_value_refs = calloc(1, sizeof(int));
        int* ds_algebraic_value_refs = calloc(1, sizeof(int));
        ds_var_value_refs[0] = 6; /* a3 */
        ds_var_value_refs[1] = 7; /* a4 */
        ds_state_value_refs[0] = 3; /* _ds.2.s1 */
        ds_algebraic_value_refs[0] = 18; /* _ds.2.a1 */
        jmi_dynamic_state_add_set(*jmi, 1, 2, 1, ds_var_value_refs, ds_state_value_refs, ds_algebraic_value_refs, ds_coefficients_1);
        free(ds_var_value_refs);
        free(ds_state_value_refs);
        free(ds_algebraic_value_refs);
    }


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    _a7_6 = _time;
    _a5_4 = - _a7_6 + 1;
    if (jmi->atInitial || jmi->atEvent) {
        jmi_dynamic_state_update_states(jmi, 0);
    }
    if (jmi->atInitial || jmi->atEvent) {
        jmi_dynamic_state_update_states(jmi, 1);
    }
    if (jmi_dynamic_state_check_is_state(jmi, 0, 4) && jmi_dynamic_state_check_is_state(jmi, 1, 7)) {
        _a1_0 = __ds_1_s1_14;
        _a4_3 = __ds_2_s1_16;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
        __ds_1_a1_13 = _a2_1;
        __ds_2_a1_15 = _a3_2;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 4) && jmi_dynamic_state_check_is_state(jmi, 1, 6)) {
        _a1_0 = __ds_1_s1_14;
        _a3_2 = __ds_2_s1_16;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        __ds_1_a1_13 = _a2_1;
        __ds_2_a1_15 = _a4_3;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5) && jmi_dynamic_state_check_is_state(jmi, 1, 7)) {
        _a2_1 = __ds_1_s1_14;
        _a4_3 = __ds_2_s1_16;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[2]);
        __ds_1_a1_13 = _a1_0;
        __ds_2_a1_15 = _a3_2;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5) && jmi_dynamic_state_check_is_state(jmi, 1, 6)) {
        _a2_1 = __ds_1_s1_14;
        _a3_2 = __ds_2_s1_16;
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[3]);
        __ds_1_a1_13 = _a1_0;
        __ds_2_a1_15 = _a4_3;
    }
    _der_a5_9 = -1.0;
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[4]);
    if (jmi_dynamic_state_check_is_state(jmi, 0, 4)) {
        tmp_1 = _der_a1_19;
    } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5)) {
        tmp_1 = _der_a2_21;
    }
    _der__ds_1_s1_17 = tmp_1;
    if (jmi_dynamic_state_check_is_state(jmi, 1, 7)) {
        tmp_2 = _der_a4_20;
    } else if (jmi_dynamic_state_check_is_state(jmi, 1, 6)) {
        tmp_2 = _der_a3_22;
    }
    _der__ds_2_s1_18 = tmp_2;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(a1, a4).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 9;
        x[1] = 5;
        x[2] = 6;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 4;
        (*res)[1] = 2;
        (*res)[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a6_5;
        x[1] = _a2_1;
        x[2] = _a3_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 2;
            int n2 = 3;
            Q1[1] = 1.0;
            Q1[2] = _a1_0;
            for (i = 0; i < 6; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-1.0);
                Q1[i + 1] = (Q1[i + 1]) / (-1.0);
            }
            Q2[0] = -1.0;
            Q2[1] = -1.0;
            Q2[2] = -1.0;
            Q2[3] = -1.0;
            Q2[5] = -1.0;
            memset(Q3, 0, 9 * sizeof(jmi_real_t));
            Q3[0] = -1.0;
            Q3[2] = -1.0;
            Q3[5] = _a1_0;
            Q3[6] = _a4_3;
            Q3[7] = _a4_3;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a6_5 = x[0];
            _a2_1 = x[1];
            _a3_2 = x[2];
        }
        _a9_8 = _a1_0 * _a2_1 - 1 - _a5_4 - (_a7_6 + 1);
        _a8_7 = _a6_5 - _time;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a6_5 + _a8_7 + _a9_8 + 4 - (_a3_2 * _a4_3 + 1);
            (*res)[1] = _a5_4 + _a7_6 + _a9_8 + 2 - (_a3_2 * _a4_3 - 1);
            (*res)[2] = _a6_5 + _a8_7 + _a9_8 + 3 - (_a1_0 * _a2_1 + 1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(a1, a3).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 9;
        x[1] = 5;
        x[2] = 7;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 4;
        (*res)[1] = 2;
        (*res)[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a6_5;
        x[1] = _a2_1;
        x[2] = _a4_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 2;
            int n2 = 3;
            Q1[1] = 1.0;
            Q1[2] = _a1_0;
            for (i = 0; i < 6; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-1.0);
                Q1[i + 1] = (Q1[i + 1]) / (-1.0);
            }
            Q2[0] = -1.0;
            Q2[1] = -1.0;
            Q2[2] = -1.0;
            Q2[3] = -1.0;
            Q2[5] = -1.0;
            memset(Q3, 0, 9 * sizeof(jmi_real_t));
            Q3[0] = -1.0;
            Q3[2] = -1.0;
            Q3[5] = _a1_0;
            Q3[6] = _a3_2;
            Q3[7] = _a3_2;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a6_5 = x[0];
            _a2_1 = x[1];
            _a4_3 = x[2];
        }
        _a9_8 = _a1_0 * _a2_1 - 1 - _a5_4 - (_a7_6 + 1);
        _a8_7 = _a6_5 - _time;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a6_5 + _a8_7 + _a9_8 + 4 - (_a3_2 * _a4_3 + 1);
            (*res)[1] = _a5_4 + _a7_6 + _a9_8 + 2 - (_a3_2 * _a4_3 - 1);
            (*res)[2] = _a6_5 + _a8_7 + _a9_8 + 3 - (_a1_0 * _a2_1 + 1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(a2, a4).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 9;
        x[1] = 4;
        x[2] = 6;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 4;
        (*res)[1] = 2;
        (*res)[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a6_5;
        x[1] = _a1_0;
        x[2] = _a3_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 2;
            int n2 = 3;
            Q1[1] = 1.0;
            Q1[2] = _a2_1;
            for (i = 0; i < 6; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-1.0);
                Q1[i + 1] = (Q1[i + 1]) / (-1.0);
            }
            Q2[0] = -1.0;
            Q2[1] = -1.0;
            Q2[2] = -1.0;
            Q2[3] = -1.0;
            Q2[5] = -1.0;
            memset(Q3, 0, 9 * sizeof(jmi_real_t));
            Q3[0] = -1.0;
            Q3[2] = -1.0;
            Q3[5] = _a2_1;
            Q3[6] = _a4_3;
            Q3[7] = _a4_3;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a6_5 = x[0];
            _a1_0 = x[1];
            _a3_2 = x[2];
        }
        _a9_8 = _a1_0 * _a2_1 - 1 - _a5_4 - (_a7_6 + 1);
        _a8_7 = _a6_5 - _time;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a6_5 + _a8_7 + _a9_8 + 4 - (_a3_2 * _a4_3 + 1);
            (*res)[1] = _a5_4 + _a7_6 + _a9_8 + 2 - (_a3_2 * _a4_3 - 1);
            (*res)[2] = _a6_5 + _a8_7 + _a9_8 + 3 - (_a1_0 * _a2_1 + 1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1(a2, a3).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 9;
        x[1] = 4;
        x[2] = 7;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 4;
        (*res)[1] = 2;
        (*res)[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a6_5;
        x[1] = _a1_0;
        x[2] = _a4_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 2;
            int n2 = 3;
            Q1[1] = 1.0;
            Q1[2] = _a2_1;
            for (i = 0; i < 6; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-1.0);
                Q1[i + 1] = (Q1[i + 1]) / (-1.0);
            }
            Q2[0] = -1.0;
            Q2[1] = -1.0;
            Q2[2] = -1.0;
            Q2[3] = -1.0;
            Q2[5] = -1.0;
            memset(Q3, 0, 9 * sizeof(jmi_real_t));
            Q3[0] = -1.0;
            Q3[2] = -1.0;
            Q3[5] = _a2_1;
            Q3[6] = _a3_2;
            Q3[7] = _a3_2;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a6_5 = x[0];
            _a1_0 = x[1];
            _a4_3 = x[2];
        }
        _a9_8 = _a1_0 * _a2_1 - 1 - _a5_4 - (_a7_6 + 1);
        _a8_7 = _a6_5 - _time;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a6_5 + _a8_7 + _a9_8 + 4 - (_a3_2 * _a4_3 + 1);
            (*res)[1] = _a5_4 + _a7_6 + _a9_8 + 2 - (_a3_2 * _a4_3 - 1);
            (*res)[2] = _a6_5 + _a8_7 + _a9_8 + 3 - (_a1_0 * _a2_1 + 1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_4(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 16;
        x[1] = 19;
        x[2] = 21;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 15;
        x[1] = 14;
        x[2] = 20;
        x[3] = 22;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
        (*res)[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _der_a6_12;
        x[1] = _der_a1_19;
        x[2] = _der_a2_21;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(12, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(12, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 4;
            int n2 = 3;
            Q1[1] = 1.0;
            Q1[3] = 1.0;
            Q1[4] = _a2_1;
            Q1[6] = 1.0;
            Q1[8] = _a1_0;
            Q1[11] = 1.0;
            for (i = 0; i < 12; i += 4) {
                Q1[i + 0] = (Q1[i + 0]) / (-1.0);
                Q1[i + 1] = (Q1[i + 1]) / (-1.0);
                Q1[i + 2] = (Q1[i + 2] - (1.0) * Q1[i + 0] - (1.0) * Q1[i + 1]) / (1.0);
                Q1[i + 3] = (Q1[i + 3]) / (1.0);
            }
            Q2[0] = -1.0;
            Q2[1] = -1.0;
            Q2[2] = -1.0;
            Q2[3] = -1.0;
            Q2[4] = -1.0;
            Q2[7] = _a3_2;
            Q2[8] = _a3_2;
            Q2[10] = _a4_3;
            Q2[11] = _a4_3;
            memset(Q3, 0, 9 * sizeof(jmi_real_t));
            Q3[0] = -1.0;
            Q3[1] = -1.0;
            Q3[3] = _a2_1;
            Q3[6] = _a1_0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _der_a6_12 = x[0];
            _der_a1_19 = x[1];
            _der_a2_21 = x[2];
        }
        _der_a9_11 = _a1_0 * _der_a2_21 + _der_a1_19 * _a2_1 - (_der_a5_9 + (- _der_a5_9));
        _der_a8_10 = _der_a6_12 - 1.0;
        _der_a4_20 = - _der_a1_19 + (- _der_a5_9) + (- _der_a8_10) + (- _der_a9_11);
        _der_a3_22 = - _der_a2_21 + _der_a5_9 + (- _der_a6_12);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _der_a6_12 + _der_a8_10 + _der_a9_11 - (_a1_0 * _der_a2_21 + _der_a1_19 * _a2_1);
            (*res)[1] = _der_a6_12 + _der_a8_10 + _der_a9_11 - (_a3_2 * _der_a4_20 + _der_a3_22 * _a4_3);
            (*res)[2] = _der_a5_9 + (- _der_a5_9) + _der_a9_11 - (_a3_2 * _der_a4_20 + _der_a3_22 * _a4_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
        end TwoDSSetSameBlock;

model PreBlock1
    Real a1;
    Real a2;
    Real b;
    Boolean b2 = time > 1;
    Real x;
equation
    der(x) = 1;
    der(a1) = b;
    der(a2) = b;
    a1 * a2 = if edge(b2) then 1 else time;
    when b2 then
        reinit(x, 0);
    end when;
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="PreBlock1",
        description="Dynamic state block inside pre block",
        template="
$C_dae_blocks_residual_functions$
",
    generatedCode="
static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1.2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 9;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 8;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _der_a2_11;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(2, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(2, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 2;
            int n2 = 1;
            Q1[0] = 1.0;
            for (i = 0; i < 2; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-1.0);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (1.0);
            }
            Q2[1] = _a2_1;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = _a1_0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _der_a2_11 = x[0];
        }
        _b_2 = _der_a2_11;
        _der_a1_10 = _b_2;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_b2_3, LOG_EXP_NOT(pre_b2_3)), JMI_TRUE, 0.0, 1.0) - (_a1_0 * _der_a2_11 + _der_a1_10 * _a2_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870924;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870924;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _b2_3 = _sw(0);
        }
        if (LOG_EXP_AND(_b2_3, LOG_EXP_NOT(pre_b2_3))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = 0.0;
                if (JMI_GLOBAL(tmp_1) != _x_4) {
                    _x_4 = JMI_GLOBAL(tmp_1);
                    jmi->reinit_triggered = 1;
                }
            }
        }
        if (jmi->atInitial || jmi->atEvent) {
            jmi_dynamic_state_update_states(jmi, 0);
        }
        if (jmi_dynamic_state_check_is_state(jmi, 0, 4)) {
            _a1_0 = __ds_1_s1_7;
            _a2_1 = jmi_divide_equation(jmi, COND_EXP_EQ(LOG_EXP_AND(_b2_3, LOG_EXP_NOT(pre_b2_3)), JMI_TRUE, 1.0, _time), _a1_0, \"(if b2 and not pre(b2) then 1 else time) / ds(1, a1)\");
            __ds_1_a1_6 = _a2_1;
        } else if (jmi_dynamic_state_check_is_state(jmi, 0, 5)) {
            _a2_1 = __ds_1_s1_7;
            _a1_0 = jmi_divide_equation(jmi, COND_EXP_EQ(LOG_EXP_AND(_b2_3, LOG_EXP_NOT(pre_b2_3)), JMI_TRUE, 1.0, _time), _a2_1, \"(if b2 and not pre(b2) then 1 else time) / ds(1, a2)\");
            __ds_1_a1_6 = _a1_0;
        }
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end PreBlock1;

end CCodeGenDynamicStatesTests;
