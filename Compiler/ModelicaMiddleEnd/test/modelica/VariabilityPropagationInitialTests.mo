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

package VariabilityPropagationInitialTests

package FixedFalse

model FixedFalse1
    parameter Real p1(fixed=false);
    Real p2 = p1 + 1;
initial equation
    p1 = 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse1",
            description="Test propagation of fixed false parameters",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse1
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
initial equation 
 p1 = 23;
 p2 = p1 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse1;
")})));
end FixedFalse1;

model FixedFalse2

    function f
        input Real x;
        output Real y2 = x;
        output Real y3 = x;
        algorithm
    end f;

    parameter Real p1(fixed=false);
    Real p2;
    Real p3;
initial equation
    p1 = 23;
equation
    (p2,p3) = f(p1);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse2",
            inline_functions="none",
            description="Test propagation of fixed false parameters, function call equation",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse2
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
 initial parameter Real p3;
initial equation 
 p1 = 23;
 (p2, p3) = VariabilityPropagationInitialTests.FixedFalse.FixedFalse2.f(p1);

public
 function VariabilityPropagationInitialTests.FixedFalse.FixedFalse2.f
  input Real x;
  output Real y2;
  output Real y3;
 algorithm
  y2 := x;
  y3 := x;
  return;
 end VariabilityPropagationInitialTests.FixedFalse.FixedFalse2.f;

end VariabilityPropagationInitialTests.FixedFalse.FixedFalse2;
")})));
end FixedFalse2;

model FixedFalse3
    parameter Real p1(fixed=false);
    discrete Real p2 = p1 + 1;
initial equation
    p1 = 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse3",
            description="Test propagation of fixed false parameters, originally discrete",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse3
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
initial equation 
 p1 = 23;
 p2 = p1 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse3;
")})));
end FixedFalse3;

model FixedFalse4
    parameter Real p1(fixed=false);
    Real p2 = p1 + 1;
    Real p3 = p2 + 1;
initial equation
    p1 = 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse4",
            description="Test propagation of fixed false parameters, chained",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse4
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
 initial parameter Real p3;
initial equation 
 p1 = 23;
 p2 = p1 + 1;
 p3 = p2 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse4;
")})));
end FixedFalse4;

model FixedFalse5
    parameter Real p1(fixed=false);
    Real p2 = p1 + 1;
    Real p3 = p2;
initial equation
    p1 = p2 * 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse5",
            description="Test propagation of fixed false parameters, alias",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse5
 initial parameter Real p1(fixed = false);
 initial parameter Real p3;
 initial parameter Real p2;
initial equation 
 p1 = p3 * 23;
 p2 = p3;
 p3 = p1 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse5;
")})));
end FixedFalse5;

model FixedFalse6
    parameter Real p1(fixed=false);
    Real p2 = p1 + 1;
    Real p3 = p2;
initial algorithm
    p1 := p2 * 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse6",
            description="Test propagation of fixed false parameters, algorithm",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse6
 initial parameter Real p1(fixed = false);
 initial parameter Real p3;
 initial parameter Real p2;
initial equation
 algorithm
  p1 := p3 * 23;
;
 p2 = p3;
 p3 = p1 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse6;
")})));
end FixedFalse6;

end FixedFalse;

package InitialEquation

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
fclass VariabilityPropagationInitialTests.InitialEquation.InitialEquation1
 parameter Boolean c = false /* false */;
 parameter Boolean b;
parameter equation
 b = c;
end VariabilityPropagationInitialTests.InitialEquation.InitialEquation1;
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
fclass VariabilityPropagationInitialTests.InitialEquation.InitialEquation2
 parameter Real y;
 parameter Real x(fixed = true,start = 3.14);
 parameter Real p1 = 1 /* 1 */;
parameter equation
 y = p1 + 1;
 x = y + 1;
end VariabilityPropagationInitialTests.InitialEquation.InitialEquation2;
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
fclass VariabilityPropagationInitialTests.InitialEquation.InitialEquation3
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
end VariabilityPropagationInitialTests.InitialEquation.InitialEquation3;
")})));
end InitialEquation3;

model InitialEquation4
    parameter Real p1;
initial equation
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InitialEquation4",
            description="Test no propagation of initial equations",
            errorMessage="
Error in flattened model:
  The DAE initialization system has 1 equations and 0 free variables.

Error in flattened model:
  The initialization system is structurally singular. The following equation(s) could not be matched to any variable:
    p1 = 3
")})));
end InitialEquation4;

end InitialEquation;

package InitialSystemPropagate

model InitialSystemPropagateConstant1
    parameter Real p1(fixed=false);
initial equation
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateConstant1",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant1
 constant Real p1(fixed = true) = 3;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant1;
")})));
end InitialSystemPropagateConstant1;

model InitialSystemPropagateConstant2
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
initial equation
    p2 = p1 + 1;
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateConstant2",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant2
 constant Real p1(fixed = true) = 3;
 constant Real p2(fixed = true) = 4.0;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant2;
")})));
end InitialSystemPropagateConstant2;

model InitialSystemPropagateConstant3
    function f
        input Real x;
        output Real y1 = x;
        output Real y2 = x + 1;
        algorithm
        annotation(Inline=false);
    end f;

    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
initial equation
    (p2,p3) = f(p1 + 1);
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateConstant3",
            description="Test propagation of initial equations, function call equation",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant3
 constant Real p1(fixed = true) = 3;
 constant Real p2(fixed = true) = 4.0;
 constant Real p3(fixed = true) = 5.0;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant3;
")})));
end InitialSystemPropagateConstant3;

model InitialSystemPropagateParameter1
    parameter Real p1(fixed=false);
    parameter Real p;
initial equation
    p1 = p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter1",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter1
 parameter Real p1(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter1;
")})));
end InitialSystemPropagateParameter1;

model InitialSystemPropagateParameter2
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p;
initial equation
    p2 = p1 + 1;
    p1 = p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter2",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter2
 parameter Real p1(fixed = true);
 parameter Real p2(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
 p2 = p1 + 1;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter2;
")})));
end InitialSystemPropagateParameter2;

model InitialSystemPropagateParameter3
    function f
        input Real x;
        output Real y1 = x;
        output Real y2 = x + 1;
        algorithm
        annotation(Inline=false);
    end f;

    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    parameter Real p;
initial equation
    (p2,p3) = f(p1 + 1);
    p1 = p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter3",
            description="Test propagation of initial equations, function call equation",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter3
 parameter Real p1(fixed = true);
 parameter Real p2(fixed = true);
 parameter Real p3(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
 (p2, p3) = VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter3.f(p1 + 1);

public
 function VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter3.f
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x;
  y2 := x + 1;
  return;
 annotation(Inline = false);
 end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter3.f;

end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter3;
")})));
end InitialSystemPropagateParameter3;

model InitialSystemPropagateParameter4
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    parameter Real p;
initial algorithm
    p2 := p1 + 1;
    p3 := p2 + 1;
initial equation
    p1 = p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter4",
            description="Test propagation of initial equations, algorithm",
            variability_propagation_initial=true,
            variability_propagation_algorithms=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter4
 parameter Real p1(fixed = true);
 parameter Real p2(fixed = true);
 parameter Real p3(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
 algorithm
  p2 := p1 + 1;
  p3 := p2 + 1;
;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter4;
")})));
end InitialSystemPropagateParameter4;

model InitialSystemPropagateParameter5
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
initial equation
    p2 = p1 + 1;
initial algorithm
    p1 := p2 * 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter5",
            description="Test propagation of fixed false parameters, algorithm, no propagation",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter5
 initial parameter Real p1(fixed = false);
 initial parameter Real p2(fixed = false);
initial equation
 p2 = p1 + 1;
 algorithm
  p1 := p2 * 23;
;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter5;
")})));
end InitialSystemPropagateParameter5;

model InitialSystemPropagateParameter6
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
initial algorithm
    p1 := p2 * 23;
    p2 := p1 + 1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter6",
            description="Test propagation of fixed false parameters, algorithm, no propagation",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter6
 initial parameter Real p1(fixed = false);
 initial parameter Real p2(fixed = false);
initial equation
 algorithm
  p1 := p2 * 23;
  p2 := p1 + 1;
;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter6;
")})));
end InitialSystemPropagateParameter6;

model InitialSystemPropagateParameter7
    function f
        input Real x1;
        input Real x2;
    algorithm
        annotation(Inline=false);
    end f;
    parameter Real p1 = 0;
    parameter Real p2(fixed=false);
initial equation
    f(p1, p2);
    p2 = 1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter7",
            description="Test propagation of fixed false parameters, function call equation, no propagation",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter7
 parameter Real p1 = 0 /* 0 */;
 constant Real p2(fixed = true) = 1;
initial equation
 VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter7.f(p1, 1.0);

public
 function VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter7.f
  input Real x1;
  input Real x2;
 algorithm
  return;
 annotation(Inline = false);
 end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter7.f;

end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter7;
")})));
end InitialSystemPropagateParameter7;


end InitialSystemPropagate;

package MixedSystemPropagate

model MixedSystemPropagateConstant1
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    Real x1,x2;
initial equation
    p3 = p2*p1 + x1*x2;
    p2 = x1*p1;
    p1 = 3;
equation
    x1 = p1*p1;
    x2 = p2*p1*x1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagateConstant1",
            description="Test propagation of initial equations, interleaving constant",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant1
 constant Real p1(fixed = true) = 3;
 constant Real p2(fixed = true) = 27.0;
 constant Real p3(fixed = true) = 6642.0;
 constant Real x1 = 9.0;
 constant Real x2 = 729.0;
end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant1;
")})));
end MixedSystemPropagateConstant1;

model MixedSystemPropagateConstant2
    function f
        input Real x1;
        input Real x2;
        output Real y1 = x1 + x2;
        output Real y2 = x1 + x2 + 1;
        algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p1(fixed=false);
    Real x1;
initial equation
    p1 = x1 + 1;
equation
    x1 = 1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagateConstant2",
            description="Test propagation of initial equations, interleaving constant",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant2
 constant Real p1(fixed = true) = 2.0;
 constant Real x1 = 1;
end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant2;
")})));
end MixedSystemPropagateConstant2;

model MixedSystemPropagateConstant3
    function f
        input Real x1;
        input Real x2;
        output Real y1 = x1 + x2;
        output Real y2 = x1 + x2 + 1;
        algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p1(fixed=false);
    Real x1,x2,x3,x4;
initial equation
    p1 = x4 + 1;
equation
    x1 = 2;
    (x2,x3) = f(x1, p1);
    x4 = 1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagateConstant3",
            description="Test propagation of initial equations, interleaving constant function call equation",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant3
 constant Real p1(fixed = true) = 2.0;
 constant Real x1 = 2;
 constant Real x2 = 4.0;
 constant Real x3 = 5.0;
 constant Real x4 = 1;
end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant3;
")})));
end MixedSystemPropagateConstant3;

model MixedSystemPropagateParameter2
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    Real x1,x2;
    parameter Real p;
initial equation
    p3 = p2*p1 + x1*x2;
    p2 = x1*p1;
    p1 = p;
equation
    x1 = p1*p1;
    x2 = p2*p1*x1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagateParameter2",
            description="Test propagation of initial equations, interleaving parameter",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter2
 parameter Real p1(fixed = true);
 parameter Real x1;
 parameter Real p2(fixed = true);
 parameter Real x2;
 parameter Real p3(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
 x1 = p1 * p1;
 p2 = x1 * p1;
 x2 = p2 * p1 * x1;
 p3 = p2 * p1 + x1 * x2;
end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter2;
")})));
end MixedSystemPropagateParameter2;

model MixedSystemPropagateParameter3
    function f
        input Real x1;
        input Real x2;
        output Real y1 = x1 + x2;
        output Real y2 = x1 + x2 + 1;
        algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p1(fixed=false);
    Real x1,x2,x3,x4;
    parameter Real p = 1;
initial equation
    p1 = x4 + 1;
equation
    x1 = p;
    (x2,x3) = f(x1, p1);
    x4 = p;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagateParameter3",
            description="Test propagation of initial equations, interleaving parameter function call equation",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter3
 parameter Real x1;
 parameter Real x4;
 parameter Real p1(fixed = true);
 parameter Real x2;
 parameter Real x3;
 parameter Real p = 1 /* 1 */;
parameter equation
 x1 = p;
 x4 = p;
 p1 = x4 + 1;
 (x2, x3) = VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter3.f(x1, p1);

public
 function VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter3.f
  input Real x1;
  input Real x2;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x1 + x2;
  y2 := x1 + x2 + 1;
  return;
 annotation(Inline = false);
 end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter3.f;

end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter3;
")})));
end MixedSystemPropagateParameter3;

model MixedSystemPropagatePartial1
    function f
        input Real x1;
        input Real x2;
        input Real x3;
        output Real y1 = x1 + 1;
        output Real y2 = x2 + 1;
        output Real y3 = x3 + 1;
        algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    Real x1,x2,x3,x4;
initial equation
    (p1,p2,p3) = f(x1, x2, x3);
equation
    (x1,x2,x3) = f(x4, p1, p2);
    x4 = 1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagatePartial1",
            description="Test propagation of initial equations, interleaving partial evaluation",
            variability_propagation_initial=true,
            variability_propagation_initial_partial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1
 constant Real p1(fixed = true) = 3.0;
 constant Real p2(fixed = true) = 5.0;
 constant Real p3(fixed = true) = 7.0;
 constant Real x1 = 2.0;
 constant Real x2 = 4.0;
 constant Real x3 = 6.0;
 constant Real x4 = 1;
end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1;
")})));
end MixedSystemPropagatePartial1;

model MixedSystemPropagatePartial1_b
    function f
        input Real x1;
        input Real x2;
        input Real x3;
        output Real y1 = x1 + 1;
        output Real y2 = x2 + 1;
        output Real y3 = x3 + 1;
        algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    Real x1,x2,x3,x4;
initial equation
    (p1,p2,p3) = f(x1, x2, x3);
equation
    (x1,x2,x3) = f(x4, p1, p2);
    x4 = 1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagatePartial1_b",
            description="Test propagation of initial equations, partial evaluation disabled",
            variability_propagation_initial=true,
            variability_propagation_initial_partial=false,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1_b
 initial parameter Real p1(fixed = false);
 initial parameter Real p2(fixed = false);
 initial parameter Real p3(fixed = false);
 constant Real x1 = 2.0;
 initial parameter Real x2;
 initial parameter Real x3;
 constant Real x4 = 1;
initial equation
 (p1, p2, p3) = VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1_b.f(2.0, x2, x3);
 (, x2, x3) = VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1_b.f(1.0, p1, p2);

public
 function VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1_b.f
  input Real x1;
  input Real x2;
  input Real x3;
  output Real y1;
  output Real y2;
  output Real y3;
 algorithm
  y1 := x1 + 1;
  y2 := x2 + 1;
  y3 := x3 + 1;
  return;
 annotation(Inline = false);
 end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1_b.f;

end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial1_b;
")})));
end MixedSystemPropagatePartial1_b;

model MixedSystemPropagatePartial2
    function f
        input Real x1;
        input Real x2;
        input Real x3;
        output Real y1 = x1 + 1;
        output Real y2 = x2 + 1;
        output Real y3 = x3 + 1;
        algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    Real x1,x2,x3,x4;
initial equation
    (p1,p2,p3) = f(x1, x2, x3);
equation
    (x1,x2,x3) = f(x4, p1, p2 + time);
    x4 = 1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagatePartial2",
            description="Test propagation of initial equations, interleaving partial evaluation",
            variability_propagation_initial=true,
            variability_propagation_initial_partial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial2
 constant Real p1(fixed = true) = 3.0;
 constant Real p2(fixed = true) = 5.0;
 initial parameter Real p3(fixed = false);
 constant Real x1 = 2.0;
 constant Real x2 = 4.0;
 Real x3;
 constant Real x4 = 1;
initial equation
 (, , p3) = VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial2.f(2.0, 4.0, x3);
equation
 (, , x3) = VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial2.f(1.0, 3.0, 5.0 + time);

public
 function VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial2.f
  input Real x1;
  input Real x2;
  input Real x3;
  output Real y1;
  output Real y2;
  output Real y3;
 algorithm
  y1 := x1 + 1;
  y2 := x2 + 1;
  y3 := x3 + 1;
  return;
 annotation(Inline = false);
 end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial2.f;

end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagatePartial2;
")})));
end MixedSystemPropagatePartial2;

end MixedSystemPropagate;

model FailedInitialPartialEval1
    function f
        input Real x1;
        input Real x2;
        output Real y1;
        output Real y2;
    algorithm
        assert(false, "");
    end f;
    
    parameter Real y1(fixed=false);
    parameter Real y2(fixed=false);
initial equation
    (y1,y2) = f(1, y1);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FailedInitialPartialEval1",
            description="Failed partial evaluation in initial system",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.FailedInitialPartialEval1
 initial parameter Real y1(fixed = false);
 initial parameter Real y2(fixed = false);
initial equation
 (y1, y2) = VariabilityPropagationInitialTests.FailedInitialPartialEval1.f(1, y1);

public
 function VariabilityPropagationInitialTests.FailedInitialPartialEval1.f
  input Real x1;
  input Real x2;
  output Real y1;
  output Real y2;
 algorithm
  assert(false, \"\");
  return;
 end VariabilityPropagationInitialTests.FailedInitialPartialEval1.f;

end VariabilityPropagationInitialTests.FailedInitialPartialEval1;
")})));
end FailedInitialPartialEval1;

model InitialSystemPropagatePartial1
    function f
        input Real x1;
        input Real x2;
        output Real y1 = x1 + 1;
        output Real y2 = x2 + 1;
        algorithm
        annotation(Inline=false);
    end f;
    
    parameter Real p1 = 1;
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    parameter Real x1(fixed=false);
initial equation
    (p1,p2) = f(x1, p3);
    p3 = p1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagatePartial1",
            description="Test infinite loop bug during partial propagation in initial system",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagatePartial1
 parameter Real p1 = 1 /* 1 */;
 initial parameter Real p2(fixed = false);
 parameter Real p3(fixed = true);
 initial parameter Real x1(fixed = false);
initial equation
 (p1, p2) = VariabilityPropagationInitialTests.InitialSystemPropagatePartial1.f(x1, p3);
parameter equation
 p3 = p1;

public
 function VariabilityPropagationInitialTests.InitialSystemPropagatePartial1.f
  input Real x1;
  input Real x2;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x1 + 1;
  y2 := x2 + 1;
  return;
 annotation(Inline = false);
 end VariabilityPropagationInitialTests.InitialSystemPropagatePartial1.f;

end VariabilityPropagationInitialTests.InitialSystemPropagatePartial1;
")})));
end InitialSystemPropagatePartial1;

end VariabilityPropagationInitialTests;
