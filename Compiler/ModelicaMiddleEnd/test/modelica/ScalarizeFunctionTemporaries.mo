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


package ScalarizeFunctionTemporaries 

model RangeInSumInSum
    function F
        input Integer p_i;
        input Integer nrows_p[:];
        input Real nrow[:];
        input Real vf[:];
        output Real n;
        algorithm
         n := sum({vf[i]*nrow[i] for i in (sum(nrows_p[1:(p_i-1)])+1):sum(nrows_p[1:p_i])});
    end F;
    Real n;
    equation
    n = F(2, {0,3}, {1,2,time}, {1,2,time});
    
    
annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="RangeBugTests_RangeInSumInSum",
        description="Scalarization of range exp in a Sum",
        flatModel="
fclass ScalarizeFunctionTemporaries.RangeInSumInSum
 Real n;
equation
 n = ScalarizeFunctionTemporaries.RangeInSumInSum.F(2, {0, 3}, {1, 2, time}, {1, 2, time});

public
 function ScalarizeFunctionTemporaries.RangeInSumInSum.F
  input Integer p_i;
  input Integer[:] nrows_p;
  input Real[:] nrow;
  input Real[:] vf;
  output Real n;
  Real temp_1;
  Real[:] temp_2;
  Integer temp_3;
  Integer temp_4;
  Integer temp_5;
  Integer temp_6;
 algorithm
  temp_3 := 0;
  for i2 in 1:max(p_i, 0) loop
   temp_3 := temp_3 + nrows_p[i2];
  end for;
  temp_4 := 0;
  for i2 in 1:max(p_i - 1, 0) loop
   temp_4 := temp_4 + nrows_p[i2];
  end for;
  init temp_2 as Real[max(integer(temp_3 - (temp_4 + 1)) + 1, 0)];
  for i2 in 1:max(integer(temp_3 - (temp_4 + 1)) + 1, 0) loop
   temp_5 := 0;
   for i3 in 1:max(p_i - 1, 0) loop
    temp_5 := temp_5 + nrows_p[i3];
   end for;
   temp_6 := 0;
   for i3 in 1:max(p_i, 0) loop
    temp_6 := temp_6 + nrows_p[i3];
   end for;
   temp_2[i2] := vf[temp_5 + 1 + (i2 - 1)] * nrow[temp_5 + 1 + (i2 - 1)];
  end for;
  temp_1 := 0.0;
  for i1 in 1:max(integer(temp_3 - (temp_4 + 1)) + 1, 0) loop
   temp_1 := temp_1 + temp_2[i1];
  end for;
  n := temp_1;
  return;
 end ScalarizeFunctionTemporaries.RangeInSumInSum.F;

end ScalarizeFunctionTemporaries.RangeInSumInSum;
")})));
end RangeInSumInSum;

end ScalarizeFunctionUnrolledTests;
