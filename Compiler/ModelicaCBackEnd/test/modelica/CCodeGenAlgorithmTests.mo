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


package CCodeGenAlgorithmTests

model Algorithm1
 Real x;
 Real y;
equation
 y = x + 2;
algorithm
 x := 5;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm1",
        description="C code generation of algorithms",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = 5;
    _y_1 = _x_0 + 2;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm1;


model Algorithm2
 Real x;
 Real y;
equation
 y = x + 2;
algorithm
 x := 5;
 x := x + 2;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm2",
        description="C code generation of algorithms",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = 5;
    _x_0 = _x_0 + 2;
    _y_1 = _x_0 + 2;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm2;


model Algorithm3a
 Real x;
 Real y;
equation
 y = x + 2;
algorithm
 x := y;
 x := x * 2;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm3a",
        description="C code generation of algorithms - in block",
        generate_ode=true,
        equation_sorting=true,
        automatic_tearing=false,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _x_0;
            _x_0 = _y_1;
            _x_0 = _x_0 * 2;
            JMI_SWAP(GEN, _x_0, tmp_1)
            (*res)[0] = tmp_1 - (_x_0);
            (*res)[1] = _x_0 + 2 - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _x_0;
            _x_0 = _y_1;
            _x_0 = _x_0 * 2;
            JMI_SWAP(GEN, _x_0, tmp_1)
            (*res)[0] = tmp_1 - (_x_0);
            (*res)[1] = _x_0 + 2 - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm3a;

model Algorithm3b
 Real x;
 Real y;
equation
 y = x + 2;
algorithm
 x := y;
 x := x * 2;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm3b",
        description="C code generation of algorithms - in torn block",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        _x_0 = _y_1;
        _x_0 = _x_0 * 2;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 2 - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        _x_0 = _y_1;
        _x_0 = _x_0 * 2;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 2 - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm3b;


model Algorithm4a
    Real x, y, z;
equation
    y + x + z = 3;
algorithm
    y:= x*2 + 2;
    z:= y + x;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm4a",
        description="C code generation of algorithms - in block",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        automatic_tearing=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
        x[2] = 2;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = (*res)[0];
        (*res)[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
        x[2] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
            _z_2 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _y_1;
            tmp_2 = _z_2;
            _y_1 = _x_0 * 2 + 2;
            _z_2 = _y_1 + _x_0;
            JMI_SWAP(GEN, _y_1, tmp_1)
            JMI_SWAP(GEN, _z_2, tmp_2)
            (*res)[0] = tmp_1 - (_y_1);
            (*res)[1] = tmp_2 - (_z_2);
            (*res)[2] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
        x[2] = 2;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = (*res)[0];
        (*res)[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
        x[2] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
            _z_2 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _y_1;
            tmp_2 = _z_2;
            _y_1 = _x_0 * 2 + 2;
            _z_2 = _y_1 + _x_0;
            JMI_SWAP(GEN, _y_1, tmp_1)
            JMI_SWAP(GEN, _z_2, tmp_2)
            (*res)[0] = tmp_1 - (_y_1);
            (*res)[1] = tmp_2 - (_z_2);
            (*res)[2] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm4a;

model Algorithm4b
    Real x, y, z;
equation
    y + x + z = 3;
algorithm
    y:= x*2 + 2;
    z:= y + x;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm4b",
        description="C code generation of algorithms - in torn block",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
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
        x[0] = 2;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        _y_1 = _x_0 * 2 + 2;
        _z_2 = _y_1 + _x_0;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        _y_1 = _x_0 * 2 + 2;
        _z_2 = _y_1 + _x_0;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm4b;


model Algorithm5
 Real x(start=0.5);
algorithm
 while noEvent(x < 1) loop
  while noEvent(x < 2) loop
   while noEvent(x < 3) loop
    x := x + 1;
   end while;
  end while;
 end while;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm5",
        description="C code generation of algorithm with while loops",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = 0.5;
    while ((COND_EXP_LT(_x_0, 1.0, JMI_TRUE, JMI_FALSE))) {
        while ((COND_EXP_LT(_x_0, 2.0, JMI_TRUE, JMI_FALSE))) {
            while ((COND_EXP_LT(_x_0, 3.0, JMI_TRUE, JMI_FALSE))) {
                _x_0 = _x_0 + 1;
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm5;

model Algorithm6

    function f
        input Real[:] x;
        output Boolean y;
        external;
    end f;
    
    function g
        input Real x;
        input Integer n;
        output Real[n] y;
        external;
    end g;

 Real x(start=0.5);
algorithm
 while f(g(x, noEvent(integer(x)))) loop
    x := x + 1;
 end while;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm6",
        description="C code generation of algorithm with while loops",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 1)
    _x_0 = 0.5;
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_1, ((floor(_x_0))), 1, ((floor(_x_0))))
    func_CCodeGenAlgorithmTests_Algorithm6_g_def1(_x_0, (floor(_x_0)), tmp_1);
    while (func_CCodeGenAlgorithmTests_Algorithm6_f_exp0(tmp_1)) {
        _x_0 = _x_0 + 1;
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_1, ((floor(_x_0))), 1, ((floor(_x_0))))
        func_CCodeGenAlgorithmTests_Algorithm6_g_def1(_x_0, (floor(_x_0)), tmp_1);
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm6;

model Algorithm6b
        function f
            input Real[:] x;
            output Boolean y;
            external;
        end f;
        
        function g
            input Real x;
            input Real n;
            output Real[integer(n)] y;
            external;
        end g;
    
        function k
            input Real x;
            input Integer n;
            output Real[n] y = 1:n .+ x;
            algorithm
        end k;
    
        Real x(start=0.5);
    algorithm
        while f(g(x, sum(k(time, 3)))) loop
            x := x + 1;
        end while;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm6b",
        description="C code generation of algorithm with while loops",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_3, -1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 3, 1)
    _x_0 = 0.5;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    func_CCodeGenAlgorithmTests_Algorithm6b_k_def2(_time, 3.0, tmp_1);
    memcpy(&_temp_1_1_1, &jmi_array_val_1(tmp_1, 1), 3 * sizeof(jmi_real_t));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1, 3)
    func_CCodeGenAlgorithmTests_Algorithm6b_k_def2(_time, 3.0, tmp_2);
    memcpy(&_temp_2_1_4, &jmi_array_val_1(tmp_2, 1), 3 * sizeof(jmi_real_t));
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_3, (floor(_temp_2_1_4 + _temp_2_2_5 + _temp_2_3_6)), 1, (floor(_temp_2_1_4 + _temp_2_2_5 + _temp_2_3_6)))
    func_CCodeGenAlgorithmTests_Algorithm6b_g_def1(_x_0, _temp_1_1_1 + _temp_1_2_2 + _temp_1_3_3, tmp_3);
    while (func_CCodeGenAlgorithmTests_Algorithm6b_f_exp0(tmp_3)) {
        _x_0 = _x_0 + 1;
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1, 3)
        func_CCodeGenAlgorithmTests_Algorithm6b_k_def2(_time, 3.0, tmp_4);
        memcpy(&_temp_1_1_1, &jmi_array_val_1(tmp_4, 1), 3 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 3, 1, 3)
        func_CCodeGenAlgorithmTests_Algorithm6b_k_def2(_time, 3.0, tmp_5);
        memcpy(&_temp_2_1_4, &jmi_array_val_1(tmp_5, 1), 3 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_3, (floor(_temp_2_1_4 + _temp_2_2_5 + _temp_2_3_6)), 1, (floor(_temp_2_1_4 + _temp_2_2_5 + _temp_2_3_6)))
        func_CCodeGenAlgorithmTests_Algorithm6b_g_def1(_x_0, _temp_1_1_1 + _temp_1_2_2 + _temp_1_3_3, tmp_3);
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm6b;

model Algorithm7
	Real x,y,z,a;
algorithm
	x := y;
algorithm
	a := z*x;
equation
	y = x * 2;
	z = time + a;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm7",
        description="C code generation of algorithm.",
        generate_ode=true,
        equation_sorting=true,
        inline_functions="none",
        variability_propagation=false,
        automatic_tearing=false,
        template="
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _x_0;
            _x_0 = _y_1;
            JMI_SWAP(GEN, _x_0, tmp_1)
            (*res)[0] = tmp_1 - (_x_0);
            (*res)[1] = _x_0 * 2 - (_y_1);
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
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_3;
        x[1] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_3 = x[0];
            _z_2 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _a_3;
            _a_3 = _z_2 * _x_0;
            JMI_SWAP(GEN, _a_3, tmp_2)
            (*res)[0] = tmp_2 - (_a_3);
            (*res)[1] = _time + _a_3 - (_z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm7;


model Algorithm8
	Real x,y,z,a;
initial algorithm
	x := y + z;
algorithm
	a := z + x;
equation
	y = x * 2;
	z = time + a;
	when time > 1 then
		x = 2;
	end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm8",
        description="C code generation of initial algorithm.",
        generate_ode=true,
        equation_sorting=true,
        inline_functions="none",
        variability_propagation=false,
        relational_time_events=false,
        automatic_tearing=false,
        template="
$C_dae_init_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
        x[2] = 5;
        x[3] = 0;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
        (*res)[2] = 1;
        (*res)[3] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_3;
        x[1] = _z_2;
        x[2] = _x_0;
        x[3] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_3 = x[0];
            _z_2 = x[1];
            _x_0 = x[2];
            _y_1 = x[3];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _a_3;
            _a_3 = _z_2 + _x_0;
            JMI_SWAP(GEN, _a_3, tmp_1)
            (*res)[0] = tmp_1 - (_a_3);
            (*res)[1] = _time + _a_3 - (_z_2);
            tmp_2 = _x_0;
            _x_0 = _y_1 + _z_2;
            JMI_SWAP(GEN, _x_0, tmp_2)
            (*res)[2] = tmp_2 - (_x_0);
            (*res)[3] = _x_0 * 2 - (_y_1);
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
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
            }
            _temp_1_4 = _sw(0);
        }
        _x_0 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4)), JMI_TRUE, 2.0, pre_x_0);
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
    JMI_DEF(REA, tmp_1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_3;
        x[1] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_3 = x[0];
            _z_2 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _a_3;
            _a_3 = _z_2 + _x_0;
            JMI_SWAP(GEN, _a_3, tmp_1)
            (*res)[0] = tmp_1 - (_a_3);
            (*res)[1] = _time + _a_3 - (_z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _y_1 = _x_0 * 2;
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm8;

model Algorithm9
record R
	Real[3] a;
end R;

function f
	output Real[2] o;
algorithm
	o := {1, 1};
end f;

function fw
protected R r_;
	output R r;
algorithm
	r.a[1:2] := 2*f();
	r.a[2:3] := f();
	r_ := r;
end fw;


R r,re;
algorithm
	r.a[1:2] := 2*f();
	r.a[2:3] := f();
	r := fw();
equation
	re.a[1] = 1;
	(re.a[2:3]) = f();
	
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm9",
        description="C code generation of assignment statements scalarized into function call statements",
        generate_ode=true,
        equation_sorting=true,
        inline_functions="none",
        variability_propagation=false,
        eliminate_alias_variables=false,
        template="
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
void func_CCodeGenAlgorithmTests_Algorithm9_f_def0(jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, o_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_a, 1) = 1;
    jmi_array_ref_1(temp_1_a, 2) = 1;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(o_a, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenAlgorithmTests_Algorithm9_fw_def1(R_0_r* r_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, r__v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_RECORD_STATIC(R_0_r, r_vn)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_2_a, 2, 1)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    r__v->a = tmp_1;
    if (r_v == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1, 3)
        r_vn->a = tmp_2;
        r_v = r_vn;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    func_CCodeGenAlgorithmTests_Algorithm9_f_def0(temp_1_a);
    i1_1in = 0;
    i1_1ie = floor((2) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(r_v->a, i1_1i) = 2 * jmi_array_val_1(temp_1_a, i1_1i);
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_2_a, 2, 1, 2)
    func_CCodeGenAlgorithmTests_Algorithm9_f_def0(temp_2_a);
    i1_2in = 0;
    i1_2ie = floor((2) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        jmi_array_ref_1(r_v->a, 2 + (i1_2i - 1)) = jmi_array_val_1(temp_2_a, i1_2i);
    }
    i1_3in = 0;
    i1_3ie = floor((3) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        jmi_array_ref_1(r__v->a, i1_3i) = jmi_array_val_1(r_v->a, i1_3i);
    }
    JMI_DYNAMIC_FREE()
    return;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_RECORD_STATIC(R_0_r, tmp_3)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenAlgorithmTests_Algorithm9_f_def0(tmp_1);
    memcpy(&_temp_2_1_6, &jmi_array_val_1(tmp_1, 1), 2 * sizeof(jmi_real_t));
    _r_a_1_0 = 2 * _temp_2_1_6;
    _r_a_2_1 = 2 * _temp_2_2_7;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    func_CCodeGenAlgorithmTests_Algorithm9_f_def0(tmp_2);
    memcpy(&_temp_3_1_8, &jmi_array_val_1(tmp_2, 1), 2 * sizeof(jmi_real_t));
    _r_a_2_1 = _temp_3_1_8;
    _r_a_3_2 = _temp_3_2_9;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1, 3)
    tmp_3->a = tmp_4;
    func_CCodeGenAlgorithmTests_Algorithm9_fw_def1(tmp_3);
    memcpy(&_temp_4_a_1_10, &jmi_array_val_1(tmp_3->a, 1), 3 * sizeof(jmi_real_t));
    _r_a_1_0 = _temp_4_a_1_10;
    _r_a_2_1 = _temp_4_a_2_11;
    _r_a_3_2 = _temp_4_a_3_12;
    _re_a_1_3 = 1;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1, 2)
    func_CCodeGenAlgorithmTests_Algorithm9_f_def0(tmp_5);
    memcpy(&_re_a_2_4, &jmi_array_val_1(tmp_5, 1), 2 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm9;

model Algorithm10

function f
	input Real[2] i;
	output Real[2] o;
	output Real dummy = 1;
algorithm
	o := i;
end f;

function fw
	output Real[5] o;
	output Real dummy = 1;
algorithm
	o[{1,3,5}] := {1,1,1};
	(o[{2,4}],) := f(o[{3,5}]);
end fw;

Real[5] a,ae;
algorithm
	(a[{2,4}],) := f({1,1});
	(a[{5,4,3,2,1}],) := fw();
equation
	(ae[{5,4,3,2,1}],) = fw();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm10",
        description="C code generation of slices in function call assignments",
        inline_functions="none",
        variability_propagation=false,
        eliminate_alias_variables=false,
        template="
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
void func_CCodeGenAlgorithmTests_Algorithm10_fw_def0(jmi_array_t* o_a, jmi_real_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, o_an, 5, 1)
    JMI_DEF(REA, dummy_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_2_a, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_3_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_4_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_5_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_6_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, o_an, 5, 1, 5)
        o_a = o_an;
    }
    dummy_v = 1;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1, 3)
    jmi_array_ref_1(temp_1_a, 1) = 1;
    jmi_array_ref_1(temp_1_a, 2) = 3;
    jmi_array_ref_1(temp_1_a, 3) = 5;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_2_a, 3, 1, 3)
    jmi_array_ref_1(temp_2_a, 1) = 1;
    jmi_array_ref_1(temp_2_a, 2) = 1;
    jmi_array_ref_1(temp_2_a, 3) = 1;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(o_a, jmi_array_ref_1(temp_1_a, i1_0i)) = jmi_array_val_1(temp_2_a, i1_0i);
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_4_a, 2, 1, 2)
    jmi_array_ref_1(temp_4_a, 1) = 3;
    jmi_array_ref_1(temp_4_a, 2) = 5;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_3_a, 2, 1, 2)
    i1_1in = 0;
    i1_1ie = floor((2) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(temp_3_a, i1_1i) = jmi_array_val_1(o_a, jmi_array_val_1(temp_4_a, i1_1i));
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_5_a, 2, 1, 2)
    func_CCodeGenAlgorithmTests_Algorithm10_f_def1(temp_3_a, temp_5_a, NULL);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_6_a, 2, 1, 2)
    jmi_array_ref_1(temp_6_a, 1) = 2;
    jmi_array_ref_1(temp_6_a, 2) = 4;
    i1_2in = 0;
    i1_2ie = floor((2) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        jmi_array_ref_1(o_a, jmi_array_ref_1(temp_6_a, i1_2i)) = jmi_array_val_1(temp_5_a, i1_2i);
    }
    JMI_RET(GEN, dummy_o, dummy_v)
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenAlgorithmTests_Algorithm10_f_def1(jmi_array_t* i_a, jmi_array_t* o_a, jmi_real_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, o_an, 2, 1)
    JMI_DEF(REA, dummy_v)
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    dummy_v = 1;
    i1_3in = 0;
    i1_3ie = floor((2) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        jmi_array_ref_1(o_a, i1_3i) = jmi_array_val_1(i_a, i1_3i);
    }
    JMI_RET(GEN, dummy_o, dummy_v)
    JMI_DYNAMIC_FREE()
    return;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 5, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = 1.0;
    jmi_array_ref_1(tmp_2, 2) = 1.0;
    func_CCodeGenAlgorithmTests_Algorithm10_f_def1(tmp_2, tmp_1, NULL);
    _a_2_1 = (jmi_array_val_1(tmp_1, 1));
    _a_4_3 = (jmi_array_val_1(tmp_1, 2));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1, 5)
    func_CCodeGenAlgorithmTests_Algorithm10_fw_def0(tmp_3, NULL);
    _a_5_4 = (jmi_array_val_1(tmp_3, 1));
    _a_4_3 = (jmi_array_val_1(tmp_3, 2));
    _a_3_2 = (jmi_array_val_1(tmp_3, 3));
    _a_2_1 = (jmi_array_val_1(tmp_3, 4));
    _a_1_0 = (jmi_array_val_1(tmp_3, 5));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 5, 1, 5)
    func_CCodeGenAlgorithmTests_Algorithm10_fw_def0(tmp_4, NULL);
    _ae_5_9 = (jmi_array_val_1(tmp_4, 1));
    _ae_4_8 = (jmi_array_val_1(tmp_4, 2));
    _ae_3_7 = (jmi_array_val_1(tmp_4, 3));
    _ae_2_6 = (jmi_array_val_1(tmp_4, 4));
    _ae_1_5 = (jmi_array_val_1(tmp_4, 5));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm10;

model Algorithm11
	Real x,y,z1,z2,z3;
algorithm
	y := x;
	z1 := x;
algorithm
	y := z1;
	z2 := x;
algorithm
	y := z3;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm11",
        description="C code generation of algorithm. Residual from algorithm result.",
        generate_ode=true,
        equation_sorting=true,
        inline_functions="none",
        template="

$C_dae_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 3, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 3;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        tmp_1 = _y_1;
        _y_1 = _x_0;
        _z1_2 = _x_0;
        JMI_SWAP(GEN, _y_1, tmp_1)
        tmp_2 = _y_1;
        _y_1 = _z1_2;
        _z2_3 = _x_0;
        JMI_SWAP(GEN, _y_1, tmp_2)
        _y_1 = (tmp_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_2 - (_y_1);
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
    JMI_DEF(REA, tmp_5)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z3_4;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z3_4 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_5 = _y_1;
            _y_1 = _z3_4;
            JMI_SWAP(GEN, _y_1, tmp_5)
            (*res)[0] = tmp_5 - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm11;

model Algorithm12
 Real x(start=0.5);
 Real y = time;
 Boolean b;
algorithm
 x := 1;
 b := y >= x * 3 or y - 1 < x;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm12",
        description="C code generation of relational expressions in algorithms, assign",
        algorithms_as_functions=false,
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_ode_derivatives$
$C_DAE_event_indicator_residuals$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_1 = _time;
    _x_0 = 1;
    __eventIndicator_1_3 = _y_1 - _x_0 * 3;
    __eventIndicator_2_4 = _y_1 - 1 - _x_0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, __eventIndicator_1_3, _sw(0), JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, __eventIndicator_2_4, _sw(1), JMI_REL_LT);
    }
    _b_2 = LOG_EXP_OR(_sw(0), _sw(1));
    pre_b_2 = _b_2;
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_3;
    (*res)[1] = COND_EXP_EQ(LOG_EXP_NOT(_sw(0)), JMI_TRUE, __eventIndicator_2_4, 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Algorithm12;

model Algorithm13
  Real r1;
algorithm
	if time > 0.5 then 
		r1 := 1;
	elseif time > 1 then
		if time > 0.7 then
			r1 := 2;
		end if;
	else
		if time > 1.5 then
			r1 := 3;
		else
			r1 := 4;
		end if;
	end if;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm13",
        description="C code generation of relational expressions in algorithms, if",
        algorithms_as_functions=false,
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        relational_time_events=false,
        template="
$C_ode_derivatives$
$C_DAE_event_indicator_residuals$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _r1_0 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (0.5), _sw(0), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _time - (1), _sw(1), JMI_REL_GT);
    }
    if (_sw(0)) {
        _r1_0 = 1;
    } else if (_sw(1)) {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(2) = jmi_turn_switch(jmi, _time - (0.7), _sw(2), JMI_REL_GT);
        }
        if (_sw(2)) {
            _r1_0 = 2;
        }
    } else {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(3) = jmi_turn_switch(jmi, _time - (1.5), _sw(3), JMI_REL_GT);
        }
        if (_sw(3)) {
            _r1_0 = 3;
        } else {
            _r1_0 = 4;
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (0.5);
    (*res)[1] = _time - (1);
    (*res)[2] = _time - (0.7);
    (*res)[3] = _time - (1.5);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Algorithm13;

model Algorithm14
	Real x;
algorithm
	when time > 1 then
		x := 2;
	end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm14",
        description="C code generation of when statement",
        generate_ode=true,
        equation_sorting=true,
        inline_functions="none",
        variability_propagation=false,
        relational_time_events=false,
        automatic_tearing=false,
        template="
$C_ode_derivatives$
$C_ode_initialization$
$C_DAE_event_indicator_residuals$
$C_dae_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (1);
    JMI_DYNAMIC_FREE()
    return ef;

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
            }
            _temp_1_1 = _sw(0);
        }
        _x_0 = pre_x_0;
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            _x_0 = 2;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm14;

model Algorithm15
	Real x;
initial equation
	x = 1;
algorithm
	when time > 1 then
		x := 2;
	end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm15",
        description="C code generation of when statement and initial equation",
        generate_ode=true,
        equation_sorting=true,
        inline_functions="none",
        variability_propagation=false,
        relational_time_events=false,
        automatic_tearing=false,
        template="
$C_ode_derivatives$
$C_ode_initialization$
$C_DAE_event_indicator_residuals$
$C_dae_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = 1;
    pre_x_0 = _x_0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (1);
    JMI_DYNAMIC_FREE()
    return ef;

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
            }
            _temp_1_1 = _sw(0);
        }
        _x_0 = pre_x_0;
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            _x_0 = 2;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm15;

model Algorithm16
  Real x;
  discrete Real a,b;
equation
  x = sin(time*10);
algorithm
  when {x >= 0.7} then
    a := a + 1;
  elsewhen {initial(), x < 0.7} then
    a := a - 1;
  elsewhen {x >= 0.7, x >= 0.8, x < 0.8, x < 0.7} then
    b := b + 1;
  end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm16",
        description="C code generation of elsewhen statement",
        generate_ode=true,
        equation_sorting=true,
        inline_functions="none",
        variability_propagation=false,
        automatic_tearing=false,
        template="
$C_ode_derivatives$
$C_ode_initialization$
$C_DAE_event_indicator_residuals$
$C_dae_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = sin(_time * 10.0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(jmi, _x_0 - (0.8), _sw(3), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_0 - (0.8), _sw(2), JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = sin(_time * 10.0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(0), JMI_REL_GEQ);
    }
    _temp_1_3 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
    }
    _temp_2_4 = _sw(1);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(0), JMI_REL_GEQ);
    }
    _temp_3_5 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_0 - (0.8), _sw(2), JMI_REL_GEQ);
    }
    _temp_4_6 = _sw(2);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(jmi, _x_0 - (0.8), _sw(3), JMI_REL_LT);
    }
    _temp_5_7 = _sw(3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
    }
    _temp_6_8 = _sw(1);
    pre_a_1 = 0.0;
    _a_1 = pre_a_1;
    _a_1 = _a_1 - 1;
    pre_b_2 = 0.0;
    _b_2 = pre_b_2;
    pre_temp_1_3 = JMI_FALSE;
    pre_temp_2_4 = JMI_FALSE;
    pre_temp_3_5 = JMI_FALSE;
    pre_temp_4_6 = JMI_FALSE;
    pre_temp_5_7 = JMI_FALSE;
    pre_temp_6_8 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _x_0 - (0.7);
    (*res)[1] = _x_0 - (0.7);
    (*res)[2] = _x_0 - (0.8);
    (*res)[3] = _x_0 - (0.8);
    JMI_DYNAMIC_FREE()
    return ef;

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870922;
        x[1] = 536870921;
        x[2] = 536870920;
        x[3] = 536870919;
        x[4] = 536870918;
        x[5] = 536870917;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
        x[1] = 536870918;
        x[2] = 536870919;
        x[3] = 536870920;
        x[4] = 536870921;
        x[5] = 536870922;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
            }
            _temp_6_8 = _sw(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(3) = jmi_turn_switch(jmi, _x_0 - (0.8), _sw(3), JMI_REL_LT);
            }
            _temp_5_7 = _sw(3);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch(jmi, _x_0 - (0.8), _sw(2), JMI_REL_GEQ);
            }
            _temp_4_6 = _sw(2);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(0), JMI_REL_GEQ);
            }
            _temp_3_5 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
            }
            _temp_2_4 = _sw(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(0), JMI_REL_GEQ);
            }
            _temp_1_3 = _sw(0);
        }
        _a_1 = pre_a_1;
        _b_2 = pre_b_2;
        if (LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3))) {
            _a_1 = _a_1 + 1;
        } else if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_2_4, LOG_EXP_NOT(pre_temp_2_4)))) {
            _a_1 = _a_1 - 1;
        } else if (LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_temp_3_5, LOG_EXP_NOT(pre_temp_3_5)), LOG_EXP_AND(_temp_4_6, LOG_EXP_NOT(pre_temp_4_6))), LOG_EXP_AND(_temp_5_7, LOG_EXP_NOT(pre_temp_5_7))), LOG_EXP_AND(_temp_6_8, LOG_EXP_NOT(pre_temp_6_8)))) {
            _b_2 = _b_2 + 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm16;

model Algorithm17
	parameter Real x(fixed=false);
	parameter Boolean b = false;
initial algorithm
	if b then
		x := 2;
	end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Algorithm17",
            description="C code generation for initial statement of non-fixed parameter",
            generate_ode=true,
            equation_sorting=true,
            inline_functions="none",
            variability_propagation=false,
            automatic_tearing=false,
            template="$C_ode_initialization$",
            generatedCode="

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = 0.0;
    if (_b_1) {
        _x_0 = 2;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm17;

model Algorithm18
    function F
        input Real i1[:];
        output Real a;
        output Real b;
    algorithm
        a := sum(i1);
        b := a * a;
        annotation(Inline=false);
    end F;
    Real a, b, c;
equation
    c = a * b;
algorithm
    (a, b) := F({-c,time});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm18",
        description="C code generation function call statement inside a block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _c_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _c_2 = x[0];
        }
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
        jmi_array_ref_1(tmp_3, 1) = - _c_2;
        jmi_array_ref_1(tmp_3, 2) = _time;
        func_CCodeGenAlgorithmTests_Algorithm18_F_def0(tmp_3, &tmp_1, &tmp_2);
        _a_0 = (tmp_1);
        _b_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a_0 * _b_1 - (_c_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm18;

model Algorithm19
    Integer t;
    Real x;
    Real y[5];
  algorithm
    y := fill(x,5);
    t := 1;
  equation
    x = sum(y) + 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm19",
        description="Mixed algorithm in block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(INT, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 3;
        x[2] = 4;
        x[3] = 5;
        x[4] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435464;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435464;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_1 = x[0];
        }
        tmp_1 = _y_1_2;
        tmp_2 = _t_0;
        _y_1_2 = _x_1;
        _y_2_3 = _x_1;
        _y_3_4 = _x_1;
        _y_4_5 = _x_1;
        _y_5_6 = _x_1;
        _t_0 = 1;
        JMI_SWAP(GEN, _y_1_2, tmp_1)
        JMI_SWAP(GEN, _t_0, tmp_2)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_2);
        }
        _y_1_2 = (tmp_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_1_2 + _y_2_3 + _y_3_4 + (_y_4_5 + _y_5_6) + 1 - (_x_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm19;

model Algorithm20
    function f
        input Real x;
        output Integer[2] i;
    algorithm
        i[1] := integer(x);
        i := (1:2) * i[1];
    end f;
    
    Integer i[2];
    Real x, y;
equation
    y * x = sum(i);
    x = time + y;
algorithm
    i := f(x) .- 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm20",
        description="",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435461;
        x[1] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
        x[1] = 268435461;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_TEMP_VALUE_REFERENCE) {
        x[0] = 268435462;
        x[1] = 268435463;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_3;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_3 = x[0];
        }
        _x_2 = _time + _y_3;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
            func_CCodeGenAlgorithmTests_Algorithm20_f_def0(_x_2, tmp_1);
            memcpy(&_temp_1_1_6, &jmi_array_val_1(tmp_1, 1), 2 * sizeof(jmi_real_t));
            _i_1_0 = _temp_1_1_6 - 1;
            _i_2_1 = _temp_1_2_7 - 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _i_1_0 + _i_2_1 - (_y_3 * _x_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm20;

model Algorithm21
    Real a;
algorithm
    a:=time;
    if a < 1 then
        a := a + 1;
    end if;
    if a < 1 then
        a := a + 1;
    end if;
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm21",
        description="",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _a_0 = _time;
    __eventIndicator_1_1 = _a_0 - 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, __eventIndicator_1_1, _sw(0), JMI_REL_LT);
    }
    if (_sw(0)) {
        _a_0 = _a_0 + 1;
    }
    __eventIndicator_2_2 = _a_0 - 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, __eventIndicator_2_2, _sw(1), JMI_REL_LT);
    }
    if (_sw(1)) {
        _a_0 = _a_0 + 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm21;

model Algorithm22
    Real a;
    Real b = time;
algorithm
    if b < 1 then
        a := a + 1;
    end if;
    if b < 1 then
        a := a + 1;
    end if;
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm22",
        description="",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _b_1 = _time;
    _a_0 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _b_1 - (1), _sw(0), JMI_REL_LT);
    }
    if (_sw(0)) {
        _a_0 = _a_0 + 1;
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _b_1 - (1), _sw(0), JMI_REL_LT);
    }
    if (_sw(0)) {
        _a_0 = _a_0 + 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm22;

model Algorithm23
    parameter Real x_start = 1;
    Real x(start=x_start);
algorithm
    if time > 1 then
        x := x + 1;
    end if;
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm23",
        description="Check for bug in #5415",
        template="
$C_ode_initialization$
$C_ode_derivatives$
",
        generatedCode="

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1 = _x_start_0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        _x_1 = _x_1 + 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1 = _x_start_0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        _x_1 = _x_1 + 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm23;

model Algorithm24
    Real a,b(start=1);
    Integer xVar,cVar;
    Boolean shift;
initial equation
    a = 0;
algorithm
    if time -a > 1 then
        if b > 0.5 then
            xVar :=xVar +1;
        else
            xVar := 0;
        end if;
        else
         xVar := 0;
    end if;
    shift := xVar <> 0;
    
    when shift then
        cVar := pre(cVar) + 1; 
        a := time;
    end when;
equation
    a^2 - b^2 = -1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm24",
        description="Check for bug in #5445",
        template="
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, tmp_1)
    JMI_DEF(BOO, tmp_2)
    JMI_DEF(INT, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_START) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_START_SET) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435461;
        x[1] = 536870919;
        x[2] = 268435462;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435461;
        x[1] = 536870919;
        x[2] = 268435462;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 1;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
        }
        tmp_1 = _xVar_2;
        tmp_2 = _shift_4;
        tmp_3 = _cVar_3;
        tmp_4 = _a_0;
        _xVar_2 = pre_xVar_2;
        _cVar_3 = pre_cVar_3;
        _a_0 = pre_a_0;
        __eventIndicator_1_5 = _time - _a_0 - 1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch(jmi, __eventIndicator_1_5, _sw(0), JMI_REL_GT);
        }
        if (_sw(0)) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _b_1 - (0.5), _sw(1), JMI_REL_GT);
            }
            if (_sw(1)) {
                _xVar_2 = _xVar_2 + 1;
            } else {
                _xVar_2 = 0;
            }
        } else {
            _xVar_2 = 0;
        }
        _shift_4 = COND_EXP_EQ(_xVar_2, 0, JMI_FALSE, JMI_TRUE);
        if (LOG_EXP_AND(_shift_4, LOG_EXP_NOT(pre_shift_4))) {
            _cVar_3 = pre_cVar_3 + 1;
            _a_0 = _time;
        }
        JMI_SWAP(GEN, _xVar_2, tmp_1)
        JMI_SWAP(GEN, _shift_4, tmp_2)
        JMI_SWAP(GEN, _cVar_3, tmp_3)
        JMI_SWAP(GEN, _a_0, tmp_4)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _xVar_2 = (tmp_1);
            _shift_4 = (tmp_2);
            _cVar_3 = (tmp_3);
        }
        _a_0 = (tmp_4);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = -1 - ((1.0 * (_a_0) * (_a_0)) - (1.0 * (_b_1) * (_b_1)));
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm24;

model Algorithm25
    String s1,s2;
    Real x,y;
equation
    y = x/2;
    when time > 1 then
        s2 = String(time);
    end when;
algorithm
    x := time + y;
    when time > 1 then
        s1 := s2 + s2;
    end when;
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Algorithm25",
        description="String variables in algorithm block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(STR, tmp_4)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
        x[1] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_STRING_VALUE_REFERENCE) {
        x[0] = 805306369;
        x[1] = 805306368;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_3;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_3 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_2_5 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_4 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
                JMI_INI_STR_STAT(tmp_1)
                snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
            } else {
            }
            JMI_ASG(STR_Z, _s_w_s2_1, COND_EXP_EQ(LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4)), JMI_TRUE, tmp_1, pre_s2_1))
        }
        tmp_3 = _x_2;
        JMI_ASG(STR, tmp_4, _s_w_s1_0)
        JMI_ASG(STR_Z, _s_w_s1_0, pre_s1_0)
        _x_2 = _time + _y_3;
        if (LOG_EXP_AND(_temp_2_5, LOG_EXP_NOT(pre_temp_2_5))) {
            JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s2_1) + JMI_LEN(_s_w_s2_1))
            snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s2_1);
            snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s2_1);
            JMI_ASG(STR_Z, _s_w_s1_0, tmp_2)
        }
        JMI_SWAP(GEN, _x_2, tmp_3)
        JMI_SWAP(STR, _s_w_s1_0, tmp_4)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            JMI_ASG(STR_Z, _s_w_s1_0, tmp_4)
        }
        _x_2 = (tmp_3);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = jmi_divide_equation(jmi, _x_2, 2, \"x / 2\") - (_y_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end Algorithm25;

end CCodeGenAlgorithmTests;
