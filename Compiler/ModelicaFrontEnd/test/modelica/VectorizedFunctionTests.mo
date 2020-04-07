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

package VectorizedFunctionTests


package Basic


model VectorizedCall1
    function f
        input Real x;
        output Real y;
    algorithm
        y := 2 * x;
    end f;
    
    Real z[2] = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall1",
            description="Vectorization: basic test",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall1
 Real z[1];
 Real z[2];
equation
 z[1] = VectorizedFunctionTests.Basic.VectorizedCall1.f(1);
 z[2] = VectorizedFunctionTests.Basic.VectorizedCall1.f(2);

public
 function VectorizedFunctionTests.Basic.VectorizedCall1.f
  input Real x;
  output Real y;
 algorithm
  y := 2 * x;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall1.f;

end VectorizedFunctionTests.Basic.VectorizedCall1;
")})));
end VectorizedCall1;


model VectorizedCall2
    function f
        input Real x1;
        input Real x2;
        input Real x3 = 2;
        output Real y;
    algorithm
        y := 2 * x1 + x2 + x3;
    end f;
    
    Real z[2,2] = f({{1,2},{3,4}}, 5);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall2",
            description="Vectorization: one of two args vectorized",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall2
 Real z[1,1];
 Real z[1,2];
 Real z[2,1];
 Real z[2,2];
equation
 z[1,1] = VectorizedFunctionTests.Basic.VectorizedCall2.f(1, 5, 2);
 z[1,2] = VectorizedFunctionTests.Basic.VectorizedCall2.f(2, 5, 2);
 z[2,1] = VectorizedFunctionTests.Basic.VectorizedCall2.f(3, 5, 2);
 z[2,2] = VectorizedFunctionTests.Basic.VectorizedCall2.f(4, 5, 2);

public
 function VectorizedFunctionTests.Basic.VectorizedCall2.f
  input Real x1;
  input Real x2;
  input Real x3;
  output Real y;
 algorithm
  y := 2 * x1 + x2 + x3;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall2.f;

end VectorizedFunctionTests.Basic.VectorizedCall2;
")})));
end VectorizedCall2;


model VectorizedCall3
    function f
        input Real[:,:] x1;
        input Real[:,:] x2;
        output Real y;
    algorithm
        y := sum(x1 * x2);
    end f;
    
    constant Real v[3,3] = -1 * [1,2,3;4,5,6;7,8,9];
    constant Real w[3,3] = [1,2,3;4,5,6;7,8,9];
    Real z[2,2] = f({{w, 2*w},{3*w, 4*w}}, {{v, 2*v},{3*v, 4*v}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall3",
            description="Vectorization: vectorised array arg, constant",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall3
 constant Real v[1,1] = -1;
 constant Real v[1,2] = -2;
 constant Real v[1,3] = -3;
 constant Real v[2,1] = -4;
 constant Real v[2,2] = -5;
 constant Real v[2,3] = -6;
 constant Real v[3,1] = -7;
 constant Real v[3,2] = -8;
 constant Real v[3,3] = -9;
 constant Real w[1,1] = 1;
 constant Real w[1,2] = 2;
 constant Real w[1,3] = 3;
 constant Real w[2,1] = 4;
 constant Real w[2,2] = 5;
 constant Real w[2,3] = 6;
 constant Real w[3,1] = 7;
 constant Real w[3,2] = 8;
 constant Real w[3,3] = 9;
 Real z[1,1];
 Real z[1,2];
 Real z[2,1];
 Real z[2,2];
equation
 z[1,1] = VectorizedFunctionTests.Basic.VectorizedCall3.f({{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}, {7.0, 8.0, 9.0}}, {{-1.0, -2.0, -3.0}, {-4.0, -5.0, -6.0}, {-7.0, -8.0, -9.0}});
 z[1,2] = VectorizedFunctionTests.Basic.VectorizedCall3.f({{2, 2 * 2.0, 2 * 3.0}, {2 * 4.0, 2 * 5.0, 2 * 6.0}, {2 * 7.0, 2 * 8.0, 2 * 9.0}}, {{-2, 2 * -2.0, 2 * -3.0}, {2 * -4.0, 2 * -5.0, 2 * -6.0}, {2 * -7.0, 2 * -8.0, 2 * -9.0}});
 z[2,1] = VectorizedFunctionTests.Basic.VectorizedCall3.f({{3, 3 * 2.0, 3 * 3.0}, {3 * 4.0, 3 * 5.0, 3 * 6.0}, {3 * 7.0, 3 * 8.0, 3 * 9.0}}, {{-3, 3 * -2.0, 3 * -3.0}, {3 * -4.0, 3 * -5.0, 3 * -6.0}, {3 * -7.0, 3 * -8.0, 3 * -9.0}});
 z[2,2] = VectorizedFunctionTests.Basic.VectorizedCall3.f({{4, 4 * 2.0, 4 * 3.0}, {4 * 4.0, 4 * 5.0, 4 * 6.0}, {4 * 7.0, 4 * 8.0, 4 * 9.0}}, {{-4, 4 * -2.0, 4 * -3.0}, {4 * -4.0, 4 * -5.0, 4 * -6.0}, {4 * -7.0, 4 * -8.0, 4 * -9.0}});

public
 function VectorizedFunctionTests.Basic.VectorizedCall3.f
  input Real[:,:] x1;
  input Real[:,:] x2;
  output Real y;
  Real temp_1;
  Real[:,:] temp_2;
  Real temp_3;
 algorithm
  init temp_2 as Real[size(x1, 1), size(x2, 2)];
  for i3 in 1:size(x1, 1) loop
   for i4 in 1:size(x2, 2) loop
    temp_3 := 0.0;
    for i5 in 1:size(x2, 1) loop
     temp_3 := temp_3 + x1[i3,i5] * x2[i5,i4];
    end for;
    temp_2[i3,i4] := temp_3;
   end for;
  end for;
  temp_1 := 0.0;
  for i1 in 1:size(x1, 1) loop
   for i2 in 1:size(x2, 2) loop
    temp_1 := temp_1 + temp_2[i1,i2];
   end for;
  end for;
  y := temp_1;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall3.f;

end VectorizedFunctionTests.Basic.VectorizedCall3;
")})));
end VectorizedCall3;


model VectorizedCall4
    function f
        input Real[:,:] x1;
        input Real[:,:] x2;
        output Real y;
    algorithm
        y := sum(x1 * x2);
    end f;
    
    Real v[3,3] = -1 * [1,2,3;4,5,6;7,8,9];
    Real w[3,3] = [1,2,3;4,5,6;7,8,9];
    Real v2[2,2,3,3] = {{v, 2*v},{3*v, 4*v}};
    Real w2[2,2,3,3] = {{w, 2*w},{3*w, 4*w}};
    Real z[2,2] = f(w2, v2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall4",
            description="Vectorization: vectorised array arg, continous",
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall4
 Real v2[1,1,1,1];
 Real v2[1,1,1,2];
 Real v2[1,1,1,3];
 Real v2[1,1,2,1];
 Real v2[1,1,2,2];
 Real v2[1,1,2,3];
 Real v2[1,1,3,1];
 Real v2[1,1,3,2];
 Real v2[1,1,3,3];
 Real v2[1,2,1,1];
 Real v2[1,2,1,2];
 Real v2[1,2,1,3];
 Real v2[1,2,2,1];
 Real v2[1,2,2,2];
 Real v2[1,2,2,3];
 Real v2[1,2,3,1];
 Real v2[1,2,3,2];
 Real v2[1,2,3,3];
 Real v2[2,1,1,1];
 Real v2[2,1,1,2];
 Real v2[2,1,1,3];
 Real v2[2,1,2,1];
 Real v2[2,1,2,2];
 Real v2[2,1,2,3];
 Real v2[2,1,3,1];
 Real v2[2,1,3,2];
 Real v2[2,1,3,3];
 Real v2[2,2,1,1];
 Real v2[2,2,1,2];
 Real v2[2,2,1,3];
 Real v2[2,2,2,1];
 Real v2[2,2,2,2];
 Real v2[2,2,2,3];
 Real v2[2,2,3,1];
 Real v2[2,2,3,2];
 Real v2[2,2,3,3];
 Real w2[1,1,1,1];
 Real w2[1,1,1,2];
 Real w2[1,1,1,3];
 Real w2[1,1,2,1];
 Real w2[1,1,2,2];
 Real w2[1,1,2,3];
 Real w2[1,1,3,1];
 Real w2[1,1,3,2];
 Real w2[1,1,3,3];
 Real w2[1,2,1,1];
 Real w2[1,2,1,2];
 Real w2[1,2,1,3];
 Real w2[1,2,2,1];
 Real w2[1,2,2,2];
 Real w2[1,2,2,3];
 Real w2[1,2,3,1];
 Real w2[1,2,3,2];
 Real w2[1,2,3,3];
 Real w2[2,1,1,1];
 Real w2[2,1,1,2];
 Real w2[2,1,1,3];
 Real w2[2,1,2,1];
 Real w2[2,1,2,2];
 Real w2[2,1,2,3];
 Real w2[2,1,3,1];
 Real w2[2,1,3,2];
 Real w2[2,1,3,3];
 Real w2[2,2,1,1];
 Real w2[2,2,1,2];
 Real w2[2,2,1,3];
 Real w2[2,2,2,1];
 Real w2[2,2,2,2];
 Real w2[2,2,2,3];
 Real w2[2,2,3,1];
 Real w2[2,2,3,2];
 Real w2[2,2,3,3];
 Real z[1,1];
 Real z[1,2];
 Real z[2,1];
 Real z[2,2];
equation
 v2[1,1,1,1] = -1;
 v2[1,1,1,2] = -2;
 v2[1,1,1,3] = -3;
 v2[1,1,2,1] = -4;
 v2[1,1,2,2] = -5;
 v2[1,1,2,3] = -6;
 v2[1,1,3,1] = -7;
 v2[1,1,3,2] = -8;
 v2[1,1,3,3] = -9;
 w2[1,1,1,1] = 1;
 w2[1,1,1,2] = 2;
 w2[1,1,1,3] = 3;
 w2[1,1,2,1] = 4;
 w2[1,1,2,2] = 5;
 w2[1,1,2,3] = 6;
 w2[1,1,3,1] = 7;
 w2[1,1,3,2] = 8;
 w2[1,1,3,3] = 9;
 v2[1,2,1,1] = 2 * v2[1,1,1,1];
 v2[1,2,1,2] = 2 * v2[1,1,1,2];
 v2[1,2,1,3] = 2 * v2[1,1,1,3];
 v2[1,2,2,1] = 2 * v2[1,1,2,1];
 v2[1,2,2,2] = 2 * v2[1,1,2,2];
 v2[1,2,2,3] = 2 * v2[1,1,2,3];
 v2[1,2,3,1] = 2 * v2[1,1,3,1];
 v2[1,2,3,2] = 2 * v2[1,1,3,2];
 v2[1,2,3,3] = 2 * v2[1,1,3,3];
 v2[2,1,1,1] = 3 * v2[1,1,1,1];
 v2[2,1,1,2] = 3 * v2[1,1,1,2];
 v2[2,1,1,3] = 3 * v2[1,1,1,3];
 v2[2,1,2,1] = 3 * v2[1,1,2,1];
 v2[2,1,2,2] = 3 * v2[1,1,2,2];
 v2[2,1,2,3] = 3 * v2[1,1,2,3];
 v2[2,1,3,1] = 3 * v2[1,1,3,1];
 v2[2,1,3,2] = 3 * v2[1,1,3,2];
 v2[2,1,3,3] = 3 * v2[1,1,3,3];
 v2[2,2,1,1] = 4 * v2[1,1,1,1];
 v2[2,2,1,2] = 4 * v2[1,1,1,2];
 v2[2,2,1,3] = 4 * v2[1,1,1,3];
 v2[2,2,2,1] = 4 * v2[1,1,2,1];
 v2[2,2,2,2] = 4 * v2[1,1,2,2];
 v2[2,2,2,3] = 4 * v2[1,1,2,3];
 v2[2,2,3,1] = 4 * v2[1,1,3,1];
 v2[2,2,3,2] = 4 * v2[1,1,3,2];
 v2[2,2,3,3] = 4 * v2[1,1,3,3];
 w2[1,2,1,1] = 2 * w2[1,1,1,1];
 w2[1,2,1,2] = 2 * w2[1,1,1,2];
 w2[1,2,1,3] = 2 * w2[1,1,1,3];
 w2[1,2,2,1] = 2 * w2[1,1,2,1];
 w2[1,2,2,2] = 2 * w2[1,1,2,2];
 w2[1,2,2,3] = 2 * w2[1,1,2,3];
 w2[1,2,3,1] = 2 * w2[1,1,3,1];
 w2[1,2,3,2] = 2 * w2[1,1,3,2];
 w2[1,2,3,3] = 2 * w2[1,1,3,3];
 w2[2,1,1,1] = 3 * w2[1,1,1,1];
 w2[2,1,1,2] = 3 * w2[1,1,1,2];
 w2[2,1,1,3] = 3 * w2[1,1,1,3];
 w2[2,1,2,1] = 3 * w2[1,1,2,1];
 w2[2,1,2,2] = 3 * w2[1,1,2,2];
 w2[2,1,2,3] = 3 * w2[1,1,2,3];
 w2[2,1,3,1] = 3 * w2[1,1,3,1];
 w2[2,1,3,2] = 3 * w2[1,1,3,2];
 w2[2,1,3,3] = 3 * w2[1,1,3,3];
 w2[2,2,1,1] = 4 * w2[1,1,1,1];
 w2[2,2,1,2] = 4 * w2[1,1,1,2];
 w2[2,2,1,3] = 4 * w2[1,1,1,3];
 w2[2,2,2,1] = 4 * w2[1,1,2,1];
 w2[2,2,2,2] = 4 * w2[1,1,2,2];
 w2[2,2,2,3] = 4 * w2[1,1,2,3];
 w2[2,2,3,1] = 4 * w2[1,1,3,1];
 w2[2,2,3,2] = 4 * w2[1,1,3,2];
 w2[2,2,3,3] = 4 * w2[1,1,3,3];
 z[1,1] = VectorizedFunctionTests.Basic.VectorizedCall4.f({{w2[1,1,1,1], w2[1,1,1,2], w2[1,1,1,3]}, {w2[1,1,2,1], w2[1,1,2,2], w2[1,1,2,3]}, {w2[1,1,3,1], w2[1,1,3,2], w2[1,1,3,3]}}, {{v2[1,1,1,1], v2[1,1,1,2], v2[1,1,1,3]}, {v2[1,1,2,1], v2[1,1,2,2], v2[1,1,2,3]}, {v2[1,1,3,1], v2[1,1,3,2], v2[1,1,3,3]}});
 z[1,2] = VectorizedFunctionTests.Basic.VectorizedCall4.f({{w2[1,2,1,1], w2[1,2,1,2], w2[1,2,1,3]}, {w2[1,2,2,1], w2[1,2,2,2], w2[1,2,2,3]}, {w2[1,2,3,1], w2[1,2,3,2], w2[1,2,3,3]}}, {{v2[1,2,1,1], v2[1,2,1,2], v2[1,2,1,3]}, {v2[1,2,2,1], v2[1,2,2,2], v2[1,2,2,3]}, {v2[1,2,3,1], v2[1,2,3,2], v2[1,2,3,3]}});
 z[2,1] = VectorizedFunctionTests.Basic.VectorizedCall4.f({{w2[2,1,1,1], w2[2,1,1,2], w2[2,1,1,3]}, {w2[2,1,2,1], w2[2,1,2,2], w2[2,1,2,3]}, {w2[2,1,3,1], w2[2,1,3,2], w2[2,1,3,3]}}, {{v2[2,1,1,1], v2[2,1,1,2], v2[2,1,1,3]}, {v2[2,1,2,1], v2[2,1,2,2], v2[2,1,2,3]}, {v2[2,1,3,1], v2[2,1,3,2], v2[2,1,3,3]}});
 z[2,2] = VectorizedFunctionTests.Basic.VectorizedCall4.f({{w2[2,2,1,1], w2[2,2,1,2], w2[2,2,1,3]}, {w2[2,2,2,1], w2[2,2,2,2], w2[2,2,2,3]}, {w2[2,2,3,1], w2[2,2,3,2], w2[2,2,3,3]}}, {{v2[2,2,1,1], v2[2,2,1,2], v2[2,2,1,3]}, {v2[2,2,2,1], v2[2,2,2,2], v2[2,2,2,3]}, {v2[2,2,3,1], v2[2,2,3,2], v2[2,2,3,3]}});

public
 function VectorizedFunctionTests.Basic.VectorizedCall4.f
  input Real[:,:] x1;
  input Real[:,:] x2;
  output Real y;
  Real temp_1;
  Real[:,:] temp_2;
  Real temp_3;
 algorithm
  init temp_2 as Real[size(x1, 1), size(x2, 2)];
  for i3 in 1:size(x1, 1) loop
   for i4 in 1:size(x2, 2) loop
    temp_3 := 0.0;
    for i5 in 1:size(x2, 1) loop
     temp_3 := temp_3 + x1[i3,i5] * x2[i5,i4];
    end for;
    temp_2[i3,i4] := temp_3;
   end for;
  end for;
  temp_1 := 0.0;
  for i1 in 1:size(x1, 1) loop
   for i2 in 1:size(x2, 2) loop
    temp_1 := temp_1 + temp_2[i1,i2];
   end for;
  end for;
  y := temp_1;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall4.f;

end VectorizedFunctionTests.Basic.VectorizedCall4;
")})));
end VectorizedCall4;


model VectorizedCall5
    record R
        Real a;
        Real b;
    end R;
    
    function f
        input R x;
        output Real y;
    algorithm
        y := 2 * x.a + x.b;
    end f;
    
    R[2] w = {R(1,2), R(3,4)};
    Real z[2] = f(w);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall5",
            description="Vectorization: vectorised record arg",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall5
 Real w[1].a;
 Real w[1].b;
 Real w[2].a;
 Real w[2].b;
 Real z[1];
 Real z[2];
equation
 w[1].a = 1;
 w[1].b = 2;
 w[2].a = 3;
 w[2].b = 4;
 z[1] = VectorizedFunctionTests.Basic.VectorizedCall5.f(VectorizedFunctionTests.Basic.VectorizedCall5.R(w[1].a, w[1].b));
 z[2] = VectorizedFunctionTests.Basic.VectorizedCall5.f(VectorizedFunctionTests.Basic.VectorizedCall5.R(w[2].a, w[2].b));

public
 function VectorizedFunctionTests.Basic.VectorizedCall5.f
  input VectorizedFunctionTests.Basic.VectorizedCall5.R x;
  output Real y;
 algorithm
  y := 2 * x.a + x.b;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall5.f;

 record VectorizedFunctionTests.Basic.VectorizedCall5.R
  Real a;
  Real b;
 end VectorizedFunctionTests.Basic.VectorizedCall5.R;

end VectorizedFunctionTests.Basic.VectorizedCall5;
")})));
end VectorizedCall5;


model VectorizedCall6
    record R
        Real a;
        Real b;
    end R;
    
    function f
        input Real x;
        output R y;
    algorithm
        y := R(x, 2*x);
    end f;
    
    Real w[2] = {1, 2};
    R z[2] = f(w);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall6",
            description="Vectorization: record return value",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall6
 Real w[1];
 Real w[2];
 Real z[1].a;
 Real z[1].b;
 Real z[2].a;
 Real z[2].b;
equation
 w[1] = 1;
 w[2] = 2;
 (VectorizedFunctionTests.Basic.VectorizedCall6.R(z[1].a, z[1].b)) = VectorizedFunctionTests.Basic.VectorizedCall6.f(w[1]);
 (VectorizedFunctionTests.Basic.VectorizedCall6.R(z[2].a, z[2].b)) = VectorizedFunctionTests.Basic.VectorizedCall6.f(w[2]);

public
 function VectorizedFunctionTests.Basic.VectorizedCall6.f
  input Real x;
  output VectorizedFunctionTests.Basic.VectorizedCall6.R y;
 algorithm
  y.a := x;
  y.b := 2 * x;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall6.f;

 record VectorizedFunctionTests.Basic.VectorizedCall6.R
  Real a;
  Real b;
 end VectorizedFunctionTests.Basic.VectorizedCall6.R;

end VectorizedFunctionTests.Basic.VectorizedCall6;
")})));
end VectorizedCall6;


model VectorizedCall7
    function f
        input Real a;
        input Real b[2];
        output Real c;
    algorithm
        c := sum(a * b);
    end f;
    
    Real d[3] = {1, 2, 3} * time;
    Real e[3] = f(d, {4, 5});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall7",
            description="",
            eliminate_linear_equations=false,
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall7
 Real d[1];
 Real d[2];
 Real d[3];
 Real e[1];
 Real e[2];
 Real e[3];
equation
 d[1] = time;
 d[2] = 2 * time;
 d[3] = 3 * time;
 e[1] = VectorizedFunctionTests.Basic.VectorizedCall7.f(d[1], {4, 5});
 e[2] = VectorizedFunctionTests.Basic.VectorizedCall7.f(d[2], {4, 5});
 e[3] = VectorizedFunctionTests.Basic.VectorizedCall7.f(d[3], {4, 5});

public
 function VectorizedFunctionTests.Basic.VectorizedCall7.f
  input Real a;
  input Real[:] b;
  output Real c;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:2 loop
   temp_1 := temp_1 + a * b[i1];
  end for;
  c := temp_1;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall7.f;

end VectorizedFunctionTests.Basic.VectorizedCall7;
")})));
end VectorizedCall7;

model VectorizedCall8
function fv
    input Real x;
    output Real y;
    algorithm
end fv;
function f
    input Real[1] x;
    output Real[1] y= fv(x);
algorithm
    annotation(Inline=false);
end f;

Real[:] y = f({time});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall8",
            description="",
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall8
 Real y[1];
equation
 ({y[1]}) = VectorizedFunctionTests.Basic.VectorizedCall8.f({time});

public
 function VectorizedFunctionTests.Basic.VectorizedCall8.f
  input Real[:] x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[1];
  init temp_1 as Real[1];
  for i1 in 1:1 loop
   temp_1[i1] := VectorizedFunctionTests.Basic.VectorizedCall8.fv(x[i1]);
  end for;
  for i1 in 1:1 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 annotation(Inline = false);
 end VectorizedFunctionTests.Basic.VectorizedCall8.f;

 function VectorizedFunctionTests.Basic.VectorizedCall8.fv
  input Real x;
  output Real y;
 algorithm
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall8.fv;

end VectorizedFunctionTests.Basic.VectorizedCall8;
")})));
end VectorizedCall8;

model VectorizedCall9
    function f
        input Real[:] x1;
        input Real x2;
        output Real y = sum(x1) + x2;
    algorithm
    end f; 
    function g
        input Real[:] x1;
        output Real[:] y = f(x1, x1);
    algorithm
    end g;
   
   Real[:] y = g({1,2});
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VectorizedCall9",
            description="Unknown size vectorization of function call with regular call as intermediate.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.Basic.VectorizedCall9
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = VectorizedFunctionTests.Basic.VectorizedCall9.g({1, 2});

public
 function VectorizedFunctionTests.Basic.VectorizedCall9.g
  input Real[:] x1;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[size(x1, 1)];
  init temp_1 as Real[size(x1, 1)];
  for i1 in 1:size(x1, 1) loop
   temp_1[i1] := VectorizedFunctionTests.Basic.VectorizedCall9.f(x1, x1[i1]);
  end for;
  for i1 in 1:size(x1, 1) loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall9.g;

 function VectorizedFunctionTests.Basic.VectorizedCall9.f
  input Real[:] x1;
  input Real x2;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(x1, 1) loop
   temp_1 := temp_1 + x1[i1];
  end for;
  y := temp_1 + x2;
  return;
 end VectorizedFunctionTests.Basic.VectorizedCall9.f;

end VectorizedFunctionTests.Basic.VectorizedCall9;
")})));
end VectorizedCall9;


end Basic;


package DifferentDimensionedParamerers


    function v
        input Integer i;
        input Integer j[:];
        output Real o = i;
    algorithm
    end v;
    
model DifferingUnknownParameters1
    function f
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := v(d, ones(d, d));
        y := 1;
    end f;
    
    Real x = f(2);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DifferingUnknownParameters1",
            description="Unknown size vectorization of function calls for scalar & matrix inputs.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters1
 Real x;
equation
 x = VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters1.f(2);

public
 function VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters1.f
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:,:] temp_2;
  Integer[:] temp_3;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d, d];
  for i2 in 1:d loop
   for i3 in 1:d loop
    temp_2[i2,i3] := 1;
   end for;
  end for;
  for i1 in 1:d loop
   init temp_3 as Integer[d];
   for i2 in 1:d loop
    temp_3[i2] := temp_2[i1,i2];
   end for;
   temp_1[i1] := VectorizedFunctionTests.DifferentDimensionedParamerers.v(d, temp_3);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters1.f;

 function VectorizedFunctionTests.DifferentDimensionedParamerers.v
  input Integer i;
  input Integer[:] j;
  output Real o;
 algorithm
  o := i;
  return;
 end VectorizedFunctionTests.DifferentDimensionedParamerers.v;

end VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters1;
")})));
end DifferingUnknownParameters1;

model DifferingUnknownParameters2
    function f
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := v(ones(d), ones(d, d));
        y := 1;
    end f;
    
    Real x = f(2);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DifferingUnknownParameters2",
            description="Unknown size vectorization of function calls for array & matrix inputs.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters2
 Real x;
equation
 x = VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters2.f(2);

public
 function VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters2.f
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:] temp_2;
  Integer[:,:] temp_3;
  Integer[:] temp_4;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d];
  for i2 in 1:d loop
   temp_2[i2] := 1;
  end for;
  init temp_3 as Integer[d, d];
  for i2 in 1:d loop
   for i3 in 1:d loop
    temp_3[i2,i3] := 1;
   end for;
  end for;
  for i1 in 1:d loop
   init temp_4 as Integer[d];
   for i2 in 1:d loop
    temp_4[i2] := temp_3[i1,i2];
   end for;
   temp_1[i1] := VectorizedFunctionTests.DifferentDimensionedParamerers.v(temp_2[i1], temp_4);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters2.f;

 function VectorizedFunctionTests.DifferentDimensionedParamerers.v
  input Integer i;
  input Integer[:] j;
  output Real o;
 algorithm
  o := i;
  return;
 end VectorizedFunctionTests.DifferentDimensionedParamerers.v;

end VectorizedFunctionTests.DifferentDimensionedParamerers.DifferingUnknownParameters2;
")})));
end DifferingUnknownParameters2;


end DifferentDimensionedParamerers;


package Nested
    function f
        input Real i[:];
        Real a[1];
        output Real[size(i, 1)] y;
    algorithm
        a[1] := i[1];
        y := ones(size(i, 1));
    end f;

    function g
        input Real i;
        Real a;
        output Real o;
    algorithm
        a := i;
        o := 1;
    end g;

model NestedVectorizedCalls1
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := f(g(ones(d)));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls1",
            description="Unknown size vectorization of function call as parameter to regular function call.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.Nested.NestedVectorizedCalls1
 Real x;
equation
 x = VectorizedFunctionTests.Nested.NestedVectorizedCalls1.z(2);

public
 function VectorizedFunctionTests.Nested.NestedVectorizedCalls1.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d];
  for i2 in 1:d loop
   temp_2[i2] := 1;
  end for;
  for i1 in 1:d loop
   temp_1[i1] := VectorizedFunctionTests.Nested.g(temp_2[i1]);
  end for;
  (a) := VectorizedFunctionTests.Nested.f(temp_1);
  y := 1;
  return;
 end VectorizedFunctionTests.Nested.NestedVectorizedCalls1.z;

 function VectorizedFunctionTests.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end VectorizedFunctionTests.Nested.f;

 function VectorizedFunctionTests.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end VectorizedFunctionTests.Nested.g;

end VectorizedFunctionTests.Nested.NestedVectorizedCalls1;
")})));
end NestedVectorizedCalls1;

model NestedVectorizedCalls2
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := g(f(ones(d)));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls2",
            description="Unknown size vectorization of function call with regular call as input.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.Nested.NestedVectorizedCalls2
 Real x;
equation
 x = VectorizedFunctionTests.Nested.NestedVectorizedCalls2.z(2);

public
 function VectorizedFunctionTests.Nested.NestedVectorizedCalls2.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:] temp_2;
  Real[:] temp_3;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d];
  for i2 in 1:d loop
   temp_2[i2] := 1;
  end for;
  init temp_3 as Real[d];
  (temp_3) := VectorizedFunctionTests.Nested.f(temp_2);
  for i1 in 1:d loop
   temp_1[i1] := VectorizedFunctionTests.Nested.g(temp_3[i1]);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end VectorizedFunctionTests.Nested.NestedVectorizedCalls2.z;

 function VectorizedFunctionTests.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end VectorizedFunctionTests.Nested.g;

 function VectorizedFunctionTests.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end VectorizedFunctionTests.Nested.f;

end VectorizedFunctionTests.Nested.NestedVectorizedCalls2;
")})));
end NestedVectorizedCalls2;

model NestedVectorizedCalls3
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := f(g(f(ones(d))));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls3",
            description="Unknown size vectorization of function call as intermediate to two function calls.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.Nested.NestedVectorizedCalls3
 Real x;
equation
 x = VectorizedFunctionTests.Nested.NestedVectorizedCalls3.z(2);

public
 function VectorizedFunctionTests.Nested.NestedVectorizedCalls3.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:] temp_2;
  Real[:] temp_3;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d];
  for i2 in 1:d loop
   temp_2[i2] := 1;
  end for;
  init temp_3 as Real[d];
  (temp_3) := VectorizedFunctionTests.Nested.f(temp_2);
  for i1 in 1:d loop
   temp_1[i1] := VectorizedFunctionTests.Nested.g(temp_3[i1]);
  end for;
  (a) := VectorizedFunctionTests.Nested.f(temp_1);
  y := 1;
  return;
 end VectorizedFunctionTests.Nested.NestedVectorizedCalls3.z;

 function VectorizedFunctionTests.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end VectorizedFunctionTests.Nested.f;

 function VectorizedFunctionTests.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end VectorizedFunctionTests.Nested.g;

end VectorizedFunctionTests.Nested.NestedVectorizedCalls3;
")})));
end NestedVectorizedCalls3;

model NestedVectorizedCalls4
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := g(f(g(ones(d))));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls4",
            description="Unknown size vectorization of function call with regular call as intermediate.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.Nested.NestedVectorizedCalls4
 Real x;
equation
 x = VectorizedFunctionTests.Nested.NestedVectorizedCalls4.z(2);

public
 function VectorizedFunctionTests.Nested.NestedVectorizedCalls4.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Real[:] temp_2;
  Integer[:] temp_3;
  Real[:] temp_4;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Real[d];
  init temp_3 as Integer[d];
  for i3 in 1:d loop
   temp_3[i3] := 1;
  end for;
  for i2 in 1:d loop
   temp_2[i2] := VectorizedFunctionTests.Nested.g(temp_3[i2]);
  end for;
  init temp_4 as Real[d];
  (temp_4) := VectorizedFunctionTests.Nested.f(temp_2);
  for i1 in 1:d loop
   temp_1[i1] := VectorizedFunctionTests.Nested.g(temp_4[i1]);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end VectorizedFunctionTests.Nested.NestedVectorizedCalls4.z;

 function VectorizedFunctionTests.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end VectorizedFunctionTests.Nested.g;

 function VectorizedFunctionTests.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end VectorizedFunctionTests.Nested.f;

end VectorizedFunctionTests.Nested.NestedVectorizedCalls4;
")})));
end NestedVectorizedCalls4;


end Nested;


package PredefinedFunctions


model Abs
    constant Real[2,2] c = {{-1, 2}, {3, -4}};
    constant Real[2,2] d = abs(c);
    Real[2,2] x = c;
    Real[2,2] y = d;
    Real[2,2] z = abs(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_NumericConversion_Abs",
            description="Test of vectorized abs()",
            eliminate_alias_variables=false,
            flatModel="
fclass VectorizedFunctionTests.PredefinedFunctions.Abs
 constant Real c[1,1] = -1;
 constant Real c[1,2] = 2;
 constant Real c[2,1] = 3;
 constant Real c[2,2] = -4;
 constant Real d[1,1] = 1.0;
 constant Real d[1,2] = 2.0;
 constant Real d[2,1] = 3.0;
 constant Real d[2,2] = 4.0;
 constant Real x[1,1] = -1.0;
 constant Real x[1,2] = 2.0;
 constant Real x[2,1] = 3.0;
 constant Real x[2,2] = -4.0;
 constant Real y[1,1] = 1.0;
 constant Real y[1,2] = 2.0;
 constant Real y[2,1] = 3.0;
 constant Real y[2,2] = 4.0;
 constant Real z[1,1] = 1.0;
 constant Real z[1,2] = 2.0;
 constant Real z[2,1] = 3.0;
 constant Real z[2,2] = 4.0;
end VectorizedFunctionTests.PredefinedFunctions.Abs;
")})));
end Abs;

model Delay
    Real[2] y1;
    Real[2] y2;
    Real[2] x;
  equation
    y1 = delay(x,{1,2},2);
    y2 = delay(x,{1,2});
    x = {time,time};
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Delay1",
            description="Test scalarizing of vectorized delay",
            flatModel="
fclass VectorizedFunctionTests.PredefinedFunctions.Delay
 Real y1[1];
 Real y1[2];
 Real y2[1];
 Real y2[2];
 Real x[2];
equation
 y1[1] = delay(x[2], 1, 2);
 y1[2] = delay(x[2], 2, 2);
 y2[1] = delay(x[2], 1);
 y2[2] = delay(x[2], 2);
 x[2] = time;
end VectorizedFunctionTests.PredefinedFunctions.Delay;
")})));
end Delay;

model SemiLinear1
    Real s[2] = {1,2};
    Real x[2] = {time,time};
    Real y[2];
equation
    y = semiLinear(x,s,s);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_SemiLinear1",
            description="Test of the semiLinear() operator. Vectorization.",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.PredefinedFunctions.SemiLinear1
 Real s[1];
 Real s[2];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 y[1] = noEvent(x[2] * s[1]);
 y[2] = noEvent(x[2] * s[2]);
 s[1] = 1;
 s[2] = 2;
 x[2] = time;
end VectorizedFunctionTests.PredefinedFunctions.SemiLinear1;
")})));
end SemiLinear1;

model SemiLinear2
    Real s[2] = {1,2};
    Real x[2] = {time,time};
    Real x2 = time;
    Real y[2,2];
equation
    y[1,:] = semiLinear(x,s[2],s);
    y[2,:] = semiLinear(x2,s,s[1]);
equation

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_SemiLinear2",
            description="Test of the semiLinear() operator. Vectorization.",
            variability_propagation=false,
            flatModel="
fclass VectorizedFunctionTests.PredefinedFunctions.SemiLinear2
 Real s[1];
 Real s[2];
 Real x[2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 y[1,1] = noEvent(if x[2] >= 0 then x[2] * s[2] else x[2] * s[1]);
 y[1,2] = noEvent(x[2] * s[2]);
 y[2,1] = noEvent(x[2] * s[1]);
 y[2,2] = noEvent(if x[2] >= 0 then x[2] * s[2] else x[2] * s[1]);
 s[1] = 1;
 s[2] = 2;
 x[2] = time;
end VectorizedFunctionTests.PredefinedFunctions.SemiLinear2;
")})));
end SemiLinear2;

model SemiLinear3
    Real s[1] = {1};
    Real x[2] = {time,time};
    Real y[2];
equation
    y = semiLinear(x,s,s);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_SemiLinear3",
            description="Test of the semiLinear() operator. Vectorization.",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/VectorizedFunctionTests.mo':
  Mismatching sizes in semiLinear. All non-scalar arguments need matching sizes
")})));
end SemiLinear3;

model Sign
    constant Real[2,2] c = {{-1, 2}, {3, -4}};
    constant Real[2,2] d = sign(c);
    Real[2,2] x = c;
    Real[2,2] y = d;
    Real[2,2] z = sign(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_NumericConversion_Sign2",
            description="Test of vectorized sign()",
            eliminate_alias_variables=false,
            flatModel="
fclass VectorizedFunctionTests.PredefinedFunctions.Sign
 constant Real c[1,1] = -1;
 constant Real c[1,2] = 2;
 constant Real c[2,1] = 3;
 constant Real c[2,2] = -4;
 constant Real d[1,1] = -1;
 constant Real d[1,2] = 1;
 constant Real d[2,1] = 1;
 constant Real d[2,2] = -1;
 constant Real x[1,1] = -1.0;
 constant Real x[1,2] = 2.0;
 constant Real x[2,1] = 3.0;
 constant Real x[2,2] = -4.0;
 constant Real y[1,1] = -1.0;
 constant Real y[1,2] = 1.0;
 constant Real y[2,1] = 1.0;
 constant Real y[2,2] = -1.0;
 constant Real z[1,1] = -1;
 constant Real z[1,2] = 1;
 constant Real z[2,1] = 1;
 constant Real z[2,2] = -1;
end VectorizedFunctionTests.PredefinedFunctions.Sign;
")})));
end Sign;

model SpatialDistribution
    Real[2] y;
    Real[2] x;
  equation
    y = spatialDistribution(x,{1,2},1,true,{{0,0.5,1.0}, {0,0.6,1.0}}, {1,2,3});
    x = {time,time};
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SpatialDistribution",
            description="Test scalarizing of vectorized delay",
            flatModel="
fclass VectorizedFunctionTests.PredefinedFunctions.SpatialDistribution
 Real y[1];
 Real y[2];
 Real x[2];
 Real _eventIndicator_1;
 Real _eventIndicator_2;
equation
 y[1] = spatialDistribution(x[2], 1, 1, true, {0, 0.5, 1.0}, {1, 2, 3});
 y[2] = spatialDistribution(x[2], 2, 1, true, {0, 0.6, 1.0}, {1, 2, 3});
 x[2] = time;
 _eventIndicator_1 = spatialDistIndicator(x[2], 1, 1, true, {0, 0.5, 1.0}, {1, 2, 3});
 _eventIndicator_2 = spatialDistIndicator(x[2], 2, 1, true, {0, 0.6, 1.0}, {1, 2, 3});
end VectorizedFunctionTests.PredefinedFunctions.SpatialDistribution;
")})));
end SpatialDistribution;


end PredefinedFunctions;


end VectorizedFunctionTests;