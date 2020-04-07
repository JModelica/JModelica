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

package DerivativeVariablePropagation

    model RewriteTest1
        Real a, b, c;
    equation
        a = der(c);
        b = -c;
        b = time;
        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="RewriteTest1",
                description="A simple case that tests a simple derivative rewrite",
                flatModel="
fclass DerivativeVariablePropagation.RewriteTest1
 Real a;
 Real b;
equation
 b = time;
 - a = 1.0;
end DerivativeVariablePropagation.RewriteTest1;
")})));
    end RewriteTest1;
    
    model NegativeBaseAlias1
        Real a, b, c;
    equation
        a = der(c);
        b = -c;
        b = time + a;
        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="NegativeBaseAlias1",
                description="Ensure that the negation is handled when substitution for an alias.",
                flatModel="
fclass DerivativeVariablePropagation.NegativeBaseAlias1
 Real a;
 Real b;
initial equation 
 b = 0.0;
equation
 a = - der(b);
 b = time + (- der(b));
end DerivativeVariablePropagation.NegativeBaseAlias1;
")})));
    end NegativeBaseAlias1;
    
    model FunctionCallLefts1
        function F
            input Real i1;
            output Real o1;
            output Real o2;
        algorithm
            o1 := i1;
            o2 := - i1;
        annotation(Inline=false);
        end F;
        
        Real a,b;
    equation
        (a,) = F(time);
        der(b) = a;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="FunctionCallLefts1",
                description="Ensure that variables in function call lefts aren't rewritten.",
                flatModel="
fclass DerivativeVariablePropagation.FunctionCallLefts1
 Real a;
 Real b;
initial equation 
 b = 0.0;
equation
 (a, ) = DerivativeVariablePropagation.FunctionCallLefts1.F(time);
 der(b) = a;

public
 function DerivativeVariablePropagation.FunctionCallLefts1.F
  input Real i1;
  output Real o1;
  output Real o2;
 algorithm
  o1 := i1;
  o2 := - i1;
  return;
 annotation(Inline = false);
 end DerivativeVariablePropagation.FunctionCallLefts1.F;

end DerivativeVariablePropagation.FunctionCallLefts1;
")})));
    end FunctionCallLefts1;
    
    model NoIndexReduction1
        Real x;
        Real y;
    equation
        der(x) = y;
        y = x + time;
        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="NoIndexReduction1_disabled",
                propagate_derivatives=false,
                description="Ensure that no substitution is done when index reduction is disabled.",
                flatModel="
fclass DerivativeVariablePropagation.NoIndexReduction1
 Real x;
 Real y;
initial equation 
 x = 0.0;
equation
 der(x) = y;
 y = x + time;
end DerivativeVariablePropagation.NoIndexReduction1;
"),TransformCanonicalTestCase(
                name="NoIndexReduction1_enabled",
                propagate_derivatives=true,
                description="Ensure that substitution is done when index reduction is enabled.",
                flatModel="
fclass DerivativeVariablePropagation.NoIndexReduction1
 Real x;
 Real y;
initial equation 
 x = 0.0;
equation
 der(x) = y;
 der(x) = x + time;
end DerivativeVariablePropagation.NoIndexReduction1;
")})));
    end NoIndexReduction1;
    
end DerivativeVariablePropagation;
