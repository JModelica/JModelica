/*
    Copyright (C) 2013 Modelon AB

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

within ;
package WhenTests
	
model ReinitErr1
	Real x;
equation
	der(x) = 1;
	reinit(x, 1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr1",
            description="reinit() outside when",
            errorMessage="
1 errors found:

Error at line 5, column 2, in file '...':
  The reinit() operator is only allowed in when clauses that are within an equation section.
")})));
end ReinitErr1;


model ReinitErr2
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x+1, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr2",
            description="reinit() with non access as var",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  First argument to reinit() must be an access to a Real variable
")})));
end ReinitErr2;


model ReinitErr3
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, true);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr3",
            description="reinit() Boolean expression",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr3;


model ReinitErr4
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, "1");
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr4",
            description="reinit() String expression",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr4;


model ReinitErr5
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;
    when time > 3 then
        reinit(x, 2);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr5",
            description="several reinit() of same var",
            errorMessage="
1 errors found:

Error at line 2, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  The variable x is assigned in reinit() clauses in more than one when clause:
    reinit(x, 1);
    reinit(x, 2);

")})));
end ReinitErr5;


model ReinitErr6
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr6",
            description="reinit() with wrong size expression",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr6;


model ReinitErr7
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1:2);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr7",
            description="reinit() with wrong size expression",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr7;


model ReinitErr8
    Integer x;
equation
    x = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr8",
            description="reinit() with Integer variable",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  First argument to reinit() must be an access to a Real variable
")})));
end ReinitErr8;


model ReinitErr9
    discrete Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr9",
            description="reinit() with discrete Real variable",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  Built-in operator reinit() must have a continuous variable access as its first argument
")})));
end ReinitErr9;


model ReinitErr10
    Real x;
equation
    when time > 2 then
        reinit(x, 1);
    end when;
    when time > 1 then
        x = 2;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr10",
            description="reinit() with (implicitly) discrete Real variable",
            errorMessage="
1 errors found:

Error at line 5, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  Built-in operator reinit() must have a continuous variable access as its first argument
")})));
end ReinitErr10;


model ReinitErr11
    Real x;
equation
    der(x) = 1;
algorithm
    when time > 2 then
        reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr11",
            description="reinit() in when statement",
            errorMessage="
1 errors found:

Error at line 7, column 9, in file '...':
  The reinit() operator is only allowed in when clauses that are within an equation section.
")})));
end ReinitErr11;


model ReinitErr12
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, ones(2));
    end when;
    when time > 4 then
        reinit(x[2], 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr12",
            description="several reinit() of same cell of array",
            errorMessage="
1 errors found:

Error at line 2, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  The variable x[2] is assigned in reinit() clauses in more than one when clause:
    reinit(x[2], 1);
    reinit(x[2], 1);

")})));
end ReinitErr12;


model ReinitErr13
    Real x;
    Real y;
equation
    der(x) = 1;
    when time > 2 then
        y = reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr13",
            description="using reinit() as RHS of equation",
            errorMessage="
1 errors found:

Error at line 7, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo', TYPE_MISMATCH_IN_EQUATION:
  The right and left expression types of equation are not compatible, type of left-hand side is Real, and type of right-hand side is (no return value)
")})));
end ReinitErr13;


model ReinitErr14
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, zeros(3));
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReinitErr14",
            description="reinit() with wrong size expression",
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/WhenTests.mo':
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr14;


model ReinitTest1
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ReinitTest1",
			description="Basic test of a when clause with reinit()",
			flatModel="
fclass WhenTests.ReinitTest1
 Real x(stateSelect = StateSelect.always);
 discrete Boolean temp_1;
initial equation 
 x = 0.0;
 pre(temp_1) = false;
equation
 der(x) = 1;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  reinit(x, 1);
 end if;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end WhenTests.ReinitTest1;
")})));
end ReinitTest1;


model ReinitTest2
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, ones(2));
    end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ReinitTest2",
			description="reinit() with array args",
			flatModel="
fclass WhenTests.ReinitTest2
 Real x[1](stateSelect = StateSelect.always);
 Real x[2](stateSelect = StateSelect.always);
 discrete Boolean temp_1;
initial equation 
 x[1] = 0.0;
 x[2] = 0.0;
 pre(temp_1) = false;
equation
 der(x[1]) = 1;
 der(x[2]) = 1;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  reinit(x[1], 1);
  reinit(x[2], 1);
 end if;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 end WhenTests.ReinitTest2;
")})));
end ReinitTest2;

model ParameterPre1
    constant Real c = 3;
    Real c2;
    Real x(start = 0);
    Real y(start = 0);
    parameter Real p = 1;
equation
    c2 = pre(c);
    when time > 0.5 then
        x = pre(p) + pre(c);
    end when;
algorithm
    when time > 0.25 then
        y := pre(p) + pre(c);
    end when;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ParameterPre1",
            description="pre() of parameter and constant",
            eliminate_alias_variables=false,
            flatModel="
fclass WhenTests.ParameterPre1
 constant Real c = 3;
 constant Real c2 = 3.0;
 discrete Real x(start = 0);
 discrete Real y(start = 0);
 parameter Real p = 1 /* 1 */;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
initial equation
 pre(x) = 0;
 pre(y) = 0;
 pre(temp_1) = false;
 pre(temp_2) = false;
equation
 temp_1 = time > 0.5;
 x = if temp_1 and not pre(temp_1) then p + 3.0 else pre(x);
 temp_2 = time > 0.25;
algorithm
 if temp_2 and not pre(temp_2) then
  y := p + 3.0;
 end if;
end WhenTests.ParameterPre1;
")})));
end ParameterPre1;

model InsideIfEquation1
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
        TransformCanonicalTestCase(
            name="InsideIfEquation1",
            description="Test rewrite of when equation inside if equation",
            flatModel="
fclass WhenTests.InsideIfEquation1
 Real x(stateSelect = StateSelect.always);
 Real y;
 discrete Boolean temp_1;
initial equation 
 x = 0.0;
 pre(temp_1) = false;
equation
 der(x) = 1;
 temp_1 = time > 2;
 y = if time < 1 then x + 1 else x - 1;
 if not time < 1 then
  if temp_1 and not pre(temp_1) then
   reinit(x, 0);
  end if;
 end if;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end WhenTests.InsideIfEquation1;
")})));
end InsideIfEquation1;


end WhenTests;
