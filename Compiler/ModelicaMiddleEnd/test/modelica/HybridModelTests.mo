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


package HybridModelTests
    package PreMerge
        /**
         * Tests that ensure that all pre(x) variable references are merged
         * into the same block that assigns x.
         */
        model Test1
            Integer i;
            Real x, y;
            Boolean b;
        equation
            der(x) = if pre(i) == 0 then 0 else 1;
            der(y) = if i == 0 then 2 else 3;
            b = sin(time) >= 0;
            i = if b then 1 else 0;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test1",
                description="Testing of hybrid models with pre variable that don't need to be iterated in block",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  b := sin(time) >= 0
  --- Solved equation ---
  i := if b then 1 else 0
  --- Solved equation ---
  der(x) := if pre(i) == 0 then 0 else 1

--- Solved equation ---
der(y) := if i == 0 then 2 else 3
-------------------------------
")})));
        end Test1;
        
        model Test2
            Real x, y;
            Integer i;
        equation
            x + pre(i) = y;
            i = if x >= 0 then 1 else 2;
            y = 3 * sin(time);
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test2",
                description="Testing of hybrid models with pre variable that need to be iterated in block",
                methodName="printDAEBLT",
                methodResult="
--- Solved equation ---
y := 3 * sin(time)

--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  x := - pre(i) + y
  --- Solved equation ---
  i := if x >= 0 then 1 else 2
-------------------------------
")})));
        end Test2;
    
        model Test3
            Real x, y, z;
            Integer i, j;
        equation
            y = 3 * sin(time);
            x + pre(i) = y;
            i = if x >= 0 then 1 else 2;
            z + pre(i) + pre(j) = y;
            j = if x >= 0 and z>=0 then 1 else 2;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test3",
                description="Testing of hybrid models with pre variables that need to be iterated in two separate blocks",
                methodName="printDAEBLT",
                methodResult="
--- Solved equation ---
y := 3 * sin(time)

--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  x := - pre(i) + y
  --- Solved equation ---
  z := - pre(i) + (- pre(j)) + y
  --- Solved equation ---
  j := if x >= 0 and z >= 0 then 1 else 2
  --- Solved equation ---
  i := if x >= 0 then 1 else 2
-------------------------------
")})));
        end Test3;
    
        model Test4
            discrete Real x_d;
            Real x_c;
        initial equation
            x_c = 1;
        equation
            der(x_c) = (-x_c) + x_d;
            when sample(0, 1) then
                x_d = x_c + 1;
            end when;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test4",
                description="Test interaction between continuous and discrete equations",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Meta equation block ---
  assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  temp_1 := not initial() and time >= pre(_sampleItr_1)
  --- Solved equation ---
  x_d := if temp_1 and not pre(temp_1) then x_c + 1 else pre(x_d)
  --- Solved equation ---
  _sampleItr_1 := if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)

--- Solved equation ---
der(x_c) := - x_c + x_d
-------------------------------

")})));
        end Test4;
    
        model Test5
            discrete Real x_d;
            Real x_c;
        initial equation
            x_c = 1;
        equation
            0 = (-x_c) + x_d;
            when sample(0, 1) then
                x_d = x_c + 1;
            end when;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test5",
                description="TODO: this model should give an error",
                methodName="printDAEBLT",
                methodResult="
--- Torn mixed linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: discrete-time
Torn variables:
  x_d

Iteration variables:
  x_c

Solved discrete variables:
  temp_1
  _sampleItr_1

Torn equations:
  x_d := if temp_1 and not pre(temp_1) then x_c + 1 else pre(x_d)

Continuous residual equations:
  0 = - x_c + x_d
    Iteration variables: x_c

Discrete equations:
  temp_1 := not initial() and time >= pre(_sampleItr_1)
  _sampleItr_1 := if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)

Meta equations:
  assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\")

Jacobian:
  |1.0, - (if temp_1 and not pre(temp_1) then 1.0 else 0.0)|
  |-1.0, 1.0|
-------------------------------
")})));
        end Test5;
    
        model Test6
            discrete Real x_d;
            Real x_c;
        initial equation
            x_c = 1;
        equation
            0 = (-x_c) + pre(x_d);
            when sample(0, 1) then
                x_d = x_c + 1;
            end when;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test6",
                description="A case which gives bigger block with local pre handling, but avoid global iteration",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Meta equation block ---
  assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  temp_1 := not initial() and time >= pre(_sampleItr_1)
  --- Solved equation ---
  _sampleItr_1 := if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)
  --- Solved equation ---
  x_c := pre(x_d)
  --- Solved equation ---
  x_d := if temp_1 and not pre(temp_1) then x_c + 1 else pre(x_d)
-------------------------------
")})));
        end Test6;
    
        model Test7
            discrete Real x_d;
            Real x_c;
        initial equation
            x_c = 1;
        equation
            0 = (-x_c) + x_d;
            when sample(0, 1) then
                x_d = pre(x_c) + 1;
            end when;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test7",
                description="A case which gives bigger block with local pre handling, but avoid global iteration",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Meta equation block ---
  assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  temp_1 := not initial() and time >= pre(_sampleItr_1)
  --- Solved equation ---
  x_d := if temp_1 and not pre(temp_1) then pre(x_c) + 1 else pre(x_d)
  --- Solved equation ---
  _sampleItr_1 := if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)

--- Solved equation ---
x_c := x_d
-------------------------------
")})));
        end Test7;
    
        model Test8
            Real x;
            discrete Real y;
            Integer i;
        equation
            i = if time >= 3 then 1 else 0;
            when sample(0, 1) then
                y = pre(y) + 1;
            end when;
            der(x) = (if pre(y) >= 3 then 1 else 2) + (if pre(i) == 4 then 5 else 6);
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test8",
                description="A case which gives bigger block with local pre handling, but avoid global iteration",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Meta equation block ---
  assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  der(x) := (if pre(y) >= 3 then 1 else 2) + (if pre(i) == 4 then 5 else 6)
  --- Solved equation ---
  temp_1 := not initial() and time >= pre(_sampleItr_1)
  --- Solved equation ---
  y := if temp_1 and not pre(temp_1) then pre(y) + 1 else pre(y)
  --- Solved equation ---
  _sampleItr_1 := if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)
  --- Solved equation ---
  i := if time >= 3 then 1 else 0
-------------------------------
")})));
        end Test8;
    
        model Test9
            parameter Real tau0_max = 0.15, tau0 = 0.10;
            Real sa;
            Boolean locked(start=true), startForward(start=false);
        equation
            sa = if locked then tau0_max+1e-4 else tau0+1e-4;
            startForward = sa > tau0_max or pre(startForward) and sa > tau0;
            locked = not startForward;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="PreMerge.Test9",
                description="A test that simulates the common friction problems",
                methodName="printDAEBLT",
                methodResult="
--- Unsolved mixed linear system (Block 1) of 3 variables ---
Coefficient variability: constant
Unknown continuous variables:
  sa

Solved discrete variables:
  startForward
  locked

Continuous residual equations:
  sa = if locked then tau0_max + 1.0E-4 else tau0 + 1.0E-4
    Iteration variables: sa

Discrete equations:
  startForward := sa > tau0_max or pre(startForward) and sa > tau0
  locked := not startForward

Jacobian:
  |1.0|
-------------------------------
")})));
        end Test9;
    end PreMerge;
    
    package EventPreMerge
        /**
         * Tests that tests so that upstream event generating exps are merged
         * into the same block as all downstream pre variable references.
         */
        model Simple1 // FAILS
            Boolean a = time > 0.5;
            Boolean b = a and not pre(a);
            Boolean c = b and true;
            Real x;
        equation
            when c then
                x = time;
            end when;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.Simple1",
                description="A simple testcase that ensure that equations asigning a and x are in the same block",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a := time > 0.5
  --- Solved equation ---
  b := a and not pre(a)
  --- Solved equation ---
  c := b and true
  --- Solved equation ---
  x := if c and not pre(c) then time else pre(x)
-------------------------------
")})));
        end Simple1;
        
        model Simple2
            Boolean a = sample(0.5, 1);
            Boolean b = a and true;
            Real x;
        equation
            when b then
                x = time;
            end when;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.Simple2",
                description="A simple testcase that ensure that equations asigning a and x are in the same block",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a := not initial() and time >= 0.5 + pre(_sampleItr_1)
  --- Solved equation ---
  b := a and true
  --- Solved equation ---
  x := if b and not pre(b) then time else pre(x)
  --- Meta equation block ---
  assert(time < 0.5 + (pre(_sampleItr_1) + 1), \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  _sampleItr_1 := if a and not pre(a) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)
-------------------------------
")})));
        end Simple2;
        
        model TwoSeparate1
            Boolean a = sample(0.5, 1);
            Boolean b = a and true;
            Boolean c = time > 0.75;
            Real x;
            Real y;
        equation
            when b then
                x = time;
            end when;
            when c then
                y = time;
            end when;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.TwoSeparate1",
                description="There are two independent parts of the system which have event equations and pre uses which shouldn't be merged",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a := not initial() and time >= 0.5 + pre(_sampleItr_1)
  --- Solved equation ---
  b := a and true
  --- Solved equation ---
  x := if b and not pre(b) then time else pre(x)
  --- Meta equation block ---
  assert(time < 0.5 + (pre(_sampleItr_1) + 1), \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  _sampleItr_1 := if a and not pre(a) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)

--- Pre propagation block (Block 2) ---
  --- Solved equation ---
  c := time > 0.75
  --- Solved equation ---
  y := if c and not pre(c) then time else pre(y)
-------------------------------
")})));
        end TwoSeparate1;
        
        model SameUpstream1
            Boolean a = time > 0.75;
            Boolean b = a and not pre(a);
            Boolean c1 = (b or b) and true;
            Boolean c2 = (b or b) and true;
            Real x1;
            Real x2;
        equation
            when c1 then
                x1 = time;
            end when;
            when c2 then
                x2 = time;
            end when;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.SameUpstream1",
                description="Two when equations which share the same upstream block to merge",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a := time > 0.75
  --- Solved equation ---
  b := a and not pre(a)
  --- Solved equation ---
  c2 := (b or b) and true
  --- Solved equation ---
  x2 := if c2 and not pre(c2) then time else pre(x2)
  --- Solved equation ---
  c1 := (b or b) and true
  --- Solved equation ---
  x1 := if c1 and not pre(c1) then time else pre(x1)
-------------------------------
")})));
        end SameUpstream1;
        
        model TwoUpstream1
            Boolean a1 = time > 0.75;
            Boolean b1 = a1 and not pre(a1);
            Boolean a2 = time > 0.5;
            Boolean b2 = a2 and not pre(a2);
            Boolean c = (b1 or b2) and true;
            Real x;
        equation
            when c then
                x = time;
            end when;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.TwoUpstream1",
                description="One when equation which has two upstream blocks to merge",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a1 := time > 0.75
  --- Solved equation ---
  b1 := a1 and not pre(a1)
  --- Solved equation ---
  a2 := time > 0.5
  --- Solved equation ---
  b2 := a2 and not pre(a2)
  --- Solved equation ---
  c := (b1 or b2) and true
  --- Solved equation ---
  x := if c and not pre(c) then time else pre(x)
-------------------------------
")})));
        end TwoUpstream1;
        
        model IndependentMiddle1
            Boolean a;
            Boolean b;
            Boolean c;
            Real m;
            Real x;
        equation
            a = time > 0.5;
            b = a and not pre(a);
            c = b and true;
            m = sin(time);
            when c then
                x = m;
            end when;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.IndependentMiddle1",
                description="Ensures that m equation is ordered correctly and not merged",
                methodName="printDAEBLT",
                methodResult="
--- Solved equation ---
m := sin(time)

--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a := time > 0.5
  --- Solved equation ---
  b := a and not pre(a)
  --- Solved equation ---
  c := b and true
  --- Solved equation ---
  x := if c and not pre(c) then m else pre(x)
-------------------------------
")})));
        end IndependentMiddle1;
        
        model IndependentMiddle2
            Boolean a;
            Boolean b;
            Boolean c;
            Real m;
            Real x;
        equation
            a = time > 0.5;
            b = a and not pre(a);
            m = if b then 1 else 0;
            c = b and true;
            when c then
                x = time;
            end when;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.IndependentMiddle2",
                description="Ensures that m equation is ordered correctly and not merged",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a := time > 0.5
  --- Solved equation ---
  b := a and not pre(a)
  --- Solved equation ---
  c := b and true
  --- Solved equation ---
  x := if c and not pre(c) then time else pre(x)

--- Solved equation ---
m := if b then 1 else 0
-------------------------------
")})));
        end IndependentMiddle2;
        
        model IndependentDownstream1
            Boolean a = time > 0.5;
            Boolean b = a and not pre(a);
            Boolean c = b and true;
            Real x;
            Real y;
        equation
            when c then
                x = time;
            end when;
            y = sin(x);
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.IndependentDownstream1",
                description="Ensures that y equation is ordered correctly and not merged",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  a := time > 0.5
  --- Solved equation ---
  b := a and not pre(a)
  --- Solved equation ---
  c := b and true
  --- Solved equation ---
  x := if c and not pre(c) then time else pre(x)

--- Solved equation ---
y := sin(x)
-------------------------------
")})));
        end IndependentDownstream1;


        model PreMergeInteraction
            Boolean sample1 = sample(1, 0.4);
            Real a,b,c;
        equation
            when sample1 then
                a = sin(time);
                c = b - 2;
            end when;
            b = a + 2;

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.PreMergeInteraction",
                description="Ensures event and pre merge interacts well with pre merge",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  sample1 := not initial() and time >= 1 + pre(_sampleItr_1) * 0.4
  --- Solved equation ---
  a := if sample1 and not pre(sample1) then sin(time) else pre(a)
  --- Solved equation ---
  b := a + 2
  --- Meta equation block ---
  assert(time < 1 + (pre(_sampleItr_1) + 1) * 0.4, \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  c := if sample1 and not pre(sample1) then b - 2 else pre(c)
  --- Solved equation ---
  _sampleItr_1 := if sample1 and not pre(sample1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)
-------------------------------
")})));
        end PreMergeInteraction;

        model DiscreteRealMerge
            discrete Real x;
            discrete Real y;
        equation
            when time > 0.25 then
                x = 2*x + y + 1;
            end when;
            when time > 0.5 then
                y = 3*x - 4*y + 1;
            end when;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.DiscreteRealMerge",
                description="Ensures that we merge discrete reals into the pre block and not nested",
                methodName="printDAEBLT",
                methodResult="
--- Torn mixed linear system (Block 1) of 2 iteration variables and 0 solved variables ---
Coefficient variability: discrete-time
Torn variables:

Iteration variables:
  y
  x

Solved discrete variables:
  temp_2
  temp_1

Torn equations:

Continuous residual equations:
  y = if temp_2 and not pre(temp_2) then 3 * x - 4 * y + 1 else pre(y)
    Iteration variables: y
  x = if temp_1 and not pre(temp_1) then 2 * x + y + 1 else pre(x)
    Iteration variables: x

Discrete equations:
  temp_2 := time > 0.5
  temp_1 := time > 0.25

Jacobian:
  |1.0 - (if temp_2 and not pre(temp_2) then -4 else 0.0), - (if temp_2 and not pre(temp_2) then 3 else 0.0)|
  |- (if temp_1 and not pre(temp_1) then 1.0 else 0.0), 1.0 - (if temp_1 and not pre(temp_1) then 2 else 0.0)|
-------------------------------
")})));
        end DiscreteRealMerge;
        
        model DiscreteRealMerge2
            Real a;
            Real b(start=1.0);
            Real c;
            Real d;
        equation
            when time > 0.5 then
                a = time+0.5;
                c = pre(a) + b;
            end when;
            -b = a + d^2-2;
            d=if b > 2.0 then 2.0 else if b < 1.0 then 1.0 else b;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.DiscreteRealMerge2",
                description="Ensures that we merge switches into the pre block and not nested",
                methodName="printDAEBLT",
                methodResult="
--- Torn mixed system (Block 1) of 1 iteration variables and 3 solved variables ---
Torn variables:
  d
  c
  a

Iteration variables:
  b (start=1.0)

Solved discrete variables:
  temp_1

Torn equations:
  d := if b > 2.0 then 2.0 elseif b < 1.0 then 1.0 else b
  c := if temp_1 and not pre(temp_1) then pre(a) + b else pre(c)
  a := if temp_1 and not pre(temp_1) then time + 0.5 else pre(a)

Continuous residual equations:
  - b = a + d ^ 2 - 2
    Iteration variables: b

Discrete equations:
  temp_1 := time > 0.5
-------------------------------
")})));
        end DiscreteRealMerge2;
        
        model DiscreteRealMerge3
            Real a;
            Real b(start=1.0);
            Real c;
            Real d;
            parameter Real p;
        equation
            when time > 0.5 then
                a = time+0.5;
                c = pre(a) + b;
            end when;
            -b = a + d^2-2;
            d=if p > 2.0 then 2.0 else if p < 1.0 then 1.0 else b;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.DiscreteRealMerge3",
                description="Ensures that we don't merge relational expressions without events into the pre block",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  temp_1 := time > 0.5
  --- Solved equation ---
  a := if temp_1 and not pre(temp_1) then time + 0.5 else pre(a)
  --- Torn system (Block 1.1) of 1 iteration variables and 1 solved variables ---
  Torn variables:
    d

  Iteration variables:
    b (start=1.0)

  Torn equations:
    d := if p > 2.0 then 2.0 elseif p < 1.0 then 1.0 else b

  Residual equations:
    - b = a + d ^ 2 - 2
      Iteration variables: b
  --- Solved equation ---
  c := if temp_1 and not pre(temp_1) then pre(a) + b else pre(c)
-------------------------------
")})));
        end DiscreteRealMerge3;
        
        model DiscreteRealMerge4
            Real a;
            Real b(start=1.0);
            Real c;
            Real d;
            Real x;
        equation
            der(x) = time;
            when time > 0.5 then
                a = time+0.5;
                c = pre(a) + b;
            end when;
            -b = a + d^2-2;
            d=if x > 2.0 then 2.0 else if x < 1.0 then 1.0 else b;
        
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.DiscreteRealMerge4",
                description="Ensures that we don't merge switches which does not depend on the block into the pre block",
                methodName="printDAEBLT",
                methodResult="
--- Solved equation ---
der(x) := time

--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  temp_1 := time > 0.5
  --- Solved equation ---
  a := if temp_1 and not pre(temp_1) then time + 0.5 else pre(a)
  --- Torn system (Block 1.1) of 1 iteration variables and 1 solved variables ---
  Torn variables:
    d

  Iteration variables:
    b (start=1.0)

  Torn equations:
    d := if x > 2.0 then 2.0 elseif x < 1.0 then 1.0 else b

  Residual equations:
    - b = a + d ^ 2 - 2
      Iteration variables: b
  --- Solved equation ---
  c := if temp_1 and not pre(temp_1) then pre(a) + b else pre(c)
-------------------------------
")})));
        end DiscreteRealMerge4;
        
        model Big1
            Boolean d1; 
            Boolean d2; 
            Boolean d3;
            Boolean d4;
            Boolean d5;
            Boolean d6(start=true);
            Boolean d7; 
            Boolean d8;
            Boolean d9(start=false);
            Boolean d16(start=true);
        initial equation
            d1=false;
            pre(d2)=pre(d1);
            d3 = true;
            pre(d4)=pre(d3);
            d7 = false;
            pre(d8)=pre(d7);
        equation 
            d1 = pre(d2);
            d3 = pre(d4);
            d5 = d3 and not d1;
            d6 = d1 or d5;
            d7 = pre(d8);
            d9 = d7 and not d6;
            d16 = d1 and not d7;
            d8 = (d16 or d7 and not d9);
            d2 = ((d5 or d9) or d1 and not d16);
            d4 = d3 and not d5;
        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="EventPreMerge.Big1",
                description="An bigger \"real world\" example",
                methodName="printDAEBLT",
                methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  d1 := pre(d2)
  --- Solved equation ---
  d3 := pre(d4)
  --- Solved equation ---
  d5 := d3 and not d1
  --- Solved equation ---
  d6 := d1 or d5
  --- Solved equation ---
  d7 := pre(d8)
  --- Solved equation ---
  d16 := d1 and not d7
  --- Solved equation ---
  d9 := d7 and not d6
  --- Solved equation ---
  d8 := d16 or d7 and not d9
  --- Solved equation ---
  d4 := d3 and not d5
  --- Solved equation ---
  d2 := d5 or d9 or d1 and not d16
-------------------------------
")})));
        end Big1;
    end EventPreMerge;
    
    model WhenAndPreTest1
        Real xx(start=2);
        discrete Real x; 
        discrete Real y; 
        discrete Boolean w(start=true); 
        discrete Boolean v(start=true); 
        discrete Boolean z(start=true); 
    equation
        when sample(0,1) then 
            x = pre(x) + 1.1; 
            y = pre(y) + 1.1; 
        end when; 
    
        der(xx) = -x; 
    
        when y > 2 and pre(z) then 
            w = false; 
        end when; 
    
        when x > 2 then 
            z = false; 
        end when; 
    
        when y > 2 and z then 
            v = false; 
        end when; 
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="WhenAndPreTest1",
            description="Test complicated when and pre variable case",
            methodName="printDAEBLT",
            methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  temp_1 := not initial() and time >= pre(_sampleItr_1)
  --- Solved equation ---
  y := if temp_1 and not pre(temp_1) then pre(y) + 1.1 else pre(y)
  --- Solved equation ---
  x := if temp_1 and not pre(temp_1) then pre(x) + 1.1 else pre(x)
  --- Solved equation ---
  temp_3 := x > 2
  --- Solved equation ---
  z := if temp_3 and not pre(temp_3) then false else pre(z)
  --- Solved equation ---
  temp_4 := y > 2 and z
  --- Solved equation ---
  v := if temp_4 and not pre(temp_4) then false else pre(v)
  --- Solved equation ---
  temp_2 := y > 2 and pre(z)
  --- Solved equation ---
  w := if temp_2 and not pre(temp_2) then false else pre(w)
  --- Meta equation block ---
  assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\")
  --- Solved equation ---
  _sampleItr_1 := if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1)

--- Solved equation ---
der(xx) := - x
-------------------------------
")})));
    end WhenAndPreTest1;
    
    model NoResTest1
        function F
            input Real i1;
            input Real i2;
            output Real o;
        algorithm
            assert(i1 == 0, "Oh, no!");
            assert(i2 == 0, "Oh, no!");
            o := 3.14 / i1 + 42 / i2;
            annotation(Inline=false);
        end F;
        Real next, x;
    initial equation
        pre(next) = 0;
    equation
        when time >= pre(next) then
            next = pre(next) + 1;
        end when;
        x = F(next, pre(next));
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="NoResTest1",
            description="Verify that no residuals are added to the block even though it contains continuous equations",
            methodName="printDAEBLT",
            methodResult="
--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  temp_1 := time >= pre(next)
  --- Solved equation ---
  next := if temp_1 and not pre(temp_1) then pre(next) + 1 else pre(next)
  --- Solved equation ---
  x := HybridModelTests.NoResTest1.F(next, pre(next))
-------------------------------
")})));
    end NoResTest1;
    
    model MixedVariabilityMatch1
        parameter Real a(fixed=false);
        Real b;
    initial equation
        b = 1;
    equation
        b = sin(a + time);
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="MixedVariabilityMatch1",
            description="Verify that a noncontinuous variable can be matched to and continuous equation in the initial system",
            methodName="printDAEInitBLT",
            methodResult="
--- Solved equation ---
b := 1

--- Unsolved equation (Block 1) ---
b = sin(a + time)
  Computed variables: a
-------------------------------
")})));
    end MixedVariabilityMatch1;
    
    model ParameterVarEventExp1
        parameter Boolean p1 = true;
        Real a = if p1 then time else -time;
        
        Boolean b = a > 0.5;
        Boolean c = b and not pre(b);
        Boolean d = c and true;
        Real x;
    equation
        when d then
            x = time;
        end when;
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ParameterVarEventExp1",
            description="Verify that event generating expressions with parameter variability ins't merged'",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
a := if p1 then time else - time

--- Pre propagation block (Block 1) ---
  --- Solved equation ---
  b := a > 0.5
  --- Solved equation ---
  c := b and not pre(b)
  --- Solved equation ---
  d := c and true
  --- Solved equation ---
  x := if d and not pre(d) then time else pre(x)
-------------------------------
")})));
    end ParameterVarEventExp1;

end HybridModelTests;