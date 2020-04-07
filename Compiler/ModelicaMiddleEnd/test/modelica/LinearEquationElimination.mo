/*
    Copyright (C) 2009-2015 Modelon AB

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


package LinearEquationElimination
    model Simple1
        Real a,b,c,y,x;
    equation
        x = a + b + c;
        a + b + c = y;
        y * x = 1;
        a * b * c = time;
        sqrt(a^2 + b^2 + c^2) = 1;
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple1",
            description="A simple test case that tests elimination",
            flatModel="
fclass LinearEquationElimination.Simple1
 Real a;
 Real b;
 Real c;
 Real y;
equation
 y = a + b + c;
 y * y = 1;
 a * b * c = time;
 sqrt(a ^ 2 + b ^ 2 + c ^ 2) = 1;
end LinearEquationElimination.Simple1;
")})));
    end Simple1;


    model Simple2
        Real a;
        Real b;
        Real c;
        Real d;
    equation
        a = 2 * b + time;
        c = 2 * a - 4 * b;
        b = a + 2 * d + time;
        d = sin(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple2",
            description="A simple test case that tests elimination.",
            flatModel="
fclass LinearEquationElimination.Simple2
 Real a;
 Real b;
 Real c;
 Real d;
equation
 a = 2 * b + time;
 c = 2 * time;
 -4 * d = a + 3 * time;
 d = sin(time);
end LinearEquationElimination.Simple2;
")})));
    end Simple2;

    model Option1
        Real a,b,c,y,x;
    equation
        x = a + b + c;
        a + b + c = y;
        y * x = 1;
        a * b * c = time;
        sqrt(a^2 + b^2 + c^2) = 1;
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Option1",
            eliminate_linear_equations=false,
            description="Ensure that no elimination is done if option is false",
            flatModel="
fclass LinearEquationElimination.Option1
 Real a;
 Real b;
 Real c;
 Real y;
 Real x;
equation
 x = a + b + c;
 a + b + c = y;
 y * x = 1;
 a * b * c = time;
 sqrt(a ^ 2 + b ^ 2 + c ^ 2) = 1;
end LinearEquationElimination.Option1;
")})));
    end Option1;


    model FunctionCall1
        function F
            input Real i;
            output Real o;
        algorithm
            o := i + 1;
        annotation(Inline=false);
        end F;
        Real a,b,c,y,x;
    equation
        F(x) = a + b + c;
        a + b + c = y;
        y * x = 1;
        a * b * c = time;
        sqrt(a^2 + b^2 + c^2) = 1;
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall1",
            description="Ensure that no elimination is done if there is a function call in one of the expressions",
            eliminate_linear_equations=false,
            flatModel="
fclass LinearEquationElimination.FunctionCall1
 Real a;
 Real b;
 Real c;
 Real y;
 Real x;
equation
 LinearEquationElimination.FunctionCall1.F(x) = a + b + c;
 a + b + c = y;
 y * x = 1;
 a * b * c = time;
 sqrt(a ^ 2 + b ^ 2 + c ^ 2) = 1;

public
 function LinearEquationElimination.FunctionCall1.F
  input Real i;
  output Real o;
 algorithm
  o := i + 1;
  return;
 annotation(Inline = false);
 end LinearEquationElimination.FunctionCall1.F;

end LinearEquationElimination.FunctionCall1;
")})));
    end FunctionCall1;


    model Constant1
        Real a;
        Real b;
        Real c;
    equation
        a = b - 1;
        b = c + 1;
        c = sin(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constant1",
            description="Alias elimination through re-arrangement of variable ordering, solving for equations with
                    constant terms.",
            flatModel="
fclass LinearEquationElimination.Constant1
 Real b;
 Real c;
equation
 c = b - 1;
 c = sin(time);
end LinearEquationElimination.Constant1;
")})));
    end Constant1;

    model Constant2
        Real a, b, c;
        Real x;
    equation
        sin(a + b) = 0;
        a * b * c = time;
        a + b + c = 0;
        x = a + b + c;

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constant2",
            description="Ensure that constants can be the unique part between two equations and elimination occurs",
            flatModel="
fclass LinearEquationElimination.Constant2
 Real a;
 Real b;
 Real c;
 Real x;
equation
 sin(a + b) = 0;
 a * b * c = time;
 a + b + c = 0;
 x = 0;
end LinearEquationElimination.Constant2;
")})));
    end Constant2;


    model Constant3

        Real a;
        Real b;
        Real c;
        Real x;
    equation
        x = a + b + c;
        a + b + c = 1;
        b = sin(time);
        c = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constant3",
            description="Find alias expressions when a variable should be equal to a constant.",
            flatModel="
fclass LinearEquationElimination.Constant3
 Real a;
 Real b;
 Real c;
 Real x;
equation
 x = a + b + c;
 1 = x;
 b = sin(time);
 c = sin(time);
end LinearEquationElimination.Constant3;
")})));
    end Constant3;

    model ZerosOnOneSide1
        Real a,b,c,d;
    equation
        b = sin(time);
        d = cos(time);
        a + b + c = 0.0;
        - a + (- b) + d = 0.0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ZerosOnOneSide1",
            description="Ensure that we are able to eliminate equations where we have zeroes on the left hand side.",
            flatModel="
fclass LinearEquationElimination.ZerosOnOneSide1
 Real a;
 Real b;
 Real d;
equation
 b = sin(time);
 d = cos(time);
 a + b + (- d) = 0.0;
end LinearEquationElimination.ZerosOnOneSide1;
")})));
    end ZerosOnOneSide1;


    model Coefficient1
        Real a;
        Real b;
        Real c;
    equation
        a = 2 * b;
        a = 2 * c;
        c = sin(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Coefficient1",
            description="",
            flatModel="
fclass LinearEquationElimination.Coefficient1
 Real a;
 Real c;
equation
 a = 2 * c;
 c = sin(time);
end LinearEquationElimination.Coefficient1;
")})));
    end Coefficient1;


    model Coefficient2
        Real a;
        Real b;
        Real c;
    equation
        3 * a = 2 * b;
        2 * a = 4 * c;
        c = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Coefficient2",
            description="Alias elimination through re-arrangement of variable ordering, with coefficients on
                    both sides.",
            flatModel="
fclass LinearEquationElimination.Coefficient2
 Real a;
 Real b;
 Real c;
equation
 3 * a = 2 * b;
 2 * c = a;
 c = sin(time);
end LinearEquationElimination.Coefficient2;
")})));
    end Coefficient2;


    model TimeExpression1
        Real a;
        Real b;
    equation
        a = time + 1;
        b = a + 1;

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TimeExpression1",
            description="Find alias expressions where time is an alias.",
            flatModel="
fclass LinearEquationElimination.TimeExpression1
 Real a;
 Real b;
equation
 a = time + 1;
 b = a + 1;
end LinearEquationElimination.TimeExpression1;
")})));
    end TimeExpression1;


    model TimeExpression2

        Real a;
        Real b;
        Real c;
    equation
        a = time + 1;
        b = time - 1;
        c = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TimeExpression2",
            description="Find alias expressions when time expression is mutual.",
            flatModel="
fclass LinearEquationElimination.TimeExpression2
 Real a;
 Real b;
 Real c;
equation
 a = time + 1;
 b = a + -2;
 c = sin(time);
end LinearEquationElimination.TimeExpression2;
")})));
    end TimeExpression2;


    model CommonSubExpression1
        Real a = time;
        Real b, c;
    equation
        a + b = c + a;
        der(b) = a^2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CommonSubExpression1",
            description="Eliminating terms that are present on both sides of linear equation",
            flatModel="
fclass LinearEquationElimination.CommonSubExpression1
 Real a;
 Real b;
initial equation
 b = 0.0;
equation
 der(b) = a ^ 2;
 a = time;
end LinearEquationElimination.CommonSubExpression1;
")})));
    end CommonSubExpression1;


    model CommonSubExpression2
        Real x, y;
    equation
        x - x = y;
        y = x + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CommonSubExpression2",
            description="Eliminating terms that cancel each other out in linear equation",
            flatModel="
fclass LinearEquationElimination.CommonSubExpression2
 Real x;
 Real y;
equation
 0 = y;
 x + 1 = 0;
end LinearEquationElimination.CommonSubExpression2;
")})));
    end CommonSubExpression2;


    model CommonSubExpression3
        Real a = time;
        Real b, c, d, e;
    equation
        -d + 3 * a + b - d = c + a - 2 * (d - a) - e;
        der(b) = a^2;
        der(d) = b + e;
        e = a^3 + c;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CommonSubExpression3",
            description="Eliminating terms that are present on both sides of linear equation",
            flatModel="
fclass LinearEquationElimination.CommonSubExpression3
 Real a;
 Real b;
 Real c;
 Real d;
 Real e;
initial equation
 b = 0.0;
 d = 0.0;
equation
 b + e = c;
 der(b) = a ^ 2;
 der(d) = b + e;
 e = a ^ 3 + c;
 a = time;
end LinearEquationElimination.CommonSubExpression3;
")})));
    end CommonSubExpression3;
    
model String1
    String s1,s2;
equation
    s2 = s1 + s2;
    s2 = String(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="String1",
            description="Don't eliminate strings",
            errorMessage="
Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     s1

  The following equation(s) could not be matched to any variable:
    s2 = s1 + s2
")})));
end String1;

end LinearEquationElimination;
