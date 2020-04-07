/*
    Copyright (C) 2019 Modelon AB

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


package ScalarizeFunctionIfExpTests

model IfExpSize1
        record R
            Real[2] x;
        end R;
        
        function f
            input Real[:] x;
            output R r;
        algorithm
            r := R(if size(x,1) == 2 then x else cat(1,x,x));
        end f;
        
        R r = f({1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfExpSize1",
            description="",
            variability_propagation=false,
            flatModel="
fclass ScalarizeFunctionIfExpTests.IfExpSize1
 Real r.x[1];
 Real r.x[2];
equation
 (ScalarizeFunctionIfExpTests.IfExpSize1.R({r.x[1], r.x[2]})) = ScalarizeFunctionIfExpTests.IfExpSize1.f({1});

public
 function ScalarizeFunctionIfExpTests.IfExpSize1.f
  input Real[:] x;
  output ScalarizeFunctionIfExpTests.IfExpSize1.R r;
  Real[:] temp_1;
 algorithm
  assert((if size(x, 1) == 2 then size(x, 1) else size(x, 1) + size(x, 1)) == 2, \"Mismatching sizes in ScalarizeFunctionIfExpTests.IfExpSize1.f\");
  if size(x, 1) == 2 then
  else
   init temp_1 as Real[size(x, 1) + size(x, 1)];
   for i1 in 1:size(x, 1) loop
    temp_1[i1] := x[i1];
   end for;
   for i1 in 1:size(x, 1) loop
    temp_1[i1 + size(x, 1)] := x[i1];
   end for;
  end if;
  for i1 in 1:2 loop
   r.x[i1] := if size(x, 1) == 2 then x[i1] else temp_1[i1];
  end for;
  return;
 end ScalarizeFunctionIfExpTests.IfExpSize1.f;

 record ScalarizeFunctionIfExpTests.IfExpSize1.R
  Real x[2];
 end ScalarizeFunctionIfExpTests.IfExpSize1.R;

end ScalarizeFunctionIfExpTests.IfExpSize1;

")})));
end IfExpSize1;

end FunctionTests;
