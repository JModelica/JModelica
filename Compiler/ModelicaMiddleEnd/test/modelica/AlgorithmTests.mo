/*
	Copyright (C) 2009-2014 Modelon AB

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

within ;
package AlgorithmTests

package For
model Break1
    Real x;
    algorithm
        x := 1;
        for i in 1:2 loop
            x := x + 1;
            break;
            x := x + i;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_Break1",
            description="Break in for",
            flatModel="
fclass AlgorithmTests.For.Break1
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
algorithm
 x := 1;
 temp_1 := true;
 if temp_1 then
  x := x + 1;
  temp_1 := false;
  if temp_1 then
   x := x + 1;
  end if;
 end if;
 if temp_1 then
  x := x + 1;
  temp_1 := false;
  if temp_1 then
   x := x + 2;
  end if;
 end if;
end AlgorithmTests.For.Break1;
")})));
end Break1;

model Break2
    Real x;
    algorithm
        x := 1;
        for i in 1:2 loop
            x := x + 1;
            if noEvent(x > 2) then
                break;
            else
                x := x + 1;
            end if;
            x := x + i;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_Break2",
            description="Break in for",
            flatModel="
fclass AlgorithmTests.For.Break2
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
algorithm
 x := 1;
 temp_1 := true;
 if temp_1 then
  x := x + 1;
  if noEvent(x > 2) then
   temp_1 := false;
  else
   x := x + 1;
  end if;
  if temp_1 then
   x := x + 1;
  end if;
 end if;
 if temp_1 then
  x := x + 1;
  if noEvent(x > 2) then
   temp_1 := false;
  else
   x := x + 1;
  end if;
  if temp_1 then
   x := x + 2;
  end if;
 end if;
end AlgorithmTests.For.Break2;
")})));
end Break2;

model Break3
    Real x;
    algorithm
        x := 1;
        for j in 1:1 loop
            for i in 1:2 loop
                if noEvent(x > 1) then
                    x := 2;
                elseif noEvent(x > 2) then
                    x := 3;
                else
                    if noEvent(x > 3) then
                        break;
                    end if;
                    x := 4;
                end if;
            end for;
            break;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_Break3",
            description="Break in for",
            flatModel="
fclass AlgorithmTests.For.Break3
 Real x;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
initial equation 
 pre(temp_1) = false;
 pre(temp_2) = false;
algorithm
 x := 1;
 temp_1 := true;
 if temp_1 then
  temp_2 := true;
  if temp_2 then
   if noEvent(x > 1) then
    x := 2;
   elseif noEvent(x > 2) then
    x := 3;
   else
    if noEvent(x > 3) then
     temp_2 := false;
    end if;
    if temp_2 then
     x := 4;
    end if;
   end if;
  end if;
  if temp_2 then
   if noEvent(x > 1) then
    x := 2;
   elseif noEvent(x > 2) then
    x := 3;
   else
    if noEvent(x > 3) then
     temp_2 := false;
    end if;
    if temp_2 then
     x := 4;
    end if;
   end if;
  end if;
  temp_1 := false;
 end if;
end AlgorithmTests.For.Break3;
")})));
end Break3;

model BreakNames1
    Real a;
    algorithm
        a := 0.0;
        for i in 1:2 loop
            a := a + i;
            if a > 0.0 then
                break;
            end if;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BreakNames1",
            description="Correct naming of temporary variables resulting from flattening of break statements.",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.For.BreakNames1
 discrete Boolean temp_1;
 Real a;
algorithm
 a := 0.0;
 temp_1 := true;
 if temp_1 then
  a := a + 1;
  if a > 0.0 then
   temp_1 := false;
  end if;
 end if;
 if temp_1 then
  a := a + 2;
  if a > 0.0 then
   temp_1 := false;
  end if;
 end if;
end AlgorithmTests.For.BreakNames1;
")})));
end BreakNames1;

model BreakNames2
    model M1
        input Real a;
        output Real b;
    algorithm
        a := 0.0;
        for i in 1:2 loop
            b := a + i;
            if b < 0.0 then
                break;
            end if;
        end for;
    end M1;
    
    model M2
        input Real a;
        output Real b;
    algorithm
        a := 0.0;
        for i in 1:2 loop
            b := b + a + i;
            if b > 10.0 then
                break;
            end if;
        end for;
    end M2;
    
    M1 m1;
    M2 m2;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BreakNames2",
            description="Correct naming of temporary variables resulting from flattening of break statements (class conflict).",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.For.BreakNames2
 discrete Boolean temp_1;
 Real m1.a;
 Real m1.b;
 discrete Boolean temp_2;
 Real m2.a;
 Real m2.b;
algorithm
 m1.a := 0.0;
 temp_1 := true;
 if temp_1 then
  m1.b := m1.a + 1;
  if m1.b < 0.0 then
   temp_1 := false;
  end if;
 end if;
 if temp_1 then
  m1.b := m1.a + 2;
  if m1.b < 0.0 then
   temp_1 := false;
  end if;
 end if;
algorithm
 m2.a := 0.0;
 temp_2 := true;
 if temp_2 then
  m2.b := m2.b + m2.a + 1;
  if m2.b > 10.0 then
   temp_2 := false;
  end if;
 end if;
 if temp_2 then
  m2.b := m2.b + m2.a + 2;
  if m2.b > 10.0 then
   temp_2 := false;
  end if;
 end if;
end AlgorithmTests.For.BreakNames2;
")})));
end BreakNames2;

model BreakNames3
    Real[2] temp_1 = {1, 2};
    Real temp_2;
    Real temp_4;
    algorithm
        for i in 1:2 loop
            temp_2 := temp_2 + temp_1[3 - i];
            temp_4 := temp_4 + temp_1[i];
            if temp_2 > temp_4 then
                break;
            end if;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BreakNames3",
            description="Correct naming of temporary variables resulting from flattening of break statements (variable conflict).",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.For.BreakNames3
 discrete Boolean temp_3;
 Real temp_1[2] = {1, 2};
 Real temp_2;
 Real temp_4;
algorithm
 temp_3 := true;
 if temp_3 then
  temp_2 := temp_2 + temp_1[3 - 1];
  temp_4 := temp_4 + temp_1[1];
  if temp_2 > temp_4 then
   temp_3 := false;
  end if;
 end if;
 if temp_3 then
  temp_2 := temp_2 + temp_1[3 - 2];
  temp_4 := temp_4 + temp_1[2];
  if temp_2 > temp_4 then
   temp_3 := false;
  end if;
 end if;
end AlgorithmTests.For.BreakNames3;
")})));
end BreakNames3;

model Empty1
    Real x;
algorithm
    x := 1;
    for i in 2:1 loop
        x := x + i;
    end for;
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_Empty1",
            description="Empty for statement",
            flatModel="
fclass AlgorithmTests.For.Empty1
 Real x;
algorithm
 x := 1;
end AlgorithmTests.For.Empty1;
")})));
end Empty1;

end For;

model TempAssign1
  function f
      input Real[:,:] x;
      output Real[size(x,2),size(x,1)] y = transpose(x);
    algorithm
      y := transpose(y);
  end f;
  
    Real[2,2] x = {{1,2},{3,4}} .* time;
    Real[2,2] y1,y2;
  equation
    y1 = f(x);
  algorithm
    y2 := x;
    y2 := transpose(y2);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempAssign1",
            description="Scalarizing assignment temp generation",
            flatModel="
fclass AlgorithmTests.TempAssign1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y1[1,1];
 Real y1[1,2];
 Real y1[2,1];
 Real y1[2,2];
 Real y2[1,1];
 Real y2[1,2];
 Real y2[2,1];
 Real y2[2,2];
 Real temp_2[1,1];
 Real temp_2[1,2];
 Real temp_2[2,1];
 Real temp_2[2,2];
equation
 ({{y1[1,1], y1[1,2]}, {y1[2,1], y1[2,2]}}) = AlgorithmTests.TempAssign1.f({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}});
algorithm
 y2[1,1] := x[1,1];
 y2[1,2] := x[1,2];
 y2[2,1] := x[2,1];
 y2[2,2] := x[2,2];
 temp_2[1,1] := y2[1,1];
 temp_2[1,2] := y2[2,1];
 temp_2[2,1] := y2[1,2];
 temp_2[2,2] := y2[2,2];
 y2[1,1] := temp_2[1,1];
 y2[1,2] := temp_2[1,2];
 y2[2,1] := temp_2[2,1];
 y2[2,2] := temp_2[2,2];
equation
 x[1,1] = time;
 x[1,2] = 2 * x[1,1];
 x[2,1] = 3 * x[1,1];
 x[2,2] = 4 * x[1,1];
 
public
 function AlgorithmTests.TempAssign1.f
  input Real[:,:] x;
  output Real[:,:] y;
  Real[:,:] temp_1;
 algorithm
  init y as Real[size(x, 2), size(x, 1)];
  for i1 in 1:size(x, 2) loop
   for i2 in 1:size(x, 1) loop
    y[i1,i2] := x[i2,i1];
   end for;
  end for;
  init temp_1 as Real[size(x, 1), size(x, 2)];
  for i1 in 1:size(x, 1) loop
   for i2 in 1:size(x, 2) loop
    temp_1[i1,i2] := y[i2,i1];
   end for;
  end for;
  for i1 in 1:size(x, 2) loop
   for i2 in 1:size(x, 1) loop
    y[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end AlgorithmTests.TempAssign1.f;

end AlgorithmTests.TempAssign1;
")})));
end TempAssign1;

model TempAssign2
  function f
      input R[:] x;
      output R[size(x,1)] y = x;
      Integer t = size(x,1);
    algorithm
      y[1:t] := y[{t+1-i for i in 1:t}];
  end f;
  
    record R
        Real a,b;
    end R;
    
    R[2] x = {R(time,time),R(time,time)};
    R[2] y1,y2;
  equation
    y1 = f(x);
  algorithm
    y2 := x;
    y2 := y2[{2+1-i for i in 1:2}];
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempAssign2",
            description="Scalarizing assignment temp generation",
            flatModel="
fclass AlgorithmTests.TempAssign2
 Real x[1].b;
 Real y1[1].a;
 Real y1[1].b;
 Real y1[2].a;
 Real y1[2].b;
 Real y2[1].a;
 Real y2[1].b;
 Real y2[2].a;
 Real y2[2].b;
 Real temp_2[1].a;
 Real temp_2[1].b;
 Real temp_2[2].a;
 Real temp_2[2].b;
equation
 ({AlgorithmTests.TempAssign2.R(y1[1].a, y1[1].b), AlgorithmTests.TempAssign2.R(y1[2].a, y1[2].b)}) = AlgorithmTests.TempAssign2.f({AlgorithmTests.TempAssign2.R(x[1].b, x[1].b), AlgorithmTests.TempAssign2.R(x[1].b, x[1].b)});
algorithm
 y2[1].a := x[1].b;
 y2[1].b := x[1].b;
 y2[2].a := x[1].b;
 y2[2].b := x[1].b;
 temp_2[1].a := y2[2].a;
 temp_2[1].b := y2[2].b;
 temp_2[2].a := y2[1].a;
 temp_2[2].b := y2[1].b;
 y2[1].a := temp_2[1].a;
 y2[1].b := temp_2[1].b;
 y2[2].a := temp_2[2].a;
 y2[2].b := temp_2[2].b;
equation
 x[1].b = time;

public
 function AlgorithmTests.TempAssign2.f
  input AlgorithmTests.TempAssign2.R[:] x;
  output AlgorithmTests.TempAssign2.R[:] y;
  Integer t;
  Integer[:] temp_1;
  AlgorithmTests.TempAssign2.R[:] temp_2;
 algorithm
  init y as AlgorithmTests.TempAssign2.R[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1].a := x[i1].a;
   y[i1].b := x[i1].b;
  end for;
  t := size(x, 1);
  init temp_1 as Integer[max(t, 0)];
  for i1 in 1:max(t, 0) loop
   temp_1[i1] := t + 1 - i1;
  end for;
  init temp_2 as AlgorithmTests.TempAssign2.R[max(t, 0)];
  for i1 in 1:max(t, 0) loop
   temp_2[i1].a := y[temp_1[i1]].a;
   temp_2[i1].b := y[temp_1[i1]].b;
  end for;
  for i1 in 1:max(t, 0) loop
   y[i1].a := temp_2[i1].a;
   y[i1].b := temp_2[i1].b;
  end for;
  return;
 end AlgorithmTests.TempAssign2.f;

 record AlgorithmTests.TempAssign2.R
  Real a;
  Real b;
 end AlgorithmTests.TempAssign2.R;

end AlgorithmTests.TempAssign2;
")})));
end TempAssign2;

model TempAssign3
  
  function f
      input R[:] x;
      output R[size(x,1)] y = x;
      Integer t = size(x,1);
    algorithm
      y[1:t] := y[{t+1-i for i in 1:t}];
  end f;
  
    record R
        Real a[2];
    end R;
    
    R[2] x = {R({time,time}),R({time,time})};
    R[2] y1,y2;
  equation
    y1 = f(x);
  algorithm
    y2 := x;
    y2 := y2[{2+1-i for i in 1:2}];
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempAssign3",
            description="Scalarizing assignment temp generation",
            flatModel="
fclass AlgorithmTests.TempAssign3
 Real x[1].a[2];
 Real y1[1].a[1];
 Real y1[1].a[2];
 Real y1[2].a[1];
 Real y1[2].a[2];
 Real y2[1].a[1];
 Real y2[1].a[2];
 Real y2[2].a[1];
 Real y2[2].a[2];
 Real temp_2[1].a[1];
 Real temp_2[1].a[2];
 Real temp_2[2].a[1];
 Real temp_2[2].a[2];
equation
 ({AlgorithmTests.TempAssign3.R({y1[1].a[1], y1[1].a[2]}), AlgorithmTests.TempAssign3.R({y1[2].a[1], y1[2].a[2]})}) = AlgorithmTests.TempAssign3.f({AlgorithmTests.TempAssign3.R({x[1].a[2], x[1].a[2]}), AlgorithmTests.TempAssign3.R({x[1].a[2], x[1].a[2]})});
algorithm
 y2[1].a[1] := x[1].a[2];
 y2[1].a[2] := x[1].a[2];
 y2[2].a[1] := x[1].a[2];
 y2[2].a[2] := x[1].a[2];
 temp_2[1].a[1] := y2[2].a[1];
 temp_2[1].a[2] := y2[2].a[2];
 temp_2[2].a[1] := y2[1].a[1];
 temp_2[2].a[2] := y2[1].a[2];
 y2[1].a[1] := temp_2[1].a[1];
 y2[1].a[2] := temp_2[1].a[2];
 y2[2].a[1] := temp_2[2].a[1];
 y2[2].a[2] := temp_2[2].a[2];
equation
 x[1].a[2] = time;

public
 function AlgorithmTests.TempAssign3.f
  input AlgorithmTests.TempAssign3.R[:] x;
  output AlgorithmTests.TempAssign3.R[:] y;
  Integer t;
  Integer[:] temp_1;
  AlgorithmTests.TempAssign3.R[:] temp_2;
 algorithm
  init y as AlgorithmTests.TempAssign3.R[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   for i2 in 1:2 loop
    y[i1].a[i2] := x[i1].a[i2];
   end for;
  end for;
  t := size(x, 1);
  for i1 in 1:size(x, 1) loop
   assert(2 == size(x[i1].a, 1), \"Mismatching sizes in function 'AlgorithmTests.TempAssign3.f', component 'x[i1].a', dimension '1'\");
  end for;
  init temp_1 as Integer[max(t, 0)];
  for i1 in 1:max(t, 0) loop
   temp_1[i1] := t + 1 - i1;
  end for;
  init temp_2 as AlgorithmTests.TempAssign3.R[max(t, 0)];
  for i1 in 1:max(t, 0) loop
   init temp_2[i1].a as Real[2];
   for i2 in 1:2 loop
    temp_2[i1].a[i2] := y[temp_1[i1]].a[i2];
   end for;
  end for;
  for i1 in 1:max(t, 0) loop
   for i2 in 1:2 loop
    y[i1].a[i2] := temp_2[i1].a[i2];
   end for;
  end for;
  return;
 end AlgorithmTests.TempAssign3.f;

 record AlgorithmTests.TempAssign3.R
  Real a[2];
 end AlgorithmTests.TempAssign3.R;

end AlgorithmTests.TempAssign3;
")})));
end TempAssign3;

model TempAssign4
    function f
        input Real x;
        output Real[3] y = {x,x,x};
        algorithm
    end f;
    Real[2,3] y;
algorithm
    for i in 1:2 loop
        y[i,:] := f(time);
    end for;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempAssign4",
            description="Scalarizing assignment temp generation",
            flatModel="
fclass AlgorithmTests.TempAssign4
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
 Real temp_2[1];
 Real temp_2[2];
 Real temp_2[3];
algorithm
 ({temp_1[1], temp_1[2], temp_1[3]}) := AlgorithmTests.TempAssign4.f(time);
 y[1,1] := temp_1[1];
 y[1,2] := temp_1[2];
 y[1,3] := temp_1[3];
 ({temp_2[1], temp_2[2], temp_2[3]}) := AlgorithmTests.TempAssign4.f(time);
 y[2,1] := temp_2[1];
 y[2,2] := temp_2[2];
 y[2,3] := temp_2[3];

public
 function AlgorithmTests.TempAssign4.f
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[3];
  init temp_1 as Real[3];
  temp_1[1] := x;
  temp_1[2] := x;
  temp_1[3] := x;
  for i1 in 1:3 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end AlgorithmTests.TempAssign4.f;

end AlgorithmTests.TempAssign4;
")})));
end TempAssign4;

model UnusedBranch1
    Real x;
algorithm
    if true then
        x := 1;
    else
        x := 2;
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnusedBranch1",
            description="",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.UnusedBranch1
 Real x;
algorithm
 x := 1;
end AlgorithmTests.UnusedBranch1;
")})));
end UnusedBranch1;

model UnusedBranch2
    Real x;
algorithm
    if false then
        x := 1;
    else
        x := 2;
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnusedBranch2",
            description="",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.UnusedBranch2
 Real x;
algorithm
  x := 2;
end AlgorithmTests.UnusedBranch2;
")})));
end UnusedBranch2;

model UnusedBranch3
    Real x;
algorithm
    if false then
        x := 1;
    elseif true then
        x := 3;
    else
        x := 2;
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnusedBranch3",
            description="",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.UnusedBranch3
 Real x;
algorithm
 x := 3;
end AlgorithmTests.UnusedBranch3;
")})));
end UnusedBranch3;

model UnusedBranch4
    Real x;
    input Boolean b;
algorithm
    if b then
        x := 1;
    elseif false then
        x := 4;
    elseif true then
        x := 3;
    else
        x := 2;
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnusedBranch4",
            description="",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.UnusedBranch4
 Real x;
 discrete input Boolean b;
algorithm
 if b then
  x := 1;
 else
  x := 3;
 end if;
end AlgorithmTests.UnusedBranch4;
")})));
end UnusedBranch4;

model UnusedBranch5
    Real x;
    input Boolean b;
algorithm
    for i in 1:4 loop
        if b then
            x := 1;
        elseif i <= 2 then
            x := 4;
        elseif i > 2 then
            x := 3;
            break;
        else
            x := 2;
        end if;
    end for;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnusedBranch5",
            description="",
            variability_propagation=false,
            flatModel="
fclass AlgorithmTests.UnusedBranch5
 discrete Boolean temp_1;
 Real x;
 discrete input Boolean b;
algorithm
 temp_1 := true;
 if temp_1 then
  if b then
   x := 1;
  else
   x := 4;
  end if;
 end if;
 if temp_1 then
  if b then
   x := 1;
  else
   x := 4;
  end if;
 end if;
 if temp_1 then
  if b then
   x := 1;
  else
   x := 3;
   temp_1 := false;
  end if;
 end if;
 if temp_1 then
  if b then
   x := 1;
  else
   x := 3;
   temp_1 := false;
  end if;
 end if;
end AlgorithmTests.UnusedBranch5;
")})));
end UnusedBranch5;

model VariableSubscriptAssign1
    Real[2,2] y;
algorithm
    y[integer(time),:] := {time,time+1};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableSubscriptAssign1",
            description="",
            flatModel="
fclass AlgorithmTests.VariableSubscriptAssign1
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
 discrete Integer temp_1;
 discrete Integer temp_2;
initial equation
 pre(temp_1) = 0;
 pre(temp_2) = 0;
algorithm
 temp_2 := if time < pre(temp_2) or time >= pre(temp_2) + 1 or initial() then integer(time) else pre(temp_2);
 ({{y[1,1], y[1,2]}, {y[2,1], y[2,2]}})[temp_2,1] := time;
 temp_1 := if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
 ({{y[1,1], y[1,2]}, {y[2,1], y[2,2]}})[temp_1,2] := time + 1;
end AlgorithmTests.VariableSubscriptAssign1;
")})));
end VariableSubscriptAssign1;


end AlgorithmTests;
