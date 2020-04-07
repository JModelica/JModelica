/*
    Copyright (C) 2009-2013 Modelon AB

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

package LocalIterationBack
    
    model CGenTest1
        Real a, b, c;
    equation
        20 = c * a;
        23 = c * b;
        c = a + b;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CGenTest1",
            description="Tests c code generation of local iteration in torn blocks",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            local_iteration_in_tearing="all",
            template="
$C_dae_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1.1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 23;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _c_2 * _b_1 - (23);
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
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 20;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _c_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _c_2 = x[0];
        }
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        _a_0 = _c_2 - _b_1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _c_2 * _a_0 - (20);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 1, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"1.1\", 0);
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 2, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
")})));
    end CGenTest1;

end LocalIterationBack;
