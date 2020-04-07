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


package CCodeGenJacobianTests

package SparseBlockJacobian

    model NonlinearBlock
        Real x;
        Real y;
    equation
        2 = x^2+x^1+y;
        x*y = 0;
        
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SparseBlockJacobian_NonlinearBlock",
            description="Test that generation of nonlinear blocks work with the sparse threshold set to 0.",
            generate_sparse_block_jacobian_threshold=0,
            template="
$C_dae_blocks_residual_functions$
------
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        _y_1 = 2 - (1.0 * (_x_0) * (_x_0)) - (1.0 * (_x_0));
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 0 - (_x_0 * _y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


------
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 1, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
")})));
    end NonlinearBlock;

    model Simple1
        Real x[3];
        parameter Real b[3] = {2, 1, 4};
    equation
        b[1] = 2 * x[1] + x[2];
        b[2] = x[1] + 2 * x[3];
        b[3] = 2 * x[2] + x[3];
        
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SparseBlockJacobian_Simple1",
            description="Test generation of sparse block jacobians for linear systems",
            generate_sparse_block_jacobian_threshold=0,
            template="
$C_dae_blocks_residual_functions$
------
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_b_2_4), jmi_max(1.0, jmi_abs(2.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_3_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        ef = -1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_3_2 = x[0];
        }
        _x_2_1 = jmi_divide_equation(jmi, (- _b_3_5 + _x_3_2), -2, \"(- b[3] + x[3]) / -2\");
        _x_1_0 = jmi_divide_equation(jmi, (- _b_1_3 + _x_2_1), -2, \"(- b[1] + x[2]) / -2\");
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_1_0 + 2 * _x_3_2 - (_b_2_4);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

void L_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 3;
    (*jac)[1] = 2;
    (*jac)[2] = 2;
}
void A12_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 2;
}
void A21_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 2;
    (*jac)[2] = 1;
}
void A22_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void L_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 2;
    (*jac)[2] = 3;
}
void A12_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
}
void A21_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 0;
    (*jac)[2] = 1;
}
void A22_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
}
void L_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void A12_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void A21_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void A22_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void L_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -2;
    (*jac)[1] = -1.0;
    (*jac)[2] = -2;
}
void A12_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -1.0;
}
void A21_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -1.0;
}
void A22_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -2;
}

jmi_jacobian_quadrants_t *jacobian_init_0() {
    jmi_jacobian_quadrants_t *jc = (jmi_jacobian_quadrants_t *) malloc(sizeof(jmi_jacobian_quadrants_t));
    jc->L.dim = &L_0_dim;
    jc->L.col = &L_0_col;
    jc->L.row = &L_0_row;
    jc->L.eval = &L_0_eval;
    jc->A12.dim = &A12_0_dim;
    jc->A12.col = &A12_0_col;
    jc->A12.row = &A12_0_row;
    jc->A12.eval = &A12_0_eval;
    jc->A21.dim = &A21_0_dim;
    jc->A21.col = &A21_0_col;
    jc->A21.row = &A21_0_row;
    jc->A21.eval = &A21_0_eval;
    jc->A22.dim = &A22_0_dim;
    jc->A22.col = &A22_0_col;
    jc->A22.row = &A22_0_row;
    jc->A22.eval = &A22_0_eval;
    return jc;
}

static int jacobian_0(jmi_t *jmi, jmi_real_t *x, jmi_real_t **jac, int mode) {
    int ef = 0;
    jmi_jacobian_quadrants_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_L) {
        jc->L.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A12) {
        jc->A12.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A21) {
        jc->A21.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A22) {
        jc->A22.eval(jmi, jac);
    }

    free(jc);
    return ef;
}

static int jacobian_struct_0(jmi_t *jmi, jmi_real_t *x, jmi_int_t **jac, int mode) {
    int ef = 0;
    jmi_jacobian_quadrants_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_DIMENSIONS) {
        jc->L.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_COLPTR) {
        jc->L.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_ROWIND) {
        jc->L.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_DIMENSIONS) {
        jc->A12.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_COLPTR) {
        jc->A12.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_ROWIND) {
        jc->A12.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_DIMENSIONS) {
        jc->A21.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_COLPTR) {
        jc->A21.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_ROWIND) {
        jc->A21.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_DIMENSIONS) {
        jc->A22.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_COLPTR) {
        jc->A22.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_ROWIND) {
        jc->A22.row(jac);
    }

    free(jc);
    return ef;
}


------
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, jacobian_0, jacobian_struct_0, 1, 2, 0, 0, 0, 0, 0, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
    end Simple1;
    
    model Simple2
        function F
            input Real[:] x;
            output Real y;
        algorithm
            y := sum(x);
        annotation(Inline=false);
        end F;
        Real x[3];
        parameter Real b[3] = {2, 1, 4};
        parameter Real[:] p1 = {1,2,3,4};
    equation
        b[1] = 2 * x[1] + x[2];
        b[2] = x[1] + F(p1) * x[3];
        b[3] = 2 * x[2] + x[3];
        
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SparseBlockJacobian_Simple2",
            description="Test generation of temporary variables in sparse block jacobians",
            generate_sparse_block_jacobian_threshold=0,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 4, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 9;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 8;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_b_3_5), jmi_max(jmi_abs(2.0), 1.0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_3_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        ef = -1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_3_2 = x[0];
        }
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 4, 1, 4)
        memcpy(&jmi_array_ref_1(tmp_1, 1), &_p1_1_6, 4 * sizeof(jmi_real_t));
        _x_1_0 = _b_2_4 - func_CCodeGenJacobianTests_SparseBlockJacobian_Simple2_F_exp0(tmp_1) * _x_3_2;
        _x_2_1 = _b_1_3 - 2 * _x_1_0;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 2 * _x_2_1 + _x_3_2 - (_b_3_5);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

void L_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 3;
    (*jac)[1] = 2;
    (*jac)[2] = 2;
}
void A12_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 2;
}
void A21_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 2;
    (*jac)[2] = 1;
}
void A22_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void L_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 2;
    (*jac)[2] = 3;
}
void A12_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
}
void A21_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 0;
    (*jac)[2] = 1;
}
void A22_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
}
void L_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void A12_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void A21_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void A22_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void L_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -1.0;
    (*jac)[1] = -2;
    (*jac)[2] = -1.0;
}
void A12_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 4, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 4, 1, 4)
    memcpy(&jmi_array_ref_1(tmp_2, 1), &_p1_1_6, 4 * sizeof(jmi_real_t));
    (*jac)[0] = - func_CCodeGenJacobianTests_SparseBlockJacobian_Simple2_F_exp0(tmp_2);
}
void A21_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -2;
}
void A22_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -1.0;
}

jmi_jacobian_quadrants_t *jacobian_init_0() {
    jmi_jacobian_quadrants_t *jc = (jmi_jacobian_quadrants_t *) malloc(sizeof(jmi_jacobian_quadrants_t));
    jc->L.dim = &L_0_dim;
    jc->L.col = &L_0_col;
    jc->L.row = &L_0_row;
    jc->L.eval = &L_0_eval;
    jc->A12.dim = &A12_0_dim;
    jc->A12.col = &A12_0_col;
    jc->A12.row = &A12_0_row;
    jc->A12.eval = &A12_0_eval;
    jc->A21.dim = &A21_0_dim;
    jc->A21.col = &A21_0_col;
    jc->A21.row = &A21_0_row;
    jc->A21.eval = &A21_0_eval;
    jc->A22.dim = &A22_0_dim;
    jc->A22.col = &A22_0_col;
    jc->A22.row = &A22_0_row;
    jc->A22.eval = &A22_0_eval;
    return jc;
}

static int jacobian_0(jmi_t *jmi, jmi_real_t *x, jmi_real_t **jac, int mode) {
    int ef = 0;
    jmi_jacobian_quadrants_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_L) {
        jc->L.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A12) {
        jc->A12.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A21) {
        jc->A21.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A22) {
        jc->A22.eval(jmi, jac);
    }

    free(jc);
    return ef;
}

static int jacobian_struct_0(jmi_t *jmi, jmi_real_t *x, jmi_int_t **jac, int mode) {
    int ef = 0;
    jmi_jacobian_quadrants_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_DIMENSIONS) {
        jc->L.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_COLPTR) {
        jc->L.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_ROWIND) {
        jc->L.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_DIMENSIONS) {
        jc->A12.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_COLPTR) {
        jc->A12.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_ROWIND) {
        jc->A12.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_DIMENSIONS) {
        jc->A21.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_COLPTR) {
        jc->A21.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_ROWIND) {
        jc->A21.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_DIMENSIONS) {
        jc->A22.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_COLPTR) {
        jc->A22.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_ROWIND) {
        jc->A22.row(jac);
    }

    free(jc);
    return ef;
}

")})));
    end Simple2;
	
model Simple3
        Real x[3];
        parameter Real b[3] = {2, 1, 4};
    equation
        b[1] = 2 * x[1] + x[2];
        b[2] = x[1] + 2 * x[3];
        b[3] = 2 * x[2] + x[3];
        
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SparseBlockJacobian_Simple3",
        description="Test generation of sparse block jacobians for linear systems at threshold",
        generate_sparse_block_jacobian_threshold=2,
        template="
$C_dae_blocks_residual_functions$
------
$C_dae_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_b_2_4), jmi_max(1.0, jmi_abs(2.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_3_2;
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
            Q1[0] = -1.0;
            for (i = 0; i < 2; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-2);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (-2);
            }
            Q2[1] = -1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = -2;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_3_2 = x[0];
        }
        _x_2_1 = jmi_divide_equation(jmi, (- _b_3_5 + _x_3_2), -2, \"(- b[3] + x[3]) / -2\");
        _x_1_0 = jmi_divide_equation(jmi, (- _b_1_3 + _x_2_1), -2, \"(- b[1] + x[2]) / -2\");
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_1_0 + 2 * _x_3_2 - (_b_2_4);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


------
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 2, 0, 0, 0, 0, 0, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end Simple3;

model Simple4
        Real x[3];
        parameter Real b[3] = {2, 1, 4};
    equation
        b[1] = 2 * x[1] + x[2];
        b[2] = x[1] + 2 * x[3];
        b[3] = 2 * x[2] + x[3];
        
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SparseBlockJacobian_Simple4",
        description="Test generation of sparse block jacobians for linear systems with just above threshold",
        generate_sparse_block_jacobian_threshold=1,
        template="
$C_dae_blocks_residual_functions$
------
$C_dae_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_b_2_4), jmi_max(1.0, jmi_abs(2.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_3_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        ef = -1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_3_2 = x[0];
        }
        _x_2_1 = jmi_divide_equation(jmi, (- _b_3_5 + _x_3_2), -2, \"(- b[3] + x[3]) / -2\");
        _x_1_0 = jmi_divide_equation(jmi, (- _b_1_3 + _x_2_1), -2, \"(- b[1] + x[2]) / -2\");
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_1_0 + 2 * _x_3_2 - (_b_2_4);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

void L_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 3;
    (*jac)[1] = 2;
    (*jac)[2] = 2;
}
void A12_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 2;
}
void A21_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 2;
    (*jac)[2] = 1;
}
void A22_0_dim(jmi_int_t **jac) {
    (*jac)[0] = 1;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void L_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 2;
    (*jac)[2] = 3;
}
void A12_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
}
void A21_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 0;
    (*jac)[2] = 1;
}
void A22_0_col(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
}
void L_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
    (*jac)[1] = 1;
    (*jac)[2] = 1;
}
void A12_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void A21_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void A22_0_row(jmi_int_t **jac) {
    (*jac)[0] = 0;
}
void L_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -2;
    (*jac)[1] = -1.0;
    (*jac)[2] = -2;
}
void A12_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -1.0;
}
void A21_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -1.0;
}
void A22_0_eval(jmi_t *jmi, jmi_real_t **jac) {
    (*jac)[0] = -2;
}

jmi_jacobian_quadrants_t *jacobian_init_0() {
    jmi_jacobian_quadrants_t *jc = (jmi_jacobian_quadrants_t *) malloc(sizeof(jmi_jacobian_quadrants_t));
    jc->L.dim = &L_0_dim;
    jc->L.col = &L_0_col;
    jc->L.row = &L_0_row;
    jc->L.eval = &L_0_eval;
    jc->A12.dim = &A12_0_dim;
    jc->A12.col = &A12_0_col;
    jc->A12.row = &A12_0_row;
    jc->A12.eval = &A12_0_eval;
    jc->A21.dim = &A21_0_dim;
    jc->A21.col = &A21_0_col;
    jc->A21.row = &A21_0_row;
    jc->A21.eval = &A21_0_eval;
    jc->A22.dim = &A22_0_dim;
    jc->A22.col = &A22_0_col;
    jc->A22.row = &A22_0_row;
    jc->A22.eval = &A22_0_eval;
    return jc;
}

static int jacobian_0(jmi_t *jmi, jmi_real_t *x, jmi_real_t **jac, int mode) {
    int ef = 0;
    jmi_jacobian_quadrants_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_L) {
        jc->L.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A12) {
        jc->A12.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A21) {
        jc->A21.eval(jmi, jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_EVALUATE_A22) {
        jc->A22.eval(jmi, jac);
    }

    free(jc);
    return ef;
}

static int jacobian_struct_0(jmi_t *jmi, jmi_real_t *x, jmi_int_t **jac, int mode) {
    int ef = 0;
    jmi_jacobian_quadrants_t *jc = jacobian_init_0();
    int evaluation_mode = mode;

    if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_DIMENSIONS) {
        jc->L.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_COLPTR) {
        jc->L.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_L_ROWIND) {
        jc->L.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_DIMENSIONS) {
        jc->A12.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_COLPTR) {
        jc->A12.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A12_ROWIND) {
        jc->A12.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_DIMENSIONS) {
        jc->A21.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_COLPTR) {
        jc->A21.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A21_ROWIND) {
        jc->A21.row(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_DIMENSIONS) {
        jc->A22.dim(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_COLPTR) {
        jc->A22.col(jac);
    } else if (evaluation_mode == JMI_BLOCK_JACOBIAN_A22_ROWIND) {
        jc->A22.row(jac);
    }

    free(jc);
    return ef;
}


------
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, jacobian_0, jacobian_struct_0, 1, 2, 0, 0, 0, 0, 0, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end Simple4;
    
end SparseBlockJacobian;
    
    model SwitchDense1
        Real x[3];
        parameter Real b[3] = {2, 1, 4};
    equation
        b[1] = if x[1] > 3 then 2 * x[1] + x[2] else x[1] + x[2];
        b[2] = x[1] + 2 * x[3];
        b[3] = 2 * x[2] + x[3];
        
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SwitchDense1",
            description="Test code generation for switch in dense jacobian",
            template="
$C_dae_blocks_residual_functions$
------
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_b_1_3), jmi_max(jmi_max(jmi_abs(2.0), 1.0), jmi_max(1.0, 1.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_1_0;
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
            Q1[0] = -1.0;
            for (i = 0; i < 2; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (-2);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (-2);
            }
            Q2[1] = -1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = - COND_EXP_EQ(_sw(0), JMI_TRUE, 2.0, 1.0);
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_1_0 = x[0];
        }
        _x_3_2 = jmi_divide_equation(jmi, (- _b_2_4 + _x_1_0), -2, \"(- b[2] + x[1]) / -2\");
        _x_2_1 = jmi_divide_equation(jmi, (- _b_3_5 + _x_3_2), -2, \"(- b[3] + x[3]) / -2\");
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_1_0 - (3.0), _sw(0), JMI_REL_GT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, 2.0 * _x_1_0 + _x_2_1, _x_1_0 + _x_2_1) - (_b_1_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


------
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 2, 0, 0, 0, 0, 0, 1, 1, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
    end SwitchDense1;

model MultipleSolvedRealInAlgorithm
    Real x(min=0,start=5),y,z;
    Real a;
algorithm
    when sample(0,1) then
        y := x;
        a := time;
    end when;
equation
    der(z) = integer(time);
    der(z) = x;
        
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="MultipleSolvedRealInAlgorithm",
        description="Test bug in #5252",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(BOO, tmp_1)
    JMI_DEF(INT, tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 2;
        x[2] = 5;
        x[3] = 6;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 6;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435463;
        x[1] = 536870921;
        x[2] = 268435464;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435463;
        x[1] = 536870921;
        x[2] = 268435464;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch_time(jmi, _time - (pre_temp_2_5), _sw(2), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(3) = jmi_turn_switch_time(jmi, _time - (pre_temp_2_5 + 1.0), _sw(3), JMI_REL_GEQ);
            }
            _temp_2_5 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(2), _sw(3)), _atInitial), JMI_TRUE, floor(_time), pre_temp_2_5);
        }
        _der_z_12 = _temp_2_5;
        _x_0 = _der_z_12;
        tmp_1 = _temp_1_4;
        tmp_2 = __sampleItr_1_6;
        tmp_3 = _y_1;
        tmp_4 = _a_3;
        __sampleItr_1_6 = pre__sampleItr_1_6;
        _y_1 = pre_y_1;
        _a_3 = pre_a_3;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_6), _sw(0), JMI_REL_GEQ);
        }
        _temp_1_4 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            __sampleItr_1_6 = pre__sampleItr_1_6 + 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_6 + 1.0), _sw(1), JMI_REL_LT);
        }
        if (_sw(1) == JMI_FALSE) {
            jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            _y_1 = _x_0;
            _a_3 = _time;
        }
        JMI_SWAP(GEN, _temp_1_4, tmp_1)
        JMI_SWAP(GEN, __sampleItr_1_6, tmp_2)
        JMI_SWAP(GEN, _y_1, tmp_3)
        JMI_SWAP(GEN, _a_3, tmp_4)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _temp_1_4 = (tmp_1);
            __sampleItr_1_6 = (tmp_2);
        }
        _y_1 = (tmp_3);
        _a_3 = (tmp_4);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end MultipleSolvedRealInAlgorithm;


model MultipleSolvedRealInAlgorithm2
    Real x(min=0,start=5),y,z;
    Real a;
algorithm
    when sample(0,1) then
        y := x;
        a := time;
    end when;
equation
    der(z) = integer(time);
    der(z) = x;
        
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="MultipleSolvedRealInAlgorithm2",
        description="",
        generate_sparse_block_jacobian_threshold=0,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(BOO, tmp_1)
    JMI_DEF(INT, tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 2;
        x[2] = 5;
        x[3] = 6;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 6;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435463;
        x[1] = 536870921;
        x[2] = 268435464;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435463;
        x[1] = 536870921;
        x[2] = 268435464;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch_time(jmi, _time - (pre_temp_2_5), _sw(2), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(3) = jmi_turn_switch_time(jmi, _time - (pre_temp_2_5 + 1.0), _sw(3), JMI_REL_GEQ);
            }
            _temp_2_5 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(2), _sw(3)), _atInitial), JMI_TRUE, floor(_time), pre_temp_2_5);
        }
        _der_z_12 = _temp_2_5;
        _x_0 = _der_z_12;
        tmp_1 = _temp_1_4;
        tmp_2 = __sampleItr_1_6;
        tmp_3 = _y_1;
        tmp_4 = _a_3;
        __sampleItr_1_6 = pre__sampleItr_1_6;
        _y_1 = pre_y_1;
        _a_3 = pre_a_3;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_6), _sw(0), JMI_REL_GEQ);
        }
        _temp_1_4 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            __sampleItr_1_6 = pre__sampleItr_1_6 + 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_6 + 1.0), _sw(1), JMI_REL_LT);
        }
        if (_sw(1) == JMI_FALSE) {
            jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            _y_1 = _x_0;
            _a_3 = _time;
        }
        JMI_SWAP(GEN, _temp_1_4, tmp_1)
        JMI_SWAP(GEN, __sampleItr_1_6, tmp_2)
        JMI_SWAP(GEN, _y_1, tmp_3)
        JMI_SWAP(GEN, _a_3, tmp_4)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _temp_1_4 = (tmp_1);
            __sampleItr_1_6 = (tmp_2);
        }
        _y_1 = (tmp_3);
        _a_3 = (tmp_4);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end MultipleSolvedRealInAlgorithm2;
end CCodeGenJacobianTests;
