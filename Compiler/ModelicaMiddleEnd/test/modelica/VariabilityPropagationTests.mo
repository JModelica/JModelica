/*
	Copyright (C) 2013-2018 Modelon AB

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

package VariabilityPropagationTests

model VariabilityInference
	Real x1;
	Boolean x2;
	
	parameter Real p1 = 4;
	Real r1;
	Real r2;
equation
	x1 = 1;
	x2 = true;
	r1 = p1;
	r2 = p1 + x1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariabilityInference",
            description="Tests if variability 
			inferred from equations is propagated to declarations",
            flatModel="
fclass VariabilityPropagationTests.VariabilityInference
 constant Real x1 = 1;
 constant Boolean x2 = true;
 parameter Real p1 = 4 /* 4 */;
 parameter Real r1;
 parameter Real r2;
parameter equation
 r1 = p1;
 r2 = p1 + 1.0;
end VariabilityPropagationTests.VariabilityInference;
")})));
end VariabilityInference;

model SimplifyLitExps
	Real x1;
	Boolean x2;
equation
	x1 = 1 + 2 * 3 - 4 / 8 + 6 * 7 - 8 * 9;
	x2 = true and false or true or false and true;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyLitExps",
            description="Tests if literal expressions are folded",
            flatModel="
fclass VariabilityPropagationTests.SimplifyLitExps
 constant Real x1 = -23.5;
 constant Boolean x2 = true;
end VariabilityPropagationTests.SimplifyLitExps;
")})));
end SimplifyLitExps;

model ConstantFolding1
	Real x1,x2,x3,x4;
equation
	x1 = 1;
	x2 = x3 + x1;
	x3 = x1;
	x4 = x2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantFolding1",
            description="Tests if constant values inferred from equations are moved to equations and folded.",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationTests.ConstantFolding1
 constant Real x1 = 1;
 constant Real x2 = 2.0;
 constant Real x3 = 1.0;
 constant Real x4 = 2.0;
end VariabilityPropagationTests.ConstantFolding1;
")})));
end ConstantFolding1;

model ConstantFolding2
function f
	input Real ii;
	input Real i[:,:];
	output Real o;
algorithm
	o := i[1,1];
end f;	

	input Real i;
	Real x;
	Real y;

equation
	x = f(i,fill(1,2,3));
	when (x >1) then
		y = f(i,fill(1,0,2));
	end when;
	

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantFolding2",
            description="Tests folding of some more advanced expressions and some which shouldn't be folded.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.ConstantFolding2
 input Real i;
 Real x;
 discrete Real y;
 discrete Boolean temp_1;
initial equation 
 pre(y) = 0.0;
 pre(temp_1) = false;
equation
 x = VariabilityPropagationTests.ConstantFolding2.f(i, {{1, 1, 1}, {1, 1, 1}});
 temp_1 = x > 1;
 y = if temp_1 and not pre(temp_1) then VariabilityPropagationTests.ConstantFolding2.f(i, fill(0, 0, 2)) else pre(y);

public
 function VariabilityPropagationTests.ConstantFolding2.f
  input Real ii;
  input Real[:,:] i;
  output Real o;
 algorithm
  o := i[1,1];
  return;
 end VariabilityPropagationTests.ConstantFolding2.f;

end VariabilityPropagationTests.ConstantFolding2;
")})));
end ConstantFolding2;

model ConstantFolding3
	function StringCompare
		input String expected;
		input String actual;
	algorithm
		assert(actual == expected, "Compare failed, expected: " + expected + ", actual: " + actual);
	end StringCompare;
	type E = enumeration(small, medium, large, xlarge);
	Real realVar = 3.14;
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

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantFolding3",
            description="Tests folding of string operator.",
            flatModel="
fclass VariabilityPropagationTests.ConstantFolding3
 constant Real realVar = 3.14;
 constant Integer intVar = 42;
 constant Boolean boolVar = false;
 constant VariabilityPropagationTests.ConstantFolding3.E enumVar = VariabilityPropagationTests.ConstantFolding3.E.medium;
equation
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"42\", \"42\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"42          \", \"42          \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"          42\", \"          42\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"3.14000\", \"3.14000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"3.14000     \", \"3.14000     \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"     3.14000\", \"     3.14000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"3.1400000\", \"3.1400000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"3.1400000   \", \"3.1400000   \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"   3.1400000\", \"   3.1400000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"-3.14000\", \"-3.14000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"-3.14000    \", \"-3.14000    \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"    -3.14000\", \"    -3.14000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"-3.1400000\", \"-3.1400000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"-3.1400000  \", \"-3.1400000  \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"  -3.1400000\", \"  -3.1400000\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"false\", \"false\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"false       \", \"false       \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"       false\", \"       false\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"true\", \"true\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"true        \", \"true        \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"        true\", \"        true\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"medium\", \"medium\");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"medium      \", \"medium      \");
 VariabilityPropagationTests.ConstantFolding3.StringCompare(\"      medium\", \"      medium\");

public
 function VariabilityPropagationTests.ConstantFolding3.StringCompare
  input String expected;
  input String actual;
 algorithm
  assert(actual == expected, \"Compare failed, expected: \" + expected + \", actual: \" + actual);
  return;
 end VariabilityPropagationTests.ConstantFolding3.StringCompare;

 type VariabilityPropagationTests.ConstantFolding3.E = enumeration(small, medium, large, xlarge);

end VariabilityPropagationTests.ConstantFolding3;
")})));
end ConstantFolding3;

model ConstantFolding4
	Real x;
	parameter Real y;
equation
	when y > 1 then
		x = 1;
	end when;
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantFolding4",
            description="Rewrite parameter pre expressions",
            flatModel="
fclass VariabilityPropagationTests.ConstantFolding4
 discrete Real x;
 parameter Real y;
 parameter Boolean temp_1;
initial equation 
 pre(x) = 0.0;
parameter equation
 temp_1 = y > 1;
equation
 x = if temp_1 and not temp_1 then 1 else pre(x);
end VariabilityPropagationTests.ConstantFolding4;
")})));
end ConstantFolding4;

model NoExp
	Real x(start=.5);
equation
	x-0.1 = cos(x);
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NoExp",
            description="Tests that an equation with a single 
			variable but no solution is not changed.",
            flatModel="
fclass VariabilityPropagationTests.NoExp
 Real x(start = 0.5);
equation
 x - 0.1 = cos(x);
end VariabilityPropagationTests.NoExp;
")})));
end NoExp;


model Output
	output Real x;
equation
	x = 5;
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Output",
            description="This tests that we do not propagate variability to output variables",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.Output
 output Real x;
equation
 x = 5;
end VariabilityPropagationTests.Output;
")})));
end Output;


model Output2
	output Real a;
	Real b;
	
	function f
		output Real o1;
		output Real o2;
	algorithm
		o1 := 1;
		o2 := 2;
	end f;

equation
	(a,b) = f();
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Output2",
            description="This tests that we do not propagate variability to output variables",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.Output2
 output Real a;
 constant Real b = 2;
equation
 (a, ) = VariabilityPropagationTests.Output2.f();

public
 function VariabilityPropagationTests.Output2.f
  output Real o1;
  output Real o2;
 algorithm
  o1 := 1;
  o2 := 2;
  return;
 end VariabilityPropagationTests.Output2.f;

end VariabilityPropagationTests.Output2;
")})));
end Output2;

model Der1
	Real x1,x2;
	Real x3,x4;
	Real x5,x6;
	parameter Real p1 = 4;
equation
    x2 = der(x1);
    x1 = 3;
    x3 = der(x4);
    der(x4) = 3;
    x5 = der(x6);
    x6 = p1 + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Der1",
            description="Tests some propagation to and through derivative expressions.",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationTests.Der1
 constant Real x1 = 3;
 constant Real x2 = 0.0;
 Real x3;
 Real x4;
 constant Real x5 = 0.0;
 parameter Real x6;
 parameter Real p1 = 4 /* 4 */;
initial equation 
 x4 = 0.0;
parameter equation
 x6 = p1 + 1;
equation
 x3 = der(x4);
 der(x4) = 3;
end VariabilityPropagationTests.Der1;
")})));
end Der1;

model Der2
	Real x,y;
	Real z;
equation
	z = time;
	y = x * der(z) + 1;
	x = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Der2",
            description="Test removal of der var",
            flatModel="
fclass VariabilityPropagationTests.Der2
 constant Real x = 0;
 constant Real y = 1.0;
 Real z;
equation
 z = time;
end VariabilityPropagationTests.Der2;
")})));
end Der2;



model WhenEq1
	Real x1,x2;
equation
	when time > 3 then
		x1 = x2 + 1;
	end when;
	x2 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEq1",
            description="Tests that folding occurs, but not propagation, in when equations.",
            flatModel="
fclass VariabilityPropagationTests.WhenEq1
 discrete Real x1;
 constant Real x2 = 3;
 discrete Boolean temp_1;
initial equation 
 pre(x1) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = time > 3;
 x1 = if temp_1 and not pre(temp_1) then 4.0 else pre(x1);
end VariabilityPropagationTests.WhenEq1;
")})));
end WhenEq1;


model IfEq1
	constant Real p1 = 4;
	Real x1,x2;
equation
	if 3 > p1 then
		x1 = x2 + 1;
	elseif 3 < p1 then
		x1 = x2;
	else
		x1 = x2 - 1;		
	end if;
	x2 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEq1",
            description="Tests if-expressions",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationTests.IfEq1
 constant Real p1 = 4;
 constant Real x1 = 3.0;
 constant Real x2 = 3;
end VariabilityPropagationTests.IfEq1;
")})));
end IfEq1;


model IfEq2
	constant Real c1 = 4;
	parameter Real p1 = 1;
	Real x1,x2,x3,x4;
equation
	x3 = 3;
	if (x3 > c1) then
		x1 = 1;
		x2 = p1 + 1;
	elseif (x4 < c1) then
		x1 = 2;
		x2 = p1 + 2;
	else
		x1 = 3;
		x2 = 4;
	end if;
	x4 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEq2",
            description="Tests if-expressions",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationTests.IfEq2
 constant Real c1 = 4;
 parameter Real p1 = 1 /* 1 */;
 constant Real x1 = 2;
 parameter Real x2;
 constant Real x3 = 3;
 constant Real x4 = 3;
parameter equation
 x2 = p1 + 2;
end VariabilityPropagationTests.IfEq2;
")})));
end IfEq2;


model FunctionCall1
	Real c_out;
    function f
        output Real c;
    algorithm
    	c := 1;
    end f;
equation
    c_out = f() * 5.0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall1",
            description="Tests a constant function call with no parameters.",
            flatModel="
fclass VariabilityPropagationTests.FunctionCall1
 constant Real c_out = 5.0;
end VariabilityPropagationTests.FunctionCall1;
")})));
end FunctionCall1;


model FunctionCallEquation1
	Real x1,x2;
	Real x3,x4;
	Real x5;
	Real x6,x7;
	parameter Real p = 3;
	
    function f
    	input Real i1;
        output Real c1;
        output Real c2;
    algorithm
    	c1 := 1*i1;
    	c2 := 2*i1;
    end f;
    function e
    	input Real i1;
    	output Real o1,o2;
    	external "C";
    end e;
equation
    (x1,x2) = f(x5);
    (x3,x4) = f(p);
    x5 = 5;
    (x6,x7) = e(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation1",
            description="Tests that variability is propagated through function call equations with multiple destinations.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation1
 constant Real x1 = 5.0;
 constant Real x2 = 10.0;
 parameter Real x3;
 parameter Real x4;
 constant Real x5 = 5;
 parameter Real x6;
 parameter Real x7;
 parameter Real p = 3 /* 3 */;
parameter equation
 (x3, x4) = VariabilityPropagationTests.FunctionCallEquation1.f(p);
 (x6, x7) = VariabilityPropagationTests.FunctionCallEquation1.e(1);

public
 function VariabilityPropagationTests.FunctionCallEquation1.f
  input Real i1;
  output Real c1;
  output Real c2;
 algorithm
  c1 := i1;
  c2 := 2 * i1;
  return;
 end VariabilityPropagationTests.FunctionCallEquation1.f;

 function VariabilityPropagationTests.FunctionCallEquation1.e
  input Real i1;
  output Real o1;
  output Real o2;
 algorithm
  external \"C\" e(i1, o1, o2);
  return;
 end VariabilityPropagationTests.FunctionCallEquation1.e;

end VariabilityPropagationTests.FunctionCallEquation1;
")})));
end FunctionCallEquation1;


model FunctionCallEquation2
	Real z1[2];
	Real z2[2];
	Real z3[2];
	parameter Real p = 3;
	
    function f
    	input Real i1;
        output Real c[2];
    algorithm
    	c[1] := 1*i1;
    	c[2] := 2*i1;
    end f;
    function e
    	input Real i1;
        output Real c[2];
    	external "C";
    end e;
equation
    (z1) = f(1);
    (z2) = f(p);
    (z3) = e(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation2",
            description="Tests that variability is propagated through function call equations with array destinations.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation2
 constant Real z1[1] = 1;
 constant Real z1[2] = 2.0;
 parameter Real z2[1];
 parameter Real z2[2];
 parameter Real z3[1];
 parameter Real z3[2];
 parameter Real p = 3 /* 3 */;
parameter equation
 ({z2[1], z2[2]}) = VariabilityPropagationTests.FunctionCallEquation2.f(p);
 ({z3[1], z3[2]}) = VariabilityPropagationTests.FunctionCallEquation2.e(1);

public
 function VariabilityPropagationTests.FunctionCallEquation2.f
  input Real i1;
  output Real[:] c;
 algorithm
  init c as Real[2];
  c[1] := i1;
  c[2] := 2 * i1;
  return;
 end VariabilityPropagationTests.FunctionCallEquation2.f;

 function VariabilityPropagationTests.FunctionCallEquation2.e
  input Real i1;
  output Real[:] c;
 algorithm
  init c as Real[2];
  external \"C\" e(i1, c, size(c, 1));
  return;
 end VariabilityPropagationTests.FunctionCallEquation2.e;

end VariabilityPropagationTests.FunctionCallEquation2;
")})));
end FunctionCallEquation2;


model FunctionCallEquation3
	A a;
	A b;
	parameter Real p = 3;
	
    function f
    	input Real i;
        output A o1;
        output Real o2;
    algorithm
    	o1 := A(i*1,i*2);
    	o2 := i*3;
    end f;
    
	record A
		Real a;
		Real b;
	end A;
equation
    (a, ) = f(3);
    (b, ) = f(p);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation3",
            description="Tests that variability is propagated through function call equations with record destinations.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation3
 constant Real a.a = 3;
 constant Real a.b = 6.0;
 parameter Real b.a;
 parameter Real b.b;
 parameter Real p = 3 /* 3 */;
parameter equation
 (VariabilityPropagationTests.FunctionCallEquation3.A(b.a, b.b), ) = VariabilityPropagationTests.FunctionCallEquation3.f(p);

public
 function VariabilityPropagationTests.FunctionCallEquation3.f
  input Real i;
  output VariabilityPropagationTests.FunctionCallEquation3.A o1;
  output Real o2;
 algorithm
  o1.a := i;
  o1.b := i * 2;
  o2 := i * 3;
  return;
 end VariabilityPropagationTests.FunctionCallEquation3.f;

 record VariabilityPropagationTests.FunctionCallEquation3.A
  Real a;
  Real b;
 end VariabilityPropagationTests.FunctionCallEquation3.A;

end VariabilityPropagationTests.FunctionCallEquation3;
")})));
end FunctionCallEquation3;


model FunctionCallEquation4
	Real a[2,2];
	constant Real b[2] = {1,2};
	Real x1[2];
equation
	x1 = Modelica.Math.Matrices.solve(a, b);
	a = {{1,2},{3,4}};
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation4",
            description="Tests that parameters in function call equations are folded. 
Also tests that when it is constant and can't evaluate, variability is propagated as parameter.",
            eliminate_alias_variables=false,
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation4
 constant Real a[1,1] = 1;
 constant Real a[1,2] = 2;
 constant Real a[2,1] = 3;
 constant Real a[2,2] = 4;
 constant Real b[1] = 1;
 constant Real b[2] = 2;
 parameter Real x1[1];
 parameter Real x1[2];
parameter equation
 ({x1[1], x1[2]}) = Modelica.Math.Matrices.solve({{1.0, 2.0}, {3.0, 4.0}}, {1.0, 2.0});

public
 function Modelica.Math.Matrices.solve
  input Real[:,:] A;
  input Real[:] b;
  output Real[:] x;
  Integer info;
 algorithm
  init x as Real[size(b, 1)];
  (x, info) := Modelica.Math.Matrices.LAPACK.dgesv_vec(A, b);
  assert(info == 0, \"Solving a linear system of equations with function
\\\"Matrices.solve\\\" is not possible, because the system has either
no or infinitely many solutions (A is singular).\");
  return;
 end Modelica.Math.Matrices.solve;

 function Modelica.Math.Matrices.LAPACK.dgesv_vec
  input Real[:,:] A;
  input Real[:] b;
  output Real[:] x;
  output Integer info;
  Real[:,:] Awork;
  Integer lda;
  Integer ldb;
  Integer[:] ipiv;
 algorithm
  init x as Real[size(A, 1)];
  for i1 in 1:size(A, 1) loop
   x[i1] := b[i1];
  end for;
  init Awork as Real[size(A, 1), size(A, 1)];
  for i1 in 1:size(A, 1) loop
   for i2 in 1:size(A, 1) loop
    Awork[i1,i2] := A[i1,i2];
   end for;
  end for;
  lda := max(1, size(A, 1));
  ldb := max(1, size(b, 1));
  init ipiv as Integer[size(A, 1)];
  external \"FORTRAN 77\" dgesv(size(A, 1), 1, Awork, lda, ipiv, x, ldb, info);
  return;
 end Modelica.Math.Matrices.LAPACK.dgesv_vec;

end VariabilityPropagationTests.FunctionCallEquation4;
")})));
end FunctionCallEquation4;


model FunctionCallEquation5
	constant Real a[2,2] = {{1,2},{3,4}};
	
	function f
		input Real a[:,:];
		input Real b[size(a,2),:];
		output Real o[size(a,1),size(b,2)];
	algorithm
		o := a * b;
	end f;

	Real x1[2,2] = f(a,a);
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation5",
            description="Tests evaluation of matrix multiplication in function.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation5
 constant Real a[1,1] = 1;
 constant Real a[1,2] = 2;
 constant Real a[2,1] = 3;
 constant Real a[2,2] = 4;
 constant Real x1[1,1] = 7.0;
 constant Real x1[1,2] = 10.0;
 constant Real x1[2,1] = 15.0;
 constant Real x1[2,2] = 22.0;
end VariabilityPropagationTests.FunctionCallEquation5;
")})));
end FunctionCallEquation5;

model Algorithm1
    parameter Real p;
    Real y;
algorithm
    y := p;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm1",
            description="",
            variability_propagation_algorithms=true,
            flatModel="
fclass VariabilityPropagationTests.Algorithm1
 parameter Real p;
 parameter Real y;
parameter equation
 algorithm
  y := p;
;
end VariabilityPropagationTests.Algorithm1;
")})));
end Algorithm1;

model Algorithm1_b
    parameter Real p;
    Real y;
algorithm
    y := p;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm1_b",
            description="Test algorithm propagation off",
            variability_propagation_algorithms=false,
            flatModel="
fclass VariabilityPropagationTests.Algorithm1_b
 parameter Real p;
 Real y;
algorithm
 y := p;
end VariabilityPropagationTests.Algorithm1_b;
")})));
end Algorithm1_b;

model Algorithm2
    parameter Real p;
    Real y;
algorithm
    y := p + time;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm2",
            description="",
            variability_propagation_algorithms=true,
            flatModel="
fclass VariabilityPropagationTests.Algorithm2
 parameter Real p;
 Real y;
algorithm
 y := p + time;
end VariabilityPropagationTests.Algorithm2;
")})));
end Algorithm2;

model Algorithm3
    parameter Real p;
    Real x;
    Real y;
algorithm
    y := x;
equation
    x = p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm3",
            description="",
            variability_propagation_algorithms=true,
            flatModel="
fclass VariabilityPropagationTests.Algorithm3
 parameter Real p;
 parameter Real x;
 parameter Real y;
parameter equation
 x = p;
 algorithm
  y := x;
;
end VariabilityPropagationTests.Algorithm3;
")})));
end Algorithm3;

model Algorithm4
    parameter Real p;
    Real x;
    Real y;
algorithm
    x := p;
    y := x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm4",
            description="",
            variability_propagation_algorithms=true,
            flatModel="
fclass VariabilityPropagationTests.Algorithm4
 parameter Real p;
 parameter Real x;
 parameter Real y;
parameter equation
 algorithm
  x := p;
  y := x;
;
end VariabilityPropagationTests.Algorithm4;
")})));
end Algorithm4;

model Algorithm5
    parameter Real p;
    Real x;
    Real y;
algorithm
    x := p;
    y := x;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Algorithm5",
            description="Parameter algorithm code generation",
            variability_propagation_algorithms=true,
            template="
$C_model_init_eval_dependent_parameters$
",
            generatedCode="
int model_init_eval_dependent_parameters(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1 = _p_0;
    _y_2 = _x_1;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end Algorithm5;

model ConstantRecord1
	record A
		Real a[:];
		Real b;
	end A;

	A c = A({1, 2, 3}, 4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantRecord1",
            description="Tests propagation of a constant record.",
            flatModel="
fclass VariabilityPropagationTests.ConstantRecord1
 constant Real c.a[1] = 1;
 constant Real c.a[2] = 2;
 constant Real c.a[3] = 3;
 constant Real c.b = 4;
end VariabilityPropagationTests.ConstantRecord1;
")})));
end ConstantRecord1;


model ConstantStartFunc1
	function f
		output Real o[2] = {1, 2};
	algorithm
	end f;
	
	Real x[2](start = f()) = {3,4};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantStartFunc1",
            description="Tests that a constant right hand in a function call equation is not folded. It should only be propagated.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.ConstantStartFunc1
 constant Real x[1](start = temp_1[1]) = 3;
 constant Real x[2](start = temp_1[2]) = 4;
 parameter Real temp_1[1];
 parameter Real temp_1[2];
parameter equation
 ({temp_1[1], temp_1[2]}) = VariabilityPropagationTests.ConstantStartFunc1.f();

public
 function VariabilityPropagationTests.ConstantStartFunc1.f
  output Real[:] o;
  Integer[:] temp_1;
 algorithm
  init o as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   o[i1] := temp_1[i1];
  end for;
  return;
 end VariabilityPropagationTests.ConstantStartFunc1.f;

end VariabilityPropagationTests.ConstantStartFunc1;
")})));
end ConstantStartFunc1;

model InitialEquation1
    parameter Boolean c = false;
    Boolean b = c;
initial equation
    pre(b) = false;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquation1",
            description="Tests that corresponding initial equations are removed",
            flatModel="
fclass VariabilityPropagationTests.InitialEquation1
 parameter Boolean c = false /* false */;
 parameter Boolean b;
parameter equation
 b = c;
end VariabilityPropagationTests.InitialEquation1;
")})));
end InitialEquation1;

model InitialEquation2
    Real x(fixed=false,start=3.14);
	Real y;
	parameter Real p1 = 1;
equation
	x = y + 1;
	y = p1 + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquation2",
            description="Check fixed=true",
            flatModel="
fclass VariabilityPropagationTests.InitialEquation2
 parameter Real y;
 parameter Real x(fixed = true,start = 3.14);
 parameter Real p1 = 1 /* 1 */;
parameter equation
 y = p1 + 1;
 x = y + 1;
end VariabilityPropagationTests.InitialEquation2;
")})));
end InitialEquation2;

model InitialEquation3
    Real x;
    parameter Real p1 = 3;
    Real p2 = p1;
initial equation
    x = p2;
equation
    when time > 1 then
        x = time;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquation3",
            description="Test no propagation of initial equations",
            flatModel="
fclass VariabilityPropagationTests.InitialEquation3
 discrete Real x;
 parameter Real p1 = 3 /* 3 */;
 parameter Real p2;
 discrete Boolean temp_1;
initial equation 
 x = p2;
 pre(temp_1) = false;
parameter equation
 p2 = p1;
equation
 temp_1 = time > 1;
 x = if temp_1 and not pre(temp_1) then time else pre(x);
end VariabilityPropagationTests.InitialEquation3;
")})));
end InitialEquation3;

model AliasVariabilities1
	Real a,b,c,d;
	parameter Real p1,p2;
	constant Real c1 = 1;
	constant Real c2 = 2;
equation
	a = b;
	b = p1 + p2;
	c = d;
	d = c1 + c2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasVariabilities1",
			description="Check that aliases are handled correctly",
            eliminate_alias_constants=false,
			flatModel="
fclass VariabilityPropagationTests.AliasVariabilities1
 parameter Real a;
 constant Real c = 3.0;
 parameter Real p1;
 parameter Real p2;
 constant Real c1 = 1;
 constant Real c2 = 2;
 parameter Real b;
 constant Real d = 3.0;
parameter equation
 a = p1 + p2;
 b = a;
end VariabilityPropagationTests.AliasVariabilities1;
			
"),
		XMLCodeGenTestCase(
			name="AliasVariabilities1XML",
			description="Check that aliases are handled correctly",
			generate_fmi_me_xml=false,
			eliminate_alias_constants=false,
			template="$XML_variables$",
			generatedCode="
		<ScalarVariable name=\"a\" valueReference=\"6\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"b\" valueReference=\"7\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"c\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"c1\" valueReference=\"1\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"c2\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"d\" valueReference=\"3\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"p1\" valueReference=\"4\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"p2\" valueReference=\"5\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
")})));
end AliasVariabilities1;

model StructParam1
    record R
        Real a,b;
    end R;
    function f
        output R r;
      algorithm
        r.a := 1;
    end f;
    function f2
        input R r;
        output Real a = r.a;
      algorithm
    end f2;
    parameter R r = f() annotation(Evaluate=true);
    Real a;
  equation
    a = f2(r);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StructParam1",
            description="Test propagation of structural parameters",
            flatModel="
fclass VariabilityPropagationTests.StructParam1
 eval parameter Real r.b = 0.0 /* 0.0 */;
 constant Real a = 1;
end VariabilityPropagationTests.StructParam1;
")})));
end StructParam1;

model ZeroFactor1
    Real c = 0;
    Real x1 = c * time;
    Real x2 = time * c;
    Real x3 = c / time;
    Real x4 = time / c;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ZeroFactor1",
            description="Test elimination of factors that can be reduced to zero.",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationTests.ZeroFactor1
 constant Real c = 0;
 constant Real x1 = 0.0;
 constant Real x2 = 0.0;
 constant Real x3 = 0.0;
 Real x4;
equation
 x4 = time / 0.0;
end VariabilityPropagationTests.ZeroFactor1;
")})));
end ZeroFactor1;

model ZeroFactor2
    Real c = 0;
    Real z = time;
    Real x1 = c * z + z;
    Real x2 = z * c + z;
    Real x3 = c / z + z;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ZeroFactor2",
            description="Test elimination of factors that can be reduced to zero.",
            flatModel="
fclass VariabilityPropagationTests.ZeroFactor2
 constant Real c = 0;
 Real x1;
equation
 x1 = time;
end VariabilityPropagationTests.ZeroFactor2;
")})));
end ZeroFactor2;

model ZeroFactor3
    Real c = 0;
    Real z1 = time;
    Real z2 = time;
    Real z3 = time;
    Real x1 = z1 * (z2 * (z3 * c));
    Real x2 = ((c / z1) / z2) / z3;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ZeroFactor3",
            description="Test elimination of factors that can be reduced to zero.",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass VariabilityPropagationTests.ZeroFactor3
 constant Real c = 0;
 Real z1;
 Real z2;
 Real z3;
 constant Real x1 = 0.0;
 constant Real x2 = 0.0;
equation
 z1 = time;
 z2 = time;
 z3 = time;
end VariabilityPropagationTests.ZeroFactor3;
")})));
end ZeroFactor3;

model EvalFail1
    function f
        output Real y = 1;
    algorithm
        assert(false,"nope");
    end f;
    
    Real y = f();
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EvalFail1",
            description="Test parameter from constant on fail to evaluate",
            flatModel="
fclass VariabilityPropagationTests.EvalFail1
 parameter Real y;
parameter equation
 y = VariabilityPropagationTests.EvalFail1.f();

public
 function VariabilityPropagationTests.EvalFail1.f
  output Real y;
 algorithm
  y := 1;
  assert(false, \"nope\");
  return;
 end VariabilityPropagationTests.EvalFail1.f;

end VariabilityPropagationTests.EvalFail1;
")})));
end EvalFail1;

model EvalFail2
    function f
        output Real[1] y = {1};
    algorithm
        assert(false,"nope");
    end f;
    
    Real[:] y = f();
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EvalFail2",
            description="Test parameter from constant on fail to evaluate",
            flatModel="
fclass VariabilityPropagationTests.EvalFail2
 parameter Real y[1];
parameter equation
 ({y[1]}) = VariabilityPropagationTests.EvalFail2.f();

public
 function VariabilityPropagationTests.EvalFail2.f
  output Real[:] y;
  Integer[:] temp_1;
 algorithm
  init y as Real[1];
  init temp_1 as Integer[1];
  temp_1[1] := 1;
  for i1 in 1:1 loop
   y[i1] := temp_1[i1];
  end for;
  assert(false, \"nope\");
  return;
 end VariabilityPropagationTests.EvalFail2.f;

end VariabilityPropagationTests.EvalFail2;
")})));
end EvalFail2;

model AlgebraicLoopParameter1
    parameter Real p = 1;
    Real zero = 0;
    Real x = p*y;
    Real y = zero * x + p;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgebraicLoopParameter1",
            description="Test evaluation of algebraic loop in propagated parameters",
            flatModel="
fclass VariabilityPropagationTests.AlgebraicLoopParameter1
 parameter Real p = 1 /* 1 */;
 constant Real zero = 0;
 parameter Real y;
 parameter Real x;
parameter equation
 y = p;
 x = p * y;
end VariabilityPropagationTests.AlgebraicLoopParameter1;
")})));
end AlgebraicLoopParameter1;

model AlgorithmFolding1
    function f
        input Real x;
        output Real y1 = x;
        output Real y2 = x;
        algorithm
    end f;
    Real y;
    Real x = 1;
    Real z;
    parameter Real p;
    Real a = p;
algorithm
    y := x;
    (y, ) := f(x);
    x := z + pre(p);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFolding1",
            description="Folding in algorithm",
            flatModel="
fclass VariabilityPropagationTests.AlgorithmFolding1
 Real y;
 constant Real x = 1;
 Real z;
 parameter Real p;
 parameter Real a;
parameter equation
 a = p;
algorithm
 y := 1.0;
 (y, ) := VariabilityPropagationTests.AlgorithmFolding1.f(1.0);
 x := z + p;

public
 function VariabilityPropagationTests.AlgorithmFolding1.f
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x;
  y2 := x;
  return;
 end VariabilityPropagationTests.AlgorithmFolding1.f;

end VariabilityPropagationTests.AlgorithmFolding1;
")})));
end AlgorithmFolding1;


model KnownParameter1
    function f
        input Real x;
        output Real[1,1] y;
    algorithm
        y[1,1] := x + 1;
    end f;
    
    model C
        Real x = y;
        Real y(start = 1) = a[1];
        parameter Real a[1] = {1};
    end C;
    
    C c[1](a = f(b));
    final parameter Real b = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="KnownParameter1",
            description="Test variability propagation for known parameter expressions",
            flatModel="
fclass VariabilityPropagationTests.KnownParameter1
 final parameter Real c[1].a[1](start = 1) = 2.0 /* 2.0 */;
 final parameter Real b = 1 /* 1 */;
end VariabilityPropagationTests.KnownParameter1;
")})));
end KnownParameter1;


model IfEquationTemp1
    function f
        input Real x;
        output Real[2] y = {x,x+1};
    algorithm
    end f;
    
    Real[:] y = if sum(f(time))>0 then f(1) else f(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEquationTemp1",
            description="",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.IfEquationTemp1
 Real y[1];
 Real y[2];
 Real temp_1[1];
 Real temp_1[2];
equation
 ({temp_1[1], temp_1[2]}) = VariabilityPropagationTests.IfEquationTemp1.f(time);
 y[1] = if temp_1[1] + temp_1[2] > 0 then 1.0 else 2.0;
 y[2] = if temp_1[1] + temp_1[2] > 0 then 2.0 else 3.0;

public
 function VariabilityPropagationTests.IfEquationTemp1.f
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := x;
  temp_1[2] := x + 1;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end VariabilityPropagationTests.IfEquationTemp1.f;

end VariabilityPropagationTests.IfEquationTemp1;
")})));
end IfEquationTemp1;

model IfEquationTemp2
    function f
        input Real x;
        output Real[2] y = {x,x+1};
    algorithm
    end f;
    
    Real[:] y = if sum(f(time))>0 then f(c) else f(c+1);
    Real c = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEquationTemp2",
            description="",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationTests.IfEquationTemp2
 Real y[1];
 Real y[2];
 constant Real c = 1;
 Real temp_1[1];
 Real temp_1[2];
equation
 ({temp_1[1], temp_1[2]}) = VariabilityPropagationTests.IfEquationTemp2.f(time);
 y[1] = if temp_1[1] + temp_1[2] > 0 then 1.0 else 2.0;
 y[2] = if temp_1[1] + temp_1[2] > 0 then 2.0 else 3.0;

public
 function VariabilityPropagationTests.IfEquationTemp2.f
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := x;
  temp_1[2] := x + 1;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end VariabilityPropagationTests.IfEquationTemp2.f;

end VariabilityPropagationTests.IfEquationTemp2;
")})));
end IfEquationTemp2;

model SmallConstant1
    Real x;
equation
    1e-17*x=1e-16;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SmallConstant1",
            description="",
            inline_functions="none",
            tearing_division_tolerance=1e-15,
            flatModel="
fclass VariabilityPropagationTests.SmallConstant1
 constant Real x = 9.999999999999998;
end VariabilityPropagationTests.SmallConstant1;
")})));
end SmallConstant1;

model StringVariable1
    String s1,s2;
equation
    s1 = "1";
    s2 = s1 + "2";
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StringVariable1",
            description="",
            flatModel="
fclass VariabilityPropagationTests.StringVariable1
 constant String s1 = \"1\";
 constant String s2 = \"12\";
end VariabilityPropagationTests.StringVariable1;
")})));
end StringVariable1;

model ExternalObjectConstant1
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    function f
        input EO x;
        output Real y;
        external;
    end f;
    
    constant Real x = 1;
    constant EO eo = EO(x);
    Real y = f(eo);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExternalObjectConstant1",
            description="Test behavior when variability propagation tries to evaluate an equation with global constant external object reference",
            flatModel="
            
fclass VariabilityPropagationTests.ExternalObjectConstant1
 constant Real x = 1;
 parameter Real y;
global variables
 constant VariabilityPropagationTests.ExternalObjectConstant1.EO VariabilityPropagationTests.ExternalObjectConstant1.eo = VariabilityPropagationTests.ExternalObjectConstant1.EO.constructor(1.0);
parameter equation
 y = VariabilityPropagationTests.ExternalObjectConstant1.f(global(VariabilityPropagationTests.ExternalObjectConstant1.eo));

public
 function VariabilityPropagationTests.ExternalObjectConstant1.EO.destructor
  input VariabilityPropagationTests.ExternalObjectConstant1.EO eo;
 algorithm
  external \"C\" destructor(eo);
  return;
 end VariabilityPropagationTests.ExternalObjectConstant1.EO.destructor;

 function VariabilityPropagationTests.ExternalObjectConstant1.EO.constructor
  input Real x;
  output VariabilityPropagationTests.ExternalObjectConstant1.EO eo;
 algorithm
  external \"C\" eo = constructor(x);
  return;
 end VariabilityPropagationTests.ExternalObjectConstant1.EO.constructor;

 function VariabilityPropagationTests.ExternalObjectConstant1.f
  input VariabilityPropagationTests.ExternalObjectConstant1.EO x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end VariabilityPropagationTests.ExternalObjectConstant1.f;

 type VariabilityPropagationTests.ExternalObjectConstant1.EO = ExternalObject;
end VariabilityPropagationTests.ExternalObjectConstant1;
")})));
end ExternalObjectConstant1;

model ExternalObjectConstant2
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    function f
        input EO x;
        output Real y;
        external;
    end f;
    
    function g
        input EO x;
        output EO y = x;
    algorithm
        annotation(Inline=false);
    end g;
    
    constant Real x = 1;
    constant EO eo = EO(x);
    Real y = f(g(eo));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExternalObjectConstant2",
            description="Test behavior when variability propagation tries to evaluate an equation with global constant external object reference",
            flatModel="
fclass VariabilityPropagationTests.ExternalObjectConstant2
 constant Real x = 1;
 parameter Real y;
global variables
 constant VariabilityPropagationTests.ExternalObjectConstant2.EO VariabilityPropagationTests.ExternalObjectConstant2.eo = VariabilityPropagationTests.ExternalObjectConstant2.EO.constructor(1.0);
parameter equation
 y = VariabilityPropagationTests.ExternalObjectConstant2.f(VariabilityPropagationTests.ExternalObjectConstant2.g(global(VariabilityPropagationTests.ExternalObjectConstant2.eo)));

public
 function VariabilityPropagationTests.ExternalObjectConstant2.EO.destructor
  input VariabilityPropagationTests.ExternalObjectConstant2.EO eo;
 algorithm
  external \"C\" destructor(eo);
  return;
 end VariabilityPropagationTests.ExternalObjectConstant2.EO.destructor;

 function VariabilityPropagationTests.ExternalObjectConstant2.EO.constructor
  input Real x;
  output VariabilityPropagationTests.ExternalObjectConstant2.EO eo;
 algorithm
  external \"C\" eo = constructor(x);
  return;
 end VariabilityPropagationTests.ExternalObjectConstant2.EO.constructor;

 function VariabilityPropagationTests.ExternalObjectConstant2.f
  input VariabilityPropagationTests.ExternalObjectConstant2.EO x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end VariabilityPropagationTests.ExternalObjectConstant2.f;

 function VariabilityPropagationTests.ExternalObjectConstant2.g
  input VariabilityPropagationTests.ExternalObjectConstant2.EO x;
  output VariabilityPropagationTests.ExternalObjectConstant2.EO y;
 algorithm
  y := x;
  return;
 annotation(Inline = false);
 end VariabilityPropagationTests.ExternalObjectConstant2.g;

 type VariabilityPropagationTests.ExternalObjectConstant2.EO = ExternalObject;
end VariabilityPropagationTests.ExternalObjectConstant2;
")})));
end ExternalObjectConstant2;

    model CompositeStmt1
        record R
            Real x;
        end R;
        
        function f
            input R r;
            constant R c(x=1);
            output R[:] y = {c, r};
        algorithm
            annotation(Inline=false);
        end f;
        
        R[:] r = f(R(2));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CompositeStmt1",
            description="",
            flatModel="
fclass VariabilityPropagationTests.CompositeStmt1
 constant Real r[1].x = 1;
 constant Real r[2].x = 2;
end VariabilityPropagationTests.CompositeStmt1;
")})));
    end CompositeStmt1;

end VariabilityPropagationTests;
