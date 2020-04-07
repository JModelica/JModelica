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


package CCodeGenTests

model CCodeGenTest1
  Real x1(start=0); 
  Real x2(start=1); 
  input Real u;
  parameter Real p = 1;
  Real w = x1+x2;
equation 
  der(x1) = (1-x2^2)*x1 - x2 + p*u; 
  der(x2) = x1; 

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest1",
        description="Test of code generation",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
        generatedCode="
#define _p_3 ((*(jmi->z))[0])
#define _der_x1_5 ((*(jmi->z))[1])
#define _der_x2_6 ((*(jmi->z))[2])
#define _x1_0 ((*(jmi->z))[3])
#define _x2_1 ((*(jmi->z))[4])
#define _u_2 ((*(jmi->z))[5])
#define _w_4 ((*(jmi->z))[6])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])

    (*res)[0] = (1 - (1.0 * (_x2_1) * (_x2_1))) * _der_x2_6 - _x2_1 + _p_3 * _u_2 - (_der_x1_5);
    (*res)[1] = _x1_0 - (_der_x2_6);
    (*res)[2] = _der_x2_6 + _x2_1 - (_w_4);
")})));
end CCodeGenTest1;


	model CCodeGenTest2
		Real x(start=1);
		Real y(start=3)=3;
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest2",
            description="Test of code generation",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="
$C_variable_aliases$
$C_DAE_equation_residuals$
$C_DAE_initial_equation_residuals$
$C_DAE_initial_guess_equation_residuals$
",
            generatedCode="
#define _der_x_4 ((*(jmi->z))[0])
#define _der_v_5 ((*(jmi->z))[1])
#define _x_0 ((*(jmi->z))[2])
#define _v_3 ((*(jmi->z))[3])
#define _y_1 ((*(jmi->z))[4])
#define _w_2 ((*(jmi->z))[5])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])

    (*res)[0] = - _x_0 - (_der_x_4);
    (*res)[1] = 4 - (_der_v_5);
    (*res)[2] = 3 - (_y_1);
    (*res)[3] = 2 - (_w_2);

    (*res)[0] = - _x_0 - (_der_x_4);
    (*res)[1] = 4 - (_der_v_5);
    (*res)[2] = 3 - (_y_1);
    (*res)[3] = 2 - (_w_2);
    (*res)[4] = 1 - (_x_0);
    (*res)[5] = 0.0 - (_v_3);

    (*res)[0] = 1 - _x_0;
    (*res)[1] = 3 - _y_1;
    (*res)[2] = 1 - _w_2;
    (*res)[3] = 0.0 - _v_3;
")})));
	end CCodeGenTest2;

	model CCodeGenTest3
	    parameter Real p3 = p2;
	    parameter Real p2 = p1*p1;
		parameter Real p1 = 4;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest3",
            description="Test of code generation",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_initial_dependent_parameter_residuals$",
            generatedCode="
    (*res)[0] = _p1_2 * _p1_2 - (_p2_0);
    (*res)[1] = _p2_0 - (_p3_1);
")})));
	end CCodeGenTest3;


model CCodeGenTest4
  Real x(start=0);
  Real y = noEvent(if time <= Modelica.Constants.pi/2 then sin(time) else x);
equation
  der(x) = y; 

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest4",
        description="Test of code generation",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = _y_1 - (_der_x_2);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(_time, jmi_divide_equation(jmi, 3.141592653589793, 2.0, \"3.141592653589793 / 2\"), JMI_TRUE, JMI_FALSE), JMI_TRUE, sin(_time), _x_0)) - (_der_x_2);
")})));
end CCodeGenTest4;


model CCodeGenTest5
  parameter Real one = 1;
  parameter Real two = 2;
  Real x(start=0.1,fixed=true);
  Real y = noEvent(if time <= one then x else if time <= two then -2*x else 3*x);
equation
  der(x) = y; 

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest5",
        description="Test of code generation",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = _y_3 - (_der_x_4);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(_time, _one_0, JMI_TRUE, JMI_FALSE), JMI_TRUE, _x_2, COND_EXP_EQ(COND_EXP_LE(_time, _two_1, JMI_TRUE, JMI_FALSE), JMI_TRUE, -2.0 * _x_2, 3.0 * _x_2))) - (_der_x_4);
")})));
end CCodeGenTest5;

model CCodeGenTest6
  parameter Real p=1;
  parameter Real one = 1;
  parameter Real two = 2;
  Real x(start=0.1,fixed=true);
  Real y = if time <= one then x else if time <= two then -2*x else 3*x;
  Real z;
initial equation
  z = if p>=one then one else two; 
equation
  der(x) = y; 
  der(z) = -z;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest6",
            description="Test of code generation",
            variability_propagation=false,
            relational_time_events=false,
            template="
$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
            generatedCode="
    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (_one_1);
    (*res)[1] = COND_EXP_EQ(LOG_EXP_NOT(_sw(0)), JMI_TRUE, _time - (_two_2), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (_one_1);
    (*res)[1] = COND_EXP_EQ(LOG_EXP_NOT(_sw(0)), JMI_TRUE, _time - (_two_2), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end CCodeGenTest6;

model CCodeGenTest7
  parameter Integer z = 2;
  Real x(start=0);
  Real y = noEvent(if time <= 2 then 0 else if time >= 4 then 1 
   else if x < 2 then 2 else if x > 4 then 4 
   else if z == 3 then 4 else 7);
equation
 der(x) = y; 

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest7",
        description="Test of code generation. Verify that no event indicators are generated from relational expressions inside noEvent operators.",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="
$C_DAE_equation_residuals$
$C_DAE_event_indicator_residuals$
",
        generatedCode="
    (*res)[0] = _y_2 - (_der_x_3);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(_time, 2.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 0.0, COND_EXP_EQ(COND_EXP_GE(_time, 4.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, COND_EXP_EQ(COND_EXP_LT(_x_1, 2.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 2.0, COND_EXP_EQ(COND_EXP_GT(_x_1, 4.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 4.0, COND_EXP_EQ(COND_EXP_EQ(_z_0, 3.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 4.0, 7.0)))))) - (_der_x_3);

    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end CCodeGenTest7;

model CCodeGenTest8
  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
equation
   x = if time>=1 then (-1 + y) else  (- y);
   y = z + x +(if z>=-1.5 then -3 else 3);
   z = -y  - x + (if y>=0.5 then -1 else 1);


annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest8",
        description="Test of code generation",
        variability_propagation=false,
        relational_time_events=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, -1.0 + _y_1, - _y_1) - (_x_0);
    (*res)[1] = _z_2 + _x_0 + COND_EXP_EQ(_sw(1), JMI_TRUE, -3.0, 3.0) - (_y_1);
    (*res)[2] = - _y_1 - _x_0 + COND_EXP_EQ(_sw(2), JMI_TRUE, -1.0, 1.0) - (_z_2);
")})));
end CCodeGenTest8;

model CCodeGenTest9
  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
initial equation
   x = noEvent(if time>=1 then (-1 + y) else  (- y));
   y = 2 * noEvent(z + x +(if z>=-1.5 then -3 else 3));
   z = -y  - x + (if y>=0.5 then -1 else 1);
equation
   der(x) = -x;
   der(y) = -y;
   der(z) = -z;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest9",
        description="Test of code generation",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="
$C_DAE_initial_equation_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
    (*res)[0] = - _x_0 - (_der_x_3);
    (*res)[1] = - _y_1 - (_der_y_4);
    (*res)[2] = - _z_2 - (_der_z_5);
    (*res)[3] = (COND_EXP_EQ(COND_EXP_GE(_time, 1.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, -1.0 + _y_1, - _y_1)) - (_x_0);
    (*res)[4] = 2 * (_z_2 + _x_0 + COND_EXP_EQ(COND_EXP_GE(_z_2, -1.5, JMI_TRUE, JMI_FALSE), JMI_TRUE, -3.0, 3.0)) - (_y_1);
    (*res)[5] = - _y_1 - _x_0 + COND_EXP_EQ(_sw_init(0), JMI_TRUE, -1.0, 1.0) - (_z_2);

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _y_1 - (0.5);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end CCodeGenTest9;

model CCodeGenTest10
  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
initial equation
   x = if time>=1 then (-1 + y) else  (- y);
   y = z + x +(if z>=-1.5 then -3 else 3);
   z = -y  - x + (if y>=0.5 then -1 else 1);
equation
   der(x) = -x;
   der(y) = -y;
   der(z) = -z;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest10",
        description="Test of code generation",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="
$C_DAE_initial_equation_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
    (*res)[0] = - _x_0 - (_der_x_3);
    (*res)[1] = - _y_1 - (_der_y_4);
    (*res)[2] = - _z_2 - (_der_z_5);
    (*res)[3] = COND_EXP_EQ(_sw_init(0), JMI_TRUE, -1.0 + _y_1, - _y_1) - (_x_0);
    (*res)[4] = _z_2 + _x_0 + COND_EXP_EQ(_sw_init(1), JMI_TRUE, -3.0, 3.0) - (_y_1);
    (*res)[5] = - _y_1 - _x_0 + COND_EXP_EQ(_sw_init(2), JMI_TRUE, -1.0, 1.0) - (_z_2);

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (1.0);
    (*res)[1] = _z_2 - (-1.5);
    (*res)[2] = _y_1 - (0.5);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end CCodeGenTest10;

model CCodeGenTest11
 Integer x = 1;
 Integer y = 2;
 Real z = noEvent(if x <> y then 1.0 else 2.0);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest11",
            description="C code generation: the '<>' operator",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = 1 - (_x_0);
    (*res)[1] = 2 - (_y_1);
    (*res)[2] = (COND_EXP_EQ(COND_EXP_EQ(_x_0, _y_1, JMI_FALSE, JMI_TRUE), JMI_TRUE, 1.0, 2.0)) - (_z_2);
")})));
end CCodeGenTest11;


model CCodeGenTest12
  Real x(start=1,fixed=true);
equation
  der(x) = (x-0.3)^0.3 + (x-0.3)^3;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest12",
            description="C code generation: test that x^2 is represented by x*x in the generated code.",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = jmi_pow_equation(jmi, (_x_0 - 0.3),0.3,\"(x - 0.3) ^ 0.3\") + (1.0 * ((_x_0 - 0.3)) * ((_x_0 - 0.3)) * ((_x_0 - 0.3))) - (_der_x_1);
")})));
end CCodeGenTest12;


model CCodeGenTest13
    constant Integer ci = 1;
    constant Integer cd = ci;
    parameter Integer pi = 2;
    parameter Integer pd = pi;
    parameter Integer pii(fixed = false); 

    type A = enumeration(a, b, c);
    type B = enumeration(d, e, f);

    constant A aic = A.a;
    constant B bic = B.e;
    constant A adc = aic;
    constant B bdc = bic;
    parameter A aip = A.b;
    parameter B bip = B.f;
    parameter A adp = aip;
    parameter B bdp = bip;
initial equation
    pii = pd;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest13",
            description="Code generation for enumerations: variable aliases",
            variability_propagation=false,
            eliminate_alias_variables=false,
            template="$C_variable_aliases$",
            generatedCode="
#define _ci_0 ((*(jmi->z))[0])
#define _cd_1 ((*(jmi->z))[1])
#define _aic_5 ((*(jmi->z))[2])
#define _bic_6 ((*(jmi->z))[3])
#define _adc_7 ((*(jmi->z))[4])
#define _bdc_8 ((*(jmi->z))[5])
#define _pi_2 ((*(jmi->z))[6])
#define _aip_9 ((*(jmi->z))[7])
#define _bip_10 ((*(jmi->z))[8])
#define _pd_3 ((*(jmi->z))[9])
#define _adp_11 ((*(jmi->z))[10])
#define _bdp_12 ((*(jmi->z))[11])
#define _pii_4 ((*(jmi->z))[12])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
")})));
end CCodeGenTest13;


model CCodeGenTest14
	function f
		input Real[2] a;
		output Real b;
	algorithm
		b := sum(a);
	end f;
	
    parameter Real[2] c = {1,2};
	Real x;
	
equation
	when initial() then
		x = f(c);
	end when;
	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest14",
            description="",
            generate_ode=true,
            generate_dae=false,
            equation_sorting=true,
            variability_propagation=false,
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (_atInitial) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        memcpy(&jmi_array_ref_1(tmp_1, 1), &_c_1_0, 2 * sizeof(jmi_real_t));
    } else {
    }
    _x_2 = COND_EXP_EQ(_atInitial, JMI_TRUE, func_CCodeGenTests_CCodeGenTest14_f_exp0(tmp_1), pre_x_2);
    pre_x_2 = _x_2;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenTest14;

model CCodeGenTest15
  Real x1(start=0); 
  Real x2(start=1); 
  input Real u; 
  parameter Real p = 1;
  Real w = x1+x2;
equation 
  der(x1) = (1-x2^2)*x1 - x2 + p*u; 
  der(x2) = x1;


annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest15",
        description="Test the compiler option generate_only_initial_system",
        generate_ode=true,
        generate_dae=false,
        equation_sorting=true,
        generate_only_initial_system=true,
        variability_propagation=false,
        template="
$C_ode_derivatives$
$C_ode_guards$
$C_ode_time_events$
$C_DAE_event_indicator_residuals$
$C_ode_initialization$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef = model_ode_initialize(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

  model_ode_guards_init(jmi);


  model_init_R0(jmi, res);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = 0;
    _der_x2_6 = _x1_0;
    _x2_1 = 1;
    _der_x1_5 = (1 - (1.0 * (_x2_1) * (_x2_1))) * _der_x2_6 + (- _x2_1) + _p_3 * _u_2;
    _w_4 = _der_x2_6 + _x2_1;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenTest15;

model CCodeGenTest16
  Real x,y,z;
initial equation
 der(x) = if time>=1 then 1 elseif time>=2 then 3 else 5;
equation
 y - (if time>=5 then -z else z) + x = 3;
 y + sin(z) + x = 5;
 der(x) = -x + z;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest16",
        description="Test the compiler option generate_only_initial_system",
        generate_ode=true,
        generate_dae=false,
        equation_sorting=true,
        generate_only_initial_system=true,
        variability_propagation=false,
        relational_time_events=false,
        template="
$n_event_indicators$
$n_initial_event_indicators$
$C_DAE_initial_event_indicator_residuals$
$C_ode_initialization$
",
        generatedCode="
3
0
    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (5.0);
    (*res)[1] = _time - (1.0);
    (*res)[2] = COND_EXP_EQ(LOG_EXP_NOT(_sw_init(0)), JMI_TRUE, _time - (2.0), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch(jmi, _time - (1.0), _sw_init(0), JMI_REL_GEQ);
    }
    if (_sw_init(0)) {
    } else {
        if (jmi->atInitial || jmi->atEvent) {
            _sw_init(1) = jmi_turn_switch(jmi, _time - (2.0), _sw_init(1), JMI_REL_GEQ);
        }
    }
    _der_x_3 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 1.0, COND_EXP_EQ(_sw_init(1), JMI_TRUE, 3.0, 5.0));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (5.0), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenTest16;


model CCodeGenTest17
	type A = enumeration(a, b, c);
	A a;
equation
	when time > 2 then
		a = pre(a);
	end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest17",
        description="Test C code compilation for pre() of enum variable",
        variability_propagation=false,
        relational_time_events=false,
        template="
$C_variable_aliases$
-----
$C_ode_initialization$
",
        generatedCode="
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _a_0 ((*(jmi->z))[2])
#define _temp_1_1 ((*(jmi->z))[3])
#define pre_a_0 ((*(jmi->z))[jmi->offs_pre_integer_d+0])
#define pre_temp_1_1 ((*(jmi->z))[jmi->offs_pre_boolean_d+0])

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    pre_a_0 = 1;
    _a_0 = pre_a_0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenTest17;

model CCodeGenTest18
    parameter Boolean[3] table = {false, true, false};
    Boolean x;
    Integer index = integer(time);
algorithm
    if index < 4 then
        x := table[index];
    else
        x := true;
    end if;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest18",
        description="Test generation of temporary variables",
        relational_time_events=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (pre_index_4), _sw(0), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _time - (pre_index_4 + 1.0), _sw(1), JMI_REL_GEQ);
    }
    _index_4 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_time), pre_index_4);
    pre_index_4 = _index_4;
    _x_3 = pre_x_3;
    if (COND_EXP_LT(_index_4, 4, JMI_TRUE, JMI_FALSE)) {
        _x_3 = (&_table_1_0)[(int)(_index_4 - 1)];
    } else {
        _x_3 = JMI_TRUE;
    }
    pre_x_3 = _x_3;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenTest18;


model CCodeGenTest19
    function f
        input String a;
        input Real b;
        output Real c;
    algorithm
        c := b;
        c := c + 1;
    end f;

    Real x = time / f("a", time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest19",
            description="Check that quotes in divisions are escaped in the string representation",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = jmi_divide_equation(jmi, _time,func_CCodeGenTests_CCodeGenTest19_f_exp0(\"a\", _time),\"time / CCodeGenTests.CCodeGenTest19.f(\\\"a\\\", time)\");
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenTest19;

model CCodeGenTest20
    function mysum
        input Real[:,:] x;
        output Real y = sum(x);
        algorithm
    end mysum;
    function f
        input Real t;
        output Real[1,1] y = {{t}};
      algorithm
    end f;
    function fw
        input Real[1,1] x;
        output Real[1,1] y;
        Real t;
      algorithm
        y := f(mysum(transpose(x)));
    end fw;
    Real[1,1] y = fw({{time}});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenTest20",
        description="Test generation of temporary variables",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CCodeGenTest20_fw_def0(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, y_an, 1, 2)
    JMI_DEF(REA, t_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 2)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, y_an, 1, 2, 1, 1)
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 2, 1, 1)
    i1_0in = 0;
    i1_0ie = floor((1) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        i2_1in = 0;
        i2_1ie = floor((1) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_ref_2(temp_1_a, i1_0i, i2_1i) = jmi_array_val_2(x_a, i2_1i, i1_0i);
        }
    }
    func_CCodeGenTests_CCodeGenTest20_f_def1(func_CCodeGenTests_CCodeGenTest20_mysum_exp2(temp_1_a), y_a);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_CCodeGenTest20_f_def1(jmi_real_t t_v, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, y_an, 1, 2)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 2)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_2_a, 1, 1)
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    jmi_real_t i2_4i;
    jmi_int_t i2_4ie;
    jmi_int_t i2_4in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, y_an, 1, 2, 1, 1)
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 2, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_2_a, 1, 1, 1)
    jmi_array_ref_1(temp_2_a, 1) = t_v;
    i1_2in = 0;
    i1_2ie = floor((1) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        jmi_array_ref_2(temp_1_a, 1, i1_2i) = jmi_array_val_1(temp_2_a, i1_2i);
    }
    i1_3in = 0;
    i1_3ie = floor((1) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        i2_4in = 0;
        i2_4ie = floor((1) - (1));
        for (i2_4i = 1; i2_4in <= i2_4ie; i2_4i = 1 + (++i2_4in)) {
            jmi_array_ref_2(y_a, i1_3i, i2_4i) = jmi_array_val_2(temp_1_a, i1_3i, i2_4i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_CCodeGenTest20_mysum_def2(jmi_array_t* x_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_5i;
    jmi_int_t i1_5ie;
    jmi_int_t i1_5in;
    jmi_real_t i2_6i;
    jmi_int_t i2_6ie;
    jmi_int_t i2_6in;
    temp_1_v = 0.0;
    i1_5in = 0;
    i1_5ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_5i = 1; i1_5in <= i1_5ie; i1_5i = 1 + (++i1_5in)) {
        i2_6in = 0;
        i2_6ie = floor((jmi_array_size(x_a, 1)) - (1));
        for (i2_6i = 1; i2_6in <= i2_6ie; i2_6i = 1 + (++i2_6in)) {
            temp_1_v = temp_1_v + jmi_array_val_2(x_a, i1_5i, i2_6i);
        }
    }
    y_v = temp_1_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenTest20_mysum_exp2(jmi_array_t* x_a) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenTest20_mysum_def2(x_a, &y_v);
    return y_v;
}

")})));
end CCodeGenTest20;

model CCodeGenTest21
    parameter Real p = 1;
    parameter Real ip1(fixed = false) = p;
    parameter Real ip2(fixed = false) = 1;
initial equation
    ip1 = ip2;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest21",
            description="Test alias generation for structural dependent variables",
            template="$C_variable_aliases$",
            generatedCode="
#define _p_0 ((*(jmi->z))[0])
#define _ip2_2 ((*(jmi->z))[1])
#define _ip1_1 ((*(jmi->z))[2])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
")})));
end CCodeGenTest21;

model CCodeGenTest22
	Real t;
equation
	t = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest22",
            description="",
            fmu_type="FMUME10",
            template="$fmu_type_define$",
            generatedCode="
#define FMUME10 1
")})));
end CCodeGenTest22;

model CCodeGenTest23
	Real t;
equation
	t = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest23",
            description="",
            fmu_type="FMUME20",
            template="$fmu_type_define$",
            generatedCode="
#define FMUME20 1
")})));
end CCodeGenTest23;

model CCodeGenTest24
	Real t;
equation
	t = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest24",
            description="",
            fmu_type="FMUCS10",
            template="$fmu_type_define$",
            generatedCode="
#define FMUCS10 1
")})));
end CCodeGenTest24;

model CCodeGenTest25
	Real t;
equation
	t = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest25",
            description="",
            fmu_type="FMUCS20",
            template="$fmu_type_define$",
            generatedCode="
#define FMUCS20 1
")})));
end CCodeGenTest25;

model CCodeGenTest26
	Real t;
equation
	t = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest26",
            description="",
            fmu_type="FMUME20;FMUCS20",
            template="$fmu_type_define$",
            generatedCode="
#define FMUME20 1
#define FMUCS20 1
")})));
end CCodeGenTest26;

model RealExpansion
 Real x;
equation
 der(x) = x/1234; 
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="RealExpansion",
        description="",
        variability_propagation=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_1 = jmi_divide_equation(jmi, _x_0, 1234, \"x / 1234\");
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end RealExpansion;

model CLogExp1
 Boolean x = true;
 Boolean y = false;
 Real z = noEvent(if x and y then 1.0 else 2.0);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CLogExp1",
            description="C code generation for logical operators: and",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = JMI_FALSE - (_y_1);
    (*res)[2] = (COND_EXP_EQ(LOG_EXP_AND(_x_0, _y_1), JMI_TRUE, 1.0, 2.0)) - (_z_2);
")})));
end CLogExp1;


model CLogExp2
 Boolean x = true;
 Boolean y = false;
 Real z = noEvent(if x or y then 1.0 else 2.0);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CLogExp2",
            description="C code generation for logical operators: or",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = JMI_FALSE - (_y_1);
    (*res)[2] = (COND_EXP_EQ(LOG_EXP_OR(_x_0, _y_1), JMI_TRUE, 1.0, 2.0)) - (_z_2);
")})));
end CLogExp2;


model CLogExp3
 Boolean x = true;
 Real y = noEvent(if not x then 1.0 else 2.0);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CLogExp3",
            description="C code generation for logical operators: not",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = (COND_EXP_EQ(LOG_EXP_NOT(_x_0), JMI_TRUE, 1.0, 2.0)) - (_y_1);
")})));
end CLogExp3;

model CStringExp
	function StringCompare
		input String expected;
		input String actual;
	algorithm
		assert(actual == expected, "Compare failed, expected: " + expected + ", actual: " + actual);
        annotation(Inline=false);
	end StringCompare;
	type E = enumeration(small, medium, large, xlarge);
	parameter Real realVar = 3.14;
	Integer intVar = if realVar < 2.5 then 12 else 42;
	Boolean boolVar = if realVar < 2.5 then true else false;
	E enumVar = if realVar < 2.5 then E.small else E.medium;
equation
	StringCompare("42",           String(intVar));
	StringCompare("42          ", String(intVar, minimumLength=12));
	StringCompare("          42", String(intVar, minimumLength=12, leftJustified=false));
	
	StringCompare("3.14000",      String(realVar));
	StringCompare("3.14000     ", String(realVar, minimumLength=12));
	StringCompare("     3.14000", String(realVar, minimumLength=12, leftJustified=false));
	StringCompare("3.1400000",    String(realVar, significantDigits=8));
	StringCompare("3.1400000   ", String(realVar, minimumLength=12, significantDigits=8));
	StringCompare("   3.1400000", String(realVar, minimumLength=12, leftJustified=false, significantDigits=8));
	
	StringCompare("-3.14000",     String(-realVar));
	StringCompare("-3.14000    ", String(-realVar, minimumLength=12));
	StringCompare("    -3.14000", String(-realVar, minimumLength=12, leftJustified=false));
	StringCompare("-3.1400000",   String(-realVar, significantDigits=8));
	StringCompare("-3.1400000  ", String(-realVar, minimumLength=12, significantDigits=8));
	StringCompare("  -3.1400000", String(-realVar, minimumLength=12, leftJustified=false, significantDigits=8));
	
	StringCompare("false",        String(boolVar));
	StringCompare("false       ", String(boolVar, minimumLength=12));
	StringCompare("       false", String(boolVar, minimumLength=12, leftJustified=false));
	
	StringCompare("true",         String(not boolVar));
	StringCompare("true        ", String(not boolVar, minimumLength=12));
	StringCompare("        true", String(not boolVar, minimumLength=12, leftJustified=false));
	
	StringCompare("medium",       String(enumVar));
	StringCompare("medium      ", String(enumVar, minimumLength=12));
	StringCompare("      medium", String(enumVar, minimumLength=12, leftJustified=false));

    StringCompare("42",           String(intVar, format="%d"));
    StringCompare("3.1400000",    String(realVar, format="%f"));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CStringExp",
        description="C code generation for string operator",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    JMI_DEF_STR_STAT(tmp_1, 10)
    JMI_DEF_STR_STAT(tmp_2, 12)
    JMI_DEF_STR_STAT(tmp_3, 12)
    JMI_DEF_STR_STAT(tmp_4, 13)
    JMI_DEF_STR_STAT(tmp_5, 13)
    JMI_DEF_STR_STAT(tmp_6, 13)
    JMI_DEF_STR_STAT(tmp_7, 15)
    JMI_DEF_STR_STAT(tmp_8, 15)
    JMI_DEF_STR_STAT(tmp_9, 15)
    JMI_DEF_STR_STAT(tmp_10, 13)
    JMI_DEF_STR_STAT(tmp_11, 13)
    JMI_DEF_STR_STAT(tmp_12, 13)
    JMI_DEF_STR_STAT(tmp_13, 15)
    JMI_DEF_STR_STAT(tmp_14, 15)
    JMI_DEF_STR_STAT(tmp_15, 15)
    JMI_DEF_STR_STAT(tmp_16, 5)
    JMI_DEF_STR_STAT(tmp_17, 12)
    JMI_DEF_STR_STAT(tmp_18, 12)
    JMI_DEF_STR_STAT(tmp_19, 5)
    JMI_DEF_STR_STAT(tmp_20, 12)
    JMI_DEF_STR_STAT(tmp_21, 12)
    JMI_DEF_STR_STAT(tmp_22, 6)
    JMI_DEF_STR_STAT(tmp_23, 12)
    JMI_DEF_STR_STAT(tmp_24, 12)
    JMI_DEF_STR_STAT(tmp_25, 16)
    JMI_DEF_STR_STAT(tmp_26, 16)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-d\", (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"42\", tmp_1);
    JMI_INI_STR_STAT(tmp_2)
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%-*d\", (int) 12.0, (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"42          \", tmp_2);
    JMI_INI_STR_STAT(tmp_3)
    snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*d\", \"%*d\"), (int) 12.0, (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"          42\", tmp_3);
    JMI_INI_STR_STAT(tmp_4)
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%-.*g\", (int) 6, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.14000\", tmp_4);
    JMI_INI_STR_STAT(tmp_5)
    snprintf(JMI_STR_END(tmp_5), JMI_STR_LEFT(tmp_5), \"%-*.*g\", (int) 12.0, (int) 6, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.14000     \", tmp_5);
    JMI_INI_STR_STAT(tmp_6)
    snprintf(JMI_STR_END(tmp_6), JMI_STR_LEFT(tmp_6), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) 12.0, (int) 6, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"     3.14000\", tmp_6);
    JMI_INI_STR_STAT(tmp_7)
    snprintf(JMI_STR_END(tmp_7), JMI_STR_LEFT(tmp_7), \"%-.*g\", (int) 8.0, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.1400000\", tmp_7);
    JMI_INI_STR_STAT(tmp_8)
    snprintf(JMI_STR_END(tmp_8), JMI_STR_LEFT(tmp_8), \"%-*.*g\", (int) 12.0, (int) 8.0, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.1400000   \", tmp_8);
    JMI_INI_STR_STAT(tmp_9)
    snprintf(JMI_STR_END(tmp_9), JMI_STR_LEFT(tmp_9), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) 12.0, (int) 8.0, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"   3.1400000\", tmp_9);
    JMI_INI_STR_STAT(tmp_10)
    snprintf(JMI_STR_END(tmp_10), JMI_STR_LEFT(tmp_10), \"%-.*g\", (int) 6, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.14000\", tmp_10);
    JMI_INI_STR_STAT(tmp_11)
    snprintf(JMI_STR_END(tmp_11), JMI_STR_LEFT(tmp_11), \"%-*.*g\", (int) 12.0, (int) 6, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.14000    \", tmp_11);
    JMI_INI_STR_STAT(tmp_12)
    snprintf(JMI_STR_END(tmp_12), JMI_STR_LEFT(tmp_12), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) 12.0, (int) 6, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"    -3.14000\", tmp_12);
    JMI_INI_STR_STAT(tmp_13)
    snprintf(JMI_STR_END(tmp_13), JMI_STR_LEFT(tmp_13), \"%-.*g\", (int) 8.0, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.1400000\", tmp_13);
    JMI_INI_STR_STAT(tmp_14)
    snprintf(JMI_STR_END(tmp_14), JMI_STR_LEFT(tmp_14), \"%-*.*g\", (int) 12.0, (int) 8.0, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.1400000  \", tmp_14);
    JMI_INI_STR_STAT(tmp_15)
    snprintf(JMI_STR_END(tmp_15), JMI_STR_LEFT(tmp_15), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) 12.0, (int) 8.0, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"  -3.1400000\", tmp_15);
    JMI_INI_STR_STAT(tmp_16)
    snprintf(JMI_STR_END(tmp_16), JMI_STR_LEFT(tmp_16), \"%-s\", COND_EXP_EQ(_boolVar_2, JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"false\", tmp_16);
    JMI_INI_STR_STAT(tmp_17)
    snprintf(JMI_STR_END(tmp_17), JMI_STR_LEFT(tmp_17), \"%-*s\", (int) 12.0, COND_EXP_EQ(_boolVar_2, JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"false       \", tmp_17);
    JMI_INI_STR_STAT(tmp_18)
    snprintf(JMI_STR_END(tmp_18), JMI_STR_LEFT(tmp_18), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*s\", \"%*s\"), (int) 12.0, COND_EXP_EQ(_boolVar_2, JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"       false\", tmp_18);
    JMI_INI_STR_STAT(tmp_19)
    snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%-s\", COND_EXP_EQ(LOG_EXP_NOT(_boolVar_2), JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"true\", tmp_19);
    JMI_INI_STR_STAT(tmp_20)
    snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%-*s\", (int) 12.0, COND_EXP_EQ(LOG_EXP_NOT(_boolVar_2), JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"true        \", tmp_20);
    JMI_INI_STR_STAT(tmp_21)
    snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*s\", \"%*s\"), (int) 12.0, COND_EXP_EQ(LOG_EXP_NOT(_boolVar_2), JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"        true\", tmp_21);
    JMI_INI_STR_STAT(tmp_22)
    snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%-s\", E_0_e[(int) _enumVar_3]);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"medium\", tmp_22);
    JMI_INI_STR_STAT(tmp_23)
    snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%-*s\", (int) 12.0, E_0_e[(int) _enumVar_3]);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"medium      \", tmp_23);
    JMI_INI_STR_STAT(tmp_24)
    snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*s\", \"%*s\"), (int) 12.0, E_0_e[(int) _enumVar_3]);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"      medium\", tmp_24);
    JMI_INI_STR_STAT(tmp_25)
    snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%d\", (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"42\", tmp_25);
    JMI_INI_STR_STAT(tmp_26)
    snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%f\", _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.1400000\", tmp_26);
    (*res)[0] = COND_EXP_EQ(COND_EXP_LT(_realVar_0, 2.5, JMI_TRUE, JMI_FALSE), JMI_TRUE, 12.0, 42.0) - (_intVar_1);
    (*res)[1] = COND_EXP_EQ(COND_EXP_LT(_realVar_0, 2.5, JMI_TRUE, JMI_FALSE), JMI_TRUE, JMI_TRUE, JMI_FALSE) - (_boolVar_2);
    (*res)[2] = COND_EXP_EQ(COND_EXP_LT(_realVar_0, 2.5, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, 2.0) - (_enumVar_3);
")})));
end CStringExp;

package FInStreamEpsExp
    model Simple1
        connector StreamConnector
            Real p;
            flow Real f;
            stream Real s;
        end StreamConnector;
        model A
            StreamConnector c1(f(nominal=0.1));
            StreamConnector c2;
            StreamConnector c3(f(nominal=2));
            Real x1 = inStream(c1.s);
            Real x2 = inStream(c2.s);
            Real x3 = inStream(c3.s);
        equation
            connect(c1, c2);
            connect(c1, c3);
        end A;
        
        model B
            StreamConnector c4(p = 7, f = 8, s = 4);
            StreamConnector c5(s = 5);
            StreamConnector c6(s = 6, f = 9);
        end B;
        
        A a;
        B b;
    equation
        connect(a.c1, b.c4);
        connect(a.c2, b.c5);
        connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="FInStreamEpsExp_Simple1",
            description="Ensure that epsilon for InStream is generated correctly",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _b_c4_p_12 = 7;
    _a_c1_p_0 = _b_c4_p_12;
    _b_c4_f_13 = 8;
    _a_c1_f_1 = - _b_c4_f_13;
    _b_c6_f_19 = 9;
    _a_c3_f_7 = - _b_c6_f_19;
    _a_c2_f_4 = - _a_c1_f_1 - _a_c3_f_7;
    __stream_s_1_21 = jmi_max(_a_c2_f_4, 0.0) + jmi_max(_a_c3_f_7, 0.0);
    __stream_alpha_1_22 = (COND_EXP_EQ(COND_EXP_GT(__stream_s_1_21, jmi_in_stream_eps(jmi) * 0.1, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, COND_EXP_EQ(COND_EXP_GT(__stream_s_1_21, 0.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, jmi_divide_equation(jmi, __stream_s_1_21, (jmi_in_stream_eps(jmi) * 0.1), \"_stream_s_1 / (_inStreamEpsilon * 0.1)\") * (jmi_divide_equation(jmi, __stream_s_1_21, (jmi_in_stream_eps(jmi) * 0.1), \"_stream_s_1 / (_inStreamEpsilon * 0.1)\") * (3.0 - 2.0 * __stream_s_1_21)), 0.0)));
    __stream_positiveMax_1_23 = __stream_alpha_1_22 * jmi_max(_a_c2_f_4, 0.0) + (1 - __stream_alpha_1_22) * (jmi_in_stream_eps(jmi) * 0.1);
    _b_c5_s_17 = 5;
    __stream_positiveMax_2_24 = __stream_alpha_1_22 * jmi_max(_a_c3_f_7, 0.0) + (1 - __stream_alpha_1_22) * (jmi_in_stream_eps(jmi) * 0.1);
    _b_c6_s_20 = 6;
    _a_c1_s_2 = jmi_divide_equation(jmi, (__stream_positiveMax_1_23 * _b_c5_s_17 + __stream_positiveMax_2_24 * _b_c6_s_20), (__stream_positiveMax_1_23 + __stream_positiveMax_2_24), \"(_stream_positiveMax_1 * b.c5.s + _stream_positiveMax_2 * b.c6.s) / (_stream_positiveMax_1 + _stream_positiveMax_2)\");
    _a_c2_p_3 = _a_c1_p_0;
    __stream_s_2_25 = jmi_max(_a_c1_f_1, 0.0) + jmi_max(_a_c3_f_7, 0.0);
    __stream_alpha_2_26 = (COND_EXP_EQ(COND_EXP_GT(__stream_s_2_25, jmi_in_stream_eps(jmi) * 0.1, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, COND_EXP_EQ(COND_EXP_GT(__stream_s_2_25, 0.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, jmi_divide_equation(jmi, __stream_s_2_25, (jmi_in_stream_eps(jmi) * 0.1), \"_stream_s_2 / (_inStreamEpsilon * 0.1)\") * (jmi_divide_equation(jmi, __stream_s_2_25, (jmi_in_stream_eps(jmi) * 0.1), \"_stream_s_2 / (_inStreamEpsilon * 0.1)\") * (3.0 - 2.0 * __stream_s_2_25)), 0.0)));
    __stream_positiveMax_3_27 = __stream_alpha_2_26 * jmi_max(_a_c1_f_1, 0.0) + (1 - __stream_alpha_2_26) * (jmi_in_stream_eps(jmi) * 0.1);
    _b_c4_s_14 = 4;
    __stream_positiveMax_4_28 = __stream_alpha_2_26 * jmi_max(_a_c3_f_7, 0.0) + (1 - __stream_alpha_2_26) * (jmi_in_stream_eps(jmi) * 0.1);
    _a_c2_s_5 = jmi_divide_equation(jmi, (__stream_positiveMax_3_27 * _b_c4_s_14 + __stream_positiveMax_4_28 * _b_c6_s_20), (__stream_positiveMax_3_27 + __stream_positiveMax_4_28), \"(_stream_positiveMax_3 * b.c4.s + _stream_positiveMax_4 * b.c6.s) / (_stream_positiveMax_3 + _stream_positiveMax_4)\");
    _a_c3_p_6 = _a_c2_p_3;
    __stream_s_3_29 = jmi_max(_a_c1_f_1, 0.0) + jmi_max(_a_c2_f_4, 0.0);
    __stream_alpha_3_30 = (COND_EXP_EQ(COND_EXP_GT(__stream_s_3_29, jmi_in_stream_eps(jmi) * 0.1, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, COND_EXP_EQ(COND_EXP_GT(__stream_s_3_29, 0.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, jmi_divide_equation(jmi, __stream_s_3_29, (jmi_in_stream_eps(jmi) * 0.1), \"_stream_s_3 / (_inStreamEpsilon * 0.1)\") * (jmi_divide_equation(jmi, __stream_s_3_29, (jmi_in_stream_eps(jmi) * 0.1), \"_stream_s_3 / (_inStreamEpsilon * 0.1)\") * (3.0 - 2.0 * __stream_s_3_29)), 0.0)));
    __stream_positiveMax_5_31 = __stream_alpha_3_30 * jmi_max(_a_c1_f_1, 0.0) + (1 - __stream_alpha_3_30) * (jmi_in_stream_eps(jmi) * 0.1);
    __stream_positiveMax_6_32 = __stream_alpha_3_30 * jmi_max(_a_c2_f_4, 0.0) + (1 - __stream_alpha_3_30) * (jmi_in_stream_eps(jmi) * 0.1);
    _a_c3_s_8 = jmi_divide_equation(jmi, (__stream_positiveMax_5_31 * _b_c4_s_14 + __stream_positiveMax_6_32 * _b_c5_s_17), (__stream_positiveMax_5_31 + __stream_positiveMax_6_32), \"(_stream_positiveMax_5 * b.c4.s + _stream_positiveMax_6 * b.c5.s) / (_stream_positiveMax_5 + _stream_positiveMax_6)\");
    _a_x1_9 = _b_c4_s_14;
    _a_x2_10 = _b_c5_s_17;
    _a_x3_11 = _b_c6_s_20;
    _b_c5_p_15 = _a_c2_p_3;
    _b_c5_f_16 = - _a_c2_f_4;
    _b_c6_p_18 = _a_c3_p_6;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
    end Simple1;
end FInStreamEpsExp;





model CCodeGenDiscreteVariables1
  constant Real c1 = 1;
  constant Real c2 = c1;
  parameter Real p1 = 1;
  parameter Real p2 = p1;
  discrete Real rd1 = 4;
  discrete Real rd2 = rd1;
  Real x(start=1);
  Real w = 4;

  constant Integer ci1 = 1;
  constant Integer ci2 = ci1;
  parameter Integer pi1 = 1;
  parameter Integer pi2 = pi1;
  discrete Integer rid1 = 4;
  discrete Integer rid2 = rid1;

  constant Boolean cb1 = true;
  constant Boolean cb2 = cb1;
  parameter Boolean pb1 = true;
  parameter Boolean pb2 = pb1;
  discrete Boolean rbd1 = false;
  discrete Boolean rbd2 = rbd1;

equation
  der(x) = -x;


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenDiscreteVariables1",
            description="Test C code generation of discrete variables.",
            variability_propagation=false,
            eliminate_alias_variables=false,
            generate_ode=false,
            generate_dae=true,
            template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
            generatedCode="
#define _c1_0 ((*(jmi->z))[0])
#define _c2_1 ((*(jmi->z))[1])
#define _p1_2 ((*(jmi->z))[2])
#define _p2_3 ((*(jmi->z))[3])
#define _ci1_8 ((*(jmi->z))[4])
#define _ci2_9 ((*(jmi->z))[5])
#define _pi1_10 ((*(jmi->z))[6])
#define _pi2_11 ((*(jmi->z))[7])
#define _cb1_14 ((*(jmi->z))[8])
#define _cb2_15 ((*(jmi->z))[9])
#define _pb1_16 ((*(jmi->z))[10])
#define _pb2_17 ((*(jmi->z))[11])
#define _der_x_26 ((*(jmi->z))[12])
#define _x_6 ((*(jmi->z))[13])
#define _w_7 ((*(jmi->z))[14])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _rd1_4 ((*(jmi->z))[17])
#define _rd2_5 ((*(jmi->z))[18])
#define _rid1_12 ((*(jmi->z))[19])
#define _rid2_13 ((*(jmi->z))[20])
#define _rbd1_18 ((*(jmi->z))[21])
#define _rbd2_19 ((*(jmi->z))[22])

    (*res)[0] = - _x_6 - (_der_x_26);
    (*res)[1] = 4 - (_rd1_4);
    (*res)[2] = _rd1_4 - (_rd2_5);
    (*res)[3] = 4 - (_w_7);
    (*res)[4] = 4 - (_rid1_12);
    (*res)[5] = _rid1_12 - (_rid2_13);
    (*res)[6] = JMI_FALSE - (_rbd1_18);
    (*res)[7] = _rbd1_18 - (_rbd2_19);
")})));
end CCodeGenDiscreteVariables1;


model CCodeGenParameters1
	function f
		input Real x;
		output Real y;
		external "C";
	end f;
	
	parameter Real x = 1;
	parameter Real y = x;
	parameter Real z = f(1);
	Real dummy = x;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenParameters1",
        description="Make sure scaling is applied properly when setting to parameter values",
        generate_dae=true,
        enable_variable_scaling=true,
        variability_propagation=false,
        template="
$C_model_init_eval_dependent_parameters$
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$
",
        generatedCode="

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_1 = ((_x_0*sf(0)))/sf(1);
    _z_2 = (func_CCodeGenTests_CCodeGenParameters1_f_exp0(1.0))/sf(2);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = (1)/sf(0);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenParameters1;

model CCodeGenParameters2
    type E = enumeration(A,B,C);
    
    // Regular independent
    parameter Real    reg1 = 1;
    parameter Integer reg2 = 1;
    parameter E       reg3 = E.A;
    parameter Boolean reg4 = true;
    parameter String  reg5 = "string";
    
    // Structural independent
    parameter Real    struct1 = 1;
    parameter Integer struct2 = 1;
    parameter E       struct3 = E.A;
    parameter Boolean struct4 = true;
    parameter String  struct5 = "string";
    
    // Final independent
    final parameter Real    final1 = 1;
    final parameter Integer final2 = 1;
    final parameter E       final3 = E.A;
    final parameter Boolean final4 = true;
    final parameter String  final5 = "string";
    
    // Evaluate independent
    parameter Real    eval1 = 1 annotation(Evaluate=true);
    parameter Integer eval2 = 1 annotation(Evaluate=true);
    parameter E       eval3 = E.A annotation(Evaluate=true);
    parameter Boolean eval4 = true annotation(Evaluate=true);
    parameter String  eval5 = "string" annotation(Evaluate=true);
    
    parameter Real dummy[n];
    parameter Integer n = if (struct4) then integer(struct1) + struct2 else Integer(struct3);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenParameters2",
            description="Code generated for independent parameters",
            eliminate_alias_variables=false,
            generate_dae=true,
            variability_propagation=false,
            template="
N_real_pi = $n_real_pi$;
N_real_pi_s = $n_real_pi_s$;
N_real_pi_f = $n_real_pi_f$;
N_real_pi_e = $n_real_pi_e$;

N_integer_pi = $n_integer_pi$ + $n_enum_pi$;
N_integer_pi_s = $n_integer_pi_s$ + $n_enum_pi_s$;
N_integer_pi_f = $n_integer_pi_f$ + $n_enum_pi_f$;
N_integer_pi_e = $n_integer_pi_e$ + $n_enum_pi_e$;

N_boolean_pi = $n_boolean_pi$;
N_boolean_pi_s = $n_boolean_pi_s$;
N_boolean_pi_f = $n_boolean_pi_f$;
N_boolean_pi_e = $n_boolean_pi_e$;

$C_z_offsets_strings$

---
$C_variable_aliases$
---
$C_model_init_eval_dependent_variables$
---
$C_model_init_eval_independent_start$
",
            generatedCode="
N_real_pi = 6;
N_real_pi_s = 1;
N_real_pi_f = 1;
N_real_pi_e = 1;

N_integer_pi = 5 + 4;
N_integer_pi_s = 2 + 1;
N_integer_pi_f = 1 + 1;
N_integer_pi_e = 1 + 1;

N_boolean_pi = 4;
N_boolean_pi_s = 1;
N_boolean_pi_f = 1;
N_boolean_pi_e = 1;

z->offs.ci = 0;
z->nums.ci = 0;
z->offs.cd = 0;
z->nums.cd = 0;
z->offs.pi = 0;
z->nums.pi = 2;
z->offs.ps = 2;
z->nums.ps = 0;
z->offs.pf = 2;
z->nums.pf = 1;
z->offs.pe = 3;
z->nums.pe = 1;
z->offs.pd = 4;
z->nums.pd = 0;
z->offs.w = 4;
z->nums.w = 0;
z->offs.wp = 4;
z->nums.wp = 0;
z->n = 4;


---
#define _reg1_0 ((*(jmi->z))[0])
#define _dummy_1_20 ((*(jmi->z))[1])
#define _dummy_2_21 ((*(jmi->z))[2])
#define _struct1_5 ((*(jmi->z))[3])
#define _final1_10 ((*(jmi->z))[4])
#define _eval1_15 ((*(jmi->z))[5])
#define _reg2_1 ((*(jmi->z))[6])
#define _reg3_2 ((*(jmi->z))[7])
#define _struct2_6 ((*(jmi->z))[8])
#define _n_22 ((*(jmi->z))[9])
#define _struct3_7 ((*(jmi->z))[10])
#define _final2_11 ((*(jmi->z))[11])
#define _final3_12 ((*(jmi->z))[12])
#define _eval2_16 ((*(jmi->z))[13])
#define _eval3_17 ((*(jmi->z))[14])
#define _reg4_3 ((*(jmi->z))[15])
#define _struct4_8 ((*(jmi->z))[16])
#define _final4_13 ((*(jmi->z))[17])
#define _eval4_18 ((*(jmi->z))[18])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_pi_reg5_4 (jmi->z_t.strings.values[0])
#define _s_pi_struct5_9 (jmi->z_t.strings.values[1])
#define _s_pi_final5_14 (jmi->z_t.strings.values[2])
#define _s_pi_eval5_19 (jmi->z_t.strings.values[3])

---

int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

---
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _reg1_0 = (1);
    _struct1_5 = (1);
    _final1_10 = (1);
    _eval1_15 = (1);
    _reg2_1 = (1);
    _reg3_2 = (1);
    _struct2_6 = (1);
    _n_22 = (2);
    _struct3_7 = (1);
    _final2_11 = (1);
    _final3_12 = (1);
    _eval2_16 = (1);
    _eval3_17 = (1);
    _reg4_3 = (JMI_TRUE);
    _struct4_8 = (JMI_TRUE);
    _final4_13 = (JMI_TRUE);
    _eval4_18 = (JMI_TRUE);
    JMI_ASG(STR_Z, _s_pi_reg5_4, (\"string\"));
    JMI_ASG(STR_Z, _s_pi_struct5_9, (\"string\"));
    JMI_ASG(STR_Z, _s_pi_final5_14, (\"string\"));
    JMI_ASG(STR_Z, _s_pi_eval5_19, (\"string\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end CCodeGenParameters2;

model CCodeGenParameters3
    function f
        input String s;
        output Integer n = 0;
    algorithm
    end f;

    constant String ci = "s1";
    constant String cd = ci;
    parameter String pi = "s2";
    parameter String ps = "s3";
    final parameter String pf = "s4";
    parameter String pe = "s5" annotation(Evaluate=true);
    parameter String pd = pi;
    
    Real[f(ps)] x;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenParameters3",
            description="Code generated for strings",
            eliminate_alias_variables=false,
            template="
$C_variable_aliases$
$C_z_offsets_strings$
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_parameters$
",
            generatedCode="
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_ci_ci_0 (jmi->z_t.strings.values[0])
#define _s_ci_cd_1 (jmi->z_t.strings.values[1])
#define _s_pi_pi_2 (jmi->z_t.strings.values[2])
#define _s_pi_ps_3 (jmi->z_t.strings.values[3])
#define _s_pi_pf_4 (jmi->z_t.strings.values[4])
#define _s_pi_pe_5 (jmi->z_t.strings.values[5])
#define _s_pd_pd_6 (jmi->z_t.strings.values[6])

z->offs.ci = 0;
z->nums.ci = 2;
z->offs.cd = 2;
z->nums.cd = 0;
z->offs.pi = 2;
z->nums.pi = 2;
z->offs.ps = 4;
z->nums.ps = 0;
z->offs.pf = 4;
z->nums.pf = 1;
z->offs.pe = 5;
z->nums.pe = 1;
z->offs.pd = 6;
z->nums.pd = 1;
z->offs.w = 7;
z->nums.w = 0;
z->offs.wp = 7;
z->nums.wp = 0;
z->n = 7;

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_ci_ci_0, (\"s1\"));
    JMI_ASG(STR_Z, _s_ci_cd_1, (\"s1\"));
    JMI_ASG(STR_Z, _s_pi_pi_2, (\"s2\"));
    JMI_ASG(STR_Z, _s_pi_ps_3, (\"s3\"));
    JMI_ASG(STR_Z, _s_pi_pf_4, (\"s4\"));
    JMI_ASG(STR_Z, _s_pi_pe_5, (\"s5\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_pd_pd_6, (_s_pi_pi_2));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenParameters3;

model CCodeGenParameters4
    type E = enumeration(A,B,C);
    
    // Initial parameters
    parameter Real    initial1(fixed = false) = time;
    parameter Integer initial2(fixed = false) = if time < 1 then 1 else 2;
    parameter E       initial3(fixed = false) = if time < 1 then E.A else E.B;
    parameter Boolean initial4(fixed = false) = time < 1;
    parameter String  initial5 = if initial1 < 1 then "A" else "B";

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenParameters4",
            description="Code generated for initial parameters",
            template="

N_real_pd = $n_real_pd$;
N_integer_pd = $n_integer_pd$ + $n_enum_pd$;
N_boolean_pd = $n_boolean_pd$;

$C_z_offsets_strings$

---
$C_variable_aliases$
---
$C_model_init_eval_independent_start$
---
$C_model_init_eval_dependent_parameters$
---
$C_model_init_eval_dependent_variables$
",
            generatedCode="
N_real_pd = 1;
N_integer_pd = 1 + 1;
N_boolean_pd = 1;

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
z->nums.pd = 1;
z->offs.w = 1;
z->nums.w = 0;
z->offs.wp = 1;
z->nums.wp = 0;
z->n = 1;


---
#define _initial1_0 ((*(jmi->z))[0])
#define _initial2_1 ((*(jmi->z))[1])
#define _initial3_2 ((*(jmi->z))[2])
#define _initial4_3 ((*(jmi->z))[3])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_pd_initial5_4 (jmi->z_t.strings.values[0])

---

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _initial3_2 = (1);
    _initial4_3 = (JMI_FALSE);
    JMI_ASG(STR_Z, _s_pd_initial5_4, (\"\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

---

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

---
int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end CCodeGenParameters4;

model CCodeGenUniqueNames
 model A
  Real y;
 end A;
 
 Real x_y = 1;
 A x(y = x_y + 2);
 Real der_x_y = der(x_y) - 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenUniqueNames",
        description="Test that unique names are generated for each variable",
        enable_structural_diagnosis=false,
        index_reduction=false,
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
        generatedCode="
#define _der_x_y_3 ((*(jmi->z))[0])
#define _x_y_0 ((*(jmi->z))[1])
#define _x_y_1 ((*(jmi->z))[2])
#define _der_x_y_2 ((*(jmi->z))[3])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])

    (*res)[0] = 1 - (_x_y_0);
    (*res)[1] = _x_y_0 + 2 - (_x_y_1);
    (*res)[2] = _der_x_y_3 - 1 - (_der_x_y_2);
")})));
end CCodeGenUniqueNames;


model CCodeGenDotOp
 Real x[2,2] = y .* y ./ (y .+ y .- 2) .^ y;
 Real y[2,2] = {{1,2},{3,4}};

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenDotOp",
        description="C code generation of dot operators (.+, .*, etc)",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = jmi_divide_equation(jmi, _y_1_1_4 * _y_1_1_4, jmi_pow_equation(jmi, (_y_1_1_4 + _y_1_1_4 - 2), _y_1_1_4, \"(y[1,1] .+ y[1,1] .- 2) .^ y[1,1]\"), \"y[1,1] .* y[1,1] ./ (y[1,1] .+ y[1,1] .- 2) .^ y[1,1]\") - (_x_1_1_0);
    (*res)[1] = jmi_divide_equation(jmi, _y_1_2_5 * _y_1_2_5, jmi_pow_equation(jmi, (_y_1_2_5 + _y_1_2_5 - 2), _y_1_2_5, \"(y[1,2] .+ y[1,2] .- 2) .^ y[1,2]\"), \"y[1,2] .* y[1,2] ./ (y[1,2] .+ y[1,2] .- 2) .^ y[1,2]\") - (_x_1_2_1);
    (*res)[2] = jmi_divide_equation(jmi, _y_2_1_6 * _y_2_1_6, jmi_pow_equation(jmi, (_y_2_1_6 + _y_2_1_6 - 2), _y_2_1_6, \"(y[2,1] .+ y[2,1] .- 2) .^ y[2,1]\"), \"y[2,1] .* y[2,1] ./ (y[2,1] .+ y[2,1] .- 2) .^ y[2,1]\") - (_x_2_1_2);
    (*res)[3] = jmi_divide_equation(jmi, _y_2_2_7 * _y_2_2_7, jmi_pow_equation(jmi, (_y_2_2_7 + _y_2_2_7 - 2), _y_2_2_7, \"(y[2,2] .+ y[2,2] .- 2) .^ y[2,2]\"), \"y[2,2] .* y[2,2] ./ (y[2,2] .+ y[2,2] .- 2) .^ y[2,2]\") - (_x_2_2_3);
    (*res)[4] = 1 - (_y_1_1_4);
    (*res)[5] = 2 - (_y_1_2_5);
    (*res)[6] = 3 - (_y_2_1_6);
    (*res)[7] = 4 - (_y_2_2_7);
")})));
end CCodeGenDotOp;

model CCodeGenExpOp
    function f
        input Real x;
        output Real y = exp(x);
      algorithm
    end f;
    Real y = exp(time) + f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenExpOp",
            description="C code generation of exp operator",
            inline_functions="none",
            template="
$C_ode_derivatives$
$C_functions$
",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = jmi_exp_equation(jmi, _time,\"exp(time)\") + func_CCodeGenTests_CCodeGenExpOp_f_exp0(_time);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenTests_CCodeGenExpOp_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = jmi_exp_function(\"CCodeGenTests.CCodeGenExpOp.f\", x_v,\"exp(x)\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenExpOp_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenExpOp_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end CCodeGenExpOp;

model CCodeGenLogOp
    function f
        input Real x;
        output Real y = log(x);
      algorithm
    end f;
    Real y = log(time) + f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenLogOp",
            description="C code generation of log operator",
            inline_functions="none",
            template="
$C_ode_derivatives$
$C_functions$
",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = jmi_log_equation(jmi, _time,\"log(time)\") + func_CCodeGenTests_CCodeGenLogOp_f_exp0(_time);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenTests_CCodeGenLogOp_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = jmi_log_function(\"CCodeGenTests.CCodeGenLogOp.f\", x_v,\"log(x)\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenLogOp_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenLogOp_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end CCodeGenLogOp;

model CCodeGenLog10Op
    function f
        input Real x;
        output Real y = log10(x);
      algorithm
    end f;
    Real y = log10(time) + f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenLog10Op",
            description="C code generation of log10 operator",
            inline_functions="none",
            template="
$C_ode_derivatives$
$C_functions$
",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = jmi_log10_equation(jmi, _time,\"log10(time)\") + func_CCodeGenTests_CCodeGenLog10Op_f_exp0(_time);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenTests_CCodeGenLog10Op_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = jmi_log10_function(\"CCodeGenTests.CCodeGenLog10Op.f\", x_v,\"log10(x)\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenLog10Op_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenLog10Op_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end CCodeGenLog10Op;

model CCodeGenSinhOp
    function f
        input Real x;
        output Real y = sinh(x);
      algorithm
    end f;
    Real y = sinh(time) + f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenSinhOp",
            description="C code generation of sinh operator",
            inline_functions="none",
            template="
$C_ode_derivatives$
$C_functions$
",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = jmi_sinh_equation(jmi, _time,\"sinh(time)\") + func_CCodeGenTests_CCodeGenSinhOp_f_exp0(_time);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenTests_CCodeGenSinhOp_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = jmi_sinh_function(\"CCodeGenTests.CCodeGenSinhOp.f\", x_v,\"sinh(x)\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenSinhOp_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenSinhOp_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end CCodeGenSinhOp;

model CCodeGenCoshOp
    function f
        input Real x;
        output Real y = cosh(x);
      algorithm
    end f;
    Real y = cosh(time) + f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenCoshOp",
            description="C code generation of cosh operator",
            inline_functions="none",
            template="
$C_ode_derivatives$
$C_functions$
",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = jmi_cosh_equation(jmi, _time,\"cosh(time)\") + func_CCodeGenTests_CCodeGenCoshOp_f_exp0(_time);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenTests_CCodeGenCoshOp_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = jmi_cosh_function(\"CCodeGenTests.CCodeGenCoshOp.f\", x_v,\"cosh(x)\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenCoshOp_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenCoshOp_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end CCodeGenCoshOp;

model CCodeGenTanOp
    function f
        input Real x;
        output Real y = tan(x);
      algorithm
    end f;
    Real y = tan(time) + f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTanOp",
            description="C code generation of tan operator",
            inline_functions="none",
            template="
$C_ode_derivatives$
$C_functions$
",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = jmi_tan_equation(jmi, _time,\"tan(time)\") + func_CCodeGenTests_CCodeGenTanOp_f_exp0(_time);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenTests_CCodeGenTanOp_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = jmi_tan_function(\"CCodeGenTests.CCodeGenTanOp.f\", x_v,\"tan(x)\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenTanOp_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenTanOp_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end CCodeGenTanOp;

model CCodeGenATan2Op
    function f
        input Real x;
        output Real y = atan2(x,x+1);
      algorithm
    end f;
    Real y = atan2(time,time+1) + f(time);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenATan2Op",
        description="C code generation of tan operator",
        inline_functions="none",
        template="
$C_ode_derivatives$
$C_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_0 = jmi_atan2_equation(jmi, _time, _time + 1.0, \"atan2(time, time + 1)\") + func_CCodeGenTests_CCodeGenATan2Op_f_exp0(_time);
    JMI_DYNAMIC_FREE()
    return ef;
}

void func_CCodeGenTests_CCodeGenATan2Op_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = jmi_atan2_function(\"CCodeGenTests.CCodeGenATan2Op.f\", x_v, x_v + 1.0, \"atan2(x, x + 1)\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CCodeGenATan2Op_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CCodeGenATan2Op_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end CCodeGenATan2Op;


model CCodeGenMinMax
 Real x[2,2] = {{1,2},{3,4}};
 Real y1 = min(x);
 Real y2 = min(1, 2);
 Real y3 = max(x);
 Real y4 = max(1, 2);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CCodeGenMinMax",
        description="C code generation of min() and max()",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = 1 - (_x_1_1_0);
    (*res)[1] = 2 - (_x_1_2_1);
    (*res)[2] = 3 - (_x_2_1_2);
    (*res)[3] = 4 - (_x_2_2_3);
    (*res)[4] = jmi_min(jmi_min(_x_1_1_0, _x_1_2_1), jmi_min(_x_2_1_2, _x_2_2_3)) - (_y1_4);
    (*res)[5] = jmi_min(1.0, 2.0) - (_y2_5);
    (*res)[6] = jmi_max(jmi_max(_x_1_1_0, _x_1_2_1), jmi_max(_x_2_1_2, _x_2_2_3)) - (_y3_6);
    (*res)[7] = jmi_max(1.0, 2.0) - (_y4_7);
")})));
end CCodeGenMinMax;



/* ====================== Function tests =================== */

/* Functions used in tests */
function TestFunction0
 output Real o1 = 0;
algorithm
end TestFunction0;

function TestFunction1
 input Real i1 = 0;
 output Real o1 = i1;
algorithm
end TestFunction1;

function TestFunction2
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = 0;
 output Real o2 = i2;
algorithm
 o1 := i1;
end TestFunction2;

function TestFunction3
 input Real i1;
 input Real i2;
 input Real i3 = 0;
 output Real o1 = i1 + i2 + i3;
 output Real o2 = i2 + i3;
 output Real o3 = i1 + i2;
algorithm
end TestFunction3;

function TestFunctionNoOut
 input Real i1;
algorithm
end TestFunctionNoOut;

function TestFunctionCallingFunction
 input Real i1;
 output Real o1;
algorithm
 o1 := TestFunction1(i1);
end TestFunctionCallingFunction;

function TestFunctionRecursive
 input Integer i1;
 output Integer o1;
algorithm
 if i1 < 3 then
  o1 := 1;
 else
  o1 := TestFunctionRecursive(i1 - 1) + TestFunctionRecursive(i1 - 2);
 end if;
end TestFunctionRecursive;


/* Function tests */
model CFunctionTest1
 Real x;
equation
 x = TestFunction1(2.0);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest1",
            description="Test of code generation",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction1_def0(jmi_real_t i1_v, jmi_real_t* o1_o);
jmi_real_t func_CCodeGenTests_TestFunction1_exp0(jmi_real_t i1_v);

void func_CCodeGenTests_TestFunction1_def0(jmi_real_t i1_v, jmi_real_t* o1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    o1_v = i1_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction1_exp0(jmi_real_t i1_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction1_def0(i1_v, &o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp0(2.0) - (_x_0);
")})));
end CFunctionTest1;

model CFunctionTest2
 Real x;
 Real y;
equation
 (x, y) = TestFunction2(1, 2);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest2",
        description="C code gen: functions: using multiple outputs",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o);
jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    JMI_DEF(REA, o2_v)
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_RET(GEN, o2_o, o2_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}


    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    func_CCodeGenTests_TestFunction2_def0(1.0, 2.0, &tmp_1, &tmp_2);
    (*res)[0] = tmp_1 - (_x_0);
    (*res)[1] = tmp_2 - (_y_1);
")})));
end CFunctionTest2;

model CFunctionTest3
 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction2(1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest3",
        description="C code gen: functions: two calls to same function",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o);
jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    JMI_DEF(REA, o2_v)
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_RET(GEN, o2_o, o2_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction2_exp0(1.0, 0.0) - (_x_0);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp0(2.0, 3.0) - (_y_1);
")})));
end CFunctionTest3;

model CFunctionTest4
 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction1(y * 2);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest4",
        description="C code gen: functions: calls to two functions",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o);
jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v);
void func_CCodeGenTests_TestFunction1_def1(jmi_real_t i1_v, jmi_real_t* o1_o);
jmi_real_t func_CCodeGenTests_TestFunction1_exp1(jmi_real_t i1_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    JMI_DEF(REA, o2_v)
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_RET(GEN, o2_o, o2_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}

void func_CCodeGenTests_TestFunction1_def1(jmi_real_t i1_v, jmi_real_t* o1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    o1_v = i1_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction1_exp1(jmi_real_t i1_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction1_def1(i1_v, &o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp1(_y_1 * 2.0) - (_x_0);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp0(2.0, 3.0) - (_y_1);
")})));
end CFunctionTest4;

model CFunctionTest5
  Real x;
  Real y;
equation
  (x, y) = TestFunction3(1, 2, 3);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest5",
        description="C code gen: functions: fewer components assigned than outputs",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunction3_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v, jmi_real_t* o1_o, jmi_real_t* o2_o, jmi_real_t* o3_o);
jmi_real_t func_CCodeGenTests_TestFunction3_exp0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v);

void func_CCodeGenTests_TestFunction3_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v, jmi_real_t* o1_o, jmi_real_t* o2_o, jmi_real_t* o3_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    JMI_DEF(REA, o2_v)
    JMI_DEF(REA, o3_v)
    o1_v = i1_v + i2_v + i3_v;
    o2_v = i2_v + i3_v;
    o3_v = i1_v + i2_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_RET(GEN, o2_o, o2_v)
    JMI_RET(GEN, o3_o, o3_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction3_exp0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction3_def0(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
    return o1_v;
}


    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    func_CCodeGenTests_TestFunction3_def0(1.0, 2.0, 3.0, &tmp_1, &tmp_2, NULL);
    (*res)[0] = tmp_1 - (_x_0);
    (*res)[1] = tmp_2 - (_y_1);
")})));
end CFunctionTest5;

model CFunctionTest6
  Real x;
  Real z;
equation
  (x, , z) = TestFunction3(1, 2, 3);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest6",
        description="C code gen: functions: one output skipped",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunction3_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v, jmi_real_t* o1_o, jmi_real_t* o2_o, jmi_real_t* o3_o);
jmi_real_t func_CCodeGenTests_TestFunction3_exp0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v);

void func_CCodeGenTests_TestFunction3_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v, jmi_real_t* o1_o, jmi_real_t* o2_o, jmi_real_t* o3_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    JMI_DEF(REA, o2_v)
    JMI_DEF(REA, o3_v)
    o1_v = i1_v + i2_v + i3_v;
    o2_v = i2_v + i3_v;
    o3_v = i1_v + i2_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_RET(GEN, o2_o, o2_v)
    JMI_RET(GEN, o3_o, o3_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction3_exp0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t i3_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction3_def0(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
    return o1_v;
}


    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    func_CCodeGenTests_TestFunction3_def0(1.0, 2.0, 3.0, &tmp_1, NULL, &tmp_2);
    (*res)[0] = tmp_1 - (_x_0);
    (*res)[1] = tmp_2 - (_z_1);
")})));
end CFunctionTest6;

model CFunctionTest7
equation
  TestFunction2(1, 2);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest7",
        description="C code gen: functions: no components assigned",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o);
jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_real_t i1_v, jmi_real_t i2_v, jmi_real_t* o1_o, jmi_real_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    JMI_DEF(REA, o2_v)
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_RET(GEN, o2_o, o2_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction2_exp0(jmi_real_t i1_v, jmi_real_t i2_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}


    func_CCodeGenTests_TestFunction2_def0(1.0, 2.0, NULL, NULL);
")})));
end CFunctionTest7;

model CFunctionTest8
 Real x = TestFunctionCallingFunction(1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest8",
        description="C code gen: functions: function calling other function",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunctionCallingFunction_def0(jmi_real_t i1_v, jmi_real_t* o1_o);
jmi_real_t func_CCodeGenTests_TestFunctionCallingFunction_exp0(jmi_real_t i1_v);
void func_CCodeGenTests_TestFunction1_def1(jmi_real_t i1_v, jmi_real_t* o1_o);
jmi_real_t func_CCodeGenTests_TestFunction1_exp1(jmi_real_t i1_v);

void func_CCodeGenTests_TestFunctionCallingFunction_def0(jmi_real_t i1_v, jmi_real_t* o1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    o1_v = func_CCodeGenTests_TestFunction1_exp1(i1_v);
    JMI_RET(GEN, o1_o, o1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunctionCallingFunction_exp0(jmi_real_t i1_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunctionCallingFunction_def0(i1_v, &o1_v);
    return o1_v;
}

void func_CCodeGenTests_TestFunction1_def1(jmi_real_t i1_v, jmi_real_t* o1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    o1_v = i1_v;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction1_exp1(jmi_real_t i1_v) {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction1_def1(i1_v, &o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunctionCallingFunction_exp0(1.0) - (_x_0);
")})));
end CFunctionTest8;

model CFunctionTest9
 Real x = TestFunctionRecursive(5);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest9",
        description="C code gen: functions:",
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunctionRecursive_def0(jmi_real_t i1_v, jmi_real_t* o1_o);
jmi_real_t func_CCodeGenTests_TestFunctionRecursive_exp0(jmi_real_t i1_v);

void func_CCodeGenTests_TestFunctionRecursive_def0(jmi_real_t i1_v, jmi_real_t* o1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, o1_v)
    if (COND_EXP_LT(i1_v, 3, JMI_TRUE, JMI_FALSE)) {
        o1_v = 1;
    } else {
        o1_v = func_CCodeGenTests_TestFunctionRecursive_exp0(i1_v - 1.0) + func_CCodeGenTests_TestFunctionRecursive_exp0(i1_v - 2.0);
    }
    JMI_RET(GEN, o1_o, o1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunctionRecursive_exp0(jmi_real_t i1_v) {
    JMI_DEF(INT, o1_v)
    func_CCodeGenTests_TestFunctionRecursive_def0(i1_v, &o1_v);
    return o1_v;
}


")})));
end CFunctionTest9;

model CFunctionTest10
 Real x = TestFunction0();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest10",
            description="C code gen: functions: no inputs",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction0_def0(jmi_real_t* o1_o);
jmi_real_t func_CCodeGenTests_TestFunction0_exp0();

void func_CCodeGenTests_TestFunction0_def0(jmi_real_t* o1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o1_v)
    o1_v = 0;
    JMI_RET(GEN, o1_o, o1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestFunction0_exp0() {
    JMI_DEF(REA, o1_v)
    func_CCodeGenTests_TestFunction0_def0(&o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction0_exp0() - (_x_0);
")})));
end CFunctionTest10;

model CFunctionTest11
equation
 TestFunctionNoOut(1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest11",
        description="C code gen: functions: no outputs",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_TestFunctionNoOut_def0(jmi_real_t i1_v);

void func_CCodeGenTests_TestFunctionNoOut_def0(jmi_real_t i1_v) {
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return;
}


    func_CCodeGenTests_TestFunctionNoOut_def0(1.0);
")})));
end CFunctionTest11;

model CFunctionTest12
function f
  input Real x[2];
  output Real y[2];
algorithm
  y:=x;
end f;

Real z[2](each nominal=3)={1,1};
Real w[2];
equation
w=f(z);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest12",
        description="C code gen: function and variable scaling",
        enable_variable_scaling=true,
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CFunctionTest12_f_def0(jmi_array_t* x_a, jmi_array_t* y_a);

void func_CCodeGenTests_CFunctionTest12_f_def0(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(y_a, i1_0i) = jmi_array_val_1(x_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    memcpy(&jmi_array_ref_1(tmp_2, 1), &_z_1_0, 2 * sizeof(jmi_real_t));
    func_CCodeGenTests_CFunctionTest12_f_def0(tmp_2, tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - ((_w_1_2*sf(2)));
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - ((_w_2_3*sf(3)));
    (*res)[2] = 1 - ((_z_1_0*sf(0)));
    (*res)[3] = 1 - ((_z_2_1*sf(1)));

")})));
end CFunctionTest12;


model CFunctionTest13

		
function F
  input Real x[2];
  input Real u;
  output Real dx[2];
  output Real y[2];
algorithm
  dx := -x + {u,0};
  y := 2*x;
end F;

Real x[2](each start = 3);
Real z[2];
Real u = 3;
Real y[2];
equation
 der(x) = -x;
(z,y) = F(x,u);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest13",
        description="C code gen: solved function call equation",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
void func_CCodeGenTests_CFunctionTest13_F_def0(jmi_array_t* x_a, jmi_real_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a);

void func_CCodeGenTests_CFunctionTest13_F_def0(jmi_array_t* x_a, jmi_real_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, dx_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    if (dx_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, dx_an, 2, 1, 2)
        dx_a = dx_an;
    }
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_a, 1) = u_v;
    jmi_array_ref_1(temp_1_a, 2) = 0;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(dx_a, i1_0i) = - jmi_array_val_1(x_a, i1_0i) + jmi_array_val_1(temp_1_a, i1_0i);
    }
    i1_1in = 0;
    i1_1ie = floor((2) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(y_a, i1_1i) = 2 * jmi_array_val_1(x_a, i1_1i);
    }
    JMI_DYNAMIC_FREE()
    return;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    _der_x_1_7 = - _x_1_0;
    _der_x_2_8 = - _x_2_1;
    _u_4 = 3;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    memcpy(&jmi_array_ref_1(tmp_3, 1), &_x_1_0, 2 * sizeof(jmi_real_t));
    func_CCodeGenTests_CFunctionTest13_F_def0(tmp_3, _u_4, tmp_1, tmp_2);
    memcpy(&_z_1_2, &jmi_array_val_1(tmp_1, 1), 2 * sizeof(jmi_real_t));
    memcpy(&_y_1_5, &jmi_array_val_1(tmp_2, 1), 2 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFunctionTest13;

model CFunctionTest14
function F
  input Real x[2];
  input Real u;
  output Real dx[2];
  output Real y[2];
algorithm
  dx := -x + {u,0};
  y := 2*x;
end F;

Real x[2](each start = 3);
Real z[2];
Real u = 3;
Real y[2];
equation
 der(x) = -x;
(z,y) = F(z+x,u);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest14",
        description="C code gen: unsolved function call equation",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
void func_CCodeGenTests_CFunctionTest14_F_def0(jmi_array_t* x_a, jmi_real_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a);

void func_CCodeGenTests_CFunctionTest14_F_def0(jmi_array_t* x_a, jmi_real_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, dx_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    if (dx_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, dx_an, 2, 1, 2)
        dx_a = dx_an;
    }
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_a, 1) = u_v;
    jmi_array_ref_1(temp_1_a, 2) = 0;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(dx_a, i1_0i) = - jmi_array_val_1(x_a, i1_0i) + jmi_array_val_1(temp_1_a, i1_0i);
    }
    i1_1in = 0;
    i1_1ie = floor((2) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(y_a, i1_1i) = 2 * jmi_array_val_1(x_a, i1_1i);
    }
    JMI_DYNAMIC_FREE()
    return;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_1_7 = - _x_1_0;
    _der_x_2_8 = - _x_2_1;
    _u_4 = 3;
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end CFunctionTest14;


model CFunctionTest15
	function f
		input Real[2] x;
		output Real y;
	algorithm
		y := sum(x);
	end f;
	
	parameter Real[2] p1 = {1,2};
    parameter Real p2 = f(p1);
    parameter Real p3 = f(p1 .+ p2);
	Real z(start=f(p1 .+ p3));
    Real w(start=f(p1 .+ p2));
equation
	der(z) = -z;
	der(w) = -w;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest15",
            description="Declare temp variables for parameters and start values at start of function",
            inline_functions="none",
            template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_parameters$
$C_model_init_eval_dependent_variables$
$C_DAE_initial_guess_equation_residuals$
",
            generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p1_1_0 = (1);
    _p1_2_1 = (2);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    memcpy(&jmi_array_ref_1(tmp_1, 1), &_p1_1_0, 2 * sizeof(jmi_real_t));
    _p2_2 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _p1_1_0 + _p2_2;
    jmi_array_ref_1(tmp_2, 2) = _p1_2_1 + _p2_2;
    _p3_3 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_2));
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = _p1_1_0 + _p3_3;
    jmi_array_ref_1(tmp_3, 2) = _p1_2_1 + _p3_3;
    _z_4 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_3));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1, 2)
    jmi_array_ref_1(tmp_4, 1) = _p1_1_0 + _p2_2;
    jmi_array_ref_1(tmp_4, 2) = _p1_2_1 + _p2_2;
    _w_5 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_4));
    JMI_DYNAMIC_FREE()
    return ef;
}

    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = _p1_1_0 + _p3_3;
    jmi_array_ref_1(tmp_3, 2) = _p1_2_1 + _p3_3;
    (*res)[0] = func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_3) - _z_4;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1, 2)
    jmi_array_ref_1(tmp_4, 1) = _p1_1_0 + _p2_2;
    jmi_array_ref_1(tmp_4, 2) = _p1_2_1 + _p2_2;
    (*res)[1] = func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_4) - _w_5;
")})));
end CFunctionTest15;

model CFunctionTest16
        record R
            Real a;
            Real b;
        end R;
        function f
            input Real x1;
            input Real x2;
            output R y1;
            output Real[2] y2;
          algorithm
            y1.a := x1;
            y1.b := x2;
            y2 := {x1,x2};
        end f;
        R y1;
        Real[2] y2;
      equation
        (y1,y2) = f(2,time);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest16",
        description="Function call equation with partially propagated composite elements",
        inline_functions="none",
        eliminate_alias_variables=false,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    func_CCodeGenTests_CFunctionTest16_f_def0(2.0, _time, tmp_1, tmp_2);
    _y1_b_1 = (tmp_1->b);
    _y2_2_3 = (jmi_array_val_1(tmp_2, 2));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFunctionTest16;

model CFunctionTest17
    function F1
        input Real x;
        output Real[2] y;
    algorithm
        y[1] := x;
        y[2] := 2*x;
        y := F2(y);
    end F1;
    
    function F2
        input Real[2] x;
        output Real[2] y;
    algorithm
        for i in 1:2 loop
            y[i] := x[1] + x[2];
        end for;
    end F2;

    parameter Real[2] p1 = F1(1) annotation(Evaluate=true);
    parameter Real[2] p2 = F1(1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest17",
        description="Test composite variable that is both input and output in function call statement",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CFunctionTest17_F1_def0(jmi_real_t x_v, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    jmi_array_ref_1(y_a, 1) = x_v;
    jmi_array_ref_1(y_a, 2) = 2 * x_v;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenTests_CFunctionTest17_F2_def1(y_a, tmp_1);
    JMI_ASG(GEN_ARR, y_a, tmp_1)    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_CFunctionTest17_F2_def1(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    i_0in = 0;
    i_0ie = floor((2) - (1));
    for (i_0i = 1; i_0in <= i_0ie; i_0i = 1 + (++i_0in)) {
        jmi_array_ref_1(y_a, i_0i) = jmi_array_val_1(x_a, 1) + jmi_array_val_1(x_a, 2);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CFunctionTest17;

model CFunctionTest18
    record R
        Real a;
        Real b;
    end R;

    function F1
        input Real x;
        output R y;
    algorithm
        y.a := x;
        y.b := 2*x;
        y := F2(y);
    end F1;

    function F2
        input R x;
        output R y;
    algorithm
        y.a := x.a + x.b;
        y.b := x.a + x.b;
    end F2;

    parameter R p1 = F1(1) annotation(Evaluate=true);
    parameter R p2 = F1(1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest18",
        description="Test composite variable that is both input and output in function call statement",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CFunctionTest18_F1_def0(jmi_real_t x_v, R_0_r* y_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, y_vn)
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    if (y_v == NULL) {
        y_v = y_vn;
    }
    y_v->a = x_v;
    y_v->b = 2 * x_v;
    func_CCodeGenTests_CFunctionTest18_F2_def1(y_v, tmp_1);
    y_v->a = (tmp_1->a);
    y_v->b = (tmp_1->b);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_CFunctionTest18_F2_def1(R_0_r* x_v, R_0_r* y_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, y_vn)
    if (y_v == NULL) {
        y_v = y_vn;
    }
    y_v->a = x_v->a + x_v->b;
    y_v->b = x_v->a + x_v->b;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CFunctionTest18;

model CFunctionTest19
    record R
        Real x;
    end R;
    
    function f
        input Real x;
        output R y = R(x);
    algorithm
        annotation(Inline=false,smoothOrder=1);
    end f;
    
    R y;
    Real x;
 equation
    y = f(time);
    der(y.x) = der(x);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest19",
            description="Derivative in solved function call left",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_RECORD_STATIC(R_0_r, tmp_2)
    func_CCodeGenTests_CFunctionTest19__der_f_def1(_time, 1.0, tmp_1);
    _der_y_x_2 = (tmp_1->x);
    _der_x_3 = _der_y_x_2;
    func_CCodeGenTests_CFunctionTest19_f_def0(_time, tmp_2);
    _y_x_0 = (tmp_2->x);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFunctionTest19;

model CFunctionTest20
    record R
        Real[5] x;
    end R;
    
    function f
        input Real[:] x1;
        input Real x2;
        output R y;
    algorithm
        y := R(x1);
        y.x[3] := x2;
        annotation(Inline=false);
    end f;
    
    R y = f({time,time,time,time,time}, 3);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest20",
        description="memcpy for parts of array",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 5, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 5, 1, 5)
    tmp_1->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1, 5)
    jmi_array_ref_1(tmp_3, 1) = _time;
    jmi_array_ref_1(tmp_3, 2) = _time;
    jmi_array_ref_1(tmp_3, 3) = _time;
    jmi_array_ref_1(tmp_3, 4) = _time;
    jmi_array_ref_1(tmp_3, 5) = _time;
    func_CCodeGenTests_CFunctionTest20_f_def0(tmp_3, 3.0, tmp_1);
    memcpy(&_y_x_1_0, &jmi_array_val_1(tmp_1->x, 1), 2 * sizeof(jmi_real_t));
    memcpy(&_y_x_4_3, &jmi_array_val_1(tmp_1->x, 4), 2 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFunctionTest20;

model CFunctionTest21
    record R
        Real[5] x;
    end R;
    
    function f
        input Real[:] x1;
        output R y;
    algorithm
        y := R(x1);
        annotation(Inline=false);
    end f;
    
    R y = f({time,time,time,time,time});
    Real x = y.x[3];
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest21",
            description="memcpy for parts of array",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 5, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 5, 1, 5)
    tmp_1->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1, 5)
    jmi_array_ref_1(tmp_3, 1) = _time;
    jmi_array_ref_1(tmp_3, 2) = _time;
    jmi_array_ref_1(tmp_3, 3) = _time;
    jmi_array_ref_1(tmp_3, 4) = _time;
    jmi_array_ref_1(tmp_3, 5) = _time;
    func_CCodeGenTests_CFunctionTest21_f_def0(tmp_3, tmp_1);
    memcpy(&_y_x_1_0, &jmi_array_val_1(tmp_1->x, 1), 2 * sizeof(jmi_real_t));
    _x_4 = (jmi_array_val_1(tmp_1->x, 3));
    memcpy(&_y_x_4_2, &jmi_array_val_1(tmp_1->x, 4), 2 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFunctionTest21;

model CFunctionTest22
    record R
        Real[5] x;
    end R;
    
    function f
        input Real[:] x1;
        output R y;
    algorithm
        y := R(x1);
        annotation(Inline=false);
    end f;
    
    parameter R y = f({1,2,3,4,5});
    parameter Real x = y.x[3];
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFunctionTest22",
        description="memcpy for parts of array",
        eliminate_alias_parameters=true,
        template="$C_model_init_eval_dependent_parameters$",
        generatedCode="

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 5, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 5, 1, 5)
    tmp_1->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 5, 1, 5)
    jmi_array_ref_1(tmp_3, 1) = 1.0;
    jmi_array_ref_1(tmp_3, 2) = 2.0;
    jmi_array_ref_1(tmp_3, 3) = 3.0;
    jmi_array_ref_1(tmp_3, 4) = 4.0;
    jmi_array_ref_1(tmp_3, 5) = 5.0;
    func_CCodeGenTests_CFunctionTest22_f_def0(tmp_3, tmp_1);
    memcpy(&_y_x_1_0, &jmi_array_val_1(tmp_1->x, 1), 5 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFunctionTest22;
model CFunctionTest23
    function F
        input Real i[6];
        output Real o[6];
    algorithm
        o := i;
    annotation(Inline=false);
    end F;
    Real a;
    Real c;
    Real d;
    
    Real e = time;
    Real b[3];
    Real f[3] = {sin(time - 0.5), sin(time), sin(time + 0.5)};
    Real g = cos(time);
    Real h = -cos(time);
equation
    {a, b[1],b[2],c,b[3],d} = F({e, f[1], f[2], g, f[3], h});
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest23",
            description="memcpy for parts of array (both of input and output)",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 6, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 6, 1)
    _e_3 = _time;
    _f_1_7 = sin(_time - 0.5);
    _f_2_8 = sin(_time);
    _g_10 = cos(_time);
    _f_3_9 = sin(_time + 0.5);
    _h_11 = - cos(_time);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 6, 1, 6)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 6, 1, 6)
    jmi_array_ref_1(tmp_2, 1) = _e_3;
    memcpy(&jmi_array_ref_1(tmp_2, 2), &_f_1_7, 2 * sizeof(jmi_real_t));
    jmi_array_ref_1(tmp_2, 4) = _g_10;
    jmi_array_ref_1(tmp_2, 5) = _f_3_9;
    jmi_array_ref_1(tmp_2, 6) = _h_11;
    func_CCodeGenTests_CFunctionTest23_F_def0(tmp_2, tmp_1);
    _a_0 = (jmi_array_val_1(tmp_1, 1));
    memcpy(&_b_1_4, &jmi_array_val_1(tmp_1, 2), 2 * sizeof(jmi_real_t));
    _c_1 = (jmi_array_val_1(tmp_1, 4));
    _b_3_6 = (jmi_array_val_1(tmp_1, 5));
    _d_2 = (jmi_array_val_1(tmp_1, 6));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFunctionTest23;

model FuncWithArray
    function g
      input Real x[:];
      output Integer n;
    algorithm
      n := integer(sum(x)/sum(x));
    end g;
	function F
        input Real x;
        output Real y[g({x,x})];
    algorithm
        y := {x};
	end F;
	Real[1] a(start=2);
	equation
		der(a) = F(1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="FuncWithArray",
        description="",
        variability_propagation=false,
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_FuncWithArray_F_def0(jmi_real_t x_v, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, y_an, -1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_ref_1(tmp_1, 1) = x_v;
        jmi_array_ref_1(tmp_1, 2) = x_v;
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, y_an, func_CCodeGenTests_FuncWithArray_g_exp1(tmp_1), 1, func_CCodeGenTests_FuncWithArray_g_exp1(tmp_1))
        y_a = y_an;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = x_v;
    jmi_array_ref_1(tmp_2, 2) = x_v;
    if (COND_EXP_EQ(func_CCodeGenTests_FuncWithArray_g_exp1(tmp_2), 1.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"Mismatching sizes in CCodeGenTests.FuncWithArray.F\", JMI_ASSERT_ERROR);
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 1, 1, 1)
    jmi_array_ref_1(temp_1_a, 1) = x_v;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = x_v;
    jmi_array_ref_1(tmp_3, 2) = x_v;
    i1_0in = 0;
    i1_0ie = floor((func_CCodeGenTests_FuncWithArray_g_exp1(tmp_3)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(y_a, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_FuncWithArray_g_def1(jmi_array_t* x_a, jmi_real_t* n_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, n_v)
    JMI_DEF(REA, temp_1_v)
    JMI_DEF(REA, temp_2_v)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    temp_1_v = 0.0;
    i1_1in = 0;
    i1_1ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(x_a, i1_1i);
    }
    temp_2_v = 0.0;
    i1_2in = 0;
    i1_2ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        temp_2_v = temp_2_v + jmi_array_val_1(x_a, i1_2i);
    }
    n_v = floor(jmi_divide_function(\"CCodeGenTests.FuncWithArray.g\", temp_1_v, temp_2_v, \"temp_1 / temp_2\"));
    JMI_RET(GEN, n_o, n_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_FuncWithArray_g_exp1(jmi_array_t* x_a) {
    JMI_DEF(INT, n_v)
    func_CCodeGenTests_FuncWithArray_g_def1(x_a, &n_v);
    return n_v;
}

")})));
end FuncWithArray;


package Loops



model For1
 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in 1:3 loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Loops_For1",
        description="C code generation for for loops: range exp",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_Loops_For1_f_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_DEF(REA, x_v)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    o_v = 1.0;
    x_v = 0;
    i_0in = 0;
    i_0ie = floor((3) - (1));
    for (i_0i = 1; i_0in <= i_0ie; i_0i = 1 + (++i_0in)) {
        x_v = x_v + i_0i;
    }
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_For1_f_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_Loops_For1_f_def0(&o_v);
    return o_v;
}

")})));
end For1;


model For2
 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in {2,3,5} loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFor2",
            description="C code generation for for loops: generic exp",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_Loops_For2_f_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_DEF(REA, x_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1)
    jmi_real_t i_0i;
    int i_0ii;
    o_v = 1.0;
    x_v = 0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1, 3)
    jmi_array_ref_1(temp_1_a, 1) = 2;
    jmi_array_ref_1(temp_1_a, 2) = 3;
    jmi_array_ref_1(temp_1_a, 3) = 5;
    for (i_0ii = 0; i_0ii < jmi_array_size(temp_1_a, 0); i_0ii++) {
        i_0i = jmi_array_val_1(temp_1_a, i_0ii);
        x_v = x_v + i_0i;
    }
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_For2_f_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_Loops_For2_f_def0(&o_v);
    return o_v;
}

")})));
end For2;


model For3
 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in 3:-1:1 loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Loops_For3",
        description="C code generation for for loops: decreasing range exp",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_Loops_For3_f_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_DEF(REA, x_v)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    o_v = 1.0;
    x_v = 0;
    i_0in = 0;
    i_0ie = floor(((1) - (3)) / (-1));
    for (i_0i = 3; i_0in <= i_0ie; i_0i = 3 + (-1) * (++i_0in)) {
        x_v = x_v + i_0i;
    }
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_For3_f_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_Loops_For3_f_def0(&o_v);
    return o_v;
}

")})));
end For3;


model For4
 function f
  input Real i;
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in 3:i:1 loop
   x := x + i;
  end for;
 end f;
 
 Real x = f(-1);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Loops_For4",
        description="C code generation for for loops: range exp, unknown if increasing or decreasing",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_Loops_For4_f_def0(jmi_real_t i_v, jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_DEF(REA, x_v)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    o_v = 1.0;
    x_v = 0;
    i_0in = 0;
    i_0ie = floor(((1) - (3)) / (i_v));
    for (i_0i = 3; i_0in <= i_0ie; i_0i = 3 + (i_v) * (++i_0in)) {
        x_v = x_v + i_0i;
    }
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_For4_f_exp0(jmi_real_t i_v) {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_Loops_For4_f_def0(i_v, &o_v);
    return o_v;
}

")})));
end For4;

model ForUnknownSize1
    function f
        input Real[:] y;
        output Real x;
    algorithm
        x := 0;
        for v in y loop
            x := x + v;
        end for;
    end f;
    
    parameter Integer n = 4;
    Real x = f(y);
    Real y[n] = (1:n) * time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CForUnknown1",
            description="C code gen for for loop over unknown size array: array variable",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_Loops_ForUnknownSize1_f_def0(jmi_array_t* y_a, jmi_real_t* x_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, x_v)
    jmi_real_t v_0i;
    int v_0ii;
    x_v = 0;
    for (v_0ii = 0; v_0ii < jmi_array_size(y_a, 0); v_0ii++) {
        v_0i = jmi_array_val_1(y_a, v_0ii);
        x_v = x_v + v_0i;
    }
    JMI_RET(GEN, x_o, x_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_ForUnknownSize1_f_exp0(jmi_array_t* y_a) {
    JMI_DEF(REA, x_v)
    func_CCodeGenTests_Loops_ForUnknownSize1_f_def0(y_a, &x_v);
    return x_v;
}

")})));
end ForUnknownSize1;


model ForUnknownSize2
    function f
        input Integer n;
        output Real x;
    algorithm
        x := 0;
        for i in 1:n loop
            x := x + i;
        end for;
    end f;
    
    Integer n = integer(time);
    Real x = f(n);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Loops_ForUnknownSize2",
        description="C code gen for for loop over unknown size array: range exp",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_Loops_ForUnknownSize2_f_def0(jmi_real_t n_v, jmi_real_t* x_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, x_v)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    x_v = 0;
    i_0in = 0;
    i_0ie = floor((n_v) - (1));
    for (i_0i = 1; i_0in <= i_0ie; i_0i = 1 + (++i_0in)) {
        x_v = x_v + i_0i;
    }
    JMI_RET(GEN, x_o, x_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_ForUnknownSize2_f_exp0(jmi_real_t n_v) {
    JMI_DEF(REA, x_v)
    func_CCodeGenTests_Loops_ForUnknownSize2_f_def0(n_v, &x_v);
    return x_v;
}

")})));
end ForUnknownSize2;


model ForUnknownSize3
    function f
        input Integer n;
        output Real x;
    algorithm
        x := 0;
        for i in (1:n).^2 loop
            x := x + i;
        end for;
    end f;
    
    Integer n = integer(time);
    Real x = f(n);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Loops_ForUnknownSize3",
        description="C code gen for for loop over unknown size array: general array exp",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_Loops_ForUnknownSize3_f_def0(jmi_real_t n_v, jmi_real_t* x_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, x_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_1_a, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i_1i;
    int i_1ii;
    x_v = 0;
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_1_a, jmi_max(n_v, 0.0), 1, jmi_max(n_v, 0.0))
    i1_0in = 0;
    i1_0ie = floor((jmi_max(n_v, 0.0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(temp_1_a, i1_0i) = (1.0 * (i1_0i) * (i1_0i));
    }
    for (i_1ii = 0; i_1ii < jmi_array_size(temp_1_a, 0); i_1ii++) {
        i_1i = jmi_array_val_1(temp_1_a, i_1ii);
        x_v = x_v + i_1i;
    }
    JMI_RET(GEN, x_o, x_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_ForUnknownSize3_f_exp0(jmi_real_t n_v) {
    JMI_DEF(REA, x_v)
    func_CCodeGenTests_Loops_ForUnknownSize3_f_def0(n_v, &x_v);
    return x_v;
}

")})));
end ForUnknownSize3;

model StepSize1

  function f
    input Real x;
    output Real y;
    Integer step;
  algorithm
    step := integer(x) + 1;
    y := 0;
    for i in 1:step:10 loop
      y := y + i;
    end for;
  end f;

  Real b = f(time);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Loops_StepSize1",
        description="Checks so that step sizes are generated correctly.",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_Loops_StepSize1_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(INT, step_v)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    step_v = floor(x_v) + 1;
    y_v = 0;
    i_0in = 0;
    i_0ie = floor(((10) - (1)) / (step_v));
    for (i_0i = 1; i_0in <= i_0ie; i_0i = 1 + (step_v) * (++i_0in)) {
        y_v = y_v + i_0i;
    }
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Loops_StepSize1_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Loops_StepSize1_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end StepSize1;

end Loops;

model CArrayInput1
 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = f(1:3);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput1",
        description="C code generation: array inputs to functions: basic test",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput1_f_def0(jmi_array_t* inp_a, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput1_f_exp0(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput1_f_def0(jmi_array_t* inp_a, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    temp_1_v = 0.0;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_0i);
    }
    out_v = temp_1_v;
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput1_f_exp0(jmi_array_t* inp_a) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput1_f_def0(inp_a, &out_v);
    return out_v;
}


    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    (*res)[0] = func_CCodeGenTests_CArrayInput1_f_exp0(tmp_1) - (_x_0);

")})));
end CArrayInput1;


model CArrayInput2
 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = 2 + 5 * f((1:3) + {3, 5, 7});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput2",
        description="C code generation: array inputs to functions: expressions around call",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput2_f_def0(jmi_array_t* inp_a, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput2_f_exp0(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput2_f_def0(jmi_array_t* inp_a, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    temp_1_v = 0.0;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_0i);
    }
    out_v = temp_1_v;
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput2_f_exp0(jmi_array_t* inp_a) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput2_f_def0(inp_a, &out_v);
    return out_v;
}


    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0 + 3.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0 + 5.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0 + 7.0;
    (*res)[0] = 2 + 5 * func_CCodeGenTests_CArrayInput2_f_exp0(tmp_1) - (_x_0);

")})));
end CArrayInput2;


model CArrayInput3
 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = f({f(1:3),f(4:6),f(7:9)});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput3",
        description="C code generation: array inputs to functions: nestled calls",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput3_f_def0(jmi_array_t* inp_a, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput3_f_exp0(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput3_f_def0(jmi_array_t* inp_a, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    temp_1_v = 0.0;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_0i);
    }
    out_v = temp_1_v;
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput3_f_exp0(jmi_array_t* inp_a) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput3_f_def0(inp_a, &out_v);
    return out_v;
}


    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1, 3)
    jmi_array_ref_1(tmp_2, 1) = 4.0;
    jmi_array_ref_1(tmp_2, 2) = 5.0;
    jmi_array_ref_1(tmp_2, 3) = 6.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 3, 1, 3)
    jmi_array_ref_1(tmp_3, 1) = 7.0;
    jmi_array_ref_1(tmp_3, 2) = 8.0;
    jmi_array_ref_1(tmp_3, 3) = 9.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1, 3)
    jmi_array_ref_1(tmp_4, 1) = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_1);
    jmi_array_ref_1(tmp_4, 2) = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_2);
    jmi_array_ref_1(tmp_4, 3) = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_3);
    (*res)[0] = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_4) - (_x_0);

")})));
end CArrayInput3;


model CArrayInput4
 function f1
  output Real out = 1.0;
 algorithm
  out := f2(1:3);
 end f1;
 
 function f2
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput4",
        description="C code generation: array inputs to functions: in assign statement",
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput4_f1_def0(jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput4_f1_exp0();
void func_CCodeGenTests_CArrayInput4_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput4_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput4_f1_def0(jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1, 3)
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(temp_1_a, i1_0i) = i1_0i;
    }
    out_v = func_CCodeGenTests_CArrayInput4_f2_exp1(temp_1_a);
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput4_f1_exp0() {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput4_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput4_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    temp_1_v = 0.0;
    i1_1in = 0;
    i1_1ie = floor((3) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_1i);
    }
    out_v = temp_1_v;
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput4_f2_exp1(jmi_array_t* inp_a) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput4_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput4;


model CArrayInput5
 function f1
  output Real out = 1.0;
  protected Real t;
 algorithm
  (out, t) := f2(1:3);
 end f1;
 
 function f2
  input Real inp[3];
  output Real out1 = sum(inp);
  output Real out2 = max(inp);
 algorithm
 end f2;
 
 Real x = f1();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput5",
        description="C code generation: array inputs to functions: function call stmt",
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput5_f1_def0(jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput5_f1_exp0();
void func_CCodeGenTests_CArrayInput5_f2_def1(jmi_array_t* inp_a, jmi_real_t* out1_o, jmi_real_t* out2_o);
jmi_real_t func_CCodeGenTests_CArrayInput5_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput5_f1_def0(jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, t_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1, 3)
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(temp_1_a, i1_0i) = i1_0i;
    }
    func_CCodeGenTests_CArrayInput5_f2_def1(temp_1_a, &out_v, &t_v);
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput5_f1_exp0() {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput5_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput5_f2_def1(jmi_array_t* inp_a, jmi_real_t* out1_o, jmi_real_t* out2_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out1_v)
    JMI_DEF(REA, out2_v)
    JMI_DEF(REA, temp_1_v)
    JMI_DEF(REA, temp_2_v)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    temp_1_v = 0.0;
    i1_1in = 0;
    i1_1ie = floor((3) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_1i);
    }
    out1_v = temp_1_v;
    temp_2_v = -1.7976931348623157E308;
    i1_2in = 0;
    i1_2ie = floor((3) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        temp_2_v = COND_EXP_EQ(COND_EXP_GT(temp_2_v, jmi_array_val_1(inp_a, i1_2i), JMI_TRUE, JMI_FALSE), JMI_TRUE, temp_2_v, jmi_array_val_1(inp_a, i1_2i));
    }
    out2_v = temp_2_v;
    JMI_RET(GEN, out1_o, out1_v)
    JMI_RET(GEN, out2_o, out2_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput5_f2_exp1(jmi_array_t* inp_a) {
    JMI_DEF(REA, out1_v)
    func_CCodeGenTests_CArrayInput5_f2_def1(inp_a, &out1_v, NULL);
    return out1_v;
}

")})));
end CArrayInput5;


model CArrayInput6
 function f1
  input Integer i;
  output Real out = 1.0;
 algorithm
  if f2(i+1:2) < 4 then
   out := f2(i+5:6);
  elseif f2(3:4) > 5 then
   out := f2(i+7:8);
  else
   out := f2(i+9:10);
  end if;
 end f1;
 
 function f2
  input Real inp[2];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1(0);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput6",
        description="C code generation: array inputs to functions: if statement",
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput6_f1_def0(jmi_real_t i_v, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput6_f1_exp0(jmi_real_t i_v);
void func_CCodeGenTests_CArrayInput6_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput6_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput6_f1_def0(jmi_real_t i_v, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_1_a, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_2_a, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_3_a, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    out_v = 1.0;
    if (COND_EXP_EQ(jmi_max(floor(2.0 - (i_v + 1.0)) + 1.0, 0.0), 2.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"Mismatching sizes in CCodeGenTests.CArrayInput6.f1\", JMI_ASSERT_ERROR);
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_1_a, jmi_max(floor(2.0 - (i_v + 1.0)) + 1.0, 0.0), 1, jmi_max(floor(2.0 - (i_v + 1.0)) + 1.0, 0.0))
    i1_0in = 0;
    i1_0ie = floor((jmi_max(floor(2.0 - (i_v + 1.0)) + 1.0, 0.0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(temp_1_a, i1_0i) = i_v + 1 + (i1_0i - 1);
    }
    if (COND_EXP_LT(func_CCodeGenTests_CArrayInput6_f2_exp1(temp_1_a), 4, JMI_TRUE, JMI_FALSE)) {
        if (COND_EXP_EQ(jmi_max(floor(6.0 - (i_v + 5.0)) + 1.0, 0.0), 2.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
            jmi_assert_failed(\"Mismatching sizes in CCodeGenTests.CArrayInput6.f1\", JMI_ASSERT_ERROR);
        }
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_2_a, jmi_max(floor(6.0 - (i_v + 5.0)) + 1.0, 0.0), 1, jmi_max(floor(6.0 - (i_v + 5.0)) + 1.0, 0.0))
        i1_1in = 0;
        i1_1ie = floor((jmi_max(floor(6.0 - (i_v + 5.0)) + 1.0, 0.0)) - (1));
        for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
            jmi_array_ref_1(temp_2_a, i1_1i) = i_v + 5 + (i1_1i - 1);
        }
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp1(temp_2_a);
    } else {
        if (COND_EXP_EQ(jmi_max(floor(8.0 - (i_v + 7.0)) + 1.0, 0.0), 2.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
            jmi_assert_failed(\"Mismatching sizes in CCodeGenTests.CArrayInput6.f1\", JMI_ASSERT_ERROR);
        }
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_3_a, jmi_max(floor(8.0 - (i_v + 7.0)) + 1.0, 0.0), 1, jmi_max(floor(8.0 - (i_v + 7.0)) + 1.0, 0.0))
        i1_2in = 0;
        i1_2ie = floor((jmi_max(floor(8.0 - (i_v + 7.0)) + 1.0, 0.0)) - (1));
        for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
            jmi_array_ref_1(temp_3_a, i1_2i) = i_v + 7 + (i1_2i - 1);
        }
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp1(temp_3_a);
    }
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput6_f1_exp0(jmi_real_t i_v) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput6_f1_def0(i_v, &out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput6_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    temp_1_v = 0.0;
    i1_3in = 0;
    i1_3ie = floor((2) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_3i);
    }
    out_v = temp_1_v;
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput6_f2_exp1(jmi_array_t* inp_a) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput6_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput6;


model CArrayInput7
 function f1
  output Real out = 1.0;
 algorithm
  while f2(1:3) < 2 loop
   out := f2(4:6);
  end while;
 end f1;
 
 function f2
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput7",
        description="C code generation: array inputs to functions: while stmt",
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput7_f1_def0(jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput7_f1_exp0();
void func_CCodeGenTests_CArrayInput7_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput7_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput7_f1_def0(jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_2_a, 3, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1, 3)
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(temp_1_a, i1_0i) = i1_0i;
    }
    while (COND_EXP_LT(func_CCodeGenTests_CArrayInput7_f2_exp1(temp_1_a), 2, JMI_TRUE, JMI_FALSE)) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_2_a, 3, 1, 3)
        i1_1in = 0;
        i1_1ie = floor((3) - (1));
        for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
            jmi_array_ref_1(temp_2_a, i1_1i) = 4 + (i1_1i - 1);
        }
        out_v = func_CCodeGenTests_CArrayInput7_f2_exp1(temp_2_a);
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1, 3)
        i1_2in = 0;
        i1_2ie = floor((3) - (1));
        for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
            jmi_array_ref_1(temp_1_a, i1_2i) = i1_2i;
        }
    }
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput7_f1_exp0() {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput7_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput7_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    temp_1_v = 0.0;
    i1_3in = 0;
    i1_3ie = floor((3) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_3i);
    }
    out_v = temp_1_v;
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput7_f2_exp1(jmi_array_t* inp_a) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput7_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput7;


model CArrayInput8
 function f1
  output Real out = 1.0;
 algorithm
  for i in {f2(1:3), f2(4:6)} loop
   out := f2(7:9);
  end for;
 end f1;
 
 function f2
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayInput8",
        description="C code generation: array inputs to functions: for stmt",
        variability_propagation=false,
        inline_functions="none",
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_CCodeGenTests_CArrayInput8_f1_def0(jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput8_f1_exp0();
void func_CCodeGenTests_CArrayInput8_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o);
jmi_real_t func_CCodeGenTests_CArrayInput8_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput8_f1_def0(jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_2_a, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_3_a, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_4_a, 3, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i_2i;
    int i_2ii;
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_2_a, 3, 1, 3)
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(temp_2_a, i1_0i) = i1_0i;
    }
    jmi_array_ref_1(temp_1_a, 1) = func_CCodeGenTests_CArrayInput8_f2_exp1(temp_2_a);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_3_a, 3, 1, 3)
    i1_1in = 0;
    i1_1ie = floor((3) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(temp_3_a, i1_1i) = 4 + (i1_1i - 1);
    }
    jmi_array_ref_1(temp_1_a, 2) = func_CCodeGenTests_CArrayInput8_f2_exp1(temp_3_a);
    for (i_2ii = 0; i_2ii < jmi_array_size(temp_1_a, 0); i_2ii++) {
        i_2i = jmi_array_val_1(temp_1_a, i_2ii);
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_4_a, 3, 1, 3)
        i1_3in = 0;
        i1_3ie = floor((3) - (1));
        for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
            jmi_array_ref_1(temp_4_a, i1_3i) = 7 + (i1_3i - 1);
        }
        out_v = func_CCodeGenTests_CArrayInput8_f2_exp1(temp_4_a);
    }
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput8_f1_exp0() {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput8_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput8_f2_def1(jmi_array_t* inp_a, jmi_real_t* out_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, out_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_4i;
    jmi_int_t i1_4ie;
    jmi_int_t i1_4in;
    temp_1_v = 0.0;
    i1_4in = 0;
    i1_4ie = floor((3) - (1));
    for (i1_4i = 1; i1_4in <= i1_4ie; i1_4i = 1 + (++i1_4in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(inp_a, i1_4i);
    }
    out_v = temp_1_v;
    JMI_RET(GEN, out_o, out_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayInput8_f2_exp1(jmi_array_t* inp_a) {
    JMI_DEF(REA, out_v)
    func_CCodeGenTests_CArrayInput8_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput8;


model CArrayOutputs1
 function f
  output Real o[2] = {1,2};
 algorithm
 end f;
 
 Real x[2] = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayOutputs1",
            description="C code generation: array outputs from functions: in equation",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayOutputs1_f_def0(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs1_f_def0(jmi_array_t* o_a) {
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
    jmi_array_ref_1(temp_1_a, 2) = 2;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(o_a, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenTests_CArrayOutputs1_f_def0(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - (_x_1_0);
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - (_x_2_1);
")})));
end CArrayOutputs1;


model CArrayOutputs2
 function f
  output Real o[2] = {1,2};
 algorithm
 end f;
 
 Real x;
equation
 x = f() * {3,4};

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayOutputs2",
        description="C code generation: array outputs from functions: in expression in equation",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CArrayOutputs2_f_def0(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs2_f_def0(jmi_array_t* o_a) {
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
    jmi_array_ref_1(temp_1_a, 2) = 2;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(o_a, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenTests_CArrayOutputs2_f_def0(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - (_temp_1_1_1);
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - (_temp_1_2_2);
    (*res)[2] = _temp_1_1_1 * 3 + _temp_1_2_2 * 4 - (_x_0);
")})));
end CArrayOutputs2;


model CArrayOutputs3
 function f1
  output Real o = 0;
  protected Real x;
 algorithm
  x := f2() * {3,4};
 end f1;
 
 function f2
  output Real o[2] = {1,2};
 algorithm
 end f2;
 
 Real x = f1();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayOutputs3",
        description="C code generation: array outputs from functions: in expression in function",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CArrayOutputs3_f1_def0(jmi_real_t* o_o);
jmi_real_t func_CCodeGenTests_CArrayOutputs3_f1_exp0();
void func_CCodeGenTests_CArrayOutputs3_f2_def1(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs3_f1_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_DEF(REA, x_v)
    JMI_DEF(REA, temp_1_v)
    JMI_DEF(REA, temp_2_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_3_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_4_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    o_v = 0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_3_a, 2, 1, 2)
    func_CCodeGenTests_CArrayOutputs3_f2_def1(temp_3_a);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_4_a, 2, 1, 2)
    jmi_array_ref_1(temp_4_a, 1) = 3;
    jmi_array_ref_1(temp_4_a, 2) = 4;
    temp_2_v = 0.0;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        temp_2_v = temp_2_v + jmi_array_val_1(temp_3_a, i1_0i) * jmi_array_val_1(temp_4_a, i1_0i);
    }
    temp_1_v = temp_2_v;
    x_v = temp_1_v;
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayOutputs3_f1_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CArrayOutputs3_f1_def0(&o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs3_f2_def1(jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, o_an, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_a, 1) = 1;
    jmi_array_ref_1(temp_1_a, 2) = 2;
    i1_1in = 0;
    i1_1ie = floor((2) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(o_a, i1_1i) = jmi_array_val_1(temp_1_a, i1_1i);
    }
    JMI_DYNAMIC_FREE()
    return;
}


    (*res)[0] = func_CCodeGenTests_CArrayOutputs3_f1_exp0() - (_x_0);
")})));
end CArrayOutputs3;


model CArrayOutputs4
 function f1
  output Real o = 0;
  protected Real x[2];
  protected Real y;
 algorithm
  (x,y) := f2();
 end f1;
 
 function f2
  output Real o1[2] = {1,2};
  output Real o2 = 3;
 algorithm
 end f2;
 
 Real x = f1();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayOutputs4",
            description="C code generation: array outputs from functions: function call statement",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayOutputs4_f1_def0(jmi_real_t* o_o);
jmi_real_t func_CCodeGenTests_CArrayOutputs4_f1_exp0();
void func_CCodeGenTests_CArrayOutputs4_f2_def1(jmi_array_t* o1_a, jmi_real_t* o2_o);

void func_CCodeGenTests_CArrayOutputs4_f1_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, x_a, 2, 1)
    JMI_DEF(REA, y_v)
    o_v = 0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, x_a, 2, 1, 2)
    func_CCodeGenTests_CArrayOutputs4_f2_def1(x_a, &y_v);
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayOutputs4_f1_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CArrayOutputs4_f1_def0(&o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs4_f2_def1(jmi_array_t* o1_a, jmi_real_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, o1_an, 2, 1)
    JMI_DEF(REA, o2_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (o1_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, o1_an, 2, 1, 2)
        o1_a = o1_an;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_a, 1) = 1;
    jmi_array_ref_1(temp_1_a, 2) = 2;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(o1_a, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    o2_v = 3;
    JMI_RET(GEN, o2_o, o2_v)
    JMI_DYNAMIC_FREE()
    return;
}


    (*res)[0] = func_CCodeGenTests_CArrayOutputs4_f1_exp0() - (_x_0);
")})));
end CArrayOutputs4;


model CArrayOutputs5
 function f1
  input Real i[2];
  output Real o = 0;
  protected Real x[2];
  protected Real y;
 algorithm
  (x, y) := f2(i);
 end f1;
 
 function f2
  input Real i[2];
  output Real o1[2] = i;
  output Real o2 = 3;
 algorithm
 end f2;
 
 Real x = f1({1,2});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CArrayOutputs5",
        description="C code generation: array outputs from functions: passing input array",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CArrayOutputs5_f1_def0(jmi_array_t* i_a, jmi_real_t* o_o);
jmi_real_t func_CCodeGenTests_CArrayOutputs5_f1_exp0(jmi_array_t* i_a);
void func_CCodeGenTests_CArrayOutputs5_f2_def1(jmi_array_t* i_a, jmi_array_t* o1_a, jmi_real_t* o2_o);

void func_CCodeGenTests_CArrayOutputs5_f1_def0(jmi_array_t* i_a, jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, x_a, 2, 1)
    JMI_DEF(REA, y_v)
    o_v = 0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, x_a, 2, 1, 2)
    func_CCodeGenTests_CArrayOutputs5_f2_def1(i_a, x_a, &y_v);
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CArrayOutputs5_f1_exp0(jmi_array_t* i_a) {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CArrayOutputs5_f1_def0(i_a, &o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs5_f2_def1(jmi_array_t* i_a, jmi_array_t* o1_a, jmi_real_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, o1_an, 2, 1)
    JMI_DEF(REA, o2_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (o1_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, o1_an, 2, 1, 2)
        o1_a = o1_an;
    }
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(o1_a, i1_0i) = jmi_array_val_1(i_a, i1_0i);
    }
    o2_v = 3;
    JMI_RET(GEN, o2_o, o2_v)
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    (*res)[0] = func_CCodeGenTests_CArrayOutputs5_f1_exp0(tmp_1) - (_x_0);
")})));
end CArrayOutputs5;



model CAbsTest1
 Real x = abs(y);
 Real y = -2;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CAbsTest1",
            description="C code generation for abs() operator",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = jmi_abs(_y_1) - (_x_0);
    (*res)[1] = -2 - (_y_1);
")})));
end CAbsTest1;



model CUnknownArray1
 function f
  input Real a[:];
  input Real b[size(a,1)];
  output Real o[size(a,1)] = a + b;
 algorithm
 end f;
 
 Real x[2] = f({1,2}, {3,4});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray1",
        description="C code generation for unknown array sizes: basic test",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray1_f_def0(jmi_array_t* a_a, jmi_array_t* b_a, jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, o_an, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, o_an, jmi_array_size(a_a, 0), 1, jmi_array_size(a_a, 0))
        o_a = o_an;
    }
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(a_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(o_a, i1_0i) = jmi_array_val_1(a_a, i1_0i) + jmi_array_val_1(b_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray1;


model CUnknownArray2
	function f
		input Real x[:,2];
		output Real y[size(x, 1), 2];
	algorithm
		y := x * {{1, 2}, {3, 4}};
	end f;

	Real x[3,2] = f({{5,6},{7,8},{9,0}});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray2",
        description="C code generation for unknown array sizes: array constructor * array with unknown size",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray2_f_def0(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, y_an, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_1_a, -1, 2)
    JMI_DEF(REA, temp_2_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_3_a, 4, 2)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_4_a, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_5_a, 2, 1)
    jmi_real_t i3_0i;
    jmi_int_t i3_0ie;
    jmi_int_t i3_0in;
    jmi_real_t i3_1i;
    jmi_int_t i3_1ie;
    jmi_int_t i3_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    jmi_real_t i2_3i;
    jmi_int_t i2_3ie;
    jmi_int_t i2_3in;
    jmi_real_t i3_4i;
    jmi_int_t i3_4ie;
    jmi_int_t i3_4in;
    jmi_real_t i1_5i;
    jmi_int_t i1_5ie;
    jmi_int_t i1_5in;
    jmi_real_t i2_6i;
    jmi_int_t i2_6ie;
    jmi_int_t i2_6in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, y_an, jmi_array_size(x_a, 0) * 2, 2, jmi_array_size(x_a, 0), 2)
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, temp_1_a, jmi_array_size(x_a, 0) * 2, 2, jmi_array_size(x_a, 0), 2)
    JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, temp_3_a, 4, 2, 2, 2)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_4_a, 2, 1, 2)
    jmi_array_ref_1(temp_4_a, 1) = 1;
    jmi_array_ref_1(temp_4_a, 2) = 2;
    i3_0in = 0;
    i3_0ie = floor((2) - (1));
    for (i3_0i = 1; i3_0in <= i3_0ie; i3_0i = 1 + (++i3_0in)) {
        jmi_array_ref_2(temp_3_a, 1, i3_0i) = jmi_array_val_1(temp_4_a, i3_0i);
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_5_a, 2, 1, 2)
    jmi_array_ref_1(temp_5_a, 1) = 3;
    jmi_array_ref_1(temp_5_a, 2) = 4;
    i3_1in = 0;
    i3_1ie = floor((2) - (1));
    for (i3_1i = 1; i3_1in <= i3_1ie; i3_1i = 1 + (++i3_1in)) {
        jmi_array_ref_2(temp_3_a, 2, i3_1i) = jmi_array_val_1(temp_5_a, i3_1i);
    }
    i1_2in = 0;
    i1_2ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        i2_3in = 0;
        i2_3ie = floor((2) - (1));
        for (i2_3i = 1; i2_3in <= i2_3ie; i2_3i = 1 + (++i2_3in)) {
            temp_2_v = 0.0;
            i3_4in = 0;
            i3_4ie = floor((2) - (1));
            for (i3_4i = 1; i3_4in <= i3_4ie; i3_4i = 1 + (++i3_4in)) {
                temp_2_v = temp_2_v + jmi_array_val_2(x_a, i1_2i, i3_4i) * jmi_array_val_2(temp_3_a, i3_4i, i2_3i);
            }
            jmi_array_ref_2(temp_1_a, i1_2i, i2_3i) = temp_2_v;
        }
    }
    i1_5in = 0;
    i1_5ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_5i = 1; i1_5in <= i1_5ie; i1_5i = 1 + (++i1_5in)) {
        i2_6in = 0;
        i2_6ie = floor((2) - (1));
        for (i2_6i = 1; i2_6in <= i2_6ie; i2_6i = 1 + (++i2_6in)) {
            jmi_array_ref_2(y_a, i1_5i, i2_6i) = jmi_array_val_2(temp_1_a, i1_5i, i2_6i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray2;


// This tests for a bug that wasn't exposed until C code generation
model CUnknownArray3
    function f1
        input Real[:] x1;
        output Real y1;
    algorithm
        y1 := f3(f2(x1));
    end f1;
    
    function f2
        input Real[:] x2;
        output Real[size(x2,1)] y2;
    algorithm
        y2 := x2;
    end f2;
    
    function f3
        input Real[:] x3;
        output Real y3;
    algorithm
        y3 := sum(x3);
    end f3;
    
    Real x = f1({1,2});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray3",
        description="Passing array return value of unknown size directly to other function",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray3_f1_def0(jmi_array_t* x1_a, jmi_real_t* y1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y1_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 1)
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, tmp_1, jmi_array_size(x1_a, 0), 1, jmi_array_size(x1_a, 0))
    func_CCodeGenTests_CUnknownArray3_f2_def2(x1_a, tmp_1);
    y1_v = func_CCodeGenTests_CUnknownArray3_f3_exp1(tmp_1);
    JMI_RET(GEN, y1_o, y1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CUnknownArray3_f1_exp0(jmi_array_t* x1_a) {
    JMI_DEF(REA, y1_v)
    func_CCodeGenTests_CUnknownArray3_f1_def0(x1_a, &y1_v);
    return y1_v;
}

void func_CCodeGenTests_CUnknownArray3_f3_def1(jmi_array_t* x3_a, jmi_real_t* y3_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y3_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    temp_1_v = 0.0;
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(x3_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(x3_a, i1_0i);
    }
    y3_v = temp_1_v;
    JMI_RET(GEN, y3_o, y3_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CUnknownArray3_f3_exp1(jmi_array_t* x3_a) {
    JMI_DEF(REA, y3_v)
    func_CCodeGenTests_CUnknownArray3_f3_def1(x3_a, &y3_v);
    return y3_v;
}

void func_CCodeGenTests_CUnknownArray3_f2_def2(jmi_array_t* x2_a, jmi_array_t* y2_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, y2_an, -1, 1)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    if (y2_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, y2_an, jmi_array_size(x2_a, 0), 1, jmi_array_size(x2_a, 0))
        y2_a = y2_an;
    }
    i1_1in = 0;
    i1_1ie = floor((jmi_array_size(x2_a, 0)) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(y2_a, i1_1i) = jmi_array_val_1(x2_a, i1_1i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray3;

model CUnknownArray4
function f
	input Real[:] i;
	output Real[size(i,1)] o;
	output Real dummy = 1;
algorithm
	o := i;
end f;

function fw
	input Integer[:] i;
	output Real[size(i,1)] o;
	output Real dummy = 1;
algorithm
	o[{1,3,5}] := {1,1,1};
	(o[i],) := f(o[i]);
end fw;

Real[3] ae;
equation
	(ae[{3,2,1}],) = fw({1,2,3});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray4",
        description="Unknown size expression",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray4_fw_def0(jmi_array_t* i_a, jmi_array_t* o_a, jmi_real_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, o_an, -1, 1)
    JMI_DEF(REA, dummy_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_2_a, 3, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_3_a, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_4_a, -1, 1)
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
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, o_an, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
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
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_3_a, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
    i1_1in = 0;
    i1_1ie = floor((jmi_array_size(i_a, 0)) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(temp_3_a, i1_1i) = jmi_array_val_1(o_a, jmi_array_val_1(i_a, i1_1i));
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_4_a, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
    func_CCodeGenTests_CUnknownArray4_f_def1(temp_3_a, temp_4_a, NULL);
    i1_2in = 0;
    i1_2ie = floor((jmi_array_size(i_a, 0)) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        jmi_array_ref_1(o_a, jmi_array_ref_1(i_a, i1_2i)) = jmi_array_val_1(temp_4_a, i1_2i);
    }
    JMI_RET(GEN, dummy_o, dummy_v)
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_CUnknownArray4_f_def1(jmi_array_t* i_a, jmi_array_t* o_a, jmi_real_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, o_an, -1, 1)
    JMI_DEF(REA, dummy_v)
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, o_an, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
        o_a = o_an;
    }
    dummy_v = 1;
    i1_3in = 0;
    i1_3ie = floor((jmi_array_size(i_a, 0)) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        jmi_array_ref_1(o_a, i1_3i) = jmi_array_val_1(i_a, i1_3i);
    }
    JMI_RET(GEN, dummy_o, dummy_v)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray4;

model CUnknownArray5
function f
	input Integer[:] i1;
	input Integer[size(i1,1)] i2;
	input Real[:,:] x;
	output Real[size(i1,1),size(i1,1)] y;
algorithm
	y := transpose([x[i1,i2]]);
end f;

Real[2,2] ae = f({1,2},{2,1},{{3,4},{5,6},{7,8}});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray5",
        description="Unknown size slice of matrix in transpose",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray5_f_def0(jmi_array_t* i1_a, jmi_array_t* i2_a, jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, y_an, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_1_a, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_2_a, -1, 2)
    jmi_real_t i5_0i;
    jmi_int_t i5_0ie;
    jmi_int_t i5_0in;
    jmi_real_t i6_1i;
    jmi_int_t i6_1ie;
    jmi_int_t i6_1in;
    jmi_real_t i3_2i;
    jmi_int_t i3_2ie;
    jmi_int_t i3_2in;
    jmi_real_t i4_3i;
    jmi_int_t i4_3ie;
    jmi_int_t i4_3in;
    jmi_real_t i3_4i;
    jmi_int_t i3_4ie;
    jmi_int_t i3_4in;
    jmi_real_t i4_5i;
    jmi_int_t i4_5ie;
    jmi_int_t i4_5in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, y_an, jmi_array_size(i1_a, 0) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i1_a, 0))
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, temp_1_a, jmi_array_size(i1_a, 0) * jmi_array_size(i2_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i2_a, 0))
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, temp_2_a, jmi_array_size(i1_a, 0) * jmi_array_size(i2_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i2_a, 0))
    i5_0in = 0;
    i5_0ie = floor((jmi_array_size(i1_a, 0)) - (1));
    for (i5_0i = 1; i5_0in <= i5_0ie; i5_0i = 1 + (++i5_0in)) {
        i6_1in = 0;
        i6_1ie = floor((jmi_array_size(i2_a, 0)) - (1));
        for (i6_1i = 1; i6_1in <= i6_1ie; i6_1i = 1 + (++i6_1in)) {
            jmi_array_ref_2(temp_2_a, i5_0i, i6_1i) = jmi_array_val_2(x_a, jmi_array_val_1(i1_a, i5_0i), jmi_array_val_1(i2_a, i6_1i));
        }
    }
    i3_2in = 0;
    i3_2ie = floor((jmi_array_size(i1_a, 0)) - (1));
    for (i3_2i = 1; i3_2in <= i3_2ie; i3_2i = 1 + (++i3_2in)) {
        i4_3in = 0;
        i4_3ie = floor((jmi_array_size(i2_a, 0)) - (1));
        for (i4_3i = 1; i4_3in <= i4_3ie; i4_3i = 1 + (++i4_3in)) {
            jmi_array_ref_2(temp_1_a, i3_2i, i4_3i) = jmi_array_val_2(temp_2_a, i3_2i, i4_3i);
        }
    }
    i3_4in = 0;
    i3_4ie = floor((jmi_array_size(i1_a, 0)) - (1));
    for (i3_4i = 1; i3_4in <= i3_4ie; i3_4i = 1 + (++i3_4in)) {
        i4_5in = 0;
        i4_5ie = floor((jmi_array_size(i1_a, 0)) - (1));
        for (i4_5i = 1; i4_5in <= i4_5ie; i4_5i = 1 + (++i4_5in)) {
            jmi_array_ref_2(y_a, i3_4i, i4_5i) = jmi_array_val_2(temp_1_a, i4_5i, i3_4i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray5;

model CUnknownArray6
function f
    input Integer[:] i1;
    input Integer[size(i1,1)] i2;
    input Real[:,:] x;
    output Real[size(i1,1) * 2 - 2,size(i1,1)] y;
algorithm
    y := transpose([x[i1,i2]]);
end f;

Real[2,2] ae = f({1,2},{2,1},{{3,4},{5,6},{7,8}});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray6",
        description="Multiple unknown size outputs with low precedence exp",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray6_f_def0(jmi_array_t* i1_a, jmi_array_t* i2_a, jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, y_an, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_1_a, -1, 2)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_2_a, -1, 2)
    jmi_real_t i5_0i;
    jmi_int_t i5_0ie;
    jmi_int_t i5_0in;
    jmi_real_t i6_1i;
    jmi_int_t i6_1ie;
    jmi_int_t i6_1in;
    jmi_real_t i3_2i;
    jmi_int_t i3_2ie;
    jmi_int_t i3_2in;
    jmi_real_t i4_3i;
    jmi_int_t i4_3ie;
    jmi_int_t i4_3in;
    jmi_real_t i3_4i;
    jmi_int_t i3_4ie;
    jmi_int_t i3_4in;
    jmi_real_t i4_5i;
    jmi_int_t i4_5ie;
    jmi_int_t i4_5in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, y_an, (jmi_array_size(i1_a, 0) * 2 - 2) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0) * 2 - 2, jmi_array_size(i1_a, 0))
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, temp_1_a, jmi_array_size(i1_a, 0) * jmi_array_size(i2_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i2_a, 0))
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, temp_2_a, jmi_array_size(i1_a, 0) * jmi_array_size(i2_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i2_a, 0))
    i5_0in = 0;
    i5_0ie = floor((jmi_array_size(i1_a, 0)) - (1));
    for (i5_0i = 1; i5_0in <= i5_0ie; i5_0i = 1 + (++i5_0in)) {
        i6_1in = 0;
        i6_1ie = floor((jmi_array_size(i2_a, 0)) - (1));
        for (i6_1i = 1; i6_1in <= i6_1ie; i6_1i = 1 + (++i6_1in)) {
            jmi_array_ref_2(temp_2_a, i5_0i, i6_1i) = jmi_array_val_2(x_a, jmi_array_val_1(i1_a, i5_0i), jmi_array_val_1(i2_a, i6_1i));
        }
    }
    i3_2in = 0;
    i3_2ie = floor((jmi_array_size(i1_a, 0)) - (1));
    for (i3_2i = 1; i3_2in <= i3_2ie; i3_2i = 1 + (++i3_2in)) {
        i4_3in = 0;
        i4_3ie = floor((jmi_array_size(i2_a, 0)) - (1));
        for (i4_3i = 1; i4_3in <= i4_3ie; i4_3i = 1 + (++i4_3in)) {
            jmi_array_ref_2(temp_1_a, i3_2i, i4_3i) = jmi_array_val_2(temp_2_a, i3_2i, i4_3i);
        }
    }
    i3_4in = 0;
    i3_4ie = floor((jmi_array_size(i1_a, 0) * 2 - 2) - (1));
    for (i3_4i = 1; i3_4in <= i3_4ie; i3_4i = 1 + (++i3_4in)) {
        i4_5in = 0;
        i4_5ie = floor((jmi_array_size(i1_a, 0)) - (1));
        for (i4_5i = 1; i4_5in <= i4_5ie; i4_5i = 1 + (++i4_5in)) {
            jmi_array_ref_2(y_a, i3_4i, i4_5i) = jmi_array_val_2(temp_1_a, i4_5i, i3_4i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray6;

model CUnknownArray7
    record R1
        R2[1] x;
    end R1;
    record R2
        Real[1] y;
    end R2;
    function f
        input Integer m;
        output R1[m,m] o;
    algorithm
        for i in 1:m loop
            o[i,:] := {R1({R2({i*j})}) for j in 1:m};
        end for;
    end f;
    
    R1[1,1] c = f(1);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray7",
        description="Unknown size record array",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray7_f_def0(jmi_real_t m_v, R1_1_ra* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, R1_1_r, R1_1_ra, o_an, -1, 2)
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_1_max)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(REA, tmp_2_max)
    JMI_ARR(HEAP, R1_1_r, R1_1_ra, temp_1_a, -1, 1)
    JMI_ARR(STACK, R2_0_r, R2_0_ra, temp_2_a, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_3_a, 1, 1)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i2_2i;
    jmi_int_t i2_2ie;
    jmi_int_t i2_2in;
    jmi_real_t i2_3i;
    jmi_int_t i2_3ie;
    jmi_int_t i2_3in;
    jmi_real_t i3_4i;
    jmi_int_t i3_4ie;
    jmi_int_t i3_4in;
    jmi_real_t i1_5i;
    jmi_int_t i1_5ie;
    jmi_int_t i1_5in;
    jmi_real_t i2_6i;
    jmi_int_t i2_6ie;
    jmi_int_t i2_6in;
    jmi_real_t i3_7i;
    jmi_int_t i3_7ie;
    jmi_int_t i3_7in;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, R1_1_r, R1_1_ra, o_an, m_v * m_v, 2, m_v, m_v)
        tmp_1_max = m_v * m_v + 1;
        for (tmp_1 = 1; tmp_1 < tmp_1_max; tmp_1++) {
            JMI_ARRAY_INIT_1(HEAP, R2_0_r, R2_0_ra, jmi_array_rec_1(o_an, tmp_1)->x, 1, 1, 1)
            tmp_2_max = 1 + 1;
            for (tmp_2 = 1; tmp_2 < tmp_2_max; tmp_2++) {
                JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, jmi_array_rec_1(jmi_array_rec_1(o_an, tmp_1)->x, tmp_2)->y, 1, 1, 1)
            }
        }
        o_a = o_an;
    }
    i_0in = 0;
    i_0ie = floor((m_v) - (1));
    for (i_0i = 1; i_0in <= i_0ie; i_0i = 1 + (++i_0in)) {
        JMI_ARRAY_INIT_1(HEAP, R1_1_r, R1_1_ra, temp_1_a, jmi_max(m_v, 0.0), 1, jmi_max(m_v, 0.0))
        i1_1in = 0;
        i1_1ie = floor((jmi_max(m_v, 0.0)) - (1));
        for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
            JMI_ARRAY_INIT_1(STACK, R2_0_r, R2_0_ra, temp_2_a, 1, 1, 1)
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_3_a, 1, 1, 1)
            jmi_array_ref_1(temp_3_a, 1) = i_0i * i1_1i;
            JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, jmi_array_rec_1(temp_2_a, 1)->y, 1, 1, 1)
            i2_2in = 0;
            i2_2ie = floor((1) - (1));
            for (i2_2i = 1; i2_2in <= i2_2ie; i2_2i = 1 + (++i2_2in)) {
                jmi_array_ref_1(jmi_array_rec_1(temp_2_a, 1)->y, i2_2i) = jmi_array_val_1(temp_3_a, i2_2i);
            }
            JMI_ARRAY_INIT_1(HEAP, R2_0_r, R2_0_ra, jmi_array_rec_1(temp_1_a, i1_1i)->x, 1, 1, 1)
            i2_3in = 0;
            i2_3ie = floor((1) - (1));
            for (i2_3i = 1; i2_3in <= i2_3ie; i2_3i = 1 + (++i2_3in)) {
                JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i1_1i)->x, i2_3i)->y, 1, 1, 1)
                i3_4in = 0;
                i3_4ie = floor((1) - (1));
                for (i3_4i = 1; i3_4in <= i3_4ie; i3_4i = 1 + (++i3_4in)) {
                    jmi_array_ref_1(jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i1_1i)->x, i2_3i)->y, i3_4i) = jmi_array_val_1(jmi_array_rec_1(temp_2_a, i2_3i)->y, i3_4i);
                }
            }
        }
        i1_5in = 0;
        i1_5ie = floor((m_v) - (1));
        for (i1_5i = 1; i1_5in <= i1_5ie; i1_5i = 1 + (++i1_5in)) {
            i2_6in = 0;
            i2_6ie = floor((1) - (1));
            for (i2_6i = 1; i2_6in <= i2_6ie; i2_6i = 1 + (++i2_6in)) {
                i3_7in = 0;
                i3_7ie = floor((1) - (1));
                for (i3_7i = 1; i3_7in <= i3_7ie; i3_7i = 1 + (++i3_7in)) {
                    jmi_array_ref_1(jmi_array_rec_1(jmi_array_rec_2(o_a, i_0i, i1_5i)->x, i2_6i)->y, i3_7i) = jmi_array_val_1(jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i1_5i)->x, i2_6i)->y, i3_7i);
                }
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
end CUnknownArray7;

model CUnknownArray8
    function l
        input Real[:] x;
        output Real y = sum(x);
        algorithm
    end l;
    function f
      input Real a[:];
      input Real b[size(a, 1)];
      output Real u[size(a, 1)];
    algorithm
      u := a*l(a + b);
    end f;
    Real[1] y = f({time}, {time});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray8",
        description="Unknown size record array",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray8_f_def0(jmi_array_t* a_a, jmi_array_t* b_a, jmi_array_t* u_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, u_an, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_1_a, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    if (u_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, u_an, jmi_array_size(a_a, 0), 1, jmi_array_size(a_a, 0))
        u_a = u_an;
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_1_a, jmi_array_size(a_a, 0), 1, jmi_array_size(a_a, 0))
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(a_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(temp_1_a, i1_0i) = jmi_array_val_1(a_a, i1_0i) + jmi_array_val_1(b_a, i1_0i);
    }
    i1_1in = 0;
    i1_1ie = floor((jmi_array_size(a_a, 0)) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(u_a, i1_1i) = jmi_array_val_1(a_a, i1_1i) * func_CCodeGenTests_CUnknownArray8_l_exp1(temp_1_a);
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_CUnknownArray8_l_def1(jmi_array_t* x_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    temp_1_v = 0.0;
    i1_2in = 0;
    i1_2ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(x_a, i1_2i);
    }
    y_v = temp_1_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CUnknownArray8_l_exp1(jmi_array_t* x_a) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_CUnknownArray8_l_def1(x_a, &y_v);
    return y_v;
}

")})));
end CUnknownArray8;

model CUnknownArray9
    function f
        input Integer n;
        output Real[size(ba,1)] ab = ba;
        output Real[n] ba = ones(n);
      algorithm
    end f;
    Real[2] x = f(2);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray9",
        description="Sorted initialization",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray9_f_def0(jmi_real_t n_v, jmi_array_t* ab_a, jmi_array_t* ba_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, ab_an, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, ba_an, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    if (ba_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, ba_an, n_v, 1, n_v)
        ba_a = ba_an;
    }
    if (ab_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, ab_an, jmi_array_size(ba_a, 0), 1, jmi_array_size(ba_a, 0))
        ab_a = ab_an;
    }
    i1_0in = 0;
    i1_0ie = floor((n_v) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(ba_a, i1_0i) = 1;
    }
    i1_1in = 0;
    i1_1ie = floor((jmi_array_size(ba_a, 0)) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_ref_1(ab_a, i1_1i) = jmi_array_val_1(ba_a, i1_1i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray9;

model CUnknownArray10
    function f
        input Integer n;
        Real t1[size(t3,1) + size(ab,1)];
        output Real[size(ba,1)] ab;
        Real t2[size(ba,1)];
        output Real[n] ba;
        Real t3[n];
      algorithm
    end f;
    Real[2] x = f(2);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray10",
            description="Sorted initialization",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray10_f_def0(jmi_real_t n_v, jmi_array_t* ab_a, jmi_array_t* ba_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, t1_a, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, ab_an, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, t2_a, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, ba_an, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, t3_a, -1, 1)
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, t3_a, n_v, 1, n_v)
    if (ba_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, ba_an, n_v, 1, n_v)
        ba_a = ba_an;
    }
    if (ab_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, ab_an, jmi_array_size(ba_a, 0), 1, jmi_array_size(ba_a, 0))
        ab_a = ab_an;
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, t1_a, (jmi_array_size(t3_a, 0) + jmi_array_size(ab_a, 0)), 1, jmi_array_size(t3_a, 0) + jmi_array_size(ab_a, 0))
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, t2_a, jmi_array_size(ba_a, 0), 1, jmi_array_size(ba_a, 0))
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray10;

model CUnknownArray11
    record R
        Real[:] x;
    end R;
    
    function f
        R r(x=1:2);
        output Real x = r.x[1];
        algorithm
    end f;
    
    Real x = f();
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray11",
        description="Sorted initialization",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray11_f_def0(jmi_real_t* x_o) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, r_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_DEF(REA, x_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    r_v->x = tmp_1;i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(r_v->x, i1_0i) = i1_0i;
    }
    x_v = jmi_array_val_1(r_v->x, 1);
    JMI_RET(GEN, x_o, x_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CUnknownArray11_f_exp0() {
    JMI_DEF(REA, x_v)
    func_CCodeGenTests_CUnknownArray11_f_def0(&x_v);
    return x_v;
}

")})));
end CUnknownArray11;

model CUnknownArray13
    function f
        input Real[:] x;
        output Real[size(x,1)*2] y;
    algorithm
        for i in 1:size(x,1) loop
            y[:] := cat(1,x,1:i);
        end for;
        annotation(Inline=false);
    end f;
    
    Real[:] y = f({time});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CUnknownArray13",
        description="Size depending on for index",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CUnknownArray13_f_def0(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, y_an, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_1_a, -1, 1)
    jmi_real_t i_0i;
    jmi_int_t i_0ie;
    jmi_int_t i_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, y_an, jmi_array_size(x_a, 0) * 2, 1, jmi_array_size(x_a, 0) * 2)
        y_a = y_an;
    }
    i_0in = 0;
    i_0ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i_0i = 1; i_0in <= i_0ie; i_0i = 1 + (++i_0in)) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_1_a, (jmi_array_size(x_a, 0) + jmi_max(i_0i, 0.0)), 1, jmi_array_size(x_a, 0) + jmi_max(i_0i, 0.0))
        i1_1in = 0;
        i1_1ie = floor((jmi_array_size(x_a, 0)) - (1));
        for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
            jmi_array_ref_1(temp_1_a, i1_1i) = jmi_array_val_1(x_a, i1_1i);
        }
        i1_2in = 0;
        i1_2ie = floor((jmi_max(i_0i, 0.0)) - (1));
        for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
            jmi_array_ref_1(temp_1_a, i1_2i + jmi_array_size(x_a, 0)) = i1_2i;
        }
        i1_3in = 0;
        i1_3ie = floor((jmi_array_size(x_a, 0) * 2) - (1));
        for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
            jmi_array_ref_1(y_a, i1_3i) = jmi_array_val_1(temp_1_a, i1_3i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray13;

model CRecordDecl1
    record A
        Real a;
        Real b;
    end A;
    function F
        input A i;
        output Real o;
    algorithm
        o := i.a + i.b;
        annotation(Inline=false);
    end F;
 
    Real r = F(A(time, time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl1",
            description="C code generation for records: structs: basic test",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_records$",
            generatedCode="
typedef struct A_0_r_ A_0_r;
struct A_0_r_ {
    jmi_real_t a;
    jmi_real_t b;
};
JMI_ARRAY_TYPE(A_0_r, A_0_ra)

typedef struct A_0_r_ext_ A_0_r_ext;
struct A_0_r_ext_ {
    jmi_real_t a;
    jmi_real_t b;
};

")})));
end CRecordDecl1;


model CRecordDecl2
    record A
        Real a;
        B b;
    end A;

    record B
        Real c;
    end B;

    function F
        input A i;
        output Real o;
    algorithm
        o := i.a + i.b.c;
        annotation(Inline=false);
    end F;
 
    Real r = F(A(time, B(time)));


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl2",
            description="C code generation for records: structs: nested records",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_records$",
            generatedCode="
typedef struct B_0_r_ B_0_r;
struct B_0_r_ {
    jmi_real_t c;
};
JMI_ARRAY_TYPE(B_0_r, B_0_ra)

typedef struct B_0_r_ext_ B_0_r_ext;
struct B_0_r_ext_ {
    jmi_real_t c;
};

typedef struct A_1_r_ A_1_r;
struct A_1_r_ {
    jmi_real_t a;
    B_0_r* b;
};
JMI_ARRAY_TYPE(A_1_r, A_1_ra)

typedef struct A_1_r_ext_ A_1_r_ext;
struct A_1_r_ext_ {
    jmi_real_t a;
    B_0_r_ext b;
};

")})));
end CRecordDecl2;


model CRecordDecl3
    record A
        Real a[2];
    end A;
    function F
        input A i;
        output Real o;
    algorithm
        o := i.a[1] + i.a[2];
        annotation(Inline=false);
    end F;
 
    Real r = F(A({time, time}));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl3",
            description="C code generation for records: structs: array in record",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_records$",
            generatedCode="
typedef struct A_0_r_ A_0_r;
struct A_0_r_ {
    jmi_array_t* a;
};
JMI_ARRAY_TYPE(A_0_r, A_0_ra)


")})));
end CRecordDecl3;


model CRecordDecl4
    record A
        Real a;
        B b[2];
    end A;

    record B
        Real c;
    end B;
    function F
        input A i;
        output Real o;
    algorithm
        o := i.a + i.b[1].c + i.b[2].c;
        annotation(Inline=false);
    end F;
 
    Real r = F(A(time, {B(time), B(time)}));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl4",
            description="C code generation for records: structs: array of records",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_records$",
            generatedCode="
typedef struct B_0_r_ B_0_r;
struct B_0_r_ {
    jmi_real_t c;
};
JMI_ARRAY_TYPE(B_0_r, B_0_ra)

typedef struct B_0_r_ext_ B_0_r_ext;
struct B_0_r_ext_ {
    jmi_real_t c;
};

typedef struct A_1_r_ A_1_r;
struct A_1_r_ {
    jmi_real_t a;
    B_0_ra* b;
};
JMI_ARRAY_TYPE(A_1_r, A_1_ra)


")})));
end CRecordDecl4;


model CRecordDecl5
  function f
  output Real o;
  protected A x = A(1,2);
 algorithm
  o := x.a;
 end f;
 
 record A
  Real a;
  Real b;
 end A;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl5",
            description="C code generation for records: declarations: basic test",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CRecordDecl5_f_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_RECORD_STATIC(A_0_r, x_v)
    x_v->a = 1;
    x_v->b = 2;
    o_v = x_v->a;
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl5_f_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl5_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl5;


model CRecordDecl6
 function f
  output Real o;
  protected A x = A(1, B(2));
 algorithm
  o := x.b.c;
 end f;
 
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl6",
            description="C code generation for records: declarations: nestled records",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CRecordDecl6_f_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_RECORD_STATIC(A_1_r, x_v)
    JMI_RECORD_STATIC(B_0_r, tmp_1)
    x_v->b = tmp_1;
    x_v->a = 1;
    x_v->b->c = 2;
    o_v = x_v->b->c;
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl6_f_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl6_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl6;


model CRecordDecl7
 function f
  output Real o;
  protected A x = A({1,2});
 algorithm
  o := x.a[1];
 end f;
 
 record A
  Real a[2];
 end A;
 
 Real x = f();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl7",
        description="C code generation for records: declarations: array in record",
        variability_propagation=false,
        inline_functions="none",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CRecordDecl7_f_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_RECORD_STATIC(A_0_r, x_v)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    x_v->a = tmp_1;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_a, 1) = 1;
    jmi_array_ref_1(temp_1_a, 2) = 2;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(x_v->a, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    o_v = jmi_array_val_1(x_v->a, 1);
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl7_f_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl7_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl7;


model CRecordDecl8
 function f
  output Real o;
  protected A x[3] = {A(1,{B(2),B(3)}),A(4,{B(5),B(6)}),A(7,{B(8),B(9)})};
 algorithm
  o := x[1].b[2].c;
 end f;
 
 record A
  Real a;
  B b[2];
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f();

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl8",
        description="C code generation for records: declarations: array of records",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_CRecordDecl8_f_def0(jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    JMI_ARR(STACK, A_1_r, A_1_ra, x_a, 3, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_1, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_3, 2, 1)
    JMI_ARR(STACK, A_1_r, A_1_ra, temp_1_a, 3, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, temp_2_a, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, temp_3_a, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, temp_4_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    JMI_ARRAY_INIT_1(STACK, A_1_r, A_1_ra, x_a, 3, 1, 3)
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_1, 2, 1, 2)
    jmi_array_rec_1(x_a, 1)->b = tmp_1;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
    jmi_array_rec_1(x_a, 2)->b = tmp_2;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
    jmi_array_rec_1(x_a, 3)->b = tmp_3;
    JMI_ARRAY_INIT_1(STACK, A_1_r, A_1_ra, temp_1_a, 3, 1, 3)
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, temp_2_a, 2, 1, 2)
    jmi_array_rec_1(temp_2_a, 1)->c = 2;
    jmi_array_rec_1(temp_2_a, 2)->c = 3;
    jmi_array_rec_1(temp_1_a, 1)->a = 1;
    jmi_array_rec_1(temp_1_a, 1)->b = temp_2_a;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, temp_3_a, 2, 1, 2)
    jmi_array_rec_1(temp_3_a, 1)->c = 5;
    jmi_array_rec_1(temp_3_a, 2)->c = 6;
    jmi_array_rec_1(temp_1_a, 2)->a = 4;
    jmi_array_rec_1(temp_1_a, 2)->b = temp_3_a;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, temp_4_a, 2, 1, 2)
    jmi_array_rec_1(temp_4_a, 1)->c = 8;
    jmi_array_rec_1(temp_4_a, 2)->c = 9;
    jmi_array_rec_1(temp_1_a, 3)->a = 7;
    jmi_array_rec_1(temp_1_a, 3)->b = temp_4_a;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_rec_1(x_a, i1_0i)->a = jmi_array_rec_1(temp_1_a, i1_0i)->a;
        i2_1in = 0;
        i2_1ie = floor((2) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_rec_1(jmi_array_rec_1(x_a, i1_0i)->b, i2_1i)->c = jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i1_0i)->b, i2_1i)->c;
        }
    }
    o_v = jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 2)->c;
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl8_f_exp0() {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl8_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl8;


model CRecordDecl9
 function f
  output A x = A(1,2);
 algorithm
 end f;
 
 record A
  Real a;
  Real b;
 end A;
 
 A x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl9",
            description="C code generation for records: outputs: basic test",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl9_f_def0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl9_f_def0(A_0_r* x_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(A_0_r, x_vn)
    if (x_v == NULL) {
        x_v = x_vn;
    }
    x_v->a = 1;
    x_v->b = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    func_CCodeGenTests_CRecordDecl9_f_def0(tmp_1);
    (*res)[0] = tmp_1->a - (_x_a_0);
    (*res)[1] = tmp_1->b - (_x_b_1);
")})));
end CRecordDecl9;


model CRecordDecl10
  function f
  output A x = A(1, B(2));
 algorithm
 end f;
 
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
 end B;
 
 A x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl10",
            description="C code generation for records: outputs: nested arrays",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl10_f_def0(A_1_r* x_v);

void func_CCodeGenTests_CRecordDecl10_f_def0(A_1_r* x_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(A_1_r, x_vn)
    JMI_RECORD_STATIC(B_0_r, tmp_1)
    if (x_v == NULL) {
        x_vn->b = tmp_1;
        x_v = x_vn;
    }
    x_v->a = 1;
    x_v->b->c = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_RECORD_STATIC(A_1_r, tmp_1)
    JMI_RECORD_STATIC(B_0_r, tmp_2)
    tmp_1->b = tmp_2;
    func_CCodeGenTests_CRecordDecl10_f_def0(tmp_1);
    (*res)[0] = tmp_1->a - (_x_a_0);
    (*res)[1] = tmp_1->b->c - (_x_b_c_1);
")})));
end CRecordDecl10;


model CRecordDecl11
  function f
  output A x = A({1,2});
 algorithm
 end f;
 
 record A
  Real a[2];
 end A;
 
 A x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl11",
            description="C code generation for records: outputs: array in record",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl11_f_def0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl11_f_def0(A_0_r* x_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(A_0_r, x_vn)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (x_v == NULL) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        x_vn->a = tmp_1;
        x_v = x_vn;
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, temp_1_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_a, 1) = 1;
    jmi_array_ref_1(temp_1_a, 2) = 2;
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(x_v->a, i1_0i) = jmi_array_val_1(temp_1_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    tmp_1->a = tmp_2;
    func_CCodeGenTests_CRecordDecl11_f_def0(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1->a, 1) - (_x_a_1_0);
    (*res)[1] = jmi_array_val_1(tmp_1->a, 2) - (_x_a_2_1);
")})));
end CRecordDecl11;


model CRecordDecl12
  function f
  output A x[3] = {A(1,{B(2),B(3)}),A(4,{B(5),B(6)}),A(7,{B(8),B(9)})};
 algorithm
 end f;
 
 record A
  Real a;
  B b[2];
 end A;
 
 record B
  Real c;
 end B;
 
 A x[3] = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl12",
            description="C code generation for records: outputs: array of records",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl12_f_def0(A_1_ra* x_a);

void func_CCodeGenTests_CRecordDecl12_f_def0(A_1_ra* x_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, A_1_r, A_1_ra, x_an, 3, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_1, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_3, 2, 1)
    JMI_ARR(STACK, A_1_r, A_1_ra, temp_1_a, 3, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, temp_2_a, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, temp_3_a, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, temp_4_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    if (x_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, A_1_r, A_1_ra, x_an, 3, 1, 3)
        JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_1, 2, 1, 2)
        jmi_array_rec_1(x_an, 1)->b = tmp_1;
        JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
        jmi_array_rec_1(x_an, 2)->b = tmp_2;
        JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
        jmi_array_rec_1(x_an, 3)->b = tmp_3;
        x_a = x_an;
    }
    JMI_ARRAY_INIT_1(STACK, A_1_r, A_1_ra, temp_1_a, 3, 1, 3)
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, temp_2_a, 2, 1, 2)
    jmi_array_rec_1(temp_2_a, 1)->c = 2;
    jmi_array_rec_1(temp_2_a, 2)->c = 3;
    jmi_array_rec_1(temp_1_a, 1)->a = 1;
    jmi_array_rec_1(temp_1_a, 1)->b = temp_2_a;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, temp_3_a, 2, 1, 2)
    jmi_array_rec_1(temp_3_a, 1)->c = 5;
    jmi_array_rec_1(temp_3_a, 2)->c = 6;
    jmi_array_rec_1(temp_1_a, 2)->a = 4;
    jmi_array_rec_1(temp_1_a, 2)->b = temp_3_a;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, temp_4_a, 2, 1, 2)
    jmi_array_rec_1(temp_4_a, 1)->c = 8;
    jmi_array_rec_1(temp_4_a, 2)->c = 9;
    jmi_array_rec_1(temp_1_a, 3)->a = 7;
    jmi_array_rec_1(temp_1_a, 3)->b = temp_4_a;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_rec_1(x_a, i1_0i)->a = jmi_array_rec_1(temp_1_a, i1_0i)->a;
        i2_1in = 0;
        i2_1ie = floor((2) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_rec_1(jmi_array_rec_1(x_a, i1_0i)->b, i2_1i)->c = jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i1_0i)->b, i2_1i)->c;
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STACK, A_1_r, A_1_ra, tmp_1, 3, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_3, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STACK, A_1_r, A_1_ra, tmp_1, 3, 1, 3)
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 1)->b = tmp_2;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 2)->b = tmp_3;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_4, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 3)->b = tmp_4;
    func_CCodeGenTests_CRecordDecl12_f_def0(tmp_1);
    (*res)[0] = jmi_array_rec_1(tmp_1, 1)->a - (_x_1_a_0);
    (*res)[1] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 1)->c - (_x_1_b_1_c_1);
    (*res)[2] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 2)->c - (_x_1_b_2_c_2);
    (*res)[3] = jmi_array_rec_1(tmp_1, 2)->a - (_x_2_a_3);
    (*res)[4] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 1)->c - (_x_2_b_1_c_4);
    (*res)[5] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 2)->c - (_x_2_b_2_c_5);
    (*res)[6] = jmi_array_rec_1(tmp_1, 3)->a - (_x_3_a_6);
    (*res)[7] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 1)->c - (_x_3_b_1_c_7);
    (*res)[8] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 2)->c - (_x_3_b_2_c_8);
")})));
end CRecordDecl12;


model CRecordDecl13
  function f
  output Real o;
  input A x;
 algorithm
  o := x.a;
 end f;
 
 record A
  Real a;
  Real b;
 end A;
 
 Real x = f(A(1,2));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl13",
        description="C code generation for records: inputs: basic test",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CRecordDecl13_f_def0(A_0_r* x_v, jmi_real_t* o_o);
jmi_real_t func_CCodeGenTests_CRecordDecl13_f_exp0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl13_f_def0(A_0_r* x_v, jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    o_v = x_v->a;
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl13_f_exp0(A_0_r* x_v) {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl13_f_def0(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    tmp_1->a = 1.0;
    tmp_1->b = 2.0;
    (*res)[0] = func_CCodeGenTests_CRecordDecl13_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl13;


model CRecordDecl14
 function f
  output Real o;
  input A x;
 algorithm
  o := x.b.c;
 end f;
 
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f(A(1, B(2)));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl14",
        description="C code generation for records: inputs: nested records",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CRecordDecl14_f_def0(A_1_r* x_v, jmi_real_t* o_o);
jmi_real_t func_CCodeGenTests_CRecordDecl14_f_exp0(A_1_r* x_v);

void func_CCodeGenTests_CRecordDecl14_f_def0(A_1_r* x_v, jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    o_v = x_v->b->c;
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl14_f_exp0(A_1_r* x_v) {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl14_f_def0(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_STATIC(A_1_r, tmp_1)
    JMI_RECORD_STATIC(B_0_r, tmp_2)
    tmp_1->b = tmp_2;
    tmp_1->a = 1.0;
    tmp_1->b->c = 2.0;
    (*res)[0] = func_CCodeGenTests_CRecordDecl14_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl14;


model CRecordDecl15
 function f
  output Real o;
  input A x;
 algorithm
  o := x.a[1];
 end f;
 
 record A
  Real a[2];
 end A;
 
 Real x = f(A({1,2}));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl15",
        description="C code generation for records: inputs: array in record",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CRecordDecl15_f_def0(A_0_r* x_v, jmi_real_t* o_o);
jmi_real_t func_CCodeGenTests_CRecordDecl15_f_exp0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl15_f_def0(A_0_r* x_v, jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    o_v = jmi_array_val_1(x_v->a, 1);
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl15_f_exp0(A_0_r* x_v) {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl15_f_def0(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    tmp_1->a = tmp_2;
    jmi_array_ref_1(tmp_1->a, 1) = 1.0;
    jmi_array_ref_1(tmp_1->a, 2) = 2.0;
    (*res)[0] = func_CCodeGenTests_CRecordDecl15_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl15;


model CRecordDecl16
 function f
  output Real o;
  input A x[3];
 algorithm
  o := x[1].b[2].c;
 end f;
 
 record A
  Real a;
  B b[2];
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f({A(1,{B(2),B(3)}),A(4,{B(5),B(6)}),A(7,{B(8),B(9)})});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl16",
        description="C code generation for records: inputs: array of records",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_CRecordDecl16_f_def0(A_1_ra* x_a, jmi_real_t* o_o);
jmi_real_t func_CCodeGenTests_CRecordDecl16_f_exp0(A_1_ra* x_a);

void func_CCodeGenTests_CRecordDecl16_f_def0(A_1_ra* x_a, jmi_real_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, o_v)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    i1_0in = 0;
    i1_0ie = floor((3) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        if (COND_EXP_EQ(2.0, jmi_array_size(jmi_array_rec_1(x_a, i1_0i)->b, 0), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
            jmi_assert_failed(\"Mismatching sizes in function 'CCodeGenTests.CRecordDecl16.f', component 'x[i1].b', dimension '1'\", JMI_ASSERT_ERROR);
        }
    }
    o_v = jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 2)->c;
    JMI_RET(GEN, o_o, o_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl16_f_exp0(A_1_ra* x_a) {
    JMI_DEF(REA, o_v)
    func_CCodeGenTests_CRecordDecl16_f_def0(x_a, &o_v);
    return o_v;
}


    JMI_ARR(STACK, A_1_r, A_1_ra, tmp_1, 3, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_3, 2, 1)
    JMI_ARR(STACK, B_0_r, B_0_ra, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STACK, A_1_r, A_1_ra, tmp_1, 3, 1, 3)
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 1)->b = tmp_2;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 2)->b = tmp_3;
    JMI_ARRAY_INIT_1(STACK, B_0_r, B_0_ra, tmp_4, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 3)->b = tmp_4;
    jmi_array_rec_1(tmp_1, 1)->a = 1.0;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 1)->c = 2.0;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 2)->c = 3.0;
    jmi_array_rec_1(tmp_1, 2)->a = 4.0;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 1)->c = 5.0;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 2)->c = 6.0;
    jmi_array_rec_1(tmp_1, 3)->a = 7.0;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 1)->c = 8.0;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 2)->c = 9.0;
    (*res)[0] = func_CCodeGenTests_CRecordDecl16_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl16;

model CRecordDecl17
    record A
    end A;
    function F
        input Real i;
        output Real o;
        A a;
    algorithm
        o := i + f2(a);
        annotation(Inline=false);
    end F;
    
    function f2
        input A a;
        output Integer i = 1;
        algorithm
    end f2;
 
    A x;
    Real r = F(time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl17",
            description="Test that a default field is created for an empty record.",
            template="$C_records$",
            generatedCode="
typedef struct A_0_r_ A_0_r;
struct A_0_r_ {
    char dummy;
};
JMI_ARRAY_TYPE(A_0_r, A_0_ra)

typedef struct A_0_r_ext_ A_0_r_ext;
struct A_0_r_ext_ {
    char dummy;
};

")})));
end CRecordDecl17;


model CRecordDecl18
	record A
		Real r;
	end A;
	
	model B
		C c;
	end B;
	
	model C
		A[2] a;
	end C;
	
	B b(c(a = {A(1), A(2)}));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl18",
            description="Array of records in subcomponent",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_variable_aliases$",
            generatedCode="
#define _b_c_a_1_r_0 ((*(jmi->z))[0])
#define _b_c_a_2_r_1 ((*(jmi->z))[1])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
")})));
end CRecordDecl18;


model CRecordDecl19
    record R
        Real[2] x;
    end R;
    
    parameter Real[2] p = {1,2};
    R r(x(start=p));
equation
    der(r.x) = p;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl19",
            description="Start value for array member of record",
            template="$C_DAE_initial_guess_equation_residuals$",
            generatedCode="
    (*res)[0] = _p_1_0 - _r_x_1_2;
    (*res)[1] = _p_2_1 - _r_x_2_3;
")})));
end CRecordDecl19;

model CRecordDecl20
    record R
        Real x1 = -1;
        constant Real y = 2;
        final parameter Real z = 3; 
        Real x2;
    end R;
    
    function f
        input R i;
        output Real o = i.x1;
        algorithm
    end f;
    
    Real r = f(R(time,time));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl20",
        description="Record constructor of record with unmodifiable components.",
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    tmp_1->x1 = _time;
    tmp_1->y = 2.0;
    tmp_1->z = 3.0;
    tmp_1->x2 = _time;
    _r_0 = func_CCodeGenTests_CRecordDecl20_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CRecordDecl20;

model CRecordDecl21
    type T = Real(min=1);

    record B
        Real x = time+1;
    end B;
    
    function f
        input B b;
        output Real x = b.x;
        algorithm
    end f;
    
    B b(redeclare T x = time + 2);
    Real x = f(b);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CRecordDecl21",
        description="Record with colon in name",
        inline_functions="none",
        template="
$C_records$
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
typedef struct b_0_r_ b_0_r;
struct b_0_r_ {
    jmi_real_t x;
};
JMI_ARRAY_TYPE(b_0_r, b_0_ra)

typedef struct b_0_r_ext_ b_0_r_ext;
struct b_0_r_ext_ {
    jmi_real_t x;
};


void func_CCodeGenTests_CRecordDecl21_f_def0(b_0_r* b_v, jmi_real_t* x_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, x_v)
    x_v = b_v->x;
    JMI_RET(GEN, x_o, x_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_CRecordDecl21_f_exp0(b_0_r* b_v) {
    JMI_DEF(REA, x_v)
    func_CCodeGenTests_CRecordDecl21_f_def0(b_v, &x_v);
    return x_v;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(b_0_r, tmp_1)
    _b_x_0 = _time + 2;
    tmp_1->x = _b_x_0;
    _x_1 = func_CCodeGenTests_CRecordDecl21_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CRecordDecl21;


model RemoveCopyright
    input Real dummy;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RemoveCopyright",
            description="Test that licence tag is filtered out",
            variability_propagation=false,
            template="/* test copyright blurb */ test",
            generatedCode="test"
 )})));
end RemoveCopyright;

model IntegerInFunc1
	function f
		input Integer i;
		input Real a[3];
		output Real x;
	algorithm
		x := a[i];
	end f;
	
	Real x[3] = {2.3, 4.2, 1.5};
	Real y = f(1, x);
	Real z = f(2, x);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerInFunc1",
            description="Using Integer variable in function",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_IntegerInFunc1_f_def0(jmi_real_t i_v, jmi_array_t* a_a, jmi_real_t* x_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, x_v)
    x_v = jmi_array_val_1(a_a, i_v);
    JMI_RET(GEN, x_o, x_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_IntegerInFunc1_f_exp0(jmi_real_t i_v, jmi_array_t* a_a) {
    JMI_DEF(REA, x_v)
    func_CCodeGenTests_IntegerInFunc1_f_def0(i_v, a_a, &x_v);
    return x_v;
}

")})));
end IntegerInFunc1;

model IfExpInParExp
  parameter Integer N = 2;
  parameter Real r[3] = array((if i<=N then 1. else 2.) for i in 1:3); 

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="IfExpInParExp",
        description="Test that relational expressions in parameter expressions are treated correctly",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_initial_dependent_parameter_residuals$",
        generatedCode="
    (*res)[0] = COND_EXP_EQ(COND_EXP_LE(1.0, _N_0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, 2.0) - (_r_1_1);
    (*res)[1] = COND_EXP_EQ(COND_EXP_LE(2.0, _N_0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, 2.0) - (_r_2_2);
    (*res)[2] = COND_EXP_EQ(COND_EXP_LE(3.0, _N_0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 1.0, 2.0) - (_r_3_3);
")})));
end IfExpInParExp;



model CIntegerExp1
	Real x = 10 ^ 4;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CIntegerExp1",
        description="Test that exponential expressions with integer exponents are properly transformed",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = (1.0 * (10) * (10) * (10) * (10)) - (_x_0);
")})));
end CIntegerExp1;


model CIntegerExp2
	Real x = 10 ^ (-4);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CIntegerExp2",
        description="Test that exponential expressions with integer exponents are properly transformed",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = (1.0 / (10) / (10) / (10) / (10)) - (_x_0);
")})));
end CIntegerExp2;


model CIntegerExp3
	Real x = 10 ^ 0;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CIntegerExp3",
            description="Test that exponential expressions with integer exponents are properly transformed",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = (1.0) - (_x_0);
")})));
end CIntegerExp3;


model CIntegerExp4
	Real x = 10 ^ 10;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CIntegerExp4",
        description="Test that exponential expressions with integer exponents are properly transformed",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = jmi_pow_equation(jmi, 10, 10, \"10 ^ 10\") - (_x_0);
")})));
end CIntegerExp4;


model CIntegerExp5
	Real x = 10 ^ (-10);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CIntegerExp5",
        description="Test that exponential expressions with integer exponents are properly transformed",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = jmi_pow_equation(jmi, 10, -10, \"10 ^ -10\") - (_x_0);
")})));
end CIntegerExp5;



model ModelIdentifierTest
	Real r = 1.0;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ModelIdentifierTest",
            description="",
            variability_propagation=false,
            template="$C_model_id$",
            generatedCode="CCodeGenTests_ModelIdentifierTest"
 )})));
end ModelIdentifierTest;

model DependentParametersWithScalingTest1
  record R
    Real x = 1;
  end R;

  function F
   input Real x;
   output Real y;
  algorithm
   y := 2*x;
  end F;

  function FR
   input R x;
   output R y;
  algorithm
   y := R(x.x*5);
  end FR;

  parameter Real p1 = 1;
  parameter Real p2 = 3*p1;
  parameter Real p3 = F(p2);
  parameter R r = R(3);
  parameter R r2 = r;
  parameter R r3 = FR(r2);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="DependentParametersWithScalingTest1",
        description="",
        enable_variable_scaling=true,
        variability_propagation=false,
        inline_functions="none",
        template="$C_model_init_eval_dependent_parameters$",
        generatedCode="

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_RECORD_STATIC(R_0_r, tmp_2)
    _p2_1 = (3 * (_p1_0*sf(0)))/sf(2);
    _r2_x_2 = ((_r_x_3*sf(1)))/sf(3);
    _p3_4 = (func_CCodeGenTests_DependentParametersWithScalingTest1_F_exp0((_p2_1*sf(2))))/sf(4);
    tmp_2->x = (_r2_x_2*sf(3));
    func_CCodeGenTests_DependentParametersWithScalingTest1_FR_def1(tmp_2, tmp_1);
    _r3_x_5 = (tmp_1->x)/sf(5);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end DependentParametersWithScalingTest1;

package WhenTests

model WhenTest1
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true); 
equation
der(xx) = -x; 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when {x > 2} then 
z = false; 
end when; 
when (time>1 and time<1.1) or  (time>2 and time<2.1) or  (time>3 and time<3.1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 


annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest1",
        description="Test of code generation of when clauses.",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        relational_time_events=false,
        template="
$C_ode_guards$
$C_ode_derivatives$ 
$C_ode_initialization$
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_DAE_event_indicator_residuals$
",
        generatedCode="


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(jmi, _time - (1), _sw(3), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(4) = jmi_turn_switch(jmi, _time - (1.1), _sw(4), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(5) = jmi_turn_switch(jmi, _time - (2), _sw(5), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(6) = jmi_turn_switch(jmi, _time - (2.1), _sw(6), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(7) = jmi_turn_switch(jmi, _time - (3), _sw(7), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(8) = jmi_turn_switch(jmi, _time - (3.1), _sw(8), JMI_REL_LT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _der_xx_19 = - _x_1;
    JMI_DYNAMIC_FREE()
    return ef;
}
 

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    pre_x_1 = 0.0;
    _x_1 = pre_x_1;
    _der_xx_19 = - _x_1;
    pre_y_2 = 0.0;
    _y_2 = pre_y_2;
    pre_z_5 = JMI_TRUE;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _y_2 - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_6 = LOG_EXP_AND(_sw(0), pre_z_5);
    _z_5 = pre_z_5;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _y_2 - (2), _sw(1), JMI_REL_GT);
    }
    _temp_2_7 = LOG_EXP_AND(_sw(1), _z_5);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_1 - (2), _sw(2), JMI_REL_GT);
    }
    _temp_3_8 = _sw(2);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(jmi, _time - (1), _sw(3), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(4) = jmi_turn_switch(jmi, _time - (1.1), _sw(4), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(5) = jmi_turn_switch(jmi, _time - (2), _sw(5), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(6) = jmi_turn_switch(jmi, _time - (2.1), _sw(6), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(7) = jmi_turn_switch(jmi, _time - (3), _sw(7), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(8) = jmi_turn_switch(jmi, _time - (3.1), _sw(8), JMI_REL_LT);
    }
    _temp_4_9 = LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(3), _sw(4)), LOG_EXP_AND(_sw(5), _sw(6))), LOG_EXP_AND(_sw(7), _sw(8)));
    pre_w_3 = JMI_TRUE;
    _w_3 = pre_w_3;
    pre_v_4 = JMI_TRUE;
    _v_4 = pre_v_4;
    _xx_0 = 2;
    pre_temp_1_6 = JMI_FALSE;
    pre_temp_2_7 = JMI_FALSE;
    pre_temp_3_8 = JMI_FALSE;
    pre_temp_4_9 = JMI_FALSE;
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
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870924;
        x[1] = 536870923;
        x[2] = 536870920;
        x[3] = 536870922;
        x[4] = 536870919;
        x[5] = 536870921;
        x[6] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870924;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 2;
        x[1] = jmi->offs_sw + 1;
        x[2] = jmi->offs_sw + 0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(3) = jmi_turn_switch(jmi, _time - (1), _sw(3), JMI_REL_GT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(4) = jmi_turn_switch(jmi, _time - (1.1), _sw(4), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(5) = jmi_turn_switch(jmi, _time - (2), _sw(5), JMI_REL_GT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(6) = jmi_turn_switch(jmi, _time - (2.1), _sw(6), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(7) = jmi_turn_switch(jmi, _time - (3), _sw(7), JMI_REL_GT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(8) = jmi_turn_switch(jmi, _time - (3.1), _sw(8), JMI_REL_LT);
            }
            _temp_4_9 = LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(3), _sw(4)), LOG_EXP_AND(_sw(5), _sw(6))), LOG_EXP_AND(_sw(7), _sw(8)));
        }
        _y_2 = COND_EXP_EQ(LOG_EXP_AND(_temp_4_9, LOG_EXP_NOT(pre_temp_4_9)), JMI_TRUE, pre_y_2 + 1.1, pre_y_2);
        _x_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_4_9, LOG_EXP_NOT(pre_temp_4_9)), JMI_TRUE, pre_x_1 + 1.1, pre_x_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch(jmi, _x_1 - (2), _sw(2), JMI_REL_GT);
            }
            _temp_3_8 = _sw(2);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _z_5 = COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, JMI_FALSE, pre_z_5);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _y_2 - (2), _sw(1), JMI_REL_GT);
            }
            _temp_2_7 = LOG_EXP_AND(_sw(1), _z_5);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _v_4 = COND_EXP_EQ(LOG_EXP_AND(_temp_2_7, LOG_EXP_NOT(pre_temp_2_7)), JMI_TRUE, JMI_FALSE, pre_v_4);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _y_2 - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_6 = LOG_EXP_AND(_sw(0), pre_z_5);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _w_3 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_6, LOG_EXP_NOT(pre_temp_1_6)), JMI_TRUE, JMI_FALSE, pre_w_3);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = COND_EXP_EQ(pre_z_5, JMI_TRUE, _y_2 - (2), 1.0);
    (*res)[1] = COND_EXP_EQ(_z_5, JMI_TRUE, _y_2 - (2), 1.0);
    (*res)[2] = _x_1 - (2);
    (*res)[3] = _time - (1);
    (*res)[4] = COND_EXP_EQ(_sw(3), JMI_TRUE, _time - (1.1), 1.0);
    (*res)[5] = COND_EXP_EQ(LOG_EXP_NOT(LOG_EXP_AND(_sw(3), _sw(4))), JMI_TRUE, _time - (2), 1.0);
    (*res)[6] = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_NOT(LOG_EXP_AND(_sw(3), _sw(4))), _sw(5)), JMI_TRUE, _time - (2.1), 1.0);
    (*res)[7] = COND_EXP_EQ(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_AND(_sw(3), _sw(4)), LOG_EXP_AND(_sw(5), _sw(6)))), JMI_TRUE, _time - (3), 1.0);
    (*res)[8] = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_AND(_sw(3), _sw(4)), LOG_EXP_AND(_sw(5), _sw(6)))), _sw(7)), JMI_TRUE, _time - (3.1), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end WhenTest1;

model WhenTest2 

 Real x,ref;
 discrete Real I;
 discrete Real u;

 parameter Real K = 1;
 parameter Real Ti = 1;
 parameter Real h = 0.1;

equation
 der(x) = -x + u;
 when sample(0,h) then
   I = pre(I) + h*(ref-x);
   u = K*(ref-x) + 1/Ti*I;
 end when;
 ref = if time <1 then 0 else 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest2",
        description="Test that samplers are not duplicated in the function tha computes the next time event.",
        equation_sorting=true,
        generate_ode=true,
        variability_propagation=false,
        template="
$C_ode_guards$
                   $C_ode_time_events$
",
        generatedCode="

                       jmi_real_t nSamp;
    if (SURELY_LT_ZERO(_time - (1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_NOT(_atInitial), JMI_TRUE, _time - (pre__sampleItr_1_8 * _h_6), 1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, pre__sampleItr_1_8 * _h_6);
    }
    if (SURELY_LT_ZERO(_time - ((pre__sampleItr_1_8 + 1.0) * _h_6))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, (pre__sampleItr_1_8 + 1.0) * _h_6);
    }
")})));
end WhenTest2; 

model WhenTest3 

 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when sample(0,2/3) then
   y = pre(y) + 1;
 end when;


annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest3",
        description="Test code generation of samplers",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_ode_time_events$ 
$C_ode_derivatives$ 
$C_ode_initialization$
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
    jmi_real_t nSamp;
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_NOT(_atInitial), JMI_TRUE, _time - (pre__sampleItr_1_4 * jmi_divide_equation(jmi, 2, 3, \"(2 / 3)\")), 1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, pre__sampleItr_1_4 * jmi_divide_equation(jmi, 2, 3, \"(2 / 3)\"));
    }
    if (SURELY_LT_ZERO(_time - ((pre__sampleItr_1_4 + 1.0) * jmi_divide_equation(jmi, 2.0, 3.0, \"(2 / 3)\")))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, (pre__sampleItr_1_4 + 1.0) * jmi_divide_equation(jmi, 2.0, 3.0, \"(2 / 3)\"));
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_NOT(_atInitial), JMI_TRUE, _time - (pre__sampleItr_2_6 * jmi_divide_equation(jmi, 1, 3, \"(1 / 3)\")), 1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, pre__sampleItr_2_6 * jmi_divide_equation(jmi, 1, 3, \"(1 / 3)\"));
    }
    if (SURELY_LT_ZERO(_time - ((pre__sampleItr_2_6 + 1.0) * jmi_divide_equation(jmi, 1.0, 3.0, \"(1 / 3)\")))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, (pre__sampleItr_2_6 + 1.0) * jmi_divide_equation(jmi, 1.0, 3.0, \"(1 / 3)\"));
    }
 

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_dummy_13 = 0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_2_6 + 1.0) * jmi_divide_equation(jmi, 1.0, 3.0, \"(1 / 3)\")), _sw(3), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_2_6 * jmi_divide_equation(jmi, 1, 3, \"(1 / 3)\")), _sw(2), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_4 + 1.0) * jmi_divide_equation(jmi, 2.0, 3.0, \"(2 / 3)\")), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_4 * jmi_divide_equation(jmi, 2, 3, \"(2 / 3)\")), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    JMI_DYNAMIC_FREE()
    return ef;
}
 

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_dummy_13 = 0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch_time(jmi, _time - (0.0), _sw_init(0), JMI_REL_LT);
    }
    __sampleItr_1_4 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 0.0, ceil(jmi_divide_equation(jmi, _time, jmi_divide_equation(jmi, 2.0, 3.0, \"(2 / 3)\"), \"time / (2 / 3)\")));
    pre__sampleItr_1_4 = __sampleItr_1_4;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_4 * jmi_divide_equation(jmi, 2, 3, \"(2 / 3)\")), _sw(0), JMI_REL_GEQ);
    }
    _temp_1_3 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_4 + 1.0) * jmi_divide_equation(jmi, 2.0, 3.0, \"(2 / 3)\")), _sw(1), JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch_time(jmi, _time - (0.0), _sw_init(0), JMI_REL_LT);
    }
    __sampleItr_2_6 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 0.0, ceil(jmi_divide_equation(jmi, _time, jmi_divide_equation(jmi, 1.0, 3.0, \"(1 / 3)\"), \"time / (1 / 3)\")));
    pre__sampleItr_2_6 = __sampleItr_2_6;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_2_6 * jmi_divide_equation(jmi, 1, 3, \"(1 / 3)\")), _sw(2), JMI_REL_GEQ);
    }
    _temp_2_5 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(2));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_2_6 + 1.0) * jmi_divide_equation(jmi, 1.0, 3.0, \"(1 / 3)\")), _sw(3), JMI_REL_LT);
    }
    if (_sw(3) == JMI_FALSE) {
        jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
    }
    pre_temp_1_3 = JMI_FALSE;
    pre_temp_2_5 = JMI_FALSE;
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_y_1 = 0.0;
    _y_1 = pre_y_1;
    _dummy_2 = 0.0;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870921;
        x[1] = 268435463;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870921;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(3) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_2_6 + 1.0) * jmi_divide_equation(jmi, 1.0, 3.0, \"(1 / 3)\")), _sw(3), JMI_REL_LT);
        }
        if (_sw(3) == JMI_FALSE) {
            jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_2_6 * jmi_divide_equation(jmi, 1, 3, \"(1 / 3)\")), _sw(2), JMI_REL_GEQ);
            }
            _temp_2_5 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(2));
        }
        _x_0 = COND_EXP_EQ(LOG_EXP_AND(_temp_2_5, LOG_EXP_NOT(pre_temp_2_5)), JMI_TRUE, pre_x_0 + 1.0, pre_x_0);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            __sampleItr_2_6 = COND_EXP_EQ(LOG_EXP_AND(_temp_2_5, LOG_EXP_NOT(pre_temp_2_5)), JMI_TRUE, pre__sampleItr_2_6 + 1.0, pre__sampleItr_2_6);
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
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
        x[1] = 268435462;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_4 + 1.0) * jmi_divide_equation(jmi, 2.0, 3.0, \"(2 / 3)\")), _sw(1), JMI_REL_LT);
        }
        if (_sw(1) == JMI_FALSE) {
            jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_4 * jmi_divide_equation(jmi, 2, 3, \"(2 / 3)\")), _sw(0), JMI_REL_GEQ);
            }
            _temp_1_3 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
        }
        _y_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3)), JMI_TRUE, pre_y_1 + 1.0, pre_y_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            __sampleItr_1_4 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3)), JMI_TRUE, pre__sampleItr_1_4 + 1.0, pre__sampleItr_1_4);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


")})));
end WhenTest3; 

model WhenTest4
 discrete Boolean sampleTrigger;
 Real x_p(start=1, fixed=true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
initial equation
 x_c = pre(x_c); 	
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {initial(),sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;


annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest4",
        description="Test code generation of samplers",
        generate_ode=true,
        equation_sorting=true,
        automatic_tearing=false,
        variability_propagation=false,
        template="
$C_ode_derivatives$
$C_ode_initialization$
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_12 + 1.0) * _h_11), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_12 * _h_11), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _u_p_2 = _c_c_10 * _x_c_3;
    _der_x_p_17 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_p_1 = 1;
    _u_c_4 = _c_p_7 * _x_p_1;
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    _u_p_2 = _c_c_10 * _x_c_3;
    _der_x_p_17 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch_time(jmi, _time - (0.0), _sw_init(0), JMI_REL_LT);
    }
    __sampleItr_1_12 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 0.0, ceil(jmi_divide_equation(jmi, _time, _h_11, \"time / h\")));
    pre__sampleItr_1_12 = __sampleItr_1_12;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_12 * _h_11), _sw(0), JMI_REL_GEQ);
    }
    _sampleTrigger_0 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_12 + 1.0) * _h_11), _sw(1), JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
    }
    pre_sampleTrigger_0 = JMI_FALSE;
    pre_u_c_4 = 0.0;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 13;
        x[1] = 12;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 13;
        x[1] = 12;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870927;
        x[1] = 268435470;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870927;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_12 + 1.0) * _h_11), _sw(1), JMI_REL_LT);
        }
        if (_sw(1) == JMI_FALSE) {
            jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_12 * _h_11), _sw(0), JMI_REL_GEQ);
            }
            _sampleTrigger_0 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
        }
        _u_c_4 = COND_EXP_EQ(LOG_EXP_OR(_atInitial, LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _c_p_7 * _x_p_1, pre_u_c_4);
        _x_c_3 = COND_EXP_EQ(LOG_EXP_OR(_atInitial, LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _a_c_8 * pre_x_c_3 + _b_c_9 * _u_c_4, pre_x_c_3);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            __sampleItr_1_12 = COND_EXP_EQ(LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0)), JMI_TRUE, pre__sampleItr_1_12 + 1.0, pre__sampleItr_1_12);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
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
        x[1] = 12;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[1] = 12;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = jmi_max(1.0, jmi_max(jmi_abs(_a_c_8), jmi_abs(_b_c_9)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = pre_x_c_3;
        x[1] = _x_c_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = -1.0;
        residual[1] = - _a_c_8;
        residual[2] = 1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            pre_x_c_3 = x[0];
            _x_c_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = pre_x_c_3 - (_x_c_3);
            (*res)[1] = _a_c_8 * pre_x_c_3 + _b_c_9 * _u_c_4 - (_x_c_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end WhenTest4;

model WhenTest5
 discrete Boolean sampleTrigger;
 Real x_p(start=1, fixed=true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
 discrete Boolean atInit = true and initial();
initial equation
 x_c = pre(x_c); 	
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {atInit,sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest5",
        description="Test code generation of samplers",
        generate_ode=true,
        automatic_tearing=false,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 13;
        x[1] = 12;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 13;
        x[1] = 12;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870928;
        x[1] = 536870927;
        x[2] = 268435470;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870928;
        x[1] = 536870927;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_13 + 1.0) * _h_11), _sw(1), JMI_REL_LT);
        }
        if (_sw(1) == JMI_FALSE) {
            jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _atInit_12 = LOG_EXP_AND(JMI_TRUE, _atInitial);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_13 * _h_11), _sw(0), JMI_REL_GEQ);
            }
            _sampleTrigger_0 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
        }
        _u_c_4 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_AND(_atInit_12, LOG_EXP_NOT(pre_atInit_12)), LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _c_p_7 * _x_p_1, pre_u_c_4);
        _x_c_3 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_AND(_atInit_12, LOG_EXP_NOT(pre_atInit_12)), LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _a_c_8 * pre_x_c_3 + _b_c_9 * _u_c_4, pre_x_c_3);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            __sampleItr_1_13 = COND_EXP_EQ(LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0)), JMI_TRUE, pre__sampleItr_1_13 + 1.0, pre__sampleItr_1_13);
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
        _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_13 + 1.0) * _h_11), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_13 * _h_11), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _u_p_2 = _c_c_10 * _x_c_3;
    _der_x_p_19 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    pre_x_c_3 = 0.0;
    _x_c_3 = pre_x_c_3;
    _u_p_2 = _c_c_10 * _x_c_3;
    _x_p_1 = 1;
    _der_x_p_19 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
    _atInit_12 = LOG_EXP_AND(JMI_TRUE, _atInitial);
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch_time(jmi, _time - (0.0), _sw_init(0), JMI_REL_LT);
    }
    __sampleItr_1_13 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 0.0, ceil(jmi_divide_equation(jmi, _time, _h_11, \"time / h\")));
    pre__sampleItr_1_13 = __sampleItr_1_13;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_13 * _h_11), _sw(0), JMI_REL_GEQ);
    }
    _sampleTrigger_0 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_13 + 1.0) * _h_11), _sw(1), JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
    }
    pre_u_c_4 = 0.0;
    _u_c_4 = pre_u_c_4;
    pre_sampleTrigger_0 = JMI_FALSE;
    pre_atInit_12 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTest5;

model WhenTest6
	function F
		input Real x;
		output Real y1;
		output Real y2;
	algorithm
		y1 := 1;
		y2 := 2;
	end F;
	Real x,y;
	equation
	when sample(0,1) then
		(x,y) = F(time);
	end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest6",
        description="Test code generation when equations with function calls.",
        generate_ode=true,
        inline_functions="none",
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$ 
$C_ode_initialization$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
        x[1] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_3 + 1.0), _sw(1), JMI_REL_LT);
        }
        if (_sw(1) == JMI_FALSE) {
            jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_3), _sw(0), JMI_REL_GEQ);
            }
            _temp_1_2 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
        }
        if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
            func_CCodeGenTests_WhenTests_WhenTest6_F_def0(_time, &tmp_1, &tmp_2);
            _x_0 = (tmp_1);
        } else {
            _x_0 = pre_x_0;
        }
        if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
            _y_1 = (tmp_2);
        } else {
            _y_1 = pre_y_1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            __sampleItr_1_3 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), JMI_TRUE, pre__sampleItr_1_3 + 1.0, pre__sampleItr_1_3);
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
        _sw(1) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_3 + 1.0), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_3), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
 

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch_time(jmi, _time - (0.0), _sw_init(0), JMI_REL_LT);
    }
    __sampleItr_1_3 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 0.0, ceil(_time));
    pre__sampleItr_1_3 = __sampleItr_1_3;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_3), _sw(0), JMI_REL_GEQ);
    }
    _temp_1_2 = LOG_EXP_AND(LOG_EXP_NOT(_atInitial), _sw(0));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_3 + 1.0), _sw(1), JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"Too long time steps relative to sample interval.\", JMI_ASSERT_ERROR);
    }
    pre_temp_1_2 = JMI_FALSE;
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_y_1 = 0.0;
    _y_1 = pre_y_1;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTest6;

model WhenTest7
 discrete Real x;
 Real y1,y2;
 Real z1,z2,z3;
equation
 when time > 3 then
  x = sin(x) +3;
 end when;
 
  y1 + y2 = 5;
  when time > 3 then 
    y1 = 7 - 2*y2;
  end when;
  
  z1 + z2 + z3 = 5;
  when time > 3 then 
    z1 = 7 - 2*z2;
    z3 = 7 - 2*z2;
  end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest7",
        description="Test code generation unsolved when equations",
        generate_ode=true,
        automatic_tearing=false,
        equation_sorting=true,
        relational_time_events=false,
        variability_propagation=false,
        template="
$C_ode_derivatives$ 
$C_ode_initialization$
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[2]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[3]);
    JMI_DYNAMIC_FREE()
    return ef;
}
 

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
    }
    _temp_1_6 = _sw(0);
    pre_y1_1 = 0.0;
    _y1_1 = pre_y1_1;
    _y2_2 = - _y1_1 + 5;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
    }
    _temp_2_7 = _sw(0);
    pre_z1_3 = 0.0;
    _z1_3 = pre_z1_3;
    pre_z3_5 = 0.0;
    _z3_5 = pre_z3_5;
    _z2_4 = - _z1_3 + (- _z3_5) + 5;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
    }
    _temp_3_8 = _sw(0);
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_temp_1_6 = JMI_FALSE;
    pre_temp_2_7 = JMI_FALSE;
    pre_temp_3_8 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1.1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_1_6, LOG_EXP_NOT(pre_temp_1_6)), JMI_TRUE, sin(_x_0) + 3.0, pre_x_0) - (_x_0);
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
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
            }
            _temp_1_6 = _sw(0);
        }
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870921;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870921;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 7;
        (*res)[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y1_1;
        x[1] = _y2_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        residual[1] = 1.0;
        residual[2] = - COND_EXP_EQ(LOG_EXP_AND(_temp_2_7, LOG_EXP_NOT(pre_temp_2_7)), JMI_TRUE, -2.0, 0.0);
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y1_1 = x[0];
            _y2_2 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
            }
            _temp_2_7 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_2_7, LOG_EXP_NOT(pre_temp_2_7)), JMI_TRUE, 7.0 - 2.0 * _y2_2, pre_y1_1) - (_y1_1);
            (*res)[1] = 5 - (_y1_1 + _y2_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 3 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 6;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 6;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870922;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870922;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 7;
        (*res)[1] = 7;
        (*res)[2] = 5;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z3_5;
        x[1] = _z1_3;
        x[2] = _z2_4;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        residual[2] = 1.0;
        residual[4] = 1.0;
        residual[5] = 1.0;
        residual[6] = - COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, -2.0, 0.0);
        residual[7] = - COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, -2.0, 0.0);
        residual[8] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z3_5 = x[0];
            _z1_3 = x[1];
            _z2_4 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (3), _sw(0), JMI_REL_GT);
            }
            _temp_3_8 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, 7.0 - 2.0 * _z2_4, pre_z3_5) - (_z3_5);
            (*res)[1] = COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, 7.0 - 2.0 * _z2_4, pre_z1_3) - (_z1_3);
            (*res)[2] = 5 - (_z1_3 + _z2_4 + _z3_5);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


")})));
end WhenTest7;

model WhenTest8
	
function f
	input Real x;
	input Real y;
	output Real a;
	output Real b;
 algorithm
	 a := y;
	 b := x;
end f;

 discrete Real x,y;
 Real a,b;
equation
	a = time;
	b = time*2;
  when {initial(), time > 1} then
    (x,y) = f(a,b);
  end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest8",
        description="Test code generation unsolved when equations",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        relational_time_events=false,
        inline_functions="none",
        template="
$C_ode_derivatives$ 
$C_ode_initialization$
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _a_2 = _time;
    _b_3 = 2 * _a_2;
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
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    _a_2 = _time;
    _b_3 = 2 * _a_2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
    }
    _temp_1_4 = _sw(0);
    func_CCodeGenTests_WhenTests_WhenTest8_f_def0(_a_2, _b_3, &tmp_1, &tmp_2);
    _x_0 = (tmp_1);
    _y_1 = (tmp_2);
    pre_x_0 = 0.0;
    pre_y_1 = 0.0;
    pre_temp_1_4 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 5;
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
        if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4)))) {
            func_CCodeGenTests_WhenTests_WhenTest8_f_def0(_a_2, _b_3, &tmp_3, &tmp_4);
            _x_0 = (tmp_3);
        } else {
            _x_0 = pre_x_0;
        }
        if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4)))) {
            _y_1 = (tmp_4);
        } else {
            _y_1 = pre_y_1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


")})));
end WhenTest8;

model WhenTest9
	
function f
	input Real x;
	input Real y;
	output Real a;
	output Real b;
 algorithm
	 a := y;
	 b := x;
end f;

 discrete Real x,y;
 Real a,b;
equation
  a = time;
  b = time*x;
  when time > 2 then
    (x,y) = f(a,b);
  end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest9",
        description="Test code generation unsolved when equations",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        inline_functions="none",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_3;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_3 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_4 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            func_CCodeGenTests_WhenTests_WhenTest9_f_def0(_a_2, _b_3, &tmp_1, &tmp_2);
            _y_1 = (tmp_2);
        } else {
            _y_1 = pre_y_1;
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            _x_0 = (tmp_1);
        } else {
            _x_0 = pre_x_0;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _time * _x_0 - (_b_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end WhenTest9;

model WhenTest10
	
function f
	input Real x;
	input Real y;
	output Real a;
	output Real b;
 algorithm
	 a := y;
	 b := x;
end f;

 discrete Real x,y;
 Real a,b;
equation
  when time > 2 then
    (a,b) = f(x,y);
  end when;
  when {initial(), time > 2} then
    (x,y) = f(a,b);
  end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest10",
        description="Test code generation unsolved when equations",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        inline_functions="none",
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 4;
        x[2] = 3;
        x[3] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
        x[1] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
        x[1] = 536870919;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_2_5 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_4 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            func_CCodeGenTests_WhenTests_WhenTest10_f_def0(_x_0, _y_1, &tmp_1, &tmp_2);
            _b_3 = (tmp_2);
        } else {
            _b_3 = pre_b_3;
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            _a_2 = (tmp_1);
        } else {
            _a_2 = pre_a_2;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_2_5, LOG_EXP_NOT(pre_temp_2_5)))) {
                func_CCodeGenTests_WhenTests_WhenTest10_f_def0(_a_2, _b_3, &tmp_3, &tmp_4);
                (*res)[0] = tmp_4 - (_y_1);
            } else {
                (*res)[0] = pre_y_1 - (_y_1);
            }
            if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_2_5, LOG_EXP_NOT(pre_temp_2_5)))) {
                (*res)[1] = tmp_3 - (_x_0);
            } else {
                (*res)[1] = pre_x_0 - (_x_0);
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


")})));
end WhenTest10;

model WhenTest11
    Real x = time;
    discrete Real z;
equation
    when time >= 2 then
        z = pre(x);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest11",
        description="Code generation for use of pre on continuous variable",
        equation_sorting=true,
        generate_ode=true,
        relational_time_events=false,
        template="
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GEQ);
            }
            _temp_1_2 = _sw(0);
        }
        _z_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), JMI_TRUE, pre_x_0, pre_z_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end WhenTest11;


model WhenTest12
    Real x(start = 2, fixed = true);
equation
    der(x) = 1;
    when time > 4 then
        reinit(x, 1);
    elsewhen time > 2 then
        reinit(x, 0);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest12",
        description="Check that elsewhen without initial() is correctly excluded from initial system",
        template="$C_ode_initialization$",
        generatedCode="

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_5 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (4), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_1_1 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (2), _sw(1), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_2_2 = _sw(1);
    _x_0 = 2;
    pre_temp_1_1 = JMI_FALSE;
    pre_temp_2_2 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTest12;


model WhenTest13
    discrete Real x;
equation
    when time > 4 then
        x = 3;
    elsewhen initial() then
        x = 4;
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest13",
        description="Check that elsewhen with initial() is correctly included in initial system",
        template="$C_ode_initialization$",
        generatedCode="

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (4), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_1_1 = _sw(0);
    _x_0 = 4;
    pre_x_0 = 0.0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTest13;

model WhenTest14
    Real x;
    Real y;
equation
    der(x) = 1;
    if time < 1 then
        y = x + 1;
    else
        y = x - 1;
        when time > 2 then
            reinit(x, 0);
        end when;
    end if;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="WhenTests_WhenTest14",
        description="Ensure that no temporaries for non-initial when inside if clause isn't generated'",
        template="$C_ode_initialization$",
        generatedCode="

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_4 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_1_2 = _sw(0);
    _x_0 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(1), JMI_REL_LT);
    }
    _y_1 = COND_EXP_EQ(_sw(1), JMI_TRUE, _x_0 + 1.0, _x_0 - 1.0);
    pre_temp_1_2 = JMI_FALSE;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (1), _sw(1), JMI_REL_LT);
    }
    if (LOG_EXP_NOT(_sw(1))) {
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTest14;

end WhenTests;

function dummyFunc
	input Real i;
	output Real x = i;
	output Real y = i;
	algorithm
end dummyFunc;

model IfEqu1

    Real x,y;
equation
    if time >= 2 then
        (x,y) = dummyFunc(time*time*time/2);
    elseif time >= 1 then
        (x,y) = dummyFunc(time*time);
    else
        (x,y) = dummyFunc(time);
    end if;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="IfEqu1",
        description="Code generation for if equation",
        variability_propagation=false,
        inline_functions="none",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    JMI_DEF(REA, tmp_5)
    JMI_DEF(REA, tmp_6)
    if (_sw(0)) {
        func_CCodeGenTests_dummyFunc_def0(jmi_divide_equation(jmi, _time * _time * _time, 2.0, \"time * time * time / 2\"), &tmp_1, &tmp_2);
        _x_0 = (tmp_1);
        _y_1 = (tmp_2);
    } else {
        if (_sw(1)) {
            func_CCodeGenTests_dummyFunc_def0(_time * _time, &tmp_3, &tmp_4);
            _x_0 = (tmp_3);
            _y_1 = (tmp_4);
        } else {
            func_CCodeGenTests_dummyFunc_def0(_time, &tmp_5, &tmp_6);
            _x_0 = (tmp_5);
            _y_1 = (tmp_6);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end IfEqu1;

model IfEqu2
    Real x,y,t;
equation
    t = time;
    if time >= 1 then
        (x,t) = dummyFunc(y);
    else
        (x,t) = dummyFunc(y);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu2",
            description="Code generation for if equation, numerically solved",
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        if (_sw(0)) {
            func_CCodeGenTests_dummyFunc_def0(_y_1, &tmp_1, &tmp_2);
            _x_0 = (tmp_1);
        } else {
            func_CCodeGenTests_dummyFunc_def0(_y_1, &tmp_3, &tmp_4);
            _x_0 = (tmp_3);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                (*res)[0] = tmp_2 - (_t_2);
            } else {
                (*res)[0] = tmp_4 - (_t_2);
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end IfEqu2;

model IfEqu3
    Real x,y,a,b;
equation
    if time >= 1 then
        (x,y) = dummyFunc(a);
    else
        (x,y) = dummyFunc(b);
    end if;
    if time >= 1 then
        (a,b) = dummyFunc(x);
    else
        (a,b) = dummyFunc(y);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu3",
            description="Code generation for if equation, in block",
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    JMI_DEF(REA, tmp_5)
    JMI_DEF(REA, tmp_6)
    JMI_DEF(REA, tmp_7)
    JMI_DEF(REA, tmp_8)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_3;
        x[1] = _a_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_3 = x[0];
            _a_2 = x[1];
        }
        if (_sw(0)) {
            func_CCodeGenTests_dummyFunc_def0(_a_2, &tmp_1, &tmp_2);
            _y_1 = (tmp_2);
        } else {
            func_CCodeGenTests_dummyFunc_def0(_b_3, &tmp_3, &tmp_4);
            _y_1 = (tmp_4);
        }
        if (_sw(0)) {
            _x_0 = (tmp_1);
        } else {
            _x_0 = (tmp_3);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                func_CCodeGenTests_dummyFunc_def0(_x_0, &tmp_5, &tmp_6);
                (*res)[0] = tmp_6 - (_b_3);
            } else {
                func_CCodeGenTests_dummyFunc_def0(_y_1, &tmp_7, &tmp_8);
                (*res)[0] = tmp_8 - (_b_3);
            }
            if (_sw(0)) {
                (*res)[1] = tmp_5 - (_a_2);
            } else {
                (*res)[1] = tmp_7 - (_a_2);
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end IfEqu3;

model IfEqu4
function f
	input Real[:] i;
	output Real[size(i,1)] x = i;
	output Real[size(i,1)] y = i;
	algorithm
end f;
    Real[2] x,y;
equation
    if time >= 1 then
        (x,y) = f({time,time});
    else
        (x[1:end],y[{2,1}]) = f({time,time});
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu4",
            description="Code generation for if equation, temp vars",
            variability_propagation=false,
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1)
    if (_sw(0)) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
        jmi_array_ref_1(tmp_3, 1) = _time;
        jmi_array_ref_1(tmp_3, 2) = _time;
        func_CCodeGenTests_IfEqu4_f_def0(tmp_3, tmp_1, tmp_2);
        memcpy(&_x_1_0, &jmi_array_val_1(tmp_1, 1), 2 * sizeof(jmi_real_t));
        memcpy(&_y_1_2, &jmi_array_val_1(tmp_2, 1), 2 * sizeof(jmi_real_t));
    } else {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1, 2)
        jmi_array_ref_1(tmp_6, 1) = _time;
        jmi_array_ref_1(tmp_6, 2) = _time;
        func_CCodeGenTests_IfEqu4_f_def0(tmp_6, tmp_4, tmp_5);
        memcpy(&_x_1_0, &jmi_array_val_1(tmp_4, 1), 2 * sizeof(jmi_real_t));
        _y_2_3 = (jmi_array_val_1(tmp_5, 1));
        _y_1_2 = (jmi_array_val_1(tmp_5, 2));
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end IfEqu4;

model IfEqu5
    Real x;
    parameter Real y(fixed=false,start=3);
initial equation
    if time >= 1 then
        (x,) = dummyFunc(1);
    else
        (x,) = dummyFunc(2);
    end if;
equation
    when time > 1 then
		x = 1;
	end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="IfEqu5",
        description="Code generation for if equation, initial equation",
        variability_propagation=false,
        relational_time_events=false,
        inline_functions="none",
        template="$C_ode_initialization$",
        generatedCode="

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1), _sw(0), JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    if (_sw_init(0)) {
        func_CCodeGenTests_dummyFunc_def0(1.0, &tmp_1, NULL);
        _x_0 = (tmp_1);
    } else {
        func_CCodeGenTests_dummyFunc_def0(2.0, &tmp_2, NULL);
        _x_0 = (tmp_2);
    }
    pre_x_0 = _x_0;
    pre_temp_1_2 = JMI_FALSE;
    _y_1 = 3;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end IfEqu5;

model IfEqu6
    function F
        input Real[2] x;
    algorithm
        annotation(Inline=false);
    end F;
    parameter Real p = 1;
equation
    if time > p then
        F({time, -time});
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu6",
            description="Ensure that temporaries for equations inside if equations only is produced once inside the guard",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (_p_0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_ref_1(tmp_1, 1) = _time;
        jmi_array_ref_1(tmp_1, 2) = - _time;
        func_CCodeGenTests_IfEqu6_F_def0(tmp_1);
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end IfEqu6;

model IfEqu7
    parameter Real p = 1;
equation
    if time > p then
        Modelica.Utilities.Streams.print("This is a dumb way of finding out the value of p: " + String(time));
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu7",
            description="Ensure that temporaries for equations inside if equations only is produced once inside the guard",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 63)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (_p_0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        JMI_INI_STR_STAT(tmp_1)
        snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"This is a dumb way of finding out the value of p: \");
        snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
        func_Modelica_Utilities_Streams_print_def0(tmp_1, \"\");
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end IfEqu7;

model IfEqu8
    parameter Real p = 1;
equation
    when time > p then
        Modelica.Utilities.Streams.print("This is a dumb way of finding out the value of p: " + String(time));
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu8",
            description="Ensure that temporaries for equations inside if equations only is produced once inside the guard",
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
    JMI_DEF_STR_STAT(tmp_1, 63)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (_p_0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            JMI_INI_STR_STAT(tmp_1)
            snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"This is a dumb way of finding out the value of p: \");
            snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
            func_Modelica_Utilities_Streams_print_def0(tmp_1, \"\");
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
        _sw(0) = jmi_turn_switch_time(jmi, _time - (_p_0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end IfEqu8;

model IfEqu9
function f
    input Real[:] x;
    output Real[:] y = x;
    algorithm
    annotation(Inline=false);
end f;
    
    parameter Real[:] x = f({1});
    parameter Real[:] y = if x[1] > 0 then f(x) else {0};
    

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="IfEqu9",
        description="Code generation for if equation in parameter equations",
        variability_propagation=false,
        inline_functions="none",
        template="$C_model_init_eval_dependent_parameters$",
        generatedCode="

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_ref_1(tmp_2, 1) = 1.0;
    func_CCodeGenTests_IfEqu9_f_def0(tmp_2, tmp_1);
    _x_1_0 = (jmi_array_val_1(tmp_1, 1));
    if (COND_EXP_GT(_x_1_0, 0, JMI_TRUE, JMI_FALSE)) {
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1, 1)
        jmi_array_ref_1(tmp_4, 1) = _x_1_0;
        func_CCodeGenTests_IfEqu9_f_def0(tmp_4, tmp_3);
        _temp_2_1_1 = (jmi_array_val_1(tmp_3, 1));
    } else {
        _temp_2_1_1 = (0.0);
    }
    _y_1_2 = (COND_EXP_EQ(COND_EXP_GT(_x_1_0, 0.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, _temp_2_1_1, 0.0));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end IfEqu9;


model NoDAEGenerationTest1
  Real x, y, z;
  parameter Real p = 1;
  parameter Real p2 = p;
equation
  z = x + y;
  3 = x - y;
  5 = x + 3*y;  


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="NoDAEGenerationTest1",
            description="Test that no DAE is generated if the corresponding option is set to false.",
            generate_dae=false,
            variability_propagation=false,
            template="
$C_DAE_equation_residuals$
                   $C_DAE_initial_equation_residuals$
                   $C_DAE_initial_dependent_parameter_residuals$
",
            generatedCode="

                   
                   
")})));
end NoDAEGenerationTest1;

model BlockTest1
  Real x, y, z;
equation
  z = x + y;
  3 = x - y;
  5 = x + 3*y;  

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest1",
        description="Test code generation of systems of equations.",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        eliminate_linear_equations=false,
        automatic_tearing=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 5;
        (*res)[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = -3;
        residual[1] = 1.0;
        residual[2] = -1.0;
        residual[3] = -1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 3 * _y_1 - (5);
            (*res)[1] = _x_0 - _y_1 - (3);
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
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 5;
        (*res)[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = -3;
        residual[1] = 1.0;
        residual[2] = -1.0;
        residual[3] = -1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 3 * _y_1 - (5);
            (*res)[1] = _x_0 - _y_1 - (3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _z_2 = _x_0 + _y_1;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    _z_2 = _x_0 + _y_1;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end BlockTest1;


model BlockTest2
Real x1,x2,z1,z2[2];

equation

sin(z1)*3 = z1 + 2;
{{1,2},{3,4}}*z2 = {4,5};

der(x2) = -x2 + z2[1] + z2[2];
der(x1) = -x1 + z1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest2",
        description="Test generation of equation blocks",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        automatic_tearing=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
        generatedCode="
static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 5;
        (*res)[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z2_2_4;
        x[1] = _z2_1_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z2_2_4 = x[0];
            _z2_1_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 5 - (3 * _z2_1_3 + 4 * _z2_2_4);
            (*res)[1] = 4 - (_z2_1_3 + 2 * _z2_2_4);
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
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z1_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z1_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z1_2 + 2 - (sin(_z1_2) * 3);
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
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z1_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z1_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z1_2 + 2 - (sin(_z1_2) * 3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_init_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 5;
        (*res)[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z2_2_4;
        x[1] = _z2_1_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z2_2_4 = x[0];
            _z2_1_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 5 - (3 * _z2_1_3 + 4 * _z2_2_4);
            (*res)[1] = 4 - (_z2_1_3 + 2 * _z2_2_4);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    _der_x2_5 = - _x2_1 + _z2_1_3 + _z2_2_4;
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _der_x1_6 = - _x1_0 + _z1_2;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[1]);
    _x2_1 = 0.0;
    _der_x2_5 = - _x2_1 + _z2_1_3 + _z2_2_4;
    _x1_0 = 0.0;
    _der_x1_6 = - _x1_0 + _z1_2;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end BlockTest2;

model BlockTest3
 parameter Real m = 1;
 parameter Real f0 = 1;
 parameter Real f1 = 1;
 Real v;
 Real a;
 Real f;
 Real u;
 Real sa;
 Boolean startFor(start=false);
 Boolean startBack(start=false);
 Integer mode(start=2);
 Real dummy;
equation 
 der(dummy) = 1;
 u = 2*sin(time);
 m*der(v) = u - f;
 der(v) = a + 1;
 startFor = pre(mode)==2 and sa > 1;
 startBack = pre(mode) == 2 and sa < -1;
 a = if pre(mode) == 1 or startFor then sa-1 else 
     if pre(mode) == 3 or startBack then 
     sa + 1 else 0;
 f = if pre(mode) == 1 or startFor then 
     f0 + f1*v else 
     if pre(mode) == 3 or startBack then 
     -f0 + f1*v else f0*sa;
 mode=if (pre(mode) == 1 or startFor)
      and v>0 then 1 else 
      if (pre(mode) == 3 or startBack)
          and v<0 then 3 else 2;


annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest3",
        description="Test of code generation of blocks",
        generate_ode=true,
        equation_sorting=true,
        automatic_tearing=false,
        eliminate_linear_equations=false,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 10;
        x[2] = 8;
        x[3] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870927;
        x[2] = 268435469;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870927;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
        (*res)[2] = jmi_max(1.0, jmi_max(jmi_max(jmi_abs(_f0_1), jmi_abs(_f1_2)), jmi_max(jmi_max(jmi_abs(_f0_1), jmi_abs(_f1_2)), jmi_abs(_f0_1))));
        (*res)[3] = jmi_max(jmi_abs(_m_0), jmi_max(1.0, 1.0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_4;
        x[1] = _sa_7;
        x[2] = _f_5;
        x[3] = _der_v_16;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 16 * sizeof(jmi_real_t));
        residual[0] = -1.0;
        residual[1] = 1.0;
        residual[5] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 1.0, 0.0));
        residual[6] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 0.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 0.0, _f0_1));
        residual[10] = 1.0;
        residual[11] = 1.0;
        residual[12] = 1.0;
        residual[15] = _m_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_4 = x[0];
            _sa_7 = x[1];
            _f_5 = x[2];
            _der_v_16 = x[3];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _sa_7 - (1), _sw(0), JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _sa_7 - (-1), _sw(1), JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(2), JMI_REL_GT);
            }
            if (LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2))) {
            } else {
                if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                    _sw(3) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(3), JMI_REL_LT);
                }
            }
            _mode_10 = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2)), JMI_TRUE, 1.0, COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), _sw(3)), JMI_TRUE, 3.0, 2.0));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a_4 + 1 - (_der_v_16);
            (*res)[1] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + 1.0, 0.0)) - (_a_4);
            (*res)[2] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7)) - (_f_5);
            (*res)[3] = _u_6 - _f_5 - (_m_0 * _der_v_16);
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
        x[0] = 7;
        x[1] = 10;
        x[2] = 8;
        x[3] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870927;
        x[1] = 536870926;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870927;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
        (*res)[2] = jmi_max(1.0, jmi_max(jmi_max(jmi_abs(_f0_1), jmi_abs(_f1_2)), jmi_max(jmi_max(jmi_abs(_f0_1), jmi_abs(_f1_2)), jmi_abs(_f0_1))));
        (*res)[3] = jmi_max(jmi_abs(_m_0), jmi_max(1.0, 1.0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_4;
        x[1] = _sa_7;
        x[2] = _f_5;
        x[3] = _der_v_16;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 16 * sizeof(jmi_real_t));
        residual[0] = -1.0;
        residual[1] = 1.0;
        residual[5] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 1.0, 0.0));
        residual[6] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 0.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 0.0, _f0_1));
        residual[10] = 1.0;
        residual[11] = 1.0;
        residual[12] = 1.0;
        residual[15] = _m_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_4 = x[0];
            _sa_7 = x[1];
            _f_5 = x[2];
            _der_v_16 = x[3];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _sa_7 - (-1), _sw(1), JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _sa_7 - (1), _sw(0), JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a_4 + 1 - (_der_v_16);
            (*res)[1] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + 1.0, 0.0)) - (_a_4);
            (*res)[2] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7)) - (_f_5);
            (*res)[3] = _u_6 - _f_5 - (_m_0 * _der_v_16);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_dummy_15 = 1;
    _u_6 = 2 * sin(_time);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(2), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(3), JMI_REL_LT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_dummy_15 = 1;
    _u_6 = 2 * sin(_time);
    pre_mode_10 = 2;
    _v_3 = 0.0;
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(2), JMI_REL_GT);
    }
    if (LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2))) {
    } else {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(3) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(3), JMI_REL_LT);
        }
    }
    _mode_10 = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2)), JMI_TRUE, 1.0, COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), _sw(3)), JMI_TRUE, 3.0, 2.0));
    _dummy_11 = 0.0;
    pre_startFor_8 = JMI_FALSE;
    pre_startBack_9 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end BlockTest3;

model BlockTest4
  Real x(min=3); 
  Real y(max=-2, nominal=5);
  Real z(min=4,max=5,nominal=8);
equation
  z = x + y;
  3 = x - y;
  5 = x + 3*y + z;  

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest4",
        description="Test that min, max, and nominal attributes are correctly generated",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        eliminate_linear_equations=false,
        automatic_tearing=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
        x[0] = 5;
        x[2] = 8;
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
        x[1] = 3;
        x[2] = 4;
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
        x[0] = -2;
        x[2] = 5;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
        x[2] = 2;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 15;
        (*res)[1] = 5;
        (*res)[2] = 8;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        init_with_ubound(x[0], -2, \"Resetting initial value for variable y\");
        x[1] = _x_0;
        init_with_lbound(x[1], 3, \"Resetting initial value for variable x\");
        x[2] = _z_2;
        init_with_bounds(x[2], 4, 5, \"Resetting initial value for variable z\");
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = -3;
        residual[1] = 1.0;
        residual[2] = -1.0;
        residual[3] = -1.0;
        residual[4] = -1.0;
        residual[5] = -1.0;
        residual[6] = -1.0;
        residual[8] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            check_ubound(x[0], -2, \"Out of bounds for variable y\");
            _y_1 = x[0];
            check_lbound(x[1], 3, \"Out of bounds for variable x\");
            _x_0 = x[1];
            check_bounds(x[2], 4, 5, \"Out of bounds for variable z\");
            _z_2 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 3 * _y_1 + _z_2 - (5);
            (*res)[1] = _x_0 - _y_1 - (3);
            (*res)[2] = _x_0 + _y_1 - (_z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest4;

model BlockTest5
  parameter Real p1 = 4;
  Real x[2](min={1, 4*p1}); 
  Real y(max=-2, nominal=5);
  equation
  3 = x[1] - y + x[2];
  5 = x[1] + 3*y;
  3 = x[1] + y + x[2];  



annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest5",
        description="Test of min and max for iteration varaibles.",
        generate_ode=true,
        equation_sorting=true,
        automatic_tearing=false,
        variability_propagation=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
        x[0] = 4 * _p1_0;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
        x[1] = -2;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 3;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 20;
        (*res)[1] = 25;
        (*res)[2] = 5;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_2;
        init_with_lbound(x[0], 16.0, \"Resetting initial value for variable x[2]\");
        x[1] = _y_3;
        init_with_ubound(x[1], -2, \"Resetting initial value for variable y\");
        x[2] = _x_1_1;
        init_with_lbound(x[2], 1, \"Resetting initial value for variable x[1]\");
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = -1.0;
        residual[2] = -1.0;
        residual[3] = 4;
        residual[4] = 5;
        residual[5] = 1.0;
        residual[7] = 1.0;
        residual[8] = -1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            check_lbound(x[0], 16.0, \"Out of bounds for variable x[2]\");
            _x_2_2 = x[0];
            check_ubound(x[1], -2, \"Out of bounds for variable y\");
            _y_3 = x[1];
            check_lbound(x[2], 1, \"Out of bounds for variable x[1]\");
            _x_1_1 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_2_2 + -4 * _y_3 + 2 - (0);
            (*res)[1] = -5 * _y_3 + 5 - (_x_1_1);
            (*res)[2] = _x_1_1 - _y_3 + _x_2_2 - (3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest5;

model BlockTest6
  function f1
    input Real x;
	output Real y=0;
  algorithm
	  for i in 1:3 loop
		  y := y + x;
	  end for;
  end f1;

  function f2
	input Real x;
	input Integer n;
	output Real y[2]={0,0};
  algorithm
	  for i in 1:n loop
		  y := {y[1] + x, y[2] + 2*x};
	  end for;
  end f2;
  
  parameter Real p1 = 4;
  Real x[2](min=f2(3,2)); 
  Real y(max=-f1(2), nominal=5);
  equation
  3 = x[1] - y + x[2];
  5 = x[1] + 3*y;
  3 = x[1] + y + x[2];  

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest6",
        description="Test of min, max and nominal attributes in blocks",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        automatic_tearing=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
        x[0] = _temp_1_2_5;
        x[2] = _temp_1_1_4;
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
        x[1] = - func_CCodeGenTests_BlockTest6_f1_exp1(2.0);
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 5;
        x[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 20;
        (*res)[1] = 25;
        (*res)[2] = 5;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_2;
        init_with_lbound(x[0], 12.0, \"Resetting initial value for variable x[2]\");
        x[1] = _y_3;
        init_with_ubound(x[1], -6.0, \"Resetting initial value for variable y\");
        x[2] = _x_1_1;
        init_with_lbound(x[2], 6.0, \"Resetting initial value for variable x[1]\");
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = -1.0;
        residual[2] = -1.0;
        residual[3] = 4;
        residual[4] = 5;
        residual[5] = 1.0;
        residual[7] = 1.0;
        residual[8] = -1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            check_lbound(x[0], 12.0, \"Out of bounds for variable x[2]\");
            _x_2_2 = x[0];
            check_ubound(x[1], -6.0, \"Out of bounds for variable y\");
            _y_3 = x[1];
            check_lbound(x[2], 6.0, \"Out of bounds for variable x[1]\");
            _x_1_1 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_2_2 + -4 * _y_3 + 2 - (0);
            (*res)[1] = -5 * _y_3 + 5 - (_x_1_1);
            (*res)[2] = _x_1_1 - _y_3 + _x_2_2 - (3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest6;

model BlockTest7
    parameter Real A[2,2] = 2*{{1,2},{3,4}};
    Real x[2];
    Real y[2];
    Real z[2];
    Real w[2];
    parameter Real p = 2;
    discrete Real d;
equation
    when time>=1 then
 d = pre(d) + 1;
    end when;
    {{1,2},{3,4}}*x = {3,4};
    p*A*y = y;
    (d+1)*A*z = z+{2,2};
    (x[1]+1)*A*w = w+{3,3};

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest7",
        description="Test of min, max and nominal attributes in blocks",
        generate_ode=true,
        equation_sorting=true,
        automatic_tearing=false,
        eliminate_linear_equations=false,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 4;
        (*res)[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_5;
        x[1] = _x_1_4;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2_5 = x[0];
            _x_1_4 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 4 - (3 * _x_1_4 + 4 * _x_2_5);
            (*res)[1] = 3 - (_x_1_4 + 2 * _x_2_5);
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
        x[0] = 8;
        x[1] = 7;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(jmi_abs(_p_12) * jmi_abs(_A_2_1_2), jmi_abs(_p_12) * jmi_abs(_A_2_2_3)), 1.0);
        (*res)[1] = jmi_max(jmi_max(jmi_abs(_p_12) * jmi_abs(_A_1_1_0), jmi_abs(_p_12) * jmi_abs(_A_1_2_1)), 1.0);
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_2_7;
        x[1] = _y_1_6;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = _p_12 * _A_2_2_3 - 1.0;
        residual[1] = _p_12 * _A_1_2_1;
        residual[2] = _p_12 * _A_2_1_2;
        residual[3] = _p_12 * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_2_7 = x[0];
            _y_1_6 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_2_7 - (_p_12 * _A_2_1_2 * _y_1_6 + _p_12 * _A_2_2_3 * _y_2_7);
            (*res)[1] = _y_1_6 - (_p_12 * _A_1_1_0 * _y_1_6 + _p_12 * _A_1_2_1 * _y_2_7);
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
        x[0] = 15;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 15;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870928;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870928;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), JMI_REL_GEQ);
            }
            _temp_1_14 = _sw(0);
        }
        _d_13 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_14, LOG_EXP_NOT(pre_temp_1_14)), JMI_TRUE, pre_d_13 + 1.0, pre_d_13);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 4 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
        x[1] = 9;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_1_2), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_2_3)), jmi_max(1.0, jmi_abs(2.0)));
        (*res)[1] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_1_0), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_2_1)), jmi_max(1.0, jmi_abs(2.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z_2_9;
        x[1] = _z_1_8;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_d_13 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_d_13 + 1) * _A_1_2_1;
        residual[2] = (_d_13 + 1) * _A_2_1_2;
        residual[3] = (_d_13 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z_2_9 = x[0];
            _z_1_8 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z_2_9 + 2 - ((_d_13 + 1) * _A_2_1_2 * _z_1_8 + (_d_13 + 1) * _A_2_2_3 * _z_2_9);
            (*res)[1] = _z_1_8 + 2 - ((_d_13 + 1) * _A_1_1_0 * _z_1_8 + (_d_13 + 1) * _A_1_2_1 * _z_2_9);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_4(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 5 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_1_2), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_2_3)), jmi_max(1.0, jmi_abs(3.0)));
        (*res)[1] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_1_0), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_2_1)), jmi_max(1.0, jmi_abs(3.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _w_2_11;
        x[1] = _w_1_10;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_x_1_4 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_x_1_4 + 1) * _A_1_2_1;
        residual[2] = (_x_1_4 + 1) * _A_2_1_2;
        residual[3] = (_x_1_4 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _w_2_11 = x[0];
            _w_1_10 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _w_2_11 + 3 - ((_x_1_4 + 1) * _A_2_1_2 * _w_1_10 + (_x_1_4 + 1) * _A_2_2_3 * _w_2_11);
            (*res)[1] = _w_1_10 + 3 - ((_x_1_4 + 1) * _A_1_1_0 * _w_1_10 + (_x_1_4 + 1) * _A_1_2_1 * _w_2_11);
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
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 4;
        (*res)[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_5;
        x[1] = _x_1_4;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2_5 = x[0];
            _x_1_4 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 4 - (3 * _x_1_4 + 4 * _x_2_5);
            (*res)[1] = 3 - (_x_1_4 + 2 * _x_2_5);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_init_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 8;
        x[1] = 7;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(jmi_abs(_p_12) * jmi_abs(_A_2_1_2), jmi_abs(_p_12) * jmi_abs(_A_2_2_3)), 1.0);
        (*res)[1] = jmi_max(jmi_max(jmi_abs(_p_12) * jmi_abs(_A_1_1_0), jmi_abs(_p_12) * jmi_abs(_A_1_2_1)), 1.0);
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_2_7;
        x[1] = _y_1_6;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = _p_12 * _A_2_2_3 - 1.0;
        residual[1] = _p_12 * _A_1_2_1;
        residual[2] = _p_12 * _A_2_1_2;
        residual[3] = _p_12 * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_2_7 = x[0];
            _y_1_6 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_2_7 - (_p_12 * _A_2_1_2 * _y_1_6 + _p_12 * _A_2_2_3 * _y_2_7);
            (*res)[1] = _y_1_6 - (_p_12 * _A_1_1_0 * _y_1_6 + _p_12 * _A_1_2_1 * _y_2_7);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_init_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 3 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
        x[1] = 9;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_1_2), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_2_3)), jmi_max(1.0, jmi_abs(2.0)));
        (*res)[1] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_1_0), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_2_1)), jmi_max(1.0, jmi_abs(2.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z_2_9;
        x[1] = _z_1_8;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_d_13 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_d_13 + 1) * _A_1_2_1;
        residual[2] = (_d_13 + 1) * _A_2_1_2;
        residual[3] = (_d_13 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z_2_9 = x[0];
            _z_1_8 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z_2_9 + 2 - ((_d_13 + 1) * _A_2_1_2 * _z_1_8 + (_d_13 + 1) * _A_2_2_3 * _z_2_9);
            (*res)[1] = _z_1_8 + 2 - ((_d_13 + 1) * _A_1_1_0 * _z_1_8 + (_d_13 + 1) * _A_1_2_1 * _z_2_9);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_init_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 4 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_1_2), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_2_2_3)), jmi_max(1.0, jmi_abs(3.0)));
        (*res)[1] = jmi_max(jmi_max(jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_1_0), jmi_max(1.0, jmi_abs(1.0)) * jmi_abs(_A_1_2_1)), jmi_max(1.0, jmi_abs(3.0)));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _w_2_11;
        x[1] = _w_1_10;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_x_1_4 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_x_1_4 + 1) * _A_1_2_1;
        residual[2] = (_x_1_4 + 1) * _A_2_1_2;
        residual[3] = (_x_1_4 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _w_2_11 = x[0];
            _w_1_10 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _w_2_11 + 3 - ((_x_1_4 + 1) * _A_2_1_2 * _w_1_10 + (_x_1_4 + 1) * _A_2_2_3 * _w_2_11);
            (*res)[1] = _w_1_10 + 3 - ((_x_1_4 + 1) * _A_1_1_0 * _w_1_10 + (_x_1_4 + 1) * _A_1_2_1 * _w_2_11);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 1, \"2\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_2, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_PARAMETER_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 2, \"3\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 0, 1, 1, 1, 1, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_3, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 3, \"4\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_4, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 4, \"5\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_PARAMETER_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 1, \"2\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_2, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 2, \"3\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_3, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 3, \"4\", -1);
")})));
end BlockTest7;

model BlockTest8
    Real a;
    Real b;
    Boolean d;
equation
    a = 1 - b;
    a = sin(b) * (if d then 1 else 2);
    d = b < 0;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest8",
        description="Test of mixed non-solved equation block",
        generate_ode=true,
        equation_sorting=true,
        eliminate_linear_equations=false,
        automatic_tearing=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 2;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _b_1 - (0), _sw(0), JMI_REL_LT);
            }
            _d_2 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = sin(_b_1) * COND_EXP_EQ(_d_2, JMI_TRUE, 1.0, 2.0) - (_a_0);
            (*res)[1] = 1 - _b_1 - (_a_0);
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
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 2;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _b_1 - (0), _sw(0), JMI_REL_LT);
            }
            _d_2 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = sin(_b_1) * COND_EXP_EQ(_d_2, JMI_TRUE, 1.0, 2.0) - (_a_0);
            (*res)[1] = 1 - _b_1 - (_a_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 2, 0, 0, 1, 1, 0, 0, 1, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 2, 0, 0, 1, 1, 0, 0, 1, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
")})));
end BlockTest8;

model BlockTest9
    function F
        input Real t[2];
        output Real y;
    algorithm
        y := t[1] * 2;
        if t[1] > t[2] then
            y := t[1] - t[2];
        end if;
    end F;
    
    Real x;
equation
    0 = x * F({time, 2});
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest9",
        description="Test of linear equation block",
        generate_ode=true,
        equation_sorting=true,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
        jmi_array_ref_1(tmp_2, 1) = _time;
        jmi_array_ref_1(tmp_2, 2) = 2.0;
        residual[0] = (- func_CCodeGenTests_BlockTest9_F_exp0(tmp_2));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
            jmi_array_ref_1(tmp_1, 1) = _time;
            jmi_array_ref_1(tmp_1, 2) = 2.0;
            (*res)[0] = _x_0 * func_CCodeGenTests_BlockTest9_F_exp0(tmp_1) - (0);
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
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
        jmi_array_ref_1(tmp_3, 1) = _time;
        jmi_array_ref_1(tmp_3, 2) = 2.0;
        residual[0] = (- func_CCodeGenTests_BlockTest9_F_exp0(tmp_3));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
            jmi_array_ref_1(tmp_1, 1) = _time;
            jmi_array_ref_1(tmp_1, 2) = 2.0;
            (*res)[0] = _x_0 * func_CCodeGenTests_BlockTest9_F_exp0(tmp_1) - (0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest9;

model BlockTest10
    function F
        input Real t[2];
        output Real y;
    algorithm
        y := t[1] * 2;
        if t[1] > t[2] then
            y := t[1] - t[2];
        end if;
    end F;
    
    Real x;
    Boolean b;
equation
    b = x > 0;
    0 = if b then x * F({time, 2}) else -1;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest10",
        description="Test of mixed linear equation block",
        generate_ode=true,
        automatic_tearing=false,
        equation_sorting=true,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        if (_b_1) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
            jmi_array_ref_1(tmp_2, 1) = _time;
            jmi_array_ref_1(tmp_2, 2) = 2.0;
        } else {
        }
        residual[0] = - COND_EXP_EQ(_b_1, JMI_TRUE, func_CCodeGenTests_BlockTest10_F_exp0(tmp_2), 0.0);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (0), _sw(0), JMI_REL_GT);
            }
            _b_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_b_1) {
                JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
                jmi_array_ref_1(tmp_1, 1) = _time;
                jmi_array_ref_1(tmp_1, 2) = 2.0;
            } else {
            }
            (*res)[0] = COND_EXP_EQ(_b_1, JMI_TRUE, _x_0 * func_CCodeGenTests_BlockTest10_F_exp0(tmp_1), -1.0) - (0);
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
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        if (_b_1) {
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
            jmi_array_ref_1(tmp_3, 1) = _time;
            jmi_array_ref_1(tmp_3, 2) = 2.0;
        } else {
        }
        residual[0] = - COND_EXP_EQ(_b_1, JMI_TRUE, func_CCodeGenTests_BlockTest10_F_exp0(tmp_3), 0.0);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (0), _sw(0), JMI_REL_GT);
            }
            _b_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_b_1) {
                JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
                jmi_array_ref_1(tmp_1, 1) = _time;
                jmi_array_ref_1(tmp_1, 2) = 2.0;
            } else {
            }
            (*res)[0] = COND_EXP_EQ(_b_1, JMI_TRUE, _x_0 * func_CCodeGenTests_BlockTest10_F_exp0(tmp_1), -1.0) - (0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest10;

model BlockTest11
    Real a,b;
equation
    a = b * (if time > 1 then 3.14 else 6.18);
    a + b = 42;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest11",
        description="Test relation switch expression in jacobian of mixed linear equation block",
        generate_ode=true,
        automatic_tearing=false,
        equation_sorting=true,
        relational_time_events=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 42;
        (*res)[1] = 6.18;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        residual[1] = (- COND_EXP_EQ(_sw(0), JMI_TRUE, 3.14, 6.18));
        residual[2] = 1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 42 - (_a_0 + _b_1);
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
            }
            (*res)[1] = _b_1 * COND_EXP_EQ(_sw(0), JMI_TRUE, 3.14, 6.18) - (_a_0);
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
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 42;
        (*res)[1] = 6.18;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        residual[1] = (- COND_EXP_EQ(_sw(0), JMI_TRUE, 3.14, 6.18));
        residual[2] = 1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 42 - (_a_0 + _b_1);
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
            }
            (*res)[1] = _b_1 * COND_EXP_EQ(_sw(0), JMI_TRUE, 3.14, 6.18) - (_a_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest11;

model BlockTest12
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    
    Integer t;
    Real y,x;
  equation
    (t,y) = f(x);
    x = y + 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest12",
        description="Mixed function call in block",
        inline_functions="none",
        variability_propagation=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        func_CCodeGenTests_BlockTest12_f_def0(_x_2, &tmp_1, &tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_1);
        }
        _y_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_1 + 1 - (_x_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest12;

model BlockTest13
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    
    Integer t;
    Real y,x;
  equation
    (t,y) = f(x);
    y = 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest13",
            description="Mixed function call in block",
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        func_CCodeGenTests_BlockTest13_f_def0(_x_2, &tmp_1, &tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_2 - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest13;

model BlockTest14
    Integer t;
    Real y,x;
  algorithm
    t := 1;
    y := x;
  equation
    x = y + 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest14",
        description="Mixed algorithm in block",
        inline_functions="none",
        variability_propagation=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        tmp_1 = _t_0;
        tmp_2 = _y_1;
        _t_0 = 1;
        _y_1 = _x_2;
        JMI_SWAP(GEN, _t_0, tmp_1)
        JMI_SWAP(GEN, _y_1, tmp_2)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_1);
        }
        _y_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_1 + 1 - (_x_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest14;

model BlockTest15
    Integer t;
    Real y,x;
  algorithm
    t := 1;
    y := x;
  equation
    y = 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest15",
        description="Mixed algorithm in block",
        inline_functions="none",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        tmp_1 = _t_0;
        tmp_2 = _y_1;
        _t_0 = 1;
        _y_1 = _x_2;
        JMI_SWAP(GEN, _t_0, tmp_1)
        JMI_SWAP(GEN, _y_1, tmp_2)
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_2 - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest15;

model BlockTest16
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    Integer t;
    Real y,x;
  equation
    if x < y then
        (t,y) = f(x);
    else
        (t,y) = f(x);
    end if;
    x = y + 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest16",
        description="Mixed if equation in block",
        inline_functions="none",
        variability_propagation=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(INT, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        _x_2 = _y_1 + 1;
        if (_sw(0)) {
            func_CCodeGenTests_BlockTest16_f_def0(_x_2, &tmp_1, &tmp_2);
        } else {
            func_CCodeGenTests_BlockTest16_f_def0(_x_2, &tmp_3, &tmp_4);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (_sw(0)) {
                _t_0 = (tmp_1);
            } else {
                _t_0 = (tmp_3);
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                (*res)[0] = tmp_2 - (_y_1);
            } else {
                (*res)[0] = tmp_4 - (_y_1);
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest16;

model BlockTest17
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    Integer t;
    Real y,x;
  equation
    if x < y then
        (t,y) = f(x);
    else
        (t,y) = f(x);
    end if;
    y = 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest17",
            description="Mixed if equation in block",
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(INT, tmp_3)
    JMI_DEF(REA, tmp_4)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        if (_sw(0)) {
            func_CCodeGenTests_BlockTest17_f_def0(_x_2, &tmp_1, &tmp_2);
        } else {
            func_CCodeGenTests_BlockTest17_f_def0(_x_2, &tmp_3, &tmp_4);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (_sw(0)) {
                _t_0 = (tmp_1);
            } else {
                _t_0 = (tmp_3);
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                (*res)[0] = tmp_2 - (_y_1);
            } else {
                (*res)[0] = tmp_4 - (_y_1);
            }
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest17;

model BlockTest18
    function f
        input Real x;
        output Real a2;
        output Integer a1;
      algorithm
        a1 := 3;
        a2 := x;
        annotation(smoothOrder=1,Inline=false);
    end f;
    Integer a;
    parameter Real b = 1;
    Real x;
  equation
    (b,a) = f(x);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest18",
            description="Mixed function call equation in block",
            inline_functions="none",
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
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        func_CCodeGenTests_BlockTest18_f_def0(_x_2, &tmp_1, &tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _a_0 = (tmp_2);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_1 - (_b_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest18;

model BlockTest19
    function f
        input Real[:] x;
        output Real[size(x,1)] y;
    algorithm
        y := x;
    end f;
    
    Real[2] x;
    Real y;
    
algorithm
    x[1] := y;
    x := f({time,time});
equation
    y = x[1] + 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest19",
        description="Function call equation in block",
        inline_functions="none",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 4;
        x[2] = 1;
        x[3] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_2 = x[0];
        }
        _x_1_0 = _y_2;
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
        jmi_array_ref_1(tmp_2, 1) = _time;
        jmi_array_ref_1(tmp_2, 2) = _time;
        func_CCodeGenTests_BlockTest19_f_def0(tmp_2, tmp_1);
        memcpy(&_temp_1_1_3, &jmi_array_val_1(tmp_1, 1), 2 * sizeof(jmi_real_t));
        _x_1_0 = _temp_1_1_3;
        _x_2_1 = _temp_1_2_4;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_1_0 + 1 - (_y_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest19;

model BlockTest20
    record R
        Real x;
        Boolean b;
    end R;
    
    function f_b 
        input Real x;
        output R r = R(x,x>1);
    algorithm
        annotation(Inline=false);
    end f_b;
    
    function f_u
        input R r;
        output Real y1 = if r.b then r.x*r.x else r.x;
    algorithm
        annotation(Inline=false,LateInline=true);
    end f_u;
    
    Real y;
 equation
    (y) = f_u(f_b(time + y));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest20",
        description="Non real temporary in block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_TEMP_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_0 = x[0];
        }
        func_CCodeGenTests_BlockTest20_f_b_def0(_time + _y_0, tmp_1);
        _temp_1_x_1 = (tmp_1->x);
        _temp_1_b_2 = (tmp_1->b);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (COND_EXP_EQ(_temp_1_b_2, JMI_TRUE, _temp_1_x_1 * _temp_1_x_1, _temp_1_x_1)) - (_y_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest20;

model BlockTest21
    function f
        input Real x;
        output Real y = x;
    algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p = 3;
    Real y(start=p);
 equation
    (y) = f(time + y);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest21",
        description="Start value in block",
        template="
$C_dae_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
",
        generatedCode="
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_PARAMETER_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_START) {
        x[0] = _p_0;
    } else if (evaluation_mode == JMI_BLOCK_START_SET) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = func_CCodeGenTests_BlockTest21_f_exp0(_time + _y_1) - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest21;

model BlockTest22
    
    record R
        Real y;
    end R;
    
    function f
        input R x;
        output Real y = x.y;
    algorithm
        annotation(Inline=false);
    end f;
    
    function f2
        input Real x;
        output Real y = x;
    algorithm
        annotation(Inline=false);
    end f2;
    
    parameter R p = R(3);
    Real x(nominal=f(p));
equation
    x = f2(x);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest22",
        description="Start value in block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
        JMI_RECORD_STATIC(R_0_r, tmp_1)
        tmp_1->y = _p_y_0;
        x[0] = func_CCodeGenTests_BlockTest22_f_exp0(tmp_1);
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        JMI_RECORD_STATIC(R_0_r, tmp_2)
        tmp_2->y = _p_y_0;
        (*res)[0] = jmi_max(jmi_abs(func_CCodeGenTests_BlockTest22_f_exp0(tmp_2)), 1.0);
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = func_CCodeGenTests_BlockTest22_f2_exp1(_x_1) - (_x_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end BlockTest22;

model BlockTest23
    function f
        input Real x;
        output Real y = x;
    algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p = 3;
    Real y(start=p);
 equation
    (y) = f(time + y);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest23",
            description="Test choice of nonlinear solver",
            init_nonlinear_solver="minpack",
            template="
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_PARAMETER_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_PARAMETER_VARIABILITY, JMI_MINPACK_SOLVER, 0, \"1\", -1);
")})));
end BlockTest23;

model BlockTest24
    function f
        input Real x;
        output Real y = x;
    algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p = 3;
    Real y(start=p);
 equation
    (y) = f(time + y);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest24",
            description="Test choice of nonlinear solver",
            nonlinear_solver="minpack",
            template="
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_PARAMETER_VARIABILITY, JMI_MINPACK_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_PARAMETER_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
")})));
end BlockTest24;

model BlockTest25
    record R
        constant Real y;
    end R;
    
    function f
        constant R[:] p = {R(3)};
        input Integer i;
        output Real y = p[i].y;
    algorithm
    end f;
    
    function f2
        input Real x;
        output Real y = x;
    algorithm
        annotation(Inline=false);
    end f2;
    
    parameter Integer i = 1;
    Real x = f(i) + f2(x);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="BlockTest25",
        description="Nominal with global constant in record",
        template="$C_dae_blocks_residual_functions$",
        variability_propagation=false,
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(1.0, jmi_max(jmi_abs(jmi_array_rec_1(JMI_GLOBAL(CCodeGenTests_BlockTest25_f_p), _i_0)->y), 1.0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = jmi_array_rec_1(JMI_GLOBAL(CCodeGenTests_BlockTest25_f_p), _i_0)->y + func_CCodeGenTests_BlockTest25_f2_exp0(_x_1) - (_x_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end BlockTest25;

model NestedUnsolvedScalarInSolvedBlock
    Real a;
    Real b;
    Real c;
equation
    when time > 0.5 then
        a = time;
        c = pre(a) + b;
    end when;
    a = asin(b);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="NestedUnsolvedScalarInSolvedBlock",
        description="Test correct block numbering for unsolved scalar block inside a solved part of a block",
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
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = asin(_b_1) - (_a_0);
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
        x[0] = 3;
        x[1] = 0;
        x[2] = 4;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (0.5), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_3 = _sw(0);
        }
        _a_0 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3)), JMI_TRUE, _time, pre_a_0);
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        _c_2 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3)), JMI_TRUE, pre_a_0 + _b_1, pre_c_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"1.1\", 0);
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 0, 3, 2, 1, 1, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end NestedUnsolvedScalarInSolvedBlock;



model InactiveBlockSwitch1
    function F
        input Real i1[:];
        output Real o1;
    algorithm
        o1 := sum(i1 .* 42);
        annotation(Inline=false);
    end F;
    Real a,b,c;
equation
    a = time + 3.14;
    b = if F({a, 1}) < 6.28 then c else -c;
    c = b + 42;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="InactiveBlockSwitch1",
        description="Test code gen for inactive block switches that need temp variables",
        template="
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _a_0 = _time + 3.14;
    if (jmi->atInitial || jmi->atEvent) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_ref_1(tmp_1, 1) = _a_0;
        jmi_array_ref_1(tmp_1, 2) = 1.0;
        _sw(0) = jmi_turn_switch(jmi, func_CCodeGenTests_InactiveBlockSwitch1_F_exp0(tmp_1) - (6.28), _sw(0), JMI_REL_LT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
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
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 42;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _c_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 1;
            int n2 = 1;
            Q1[0] = - COND_EXP_EQ(_sw(0), JMI_TRUE, 1.0, -1.0);
            for (i = 0; i < 1; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            Q2[0] = -1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _c_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
            JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
            jmi_array_ref_1(tmp_2, 1) = _a_0;
            jmi_array_ref_1(tmp_2, 2) = 1.0;
            _sw(0) = jmi_turn_switch(jmi, func_CCodeGenTests_InactiveBlockSwitch1_F_exp0(tmp_2) - (6.28), _sw(0), JMI_REL_LT);
        }
        _b_1 = COND_EXP_EQ(_sw(0), JMI_TRUE, _c_2, - _c_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _b_1 + 42 - (_c_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end InactiveBlockSwitch1;


model ActiveBlockSwitch1
    parameter Real p1(fixed=false);
    parameter Boolean p2(fixed=false);
initial equation
    p1 = if p2 then 1 else 2;
    p2 = p1*p1 > time;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="ActiveBlockSwitch1",
        description="Test code gen for inactive block switches that need temp variables",
        template="$C_dae_init_blocks_residual_functions$",
        generatedCode="
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870913;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870913;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw_init + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _p1_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _p1_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw_init(0) = jmi_turn_switch_time(jmi, _p1_0 * _p1_0 - (_time), _sw_init(0), JMI_REL_GT);
            }
            _p2_1 = _sw_init(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_p2_1, JMI_TRUE, 1.0, 2.0) - (_p1_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end ActiveBlockSwitch1;

model OutputTest1

  output Real x_1(start=0.951858508368);
  output Real x_2(start=2.17691690118);
  output Real x_3(start=1.47982066619);
  output Real x_4(start=2.41568015438);
  output Real x_5(start=2.50288121643);
  output Real w_ode_1_1;
  Real w_ode_1_2;
  Real w_ode_1_3;
  output Real w_ode_2_1;
  Real w_ode_2_2;
  Real w_ode_2_3;
  output Real w_ode_3_1;
  Real w_ode_3_2;
  Real w_ode_3_3;
  output Real w_ode_4_1;
  Real w_ode_4_2;
  Real w_ode_4_3;
  output Real w_ode_5_1;
  Real w_ode_5_2;
  Real w_ode_5_3;
  output Real w_output_1_1;
  output Real w_output_1_2;
  output Real w_output_1_3;
  output Real w_output_2_1;
  output Real w_output_2_2;
  output Real w_output_2_3;
  output Real w_output_3_1;
  output Real w_output_3_2;
  output Real w_output_3_3;
  output Real w_output_4_1;
  output Real w_output_4_2;
  output Real w_output_4_3;
  output Real w_output_5_1;
  output Real w_output_5_2;
  output Real w_output_5_3;
  output Real w_output_6_1;
  output Real w_output_6_2;
  output Real w_output_6_3;
  Real w_other_1_1;
  Real w_other_1_2;
  Real w_other_1_3;
  Real w_other_2_1;
  Real w_other_2_2;
  Real w_other_2_3;
  Real w_other_3_1;
  Real w_other_3_2;
  Real w_other_3_3;
  input Real ur_1;
  input Real ur_2;
  input Real ur_3;
  input Real ur_4;
  output Integer io1 = 1;
  output Boolean bo1 = true;
equation
(w_ode_1_1) + 4*(w_ode_1_2) + (w_ode_1_3) + sin(x_5) - (x_3) - 4*(x_5) + cos(ur_3) + 4*(ur_3) = 0;
cos(w_ode_1_1) + (w_ode_1_2)*sin(w_ode_1_3) + 4*(x_4) - 4*(x_5) - 4*(x_4) + (ur_4) + 4*(ur_1) = 0;
sin(w_ode_1_1) - sin(w_ode_1_2) - sin(w_ode_1_3) + 4*(x_2)*4*(x_3)*4*(x_3) + 4*(ur_3)*4*(ur_1) = 0;

der(x_1) = cos(w_ode_1_1)*(w_ode_1_2)*cos(w_ode_1_3) + 4*(x_2) + 4*(x_1) - (x_5) + 4*(ur_2) + cos(ur_4);

(w_ode_2_1)*sin(w_ode_2_2)*4*(w_ode_2_3) + (x_3) - (x_5) + sin(x_2) + (ur_3)*sin(ur_1) = 0;
4*(w_ode_2_1)*sin(w_ode_2_2) - cos(w_ode_2_3) + cos(x_4)*cos(x_3) - cos(x_3) + 4*(ur_1) - cos(ur_2) = 0;
(w_ode_2_1) - cos(w_ode_2_2) + cos(w_ode_2_3) + sin(x_4)*sin(x_1)*cos(x_4) + cos(ur_1)*sin(ur_1) = 0;

der(x_2) = sin(w_ode_2_1) - sin(w_ode_2_2) - sin(w_ode_2_3) + sin(w_ode_1_1) - sin(w_ode_1_2) - 4*(w_ode_1_3) + sin(x_1) + 4*(x_3) + (x_4) + (ur_2) + sin(ur_3);

4*(w_ode_3_1) - 4*(w_ode_3_2) + sin(w_ode_3_3) + (x_4) + cos(x_5) + 4*(x_3) + sin(ur_4)*cos(ur_1) = 0;
4*(w_ode_3_1) - (w_ode_3_2) + 4*(w_ode_3_3) + sin(x_2) - 4*(x_2) + (x_3) + 4*(ur_4) - 4*(ur_4) = 0;
4*(w_ode_3_1) + cos(w_ode_3_2)*cos(w_ode_3_3) + (x_3) + cos(x_2) + 4*(x_2) + cos(ur_1)*4*(ur_4) = 0;

der(x_3) = 4*(w_ode_3_1) - (w_ode_3_2)*(w_ode_3_3) + sin(w_ode_2_1) - cos(w_ode_2_2) - 4*(w_ode_2_3) + 4*(x_4) - 4*(x_2) - (x_2) + (ur_3)*4*(ur_4);

4*(w_ode_4_1)*(w_ode_4_2) - 4*(w_ode_4_3) + cos(x_1) - sin(x_2)*(x_2) + (ur_1) + 4*(ur_1) = 0;
4*(w_ode_4_1) + cos(w_ode_4_2) + sin(w_ode_4_3) + sin(x_2) + sin(x_4) + cos(x_3) + (ur_3) + sin(ur_2) = 0;
cos(w_ode_4_1)*sin(w_ode_4_2)*cos(w_ode_4_3) + cos(x_3) - cos(x_2) - (x_3) + (ur_3) - sin(ur_3) = 0;

der(x_4) = 4*(w_ode_4_1)*sin(w_ode_4_2)*4*(w_ode_4_3) + sin(w_ode_3_1) - (w_ode_3_2)*cos(w_ode_3_3) + cos(x_5) - (x_4) - (x_4) + (ur_1) + (ur_4);

4*(w_ode_5_1) + (w_ode_5_2)*(w_ode_5_3) + 4*(x_5) - 4*(x_4) + 4*(x_5) + (ur_3)*4*(ur_3) = 0;
(w_ode_5_1) + cos(w_ode_5_2)*(w_ode_5_3) + 4*(x_1) - sin(x_2) - sin(x_4) + cos(ur_2)*sin(ur_1) = 0;
cos(w_ode_5_1) + cos(w_ode_5_2)*cos(w_ode_5_3) + 4*(x_3) + (x_3)*4*(x_4) + cos(ur_3) + sin(ur_2) = 0;

der(x_5) = (w_ode_5_1) - sin(w_ode_5_2) + cos(w_ode_5_3) + 4*(w_ode_4_1) + cos(w_ode_4_2) - 4*(w_ode_4_3) + (x_3) - sin(x_2) + sin(x_2) + (ur_2)*sin(ur_4);

cos(w_output_1_1) - 4*(w_output_1_2)*cos(w_output_1_3) + sin(x_3)*4*(x_4) - (x_5) + cos(ur_1)*4*(ur_3) = 0;
(w_output_1_1) + sin(w_output_1_2) + cos(w_output_1_3) + 4*(x_5) + sin(x_5)*(x_2) + sin(ur_1) - cos(ur_4) = 0;
cos(w_output_1_1) + sin(w_output_1_2) - sin(w_output_1_3) + sin(x_2) - (x_3) + cos(x_5) + 4*(ur_1) + 4*(ur_4) = 0;

sin(w_output_2_1)*4*(w_output_2_2) + cos(w_output_2_3) + 4*(x_4)*cos(x_5) - (x_2) + cos(ur_2)*cos(ur_2) = 0;
(w_output_2_1) - cos(w_output_2_2) + 4*(w_output_2_3) + (x_4) + cos(x_1) - cos(x_5) + sin(ur_3) + (ur_2) = 0;
cos(w_output_2_1)*cos(w_output_2_2)*sin(w_output_2_3) + (x_2) - (x_2)*sin(x_5) + cos(ur_2)*sin(ur_2) = 0;

4*(w_output_3_1) + sin(w_output_3_2) + (w_output_3_3) + (x_4) - cos(x_4)*cos(x_1) + sin(ur_3) + cos(ur_1) = 0;
cos(w_output_3_1) + sin(w_output_3_2)*(w_output_3_3) + sin(x_5) - cos(x_5) - 4*(x_5) + 4*(ur_3) - cos(ur_2) = 0;
cos(w_output_3_1) + 4*(w_output_3_2) - sin(w_output_3_3) + cos(x_3) + cos(x_3) - sin(x_1) + 4*(ur_3) + 4*(ur_4) = 0;

cos(w_output_4_1) + sin(w_output_4_2) + (w_output_4_3) + 4*(x_3)*(x_5)*cos(x_2) + cos(ur_4) - 4*(ur_3) = 0;
4*(w_output_4_1)*sin(w_output_4_2)*sin(w_output_4_3) + (x_1) + sin(x_1)*cos(x_1) + sin(ur_2) - 4*(ur_3) = 0;
sin(w_output_4_1) + 4*(w_output_4_2)*sin(w_output_4_3) + (x_2) + (x_3)*(x_3) + (ur_2) + sin(ur_1) = 0;

(w_output_5_1) + (w_output_5_2) + sin(w_output_5_3) + sin(x_1)*(x_1) - sin(x_3) + (ur_1) + sin(ur_4) = 0;
(w_output_5_1) - sin(w_output_5_2) + (w_output_5_3) + sin(x_4)*sin(x_2) + sin(x_4) + sin(ur_4) + cos(ur_3) = 0;
4*(w_output_5_1) - (w_output_5_2) + (w_output_5_3) + cos(x_1)*(x_1)*sin(x_1) + 4*(ur_4) + sin(ur_4) = 0;

cos(w_output_6_1)*(w_output_6_2) + 4*(w_output_6_3) + cos(x_1)*(x_2)*cos(x_2) + 4*(ur_4) - sin(ur_3) = 0;
(w_output_6_1)*sin(w_output_6_2) + (w_output_6_3) + sin(x_4) - (x_4)*(x_4) + cos(ur_2) + (ur_4) = 0;
4*(w_output_6_1) - 4*(w_output_6_2)*sin(w_output_6_3) + sin(x_5) + sin(x_4)*(x_2) + (ur_3) - (ur_1) = 0;

(w_other_1_1) + cos(w_other_1_2) - (w_other_1_3) + cos(x_2) - 4*(x_5) - 4*(x_2) + (ur_3) + 4*(ur_1) = 0;
(w_other_1_1) + 4*(w_other_1_2) + 4*(w_other_1_3) + 4*(x_1) - cos(x_3)*4*(x_2) + sin(ur_2) + 4*(ur_3) = 0;
cos(w_other_1_1)*(w_other_1_2) - sin(w_other_1_3) + sin(x_4) + cos(x_1)*sin(x_2) + (ur_3) - 4*(ur_3) = 0;

sin(w_other_2_1) - (w_other_2_2) + (w_other_2_3) + 4*(x_5) - 4*(x_4) - sin(x_5) + 4*(ur_4) - 4*(ur_4) = 0;
sin(w_other_2_1)*4*(w_other_2_2) + 4*(w_other_2_3) + sin(x_1) - cos(x_1) + cos(x_4) + sin(ur_2)*cos(ur_2) = 0;
sin(w_other_2_1) + sin(w_other_2_2) - (w_other_2_3) + 4*(x_1)*4*(x_4) - (x_4) + cos(ur_2) - sin(ur_2) = 0;

4*(w_other_3_1) + sin(w_other_3_2)*4*(w_other_3_3) + (x_2) + cos(x_2) - (x_5) + 4*(ur_1) - 4*(ur_1) = 0;
4*(w_other_3_1)*(w_other_3_2) + (w_other_3_3) + cos(x_3) + sin(x_2) + 4*(x_1) + (ur_2) - cos(ur_2) = 0;
cos(w_other_3_1)*4*(w_other_3_2) + (w_other_3_3) + 4*(x_4) - sin(x_4) + (x_3) + 4*(ur_3) - cos(ur_4) = 0;


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="OutputTest1",
            description="Test of code generation of output value references.",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            template="
$n_outputs$
				   $C_DAE_output_vrefs$
",
            generatedCode="
30
				   static const int Output_vrefs[30] = {5,6,7,8,9,14,17,20,23,26,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,268435514,536870971};
")})));
end OutputTest1;


model StartValues1
  Real x(start=1);
  parameter Real y = 2;
  parameter Real z(start=3);
  Real q;
  
equation
  der(x) = x;
  q = x + 1;


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StartValues1",
            description="",
            variability_propagation=false,
            template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$
",
            generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_1 = (2);
    _z_2 = (3);
    _x_0 = (1);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end StartValues1;

model StartValues2
  parameter Real pr = 1.5;
  parameter Integer pi = 2;
  parameter Boolean pb = true;
  
  Real r(start=5.5);
  Integer i(start=10); 
  Boolean b(start=false);
  
equation
  der(r) = -r;
  i = integer(r) + 2;
  b = false;
  

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StartValues2",
            description="",
            variability_propagation=false,
            template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_variables$
",
            generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _pr_0 = (1.5);
    _pi_1 = (2);
    _pb_2 = (JMI_TRUE);
    _r_3 = (5.5);
    _i_4 = (10);
    _b_5 = (JMI_FALSE);
    pre_i_4 = (10);
    pre_b_5 = (JMI_FALSE);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end StartValues2;

model Smooth1
  Real y = time - 2;
  Real x = smooth(0, if y < 0 then 0 else y ^ 3);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Smooth1",
        description="",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = _time - 2 - (_y_0);
    (*res)[1] = (COND_EXP_EQ(_sw(0), JMI_TRUE, 0.0, (1.0 * (_y_0) * (_y_0) * (_y_0)))) - (_x_1);
")})));
end Smooth1;

model Smooth1_noEventOption
  Real y = time - 2;
  Real x = smooth(0, if y < 0 then 0 else y ^ 3);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Smooth1_noEventOption",
        description="",
        variability_propagation=false,
        disable_smooth_events=true,
        generate_ode=false,
        generate_dae=true,
        template="$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = _time - 2 - (_y_0);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LT(_y_0, 0.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, 0.0, (1.0 * (_y_0) * (_y_0) * (_y_0)))) - (_x_1);
")})));
end Smooth1_noEventOption;

model Homotopy1
    Real x,y;
equation
    x = homotopy(x * x,time);
    y = homotopy(y * x,time);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Homotopy1",
        description="",
        homotopy_type="homotopy",
        template="
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
        generatedCode="
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 2, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"1(Homotopy).1\", 0);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1(Homotopy)\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_2, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 2, \"1(Simplified).1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_3, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 3, \"1(Simplified).2\", -1);

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (_x_0 * _x_0) - (_x_0);
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
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (_y_1 * _x_0) - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


static int dae_init_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1(Homotopy).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (__homotopy_lambda * (_y_1 * _x_0) + (1 - __homotopy_lambda) * (_time)) - (_y_1);
            (*res)[1] = (__homotopy_lambda * (_x_0 * _x_0) + (1 - __homotopy_lambda) * (_time)) - (_x_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1(Homotopy) *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[1]);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_init_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1(Simplified).1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (_time) - (_y_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_init_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1(Simplified).2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (_time) - (_x_0);
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


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    /* Start of section for simplified version of homotopy*/
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[2]);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[3]);
    /* End of section for simplified version of homotopy*/
    ef |= jmi_solve_block_with_homotopy_residual(jmi->dae_init_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Homotopy1;


model CFloor1
	parameter Real x = 2.4;
	Real y = floor(x);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFloor1",
            description="C code generation for floor() operator",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    (*res)[0] = floor(_x_0) - (_y_1);
")})));
end CFloor1;


model TearingTest1
	
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TearingTest1",
        description="Test code generation of torn blocks",
        generate_ode=true,
        equation_sorting=true,
        automatic_tearing=true,
        variability_propagation=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 11;
        x[1] = 12;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 10;
        x[1] = 6;
        x[2] = 7;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(1.0, jmi_abs(_R3_10));
        (*res)[1] = jmi_max(1.0, jmi_abs(_R2_9));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _i2_5;
        x[1] = _i3_6;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(6, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 3;
            int n2 = 2;
            Q1[0] = -1.0;
            Q1[3] = -1.0;
            for (i = 0; i < 6; i += 3) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
                Q1[i + 1] = (Q1[i + 1] - ((- _R1_8)) * Q1[i + 0]) / (1.0);
                Q1[i + 2] = (Q1[i + 2] - (-1.0) * Q1[i + 1]) / (-1.0);
            }
            Q2[4] = 1.0;
            Q2[5] = 1.0;
            memset(Q3, 0, 4 * sizeof(jmi_real_t));
            Q3[1] = (- _R2_9);
            Q3[2] = (- _R3_10);
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _i2_5 = x[0];
            _i3_6 = x[1];
        }
        _i1_4 = _i2_5 + _i3_6;
        _u1_0 = _R1_8 * _i1_4;
        _u2_1 = _uL_2 - _u1_0;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _R3_10 * _i3_6 - (_u2_1);
            (*res)[1] = _R2_9 * _i2_5 - (_u2_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end TearingTest1;

model TearingTest2
 parameter Real m = 1;
 parameter Real f0 = 1;
 parameter Real f1 = 1;
 Real v;
 Real a;
 Real f;
 Real u;
 Real sa;
 Boolean startFor(start=false);
 Boolean startBack(start=false);
 Integer mode(start=2);
 Real dummy;
equation 
 der(dummy) = 1;
 u = 2*sin(time);
 m*der(v) = u - f;
 der(v) = a + 1;
 startFor = pre(mode)==2 and sa > 1;
 startBack = pre(mode) == 2 and sa < -1;
 a = if pre(mode) == 1 or startFor then sa-1 else 
     if pre(mode) == 3 or startBack then 
     sa + 1 else 0;
 f = if pre(mode) == 1 or startFor then 
     f0 + f1*v else 
     if pre(mode) == 3 or startBack then 
     -f0 + f1*v else f0*sa;
 mode=if (pre(mode) == 1 or startFor)
      and v>0 then 1 else 
      if (pre(mode) == 3 or startBack)
          and v<0 then 3 else 2;


annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TearingTest2",
        description="Test of code generation of torn mixed linear block",
        generate_ode=true,
        equation_sorting=true,
        eliminate_linear_equations=false,
        variability_propagation=false,
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 4;
        x[2] = 8;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870927;
        x[2] = 268435469;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870927;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_m_0), jmi_max(1.0, 1.0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _sa_7;
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
            Q1[0] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 1.0, 0.0));
            Q1[2] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 0.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 0.0, _f0_1));
            for (i = 0; i < 3; i += 3) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (1.0);
                Q1[i + 2] = (Q1[i + 2]) / (1.0);
            }
            Q2[1] = _m_0;
            Q2[2] = 1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _sa_7 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _sa_7 - (1), _sw(0), JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _sa_7 - (-1), _sw(1), JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(2), JMI_REL_GT);
            }
            if (LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2))) {
            } else {
                if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                    _sw(3) = jmi_turn_switch(jmi, _v_3 - (0.0), _sw(3), JMI_REL_LT);
                }
            }
            _mode_10 = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2)), JMI_TRUE, 1.0, COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), _sw(3)), JMI_TRUE, 3.0, 2.0));
        }
        _a_4 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + 1.0, 0.0));
        _der_v_16 = _a_4 + 1;
        _f_5 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7));
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _u_6 - _f_5 - (_m_0 * _der_v_16);
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
        x[0] = 10;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 4;
        x[2] = 8;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870927;
        x[1] = 536870926;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870927;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = jmi_max(jmi_abs(_m_0), jmi_max(1.0, 1.0));
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _sa_7;
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
            Q1[0] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 1.0, 0.0));
            Q1[2] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, 0.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, 0.0, _f0_1));
            for (i = 0; i < 3; i += 3) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
                Q1[i + 1] = (Q1[i + 1] - (-1.0) * Q1[i + 0]) / (1.0);
                Q1[i + 2] = (Q1[i + 2]) / (1.0);
            }
            Q2[1] = _m_0;
            Q2[2] = 1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _sa_7 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _sa_7 - (-1), _sw(1), JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _sa_7 - (1), _sw(0), JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        _a_4 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - 1.0, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + 1.0, 0.0));
        _der_v_16 = _a_4 + 1;
        _f_5 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 1.0, JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, 3.0, JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7));
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _u_6 - _f_5 - (_m_0 * _der_v_16);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 3, 0, 3, 2, 0, 0, 2, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 3, 0, 2, 2, 0, 0, 2, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end TearingTest2;

model TearingTest3
    Real x,y;
    Boolean b;
equation
    y = x + 1;
    x = if b then 0 else y;
    b = x > 0;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TearingTest3",
        description="Test code generation of torn blocks",
        eliminate_linear_equations=false,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        residual[1] = - COND_EXP_EQ(_b_2, JMI_TRUE, 0.0, 1.0);
        residual[2] = -1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (0), _sw(0), JMI_REL_GT);
            }
            _b_2 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 1 - (_y_1);
            (*res)[1] = COND_EXP_EQ(_b_2, JMI_TRUE, 0.0, _y_1) - (_x_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end TearingTest3;

model LinearTearingTest1
    function F
        input Real i1;
        output Boolean o1;
        output Integer o2;
    algorithm
        o1 := i1 > 3.14;
        o2 := 1;
    annotation(Inline=false);
    end F;
    parameter Real p1[:] = {1.0};
    Real x1,x2,x3(start=2),x4[1];
    Boolean b1;
    Integer i1;
equation
    x3 = x2 * 1.1;
    x2 = x1 * 2 + x3;
    x1 = if b1 then x4[i1] else 0;
    (b1, i1) = F(x3);
    x4[1] = if b1 then 3.14 else 6.28;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="LinearTearingTest1",
        description="Ensure that temporary variables are declared and initialized for jacobian",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(BOO, tmp_1)
    JMI_DEF(INT, tmp_2)
    if (evaluation_mode == JMI_BLOCK_START) {
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_START_SET) {
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
        x[1] = 268435463;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
        x[1] = 268435463;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 6.28;
        (*res)[1] = 1.1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x4_1_4;
        x[1] = _x3_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1)
            jmi_real_t* Q1 = calloc(4, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(4, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 2;
            int n2 = 2;
            if (_b1_5) {
                JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 1, 1, 1)
                jmi_array_ref_1(tmp_4, 1) = 1.0;
            } else {
            }
            Q1[0] = - COND_EXP_EQ(_b1_5, JMI_TRUE, jmi_array_val_1(tmp_4, _i1_6), 0.0);
            Q1[3] = -1.0;
            for (i = 0; i < 4; i += 2) {
                if (_b1_5) {
                    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
                    jmi_array_ref_1(tmp_3, 1) = 0.0;
                } else {
                }
                Q1[i + 0] = (Q1[i + 0]) / (1.0 - COND_EXP_EQ(_b1_5, JMI_TRUE, jmi_array_val_1(tmp_3, _i1_6), 0.0));
                Q1[i + 1] = (Q1[i + 1] - (-2) * Q1[i + 0]) / (1.0);
            }
            Q2[3] = -1.1;
            memset(Q3, 0, 4 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            Q3[3] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x4_1_4 = x[0];
            _x3_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            func_CCodeGenTests_LinearTearingTest1_F_def0(_x3_3, &tmp_1, &tmp_2);
            _b1_5 = (tmp_1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _i1_6 = (tmp_2);
        }
        _x1_1 = COND_EXP_EQ(_b1_5, JMI_TRUE, (&_x4_1_4)[(int)(_i1_6 - 1)], 0.0);
        _x2_2 = _x1_1 * 2 + _x3_3;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_b1_5, JMI_TRUE, 3.14, 6.28) - (_x4_1_4);
            (*res)[1] = _x2_2 * 1.1 - (_x3_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end LinearTearingTest1;

model MapTearingTest1

  function F
    input Real x;
    input Integer[2] map;
    output Real y;
  algorithm
    y := x + 1;
  end F;
  Integer[2] map = {1,2};
  Real x, y;
equation
  x = y + 1;
  y = F(x, map);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="MapTearingTest1",
        description="Test code generation of torn blocks",
        generate_ode=true,
        equation_sorting=true,
        automatic_tearing=true,
        variability_propagation=false,
        inline_functions="none",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        memcpy(&jmi_array_ref_1(tmp_1, 1), &_map_1_0, 2 * sizeof(jmi_real_t));
        _y_3 = func_CCodeGenTests_MapTearingTest1_F_exp0(_x_2, tmp_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_3 + 1 - (_x_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end MapTearingTest1;

model RecordTearingTest1
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real a;
  Real b;
  Real c;
  Real d;
  Real e;
  Real f;
equation
  (c,d) = F(a,b);
  (e,f) = F(c,d);
  (a,b) = F(e,f);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordTearingTest1",
            description="",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    JMI_DEF(REA, tmp_5)
    JMI_DEF(REA, tmp_6)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 1;
        x[2] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 3;
        x[2] = 4;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
        (*res)[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _f_5;
        x[1] = _b_1;
        x[2] = _a_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _f_5 = x[0];
            _b_1 = x[1];
            _a_0 = x[2];
        }
        func_CCodeGenTests_RecordTearingTest1_F_def0(_a_0, _b_1, &tmp_1, &tmp_2);
        _c_2 = (tmp_1);
        _d_3 = (tmp_2);
        func_CCodeGenTests_RecordTearingTest1_F_def0(_c_2, _d_3, &tmp_3, &tmp_4);
        _e_4 = (tmp_3);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_4 - (_f_5);
            func_CCodeGenTests_RecordTearingTest1_F_def0(_e_4, _f_5, &tmp_5, &tmp_6);
            (*res)[1] = tmp_6 - (_b_1);
            (*res)[2] = tmp_5 - (_a_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end RecordTearingTest1;

model RecordTearingTest2
	function F
		input Real a;
		input Real b;
		output Real c;
		output Real d;
	algorithm
		c := a + b;
		d := c - a;
	end F;
	Real x,y;
	
	constant Real c1 = 23;
equation
	(c1, c1) = F(x,y);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordTearingTest2",
            description="",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = (*res)[0];
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            func_CCodeGenTests_RecordTearingTest2_F_def0(_x_0, _y_1, &tmp_1, &tmp_2);
            (*res)[0] = tmp_1 - (_c1_2);
            (*res)[1] = tmp_2 - (_c1_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end RecordTearingTest2;

model TornMetaEquation1
    Real x;
    Real y;
    Real z;
    Real zz;
    Boolean b;
    
equation
    zz + y = 0.1;
    zz + z = 1;
    y + z = if b then time else -time;
    b = y - z > time;
    der(x) = 1;
    when b and not pre(b) then
        reinit(x, 1);
    end when;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TornMetaEquation1",
        description="",
        eliminate_linear_equations=false,
        template="
$C_dae_add_blocks_residual_functions$
$C_global_temps$
$C_dae_blocks_residual_functions$
",
        generatedCode="
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 2, 1, 0, 2, 2, 0, 0, 1, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

    jmi_real_t tmp_1;

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
        x[1] = 536870920;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870920;
        x[1] = 536870919;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z_2;
        x[1] = _y_1;
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
            Q1[1] = 1.0;
            for (i = 0; i < 2; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            Q2[0] = 1.0;
            memset(Q3, 0, 4 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            Q3[1] = 1.0;
            Q3[3] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z_2 = x[0];
            _y_1 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _y_1 - _z_2 - (_time), _sw(0), JMI_REL_GT);
            }
            _b_4 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _temp_1_5 = LOG_EXP_AND(_b_4, LOG_EXP_NOT(pre_b_4));
        }
        if (LOG_EXP_AND(_temp_1_5, LOG_EXP_NOT(pre_temp_1_5))) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                JMI_GLOBAL(tmp_1) = 1.0;
                if (JMI_GLOBAL(tmp_1) != _x_0) {
                    _x_0 = JMI_GLOBAL(tmp_1);
                    jmi->reinit_triggered = 1;
                }
            }
        }
        _zz_3 = - _y_1 + 0.1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 1 - (_zz_3 + _z_2);
            (*res)[1] = COND_EXP_EQ(_b_4, JMI_TRUE, _time, - _time) - (_y_1 + _z_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end TornMetaEquation1;



model MathSolve
	Real a[2,2] = [1,2;3,4];
    Real b[2] = {-2,3};
	Real x[2];
equation
	x = Modelica.Math.Matrices.solve(a, b);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="MathSolve",
        description="Using MSL function Modelica.Math.Matrices.solve",
        variability_propagation=false,
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_Modelica_Math_Matrices_solve_def0(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a);
void func_Modelica_Math_Matrices_LAPACK_dgesv_vec_def1(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a, jmi_real_t* info_o);

void func_Modelica_Math_Matrices_solve_def0(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, x_an, -1, 1)
    JMI_DEF(INT, info_v)
    if (x_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, x_an, jmi_array_size(b_a, 0), 1, jmi_array_size(b_a, 0))
        x_a = x_an;
    }
    func_Modelica_Math_Matrices_LAPACK_dgesv_vec_def1(A_a, b_a, x_a, &info_v);
    if (COND_EXP_EQ(info_v, 0.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"Solving a linear system of equations with function\\n\\\"Matrices.solve\\\" is not possible, because the system has either\\nno or infinitely many solutions (A is singular).\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_Modelica_Math_Matrices_LAPACK_dgesv_vec_def1(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a, jmi_real_t* info_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, x_an, -1, 1)
    JMI_DEF(INT, info_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, Awork_a, -1, 2)
    JMI_DEF(INT, lda_v)
    JMI_DEF(INT, ldb_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, ipiv_a, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    jmi_real_t i2_2i;
    jmi_int_t i2_2ie;
    jmi_int_t i2_2in;
    JMI_DEF(INT_EXT, tmp_1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_2, -1, 2)
    JMI_DEF(INT_EXT, tmp_3)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_4, -1, 1)
    JMI_DEF(INT_EXT, tmp_5)
    JMI_DEF(INT_EXT, tmp_6)
    extern void dgesv_(int*, int*, double*, int*, int*, double*, int*, int*);
    if (x_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, x_an, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
        x_a = x_an;
    }
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(A_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_ref_1(x_a, i1_0i) = jmi_array_val_1(b_a, i1_0i);
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, Awork_a, jmi_array_size(A_a, 0) * jmi_array_size(A_a, 0), 2, jmi_array_size(A_a, 0), jmi_array_size(A_a, 0))
    i1_1in = 0;
    i1_1ie = floor((jmi_array_size(A_a, 0)) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        i2_2in = 0;
        i2_2ie = floor((jmi_array_size(A_a, 0)) - (1));
        for (i2_2i = 1; i2_2in <= i2_2ie; i2_2i = 1 + (++i2_2in)) {
            jmi_array_ref_2(Awork_a, i1_1i, i2_2i) = jmi_array_val_2(A_a, i1_1i, i2_2i);
        }
    }
    lda_v = jmi_max(1.0, jmi_array_size(A_a, 0));
    ldb_v = jmi_max(1.0, jmi_array_size(b_a, 0));
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, ipiv_a, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
    tmp_1 = (int)1;
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_2, jmi_array_size(Awork_a, 0) * jmi_array_size(Awork_a, 1), 2, jmi_array_size(Awork_a, 0), jmi_array_size(Awork_a, 1))
    jmi_matrix_to_fortran_real(Awork_a, Awork_a->var, tmp_2->var);
    tmp_3 = (int)lda_v;
    JMI_ARRAY_INIT_1(HEAP, jmi_int_t, jmi_int_array_t, tmp_4, jmi_array_size(ipiv_a, 0), 1, jmi_array_size(ipiv_a, 0))
    jmi_matrix_to_fortran_int(ipiv_a, ipiv_a->var, tmp_4->var);
    tmp_5 = (int)ldb_v;
    tmp_6 = (int)info_v;
    dgesv_(&jmi_array_size(A_a, 0), &tmp_1, tmp_2->var, &tmp_3, tmp_4->var, x_a->var, &tmp_5, &tmp_6);
    info_v = tmp_6;
    JMI_RET(GEN, info_o, info_v)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end MathSolve;

model MathSolve2
	Real A[2,2] = [1,2;3,4];
	Real x_r[2] = {-2,3};
    Real b[2] = A*x_r;
    Real B[2,3] = [b, 2*b, -3*b];
    Real X[2,3];
equation
	X = Modelica.Math.Matrices.solve2(A, B);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="MathSolve2",
        description="Using MSL function Modelica.Math.Matrices.solve",
        variability_propagation=false,
        template="
$C_function_headers$
$C_functions$
",
        generatedCode="
void func_Modelica_Math_Matrices_solve2_def0(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a);
void func_Modelica_Math_Matrices_LAPACK_dgesv_def1(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a, jmi_real_t* info_o);

void func_Modelica_Math_Matrices_solve2_def0(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, X_an, -1, 2)
    JMI_DEF(INT, info_v)
    if (X_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, X_an, jmi_array_size(B_a, 0) * jmi_array_size(B_a, 1), 2, jmi_array_size(B_a, 0), jmi_array_size(B_a, 1))
        X_a = X_an;
    }
    func_Modelica_Math_Matrices_LAPACK_dgesv_def1(A_a, B_a, X_a, &info_v);
    if (COND_EXP_EQ(info_v, 0.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"Solving a linear system of equations with function\\n\\\"Matrices.solve2\\\" is not possible, because the system has either\\nno or infinitely many solutions (A is singular).\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_Modelica_Math_Matrices_LAPACK_dgesv_def1(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a, jmi_real_t* info_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, X_an, -1, 2)
    JMI_DEF(INT, info_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, Awork_a, -1, 2)
    JMI_DEF(INT, lda_v)
    JMI_DEF(INT, ldb_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, ipiv_a, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    jmi_real_t i2_3i;
    jmi_int_t i2_3ie;
    jmi_int_t i2_3in;
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_1, -1, 2)
    JMI_DEF(INT_EXT, tmp_2)
    JMI_ARR(HEAP, jmi_int_t, jmi_int_array_t, tmp_3, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, tmp_4, -1, 2)
    JMI_DEF(INT_EXT, tmp_5)
    JMI_DEF(INT_EXT, tmp_6)
    extern void dgesv_(int*, int*, double*, int*, int*, double*, int*, int*);
    if (X_a == NULL) {
        JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, X_an, jmi_array_size(A_a, 0) * jmi_array_size(B_a, 1), 2, jmi_array_size(A_a, 0), jmi_array_size(B_a, 1))
        X_a = X_an;
    }
    i1_0in = 0;
    i1_0ie = floor((jmi_array_size(A_a, 0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        i2_1in = 0;
        i2_1ie = floor((jmi_array_size(B_a, 1)) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_ref_2(X_a, i1_0i, i2_1i) = jmi_array_val_2(B_a, i1_0i, i2_1i);
        }
    }
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, Awork_a, jmi_array_size(A_a, 0) * jmi_array_size(A_a, 0), 2, jmi_array_size(A_a, 0), jmi_array_size(A_a, 0))
    i1_2in = 0;
    i1_2ie = floor((jmi_array_size(A_a, 0)) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        i2_3in = 0;
        i2_3ie = floor((jmi_array_size(A_a, 0)) - (1));
        for (i2_3i = 1; i2_3in <= i2_3ie; i2_3i = 1 + (++i2_3in)) {
            jmi_array_ref_2(Awork_a, i1_2i, i2_3i) = jmi_array_val_2(A_a, i1_2i, i2_3i);
        }
    }
    lda_v = jmi_max(1.0, jmi_array_size(A_a, 0));
    ldb_v = jmi_max(1.0, jmi_array_size(B_a, 0));
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, ipiv_a, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_1, jmi_array_size(Awork_a, 0) * jmi_array_size(Awork_a, 1), 2, jmi_array_size(Awork_a, 0), jmi_array_size(Awork_a, 1))
    jmi_matrix_to_fortran_real(Awork_a, Awork_a->var, tmp_1->var);
    tmp_2 = (int)lda_v;
    JMI_ARRAY_INIT_1(HEAP, jmi_int_t, jmi_int_array_t, tmp_3, jmi_array_size(ipiv_a, 0), 1, jmi_array_size(ipiv_a, 0))
    jmi_matrix_to_fortran_int(ipiv_a, ipiv_a->var, tmp_3->var);
    JMI_ARRAY_INIT_2(HEAP, jmi_real_t, jmi_array_t, tmp_4, jmi_array_size(X_a, 0) * jmi_array_size(X_a, 1), 2, jmi_array_size(X_a, 0), jmi_array_size(X_a, 1))
    jmi_matrix_to_fortran_real(X_a, X_a->var, tmp_4->var);
    tmp_5 = (int)ldb_v;
    tmp_6 = (int)info_v;
    dgesv_(&jmi_array_size(A_a, 0), &jmi_array_size(B_a, 1), tmp_1->var, &tmp_2, tmp_3->var, tmp_4->var, &tmp_5, &tmp_6);
    jmi_matrix_from_fortran_real(X_a, tmp_4->var, X_a->var);
    info_v = tmp_6;
    JMI_RET(GEN, info_o, info_v)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end MathSolve2;

model TestRuntimeOptions1
    Real x = 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRuntimeOptions1",
            description="Testing generation of runtime options map",
            generate_ode=true,
            generate_runtime_option_parameters=true,
            variability_propagation=false,
            cs_step_size=0.0011,
            template="
$C_runtime_option_map$
$C_variable_aliases$
$C_model_init_eval_independent_start$
",
            generatedCode="
const char *fmi_runtime_options_map_names[] = {
    \"_block_jacobian_check\",
    \"_block_jacobian_check_tol\",
    \"_block_solver_experimental_mode\",
    \"_block_solver_profiling\",
    \"_cs_experimental_mode\",
    \"_cs_rel_tol\",
    \"_cs_solver\",
    \"_cs_step_size\",
    \"_enforce_bounds\",
    \"_events_default_tol\",
    \"_events_tol_factor\",
    \"_iteration_variable_scaling\",
    \"_log_level\",
    \"_nle_active_bounds_mode\",
    \"_nle_brent_ignore_error\",
    \"_nle_jacobian_calculation_mode\",
    \"_nle_jacobian_finite_difference_delta\",
    \"_nle_jacobian_update_mode\",
    \"_nle_solver_check_jac_cond\",
    \"_nle_solver_default_tol\",
    \"_nle_solver_exit_criterion\",
    \"_nle_solver_max_iter\",
    \"_nle_solver_max_iter_no_jacobian\",
    \"_nle_solver_max_residual_scaling_factor\",
    \"_nle_solver_min_residual_scaling_factor\",
    \"_nle_solver_min_tol\",
    \"_nle_solver_regularization_tolerance\",
    \"_nle_solver_step_limit_factor\",
    \"_nle_solver_tol_factor\",
    \"_nle_solver_use_last_integrator_step\",
    \"_nle_solver_use_nominals_as_fallback\",
    \"_rescale_after_singular_jac\",
    \"_rescale_each_step\",
    \"_residual_equation_scaling\",
    \"_runtime_log_to_file\",
    \"_time_events_default_tol\",
    \"_use_Brent_in_1d\",
    \"_use_jacobian_equilibration\",
    \"_use_newton_for_brent\",
    NULL
};

const int fmi_runtime_options_map_vrefs[] = {
    536870938, 0, 268435470, 536870939, 268435471, 1, 268435472, 2, 536870940, 3,
    4, 268435473, 268435474, 268435475, 536870941, 268435476, 5, 268435477, 536870942, 6,
    268435478, 268435479, 268435480, 7, 8, 9, 10, 11, 12, 536870943,
    536870944, 536870945, 536870946, 268435481, 536870947, 13, 536870948, 536870949, 536870950, 0
};

const int fmi_runtime_options_map_length = 39;
#define __block_jacobian_check_tol_2 ((*(jmi->z))[0])
#define __cs_rel_tol_6 ((*(jmi->z))[1])
#define __cs_step_size_8 ((*(jmi->z))[2])
#define __events_default_tol_10 ((*(jmi->z))[3])
#define __events_tol_factor_11 ((*(jmi->z))[4])
#define __nle_jacobian_finite_difference_delta_17 ((*(jmi->z))[5])
#define __nle_solver_default_tol_20 ((*(jmi->z))[6])
#define __nle_solver_max_residual_scaling_factor_24 ((*(jmi->z))[7])
#define __nle_solver_min_residual_scaling_factor_25 ((*(jmi->z))[8])
#define __nle_solver_min_tol_26 ((*(jmi->z))[9])
#define __nle_solver_regularization_tolerance_27 ((*(jmi->z))[10])
#define __nle_solver_step_limit_factor_28 ((*(jmi->z))[11])
#define __nle_solver_tol_factor_29 ((*(jmi->z))[12])
#define __time_events_default_tol_36 ((*(jmi->z))[13])
#define __block_solver_experimental_mode_3 ((*(jmi->z))[14])
#define __cs_experimental_mode_5 ((*(jmi->z))[15])
#define __cs_solver_7 ((*(jmi->z))[16])
#define __iteration_variable_scaling_12 ((*(jmi->z))[17])
#define __log_level_13 ((*(jmi->z))[18])
#define __nle_active_bounds_mode_14 ((*(jmi->z))[19])
#define __nle_jacobian_calculation_mode_16 ((*(jmi->z))[20])
#define __nle_jacobian_update_mode_18 ((*(jmi->z))[21])
#define __nle_solver_exit_criterion_21 ((*(jmi->z))[22])
#define __nle_solver_max_iter_22 ((*(jmi->z))[23])
#define __nle_solver_max_iter_no_jacobian_23 ((*(jmi->z))[24])
#define __residual_equation_scaling_34 ((*(jmi->z))[25])
#define __block_jacobian_check_1 ((*(jmi->z))[26])
#define __block_solver_profiling_4 ((*(jmi->z))[27])
#define __enforce_bounds_9 ((*(jmi->z))[28])
#define __nle_brent_ignore_error_15 ((*(jmi->z))[29])
#define __nle_solver_check_jac_cond_19 ((*(jmi->z))[30])
#define __nle_solver_use_last_integrator_step_30 ((*(jmi->z))[31])
#define __nle_solver_use_nominals_as_fallback_31 ((*(jmi->z))[32])
#define __rescale_after_singular_jac_32 ((*(jmi->z))[33])
#define __rescale_each_step_33 ((*(jmi->z))[34])
#define __runtime_log_to_file_35 ((*(jmi->z))[35])
#define __use_Brent_in_1d_37 ((*(jmi->z))[36])
#define __use_jacobian_equilibration_38 ((*(jmi->z))[37])
#define __use_newton_for_brent_39 ((*(jmi->z))[38])
#define _x_0 ((*(jmi->z))[39])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define pre_x_0 ((*(jmi->z))[jmi->offs_pre_real_w+0])

int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    __block_jacobian_check_tol_2 = (1.0E-6);
    __cs_rel_tol_6 = (1.0E-6);
    __cs_step_size_8 = (0.0011);
    __events_default_tol_10 = (1.0E-10);
    __events_tol_factor_11 = (1.0E-4);
    __nle_jacobian_finite_difference_delta_17 = (1.490116119384766E-8);
    __nle_solver_default_tol_20 = (1.0E-10);
    __nle_solver_max_residual_scaling_factor_24 = (1.0E10);
    __nle_solver_min_residual_scaling_factor_25 = (1.0E-10);
    __nle_solver_min_tol_26 = (1.0E-12);
    __nle_solver_regularization_tolerance_27 = (-1.0);
    __nle_solver_step_limit_factor_28 = (10.0);
    __nle_solver_tol_factor_29 = (1.0E-4);
    __time_events_default_tol_36 = (2.220446049250313E-14);
    __iteration_variable_scaling_12 = (1);
    __log_level_13 = (3);
    __nle_jacobian_update_mode_18 = (2);
    __nle_solver_exit_criterion_21 = (3);
    __nle_solver_max_iter_22 = (100);
    __nle_solver_max_iter_no_jacobian_23 = (10);
    __residual_equation_scaling_34 = (1);
    __block_jacobian_check_1 = (JMI_FALSE);
    __block_solver_profiling_4 = (JMI_FALSE);
    __enforce_bounds_9 = (JMI_TRUE);
    __nle_brent_ignore_error_15 = (JMI_FALSE);
    __nle_solver_check_jac_cond_19 = (JMI_FALSE);
    __nle_solver_use_last_integrator_step_30 = (JMI_TRUE);
    __nle_solver_use_nominals_as_fallback_31 = (JMI_TRUE);
    __rescale_after_singular_jac_32 = (JMI_TRUE);
    __rescale_each_step_33 = (JMI_FALSE);
    __runtime_log_to_file_35 = (JMI_FALSE);
    __use_Brent_in_1d_37 = (JMI_TRUE);
    __use_jacobian_equilibration_38 = (JMI_FALSE);
    __use_newton_for_brent_39 = (JMI_TRUE);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRuntimeOptions1;



model TestEmptyArray1
	function f
		input Real d[:,:];
		output Real e;
	algorithm
		e := sum(size(d));
		e := e + 1;
	end f;
	
	parameter Real a[:, :] = fill(0.0,0,2);
	parameter Integer b[:] = 2:size(a, 2);
	parameter Boolean c = false;
	Real x = f(a);
	Real y = if c then a[1, b[1]] else 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestEmptyArray1",
            description="Test handling of empty arrays",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 0, 2)
    JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, tmp_1, 0, 2, 0, 2)
    (*res)[0] = func_CCodeGenTests_TestEmptyArray1_f_exp0(tmp_1) - (_x_2);
    (*res)[1] = 1 - (_y_3);
")})));
end TestEmptyArray1;

model VariableArrayIndex1
    Real table[:] = {42, 3.14};
    Integer i = if time > 1 then 1 else 2;
    Real x = table[i];

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex1",
        description="Test of variable array index access",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _i_2 = COND_EXP_EQ(_sw(0), JMI_TRUE, 1.0, 2.0);
    pre_i_2 = _i_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = 42.0;
    jmi_array_ref_1(tmp_1, 2) = 3.14;
    _x_3 = jmi_array_val_1(tmp_1, _i_2);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end VariableArrayIndex1;

model VariableArrayIndex2
    Real[3] x = {time,time+1,time+2};
    Real y = x[i];
    Integer i = integer(y) + 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex2",
        description="Test of variable array index access in block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435463;
        x[1] = 268435462;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435462;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
        jmi_array_ref_1(tmp_1, 1) = 0.0;
        jmi_array_ref_1(tmp_1, 2) = 0.0;
        jmi_array_ref_1(tmp_1, 3) = 0.0;
        residual[0] = 1.0 - jmi_array_val_1(tmp_1, _i_4);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_3 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _y_3 - (pre_temp_1_5), _sw(0), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _y_3 - (pre_temp_1_5 + 1.0), _sw(1), JMI_REL_GEQ);
            }
            _temp_1_5 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_y_3), pre_temp_1_5);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _i_4 = _temp_1_5 + 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (&_x_1_0)[(int)(_i_4 - 1)] - (_y_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end VariableArrayIndex2;

model VariableArrayIndex3
    Real[3] x = {time,time+1,time+2};
    Real y;
    Integer i = integer(y) + 1;
algorithm
    y := x[i];

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex3",
        description="Test of variable array index access in block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435463;
        x[1] = 268435462;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435462;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 1;
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
                _sw(0) = jmi_turn_switch(jmi, _y_3 - (pre_temp_1_5), _sw(0), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _y_3 - (pre_temp_1_5 + 1.0), _sw(1), JMI_REL_GEQ);
            }
            _temp_1_5 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_y_3), pre_temp_1_5);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _i_4 = _temp_1_5 + 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_1 = _y_3;
            _y_3 = (&_x_1_0)[(int)(_i_4 - 1)];
            JMI_SWAP(GEN, _y_3, tmp_1)
            (*res)[0] = tmp_1 - (_y_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end VariableArrayIndex3;

model VariableArrayIndex4
    Integer t = integer(time);
    Integer[3] x = {t+1,t+2,t+3};
    Real y;
    Integer i = integer(y) + 1;
equation
    y = x[x[i]];

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex4",
        description="Test of variable array index access in block",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435464;
        x[1] = 268435463;
        x[2] = 268435459;
        x[3] = 268435462;
        x[4] = 268435461;
        x[5] = 268435460;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435460;
        x[1] = 268435461;
        x[2] = 268435462;
        x[3] = 268435463;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_4;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
        jmi_array_ref_1(tmp_1, 1) = 0;
        jmi_array_ref_1(tmp_1, 2) = 0;
        jmi_array_ref_1(tmp_1, 3) = 0;
        residual[0] = 1.0 - jmi_array_val_1(tmp_1, (&_x_1_1)[(int)(_i_5 - 1)]);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_4 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _y_4 - (pre_temp_1_6), _sw(0), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _y_4 - (pre_temp_1_6 + 1.0), _sw(1), JMI_REL_GEQ);
            }
            _temp_1_6 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_y_4), pre_temp_1_6);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _i_5 = _temp_1_6 + 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch_time(jmi, _time - (pre_t_0), _sw(2), JMI_REL_LT);
            }
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(3) = jmi_turn_switch_time(jmi, _time - (pre_t_0 + 1.0), _sw(3), JMI_REL_GEQ);
            }
            _t_0 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(2), _sw(3)), _atInitial), JMI_TRUE, floor(_time), pre_t_0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _x_3_3 = _t_0 + 3;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _x_2_2 = _t_0 + 2;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _x_1_1 = _t_0 + 1;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = (&_x_1_1)[(int)((&_x_1_1)[(int)(_i_5 - 1)] - 1)] - (_y_4);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end VariableArrayIndex4;


model VariableArrayIndex5
    Real[3] y;
    Real x = time;
    Integer i = integer(time);
algorithm
    y[i] := x;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex5",
        description="Test of variable array index in LHS of algorithm",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre_i_4), _sw(0), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (pre_i_4 + 1.0), _sw(1), JMI_REL_GEQ);
    }
    _i_4 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_time), pre_i_4);
    pre_i_4 = _i_4;
    _x_3 = _time;
    (&_y_1_0)[(int)(_i_4 - 1)] = _x_3;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end VariableArrayIndex5;

model VariableArrayIndex6
    Real[3] y;
    Real[:] x = {time,time,time};
    Integer i = integer(time);
    Integer[:] is = {i-1,i-2,i-3};
algorithm
    y[is[i]] := x[is[i]];

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex6",
        description="Test of variable array index in LHS of algorithm",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (pre_i_4), _sw(0), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (pre_i_4 + 1.0), _sw(1), JMI_REL_GEQ);
    }
    _i_4 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_time), pre_i_4);
    pre_i_4 = _i_4;
    _is_1_5 = _i_4 + -1;
    pre_is_1_5 = _is_1_5;
    _is_2_6 = _i_4 + -2;
    pre_is_2_6 = _is_2_6;
    _is_3_7 = _i_4 + -3;
    pre_is_3_7 = _is_3_7;
    _x_2_3 = _time;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = _x_2_3;
    jmi_array_ref_1(tmp_1, 2) = _x_2_3;
    jmi_array_ref_1(tmp_1, 3) = _x_2_3;
    (&_y_1_0)[(int)((&_is_1_5)[(int)(_i_4 - 1)] - 1)] = jmi_array_val_1(tmp_1, (&_is_1_5)[(int)(_i_4 - 1)]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end VariableArrayIndex6;

model VariableArrayIndex7
    Real m[4,4];
    Integer i;
    Integer j;
equation
    when sample(0, 0.01) then
        if pre(i) == size(m, 1) then
            i = 1;
            j = mod(pre(j) + 1, size(m, 2));
        else
            i = pre(i) + 1;
            j = pre(j);
        end if;
    end when;
algorithm
    m[i,j] := time;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex7",
        description="Test of variable array index with multiple dimentions",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_19 + 1.0) * 0.01), _sw(3), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_19 * 0.01), _sw(2), JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, jmi_divide_equation(jmi, (pre_j_17 + 1.0), 4.0, \"(pre(j) + 1) / 4\") - (pre_temp_2_20), _sw(0), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, jmi_divide_equation(jmi, (pre_j_17 + 1.0), 4.0, \"(pre(j) + 1) / 4\") - (pre_temp_2_20 + 1.0), _sw(1), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    (&_m_1_1_0)[(int)(_j_17 - 1 + 4 * (_i_16 - 1))] = _time;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end VariableArrayIndex7;

model VariableArrayIndex8
    Real m[4,4];
    Integer i;
    Integer j;
    Real t = m[2,3];
equation
    when sample(0, 0.01) then
        if pre(i) == size(m, 1) then
            i = 1;
            j = mod(pre(j) + 1, size(m, 2));
        else
            i = pre(i) + 1;
            j = pre(j);
        end if;
    end when;
algorithm
    m[i,j] := time;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex8",
        description="Test of variable array index with multiple dimentions",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 16, 2)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch_time(jmi, _time - ((pre__sampleItr_1_19 + 1.0) * 0.01), _sw(3), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch_time(jmi, _time - (pre__sampleItr_1_19 * 0.01), _sw(2), JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, jmi_divide_equation(jmi, (pre_j_16 + 1.0), 4.0, \"(pre(j) + 1) / 4\") - (pre_temp_2_20), _sw(0), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, jmi_divide_equation(jmi, (pre_j_16 + 1.0), 4.0, \"(pre(j) + 1) / 4\") - (pre_temp_2_20 + 1.0), _sw(1), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, tmp_1, 16, 2, 4, 4)
    memcpy(&jmi_array_ref_2(tmp_1, 1,1), &_m_1_1_0, 6 * sizeof(jmi_real_t));
    jmi_array_ref_2(tmp_1, 2,3) = _t_17;
    memcpy(&jmi_array_ref_2(tmp_1, 2,4), &_m_2_4_6, 9 * sizeof(jmi_real_t));
    jmi_array_val_2(tmp_1, _i_15, _j_16) = _time;
    memcpy(&_m_1_1_0, &jmi_array_val_2(tmp_1, 1,1), 6 * sizeof(jmi_real_t));
    _t_17 = (jmi_array_val_2(tmp_1, 2,3));
    memcpy(&_m_2_4_6, &jmi_array_val_2(tmp_1, 2,4), 9 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end VariableArrayIndex8;

model VariableArrayIndex9
    Integer table[:] = {42, 3};
    Integer i = if time > 1 then 1 else 2;
    Real x = table[table[i]];

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="VariableArrayIndex9",
        description="Test of nested variable array index",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _i_2 = COND_EXP_EQ(_sw(0), JMI_TRUE, 1.0, 2.0);
    pre_i_2 = _i_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = 42;
    jmi_array_ref_1(tmp_1, 2) = 3;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = 42;
    jmi_array_ref_1(tmp_2, 2) = 3;
    _x_3 = jmi_array_val_1(tmp_2, jmi_array_val_1(tmp_1, _i_2));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end VariableArrayIndex9;

model TestRelationalOp1
Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
initial equation
 v1 = if time>=0 and time<=3 then 0 else 1;
 v2 = if time>0 then 0 else 1;
 v3 = if time<=0 and time <= 2 then 0 else 1;
 v4 = if time<0 then 0 else 1;
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = if y<=0 then 0 else 1;
 der(v2) = if y<0 then 0 else 1;
 der(v3) = if y>=0 then 0 else 1;
 der(v4) = if y>0 then 0 else 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp1",
            description="Test correct generation of all four relational operators",
            variability_propagation=false,
            template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
            generatedCode="
static const int N_initial_relations = 7;
static const int DAE_initial_relations[] = { JMI_REL_GEQ, JMI_REL_LEQ, JMI_REL_GT, JMI_REL_LEQ, JMI_REL_LEQ, JMI_REL_LT, JMI_REL_LT };
static const int N_relations = 4;
static const int DAE_relations[] = { JMI_REL_LEQ, JMI_REL_LT, JMI_REL_GEQ, JMI_REL_GT };
")})));
end TestRelationalOp1;

model TestRelationalOp2

Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = if y<=0 then 0 else 1;
 der(v2) = if y<0 then 0 else 1;
 der(v3) = if y>=0 then 0 else 1;
 der(v4) = if y>0 then 0 else 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp2",
            description="Test correct generation of all four relational operators",
            variability_propagation=false,
            template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
            generatedCode="
static const int N_initial_relations = 1;
static const int DAE_initial_relations[] = { JMI_REL_LT };
static const int N_relations = 4;
static const int DAE_relations[] = { JMI_REL_LEQ, JMI_REL_LT, JMI_REL_GEQ, JMI_REL_GT };
")})));
end TestRelationalOp2;

model TestRelationalOp3
Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
initial equation
 v1 = if time>=0 and time<=3 then 0 else 1;
 v2 = if time>0 then 0 else 1;
 v3 = if time<=0 and time <= 2 then 0 else 1;
 v4 = if time<0 then 0 else 1;
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = y;
 der(v2) = y;
 der(v3) = y;
 der(v4) = y;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp3",
            description="Test generation of all four relational operators.",
            variability_propagation=false,
            template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
            generatedCode="
static const int N_initial_relations = 7;
static const int DAE_initial_relations[] = { JMI_REL_GEQ, JMI_REL_LEQ, JMI_REL_GT, JMI_REL_LEQ, JMI_REL_LEQ, JMI_REL_LT, JMI_REL_LT };
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };
")})));
end TestRelationalOp3;

model TestRelationalOp4
  parameter Real p1 = 1;
  parameter Real p2 = if p1 >=1 then 1 else 2;
  Real x;
  Real y;
  Real z;
  Real w;
  Real r;
  discrete Real q1;
  discrete Real q2;
initial equation
  x = if time>=4 then 1 else 2;
  y = if noEvent(time>=2) then 2 else 5;
  z = if p1<=5 then 1 else 6;
equation
  der(x) = if time>=1 then 1 else 0; 
  der(y) = if noEvent(time>=1) then 1 else 0; 
  der(z) = if p1>=1 then 1 else 0; 
  der(w) = if 2>=1 then 1 else 0; 
  der(r) = if y>=3 then 1.0 else 0.0; 
  when x>=0.1 then 
    q1 = if pre(q1)>=0.5 then pre(q1) else 2*pre(q1);
    q2 = if w>=0.5 then pre(q2) else 2*pre(q2); 
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp4",
            description="Test correct event generation.",
            variability_propagation=false,
            relational_time_events=false,
            template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
            generatedCode="
static const int N_initial_relations = 1;
static const int DAE_initial_relations[] = { JMI_REL_GEQ };
static const int N_relations = 5;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ };
")})));
end TestRelationalOp4;

model TestRelationalOp5
  Real x;
  Real y;
  Real z;
equation
  der(x) = smooth(0,if x>=0 then x else 0); 
  der(y) = smooth(1,if y>=0 then y^2 else 0); 
  der(z) = smooth(2,if z>=0 then z^3 else 0); 

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp5",
        description="Test correct event generation in smooth operators.",
        generate_ode=true,
        equation_sorting=true,
        variability_propagation=false,
        template="
$C_DAE_initial_relations$
$C_DAE_relations$
$C_ode_derivatives$
",
        generatedCode="
static const int N_initial_relations = 0;
static const int DAE_initial_relations[] = { -1 };
static const int N_relations = 1;
static const int DAE_relations[] = { JMI_REL_GEQ };

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.0), _sw(0), JMI_REL_GEQ);
    }
    _der_x_3 = (COND_EXP_EQ(_sw(0), JMI_TRUE, _x_0, 0.0));
    _der_y_4 = (COND_EXP_EQ(COND_EXP_GE(_y_1, 0.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, (1.0 * (_y_1) * (_y_1)), 0.0));
    _der_z_5 = (COND_EXP_EQ(COND_EXP_GE(_z_2, 0.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, (1.0 * (_z_2) * (_z_2) * (_z_2)), 0.0));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp5;

model TestRelationalOp6
	type E = enumeration(a, b);
	parameter Real x = 3.14;
	E a = if x > 3 then E.a else E.b;
	E b = if x > 3 then E.b else E.a;
equation
	assert(String(a) < String(b), "Assertion error, " + String(a) + " < " + String(b));
	assert(String(b) > String(a), "Assertion error, " + String(b) + " > " + String(a));
	assert(String(a) == String(a), "Assertion error, " + String(a) + " == " + String(a));
	assert(String(a) <= String(b), "Assertion error, " + String(a) + " <= " + String(b));
	assert(String(a) <= String(a), "Assertion error, " + String(a) + " <= " + String(a));
	assert(String(b) >= String(a), "Assertion error, " + String(b) + " >= " + String(a));
	assert(String(a) >= String(a), "Assertion error, " + String(a) + " >= " + String(a));
	assert(String(a) <> String(b), "Assertion error, " + String(a) + " <> " + String(b));
	assert(String(b) <> String(a), "Assertion error, " + String(b) + " <> " + String(a));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp6",
            description="Test generation of relational operators when comparing strings.",
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    JMI_DEF_STR_STAT(tmp_1, 1)
    JMI_DEF_STR_STAT(tmp_2, 1)
    JMI_DEF_STR_STAT(tmp_3, 1)
    JMI_DEF_STR_STAT(tmp_4, 1)
    JMI_DEF_STR_STAT(tmp_5, 1)
    JMI_DEF_STR_STAT(tmp_6, 1)
    JMI_DEF_STR_STAT(tmp_7, 1)
    JMI_DEF_STR_STAT(tmp_8, 1)
    JMI_DEF_STR_STAT(tmp_9, 1)
    JMI_DEF_STR_STAT(tmp_10, 1)
    JMI_DEF_STR_STAT(tmp_11, 1)
    JMI_DEF_STR_STAT(tmp_12, 1)
    JMI_DEF_STR_STAT(tmp_13, 1)
    JMI_DEF_STR_STAT(tmp_14, 1)
    JMI_DEF_STR_STAT(tmp_15, 1)
    JMI_DEF_STR_STAT(tmp_16, 1)
    JMI_DEF_STR_STAT(tmp_17, 1)
    JMI_DEF_STR_STAT(tmp_18, 1)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_2)
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%-s\", E_0_e[(int) _b_2]);
    if (strcmp(tmp_1, tmp_2) < 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_19, 22)
        JMI_INI_STR_STAT(tmp_19)
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%s\", \" < \");
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%-s\", E_0_e[(int) _b_2]);
        jmi_assert_failed(tmp_19, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_3)
    snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), \"%-s\", E_0_e[(int) _b_2]);
    JMI_INI_STR_STAT(tmp_4)
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_3, tmp_4) > 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_20, 22)
        JMI_INI_STR_STAT(tmp_20)
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%-s\", E_0_e[(int) _b_2]);
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%s\", \" > \");
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_20, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_5)
    snprintf(JMI_STR_END(tmp_5), JMI_STR_LEFT(tmp_5), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_6)
    snprintf(JMI_STR_END(tmp_6), JMI_STR_LEFT(tmp_6), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_5, tmp_6) == 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_21, 23)
        JMI_INI_STR_STAT(tmp_21)
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%s\", \" == \");
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_21, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_7)
    snprintf(JMI_STR_END(tmp_7), JMI_STR_LEFT(tmp_7), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_8)
    snprintf(JMI_STR_END(tmp_8), JMI_STR_LEFT(tmp_8), \"%-s\", E_0_e[(int) _b_2]);
    if (strcmp(tmp_7, tmp_8) <= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_22, 23)
        JMI_INI_STR_STAT(tmp_22)
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%s\", \" <= \");
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%-s\", E_0_e[(int) _b_2]);
        jmi_assert_failed(tmp_22, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_9)
    snprintf(JMI_STR_END(tmp_9), JMI_STR_LEFT(tmp_9), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_10)
    snprintf(JMI_STR_END(tmp_10), JMI_STR_LEFT(tmp_10), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_9, tmp_10) <= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_23, 23)
        JMI_INI_STR_STAT(tmp_23)
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%s\", \" <= \");
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_23, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_11)
    snprintf(JMI_STR_END(tmp_11), JMI_STR_LEFT(tmp_11), \"%-s\", E_0_e[(int) _b_2]);
    JMI_INI_STR_STAT(tmp_12)
    snprintf(JMI_STR_END(tmp_12), JMI_STR_LEFT(tmp_12), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_11, tmp_12) >= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_24, 23)
        JMI_INI_STR_STAT(tmp_24)
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%-s\", E_0_e[(int) _b_2]);
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%s\", \" >= \");
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_24, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_13)
    snprintf(JMI_STR_END(tmp_13), JMI_STR_LEFT(tmp_13), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_14)
    snprintf(JMI_STR_END(tmp_14), JMI_STR_LEFT(tmp_14), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_13, tmp_14) >= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_25, 23)
        JMI_INI_STR_STAT(tmp_25)
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%s\", \" >= \");
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_25, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_15)
    snprintf(JMI_STR_END(tmp_15), JMI_STR_LEFT(tmp_15), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_16)
    snprintf(JMI_STR_END(tmp_16), JMI_STR_LEFT(tmp_16), \"%-s\", E_0_e[(int) _b_2]);
    if (strcmp(tmp_15, tmp_16) != 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_26, 23)
        JMI_INI_STR_STAT(tmp_26)
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%s\", \" <> \");
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%-s\", E_0_e[(int) _b_2]);
        jmi_assert_failed(tmp_26, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_17)
    snprintf(JMI_STR_END(tmp_17), JMI_STR_LEFT(tmp_17), \"%-s\", E_0_e[(int) _b_2]);
    JMI_INI_STR_STAT(tmp_18)
    snprintf(JMI_STR_END(tmp_18), JMI_STR_LEFT(tmp_18), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_17, tmp_18) != 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_27, 23)
        JMI_INI_STR_STAT(tmp_27)
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%-s\", E_0_e[(int) _b_2]);
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%s\", \" <> \");
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_27, JMI_ASSERT_ERROR);
    }
")})));
end TestRelationalOp6;

model TestRelationalOp7
    function f
        input Real[:] x;
        output Real y = sum(x);
      algorithm
    end f;
    
    Real y1,y2;
  initial equation
    y1 = integer(f({y1}));
    y2 = integer(f({y2}));
  equation
    when time > f({pre(y1)}) then
        y1 = 1;
    end when;
    when time > f({pre(y2)}) then
        y2 = 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp7",
            description="Test generation of temps in relational operators.",
            relational_time_events=false,
            template="
$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
            generatedCode="
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
    jmi_array_ref_1(tmp_1, 1) = pre_y1_0;
    (*res)[0] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_ref_1(tmp_2, 1) = pre_y2_1;
    (*res)[1] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_2));
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
    jmi_array_ref_1(tmp_1, 1) = pre_y1_0;
    (*res)[0] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_ref_1(tmp_2, 1) = pre_y2_1;
    (*res)[1] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_2));
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end TestRelationalOp7;

model TestRelationalOp8
  Real x;
equation
  x = if time>=1 and 1>=time or time>1 and 1>time or time<=1 and 1<=time or time<1 and 1<time then 1 else 0; 
  
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp8",
        description="Test correct event generation.",
        variability_propagation=false,
        relational_time_events=true,
        template="
$C_DAE_relations$
static const int N_sw = $n_state_switches$ + $n_time_switches$;

C_ode_time_events
$C_ode_time_events$

C_ode_derivatives
$C_ode_derivatives$
",
        generatedCode="
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };
static const int N_sw = 0 + 8;

C_ode_time_events
    jmi_real_t nSamp;
    if (SURELY_LT_ZERO(_time - (1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(_sw(0), JMI_TRUE, 1.0 - (_time), 1.0)) || (!jmi->eventPhase && ALMOST_ZERO(COND_EXP_EQ(_sw(0), JMI_TRUE, 1.0 - (_time), 1.0)))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_NOT(LOG_EXP_AND(_sw(0), _sw(1))), JMI_TRUE, _time - (1.0), 1.0)) || (!jmi->eventPhase && ALMOST_ZERO(COND_EXP_EQ(LOG_EXP_NOT(LOG_EXP_AND(_sw(0), _sw(1))), JMI_TRUE, _time - (1.0), 1.0)))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_NOT(LOG_EXP_AND(_sw(0), _sw(1))), _sw(2)), JMI_TRUE, 1.0 - (_time), 1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_AND(_sw(0), _sw(1)), LOG_EXP_AND(_sw(2), _sw(3)))), JMI_TRUE, _time - (1.0), 1.0)) || (!jmi->eventPhase && ALMOST_ZERO(COND_EXP_EQ(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_AND(_sw(0), _sw(1)), LOG_EXP_AND(_sw(2), _sw(3)))), JMI_TRUE, _time - (1.0), 1.0)))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_AND(_sw(0), _sw(1)), LOG_EXP_AND(_sw(2), _sw(3)))), _sw(4)), JMI_TRUE, 1.0 - (_time), 1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(0), _sw(1)), LOG_EXP_AND(_sw(2), _sw(3))), LOG_EXP_AND(_sw(4), _sw(5)))), JMI_TRUE, _time - (1.0), 1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, 1.0);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(0), _sw(1)), LOG_EXP_AND(_sw(2), _sw(3))), LOG_EXP_AND(_sw(4), _sw(5)))), _sw(6)), JMI_TRUE, 1.0 - (_time), 1.0)) || (!jmi->eventPhase && ALMOST_ZERO(COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_NOT(LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(0), _sw(1)), LOG_EXP_AND(_sw(2), _sw(3))), LOG_EXP_AND(_sw(4), _sw(5)))), _sw(6)), JMI_TRUE, 1.0 - (_time), 1.0)))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, 1.0);
    }


C_ode_derivatives

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(0), JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, 1.0 - (_time), _sw(1), jmi->eventPhase ? (JMI_REL_GT) : (JMI_REL_GEQ));
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(2), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch_time(jmi, 1.0 - (_time), _sw(3), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(4) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(4), jmi->eventPhase ? (JMI_REL_LT) : (JMI_REL_LEQ));
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(5) = jmi_turn_switch_time(jmi, 1.0 - (_time), _sw(5), JMI_REL_LEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(6) = jmi_turn_switch_time(jmi, _time - (1.0), _sw(6), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(7) = jmi_turn_switch_time(jmi, 1.0 - (_time), _sw(7), jmi->eventPhase ? (JMI_REL_LEQ) : (JMI_REL_LT));
    }
    _x_0 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(0), _sw(1)), LOG_EXP_AND(_sw(2), _sw(3))), LOG_EXP_AND(_sw(4), _sw(5))), LOG_EXP_AND(_sw(6), _sw(7))), JMI_TRUE, 1.0, 0.0);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp8;

model TestRelationalOp9
    function f
        input Real[:] x;
        output Real y;
      algorithm
        y := max(x);
    end f;
    Boolean b1 = time > f({1,2,3});
    Boolean b2 = sample(1,f({1,2,3}));
  
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp9",
        description="Test correct event generation. Temp in time event calculation.",
        variability_propagation=false,
        inline_functions="none",
        common_subexp_elim=false,
        template="
$C_DAE_relations$
static const int N_sw = $n_state_switches$ + $n_time_switches$;

C_ode_time_events
$C_ode_time_events$

C_ode_derivatives
$C_ode_derivatives$
",
        generatedCode="
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };
static const int N_sw = 0 + 3;

C_ode_time_events
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 3, 1)
    jmi_real_t nSamp;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    if (SURELY_LT_ZERO(_time - (func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_1))) || (!jmi->eventPhase && ALMOST_ZERO(_time - (func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_1))))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_1));
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1, 3)
    jmi_array_ref_1(tmp_2, 1) = 1.0;
    jmi_array_ref_1(tmp_2, 2) = 2.0;
    jmi_array_ref_1(tmp_2, 3) = 3.0;
    if (SURELY_LT_ZERO(COND_EXP_EQ(LOG_EXP_NOT(_atInitial), JMI_TRUE, _time - (1 + pre__sampleItr_1_2 * func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_2)), 1.0))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, 1 + pre__sampleItr_1_2 * func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_2));
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 3, 1, 3)
    jmi_array_ref_1(tmp_3, 1) = 1.0;
    jmi_array_ref_1(tmp_3, 2) = 2.0;
    jmi_array_ref_1(tmp_3, 3) = 3.0;
    if (SURELY_LT_ZERO(_time - (1.0 + (pre__sampleItr_1_2 + 1.0) * func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_3)))) {
        jmi_min_time_event(nextTimeEvent, 1, 0, 1.0 + (pre__sampleItr_1_2 + 1.0) * func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_3));
    }


C_ode_derivatives

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 3, 1, 3)
        jmi_array_ref_1(tmp_4, 1) = 1.0;
        jmi_array_ref_1(tmp_4, 2) = 2.0;
        jmi_array_ref_1(tmp_4, 3) = 3.0;
        _sw(0) = jmi_turn_switch_time(jmi, _time - (func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_4)), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _b1_0 = _sw(0);
    pre_b1_0 = _b1_0;
    if (jmi->atInitial || jmi->atEvent) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 3, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 3, 1, 3)
        jmi_array_ref_1(tmp_3, 1) = 1.0;
        jmi_array_ref_1(tmp_3, 2) = 2.0;
        jmi_array_ref_1(tmp_3, 3) = 3.0;
        _sw(2) = jmi_turn_switch_time(jmi, _time - (1.0 + (pre__sampleItr_1_2 + 1.0) * func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_3)), _sw(2), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 3, 1, 3)
        jmi_array_ref_1(tmp_2, 1) = 1.0;
        jmi_array_ref_1(tmp_2, 2) = 2.0;
        jmi_array_ref_1(tmp_2, 3) = 3.0;
        _sw(1) = jmi_turn_switch_time(jmi, _time - (1 + pre__sampleItr_1_2 * func_CCodeGenTests_TestRelationalOp9_f_exp0(tmp_2)), _sw(1), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp9;

model TestRelationalOp10
    function f
        input Real[:] x;
        output Real y;
      algorithm
        y := max(x);
    end f;
    parameter Real p = 0.1;
    Real x(nominal = f({0.1,0.5})) = 1 - time;
    Boolean b1 = time + p > x;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp10",
        description="Scaling event indicator",
        variability_propagation=false,
        inline_functions="none",
        common_subexp_elim=false,
        event_indicator_scaling=true,
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1 = 1 + (- _time);
    if (jmi->atInitial || jmi->atEvent) {
        JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_ref_1(tmp_1, 1) = 0.1;
        jmi_array_ref_1(tmp_1, 2) = 0.5;
        _sw(0) = jmi_turn_switch(jmi, (_time + _p_0 - (_x_1)) / jmi_max(jmi_max(1.0, jmi_abs(_p_0)), jmi_abs(func_CCodeGenTests_TestRelationalOp10_f_exp0(tmp_1))), _sw(0), JMI_REL_GT);
    }
    _b1_2 = _sw(0);
    pre_b1_2 = _b1_2;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp10;

model TestRelationalOp11
    Real x = time + 1;
    Boolean b = if (x > 1) then (x > 2) else ((x > 3) or (x > 4 and x > 5));
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp11",
        description="Guarded event indicators",
        template="$C_DAE_event_indicator_residuals$",
        generatedCode="
    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _x_0 - (1.0);
    (*res)[1] = COND_EXP_EQ(_sw(0), JMI_TRUE, _x_0 - (2.0), 1.0);
    (*res)[2] = COND_EXP_EQ(LOG_EXP_NOT(_sw(0)), JMI_TRUE, _x_0 - (3.0), 1.0);
    (*res)[3] = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_NOT(_sw(0)), LOG_EXP_NOT(_sw(2))), JMI_TRUE, _x_0 - (4.0), 1.0);
    (*res)[4] = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_AND(LOG_EXP_NOT(_sw(0)), LOG_EXP_NOT(_sw(2))), _sw(3)), JMI_TRUE, _x_0 - (5.0), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end TestRelationalOp11;

model TestRelationalOp12

    function f
        input Boolean[:] x;
        output Boolean y = x[1];
    algorithm
        annotation(Inline=false);
    end f;

    Real x = time + 1;
    Boolean b = f({x>4,x>4}) and x > 5;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp12",
        description="Guarded event indicators",
        template="
$C_DAE_event_indicator_residuals$
$C_ode_derivatives$
",
        generatedCode="
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    (*res)[0] = _x_0 - (4.0);
    (*res)[1] = _x_0 - (4.0);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _sw(0);
    jmi_array_ref_1(tmp_1, 2) = _sw(1);
    (*res)[2] = COND_EXP_EQ(func_CCodeGenTests_TestRelationalOp12_f_exp0(tmp_1), JMI_TRUE, _x_0 - (5), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    _x_0 = _time + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (4.0), _sw(0), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (4.0), _sw(1), JMI_REL_GT);
    }
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _sw(0);
    jmi_array_ref_1(tmp_2, 2) = _sw(1);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_0 - (5), _sw(2), JMI_REL_GT);
    }
    _b_1 = LOG_EXP_AND(func_CCodeGenTests_TestRelationalOp12_f_exp0(tmp_2), _sw(2));
    pre_b_1 = _b_1;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp12;

model TestRelationalOp13

    Boolean b3 = time > 3 and time > 1;
    Boolean b2 = time > 2 and b1;
    Boolean b1 = time > 1;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp13",
        description="Guarded event indicators",
        template="
$C_ode_time_events$
$C_ode_derivatives$
",
        generatedCode="
    jmi_real_t nSamp;
    if (SURELY_LT_ZERO(COND_EXP_EQ(_sw(2), JMI_TRUE, _time - (3), 1.0)) || (!jmi->eventPhase && ALMOST_ZERO(COND_EXP_EQ(_sw(2), JMI_TRUE, _time - (3), 1.0)))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, 3);
    }
    if (SURELY_LT_ZERO(COND_EXP_EQ(_b1_2, JMI_TRUE, _time - (2), 1.0)) || (!jmi->eventPhase && ALMOST_ZERO(COND_EXP_EQ(_b1_2, JMI_TRUE, _time - (2), 1.0)))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, 2);
    }
    if (SURELY_LT_ZERO(_time - (1)) || (!jmi->eventPhase && ALMOST_ZERO(_time - (1)))) {
        jmi_min_time_event(nextTimeEvent, 1, 1, 1);
    }


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (3), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch_time(jmi, _time - (1), _sw(2), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _b3_0 = LOG_EXP_AND(_sw(0), _sw(2));
    pre_b3_0 = _b3_0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch_time(jmi, _time - (1), _sw(2), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _b1_2 = _sw(2);
    pre_b1_2 = _b1_2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch_time(jmi, _time - (2), _sw(1), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _b2_1 = LOG_EXP_AND(_sw(1), _b1_2);
    pre_b2_1 = _b2_1;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp13;
model TestRelationalOp14
    function f
        input Real[1] X;
        output Real r;
    algorithm
        r := X[1];
    end f;
    Real a;
    Real b;
equation
    a = f({if b > 0.0 then b else -b});
    b = cos(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp14",
            description="Test inline bug which caused exception during code gen (related to switch index)",
            template="
$C_ode_time_events$
$C_ode_derivatives$
",
            generatedCode="

    jmi_real_t nSamp;




int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _b_1 = cos(_time);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _b_1 - (0.0), _sw(0), JMI_REL_GT);
    }
    _a_0 = COND_EXP_EQ(_sw(0), JMI_TRUE, _b_1, - _b_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp14;
model TestRelationalOp14B
    function f
        input Real[1] X;
        output Real r;
    algorithm
        r := X[1];
    annotation(LateInline=true);
    end f;
    Real a = f({if b > 0.0 then b else -b});
    Real b = cos(time);
    Real c = if b > 0.0 then b else -b;
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp14B",
            description="Test inline bug which caused exception during code gen (related to switch index)",
            template="
$C_ode_time_events$
$C_ode_derivatives$
",
            generatedCode="
    jmi_real_t nSamp;


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _b_1 = cos(_time);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _b_1 - (0.0), _sw(0), JMI_REL_GT);
    }
    _a_0 = COND_EXP_EQ(_sw(0), JMI_TRUE, _b_1, - _b_1);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _b_1 - (0.0), _sw(1), JMI_REL_GT);
    }
    _c_2 = COND_EXP_EQ(_sw(1), JMI_TRUE, _b_1, - _b_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestRelationalOp14B;
model TestRelationalOp15
    Real a = if sin(time) > 0 and cos(time) > 0 then 1 else time;
    Real b = if sin(time) > 0 and cos(time) > 0 then time else 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp15",
        description="Ensure that guards are generated correctly",
        template="
$C_ode_time_events$
$C_ode_derivatives$
$C_DAE_event_indicator_residuals$
",
        generatedCode="
    jmi_real_t nSamp;


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, sin(_time) - (0.0), _sw(0), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, cos(_time) - (0.0), _sw(1), JMI_REL_GT);
    }
    _a_0 = COND_EXP_EQ(LOG_EXP_AND(_sw(0), _sw(1)), JMI_TRUE, 1.0, _time);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, sin(_time) - (0.0), _sw(0), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, cos(_time) - (0.0), _sw(2), JMI_REL_GT);
    }
    _b_1 = COND_EXP_EQ(LOG_EXP_AND(_sw(0), _sw(2)), JMI_TRUE, _time, 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = sin(_time) - (0.0);
    (*res)[1] = COND_EXP_EQ(_sw(0), JMI_TRUE, cos(_time) - (0.0), 1.0);
    (*res)[2] = COND_EXP_EQ(_sw(0), JMI_TRUE, cos(_time) - (0.0), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end TestRelationalOp15;
model TestRelationalOp16
    Real a = if sin(time) > 0 and cos(time) > 0 and cos(time+0.5) > 0 then 1 else time;
    Real b = if sin(time) > 0 and cos(time) > 0 and cos(time+0.5) > 0 then time else 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestRelationalOp16",
        description="Ensure that guards are generated correctly",
        template="
$C_ode_time_events$
$C_ode_derivatives$
$C_DAE_event_indicator_residuals$
",
        generatedCode="
    jmi_real_t nSamp;


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, sin(_time) - (0.0), _sw(0), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, cos(_time) - (0.0), _sw(1), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, cos(_time + 0.5) - (0.0), _sw(2), JMI_REL_GT);
    }
    _a_0 = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_AND(_sw(0), _sw(1)), _sw(2)), JMI_TRUE, 1.0, _time);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, sin(_time) - (0.0), _sw(0), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(jmi, cos(_time) - (0.0), _sw(3), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(4) = jmi_turn_switch(jmi, cos(_time + 0.5) - (0.0), _sw(4), JMI_REL_GT);
    }
    _b_1 = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_AND(_sw(0), _sw(3)), _sw(4)), JMI_TRUE, _time, 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = sin(_time) - (0.0);
    (*res)[1] = COND_EXP_EQ(_sw(0), JMI_TRUE, cos(_time) - (0.0), 1.0);
    (*res)[2] = COND_EXP_EQ(LOG_EXP_AND(_sw(0), _sw(1)), JMI_TRUE, cos(_time + 0.5) - (0.0), 1.0);
    (*res)[3] = COND_EXP_EQ(_sw(0), JMI_TRUE, cos(_time) - (0.0), 1.0);
    (*res)[4] = COND_EXP_EQ(LOG_EXP_AND(_sw(0), _sw(3)), JMI_TRUE, cos(_time + 0.5) - (0.0), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end TestRelationalOp16;
model TestRelationalOp17
    Real x = sin(time);
    Boolean b(start = true);
initial equation
    b = x > 0.5;
equation
    when (not pre(b)) and x > 0.5 then
        b = true;
    elsewhen pre(b) and x < -0.5 then
        b = false;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp17",
            description="Ensure that switches in DAE isn't eliminated for switch in initDAE'",
            template="
$C_ode_derivatives$
$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
            generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = sin(_time);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (-0.5), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.5), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = COND_EXP_EQ(LOG_EXP_NOT(pre_b_1), JMI_TRUE, _x_0 - (0.5), 1.0);
    (*res)[1] = COND_EXP_EQ(pre_b_1, JMI_TRUE, _x_0 - (-0.5), 1.0);
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = COND_EXP_EQ(LOG_EXP_NOT(pre_b_1), JMI_TRUE, _x_0 - (0.5), 1.0);
    (*res)[1] = COND_EXP_EQ(pre_b_1, JMI_TRUE, _x_0 - (-0.5), 1.0);
    (*res)[2] = _x_0 - (0.5);
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end TestRelationalOp17;

model StringOperations1
	type E = enumeration(a, bb, ccc);
	
	function f
		input String x;
		output Real y;
	algorithm
		y := 1;
	end f;
	
	Real r = time;
	Boolean b = r < 2;
	E e = if b then E.bb else E.ccc;
	Integer i = Integer(e);
	Real dummy = f("x " + String(r) + " y " + String(b) + " z " + String(e) + " v " + String(i) + " w");

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="StringOperations1",
        description="Basic test of string concatenation and the String() operator, variable values",
        inline_functions="none",
        template="
$C_enum_strings$
$C_ode_derivatives$
",
        generatedCode="
static char* E_0_e[] = { \"\", \"a\", \"bb\", \"ccc\" };


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 44)
    _r_0 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _r_0 - (2), _sw(0), JMI_REL_LT);
    }
    _b_1 = _sw(0);
    pre_b_1 = _b_1;
    _e_2 = COND_EXP_EQ(_b_1, JMI_TRUE, 2.0, 3.0);
    pre_e_2 = _e_2;
    _i_3 = (_e_2);
    pre_i_3 = _i_3;
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"x \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _r_0);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" y \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-s\", COND_EXP_EQ(_b_1, JMI_TRUE, \"true\", \"false\"));
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" z \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-s\", E_0_e[(int) _e_2]);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" v \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-d\", (int) _i_3);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" w\");
    _dummy_4 = func_CCodeGenTests_StringOperations1_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end StringOperations1;


model StringOperations2
    type E = enumeration(a, bb, ccc);
    
    function f
        input String x;
        output Real y;
    algorithm
        y := 1;
    end f;
    
    Real dummy = f("x " + String(0.1234567) + " y " + String(true) + " z " + String(E.a) + " v " + String(42) + " w " + String(time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations2",
            description="Basic test of string concatenation and the String() operator, constant values",
            inline_functions="none",
            template="
$C_enum_strings$
$C_ode_derivatives$
",
            generatedCode="
static char* E_0_e[] = { \"\", \"a\", \"bb\", \"ccc\" };


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 42)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"x 0.123457 y true z a v 42 w \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    _dummy_0 = func_CCodeGenTests_StringOperations2_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end StringOperations2;


model StringOperations3
    type E = enumeration(a, bb, ccc);
    
    function f
        input String x;
        output Real y;
    algorithm
        y := 1;
    end f;
    
    constant String s = "x " + String(0.1234567) + " y " + String(true) + " z " + String(E.a) + " v " + String(42) + " w";
	Real dummy = f(s);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations3",
            description="Basic test of string concatenation and the String() operator, constant evaluation",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_enum_strings$
$C_ode_derivatives$
",
            generatedCode="
static char* E_0_e[] = { \"\", \"a\", \"bb\", \"ccc\" };


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _dummy_1 = func_CCodeGenTests_StringOperations3_f_exp0(\"x 0.123457 y true z a v 42 w\");
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end StringOperations3;


model StringOperations4
    function f
        input String s;
        output Real x;
    algorithm
        x := 1;
        f(s + "123");
    end f;
    
    Real y = f("abc" + String(time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations4",
            description="Basic test of string concatenation and the String() operator, using function inputs",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
void func_CCodeGenTests_StringOperations4_f_def0(jmi_string_t s_v, jmi_real_t* x_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, x_v)
    JMI_DEF_STR_DYNA(tmp_1)
    x_v = 1;
    JMI_INI_STR_DYNA(tmp_1, JMI_LEN(s_v) + 3)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", s_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"123\");
    func_CCodeGenTests_StringOperations4_f_def0(tmp_1, NULL);
    JMI_RET(GEN, x_o, x_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations4_f_exp0(jmi_string_t s_v) {
    JMI_DEF(REA, x_v)
    func_CCodeGenTests_StringOperations4_f_def0(s_v, &x_v);
    return x_v;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 16)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"abc\");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    _y_0 = func_CCodeGenTests_StringOperations4_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end StringOperations4;

model StringOperations5
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        s := "str";
        s := s;
        t := s;
        s := t + s;
    end f2;
    
    Real y = f2(-time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations5",
            description="Basic test of string assignments",
            inline_functions="none",
            variability_propagation=false,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_StringOperations5_f2_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(STR, s_v)
    JMI_DEF(STR, t_v)
    JMI_DEF_STR_DYNA(tmp_1)
    JMI_INI(STR, s_v)
    JMI_INI(STR, t_v)
    y_v = x_v;
    JMI_ASG(STR, s_v, \"str\")
    JMI_ASG(STR, s_v, s_v)
    JMI_ASG(STR, t_v, s_v)
    JMI_INI_STR_DYNA(tmp_1, JMI_LEN(t_v) + JMI_LEN(s_v))
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", t_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", s_v);
    JMI_ASG(STR, s_v, tmp_1)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations5_f2_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_StringOperations5_f2_def0(x_v, &y_v);
    return y_v;
}

")})));
end StringOperations5;

model StringOperations6
    function f1
        input String s;
        output String o;
        output Integer i;
      algorithm
        o := s;
        i := 1;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        s := "str";
        s := f1(s);
    end f2;
    
    Real y = f2(-time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations6",
            description="String return value in function call",
            inline_functions="none",
            variability_propagation=false,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_StringOperations6_f2_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(STR, s_v)
    JMI_DEF(STR, t_v)
    JMI_DEF(STR, tmp_1)
    JMI_INI(STR, s_v)
    JMI_INI(STR, t_v)
    y_v = x_v;
    JMI_ASG(STR, s_v, \"str\")
    tmp_1 = func_CCodeGenTests_StringOperations6_f1_exp1(s_v);
    JMI_ASG(STR, s_v, tmp_1)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations6_f2_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_StringOperations6_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations6_f1_def1(jmi_string_t s_v, jmi_string_t* o_o, jmi_real_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(STR, o_v)
    JMI_DEF(INT, i_v)
    JMI_INI(STR, o_v)
    JMI_ASG(STR, o_v, s_v)
    i_v = 1;
    JMI_RET(STR, o_o, o_v)
    JMI_RET(GEN, i_o, i_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_string_t func_CCodeGenTests_StringOperations6_f1_exp1(jmi_string_t s_v) {
    JMI_DEF(STR, o_v)
    func_CCodeGenTests_StringOperations6_f1_def1(s_v, &o_v, NULL);
    return o_v;
}

")})));
end StringOperations6;

model StringOperations7
    function f1
        input String s;
        output String o;
        output Integer i;
      algorithm
        o := s;
        i := 1;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        s := "str";
        (s,) := f1(s);
    end f2;
    
    Real y = f2(-time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations7",
            description="String return value in function call assignment",
            inline_functions="none",
            variability_propagation=false,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_StringOperations7_f2_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(STR, s_v)
    JMI_DEF(STR, t_v)
    JMI_DEF(STR, tmp_1)
    JMI_INI(STR, s_v)
    JMI_INI(STR, t_v)
    y_v = x_v;
    JMI_ASG(STR, s_v, \"str\")
    JMI_INI(STR, tmp_1)
    func_CCodeGenTests_StringOperations7_f1_def1(s_v, &tmp_1, NULL);
    JMI_ASG(STR, s_v, tmp_1)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations7_f2_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_StringOperations7_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations7_f1_def1(jmi_string_t s_v, jmi_string_t* o_o, jmi_real_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(STR, o_v)
    JMI_DEF(INT, i_v)
    JMI_INI(STR, o_v)
    JMI_ASG(STR, o_v, s_v)
    i_v = 1;
    JMI_RET(STR, o_o, o_v)
    JMI_RET(GEN, i_o, i_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_string_t func_CCodeGenTests_StringOperations7_f1_exp1(jmi_string_t s_v) {
    JMI_DEF(STR, o_v)
    func_CCodeGenTests_StringOperations7_f1_def1(s_v, &o_v, NULL);
    return o_v;
}

")})));
end StringOperations7;

model StringOperations8
    function f1
        input String s;
        output String o;
        output Integer i;
      algorithm
        o := s;
        i := 1;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        (s,) := f1("| " + f1(String(x)) + " ^_^ " + String(x) + " |");
        Modelica.Utilities.Streams.print(s);
    end f2;
    
    Real y = f2(-time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations8",
            description="String operator combinations",
            inline_functions="none",
            variability_propagation=false,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_StringOperations8_f2_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(STR, s_v)
    JMI_DEF(STR, t_v)
    JMI_DEF(STR, tmp_1)
    JMI_DEF_STR_STAT(tmp_2, 13)
    JMI_DEF(STR, tmp_3)
    JMI_DEF_STR_DYNA(tmp_4)
    JMI_INI(STR, s_v)
    JMI_INI(STR, t_v)
    y_v = x_v;
    JMI_INI(STR, tmp_1)
    JMI_INI_STR_STAT(tmp_2)
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%-.*g\", (int) 6, x_v);
    tmp_3 = func_CCodeGenTests_StringOperations8_f1_exp1(tmp_2);
    JMI_INI_STR_DYNA(tmp_4, 2 + JMI_LEN(tmp_3) + 5 + 7 + 6 + 2)
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", \"| \");
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", tmp_3);
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", \" ^_^ \");
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%-.*g\", (int) 6, x_v);
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", \" |\");
    func_CCodeGenTests_StringOperations8_f1_def1(tmp_4, &tmp_1, NULL);
    JMI_ASG(STR, s_v, tmp_1)
    func_Modelica_Utilities_Streams_print_def2(s_v, \"\");
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations8_f2_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_StringOperations8_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations8_f1_def1(jmi_string_t s_v, jmi_string_t* o_o, jmi_real_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(STR, o_v)
    JMI_DEF(INT, i_v)
    JMI_INI(STR, o_v)
    JMI_ASG(STR, o_v, s_v)
    i_v = 1;
    JMI_RET(STR, o_o, o_v)
    JMI_RET(GEN, i_o, i_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_string_t func_CCodeGenTests_StringOperations8_f1_exp1(jmi_string_t s_v) {
    JMI_DEF(STR, o_v)
    func_CCodeGenTests_StringOperations8_f1_def1(s_v, &o_v, NULL);
    return o_v;
}

void func_Modelica_Utilities_Streams_print_def2(jmi_string_t string_v, jmi_string_t fileName_v) {
    JMI_DYNAMIC_INIT()
    extern void ModelicaInternal_print(const char*, const char*);
    ModelicaInternal_print(string_v, fileName_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end StringOperations8;

model StringOperations9
    function f
        input Real x;
        input Integer i;
        input Boolean b;
        input String fmt;
        output Real y;
        String s;
      algorithm
        s := String(x, significantDigits=1, minimumLength=i, leftJustified=b)
        + String(x, significantDigits=i, minimumLength=2, leftJustified=b)
        + String(x, significantDigits=i, minimumLength=i, leftJustified=false)
        + String(x, significantDigits=i, minimumLength=i, leftJustified=b)
        + String(x, significantDigits=i, leftJustified=b)
        + String(x)
        + String(x, format=fmt)
        
        + String(i, minimumLength=2, leftJustified=b)
        + String(i, minimumLength=i, leftJustified=true)
        + String(i, minimumLength=i, leftJustified=b)
        + String(i, format=fmt)
        
        + String(b, minimumLength=2, leftJustified=b)
        + String(b, minimumLength=i, leftJustified=true)
        + String(b, minimumLength=i, leftJustified=b);
    end f;
    
    Real y = f(-time, 3, true, "%g");

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="StringOperations9",
        description="String operator unknown options",
        inline_functions="none",
        variability_propagation=false,
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_StringOperations9_f_def0(jmi_real_t x_v, jmi_real_t i_v, jmi_real_t b_v, jmi_string_t fmt_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(STR, s_v)
    JMI_DEF_STR_DYNA(tmp_1)
    JMI_INI(STR, s_v)
    JMI_INI_STR_DYNA(tmp_1, jmi_max(7 + 1.0, i_v) + jmi_max(7 + i_v, 2.0) + jmi_max(7 + i_v, i_v) + jmi_max(7 + i_v, i_v) + 7 + i_v + 7 + 6 + 16 + jmi_max(10, 2.0) + jmi_max(10, i_v) + jmi_max(10, i_v) + 16 + jmi_max(5, 2.0) + jmi_max(5, i_v) + jmi_max(5, i_v))
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) i_v, (int) 1.0, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) 2.0, (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(JMI_FALSE, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) i_v, (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-*.*g\", \"%*.*g\"), (int) i_v, (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-.*g\", \"%.*g\"), (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), fmt_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-*d\", \"%*d\"), (int) 2.0, (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(JMI_TRUE, JMI_TRUE, \"%-*d\", \"%*d\"), (int) i_v, (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-*d\", \"%*d\"), (int) i_v, (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), fmt_v, (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-*s\", \"%*s\"), (int) 2.0, COND_EXP_EQ(b_v, JMI_TRUE, \"true\", \"false\"));
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(JMI_TRUE, JMI_TRUE, \"%-*s\", \"%*s\"), (int) i_v, COND_EXP_EQ(b_v, JMI_TRUE, \"true\", \"false\"));
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), COND_EXP_EQ(b_v, JMI_TRUE, \"%-*s\", \"%*s\"), (int) i_v, COND_EXP_EQ(b_v, JMI_TRUE, \"true\", \"false\"));
    JMI_ASG(STR, s_v, tmp_1)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations9_f_exp0(jmi_real_t x_v, jmi_real_t i_v, jmi_real_t b_v, jmi_string_t fmt_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_StringOperations9_f_def0(x_v, i_v, b_v, fmt_v, &y_v);
    return y_v;
}

")})));
end StringOperations9;

model StringOperations10
    function f1
        input String[:] s;
        output String[size(s,1)] o;
      algorithm
        o := s;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String[2] s;
      algorithm
        y := x;
        s := {"str", "str"};
        s := f1(s);
    end f2;
    
    Real y = f2(-time);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="StringOperations10",
        description="String array return value in function call",
        inline_functions="none",
        variability_propagation=false,
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_StringOperations10_f2_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_ARR(STACK, jmi_string_t, jmi_string_array_t, s_a, 2, 1)
    JMI_ARR(STACK, jmi_string_t, jmi_string_array_t, temp_1_a, 2, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    JMI_ARR(STACK, jmi_string_t, jmi_string_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_string_t, jmi_string_array_t, s_a, 2, 1, 2)
    y_v = x_v;
    JMI_ARRAY_INIT_1(STACK, jmi_string_t, jmi_string_array_t, temp_1_a, 2, 1, 2)
    JMI_ASG(STR, jmi_array_ref_1(temp_1_a, 1), \"str\")
    JMI_ASG(STR, jmi_array_ref_1(temp_1_a, 2), \"str\")
    i1_0in = 0;
    i1_0ie = floor((2) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        JMI_ASG(STR, jmi_array_ref_1(s_a, i1_0i), jmi_array_val_1(temp_1_a, i1_0i))
    }
    JMI_ARRAY_INIT_1(STACK, jmi_string_t, jmi_string_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenTests_StringOperations10_f1_def1(s_a, tmp_1);
    JMI_ASG(STR_ARR, s_a, tmp_1)    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations10_f2_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_StringOperations10_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations10_f1_def1(jmi_string_array_t* s_a, jmi_string_array_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_string_t, jmi_string_array_t, o_a, -1, 1)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    JMI_ARRAY_INIT_1(HEAP, jmi_string_t, jmi_string_array_t, o_a, jmi_array_size(s_a, 0), 1, jmi_array_size(s_a, 0))
    i1_1in = 0;
    i1_1ie = floor((jmi_array_size(s_a, 0)) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        JMI_ASG(STR, jmi_array_ref_1(o_a, i1_1i), jmi_array_val_1(s_a, i1_1i))
    }
    JMI_RET(STR_ARR, o_o, o_a)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end StringOperations10;

model StringOperations11
    function f1
        input String[:] s;
        output String[size(s,1)] o;
      algorithm
        o := s;
    end f1;
    
    function f2
        input Real x;
        input Integer n;
        output Real y;
        String[n] s;
      algorithm
        y := x;
        s := {"str" for i in 1:n};
        s := f1(s);
    end f2;
    
    Real y = f2(-time, 2);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="StringOperations11",
        description="Unknown size string array return value in function call",
        inline_functions="none",
        variability_propagation=false,
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_StringOperations11_f2_def0(jmi_real_t x_v, jmi_real_t n_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_ARR(HEAP, jmi_string_t, jmi_string_array_t, s_a, -1, 1)
    JMI_ARR(HEAP, jmi_string_t, jmi_string_array_t, temp_1_a, -1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    JMI_ARR(HEAP, jmi_string_t, jmi_string_array_t, tmp_1, -1, 1)
    JMI_ARRAY_INIT_1(HEAP, jmi_string_t, jmi_string_array_t, s_a, n_v, 1, n_v)
    y_v = x_v;
    JMI_ARRAY_INIT_1(HEAP, jmi_string_t, jmi_string_array_t, temp_1_a, jmi_max(n_v, 0.0), 1, jmi_max(n_v, 0.0))
    i1_0in = 0;
    i1_0ie = floor((jmi_max(n_v, 0.0)) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        JMI_ASG(STR, jmi_array_ref_1(temp_1_a, i1_0i), \"str\")
    }
    i1_1in = 0;
    i1_1ie = floor((n_v) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        JMI_ASG(STR, jmi_array_ref_1(s_a, i1_1i), jmi_array_val_1(temp_1_a, i1_1i))
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_string_t, jmi_string_array_t, tmp_1, n_v, 1, n_v)
    func_CCodeGenTests_StringOperations11_f1_def1(s_a, tmp_1);
    JMI_ASG(STR_ARR, s_a, tmp_1)    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_StringOperations11_f2_exp0(jmi_real_t x_v, jmi_real_t n_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_StringOperations11_f2_def0(x_v, n_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations11_f1_def1(jmi_string_array_t* s_a, jmi_string_array_t* o_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_string_t, jmi_string_array_t, o_a, -1, 1)
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    JMI_ARRAY_INIT_1(HEAP, jmi_string_t, jmi_string_array_t, o_a, jmi_array_size(s_a, 0), 1, jmi_array_size(s_a, 0))
    i1_2in = 0;
    i1_2ie = floor((jmi_array_size(s_a, 0)) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        JMI_ASG(STR, jmi_array_ref_1(o_a, i1_2i), jmi_array_val_1(s_a, i1_2i))
    }
    JMI_RET(STR_ARR, o_o, o_a)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end StringOperations11;

package TestTerminate

model TestTerminate1
        Real x(start = 0);
    equation
        der(x) = time;
        when x >= 2 then
            terminate("X is high enough.");
        end when;
	
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestTerminate_TestTerminate1",
        description="",
        template="
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_3 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (2), _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

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
                _sw(0) = jmi_turn_switch(jmi, _x_0 - (2), _sw(0), JMI_REL_GEQ);
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            jmi_flag_termination(jmi, \"X is high enough.\");
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end TestTerminate1;

model TestTerminate2
    parameter String p = "str";
    Real x(start = 0);
equation
    der(x) = time;
    when x >= 2 then
        terminate("X is high enough." + p);
    end when;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestTerminate_TestTerminate2",
        description="",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(tmp_1)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_1 - (2), _sw(0), JMI_REL_GEQ);
            }
            _temp_1_2 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
            JMI_INI_STR_DYNA(tmp_1, 17 + JMI_LEN(_s_pi_p_0))
            snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"X is high enough.\");
            snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", _s_pi_p_0);
            jmi_flag_termination(jmi, tmp_1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end TestTerminate2;

model TestTerminate3
    Real x(start = 0);
equation
    der(x) = time;
    if x >= 2 then
        terminate("X is high enough.");
    end if;
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestTerminate_TestTerminate3",
        description="",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_1 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (2), _sw(0), JMI_REL_GEQ);
    }
    if (_sw(0)) {
        jmi_flag_termination(jmi, \"X is high enough.\");
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestTerminate3;

end TestTerminate;

model TestAssert1
    function f
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
        assert(x < 3, "x is too high.");
        assert(y < 4, "y is too high.", AssertionLevel.error);
        assert(x + y < 5, "sum is a bit high.", AssertionLevel.warning);
        annotation(Inline=false);
    end f;
    
    Real x = time + 1;
    Real y = f(x);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestAssert1",
        description="Test C code generation for assert() in functions",
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_TestAssert1_f_def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = x_v + 1;
    if (COND_EXP_LT(x_v, 3.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"x is too high.\", JMI_ASSERT_ERROR);
    }
    if (COND_EXP_LT(y_v, 4.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"y is too high.\", JMI_ASSERT_ERROR);
    }
    if (COND_EXP_LT(x_v + y_v, 5.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"sum is a bit high.\", JMI_ASSERT_WARNING);
    }
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_TestAssert1_f_exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_TestAssert1_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end TestAssert1;


model TestAssert2
    Real x = time + 1;
    Real y = x + 1;
equation
    assert(x < 3, "x is too high.");
    assert(y < 4, "y is too high.", AssertionLevel.error);
    assert(x + y < 5, "sum is a bit high.", AssertionLevel.warning);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestAssert2",
        description="Test C code generation for assert() in equations",
        template="
$C_ode_initialization$
$C_ode_derivatives$
",
        generatedCode="

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = _time + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (3.0), _sw(0), JMI_REL_LT);
    }
    if (_sw(0) == JMI_FALSE) {
        jmi_assert_failed(\"x is too high.\", JMI_ASSERT_ERROR);
    }
    _y_1 = _x_0 + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _y_1 - (4.0), _sw(1), JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"y is too high.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_0 + _y_1 - (5.0), _sw(2), JMI_REL_LT);
    }
    if (_sw(2) == JMI_FALSE) {
        jmi_assert_failed(\"sum is a bit high.\", JMI_ASSERT_WARNING);
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = _time + 1;
    _y_1 = _x_0 + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (3.0), _sw(0), JMI_REL_LT);
    }
    if (_sw(0) == JMI_FALSE) {
        jmi_assert_failed(\"x is too high.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _y_1 - (4.0), _sw(1), JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"y is too high.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_0 + _y_1 - (5.0), _sw(2), JMI_REL_LT);
    }
    if (_sw(2) == JMI_FALSE) {
        jmi_assert_failed(\"sum is a bit high.\", JMI_ASSERT_WARNING);
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestAssert2;


model TestStringWithUnicode1
	Real x = time + 1;
equation
	assert(x < 5, "euro: €
aring: å
Auml: Ä\nbell: \a");

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestStringWithUnicode1",
        description="C string literal with line breaks and unicode chars",
        template="$C_ode_derivatives$",
        generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = _time + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (5.0), _sw(0), JMI_REL_LT);
    }
    if (_sw(0) == JMI_FALSE) {
        jmi_assert_failed(\"euro: \\xe2\\x82\\xac\\naring: \\xc3\\xa5\\nAuml: \\xc3\\x84\\nbell: \\a\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestStringWithUnicode1;

model TestStringWithUnicode2
	parameter String s = "°C";
    Real x = time + 1;
equation
	assert(x < 5, "°C");

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="TestStringWithUnicode2",
        description="C string literal with unicode followed by a C, checks bug where the hex escape also included the C",
        template="
$C_model_init_eval_independent_start$
$C_ode_derivatives$
",
        generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_pi_s_0, (\"\\xc2\\xb0\"\"C\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1 = _time + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_1 - (5.0), _sw(0), JMI_REL_LT);
    }
    if (_sw(0) == JMI_FALSE) {
        jmi_assert_failed(\"\\xc2\\xb0\"\"C\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TestStringWithUnicode2;


model CFixedFalseParam1
    Real x, y;
    parameter Real p(fixed=false);
initial equation
    2*x = p;
    x = 3;
equation
    der(x) = -x;
    y = x * time;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFixedFalseParam1",
        description="Test of C code generation of parameters with fixed = false.",
        template="
***Derivatives:
$C_ode_derivatives$
***Initialization:
$C_ode_initialization$
***Param:
$C_model_init_eval_dependent_variables$
",
        generatedCode="
***Derivatives:

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_3 = - _x_0;
    _y_1 = _x_0 * _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

***Initialization:

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = 3;
    _der_x_3 = - _x_0;
    _y_1 = _x_0 * _time;
    _p_2 = 2 * _x_0;
    JMI_DYNAMIC_FREE()
    return ef;
}

***Param:

int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFixedFalseParam1;

model CFixedFalseParam2
    parameter Real x1(start=z, fixed=false) = y;
    parameter Real x2(start=z, fixed=false);
    parameter Real x3(start=1, fixed=false) = x2 + 1;
    parameter Real y = 4;
    parameter Real z = y;
initial equation
    x2 = y;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFixedFalseParam2",
        description="Test of C code generation of parameters with fixed = false. Check that start value is generated.",
        template="
$C_model_init_eval_independent_start$
$C_model_init_eval_dependent_parameters$
$C_model_init_eval_dependent_variables$
$C_ode_initialization$
",
        generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_3 = (4);
    _x3_2 = (1);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = (_y_3);
    _z_4 = (_y_3);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_init_eval_dependent_variables(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x2_1 = (_z_4);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x2_1 = _y_3;
    _x3_2 = _x2_1 + 1;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFixedFalseParam2;

model CFixedFalseParam3
    function f
        input Real[:] x;
        output Real y = sum(x);
      algorithm
    end f;
    parameter Real x1(start=f({1,2,3}), fixed=false);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="CFixedFalseParam3",
        description="Test of C code generation of parameters with fixed = false. Check that start value is generated.",
        variability_propagation=false,
        template="$C_model_init_eval_independent_start$",
        generatedCode="
int model_init_eval_independent_start(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    _x1_0 = (func_CCodeGenTests_CFixedFalseParam3_f_exp0(tmp_1));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CFixedFalseParam3;

model ActiveSwitches1
    Real f = if s then time else -1;
    Boolean s = f > 10;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="ActiveSwitches1",
        description="Test code gen for active switch indexes in block.",
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _f_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _f_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _f_0 - (10), _sw(0), JMI_REL_GT);
            }
            _s_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_s_1, JMI_TRUE, _time, -1.0) - (_f_0);
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
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _f_0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _f_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _f_0 - (10), _sw(0), JMI_REL_GT);
            }
            _s_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_s_1, JMI_TRUE, _time, -1.0) - (_f_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, 1, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, 1, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end ActiveSwitches1;

model ActiveSwitches2
    Real a = if b < 3.14 then time else -1;
    Real b = if a > 10 then a else -der(a);
initial equation
    der(a) = if a > 42 then 0.1 else 0.2;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="ActiveSwitches2",
        description="Test code gen for active switch indexes in block.",
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _b_1 - (3.14), _sw(0), JMI_REL_LT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, _time, -1.0) - (_a_0);
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
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _der_a_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = - COND_EXP_EQ(_sw(1), JMI_TRUE, 0.0, -1.0);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _der_a_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _a_0 - (10.0), _sw(1), JMI_REL_GT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(1), JMI_TRUE, _a_0, - _der_a_2) - (_b_1);
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
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
        x[2] = jmi->offs_sw_init + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw_init + 0;
        x[1] = jmi->offs_sw + 1;
        x[2] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_0;
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
            Q1[1] = - COND_EXP_EQ(_sw(1), JMI_TRUE, 1.0, 0.0);
            for (i = 0; i < 2; i += 2) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
                Q1[i + 1] = (Q1[i + 1] - (- COND_EXP_EQ(_sw(1), JMI_TRUE, 0.0, -1.0)) * Q1[i + 0]) / (1.0);
            }
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw_init(0) = jmi_turn_switch(jmi, _a_0 - (42.0), _sw_init(0), JMI_REL_GT);
        }
        _der_a_2 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 0.1, 0.2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch(jmi, _a_0 - (10.0), _sw(1), JMI_REL_GT);
        }
        _b_1 = COND_EXP_EQ(_sw(1), JMI_TRUE, _a_0, - _der_a_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _b_1 - (3.14), _sw(0), JMI_REL_LT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, _time, -1.0) - (_a_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 1, 1, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 1, \"2\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 2, 0, 0, 0, 0, 0, 3, 3, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end ActiveSwitches2;

model ActiveSwitches3
    Real x;
    parameter Real p(fixed=false);
initial equation
    p = x * 6.28;
equation
    x = if p > 3.14 then p - 42 else p + time;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="ActiveSwitches3",
        description="Test code gen fixed=false parameters with switch indicators.",
        template="
C_dae_init_blocks_residual_functions
$C_dae_init_blocks_residual_functions$
C_dae_init_add_blocks_residual_functions
$C_dae_init_add_blocks_residual_functions$
C_ode_derivatives
$C_ode_derivatives$
C_ode_initialization
$C_ode_initialization$
C_DAE_event_indicator_residuals
$C_DAE_event_indicator_residuals$
C_DAE_initial_event_indicator_residuals
$C_DAE_initial_event_indicator_residuals$
static const int N_sw = $n_state_switches$ + $n_time_switches$;
static const int N_sw_init = $n_initial_switches$;
",
        generatedCode="
C_dae_init_blocks_residual_functions
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw_init + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw_init + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 6.28;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _p_1;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 1;
            int n2 = 1;
            Q1[0] = -1.0;
            for (i = 0; i < 1; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            Q2[0] = -6.28;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _p_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw_init(0) = jmi_turn_switch(jmi, _p_1 - (3.14), _sw_init(0), JMI_REL_GT);
        }
        _x_0 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, _p_1 - 42.0, _p_1 + _time);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 * 6.28 - (_p_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


C_dae_init_add_blocks_residual_functions
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 1, 0, 0, 0, 0, 0, 1, 1, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

C_ode_derivatives

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = COND_EXP_EQ(COND_EXP_GT(_p_1, 3.14, JMI_TRUE, JMI_FALSE), JMI_TRUE, _p_1 - 42.0, _p_1 + _time);
    JMI_DYNAMIC_FREE()
    return ef;
}

C_ode_initialization

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

C_DAE_event_indicator_residuals
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;

C_DAE_initial_event_indicator_residuals
    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _p_1 - (3.14);
    JMI_DYNAMIC_FREE()
    return ef;

static const int N_sw = 0 + 0;
static const int N_sw_init = 1;
")})));
end ActiveSwitches3;

model ActiveSwitches4
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    Real a = if p1 > 0 then 1 else 2;
initial equation
    p1 = p2 * 23;
    p2 = p1 + 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="ActiveSwitches4",
        description="Test code gen variability propagated switches (fixed = false).",
        template="
C_dae_init_blocks_residual_functions
$C_dae_init_blocks_residual_functions$
C_dae_init_add_blocks_residual_functions
$C_dae_init_add_blocks_residual_functions$
C_ode_derivatives
$C_ode_derivatives$
C_ode_initialization
$C_ode_initialization$
C_DAE_event_indicator_residuals
$C_DAE_event_indicator_residuals$
C_DAE_initial_event_indicator_residuals
$C_DAE_initial_event_indicator_residuals$
static const int N_sw = $n_state_switches$ + $n_time_switches$;
static const int N_sw_init = $n_initial_switches$;
",
        generatedCode="
C_dae_init_blocks_residual_functions
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
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _p2_1;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 1;
            int n2 = 1;
            Q1[0] = -23;
            for (i = 0; i < 1; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            Q2[0] = -1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _p2_1 = x[0];
        }
        _p1_0 = _p2_1 * 23;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _p1_0 + 1 - (_p2_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


C_dae_init_add_blocks_residual_functions
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 1, 0, 0, 0, 0, 0, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

C_ode_derivatives

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

C_ode_initialization

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch(jmi, _p1_0 - (0.0), _sw_init(0), JMI_REL_GT);
    }
    _a_2 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, 1.0, 2.0);
    JMI_DYNAMIC_FREE()
    return ef;
}

C_DAE_event_indicator_residuals
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;

C_DAE_initial_event_indicator_residuals
    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _p1_0 - (0.0);
    JMI_DYNAMIC_FREE()
    return ef;

static const int N_sw = 0 + 0;
static const int N_sw_init = 1;
")})));
end ActiveSwitches4;

model ActiveSwitches5
    Real x,y;
equation
    x = smooth(1,if time > 1 then time * 1.2 else 1);
    y = der(x);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="ActiveSwitches5",
        description="Test code gen differentiated switches inside Smooth(1, ...)",
        relational_time_events=false,
        template="
C_dae_init_blocks_residual_functions
$C_dae_init_blocks_residual_functions$
C_dae_init_add_blocks_residual_functions
$C_dae_init_add_blocks_residual_functions$
C_ode_derivatives
$C_ode_derivatives$
C_ode_initialization
$C_ode_initialization$
C_DAE_event_indicator_residuals
$C_DAE_event_indicator_residuals$
C_DAE_initial_event_indicator_residuals
$C_DAE_initial_event_indicator_residuals$
static const int N_sw = $n_state_switches$ + $n_time_switches$;
static const int N_sw_init = $n_initial_switches$;
",
        generatedCode="
C_dae_init_blocks_residual_functions

C_dae_init_add_blocks_residual_functions

C_ode_derivatives

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = (COND_EXP_EQ(COND_EXP_GT(_time, 1.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, _time * 1.2, 1.0));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
    }
    _y_1 = (COND_EXP_EQ(_sw(0), JMI_TRUE, 1.2, 0.0));
    JMI_DYNAMIC_FREE()
    return ef;
}

C_ode_initialization

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = (COND_EXP_EQ(COND_EXP_GT(_time, 1.0, JMI_TRUE, JMI_FALSE), JMI_TRUE, _time * 1.2, 1.0));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
    }
    _y_1 = (COND_EXP_EQ(_sw(0), JMI_TRUE, 1.2, 0.0));
    JMI_DYNAMIC_FREE()
    return ef;
}

C_DAE_event_indicator_residuals
    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (1.0);
    JMI_DYNAMIC_FREE()
    return ef;

C_DAE_initial_event_indicator_residuals
    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (1.0);
    JMI_DYNAMIC_FREE()
    return ef;

static const int N_sw = 1 + 0;
static const int N_sw_init = 0;
")})));
end ActiveSwitches5;

model DirectlyActiveSwitches1
    Boolean b1, b2;
    Real x, a, y;
equation
    a = time + 1;
    x = if b2 then -time else time;
    y = if x > 0 then x elseif a > 0 then x * 2 else -x;
    b1 = x > 0;
    b2 = not b1 or y < 1;

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="DirectlyActiveSwitches1",
        description="Test code gen for switches and nonreals that directly impact continuous equations.",
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
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
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
        x[1] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 2;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 1;
            int n2 = 1;
            for (i = 0; i < 1; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch(jmi, _x_2 - (0.0), _sw(0), JMI_REL_GT);
        }
        if (_sw(0)) {
        } else {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _a_3 - (0.0), _sw(1), JMI_REL_GT);
            }
        }
        _y_4 = COND_EXP_EQ(_sw(0), JMI_TRUE, _x_2, COND_EXP_EQ(_sw(1), JMI_TRUE, _x_2 * 2.0, - _x_2));
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_2 - (0), _sw(0), JMI_REL_GT);
            }
            _b1_0 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch(jmi, _y_4 - (1), _sw(2), JMI_REL_LT);
            }
            _b2_1 = LOG_EXP_OR(LOG_EXP_NOT(_b1_0), _sw(2));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_b2_1, JMI_TRUE, - _time, _time) - (_x_2);
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
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870917;
        x[1] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 2;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 1;
            int n2 = 1;
            for (i = 0; i < 1; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = 1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch(jmi, _x_2 - (0.0), _sw(0), JMI_REL_GT);
        }
        if (_sw(0)) {
        } else {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _a_3 - (0.0), _sw(1), JMI_REL_GT);
            }
        }
        _y_4 = COND_EXP_EQ(_sw(0), JMI_TRUE, _x_2, COND_EXP_EQ(_sw(1), JMI_TRUE, _x_2 * 2.0, - _x_2));
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _x_2 - (0), _sw(0), JMI_REL_GT);
            }
            _b1_0 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(2) = jmi_turn_switch(jmi, _y_4 - (1), _sw(2), JMI_REL_LT);
            }
            _b2_1 = LOG_EXP_OR(LOG_EXP_NOT(_b1_0), _sw(2));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_b2_1, JMI_TRUE, - _time, _time) - (_x_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 1, 0, 2, 1, 0, 0, 2, 1, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 1, 0, 2, 1, 0, 0, 2, 1, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end DirectlyActiveSwitches1;

model DirectlyActiveSwitches2
    Real x[2];
equation
    x[1] = if time > x[2] then time else time .+ x[2];
    x[2] = if time > x[2] then time else time .+ x[2];

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="DirectlyActiveSwitches2",
        description="Test code gen for switches and nonreals that directly impact continuous equations.",
        template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_1;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0 - COND_EXP_EQ(_sw(0), JMI_TRUE, 0.0, 1.0);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (_x_2_1), _sw(0), JMI_REL_GT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, _time, _time + _x_2_1) - (_x_2_1);
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
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_1;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0 - COND_EXP_EQ(_sw(0), JMI_TRUE, 0.0, 1.0);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (_x_2_1), _sw(0), JMI_REL_GT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, _time, _time + _x_2_1) - (_x_2_1);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 1, 1, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 1, 1, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end DirectlyActiveSwitches2;

model SwitchesAsNoEvent1
    Boolean x = time > 0.5;
    Real y = abs(time + 0.5);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SwitchesAsNoEvent1",
            description="Test so that no switches are generated when generate_event_switches is set to false.",
            generate_event_switches=false,
            template="
$C_DAE_initial_relations$
$C_DAE_relations$
$C_ode_derivatives$
",
            generatedCode="
static const int N_initial_relations = 0;
static const int DAE_initial_relations[] = { -1 };
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_0 = COND_EXP_GT(_time, 0.5, JMI_TRUE, JMI_FALSE);
    pre_x_0 = _x_0;
    _y_1 = jmi_abs(_time + 0.5);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SwitchesAsNoEvent1;

model TruncDivString1
	Real[5,5] a_really_long_variable_name = ones(5,5) * time;
	Real x;
equation
	x = time / (sum(a_really_long_variable_name));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TruncDivString1",
            description="Test code gen for active switch indexes in block.",
            eliminate_linear_equations=false,
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _a_really_long_variable_name_1_1_0 = _time;
    _a_really_long_variable_name_1_2_1 = _time;
    _a_really_long_variable_name_1_3_2 = _time;
    _a_really_long_variable_name_1_4_3 = _time;
    _a_really_long_variable_name_1_5_4 = _time;
    _a_really_long_variable_name_2_1_5 = _time;
    _a_really_long_variable_name_2_2_6 = _time;
    _a_really_long_variable_name_2_3_7 = _time;
    _a_really_long_variable_name_2_4_8 = _time;
    _a_really_long_variable_name_2_5_9 = _time;
    _a_really_long_variable_name_3_1_10 = _time;
    _a_really_long_variable_name_3_2_11 = _time;
    _a_really_long_variable_name_3_3_12 = _time;
    _a_really_long_variable_name_3_4_13 = _time;
    _a_really_long_variable_name_3_5_14 = _time;
    _a_really_long_variable_name_4_1_15 = _time;
    _a_really_long_variable_name_4_2_16 = _time;
    _a_really_long_variable_name_4_3_17 = _time;
    _a_really_long_variable_name_4_4_18 = _time;
    _a_really_long_variable_name_4_5_19 = _time;
    _a_really_long_variable_name_5_1_20 = _time;
    _a_really_long_variable_name_5_2_21 = _time;
    _a_really_long_variable_name_5_3_22 = _time;
    _a_really_long_variable_name_5_4_23 = _time;
    _a_really_long_variable_name_5_5_24 = _time;
    _x_25 = jmi_divide_equation(jmi, _time,(_a_really_long_variable_name_1_1_0 + _a_really_long_variable_name_1_2_1 + (_a_really_long_variable_name_1_3_2 + _a_really_long_variable_name_1_4_3) + (_a_really_long_variable_name_1_5_4 + _a_really_long_variable_name_2_1_5 + _a_really_long_variable_name_2_2_6) + (_a_really_long_variable_name_2_3_7 + _a_really_long_variable_name_2_4_8 + _a_really_long_variable_name_2_5_9 + (_a_really_long_variable_name_3_1_10 + _a_really_long_variable_name_3_2_11 + _a_really_long_variable_name_3_3_12)) + (_a_really_long_variable_name_3_4_13 + _a_really_long_variable_name_3_5_14 + _a_really_long_variable_name_4_1_15 + (_a_really_long_variable_name_4_2_16 + _a_really_long_variable_name_4_3_17 + _a_really_long_variable_name_4_4_18) + (_a_really_long_variable_name_4_5_19 + _a_really_long_variable_name_5_1_20 + _a_really_long_variable_name_5_2_21 + (_a_really_long_variable_name_5_3_22 + _a_really_long_variable_name_5_4_23 + _a_really_long_variable_name_5_5_24)))),\"(truncated) time / (a_really_long_variable_name[1,1] + a_really_long_variable_name[1,2] + (a_really_long_variable_name[1,3] + a_really_long_variable_name[1,4]) + (a_really_long_variable_name[1,5] + a_really_long_variable_name[2,1] + a_really_long_variable_name[2,2]) + (a_really_long_variable_name[2,3] + a_really_long_variable_name[2,4] + a_really_long_variable_name[2,5] + (a_really_long_variable_name[3,1] + a_really_long_variable_name[3,2] + a_really_long_variable_name[3,3])) + (a_really_long_variable...\");
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end TruncDivString1;


model QuotedIdentifierFunc1
    function '!#%'
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
    end '!#%';

    function '&/('
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
    end '&/(';

    Real z = '!#%'(time) + '&/('(time);
	
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="QuotedIdentifierFunc1",
        description="",
        variability_propagation=false,
        inline_functions="none",
        generate_ode=false,
        generate_dae=true,
        template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
        generatedCode="
void func_CCodeGenTests_QuotedIdentifierFunc1_______def0(jmi_real_t x_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp0(jmi_real_t x_v);
void func_CCodeGenTests_QuotedIdentifierFunc1_______def1(jmi_real_t x_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp1(jmi_real_t x_v);

void func_CCodeGenTests_QuotedIdentifierFunc1_______def0(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = x_v + 1;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp0(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_QuotedIdentifierFunc1_______def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_QuotedIdentifierFunc1_______def1(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = x_v + 1;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp1(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_QuotedIdentifierFunc1_______def1(x_v, &y_v);
    return y_v;
}


    (*res)[0] = func_CCodeGenTests_QuotedIdentifierFunc1_______exp0(_time) + func_CCodeGenTests_QuotedIdentifierFunc1_______exp1(_time) - (_z_0);
")})));
end QuotedIdentifierFunc1;

model LoadResource1
    function strlen
        input String s;
        output Integer n;
        external;
    end strlen;
    parameter Integer y = strlen(Modelica.Utilities.Files.loadResource("modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt"));
    discrete  Integer z = strlen(Modelica.Utilities.Files.loadResource("modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt"));
    
    discrete Integer rel  = strlen(Modelica.Utilities.Files.loadResource("../Data/String.txt"));
    discrete Integer abs  = strlen(Modelica.Utilities.Files.loadResource("/C:/home/user/Data/String.txt"));
    discrete Integer file = strlen(Modelica.Utilities.Files.loadResource("file:///C:/home/user/Data/String.txt"));
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="LoadResource1",
            description="",
            variability_propagation=false,
            common_subexp_elim=false,
            template="
$C_ode_derivatives$
$C_model_init_eval_dependent_parameters$
",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    char tmp_1[JMI_PATH_MAX];
    char tmp_2[JMI_PATH_MAX];
    char tmp_3[JMI_PATH_MAX];
    char tmp_4[JMI_PATH_MAX];
    jmi_load_resource(jmi, tmp_1, \"/0/Examples_readRealParameters.txt\");
    _z_1 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_1);
    pre_z_1 = _z_1;
    jmi_load_resource(jmi, tmp_2, \"/1/String.txt\");
    _rel_2 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_2);
    pre_rel_2 = _rel_2;
    jmi_load_resource(jmi, tmp_3, \"/2/String.txt\");
    _abs_3 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_3);
    pre_abs_3 = _abs_3;
    jmi_load_resource(jmi, tmp_4, \"/2/String.txt\");
    _file_4 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_4);
    pre_file_4 = _file_4;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    char tmp_5[JMI_PATH_MAX];
    jmi_load_resource(jmi, tmp_5, \"/0/Examples_readRealParameters.txt\");
    _y_0 = (func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_5));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end LoadResource1;

model IntegerEnumIndices
    type E = enumeration(ONE,TWO,THREE);
    constant Integer i1 = 1;
    parameter Integer i2 = 2;
    Integer i3 = integer(time);
    constant E e1 = E.ONE;
    parameter E e2 = E.TWO;
    E e3 = if i3 > 0 then E.THREE else E.TWO;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerEnumIndices",
            description="Check that indices given to integers and enums don't overlap. #3871",
            variability_propagation=false,
            template="$C_variable_aliases$",
            generatedCode="
#define _i1_0 ((*(jmi->z))[0])
#define _e1_3 ((*(jmi->z))[1])
#define _i2_1 ((*(jmi->z))[2])
#define _e2_4 ((*(jmi->z))[3])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _i3_2 ((*(jmi->z))[6])
#define _e3_5 ((*(jmi->z))[7])
#define pre_i3_2 ((*(jmi->z))[jmi->offs_pre_integer_d+0])
#define pre_e3_5 ((*(jmi->z))[jmi->offs_pre_integer_d+1])
")})));
end IntegerEnumIndices;

model FuncInitOrder
    function g
        input Real[:] x;
        output Integer y = integer(sum(x));
    algorithm
    end g;

    function f
        input Real[:] x;
        output Real[g(x)] y;
    algorithm
        y := zeros(0);
    end f;
    
    function h
        input Real[:,:] x;
        output Real y = sum(f(x[:,1]));
    algorithm
    end h;
    
    Real y = h({{time}});
        
        
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="FuncInitOrder",
        description="",
        variability_propagation=false,
        generate_ode=false,
        generate_dae=true,
        template="$C_functions$",
        generatedCode="
void func_CCodeGenTests_FuncInitOrder_h_def0(jmi_array_t* x_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(REA, temp_1_v)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_2_a, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_3_a, -1, 1)
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, temp_4_a, -1, 1)
    jmi_real_t i2_0i;
    jmi_int_t i2_0ie;
    jmi_int_t i2_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    jmi_real_t i2_2i;
    jmi_int_t i2_2ie;
    jmi_int_t i2_2in;
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_2_a, jmi_array_size(x_a, 0), 1, jmi_array_size(x_a, 0))
    i2_0in = 0;
    i2_0ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i2_0i = 1; i2_0in <= i2_0ie; i2_0i = 1 + (++i2_0in)) {
        jmi_array_ref_1(temp_2_a, i2_0i) = jmi_array_val_2(x_a, i2_0i, 1);
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_3_a, jmi_array_size(x_a, 0), 1, jmi_array_size(x_a, 0))
    i2_1in = 0;
    i2_1ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
        jmi_array_ref_1(temp_3_a, i2_1i) = jmi_array_val_2(x_a, i2_1i, 1);
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_3_a, jmi_array_size(x_a, 0), 1, jmi_array_size(x_a, 0))
    i2_2in = 0;
    i2_2ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i2_2i = 1; i2_2in <= i2_2ie; i2_2i = 1 + (++i2_2in)) {
        jmi_array_ref_1(temp_3_a, i2_2i) = jmi_array_val_2(x_a, i2_2i, 1);
    }
    JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, temp_4_a, func_CCodeGenTests_FuncInitOrder_g_exp2(temp_3_a), 1, func_CCodeGenTests_FuncInitOrder_g_exp2(temp_3_a))
    func_CCodeGenTests_FuncInitOrder_f_def1(temp_2_a, temp_4_a);
    temp_1_v = 0.0;
    i1_3in = 0;
    i1_3ie = floor((func_CCodeGenTests_FuncInitOrder_g_exp2(temp_3_a)) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(temp_4_a, i1_3i);
    }
    y_v = temp_1_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_FuncInitOrder_h_exp0(jmi_array_t* x_a) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_FuncInitOrder_h_def0(x_a, &y_v);
    return y_v;
}

void func_CCodeGenTests_FuncInitOrder_f_def1(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(HEAP, jmi_real_t, jmi_array_t, y_an, -1, 1)
    jmi_real_t i1_4i;
    jmi_int_t i1_4ie;
    jmi_int_t i1_4in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(HEAP, jmi_real_t, jmi_array_t, y_an, func_CCodeGenTests_FuncInitOrder_g_exp2(x_a), 1, func_CCodeGenTests_FuncInitOrder_g_exp2(x_a))
        y_a = y_an;
    }
    if (COND_EXP_EQ(func_CCodeGenTests_FuncInitOrder_g_exp2(x_a), 0.0, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"Mismatching sizes in CCodeGenTests.FuncInitOrder.f\", JMI_ASSERT_ERROR);
    }
    i1_4in = 0;
    i1_4ie = floor((func_CCodeGenTests_FuncInitOrder_g_exp2(x_a)) - (1));
    for (i1_4i = 1; i1_4in <= i1_4ie; i1_4i = 1 + (++i1_4in)) {
        jmi_array_ref_1(y_a, i1_4i) = 0;
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_FuncInitOrder_g_def2(jmi_array_t* x_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, y_v)
    JMI_DEF(REA, temp_1_v)
    jmi_real_t i1_5i;
    jmi_int_t i1_5ie;
    jmi_int_t i1_5in;
    temp_1_v = 0.0;
    i1_5in = 0;
    i1_5ie = floor((jmi_array_size(x_a, 0)) - (1));
    for (i1_5i = 1; i1_5in <= i1_5ie; i1_5i = 1 + (++i1_5in)) {
        temp_1_v = temp_1_v + jmi_array_val_1(x_a, i1_5i);
    }
    y_v = floor(temp_1_v);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_FuncInitOrder_g_exp2(jmi_array_t* x_a) {
    JMI_DEF(INT, y_v)
    func_CCodeGenTests_FuncInitOrder_g_def2(x_a, &y_v);
    return y_v;
}

")})));
end FuncInitOrder;

model Functional1
    partial function partFunc
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf1;
        input partFunc pf2;
        input Real x;
        output Real y;
      algorithm
        y := pf1() + pf2();
    end usePartFunc;

    Real y = usePartFunc(function fullFunc(x=time), function fullFunc(x=time), time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Functional1",
            description="Code generation for functional input arguments. Basic.",
            variability_propagation=false,
            generate_ode=true,
            equation_sorting=true,
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
typedef struct func_CCodeGenTests_Functional1_fullFunc_fpout2_ func_CCodeGenTests_Functional1_fullFunc_fpout2;
struct func_CCodeGenTests_Functional1_fullFunc_fpout2_ {
    int n;
    jmi_real_t y_v;
};
typedef struct func_CCodeGenTests_Functional1_fullFunc_fp2_ func_CCodeGenTests_Functional1_fullFunc_fp2;
struct func_CCodeGenTests_Functional1_fullFunc_fp2_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional1_fullFunc_fp2*, func_CCodeGenTests_Functional1_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional1_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional1_fullFunc_fp2*, func_CCodeGenTests_Functional1_fullFunc_fp2*, ...);
    jmi_real_t x_v;
    int x_v_s;
};
typedef struct func_CCodeGenTests_Functional1_partFunc_fpout1_ func_CCodeGenTests_Functional1_partFunc_fpout1;
struct func_CCodeGenTests_Functional1_partFunc_fpout1_ {
    int n;
    jmi_real_t y_v;
};
typedef struct func_CCodeGenTests_Functional1_partFunc_fp1_ func_CCodeGenTests_Functional1_partFunc_fp1;
struct func_CCodeGenTests_Functional1_partFunc_fp1_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional1_partFunc_fp1*, func_CCodeGenTests_Functional1_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional1_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional1_partFunc_fp1*, func_CCodeGenTests_Functional1_partFunc_fp1*, ...);
};
jmi_real_t func_CCodeGenTests_Functional1_fullFunc_fpcl2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional1_fullFunc_fp2* func_CCodeGenTests_Functional1_fullFunc_fpcr2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional1_usePartFunc_def0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_real_t x_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional1_usePartFunc_exp0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_real_t x_v);
void func_CCodeGenTests_Functional1_partFunc_def1(jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional1_partFunc_exp1();
void func_CCodeGenTests_Functional1_fullFunc_def2(jmi_real_t x_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional1_fullFunc_exp2(jmi_real_t x_v);

jmi_real_t func_CCodeGenTests_Functional1_fullFunc_fpcl2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fpout2* out, ...) {
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x_v_s) {
        tmp_1 = fp_in->x_v;
    } else {
        tmp_1 = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional1_fullFunc_def2(tmp_1, &tmp_2);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_2;
        }
    }
    return tmp_2;
}

func_CCodeGenTests_Functional1_fullFunc_fp2* func_CCodeGenTests_Functional1_fullFunc_fpcr2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional1_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional1_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional1_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x_v_s = 0;
    } else {
        fp_out->x_v_s = fp_in->x_v_s;
        fp_out->x_v = fp_in->x_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x_v_s && va_arg(argp, int)) {
        fp_out->x_v_s = 1;
        fp_out->x_v = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional1_usePartFunc_def0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = pf1_v->fpcl(pf1_v, NULL) + pf2_v->fpcl(pf2_v, NULL);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional1_usePartFunc_exp0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional1_usePartFunc_def0(pf1_v, pf2_v, x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional1_partFunc_def1(jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional1_partFunc_exp1() {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional1_partFunc_def1(&y_v);
    return y_v;
}

void func_CCodeGenTests_Functional1_fullFunc_def2(jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = x_v * x_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional1_fullFunc_exp2(jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional1_fullFunc_def2(x_v, &y_v);
    return y_v;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    func_CCodeGenTests_Functional1_fullFunc_fp2 tmp_1;
    func_CCodeGenTests_Functional1_fullFunc_fp2 tmp_2;
    _y_0 = func_CCodeGenTests_Functional1_usePartFunc_exp0((func_CCodeGenTests_Functional1_partFunc_fp1*)func_CCodeGenTests_Functional1_fullFunc_fpcr2(NULL, &tmp_1, 1, (jmi_real_t)(_time)), (func_CCodeGenTests_Functional1_partFunc_fp1*)func_CCodeGenTests_Functional1_fullFunc_fpcr2(NULL, &tmp_2, 1, (jmi_real_t)(_time)), _time);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Functional1;

model Functional2
    record R
        Real x;
        Integer y;
        String s;
    end R;
    
    partial function partFunc
        input Real x1;
        input Real x2;
        output Real y1;
        output Real y2;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input R r;
        input Real a;
        output Real b;
      algorithm
        y1 := r.x + r.y + x1 + x2 + a;
        y2 := y1 + 1;
        b := y2 + 1;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      protected
        Real y1,y2;
      algorithm
        (y1,y2) := pf(x, x+1);
        y := y1 + y2;
    end usePartFunc;

    Real y = usePartFunc(function fullFunc(r=R(time, 1, "string"), a=time+1), time);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Functional2",
        description="Code generation for functional input arguments. Multiple inputs and outputs.",
        variability_propagation=false,
        generate_ode=true,
        equation_sorting=true,
        template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
typedef struct func_CCodeGenTests_Functional2_fullFunc_fpout2_ func_CCodeGenTests_Functional2_fullFunc_fpout2;
struct func_CCodeGenTests_Functional2_fullFunc_fpout2_ {
    int n;
    jmi_real_t y1_v;
    jmi_real_t y2_v;
    jmi_real_t b_v;
};
typedef struct func_CCodeGenTests_Functional2_fullFunc_fp2_ func_CCodeGenTests_Functional2_fullFunc_fp2;
struct func_CCodeGenTests_Functional2_fullFunc_fp2_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional2_fullFunc_fp2*, func_CCodeGenTests_Functional2_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional2_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional2_fullFunc_fp2*, func_CCodeGenTests_Functional2_fullFunc_fp2*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
    jmi_real_t x2_v;
    int x2_v_s;
    R_0_r* r_v;
    int r_v_s;
    jmi_real_t a_v;
    int a_v_s;
};
typedef struct func_CCodeGenTests_Functional2_partFunc_fpout1_ func_CCodeGenTests_Functional2_partFunc_fpout1;
struct func_CCodeGenTests_Functional2_partFunc_fpout1_ {
    int n;
    jmi_real_t y1_v;
    jmi_real_t y2_v;
};
typedef struct func_CCodeGenTests_Functional2_partFunc_fp1_ func_CCodeGenTests_Functional2_partFunc_fp1;
struct func_CCodeGenTests_Functional2_partFunc_fp1_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional2_partFunc_fp1*, func_CCodeGenTests_Functional2_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional2_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional2_partFunc_fp1*, func_CCodeGenTests_Functional2_partFunc_fp1*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
    jmi_real_t x2_v;
    int x2_v_s;
};
jmi_real_t func_CCodeGenTests_Functional2_fullFunc_fpcl2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional2_fullFunc_fp2* func_CCodeGenTests_Functional2_fullFunc_fpcr2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional2_usePartFunc_def0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_real_t x_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional2_usePartFunc_exp0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_real_t x_v);
void func_CCodeGenTests_Functional2_partFunc_def1(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t* y1_o, jmi_real_t* y2_o);
jmi_real_t func_CCodeGenTests_Functional2_partFunc_exp1(jmi_real_t x1_v, jmi_real_t x2_v);
void func_CCodeGenTests_Functional2_fullFunc_def2(jmi_real_t x1_v, jmi_real_t x2_v, R_0_r* r_v, jmi_real_t a_v, jmi_real_t* y1_o, jmi_real_t* y2_o, jmi_real_t* b_o);
jmi_real_t func_CCodeGenTests_Functional2_fullFunc_exp2(jmi_real_t x1_v, jmi_real_t x2_v, R_0_r* r_v, jmi_real_t a_v);

jmi_real_t func_CCodeGenTests_Functional2_fullFunc_fpcl2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fpout2* out, ...) {
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    R_0_r* tmp_3;
    jmi_real_t tmp_4;
    jmi_real_t tmp_5;
    jmi_real_t tmp_6;
    jmi_real_t tmp_7;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->r_v_s) {
        tmp_3 = fp_in->r_v;
    } else {
        tmp_3 = va_arg(argp, R_0_r*);
    }
    if (fp_in->a_v_s) {
        tmp_4 = fp_in->a_v;
    } else {
        tmp_4 = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional2_fullFunc_def2(tmp_1, tmp_2, tmp_3, tmp_4, &tmp_5, &tmp_6, &tmp_7);
    if (out != NULL) {
        if (out->n > 0) {
            out->y1_v = tmp_5;
        }
        if (out->n > 1) {
            out->y2_v = tmp_6;
        }
        if (out->n > 2) {
            out->b_v = tmp_7;
        }
    }
    return tmp_5;
}

func_CCodeGenTests_Functional2_fullFunc_fp2* func_CCodeGenTests_Functional2_fullFunc_fpcr2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional2_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional2_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional2_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
        fp_out->r_v_s = 0;
        fp_out->a_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
        fp_out->r_v_s = fp_in->r_v_s;
        fp_out->r_v = fp_in->r_v;
        fp_out->a_v_s = fp_in->a_v_s;
        fp_out->a_v = fp_in->a_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->r_v_s && va_arg(argp, int)) {
        fp_out->r_v_s = 1;
        fp_out->r_v = va_arg(argp, R_0_r*);
    }
    if (!fp_out->a_v_s && va_arg(argp, int)) {
        fp_out->a_v_s = 1;
        fp_out->a_v = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional2_usePartFunc_def0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_real_t x_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_DEF(REA, y1_v)
    JMI_DEF(REA, y2_v)
    func_CCodeGenTests_Functional2_partFunc_fpout1 tmp_1;
    tmp_1.n = 2;
    pf_v->fpcl(pf_v, &tmp_1, (jmi_real_t)(x_v), (jmi_real_t)(x_v + 1.0));
    y1_v = tmp_1.y1_v;
    y2_v = tmp_1.y2_v;
    y_v = y1_v + y2_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional2_usePartFunc_exp0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_real_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional2_usePartFunc_def0(pf_v, x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional2_partFunc_def1(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t* y1_o, jmi_real_t* y2_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y1_v)
    JMI_DEF(REA, y2_v)
    JMI_RET(GEN, y1_o, y1_v)
    JMI_RET(GEN, y2_o, y2_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional2_partFunc_exp1(jmi_real_t x1_v, jmi_real_t x2_v) {
    JMI_DEF(REA, y1_v)
    func_CCodeGenTests_Functional2_partFunc_def1(x1_v, x2_v, &y1_v, NULL);
    return y1_v;
}

void func_CCodeGenTests_Functional2_fullFunc_def2(jmi_real_t x1_v, jmi_real_t x2_v, R_0_r* r_v, jmi_real_t a_v, jmi_real_t* y1_o, jmi_real_t* y2_o, jmi_real_t* b_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y1_v)
    JMI_DEF(REA, y2_v)
    JMI_DEF(REA, b_v)
    y1_v = r_v->x + r_v->y + x1_v + x2_v + a_v;
    y2_v = y1_v + 1;
    b_v = y2_v + 1;
    JMI_RET(GEN, y1_o, y1_v)
    JMI_RET(GEN, y2_o, y2_v)
    JMI_RET(GEN, b_o, b_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional2_fullFunc_exp2(jmi_real_t x1_v, jmi_real_t x2_v, R_0_r* r_v, jmi_real_t a_v) {
    JMI_DEF(REA, y1_v)
    func_CCodeGenTests_Functional2_fullFunc_def2(x1_v, x2_v, r_v, a_v, &y1_v, NULL, NULL);
    return y1_v;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    func_CCodeGenTests_Functional2_fullFunc_fp2 tmp_2;
    tmp_1->x = _time;
    tmp_1->y = 1.0;
    tmp_1->s = \"string\";
    _y_0 = func_CCodeGenTests_Functional2_usePartFunc_exp0((func_CCodeGenTests_Functional2_partFunc_fp1*)func_CCodeGenTests_Functional2_fullFunc_fpcr2(NULL, &tmp_2, 0, 0, 1, (R_0_r*)(tmp_1), 1, (jmi_real_t)(_time + 1.0)), _time);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Functional2;

model Functional3
    partial function partFunc
        input Real x1;
        output Real y;
    end partFunc;
    
    partial function middleFunc
        extends partFunc;
        input Real x2;
    end middleFunc;
    
    function fullFunc
        extends middleFunc;
        input Real x3;
      algorithm
        y := x1 + x2 + x3;
    end fullFunc;
    
    function useMiddleFunc
        input middleFunc mf;
        input Real b;
        input Real c;
        output Real y = usePartFunc(function mf(x2=b), c);
        algorithm
    end useMiddleFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real c;
        output Real y;
      algorithm
        y := pf(c);
    end usePartFunc;

    Real y = useMiddleFunc(function fullFunc(x3=time), time, time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Functional3",
            description="Code generation for functional input arguments. Chained.",
            variability_propagation=false,
            generate_ode=true,
            equation_sorting=true,
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
typedef struct func_CCodeGenTests_Functional3_fullFunc_fpout4_ func_CCodeGenTests_Functional3_fullFunc_fpout4;
struct func_CCodeGenTests_Functional3_fullFunc_fpout4_ {
    int n;
    jmi_real_t y_v;
};
typedef struct func_CCodeGenTests_Functional3_fullFunc_fp4_ func_CCodeGenTests_Functional3_fullFunc_fp4;
struct func_CCodeGenTests_Functional3_fullFunc_fp4_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional3_fullFunc_fp4*, func_CCodeGenTests_Functional3_fullFunc_fpout4*, ...);
    func_CCodeGenTests_Functional3_fullFunc_fp4* (*fpcr)(func_CCodeGenTests_Functional3_fullFunc_fp4*, func_CCodeGenTests_Functional3_fullFunc_fp4*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
    jmi_real_t x2_v;
    int x2_v_s;
    jmi_real_t x3_v;
    int x3_v_s;
};
typedef struct func_CCodeGenTests_Functional3_middleFunc_fpout3_ func_CCodeGenTests_Functional3_middleFunc_fpout3;
struct func_CCodeGenTests_Functional3_middleFunc_fpout3_ {
    int n;
    jmi_real_t y_v;
};
typedef struct func_CCodeGenTests_Functional3_middleFunc_fp3_ func_CCodeGenTests_Functional3_middleFunc_fp3;
struct func_CCodeGenTests_Functional3_middleFunc_fp3_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional3_middleFunc_fp3*, func_CCodeGenTests_Functional3_middleFunc_fpout3*, ...);
    func_CCodeGenTests_Functional3_middleFunc_fp3* (*fpcr)(func_CCodeGenTests_Functional3_middleFunc_fp3*, func_CCodeGenTests_Functional3_middleFunc_fp3*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
    jmi_real_t x2_v;
    int x2_v_s;
};
typedef struct func_CCodeGenTests_Functional3_partFunc_fpout2_ func_CCodeGenTests_Functional3_partFunc_fpout2;
struct func_CCodeGenTests_Functional3_partFunc_fpout2_ {
    int n;
    jmi_real_t y_v;
};
typedef struct func_CCodeGenTests_Functional3_partFunc_fp2_ func_CCodeGenTests_Functional3_partFunc_fp2;
struct func_CCodeGenTests_Functional3_partFunc_fp2_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional3_partFunc_fp2*, func_CCodeGenTests_Functional3_partFunc_fpout2*, ...);
    func_CCodeGenTests_Functional3_partFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional3_partFunc_fp2*, func_CCodeGenTests_Functional3_partFunc_fp2*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
};
jmi_real_t func_CCodeGenTests_Functional3_fullFunc_fpcl4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fpout4* out, ...);
func_CCodeGenTests_Functional3_fullFunc_fp4* func_CCodeGenTests_Functional3_fullFunc_fpcr4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fp4* fp_out, ...);
jmi_real_t func_CCodeGenTests_Functional3_middleFunc_fpcl3(func_CCodeGenTests_Functional3_middleFunc_fp3* fp_in, func_CCodeGenTests_Functional3_middleFunc_fpout3* out, ...);
func_CCodeGenTests_Functional3_middleFunc_fp3* func_CCodeGenTests_Functional3_middleFunc_fpcr3(func_CCodeGenTests_Functional3_middleFunc_fp3* fp_in, func_CCodeGenTests_Functional3_middleFunc_fp3* fp_out, ...);
void func_CCodeGenTests_Functional3_useMiddleFunc_def0(func_CCodeGenTests_Functional3_middleFunc_fp3* mf_v, jmi_real_t b_v, jmi_real_t c_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional3_useMiddleFunc_exp0(func_CCodeGenTests_Functional3_middleFunc_fp3* mf_v, jmi_real_t b_v, jmi_real_t c_v);
void func_CCodeGenTests_Functional3_usePartFunc_def1(func_CCodeGenTests_Functional3_partFunc_fp2* pf_v, jmi_real_t c_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional3_usePartFunc_exp1(func_CCodeGenTests_Functional3_partFunc_fp2* pf_v, jmi_real_t c_v);
void func_CCodeGenTests_Functional3_partFunc_def2(jmi_real_t x1_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional3_partFunc_exp2(jmi_real_t x1_v);
void func_CCodeGenTests_Functional3_middleFunc_def3(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional3_middleFunc_exp3(jmi_real_t x1_v, jmi_real_t x2_v);
void func_CCodeGenTests_Functional3_fullFunc_def4(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional3_fullFunc_exp4(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v);

jmi_real_t func_CCodeGenTests_Functional3_fullFunc_fpcl4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fpout4* out, ...) {
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    jmi_real_t tmp_3;
    jmi_real_t tmp_4;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x3_v_s) {
        tmp_3 = fp_in->x3_v;
    } else {
        tmp_3 = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional3_fullFunc_def4(tmp_1, tmp_2, tmp_3, &tmp_4);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_4;
        }
    }
    return tmp_4;
}

func_CCodeGenTests_Functional3_fullFunc_fp4* func_CCodeGenTests_Functional3_fullFunc_fpcr4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fp4* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional3_fullFunc_fp4));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional3_fullFunc_fpcl4;
    fp_out->fpcr = &func_CCodeGenTests_Functional3_fullFunc_fpcr4;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
        fp_out->x3_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
        fp_out->x3_v_s = fp_in->x3_v_s;
        fp_out->x3_v = fp_in->x3_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x3_v_s && va_arg(argp, int)) {
        fp_out->x3_v_s = 1;
        fp_out->x3_v = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    return fp_out;
}

jmi_real_t func_CCodeGenTests_Functional3_middleFunc_fpcl3(func_CCodeGenTests_Functional3_middleFunc_fp3* fp_in, func_CCodeGenTests_Functional3_middleFunc_fpout3* out, ...) {
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    jmi_real_t tmp_3;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional3_middleFunc_def3(tmp_1, tmp_2, &tmp_3);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_3;
        }
    }
    return tmp_3;
}

func_CCodeGenTests_Functional3_middleFunc_fp3* func_CCodeGenTests_Functional3_middleFunc_fpcr3(func_CCodeGenTests_Functional3_middleFunc_fp3* fp_in, func_CCodeGenTests_Functional3_middleFunc_fp3* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional3_middleFunc_fp3));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional3_middleFunc_fpcl3;
    fp_out->fpcr = &func_CCodeGenTests_Functional3_middleFunc_fpcr3;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional3_useMiddleFunc_def0(func_CCodeGenTests_Functional3_middleFunc_fp3* mf_v, jmi_real_t b_v, jmi_real_t c_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional3_middleFunc_fp3* tmp_1;
    tmp_1 = mf_v->fpcr(mf_v, NULL, 0, 1, (jmi_real_t)(b_v));
    JMI_DYNAMIC_ADD(tmp_1)
    y_v = func_CCodeGenTests_Functional3_usePartFunc_exp1((func_CCodeGenTests_Functional3_partFunc_fp2*)tmp_1, c_v);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional3_useMiddleFunc_exp0(func_CCodeGenTests_Functional3_middleFunc_fp3* mf_v, jmi_real_t b_v, jmi_real_t c_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional3_useMiddleFunc_def0(mf_v, b_v, c_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_usePartFunc_def1(func_CCodeGenTests_Functional3_partFunc_fp2* pf_v, jmi_real_t c_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = pf_v->fpcl(pf_v, NULL, (jmi_real_t)(c_v));
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional3_usePartFunc_exp1(func_CCodeGenTests_Functional3_partFunc_fp2* pf_v, jmi_real_t c_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional3_usePartFunc_def1(pf_v, c_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_partFunc_def2(jmi_real_t x1_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional3_partFunc_exp2(jmi_real_t x1_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional3_partFunc_def2(x1_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_middleFunc_def3(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional3_middleFunc_exp3(jmi_real_t x1_v, jmi_real_t x2_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional3_middleFunc_def3(x1_v, x2_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_fullFunc_def4(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = x1_v + x2_v + x3_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional3_fullFunc_exp4(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional3_fullFunc_def4(x1_v, x2_v, x3_v, &y_v);
    return y_v;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    func_CCodeGenTests_Functional3_fullFunc_fp4 tmp_1;
    _y_0 = func_CCodeGenTests_Functional3_useMiddleFunc_exp0((func_CCodeGenTests_Functional3_middleFunc_fp3*)func_CCodeGenTests_Functional3_fullFunc_fpcr4(NULL, &tmp_1, 0, 0, 1, (jmi_real_t)(_time)), _time, _time);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Functional3;

model Functional4
    partial function partFunc
        input Real x1;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x2;
      algorithm
        assert(x1 < x2, "msg");
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
      algorithm
        pf(x);
    end usePartFunc;
  equation
    usePartFunc(function fullFunc(x2=time+1), time);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Functional4",
        description="Code generation for functional input arguments. No output.",
        generate_ode=true,
        equation_sorting=true,
        template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
typedef struct func_CCodeGenTests_Functional4_fullFunc_fpout2_ func_CCodeGenTests_Functional4_fullFunc_fpout2;
struct func_CCodeGenTests_Functional4_fullFunc_fpout2_ {
    int n;
};
typedef struct func_CCodeGenTests_Functional4_fullFunc_fp2_ func_CCodeGenTests_Functional4_fullFunc_fp2;
struct func_CCodeGenTests_Functional4_fullFunc_fp2_ {
    void (*fpcl)(func_CCodeGenTests_Functional4_fullFunc_fp2*, func_CCodeGenTests_Functional4_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional4_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional4_fullFunc_fp2*, func_CCodeGenTests_Functional4_fullFunc_fp2*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
    jmi_real_t x2_v;
    int x2_v_s;
};
typedef struct func_CCodeGenTests_Functional4_partFunc_fpout1_ func_CCodeGenTests_Functional4_partFunc_fpout1;
struct func_CCodeGenTests_Functional4_partFunc_fpout1_ {
    int n;
};
typedef struct func_CCodeGenTests_Functional4_partFunc_fp1_ func_CCodeGenTests_Functional4_partFunc_fp1;
struct func_CCodeGenTests_Functional4_partFunc_fp1_ {
    void (*fpcl)(func_CCodeGenTests_Functional4_partFunc_fp1*, func_CCodeGenTests_Functional4_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional4_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional4_partFunc_fp1*, func_CCodeGenTests_Functional4_partFunc_fp1*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
};
void func_CCodeGenTests_Functional4_fullFunc_fpcl2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional4_fullFunc_fp2* func_CCodeGenTests_Functional4_fullFunc_fpcr2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional4_usePartFunc_def0(func_CCodeGenTests_Functional4_partFunc_fp1* pf_v, jmi_real_t x_v);
void func_CCodeGenTests_Functional4_partFunc_def1(jmi_real_t x1_v);
void func_CCodeGenTests_Functional4_fullFunc_def2(jmi_real_t x1_v, jmi_real_t x2_v);

void func_CCodeGenTests_Functional4_fullFunc_fpcl2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fpout2* out, ...) {
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional4_fullFunc_def2(tmp_1, tmp_2);
    if (out != NULL) {
    }
}

func_CCodeGenTests_Functional4_fullFunc_fp2* func_CCodeGenTests_Functional4_fullFunc_fpcr2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional4_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional4_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional4_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional4_usePartFunc_def0(func_CCodeGenTests_Functional4_partFunc_fp1* pf_v, jmi_real_t x_v) {
    JMI_DYNAMIC_INIT()
    func_CCodeGenTests_Functional4_partFunc_fpout1 tmp_1;
    tmp_1.n = 0;
    pf_v->fpcl(pf_v, &tmp_1, (jmi_real_t)(x_v));
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_Functional4_partFunc_def1(jmi_real_t x1_v) {
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_Functional4_fullFunc_def2(jmi_real_t x1_v, jmi_real_t x2_v) {
    JMI_DYNAMIC_INIT()
    if (COND_EXP_LT(x1_v, x2_v, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"msg\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    func_CCodeGenTests_Functional4_fullFunc_fp2 tmp_1;
    func_CCodeGenTests_Functional4_usePartFunc_def0((func_CCodeGenTests_Functional4_partFunc_fp1*)func_CCodeGenTests_Functional4_fullFunc_fpcr2(NULL, &tmp_1, 0, 1, (jmi_real_t)(_time + 1.0)), _time);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Functional4;

model Functional5
    partial function partFunc
        input Real x1;
        input Real x3;
        input Real x5;
        output Real y;
    end partFunc;
    
    function fullFunc
        input Real x1;
        input Real x2;
        input Real x3;
        input Real x4;
        input Real x5;
        output Real y;
      algorithm
        y := x1 + x2 + x3 + x4 + x5;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        output Real y;
      algorithm
        y := pf(1,3,5);
    end usePartFunc;
    
    function usePartAlias = usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(x2=time, x4=4));
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Functional5",
        description="Code generation for functional input arguments. Interleaving binds.",
        generate_ode=true,
        equation_sorting=true,
        template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
        generatedCode="
typedef struct func_CCodeGenTests_Functional5_fullFunc_fpout2_ func_CCodeGenTests_Functional5_fullFunc_fpout2;
struct func_CCodeGenTests_Functional5_fullFunc_fpout2_ {
    int n;
    jmi_real_t y_v;
};
typedef struct func_CCodeGenTests_Functional5_fullFunc_fp2_ func_CCodeGenTests_Functional5_fullFunc_fp2;
struct func_CCodeGenTests_Functional5_fullFunc_fp2_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional5_fullFunc_fp2*, func_CCodeGenTests_Functional5_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional5_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional5_fullFunc_fp2*, func_CCodeGenTests_Functional5_fullFunc_fp2*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
    jmi_real_t x2_v;
    int x2_v_s;
    jmi_real_t x3_v;
    int x3_v_s;
    jmi_real_t x4_v;
    int x4_v_s;
    jmi_real_t x5_v;
    int x5_v_s;
};
typedef struct func_CCodeGenTests_Functional5_partFunc_fpout1_ func_CCodeGenTests_Functional5_partFunc_fpout1;
struct func_CCodeGenTests_Functional5_partFunc_fpout1_ {
    int n;
    jmi_real_t y_v;
};
typedef struct func_CCodeGenTests_Functional5_partFunc_fp1_ func_CCodeGenTests_Functional5_partFunc_fp1;
struct func_CCodeGenTests_Functional5_partFunc_fp1_ {
    jmi_real_t (*fpcl)(func_CCodeGenTests_Functional5_partFunc_fp1*, func_CCodeGenTests_Functional5_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional5_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional5_partFunc_fp1*, func_CCodeGenTests_Functional5_partFunc_fp1*, ...);
    jmi_real_t x1_v;
    int x1_v_s;
    jmi_real_t x3_v;
    int x3_v_s;
    jmi_real_t x5_v;
    int x5_v_s;
};
jmi_real_t func_CCodeGenTests_Functional5_fullFunc_fpcl2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional5_fullFunc_fp2* func_CCodeGenTests_Functional5_fullFunc_fpcr2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional5_usePartFunc_def0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional5_usePartFunc_exp0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v);
void func_CCodeGenTests_Functional5_partFunc_def1(jmi_real_t x1_v, jmi_real_t x3_v, jmi_real_t x5_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional5_partFunc_exp1(jmi_real_t x1_v, jmi_real_t x3_v, jmi_real_t x5_v);
void func_CCodeGenTests_Functional5_fullFunc_def2(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v, jmi_real_t x4_v, jmi_real_t x5_v, jmi_real_t* y_o);
jmi_real_t func_CCodeGenTests_Functional5_fullFunc_exp2(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v, jmi_real_t x4_v, jmi_real_t x5_v);

jmi_real_t func_CCodeGenTests_Functional5_fullFunc_fpcl2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fpout2* out, ...) {
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    jmi_real_t tmp_3;
    jmi_real_t tmp_4;
    jmi_real_t tmp_5;
    jmi_real_t tmp_6;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x3_v_s) {
        tmp_3 = fp_in->x3_v;
    } else {
        tmp_3 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x4_v_s) {
        tmp_4 = fp_in->x4_v;
    } else {
        tmp_4 = va_arg(argp, jmi_real_t);
    }
    if (fp_in->x5_v_s) {
        tmp_5 = fp_in->x5_v;
    } else {
        tmp_5 = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional5_fullFunc_def2(tmp_1, tmp_2, tmp_3, tmp_4, tmp_5, &tmp_6);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_6;
        }
    }
    return tmp_6;
}

func_CCodeGenTests_Functional5_fullFunc_fp2* func_CCodeGenTests_Functional5_fullFunc_fpcr2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional5_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional5_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional5_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
        fp_out->x3_v_s = 0;
        fp_out->x4_v_s = 0;
        fp_out->x5_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
        fp_out->x3_v_s = fp_in->x3_v_s;
        fp_out->x3_v = fp_in->x3_v;
        fp_out->x4_v_s = fp_in->x4_v_s;
        fp_out->x4_v = fp_in->x4_v;
        fp_out->x5_v_s = fp_in->x5_v_s;
        fp_out->x5_v = fp_in->x5_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x3_v_s && va_arg(argp, int)) {
        fp_out->x3_v_s = 1;
        fp_out->x3_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x4_v_s && va_arg(argp, int)) {
        fp_out->x4_v_s = 1;
        fp_out->x4_v = va_arg(argp, jmi_real_t);
    }
    if (!fp_out->x5_v_s && va_arg(argp, int)) {
        fp_out->x5_v_s = 1;
        fp_out->x5_v = va_arg(argp, jmi_real_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional5_usePartFunc_def0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = pf_v->fpcl(pf_v, NULL, (jmi_real_t)(1.0), (jmi_real_t)(3.0), (jmi_real_t)(5.0));
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional5_usePartFunc_exp0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional5_usePartFunc_def0(pf_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional5_partFunc_def1(jmi_real_t x1_v, jmi_real_t x3_v, jmi_real_t x5_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional5_partFunc_exp1(jmi_real_t x1_v, jmi_real_t x3_v, jmi_real_t x5_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional5_partFunc_def1(x1_v, x3_v, x5_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional5_fullFunc_def2(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v, jmi_real_t x4_v, jmi_real_t x5_v, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    y_v = x1_v + x2_v + x3_v + x4_v + x5_v;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CCodeGenTests_Functional5_fullFunc_exp2(jmi_real_t x1_v, jmi_real_t x2_v, jmi_real_t x3_v, jmi_real_t x4_v, jmi_real_t x5_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenTests_Functional5_fullFunc_def2(x1_v, x2_v, x3_v, x4_v, x5_v, &y_v);
    return y_v;
}



int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    func_CCodeGenTests_Functional5_fullFunc_fp2 tmp_1;
    _y1_0 = func_CCodeGenTests_Functional5_usePartFunc_exp0((func_CCodeGenTests_Functional5_partFunc_fp1*)func_CCodeGenTests_Functional5_fullFunc_fpcr2(NULL, &tmp_1, 0, 1, (jmi_real_t)(_time), 0, 1, (jmi_real_t)(4.0), 0));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Functional5;

model Delay1
    Real x1,x2;
  equation
    x1 = delay(time, 1);
    x2 = noEvent(delay(time, 1));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Delay1",
        description="Delay operator code gen: Basic",
        generate_ode=true,
        equation_sorting=true,
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 2;
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };

    jmi_delay_init(jmi, 0, JMI_TRUE, JMI_FALSE, 1.0, _time);
    jmi_delay_init(jmi, 1, JMI_TRUE, JMI_TRUE, 1.0, _time);

    jmi_delay_record_sample(jmi, 0, _time);
    jmi_delay_record_sample(jmi, 1, _time);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = _time;
    _x2_1 = (_time);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = jmi_delay_evaluate(jmi, 0, _time, 1.0);
    _x2_1 = (jmi_delay_evaluate(jmi, 1, _time, 1.0));
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Delay1;

model Delay2
    Real x1,x2,x3;
    parameter Real p = 10;
  equation
    x1 = delay(time, 1) + delay(time, 2);
    x2 = delay(x1, 3);
    x3 = delay(x1, x2, p);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Delay2",
        description="Delay operator code gen: Several",
        generate_ode=true,
        equation_sorting=true,
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 4;
static const int N_relations = 2;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ };

    jmi_delay_init(jmi, 0, JMI_TRUE, JMI_FALSE, 1.0, _time);
    jmi_delay_init(jmi, 1, JMI_TRUE, JMI_FALSE, 2.0, _time);
    jmi_delay_init(jmi, 2, JMI_TRUE, JMI_FALSE, 3.0, _x1_0);
    jmi_delay_init(jmi, 3, JMI_FALSE, JMI_FALSE, _p_3, _x1_0);

    jmi_delay_record_sample(jmi, 0, _time);
    jmi_delay_record_sample(jmi, 1, _time);
    jmi_delay_record_sample(jmi, 2, _x1_0);
    jmi_delay_record_sample(jmi, 3, _x1_0);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    __eventIndicator_1_4 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_2_5 = JMI_DELAY_INITIAL_EVENT_RES;
    _x1_0 = _time + _time;
    _x2_1 = _x1_0;
    _x3_2 = _x1_0;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = jmi_delay_evaluate(jmi, 0, _time, 1.0) + jmi_delay_evaluate(jmi, 1, _time, 2.0);
    _x2_1 = jmi_delay_evaluate(jmi, 2, _x1_0, 3.0);
    __eventIndicator_1_4 = jmi_delay_first_event_indicator_exp(jmi, 3, _x2_1);
    __eventIndicator_2_5 = jmi_delay_second_event_indicator_exp(jmi, 3, _x2_1);
    _x3_2 = jmi_delay_evaluate(jmi, 3, _x1_0, _x2_1);
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Delay2;

model Delay3
    Real x1,x2,x3;
    parameter Real p(fixed=false);
  initial equation
    p = x3;
  equation
    x1 = delay(time, 1) + delay(time, 2);
    x2 = delay(x1, 3);
    x3 = delay(x1, x2, p);
    
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Delay3",
        description="Delay operator code gen: Initial system loop",
        generate_ode=true,
        equation_sorting=true,
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$
$C_dae_init_blocks_residual_functions$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 4;
static const int N_relations = 2;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ };

    jmi_delay_init(jmi, 0, JMI_TRUE, JMI_FALSE, 1.0, _time);
    jmi_delay_init(jmi, 1, JMI_TRUE, JMI_FALSE, 2.0, _time);
    jmi_delay_init(jmi, 2, JMI_TRUE, JMI_FALSE, 3.0, _x1_0);
    jmi_delay_init(jmi, 3, JMI_FALSE, JMI_FALSE, _p_3, _x1_0);

    jmi_delay_record_sample(jmi, 0, _time);
    jmi_delay_record_sample(jmi, 1, _time);
    jmi_delay_record_sample(jmi, 2, _x1_0);
    jmi_delay_record_sample(jmi, 3, _x1_0);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    __eventIndicator_1_4 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_2_5 = JMI_DELAY_INITIAL_EVENT_RES;
    _x1_0 = _time + _time;
    _x2_1 = _x1_0;
    _x3_2 = _x1_0;
    _p_3 = _x3_2;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = jmi_delay_evaluate(jmi, 0, _time, 1.0) + jmi_delay_evaluate(jmi, 1, _time, 2.0);
    _x2_1 = jmi_delay_evaluate(jmi, 2, _x1_0, 3.0);
    __eventIndicator_1_4 = jmi_delay_first_event_indicator_exp(jmi, 3, _x2_1);
    __eventIndicator_2_5 = jmi_delay_second_event_indicator_exp(jmi, 3, _x2_1);
    _x3_2 = jmi_delay_evaluate(jmi, 3, _x1_0, _x2_1);
    JMI_DYNAMIC_FREE()
    return ef;
}



    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Delay3;

model Delay4
    function f
        input Real[:] x;
        output Real y = sum(x);
      algorithm
      annotation(Inline=false);
    end f;

    Real x1,x2,t;
    parameter Real p = 3;
  equation
    t = time;
    x1 = delay(f({t,t}), f({p,p}));
    x2 = delay(f({t,t}), f({t,t}), f({p,p}));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Delay4",
            description="Delay operator code gen: Array temp generation",
            generate_ode=true,
            equation_sorting=true,
            common_subexp_elim=false,
            template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
            generatedCode="
N_delays = 2;
static const int N_relations = 2;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ };

    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _t_2;
    jmi_array_ref_1(tmp_1, 2) = _t_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _p_3;
    jmi_array_ref_1(tmp_2, 2) = _p_3;
    jmi_delay_init(jmi, 0, JMI_TRUE, JMI_FALSE, func_CCodeGenTests_Delay4_f_exp0(tmp_2), func_CCodeGenTests_Delay4_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = _t_2;
    jmi_array_ref_1(tmp_3, 2) = _t_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1, 2)
    jmi_array_ref_1(tmp_4, 1) = _p_3;
    jmi_array_ref_1(tmp_4, 2) = _p_3;
    jmi_delay_init(jmi, 1, JMI_FALSE, JMI_FALSE, func_CCodeGenTests_Delay4_f_exp0(tmp_4), func_CCodeGenTests_Delay4_f_exp0(tmp_3));

    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _t_2;
    jmi_array_ref_1(tmp_1, 2) = _t_2;
    jmi_delay_record_sample(jmi, 0, func_CCodeGenTests_Delay4_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = _t_2;
    jmi_array_ref_1(tmp_3, 2) = _t_2;
    jmi_delay_record_sample(jmi, 1, func_CCodeGenTests_Delay4_f_exp0(tmp_3));


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1)
    _t_2 = _time;
    __eventIndicator_1_4 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_2_5 = JMI_DELAY_INITIAL_EVENT_RES;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1, 2)
    jmi_array_ref_1(tmp_5, 1) = _t_2;
    jmi_array_ref_1(tmp_5, 2) = _t_2;
    _x1_0 = func_CCodeGenTests_Delay4_f_exp0(tmp_5);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1, 2)
    jmi_array_ref_1(tmp_6, 1) = _t_2;
    jmi_array_ref_1(tmp_6, 2) = _t_2;
    _x2_1 = func_CCodeGenTests_Delay4_f_exp0(tmp_6);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_7, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_8, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_9, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_10, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_11, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_12, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_13, 2, 1)
    _t_2 = _time;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_7, 2, 1, 2)
    jmi_array_ref_1(tmp_7, 1) = _t_2;
    jmi_array_ref_1(tmp_7, 2) = _t_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_8, 2, 1, 2)
    jmi_array_ref_1(tmp_8, 1) = _p_3;
    jmi_array_ref_1(tmp_8, 2) = _p_3;
    _x1_0 = jmi_delay_evaluate(jmi, 0, func_CCodeGenTests_Delay4_f_exp0(tmp_7), func_CCodeGenTests_Delay4_f_exp0(tmp_8));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_9, 2, 1, 2)
    jmi_array_ref_1(tmp_9, 1) = _t_2;
    jmi_array_ref_1(tmp_9, 2) = _t_2;
    __eventIndicator_1_4 = jmi_delay_first_event_indicator_exp(jmi, 1, func_CCodeGenTests_Delay4_f_exp0(tmp_9));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_10, 2, 1, 2)
    jmi_array_ref_1(tmp_10, 1) = _t_2;
    jmi_array_ref_1(tmp_10, 2) = _t_2;
    __eventIndicator_2_5 = jmi_delay_second_event_indicator_exp(jmi, 1, func_CCodeGenTests_Delay4_f_exp0(tmp_10));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_11, 2, 1, 2)
    jmi_array_ref_1(tmp_11, 1) = _t_2;
    jmi_array_ref_1(tmp_11, 2) = _t_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_12, 2, 1, 2)
    jmi_array_ref_1(tmp_12, 1) = _t_2;
    jmi_array_ref_1(tmp_12, 2) = _t_2;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_13, 2, 1, 2)
    jmi_array_ref_1(tmp_13, 1) = _p_3;
    jmi_array_ref_1(tmp_13, 2) = _p_3;
    _x2_1 = jmi_delay_evaluate(jmi, 1, func_CCodeGenTests_Delay4_f_exp0(tmp_11), func_CCodeGenTests_Delay4_f_exp0(tmp_12));
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Delay4;

model Delay5
    Real x,y;
  equation
    y = time + 2;
    x = delay(if time > 1 then time else time + 1, y, 10);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Delay5",
        description="Delay operator code gen: Event generation",
        generate_ode=true,
        equation_sorting=true,
        relational_time_events=false,
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 1;
static const int N_relations = 3;
static const int DAE_relations[] = { JMI_REL_GT, JMI_REL_GEQ, JMI_REL_GEQ };

    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
    }
    jmi_delay_init(jmi, 0, JMI_FALSE, JMI_FALSE, 10.0, COND_EXP_EQ(_sw(0), JMI_TRUE, _time, _time + 1.0));

    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
    }
    jmi_delay_record_sample(jmi, 0, COND_EXP_EQ(_sw(0), JMI_TRUE, _time, _time + 1.0));


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_1 = _time + 2;
    __eventIndicator_1_2 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_2_3 = JMI_DELAY_INITIAL_EVENT_RES;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
    }
    _x_0 = COND_EXP_EQ(_sw(0), JMI_TRUE, _time, _time + 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _y_1 = _time + 2;
    __eventIndicator_1_2 = jmi_delay_first_event_indicator_exp(jmi, 0, _y_1);
    __eventIndicator_2_3 = jmi_delay_second_event_indicator_exp(jmi, 0, _y_1);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (1.0), _sw(0), JMI_REL_GT);
    }
    _x_0 = jmi_delay_evaluate(jmi, 0, COND_EXP_EQ(_sw(0), JMI_TRUE, _time, _time + 1.0), _y_1);
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (1.0);
    (*res)[1] = __eventIndicator_1_2;
    (*res)[2] = __eventIndicator_2_3;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = _time - (1.0);
    (*res)[1] = __eventIndicator_1_2;
    (*res)[2] = __eventIndicator_2_3;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Delay5;

model Delay6
    Real x1;
  equation
    x1 = delay(time, 1, 2);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="Delay6",
        description="",
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 1;
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };

    jmi_delay_init(jmi, 0, JMI_TRUE, JMI_FALSE, 1.0, _time);

    jmi_delay_record_sample(jmi, 0, _time);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = _time;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x1_0 = jmi_delay_evaluate(jmi, 0, _time, 1.0);
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Delay6;

model Delay7
    function f
        input Real[:] x;
        output Real y = sum(x);
      algorithm
      annotation(Inline=false);
    end f;

    Real x, t;
    parameter Real p = 3;
  equation
    t = time;
    x = delay(time, delay(time, delay(time, f({t,t}), 1), 10), 100);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Delay7",
            description="Delay operator code gen: Nested delays",
            generate_ode=true,
            equation_sorting=true,
            common_subexp_elim=false,
            template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
            generatedCode="
N_delays = 3;
static const int N_relations = 6;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ };

    jmi_delay_init(jmi, 0, JMI_FALSE, JMI_FALSE, 100.0, _time);
    jmi_delay_init(jmi, 1, JMI_FALSE, JMI_FALSE, 10.0, _time);
    jmi_delay_init(jmi, 2, JMI_FALSE, JMI_FALSE, 1.0, _time);

    jmi_delay_record_sample(jmi, 0, _time);
    jmi_delay_record_sample(jmi, 1, _time);
    jmi_delay_record_sample(jmi, 2, _time);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _t_1 = _time;
    __eventIndicator_1_3 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_2_4 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_3_5 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_4_6 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_5_7 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_6_8 = JMI_DELAY_INITIAL_EVENT_RES;
    _x_0 = _time;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_7, 2, 1)
    _t_1 = _time;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _t_1;
    jmi_array_ref_1(tmp_1, 2) = _t_1;
    __eventIndicator_5_7 = jmi_delay_first_event_indicator_exp(jmi, 2, func_CCodeGenTests_Delay7_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _t_1;
    jmi_array_ref_1(tmp_2, 2) = _t_1;
    __eventIndicator_6_8 = jmi_delay_second_event_indicator_exp(jmi, 2, func_CCodeGenTests_Delay7_f_exp0(tmp_2));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = _t_1;
    jmi_array_ref_1(tmp_3, 2) = _t_1;
    __eventIndicator_3_5 = jmi_delay_first_event_indicator_exp(jmi, 1, jmi_delay_evaluate(jmi, 2, _time, func_CCodeGenTests_Delay7_f_exp0(tmp_3)));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1, 2)
    jmi_array_ref_1(tmp_4, 1) = _t_1;
    jmi_array_ref_1(tmp_4, 2) = _t_1;
    __eventIndicator_4_6 = jmi_delay_second_event_indicator_exp(jmi, 1, jmi_delay_evaluate(jmi, 2, _time, func_CCodeGenTests_Delay7_f_exp0(tmp_4)));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1, 2)
    jmi_array_ref_1(tmp_5, 1) = _t_1;
    jmi_array_ref_1(tmp_5, 2) = _t_1;
    __eventIndicator_1_3 = jmi_delay_first_event_indicator_exp(jmi, 0, jmi_delay_evaluate(jmi, 1, _time, jmi_delay_evaluate(jmi, 2, _time, func_CCodeGenTests_Delay7_f_exp0(tmp_5))));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1, 2)
    jmi_array_ref_1(tmp_6, 1) = _t_1;
    jmi_array_ref_1(tmp_6, 2) = _t_1;
    __eventIndicator_2_4 = jmi_delay_second_event_indicator_exp(jmi, 0, jmi_delay_evaluate(jmi, 1, _time, jmi_delay_evaluate(jmi, 2, _time, func_CCodeGenTests_Delay7_f_exp0(tmp_6))));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_7, 2, 1, 2)
    jmi_array_ref_1(tmp_7, 1) = _t_1;
    jmi_array_ref_1(tmp_7, 2) = _t_1;
    _x_0 = jmi_delay_evaluate(jmi, 0, _time, jmi_delay_evaluate(jmi, 1, _time, jmi_delay_evaluate(jmi, 2, _time, func_CCodeGenTests_Delay7_f_exp0(tmp_7))));
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_3;
    (*res)[1] = __eventIndicator_2_4;
    (*res)[2] = __eventIndicator_3_5;
    (*res)[3] = __eventIndicator_4_6;
    (*res)[4] = __eventIndicator_5_7;
    (*res)[5] = __eventIndicator_6_8;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_3;
    (*res)[1] = __eventIndicator_2_4;
    (*res)[2] = __eventIndicator_3_5;
    (*res)[3] = __eventIndicator_4_6;
    (*res)[4] = __eventIndicator_5_7;
    (*res)[5] = __eventIndicator_6_8;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end Delay7;


model DelayOnlyStateEvents
    Real x1,x2;
  equation
    x1 = delay(time, 1);
    x2 = noEvent(delay(time, 1));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="DelayOnlyStateEvents",
        description="similar to Delay1, but should generate only state events when the option time_events=false",
        time_events=false,
        generate_ode=true,
        equation_sorting=true,
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 2;
static const int N_relations = 2;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ };

    jmi_delay_init(jmi, 0, JMI_FALSE, JMI_FALSE, 1.0, _time);
    jmi_delay_init(jmi, 1, JMI_FALSE, JMI_TRUE, 1.0, _time);

    jmi_delay_record_sample(jmi, 0, _time);
    jmi_delay_record_sample(jmi, 1, _time);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    __eventIndicator_1_2 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_2_3 = JMI_DELAY_INITIAL_EVENT_RES;
    _x1_0 = _time;
    _x2_1 = (_time);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    __eventIndicator_1_2 = jmi_delay_first_event_indicator_exp(jmi, 0, 1.0);
    __eventIndicator_2_3 = jmi_delay_second_event_indicator_exp(jmi, 0, 1.0);
    _x1_0 = jmi_delay_evaluate(jmi, 0, _time, 1.0);
    _x2_1 = (jmi_delay_evaluate(jmi, 1, _time, 1.0));
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_2;
    (*res)[1] = __eventIndicator_2_3;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_2;
    (*res)[1] = __eventIndicator_2_3;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end DelayOnlyStateEvents;

model DelayStateEvents1
    discrete Real x(start=0.0, fixed=true);
    output Real y;
equation
    when (time >= 0.5) then
        x = 2;
    end when;
    y = delay(x, 1);
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="DelayStateEvents1",
        description="",
        time_events=false,
        event_output_vars=true,
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 1;
static const int N_relations = 3;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ };

    jmi_delay_init(jmi, 0, JMI_FALSE, JMI_FALSE, 1.0, _x_0);

    jmi_delay_record_sample(jmi, 0, _x_0);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, __eventIndicator_1_2, _sw(0), JMI_REL_GEQ);
    }
    _temp_1_5 = _sw(0);
    __eventIndicator_1_2 = _time + -0.5;
    __eventIndicator_2_3 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_3_4 = JMI_DELAY_INITIAL_EVENT_RES;
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    _y_1 = _x_0;
    pre_temp_1_5 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, __eventIndicator_1_2, _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    __eventIndicator_2_3 = jmi_delay_first_event_indicator_exp(jmi, 0, 1.0);
    __eventIndicator_3_4 = jmi_delay_second_event_indicator_exp(jmi, 0, 1.0);
    _y_1 = jmi_delay_evaluate(jmi, 0, _x_0, 1.0);
    __eventIndicator_1_2 = _time + -0.5;
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_2;
    (*res)[1] = __eventIndicator_2_3;
    (*res)[2] = __eventIndicator_3_4;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_2;
    (*res)[1] = __eventIndicator_2_3;
    (*res)[2] = __eventIndicator_3_4;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end DelayStateEvents1;

model DelayStateEvents2
    discrete Real x(start=0.0, fixed=true);
    output Real y;
    Real tmp;
equation
    tmp = sin(time * 100);
    when (time >= 0.5) then
        x = 2;
    end when;
    y = delay(x, tmp, 1);
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="DelayStateEvents2",
        description="",
        time_events=false,
        event_output_vars=true,
        template="
N_delays = $n_delays$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_delays = 1;
static const int N_relations = 3;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ };

    jmi_delay_init(jmi, 0, JMI_FALSE, JMI_FALSE, 1.0, _x_0);

    jmi_delay_record_sample(jmi, 0, _x_0);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _tmp_2 = sin(_time * 100.0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, __eventIndicator_1_3, _sw(0), JMI_REL_GEQ);
    }
    _temp_1_6 = _sw(0);
    __eventIndicator_1_3 = _time + -0.5;
    __eventIndicator_2_4 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_3_5 = JMI_DELAY_INITIAL_EVENT_RES;
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    _y_1 = _x_0;
    pre_temp_1_6 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, __eventIndicator_1_3, _sw(0), JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _tmp_2 = sin(_time * 100.0);
    __eventIndicator_2_4 = jmi_delay_first_event_indicator_exp(jmi, 0, _tmp_2);
    __eventIndicator_3_5 = jmi_delay_second_event_indicator_exp(jmi, 0, _tmp_2);
    _y_1 = jmi_delay_evaluate(jmi, 0, _x_0, _tmp_2);
    __eventIndicator_1_3 = _time + -0.5;
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_3;
    (*res)[1] = __eventIndicator_2_4;
    (*res)[2] = __eventIndicator_3_5;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_3;
    (*res)[1] = __eventIndicator_2_4;
    (*res)[2] = __eventIndicator_3_5;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end DelayStateEvents2;

model SpatialDist1
    Real x1,x2,x3,x4;
  equation
    (x1,x2) = spatialDistribution(time+1, time+2, time+3, true, initialPoints={1,2}, initialValues={3,4});
    (,x3) = spatialDistribution(time+1, time+2, time+3, false, initialPoints={1,2}, initialValues={3,4});
    x4 = noEvent(spatialDistribution(time+1, time+2, time+3, true));

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SpatialDist1",
        description="SpatialDistribution operator code gen: Basic",
        generate_ode=true,
        equation_sorting=true,
        template="
N_spatialdists = $n_spatialdists$;
$C_DAE_relations$

$C_delay_init$
$C_delay_sample$
$C_ode_initialization$
$C_ode_derivatives$

$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
        generatedCode="
N_spatialdists = 3;
static const int N_relations = 2;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ };

    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = 3.0;
    jmi_array_ref_1(tmp_2, 2) = 4.0;
    jmi_spatialdist_init(jmi, 0, JMI_FALSE, _time + 3.0, tmp_1, tmp_2);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = 1.0;
    jmi_array_ref_1(tmp_3, 2) = 2.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_4, 2, 1, 2)
    jmi_array_ref_1(tmp_4, 1) = 3.0;
    jmi_array_ref_1(tmp_4, 2) = 4.0;
    jmi_spatialdist_init(jmi, 1, JMI_FALSE, _time + 3.0, tmp_3, tmp_4);
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1, 2)
    jmi_array_ref_1(tmp_5, 1) = 0.0;
    jmi_array_ref_1(tmp_5, 2) = 1.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1, 2)
    jmi_array_ref_1(tmp_6, 1) = 0.0;
    jmi_array_ref_1(tmp_6, 2) = 0.0;
    jmi_spatialdist_init(jmi, 2, JMI_TRUE, _time + 3.0, tmp_5, tmp_6);

    jmi_spatialdist_record_sample(jmi, 0, _time + 1.0, _time + 2.0, _time + 3.0, JMI_TRUE);
    jmi_spatialdist_record_sample(jmi, 1, _time + 1.0, _time + 2.0, _time + 3.0, JMI_FALSE);
    jmi_spatialdist_record_sample(jmi, 2, _time + 1.0, _time + 2.0, _time + 3.0, JMI_TRUE);


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    __eventIndicator_1_4 = JMI_DELAY_INITIAL_EVENT_RES;
    __eventIndicator_2_5 = JMI_DELAY_INITIAL_EVENT_RES;
    _x1_0 = COND_EXP_EQ(JMI_TRUE, JMI_TRUE, 3.0, 4.0);
    _x2_1 = COND_EXP_EQ(JMI_TRUE, JMI_TRUE, 4.0, 3.0);
    _x3_2 = COND_EXP_EQ(JMI_FALSE, JMI_TRUE, 4.0, 3.0);
    _x4_3 = 0.0;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_7)
    JMI_DEF(REA, tmp_8)
    JMI_DEF(REA, tmp_9)
    __eventIndicator_1_4 = jmi_spatialdist_event_indicator_exp(jmi, 0, _time + 3.0, JMI_TRUE);
    jmi_spatialdist_evaluate(jmi, 0, &tmp_7, &tmp_8, _time + 1.0, _time + 2.0, _time + 3.0, JMI_TRUE);
    _x1_0 = (tmp_7);
    _x2_1 = (tmp_8);
    __eventIndicator_2_5 = jmi_spatialdist_event_indicator_exp(jmi, 1, _time + 3.0, JMI_FALSE);
    jmi_spatialdist_evaluate(jmi, 1, NULL, &tmp_9, _time + 1.0, _time + 2.0, _time + 3.0, JMI_FALSE);
    _x3_2 = (tmp_9);
    _x4_3 = (jmi_spatialdist_evaluate(jmi, 2, NULL, NULL, _time + 1.0, _time + 2.0, _time + 3.0, JMI_TRUE));
    JMI_DYNAMIC_FREE()
    return ef;
}


    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;

    int ef = 0;
    JMI_DYNAMIC_INIT()
    (*res)[0] = __eventIndicator_1_4;
    (*res)[1] = __eventIndicator_2_5;
    JMI_DYNAMIC_FREE()
    return ef;
")})));
end SpatialDist1;

model SpatialDist2
    Real x1,x2,x3,x4;
  equation
    der(x3) = time;
    der(x4) = time;
    (x3,x4) = spatialDistribution(x1, x2, time+3, true, initialPoints={1,2}, initialValues={3,4});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SpatialDist2",
        description="SpatialDistribution operator code gen: FFunctionCallEquation in a block",
        generate_ode=true,
        equation_sorting=true,
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, tmp_1)
    JMI_DEF(REA, tmp_2)
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 4;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
        (*res)[1] = (*res)[0];
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x2_1;
        x[1] = _x1_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x2_1 = x[0];
            _x1_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            jmi_spatialdist_evaluate(jmi, 0, &tmp_1, &tmp_2, _x1_0, _x2_1, _time + 3.0, JMI_TRUE);
            (*res)[0] = tmp_1 - (_x3_2);
            (*res)[1] = tmp_2 - (_x4_3);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end SpatialDist2;

model SpatialDist3
    function f
        input Real[:] x;
        output Real y = sum(x);
      algorithm
      annotation(Inline=false);
    end f;
    function g
        input Real[2] x;
        output Boolean y = sum(x) > 1;
      algorithm
      annotation(Inline=false);
    end g;

    Real x1,x2;
  equation
    (x1,x2) = spatialDistribution(f({time,1}), f({time,2}), f({time,3}), g({time,time}), initialPoints={1,2}, initialValues={3,4});

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="SpatialDist3",
        description="SpatialDistribution operator code gen: Temporaries",
        generate_ode=true,
        equation_sorting=true,
        common_subexp_elim=false,
        template="$C_ode_derivatives$",
        generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_DEF(REA, tmp_3)
    JMI_DEF(REA, tmp_4)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_7, 2, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_8, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _time;
    jmi_array_ref_1(tmp_1, 2) = 3.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _time;
    jmi_array_ref_1(tmp_2, 2) = _time;
    __eventIndicator_1_2 = jmi_spatialdist_event_indicator_exp(jmi, 0, func_CCodeGenTests_SpatialDist3_f_exp0(tmp_1), func_CCodeGenTests_SpatialDist3_g_exp1(tmp_2));
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_5, 2, 1, 2)
    jmi_array_ref_1(tmp_5, 1) = _time;
    jmi_array_ref_1(tmp_5, 2) = 1.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_6, 2, 1, 2)
    jmi_array_ref_1(tmp_6, 1) = _time;
    jmi_array_ref_1(tmp_6, 2) = 2.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_7, 2, 1, 2)
    jmi_array_ref_1(tmp_7, 1) = _time;
    jmi_array_ref_1(tmp_7, 2) = 3.0;
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_8, 2, 1, 2)
    jmi_array_ref_1(tmp_8, 1) = _time;
    jmi_array_ref_1(tmp_8, 2) = _time;
    jmi_spatialdist_evaluate(jmi, 0, &tmp_3, &tmp_4, func_CCodeGenTests_SpatialDist3_f_exp0(tmp_5), func_CCodeGenTests_SpatialDist3_f_exp0(tmp_6), func_CCodeGenTests_SpatialDist3_f_exp0(tmp_7), func_CCodeGenTests_SpatialDist3_g_exp1(tmp_8));
    _x1_0 = (tmp_3);
    _x2_1 = (tmp_4);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SpatialDist3;

model DiscreteInput
        input Boolean b;
    equation
        when b then
            assert(false, "msg");
        end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="DiscreteInput",
            description="Code generated from a discrete input.",
            equation_sorting=true,
            generate_ode=true,
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (LOG_EXP_AND(_b_0, LOG_EXP_NOT(pre_b_0))) {
        if (JMI_FALSE == JMI_FALSE) {
            jmi_assert_failed(\"msg\", JMI_ASSERT_ERROR);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end DiscreteInput;

model AliasNegParam1
    parameter Real x = 1;
    parameter Real y = x + 1;
    parameter Real z = -y;
annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="AliasNegParam1",
        description="",
        eliminate_alias_parameters=true,
        template="$C_model_init_eval_dependent_parameters$",
        generatedCode="

int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _z_1 = -(_x_0 + 1);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end AliasNegParam1;


model LinearityCheckMul1
    Real a, b;
equation
    a * a + a = time;
    b .* b + b = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="LinearityCheckMul1",
            description="",
            template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);
")})));
end LinearityCheckMul1;

model LinearityCheckDiv1
    Real a, b;
equation
    a / (1 / a) + a = time;
    b ./ (1 ./ b) + b = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="LinearityCheckDiv1",
            description="",
            template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);
")})));
end LinearityCheckDiv1;

model LinearityCheckPow1
    Real a,b;
equation
	a^2 + a  = 2; 
    b.^2 + b = 2; 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="LinearityCheckPow1",
            description="",
            template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);
")})));
end LinearityCheckPow1;

model NonlinearSolverChoice1
    Real a,b;
equation
    a^2 + a  = 2; 
    b.^2 + b = 2; 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="NonlinearSolverChoice1",
            description="",
            init_nonlinear_solver="realtime",
            template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 1, \"2\", -1);

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);
")})));
end NonlinearSolverChoice1;

model NonlinearSolverChoice2
    Real a,b;
equation
    a^2 + a  = 2; 
    b.^2 + b = 2; 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="NonlinearSolverChoice2",
            description="",
            nonlinear_solver="realtime",
            template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0,0,  0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 1, \"2\", -1);
")})));
end NonlinearSolverChoice2;

model NonlinearSolverChoice3
    Real a,b;
equation
    a^2 + a  = 2; 
    b.^2 + b = 2; 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="NonlinearSolverChoice3",
            description="",
            nonlinear_solver="realtime",
            init_nonlinear_solver="realtime",
            template="
$C_dae_init_add_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 1, \"2\", -1);

    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, NULL, NULL, 1, 0, 0, 0, 0, 0, 0, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_REALTIME_SOLVER, 1, \"2\", -1);
")})));
end NonlinearSolverChoice3;

model RecordScalarTemp1
    operator record R
        Real x;
        
        encapsulated operator '*'
            function mul
                input R a;
                input R b;
                output R c;
            algorithm
                c := R(a.x*b.x);
            end mul;
        end '*';
    end R;
    
    function f
        input Real x;
        output R r;
    algorithm
        r := R(x)*R(x);
        annotation(Inline=false);
    end f;
    
    R r = f(time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordScalarTemp1",
            description="",
            template="
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_RecordScalarTemp1_f_def0(jmi_real_t x_v, R_0_r* r_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, r_vn)
    JMI_RECORD_STATIC(R_0_r, temp_1_v)
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_RECORD_STATIC(R_0_r, tmp_2)
    if (r_v == NULL) {
        r_v = r_vn;
    }
    tmp_1->x = x_v;
    tmp_2->x = x_v;
    func_CCodeGenTests_RecordScalarTemp1_R_____mul_def1(tmp_1, tmp_2, temp_1_v);
    r_v->x = temp_1_v->x;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_RecordScalarTemp1_R_____mul_def1(R_0_r* a_v, R_0_r* b_v, R_0_r* c_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, c_vn)
    if (c_v == NULL) {
        c_v = c_vn;
    }
    c_v->x = a_v->x * b_v->x;
    JMI_DYNAMIC_FREE()
    return;
}
")})));
end RecordScalarTemp1;

end CCodeGenTests;
