/*
    Copyright (C) 2011-2013 Modelon AB

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

package ComplianceTests


/*
model String_ComplErr

 String str1="s1";
 parameter String str2="s2";


	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="String_ComplErr",
			description="Compliance error for String variables",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 73, column 9:
  String variables are not supported
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 74, column 19:
  String variables are not supported
")})));
end String_ComplErr;
*/

model IntegerVariable_ComplErr

Integer i=1;


    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="IntegerVariable_ComplErr",
            description="Compliance error for integer variables",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
1 errors found:

Compliance error at line 3, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_INTEGER_VARIABLES:
  Integer variables of discrete variability is currently only supported when compiling FMUs
")})));
end IntegerVariable_ComplErr;

model BooleanVariable_ComplErr
 Boolean b=true;


    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="BooleanVariable_ComplErr",
            description="Compliance error for boolean variables",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
1 errors found:

Compliance error at line 2, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_BOOLEAN_VARIABLES:
  Boolean variables of discrete variability is currently only supported when compiling FMUs
")})));
end BooleanVariable_ComplErr;

model EnumVariable_ComplErr
 type A = enumeration(a, b, c);
 A x = A.b;


    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="EnumVariable_ComplErr",
            description="Compliance error for enumeration variables",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
1 errors found:

Compliance error at line 3, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_ENUMERATION_VARIABLES:
  Enumeration variables of discrete variability is currently only supported when compiling FMUs
")})));
end EnumVariable_ComplErr;

model ArrayOfRecords_Warn
 function f
  input Real i;
  output R[2] a;
 algorithm
  a := {R(1,2), R(3,4)};
  a[integer(i)].a := 0;
 end f;

 record R
  Real a;
  Real b;
 end R;
 
 R x[2] = f(1);

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayOfRecords_Warn",
            description="Compliance warning for arrays of records with index variability > parameter",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
2 errors found:

Compliance error at line 7, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_NON_FIXED_RECORD_ARRAY_INDEX:
  Using arrays of records with indices of higher than parameter variability is currently only supported when compiling FMUs

Compliance error at line 7, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The integer() function-like operator is currently only supported when compiling FMUs
")})));
end ArrayOfRecords_Warn;


model ExternalFunction_ComplErr
    record R
    end R;
    function f
        output R x;
      external "C";
    end f;
 
    R x = f();

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ExternalFunction_ComplErr",
            description="",
            errorMessage="
1 errors found:

Compliance error at line 4, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_EXTERNAL_FUNCTION_RECORD_RETURN_VALUE:
  Using records as return value from external functions is not supported

")})));
end ExternalFunction_ComplErr;

model UnsupportedBuiltins2_ComplErr
  parameter Boolean x;
  parameter Real y;
 equation
  sign(1);
  div(1,1);
  mod(1,1);
  rem(1,1);
  ceil(1.0);
  floor(1.0);
  integer(1.0);
  semiLinear(1,1,1);
  initial();
  sample(1,1);
  pre(x);
  edge(x);
  change(x);
  terminate("");
  der(y) = time;
  when y > time then
    reinit(y, 2);
  end when;
  delay(3,3);
  spatialDistribution(1,1,1,true);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="UnsupportedBuiltins2_ComplErr",
            description="Compliance error for builtins that are only supported for FMUs",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
18 errors found:

Compliance error at line 5, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The sign() function-like operator is currently only supported when compiling FMUs

Compliance error at line 6, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The div() function-like operator is currently only supported when compiling FMUs

Compliance error at line 7, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The mod() function-like operator is currently only supported when compiling FMUs

Compliance error at line 8, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The rem() function-like operator is currently only supported when compiling FMUs

Compliance error at line 9, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The ceil() function-like operator is currently only supported when compiling FMUs

Compliance error at line 10, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The floor() function-like operator is currently only supported when compiling FMUs

Compliance error at line 11, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The integer() function-like operator is currently only supported when compiling FMUs

Compliance error at line 12, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The semiLinear() function-like operator is currently only supported when compiling FMUs

Compliance error at line 13, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The initial() function-like operator is currently only supported when compiling FMUs

Compliance error at line 14, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The sample() function-like operator is currently only supported when compiling FMUs

Compliance error at line 15, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The pre() function-like operator is currently only supported when compiling FMUs

Compliance error at line 16, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The edge() function-like operator is currently only supported when compiling FMUs

Compliance error at line 17, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The change() function-like operator is currently only supported when compiling FMUs

Compliance error at line 18, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The terminate() function-like operator is currently only supported when compiling FMUs

Compliance error at line 20, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_WHEN_EQUATIONS:
  When equations are currently only supported when compiling FMUs

Compliance error at line 21, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The reinit() function-like operator is currently only supported when compiling FMUs

Compliance error at line 23, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The delay() function-like operator is currently only supported when compiling FMUs

Compliance error at line 24, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The spatialDistribution() function-like operator is currently only supported when compiling FMUs
")})));
end UnsupportedBuiltins2_ComplErr;

model ArrayCellMod_ComplErr
 model A
  Real b[2];
 end A;
 
 A a(b[1] = 1, b[1](start=2));
 A a2(b[:] = {1,2}, b[:](start={2,3}));

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ArrayCellMod_ComplErr",
            description="Compliance error for modifiers of specific array elements",
            errorMessage="
2 errors found:

Error at line 6, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo':
  Modifiers of specific array elements are not allowed

Error at line 6, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo':
  Modifiers of specific array elements are not allowed
")})));
end ArrayCellMod_ComplErr;


model DuplicateVariables_Warn
    model A
        Real x(start=1) = 1;
    end A;
    
    model B
        extends A;
        Real x = 1;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="DuplicateVariables_Warn",
            description="Check that duplicate components from extends generates warning",
            errorMessage="
1 errors found:

Warning at line 8, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNABLE_TO_INFER_EQUALITY_FOR_DUPLICATES:
  The component x is declared multiple times and can not be verified to be identical to other declaration(s) with the same name.
")})));
end DuplicateVariables_Warn;


model HybridNonFMU1
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
when x > 2 then 
z = false; 
end when; 
when sample(0,1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="HybridNonFMU1",
            description="Test that compliance warnings for hybrid elements are issued when not compiling FMU",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
11 errors found:

Compliance error at line 5, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_BOOLEAN_VARIABLES:
  Boolean variables of discrete variability is currently only supported when compiling FMUs

Compliance error at line 6, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_BOOLEAN_VARIABLES:
  Boolean variables of discrete variability is currently only supported when compiling FMUs

Compliance error at line 7, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_BOOLEAN_VARIABLES:
  Boolean variables of discrete variability is currently only supported when compiling FMUs

Compliance error at line 10, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_WHEN_EQUATIONS:
  When equations are currently only supported when compiling FMUs

Compliance error at line 10, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The pre() function-like operator is currently only supported when compiling FMUs

Compliance error at line 13, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_WHEN_EQUATIONS:
  When equations are currently only supported when compiling FMUs

Compliance error at line 16, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_WHEN_EQUATIONS:
  When equations are currently only supported when compiling FMUs

Compliance error at line 19, column 1, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_WHEN_EQUATIONS:
  When equations are currently only supported when compiling FMUs

Compliance error at line 19, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The sample() function-like operator is currently only supported when compiling FMUs

Compliance error at line 20, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The pre() function-like operator is currently only supported when compiling FMUs

Compliance error at line 21, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The pre() function-like operator is currently only supported when compiling FMUs
")})));
end HybridNonFMU1;


model HybridFMU1
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true);
parameter Real p1 = 1.2; 
parameter Real p2 = floor(p1);
equation
der(xx) = -x; 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when x > 2 then 
z = false; 
end when; 
when sample(0,1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="HybridFMU1",
            description="Test that compliance warnings for hybrid elements aren't issued when compiling FMU",
            generate_ode=true,
            checkAll=true,
            flatModel="
fclass ComplianceTests.HybridFMU1
 Real xx(start = 2);
 discrete Real x;
 discrete Real y;
 discrete Boolean w(start = true);
 discrete Boolean v(start = true);
 discrete Boolean z(start = true);
 parameter Real p1 = 1.2 /* 1.2 */;
 parameter Real p2;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
 discrete Boolean temp_2;
 discrete Boolean temp_3;
 discrete Boolean temp_4;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time);
 xx = 2;
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(w) = true;
 pre(v) = true;
 pre(z) = true;
 pre(temp_2) = false;
 pre(temp_3) = false;
 pre(temp_4) = false;
parameter equation
 p2 = floor(p1);
equation
 der(xx) = - x;
 temp_2 = y > 2 and pre(z);
 w = if temp_2 and not pre(temp_2) then false else pre(w);
 temp_3 = y > 2 and z;
 v = if temp_3 and not pre(temp_3) then false else pre(v);
 temp_4 = x > 2;
 z = if temp_4 and not pre(temp_4) then false else pre(z);
 x = if temp_1 and not pre(temp_1) then pre(x) + 1.1 else pre(x);
 y = if temp_1 and not pre(temp_1) then pre(y) + 1.1 else pre(y);
 temp_1 = not initial() and time >= pre(_sampleItr_1);
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\");
end ComplianceTests.HybridFMU1;
")})));
end HybridFMU1;


model HybridNonFMU2 
 discrete Real x, y, z;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when initial() then
   y = pre(y) + 1;
 end when;
 z = floor(dummy);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="HybridNonFMU2",
            description="",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
7 errors found:

Compliance error at line 6, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_WHEN_EQUATIONS:
  When equations are currently only supported when compiling FMUs

Compliance error at line 6, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The sample() function-like operator is currently only supported when compiling FMUs

Compliance error at line 7, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The pre() function-like operator is currently only supported when compiling FMUs

Compliance error at line 9, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_WHEN_EQUATIONS:
  When equations are currently only supported when compiling FMUs

Compliance error at line 9, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The initial() function-like operator is currently only supported when compiling FMUs

Compliance error at line 10, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The pre() function-like operator is currently only supported when compiling FMUs

Compliance error at line 12, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTION_LIKE_OPERATOR:
  The floor() function-like operator is currently only supported when compiling FMUs
")})));
end HybridNonFMU2; 


model HybridFMU2 
 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when initial() then
   y = pre(y) + 1;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="HybridFMU2",
            description="Test that compliance warnings for hybrid elements aren't issued when compiling FMU",
            generate_ode=true,
            checkAll=true,
            flatModel="
fclass ComplianceTests.HybridFMU2
 discrete Real x;
 discrete Real y;
 Real dummy;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time / 0.3333333333333333);
 dummy = 0.0;
 pre(x) = 0.0;
 pre(y) = 0.0;
equation
 der(dummy) = 0;
 x = if temp_1 and not pre(temp_1) then pre(x) + 1 else pre(x);
 y = if initial() then pre(y) + 1 else pre(y);
 temp_1 = not initial() and time >= pre(_sampleItr_1) * 0.3333333333333333;
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < (pre(_sampleItr_1) + 1) * (1 / 3), \"Too long time steps relative to sample interval.\");
end ComplianceTests.HybridFMU2;
")})));
end HybridFMU2;

model StringOperator1
    Integer len = if time < 0 then 4 else 3;
    Integer digits = if time < 0 then 5 else 2;
equation
    assert(time>2.0, String(time, significantDigits=digits, minimumLength=len, leftJustified=time<1));
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="StringOperator1",
            description="Test compliance warnings for non fixed string operator arguments (significantDigits, minimumLength, leftJustified)",
            errorMessage="
3 errors found:

Compliance error at line 5, column 53, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_NON_FIXED_STRING_ARGUMENT:
  significantDigits with higher than parameter variability is not supported

Compliance error at line 5, column 75, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_NON_FIXED_STRING_ARGUMENT:
  minimumLength with higher than parameter variability is not supported

Compliance error at line 5, column 94, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_NON_FIXED_STRING_ARGUMENT:
  leftJustified with higher than parameter variability is not supported
")})));
end StringOperator1;



package UnknownArraySizes
/* Tests compliance errors for array exps 
   of unknown size in functions. #2155 #698 */

model Error2
  function f
    input Real x[:,:];
	input Integer n;
    Real a;
	Real b[n,n];
	Real c[n];
    output Real y[size(x,2),size(x,1)];
  algorithm
	y := symmetric(x);
	b := identity(n+1-1);
	b := zeros(n,n);
	b := ones(n,n);
	b := fill(n,n,n);
	a := min(c);
	a := max(c);
	b := b^2;
	a := scalar(x);
	c := vector(c);
	b := matrix(c);
  end f;
  
  Real x[4,2] = f({{1,2,3,4},{5,6,7,8}}, 4);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="UnknownArraySizes_Error2",
            description="Test that compliance errors are given.",
            errorMessage="
2 errors found:

Compliance error at line 10, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_IN_FUNCTION_UNKNOWN_SIZE_OPERATOR:
  Unknown sizes in operator symmetric() is not supported in functions

Compliance error at line 17, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_IN_FUNCTION_UNKNOWN_SIZE_OPERATOR:
  Unknown sizes in operator ^ is not supported in functions
")})));
end Error2;

model ArrayIterTest
    type E = enumeration(a, b, c);
    Real x[E];
    Real y[E] = { x[i] for i };

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="UnknownArraySizes_ArrayIterTest",
            description="Array constructor with iterators: without in for non-integer indexed array",
            errorMessage="
2 errors found:

Error at line 4, column 21, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo':
  Expected array index of type 'ComplianceTests.UnknownArraySizes.ArrayIterTest.E' found 'Integer'

Compliance error at line 4, column 21, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', IMPLICIT_FOR_RANGE_NON_INTEGER:
  Non-integer for iteration range not supported
")})));
end ArrayIterTest;

end UnknownArraySizes;

model UnknownArrayIndex
	Real[2] x1,x2;
equation
	for i in 1:integer(time) loop
		x1[i] = i;
	end for;
algorithm
	for i in 1:integer(time) loop
		x2[i] := i;
	end for;
	
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="UnknownArrayIndex",
            description="Test errors for unknown array for indices in algorithms and equations.",
            errorMessage="
4 errors found:

Compliance error at line 4, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_NON_FIXED_FOR_INDEX:
  For index with higher than parameter variability is not supported in equations and algorithms

Compliance error at line 4, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', NON_PARAMETER_SIZE_IN_EXPRESSION:
  Non-parameter expression sizes not supported, 'max(integer(time), 0)', dimension 0 in '1:integer(time)'

Compliance error at line 8, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_NON_FIXED_FOR_INDEX:
  For index with higher than parameter variability is not supported in equations and algorithms

Compliance error at line 8, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', NON_PARAMETER_SIZE_IN_EXPRESSION:
  Non-parameter expression sizes not supported, 'max(integer(time), 0)', dimension 0 in '1:integer(time)'

")})));
end UnknownArrayIndex;

model WhileStmt
	Real x;
algorithm
	while x > time loop
		x := x - 1;
	end while;
	
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="WhileStmt",
            description="Test while statement in algorithm",
            algorithms_as_functions=false,
            errorMessage="
1 errors found:

Compliance error at line 4, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_EVENT_GENERATING_EXPRESSION_IN_WHILE_STATEMENT:
  Event generating expressions are not supported in while statements
")})));
end WhileStmt;

model FunctionalArgument
  function func
    input partialFunctional f;
    input Real x;
    output Real y;
  algorithm
    y := f(x);
  end func;

  partial function partialFunctional
    input Real u;
    output Real y;
  end partialFunctional;
  
  function functional
    extends partialFunctional;
    input Real A;
  algorithm
    y := A*u;
  end functional;
  
  Real y = func(function functional(A=3.14), time);
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="FunctionalArgument",
            description="Test compliance error for functional argument",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
1 errors found:

Compliance error at line 3, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', ONLY_FMU_FUNCTIONAL_INPUT:
  Using functional input arguments is currently only supported when compiling FMUs
")})));
end FunctionalArgument;

model ExtObjInFunction1
  model EO
    extends ExternalObject;
    function constructor
        output EO o;
        external;
    end constructor;
    
    function destructor
        input EO o;
        external;
    end destructor;
  end EO;
  
  function wrap
    output EO eo = EO();
    algorithm
  end wrap;
    
  EO eo = wrap();
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ExtObjInFunction1",
            description="Test compliance error for external object constructor in function",
            errorMessage="
1 errors found:

Compliance error at line 16, column 20, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', UNSUPPORTED_EXTERNAL_OBJECT_CONSTRUCTORS:
  Constructors for external objects is not supported in functions
")})));
end ExtObjInFunction1;

model DeprecatedDecoupleTest1
    Real x[2] = time * (1:2);
    Real y[:] = Subtask.decouple(x);

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="DeprecatedDecoupleTest1",
            description="Deprecation warning for Subtask.decouple()",
            errorMessage="
1 warnings found:

Warning at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', DEPRECATED_DECOUPLE:
  The Subtask.decouple() function-like operator is removed as of Modelica version 3.2r2
")})));
end DeprecatedDecoupleTest1;

model NonParameterSize1
    Real x = sum(1:integer(time));
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="NonParameterSize1",
            description="",
            errorMessage="
1 errors found:

Compliance error at line 2, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/ComplianceTests.mo', NON_PARAMETER_SIZE_IN_EXPRESSION:
  Non-parameter expression sizes not supported, 'max(integer(time), 0)', dimension 0 in '1:integer(time)'

")})));
end NonParameterSize1;

end ComplianceTests;
