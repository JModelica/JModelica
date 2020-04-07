/*
    Copyright (C) 2017 Modelon AB

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

package BlockCompositionTests
    package InitialParameters
        model Test1
            Real x;
            parameter Real p(fixed=false);
        initial equation
            2*x = p;
            x = 3;
        equation
            der(x) = -x;
        
        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="InitialParameters_Test1",
                description="Test of initial parameters.",
                flatModel="
fclass BlockCompositionTests.InitialParameters.Test1
 Real x;
 initial parameter Real p(fixed = false);
initial equation
 2 * x = p;
 x = 3;
equation
 der(x) = - x;
end BlockCompositionTests.InitialParameters.Test1;
")})));
        end Test1;
        
        model Test2
            Real x(start=p);
            parameter Real p(fixed=false) = time + x;
            Real y = p * time;
        equation
            der(x) = sin(time);
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="InitialParameters_Test2",
                description="Test incidence computation for state startvalues with initial parameters",
                methodName="printDAEInitBLT",
                methodResult="
--- Solved equation ---
der(x) := sin(time)

--- Torn linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  p

Iteration variables:
  x

Torn equations:
  p := time + x

Residual equations:
  x = p
    Iteration variables: x

Jacobian:
  |1.0, -1.0|
  |-1.0, 1.0|

--- Solved equation ---
y := p * time
-------------------------------
")})));
        end Test2;
        
        model Differentiation1
            parameter Real a1(fixed = false);
            parameter Real a2(fixed = false);
            parameter Real b = 2;
            parameter Real c = 3;
            Real d = time * 42;
        initial equation
            c = b * a1 - a2 * d;
            a1 = a2 * 3.14;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="InitialParameters_Differentiation1",
                description="Test differentiation of initial parameters",
                methodName="printDAEInitBLT",
                methodResult="
--- Solved equation ---
d := time * 42

--- Torn linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  a2

Iteration variables:
  a1

Torn equations:
  a2 := (- a1) / -3.14

Residual equations:
  c = b * a1 - a2 * d
    Iteration variables: a1

Jacobian:
  |-3.14, 1.0|
  |d, - b|
-------------------------------
")})));
        end Differentiation1;
        
        model StartValueDependency1
            parameter Real x_start(fixed = false);
            Real x(start = x_start) = sin(x);
        initial equation
            x_start = time;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="InitialParameters_StartValueDependency1",
                description="Test BLT order where start value of variable depend on initial parameter",
                methodName="printDAEInitBLT",
                methodResult="
--- Solved equation ---
x_start := time

--- Unsolved equation (Block 1) ---
x = sin(x)
  Computed variables: x
-------------------------------
")})));
        end StartValueDependency1;
        
        model StartValueDependency2
            parameter Real p(fixed=false) = y + 1;
            Real x(start = p);
            Real y;
        equation
            x * y = 10;
            x = y + time;

        annotation(__JModelica(UnitTesting(tests={
            ErrorTestCase(
                name="InitialParameters_StartValueDependency2",
                description="Test error given when start value of a variable depends on initial parameter which is computed in same block",
                errorMessage="
Error in flattened model, START_VALUE_DEPEND_ON_BLOCK_ERROR:
  The start value ('p') for variable x depends on variables which are computed in the same block, this is not allowed!
Block which produced the error:
--- Torn system (Block 1) of 1 iteration variables and 2 solved variables ---
Torn variables:
  y
  p

Iteration variables:
  x (start=p)

Torn equations:
  y := x - time
  p := y + 1

Residual equations:
  x * y = 10
    Iteration variables: x
")})));
        end StartValueDependency2;
        
    end InitialParameters;
end BlockCompositionTests;
