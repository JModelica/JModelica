/*
    Copyright (C) 2009-2011 Modelon AB

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


package TearingTests

model Test1
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="Test1",
			description="Test of tearing",
			equation_sorting=true,
			automatic_tearing=true,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
uL := sin(time)

--- Torn linear system (Block 1) of 2 iteration variables and 3 solved variables ---
Coefficient variability: parameter
Torn variables:
  i1
  u1
  u2

Iteration variables:
  i2
  i3

Torn equations:
  i1 := i2 + i3
  u1 := R1 * i1
  u2 := uL - u1

Residual equations:
  u2 = R3 * i3
    Iteration variables: i2
  u2 = R2 * i2
    Iteration variables: i3

Jacobian:
  |1.0, 0.0, 0.0, -1.0, -1.0|
  |(- R1), 1.0, 0.0, 0.0, 0.0|
  |0.0, -1.0, -1.0, 0.0, 0.0|
  |0.0, 0.0, 1.0, 0.0, (- R3)|
  |0.0, 0.0, 1.0, (- R2), 0.0|

--- Solved equation ---
der(iL) := (- uL) / (- L)

--- Solved equation ---
i0 := i1 + iL
-------------------------------
")})));
  end Test1;

model Test2
 parameter Real m = 1;
 parameter Real f0 = 1;
 parameter Real f1 = 1;
 Real v;
 Real a;
 Real f;
 Real u;
 Real sa;
 Boolean startFor(start=false);
 Boolean startBack(start=false);
 Integer mode(start=2);
 Real dummy;
equation 
 der(dummy) = 1;
 u = 2*sin(time);
 m*der(v) = u - f;
 der(v) = a;
 startFor = pre(mode)==2 and sa > 1;
 startBack = pre(mode) == 2 and sa < -1;
 a = if pre(mode) == 1 or startFor then sa-1 else 
     if pre(mode) == 3 or startBack then 
     sa + 1 else 0;
 f = if pre(mode) == 1 or startFor then 
     f0 + f1*v else 
     if pre(mode) == 3 or startBack then 
     -f0 + f1*v else f0*sa;
 mode=if (pre(mode) == 1 or startFor)
      and v>0 then 1 else 
      if (pre(mode) == 3 or startBack)
          and v<0 then 3 else 2;


    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Test2",
            description="Test tearing of mixed linear equation block",
            equation_sorting=true,
            automatic_tearing=true,
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
der(dummy) := 1

--- Solved equation ---
u := 2 * sin(time)

--- Torn mixed linear system (Block 1) of 1 iteration variables and 2 solved variables ---
Coefficient variability: discrete-time
Torn variables:
  der(v)
  f

Iteration variables:
  sa

Solved discrete variables:
  startFor
  startBack
  mode

Torn equations:
  der(v) := if pre(mode) == 1 or startFor then sa - 1 elseif pre(mode) == 3 or startBack then sa + 1 else 0
  f := if pre(mode) == 1 or startFor then f0 + f1 * v elseif pre(mode) == 3 or startBack then - f0 + f1 * v else f0 * sa

Continuous residual equations:
  m * der(v) = u - f
    Iteration variables: sa

Discrete equations:
  startFor := pre(mode) == 2 and sa > 1
  startBack := pre(mode) == 2 and sa < -1
  mode := if (pre(mode) == 1 or startFor) and v > 0 then 1 elseif (pre(mode) == 3 or startBack) and v < 0 then 3 else 2

Jacobian:
  |1.0, 0.0, - (if pre(mode) == 1 or startFor then 1.0 elseif pre(mode) == 3 or startBack then 1.0 else 0)|
  |0.0, 1.0, - (if pre(mode) == 1 or startFor then 0.0 elseif pre(mode) == 3 or startBack then 0.0 else f0)|
  |m, 1.0, 0.0|

--- Solved equation ---
a := der(v)
-------------------------------
")})));
end Test2;

model Test3
    Real a,b,c;
equation
    a * b = 0;
    a - b = c;
    a + b = c;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Test3",
            description="Tests a tricky tearing bug where incorrect torn part was constructed.",
            methodName="printDAEBLT",
            methodResult="
--- Torn system (Block 1) of 2 iteration variables and 1 solved variables ---
Torn variables:
  c

Iteration variables:
  b ()
  a ()

Torn equations:
  c := a + b

Residual equations:
  a - b = c
    Iteration variables: b
  a * b = 0
    Iteration variables: a
-------------------------------
")})));
end Test3;

model WarningTest1
	Real u0,u1,u2,u3,uL;
	Real i0,i1,i2,i3,iL;
	parameter Real R1 = 1;
	parameter Real R2 = 1;
	parameter Real R3 = 1;
	parameter Real L = 1;
equation
	u0 = sin(time);
	u1 = R1*i1;
	u2 = R2*abs(i2);
	u3 = R3*i3;
	uL = L*der(iL);
	u0 = u1 + u3;
	uL = u1 + u2;
	u2 = u3;
	i0 = i1 + iL;
	i1 = i2 + i3;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="WarningTest1",
            description="Test missing start value warning",
            equation_sorting=true,
            automatic_tearing=true,
            errorMessage="
2 errors found:

Warning at line 3, column 2, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TearingTests.mo':
  Iteration variable \"i2\" is missing start value!

Warning at line 3, column 2, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TearingTests.mo':
  Iteration variable \"i3\" is missing start value!
")})));
end WarningTest1;

model WarningTest2
	Real u0,u1,u2,u3,uL;
	Real i0,i1,i2(start=1),i3,iL;
	parameter Real R1 = 1;
	parameter Real R2 = 1;
	parameter Real R3 = 1;
	parameter Real L = 1;
equation
	u0 = sin(time);
	u1 = R1*i1;
	u2 = R2*abs(i2);
	u3 = R3*i3;
	uL = L*der(iL);
	u0 = u1 + u3;
	uL = u1 + u2;
	u2 = u3;
	i0 = i1 + iL;
	i1 = i2 + i3;
	
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="WarningTest2",
            description="Test missing start value warning",
            equation_sorting=true,
            automatic_tearing=true,
            errorMessage="
1 errors found:

Warning at line 3, column 2, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TearingTests.mo':
  Iteration variable \"i3\" is missing start value!
")})));
end WarningTest2;


model BLTError1
    Integer i, j;
    Real r,s;
equation
    i = j + integer(time) + integer(s);
    j = 1/i;
    r = i * time;
    s = r * 3.14;

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="BLTError1",
            description="Test error message given by BLT when non-real equation contains a loop",
            errorMessage="
1 errors found:

Error at line 5, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TearingTests.mo':
  Non-real equation used as residual:
i = j + temp_2 + temp_1
")})));
end BLTError1;


model RecordTearingTest1
  record R
    Real x;
    Real y;
  end R;
  function F
    input Real a;
    input Real b;
    output R r;
  algorithm
    r := R(a + b, a - b);
  end F;
  Real x, y;
  R r;
equation
  x = 1;
  y = x + 2;
  r = F(x, y);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest1",
			methodName="printDAEBLT",
			equation_sorting=true,
			variability_propagation=false,
			inline_functions="none",
			automatic_tearing=true,
			description="Test of record tearing",
			methodResult="
--- Solved equation ---
x := 1

--- Solved equation ---
y := x + 2

--- Solved function call equation ---
(TearingTests.RecordTearingTest1.R(r.x, r.y)) = TearingTests.RecordTearingTest1.F(x, y)
  Assigned variables: r.x
                      r.y
-------------------------------
")})));
end RecordTearingTest1;

model RecordTearingTest2
  record R
    Real x;
    Real y;
  end R;
  function F
    input Real a;
    input Real b;
    output R r;
  algorithm
    r := R(a + b, a - b);
  end F;
  Real x,y;
  R r;
equation
  y = sin(time);
  r.y = 2;
  r = F(x,y);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest2",
			description="Test of record tearing",
			equation_sorting=true,
			automatic_tearing=true,
			inline_functions="none",
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
y := sin(time)

--- Torn system (Block 1) of 1 iteration variables and 1 solved variables ---
Torn variables:
  r.x

Iteration variables:
  x ()

Torn equations:
  (TearingTests.RecordTearingTest2.R(r.x, r.y)) = TearingTests.RecordTearingTest2.F(x, y)
    Assigned variables: r.x

Residual equations:
  (TearingTests.RecordTearingTest2.R(r.x, r.y)) = TearingTests.RecordTearingTest2.F(x, y)
    Iteration variables: x
-------------------------------
")})));
end RecordTearingTest2;

model RecordTearingTest3
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real x, y,z;
equation
  y = z + 3.14;
  (x, y) = F(z, x);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest3",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			inline_functions="none",
			description="Test of record tearing",
			methodResult="
--- Torn system (Block 1) of 2 iteration variables and 1 solved variables ---
Torn variables:
  y

Iteration variables:
  z ()
  x ()

Torn equations:
  (x, y) = TearingTests.RecordTearingTest3.F(z, x)
    Assigned variables: y

Residual equations:
  y = z + 3.14
    Iteration variables: z
  (x, y) = TearingTests.RecordTearingTest3.F(z, x)
    Iteration variables: x
-------------------------------
")})));
end RecordTearingTest3;

model RecordTearingTest4
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real x, y;
  Real v;
equation
   (x, y) = F(v, v);
   v = x + y;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest4",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			inline_functions="none",
			description="Test of record tearing",
			methodResult="
--- Torn system (Block 1) of 1 iteration variables and 2 solved variables ---
Torn variables:
  x
  y

Iteration variables:
  v ()

Torn equations:
  (x, y) = TearingTests.RecordTearingTest4.F(v, v)
    Assigned variables: x
  (x, y) = TearingTests.RecordTearingTest4.F(v, v)
    Assigned variables: y

Residual equations:
  v = x + y
    Iteration variables: v
-------------------------------
")})));
end RecordTearingTest4;

model RecordTearingTest5
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real a;
  Real b;
  Real c;
  Real d;
  Real e;
  Real f;
equation
  (c,d) = F(a,b);
  (e,f) = F(c,d);
  (a,b) = F(e,f);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest5",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			inline_functions="none",
			description="Test of record tearing",
			methodResult="
--- Torn system (Block 1) of 3 iteration variables and 3 solved variables ---
Torn variables:
  c
  d
  e

Iteration variables:
  f ()
  b ()
  a ()

Torn equations:
  (c, d) = TearingTests.RecordTearingTest5.F(a, b)
    Assigned variables: c
  (c, d) = TearingTests.RecordTearingTest5.F(a, b)
    Assigned variables: d
  (e, f) = TearingTests.RecordTearingTest5.F(c, d)
    Assigned variables: e

Residual equations:
  (e, f) = TearingTests.RecordTearingTest5.F(c, d)
    Iteration variables: f
  (a, b) = TearingTests.RecordTearingTest5.F(e, f)
    Iteration variables: b
  (a, b) = TearingTests.RecordTearingTest5.F(e, f)
    Iteration variables: a
-------------------------------
")})));
end RecordTearingTest5;

model AlgorithmTearingTest1
  Real x, y, z;
algorithm
  x := x + y + z;
  y := y - x + z;
equation
  z = x + y;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AlgorithmTearingTest1",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			inline_functions="none",
			description="Test of algorithm tearing",
			methodResult="
--- Torn system (Block 1) of 1 iteration variables and 2 solved variables ---
Torn variables:
  y
  x

Iteration variables:
  z ()

Torn equations:
  algorithm
    x := x + y + z;
    y := y - x + z;

    Assigned variables: y
                        x

Residual equations:
  z = x + y
    Iteration variables: z
-------------------------------
")})));
end AlgorithmTearingTest1;

model AlgorithmTearingTest2
  Real x, y, z;
algorithm
  y := y * z + 1;
equation
  x = 2*z + y;
  z = 2*x;
  
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="AlgorithmTearingTest2",
            methodName="printDAEBLT",
            equation_sorting=true,
            automatic_tearing=true,
            eliminate_linear_equations=false,
            inline_functions="none",
            description="Test of algorithm tearing",
            methodResult="
--- Torn system (Block 1) of 1 iteration variables and 2 solved variables ---
Torn variables:
  y
  x

Iteration variables:
  z ()

Torn equations:
  algorithm
    y := y * z + 1;

    Assigned variables: y
  x := 2 * z + y

Residual equations:
  z = 2 * x
    Iteration variables: z
-------------------------------
")})));
end AlgorithmTearingTest2;

model TearingFixedFalse1
    parameter Real a(fixed = false);
    parameter Real b(fixed = false);
    parameter Real c(fixed = false);
initial equation
    20 = c * a;
    23 = c * b;
    c = a + b;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="TearingFixedFalse1",
            methodName="printDAEInitBLT",
            methodResult="
--- Torn system (Block 1) of 2 iteration variables and 1 solved variables ---
Torn variables:
  c

Iteration variables:
  a ()
  b ()

Torn equations:
  c := a + b

Residual equations:
  23 = c * b
    Iteration variables: a
  20 = c * a
    Iteration variables: b
-------------------------------
")})));
end TearingFixedFalse1;

model InitialTearingMatchingTest1
    Real e(start=0.01);
    Real c;
    Real f;
    Real d;
    Real a;
    Real b;
    parameter Real p1 = 2;
    parameter Real p2 = 3;
equation
  a = time * 2;
  
  b = smooth(0, min(1000, max(0, 42 * c)));
  d = p1 * e;
  d = c - b;
  f = p2 * (- e);
  f = c - a;
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="InitialTearingMatchingTest1",
            description="Test the initial tearing matching transformation that is done at the start of automatic tearing",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
a := time * 2

--- Torn system (Block 1) of 1 iteration variables and 4 solved variables ---
Torn variables:
  f
  c
  d
  b

Iteration variables:
  e (start=0.01)

Torn equations:
  f := p2 * (- e)
  c := f + a
  d := p1 * e
  b := smooth(0, min(1000, max(0, 42 * c)))

Residual equations:
  d = c - b
    Iteration variables: e
-------------------------------
")})));
end InitialTearingMatchingTest1;

model TypeComputation1
    Real Zc;
    Real p(min=0,max=1.0E8,start=5.0,nominal=100000.0);
    Real a;
    R r;
    Real q1(start = 5.0);

    parameter Real p1 = 1;
    parameter Real p2 = 2;
    parameter Real p3 = 3;
    parameter Real p4 = 4;

    function f
        input Real x1;
        input Real x2;
        output R r;
    algorithm
        r.d := if x1 > 0.5 then 4 else 3;
        r.r1 := x2 * x2;
        r.r2 := x2 * r.r1;
        r.r3 := x2 + x2;
        r.r4 := x2 + r.r3;
    annotation(Inline=false);
    end f;

    record R
        Integer d;
        Real r1;
        Real r2;
        Real r3;
        Real r4;
    end R;

equation
    Zc = r.r1 * a / p1;
    p = p2 + Zc * q1;
    r = f(p, p3);
    a = noEvent(if r.d == 3 then  r.r1 * r.r1 + r.r2 * r.r3 * r.r4 else r.r1);
    p4 = q1 * r.r1;
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="TypeComputation1",
            description="Test type computation bug where all BiP equations was considered non-real since one group member was integer",
            methodName="printDAEBLT",
            methodResult="
--- Torn mixed system (Block 1) of 2 iteration variables and 6 solved variables ---
Torn variables:
  r.r4
  r.r3
  r.r2
  r.r1
  a
  Zc

Iteration variables:
  p (min=0,max=1.0E8,start=5.0,nominal=100000.0)
  q1 (start=5.0)

Solved discrete variables:
  r.d

Torn equations:
  (TearingTests.TypeComputation1.R(r.d, r.r1, r.r2, r.r3, r.r4)) = TearingTests.TypeComputation1.f(p, p3)
    Assigned variables: r.r4
  (TearingTests.TypeComputation1.R(r.d, r.r1, r.r2, r.r3, r.r4)) = TearingTests.TypeComputation1.f(p, p3)
    Assigned variables: r.r3
  (TearingTests.TypeComputation1.R(r.d, r.r1, r.r2, r.r3, r.r4)) = TearingTests.TypeComputation1.f(p, p3)
    Assigned variables: r.r2
  (TearingTests.TypeComputation1.R(r.d, r.r1, r.r2, r.r3, r.r4)) = TearingTests.TypeComputation1.f(p, p3)
    Assigned variables: r.r1
  a := noEvent(if r.d == 3 then r.r1 * r.r1 + r.r2 * r.r3 * r.r4 else r.r1)
  Zc := r.r1 * a / p1

Continuous residual equations:
  p = p2 + Zc * q1
    Iteration variables: p
  p4 = q1 * r.r1
    Iteration variables: q1

Discrete equations:
  (TearingTests.TypeComputation1.R(r.d, r.r1, r.r2, r.r3, r.r4)) = TearingTests.TypeComputation1.f(p, p3)
    Assigned variables: r.d
-------------------------------
")})));
end TypeComputation1;

model MetaEquation1
    Real x;
    Real y;
    Real z;
    Real zz;
    Boolean b;
    
equation
    zz + y = 0.1;
    zz + z = 1;
    y + z = if b then time else -time;
    b = y - z > time;
    der(x) = 1;
    when b and not pre(b) then
        reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="MetaEquation1",
            description="Test so that the tearing algorithm handles meta equations correctly",
            methodName="printDAEBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 2 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  zz

Iteration variables:
  z
  y

Solved discrete variables:
  b
  temp_1

Torn equations:
  zz := - y + 0.1

Continuous residual equations:
  zz + z = 1
    Iteration variables: z
  y + z = if b then time else - time
    Iteration variables: y

Discrete equations:
  b := y - z > time
  temp_1 := b and not pre(b)

Meta equations:
  if temp_1 and not pre(temp_1) then
    reinit(x, 1);
  end if

Jacobian:
  |1.0, 0.0, 1.0|
  |1.0, 1.0, 0.0|
  |0.0, 1.0, 1.0|

--- Solved equation ---
der(x) := 1
-------------------------------
")})));
end MetaEquation1;

model MetaEquation2
    function f
        input Real i1;
        input Boolean i2[1];
        output Boolean o1;
        output Integer o2;
    algorithm
        o1 := i2[1] and i1 > 0;
        o2 := 1;
        annotation(Inline=false);
    end f;
    
    Real x1;
    Real x2;
    Real r1;
    Integer i1;
    Boolean b1;
    Real r2;
    Real r3[1];
    Real r4;
    Real r5;
    Boolean b2;
    Boolean b3;
    parameter Boolean p1 = true;
    
equation
    der(x1) = 1;
    der(x2) = time;
    r2 = if b1 then r1 else 42.0;
    r1 = if b1 then r3[i1] else 0.0;
    r3[1] = if b3 then 3.14 else 6.28;
    when pre(b3) and not b3 then
        reinit(x1, 321.0);
    end when;
    when not pre(b1) and b1 then
        reinit(x2, 123.0);
    end when;
    r4 = r3[1] + r2;
    b3 = p1 and b2;
    r5 = if noEvent(r4 >= 0) then r4 else - r4;
    b2 = r5 < 42.0;
    (b1, i1) = f(1, {b3});

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="MetaEquation2",
            description="Test so that the tearing algorithm handles meta equations correctly",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
der(x1) := 1

--- Solved equation ---
der(x2) := time

--- Torn mixed linear system (Block 1) of 3 iteration variables and 2 solved variables ---
Coefficient variability: discrete-time
Torn variables:
  r5
  r2

Iteration variables:
  r3[1]
  r1
  r4

Solved discrete variables:
  b2
  b3
  b1
  temp_2
  temp_1

Torn equations:
  r5 := if noEvent(r4 >= 0) then r4 else - r4
  r2 := if b1 then r1 else 42.0

Continuous residual equations:
  r3[1] = if b3 then 3.14 else 6.28
    Iteration variables: r3[1]
  r1 = if b1 then ({r3[1]})[1] else 0.0
    Iteration variables: r1
  r4 = r3[1] + r2
    Iteration variables: r4

Discrete equations:
  b2 := r5 < 42.0
  b3 := p1 and b2
  (b1, ) = TearingTests.MetaEquation2.f(1, {b3})
    Assigned variables: b1
  temp_2 := not pre(b1) and b1
  temp_1 := pre(b3) and not b3

Meta equations:
  if temp_2 and not pre(temp_2) then
    reinit(x2, 123.0);
  end if
  if temp_1 and not pre(temp_1) then
    reinit(x1, 321.0);
  end if

Jacobian:
  |1.0, 0.0, 0.0, 0.0, 0.0|
  |0.0, 1.0, 0.0, - (if b1 then 1.0 else 0.0), 0.0|
  |0.0, 0.0, 1.0, 0.0, 0.0|
  |0.0, 0.0, - (if b1 then ({1.0})[1] else 0.0), 1.0, 0.0|
  |0.0, -1.0, -1.0, 0.0, 1.0|
-------------------------------
")})));
end MetaEquation2;

model NoEventLinear1
    Real x = y * 2;
    Real y = z / 2;
    Real z = noEvent(if p > 2 then x else -x);
    parameter Real p = 3;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="NoEventLinear1",
            description="",
            methodName="printDAEBLT",
            methodResult="
--- Torn linear system (Block 1) of 1 iteration variables and 2 solved variables ---
Coefficient variability: parameter
Torn variables:
  z
  y

Iteration variables:
  x

Torn equations:
  z := noEvent(if p > 2 then x else - x)
  y := z / 2

Residual equations:
  x = y * 2
    Iteration variables: x

Jacobian:
  |1.0, 0.0, - noEvent(if p > 2 then 1.0 else -1.0)|
  |(- 1.0 / 2), 1.0, 0.0|
  |0.0, -2, 1.0|
-------------------------------
")})));
end NoEventLinear1;

model NoEventLinear2
    Real x = y * 2;
    Real y = z / 2;
    Real z = noEvent(if noEvent(time > 2) then x else -x);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="NoEventLinear2",
            description="",
            methodName="printDAEBLT",
            methodResult="
--- Torn linear system (Block 1) of 1 iteration variables and 2 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  z
  y

Iteration variables:
  x

Torn equations:
  z := noEvent(if noEvent(time > 2) then x else - x)
  y := z / 2

Residual equations:
  x = y * 2
    Iteration variables: x

Jacobian:
  |1.0, 0.0, - noEvent(if noEvent(time > 2) then 1.0 else -1.0)|
  |(- 1.0 / 2), 1.0, 0.0|
  |0.0, -2, 1.0|
-------------------------------
")})));
end NoEventLinear2;

model NoEventLinear3
    Boolean b = time > 2;
    Real x = y * 2;
    Real y = z / 2;
    Real z = noEvent(if b then x else -x);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="NoEventLinear3",
            description="",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
b := time > 2

--- Torn linear system (Block 1) of 1 iteration variables and 2 solved variables ---
Coefficient variability: discrete-time
Torn variables:
  z
  y

Iteration variables:
  x

Torn equations:
  z := noEvent(if b then x else - x)
  y := z / 2

Residual equations:
  x = y * 2
    Iteration variables: x

Jacobian:
  |1.0, 0.0, - noEvent(if b then 1.0 else -1.0)|
  |(- 1.0 / 2), 1.0, 0.0|
  |0.0, -2, 1.0|
-------------------------------
")})));
end NoEventLinear3;

model NoEventNonlinear
    
    Real x = y * 2;
    Real y = z / 2;
    Real z = noEvent(if y > 0 then x else -x);
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="NoEventNonlinear",
            description="",
            methodName="printDAEBLT",
            methodResult="
--- Torn system (Block 1) of 1 iteration variables and 2 solved variables ---
Torn variables:
  x
  z

Iteration variables:
  y ()

Torn equations:
  x := y * 2
  z := noEvent(if y > 0 then x else - x)

Residual equations:
  y = z / 2
    Iteration variables: y
-------------------------------
")})));
end NoEventNonlinear; 


model NoEventNonlinear1
    
    Real x = y * 2;
    Real y = z / 2;
    Real z = noEvent(x*x);
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="NoEventNonlinear1",
            description="",
            methodName="printDAEBLT",
            methodResult="
--- Torn system (Block 1) of 1 iteration variables and 2 solved variables ---
Torn variables:
  z
  y

Iteration variables:
  x ()

Torn equations:
  z := noEvent(x * x)
  y := z / 2

Residual equations:
  x = y * 2
    Iteration variables: x
-------------------------------
")})));
end NoEventNonlinear1; 

model NoEventNonlinear2
    
    Real x = y * 2;
    Real y = z / 2;
    Real z = noEvent(x)*noEvent(x);
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="NoEventNonlinear2",
            description="",
            eliminate_linear_equations=false,
            methodName="printDAEBLT",
            methodResult="
--- Torn system (Block 1) of 1 iteration variables and 2 solved variables ---
Torn variables:
  z
  y

Iteration variables:
  x ()

Torn equations:
  z := x * x
  y := z / 2

Residual equations:
  x = y * 2
    Iteration variables: x
-------------------------------
")})));
end NoEventNonlinear2; 

    model DivisionSmallConstant
        constant Real small_1 = 2E-11;
        constant Real small_2 = 1E-11;
        Real x;
        Real y(start=0.5);
    equation
        x*y=1;
        x*small_1 + y*small_2 = 0;
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="DivisionSmallConstant",
            description="Ensure that division of small numbers isn't done during tearing'",
            methodName="printDAEBLT",
            methodResult="
--- Unsolved system (Block 1) of 2 variables ---
Unknown variables:
  y (start=0.5)
  x ()

Equations:
  x * 2.0E-11 + y * 1.0E-11 = 0
    Iteration variables: y
  x * y = 1
    Iteration variables: x
-------------------------------
"), FClassMethodTestCase(
            name="DivisionSmallConstant_tighterLimit",
            description="Ensure that division of almost to small numbers is possible divider greater than tolerance (1e-11 > 1e-12)",
            methodName="printDAEBLT",
            tearing_division_tolerance=1e-12,
            methodResult="
--- Torn system (Block 1) of 1 iteration variables and 1 solved variables ---
Torn variables:
  y

Iteration variables:
  x ()

Torn equations:
  y := (- x * 2.0E-11) / 1.0E-11

Residual equations:
  x * y = 1
    Iteration variables: x
-------------------------------
")})));
    end DivisionSmallConstant;
end TearingTests;
