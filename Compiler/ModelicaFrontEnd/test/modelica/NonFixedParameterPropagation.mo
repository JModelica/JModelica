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


package NonFixedParameterPropagation
    
    model Simple1
        parameter Real x(fixed=false, start=3.14);
        parameter Real y = x;
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple1",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple1
 initial parameter Real x(fixed = false,start = 3.14);
 initial parameter Real y;
 initial parameter Real z(start = 1);
initial equation 
 x = 3.14;
 y = x;
 z = y;
end NonFixedParameterPropagation.Simple1;
")})));
    end Simple1;
    
    model Simple2
        parameter Real x(fixed=false, start=3.14);
        parameter Real y(fixed=false) = x;
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple2",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple2
 initial parameter Real x(fixed = false,start = 3.14);
 initial parameter Real y(fixed = false);
 initial parameter Real z(start = 1);
initial equation 
 x = 3.14;
 y = x;
 z = y;
end NonFixedParameterPropagation.Simple2;
")})));
    end Simple2;
    
    model Simple3
        parameter Real x(fixed=false, start=3.14);
        parameter Real y(fixed=false);
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
        y = x + 42;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple3",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple3
 initial parameter Real x(fixed = false,start = 3.14);
 initial parameter Real y(fixed = false);
 initial parameter Real z(start = 1);
initial equation 
 x = 3.14;
 y = x + 42;
 z = y;
end NonFixedParameterPropagation.Simple3;
")})));
    end Simple3;
    
    model Simple4
        parameter Real x(fixed=false, start=3.14);
        parameter Real y(fixed=false);
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
        y = x;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple4",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple4
 initial parameter Real x(fixed = false,start = 3.14);
 initial parameter Real y(fixed = false);
 initial parameter Real z(start = 1);
initial equation 
 x = 3.14;
 y = x;
 z = y;
end NonFixedParameterPropagation.Simple4;
")})));
    end Simple4;
    
    model Simple5
        parameter Real x(fixed=false);
        Real y;
    initial equation
        y = 23;
    equation
        y = x + time;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple5",
            description="Test matching of non-fixed parameter",
            flatModel="
fclass NonFixedParameterPropagation.Simple5
 initial parameter Real x(fixed = false);
 Real y;
initial equation 
 y = 23;
equation
 y = x + time;
end NonFixedParameterPropagation.Simple5;
")})));
    end Simple5;
    
    model FunctionCall1
        function F
            input Real i;
            output Real o[2];
        algorithm
            o[1] := i;
            o[2] := - i;
        annotation(Inline=false);
        end F;
        parameter Real p[2] = F(x);
        parameter Real x(fixed=false);
    initial equation
        x = time;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall1",
            description="Test propagation of non fixed parameters through function call equations",
            flatModel="
fclass NonFixedParameterPropagation.FunctionCall1
 initial parameter Real p[1];
 initial parameter Real p[2];
 initial parameter Real x(fixed = false);
initial equation 
 x = time;
 ({p[1], p[2]}) = NonFixedParameterPropagation.FunctionCall1.F(x);

public
 function NonFixedParameterPropagation.FunctionCall1.F
  input Real i;
  output Real[:] o;
 algorithm
  init o as Real[2];
  o[1] := i;
  o[2] := - i;
  return;
 annotation(Inline = false);
 end NonFixedParameterPropagation.FunctionCall1.F;

end NonFixedParameterPropagation.FunctionCall1;
")})));
    end FunctionCall1;
    
model FunctionCall2
    function F1
        input Real[2] i1;
        output Real[2] o1;
    algorithm
        o1 := F2(i1);
    annotation(Inline=true);
    end F1;
    function F2
        input Real[2] i1;
        output Real[2] o1;
    algorithm
        o1[1] := i1[1] + i1[2];
        o1[2] := i1[1] * i1[2];
    annotation(LateInline=true);
    end F2;
    parameter Real[2] p1(fixed=false);
    parameter Real[2] p2 = F1(p1);
initial equation
    p1 = {time, time * 2};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall2",
            description="Test propagation of non fixed parameters through function call equations",
            flatModel="
fclass NonFixedParameterPropagation.FunctionCall2
 initial parameter Real p1[1](fixed = false);
 initial parameter Real p1[2](fixed = false);
 initial parameter Real p2[1];
 initial parameter Real p2[2];
initial equation
 p1[1] = time;
 p1[2] = time * 2;
 p2[1] = p1[1] + p1[2];
 p2[2] = p1[1] * p1[2];
end NonFixedParameterPropagation.FunctionCall2;
")})));
    end FunctionCall2;

model Reduction1
    parameter Real x(fixed=false) = y;
    parameter Real y = 3;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Reduction1",
            description="Fixed false reduced to fixed",
            flatModel="
fclass NonFixedParameterPropagation.Reduction1
 parameter Real x(fixed = false);
 parameter Real y = 3 /* 3 */;
parameter equation 
 x = y;
end NonFixedParameterPropagation.Reduction1;
")})));
end Reduction1;

model Reduction2
    record R
        parameter Real x(fixed=false);
        parameter Real y;
    end R;
    
    parameter Real x = 1;
    parameter Real y(fixed=false) = 2;
    
    R r = R(x, y);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Reduction2",
            description="Fixed false reduced to fixed",
            flatModel="
fclass NonFixedParameterPropagation.Reduction2
 parameter Real x = 1 /* 1 */;
 parameter Real y(fixed = false) = 2 /* 2 */;
 parameter Real r.x(fixed = false);
 parameter Real r.y;
parameter equation
 r.x = x;
 r.y = y;
end NonFixedParameterPropagation.Reduction2;
")})));
end Reduction2;

model Reduction3
    record R
        parameter Real x(fixed=false);
        parameter Real y;
    end R;
    
    parameter Real x = 1;
    parameter Real y(fixed=false);
    
    R r = R(x, y);
    
initial equation
    y = 2;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Reduction3",
            description="Fixed false reduced to fixed",
            flatModel="
fclass NonFixedParameterPropagation.Reduction3
 parameter Real x = 1 /* 1 */;
 initial parameter Real y(fixed = false);
 parameter Real r.x(fixed = false);
 initial parameter Real r.y;
initial equation 
 y = 2;
 r.y = y;
parameter equation
 r.x = x;
end NonFixedParameterPropagation.Reduction3;
")})));
end Reduction3;

model Reduction4
    record R
        Real[2] x;
        Real[2] y;
    end R;
    parameter R r(x(fixed=false),y(fixed=false));
initial equation
    r.x = 1:2;
    r.y = 1:2;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Reduction4",
            description="Fixed false reduced to fixed",
            flatModel="
fclass NonFixedParameterPropagation.Reduction4
 initial parameter Real r.x[1](fixed = false);
 initial parameter Real r.x[2](fixed = false);
 initial parameter Real r.y[1](fixed = false);
 initial parameter Real r.y[2](fixed = false);
initial equation 
 r.x[1] = 1;
 r.x[2] = 2;
 r.y[1] = 1;
 r.y[2] = 2;
end NonFixedParameterPropagation.Reduction4;
")})));
end Reduction4;

end NonFixedParameterPropagation;