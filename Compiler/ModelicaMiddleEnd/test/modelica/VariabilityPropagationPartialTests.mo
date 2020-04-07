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

package VariabilityPropagationPartialTests

    function fp
        input Real i1;
        input Real i2;
        output Real o1 = i1;
        output Real o2 = i2;
    algorithm
    end fp;

model FunctionCallEquationPartial1
    Real x1,x2;
  equation
    (x1,x2) = fp(time,7);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial1",
            description="Tests evaluation of matrix multiplication in function.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial1
 Real x1;
 constant Real x2 = 7;
equation
 (x1, ) = VariabilityPropagationPartialTests.fp(time, 7);

public
 function VariabilityPropagationPartialTests.fp
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := i1;
  o2 := i2;
  return;
 end VariabilityPropagationPartialTests.fp;

end VariabilityPropagationPartialTests.FunctionCallEquationPartial1;
")})));
end FunctionCallEquationPartial1;

model FunctionCallEquationPartial2
    Real x1,x2,x3;
  equation
    x3 = 7;
    (x1,x2) = fp(time,x3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial2",
            description="Tests evaluation of matrix multiplication in function.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial2
 Real x1;
 constant Real x2 = 7.0;
 constant Real x3 = 7;
equation
 (x1, ) = VariabilityPropagationPartialTests.fp(time, 7.0);

public
 function VariabilityPropagationPartialTests.fp
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := i1;
  o2 := i2;
  return;
 end VariabilityPropagationPartialTests.fp;

end VariabilityPropagationPartialTests.FunctionCallEquationPartial2;
")})));
end FunctionCallEquationPartial2;

model FunctionCallEquationPartial3
    Real x1,x2,x3;
  equation
    (x1,x2) = fp(time,x3);
    x3 = 7;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial3",
            description="Tests evaluation of matrix multiplication in function.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial3
 Real x1;
 constant Real x2 = 7.0;
 constant Real x3 = 7;
equation
 (x1, ) = VariabilityPropagationPartialTests.fp(time, 7.0);

public
 function VariabilityPropagationPartialTests.fp
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := i1;
  o2 := i2;
  return;
 end VariabilityPropagationPartialTests.fp;

end VariabilityPropagationPartialTests.FunctionCallEquationPartial3;
")})));
end FunctionCallEquationPartial3;

model FunctionCallEquationPartial4
    Real x1,x2,x3,x4,x5;
  equation
    (x1,x2) = fp(x4,x5);
    (x3,x4) = fp(x1,x2);
    x5 = 7;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial4",
            description="Tests evaluation of matrix multiplication in function.",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial4
 constant Real x1 = 7.0;
 constant Real x2 = 7.0;
 constant Real x3 = 7.0;
 constant Real x4 = 7.0;
 constant Real x5 = 7;
end VariabilityPropagationPartialTests.FunctionCallEquationPartial4;
")})));
end FunctionCallEquationPartial4;

model FunctionCallEquationPartial5
    function fp
        input Real i1;
        input Real i2;
        input Real i3;
        input Real i4 = 13;
        output Real o1 = i1;
        output Real o2 = i2;
        output Real o3 = i3;
        output Real o4 = i4;
    algorithm
    end fp;
    Real x1,x2,x3,x4,x5,x6;
  equation
    (x1,x2,x3) = fp(x4, x5, x6);
    x4 = 3;
    x5 = x4 + x1;
    x6 = x4 + x1 + x2;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial5",
            description="Tests evaluation of matrix multiplication in function.",
            eliminate_alias_variables=false,
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial5
 constant Real x1 = 3.0;
 constant Real x2 = 6.0;
 constant Real x3 = 12.0;
 constant Real x4 = 3;
 constant Real x5 = 6.0;
 constant Real x6 = 12.0;
end VariabilityPropagationPartialTests.FunctionCallEquationPartial5;
")})));
end FunctionCallEquationPartial5;

model FunctionCallEquationPartial6
    Real x1,x2;
    parameter Real x3;
    Real x4;
  equation
    (x1,x2) = fp(x3,x4);
    x4 = 7;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial6",
            description="Tests evaluation of matrix multiplication in function.",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial6
 parameter Real x1;
 constant Real x2 = 7.0;
 parameter Real x3;
 constant Real x4 = 7;
parameter equation
 (x1, ) = VariabilityPropagationPartialTests.fp(x3, 7.0);

public
 function VariabilityPropagationPartialTests.fp
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := i1;
  o2 := i2;
  return;
 end VariabilityPropagationPartialTests.fp;

end VariabilityPropagationPartialTests.FunctionCallEquationPartial6;
")})));
end FunctionCallEquationPartial6;

model FunctionCallEquationPartial7
    function fp
        input Real i1;
        input Real i2;
        output Real o1 = i1;
        output Real o2 = i2;
        output Real o3 = i1;
    algorithm
    end fp;
    
    Real x1,x2,x3,x4,x5,c;
    parameter Real p;
  equation
    (x3,x4,x5) = fp(x1,x2);
    (x1,x2) = fp(p,c);
    c = 7;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial7",
            description="Tests evaluation of matrix multiplication in function.",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial7
 parameter Real x1;
 constant Real x2 = 7.0;
 parameter Real x3;
 constant Real x4 = 7.0;
 parameter Real x5;
 constant Real c = 7;
 parameter Real p;
parameter equation
 (x1, ) = VariabilityPropagationPartialTests.FunctionCallEquationPartial7.fp(p, 7.0);
 (x3, , x5) = VariabilityPropagationPartialTests.FunctionCallEquationPartial7.fp(x1, 7.0);

public
 function VariabilityPropagationPartialTests.FunctionCallEquationPartial7.fp
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
  output Real o3;
 algorithm
  o1 := i1;
  o2 := i2;
  o3 := i1;
  return;
 end VariabilityPropagationPartialTests.FunctionCallEquationPartial7.fp;

end VariabilityPropagationPartialTests.FunctionCallEquationPartial7;
")})));
end FunctionCallEquationPartial7;

model FunctionCallEquationPartial8
    function f
        input Real[:] x;
        input Boolean b;
        output Real[:] y = x;
    algorithm
        y := g(y);
        y := u(y);
        annotation(Inline=false);
    end f;
    
    function g
        input Real[:] x;
        output Real[size(x,1)] y;
    external;
    end g;
    
    function u
        input Real[:] x;
        output Real[size(x,1)] y = x;
    algorithm
    end u;
    Real[:] y = f({time,time},true);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial8",
            description="",
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial8
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = VariabilityPropagationPartialTests.FunctionCallEquationPartial8.f({time, time}, true);

public
 function VariabilityPropagationPartialTests.FunctionCallEquationPartial8.f
  input Real[:] x;
  input Boolean b;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  (y) := VariabilityPropagationPartialTests.FunctionCallEquationPartial8.g(y);
  (y) := VariabilityPropagationPartialTests.FunctionCallEquationPartial8.u(y);
  return;
 annotation(Inline = false);
 end VariabilityPropagationPartialTests.FunctionCallEquationPartial8.f;

 function VariabilityPropagationPartialTests.FunctionCallEquationPartial8.g
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  external \"C\" g(x, size(x, 1), y, size(y, 1));
  return;
 end VariabilityPropagationPartialTests.FunctionCallEquationPartial8.g;

 function VariabilityPropagationPartialTests.FunctionCallEquationPartial8.u
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  return;
 end VariabilityPropagationPartialTests.FunctionCallEquationPartial8.u;

end VariabilityPropagationPartialTests.FunctionCallEquationPartial8;
")})));
end FunctionCallEquationPartial8;

model FunctionCallEquationPartial9
        function f
            input Real x1;
            input Integer n;
            output Real[n] y;
        algorithm
            y := {x1,x1};
            assert(x1==1,"nope");
        end f;
    
        function g
            input Real x1;
            input Real x2;
            input Integer n;
            output Real[n] y;
        algorithm
            if x1 < x2 then
                y := f(x1,n);
            else
                y := {1,2};
            end if;
        end g;
    
        Real[:] y = g(2,time,2);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquationPartial9",
            description="Bug when returning cloned CValueUnknown",
            flatModel="
fclass VariabilityPropagationPartialTests.FunctionCallEquationPartial9
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = VariabilityPropagationPartialTests.FunctionCallEquationPartial9.g(2, time, 2);

public
 function VariabilityPropagationPartialTests.FunctionCallEquationPartial9.g
  input Real x1;
  input Real x2;
  input Integer n;
  output Real[:] y;
  Integer[:] temp_1;
 algorithm
  init y as Real[n];
  if x1 < x2 then
   (y) := VariabilityPropagationPartialTests.FunctionCallEquationPartial9.f(x1, n);
  else
   assert(n == 2, \"Mismatching sizes in VariabilityPropagationPartialTests.FunctionCallEquationPartial9.g\");
   init temp_1 as Integer[2];
   temp_1[1] := 1;
   temp_1[2] := 2;
   for i1 in 1:n loop
    y[i1] := temp_1[i1];
   end for;
  end if;
  return;
 end VariabilityPropagationPartialTests.FunctionCallEquationPartial9.g;

 function VariabilityPropagationPartialTests.FunctionCallEquationPartial9.f
  input Real x1;
  input Integer n;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[n];
  assert(n == 2, \"Mismatching sizes in VariabilityPropagationPartialTests.FunctionCallEquationPartial9.f\");
  init temp_1 as Real[2];
  temp_1[1] := x1;
  temp_1[2] := x1;
  for i1 in 1:n loop
   y[i1] := temp_1[i1];
  end for;
  assert(x1 == 1, \"nope\");
  return;
 end VariabilityPropagationPartialTests.FunctionCallEquationPartial9.f;

end VariabilityPropagationPartialTests.FunctionCallEquationPartial9;
")})));
end FunctionCallEquationPartial9;

    model PartiallyKnownComposite1
        function f
            input Real x1;
            input Real x2;
            output Real[2] y;
          algorithm
            y[1] := x1;
            y[2] := x2;
        end f;
        Real[2] y = f(2,time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite1",
            description="Partially propagated array",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite1
 constant Real y[1] = 2;
 Real y[2];
equation
 ({, y[2]}) = VariabilityPropagationPartialTests.PartiallyKnownComposite1.f(2, time);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite1.f
  input Real x1;
  input Real x2;
  output Real[:] y;
 algorithm
  init y as Real[2];
  y[1] := x1;
  y[2] := x2;
  return;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite1.f;

end VariabilityPropagationPartialTests.PartiallyKnownComposite1;
")})));
    end PartiallyKnownComposite1;
    
    model PartiallyKnownComposite2
        record R
            Real a;
            Real b;
        end R;
        function f
            input Real x1;
            input Real x2;
            output R y;
          algorithm
            y.a := x1;
            y.b := x2;
        end f;
        R y = f(2,time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite2",
            description="Partially propagated record",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite2
 constant Real y.a = 2;
 Real y.b;
equation
 (VariabilityPropagationPartialTests.PartiallyKnownComposite2.R(, y.b)) = VariabilityPropagationPartialTests.PartiallyKnownComposite2.f(2, time);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite2.f
  input Real x1;
  input Real x2;
  output VariabilityPropagationPartialTests.PartiallyKnownComposite2.R y;
 algorithm
  y.a := x1;
  y.b := x2;
  return;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite2.f;

 record VariabilityPropagationPartialTests.PartiallyKnownComposite2.R
  Real a;
  Real b;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite2.R;

end VariabilityPropagationPartialTests.PartiallyKnownComposite2;
")})));
    end PartiallyKnownComposite2;
    
        model PartiallyKnownComposite3
        function f
            input Real x1;
            input Real x2;
            output Real[2] y;
          algorithm
            y[1] := x1;
            y[2] := x2;
        end f;
        parameter Real p = 2;
        Real[2] y = f(2,p);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite3",
            description="Partially propagated array, parameter",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite3
 parameter Real p = 2 /* 2 */;
 constant Real y[1] = 2;
 parameter Real y[2];
parameter equation
 ({, y[2]}) = VariabilityPropagationPartialTests.PartiallyKnownComposite3.f(2, p);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite3.f
  input Real x1;
  input Real x2;
  output Real[:] y;
 algorithm
  init y as Real[2];
  y[1] := x1;
  y[2] := x2;
  return;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite3.f;

end VariabilityPropagationPartialTests.PartiallyKnownComposite3;
")})));
    end PartiallyKnownComposite3;
    
    model PartiallyKnownComposite4
        record R
            Real a;
            Real b;
        end R;
        function f
            input Real x1;
            input Real x2;
            output R y;
          algorithm
            y.a := x1;
            y.b := x2;
        end f;
        parameter Real p = 2;
        R y = f(2,p);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite4",
            description="Partially propagated record, parameter",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite4
 parameter Real p = 2 /* 2 */;
 constant Real y.a = 2;
 parameter Real y.b;
parameter equation
 (VariabilityPropagationPartialTests.PartiallyKnownComposite4.R(, y.b)) = VariabilityPropagationPartialTests.PartiallyKnownComposite4.f(2, p);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite4.f
  input Real x1;
  input Real x2;
  output VariabilityPropagationPartialTests.PartiallyKnownComposite4.R y;
 algorithm
  y.a := x1;
  y.b := x2;
  return;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite4.f;

 record VariabilityPropagationPartialTests.PartiallyKnownComposite4.R
  Real a;
  Real b;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite4.R;

end VariabilityPropagationPartialTests.PartiallyKnownComposite4;
")})));
    end PartiallyKnownComposite4;
    
        model PartiallyKnownComposite5
        function f
            input Integer n;
            input Real[n] x;
            output Real[n] y;
          algorithm
            y := x;
        end f;
        Real[4] y;
        Real[4] z;
      equation
        z[1:3] = y[2:4] .+ 1;
        y = f(4,z);
        z[4] = 3.14;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite5",
            description="Repeatedly partially propagated array",
            eliminate_alias_variables=false,
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite5
 constant Real y[1] = 6.140000000000001;
 constant Real y[2] = 5.140000000000001;
 constant Real y[3] = 4.140000000000001;
 constant Real y[4] = 3.14;
 constant Real z[1] = 6.140000000000001;
 constant Real z[2] = 5.140000000000001;
 constant Real z[3] = 4.140000000000001;
 constant Real z[4] = 3.14;
end VariabilityPropagationPartialTests.PartiallyKnownComposite5;
")})));
    end PartiallyKnownComposite5;
    
    model PartiallyKnownComposite6
        function f
            input Real[:] x;
            input Integer n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
        end f;
        Real[2] y = f({1,1-time}, 3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite6",
            description="Test evaluation of known components in partially known composite arg. (array)",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite6
 constant Real y[1] = 1;
 Real y[2];
equation
 ({, y[2]}) = VariabilityPropagationPartialTests.PartiallyKnownComposite6.f({1, 1 - time}, 3);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite6.f
  input Real[:] x;
  input Integer n;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  return;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite6.f;

end VariabilityPropagationPartialTests.PartiallyKnownComposite6;
")})));
    end PartiallyKnownComposite6;
    
    model PartiallyKnownComposite7
        record R
            Real a;
            Real b;
        end R;
        function f
            input R x;
            input Integer n;
            output R y;
          algorithm
            y := x;
        end f;
        R y = f(R(1,1-time), 3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite7",
            description="Test evaluation of known components in partially known composite arg. (record)",
            inline_functions="none",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite7
 constant Real y.a = 1;
 Real y.b;
equation
 (VariabilityPropagationPartialTests.PartiallyKnownComposite7.R(, y.b)) = VariabilityPropagationPartialTests.PartiallyKnownComposite7.f(VariabilityPropagationPartialTests.PartiallyKnownComposite7.R(1, 1 - time), 3);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite7.f
  input VariabilityPropagationPartialTests.PartiallyKnownComposite7.R x;
  input Integer n;
  output VariabilityPropagationPartialTests.PartiallyKnownComposite7.R y;
 algorithm
  y.a := x.a;
  y.b := x.b;
  return;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite7.f;

 record VariabilityPropagationPartialTests.PartiallyKnownComposite7.R
  Real a;
  Real b;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite7.R;

end VariabilityPropagationPartialTests.PartiallyKnownComposite7;
")})));
    end PartiallyKnownComposite7;
    
    model PartiallyKnownComposite8
        record R1
            R2 r2;
            Real y2;
        end R1;
        record R2
            Real[2] y1;
        end R2;
        function f
            input Real x1;
            input Real x2;
            output R1 r = R1(R2({x1,x1}),x2);
          algorithm
            annotation(Inline=false);
        end f;
        
        R1 r;
      equation
        r = f(1,time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="PartiallyKnownComposite8",
            description="Test cleanup of record/array outputs",
            inline_functions="none",
            eliminate_alias_constants=false,
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R1_1_r, tmp_1)
    JMI_RECORD_STATIC(R2_0_r, tmp_2)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
    tmp_2->y1 = tmp_3;
    tmp_1->r2 = tmp_2;
    func_VariabilityPropagationPartialTests_PartiallyKnownComposite8_f_def0(1.0, _time, tmp_1);
    _r_y2_2 = (tmp_1->y2);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
    end PartiallyKnownComposite8;
    
    model PartiallyKnownComposite9
        record R
            Real x,y,z;
        end R;
        function f1
            input Real x,y,z;
            output R r = R(x,y,z);
            algorithm
            annotation(Inline=false);
        end f1;
        function f2
            input R r;
            output Real x = r.x;
            output Real y = r.y;
            algorithm
            annotation(Inline=true);
        end f2;
        
        Real x,y;
    equation
        (x,y) = f2(f1(3,time,time));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite9",
            description="Test propagation to FNoExp in lhs",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite9
 constant Real x = 3;
 Real y;
equation
 (VariabilityPropagationPartialTests.PartiallyKnownComposite9.R(, y, )) = VariabilityPropagationPartialTests.PartiallyKnownComposite9.f1(3, time, time);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite9.f1
  input Real x;
  input Real y;
  input Real z;
  output VariabilityPropagationPartialTests.PartiallyKnownComposite9.R r;
 algorithm
  r.x := x;
  r.y := y;
  r.z := z;
  return;
 annotation(Inline = false);
 end VariabilityPropagationPartialTests.PartiallyKnownComposite9.f1;

 record VariabilityPropagationPartialTests.PartiallyKnownComposite9.R
  Real x;
  Real y;
  Real z;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite9.R;

end VariabilityPropagationPartialTests.PartiallyKnownComposite9;
")})));
    end PartiallyKnownComposite9;

    model PartiallyKnownComposite10
        record R
            Real x,y,z;
        end R;
        function f1
            input Real x;
            output Real[:,:] r = {{x,x},{x,x}};
            algorithm
            annotation(Inline=false);
        end f1;
        function f2
            input Real[:,:] r;
            output Real[:] y = r[1,:];
            algorithm
            annotation(Inline=true);
        end f2;
        
        Real[:] x = f2(f1(time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="PartiallyKnownComposite10",
            description="Test cleanup of record/array outputs",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 4, 2)
    JMI_ARRAY_INIT_2(STACK, jmi_real_t, jmi_array_t, tmp_1, 4, 2, 2, 2)
    func_VariabilityPropagationPartialTests_PartiallyKnownComposite10_f1_def0(_time, tmp_1);
    memcpy(&_x_1_0, &jmi_array_val_2(tmp_1, 1,1), 2 * sizeof(jmi_real_t));
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
    end PartiallyKnownComposite10;
    
    model PartiallyKnownComposite11
    record R
        Real x;
        Real[1] z;
    end R;
    
    function f
        input Real x;
        input Real y;
        output R r = R(x, {y});
        algorithm
        annotation(Inline=false);
    end f;
    
    R r;
  equation
    r = f(time, 3);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="PartiallyKnownComposite11",
            description="Test cleanup of record/array outputs",
            template="$C_ode_derivatives$",
            generatedCode="

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    tmp_1->z = tmp_2;
    func_VariabilityPropagationPartialTests_PartiallyKnownComposite11_f_def0(_time, 3.0, tmp_1);
    _r_x_0 = (tmp_1->x);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
    end PartiallyKnownComposite11;
    
    model PartiallyKnownComposite12
       function e
           input Real x;
           output Real y;
           external;
       end e;
           
       function f
           input Real x1,x2;
           output Real y1,y2;
       algorithm
           y2 := e(x2);
           y1 := x1;
           annotation(Inline=false);
       end f;
    
        Real y1,y2,y3;
    equation
        (y1,y2) = f(1,y3);
        y3 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownComposite12",
            description="Failing on second evaluation of constant function",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownComposite12
 constant Real y1 = 1;
 parameter Real y2;
 constant Real y3 = 3;
parameter equation
 (, y2) = VariabilityPropagationPartialTests.PartiallyKnownComposite12.f(1, 3.0);

public
 function VariabilityPropagationPartialTests.PartiallyKnownComposite12.f
  input Real x1;
  input Real x2;
  output Real y1;
  output Real y2;
 algorithm
  y2 := VariabilityPropagationPartialTests.PartiallyKnownComposite12.e(x2);
  y1 := x1;
  return;
 annotation(Inline = false);
 end VariabilityPropagationPartialTests.PartiallyKnownComposite12.f;

 function VariabilityPropagationPartialTests.PartiallyKnownComposite12.e
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = e(x);
  return;
 end VariabilityPropagationPartialTests.PartiallyKnownComposite12.e;

end VariabilityPropagationPartialTests.PartiallyKnownComposite12;
")})));
    end PartiallyKnownComposite12;

    model PartiallyKnownDiscrete1
       function f
           input Real x1,x2,x3;
           output Real y1,y2;
       algorithm
           y1 := x1;
           y2 := x2;
           annotation(Inline=false);
       end f;
    
        Real y1,y2,y4;
        Integer y3;
    equation
        (y1,y2) = f(1,y3,y4);
        when time > 1 then
            y4 = time;
        end when;
        y3 = 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyKnownDiscrete1",
            description="Partial evaluation of discrete function call",
            flatModel="
fclass VariabilityPropagationPartialTests.PartiallyKnownDiscrete1
 constant Real y1 = 1;
 constant Real y2 = 2;
 discrete Real y4;
 constant Integer y3 = 2;
 discrete Boolean temp_1;
initial equation
 pre(y4) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = time > 1;
 y4 = if temp_1 and not pre(temp_1) then time else pre(y4);
end VariabilityPropagationPartialTests.PartiallyKnownDiscrete1;
")})));
    end PartiallyKnownDiscrete1;


end VariabilityPropagationPartialTests;
