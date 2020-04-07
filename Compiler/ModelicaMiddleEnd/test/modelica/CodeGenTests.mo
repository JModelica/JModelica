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

package CodeGenTests


  model CodeGenTest1
  	parameter Real rp1=1;
  	parameter Real rp2=rp1;
    parameter Real rp3(start=1);
    parameter Real rp4(start=rp1);
    parameter Real rp5(start=rp1) = 5;
    Real r1(start=1);
    Real r2=3;
    Real r3;
	input Real r4;

  	parameter Integer ip1=1;
  	parameter Integer ip2=ip1;
    parameter Integer ip3(start=1);
    parameter Integer ip4(start=ip1);
    parameter Integer ip5(start=ip1) = 5;
    Integer i1(start=1);
    Integer i2=3;
  	Integer i3=4;
	input Integer i4;

  	parameter Boolean bp1=true;
  	parameter Boolean bp2=bp1;
    parameter Boolean bp3(start=true);
    parameter Boolean bp4(start=bp1);
    parameter Boolean bp5(start=bp1) = false;
    Boolean b1(start=true);
    Boolean b2=true;
	Boolean b3=true;
	input Boolean b4;
		
  	parameter String sp1="hello";
  	parameter String sp2=sp1;
    parameter String sp3(start="hello");
    parameter String sp4(start=sp1);
    parameter String sp5(start=sp1) = "hello";
    String s1(start="hello");
    String s2="hello";
	String s3="hello";
	input String s4;
    
    equation 
     r1 = 1;
     der(r3)=1;
     i1 = 1;
     b1 = true;
     s2 = "hello";

    annotation(__JModelica(UnitTesting(tests={
        GenericCodeGenTestCase(
            name="CodeGenTest1",
            description="Test of code generation",
            variability_propagation=false,
            eliminate_alias_variables=false,
            automatic_add_initial_equations=false,
            enable_structural_diagnosis=false,
            index_reduction=false,
            compliance_as_warning=true,
            template="
n_ci: $n_ci$
n_real_ci: $n_real_ci$
n_integer_ci: $n_integer_ci$
n_boolean_ci: $n_boolean_ci$
n_string_ci $n_string_ci$
n_cd: $n_cd$
n_real_cd: $n_real_cd$
n_integer_cd: $n_integer_cd$
n_boolean_cd: $n_boolean_cd$
n_string_cd: $n_string_cd$
n_pi: $n_pi$
n_real_pi: $n_real_pi$
n_integer_pi: $n_integer_pi$
n_boolean_pi: $n_boolean_pi$
n_string_pi: $n_string_pi$
n_pd: $n_pd$
n_real_pd: $n_real_pd$
n_integer_pd: $n_integer_pd$
n_boolean_pd: $n_boolean_pd$
n_string_pd: $n_string_pd$
n_real_w: $n_real_w$
n_d: $n_d$
n_real_d: $n_real_d$
n_integer_d: $n_integer_d$
n_boolean_d: $n_boolean_d$
n_string_d: $n_string_d$
n_real_x: $n_real_x$
n_u: $n_u$
n_real_u: $n_real_u$
n_integer_u: $n_integer_u$
n_boolean_u: $n_boolean_u$
n_string_u: $n_string_u$
n_equations: $n_equations$
n_initial_equations: $n_initial_equations$
",
        generatedCode="
n_ci: 0
n_real_ci: 0
n_integer_ci: 0
n_boolean_ci: 0
n_string_ci 0
n_cd: 0
n_real_cd: 0
n_integer_cd: 0
n_boolean_cd: 0
n_string_cd: 0
n_pi: 16
n_real_pi: 4
n_integer_pi: 4
n_boolean_pi: 4
n_string_pi: 4
n_pd: 4
n_real_pd: 1
n_integer_pd: 1
n_boolean_pd: 1
n_string_pd: 1
n_real_w: 2
n_d: 9
n_real_d: 0
n_integer_d: 3
n_boolean_d: 3
n_string_d: 3
n_real_x: 1
n_u: 4
n_real_u: 1
n_integer_u: 1
n_boolean_u: 1
n_string_u: 1
n_equations: 12
n_initial_equations: 0
")})));
  end CodeGenTest1;


	model CodeGenTest2
		Real x;
    equation
        der(x)=1;
		
    annotation(__JModelica(UnitTesting(tests={
        GenericCodeGenTestCase(
            name="CodeGenTest2",
            description="Test of code generation",
            variability_propagation=false,
            template="$n_real_x$",
            generatedCode="1")})));
	end CodeGenTest2;

	
	model CodeGenTest3
	
		parameter Real p1 = 5;
		parameter Real p2 = p1+4;
		parameter Real p3 = p2-1;
		parameter Real p4 = p3*6;
		parameter Real p5 = p4/6;
		parameter Real p6 = -p5;
		parameter Real p7 = p6/83;
		parameter Real p8 = p7^2;
   	 equation
   	end CodeGenTest3;

	
	model CodeGenTest4	
		Real r(quantity="q", unit="kg", displayUnit="g", 
		  min=-2-1,max=4,start=1+1,fixed=false,nominal=4-3) = 1;
		Integer i(quantity="q", min=-2-1,max=4,start=1+1,fixed=false) = 1;
		Boolean b(quantity="q", start=true,fixed=false) = 1;
		String s(quantity="q",start="qwe") = 1;


   	 equation
	end CodeGenTest4;
	
	
	model CodeGenTest5
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

    annotation(__JModelica(UnitTesting(tests={
        GenericCodeGenTestCase(
            name="CodeGenTest5",
            description="Code generation for enumerations: number of enum vars of different types",
            variability_propagation=false,
            eliminate_alias_variables=false,
            template="
n_enum_ci: $n_enum_ci$
n_enum_cd: $n_enum_cd$
n_enum_pi: $n_enum_pi$
n_enum_pd: $n_enum_pd$
",
         generatedCode="
n_enum_ci: 4
n_enum_cd: 0
n_enum_pi: 2
n_enum_pd: 2
")})));
	end CodeGenTest5;
	
	
	
	model HookCodeGenTest1
		Real x = 1;

	annotation(__JModelica(UnitTesting(tests={
		GenericCodeGenTestCase(
			name="HookCodeGenTest1",
			description="Test that undefined hook tags don't generate errors",
			template="$HOOK__not_defined$",
			generatedCode="
")})));
	end HookCodeGenTest1;



end CodeGenTests;
