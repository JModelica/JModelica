/*
    Copyright (C) 2009-2019 Modelon AB

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


package ScalarizeFunctionVectorTests 

model Vector1
    function f
        input Real x;
        output Real[1] y = vector(x);
    algorithm
        annotation(Inline=false);
    end f;
    
    Real[1] y = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Vector1",
            description="",
            flatModel="
fclass ScalarizeFunctionVectorTests.Vector1
 Real y[1];
equation
 ({y[1]}) = ScalarizeFunctionVectorTests.Vector1.f(time);

public
 function ScalarizeFunctionVectorTests.Vector1.f
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[1];
  init temp_1 as Real[1];
  temp_1[1] := x;
  for i1 in 1:1 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 annotation(Inline = false);
 end ScalarizeFunctionVectorTests.Vector1.f;

end ScalarizeFunctionVectorTests.Vector1;
")})));
end Vector1;

model Vector2
    function f
        input Real[:,:,:] a;
        output Real[size(a,1)*size(a,2)*size(a,3)] b;
      algorithm
        b := vector(a);
    end f;
    
    Real[1] y = f({{{1}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Vector2",
            description="Scalarization of functions: unknown size vector operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass ScalarizeFunctionVectorTests.Vector2
 Real y[1];
equation
 ({y[1]}) = ScalarizeFunctionVectorTests.Vector2.f({{{1}}});

public
 function ScalarizeFunctionVectorTests.Vector2.f
  input Real[:,:,:] a;
  output Real[:] b;
  Real[:] temp_1;
 algorithm
  init b as Real[size(a, 1) * size(a, 2) * size(a, 3)];
  assert(size(a, 1) * size(a, 2) * size(a, 3) <= size(a, 1) + size(a, 2) + size(a, 3) - 3 + 1, \"Mismatching size in expression vector(a[:,:,:]) in function ScalarizeFunctionVectorTests.Vector2.f\");
  init temp_1 as Real[size(a, 1) * size(a, 2) * size(a, 3)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    for i3 in 1:size(a, 3) loop
     temp_1[((i1 - 1) * size(a, 2) + (i2 - 1)) * size(a, 3) + (i3 - 1) + 1] := a[i1,i2,i3];
    end for;
   end for;
  end for;
  for i1 in 1:size(a, 1) * size(a, 2) * size(a, 3) loop
   b[i1] := temp_1[i1];
  end for;
  return;
 end ScalarizeFunctionVectorTests.Vector2.f;

end ScalarizeFunctionVectorTests.Vector2;
")})));
end Vector2;

model Vector3
    function f
        input Real[:] a;
        output Real[size(a,1),1] b;
      algorithm
        b := matrix(a);
    end f;
    
    Real[1,1] y = f({3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Vector3",
            description="Scalarization of functions: unknown size matrix operator, vector input",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass ScalarizeFunctionVectorTests.Vector3
 Real y[1,1];
equation
 ({{y[1,1]}}) = ScalarizeFunctionVectorTests.Vector3.f({3});

public
 function ScalarizeFunctionVectorTests.Vector3.f
  input Real[:] a;
  output Real[:,:] b;
  Real[:,:] temp_1;
 algorithm
  init b as Real[size(a, 1), 1];
  init temp_1 as Real[size(a, 1), 1];
  for i1 in 1:size(a, 1) loop
   temp_1[i1,1] := a[i1];
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:1 loop
    b[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end ScalarizeFunctionVectorTests.Vector3.f;

end ScalarizeFunctionVectorTests.Vector3;
")})));
end Vector3;

end FunctionTests;
