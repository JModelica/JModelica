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

package BLTTests

package Unbalanced

model UnbalancedTest1_Err
  Real x = 1;
  Real y;
  Real z;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnbalancedTest1_Err",
            description="Test error messages for unbalanced systems.",
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     y
     z

")})));
end UnbalancedTest1_Err;

model UnbalancedTest2_Err
  Real x;
  Real y;
equation
  x = 1;
  x = 1+2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnbalancedTest2_Err",
            description="Test error messages for unbalanced systems.",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     y

  The following equation(s) could not be matched to any variable:
    x = 1 + 2
")})));
end UnbalancedTest2_Err;

model UnbalancedTest3_Err
  Real x;
equation
  x = 4;
  x = 5;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnbalancedTest3_Err",
            description="Test error messages for unbalanced systems.",
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following equation(s) could not be matched to any variable:
    4.0 = 5
")})));
end UnbalancedTest3_Err;

model UnbalancedTest4_Err
  Real x;
equation

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnbalancedTest4_Err",
            description="Test error messages for unbalanced systems.",
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     x
")})));
end UnbalancedTest4_Err;

model UnbalancedTest5_Err
    Real x = 0;
    Boolean y = false;
equation
    x = if y then 1 else 2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnbalancedTest5_Err",
            description="Test error messages for unbalanced systems.",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following equation(s) could not be matched to any variable:
    x = 0
")})));
end UnbalancedTest5_Err;

model UnbalancedInitTest1
	parameter Real x(fixed=false);
	parameter Real y(fixed=false);
initial equation
	x = 1;
	x = x * 3.14;
	
	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnbalancedInitTest1",
			description="Test error messages for unbalanced initial systems.",
			errorMessage="
Error in flattened model:
  The initialization system is structurally singular. The following variable(s) could not be matched to any equation:
     y

  The following equation(s) could not be matched to any variable:
    x = x * 3.14

")})));
end UnbalancedInitTest1;

end Unbalanced;

model MatchingTest1
	Real x(start=1);
	Real y;
initial equation
	x = 2*y;
equation
	der(x) = -x;
	der(y) = -y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MatchingTest1",
			description="Tests so that the matching algorithm prioritizes start value",
			equation_sorting=true,
			flatModel="
fclass BLTTests.MatchingTest1
 Real x(start = 1);
 Real y;
initial equation 
 x = 2 * y;
 x = 1;
equation
 der(x) = - x;
 der(y) = - y;
end BLTTests.MatchingTest1;
")})));
end MatchingTest1;

model MatchingTest2
	Real x;
	Real y(start=1);
initial equation
	x = 2*y;
equation
	der(x) = -x;
	der(y) = -y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MatchingTest2",
			description="Tests so that the matching algorithm prioritizes start value",
			equation_sorting=true,
			flatModel="
fclass BLTTests.MatchingTest2
 Real x;
 Real y(start = 1);
initial equation 
 x = 2 * y;
 y = 1;
equation
 der(x) = - x;
 der(y) = - y;
end BLTTests.MatchingTest2;
")})));
end MatchingTest2;

model MatchingTest3
    Real a, b;
    Integer c;
    discrete Real d;
equation
    when b > pre(c) then
        c = pre(c) + 42;
        d = time;
    end when;
    a = b + c + time;
    a = integer(time + 3.14);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="MatchingTest3",
            description="Tests so that the matching algorithm works well with discrete variables and equation",
            errorMessage="
1 errors found:

Error in flattened model:
  A when-guard is involved in an algebraic loop, consider breaking it using pre() expressions. Equations in block:
c = if temp_2 and not pre(temp_2) then pre(c) + 42 else pre(c)
a = b + c + time
temp_2 = b > pre(c)
")})));
end MatchingTest3;

model MatchingDiscreteReal1
    Boolean g;
    Real x;
    Real y;
equation
    der(y) = 1;
    when g then
        reinit(y, 0);
    end when;
algorithm 
    g := y > 0;
    when {g} then
        x := 0;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="MatchingDiscreteReal1",
            description="Matching discrete real in mixed algorithm",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
der(y) := 1

--- Pre propagation block (Block 1) ---
  --- Solved algorithm ---
  algorithm
    g := y > 0;
    if g and not pre(g) then
      x := 0;
    end if;

    Assigned variables: g
  --- Meta equation block ---
  if g and not pre(g) then
    reinit(y, 0);
  end if
  --- Solved algorithm ---
  algorithm
    g := y > 0;
    if g and not pre(g) then
      x := 0;
    end if;

    Assigned variables: x
-------------------------------
")})));
end MatchingDiscreteReal1;

model ExternalObjectLoop1
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
        input EO eo;
        output Real y;
        external;
    end f;
    
    parameter Real x(fixed=false);
    parameter EO eo = EO(x);
    parameter Real y = f(eo);
initial equation
    x = y;
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExternalObjectLoop1",
            description="Test error for external object in algebraic loop",
            errorMessage="
Error in flattened model, EXTERNAL_OBJECT_IN_BLOCK:
  The external object eo is computed in a block, this is not allowed!
Block which produced the error:
--- Torn mixed linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  x

Iteration variables:
  y

Solved discrete variables:
  eo

Torn equations:
  x := y

Continuous residual equations:
  y = BLTTests.ExternalObjectLoop1.f(eo)
    Iteration variables: y

Discrete equations:
  eo := BLTTests.ExternalObjectLoop1.EO.constructor(x)

Jacobian:
  |1.0, 0.0|
  |0.0, 1.0|
")})));
end ExternalObjectLoop1;

model ExternalObjectLoop2
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            input EO eo1;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    parameter Real x(fixed=false);
    parameter EO eo = EO(x, eo);
initial equation
    x = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExternalObjectLoop2",
            description="Test error for external object in algebraic loop",
            errorMessage="
Error at line 17, column 23, in file '...':
  Circularity in binding expression of parameter: eo = EO.constructor(x, eo)
")})));
end ExternalObjectLoop2;

end BLTTests;
