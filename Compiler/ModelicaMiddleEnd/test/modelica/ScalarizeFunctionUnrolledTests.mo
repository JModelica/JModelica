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


package ScalarizeFunctionUnrolledTests 

model RecordTempArray1
    record R
        Real[2] x;
    end R;
    
    function g
        input R[2] r;
        output R[2] y = r;
    algorithm
    end g;
    
    function f
        input Integer i;
        input R r;
        R[2] rs = g(noEvent(if i > 1 then g({r,r}) else g({r,r})));
        output R y = rs[i];
    algorithm
    end f;
    
    R r = f(integer(time), R({time,1}));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordTempArray1",
            description="",
            unroll_functions=true,
            flatModel="
fclass ScalarizeFunctionUnrolledTests.RecordTempArray1
 Real r.x[1];
 Real r.x[2];
 discrete Integer temp_2;
initial equation
 pre(temp_2) = 0;
equation
 (ScalarizeFunctionUnrolledTests.RecordTempArray1.R({r.x[1], r.x[2]})) = ScalarizeFunctionUnrolledTests.RecordTempArray1.f(temp_2, ScalarizeFunctionUnrolledTests.RecordTempArray1.R({time, 1}));
 temp_2 = if time < pre(temp_2) or time >= pre(temp_2) + 1 or initial() then integer(time) else pre(temp_2);

public
 function ScalarizeFunctionUnrolledTests.RecordTempArray1.f
  input Integer i;
  input ScalarizeFunctionUnrolledTests.RecordTempArray1.R r;
  ScalarizeFunctionUnrolledTests.RecordTempArray1.R[:] rs;
  output ScalarizeFunctionUnrolledTests.RecordTempArray1.R y;
  ScalarizeFunctionUnrolledTests.RecordTempArray1.R[:] temp_1;
  ScalarizeFunctionUnrolledTests.RecordTempArray1.R[:] temp_2;
 algorithm
  init rs as ScalarizeFunctionUnrolledTests.RecordTempArray1.R[2];
  if i > 1 then
   init temp_1 as ScalarizeFunctionUnrolledTests.RecordTempArray1.R[2];
   (temp_1) := ScalarizeFunctionUnrolledTests.RecordTempArray1.g({ScalarizeFunctionUnrolledTests.RecordTempArray1.R(r.x), ScalarizeFunctionUnrolledTests.RecordTempArray1.R(r.x)});
  else
   init temp_2 as ScalarizeFunctionUnrolledTests.RecordTempArray1.R[2];
   (temp_2) := ScalarizeFunctionUnrolledTests.RecordTempArray1.g({ScalarizeFunctionUnrolledTests.RecordTempArray1.R(r.x), ScalarizeFunctionUnrolledTests.RecordTempArray1.R(r.x)});
  end if;
  (rs) := ScalarizeFunctionUnrolledTests.RecordTempArray1.g({ScalarizeFunctionUnrolledTests.RecordTempArray1.R({noEvent(if i > 1 then temp_1[1].x[1] else temp_2[1].x[1]), noEvent(if i > 1 then temp_1[1].x[2] else temp_2[1].x[2])}), ScalarizeFunctionUnrolledTests.RecordTempArray1.R({noEvent(if i > 1 then temp_1[2].x[1] else temp_2[2].x[1]), noEvent(if i > 1 then temp_1[2].x[2] else temp_2[2].x[2])})});
  y.x[1] := rs[i].x[1];
  y.x[2] := rs[i].x[2];
  return;
 end ScalarizeFunctionUnrolledTests.RecordTempArray1.f;

 function ScalarizeFunctionUnrolledTests.RecordTempArray1.g
  input ScalarizeFunctionUnrolledTests.RecordTempArray1.R[:] r;
  output ScalarizeFunctionUnrolledTests.RecordTempArray1.R[:] y;
 algorithm
  init y as ScalarizeFunctionUnrolledTests.RecordTempArray1.R[2];
  y[1].x[1] := r[1].x[1];
  y[1].x[2] := r[1].x[2];
  y[2].x[1] := r[2].x[1];
  y[2].x[2] := r[2].x[2];
  for i1 in 1:2 loop
   assert(2 == size(r[i1].x, 1), \"Mismatching sizes in function 'ScalarizeFunctionUnrolledTests.RecordTempArray1.g', component 'r[i1].x', dimension '1'\");
  end for;
  return;
 end ScalarizeFunctionUnrolledTests.RecordTempArray1.g;

 record ScalarizeFunctionUnrolledTests.RecordTempArray1.R
  Real x[2];
 end ScalarizeFunctionUnrolledTests.RecordTempArray1.R;

end ScalarizeFunctionUnrolledTests.RecordTempArray1;
")})));
end RecordTempArray1;

end ScalarizeFunctionUnrolledTests;
