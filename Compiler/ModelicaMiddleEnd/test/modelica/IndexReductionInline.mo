/*
    Copyright (C) 2018 Modelon AB

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


package IndexReductionInline

model InlineInitialTemp1
    function f
        input Real x;
        input Real y;
        output Real z;
    algorithm
        while z > 0 loop
            z := z - 1;
        end while;
        z := (x - y);
        annotation(derivative=fd);
    end f;
    
    function fd
        input Real x;
        input Real y;
        input Real xd;
        input Real yd;
        output Real z;
    algorithm
        z := (x - y) * x;
    end fd;
    
    parameter Real p(fixed = false);
    Real x1;
    Real x2;
equation
    der(x1) + der(x2) = f(p, time);
    x1 + f(p, x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InlineInitialTemp1",
            description="Index reduction inlining of function call depending on fixed=false parameter should generate fixed=false parameters",
            flatModel="
fclass IndexReductionInline.InlineInitialTemp1
 initial parameter Real p(fixed = false);
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
 p = 0.0;
equation
 _der_x1 + der(x2) = IndexReductionInline.InlineInitialTemp1.f(p, time);
 x1 + IndexReductionInline.InlineInitialTemp1.f(p, x2) = 1;
 - _der_x1 = (p - x2) * p;

public
 function IndexReductionInline.InlineInitialTemp1.f
  input Real x;
  input Real y;
  output Real z;
 algorithm
  while z > 0 loop
   z := z - 1;
  end while;
  z := x - y;
  return;
 annotation(derivative = IndexReductionInline.InlineInitialTemp1.fd);
 end IndexReductionInline.InlineInitialTemp1.f;

end IndexReductionInline.InlineInitialTemp1;
")})));
end InlineInitialTemp1;

model InlineInitialTemp2
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
    
    function g
        input EO eo;
        output Real y;
        external;
    end g;
    
    function f
        input EO eo;
        input Real y;
        output Real z;
    algorithm
        while z > 0 loop
            z := z - 1;
        end while;
        z := (g(eo) - y);
        annotation(derivative=fd);
    end f;
    
    function fd
        input EO eo;
        input Real y;
        input Real yd;
        output Real z;
    algorithm
        z := (g(eo) - y) * g(eo);
    end fd;
    
    parameter Real x(fixed=false);
    parameter EO eo = EO(x);
    Real x1;
    Real x2;
equation
    der(x1) + der(x2) = f(eo, time);
    x1 + f(eo, x2) = 1;
    
initial equation
    x = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InlineInitialTemp3",
            description="Index reduction inlining of function call depending on fixed=false parameter should generate fixed=false parameters",
            flatModel="
fclass IndexReductionInline.InlineInitialTemp2
 initial parameter Real x(fixed = false);
 initial parameter IndexReductionInline.InlineInitialTemp2.EO eo;
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x = 1;
 eo = IndexReductionInline.InlineInitialTemp2.EO.constructor(x);
 x2 = 0.0;
equation
 _der_x1 + der(x2) = IndexReductionInline.InlineInitialTemp2.f(eo, time);
 x1 + IndexReductionInline.InlineInitialTemp2.f(eo, x2) = 1;
 - _der_x1 = (IndexReductionInline.InlineInitialTemp2.g(eo) - x2) * IndexReductionInline.InlineInitialTemp2.g(eo);

public
 function IndexReductionInline.InlineInitialTemp2.EO.destructor
  input IndexReductionInline.InlineInitialTemp2.EO eo;
 algorithm
  external \"C\" destructor(eo);
  return;
 end IndexReductionInline.InlineInitialTemp2.EO.destructor;

 function IndexReductionInline.InlineInitialTemp2.EO.constructor
  input Real x;
  output IndexReductionInline.InlineInitialTemp2.EO eo;
 algorithm
  external \"C\" eo = constructor(x);
  return;
 end IndexReductionInline.InlineInitialTemp2.EO.constructor;

 function IndexReductionInline.InlineInitialTemp2.f
  input IndexReductionInline.InlineInitialTemp2.EO eo;
  input Real y;
  output Real z;
 algorithm
  while z > 0 loop
   z := z - 1;
  end while;
  z := IndexReductionInline.InlineInitialTemp2.g(eo) - y;
  return;
 annotation(derivative = IndexReductionInline.InlineInitialTemp2.fd);
 end IndexReductionInline.InlineInitialTemp2.f;

 function IndexReductionInline.InlineInitialTemp2.g
  input IndexReductionInline.InlineInitialTemp2.EO eo;
  output Real y;
 algorithm
  external \"C\" y = g(eo);
  return;
 end IndexReductionInline.InlineInitialTemp2.g;

 type IndexReductionInline.InlineInitialTemp2.EO = ExternalObject;
end IndexReductionInline.InlineInitialTemp2;
")})));
end InlineInitialTemp2;


end IndexReductionInline;

