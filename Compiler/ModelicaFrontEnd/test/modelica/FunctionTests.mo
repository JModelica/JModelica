/*
    Copyright (C) 2009-2017 Modelon AB

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


package FunctionTests 

/* Functions used in tests. */
function TestFunction0
 output Real o1 = 0;
algorithm
 return;
end TestFunction0;

function TestFunction1
 input Real i1 = 0;
 output Real o1 = i1;
algorithm
end TestFunction1;

function TestFunction2
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = 0;
 output Real o2 = i2;
algorithm
 o1 := i1;
end TestFunction2;

function TestFunction3
 input Real i1;
 input Real i2;
 input Real i3 = 0;
 output Real o1 = i1 + i2 + i3;
 output Real o2 = i2 + i3;
 output Real o3 = i1 + i2;
algorithm
end TestFunction3;

function TestFunctionString
 input String i1;
 output String o1 = i1;
algorithm
end TestFunctionString;

function TestFunctionCallingFunction
 input Real i1;
 output Real o1;
algorithm
 o1 := TestFunction1(i1);
end TestFunctionCallingFunction;

function TestFunctionRecursive
 input Integer i1;
 output Integer o1;
algorithm
 if i1 < 3 then
  o1 := 1;
 else
  o1 := TestFunctionRecursive(i1 - 1) + TestFunctionRecursive(i1 - 2);
 end if;
end TestFunctionRecursive;

function TestFunctionWithConst
 input Real x = 1;
 output Real y = x + A + B + C;
protected
 constant Real A = 1;
 constant Real B = 2;
 constant Real C = 3;
algorithm
end TestFunctionWithConst;


/* Temporary functions for manual C-tests */

function Func00
algorithm
 return;
end Func00;

function Func10
 input Real i1 = 0;
algorithm
 return;
end Func10;

function Func01
 output Real o1 = 0;
algorithm
 return;
end Func01;

function Func11
 input Real i1 = 0;
 output Real o1 = i1;
algorithm
 return;
end Func11;

function Func21
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = i1 + i2;
algorithm
 return;
end Func21;

function Func02
 output Real o1 = 0;
 output Real o2 = 1;
algorithm
 return;
end Func02;

function Func12
 input Real i1 = 0;
 output Real o1 = i1;
 output Real o2 = 1;
algorithm
 return;
end Func12;

function Func22
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = i1 + i2;
 output Real o2 = 1;
algorithm
 for i in 1:3 loop
   o1 := o1 + 1;
   o2 := o2 - o1;
 end for;
 return;
end Func22;


/* ====================== Functions ====================== */

model FunctionFlatten1
 Real x;
equation
 x = TestFunction1(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten1",
            description="Flattening functions: simple function call",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten1
 Real x;
equation
 x = FunctionTests.TestFunction1(1);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionFlatten1;
")})));
end FunctionFlatten1;


model FunctionFlatten2
 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction2(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten2",
            description="Flattening functions: two calls to same function",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten2
 Real x;
 Real y = FunctionTests.TestFunction2(2, 3);
equation
 x = FunctionTests.TestFunction2(1, 0);

public
 function FunctionTests.TestFunction2
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := 0;
  o2 := i2;
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;

end FunctionTests.FunctionFlatten2;
")})));
end FunctionFlatten2;


model FunctionFlatten3
 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction1(y * 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten3",
            description="Flattening functions: calls to two functions",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten3
 Real x;
 Real y = FunctionTests.TestFunction2(2, 3);
equation
 x = FunctionTests.TestFunction1(y * 2);

public
 function FunctionTests.TestFunction2
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := 0;
  o2 := i2;
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;

 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionFlatten3;
")})));
end FunctionFlatten3;


model FunctionFlatten4
 Real x = TestFunctionWithConst(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten4",
            description="Flattening functions: function containing constants",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.FunctionFlatten4
 Real x;
equation
 x = FunctionTests.TestFunctionWithConst(2);

public
 function FunctionTests.TestFunctionWithConst
  input Real x;
  output Real y;
 algorithm
  y := x + 1.0 + 2.0 + 3.0;
  return;
 end FunctionTests.TestFunctionWithConst;

end FunctionTests.FunctionFlatten4;
")})));
end FunctionFlatten4;


model FunctionFlatten5
	model A
		Real x;
	equation
		x = TestFunction1(1);
	end A;
	
	model B
		extends A;
	end B;
	
	B y;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten5",
            description="Flattening functions: function called in extended class",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten5
 Real y.x;
equation
 y.x = FunctionTests.TestFunction1(1);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionFlatten5;
")})));
end FunctionFlatten5;


model FunctionFlatten6
	model A
		Real x;
	end A;
	
	model B = A(x = TestFunction1(1));
	
	B y;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten6",
            description="Flattening functions: function called in class modification",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten6
 Real y.x = FunctionTests.TestFunction1(1);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionFlatten6;
")})));
end FunctionFlatten6;


model FunctionFlatten7
	package A
		constant Real c = 1;
		function f
			output Real a = c;
		algorithm
		end f;
	end A;
	
	package B
		extends A(c = 2);
	end B;
	
	package C
		extends A(c = 3);
	end C;
	
	Real x = A.f();
	Real y = B.f();
	Real z = C.f();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten7",
            description="Calling different inherited versions of same function",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten7
 Real x = FunctionTests.FunctionFlatten7.A.f();
 Real y = FunctionTests.FunctionFlatten7.B.f();
 Real z = FunctionTests.FunctionFlatten7.C.f();

public
 function FunctionTests.FunctionFlatten7.A.f
  output Real a;
 algorithm
  a := 1.0;
  return;
 end FunctionTests.FunctionFlatten7.A.f;

 function FunctionTests.FunctionFlatten7.B.f
  output Real a;
 algorithm
  a := 2.0;
  return;
 end FunctionTests.FunctionFlatten7.B.f;

 function FunctionTests.FunctionFlatten7.C.f
  output Real a;
 algorithm
  a := 3.0;
  return;
 end FunctionTests.FunctionFlatten7.C.f;

end FunctionTests.FunctionFlatten7;
")})));
end FunctionFlatten7;


model FunctionFlatten8
	function f
		output Real x = 1;
	algorithm
	end f;
	
	model A
		Real x;
	equation
		x = f();
	end A;
	
	A y;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten8",
            description="Calling function from parallel class",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten8
 Real y.x;
equation
 y.x = FunctionTests.FunctionFlatten8.f();

public
 function FunctionTests.FunctionFlatten8.f
  output Real x;
 algorithm
  x := 1;
  return;
 end FunctionTests.FunctionFlatten8.f;

end FunctionTests.FunctionFlatten8;
")})));
end FunctionFlatten8;


model FunctionFlatten9
    constant Real[3] a = {1,2,3};
    
    function f
        input Real[2] x;
		input Integer i;
        output Real[2] y;
    algorithm
        y := x .+ a[i] .+ a[i+1];
        annotation(Inline=false);
    end f;
    
    Real[2] z = f({3,4}, 1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten9",
            description="Require copying of same constant array twice",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten9
 constant Real a[1] = 1;
 constant Real a[2] = 2;
 constant Real a[3] = 3;
 Real z[1];
 Real z[2];
global variables
 constant Real FunctionTests.FunctionFlatten9.a[3] = {1, 2, 3};
equation
 ({z[1], z[2]}) = FunctionTests.FunctionFlatten9.f({3, 4}, 1);

public
 function FunctionTests.FunctionFlatten9.f
  input Real[:] x;
  input Integer i;
  output Real[:] y;
 algorithm
  init y as Real[2];
  for i1 in 1:2 loop
   y[i1] := x[i1] .+ global(FunctionTests.FunctionFlatten9.a[i]) .+ global(FunctionTests.FunctionFlatten9.a[i + 1]);
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.FunctionFlatten9.f;

end FunctionTests.FunctionFlatten9;
")})));
end FunctionFlatten9;


model FunctionFlatten10
    function f1
        input Real x;
        output Real y;
    end f1;
    
    function f2
        extends f1;
    end f2;
    
    function f3
        extends f2;
    algorithm
        y := x;
    end f3;
    
    Real z = f3(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten10",
            description="Multi-level extending of functions",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten10
 Real z = FunctionTests.FunctionFlatten10.f3(1);

public
 function FunctionTests.FunctionFlatten10.f3
  input Real x;
  output Real y;
 algorithm
  y := x;
  return;
 end FunctionTests.FunctionFlatten10.f3;

end FunctionTests.FunctionFlatten10;
")})));
end FunctionFlatten10;


model FunctionFlatten11
    function f0
        input Real x;
        output Real y;
    end f0;
    
    function f1
        extends f0;
    algorithm
        y := x;
    end f1;
    
    function f2
        extends f0;
    algorithm
        y := x + 1;
    end f2;
    
	model A
		replaceable function f3 = f1 constrainedby f0;
		Real x = 1;
		Real y = f3(x);
	end A;
	
	model B = A(redeclare function f3 = f2);
	
	model C
		extends A;
		redeclare function f3 = f2;
	end C;
	
	B b;
	C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten11",
            description="Using redeclared function in model",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten11
 Real b.x = 1;
 Real b.y = FunctionTests.FunctionFlatten11.f2(b.x);
 Real c.x = 1;
 Real c.y = FunctionTests.FunctionFlatten11.f2(c.x);

public
 function FunctionTests.FunctionFlatten11.f2
  input Real x;
  output Real y;
 algorithm
  y := x + 1;
  return;
 end FunctionTests.FunctionFlatten11.f2;

end FunctionTests.FunctionFlatten11;
")})));
end FunctionFlatten11;


model FunctionFlatten12
	function f
		input Real[:] x;
		output Real y;
	algorithm
		y := min(size(x));
	end f;
	
	constant Real z = f({1,2,3});
	Real w = z;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten12",
            description="Size of function input with unknown size as argument to min",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten12
 constant Real z = 3;
 Real w;
equation
 w = 3.0;
end FunctionTests.FunctionFlatten12;
")})));
end FunctionFlatten12;

model FunctionFlatten13
    record R
        Real x;
    end R;
    function f
      input Real a;
      output R r(x=a);
    algorithm
    annotation(Inline=false);
    end f;
    
    R r = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten13",
            description="Modifying records in functions",
            flatModel="
fclass FunctionTests.FunctionFlatten13
 Real r.x;
equation
 (FunctionTests.FunctionFlatten13.R(r.x)) = FunctionTests.FunctionFlatten13.f(time);

public
 function FunctionTests.FunctionFlatten13.f
  input Real a;
  output FunctionTests.FunctionFlatten13.R r;
 algorithm
  r.x := a;
  return;
 annotation(Inline = false);
 end FunctionTests.FunctionFlatten13.f;

 record FunctionTests.FunctionFlatten13.R
  Real x;
 end FunctionTests.FunctionFlatten13.R;

end FunctionTests.FunctionFlatten13;
")})));
end FunctionFlatten13;

model FunctionFlatten14
    record R1
        Real x;
        R2 r2;
        Real y = 3;
    end R1;
    record R2
        Real x;
    end R2;
    function f
      input Real a;
      output R1 r(x=a, r2(x=a+a));
    algorithm
    annotation(Inline=false);
    end f;
    
    R1 r = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten14",
            description="Modifying records in functions",
            flatModel="
fclass FunctionTests.FunctionFlatten14
 Real r.x;
 Real r.r2.x;
 Real r.y;
equation
 (FunctionTests.FunctionFlatten14.R1(r.x, FunctionTests.FunctionFlatten14.R2(r.r2.x), r.y)) = FunctionTests.FunctionFlatten14.f(time);

public
 function FunctionTests.FunctionFlatten14.f
  input Real a;
  output FunctionTests.FunctionFlatten14.R1 r;
 algorithm
  r.x := a;
  r.r2.x := a + a;
  r.y := 3;
  return;
 annotation(Inline = false);
 end FunctionTests.FunctionFlatten14.f;

 record FunctionTests.FunctionFlatten14.R2
  Real x;
 end FunctionTests.FunctionFlatten14.R2;

 record FunctionTests.FunctionFlatten14.R1
  Real x;
  FunctionTests.FunctionFlatten14.R2 r2;
  Real y;
 end FunctionTests.FunctionFlatten14.R1;

end FunctionTests.FunctionFlatten14;
")})));
end FunctionFlatten14;

model FunctionFlatten15
    record R1
        R2 r2 = R2(3);
    end R1;
    record R2
        Real x;
    end R2;
    function f
      input Real a;
      output R1 r(r2(x=a+a));
    algorithm
    annotation(Inline=false);
    end f;
    
    R1 r = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten15",
            description="Modifying records in functions",
            flatModel="
fclass FunctionTests.FunctionFlatten15
 Real r.r2.x;
equation
 (FunctionTests.FunctionFlatten15.R1(FunctionTests.FunctionFlatten15.R2(r.r2.x))) = FunctionTests.FunctionFlatten15.f(time);

public
 function FunctionTests.FunctionFlatten15.f
  input Real a;
  output FunctionTests.FunctionFlatten15.R1 r;
 algorithm
  r.r2.x := 3;
  return;
 annotation(Inline = false);
 end FunctionTests.FunctionFlatten15.f;

 record FunctionTests.FunctionFlatten15.R2
  Real x;
 end FunctionTests.FunctionFlatten15.R2;

 record FunctionTests.FunctionFlatten15.R1
  FunctionTests.FunctionFlatten15.R2 r2;
 end FunctionTests.FunctionFlatten15.R1;

end FunctionTests.FunctionFlatten15;
")})));
end FunctionFlatten15;

model FunctionFlatten16
    record R1
        R2 r2;
    end R1;
    record R2
        Real x;
    end R2;
    function f
      input Real a;
      output R1[2] r(each r2(x=a+a));
    algorithm
    annotation(Inline=false);
    end f;
    
    R1[2] r = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten16",
            description="Modifying record arrays in functions",
            flatModel="
fclass FunctionTests.FunctionFlatten16
 Real r[1].r2.x;
 Real r[2].r2.x;
equation
 ({FunctionTests.FunctionFlatten16.R1(FunctionTests.FunctionFlatten16.R2(r[1].r2.x)), FunctionTests.FunctionFlatten16.R1(FunctionTests.FunctionFlatten16.R2(r[2].r2.x))}) = FunctionTests.FunctionFlatten16.f(time);

public
 function FunctionTests.FunctionFlatten16.f
  input Real a;
  output FunctionTests.FunctionFlatten16.R1[:] r;
 algorithm
  init r as FunctionTests.FunctionFlatten16.R1[2];
  r[1].r2.x := a + a;
  r[2].r2.x := a + a;
  return;
 annotation(Inline = false);
 end FunctionTests.FunctionFlatten16.f;

 record FunctionTests.FunctionFlatten16.R2
  Real x;
 end FunctionTests.FunctionFlatten16.R2;

 record FunctionTests.FunctionFlatten16.R1
  FunctionTests.FunctionFlatten16.R2 r2;
 end FunctionTests.FunctionFlatten16.R1;

end FunctionTests.FunctionFlatten16;
")})));
end FunctionFlatten16;

model FunctionFlatten17
    record R1
        R2 r2;
    end R1;
    record R2
        Real x;
    end R2;
    function f
      input Real a;
      output R1[2] r(r2 = {R2(a), R2(a+a)});
    algorithm
    annotation(Inline=false);
    end f;
    
    R1[2] r = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten17",
            description="Modifying record arrays in functions",
            flatModel="
fclass FunctionTests.FunctionFlatten17
 Real r[1].r2.x;
 Real r[2].r2.x;
equation
 ({FunctionTests.FunctionFlatten17.R1(FunctionTests.FunctionFlatten17.R2(r[1].r2.x)), FunctionTests.FunctionFlatten17.R1(FunctionTests.FunctionFlatten17.R2(r[2].r2.x))}) = FunctionTests.FunctionFlatten17.f(time);

public
 function FunctionTests.FunctionFlatten17.f
  input Real a;
  output FunctionTests.FunctionFlatten17.R1[:] r;
 algorithm
  init r as FunctionTests.FunctionFlatten17.R1[2];
  r[1].r2.x := a;
  r[2].r2.x := a + a;
  return;
 annotation(Inline = false);
 end FunctionTests.FunctionFlatten17.f;

 record FunctionTests.FunctionFlatten17.R2
  Real x;
 end FunctionTests.FunctionFlatten17.R2;

 record FunctionTests.FunctionFlatten17.R1
  FunctionTests.FunctionFlatten17.R2 r2;
 end FunctionTests.FunctionFlatten17.R1;

end FunctionTests.FunctionFlatten17;
")})));
end FunctionFlatten17;

model FunctionFlatten18
    function f
        input Real x[:];
        output Real y;
    algorithm
        y := size(x[:],1);
    end f;
    
    Real z = f({1, 2, 3} * time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten18",
            description="Scalarization of size exp containing unknown subscripts",
            inline_functions="none",
            flatModel="
fclass FunctionTests.FunctionFlatten18
 Real z;
equation
 z = FunctionTests.FunctionFlatten18.f({time, 2 * time, 3 * time});

public
 function FunctionTests.FunctionFlatten18.f
  input Real[:] x;
  output Real y;
 algorithm
  y := size(x, 1);
  return;
 end FunctionTests.FunctionFlatten18.f;

end FunctionTests.FunctionFlatten18;
")})));
end FunctionFlatten18;

model FunctionFlatten19
    function f
        input Real x[:];
        output Real y;
    algorithm
        y := size(x[2:size(x,1)],1);
    end f;
    
    Real z = f({1, 2, 3} * time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten19",
            description="Scalarization of size exp containing unknown subscripts",
            inline_functions="none",
            flatModel="
fclass FunctionTests.FunctionFlatten19
 Real z;
equation
 z = FunctionTests.FunctionFlatten19.f({time, 2 * time, 3 * time});

public
 function FunctionTests.FunctionFlatten19.f
  input Real[:] x;
  output Real y;
 algorithm
  y := max(integer(size(x, 1) - 2) + 1, 0);
  return;
 end FunctionTests.FunctionFlatten19.f;

end FunctionTests.FunctionFlatten19;
")})));
end FunctionFlatten19;

model FunctionFlatten20
    function f
        input Real x[:];
        output Real y;
    algorithm
        y := sum(x[2:end]);
    end f;
    
    Real z = f({1, 2, 3} * time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten20",
            description="Scalarization of end",
            inline_functions="none",
            flatModel="
fclass FunctionTests.FunctionFlatten20
 Real z;
equation
 z = FunctionTests.FunctionFlatten20.f({time, 2 * time, 3 * time});

public
 function FunctionTests.FunctionFlatten20.f
  input Real[:] x;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:max(integer(size(x, 1) - 2) + 1, 0) loop
   temp_1 := temp_1 + x[2 + (i1 - 1)];
  end for;
  y := temp_1;
  return;
 end FunctionTests.FunctionFlatten20.f;

end FunctionTests.FunctionFlatten20;
")})));
end FunctionFlatten20;

model FunctionFlatten21
    function f
        constant Real x;
        output Real y = x;
        algorithm
    end f;
    
    Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten21",
            description="Flattening of constant in function",
            flatModel="
fclass FunctionTests.FunctionFlatten21
 Real x = FunctionTests.FunctionFlatten21.f();
global variables
 constant Real FunctionTests.FunctionFlatten21.f.x; // TODO: Compilation error?

public
 function FunctionTests.FunctionFlatten21.f
  output Real y;
 algorithm
  y := global(FunctionTests.FunctionFlatten21.f.x);
  return;
 end FunctionTests.FunctionFlatten21.f;

end FunctionTests.FunctionFlatten21;
")})));
end FunctionFlatten21;

model FunctionFlatten22
    record R
        constant Real x;
    end R;
    
    function f
        input R y;
        output R z;
    algorithm
        z := y;
    end f;
    
    R y = f(R(1));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten22",
            description="Flattening of constant in function",
            flatModel="
fclass FunctionTests.FunctionFlatten22
 constant FunctionTests.FunctionFlatten22.R y = FunctionTests.FunctionFlatten22.R(1);

public
 function FunctionTests.FunctionFlatten22.f
  input FunctionTests.FunctionFlatten22.R y;
  output FunctionTests.FunctionFlatten22.R z;
 algorithm
  z := y;
  return;
 end FunctionTests.FunctionFlatten22.f;

 record FunctionTests.FunctionFlatten22.R
  constant Real x;
 end FunctionTests.FunctionFlatten22.R;

end FunctionTests.FunctionFlatten22;
")})));
end FunctionFlatten22;

model FunctionFlatten23
    record R
        constant Integer n = 1;
        constant Real a[n] = {3.14};
    end R;
    
    function f
        input Real x;
        output Real y;
        R r;
    algorithm
        for i in 1:r.n loop
            y := r.a[i] * x;
        end for;
    end f;
    
    Real y = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten23",
            description="Flattening of constant in function",
            flatModel="
fclass FunctionTests.FunctionFlatten23
 Real y;
global variables
 constant FunctionTests.FunctionFlatten23.R FunctionTests.FunctionFlatten23.f.r = FunctionTests.FunctionFlatten23.R(1, {3.14});
equation
 y = FunctionTests.FunctionFlatten23.f(time);

public
 function FunctionTests.FunctionFlatten23.f
  input Real x;
  output Real y;
 algorithm
  for i in 1:1 loop
   y := global(FunctionTests.FunctionFlatten23.f.r.a[i]) * x;
  end for;
  return;
 end FunctionTests.FunctionFlatten23.f;

 record FunctionTests.FunctionFlatten23.R
  constant Integer n;
  constant Real a[1];
 end FunctionTests.FunctionFlatten23.R;

end FunctionTests.FunctionFlatten23;
")})));
end FunctionFlatten23;

model FunctionFlatten24
    record R
        parameter Integer n1;
        parameter Integer n2;
        Real[n1+n2] x;
    end R;
    
    function f
        input R r;
        output Real y = f2(r.x);
    algorithm
        annotation(Inline=false); 
    end f;
    
    function f2
        input Real[:] x;
        output Real y = sum(x);
        algorithm
    end f2;
    
    Real y = f(R(1,1,{1,2}));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten24",
            description="Flattening of size in function",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionFlatten24
 Real y;
equation
 y = FunctionTests.FunctionFlatten24.f(FunctionTests.FunctionFlatten24.R(1, 1, {1, 2}));

public
 function FunctionTests.FunctionFlatten24.f
  input FunctionTests.FunctionFlatten24.R r;
  output Real y;
 algorithm
  y := FunctionTests.FunctionFlatten24.f2(r.x);
  return;
 annotation(Inline = false);
 end FunctionTests.FunctionFlatten24.f;

 function FunctionTests.FunctionFlatten24.f2
  input Real[:] x;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(x, 1) loop
   temp_1 := temp_1 + x[i1];
  end for;
  y := temp_1;
  return;
 end FunctionTests.FunctionFlatten24.f2;

 record FunctionTests.FunctionFlatten24.R
  parameter Integer n1;
  parameter Integer n2;
  Real x[n1 + n2];
 end FunctionTests.FunctionFlatten24.R;

end FunctionTests.FunctionFlatten24;
")})));
end FunctionFlatten24;

model FunctionFlatten25
    record R
        Real[:] x;
    end R;
    function f
        input R r;
        output Real x = r.x[end];
    algorithm
    end f;
    Real x = f(R({1,2}));
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten25",
            description="Flattening of end in function",
            flatModel="
fclass FunctionTests.FunctionFlatten25
 Real x = FunctionTests.FunctionFlatten25.f(FunctionTests.FunctionFlatten25.R({1, 2}));

public
 function FunctionTests.FunctionFlatten25.f
  input FunctionTests.FunctionFlatten25.R r;
  output Real x;
 algorithm
  x := r.x[size(r.x, 1)];
  return;
 end FunctionTests.FunctionFlatten25.f;

 record FunctionTests.FunctionFlatten25.R
  Real x[:];
 end FunctionTests.FunctionFlatten25.R;

end FunctionTests.FunctionFlatten25;
")})));
end FunctionFlatten25;


model FunctionFlatten26
    function f1
        input Integer x;
        output Integer y;
    algorithm
        y := mod(sum(1:x), 3);
    end f1;
    
    function f2
        input Integer x;
        input Real y;
        output Real z[f1(x)];
    algorithm
        z := (1:size(z,1)) * y;
    end f2;
    
    parameter Integer n = f1(4);
    Real x[n] = f2(4, time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionFlatten26",
            description="Check that function eval of already scalarized function works during scalarization of another function",
            flatModel="
fclass FunctionTests.FunctionFlatten26
 structural parameter Integer n = 1 /* 1 */;
 Real x[1];
equation
 x[1] = time;
end FunctionTests.FunctionFlatten26;
")})));
end FunctionFlatten26;


model FunctionFlatten27
    model A
        function f
            input Real[:] x;
            output Real y;
        algorithm
            y := x[end];
        end f;
        Real x = f({1,2});
    end A;
    
    A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionFlatten27",
            description="Flattening of end in function that is in a component",
            flatModel="
fclass FunctionTests.FunctionFlatten27
 Real a.x = FunctionTests.FunctionFlatten27.a.f({1, 2});

public
 function FunctionTests.FunctionFlatten27.a.f
  input Real[:] x;
  output Real y;
 algorithm
  y := x[size(x, 1)];
  return;
 end FunctionTests.FunctionFlatten27.a.f;

end FunctionTests.FunctionFlatten27;
")})));
end FunctionFlatten27;


/* ====================== Function calls ====================== */

model FunctionBinding1
 Real x = TestFunction1();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding1",
            description="Binding function arguments: 1 input, use default",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding1
 Real x = FunctionTests.TestFunction1(0);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionBinding1;
")})));
end FunctionBinding1;

model FunctionBinding2
 Real x = TestFunction1(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding2",
            description="Binding function arguments: 1 input, 1 arg",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding2
 Real x = FunctionTests.TestFunction1(1);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionBinding2;
")})));
end FunctionBinding2;

model FunctionBinding3
 Real x = TestFunction1(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding3",
            description="Function call with too many arguments",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction1(): too many positional arguments
")})));
end FunctionBinding3;

model FunctionBinding4
 Real x = TestFunction3();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding4",
            description="Function call with too few arguments: no arguments",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction3(): missing argument for required input i1

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction3(): missing argument for required input i2
")})));
end FunctionBinding4;

model FunctionBinding5
 Real x = TestFunction3(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding5",
            description="Function call with too few arguments: one positional argument",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction3(): missing argument for required input i2
")})));
end FunctionBinding5;

model FunctionBinding6
 Real x = TestFunction3(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding6",
            description="Binding function arguments: 3 inputs, 2 args, 1 default",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding6
 Real x = FunctionTests.TestFunction3(1, 2, 0);

public
 function FunctionTests.TestFunction3
  input Real i1;
  input Real i2;
  input Real i3;
  output Real o1;
  output Real o2;
  output Real o3;
 algorithm
  o1 := i1 + i2 + i3;
  o2 := i2 + i3;
  o3 := i1 + i2;
  return;
 end FunctionTests.TestFunction3;

end FunctionTests.FunctionBinding6;
")})));
end FunctionBinding6;

model FunctionBinding7
 Real x = TestFunction0();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding7",
            description="Binding function arguments: 3 inputs, 2 args, 1 default",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding7
 Real x = FunctionTests.TestFunction0();

public
 function FunctionTests.TestFunction0
  output Real o1;
 algorithm
  o1 := 0;
  return;
 end FunctionTests.TestFunction0;

end FunctionTests.FunctionBinding7;
")})));
end FunctionBinding7;

model FunctionBinding8
 Real x = TestFunction1(i1=1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding8",
            description="Binding function arguments: 1 input, 1 named arg",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding8
 Real x = FunctionTests.TestFunction1(1);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionBinding8;
")})));
end FunctionBinding8;

model FunctionBinding9
 Real x = TestFunction2(i2=2, i1=1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding9",
            description="Binding function arguments: 2 inputs, 2 named arg (inverted order)",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding9
 Real x = FunctionTests.TestFunction2(1, 2);

public
 function FunctionTests.TestFunction2
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := 0;
  o2 := i2;
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;

end FunctionTests.FunctionBinding9;
")})));
end FunctionBinding9;

model FunctionBinding10
 Real x = TestFunction3(1, i3=2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding10",
            description="Function call with too few arguments: missing middle argument",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction3(): missing argument for required input i2
")})));
end FunctionBinding10;

model FunctionBinding11
 Real x = TestFunction2(i3=1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding11",
            description="Function call with named arguments: non-existing input",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction2(): no input matching named argument i3 found
")})));
end FunctionBinding11;

model FunctionBinding12
 Real x = TestFunction2(o1=1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding12",
            description="Function call with named arguments: using output as input",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction2(): no input matching named argument o1 found
")})));
end FunctionBinding12;

model FunctionBinding13
 Real x = TestFunction2(1, 2, i1=3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding13",
            description="Function call with named arguments: giving an input value twice",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction2(): multiple arguments matches input i1
")})));
end FunctionBinding13;

model FunctionBinding14
 Real x = TestFunction2(1, 2, i1=3, i1=3, i1=3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding14",
            description="Function call with named arguments: giving an input value four times",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction2(): multiple arguments matches input i1
")})));
end FunctionBinding14;

model FunctionBinding15
    package A
        constant Real a = 1;
        
        function f
            input  Real b = a;
            output Real c = b;
        algorithm
        end f;
    end A;
    
    model B
        Real c = A.f();
    end B;
    
    B d;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding15",
            description="Access to constant in default input value",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding15
 Real d.c = FunctionTests.FunctionBinding15.A.f(1.0);

public
 function FunctionTests.FunctionBinding15.A.f
  input Real b;
  output Real c;
 algorithm
  c := b;
  return;
 end FunctionTests.FunctionBinding15.A.f;

end FunctionTests.FunctionBinding15;
")})));
end FunctionBinding15;


model FunctionBinding16
    function f
        input Real a = 1;
        input Real b = a;
        output Real c = a + b;
    algorithm
    end f;
    
    Real x = f();
    Real y = f(x);
    Real z = f(x,y);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding16",
            description="",
            flatModel="
fclass FunctionTests.FunctionBinding16
 Real x = FunctionTests.FunctionBinding16.f(1, 1);
 Real y = FunctionTests.FunctionBinding16.f(x, x);
 Real z = FunctionTests.FunctionBinding16.f(x, y);

public
 function FunctionTests.FunctionBinding16.f
  input Real a;
  input Real b;
  output Real c;
 algorithm
  c := a + b;
  return;
 end FunctionTests.FunctionBinding16.f;

end FunctionTests.FunctionBinding16;
")})));
end FunctionBinding16;


model FunctionBinding19
	function a
        input Real x; 
        output Real y;
    end a;
	
    function b
        extends a;
    end b;
	
    function c
        extends a;
        extends b;
    algorithm
        y := x;
    end c;

    Real w = c(1.0);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding19",
            description="Check that identical inherited inputs/outputs of functions are merged",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionBinding19
 Real w = FunctionTests.FunctionBinding19.c(1.0);

public
 function FunctionTests.FunctionBinding19.c
  input Real x;
  output Real y;
 algorithm
  y := x;
  return;
 end FunctionTests.FunctionBinding19.c;

end FunctionTests.FunctionBinding19;
")})));
end FunctionBinding19;


model FunctionBinding20
    function f
        input Real a;
        input Real b = a + 2;
        output Real c;
    algorithm
        c := a + b;
    end f;

    model E
        Real g = f(time + 1);
    end E;

    E e;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding20",
            description="Default arguments referencing other arguments",
            flatModel="
fclass FunctionTests.FunctionBinding20
 Real e.g = FunctionTests.FunctionBinding20.f(time + 1, time + 1 + 2);

public
 function FunctionTests.FunctionBinding20.f
  input Real a;
  input Real b;
  output Real c;
 algorithm
  c := a + b;
  return;
 end FunctionTests.FunctionBinding20.f;

end FunctionTests.FunctionBinding20;
")})));
end FunctionBinding20;


model FunctionBinding21
    function f1
        input Real a;
        input Real b;
        output Real c;
    algorithm
        c := a + b;
    end f1;


    model E
	    parameter Real d = 2;
	
	    function f2 = f1(b = d);
		
		model F
            Real h = f2(1);
		end F;
		
		F f;
    end E;

    E e;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding21",
            description="Default arguments that reference parameters",
            flatModel="
fclass FunctionTests.FunctionBinding21
 parameter Real e.d = 2 /* 2 */;
 Real e.f.h = FunctionTests.FunctionBinding21.e.f2(1, e.d);

public
 function FunctionTests.FunctionBinding21.e.f2
  input Real a;
  input Real b;
  output Real c;
 algorithm
  c := a + b;
  return;
 end FunctionTests.FunctionBinding21.e.f2;

end FunctionTests.FunctionBinding21;
")})));
end FunctionBinding21;


model FunctionBinding22
    function f1
        input Real a;
        input Real b = f2(a + 2);
        output Real c;
    algorithm
        c := a + b;
    end f1;
		
    function f2
        input Real a;
        output Real b;
    algorithm
        b := a + 3;
    end f2;

    model E
        Real g = f1(time + 1);
    end E;

    E e;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding22",
            description="Test default argument using function call where arguments use another argument of the outer function",
            flatModel="
fclass FunctionTests.FunctionBinding22
 Real e.g = FunctionTests.FunctionBinding22.f1(time + 1, FunctionTests.FunctionBinding22.f2(time + 1 + 2));

public
 function FunctionTests.FunctionBinding22.f1
  input Real a;
  input Real b;
  output Real c;
 algorithm
  c := a + b;
  return;
 end FunctionTests.FunctionBinding22.f1;

 function FunctionTests.FunctionBinding22.f2
  input Real a;
  output Real b;
 algorithm
  b := a + 3;
  return;
 end FunctionTests.FunctionBinding22.f2;

end FunctionTests.FunctionBinding22;
")})));
end FunctionBinding22;

model FunctionBinding23
    function f
        input Real x;
        input Real z;
        output Real y = z;
        algorithm
    end f;
    
    function f2
        extends f(z=x);
    end f2;
    
    Real y = f2(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding23",
            description="Test default argument using function call where arguments use another argument of the outer function",
            flatModel="
fclass FunctionTests.FunctionBinding23
 Real y = FunctionTests.FunctionBinding23.f2(1, 1);

public
 function FunctionTests.FunctionBinding23.f2
  input Real x;
  input Real z;
  output Real y;
 algorithm
  y := z;
  return;
 end FunctionTests.FunctionBinding23.f2;

end FunctionTests.FunctionBinding23;
")})));
end FunctionBinding23;

model FunctionBinding24
    function f
        input Real x;
        input Real z;
        output Real y = z;
        algorithm
    end f;
    
    function f2
        extends f(z=t);
    protected
        Real t = x;
    end f2;
    
    Real y = f2(time);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding24",
            description="Test default arguments",
            flatModel="
fclass FunctionTests.FunctionBinding24
 Real y = FunctionTests.FunctionBinding24.f2(time, time);

public
 function FunctionTests.FunctionBinding24.f2
  input Real x;
  input Real z;
  output Real y;
  Real t;
 algorithm
  y := z;
  t := x;
  return;
 end FunctionTests.FunctionBinding24.f2;

end FunctionTests.FunctionBinding24;
")})));
end FunctionBinding24;

model FunctionBinding25
    function f
        input Real x;
        input Real y = x;
        output Real z = y;
        algorithm
    end f;
    
    parameter Integer n = 1;
    parameter Real[n] x = 1:n;
    parameter Real z = f(n);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionBinding25",
            description="Test default arguments: variability of call",
            flatModel="
fclass FunctionTests.FunctionBinding25
 structural parameter Integer n = 1 /* 1 */;
 structural parameter Real x[1] = {1} /* { 1 } */;
 parameter Real z = FunctionTests.FunctionBinding25.f(1, 1) /* 1 */;

public
 function FunctionTests.FunctionBinding25.f
  input Real x;
  input Real y;
  output Real z;
 algorithm
  z := y;
  return;
 end FunctionTests.FunctionBinding25.f;

end FunctionTests.FunctionBinding25;
")})));
end FunctionBinding25;

model FunctionBinding26
    function f
        input T x = 1;
        output T y = x;
        algorithm
    end f;
    Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding26",
            description="Bind argument for missing type of function input #5636",
            errorMessage="
Error at line 3, column 15, in file '...':
  Cannot find class declaration for T

Error at line 4, column 16, in file '...':
  Cannot find class declaration for T

Error at line 7, column 14, in file '...':
  Calling function f(): could not resolve argument for required input x

")})));
end FunctionBinding26;

model FunctionBinding27
    model T
    
    end T;
    function f
        input T x = 1;
        output T y = 1;
        algorithm
    end f;
    Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionBinding27",
            description="Bind argument for bad type of function input #5636",
            errorMessage="
Error at line 10, column 14, in file '...':
  Calling function f(): could not resolve argument for required input x
")})));
end FunctionBinding27;

model BadFunctionCall1
  Real x = NonExistingFunction(1, 2);
  Real y = NonExistingFunction();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BadFunctionCall1",
            description="Call to non-existing function",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 2, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find function declaration for NonExistingFunction()

Error at line 3, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find function declaration for NonExistingFunction()
")})));
end BadFunctionCall1;

model BadFunctionCall2
  Real notAFunction = 0;
  Real x = notAFunction(1, 2);
  Real y = notAFunction();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BadFunctionCall2",
            description="Call to component as function",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 3, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find function declaration for notAFunction()

Error at line 4, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find function declaration for notAFunction()
")})));
end BadFunctionCall2;

class NotAFunctionClass
 Real x;
end NotAFunctionClass;

model BadFunctionCall3
  Real x = NotAFunctionClass(1, 2);
  Real y = NotAFunctionClass();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BadFunctionCall3",
            description="Call to non-function class as function",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 2, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  The class NotAFunctionClass is not a function

Error at line 3, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  The class NotAFunctionClass is not a function
")})));
end BadFunctionCall3;

model BadFunctionCall4
    package A
    end A;
  
    package B
        function f
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
        end f;
    end B;
    
    replaceable package C = B constrainedby A;
    
    Real x = C.f(1);

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="BadFunctionCall4",
            description="Call to function in replaceable package that is not present in constraining type",
            errorMessage="
1 warnings found:

Warning at line 16, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', NOT_IN_CONSTRAINING_TYPE:
  Access to function C.f() not recommended, it is not present in constraining type of declaration 'replaceable package C = B constrainedby A'
")})));
end BadFunctionCall4;

model MultipleOutput1
  Real x;
  Real y;
equation
  (x, y) = TestFunction2(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="MultipleOutput1",
            description="Functions with multiple outputs: flattening of equation",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.MultipleOutput1
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.TestFunction2(1, 2);

public
 function FunctionTests.TestFunction2
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := 0;
  o2 := i2;
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;

end FunctionTests.MultipleOutput1;
")})));
end MultipleOutput1;

model MultipleOutput2
  Real x;
  Real y;
equation
  (x, y) = TestFunction3(1, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="MultipleOutput2",
            description="Functions with multiple outputs: flattening, fewer components assigned than outputs",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.MultipleOutput2
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.TestFunction3(1, 2, 3);

public
 function FunctionTests.TestFunction3
  input Real i1;
  input Real i2;
  input Real i3;
  output Real o1;
  output Real o2;
  output Real o3;
 algorithm
  o1 := i1 + i2 + i3;
  o2 := i2 + i3;
  o3 := i1 + i2;
  return;
 end FunctionTests.TestFunction3;

end FunctionTests.MultipleOutput2;
")})));
end MultipleOutput2;

model MultipleOutput3
  Real x;
  Real z;
equation
  (x, , z) = TestFunction3(1, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="MultipleOutput3",
            description="Functions with multiple outputs: flattening, one output skipped",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.MultipleOutput3
 Real x;
 Real z;
equation
 (x, , z) = FunctionTests.TestFunction3(1, 2, 3);

public
 function FunctionTests.TestFunction3
  input Real i1;
  input Real i2;
  input Real i3;
  output Real o1;
  output Real o2;
  output Real o3;
 algorithm
  o1 := i1 + i2 + i3;
  o2 := i2 + i3;
  o3 := i1 + i2;
  return;
 end FunctionTests.TestFunction3;

end FunctionTests.MultipleOutput3;
")})));
end MultipleOutput3;

model MultipleOutput4
  Real x;
  Real y;
equation
  TestFunction2(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="MultipleOutput4",
            description="Functions with multiple outputs: flattening, no components assigned",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.MultipleOutput4
 Real x;
 Real y;
equation
 FunctionTests.TestFunction2(1, 2);

public
 function FunctionTests.TestFunction2
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := 0;
  o2 := i2;
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;

end FunctionTests.MultipleOutput4;
")})));
end MultipleOutput4;

model RecursionTest1
 Real x = TestFunctionCallingFunction(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecursionTest1",
            description="Flattening function calling other function",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.RecursionTest1
 Real x = FunctionTests.TestFunctionCallingFunction(1);

public
 function FunctionTests.TestFunctionCallingFunction
  input Real i1;
  output Real o1;
 algorithm
  o1 := FunctionTests.TestFunction1(i1);
  return;
 end FunctionTests.TestFunctionCallingFunction;

 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.RecursionTest1;
")})));
end RecursionTest1;

model RecursionTest2
 Real x = TestFunctionRecursive(5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecursionTest2",
            description="Flattening function calling other function",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.RecursionTest2
 Real x = FunctionTests.TestFunctionRecursive(5);

public
 function FunctionTests.TestFunctionRecursive
  input Integer i1;
  output Integer o1;
 algorithm
  if i1 < 3 then
   o1 := 1;
  else
   o1 := FunctionTests.TestFunctionRecursive(i1 - 1) + FunctionTests.TestFunctionRecursive(i1 - 2);
  end if;
  return;
 end FunctionTests.TestFunctionRecursive;

end FunctionTests.RecursionTest2;
")})));
end RecursionTest2;

model RecursionTest3
 function f
  input Real x[:];
  output Real y[size(x,1)];
  Integer n = size(x,1);
 algorithm
  if n == 1 then
    y[1] := x[1];
  elseif n > 1 then
    y[1:integer(n/2)] := f(x[1:integer(n/2)]);
    y[integer(1+n/2):n] := f(x[integer(1+n/2):n])-fill(0.0,integer(1+n/2)+1);
  end if;
 end f;
 
  constant Real[:] y1 = f({1,2,3,4,5});
  Real[:] y2 = f({1,2,3,4,5});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecursionTest3",
            description="Type calculation of recursive function call during constant evaluation",
            flatModel="
fclass FunctionTests.RecursionTest3
 constant Real y1[1] = 1;
 constant Real y1[2] = 2;
 constant Real y1[3] = 3;
 constant Real y1[4] = 4;
 constant Real y1[5] = 5;
end FunctionTests.RecursionTest3;
")})));
end RecursionTest3;

/* ====================== Function call type checks ====================== */

model FunctionType0
 Real x = TestFunction1(1.0);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionType0",
            description="Function type checks: Real literal arg, Real input",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionType0
 Real x = FunctionTests.TestFunction1(1.0);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionType0;
")})));
end FunctionType0;

model FunctionType1
 Real x = TestFunction1(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionType1",
            description="Function type checks: Integer literal arg, Real input",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionType1
 Real x = FunctionTests.TestFunction1(1);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionType1;
")})));
end FunctionType1;

model FunctionType2
 Integer x = TestFunction1(1.0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType2",
            description="Function type checks: function with Real output as binding exp for Integer component",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end FunctionType2;

model FunctionType3
 parameter Real a = 1.0;
 Real x = TestFunction1(a);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionType3",
            description="Function type checks: Real component arg, Real input",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionType3
 parameter Real a = 1.0 /* 1.0 */;
 Real x = FunctionTests.TestFunction1(a);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionType3;
")})));
end FunctionType3;

model FunctionType4
 parameter Integer a = 1;
 Real x = TestFunction1(a);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionType4",
            description="Function type checks: Integer component arg, Real input",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionType4
 parameter Integer a = 1 /* 1 */;
 Real x = FunctionTests.TestFunction1(a);

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

end FunctionTests.FunctionType4;
")})));
end FunctionType4;

model FunctionType5
 Real x = TestFunction2(1, true);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType5",
            description="Function type checks: Boolean literal arg, Real input",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction2(): types of positional argument 2 and input i2 are not compatible
    type of 'true' is Boolean
    expected type is Real
")})));
end FunctionType5;

model FunctionType6
 parameter Boolean a = true;
 Real x = TestFunction2(1, a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType6",
            description="Function type checks: Boolean component arg, Real input",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 3, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction2(): types of positional argument 2 and input i2 are not compatible
    type of 'a' is Boolean
    expected type is Real
")})));
end FunctionType6;

model FunctionType7
 parameter Integer a = 1;
 Real x = TestFunction2(TestFunction2(), TestFunction2(1));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionType7",
            description="Function type checks: nestled function calls",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionType7
 parameter Integer a = 1 /* 1 */;
 Real x = FunctionTests.TestFunction2(FunctionTests.TestFunction2(0, 0), FunctionTests.TestFunction2(1, 0));

public
 function FunctionTests.TestFunction2
  input Real i1;
  input Real i2;
  output Real o1;
  output Real o2;
 algorithm
  o1 := 0;
  o2 := i2;
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;

end FunctionTests.FunctionType7;
")})));
end FunctionType7;

model FunctionType8
 parameter Integer a = 1;
 Real x = TestFunction2(TestFunction1(true), TestFunction2(1));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType8",
            description="Function type checks: nestled function calls, type mismatch in inner",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 3, column 39, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction1(): types of positional argument 1 and input i1 are not compatible
    type of 'true' is Boolean
    expected type is Real
")})));
end FunctionType8;

model FunctionType11
 String x = TestFunctionString(1);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="FunctionType11",
            description="Function type checks: Integer literal arg, String input",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 32, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunctionString(): types of positional argument 1 and input i1 are not compatible
    type of '1' is Integer
    expected type is String
")})));
end FunctionType11;

model FunctionType12
 Real x;
 Integer y;
equation
 (x, y) = TestFunction2(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType12",
            description="Function type checks: 2 outputs, 2nd wrong type",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction2(): component y is of type Integer and output o2 is of type Real - they are not compatible
")})));
end FunctionType12;

model FunctionType13
 Integer x;
 Real y;
 Integer z;
equation
 (x, y, z) = TestFunction3(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType13",
            description="Function type checks: 3 outputs, 1st and 3rd wrong type",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 6, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction3(): component x is of type Integer and output o1 is of type Real - they are not compatible

Error at line 6, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction3(): component z is of type Integer and output o3 is of type Real - they are not compatible
")})));
end FunctionType13;

model FunctionType14
 Real x;
 Real y;
 Real z;
equation
 (x, y, z) = TestFunction2(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType14",
            description="Function type checks: 2 outputs, 3 components assigned",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 6, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Too many components assigned from function call: TestFunction2() has 2 output(s)
")})));
end FunctionType14;

model FunctionType15
 Real x;
 Integer z;
equation
 (x, , z) = TestFunction3(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType15",
            description="Function type checks: 3 outputs, 2nd skipped, 3rd wrong type",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function TestFunction3(): component z is of type Integer and output o3 is of type Real - they are not compatible
")})));
end FunctionType15;

model FunctionType16
 Real x;
 Real y;
equation
 (x, y) = sin(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType16",
            description="Function type checks: assigning 2 components from sin()",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Too many components assigned from function call: sin() has 1 output(s)
")})));
end FunctionType16;

model FunctionType17
 function f
  input Real x[:,:];
  input Real y[2,:];
  output Real z[size(x,1),size(x,2)];
 algorithm
  z := x + y;
 end f;
  
 Real x[2,2] = f({{1,2},{3,4}}, {{5,6},{7,8}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionType17",
            description="Function type checks: combining known and unknown types",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 7, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: x + y
    type of 'x' is Real[size(x, 1), size(x, 2)]
    type of 'y' is Real[2, size(y, 2)]
")})));
end FunctionType17;

model FunctionType18
    function f1
        input Integer a;
        input Integer b;
        output Integer c;
    algorithm
        c := a + b;
    end f1;
    
    function f2
        input Integer d = 2 * e;
        input Integer e = 1;
        input Integer f = d - 1;
        output Real g[f1(f, e)];
    algorithm
        g := (1:size(g, 1)) .+ d;
    end f2;

    Real x[:] = f2(e = 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionType18",
            description="",
            flatModel="
fclass FunctionTests.FunctionType18
 Real x[5] = FunctionTests.FunctionType18.f2(2 * 2, 2, 2 * 2 - 1);

public
 function FunctionTests.FunctionType18.f2
  input Integer d;
  input Integer e;
  input Integer f;
  output Real[:] g;
 algorithm
  init g as Real[FunctionTests.FunctionType18.f1(f, e)];
  g[:] := (1:size(g, 1)) .+ d;
  return;
 end FunctionTests.FunctionType18.f2;

 function FunctionTests.FunctionType18.f1
  input Integer a;
  input Integer b;
  output Integer c;
 algorithm
  c := a + b;
  return;
 end FunctionTests.FunctionType18.f1;

end FunctionTests.FunctionType18;
")})));
end FunctionType18;


model BuiltInCallType1
  Real x = sin(true);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType1",
            description="Built-in type checks: passing Boolean literal to sin()",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function sin(): types of positional argument 1 and input u are not compatible
    type of 'true' is Boolean
    expected type is Real
")})));
end BuiltInCallType1;

model BuiltInCallType2
  Real x = sqrt("test");

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType2",
            description="Built-in type checks: passing String literal to sqrt()",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function sqrt(): types of positional argument 1 and input x are not compatible
    type of '\"test\"' is String
    expected type is Real
")})));
end BuiltInCallType2;

model BuiltInCallType3
  Real x = sqrt(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BuiltInCallType3",
            description="Built-in type checks: passing Integer literal to sqrt()",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.BuiltInCallType3
 Real x = sqrt(1);
end FunctionTests.BuiltInCallType3;
")})));
end BuiltInCallType3;

model BuiltInCallType4
  Integer x = sqrt(9.0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType4",
            description="Built-in type checks: using return value from sqrt() as Integer",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end BuiltInCallType4;

model BuiltInCallType5
  Real x = sin();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType5",
            description="Built-in type checks: calling sin() without arguments",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function sin(): missing argument for required input u
")})));
end BuiltInCallType5;

model BuiltInCallType6
  Real x = atan2(9.0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType6",
            description="Built-in type checks: calling atan2() with only one argument",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function atan2(): missing argument for required input u2
")})));
end BuiltInCallType6;

model BuiltInCallType7
  Real x = atan2(9.0, "test");

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType7",
            description="Built-in type checks: calling atan2() with String literal as second argument",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 23, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function atan2(): types of positional argument 2 and input u2 are not compatible
    type of '\"test\"' is String
    expected type is Real
")})));
end BuiltInCallType7;

model BuiltInCallType8
  Real x[3] = zeros(3);
  Real y[3,2] = ones(3,2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BuiltInCallType8",
            description="Built-in type checks: using ones and zeros",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.BuiltInCallType8
 Real x[3] = zeros(3);
 Real y[3,2] = ones(3, 2);
end FunctionTests.BuiltInCallType8;
")})));
end BuiltInCallType8;

model BuiltInCallType9
   Real x[3] = zeros(3.0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType9",
            description="Built-in type checks: calling zeros() with Real literal as argument",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 2, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Argument of zeros() is not compatible with Integer: 3.0
")})));
end BuiltInCallType9;

model BuiltInCallType10
   Real x[3] = ones(3, "test");

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BuiltInCallType10",
            description="Built-in type checks: calling ones() with String literal as second argument",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [3] and size of binding expression is [3, \"test\"]

Error at line 2, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Argument of ones() is not compatible with Integer: \"test\"
")})));
end BuiltInCallType10;

model FunctionVariability1
    function IsXPositive
        input Real x;
        output Boolean y;
    algorithm
        if x >= 0 then
            y := true;
        else
            y := false;
        end if;
    end IsXPositive;
    Boolean x = IsXPositive(time - 0.5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionVariability1",
            description="Function variability test",
            flatModel="
fclass FunctionTests.FunctionVariability1
 discrete Boolean x = FunctionTests.FunctionVariability1.IsXPositive(time - 0.5);

public
 function FunctionTests.FunctionVariability1.IsXPositive
  input Real x;
  output Boolean y;
 algorithm
  if x >= 0 then
   y := true;
  else
   y := false;
  end if;
  return;
 end FunctionTests.FunctionVariability1.IsXPositive;

end FunctionTests.FunctionVariability1;
")})));
end FunctionVariability1;

model FunctionVariability2
    function count
        input Real x;
        output Integer y = 0;
    algorithm
        while x > y loop
            y := y + 1;
        end while;
    end count;
    Integer x = count(time);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionVariability2",
            description="Function variability test",
            flatModel="
fclass FunctionTests.FunctionVariability2
 discrete Integer x = FunctionTests.FunctionVariability2.count(time);

public
 function FunctionTests.FunctionVariability2.count
  input Real x;
  output Integer y;
 algorithm
  y := 0;
  while x > y loop
   y := y + 1;
  end while;
  return;
 end FunctionTests.FunctionVariability2.count;

end FunctionTests.FunctionVariability2;
")})));
end FunctionVariability2;

/* ====================== Algorithm flattening ====================== */

model AlgorithmFlatten1
 Real x;
algorithm
 x := 5;
 x := x + 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten1",
            description="Flattening algorithms: assign stmts",
            flatModel="
fclass FunctionTests.AlgorithmFlatten1
 Real x;
algorithm
 x := 5;
 x := x + 2;
end FunctionTests.AlgorithmFlatten1;
")})));
end AlgorithmFlatten1;


model AlgorithmFlatten2
 Real x(start = 1.0);
 Real y = x;
algorithm
 x := 5;
 x := x + 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten2",
            description="Alias elimination in algorithm",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmFlatten2
 Real x(start = 1.0);
algorithm
 x := 5;
 x := x + 2;
end FunctionTests.AlgorithmFlatten2;
")})));
end AlgorithmFlatten2;


model AlgorithmFlatten3
 Integer x;
 Integer y;
algorithm
 if x == 4 then
  x := 1;
  y := 2;
 elseif x == 3 then
  if y == 0 then
   y := 1;
  end if;
  x := 2;
  y := 3;
 else
  x := 3;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten3",
            description="Flattening algorithms: if stmts",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmFlatten3
 discrete Integer x;
 discrete Integer y;
initial equation 
 pre(x) = 0;
 pre(y) = 0;
algorithm
 if x == 4 then
  x := 1;
  y := 2;
 elseif x == 3 then
  if y == 0 then
   y := 1;
  end if;
  x := 2;
  y := 3;
 else
  x := 3;
 end if;
end FunctionTests.AlgorithmFlatten3;
")})));
end AlgorithmFlatten3;


model AlgorithmFlatten4
 Integer x;
 Integer y;
algorithm
 when x == 4 then
  x := 1;
  y := 2;
 elsewhen x == 3 then
  x := 2;
  y := 3;
  if x == 2 then
   x := 3;
  end if;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten4",
            description="Flattening algorithms: when stmts",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmFlatten4
 discrete Integer x;
 discrete Integer y;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
initial equation 
 pre(x) = 0;
 pre(y) = 0;
 pre(temp_1) = false;
 pre(temp_2) = false;
algorithm
 temp_1 := x == 4;
 temp_2 := x == 3;
 if temp_1 and not pre(temp_1) then
  x := 1;
  y := 2;
 elseif temp_2 and not pre(temp_2) then
  x := 2;
  y := 3;
  if x == 2 then
   x := 3;
  end if;
 end if;
end FunctionTests.AlgorithmFlatten4;
")})));
end AlgorithmFlatten4;


model AlgorithmFlatten5
 Real x;
algorithm
 while noEvent(x < 1) loop
  while noEvent(x < 2) loop
   while noEvent(x < 3) loop
    x := x + 1;
   end while;
  end while;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten5",
            description="Flattening algorithms: while stmts",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmFlatten5
 Real x;
algorithm
 while noEvent(x < 1) loop
  while noEvent(x < 2) loop
   while noEvent(x < 3) loop
    x := x + 1;
   end while;
  end while;
 end while;
end FunctionTests.AlgorithmFlatten5;
")})));
end AlgorithmFlatten5;


model AlgorithmFlatten6
 Real x;
algorithm
 for i in {1, 2, 4}, j in 1:3 loop
  x := x + i * j;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten6",
            description="Flattening algorithms: for stmts",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmFlatten6
 Real x;
algorithm
 x := x + 1;
 x := x + 2;
 x := x + 3;
 x := x + 2;
 x := x + 2 * 2;
 x := x + 2 * 3;
 x := x + 4;
 x := x + 4 * 2;
 x := x + 4 * 3;
end FunctionTests.AlgorithmFlatten6;
")})));
end AlgorithmFlatten6;

model AlgorithmFlatten7
function f
	input Real[2] i;
	output Real[2] o;
algorithm
    o := if i * i > 1.0E-6 then i else i .+ 1;
end f;

Real[2] x = f({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten7",
            description="Flattening algorithms: if expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmFlatten7
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.AlgorithmFlatten7.f({time, time * 2});

public
 function FunctionTests.AlgorithmFlatten7.f
  input Real[:] i;
  output Real[:] o;
  Real temp_1;
  Real temp_2;
 algorithm
  init o as Real[2];
  temp_2 := 0.0;
  for i1 in 1:2 loop
   temp_2 := temp_2 + i[i1] * i[i1];
  end for;
  temp_1 := temp_2;
  for i1 in 1:2 loop
   o[i1] := if temp_1 > 1.0E-6 then i[i1] else i[i1] .+ 1;
  end for;
  return;
 end FunctionTests.AlgorithmFlatten7.f;

end FunctionTests.AlgorithmFlatten7;
")})));
end AlgorithmFlatten7;

model AlgorithmFlatten8
  Real[3] x;
algorithm
  for i in 1:3 loop
    x[1:i] := 1:i;
    x[{i,2}] := {i,2};
  end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten8",
            description="Flattening algorithms: for indices in left hand side of array assignments.",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmFlatten8
 Real x[1];
 Real x[2];
 Real x[3];
algorithm
 x[1] := 1;
 x[1] := 1;
 x[2] := 2;
 x[1] := 1;
 x[2] := 2;
 x[2] := 2;
 x[2] := 2;
 x[1] := 1;
 x[2] := 2;
 x[3] := 3;
 x[3] := 3;
 x[2] := 2;
end FunctionTests.AlgorithmFlatten8;
")})));
end AlgorithmFlatten8;

model AlgorithmFlatten9
 Real y1,y2,y3,x;
algorithm
 when x > 2 then
  y1 := sin(x);
 end when;
equation
 y2 = sin(y1);
 x = time;
algorithm
 when x > 2 then
	 y3 := 2*x + y1 + y2;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten9",
            description="Flattening algorithms: when stmts",
            flatModel="
fclass FunctionTests.AlgorithmFlatten9
 discrete Real y1;
 Real y2;
 discrete Real y3;
 Real x;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
initial equation
 pre(y1) = 0.0;
 pre(y3) = 0.0;
 pre(temp_1) = false;
 pre(temp_2) = false;
equation
 y2 = sin(y1);
 x = time;
 temp_1 = x > 2;
algorithm
 if temp_1 and not pre(temp_1) then
  y1 := sin(x);
 end if;
equation
 temp_2 = x > 2;
algorithm
 if temp_2 and not pre(temp_2) then
  y3 := 2 * x + y1 + y2;
 end if;
end FunctionTests.AlgorithmFlatten9;
")})));
end AlgorithmFlatten9;

model AlgorithmFlatten10
  Real y1,y2;
algorithm
  when time > 1 then
    y1 := 1;
  elsewhen time > 2 then
    y2 := 2;
  end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmFlatten10",
            description="Flattening algorithms: else-when stmts",
            flatModel="
fclass FunctionTests.AlgorithmFlatten10
 discrete Real y1;
 discrete Real y2;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
initial equation
 pre(y1) = 0.0;
 pre(y2) = 0.0;
 pre(temp_1) = false;
 pre(temp_2) = false;
equation
 temp_1 = time > 1;
 temp_2 = time > 2;
algorithm
 if temp_1 and not pre(temp_1) then
  y1 := 1;
 elseif temp_2 and not pre(temp_2) then
  y2 := 2;
 end if;
end FunctionTests.AlgorithmFlatten10;
")})));
end AlgorithmFlatten10;


/* ====================== Algorithm type checks ====================== */

/* ----- if ----- */

model AlgorithmTypeIf1
 Real x;
algorithm
 if 1 then
  x := 1.0;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeIf1",
            description="Type checks in algorithms: Integer literal as test in if",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 4, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of if statement is not Boolean
")})));
end AlgorithmTypeIf1;

model AlgorithmTypeIf2
 Integer a = 1;
 Real x;
algorithm
 if a then
  x := 1.0;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeIf2",
            description="Type checks in algorithms: Integer component as test in if",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of if statement is not Boolean
")})));
end AlgorithmTypeIf2;

model AlgorithmTypeIf3
 Integer a = 1;
 Real x;
algorithm
 if a + x then
  x := 1.0;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeIf3",
            description="Type checks in algorithms: arithmetic expression as test in if",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of if statement is not Boolean
")})));
end AlgorithmTypeIf3;

model AlgorithmTypeIf4
 Real x;
algorithm
 if { true, false } then
  x := 1.0;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeIf4",
            description="Type checks in algorithms: Boolean vector as test in if",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 4, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of if statement is not Boolean
")})));
end AlgorithmTypeIf4;

model AlgorithmTypeIf5
 Real x;
algorithm
 if true then
  x := 1.0;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AlgorithmTypeIf5",
            description="Type checks in algorithms: Boolean literal as test in if",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmTypeIf5
 Real x;
algorithm
  x := 1.0;
end FunctionTests.AlgorithmTypeIf5;
")})));
end AlgorithmTypeIf5;

/* ----- when ----- */

model AlgorithmTypeWhen1
 Real x;
algorithm
 when 1 then
  x := 1.0;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeWhen1",
            description="Type checks in algorithms: Integer literal as test in when",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 4, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Test expression of when statement isn't Boolean scalar or vector expression
")})));
end AlgorithmTypeWhen1;

model AlgorithmTypeWhen2
 Integer a = 1;
 Real x;
algorithm
 when a then
  x := 1.0;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeWhen2",
            description="Type checks in algorithms: Integer component as test in when",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Test expression of when statement isn't Boolean scalar or vector expression
")})));
end AlgorithmTypeWhen2;

model AlgorithmTypeWhen3
 Integer a = 1;
 Real x;
algorithm
 when a + x then
  x := 1.0;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeWhen3",
            description="Type checks in algorithms: arithmetic expression as test in when",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Test expression of when statement isn't Boolean scalar or vector expression
")})));
end AlgorithmTypeWhen3;

model AlgorithmTypeWhen4
 Real x;
algorithm
 when { true, false } then
  x := 1.0;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AlgorithmTypeWhen4",
            description="Type checks in algorithms: Boolean vector as test in when",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmTypeWhen4
 discrete Real x;
algorithm
 when {true, false} then
  x := 1.0;
 end when;
end FunctionTests.AlgorithmTypeWhen4;
")})));
end AlgorithmTypeWhen4;

model AlgorithmTypeWhen5
 Real x;
algorithm
 when true then
  x := 1.0;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AlgorithmTypeWhen5",
            description="Type checks in algorithms: Boolean literal as test in when",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmTypeWhen5
 discrete Real x;
algorithm
 when true then
  x := 1.0;
 end when;
end FunctionTests.AlgorithmTypeWhen5;
")})));
end AlgorithmTypeWhen5;

/* ----- while ----- */

model AlgorithmTypeWhile1
 Real x;
algorithm
 while 1 loop
  x := 1.0;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeWhile1",
            description="Type checks in algorithms: Integer literal as test in while",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 4, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of while statement is not Boolean
")})));
end AlgorithmTypeWhile1;

model AlgorithmTypeWhile2
 Integer a = 1;
 Real x;
algorithm
 while a loop
  x := 1.0;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeWhile2",
            description="Type checks in algorithms: Integer component as test in while",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of while statement is not Boolean
")})));
end AlgorithmTypeWhile2;

model AlgorithmTypeWhile3
 Integer a = 1;
 Real x;
algorithm
 while a + x loop
  x := 1.0;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeWhile3",
            description="Type checks in algorithms: arithmetic expression as test in while",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of while statement is not Boolean
")})));
end AlgorithmTypeWhile3;

model AlgorithmTypeWhile4
 Real x;
algorithm
 while { true, false } loop
  x := 1.0;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeWhile4",
            description="Type checks in algorithms: Boolean vector as test in while",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 4, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Type of test expression of while statement is not Boolean
")})));
end AlgorithmTypeWhile4;

model AlgorithmTypeWhile5
 Real x;
algorithm
 while true loop
  x := 1.0;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AlgorithmTypeWhile5",
            description="Type checks in algorithms: Boolean literal as test in while",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmTypeWhile5
 Real x;
algorithm
 while true loop
  x := 1.0;
 end while;
end FunctionTests.AlgorithmTypeWhile5;
")})));
end AlgorithmTypeWhile5;

model AlgorithmTypeAssign1
 Integer x;
algorithm
 x := 1.0;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeAssign1",
            description="Type checks in algorithms: assign Real to Integer component",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 4, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  The right and left expression types of assignment are not compatible, type of left-hand side is Integer, and type of right-hand side is Real
")})));
end AlgorithmTypeAssign1;

model AlgorithmTypeAssign2
 Real x;
algorithm
 x := 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AlgorithmTypeAssign2",
            description="Type checks in algorithms: assign Integer to Real component",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmTypeAssign2
 Real x;
algorithm
 x := 1;
end FunctionTests.AlgorithmTypeAssign2;
")})));
end AlgorithmTypeAssign2;

model AlgorithmTypeAssign3
 Real x;
algorithm
 x := 1.0;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AlgorithmTypeAssign3",
            description="Type checks in algorithms: assign Real to Real component",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.AlgorithmTypeAssign3
 Real x;
algorithm
 x := 1.0;
end FunctionTests.AlgorithmTypeAssign3;
")})));
end AlgorithmTypeAssign3;

model AlgorithmTypeAssign4
 Real x;
algorithm
 x := "foo";

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeAssign4",
            description="Type checks in algorithms: assign String to Real component",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 4, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  The right and left expression types of assignment are not compatible, type of left-hand side is Real, and type of right-hand side is String
")})));
end AlgorithmTypeAssign4;


model AlgorithmTypeForIndex1
 Real x;
algorithm
 for i in 1:3 loop
  i := 2;
  x := i;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeForIndex1",
            description="Type checks in algorithms: assigning to for index",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Can not assign a value to a for loop index
")})));
end AlgorithmTypeForIndex1;


model AlgorithmTypeForIndex2
 Real x;
algorithm
 for i in 1:3 loop
  (i, x) := TestFunction2(1, 2);
 end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AlgorithmTypeForIndex2",
            description="Type checks in algorithms: assigning to for index (FunctionCallStmt)",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 5, column 4, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Can not assign a value to a for loop index
")})));
end AlgorithmTypeForIndex2;


/* ====================== Algorithm transformations ===================== */

model AlgorithmTransformation1
 Real a = 1;
 Real b = 2;
 Real x;
 Real y;
algorithm
 x := a;
 y := b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation1",
            description="Generating functions from algorithms: simple algorithm",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation1
 Real a;
 Real b;
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation1.algorithm_1(a, b);
 a = 1;
 b = 2;

public
 function FunctionTests.AlgorithmTransformation1.algorithm_1
  output Real x;
  output Real y;
  input Real a;
  input Real b;
 algorithm
  x := a;
  y := b;
  return;
 end FunctionTests.AlgorithmTransformation1.algorithm_1;

end FunctionTests.AlgorithmTransformation1;
")})));
end AlgorithmTransformation1;


model AlgorithmTransformation2
 Real a = 1;
 Real x;
 Real y;
algorithm
 x := a;
 y := a;
 x := a;
 y := a;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation2",
            description="Generating functions from algorithms: vars used several times",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation2
 Real a;
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation2.algorithm_1(a);
 a = 1;

public
 function FunctionTests.AlgorithmTransformation2.algorithm_1
  output Real x;
  output Real y;
  input Real a;
 algorithm
  x := a;
  y := a;
  x := a;
  y := a;
  return;
 end FunctionTests.AlgorithmTransformation2.algorithm_1;

end FunctionTests.AlgorithmTransformation2;
")})));
end AlgorithmTransformation2;


model AlgorithmTransformation3
 Real a = 1;
 Real b = 2;
 Real x;
 Real y;
algorithm
 x := a + 1;
 if b > 1 then
  y := a + 2;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation3",
            description="Generating functions from algorithms: complex algorithm",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation3
 Real a;
 Real b;
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation3.algorithm_1(a, b);
 a = 1;
 b = 2;

public
 function FunctionTests.AlgorithmTransformation3.algorithm_1
  output Real x;
  output Real y;
  input Real a;
  input Real b;
 algorithm
  x := a + 1;
  if b > 1 then
   y := a + 2;
  end if;
  return;
 end FunctionTests.AlgorithmTransformation3.algorithm_1;

end FunctionTests.AlgorithmTransformation3;
")})));
end AlgorithmTransformation3;


model AlgorithmTransformation4
 Real a = 1;
 Real b;
 Real x;
 Real y;
algorithm
 b := 2;
 while b > 1 loop
  x := a;
  if a < 2 then
   y := b;
  else
   y := a + 2;
  end if;
  b := b - 0.1;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation4",
            description="Generating functions from algorithms: complex algorithm",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation4
 Real a;
 Real b;
 Real x;
 Real y;
equation
 (b, x, y) = FunctionTests.AlgorithmTransformation4.algorithm_1(0.0, a);
 a = 1;

public
 function FunctionTests.AlgorithmTransformation4.algorithm_1
  output Real b;
  output Real x;
  output Real y;
  input Real b_0;
  input Real a;
 algorithm
  b := b_0;
  b := 2;
  while b > 1 loop
   x := a;
   if a < 2 then
    y := b;
   else
    y := a + 2;
   end if;
   b := b - 0.1;
  end while;
  return;
 end FunctionTests.AlgorithmTransformation4.algorithm_1;

end FunctionTests.AlgorithmTransformation4;
")})));
end AlgorithmTransformation4;


model AlgorithmTransformation5
 Real x;
 Real y;
algorithm
 x := 1;
 y := 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation5",
            description="Generating functions from algorithms: no used variables",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation5
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation5.algorithm_1();

public
 function FunctionTests.AlgorithmTransformation5.algorithm_1
  output Real x;
  output Real y;
 algorithm
  x := 1;
  y := 2;
  return;
 end FunctionTests.AlgorithmTransformation5.algorithm_1;

end FunctionTests.AlgorithmTransformation5;
")})));
end AlgorithmTransformation5;


model AlgorithmTransformation6
 Real x;
 Real y;
algorithm
 x := 1;
algorithm
 y := 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation6",
            description="Generating functions from algorithms: 2 algorithms",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation6
 Real x;
 Real y;
equation
 (x) = FunctionTests.AlgorithmTransformation6.algorithm_1();
 (y) = FunctionTests.AlgorithmTransformation6.algorithm_2();

public
 function FunctionTests.AlgorithmTransformation6.algorithm_1
  output Real x;
 algorithm
  x := 1;
  return;
 end FunctionTests.AlgorithmTransformation6.algorithm_1;

 function FunctionTests.AlgorithmTransformation6.algorithm_2
  output Real y;
 algorithm
  y := 2;
  return;
 end FunctionTests.AlgorithmTransformation6.algorithm_2;

end FunctionTests.AlgorithmTransformation6;
")})));
end AlgorithmTransformation6;


model AlgorithmTransformation7
 function algorithm_1
  input Real i;
  output Real o = i * 2;
  algorithm
 end algorithm_1;
 
 Real x;
algorithm
 x := algorithm_1(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation7",
            description="Generating functions from algorithms: generated name exists - function",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation7
 Real x;
equation
 (x) = FunctionTests.AlgorithmTransformation7.algorithm_2();

public
 function FunctionTests.AlgorithmTransformation7.algorithm_1
  input Real i;
  output Real o;
 algorithm
  o := i * 2;
  return;
 end FunctionTests.AlgorithmTransformation7.algorithm_1;

 function FunctionTests.AlgorithmTransformation7.algorithm_2
  output Real x;
 algorithm
  x := FunctionTests.AlgorithmTransformation7.algorithm_1(2);
  return;
 end FunctionTests.AlgorithmTransformation7.algorithm_2;

end FunctionTests.AlgorithmTransformation7;
")})));
end AlgorithmTransformation7;


model AlgorithmTransformation8
 model algorithm_1
  Real a;
  Real b;
 end algorithm_1;
 
 algorithm_1 x;
algorithm
 x.a := 2;
 x.b := 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation8",
            description="Generating functions from algorithms: generated name exists - model",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation8
 Real x.a;
 Real x.b;
equation
 (x.a, x.b) = FunctionTests.AlgorithmTransformation8.algorithm_1();

public
 function FunctionTests.AlgorithmTransformation8.algorithm_1
  output Real x.a;
  output Real x.b;
 algorithm
  x.a := 2;
  x.b := 3;
  return;
 end FunctionTests.AlgorithmTransformation8.algorithm_1;

end FunctionTests.AlgorithmTransformation8;
")})));
end AlgorithmTransformation8;


model AlgorithmTransformation9
 Real algorithm_1;
 Real algorithm_3;
algorithm
 algorithm_1 := 1;
algorithm
 algorithm_3 := 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation9",
            description="Generating functions from algorithms: generated name exists - component",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation9
 Real algorithm_1;
 Real algorithm_3;
equation
 (algorithm_1) = FunctionTests.AlgorithmTransformation9.algorithm_2();
 (algorithm_3) = FunctionTests.AlgorithmTransformation9.algorithm_4();

public
 function FunctionTests.AlgorithmTransformation9.algorithm_2
  output Real algorithm_1;
 algorithm
  algorithm_1 := 1;
  return;
 end FunctionTests.AlgorithmTransformation9.algorithm_2;

 function FunctionTests.AlgorithmTransformation9.algorithm_4
  output Real algorithm_3;
 algorithm
  algorithm_3 := 3;
  return;
 end FunctionTests.AlgorithmTransformation9.algorithm_4;

end FunctionTests.AlgorithmTransformation9;
")})));
end AlgorithmTransformation9;


model AlgorithmTransformation10
 Real x;
 Real x_0;
 Real x_1;
algorithm
 x := x_0;
 x_1 := x;
equation
 x_0 = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation10",
            description="Generating functions from algorithms: generated arg name exists",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation10
 Real x;
 Real x_0;
 Real x_1;
equation
 x_0 = 0;
 (x, x_1) = FunctionTests.AlgorithmTransformation10.algorithm_1(x_0, 0.0);

public
 function FunctionTests.AlgorithmTransformation10.algorithm_1
  output Real x;
  output Real x_1;
  input Real x_0;
  input Real x_2;
 algorithm
  x := x_2;
  x := x_0;
  x_1 := x;
  return;
 end FunctionTests.AlgorithmTransformation10.algorithm_1;

end FunctionTests.AlgorithmTransformation10;
")})));
end AlgorithmTransformation10;


model AlgorithmTransformation11
 Real x;
 Real y;
algorithm
 x := 1;
 y := x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation11",
            description="Generating functions from algorithms: assigned variable used",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation11
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation11.algorithm_1(0.0);

public
 function FunctionTests.AlgorithmTransformation11.algorithm_1
  output Real x;
  output Real y;
  input Real x_0;
 algorithm
  x := x_0;
  x := 1;
  y := x;
  return;
 end FunctionTests.AlgorithmTransformation11.algorithm_1;

end FunctionTests.AlgorithmTransformation11;
")})));
end AlgorithmTransformation11;


model AlgorithmTransformation12
 Real x0;
 Real x1(start=1);
 Real x2(start=2);
 Real y;
algorithm
 x0 := 1;
 x1 := x0;
 x2 := x1;
 y := x2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation12",
            description="Generating functions from algorithms: assigned variables used, different start values",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation12
 Real x0;
 Real x1(start = 1);
 Real x2(start = 2);
 Real y;
equation
 (x0, x1, x2, y) = FunctionTests.AlgorithmTransformation12.algorithm_1(0.0, 1, 2);

public
 function FunctionTests.AlgorithmTransformation12.algorithm_1
  output Real x0;
  output Real x1;
  output Real x2;
  output Real y;
  input Real x0_0;
  input Real x1_0;
  input Real x2_0;
 algorithm
  x0 := x0_0;
  x1 := x1_0;
  x2 := x2_0;
  x0 := 1;
  x1 := x0;
  x2 := x1;
  y := x2;
  return;
 end FunctionTests.AlgorithmTransformation12.algorithm_1;

end FunctionTests.AlgorithmTransformation12;
")})));
end AlgorithmTransformation12;


model AlgorithmTransformation13
 Real x = 2;
algorithm
 if x < 3 then
  TestFunction1(x);
 end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation13",
            description="Generating functions from algorithms: no assignments",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation13
 Real x;
equation
 FunctionTests.AlgorithmTransformation13.algorithm_1(x);
 x = 2;

public
 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

 function FunctionTests.AlgorithmTransformation13.algorithm_1
  input Real x;
 algorithm
  if x < 3 then
   FunctionTests.TestFunction1(x);
  end if;
  return;
 end FunctionTests.AlgorithmTransformation13.algorithm_1;

end FunctionTests.AlgorithmTransformation13;
")})));
end AlgorithmTransformation13;


model AlgorithmTransformation14
 Real x;
algorithm
 x := 0;
 for i in 1:3 loop
  x := x + i;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation14",
            description="Generating functions from algorithms: using for index",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation14
 Real x;
equation
 (x) = FunctionTests.AlgorithmTransformation14.algorithm_1(0.0);

public
 function FunctionTests.AlgorithmTransformation14.algorithm_1
  output Real x;
  input Real x_0;
 algorithm
  x := x_0;
  x := 0;
  x := x + 1;
  x := x + 2;
  x := x + 3;
  return;
 end FunctionTests.AlgorithmTransformation14.algorithm_1;

end FunctionTests.AlgorithmTransformation14;
")})));
end AlgorithmTransformation14;


model AlgorithmTransformation15
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	Real d_out;

	function f
		input Real a;
		input Real b;
		output Real c = a;
		output Real d = b;
	algorithm
	end f;

algorithm
	(c_out, d_out) := f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmTransformation15",
            description="Generating functions from algorithms: function call statement",
            variability_propagation=false,
            algorithms_as_functions=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AlgorithmTransformation15
 Real a_in;
 Real b_in;
 Real c_out;
 Real d_out;
equation
 (c_out, d_out) = FunctionTests.AlgorithmTransformation15.algorithm_1(a_in, b_in);
 a_in = 1;
 b_in = 2;

public
 function FunctionTests.AlgorithmTransformation15.f
  input Real a;
  input Real b;
  output Real c;
  output Real d;
 algorithm
  c := a;
  d := b;
  return;
 end FunctionTests.AlgorithmTransformation15.f;

 function FunctionTests.AlgorithmTransformation15.algorithm_1
  output Real c_out;
  output Real d_out;
  input Real a_in;
  input Real b_in;
 algorithm
  (c_out, d_out) := FunctionTests.AlgorithmTransformation15.f(a_in, b_in);
  return;
 end FunctionTests.AlgorithmTransformation15.algorithm_1;

end FunctionTests.AlgorithmTransformation15;
")})));
end AlgorithmTransformation15;



/* =========================== Arrays in functions =========================== */

model ArrayExpInFunc1
 function f
  output Real o = 1.0;
  protected Real x[3];
 algorithm
  x := { 1, 2, 3 };
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc1",
            description="Scalarization of functions: assign from array",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc1
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc1.f();

public
 function FunctionTests.ArrayExpInFunc1.f
  output Real o;
  Real[:] x;
  Integer[:] temp_1;
 algorithm
  o := 1.0;
  init x as Real[3];
  init temp_1 as Integer[3];
  temp_1[1] := 1;
  temp_1[2] := 2;
  temp_1[3] := 3;
  for i1 in 1:3 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc1.f;

end FunctionTests.ArrayExpInFunc1;
")})));
end ArrayExpInFunc1;


model ArrayExpInFunc2
 function f
  output Real o = 1.0;
  protected Real x[2,2];
 algorithm
  x := {{1,2},{3,4}} * {{1,2},{3,4}};
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc2",
            description="Scalarization of functions: assign from array exp",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc2
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc2.f();

public
 function FunctionTests.ArrayExpInFunc2.f
  output Real o;
  Real[:,:] x;
  Integer[:,:] temp_1;
  Integer temp_2;
  Integer[:,:] temp_3;
  Integer[:] temp_4;
  Integer[:] temp_5;
  Integer[:,:] temp_6;
  Integer[:] temp_7;
  Integer[:] temp_8;
 algorithm
  o := 1.0;
  init x as Real[2, 2];
  init temp_1 as Integer[2, 2];
  init temp_3 as Integer[2, 2];
  init temp_4 as Integer[2];
  temp_4[1] := 1;
  temp_4[2] := 2;
  for i4 in 1:2 loop
   temp_3[1,i4] := temp_4[i4];
  end for;
  init temp_5 as Integer[2];
  temp_5[1] := 3;
  temp_5[2] := 4;
  for i4 in 1:2 loop
   temp_3[2,i4] := temp_5[i4];
  end for;
  init temp_6 as Integer[2, 2];
  init temp_7 as Integer[2];
  temp_7[1] := 1;
  temp_7[2] := 2;
  for i3 in 1:2 loop
   temp_6[1,i3] := temp_7[i3];
  end for;
  init temp_8 as Integer[2];
  temp_8[1] := 3;
  temp_8[2] := 4;
  for i3 in 1:2 loop
   temp_6[2,i3] := temp_8[i3];
  end for;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    temp_2 := 0;
    for i3 in 1:2 loop
     temp_2 := temp_2 + temp_3[i1,i3] * temp_6[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    x[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc2.f;

end FunctionTests.ArrayExpInFunc2;
")})));
end ArrayExpInFunc2;


model ArrayExpInFunc3
 function f
  output Real o = 1.0;
  protected Real x[2,2];
 algorithm
  x[1,:] := {1,2};
  x[2,:] := {3,4};
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc3",
            description="Scalarization of functions: assign to slice",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc3
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc3.f();

public
 function FunctionTests.ArrayExpInFunc3.f
  output Real o;
  Real[:,:] x;
  Integer[:] temp_1;
  Integer[:] temp_2;
 algorithm
  o := 1.0;
  init x as Real[2, 2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[1,i1] := temp_1[i1];
  end for;
  init temp_2 as Integer[2];
  temp_2[1] := 3;
  temp_2[2] := 4;
  for i1 in 1:2 loop
   x[2,i1] := temp_2[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc3.f;

end FunctionTests.ArrayExpInFunc3;
")})));
end ArrayExpInFunc3;


model ArrayExpInFunc4
 function f
  output Real o = 1.0;
  protected Real x[2,2] = {{1,2},{3,4}} * {{1,2},{3,4}};
 algorithm
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc4",
            description="Scalarization of functions: binding exp to array var",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc4
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc4.f();

public
 function FunctionTests.ArrayExpInFunc4.f
  output Real o;
  Real[:,:] x;
  Integer[:,:] temp_1;
  Integer temp_2;
  Integer[:,:] temp_3;
  Integer[:] temp_4;
  Integer[:] temp_5;
  Integer[:,:] temp_6;
  Integer[:] temp_7;
  Integer[:] temp_8;
 algorithm
  o := 1.0;
  init x as Real[2, 2];
  init temp_1 as Integer[2, 2];
  init temp_3 as Integer[2, 2];
  init temp_4 as Integer[2];
  temp_4[1] := 1;
  temp_4[2] := 2;
  for i4 in 1:2 loop
   temp_3[1,i4] := temp_4[i4];
  end for;
  init temp_5 as Integer[2];
  temp_5[1] := 3;
  temp_5[2] := 4;
  for i4 in 1:2 loop
   temp_3[2,i4] := temp_5[i4];
  end for;
  init temp_6 as Integer[2, 2];
  init temp_7 as Integer[2];
  temp_7[1] := 1;
  temp_7[2] := 2;
  for i3 in 1:2 loop
   temp_6[1,i3] := temp_7[i3];
  end for;
  init temp_8 as Integer[2];
  temp_8[1] := 3;
  temp_8[2] := 4;
  for i3 in 1:2 loop
   temp_6[2,i3] := temp_8[i3];
  end for;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    temp_2 := 0;
    for i3 in 1:2 loop
     temp_2 := temp_2 + temp_3[i1,i3] * temp_6[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    x[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc4.f;

end FunctionTests.ArrayExpInFunc4;
")})));
end ArrayExpInFunc4;


model ArrayExpInFunc5
 function f
  input Real a;
  output Real o;
  protected Real x;
  protected Real y;
 algorithm
  (x, y) := f2({1,2,3} * {1,2,3});
  o := a + x + y;
 end f;
 
 function f2
  input Real a;
  output Real b = a;
  output Real c = a;
 algorithm
 end f2;
 
 Real x = f({1,2,3} * {1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc5",
            description="Scalarization of functions: (x, y) := f(...) syntax",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc5
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc5.f(1 + 2 * 2 + 3 * 3);

public
 function FunctionTests.ArrayExpInFunc5.f
  input Real a;
  output Real o;
  Real x;
  Real y;
  Integer temp_1;
  Integer temp_2;
  Integer[:] temp_3;
  Integer[:] temp_4;
 algorithm
  init temp_3 as Integer[3];
  temp_3[1] := 1;
  temp_3[2] := 2;
  temp_3[3] := 3;
  init temp_4 as Integer[3];
  temp_4[1] := 1;
  temp_4[2] := 2;
  temp_4[3] := 3;
  temp_2 := 0;
  for i1 in 1:3 loop
   temp_2 := temp_2 + temp_3[i1] * temp_4[i1];
  end for;
  temp_1 := temp_2;
  (x, y) := FunctionTests.ArrayExpInFunc5.f2(temp_1);
  o := a + x + y;
  return;
 end FunctionTests.ArrayExpInFunc5.f;

 function FunctionTests.ArrayExpInFunc5.f2
  input Real a;
  output Real b;
  output Real c;
 algorithm
  b := a;
  c := a;
  return;
 end FunctionTests.ArrayExpInFunc5.f2;

end FunctionTests.ArrayExpInFunc5;
")})));
end ArrayExpInFunc5;


model ArrayExpInFunc6
 function f
  output Real o = 1.0;
  protected Real x[3];
 algorithm
  if o < 2.0 then
   x := { 1, 2, 3 };
  elseif o < 1.5 then
   x := { 4, 5, 6 };
  else
   x := { 7, 8, 9 };
  end if;
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc6",
            description="Scalarization of functions: if statements",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc6
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc6.f();

public
 function FunctionTests.ArrayExpInFunc6.f
  output Real o;
  Real[:] x;
  Integer[:] temp_1;
  Integer[:] temp_2;
  Integer[:] temp_3;
 algorithm
  o := 1.0;
  init x as Real[3];
  if o < 2.0 then
   init temp_1 as Integer[3];
   temp_1[1] := 1;
   temp_1[2] := 2;
   temp_1[3] := 3;
   for i1 in 1:3 loop
    x[i1] := temp_1[i1];
   end for;
  elseif o < 1.5 then
   init temp_2 as Integer[3];
   temp_2[1] := 4;
   temp_2[2] := 5;
   temp_2[3] := 6;
   for i1 in 1:3 loop
    x[i1] := temp_2[i1];
   end for;
  else
   init temp_3 as Integer[3];
   temp_3[1] := 7;
   temp_3[2] := 8;
   temp_3[3] := 9;
   for i1 in 1:3 loop
    x[i1] := temp_3[i1];
   end for;
  end if;
  return;
 end FunctionTests.ArrayExpInFunc6.f;

end FunctionTests.ArrayExpInFunc6;
")})));
end ArrayExpInFunc6;


model ArrayExpInFunc8
 function f
  output Real o = 1.0;
  protected Real x[3];
  protected Real y[3];
 algorithm
  for i in 1:3 loop
   x[i] := i;
   y := {i*i for i in 1:3};
  end for;
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc8",
            description="Scalarization of functions: for statements",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc8
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc8.f();

public
 function FunctionTests.ArrayExpInFunc8.f
  output Real o;
  Real[:] x;
  Real[:] y;
  Integer[:] temp_1;
 algorithm
  o := 1.0;
  init x as Real[3];
  init y as Real[3];
  for i in 1:3 loop
   x[i] := i;
   init temp_1 as Integer[3];
   temp_1[1] := 1;
   temp_1[2] := 2 * 2;
   temp_1[3] := 3 * 3;
   for i1 in 1:3 loop
    y[i1] := temp_1[i1];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc8.f;

end FunctionTests.ArrayExpInFunc8;
")})));
end ArrayExpInFunc8;


model ArrayExpInFunc9
 function f
  output Real o = 1.0;
  protected Real x[3];
  protected Integer y = 3;
 algorithm
  while y > 0 loop
   x := 1:3;
   x[y] := y;
   y := y - 1;
  end while;
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc9",
            description="Scalarization of functions: while statements",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc9
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc9.f();

public
 function FunctionTests.ArrayExpInFunc9.f
  output Real o;
  Real[:] x;
  Integer y;
 algorithm
  o := 1.0;
  init x as Real[3];
  y := 3;
  while y > 0 loop
   for i1 in 1:3 loop
    x[i1] := i1;
   end for;
   x[y] := y;
   y := y - 1;
  end while;
  return;
 end FunctionTests.ArrayExpInFunc9.f;

end FunctionTests.ArrayExpInFunc9;
")})));
end ArrayExpInFunc9;

model ArrayExpInFunc10
function f
	input Real[:,2] a;
	output Real[size(a,1)] b;
algorithm
	b := a[:,2];
end f;
	Real[3,2] x = {{1,2},{3,4},{5,6}};
	Real y[3];
equation
	y = f(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc10",
            description="Scalarization of functions: unknown size slice",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc10
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real x[3,1];
 Real x[3,2];
 Real y[1];
 Real y[2];
 Real y[3];
equation
 ({y[1], y[2], y[3]}) = FunctionTests.ArrayExpInFunc10.f({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}, {x[3,1], x[3,2]}});
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;
 x[3,1] = 5;
 x[3,2] = 6;

public
 function FunctionTests.ArrayExpInFunc10.f
  input Real[:,:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   b[i1] := a[i1,2];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc10.f;

end FunctionTests.ArrayExpInFunc10;
")})));
end ArrayExpInFunc10;

model ArrayExpInFunc11
	
record R
	Real x;
end R;
function f
	input Real[2,:,2] a;
	output Real[3,size(a,2)] b;
algorithm
	b[1,:] := a[2,:,1];
	b[{2,3},:] := 2*a[:,:,1];
end f;
	constant Real[3,2] c = {{1,1},{1,1},{1,1}};
	Real[2,3,2] x = {c,c};
	Real y[3,3];
equation
	y = f(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc11",
            description="Scalarization of functions: unknown size slice",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc11
 constant Real c[1,1] = 1;
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[1,3,1];
 Real x[1,3,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real x[2,3,1];
 Real x[2,3,2];
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
 Real y[3,1];
 Real y[3,2];
 Real y[3,3];
equation
 ({{y[1,1], y[1,2], y[1,3]}, {y[2,1], y[2,2], y[2,3]}, {y[3,1], y[3,2], y[3,3]}}) = FunctionTests.ArrayExpInFunc11.f({{{x[1,1,1], x[1,1,2]}, {x[1,2,1], x[1,2,2]}, {x[1,3,1], x[1,3,2]}}, {{x[2,1,1], x[2,1,2]}, {x[2,2,1], x[2,2,2]}, {x[2,3,1], x[2,3,2]}}});
 x[1,1,1] = 1.0;
 x[1,1,2] = 1.0;
 x[1,2,1] = 1.0;
 x[1,2,2] = 1.0;
 x[1,3,1] = 1.0;
 x[1,3,2] = 1.0;
 x[2,1,1] = 1.0;
 x[2,1,2] = 1.0;
 x[2,2,1] = 1.0;
 x[2,2,2] = 1.0;
 x[2,3,1] = 1.0;
 x[2,3,2] = 1.0;

public
 function FunctionTests.ArrayExpInFunc11.f
  input Real[:,:,:] a;
  output Real[:,:] b;
  Integer[:] temp_1;
 algorithm
  init b as Real[3, size(a, 2)];
  for i1 in 1:size(a, 2) loop
   b[1,i1] := a[2,i1,1];
  end for;
  init temp_1 as Integer[2];
  temp_1[1] := 2;
  temp_1[2] := 3;
  for i1 in 1:2 loop
   for i2 in 1:size(a, 2) loop
    b[temp_1[i1],i2] := 2 * a[i1,i2,1];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc11.f;

end FunctionTests.ArrayExpInFunc11;
")})));
end ArrayExpInFunc11;

model ArrayExpInFunc12
	
record R
	Real x[2];
end R;
function f1
	output Real[2] o = {1,2};
	algorithm
end f1;
function f2
	output R b;
algorithm
	b := R(f1());
end f2;
	R r;
equation
	r = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc12",
            description="Scalarization of functions: temp in record constructor",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc12
 Real r.x[1];
 Real r.x[2];
equation
 (FunctionTests.ArrayExpInFunc12.R({r.x[1], r.x[2]})) = FunctionTests.ArrayExpInFunc12.f2();

public
 function FunctionTests.ArrayExpInFunc12.f2
  output FunctionTests.ArrayExpInFunc12.R b;
  Real[:] temp_1;
 algorithm
  init temp_1 as Real[2];
  (temp_1) := FunctionTests.ArrayExpInFunc12.f1();
  for i1 in 1:2 loop
   b.x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc12.f2;

 function FunctionTests.ArrayExpInFunc12.f1
  output Real[:] o;
  Integer[:] temp_1;
 algorithm
  init o as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   o[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc12.f1;

 record FunctionTests.ArrayExpInFunc12.R
  Real x[2];
 end FunctionTests.ArrayExpInFunc12.R;

end FunctionTests.ArrayExpInFunc12;
")})));
end ArrayExpInFunc12;

model ArrayExpInFunc13
	
function f
	input Integer[:] i;
	input Real[:] x;
	output Real[size(i,1)] y;
algorithm
	y := x[i];
end f;

Real[3] x = f({1,2,3}, {1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc13",
            description="Scalarization of functions: unknown size slice",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc13
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = FunctionTests.ArrayExpInFunc13.f({1, 2, 3}, {1, 2, 3});

public
 function FunctionTests.ArrayExpInFunc13.f
  input Integer[:] i;
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(i, 1)];
  for i1 in 1:size(i, 1) loop
   y[i1] := x[i[i1]];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc13.f;

end FunctionTests.ArrayExpInFunc13;
")})));
end ArrayExpInFunc13;

model ArrayExpInFunc14
	
function f
	input Integer[:] is1;
	input Integer[size(is1,1)] is2;
	input Real[:,:] x;
	output Real[size(is1,1),size(is1,1)] y;
algorithm
	y := x[is1,is2];
	y := x[is2,is1] + y;
end f;

Real[2,2] x = f({1,2}, {1,2}, {{1,2},{3,4}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc14",
            description="Scalarization of functions: unknown size slice",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc14
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 ({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}}) = FunctionTests.ArrayExpInFunc14.f({1, 2}, {1, 2}, {{1, 2}, {3, 4}});

public
 function FunctionTests.ArrayExpInFunc14.f
  input Integer[:] is1;
  input Integer[:] is2;
  input Real[:,:] x;
  output Real[:,:] y;
  Real[:,:] temp_1;
 algorithm
  init y as Real[size(is1, 1), size(is1, 1)];
  for i1 in 1:size(is1, 1) loop
   for i2 in 1:size(is1, 1) loop
    y[i1,i2] := x[is1[i1],is2[i2]];
   end for;
  end for;
  init temp_1 as Real[size(is2, 1), size(is1, 1)];
  for i1 in 1:size(is2, 1) loop
   for i2 in 1:size(is1, 1) loop
    temp_1[i1,i2] := x[is2[i1],is1[i2]] + y[i1,i2];
   end for;
  end for;
  for i1 in 1:size(is1, 1) loop
   for i2 in 1:size(is1, 1) loop
    y[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc14.f;

end FunctionTests.ArrayExpInFunc14;
")})));
end ArrayExpInFunc14;

model ArrayExpInFunc15
	
function f
	input Integer[:] is1;
	input Integer[:] is2;
	input Real[:,:] x;
	output Real[size(is2,1), 2] y;
algorithm
	y := x[is1[is2], {1,2}];
end f;

Real[2,2] x = f({1,2,3}, {2,3}, {{1,2,3},{4,5,6}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc15",
            description="Scalarization of functions: unknown size slice",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc15
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 ({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}}) = FunctionTests.ArrayExpInFunc15.f({1, 2, 3}, {2, 3}, {{1, 2, 3}, {4, 5, 6}});

public
 function FunctionTests.ArrayExpInFunc15.f
  input Integer[:] is1;
  input Integer[:] is2;
  input Real[:,:] x;
  output Real[:,:] y;
  Integer[:] temp_1;
 algorithm
  init y as Real[size(is2, 1), 2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:size(is2, 1) loop
   for i2 in 1:2 loop
    y[i1,i2] := x[is1[is2[i1]],temp_1[i2]];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc15.f;

end FunctionTests.ArrayExpInFunc15;
")})));
end ArrayExpInFunc15;

model ArrayExpInFunc16
	
function f
	input Integer[:] is1;
	input Integer[:] is2;
	input Real[:,:] x;
	output Real[size(is2,1), 2] y;
algorithm
	y := x[is1[{1,2}],is2];
end f;

Real[2,2] x = f({1,2,3}, {2,3}, {{1,2,3},{4,5,6}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc16",
            description="Scalarization of functions: unknown size slice",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc16
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 ({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}}) = FunctionTests.ArrayExpInFunc16.f({1, 2, 3}, {2, 3}, {{1, 2, 3}, {4, 5, 6}});

public
 function FunctionTests.ArrayExpInFunc16.f
  input Integer[:] is1;
  input Integer[:] is2;
  input Real[:,:] x;
  output Real[:,:] y;
  Integer[:] temp_1;
 algorithm
  init y as Real[size(is2, 1), 2];
  assert(size(is2, 1) == 2, \"Mismatching sizes in FunctionTests.ArrayExpInFunc16.f\");
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:size(is2, 1) loop
   for i2 in 1:2 loop
    y[i1,i2] := x[is1[temp_1[i1]],is2[i2]];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc16.f;

end FunctionTests.ArrayExpInFunc16;
")})));
end ArrayExpInFunc16;

model ArrayExpInFunc17
	
function f
	input Integer is1;
	input Integer is2;
	input Integer n;
	input Real[:,:] x;
	output Real[n, size(x,2)] y;
algorithm
	y[:] := x[is1:is2];
end f;

Real[3,3] x = f(1,3,3,{{1,2,3},{4,5,6}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc17",
            description="Scalarization of functions: unknown size range exp as slice",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc17
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[3,1];
 Real x[3,2];
 Real x[3,3];
equation
 ({{x[1,1], x[1,2], x[1,3]}, {x[2,1], x[2,2], x[2,3]}, {x[3,1], x[3,2], x[3,3]}}) = FunctionTests.ArrayExpInFunc17.f(1, 3, 3, {{1, 2, 3}, {4, 5, 6}});

public
 function FunctionTests.ArrayExpInFunc17.f
  input Integer is1;
  input Integer is2;
  input Integer n;
  input Real[:,:] x;
  output Real[:,:] y;
 algorithm
  init y as Real[n, size(x, 2)];
  for i1 in 1:n loop
   y[i1] := x[is1 + (i1 - 1)];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc17.f;

end FunctionTests.ArrayExpInFunc17;
")})));
end ArrayExpInFunc17;

model ArrayExpInFunc18
	
function f
	input Real[:] i;
	output Real[size(i,1)] o;
	output Real dummy = 1;
algorithm
	o := i;
end f;

function fw
	input Integer[:] i;
	output Real[size(i,1)] o;
	output Real dummy = 1;
algorithm
	o[{1,3,5}] := {1,1,1};
	(o[i],) := f(o[i]);
end fw;

Real[3] ae;
equation
	(ae[{3,2,1}],) = fw({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc18",
            description="Scalarization of functions: unknown size slice in function call stmt",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc18
 Real ae[1];
 Real ae[2];
 Real ae[3];
equation
 ({ae[3], ae[2], ae[1]}, ) = FunctionTests.ArrayExpInFunc18.fw({1, 2, 3});

public
 function FunctionTests.ArrayExpInFunc18.fw
  input Integer[:] i;
  output Real[:] o;
  output Real dummy;
  Integer[:] temp_1;
  Integer[:] temp_2;
  Real[:] temp_3;
  Real[:] temp_4;
 algorithm
  init o as Real[size(i, 1)];
  dummy := 1;
  init temp_1 as Integer[3];
  temp_1[1] := 1;
  temp_1[2] := 3;
  temp_1[3] := 5;
  init temp_2 as Integer[3];
  temp_2[1] := 1;
  temp_2[2] := 1;
  temp_2[3] := 1;
  for i1 in 1:3 loop
   o[temp_1[i1]] := temp_2[i1];
  end for;
  init temp_3 as Real[size(i, 1)];
  for i1 in 1:size(i, 1) loop
   temp_3[i1] := o[i[i1]];
  end for;
  init temp_4 as Real[size(i, 1)];
  (temp_4, ) := FunctionTests.ArrayExpInFunc18.f(temp_3);
  for i1 in 1:size(i, 1) loop
   o[i[i1]] := temp_4[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc18.fw;

 function FunctionTests.ArrayExpInFunc18.f
  input Real[:] i;
  output Real[:] o;
  output Real dummy;
 algorithm
  init o as Real[size(i, 1)];
  dummy := 1;
  for i1 in 1:size(i, 1) loop
   o[i1] := i[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc18.f;

end FunctionTests.ArrayExpInFunc18;
")})));
end ArrayExpInFunc18;

model ArrayExpInFunc19
	
function f
	input Real[:,:] x1;
	input Real[:,:] x2;
	output Real[2,size(x1,1),size(x1,2)] y;
algorithm
	y := {x1, x2};
end f;

Real[2,2,2] ae = f({{1,2},{3,4}},{{1,2},{3,4}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc19",
            description="Scalarization of functions: unknown size array expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc19
 Real ae[1,1,1];
 Real ae[1,1,2];
 Real ae[1,2,1];
 Real ae[1,2,2];
 Real ae[2,1,1];
 Real ae[2,1,2];
 Real ae[2,2,1];
 Real ae[2,2,2];
equation
 ({{{ae[1,1,1], ae[1,1,2]}, {ae[1,2,1], ae[1,2,2]}}, {{ae[2,1,1], ae[2,1,2]}, {ae[2,2,1], ae[2,2,2]}}}) = FunctionTests.ArrayExpInFunc19.f({{1, 2}, {3, 4}}, {{1, 2}, {3, 4}});

public
 function FunctionTests.ArrayExpInFunc19.f
  input Real[:,:] x1;
  input Real[:,:] x2;
  output Real[:,:,:] y;
  Real[:,:,:] temp_1;
 algorithm
  init y as Real[2, size(x1, 1), size(x1, 2)];
  init temp_1 as Real[2, size(x1, 1), size(x1, 2)];
  for i1 in 1:size(x1, 1) loop
   for i2 in 1:size(x1, 2) loop
    temp_1[1,i1,i2] := x1[i1,i2];
   end for;
  end for;
  for i1 in 1:size(x2, 1) loop
   for i2 in 1:size(x2, 2) loop
    temp_1[2,i1,i2] := x2[i1,i2];
   end for;
  end for;
  for i1 in 1:2 loop
   for i2 in 1:size(x1, 1) loop
    for i3 in 1:size(x1, 2) loop
     y[i1,i2,i3] := temp_1[i1,i2,i3];
    end for;
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc19.f;

end FunctionTests.ArrayExpInFunc19;
")})));
end ArrayExpInFunc19;

model ArrayExpInFunc20
	
function f
	input Real[:] x1;
	output Real[2,size(x1,1)+2] o;
algorithm
	o := [{x1}, 1, 2; 3,{x1},4];
end f;

Real[2,4] ae = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc20",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc20
 Real ae[1,1];
 Real ae[1,2];
 Real ae[1,3];
 Real ae[1,4];
 Real ae[2,1];
 Real ae[2,2];
 Real ae[2,3];
 Real ae[2,4];
equation
 ({{ae[1,1], ae[1,2], ae[1,3], ae[1,4]}, {ae[2,1], ae[2,2], ae[2,3], ae[2,4]}}) = FunctionTests.ArrayExpInFunc20.f({1, 2});

public
 function FunctionTests.ArrayExpInFunc20.f
  input Real[:] x1;
  output Real[:,:] o;
  Real[:,:] temp_1;
  Real[:,:] temp_2;
  Real[:,:] temp_3;
  Real[:,:] temp_4;
  Real[:,:] temp_5;
 algorithm
  init o as Real[2, size(x1, 1) + 2];
  assert(size(x1, 1) + 1 + 1 == 1 + size(x1, 1) + 1, \"Mismatching size in dimension 2 of expression [{x1[:]}, 1, 2; 3, {x1[:]}, 4] in function FunctionTests.ArrayExpInFunc20.f\");
  init temp_1 as Real[2, size(x1, 1) + 1 + 1];
  init temp_2 as Real[1, size(x1, 1) + 1 + 1];
  init temp_3 as Real[1, size(x1, 1)];
  for i5 in 1:size(x1, 1) loop
   temp_3[1,i5] := x1[i5];
  end for;
  for i3 in 1:1 loop
   for i4 in 1:size(x1, 1) loop
    temp_2[i3,i4] := temp_3[i3,i4];
   end for;
  end for;
  temp_2[1,1 + size(x1, 1)] := 1;
  temp_2[1,1 + (size(x1, 1) + 1)] := 2;
  for i1 in 1:1 loop
   for i2 in 1:size(x1, 1) + 1 + 1 loop
    temp_1[i1,i2] := temp_2[i1,i2];
   end for;
  end for;
  init temp_4 as Real[1, 1 + size(x1, 1) + 1];
  temp_4[1,1] := 3;
  init temp_5 as Real[1, size(x1, 1)];
  for i5 in 1:size(x1, 1) loop
   temp_5[1,i5] := x1[i5];
  end for;
  for i3 in 1:1 loop
   for i4 in 1:size(x1, 1) loop
    temp_4[i3,i4 + 1] := temp_5[i3,i4];
   end for;
  end for;
  temp_4[1,1 + (1 + size(x1, 1))] := 4;
  for i1 in 1:1 loop
   for i2 in 1:1 + size(x1, 1) + 1 loop
    temp_1[i1 + 1,i2] := temp_4[i1,i2];
   end for;
  end for;
  for i1 in 1:2 loop
   for i2 in 1:size(x1, 1) + 2 loop
    o[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc20.f;

end FunctionTests.ArrayExpInFunc20;
")})));
end ArrayExpInFunc20;

model ArrayExpInFunc20ceval
    
function f
    input Real[:] x1;
    output Real[2,size(x1,1)+2] o;
algorithm
    o := [{x1}, 1, 2; 3,{x1},4];
end f;

Real[2,4] ae = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc20ceval",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=true,
            eliminate_alias_variables=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc20ceval
 constant Real ae[1,1] = 1;
 constant Real ae[1,2] = 2;
 constant Real ae[1,3] = 1;
 constant Real ae[1,4] = 2;
 constant Real ae[2,1] = 3;
 constant Real ae[2,2] = 1;
 constant Real ae[2,3] = 2;
 constant Real ae[2,4] = 4;
end FunctionTests.ArrayExpInFunc20ceval;
")})));
end ArrayExpInFunc20ceval;

model ArrayExpInFunc21
	
function f
	input Real[:] x1;
	input Real[:,:] x2;
	input Real[:,:] x3;
	output Real[size(x1,1)*2+size(x3,1),size(x2,2)+1] y;
algorithm
	y := [x1, x2; x2, x1; x3];
end f;

Real[5,3] ae = f({1,2},{{3,4},{5,6}},{{10,11,12}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc21",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc21
 Real ae[1,1];
 Real ae[1,2];
 Real ae[1,3];
 Real ae[2,1];
 Real ae[2,2];
 Real ae[2,3];
 Real ae[3,1];
 Real ae[3,2];
 Real ae[3,3];
 Real ae[4,1];
 Real ae[4,2];
 Real ae[4,3];
 Real ae[5,1];
 Real ae[5,2];
 Real ae[5,3];
equation
 ({{ae[1,1], ae[1,2], ae[1,3]}, {ae[2,1], ae[2,2], ae[2,3]}, {ae[3,1], ae[3,2], ae[3,3]}, {ae[4,1], ae[4,2], ae[4,3]}, {ae[5,1], ae[5,2], ae[5,3]}}) = FunctionTests.ArrayExpInFunc21.f({1, 2}, {{3, 4}, {5, 6}}, {{10, 11, 12}});

public
 function FunctionTests.ArrayExpInFunc21.f
  input Real[:] x1;
  input Real[:,:] x2;
  input Real[:,:] x3;
  output Real[:,:] y;
  Real[:,:] temp_1;
  Real[:,:] temp_2;
  Real[:,:] temp_3;
  Real[:,:] temp_4;
 algorithm
  init y as Real[size(x1, 1) * 2 + size(x3, 1), size(x2, 2) + 1];
  assert(1 + size(x2, 2) == size(x2, 2) + 1, \"Mismatching size in dimension 2 of expression [x1[:], x2[:,:]; x2[:,:], x1[:]; x3[:,:]] in function FunctionTests.ArrayExpInFunc21.f\");
  assert(1 + size(x2, 2) == size(x3, 2), \"Mismatching size in dimension 2 of expression [x1[:], x2[:,:]; x2[:,:], x1[:]; x3[:,:]] in function FunctionTests.ArrayExpInFunc21.f\");
  assert(size(x1, 1) == size(x2, 1), \"Mismatching size in dimension 1 of expression x1[:], x2[:,:] in function FunctionTests.ArrayExpInFunc21.f\");
  assert(size(x2, 1) == size(x1, 1), \"Mismatching size in dimension 1 of expression x2[:,:], x1[:] in function FunctionTests.ArrayExpInFunc21.f\");
  init temp_1 as Real[size(x1, 1) + size(x2, 1) + size(x3, 1), 1 + size(x2, 2)];
  init temp_2 as Real[size(x1, 1), 1 + size(x2, 2)];
  for i3 in 1:size(x1, 1) loop
   temp_2[i3,1] := x1[i3];
  end for;
  for i3 in 1:size(x2, 1) loop
   for i4 in 1:size(x2, 2) loop
    temp_2[i3,i4 + 1] := x2[i3,i4];
   end for;
  end for;
  for i1 in 1:size(x1, 1) loop
   for i2 in 1:1 + size(x2, 2) loop
    temp_1[i1,i2] := temp_2[i1,i2];
   end for;
  end for;
  init temp_3 as Real[size(x2, 1), size(x2, 2) + 1];
  for i3 in 1:size(x2, 1) loop
   for i4 in 1:size(x2, 2) loop
    temp_3[i3,i4] := x2[i3,i4];
   end for;
  end for;
  for i3 in 1:size(x1, 1) loop
   temp_3[i3,1 + size(x2, 2)] := x1[i3];
  end for;
  for i1 in 1:size(x2, 1) loop
   for i2 in 1:size(x2, 2) + 1 loop
    temp_1[i1 + size(x1, 1),i2] := temp_3[i1,i2];
   end for;
  end for;
  init temp_4 as Real[size(x3, 1), size(x3, 2)];
  for i3 in 1:size(x3, 1) loop
   for i4 in 1:size(x3, 2) loop
    temp_4[i3,i4] := x3[i3,i4];
   end for;
  end for;
  for i1 in 1:size(x3, 1) loop
   for i2 in 1:size(x3, 2) loop
    temp_1[i1 + (size(x1, 1) + size(x2, 1)),i2] := temp_4[i1,i2];
   end for;
  end for;
  for i1 in 1:size(x1, 1) * 2 + size(x3, 1) loop
   for i2 in 1:size(x2, 2) + 1 loop
    y[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc21.f;

end FunctionTests.ArrayExpInFunc21;
")})));
end ArrayExpInFunc21;

model ArrayExpInFunc22
	
function f
	input Integer[:] a;
	input Integer[size(a,1)] b;
	input Real[:,:] x;
	output Real[size(a,1),size(a,1)] y;
algorithm
	y := transpose([x[a,a]]);
	y := transpose([x[a,b]]);
end f;

Real[2,2] ae = f({1,2},{2,1},{{3,4},{5,6},{7,8}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc22",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc22
 Real ae[1,1];
 Real ae[1,2];
 Real ae[2,1];
 Real ae[2,2];
equation
 ({{ae[1,1], ae[1,2]}, {ae[2,1], ae[2,2]}}) = FunctionTests.ArrayExpInFunc22.f({1, 2}, {2, 1}, {{3, 4}, {5, 6}, {7, 8}});

public
 function FunctionTests.ArrayExpInFunc22.f
  input Integer[:] a;
  input Integer[:] b;
  input Real[:,:] x;
  output Real[:,:] y;
  Real[:,:] temp_1;
  Real[:,:] temp_2;
  Real[:,:] temp_3;
  Real[:,:] temp_4;
 algorithm
  init y as Real[size(a, 1), size(a, 1)];
  init temp_1 as Real[size(a, 1), size(a, 1)];
  init temp_2 as Real[size(a, 1), size(a, 1)];
  for i3 in 1:size(a, 1) loop
   for i4 in 1:size(a, 1) loop
    temp_2[i3,i4] := x[a[i3],a[i4]];
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 1) loop
    temp_1[i1,i2] := temp_2[i1,i2];
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 1) loop
    y[i1,i2] := temp_1[i2,i1];
   end for;
  end for;
  init temp_3 as Real[size(a, 1), size(b, 1)];
  init temp_4 as Real[size(a, 1), size(b, 1)];
  for i3 in 1:size(a, 1) loop
   for i4 in 1:size(b, 1) loop
    temp_4[i3,i4] := x[a[i3],b[i4]];
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 1) loop
    temp_3[i1,i2] := temp_4[i1,i2];
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 1) loop
    y[i1,i2] := temp_3[i2,i1];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc22.f;

end FunctionTests.ArrayExpInFunc22;
")})));
end ArrayExpInFunc22;

model ArrayExpInFunc23
	
function f
  input Integer[:,:] a;
  input Integer[size(a,2),:] b;
  output Real[size(a,1),size(b,2)] o;
algorithm
  o := f(a*b,a);
end f;

Real[1,1] x = f({{1}},{{1}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc23",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc23
 Real x[1,1];
equation
 ({{x[1,1]}}) = FunctionTests.ArrayExpInFunc23.f({{1}}, {{1}});

public
 function FunctionTests.ArrayExpInFunc23.f
  input Integer[:,:] a;
  input Integer[:,:] b;
  output Real[:,:] o;
  Integer[:,:] temp_1;
  Integer temp_2;
 algorithm
  init o as Real[size(a, 1), size(b, 2)];
  init temp_1 as Integer[size(a, 1), size(b, 2)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    temp_2 := 0;
    for i3 in 1:size(b, 1) loop
     temp_2 := temp_2 + a[i1,i3] * b[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  (o) := FunctionTests.ArrayExpInFunc23.f(temp_1, a);
  return;
 end FunctionTests.ArrayExpInFunc23.f;

end FunctionTests.ArrayExpInFunc23;
")})));
end ArrayExpInFunc23;

model ArrayExpInFunc24
	
function f
  input Integer[:] in1;
  input Integer[:] in2;
  input Real[:] o_in;
  output Real[size(in1,1)] o;
algorithm
  o[in1] := f(in1, in2, o_in[in2]);
end f;

Real[1] x = f({1},{1},{1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc24",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc24
 Real x[1];
equation
 ({x[1]}) = FunctionTests.ArrayExpInFunc24.f({1}, {1}, {1});

public
 function FunctionTests.ArrayExpInFunc24.f
  input Integer[:] in1;
  input Integer[:] in2;
  input Real[:] o_in;
  output Real[:] o;
  Real[:] temp_1;
  Real[:] temp_2;
 algorithm
  init o as Real[size(in1, 1)];
  init temp_1 as Real[size(in2, 1)];
  for i1 in 1:size(in2, 1) loop
   temp_1[i1] := o_in[in2[i1]];
  end for;
  init temp_2 as Real[size(in1, 1)];
  (temp_2) := FunctionTests.ArrayExpInFunc24.f(in1, in2, temp_1);
  for i1 in 1:size(in1, 1) loop
   o[in1[i1]] := temp_2[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc24.f;

end FunctionTests.ArrayExpInFunc24;
")})));
end ArrayExpInFunc24;

model ArrayExpInFunc25
	
function f
  input Integer[:,:] a;
  input Integer[size(a,2),:] b;
  input Integer[:,:] c;
  output Real[size(c,1),size(c,2)] o;
algorithm
  o := c*sum(a*b);
end f;

Real[1,1] x = f({{1}},{{1}},{{1}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc25",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc25
 Real x[1,1];
equation
 ({{x[1,1]}}) = FunctionTests.ArrayExpInFunc25.f({{1}}, {{1}}, {{1}});

public
 function FunctionTests.ArrayExpInFunc25.f
  input Integer[:,:] a;
  input Integer[:,:] b;
  input Integer[:,:] c;
  output Real[:,:] o;
  Integer temp_1;
  Integer[:,:] temp_2;
  Integer temp_3;
 algorithm
  init o as Real[size(c, 1), size(c, 2)];
  init temp_2 as Integer[size(a, 1), size(b, 2)];
  for i3 in 1:size(a, 1) loop
   for i4 in 1:size(b, 2) loop
    temp_3 := 0;
    for i5 in 1:size(b, 1) loop
     temp_3 := temp_3 + a[i3,i5] * b[i5,i4];
    end for;
    temp_2[i3,i4] := temp_3;
   end for;
  end for;
  temp_1 := 0;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    temp_1 := temp_1 + temp_2[i1,i2];
   end for;
  end for;
  for i1 in 1:size(c, 1) loop
   for i2 in 1:size(c, 2) loop
    o[i1,i2] := c[i1,i2] * temp_1;
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc25.f;

end FunctionTests.ArrayExpInFunc25;
")})));
end ArrayExpInFunc25;

model ArrayExpInFunc26
	
function f
	input Real[:,:] a;
	input Real[:,:] b;
	output Real[size(a,1),size(b,2)] o = transpose(a * b + a);
	algorithm
end f;
	Real[1,1] x = f({{1}},{{1}}); 
equation

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc26",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc26
 Real x[1,1];
equation
 ({{x[1,1]}}) = FunctionTests.ArrayExpInFunc26.f({{1}}, {{1}});

public
 function FunctionTests.ArrayExpInFunc26.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] o;
  Real[:,:] temp_1;
  Real temp_2;
 algorithm
  init o as Real[size(a, 1), size(b, 2)];
  init temp_1 as Real[size(a, 1), size(b, 2)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    temp_2 := 0.0;
    for i3 in 1:size(b, 1) loop
     temp_2 := temp_2 + a[i1,i3] * b[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    o[i1,i2] := temp_1[i2,i1] + a[i2,i1];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc26.f;

end FunctionTests.ArrayExpInFunc26;
")})));
end ArrayExpInFunc26;

model ArrayExpInFunc27
	
function f
	input Real[:,:] a;
	input Real[:,:] b;
	output Real o[size(a,1),size(b,2)] = sum(a * b * i for i in 1:size(a,1));
	algorithm
end f;
	Real x[1,1] = f({{1}},{{1}}); 
equation

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc27",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc27
 Real x[1,1];
equation
 ({{x[1,1]}}) = FunctionTests.ArrayExpInFunc27.f({{1}}, {{1}});

public
 function FunctionTests.ArrayExpInFunc27.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] o;
  Real[:,:] temp_1;
  Real[:,:] temp_2;
  Real temp_3;
 algorithm
  init o as Real[size(a, 1), size(b, 2)];
  init temp_1 as Real[size(a, 1), size(b, 2)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 1) loop
    temp_1[i1,i2] := 0.0;
    for i3 in 1:size(b, 2) loop
     init temp_2 as Real[size(a, 1), size(b, 2)];
     for i4 in 1:size(a, 1) loop
      for i5 in 1:size(b, 2) loop
       temp_3 := 0.0;
       for i6 in 1:size(b, 1) loop
        temp_3 := temp_3 + a[i4,i6] * b[i6,i5];
       end for;
       temp_2[i4,i5] := temp_3;
      end for;
     end for;
     temp_1[i1,i2] := temp_1[i1,i2] + temp_2[i2,i3] * i1;
    end for;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    o[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc27.f;

end FunctionTests.ArrayExpInFunc27;
")})));
end ArrayExpInFunc27;

model ArrayExpInFunc28
	
function f
	input Real[:,:] a;
	input Real[:,:] b;
	output Real o[size(a,1),size(b,2)] = sum(transpose(a * b * i) for i in 1:size(a,1));
	algorithm
end f;
	Real x[1,1] = f({{1}},{{1}}); 
equation

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc28",
            description="Scalarization of functions: unknown size matrix expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc28
 Real x[1,1];
equation
 ({{x[1,1]}}) = FunctionTests.ArrayExpInFunc28.f({{1}}, {{1}});

public
 function FunctionTests.ArrayExpInFunc28.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] o;
  Real[:,:] temp_1;
  Real[:,:] temp_2;
  Real temp_3;
 algorithm
  init o as Real[size(a, 1), size(b, 2)];
  init temp_1 as Real[size(b, 2), size(a, 1)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    temp_1[i1,i2] := 0.0;
    for i3 in 1:size(a, 1) loop
     init temp_2 as Real[size(a, 1), size(b, 2)];
     for i4 in 1:size(a, 1) loop
      for i5 in 1:size(b, 2) loop
       temp_3 := 0.0;
       for i6 in 1:size(b, 1) loop
        temp_3 := temp_3 + a[i4,i6] * b[i6,i5];
       end for;
       temp_2[i4,i5] := temp_3;
      end for;
     end for;
     temp_1[i1,i2] := temp_1[i1,i2] + temp_2[i3,i2] * i1;
    end for;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    o[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc28.f;

end FunctionTests.ArrayExpInFunc28;
")})));
end ArrayExpInFunc28;

model ArrayExpInFunc29
    
function f
  input Real[:, :] a;
  input Real[:, :] b;
  output Real[size(a, 1) + size(b, 1), size(b, 2)] o = cat(1,a,b);
   algorithm
end f;
    Real y[2,1] = f({{1}},{{1}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc29",
            description="Scalarization of functions: unknown size cat expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc29
 Real y[1,1];
 Real y[2,1];
equation
 ({{y[1,1]}, {y[2,1]}}) = FunctionTests.ArrayExpInFunc29.f({{1}}, {{1}});

public
 function FunctionTests.ArrayExpInFunc29.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] o;
  Real[:,:] temp_1;
 algorithm
  init o as Real[size(a, 1) + size(b, 1), size(b, 2)];
  assert(size(a, 2) == size(b, 2), \"Mismatching size in dimension 2 of expression cat(1, a[:,:], b[:,:]) in function FunctionTests.ArrayExpInFunc29.f\");
  init temp_1 as Real[size(a, 1) + size(b, 1), size(a, 2)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    temp_1[i1,i2] := a[i1,i2];
   end for;
  end for;
  for i1 in 1:size(b, 1) loop
   for i2 in 1:size(b, 2) loop
    temp_1[i1 + size(a, 1),i2] := b[i1,i2];
   end for;
  end for;
  for i1 in 1:size(a, 1) + size(b, 1) loop
   for i2 in 1:size(b, 2) loop
    o[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc29.f;

end FunctionTests.ArrayExpInFunc29;
")})));
end ArrayExpInFunc29;

model ArrayExpInFunc30
    
function f
  input Real[:, :, size(b,3) + size(c,3)] a;
  input Real[size(a,1), :, :] b;
  input Real[size(b,1), size(b,2), :] c;
  output Real[size(a,1), size(a, 2) + size(b, 2), size(a, 3)] o = cat(2,a,cat(3,b,c));
   algorithm
end f;
    Real y[1,3,3] = f({{{0,1,2},{10,11,12}}},{{{3,4}}},{{{5}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc30",
            description="Scalarization of functions: unknown size cat expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc30
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,1,3];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[1,2,3];
 Real y[1,3,1];
 Real y[1,3,2];
 Real y[1,3,3];
equation
 ({{{y[1,1,1], y[1,1,2], y[1,1,3]}, {y[1,2,1], y[1,2,2], y[1,2,3]}, {y[1,3,1], y[1,3,2], y[1,3,3]}}}) = FunctionTests.ArrayExpInFunc30.f({{{0, 1, 2}, {10, 11, 12}}}, {{{3, 4}}}, {{{5}}});

public
 function FunctionTests.ArrayExpInFunc30.f
  input Real[:,:,:] a;
  input Real[:,:,:] b;
  input Real[:,:,:] c;
  output Real[:,:,:] o;
  Real[:,:,:] temp_1;
  Real[:,:,:] temp_2;
 algorithm
  init o as Real[size(a, 1), size(a, 2) + size(b, 2), size(a, 3)];
  assert(size(a, 1) == size(b, 1), \"Mismatching size in dimension 1 of expression cat(2, a[:,:,:], cat(3, b[:,:,:], c[:,:,:])) in function FunctionTests.ArrayExpInFunc30.f\");
  assert(size(a, 3) == size(b, 3) + size(c, 3), \"Mismatching size in dimension 3 of expression cat(2, a[:,:,:], cat(3, b[:,:,:], c[:,:,:])) in function FunctionTests.ArrayExpInFunc30.f\");
  assert(size(b, 1) == size(c, 1), \"Mismatching size in dimension 1 of expression cat(3, b[:,:,:], c[:,:,:]) in function FunctionTests.ArrayExpInFunc30.f\");
  assert(size(b, 2) == size(c, 2), \"Mismatching size in dimension 2 of expression cat(3, b[:,:,:], c[:,:,:]) in function FunctionTests.ArrayExpInFunc30.f\");
  init temp_1 as Real[size(a, 1), size(a, 2) + size(b, 2), size(a, 3)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    for i3 in 1:size(a, 3) loop
     temp_1[i1,i2,i3] := a[i1,i2,i3];
    end for;
   end for;
  end for;
  init temp_2 as Real[size(b, 1), size(b, 2), size(b, 3) + size(c, 3)];
  for i4 in 1:size(b, 1) loop
   for i5 in 1:size(b, 2) loop
    for i6 in 1:size(b, 3) loop
     temp_2[i4,i5,i6] := b[i4,i5,i6];
    end for;
   end for;
  end for;
  for i4 in 1:size(c, 1) loop
   for i5 in 1:size(c, 2) loop
    for i6 in 1:size(c, 3) loop
     temp_2[i4,i5,i6 + size(b, 3)] := c[i4,i5,i6];
    end for;
   end for;
  end for;
  for i1 in 1:size(b, 1) loop
   for i2 in 1:size(b, 2) loop
    for i3 in 1:size(b, 3) + size(c, 3) loop
     temp_1[i1,i2 + size(a, 2),i3] := temp_2[i1,i2,i3];
    end for;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) + size(b, 2) loop
    for i3 in 1:size(a, 3) loop
     o[i1,i2,i3] := temp_1[i1,i2,i3];
    end for;
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc30.f;

end FunctionTests.ArrayExpInFunc30;
")})));
end ArrayExpInFunc30;

model ArrayExpInFunc30ceval
    
function f
  input Real[:, :, size(b,3) + size(c,3)] a;
  input Real[size(a,1), :, :] b;
  input Real[size(b,1), size(b,2), :] c;
  output Real[size(a,1), size(a, 2) + size(b, 2), size(a, 3)] o = cat(2,a,cat(3,b,c));
   algorithm
end f;
    Real y[1,3,3] = f({{{0,1,2},{10,11,12}}},{{{3,4}}},{{{5}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc30ceval",
            description="Scalarization of functions: unknown size cat expression",
            variability_propagation=true,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc30ceval
 constant Real y[1,1,1] = 0;
 constant Real y[1,1,2] = 1;
 constant Real y[1,1,3] = 2;
 constant Real y[1,2,1] = 10;
 constant Real y[1,2,2] = 11;
 constant Real y[1,2,3] = 12;
 constant Real y[1,3,1] = 3;
 constant Real y[1,3,2] = 4;
 constant Real y[1,3,3] = 5;
end FunctionTests.ArrayExpInFunc30ceval;
")})));
end ArrayExpInFunc30ceval;


model ArrayExpInFunc31
type E = enumeration(A,B);
function f
  input Real[:] a;
  input Integer[:] b;
  input Boolean[:] c;
  input E[:] d;
  output Real ao = max(a);
  output Integer bo = max(b);
  output Boolean co = max(c);
  output E do = max(d);
  algorithm
end f;
    Real a;
    Integer b;
    Boolean c;
    E d;
equation
    (a,b,c,d) = f({1},{1},{true},{E.A});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc31",
            description="Scalarization of functions: unknown size max expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc31
 Real a;
 discrete Integer b;
 discrete Boolean c;
 discrete FunctionTests.ArrayExpInFunc31.E d;
initial equation 
 pre(b) = 0;
 pre(d) = FunctionTests.ArrayExpInFunc31.E.A;
 pre(c) = false;
equation
 (a, b, c, d) = FunctionTests.ArrayExpInFunc31.f({1}, {1}, {true}, {FunctionTests.ArrayExpInFunc31.E.A});

public
 function FunctionTests.ArrayExpInFunc31.f
  input Real[:] a;
  input Integer[:] b;
  input Boolean[:] c;
  input FunctionTests.ArrayExpInFunc31.E[:] d;
  output Real ao;
  output Integer bo;
  output Boolean co;
  output FunctionTests.ArrayExpInFunc31.E do;
  Real temp_1;
  Integer temp_2;
  Boolean temp_3;
  FunctionTests.ArrayExpInFunc31.E temp_4;
 algorithm
  temp_1 := -1.7976931348623157E308;
  for i1 in 1:size(a, 1) loop
   temp_1 := if temp_1 > a[i1] then temp_1 else a[i1];
  end for;
  ao := temp_1;
  temp_2 := -2147483648;
  for i1 in 1:size(b, 1) loop
   temp_2 := if temp_2 > b[i1] then temp_2 else b[i1];
  end for;
  bo := temp_2;
  temp_3 := false;
  for i1 in 1:size(c, 1) loop
   temp_3 := if temp_3 > c[i1] then temp_3 else c[i1];
  end for;
  co := temp_3;
  temp_4 := FunctionTests.ArrayExpInFunc31.E.A;
  for i1 in 1:size(d, 1) loop
   temp_4 := if temp_4 > d[i1] then temp_4 else d[i1];
  end for;
  do := temp_4;
  return;
 end FunctionTests.ArrayExpInFunc31.f;

 type FunctionTests.ArrayExpInFunc31.E = enumeration(A, B);

end FunctionTests.ArrayExpInFunc31;
")})));
end ArrayExpInFunc31;

model ArrayExpInFunc32
type E = enumeration(A,B);
function f
  input Real[:,:] a;
  input Integer[:] b;
  input Boolean[:] c;
  input E[:] d;
  output Real ao = min(a);
  output Integer bo = min(b);
  output Boolean co = min(c);
  output E do = min(d);
  algorithm
end f;
    Real a;
    Integer b;
    Boolean c;
    E d;
equation
    (a,b,c,d) = f({{1}},{1},{true},{E.A});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc32",
            description="Scalarization of functions: unknown size min expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc32
 Real a;
 discrete Integer b;
 discrete Boolean c;
 discrete FunctionTests.ArrayExpInFunc32.E d;
initial equation 
 pre(b) = 0;
 pre(d) = FunctionTests.ArrayExpInFunc32.E.A;
 pre(c) = false;
equation
 (a, b, c, d) = FunctionTests.ArrayExpInFunc32.f({{1}}, {1}, {true}, {FunctionTests.ArrayExpInFunc32.E.A});

public
 function FunctionTests.ArrayExpInFunc32.f
  input Real[:,:] a;
  input Integer[:] b;
  input Boolean[:] c;
  input FunctionTests.ArrayExpInFunc32.E[:] d;
  output Real ao;
  output Integer bo;
  output Boolean co;
  output FunctionTests.ArrayExpInFunc32.E do;
  Real temp_1;
  Integer temp_2;
  Boolean temp_3;
  FunctionTests.ArrayExpInFunc32.E temp_4;
 algorithm
  temp_1 := 1.7976931348623157E308;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    temp_1 := if temp_1 < a[i1,i2] then temp_1 else a[i1,i2];
   end for;
  end for;
  ao := temp_1;
  temp_2 := 2147483647;
  for i1 in 1:size(b, 1) loop
   temp_2 := if temp_2 < b[i1] then temp_2 else b[i1];
  end for;
  bo := temp_2;
  temp_3 := true;
  for i1 in 1:size(c, 1) loop
   temp_3 := if temp_3 < c[i1] then temp_3 else c[i1];
  end for;
  co := temp_3;
  temp_4 := FunctionTests.ArrayExpInFunc32.E.B;
  for i1 in 1:size(d, 1) loop
   temp_4 := if temp_4 < d[i1] then temp_4 else d[i1];
  end for;
  do := temp_4;
  return;
 end FunctionTests.ArrayExpInFunc32.f;

 type FunctionTests.ArrayExpInFunc32.E = enumeration(A, B);

end FunctionTests.ArrayExpInFunc32;
")})));
end ArrayExpInFunc32;

model ArrayExpInFunc33
function f
  input Integer k;
  output Real ao = max(i for i in 1:k);
  algorithm
end f;
    Real a;
equation
    (a) = f(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc33",
            description="Scalarization of functions: unknown size max-iter expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc33
 Real a;
equation
 a = FunctionTests.ArrayExpInFunc33.f(1);

public
 function FunctionTests.ArrayExpInFunc33.f
  input Integer k;
  output Real ao;
  Integer temp_1;
 algorithm
  temp_1 := -2147483648;
  for i1 in 1:max(k, 0) loop
   temp_1 := if temp_1 > i1 then temp_1 else i1;
  end for;
  ao := temp_1;
  return;
 end FunctionTests.ArrayExpInFunc33.f;

end FunctionTests.ArrayExpInFunc33;
")})));
end ArrayExpInFunc33;

model ArrayExpInFunc34
    function f
        input Integer n;
        output Real[n,n] o;
      algorithm
        o := identity(n);
    end f;
    Real[1,1] y = f(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc34",
            description="Scalarization of functions: unknown size identity expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc34
 Real y[1,1];
equation
 ({{y[1,1]}}) = FunctionTests.ArrayExpInFunc34.f(1);

public
 function FunctionTests.ArrayExpInFunc34.f
  input Integer n;
  output Real[:,:] o;
  Integer[:,:] temp_1;
 algorithm
  init o as Real[n, n];
  init temp_1 as Integer[n, n];
  for i1 in 1:n loop
   for i2 in 1:n loop
    temp_1[i1,i2] := if i1 == i2 then 1 else 0;
   end for;
  end for;
  for i1 in 1:n loop
   for i2 in 1:n loop
    o[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc34.f;

end FunctionTests.ArrayExpInFunc34;
")})));
end ArrayExpInFunc34;

model ArrayExpInFunc35
    function f
        input Integer n;
        output Real o;
      algorithm
        o := sum(identity(n));
    end f;
    Real y = f(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc35",
            description="Scalarization of functions: unknown size identity expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc35
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc35.f(1);

public
 function FunctionTests.ArrayExpInFunc35.f
  input Integer n;
  output Real o;
  Integer temp_1;
  Integer[:,:] temp_2;
 algorithm
  init temp_2 as Integer[n, n];
  for i3 in 1:n loop
   for i4 in 1:n loop
    temp_2[i3,i4] := if i3 == i4 then 1 else 0;
   end for;
  end for;
  temp_1 := 0;
  for i1 in 1:n loop
   for i2 in 1:n loop
    temp_1 := temp_1 + temp_2[i1,i2];
   end for;
  end for;
  o := temp_1;
  return;
 end FunctionTests.ArrayExpInFunc35.f;

end FunctionTests.ArrayExpInFunc35;
")})));
end ArrayExpInFunc35;

model ArrayExpInFunc36
    function f
        input Real[:] a;
        output Real[size(a,1)] b;
      algorithm
        b := vector(a);
    end f;
    
    Real[1] y = f({1});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc36",
            description="Scalarization of functions: unknown size vector operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc36
 Real y[1];
equation
 ({y[1]}) = FunctionTests.ArrayExpInFunc36.f({1});

public
 function FunctionTests.ArrayExpInFunc36.f
  input Real[:] a;
  output Real[:] b;
  Real[:] temp_1;
 algorithm
  init b as Real[size(a, 1)];
  init temp_1 as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   temp_1[i1 - 1 + 1] := a[i1];
  end for;
  for i1 in 1:size(a, 1) loop
   b[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc36.f;

end FunctionTests.ArrayExpInFunc36;
")})));
end ArrayExpInFunc36;

model ArrayExpInFunc39
    function f
        input Real[:,:] a;
        output Real[size(a,1),size(a,2)] b;
      algorithm
        b := matrix(a);
    end f;
    
    Real[1,1] y = f({{3}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc39",
            description="Scalarization of functions: unknown size vector operator, matrix input",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc39
 Real y[1,1];
equation
 ({{y[1,1]}}) = FunctionTests.ArrayExpInFunc39.f({{3}});

public
 function FunctionTests.ArrayExpInFunc39.f
  input Real[:,:] a;
  output Real[:,:] b;
  Real[:,:] temp_1;
 algorithm
  init b as Real[size(a, 1), size(a, 2)];
  init temp_1 as Real[size(a, 1), size(a, 2)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    temp_1[i1,i2] := a[i1,i2];
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    b[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc39.f;

end FunctionTests.ArrayExpInFunc39;
")})));
end ArrayExpInFunc39;

model ArrayExpInFunc40
    function f
        input Real[:,:,:] a;
        output Real[size(a,1),size(a,2)] b;
      algorithm
        b := matrix(a);
    end f;
    
    Real[1,1] y = f({{{3}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc40",
            description="Scalarization of functions: unknown size vector operator, many dims input",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc40
 Real y[1,1];
equation
 ({{y[1,1]}}) = FunctionTests.ArrayExpInFunc40.f({{{3}}});

public
 function FunctionTests.ArrayExpInFunc40.f
  input Real[:,:,:] a;
  output Real[:,:] b;
  Real[:,:] temp_1;
 algorithm
  init b as Real[size(a, 1), size(a, 2)];
  assert(size(a, 3) == 1, \"Mismatching size in dimension 3 of expression matrix(a[:,:,:]) in function FunctionTests.ArrayExpInFunc40.f\");
  init temp_1 as Real[size(a, 1), size(a, 2)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    for i3 in 1:size(a, 3) loop
     temp_1[i1,i2] := a[i1,i2,i3];
    end for;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 2) loop
    b[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayExpInFunc40.f;

end FunctionTests.ArrayExpInFunc40;
")})));
end ArrayExpInFunc40;

model ArrayExpInFunc41
    function f
        input Real[:,:,:] a;
        output Real b;
      algorithm
        b := scalar(a + a);
    end f;
    
    Real y = f({{{1}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc41",
            description="Scalarization of functions: unknown size in scalar operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc41
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc41.f({{{1}}});

public
 function FunctionTests.ArrayExpInFunc41.f
  input Real[:,:,:] a;
  output Real b;
 algorithm
  assert(size(a, 1) == 1, \"Mismatching size in dimension 1 of expression scalar(a[:,:,:] + a[:,:,:]) in function FunctionTests.ArrayExpInFunc41.f\");
  assert(size(a, 2) == 1, \"Mismatching size in dimension 2 of expression scalar(a[:,:,:] + a[:,:,:]) in function FunctionTests.ArrayExpInFunc41.f\");
  assert(size(a, 3) == 1, \"Mismatching size in dimension 3 of expression scalar(a[:,:,:] + a[:,:,:]) in function FunctionTests.ArrayExpInFunc41.f\");
  b := a[1,1,1] + a[1,1,1];
  return;
 end FunctionTests.ArrayExpInFunc41.f;

end FunctionTests.ArrayExpInFunc41;
")})));
end ArrayExpInFunc41;

model ArrayExpInFunc42
    function f
      input Real a[:, :];
      input Real b[size(a, 1)];
      output Real o;

    algorithm
      o := sum({scalar(2*transpose(matrix(b))*a[:, i]) for i in 1:size(a,2)});
    end f;
    
    Real y = f({{1}},{1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc42",
            description="Scalarization of functions: unknown size in scalar operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc42
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc42.f({{1}}, {1});

public
 function FunctionTests.ArrayExpInFunc42.f
  input Real[:,:] a;
  input Real[:] b;
  output Real o;
  Real temp_1;
  Real[:] temp_2;
  Real[:] temp_3;
  Real temp_4;
  Real[:,:] temp_5;
 algorithm
  init temp_2 as Real[size(a, 2)];
  for i2 in 1:size(a, 2) loop
   init temp_3 as Real[1];
   init temp_5 as Real[size(b, 1), 1];
   for i5 in 1:size(b, 1) loop
    temp_5[i5,1] := b[i5];
   end for;
   for i3 in 1:1 loop
    temp_4 := 0.0;
    for i4 in 1:size(a, 1) loop
     temp_4 := temp_4 + 2 * temp_5[i4,i3] * a[i4,i2];
    end for;
    temp_3[i3] := temp_4;
   end for;
   temp_2[i2] := temp_3[1];
  end for;
  temp_1 := 0.0;
  for i1 in 1:size(a, 2) loop
   temp_1 := temp_1 + temp_2[i1];
  end for;
  o := temp_1;
  return;
 end FunctionTests.ArrayExpInFunc42.f;

end FunctionTests.ArrayExpInFunc42;
")})));
end ArrayExpInFunc42;

model ArrayExpInFunc43
    function f
      input Real a[:, 1];
      input Real b[1, :];
      output Real tk;
      algorithm
        tk := scalar(transpose(b*a));
    end f;
    
    Real y = f({{1},{2}},{{3,4}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc43",
            description="Scalarization of functions: unknown size in scalar operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayExpInFunc43
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc43.f({{1}, {2}}, {{3, 4}});

public
 function FunctionTests.ArrayExpInFunc43.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real tk;
  Real[:,:] temp_1;
  Real temp_2;
 algorithm
  init temp_1 as Real[1, 1];
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    temp_2 := 0.0;
    for i3 in 1:size(a, 1) loop
     temp_2 := temp_2 + b[i1,i3] * a[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  tk := temp_1[1,1];
  return;
 end FunctionTests.ArrayExpInFunc43.f;

end FunctionTests.ArrayExpInFunc43;
")})));
end ArrayExpInFunc43;

model ArrayExpInFunc44
        function F
            input Real[:] a;
            output Real[size(a,1),size(a,1)] b;
        algorithm
            b := diagonal(a);
        annotation(Inline=false);
        end F;
        Real x[2,2] = F({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc44",
            description="Scalarization of functions: unknown size in scalar operator",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc44
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 ({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}}) = FunctionTests.ArrayExpInFunc44.F({1, 2});

public
 function FunctionTests.ArrayExpInFunc44.F
  input Real[:] a;
  output Real[:,:] b;
  Real[:,:] temp_1;
 algorithm
  init b as Real[size(a, 1), size(a, 1)];
  init temp_1 as Real[size(a, 1), size(a, 1)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 1) loop
    temp_1[i1,i2] := if i1 == i2 then a[i1] else 0;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 1) loop
    b[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc44.F;

end FunctionTests.ArrayExpInFunc44;
")})));
end ArrayExpInFunc44;

model ArrayExpInFunc45
    function f1
        input Real[:] x;
        output Real[:] y = x;
        algorithm 
    end f1;
    function f2
        input Integer n;
        output Real s = sum(f1(1:n));
        algorithm
        annotation(Inline = false);
    end f2;
    Real y = f2(3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc45",
            description="Scalarization of functions: unknown size in scalar operator",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc45
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc45.f2(3);

public
 function FunctionTests.ArrayExpInFunc45.f2
  input Integer n;
  output Real s;
  Real temp_1;
  Integer[:] temp_2;
  Real[:] temp_3;
 algorithm
  init temp_2 as Integer[max(n, 0)];
  for i2 in 1:max(n, 0) loop
   temp_2[i2] := i2;
  end for;
  init temp_3 as Real[max(n, 0)];
  (temp_3) := FunctionTests.ArrayExpInFunc45.f1(temp_2);
  temp_1 := 0.0;
  for i1 in 1:max(n, 0) loop
   temp_1 := temp_1 + temp_3[i1];
  end for;
  s := temp_1;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc45.f2;

 function FunctionTests.ArrayExpInFunc45.f1
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc45.f1;

end FunctionTests.ArrayExpInFunc45;
")})));
end ArrayExpInFunc45;


model ArrayExpInFunc46
    function f
        input Real x[:];
        output Real y[size(x,1)-1];
    algorithm
        for i in 1:2 loop
            y := x[2:end];
        end for;
	end f;
    
    parameter Real[:] x1 = f({1,2,3,4,5}) annotation(Evaluate=true);
    parameter Real[:] x2 = f({6,7,8}) annotation(Evaluate=true);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayExpInFunc46",
            description="Check that we don't crash due to cached size for range expression in for loop in function",
            flatModel="
fclass FunctionTests.ArrayExpInFunc46
 eval parameter Real x1[4] = {2, 3, 4, 5} /* { 2, 3, 4, 5 } */;
 eval parameter Real x2[2] = {7, 8} /* { 7, 8 } */;

public
 function FunctionTests.ArrayExpInFunc46.f
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1) - 1];
  for i in 1:2 loop
   y[:] := x[2:size(x, 1)];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc46.f;

end FunctionTests.ArrayExpInFunc46;
")})));
end ArrayExpInFunc46;

model ArrayExpInFunc47
    function f1
        input Real[:,:] x;
        output Real y = sum(x);
        algorithm
        annotation(Inline=false);
    end f1;
    
    function f2
        input Real[2] x;
        output Real y = f1({x,x});
        algorithm
        annotation(Inline=false);
    end f2;
    
    Real y = f2({time,time});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc47",
            description="",
            flatModel="
fclass FunctionTests.ArrayExpInFunc47
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc47.f2({time, time});

public
 function FunctionTests.ArrayExpInFunc47.f2
  input Real[:] x;
  output Real y;
  Real[:,:] temp_1;
 algorithm
  init temp_1 as Real[2, 2];
  for i1 in 1:2 loop
   temp_1[1,i1] := x[i1];
  end for;
  for i1 in 1:2 loop
   temp_1[2,i1] := x[i1];
  end for;
  y := FunctionTests.ArrayExpInFunc47.f1(temp_1);
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc47.f2;

 function FunctionTests.ArrayExpInFunc47.f1
  input Real[:,:] x;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(x, 1) loop
   for i2 in 1:size(x, 2) loop
    temp_1 := temp_1 + x[i1,i2];
   end for;
  end for;
  y := temp_1;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc47.f1;

end FunctionTests.ArrayExpInFunc47;
")})));
end ArrayExpInFunc47;

model ArrayExpInFunc48
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            for j in 1:size(r[i].x, 1) loop
                y := y + r[i].x[j];
            end for;
        end for;
        annotation(Inline=false);
    end f;
    
    Real y = f({R({time})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc48",
            description="Scalarizing size expression",
            flatModel="
fclass FunctionTests.ArrayExpInFunc48
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc48.f({FunctionTests.ArrayExpInFunc48.R({time})});

public
 function FunctionTests.ArrayExpInFunc48.f
  input FunctionTests.ArrayExpInFunc48.R[:] r;
  output Real y;
 algorithm
  for i in 1:size(r, 1) loop
   for j in 1:size(r[i].x, 1) loop
    y := y + r[i].x[j];
   end for;
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc48.f;

 record FunctionTests.ArrayExpInFunc48.R
  Real x[:];
 end FunctionTests.ArrayExpInFunc48.R;

end FunctionTests.ArrayExpInFunc48;
")})));
end ArrayExpInFunc48;

model ArrayExpInFunc49
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:div(size(r,1),2) loop
            for j in 1:size(r[i:2*i].x, 2) loop
                y := y + r[i].x[j];
            end for;
        end for;
        annotation(Inline=false);
    end f;
    
    Real y = f({R({time})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc49",
            description="Scalarizing size expression",
            flatModel="
fclass FunctionTests.ArrayExpInFunc49
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc49.f({FunctionTests.ArrayExpInFunc49.R({time})});

public
 function FunctionTests.ArrayExpInFunc49.f
  input FunctionTests.ArrayExpInFunc49.R[:] r;
  output Real y;
 algorithm
  for i in 1:div(size(r, 1), 2) loop
   for j in 1:size(r[i].x, 1) loop
    y := y + r[i].x[j];
   end for;
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc49.f;

 record FunctionTests.ArrayExpInFunc49.R
  Real x[:];
 end FunctionTests.ArrayExpInFunc49.R;

end FunctionTests.ArrayExpInFunc49;
")})));
end ArrayExpInFunc49;

model ArrayExpInFunc50
    record R
        Real[:] x;
    end R;
    
    function g
        input Integer x;
        output Integer[:] y = x:2*x;
        algorithm
    end g;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:div(size(r,1),2) loop
            for j in 1:size(r[g(i)].x, 2) loop
                y := y + r[i].x[j];
            end for;
        end for;
        annotation(Inline=false);
    end f;
    
    Real y = f({R({time})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc50",
            description="Scalarizing temporary in size expression",
            flatModel="
fclass FunctionTests.ArrayExpInFunc50
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc50.f({FunctionTests.ArrayExpInFunc50.R({time})});

public
 function FunctionTests.ArrayExpInFunc50.f
  input FunctionTests.ArrayExpInFunc50.R[:] r;
  output Real y;
  Integer[:] temp_1;
 algorithm
  for i in 1:div(size(r, 1), 2) loop
   init temp_1 as Integer[max(integer(2 * i - i) + 1, 0)];
   (temp_1) := FunctionTests.ArrayExpInFunc50.g(i);
   for j in 1:size(r[temp_1[1]].x, 1) loop
    y := y + r[i].x[j];
   end for;
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc50.f;

 function FunctionTests.ArrayExpInFunc50.g
  input Integer x;
  output Integer[:] y;
 algorithm
  init y as Integer[max(integer(2 * x - x) + 1, 0)];
  for i1 in 1:max(integer(2 * x - x) + 1, 0) loop
   y[i1] := x + (i1 - 1);
  end for;
  return;
 end FunctionTests.ArrayExpInFunc50.g;

 record FunctionTests.ArrayExpInFunc50.R
  Real x[:];
 end FunctionTests.ArrayExpInFunc50.R;

end FunctionTests.ArrayExpInFunc50;
")})));
end ArrayExpInFunc50;

model ArrayExpInFunc51
    record R
        Real[:] x;
    end R;
    
    function g
        input Integer x;
        output Integer[:] y = x:2*x;
        algorithm
    end g;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:div(size(r,1),2) loop
            for j in size(r[g(i)].x) loop
                y := y + r[i].x[j];
            end for;
        end for;
        annotation(Inline=false);
    end f;
    
    Real y = f({R({time})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc51",
            description="Scalarizing temporary in size expression",
            flatModel="
fclass FunctionTests.ArrayExpInFunc51
 Real y;
equation
 y = FunctionTests.ArrayExpInFunc51.f({FunctionTests.ArrayExpInFunc51.R({time})});

public
 function FunctionTests.ArrayExpInFunc51.f
  input FunctionTests.ArrayExpInFunc51.R[:] r;
  output Real y;
  Integer[:] temp_1;
  Integer[:] temp_2;
 algorithm
  for i in 1:div(size(r, 1), 2) loop
   init temp_1 as Integer[2];
   temp_1[1] := max(integer(2 * i - i) + 1, 0);
   init temp_2 as Integer[max(integer(2 * i - i) + 1, 0)];
   (temp_2) := FunctionTests.ArrayExpInFunc51.g(i);
   temp_1[2] := size(r[temp_2[1]].x, 1);
   for j in temp_1 loop
    y := y + r[i].x[j];
   end for;
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc51.f;

 function FunctionTests.ArrayExpInFunc51.g
  input Integer x;
  output Integer[:] y;
 algorithm
  init y as Integer[max(integer(2 * x - x) + 1, 0)];
  for i1 in 1:max(integer(2 * x - x) + 1, 0) loop
   y[i1] := x + (i1 - 1);
  end for;
  return;
 end FunctionTests.ArrayExpInFunc51.g;

 record FunctionTests.ArrayExpInFunc51.R
  Real x[:];
 end FunctionTests.ArrayExpInFunc51.R;

end FunctionTests.ArrayExpInFunc51;
")})));
end ArrayExpInFunc51;

model ArrayExpInFunc52
    // This test gives wrong result a getArray call is not 
    // cached due boundariescrossed changing during computation.
    // Looks like the expressions in the type on flat function call
    // are not final. 

    record R
        Integer[:] x;
    end R;
    
    function g
        input Integer[:] x;
        output Integer[:] y = x;
        algorithm
    end g;
    
    function f
        input R[:] r;
        output Integer[:] y = size(r[g(r[1].x)].x);
    algorithm
        annotation(Inline=false);
    end f;
    
    Real[:] y = f({R({1})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayExpInFunc52",
            description="Scalarizing temporary in size expression",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayExpInFunc52
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = FunctionTests.ArrayExpInFunc52.f({FunctionTests.ArrayExpInFunc52.R({1})});

public
 function FunctionTests.ArrayExpInFunc52.f
  input FunctionTests.ArrayExpInFunc52.R[:] r;
  output Integer[:] y;
  Integer[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init y as Integer[2];
  init temp_1 as Integer[2];
  temp_1[1] := size(r[1].x, 1);
  init temp_2 as Integer[size(r[1].x, 1)];
  (temp_2) := FunctionTests.ArrayExpInFunc52.g(r[1].x);
  temp_1[2] := size(r[temp_2[1]].x, 1);
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayExpInFunc52.f;

 function FunctionTests.ArrayExpInFunc52.g
  input Integer[:] x;
  output Integer[:] y;
 algorithm
  init y as Integer[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  return;
 end FunctionTests.ArrayExpInFunc52.g;

 record FunctionTests.ArrayExpInFunc52.R
  discrete Integer x[:];
 end FunctionTests.ArrayExpInFunc52.R;

end FunctionTests.ArrayExpInFunc52;
")})));
end ArrayExpInFunc52;


model ArrayOutputScalarization1
 function f
  output Real x[2] = {1,2};
  output Real y[2] = {1,2};
 algorithm
 end f;
 
 Real x[2];
 Real y[2];
equation
 (x,y) = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization1",
            description="Scalarization of array function outputs: function call equation",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 ({x[1], x[2]}, {y[1], y[2]}) = FunctionTests.ArrayOutputScalarization1.f();

public
 function FunctionTests.ArrayOutputScalarization1.f
  output Real[:] x;
  output Real[:] y;
  Integer[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  init y as Real[2];
  init temp_2 as Integer[2];
  temp_2[1] := 1;
  temp_2[2] := 2;
  for i1 in 1:2 loop
   y[i1] := temp_2[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization1.f;

end FunctionTests.ArrayOutputScalarization1;
")})));
end ArrayOutputScalarization1;


model ArrayOutputScalarization2
 function f
  output Real x[2] = {1,2};
 algorithm
 end f;
 
 Real x[2];
equation
 x = {3,4} + f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization2",
            description="Scalarization of array function outputs: expression with func call",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization2
 Real x[1];
 Real x[2];
 Real temp_1[1];
 Real temp_1[2];
equation
 ({temp_1[1], temp_1[2]}) = FunctionTests.ArrayOutputScalarization2.f();
 x[1] = 3 + temp_1[1];
 x[2] = 4 + temp_1[2];

public
 function FunctionTests.ArrayOutputScalarization2.f
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization2.f;

end FunctionTests.ArrayOutputScalarization2;
")})));
end ArrayOutputScalarization2;


model ArrayOutputScalarization3
 function f
  output Real x[2] = {1, 2};
 algorithm
 end f;
 
 Real x[2];
 Real temp = 1;
 Real temp_1 = 2;
 Real temp_3 = 3;
equation
 x = {1,2} + f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization3",
            description="Scalarization of array function outputs: finding free temp name",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization3
 Real x[1];
 Real x[2];
 Real temp;
 Real temp_1;
 Real temp_3;
 Real temp_2[1];
 Real temp_2[2];
equation
 ({temp_2[1], temp_2[2]}) = FunctionTests.ArrayOutputScalarization3.f();
 x[1] = 1 + temp_2[1];
 x[2] = 2 + temp_2[2];
 temp = 1;
 temp_1 = 2;
 temp_3 = 3;

public
 function FunctionTests.ArrayOutputScalarization3.f
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization3.f;

end FunctionTests.ArrayOutputScalarization3;
")})));
end ArrayOutputScalarization3;


model ArrayOutputScalarization4
 function f1
  output Real x[2] = {1,2};
  output Real y[2] = {1,2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
  protected Real z[2];
 algorithm
  (y,z) := f1();
  x := y[1];
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization4",
            description="Scalarization of array function outputs: function call statement",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization4
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization4.f2();

public
 function FunctionTests.ArrayOutputScalarization4.f2
  output Real x;
  Real[:] y;
  Real[:] z;
 algorithm
  init y as Real[2];
  init z as Real[2];
  (y, z) := FunctionTests.ArrayOutputScalarization4.f1();
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization4.f2;

 function FunctionTests.ArrayOutputScalarization4.f1
  output Real[:] x;
  output Real[:] y;
  Integer[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  init y as Real[2];
  init temp_2 as Integer[2];
  temp_2[1] := 1;
  temp_2[2] := 2;
  for i1 in 1:2 loop
   y[i1] := temp_2[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization4.f1;

end FunctionTests.ArrayOutputScalarization4;
")})));
end ArrayOutputScalarization4;


model ArrayOutputScalarization5
 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
 algorithm
  y := {1,2} + f1();
  x := y[1];
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization5",
            description="Scalarization of array function outputs: assign statement with expression",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization5
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization5.f2();

public
 function FunctionTests.ArrayOutputScalarization5.f2
  output Real x;
  Real[:] y;
  Integer[:] temp_1;
  Real[:] temp_2;
 algorithm
  init y as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  init temp_2 as Real[2];
  (temp_2) := FunctionTests.ArrayOutputScalarization5.f1();
  for i1 in 1:2 loop
   y[i1] := temp_1[i1] + temp_2[i1];
  end for;
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization5.f2;

 function FunctionTests.ArrayOutputScalarization5.f1
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization5.f1;

end FunctionTests.ArrayOutputScalarization5;
")})));
end ArrayOutputScalarization5;


model ArrayOutputScalarization6

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
  protected Real temp_1;
 algorithm
  y := f1();
  x := y[1];
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization6",
            description="Scalarization of array function outputs: finding free temp name",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization6
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization6.f2();

public
 function FunctionTests.ArrayOutputScalarization6.f2
  output Real x;
  Real[:] y;
  Real temp_1;
 algorithm
  init y as Real[2];
  (y) := FunctionTests.ArrayOutputScalarization6.f1();
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization6.f2;

 function FunctionTests.ArrayOutputScalarization6.f1
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization6.f1;

end FunctionTests.ArrayOutputScalarization6;
")})));
end ArrayOutputScalarization6;


model ArrayOutputScalarization7
 function f1
  input Real i;
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  input Real i;
  output Real x;
  protected Real y[2];
 algorithm
  if sum(f1(i)) < 4 then
   x := 1;
   y := {1,2} + f1(i);
  elseif sum(f1(i)) < 5 then
   y := {3,4};
  else
   x := 1;
   y := f1(i);
  end if;
  x := y[1];
 end f2;
 
 Real x = f2(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization7",
            description="Scalarization of array function outputs: if statement",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization7
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization7.f2(1);

public
 function FunctionTests.ArrayOutputScalarization7.f2
  input Real i;
  output Real x;
  Real[:] y;
  Real temp_1;
  Real[:] temp_2;
  Real temp_3;
  Real[:] temp_4;
  Integer[:] temp_5;
  Real[:] temp_6;
  Integer[:] temp_7;
 algorithm
  init y as Real[2];
  init temp_2 as Real[2];
  (temp_2) := FunctionTests.ArrayOutputScalarization7.f1(i);
  temp_1 := 0.0;
  for i1 in 1:2 loop
   temp_1 := temp_1 + temp_2[i1];
  end for;
  init temp_4 as Real[2];
  (temp_4) := FunctionTests.ArrayOutputScalarization7.f1(i);
  temp_3 := 0.0;
  for i1 in 1:2 loop
   temp_3 := temp_3 + temp_4[i1];
  end for;
  if temp_1 < 4 then
   x := 1;
   init temp_5 as Integer[2];
   temp_5[1] := 1;
   temp_5[2] := 2;
   init temp_6 as Real[2];
   (temp_6) := FunctionTests.ArrayOutputScalarization7.f1(i);
   for i1 in 1:2 loop
    y[i1] := temp_5[i1] + temp_6[i1];
   end for;
  elseif temp_3 < 5 then
   init temp_7 as Integer[2];
   temp_7[1] := 3;
   temp_7[2] := 4;
   for i1 in 1:2 loop
    y[i1] := temp_7[i1];
   end for;
  else
   x := 1;
   (y) := FunctionTests.ArrayOutputScalarization7.f1(i);
  end if;
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization7.f2;

 function FunctionTests.ArrayOutputScalarization7.f1
  input Real i;
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization7.f1;

end FunctionTests.ArrayOutputScalarization7;
")})));
end ArrayOutputScalarization7;


model ArrayOutputScalarization8
 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
 algorithm
  for i in f1() loop
   y[1] := i;
   y := f1();
  end for;
  x := y[1];
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization8",
            description="Scalarization of array function outputs: for statement",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization8
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization8.f2();

public
 function FunctionTests.ArrayOutputScalarization8.f2
  output Real x;
  Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  (temp_1) := FunctionTests.ArrayOutputScalarization8.f1();
  for i in temp_1 loop
   y[1] := i;
   (y) := FunctionTests.ArrayOutputScalarization8.f1();
  end for;
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization8.f2;

 function FunctionTests.ArrayOutputScalarization8.f1
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization8.f1;

end FunctionTests.ArrayOutputScalarization8;
")})));
end ArrayOutputScalarization8;


model ArrayOutputScalarization9
 function f
  output Real x[2] = {1, 2};
 algorithm
 end f;
 
 Real x[2];
equation
 x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization9",
            description="Scalarization of array function outputs: equation without expression",
            variability_propagation=false,
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization9
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.ArrayOutputScalarization9.f();

public
 function FunctionTests.ArrayOutputScalarization9.f
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization9.f;

end FunctionTests.ArrayOutputScalarization9;
")})));
end ArrayOutputScalarization9;


model ArrayOutputScalarization10
 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x = 0;
 algorithm
  while x < sum(f1() .+ 1) loop
   x := x + 1;
  end while;
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization10",
            description="Scalarization of array function outputs: while statement",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization10
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization10.f2();

public
 function FunctionTests.ArrayOutputScalarization10.f2
  output Real x;
  Real temp_1;
  Real[:] temp_2;
 algorithm
  x := 0;
  init temp_2 as Real[2];
  (temp_2) := FunctionTests.ArrayOutputScalarization10.f1();
  temp_1 := 0.0;
  for i1 in 1:2 loop
   temp_1 := temp_1 + (temp_2[i1] .+ 1);
  end for;
  while x < temp_1 loop
   x := x + 1;
   init temp_2 as Real[2];
   (temp_2) := FunctionTests.ArrayOutputScalarization10.f1();
   temp_1 := 0.0;
   for i1 in 1:2 loop
    temp_1 := temp_1 + (temp_2[i1] .+ 1);
   end for;
  end while;
  return;
 end FunctionTests.ArrayOutputScalarization10.f2;

 function FunctionTests.ArrayOutputScalarization10.f1
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization10.f1;

end FunctionTests.ArrayOutputScalarization10;
")})));
end ArrayOutputScalarization10;


model ArrayOutputScalarization11
 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2] = f1();
 algorithm
  x := y[1];
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization11",
            description="Scalarization of array function outputs: binding expression",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization11
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization11.f2();

public
 function FunctionTests.ArrayOutputScalarization11.f2
  output Real x;
  Real[:] y;
 algorithm
  init y as Real[2];
  (y) := FunctionTests.ArrayOutputScalarization11.f1();
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization11.f2;

 function FunctionTests.ArrayOutputScalarization11.f1
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization11.f1;

end FunctionTests.ArrayOutputScalarization11;
")})));
end ArrayOutputScalarization11;


model ArrayOutputScalarization12
 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2] = f1() + {3, 4};
 algorithm
  x := y[1];
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization12",
            description="Scalarization of array function outputs: part of binding expression",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization12
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization12.f2();

public
 function FunctionTests.ArrayOutputScalarization12.f2
  output Real x;
  Real[:] y;
  Real[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  (temp_1) := FunctionTests.ArrayOutputScalarization12.f1();
  init temp_2 as Integer[2];
  temp_2[1] := 3;
  temp_2[2] := 4;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1] + temp_2[i1];
  end for;
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization12.f2;

 function FunctionTests.ArrayOutputScalarization12.f1
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization12.f1;

end FunctionTests.ArrayOutputScalarization12;
")})));
end ArrayOutputScalarization12;


model ArrayOutputScalarization13
 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y = sum(f1());
 algorithm
  x := y;
 end f2;
 
 Real x = f2();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization13",
            description="Scalarization of array function outputs: part of scalar binding exp",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization13
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization13.f2();

public
 function FunctionTests.ArrayOutputScalarization13.f2
  output Real x;
  Real y;
  Real temp_1;
  Real[:] temp_2;
 algorithm
  init temp_2 as Real[2];
  (temp_2) := FunctionTests.ArrayOutputScalarization13.f1();
  temp_1 := 0.0;
  for i1 in 1:2 loop
   temp_1 := temp_1 + temp_2[i1];
  end for;
  y := temp_1;
  x := y;
  return;
 end FunctionTests.ArrayOutputScalarization13.f2;

 function FunctionTests.ArrayOutputScalarization13.f1
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization13.f1;

end FunctionTests.ArrayOutputScalarization13;
")})));
end ArrayOutputScalarization13;


model ArrayOutputScalarization14
 function f
  output Real x[2] = {1, 2};
 algorithm
 end f;
 
 Real x = f() * {3, 4};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization14",
            description="Scalarization of array function outputs: part of scalar expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization14
 Real x;
 Real temp_1[1];
 Real temp_1[2];
equation
 ({temp_1[1], temp_1[2]}) = FunctionTests.ArrayOutputScalarization14.f();
 x = temp_1[1] * 3 + temp_1[2] * 4;

public
 function FunctionTests.ArrayOutputScalarization14.f
  output Real[:] x;
  Integer[:] temp_1;
 algorithm
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization14.f;

end FunctionTests.ArrayOutputScalarization14;
")})));
end ArrayOutputScalarization14;


model ArrayOutputScalarization15
 function f
  output Real x[2] = {1,2};
  output Real y = 2;
 algorithm
 end f;
 
 Real x[2];
 Real y;
equation
 (x, y) = f();

    annotation(__JModelica(UnitTesting(tests={
        GenericCodeGenTestCase(
            name="ArrayOutputScalarization15",
            description="Scalarization of array function outputs: number of equations",
            variability_propagation=false,
            template="$n_equations$",
            generatedCode="3"
 )})));
end ArrayOutputScalarization15;


model ArrayOutputScalarization16
 function f1
  output Real o = 2;
  protected Real x[2] = {1,2};
  protected Real y[2];
 algorithm
  y := f2(x);
 end f1;
 
 function f2
  input Real x[2];
  output Real y[2] = x;
 algorithm
 end f2;
 
 Real x = f1();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization16",
            description="Scalarization of array function outputs: using original arrays",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization16
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization16.f1();

public
 function FunctionTests.ArrayOutputScalarization16.f1
  output Real o;
  Real[:] x;
  Real[:] y;
  Integer[:] temp_1;
 algorithm
  o := 2;
  init x as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   x[i1] := temp_1[i1];
  end for;
  init y as Real[2];
  (y) := FunctionTests.ArrayOutputScalarization16.f2(x);
  return;
 end FunctionTests.ArrayOutputScalarization16.f1;

 function FunctionTests.ArrayOutputScalarization16.f2
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[2];
  for i1 in 1:2 loop
   y[i1] := x[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization16.f2;

end FunctionTests.ArrayOutputScalarization16;
")})));
end ArrayOutputScalarization16;


model ArrayOutputScalarization17
 function f1
  output Real o = 2;
  protected Real y[2];
 algorithm
  y := f2(f2({1,2}));
 end f1;
 
 function f2
  input Real x[2];
  output Real y[2] = x;
 algorithm
 end f2;
 
 Real x = f1();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization17",
            description="Scalarization of array function outputs: using original arrays",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization17
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization17.f1();

public
 function FunctionTests.ArrayOutputScalarization17.f1
  output Real o;
  Real[:] y;
 algorithm
  o := 2;
  init y as Real[2];
  (y) := FunctionTests.ArrayOutputScalarization17.f2(FunctionTests.ArrayOutputScalarization17.f2({1, 2}));
  return;
 end FunctionTests.ArrayOutputScalarization17.f1;

 function FunctionTests.ArrayOutputScalarization17.f2
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[2];
  for i1 in 1:2 loop
   y[i1] := x[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization17.f2;

end FunctionTests.ArrayOutputScalarization17;
")})));
end ArrayOutputScalarization17;


model ArrayOutputScalarization18
    function f1
        input Real[:] a1;
        output Real x1;
    protected
        Real[:] b1 = f2(a1);
    algorithm
        x1 := a1 * b1;
    end f1;
    
    function f2
        input Real[:] a2;
        output Real[size(a2, 1)] x2 = 2 * a2;
    algorithm
    end f2;
    
    Real x = f1({ 1, 2 });

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization18",
            description="Scalarization of binding expression of unknown size for protected var in func",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization18
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization18.f1({1, 2});

public
 function FunctionTests.ArrayOutputScalarization18.f1
  input Real[:] a1;
  output Real x1;
  Real[:] b1;
  Real temp_1;
  Real temp_2;
 algorithm
  init b1 as Real[size(a1, 1)];
  (b1) := FunctionTests.ArrayOutputScalarization18.f2(a1);
  temp_2 := 0.0;
  for i1 in 1:size(a1, 1) loop
   temp_2 := temp_2 + a1[i1] * b1[i1];
  end for;
  temp_1 := temp_2;
  x1 := temp_1;
  return;
 end FunctionTests.ArrayOutputScalarization18.f1;

 function FunctionTests.ArrayOutputScalarization18.f2
  input Real[:] a2;
  output Real[:] x2;
 algorithm
  init x2 as Real[size(a2, 1)];
  for i1 in 1:size(a2, 1) loop
   x2[i1] := 2 * a2[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization18.f2;

end FunctionTests.ArrayOutputScalarization18;
")})));
end ArrayOutputScalarization18;


model ArrayOutputScalarization19
    function f1
        input Real[:] a1;
        output Real x1;
    protected
        Real[2] b1 = f2(a1);
    algorithm
        x1 := sum(b1);
    end f1;
    
    function f2
        input Real[:] a2;
        output Real[size(a2, 1)] x2 = 2 * a2;
    algorithm
    end f2;
    
    Real x = f1({ 1, 2 });

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization19",
            description="Scalarization of binding expression of unknown size for protected var in func",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization19
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization19.f1({1, 2});

public
 function FunctionTests.ArrayOutputScalarization19.f1
  input Real[:] a1;
  output Real x1;
  Real[:] b1;
  Real temp_1;
 algorithm
  init b1 as Real[2];
  assert(size(a1, 1) == 2, \"Mismatching sizes in FunctionTests.ArrayOutputScalarization19.f1\");
  (b1) := FunctionTests.ArrayOutputScalarization19.f2(a1);
  temp_1 := 0.0;
  for i1 in 1:2 loop
   temp_1 := temp_1 + b1[i1];
  end for;
  x1 := temp_1;
  return;
 end FunctionTests.ArrayOutputScalarization19.f1;

 function FunctionTests.ArrayOutputScalarization19.f2
  input Real[:] a2;
  output Real[:] x2;
 algorithm
  init x2 as Real[size(a2, 1)];
  for i1 in 1:size(a2, 1) loop
   x2[i1] := 2 * a2[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization19.f2;

end FunctionTests.ArrayOutputScalarization19;
")})));
end ArrayOutputScalarization19;


model ArrayOutputScalarization20
	record R
		Real a;
		Real b[2];		
	end R;
	
    function f1
        input Real c;
        output R d;
    algorithm
        d := f2(c);
    end f1;
    
    function f2
        input Real e;
        output R f;
    algorithm
        f := R(e, {1,2});
    end f2;
    
    R x = f1(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization20",
            description="Checks for bug in #1895",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization20
 Real x.a;
 Real x.b[1];
 Real x.b[2];
equation
 (FunctionTests.ArrayOutputScalarization20.R(x.a, {x.b[1], x.b[2]})) = FunctionTests.ArrayOutputScalarization20.f1(1);

public
 function FunctionTests.ArrayOutputScalarization20.f1
  input Real c;
  output FunctionTests.ArrayOutputScalarization20.R d;
 algorithm
  (d) := FunctionTests.ArrayOutputScalarization20.f2(c);
  return;
 end FunctionTests.ArrayOutputScalarization20.f1;

 function FunctionTests.ArrayOutputScalarization20.f2
  input Real e;
  output FunctionTests.ArrayOutputScalarization20.R f;
  Integer[:] temp_1;
 algorithm
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  f.a := e;
  for i1 in 1:2 loop
   f.b[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization20.f2;

 record FunctionTests.ArrayOutputScalarization20.R
  Real a;
  Real b[2];
 end FunctionTests.ArrayOutputScalarization20.R;

end FunctionTests.ArrayOutputScalarization20;
")})));
end ArrayOutputScalarization20;


model ArrayOutputScalarization21
	record R
		Real x[2,2];
	end R;
	
	function f
		input Real x;
		output R y;
	algorithm
		y := R({{x, 2* x},{3 * x, 4 * x}});
	end f;
	
	R z = f(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization21",
            description="Scalarization of matrix in record as output of function",
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization21
 Real z.x[1,1];
 Real z.x[1,2];
 Real z.x[2,1];
 Real z.x[2,2];
equation
 (FunctionTests.ArrayOutputScalarization21.R({{z.x[1,1], z.x[1,2]}, {z.x[2,1], z.x[2,2]}})) = FunctionTests.ArrayOutputScalarization21.f(time);

public
 function FunctionTests.ArrayOutputScalarization21.f
  input Real x;
  output FunctionTests.ArrayOutputScalarization21.R y;
  Real[:,:] temp_1;
  Real[:] temp_2;
  Real[:] temp_3;
 algorithm
  init temp_1 as Real[2, 2];
  init temp_2 as Real[2];
  temp_2[1] := x;
  temp_2[2] := 2 * x;
  for i1 in 1:2 loop
   temp_1[1,i1] := temp_2[i1];
  end for;
  init temp_3 as Real[2];
  temp_3[1] := 3 * x;
  temp_3[2] := 4 * x;
  for i1 in 1:2 loop
   temp_1[2,i1] := temp_3[i1];
  end for;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    y.x[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization21.f;

 record FunctionTests.ArrayOutputScalarization21.R
  Real x[2,2];
 end FunctionTests.ArrayOutputScalarization21.R;

end FunctionTests.ArrayOutputScalarization21;
")})));
end ArrayOutputScalarization21;


model ArrayOutputScalarization22
    function f
        input Real a;
        output Real[2] b;
    algorithm
        b := { a, a*a };
    end f;
    
    parameter Integer n = 3;
    Real[n,2] c = { f(i) for i in 1:n };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization22",
            description="Iteration expression with function call",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization22
 structural parameter Integer n = 3 /* 3 */;
 Real c[1,1];
 Real c[1,2];
 Real c[2,1];
 Real c[2,2];
 Real c[3,1];
 Real c[3,2];
equation
 ({c[1,1], c[1,2]}) = FunctionTests.ArrayOutputScalarization22.f(1);
 ({c[2,1], c[2,2]}) = FunctionTests.ArrayOutputScalarization22.f(2);
 ({c[3,1], c[3,2]}) = FunctionTests.ArrayOutputScalarization22.f(3);

public
 function FunctionTests.ArrayOutputScalarization22.f
  input Real a;
  output Real[:] b;
  Real[:] temp_1;
 algorithm
  init b as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := a;
  temp_1[2] := a * a;
  for i1 in 1:2 loop
   b[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization22.f;

end FunctionTests.ArrayOutputScalarization22;
")})));
end ArrayOutputScalarization22;


model ArrayOutputScalarization23
    function f
        input Real a;
        output Real[2] b;
    algorithm
        b := { a, a*a };
    end f;
    
    parameter Integer n = 3;
    Real[n,2] c;
equation
	for i in 1:n loop
		c[i,:] = f(i);
	end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization23",
            description="Function returning array in for loop",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ArrayOutputScalarization23
 structural parameter Integer n = 3 /* 3 */;
 Real c[1,1];
 Real c[1,2];
 Real c[2,1];
 Real c[2,2];
 Real c[3,1];
 Real c[3,2];
equation
 ({c[1,1], c[1,2]}) = FunctionTests.ArrayOutputScalarization23.f(1);
 ({c[2,1], c[2,2]}) = FunctionTests.ArrayOutputScalarization23.f(2);
 ({c[3,1], c[3,2]}) = FunctionTests.ArrayOutputScalarization23.f(3);

public
 function FunctionTests.ArrayOutputScalarization23.f
  input Real a;
  output Real[:] b;
  Real[:] temp_1;
 algorithm
  init b as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := a;
  temp_1[2] := a * a;
  for i1 in 1:2 loop
   b[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization23.f;

end FunctionTests.ArrayOutputScalarization23;
")})));
end ArrayOutputScalarization23;


model ArrayOutputScalarization24
    function f
        input Real a;
        output Real[2] b;
    algorithm
        b := { a, a*a };
    end f;
        
    Real x(start = 1);
    Real y;
    Real z[2];
initial equation
    y = x / 2;
    z = x .+ f(y);
equation
    der(x) = z[1];
    der(y) = z[2];
    der(z) = { -x, -y };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization24",
            description="Scalarize use of function returning array in initial equations",
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization24
 Real x(start = 1);
 Real y;
 Real z[1];
 Real z[2];
 initial parameter Real temp_1[1];
 initial parameter Real temp_1[2];
initial equation
 y = x / 2;
 ({temp_1[1], temp_1[2]}) = FunctionTests.ArrayOutputScalarization24.f(y);
 z[1] = x .+ temp_1[1];
 z[2] = x .+ temp_1[2];
 x = 1;
equation
 der(x) = z[1];
 der(y) = z[2];
 der(z[1]) = - x;
 der(z[2]) = - y;

public
 function FunctionTests.ArrayOutputScalarization24.f
  input Real a;
  output Real[:] b;
  Real[:] temp_1;
 algorithm
  init b as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := a;
  temp_1[2] := a * a;
  for i1 in 1:2 loop
   b[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization24.f;

end FunctionTests.ArrayOutputScalarization24;
")})));
end ArrayOutputScalarization24;

model ArrayOutputScalarization25
	record R
		Real[2] x;
		Real[2] y;
	end R;

function f
	input R[2] i;
	output R[2] o;
algorithm
	o := i;
end f;

function fwrap
	input R[2] i;
	output R[2] o;
	output Real dummy;
algorithm
	o := f(i);
	dummy := 1;
end fwrap;

	R[2] a;
algorithm
	a := fwrap({R({1,1},{1,1}),R({1,1},{1,1})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization25",
            description="Scalarize function call statements.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization25
 Real a[1].x[1];
 Real a[1].x[2];
 Real a[1].y[1];
 Real a[1].y[2];
 Real a[2].x[1];
 Real a[2].x[2];
 Real a[2].y[1];
 Real a[2].y[2];
 Real temp_1[1].x[1];
 Real temp_1[1].x[2];
 Real temp_1[1].y[1];
 Real temp_1[1].y[2];
 Real temp_1[2].x[1];
 Real temp_1[2].x[2];
 Real temp_1[2].y[1];
 Real temp_1[2].y[2];
algorithm
 ({FunctionTests.ArrayOutputScalarization25.R({temp_1[1].x[1], temp_1[1].x[2]}, {temp_1[1].y[1], temp_1[1].y[2]}), FunctionTests.ArrayOutputScalarization25.R({temp_1[2].x[1], temp_1[2].x[2]}, {temp_1[2].y[1], temp_1[2].y[2]})}) := FunctionTests.ArrayOutputScalarization25.fwrap({FunctionTests.ArrayOutputScalarization25.R({1, 1}, {1, 1}), FunctionTests.ArrayOutputScalarization25.R({1, 1}, {1, 1})});
 a[1].x[1] := temp_1[1].x[1];
 a[1].x[2] := temp_1[1].x[2];
 a[1].y[1] := temp_1[1].y[1];
 a[1].y[2] := temp_1[1].y[2];
 a[2].x[1] := temp_1[2].x[1];
 a[2].x[2] := temp_1[2].x[2];
 a[2].y[1] := temp_1[2].y[1];
 a[2].y[2] := temp_1[2].y[2];

public
 function FunctionTests.ArrayOutputScalarization25.fwrap
  input FunctionTests.ArrayOutputScalarization25.R[:] i;
  output FunctionTests.ArrayOutputScalarization25.R[:] o;
  output Real dummy;
 algorithm
  init o as FunctionTests.ArrayOutputScalarization25.R[2];
  for i1 in 1:2 loop
   assert(2 == size(i[i1].x, 1), \"Mismatching sizes in function 'FunctionTests.ArrayOutputScalarization25.fwrap', component 'i[i1].x', dimension '1'\");
   assert(2 == size(i[i1].y, 1), \"Mismatching sizes in function 'FunctionTests.ArrayOutputScalarization25.fwrap', component 'i[i1].y', dimension '1'\");
  end for;
  (o) := FunctionTests.ArrayOutputScalarization25.f(i);
  dummy := 1;
  return;
 end FunctionTests.ArrayOutputScalarization25.fwrap;

 function FunctionTests.ArrayOutputScalarization25.f
  input FunctionTests.ArrayOutputScalarization25.R[:] i;
  output FunctionTests.ArrayOutputScalarization25.R[:] o;
 algorithm
  init o as FunctionTests.ArrayOutputScalarization25.R[2];
  for i1 in 1:2 loop
   assert(2 == size(i[i1].x, 1), \"Mismatching sizes in function 'FunctionTests.ArrayOutputScalarization25.f', component 'i[i1].x', dimension '1'\");
   assert(2 == size(i[i1].y, 1), \"Mismatching sizes in function 'FunctionTests.ArrayOutputScalarization25.f', component 'i[i1].y', dimension '1'\");
  end for;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    o[i1].x[i2] := i[i1].x[i2];
   end for;
   for i2 in 1:2 loop
    o[i1].y[i2] := i[i1].y[i2];
   end for;
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization25.f;

 record FunctionTests.ArrayOutputScalarization25.R
  Real x[2];
  Real y[2];
 end FunctionTests.ArrayOutputScalarization25.R;

end FunctionTests.ArrayOutputScalarization25;
")})));
end ArrayOutputScalarization25;

model ArrayOutputScalarization26
record R
	Real x;
end R;

function f
	input Real[2] i;
	output R[2] o;
	output Real d = 1;
algorithm
	o := {R(i[1]),R(i[2])};
end f;

R[4] x;
Real[4] y = {1,2,3,4};
algorithm
	(x[{4,2}],) := f(y[{4,2}]);
	(x[{1,3}],) := f(y[{1,3}]);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization26",
            description="Slices of records in function call statements.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization26
 Real x[1].x;
 Real x[2].x;
 Real x[3].x;
 Real x[4].x;
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
algorithm
 ({FunctionTests.ArrayOutputScalarization26.R(x[4].x), FunctionTests.ArrayOutputScalarization26.R(x[2].x)}, ) := FunctionTests.ArrayOutputScalarization26.f({y[4], y[2]});
 ({FunctionTests.ArrayOutputScalarization26.R(x[1].x), FunctionTests.ArrayOutputScalarization26.R(x[3].x)}, ) := FunctionTests.ArrayOutputScalarization26.f({y[1], y[3]});
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 y[4] = 4;

public
 function FunctionTests.ArrayOutputScalarization26.f
  input Real[:] i;
  output FunctionTests.ArrayOutputScalarization26.R[:] o;
  output Real d;
  FunctionTests.ArrayOutputScalarization26.R[:] temp_1;
 algorithm
  init o as FunctionTests.ArrayOutputScalarization26.R[2];
  d := 1;
  init temp_1 as FunctionTests.ArrayOutputScalarization26.R[2];
  temp_1[1].x := i[1];
  temp_1[2].x := i[2];
  for i1 in 1:2 loop
   o[i1].x := temp_1[i1].x;
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization26.f;

 record FunctionTests.ArrayOutputScalarization26.R
  Real x;
 end FunctionTests.ArrayOutputScalarization26.R;

end FunctionTests.ArrayOutputScalarization26;
")})));
end ArrayOutputScalarization26;


model ArrayOutputScalarization27
    function f1
        input Real c;
        output Real d[2];
    algorithm
        d := {1,2} * c;
        d[1] := d[1] + 0.1;
    end f1;
        
    function f2
        input Real c;
        output Real d[2];
    algorithm
        d := {2,3} * c;
        d[1] := d[1] + 0.1;
    end f2;
        
    parameter Boolean a = false annotation(Evaluate=true);
    Real b[2] = if a then f1(time) else f2(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization27",
            description="Function with array output in if exp",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization27
 eval parameter Boolean a = false /* false */;
 Real b[1];
 Real b[2];
equation
 ({b[1], b[2]}) = FunctionTests.ArrayOutputScalarization27.f2(time);

public
 function FunctionTests.ArrayOutputScalarization27.f2
  input Real c;
  output Real[:] d;
  Integer[:] temp_1;
 algorithm
  init d as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 2;
  temp_1[2] := 3;
  for i1 in 1:2 loop
   d[i1] := temp_1[i1] * c;
  end for;
  d[1] := d[1] + 0.1;
  return;
 end FunctionTests.ArrayOutputScalarization27.f2;

end FunctionTests.ArrayOutputScalarization27;
")})));
end ArrayOutputScalarization27;

model ArrayOutputScalarization28
    function F
        input Integer[:] x;
        output Real[sum(x)] y;
    algorithm
        for i in 1:sum(x) loop
            y[i] := i + sum(x);
        end for;
    end F;
    
    model B
        parameter Real p1 = 0;
    end B;
    
    parameter Integer p2[:] = {2};
    
    parameter Real a = 0.1;
    
    B b[2](p1 = a * F(p2));


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization28",
            description="Scalarization of function type with mutable record size",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization28
 structural parameter Integer p2[1] = 2 /* 2 */;
 parameter Real a = 0.1 /* 0.1 */;
 parameter Real temp_1[1];
 parameter Real temp_2[2];
 parameter Real b[1].p1;
 parameter Real b[2].p1;
parameter equation
 ({temp_1[1], }) = FunctionTests.ArrayOutputScalarization28.F({2});
 ({, temp_2[2]}) = FunctionTests.ArrayOutputScalarization28.F({2});
 b[1].p1 = a * temp_1[1];
 b[2].p1 = a * temp_2[2];

public
 function FunctionTests.ArrayOutputScalarization28.F
  input Integer[:] x;
  output Real[:] y;
  Integer temp_1;
  Integer temp_2;
  Integer temp_3;
 algorithm
  temp_1 := 0;
  for i1 in 1:size(x, 1) loop
   temp_1 := temp_1 + x[i1];
  end for;
  init y as Real[temp_1];
  temp_2 := 0;
  for i1 in 1:size(x, 1) loop
   temp_2 := temp_2 + x[i1];
  end for;
  for i in 1:temp_2 loop
   temp_3 := 0;
   for i1 in 1:size(x, 1) loop
    temp_3 := temp_3 + x[i1];
   end for;
   y[i] := i + temp_3;
  end for;
  return;
 end FunctionTests.ArrayOutputScalarization28.F;

end FunctionTests.ArrayOutputScalarization28;
")})));
end ArrayOutputScalarization28;


model ArrayOutputScalarization29
    function f
        input Real x;
        input Integer n;
        input Real z[n];
        output Real[n] y;
    algorithm
        assert(x > 2, "Too low!");
        y := x * z;
        annotation(Inline=false);
    end f;
    
    record R
        final parameter Real z1[n] = f(w1, n, z2);
        final parameter Real z2[n] = f(1, n, {2, 3});
        parameter Integer n;
        parameter Real w1;
        parameter Real w2;
    end R;
    
    R r(final w1 = 1, final n = 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayOutputScalarization29",
            description="Do not replace final parameter function call that fails eval with zeroes",
            flatModel="
fclass FunctionTests.ArrayOutputScalarization29
 parameter Real temp_2[1];
 parameter Real temp_2[2];
 structural parameter Real r.z2[1];
 structural parameter Real r.z2[2];
 structural parameter Integer r.n = 2 /* 2 */;
 final parameter Real r.w1 = 1 /* 1 */;
 parameter Real r.w2;
 parameter Real temp_1[1];
 parameter Real temp_1[2];
 final parameter Real r.z1[1];
 final parameter Real r.z1[2];
parameter equation
 ({temp_2[1], temp_2[2]}) = FunctionTests.ArrayOutputScalarization29.f(1, 2, {2, 3});
 r.z2[1] = temp_2[1];
 r.z2[2] = temp_2[2];
 ({temp_1[1], temp_1[2]}) = FunctionTests.ArrayOutputScalarization29.f(1.0, 2, {r.z2[1], r.z2[2]});
 r.z1[1] = temp_1[1];
 r.z1[2] = temp_1[2];

public
 function FunctionTests.ArrayOutputScalarization29.f
  input Real x;
  input Integer n;
  input Real[:] z;
  output Real[:] y;
 algorithm
  init y as Real[n];
  assert(x > 2, \"Too low!\");
  for i1 in 1:n loop
   y[i1] := x * z[i1];
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.ArrayOutputScalarization29.f;

end FunctionTests.ArrayOutputScalarization29;
")})));
end ArrayOutputScalarization29;


/* ======================= Unknown array sizes ======================*/

model UnknownArray1
 function f
  input Real a[:];
  output Real b[size(a,1)];
 algorithm
  b := a;
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnknownArray1",
            description="Using functions with unknown array sizes: basic type test",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray1
 Real x[3] = FunctionTests.UnknownArray1.f({1, 2, 3});
 Real y[2] = FunctionTests.UnknownArray1.f({4, 5});

public
 function FunctionTests.UnknownArray1.f
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  b[:] := a[:];
  return;
 end FunctionTests.UnknownArray1.f;

end FunctionTests.UnknownArray1;
")})));
end UnknownArray1;


model UnknownArray2
 function f
  input Real a[:];
  output Real b[:] = a;
 algorithm
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnknownArray2",
            description="Using functions with unknown array sizes: size from binding exp",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray2
 Real x[3] = FunctionTests.UnknownArray2.f({1, 2, 3});
 Real y[2] = FunctionTests.UnknownArray2.f({4, 5});

public
 function FunctionTests.UnknownArray2.f
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  b := a[:];
  return;
 end FunctionTests.UnknownArray2.f;

end FunctionTests.UnknownArray2;
")})));
end UnknownArray2;


model UnknownArray3
 function f
  input Real a[:];
  output Real b[size(c,1)];
  protected Real c[size(a,1)];
 algorithm
  b := a;
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnknownArray3",
            description="Using functions with unknown array sizes: indirect dependency",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray3
 Real x[3] = FunctionTests.UnknownArray3.f({1, 2, 3});
 Real y[2] = FunctionTests.UnknownArray3.f({4, 5});

public
 function FunctionTests.UnknownArray3.f
  input Real[:] a;
  output Real[:] b;
  Real[:] c;
 algorithm
  init b as Real[size(c, 1)];
  init c as Real[size(a, 1)];
  b[:] := a[:];
  return;
 end FunctionTests.UnknownArray3.f;

end FunctionTests.UnknownArray3;
")})));
end UnknownArray3;


model UnknownArray4
 function f
  input Real a[:];
  output Real b[:] = c;
  protected Real c[:] = a;
 algorithm
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnknownArray4",
            description="Using functions with unknown array sizes: indirect dependency from binding exp",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray4
 Real x[3] = FunctionTests.UnknownArray4.f({1, 2, 3});
 Real y[2] = FunctionTests.UnknownArray4.f({4, 5});

public
 function FunctionTests.UnknownArray4.f
  input Real[:] a;
  output Real[:] b;
  Real[:] c;
 algorithm
  init b as Real[size(a, 1)];
  b := c[:];
  init c as Real[size(a, 1)];
  c := a[:];
  return;
 end FunctionTests.UnknownArray4.f;

end FunctionTests.UnknownArray4;
")})));
end UnknownArray4;


model UnknownArray5
 function f
  input Real a[:];
  output Real b[:] = c;
  output Real c[:] = a;
 algorithm
 end f;
 
 Real x[3];
 Real y[3];
equation
 (x, y) = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnknownArray5",
            description="Using functions with unknown array sizes: multiple outputs",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray5
 Real x[3];
 Real y[3];
equation
 (x[1:3], y[1:3]) = FunctionTests.UnknownArray5.f({1, 2, 3});

public
 function FunctionTests.UnknownArray5.f
  input Real[:] a;
  output Real[:] b;
  output Real[:] c;
 algorithm
  init b as Real[size(a, 1)];
  b := c[:];
  init c as Real[size(a, 1)];
  c := a[:];
  return;
 end FunctionTests.UnknownArray5.f;

end FunctionTests.UnknownArray5;
")})));
end UnknownArray5;


model UnknownArray6
 function f
  input Real a[:];
  output Real b[:] = c;
  output Real c[:] = a;
 algorithm
 end f;
 
 Real x[2] = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownArray6",
            description="Using functions with unknown array sizes: wrong size",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 9, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [3]
")})));
end UnknownArray6;


model UnknownArray7
 function f
  input Real a[:];
  output Real b[:] = c;
  output Real c[:] = a;
 algorithm
 end f;
 
 Real x[3];
 Real y[2];
equation
 (x, y) = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownArray7",
            description="Using functions with unknown array sizes: wrong size",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 12, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function f(): component y is of size [2] and output c is of size [3] - they are not compatible
")})));
end UnknownArray7;


model UnknownArray8
 function f
  input Real a[:];
  output Real b[size(b,1)];
 algorithm
  b := {1,2};
 end f;
 
 Real x[2] = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownArray8",
            description="Using functions with unknown array sizes: circular size",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 9, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [:]

Error at line 9, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_OUTPUT:
  Could not evaluate array size of output b
")})));
end UnknownArray8;


model UnknownArray9
 function f
  input Real a[:,:];
  input Real b[:,size(a,2)];
  output Real c[size(d,1), size(d,2)];
 protected Real d[:,:] = cat(1, a, b);
 protected Real e[:,:] = [a; b];
 algorithm
  c := d;
 end f;
 
 Real x[5,2] = f({{1,2},{3,4}}, {{5,6},{7,8},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnknownArray9",
            description="Unknown size calculated by adding sizes",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray9
 Real x[5,2] = FunctionTests.UnknownArray9.f({{1, 2}, {3, 4}}, {{5, 6}, {7, 8}, {9, 0}});

public
 function FunctionTests.UnknownArray9.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] c;
  Real[:,:] d;
  Real[:,:] e;
 algorithm
  assert(size(a, 2) == size(b, 2), \"Mismatching sizes in function 'FunctionTests.UnknownArray9.f', component 'b', dimension '2'\");
  init c as Real[size(d, 1), size(d, 2)];
  init d as Real[size(a, 1) + size(b, 1), size(a, 2)];
  d := cat(1, a[:,:], b[:,:]);
  init e as Real[size(a, 1) + size(b, 1), size(a, 2)];
  e := [a[:,:]; b[:,:]];
  c[:,:] := d[:,:];
  return;
 end FunctionTests.UnknownArray9.f;

end FunctionTests.UnknownArray9;
")})));
end UnknownArray9;


model UnknownArray10
 function f
  input Real a[:];
  output Real b[size(a,1)];
 algorithm
  b := a;
 end f;
 
 Real x[2] = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray10",
            description="Scalarization of operations on arrays of unknown size: assignment",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray10
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.UnknownArray10.f({1, 2});

public
 function FunctionTests.UnknownArray10.f
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   b[i1] := a[i1];
  end for;
  return;
 end FunctionTests.UnknownArray10.f;

end FunctionTests.UnknownArray10;
")})));
end UnknownArray10;


model UnknownArray11
 function f
  input Real a[:];
  output Real b[size(a,1)] = a;
 algorithm
 end f;
 
 Real x[2] = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray11",
            description="Scalarization of operations on arrays of unknown size: binding expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray11
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.UnknownArray11.f({1, 2});

public
 function FunctionTests.UnknownArray11.f
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   b[i1] := a[i1];
  end for;
  return;
 end FunctionTests.UnknownArray11.f;

end FunctionTests.UnknownArray11;
")})));
end UnknownArray11;


model UnknownArray12
 function f
  input Real a[:];
  input Real b[:];
  input Real c;
  output Real o[size(a,1)];
 algorithm
  o := c * a + 2 * b;
 end f;
 
 Real x[2] = f({1,2}, {3,4}, 5);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray12",
            description="Scalarization of operations on arrays of unknown size: element-wise expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray12
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.UnknownArray12.f({1, 2}, {3, 4}, 5);

public
 function FunctionTests.UnknownArray12.f
  input Real[:] a;
  input Real[:] b;
  input Real c;
  output Real[:] o;
 algorithm
  init o as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   o[i1] := c * a[i1] + 2 * b[i1];
  end for;
  return;
 end FunctionTests.UnknownArray12.f;

end FunctionTests.UnknownArray12;
")})));
end UnknownArray12;


model UnknownArray13
 function f
  input Real a[:];
  input Real b[:];
  input Real c;
  output Real o[size(a,1)] = c * a + 2 * b;
 algorithm
 end f;
 
 Real x[2] = f({1,2}, {3,4}, 5);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray13",
            description="Scalarization of operations on arrays of unknown size: element-wise binding expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray13
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.UnknownArray13.f({1, 2}, {3, 4}, 5);

public
 function FunctionTests.UnknownArray13.f
  input Real[:] a;
  input Real[:] b;
  input Real c;
  output Real[:] o;
 algorithm
  init o as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   o[i1] := c * a[i1] + 2 * b[i1];
  end for;
  return;
 end FunctionTests.UnknownArray13.f;

end FunctionTests.UnknownArray13;
")})));
end UnknownArray13;


model UnknownArray14
 function f
  input Real a[:,:];
  input Real b[size(a,2),:];
  output Real o[size(a,1),size(b,2)] = a * b;
 algorithm
 end f;
 
 Real x[2,2] = f({{1,2},{3,4}}, {{5,6},{7,8}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray14",
            description="Scalarization of operations on arrays of unknown size: matrix multiplication",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray14
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 ({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}}) = FunctionTests.UnknownArray14.f({{1, 2}, {3, 4}}, {{5, 6}, {7, 8}});

public
 function FunctionTests.UnknownArray14.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] o;
  Real[:,:] temp_1;
  Real temp_2;
 algorithm
  init o as Real[size(a, 1), size(b, 2)];
  init temp_1 as Real[size(a, 1), size(b, 2)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    temp_2 := 0.0;
    for i3 in 1:size(b, 1) loop
     temp_2 := temp_2 + a[i1,i3] * b[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(b, 2) loop
    o[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray14.f;

end FunctionTests.UnknownArray14;
")})));
end UnknownArray14;


model UnknownArray15
 function f
  input Real a[:];
  input Real b[size(a,1)];
  output Real o = a * b;
 algorithm
 end f;
 
 Real x = f({1,2}, {3,4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray15",
            description="Scalarization of operations on arrays of unknown size: vector multiplication",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray15
 Real x;
equation
 x = FunctionTests.UnknownArray15.f({1, 2}, {3, 4});

public
 function FunctionTests.UnknownArray15.f
  input Real[:] a;
  input Real[:] b;
  output Real o;
  Real temp_1;
  Real temp_2;
 algorithm
  temp_2 := 0.0;
  for i1 in 1:size(b, 1) loop
   temp_2 := temp_2 + a[i1] * b[i1];
  end for;
  temp_1 := temp_2;
  o := temp_1;
  return;
 end FunctionTests.UnknownArray15.f;

end FunctionTests.UnknownArray15;
")})));
end UnknownArray15;


model UnknownArray16
 function f
  input Real a[:];
  input Real b[size(a,1)];
  output Real o = 1;
 algorithm
  if a * b < 4 then
   o := 2;
  end if;
 end f;
 
 Real x = f({1,2}, {3,4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray16",
            description="Scalarization of operations on arrays of unknown size: outside assignment",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray16
 Real x;
equation
 x = FunctionTests.UnknownArray16.f({1, 2}, {3, 4});

public
 function FunctionTests.UnknownArray16.f
  input Real[:] a;
  input Real[:] b;
  output Real o;
  Real temp_1;
  Real temp_2;
 algorithm
  o := 1;
  temp_2 := 0.0;
  for i1 in 1:size(b, 1) loop
   temp_2 := temp_2 + a[i1] * b[i1];
  end for;
  temp_1 := temp_2;
  if temp_1 < 4 then
   o := 2;
  end if;
  return;
 end FunctionTests.UnknownArray16.f;

end FunctionTests.UnknownArray16;
")})));
end UnknownArray16;


model UnknownArray17
 function f
  input Real a[:,:];
  input Real b[size(a,2),:];
  input Real c[size(b,2),:];
  output Real[size(a, 1), size(c, 2)] o = a * b * c;
 algorithm
 end f;
 
 Real y[2,2] = {{1,2}, {3,4}};
 Real x[2,2] = f(y, y, y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray17",
            description="Scalarization of operations on arrays of unknown size: nestled multiplications",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray17
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
 ({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}}) = FunctionTests.UnknownArray17.f({{y[1,1], y[1,2]}, {y[2,1], y[2,2]}}, {{y[1,1], y[1,2]}, {y[2,1], y[2,2]}}, {{y[1,1], y[1,2]}, {y[2,1], y[2,2]}});

public
 function FunctionTests.UnknownArray17.f
  input Real[:,:] a;
  input Real[:,:] b;
  input Real[:,:] c;
  output Real[:,:] o;
  Real[:,:] temp_1;
  Real temp_2;
  Real[:,:] temp_3;
  Real temp_4;
 algorithm
  init o as Real[size(a, 1), size(c, 2)];
  init temp_1 as Real[size(a, 1), size(c, 2)];
  init temp_3 as Real[size(a, 1), size(b, 2)];
  for i4 in 1:size(a, 1) loop
   for i5 in 1:size(b, 2) loop
    temp_4 := 0.0;
    for i6 in 1:size(b, 1) loop
     temp_4 := temp_4 + a[i4,i6] * b[i6,i5];
    end for;
    temp_3[i4,i5] := temp_4;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(c, 2) loop
    temp_2 := 0.0;
    for i3 in 1:size(c, 1) loop
     temp_2 := temp_2 + temp_3[i1,i3] * c[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(c, 2) loop
    o[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray17.f;

end FunctionTests.UnknownArray17;
")})));
end UnknownArray17;


model UnknownArray18
 function f
  input Real a[:];
  output Real o[size(a,1)];
 algorithm
  for i in 1:size(a,1) loop
   o[i] := a[i] + i;
  end for;
 end f;
 
  Real x[2] = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray18",
            description="Scalarization of operations on arrays of unknown size: already expressed as loop",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray18
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.UnknownArray18.f({1, 2});

public
 function FunctionTests.UnknownArray18.f
  input Real[:] a;
  output Real[:] o;
 algorithm
  init o as Real[size(a, 1)];
  for i in 1:size(a, 1) loop
   o[i] := a[i] + i;
  end for;
  return;
 end FunctionTests.UnknownArray18.f;

end FunctionTests.UnknownArray18;
")})));
end UnknownArray18;


model UnknownArray19
 function f
  input Real a[:,:];
  output Real[size(a, 1), size(b, 2)] c = a;
 algorithm
 end f;
 
 Real x[2,2] = f({{1,2}, {3,4}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownArray19",
            description="Function inputs of unknown size: using size() of non-existent component",
            variability_propagation=false,
            errorMessage="
3 errors found:

Error at line 4, column 32, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find class or component declaration for b

Error at line 8, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [2, 2] and size of binding expression is [2, :]

Error at line 8, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_OUTPUT:
  Could not evaluate array size of output c
")})));
end UnknownArray19;


model UnknownArray20
 function f
  input Real a[:,:];
  output Real[2] c;
 algorithm
  c[1] := a[1,1];
  c[end] := a[end,end];
 end f;
 
 Real x[2] = f({{1,2}, {3,4}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray20",
            description="Function inputs of unknown size: scalarizing end",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray20
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.UnknownArray20.f({{1, 2}, {3, 4}});

public
 function FunctionTests.UnknownArray20.f
  input Real[:,:] a;
  output Real[:] c;
 algorithm
  init c as Real[2];
  c[1] := a[1,1];
  c[2] := a[size(a, 1),size(a, 2)];
  return;
 end FunctionTests.UnknownArray20.f;

end FunctionTests.UnknownArray20;
")})));
end UnknownArray20;


model UnknownArray21
	function f
		input Real a[:];
		input Real b[:];
		output Real c = a * b;
	algorithm
	end f;
	
	Real x = f({1,2}, {3,4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray21",
            description="Scalarizing multiplication between two inputs of unknown size",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray21
 Real x;
equation
 x = FunctionTests.UnknownArray21.f({1, 2}, {3, 4});

public
 function FunctionTests.UnknownArray21.f
  input Real[:] a;
  input Real[:] b;
  output Real c;
  Real temp_1;
  Real temp_2;
 algorithm
  temp_2 := 0.0;
  for i1 in 1:size(b, 1) loop
   temp_2 := temp_2 + a[i1] * b[i1];
  end for;
  temp_1 := temp_2;
  c := temp_1;
  return;
 end FunctionTests.UnknownArray21.f;

end FunctionTests.UnknownArray21;
")})));
end UnknownArray21;


model UnknownArray22
	function f
		input Real a[:] = {1, 2, 3};
		input Real b[:] = {4, 5, 6};
		output Real c = a * b;
	algorithm
	end f;
	
	Real x = f({1,2}, {3,4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray22",
            description="Scalarizing multiplication between two inputs of unknown size, with defaults",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray22
 Real x;
equation
 x = FunctionTests.UnknownArray22.f({1, 2}, {3, 4});

public
 function FunctionTests.UnknownArray22.f
  input Real[:] a;
  input Real[:] b;
  output Real c;
  Real temp_1;
  Real temp_2;
 algorithm
  temp_2 := 0.0;
  for i1 in 1:size(b, 1) loop
   temp_2 := temp_2 + a[i1] * b[i1];
  end for;
  temp_1 := temp_2;
  c := temp_1;
  return;
 end FunctionTests.UnknownArray22.f;

end FunctionTests.UnknownArray22;
")})));
end UnknownArray22;


model UnknownArray23
	function f
		input Real a[:];
		output Real c = a * {1, 2, 3};
	algorithm
	end f;

	Real x = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray23",
            description="Using array constructors with inputs of unknown size",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray23
 Real x;
equation
 x = FunctionTests.UnknownArray23.f({1, 2, 3});

public
 function FunctionTests.UnknownArray23.f
  input Real[:] a;
  output Real c;
  Real temp_1;
  Real temp_2;
  Integer[:] temp_3;
 algorithm
  init temp_3 as Integer[3];
  temp_3[1] := 1;
  temp_3[2] := 2;
  temp_3[3] := 3;
  temp_2 := 0.0;
  for i1 in 1:3 loop
   temp_2 := temp_2 + a[i1] * temp_3[i1];
  end for;
  temp_1 := temp_2;
  c := temp_1;
  return;
 end FunctionTests.UnknownArray23.f;

end FunctionTests.UnknownArray23;
")})));
end UnknownArray23;


model UnknownArray24
	function f
		input Real x[:,2];
		output Real y[size(x, 1), 2];
	algorithm
		y := x * {{1, 2}, {3, 4}};
	end f;

	Real x[3,2] = f({{5,6},{7,8},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray24",
            description="Using array constructors with inputs of unknown size",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray24
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real x[3,1];
 Real x[3,2];
equation
 ({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}, {x[3,1], x[3,2]}}) = FunctionTests.UnknownArray24.f({{5, 6}, {7, 8}, {9, 0}});

public
 function FunctionTests.UnknownArray24.f
  input Real[:,:] x;
  output Real[:,:] y;
  Real[:,:] temp_1;
  Real temp_2;
  Integer[:,:] temp_3;
  Integer[:] temp_4;
  Integer[:] temp_5;
 algorithm
  init y as Real[size(x, 1), 2];
  init temp_1 as Real[size(x, 1), 2];
  init temp_3 as Integer[2, 2];
  init temp_4 as Integer[2];
  temp_4[1] := 1;
  temp_4[2] := 2;
  for i3 in 1:2 loop
   temp_3[1,i3] := temp_4[i3];
  end for;
  init temp_5 as Integer[2];
  temp_5[1] := 3;
  temp_5[2] := 4;
  for i3 in 1:2 loop
   temp_3[2,i3] := temp_5[i3];
  end for;
  for i1 in 1:size(x, 1) loop
   for i2 in 1:2 loop
    temp_2 := 0.0;
    for i3 in 1:2 loop
     temp_2 := temp_2 + x[i1,i3] * temp_3[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:size(x, 1) loop
   for i2 in 1:2 loop
    y[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray24.f;

end FunctionTests.UnknownArray24;
")})));
end UnknownArray24;


model UnknownArray25
    function f
        input Real[:] y;
        output Real x;
    algorithm
        x := sum(y);
    end f;
    
    Real x = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray25",
            description="Taking sum of array of unknown size",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray25
 Real x;
equation
 x = FunctionTests.UnknownArray25.f({1, 2});

public
 function FunctionTests.UnknownArray25.f
  input Real[:] y;
  output Real x;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(y, 1) loop
   temp_1 := temp_1 + y[i1];
  end for;
  x := temp_1;
  return;
 end FunctionTests.UnknownArray25.f;

end FunctionTests.UnknownArray25;
")})));
end UnknownArray25;


model UnknownArray26
    function f
        input Real[:] y;
        output Real x;
    algorithm
        x := sum(y[i]*y[i] for i in 1:size(y,1));
    end f;
    
    Real x = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray26",
            description="Taking sum of iterator expression over array of unknown size",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray26
 Real x;
equation
 x = FunctionTests.UnknownArray26.f({1, 2});

public
 function FunctionTests.UnknownArray26.f
  input Real[:] y;
  output Real x;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(y, 1) loop
   temp_1 := temp_1 + y[i1] * y[i1];
  end for;
  x := temp_1;
  return;
 end FunctionTests.UnknownArray26.f;

end FunctionTests.UnknownArray26;
")})));
end UnknownArray26;


model UnknownArray27
    function f
        input Real[:] y;
        input Real[size(y,1), size(y,1)] z;
        output Real x;
    algorithm
        x := sum(y[i]*y[i]/(sum(y[j]*z[i,j] for j in 1:size(y,1))) for i in 1:size(y,1));
    end f;
    
    Real x = f({1,2}, {{1,2},{3,4}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray27",
            description="Nestled sums over iterator expressions over arrays of unknown size",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray27
 Real x;
equation
 x = FunctionTests.UnknownArray27.f({1, 2}, {{1, 2}, {3, 4}});

public
 function FunctionTests.UnknownArray27.f
  input Real[:] y;
  input Real[:,:] z;
  output Real x;
  Real temp_1;
  Real temp_2;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(y, 1) loop
   temp_2 := 0.0;
   for i2 in 1:size(y, 1) loop
    temp_2 := temp_2 + y[i2] * z[i1,i2];
   end for;
   temp_1 := temp_1 + y[i1] * y[i1] / temp_2;
  end for;
  x := temp_1;
  return;
 end FunctionTests.UnknownArray27.f;

end FunctionTests.UnknownArray27;
")})));
end UnknownArray27;


// TODO: this gives wrong result
//model UnknownArray28
//    function f
//        input Real[:] y;
//        output Real x;
//    algorithm
//        x := sum(sum(j for j in 1:size({k for k in 1:i},1)) for i in 1:size(y,1));
//    end f;
//    
//    Real x = f({1,2});
//end UnknownArray28;


model UnknownArray29
    final constant Real a[:] = {1, 2, 3};
    
    function f1
		input Integer i;
        output Real y1;
    algorithm
      y1 := f2({a[i], a[i+1]});
        annotation(Inline=false);
    end f1;
    
    function f2
        input Real x2[:];
        output Real y2 = sum(x2);
    algorithm
        annotation(Inline=false);
    end f2;
    
    Real x = f1(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray29",
            description="Calling function from function with slice argument",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray29
 constant Real a[1] = 1;
 constant Real a[2] = 2;
 constant Real a[3] = 3;
 Real x;
global variables
 constant Real FunctionTests.UnknownArray29.a[3] = {1, 2, 3};
equation
 x = FunctionTests.UnknownArray29.f1(1);

public
 function FunctionTests.UnknownArray29.f1
  input Integer i;
  output Real y1;
 algorithm
  y1 := FunctionTests.UnknownArray29.f2({global(FunctionTests.UnknownArray29.a[i]), global(FunctionTests.UnknownArray29.a[i + 1])});
  return;
 annotation(Inline = false);
 end FunctionTests.UnknownArray29.f1;

 function FunctionTests.UnknownArray29.f2
  input Real[:] x2;
  output Real y2;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(x2, 1) loop
   temp_1 := temp_1 + x2[i1];
  end for;
  y2 := temp_1;
  return;
 annotation(Inline = false);
 end FunctionTests.UnknownArray29.f2;

end FunctionTests.UnknownArray29;
")})));
end UnknownArray29;


model UnknownArray30
	function f
		input Real[:] a;
		output Real b;
	algorithm
		b := a * ones(size(a, 1)) + zeros(size(a, 1)) * fill(a[1], size(a, 1));
	end f;
	
	Real x = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray30",
            description="Fill type operators with unknown arguments in functions",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray30
 Real x;
equation
 x = FunctionTests.UnknownArray30.f({1, 2, 3});

public
 function FunctionTests.UnknownArray30.f
  input Real[:] a;
  output Real b;
  Real temp_1;
  Real temp_2;
  Real temp_3;
  Real temp_4;
 algorithm
  temp_2 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_2 := temp_2 + a[i1];
  end for;
  temp_1 := temp_2;
  temp_4 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_4 := temp_4;
  end for;
  temp_3 := temp_4;
  b := temp_1 + temp_3;
  return;
 end FunctionTests.UnknownArray30.f;

end FunctionTests.UnknownArray30;
")})));
end UnknownArray30;

model UnknownArray31
	function f1
		input Real[:] a;
		output Real[size(a,1)] b;
	algorithm
		b := 2 * a;
	end f1;
	
	function f2
		input Real[:] c;
		output Real[size(c,1)] d;
	algorithm
		d := f1(c);
	end f2;
	
	Real[2] x = f2({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray31",
            description="Assignstatement with right hand side function call.",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray31
 Real x[1];
 Real x[2];
equation
 ({x[1], x[2]}) = FunctionTests.UnknownArray31.f2({1, 2});

public
 function FunctionTests.UnknownArray31.f2
  input Real[:] c;
  output Real[:] d;
 algorithm
  init d as Real[size(c, 1)];
  (d) := FunctionTests.UnknownArray31.f1(c);
  return;
 end FunctionTests.UnknownArray31.f2;

 function FunctionTests.UnknownArray31.f1
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   b[i1] := 2 * a[i1];
  end for;
  return;
 end FunctionTests.UnknownArray31.f1;

end FunctionTests.UnknownArray31;
")})));
end UnknownArray31;

model UnknownArray32
    function f
        input Real[:] a;
        output Real b;
	protected
        Real[1,size(a,1)] c;
    algorithm
        c[1,:] := 2 * a;
		b := sum(c);
    end f;
    
    Real x = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray32",
            description="Check that size assignment for protected array with some dimensions known works",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray32
 Real x;
equation
 x = FunctionTests.UnknownArray32.f({1, 2});

public
 function FunctionTests.UnknownArray32.f
  input Real[:] a;
  output Real b;
  Real[:,:] c;
  Real temp_1;
 algorithm
  init c as Real[1, size(a, 1)];
  for i1 in 1:size(a, 1) loop
   c[1,i1] := 2 * a[i1];
  end for;
  temp_1 := 0.0;
  for i1 in 1:1 loop
   for i2 in 1:size(a, 1) loop
    temp_1 := temp_1 + c[i1,i2];
   end for;
  end for;
  b := temp_1;
  return;
 end FunctionTests.UnknownArray32.f;

end FunctionTests.UnknownArray32;
")})));
end UnknownArray32;

model UnknownArray33
  record R
    Real[2] x;
  end R;
	
    function f
        input Real[2] a;
        output Real b;
        output R c;
    algorithm
        b := a[1];
		c := R(f2(f2(a)));
    end f;
	
	function f2
		input Real[:] a;
		output Real[size(a,1)] b = a;
		algorithm
	end f2;
    
    Real x;
	R y;
equation
	(x,y) = f(f2(f2({time,time*2})));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray33",
            description="Check extraction of function calls in function call equations",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray33
 Real x;
 Real y.x[1];
 Real y.x[2];
equation
 (x, FunctionTests.UnknownArray33.R({y.x[1], y.x[2]})) = FunctionTests.UnknownArray33.f(FunctionTests.UnknownArray33.f2(FunctionTests.UnknownArray33.f2({time, time * 2})));

public
 function FunctionTests.UnknownArray33.f
  input Real[:] a;
  output Real b;
  output FunctionTests.UnknownArray33.R c;
  Real[:] temp_1;
 algorithm
  b := a[1];
  init temp_1 as Real[2];
  (temp_1) := FunctionTests.UnknownArray33.f2(FunctionTests.UnknownArray33.f2(a));
  for i1 in 1:2 loop
   c.x[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.UnknownArray33.f;

 function FunctionTests.UnknownArray33.f2
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   b[i1] := a[i1];
  end for;
  return;
 end FunctionTests.UnknownArray33.f2;

 record FunctionTests.UnknownArray33.R
  Real x[2];
 end FunctionTests.UnknownArray33.R;

end FunctionTests.UnknownArray33;
")})));
end UnknownArray33;

model UnknownArray34
    function f
		input Integer n;
        output Real b;
    protected
        Real[3] c;
        Real[n] d;
    algorithm
        d := {1,2,3};
        c := d;
        b := 1;
    end f;

    Real x = f(3);
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray34",
            description="Known to unknown size assignment",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray34
 Real x;
equation
 x = FunctionTests.UnknownArray34.f(3);

public
 function FunctionTests.UnknownArray34.f
  input Integer n;
  output Real b;
  Real[:] c;
  Real[:] d;
  Integer[:] temp_1;
 algorithm
  init c as Real[3];
  init d as Real[n];
  assert(n == 3, \"Mismatching sizes in FunctionTests.UnknownArray34.f\");
  init temp_1 as Integer[3];
  temp_1[1] := 1;
  temp_1[2] := 2;
  temp_1[3] := 3;
  for i1 in 1:n loop
   d[i1] := temp_1[i1];
  end for;
  assert(n == 3, \"Mismatching sizes in FunctionTests.UnknownArray34.f\");
  for i1 in 1:3 loop
   c[i1] := d[i1];
  end for;
  b := 1;
  return;
 end FunctionTests.UnknownArray34.f;

end FunctionTests.UnknownArray34;
")})));
end UnknownArray34;

model UnknownArray35
    function f
		input Integer n;
		input Real[:] d;
        output Real b;
    protected
		Real[n,3] e;
    algorithm
		e := {d,d,d};
        b := 1;
    end f;

    Real x = f(3, {1,2,3});
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray35",
            description="Known to unknown size assignment",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray35
 Real x;
equation
 x = FunctionTests.UnknownArray35.f(3, {1, 2, 3});

public
 function FunctionTests.UnknownArray35.f
  input Integer n;
  input Real[:] d;
  output Real b;
  Real[:,:] e;
  Real[:,:] temp_1;
 algorithm
  init e as Real[n, 3];
  assert(size(d, 1) == 3, \"Mismatching sizes in FunctionTests.UnknownArray35.f\");
  assert(n == 3, \"Mismatching sizes in FunctionTests.UnknownArray35.f\");
  init temp_1 as Real[3, size(d, 1)];
  for i1 in 1:size(d, 1) loop
   temp_1[1,i1] := d[i1];
  end for;
  for i1 in 1:size(d, 1) loop
   temp_1[2,i1] := d[i1];
  end for;
  for i1 in 1:size(d, 1) loop
   temp_1[3,i1] := d[i1];
  end for;
  for i1 in 1:n loop
   for i2 in 1:3 loop
    e[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  b := 1;
  return;
 end FunctionTests.UnknownArray35.f;

end FunctionTests.UnknownArray35;
")})));
end UnknownArray35;

model UnknownArray36
    function f2
		input Real[:] xin;
		input Real[2] yin;
		output Real[size(xin,1)] xout = yin;
		output Real[2] yout = xin;
		algorithm
	end f2;
	
    function f1
		input Integer n;
        output Real b;
    protected
        Real[2] c;
        Real[n] d;
    algorithm
        d[1:2] := {1,2};
        c := d;
		(c,d) := f2(c,d);
        b := 1;
    end f1;

    Real x = f1(2);
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray36",
            description="Known to unknown size assignment",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray36
 Real x;
equation
 x = FunctionTests.UnknownArray36.f1(2);

public
 function FunctionTests.UnknownArray36.f1
  input Integer n;
  output Real b;
  Real[:] c;
  Real[:] d;
  Integer[:] temp_1;
 algorithm
  init c as Real[2];
  init d as Real[n];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   d[i1] := temp_1[i1];
  end for;
  assert(n == 2, \"Mismatching sizes in FunctionTests.UnknownArray36.f1\");
  for i1 in 1:2 loop
   c[i1] := d[i1];
  end for;
  assert(n == 2, \"Mismatching sizes in FunctionTests.UnknownArray36.f1\");
  (c, d) := FunctionTests.UnknownArray36.f2(c, d);
  b := 1;
  return;
 end FunctionTests.UnknownArray36.f1;

 function FunctionTests.UnknownArray36.f2
  input Real[:] xin;
  input Real[:] yin;
  output Real[:] xout;
  output Real[:] yout;
 algorithm
  init xout as Real[size(xin, 1)];
  assert(size(xin, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray36.f2\");
  for i1 in 1:size(xin, 1) loop
   xout[i1] := yin[i1];
  end for;
  init yout as Real[2];
  assert(size(xin, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray36.f2\");
  for i1 in 1:2 loop
   yout[i1] := xin[i1];
  end for;
  return;
 end FunctionTests.UnknownArray36.f2;

end FunctionTests.UnknownArray36;
")})));
end UnknownArray36;

model UnknownArray37
    function f2
		input Real[:,:] xin;
		input Real[2,:] yin;
		output Real[size(xin,1),size(xin,2)] xout = yin;
		output Real[2,2] yout = xin;
		algorithm
	end f2;
	
    function f1
		input Integer n;
		input Real[:,:] d;
        output Real b;
    protected
        Real[2,n] c;
    algorithm
        c := d;
		(c,d) := f2(c,d);
        b := 1;
    end f1;

    Real x = f1(2, {{1,2},{3,4}});
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray37",
            description="Known to unknown size assignment",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray37
 Real x;
equation
 x = FunctionTests.UnknownArray37.f1(2, {{1, 2}, {3, 4}});

public
 function FunctionTests.UnknownArray37.f1
  input Integer n;
  input Real[:,:] d;
  output Real b;
  Real[:,:] c;
 algorithm
  init c as Real[2, n];
  assert(size(d, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray37.f1\");
  for i1 in 1:2 loop
   for i2 in 1:n loop
    c[i1,i2] := d[i1,i2];
   end for;
  end for;
  assert(size(d, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray37.f1\");
  assert(size(d, 2) == 2, \"Mismatching sizes in FunctionTests.UnknownArray37.f1\");
  (c, d) := FunctionTests.UnknownArray37.f2(c, d);
  b := 1;
  return;
 end FunctionTests.UnknownArray37.f1;

 function FunctionTests.UnknownArray37.f2
  input Real[:,:] xin;
  input Real[:,:] yin;
  output Real[:,:] xout;
  output Real[:,:] yout;
 algorithm
  init xout as Real[size(xin, 1), size(xin, 2)];
  assert(size(xin, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray37.f2\");
  for i1 in 1:size(xin, 1) loop
   for i2 in 1:size(xin, 2) loop
    xout[i1,i2] := yin[i1,i2];
   end for;
  end for;
  init yout as Real[2, 2];
  assert(size(xin, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray37.f2\");
  assert(size(xin, 2) == 2, \"Mismatching sizes in FunctionTests.UnknownArray37.f2\");
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    yout[i1,i2] := xin[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray37.f2;

end FunctionTests.UnknownArray37;
")})));
end UnknownArray37;

model UnknownArray38
    function f
		input Integer n;
		input Real[:] d;
        output Real b;
    protected
		Real[n,3] e;
		Real[1,1] c;
    algorithm
		e := {d,d,d};
		c := [f(n,3 * e * 3 * {{1,2},{3,4},{5,6}})];
        b := 1;
    end f;
    Real x = f(3, {1,2,3});
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray38",
            description="Checks a more complex combination of known/unknown sizes",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray38
 Real x;
equation
 x = FunctionTests.UnknownArray38.f(3, {1, 2, 3});

public
 function FunctionTests.UnknownArray38.f
  input Integer n;
  input Real[:] d;
  output Real b;
  Real[:,:] e;
  Real[:,:] c;
  Real[:,:] temp_1;
  Real[:,:] temp_2;
  Real[:,:] temp_3;
  Real[:] temp_4;
  Real[:,:] temp_5;
  Real temp_6;
  Integer[:,:] temp_7;
  Integer[:] temp_8;
  Integer[:] temp_9;
  Integer[:] temp_10;
  Real[:] temp_11;
 algorithm
  init e as Real[n, 3];
  init c as Real[1, 1];
  assert(size(d, 1) == 3, \"Mismatching sizes in FunctionTests.UnknownArray38.f\");
  assert(n == 3, \"Mismatching sizes in FunctionTests.UnknownArray38.f\");
  init temp_1 as Real[3, size(d, 1)];
  for i1 in 1:size(d, 1) loop
   temp_1[1,i1] := d[i1];
  end for;
  for i1 in 1:size(d, 1) loop
   temp_1[2,i1] := d[i1];
  end for;
  for i1 in 1:size(d, 1) loop
   temp_1[3,i1] := d[i1];
  end for;
  for i1 in 1:n loop
   for i2 in 1:3 loop
    e[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  assert(n == 1, \"Mismatching sizes in FunctionTests.UnknownArray38.f\");
  init temp_2 as Real[n, 1];
  init temp_3 as Real[n, 1];
  init temp_4 as Real[n];
  init temp_5 as Real[n, 2];
  init temp_7 as Integer[3, 2];
  init temp_8 as Integer[2];
  temp_8[1] := 1;
  temp_8[2] := 2;
  for i7 in 1:2 loop
   temp_7[1,i7] := temp_8[i7];
  end for;
  init temp_9 as Integer[2];
  temp_9[1] := 3;
  temp_9[2] := 4;
  for i7 in 1:2 loop
   temp_7[2,i7] := temp_9[i7];
  end for;
  init temp_10 as Integer[2];
  temp_10[1] := 5;
  temp_10[2] := 6;
  for i7 in 1:2 loop
   temp_7[3,i7] := temp_10[i7];
  end for;
  for i5 in 1:n loop
   for i6 in 1:2 loop
    temp_6 := 0.0;
    for i7 in 1:3 loop
     temp_6 := temp_6 + 3 * e[i5,i7] * 3 * temp_7[i7,i6];
    end for;
    temp_5[i5,i6] := temp_6;
   end for;
  end for;
  for i4 in 1:n loop
   init temp_11 as Real[2];
   for i5 in 1:2 loop
    temp_11[i5] := temp_5[i4,i5];
   end for;
   temp_4[i4] := FunctionTests.UnknownArray38.f(n, temp_11);
  end for;
  for i3 in 1:n loop
   temp_3[i3,1] := temp_4[i3];
  end for;
  for i1 in 1:n loop
   for i2 in 1:1 loop
    temp_2[i1,i2] := temp_3[i1,i2];
   end for;
  end for;
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    c[i1,i2] := temp_2[i1,i2];
   end for;
  end for;
  b := 1;
  return;
 end FunctionTests.UnknownArray38.f;

end FunctionTests.UnknownArray38;
")})));
end UnknownArray38;

model UnknownArray39
    record R
        Real x;
    end R;
    function f
        input Integer m;
        output R[m,m] o;
    algorithm
        for i in 1:m loop
            o[i,:] := {R(i*j) for j in 1:m};
        end for;
    end f;
    
    R[1,1] c = f(1);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray39",
            description="Unknown size record array",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray39
 Real c[1,1].x;
equation
 ({{FunctionTests.UnknownArray39.R(c[1,1].x)}}) = FunctionTests.UnknownArray39.f(1);

public
 function FunctionTests.UnknownArray39.f
  input Integer m;
  output FunctionTests.UnknownArray39.R[:,:] o;
  FunctionTests.UnknownArray39.R[:] temp_1;
 algorithm
  init o as FunctionTests.UnknownArray39.R[m, m];
  for i in 1:m loop
   init temp_1 as FunctionTests.UnknownArray39.R[max(m, 0)];
   for i1 in 1:max(m, 0) loop
    temp_1[i1].x := i * i1;
   end for;
   for i1 in 1:m loop
    o[i,i1].x := temp_1[i1].x;
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray39.f;

 record FunctionTests.UnknownArray39.R
  Real x;
 end FunctionTests.UnknownArray39.R;

end FunctionTests.UnknownArray39;
")})));
end UnknownArray39;

model UnknownArray40
    record R
        Real[2] y;
    end R;
    function f
        input  R[:] i;
        output R[size(i,1)] o;
    algorithm
        o := i;
        o[:] := i;
        o := i[:];
        o[:] := i[:];
    end f;
    
    R[1] r = f({R({2,3})});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray40",
            description="Unknown size record array",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray40
 Real r[1].y[1];
 Real r[1].y[2];
equation
 ({FunctionTests.UnknownArray40.R({r[1].y[1], r[1].y[2]})}) = FunctionTests.UnknownArray40.f({FunctionTests.UnknownArray40.R({2, 3})});

public
 function FunctionTests.UnknownArray40.f
  input FunctionTests.UnknownArray40.R[:] i;
  output FunctionTests.UnknownArray40.R[:] o;
 algorithm
  init o as FunctionTests.UnknownArray40.R[size(i, 1)];
  for i1 in 1:size(i, 1) loop
   assert(2 == size(i[i1].y, 1), \"Mismatching sizes in function 'FunctionTests.UnknownArray40.f', component 'i[i1].y', dimension '1'\");
  end for;
  for i1 in 1:size(i, 1) loop
   for i2 in 1:2 loop
    o[i1].y[i2] := i[i1].y[i2];
   end for;
  end for;
  for i1 in 1:size(i, 1) loop
   for i2 in 1:2 loop
    o[i1].y[i2] := i[i1].y[i2];
   end for;
  end for;
  for i1 in 1:size(i, 1) loop
   for i2 in 1:2 loop
    o[i1].y[i2] := i[i1].y[i2];
   end for;
  end for;
  for i1 in 1:size(i, 1) loop
   for i2 in 1:2 loop
    o[i1].y[i2] := i[i1].y[i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray40.f;

 record FunctionTests.UnknownArray40.R
  Real y[2];
 end FunctionTests.UnknownArray40.R;

end FunctionTests.UnknownArray40;
")})));
end UnknownArray40;

model UnknownArray41
    record R
        Real x;
        Real[2] y;
    end R;
    function f
        input Integer m;
        output R[m,m] o;
    algorithm
        for i in 1:m loop
            o[i,:] := {R(i*j, {i,j}) for j in 1:m};
        end for;
    end f;
    
    R[1,1] c = f(1);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray41",
            description="Unknown size record array",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray41
 Real c[1,1].x;
 Real c[1,1].y[1];
 Real c[1,1].y[2];
equation
 ({{FunctionTests.UnknownArray41.R(c[1,1].x, {c[1,1].y[1], c[1,1].y[2]})}}) = FunctionTests.UnknownArray41.f(1);

public
 function FunctionTests.UnknownArray41.f
  input Integer m;
  output FunctionTests.UnknownArray41.R[:,:] o;
  FunctionTests.UnknownArray41.R[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init o as FunctionTests.UnknownArray41.R[m, m];
  for i in 1:m loop
   init temp_1 as FunctionTests.UnknownArray41.R[max(m, 0)];
   for i1 in 1:max(m, 0) loop
    init temp_2 as Integer[2];
    temp_2[1] := i;
    temp_2[2] := i1;
    temp_1[i1].x := i * i1;
    init temp_1[i1].y as Real[2];
    for i2 in 1:2 loop
     temp_1[i1].y[i2] := temp_2[i2];
    end for;
   end for;
   for i1 in 1:m loop
    o[i,i1].x := temp_1[i1].x;
    for i2 in 1:2 loop
     o[i,i1].y[i2] := temp_1[i1].y[i2];
    end for;
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray41.f;

 record FunctionTests.UnknownArray41.R
  Real x;
  Real y[2];
 end FunctionTests.UnknownArray41.R;

end FunctionTests.UnknownArray41;
")})));
end UnknownArray41;

model UnknownArray42
    record R1
        R2[1] y;
        R2 z;
    end R1;
    record R2
        Real[1] p1;
        Real p2;
    end R2;
    function f2
        input Real x;
        output R2 y = R2(1:1,x);
      algorithm
    end f2;
    function f
        input Integer m;
        output R1[m] o;
    algorithm
        o[:] := {R1({f2(j)},f2(j)) for j in 1:m};
    end f;
    
    R1[1] c = f(1);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray42",
            description="Unknown size record array",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray42
 Real c[1].y[1].p1[1];
 Real c[1].y[1].p2;
 Real c[1].z.p1[1];
 Real c[1].z.p2;
equation
 ({FunctionTests.UnknownArray42.R1({FunctionTests.UnknownArray42.R2({c[1].y[1].p1[1]}, c[1].y[1].p2)}, FunctionTests.UnknownArray42.R2({c[1].z.p1[1]}, c[1].z.p2))}) = FunctionTests.UnknownArray42.f(1);

public
 function FunctionTests.UnknownArray42.f
  input Integer m;
  output FunctionTests.UnknownArray42.R1[:] o;
  FunctionTests.UnknownArray42.R1[:] temp_1;
  FunctionTests.UnknownArray42.R2[:] temp_2;
  FunctionTests.UnknownArray42.R2 temp_3;
  FunctionTests.UnknownArray42.R2 temp_4;
 algorithm
  init o as FunctionTests.UnknownArray42.R1[m];
  init temp_1 as FunctionTests.UnknownArray42.R1[max(m, 0)];
  for i1 in 1:max(m, 0) loop
   init temp_2 as FunctionTests.UnknownArray42.R2[1];
   (temp_3) := FunctionTests.UnknownArray42.f2(i1);
   temp_2[1] := temp_3;
   (temp_4) := FunctionTests.UnknownArray42.f2(i1);
   temp_1[i1].y := temp_2;
   temp_1[i1].z := temp_4;
  end for;
  for i1 in 1:m loop
   for i2 in 1:1 loop
    for i3 in 1:1 loop
     o[i1].y[i2].p1[i3] := temp_1[i1].y[i2].p1[i3];
    end for;
    o[i1].y[i2].p2 := temp_1[i1].y[i2].p2;
   end for;
   for i2 in 1:1 loop
    o[i1].z.p1[i2] := temp_1[i1].z.p1[i2];
   end for;
   o[i1].z.p2 := temp_1[i1].z.p2;
  end for;
  return;
 end FunctionTests.UnknownArray42.f;

 function FunctionTests.UnknownArray42.f2
  input Real x;
  output FunctionTests.UnknownArray42.R2 y;
 algorithm
  for i1 in 1:1 loop
   y.p1[i1] := i1;
  end for;
  y.p2 := x;
  return;
 end FunctionTests.UnknownArray42.f2;

 record FunctionTests.UnknownArray42.R2
  Real p1[1];
  Real p2;
 end FunctionTests.UnknownArray42.R2;

 record FunctionTests.UnknownArray42.R1
  FunctionTests.UnknownArray42.R2 y[1];
  FunctionTests.UnknownArray42.R2 z;
 end FunctionTests.UnknownArray42.R1;

end FunctionTests.UnknownArray42;
")})));
end UnknownArray42;

model UnknownArray43
    record R1
        Real[2] x;
    end R1;
    function f
        input Real[:] x;
        output R1 r;
      algorithm
        r := R1(x);
    end f;
    R1 r = f({3,4});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray43",
            description="Unknown size array in record constructor",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray43
 Real r.x[1];
 Real r.x[2];
equation
 (FunctionTests.UnknownArray43.R1({r.x[1], r.x[2]})) = FunctionTests.UnknownArray43.f({3, 4});

public
 function FunctionTests.UnknownArray43.f
  input Real[:] x;
  output FunctionTests.UnknownArray43.R1 r;
 algorithm
  assert(size(x, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray43.f\");
  for i1 in 1:2 loop
   r.x[i1] := x[i1];
  end for;
  return;
 end FunctionTests.UnknownArray43.f;

 record FunctionTests.UnknownArray43.R1
  Real x[2];
 end FunctionTests.UnknownArray43.R1;

end FunctionTests.UnknownArray43;
")})));
end UnknownArray43;

model UnknownArray44
    record R1
        Real[1] x;
    end R1;
    record R2
        R1[1] y;
    end R1;
    function f
        input R1[:] r1;
        output R2 r2;
      algorithm
        r2 := R2(r1);
    end f;
    R2 r = f({R1({3}),R1({4})});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray44",
            description="Unknown size record array in record constructor",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray44
 Real r.y[1].x[1];
equation
 (FunctionTests.UnknownArray44.R2({FunctionTests.UnknownArray44.R1({r.y[1].x[1]})})) = FunctionTests.UnknownArray44.f({FunctionTests.UnknownArray44.R1({3}), FunctionTests.UnknownArray44.R1({4})});

public
 function FunctionTests.UnknownArray44.f
  input FunctionTests.UnknownArray44.R1[:] r1;
  output FunctionTests.UnknownArray44.R2 r2;
 algorithm
  for i1 in 1:size(r1, 1) loop
   assert(1 == size(r1[i1].x, 1), \"Mismatching sizes in function 'FunctionTests.UnknownArray44.f', component 'r1[i1].x', dimension '1'\");
  end for;
  assert(size(r1, 1) == 1, \"Mismatching sizes in FunctionTests.UnknownArray44.f\");
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    r2.y[i1].x[i2] := r1[i1].x[i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray44.f;

 record FunctionTests.UnknownArray44.R1
  Real x[1];
 end FunctionTests.UnknownArray44.R1;

 record FunctionTests.UnknownArray44.R2
  FunctionTests.UnknownArray44.R1 y[1];
 end FunctionTests.UnknownArray44.R2;

end FunctionTests.UnknownArray44;
")})));
end UnknownArray44;

model UnknownArray45
    record R1
        Real[2] x;
    end R1;
    function f
        input Real[:] x;
        input Real[:] y;
        output R1 r;
      algorithm
        r := if size(x,1) == 2 then R1(x) else if not size(y,1) == 2 then R1({1,2}) else R1(y);
    end f;
    R1 r = f({3,4},{5,6});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray45",
            description="Unknown size array in record constructor in if expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray45
 Real r.x[1];
 Real r.x[2];
equation
 (FunctionTests.UnknownArray45.R1({r.x[1], r.x[2]})) = FunctionTests.UnknownArray45.f({3, 4}, {5, 6});

public
 function FunctionTests.UnknownArray45.f
  input Real[:] x;
  input Real[:] y;
  output FunctionTests.UnknownArray45.R1 r;
  Integer[:] temp_1;
 algorithm
  assert(size(x, 1) == 2 or not size(x, 1) == 2, \"Mismatching sizes in FunctionTests.UnknownArray45.f\");
  assert(size(y, 1) == 2 or not (not size(x, 1) == 2 and not not size(y, 1) == 2), \"Mismatching sizes in FunctionTests.UnknownArray45.f\");
  if size(x, 1) == 2 then
  else
   if not size(y, 1) == 2 then
    init temp_1 as Integer[2];
    temp_1[1] := 1;
    temp_1[2] := 2;
   end if;
  end if;
  for i1 in 1:2 loop
   r.x[i1] := if size(x, 1) == 2 then x[i1] elseif not size(y, 1) == 2 then temp_1[i1] else y[i1];
  end for;
  return;
 end FunctionTests.UnknownArray45.f;

 record FunctionTests.UnknownArray45.R1
  Real x[2];
 end FunctionTests.UnknownArray45.R1;

end FunctionTests.UnknownArray45;
")})));
end UnknownArray45;

model UnknownArray46
    function f2
        input Real[:] x;
        output Real[size(x,1)] y;
      algorithm
        y := x;
    end f2;
    function f1
        input Real[:] x;
        output Real[size(x,1)] y;
      algorithm
        y := f2(if size(x,1) > 1 then x else x .+ 1);
    end f1;
    Real[1] y = f1({1});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray46",
            description="Unknown size if exp as function call arg",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray46
 Real y[1];
equation
 ({y[1]}) = FunctionTests.UnknownArray46.f1({1});

public
 function FunctionTests.UnknownArray46.f1
  input Real[:] x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[size(x, 1)];
  if size(x, 1) > 1 then
  else
   init temp_1 as Real[size(x, 1)];
   for i1 in 1:size(x, 1) loop
    temp_1[i1] := x[i1] .+ 1;
   end for;
  end if;
  (y) := FunctionTests.UnknownArray46.f2(if size(x, 1) > 1 then x else temp_1);
  return;
 end FunctionTests.UnknownArray46.f1;

 function FunctionTests.UnknownArray46.f2
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  return;
 end FunctionTests.UnknownArray46.f2;

end FunctionTests.UnknownArray46;
")})));
end UnknownArray46;

model UnknownArray47
    function f2
        input Real[:] a;
        output Real[size(a,1)] b = a;
        algorithm
    end f2;
    function f1
        input Real[:] x;
        output Real[size(x,1)] y;
        algorithm
            y := f2(x + x) + x;
        annotation(Inline=false);
    end f1;
    
    Real[1] y = f1({time});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray47",
            description="Test flattening of function call sizes with unknown size args #3806",
            flatModel="
fclass FunctionTests.UnknownArray47
 Real y[1];
equation
 ({y[1]}) = FunctionTests.UnknownArray47.f1({time});

public
 function FunctionTests.UnknownArray47.f1
  input Real[:] x;
  output Real[:] y;
  Real[:] temp_1;
  Real[:] temp_2;
 algorithm
  init y as Real[size(x, 1)];
  init temp_1 as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   temp_1[i1] := x[i1] + x[i1];
  end for;
  init temp_2 as Real[size(x, 1)];
  (temp_2) := FunctionTests.UnknownArray47.f2(temp_1);
  for i1 in 1:size(x, 1) loop
   y[i1] := temp_2[i1] + x[i1];
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.UnknownArray47.f1;

 function FunctionTests.UnknownArray47.f2
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   b[i1] := a[i1];
  end for;
  return;
 end FunctionTests.UnknownArray47.f2;

end FunctionTests.UnknownArray47;
")})));
end UnknownArray47;

model UnknownArray48
    function f
        input Real[1,:] x;
        output Real[1,1] y;
        algorithm
            y := x*transpose(x);
        annotation(Inline=false);
    end f;
    
    Real[1,1] y = f({{time}});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray48",
            description="Scalarizing known size mul exp with unknown size parts as rhs of assigment. #3788",
            flatModel="
fclass FunctionTests.UnknownArray48
 Real y[1,1];
equation
 ({{y[1,1]}}) = FunctionTests.UnknownArray48.f({{time}});

public
 function FunctionTests.UnknownArray48.f
  input Real[:,:] x;
  output Real[:,:] y;
  Real[:,:] temp_1;
  Real temp_2;
 algorithm
  init y as Real[1, 1];
  init temp_1 as Real[1, 1];
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    temp_2 := 0.0;
    for i3 in 1:size(x, 2) loop
     temp_2 := temp_2 + x[i1,i3] * x[i2,i3];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    y[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 annotation(Inline = false);
 end FunctionTests.UnknownArray48.f;

end FunctionTests.UnknownArray48;
")})));
end UnknownArray48;

model UnknownArray49
    partial function part
        input Real[3] x;
        output Real[3] y;
    end part;
    
    function full
        extends part;
        input Real z;
      algorithm
        y := x .+ z;
    end full;

    function f
        input Real[:] x;
        input part pf;
        output Real[size(x,1)] y;
      algorithm
        y := pf(x);
    end f;
    
    Real[3] y = f({1,2,3}, function full(z=time));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray49",
            description="Size asserts for partial function call",
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray49
 Real y[1];
 Real y[2];
 Real y[3];
equation
 ({y[1], y[2], y[3]}) = FunctionTests.UnknownArray49.f({1, 2, 3}, function FunctionTests.UnknownArray49.full(time));

public
 function FunctionTests.UnknownArray49.f
  input Real[:] x;
  input ((Real[3] y) = FunctionTests.UnknownArray49.part(Real[3] x)) pf;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  assert(size(x, 1) == 3, \"Mismatching sizes in FunctionTests.UnknownArray49.f\");
  (y) := pf(x);
  return;
 end FunctionTests.UnknownArray49.f;

 function FunctionTests.UnknownArray49.part
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[3];
  return;
 end FunctionTests.UnknownArray49.part;

 function FunctionTests.UnknownArray49.full
  input Real[:] x;
  output Real[:] y;
  input Real z;
 algorithm
  init y as Real[3];
  for i1 in 1:3 loop
   y[i1] := x[i1] .+ z;
  end for;
  return;
 end FunctionTests.UnknownArray49.full;

end FunctionTests.UnknownArray49;
")})));
end UnknownArray49;

model UnknownArray50
    function F
        input Integer x;
        output Real y = 0;
    algorithm
        for i in 0:x loop
            y := missingFunction(i, x) + notAVariable;
        end for;
    end F;
    
    parameter Real r = F(3);
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownArray50",
            description="Ensure that error checking is done in for loops which loop over unknown size",
            errorMessage="
2 errors found:

Error at line 7, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find function declaration for missingFunction()

Error at line 7, column 42, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find class or component declaration for notAVariable
")})));
end UnknownArray50;

model UnknownArray51
    function f
        input Real[:,size(x,1)] x;
        output Real y[size(x,1)] = x[1,:];
        algorithm
    end f;
    constant Real[:] y = f({{1}});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray51",
            description="Non-circular sizes",
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray51
 constant Real y[1] = 1;
end FunctionTests.UnknownArray51;
")})));
end UnknownArray51;

model UnknownArray52
    record R
        Real[:] x;
    end R;
    
    function f
        output R r;
    algorithm
        r := R(1:2);
    end f;
    R r = f();
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="UnknownArray52",
            description="Cannot resolve size of function output",
            errorMessage="
1 errors found:

Compliance error at line 6, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_FUNCTION_OUTPUT:
  Can not infer array size of the function output r.x
")})));
end UnknownArray52;

model UnknownArray53
    record R
        Real[2] a;
    end R;
    function F
        input Real[:] X;
        output R r;
    algorithm
        r := R(cat(1, X, {1 - sum(X)}));
    end F;
    R r = F({(sin(time) + 1) / 2});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray53",
            description="Bug in #5272",
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray53
 Real r.a[1];
 Real r.a[2];
equation
 (FunctionTests.UnknownArray53.R({r.a[1], r.a[2]})) = FunctionTests.UnknownArray53.F({(sin(time) + 1) / 2});

public
 function FunctionTests.UnknownArray53.F
  input Real[:] X;
  output FunctionTests.UnknownArray53.R r;
  Real[:] temp_1;
  Real[:] temp_2;
  Real temp_3;
 algorithm
  assert(size(X, 1) + 1 == 2, \"Mismatching sizes in FunctionTests.UnknownArray53.F\");
  init temp_1 as Real[size(X, 1) + 1];
  for i1 in 1:size(X, 1) loop
   temp_1[i1] := X[i1];
  end for;
  init temp_2 as Real[1];
  temp_3 := 0.0;
  for i2 in 1:size(X, 1) loop
   temp_3 := temp_3 + X[i2];
  end for;
  temp_2[1] := 1 - temp_3;
  for i1 in 1:1 loop
   temp_1[i1 + size(X, 1)] := temp_2[i1];
  end for;
  for i1 in 1:2 loop
   r.a[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.UnknownArray53.F;

 record FunctionTests.UnknownArray53.R
  Real a[2];
 end FunctionTests.UnknownArray53.R;

end FunctionTests.UnknownArray53;
")})));
end UnknownArray53;

model UnknownArray54
    function f1
        input Integer n;
        Real[:] t = 1:n;
        output Real y = f2({f2(t[1:1]) for i in 1:n});
        algorithm
    end f1;
    
    function f2
        input Real[:] x;
        output Real y = sum(x);
        algorithm
    end f2;
    
    Real y = f1(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray54",
            description="Bug in #5291",
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownArray54
 constant Real y = 2.0;
end FunctionTests.UnknownArray54;
")})));
end UnknownArray54;

model UnknownArray55
record R
    Real x;
end R;

function f
    input R[:] r;
    output Real y = sum(r[:].x);
algorithm
end f;

Real y = f({R(1),R(2)});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownArray55",
            description="Bug in #5317",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.UnknownArray55
 Real y;
equation
 y = FunctionTests.UnknownArray55.f({FunctionTests.UnknownArray55.R(1), FunctionTests.UnknownArray55.R(2)});

public
 function FunctionTests.UnknownArray55.f
  input FunctionTests.UnknownArray55.R[:] r;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(r, 1) loop
   temp_1 := temp_1 + r[i1].x;
  end for;
  y := temp_1;
  return;
 end FunctionTests.UnknownArray55.f;

 record FunctionTests.UnknownArray55.R
  Real x;
 end FunctionTests.UnknownArray55.R;

end FunctionTests.UnknownArray55;
")})));
end UnknownArray55;


// TODO: need more complex cases
model IncompleteFunc1
 function f
  input Real x;
  output Real y = x;
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IncompleteFunc1",
            description="Wrong contents of called function: neither algorithm nor external",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 7, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));
end IncompleteFunc1;


model IncompleteFunc2
 function f
  input Real x;
  output Real y = x;
 algorithm
  y := y + 1;
 algorithm
  y := y + 1;
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IncompleteFunc2",
            description="Wrong contents of called function: 2 algorithm",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 11, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));
end IncompleteFunc2;


model IncompleteFunc3
 function f
  input Real x;
  output Real y = x;
 algorithm
  y := y + 1;
 external;
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IncompleteFunc3",
            description="Wrong contents of called function: both algorithm and external",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 10, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));
end IncompleteFunc3;



model ExternalFunc1
 function f
  input Real x;
  output Real y;
 external;
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc1",
            description="External functions: simple func, all default",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExternalFunc1
 Real x = FunctionTests.ExternalFunc1.f(2);

public
 function FunctionTests.ExternalFunc1.f
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end FunctionTests.ExternalFunc1.f;

end FunctionTests.ExternalFunc1;
")})));
end ExternalFunc1;


model ExternalFunc2
 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
  protected Real a = y + 2;
 external;
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc2",
            description="External functions: complex func, all default",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExternalFunc2
 Real x = FunctionTests.ExternalFunc2.f({{1, 2}, {3, 4}}, 5);

public
 function FunctionTests.ExternalFunc2.f
  input Real[:,:] x;
  input Real y;
  output Real z;
  output Real q;
  Real a;
 algorithm
  assert(2 == size(x, 2), \"Mismatching sizes in function 'FunctionTests.ExternalFunc2.f', component 'x', dimension '2'\");
  a := y + 2;
  external \"C\" f(x, size(x, 1), size(x, 2), y, z, q, a);
  return;
 end FunctionTests.ExternalFunc2.f;

end FunctionTests.ExternalFunc2;
")})));
end ExternalFunc2;


model ExternalFunc3
 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
 external foo(size(x,1), 2, x, z, y, q);
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc3",
            description="External functions: complex func, call set",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExternalFunc3
 Real x = FunctionTests.ExternalFunc3.f({{1, 2}, {3, 4}}, 5);

public
 function FunctionTests.ExternalFunc3.f
  input Real[:,:] x;
  input Real y;
  output Real z;
  output Real q;
 algorithm
  assert(2 == size(x, 2), \"Mismatching sizes in function 'FunctionTests.ExternalFunc3.f', component 'x', dimension '2'\");
  external \"C\" foo(size(x, 1), 2, x, z, y, q);
  return;
 end FunctionTests.ExternalFunc3.f;

end FunctionTests.ExternalFunc3;
")})));
end ExternalFunc3;


model ExternalFunc4
 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
 external q = foo(size(x,1), 2, x, z, y);
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc4",
            description="External functions: complex func, call and return set",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExternalFunc4
 Real x = FunctionTests.ExternalFunc4.f({{1, 2}, {3, 4}}, 5);

public
 function FunctionTests.ExternalFunc4.f
  input Real[:,:] x;
  input Real y;
  output Real z;
  output Real q;
 algorithm
  assert(2 == size(x, 2), \"Mismatching sizes in function 'FunctionTests.ExternalFunc4.f', component 'x', dimension '2'\");
  external \"C\" q = foo(size(x, 1), 2, x, z, y);
  return;
 end FunctionTests.ExternalFunc4.f;

end FunctionTests.ExternalFunc4;
")})));
end ExternalFunc4;


model ExternalFunc5
 function f
  input Real x;
  output Real y;
 external "C";
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc5",
            description="External functions: simple func, language \"C\"",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExternalFunc5
 Real x = FunctionTests.ExternalFunc5.f(2);

public
 function FunctionTests.ExternalFunc5.f
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end FunctionTests.ExternalFunc5.f;

end FunctionTests.ExternalFunc5;
")})));
end ExternalFunc5;


model ExternalFunc6
 function f
  input Real x;
  output Real y;
 external "FORTRAN 77";
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc6",
            description="External functions: simple func, language \"FORTRAN 77\"",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExternalFunc6
 Real x = FunctionTests.ExternalFunc6.f(2);

public
 function FunctionTests.ExternalFunc6.f
  input Real x;
  output Real y;
 algorithm
  external \"FORTRAN 77\" y = f(x);
  return;
 end FunctionTests.ExternalFunc6.f;

end FunctionTests.ExternalFunc6;
")})));
end ExternalFunc6;


model ExternalFunc7
 function f
  input Real x;
  output Real y;
 external "C++";
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExternalFunc7",
            description="External functions: simple func, language \"C++\"",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 2, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  The external language specification \"C++\" is not supported

Error at line 5, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  The external language specification \"C++\" is not supported
")})));
end ExternalFunc7;



model ExternalFuncLibs1
 function f1
  input Real x;
  output Real y;
 external annotation(Library="foo");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="bar");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Library={"bar", "m"});
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs1",
            description="External function annotations, Library",
            variability_propagation=false,
            methodName="externalLibraries",
            methodResult="[foo, bar, m]"
 )})));
end ExternalFuncLibs1;


model ExternalFuncLibs2
 function f1
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"");
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs2",
            description="External function annotations, Include",
            variability_propagation=false,
            methodName="externalIncludes",
            methodResult="[#include \"foo.h\", #include \"bar.h\"]"
 )})));
end ExternalFuncLibs2;


model ExternalFuncLibs3
 function f1
  input Real x;
  output Real y;
 external annotation(LibraryDirectory="file:///c:/foo/lib");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external;
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Library="bar", 
                     LibraryDirectory="file:///c:/bar/lib");
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs3",
            description="External function annotations, LibraryDirectory",
            variability_propagation=false,
            methodName="externalLibraryDirectories",
            methodResult="[/c:/foo/lib, /c:/bar/lib]"
 )})));
end ExternalFuncLibs3;


model ExternalFuncLibs4
 function f1
  input Real x;
  output Real y;
 external annotation(Library="foo");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="bar");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs4",
            description="External function annotations, LibraryDirectory",
            variability_propagation=false,
            methodName="externalLibraryDirectories",
            filter=true,
            methodResult="
[%dir%/Resources/Library]"
 )})));
end ExternalFuncLibs4;


model ExternalFuncLibs5
 function f1
  input Real x;
  output Real y;
 external annotation(IncludeDirectory="file:///c:/foo/inc");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"", 
                     IncludeDirectory="file:///c:/bar/inc");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs5",
            description="External function annotations, IncludeDirectory",
            variability_propagation=false,
            methodName="externalIncludeDirectories",
            filter=true,
            methodResult="[/c:/foo/inc, /c:/bar/inc]"
 )})));
end ExternalFuncLibs5;


model ExternalFuncLibs6
 function f1
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs6",
            description="External function annotations, IncludeDirectory",
            variability_propagation=false,
            methodName="externalIncludeDirectories",
            filter=true,
            methodResult="
[%dir%/Resources/Include]"
 )})));
end ExternalFuncLibs6;


model ExternalFuncLibs7
 function f1
  input Real x;
  output Real y;
 external annotation(LibraryDirectory="file:///c:/std/lib", 
                     IncludeDirectory="file:///c:/std/inc");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="foo",
                     LibraryDirectory="file:///c:/foo/lib",  
                     Include="#include \"foo.h\"", 
                     IncludeDirectory="file:///c:/foo/inc");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"", 
                     IncludeDirectory="file:///c:/bar/inc", 
                     Library="bar", 
                     LibraryDirectory="file:///c:/bar/lib");
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs7",
            description="External function annotations, compiler args",
            variability_propagation=false,
            methodName="externalCompilerArgs",
            methodResult=" -lfoo -lbar -L/c:/std/lib -L/c:/foo/lib -L/c:/bar/lib -I/c:/std/inc -I/c:/foo/inc -I/c:/bar/inc"
 )})));
end ExternalFuncLibs7;


model ExternalFuncLibs8
 function f
  input Real x;
  output Real y;
 external annotation(Library="foo", 
                     Include="#include \"foo.h\"");
 end f;
 
 Real x = f(1);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs8",
            description="External function annotations, compiler args",
            variability_propagation=false,
            methodName="externalCompilerArgs",
            filter=true,
            methodResult=" -lfoo -L%dir%/Resources/Library -I%dir%/Resources/Include"
 )})));
end ExternalFuncLibs8;



model ExtendFunc1
    function f1
        input Real a;
        output Real b;
    end f1;
    
    function f2
        extends f1;
    algorithm
        b := a;
    end f2;
    
    Real x = f2(1.0);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExtendFunc1",
            description="Flattening of function extending other function",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExtendFunc1
 Real x = FunctionTests.ExtendFunc1.f2(1.0);

public
 function FunctionTests.ExtendFunc1.f2
  input Real a;
  output Real b;
 algorithm
  b := a;
  return;
 end FunctionTests.ExtendFunc1.f2;

end FunctionTests.ExtendFunc1;
")})));
end ExtendFunc1;



model ExtendFunc2
	constant Real[2] d = { 1, 2 };
	
    function f1
        input Real a;
        output Real b;
    end f1;
    
    function f2
        extends f1;
		input Integer c = 2;
	protected
		Real f = a + d[c];
    algorithm
        b := f;
    end f2;

    Real x = f2(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExtendFunc2",
            description="Order of variables in functions when inheriting and adding constants",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ExtendFunc2
 constant Real d[2] = {1, 2};
 Real x = FunctionTests.ExtendFunc2.f2(1, 2);
global variables
 constant Real FunctionTests.ExtendFunc2.d[2] = {1, 2};

public
 function FunctionTests.ExtendFunc2.f2
  input Real a;
  output Real b;
  input Integer c;
  Real f;
 algorithm
  f := a + global(FunctionTests.ExtendFunc2.d[c]);
  b := f;
  return;
 end FunctionTests.ExtendFunc2.f2;

end FunctionTests.ExtendFunc2;
")})));
end ExtendFunc2;



model AttributeTemp1
	function f
		output Real o[2] = {1, 2};
	algorithm
	end f;
	
	Real x[2](start = f()) = {3, 4};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AttributeTemp1",
            description="Temporary variable for attribute",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.AttributeTemp1
 Real x[1](start = temp_1[1]);
 Real x[2](start = temp_1[2]);
 parameter Real temp_1[1];
 parameter Real temp_1[2];
parameter equation
 ({temp_1[1], temp_1[2]}) = FunctionTests.AttributeTemp1.f();
equation
 x[1] = 3;
 x[2] = 4;

public
 function FunctionTests.AttributeTemp1.f
  output Real[:] o;
  Integer[:] temp_1;
 algorithm
  init o as Real[2];
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  for i1 in 1:2 loop
   o[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.AttributeTemp1.f;

end FunctionTests.AttributeTemp1;
")})));
end AttributeTemp1;



model InputAsArraySize1
	function f
		input Integer n;
		output Real x[n];
	algorithm
		x := 1:size(x,1);
	end f;
	
	Real x[3] = f(3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InputAsArraySize1",
            description="Input as array size of output in function: basic test",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.InputAsArraySize1
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = FunctionTests.InputAsArraySize1.f(3);

public
 function FunctionTests.InputAsArraySize1.f
  input Integer n;
  output Real[:] x;
 algorithm
  init x as Real[n];
  for i1 in 1:n loop
   x[i1] := i1;
  end for;
  return;
 end FunctionTests.InputAsArraySize1.f;

end FunctionTests.InputAsArraySize1;
")})));
end InputAsArraySize1;


model InputAsArraySize2
	function f
		input Integer n;
		output Real x[n];
	algorithm
		x := 1:size(x,1);
	end f;
	
	parameter Integer n = 3;
	Real x[3] = f(n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InputAsArraySize2",
            description="Input as array size of output in function: basic test",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.InputAsArraySize2
 structural parameter Integer n = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = FunctionTests.InputAsArraySize2.f(3);

public
 function FunctionTests.InputAsArraySize2.f
  input Integer n;
  output Real[:] x;
 algorithm
  init x as Real[n];
  for i1 in 1:n loop
   x[i1] := i1;
  end for;
  return;
 end FunctionTests.InputAsArraySize2.f;

end FunctionTests.InputAsArraySize2;
")})));
end InputAsArraySize2;


model InputAsArraySize3
	function f
		input Integer n;
		output Real x[n];
	algorithm
		x := 1:size(x,1);
	end f;
	
	parameter Integer n = 3;
	Real x[n] = f(n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InputAsArraySize3",
            description="Input as array size of output in function: basic test",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.InputAsArraySize3
 structural parameter Integer n = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = FunctionTests.InputAsArraySize3.f(3);

public
 function FunctionTests.InputAsArraySize3.f
  input Integer n;
  output Real[:] x;
 algorithm
  init x as Real[n];
  for i1 in 1:n loop
   x[i1] := i1;
  end for;
  return;
 end FunctionTests.InputAsArraySize3.f;

end FunctionTests.InputAsArraySize3;
")})));
end InputAsArraySize3;


model InputAsArraySize4
	function f
		input Integer n;
		output Real x[n];
	algorithm
		x := 1:size(x,1);
	end f;
	
	Real x[3] = f(size(x,1));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InputAsArraySize4",
            description="Input as array size of output in function: test using size()",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.InputAsArraySize4
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = FunctionTests.InputAsArraySize4.f(3);

public
 function FunctionTests.InputAsArraySize4.f
  input Integer n;
  output Real[:] x;
 algorithm
  init x as Real[n];
  for i1 in 1:n loop
   x[i1] := i1;
  end for;
  return;
 end FunctionTests.InputAsArraySize4.f;

end FunctionTests.InputAsArraySize4;
")})));
end InputAsArraySize4;


model InputAsArraySize5
	function f
		input Integer n;
		output Real x[n];
	algorithm
		x := 1:size(x,1);
	end f;
	
	Integer n = 3;
	Real x[3] = f(n);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InputAsArraySize5",
            description="Input as array size of output in function: variable passed",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 10, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [3] and size of binding expression is [n]

Error at line 10, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_OUTPUT:
  Could not evaluate array size of output x
")})));
end InputAsArraySize5;


model InputAsArraySize6
	function f
		input Integer n;
		output Real x[n];
	algorithm
		x := 1:size(x,1);
	end f;
	
	Real x[3] = f(4);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InputAsArraySize6",
            description="Input as array size of output in function: wrong value passed",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 9, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [3] and size of binding expression is [4]
")})));
end InputAsArraySize6;


model InputAsArraySize7
	function f
		input Integer n;
		input Real y[n];
		output Real x;
	algorithm
		x := sum(y[1:n]);
	end f;
	
	Real x = f(3, {1, 2, 3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InputAsArraySize7",
            description="Input as array size of other input in function: basic test",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.InputAsArraySize7
 Real x;
equation
 x = FunctionTests.InputAsArraySize7.f(3, {1, 2, 3});

public
 function FunctionTests.InputAsArraySize7.f
  input Integer n;
  input Real[:] y;
  output Real x;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:max(n, 0) loop
   temp_1 := temp_1 + y[i1];
  end for;
  x := temp_1;
  return;
 end FunctionTests.InputAsArraySize7.f;

end FunctionTests.InputAsArraySize7;
")})));
end InputAsArraySize7;

model InputAsArraySize9
	function f
		input Integer n;
		input Real y[n];
		output Real x;
	algorithm
		x := sum(y);
	end f;
	
	Real x = f(3, {1, 2, 3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InputAsArraySize9",
            description="Input as array size of other input in function: basic test",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.InputAsArraySize9
 Real x;
equation
 x = FunctionTests.InputAsArraySize9.f(3, {1, 2, 3});

public
 function FunctionTests.InputAsArraySize9.f
  input Integer n;
  input Real[:] y;
  output Real x;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(y, 1) loop
   temp_1 := temp_1 + y[i1];
  end for;
  x := temp_1;
  return;
 end FunctionTests.InputAsArraySize9.f;

end FunctionTests.InputAsArraySize9;
")})));
end InputAsArraySize9;

model InputAsArraySize11
    function f1
        input Integer n;
        output Real y[f2(n)];
    algorithm
        y := 1:f2(n);
    end f1;
    
    function f2
        input Integer m;
        output Integer k;
    algorithm
        k := div(m, 2) + 1;
    end f2;
    
    Real[3] x = f1(5);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InputAsArraySize11",
            description="Declared size of function output that depends on value of other function call",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.InputAsArraySize11
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
end FunctionTests.InputAsArraySize11;
")})));
end InputAsArraySize11;


model InputAsArraySize12
    parameter Integer p = 3;
    Real x = sum(1:p);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InputAsArraySize12",
            description="Parameters that decide size of array expression should be structural",
            flatModel="
fclass FunctionTests.InputAsArraySize12
 structural parameter Integer p = 3 /* 3 */;
 Real x = sum(1:3);
end FunctionTests.InputAsArraySize12;
")})));
end InputAsArraySize12;


model InputAsArraySize13
    function f
        input Integer n;
        output Real y[n];
    algorithm
        y := 1:n;
    end f;
    
    parameter Integer p = 3;
    Real x = sum(f(p));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InputAsArraySize13",
            description="Parameters that decide size of array expression should be structural",
            flatModel="
fclass FunctionTests.InputAsArraySize13
 structural parameter Integer p = 3 /* 3 */;
 Real x = sum(FunctionTests.InputAsArraySize13.f(3));

public
 function FunctionTests.InputAsArraySize13.f
  input Integer n;
  output Real[:] y;
 algorithm
  init y as Real[n];
  y[:] := 1:n;
  return;
 end FunctionTests.InputAsArraySize13.f;

end FunctionTests.InputAsArraySize13;
")})));
end InputAsArraySize13;


model InputAsArraySize14
    function f
        input Integer n;
        input Integer m;
        output Real y[n];
        output Real z[m];
    algorithm
        y := 1:n;
        y := 1:m;
    end f;
    
    parameter Integer p1 = 2;
    parameter Integer p2 = 3;
    Real x[2];
    Real y[3];
equation
    (x, y) = f(p1, p2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InputAsArraySize14",
            description="Parameters that decide size of array expression should be structural",
            flatModel="
fclass FunctionTests.InputAsArraySize14
 structural parameter Integer p1 = 2 /* 2 */;
 structural parameter Integer p2 = 3 /* 3 */;
 Real x[2];
 Real y[3];
equation
 (x[1:2], y[1:3]) = FunctionTests.InputAsArraySize14.f(2, 3);

public
 function FunctionTests.InputAsArraySize14.f
  input Integer n;
  input Integer m;
  output Real[:] y;
  output Real[:] z;
 algorithm
  init y as Real[n];
  init z as Real[m];
  y[:] := 1:n;
  y[:] := 1:m;
  return;
 end FunctionTests.InputAsArraySize14.f;

end FunctionTests.InputAsArraySize14;
")})));
end InputAsArraySize14;


model InputAsArraySize15
    function f
        input Integer n;
        input Integer m;
        output Real y[n];
        output Real z[m];
    algorithm
        y := 1:n;
        y := 1:m;
    end f;
    
    parameter Integer p1 = 2;
    parameter Integer p2 = 3;
    Real x = sum(f(p1, p2));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InputAsArraySize15",
            description="Parameters that decide size of array expression should be structural",
            flatModel="
fclass FunctionTests.InputAsArraySize15
 structural parameter Integer p1 = 2 /* 2 */;
 parameter Integer p2 = 3 /* 3 */;
 Real x = sum(FunctionTests.InputAsArraySize15.f(2, p2));

public
 function FunctionTests.InputAsArraySize15.f
  input Integer n;
  input Integer m;
  output Real[:] y;
  output Real[:] z;
 algorithm
  init y as Real[n];
  init z as Real[m];
  y[:] := 1:n;
  y[:] := 1:m;
  return;
 end FunctionTests.InputAsArraySize15.f;

end FunctionTests.InputAsArraySize15;
")})));
end InputAsArraySize15;


model InputAsArraySize16
    function f
        input Integer a;
        output Real[2,a] y = {1:a,3:a+2};
        algorithm
    end f;
    function w
        input Integer b;
        R[2] r(n=b,x=f(b));
        output Real[2] y = r.y;
        algorithm
    end w;
    record R
        parameter Integer n = 1;
        Real[n] x;
        Real y = x[1];
    end R;
    parameter Integer m = 2;
    Real[2] r = w(m);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InputAsArraySize16",
            description="Parametrized size in FSubscriptedExp over array of records",
            flatModel="
fclass FunctionTests.InputAsArraySize16
 parameter Integer m = 2 /* 2 */;
 Real r[2] = FunctionTests.InputAsArraySize16.w(m);

public
 function FunctionTests.InputAsArraySize16.w
  input Integer b;
  FunctionTests.InputAsArraySize16.R[:] r;
  output Real[:] y;
 algorithm
  init r as FunctionTests.InputAsArraySize16.R[2];
  r[1].n := b;
  r[1].x := (FunctionTests.InputAsArraySize16.f(b))[1,:];
  r[1].y := r[1].x[1];
  r[2].n := b;
  r[2].x := (FunctionTests.InputAsArraySize16.f(b))[2,:];
  r[2].y := r[2].x[1];
  init y as Real[2];
  y := r[1:2].y;
  return;
 end FunctionTests.InputAsArraySize16.w;

 function FunctionTests.InputAsArraySize16.f
  input Integer a;
  output Real[:,:] y;
 algorithm
  init y as Real[2, a];
  y := {1:a, 3:a + 2};
  return;
 end FunctionTests.InputAsArraySize16.f;

 record FunctionTests.InputAsArraySize16.R
  parameter Integer n;
  Real x[n];
  Real y;
 end FunctionTests.InputAsArraySize16.R;

end FunctionTests.InputAsArraySize16;
")})));
end InputAsArraySize16;


model InputAsArraySize17
    function f
        input Integer a;
        output Real[2,a] y = {1:a,3:a+2};
        algorithm
    end f;
    model M
        parameter Integer n = 1;
        Real[n] x;
        Real y = x[1];
    end R;
    parameter Integer k = 2;
    M[2] m(n=k,x=f(k));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InputAsArraySize17",
            description="Parametrized size in FSubscriptedExp over array of records",
            flatModel="
fclass FunctionTests.InputAsArraySize17
 structural parameter Integer k = 2 /* 2 */;
 structural parameter Integer m[1].n = 2 /* 2 */;
 Real m[1].x[2] = (FunctionTests.InputAsArraySize17.f(2))[1,1:2];
 Real m[1].y = m[1].x[1];
 structural parameter Integer m[2].n = 2 /* 2 */;
 Real m[2].x[2] = (FunctionTests.InputAsArraySize17.f(2))[2,1:2];
 Real m[2].y = m[2].x[1];

public
 function FunctionTests.InputAsArraySize17.f
  input Integer a;
  output Real[:,:] y;
 algorithm
  init y as Real[2, a];
  y := {1:a, 3:a + 2};
  return;
 end FunctionTests.InputAsArraySize17.f;

end FunctionTests.InputAsArraySize17;
")})));
end InputAsArraySize17;

model FuncColonSubscript
        // We generate multiple init/calculations for a single temp here.
        // The second one is redundant and will probably be removed
        // once we fix the type representation for function calls.
        
        function g
            input Real[:] x;
            output Integer y = integer(sum(x));
        algorithm
        end g;
    
        function f
            input Real[:] x;
            output Real[g(x)] y;
        algorithm
            y := zeros(size(y,1));
        end f;
        
        function h
            input Real[:,:] x;
            Real[1] t;
            output Real y;
        algorithm
            t := f(x[:,1]);
            y := sum(t);
        end h;
        
        Real y = h({{1}});

annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="FuncColonSubscript",
        description="tests scalarization, covers #5675",
        variability_propagation=false,
        flatModel="
fclass FunctionTests.FuncColonSubscript
 Real y;
equation
 y = FunctionTests.FuncColonSubscript.h({{1}});

public
 function FunctionTests.FuncColonSubscript.h
  input Real[:,:] x;
  Real[:] t;
  output Real y;
  Real[:] temp_1;
  Real[:] temp_2;
  Real[:] temp_3;
  Real temp_4;
 algorithm
  init t as Real[1];
  init temp_1 as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   temp_1[i1] := x[i1,1];
  end for;
  assert(FunctionTests.FuncColonSubscript.g(temp_1) == 1, \"Mismatching sizes in FunctionTests.FuncColonSubscript.h\");
  init temp_2 as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   temp_2[i1] := x[i1,1];
  end for;
  init temp_3 as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   temp_3[i1] := x[i1,1];
  end for;
  (t) := FunctionTests.FuncColonSubscript.f(temp_2);
  temp_4 := 0.0;
  for i1 in 1:1 loop
   temp_4 := temp_4 + t[i1];
  end for;
  y := temp_4;
  return;
 end FunctionTests.FuncColonSubscript.h;

 function FunctionTests.FuncColonSubscript.f
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[FunctionTests.FuncColonSubscript.g(x)];
  for i1 in 1:FunctionTests.FuncColonSubscript.g(x) loop
   y[i1] := 0;
  end for;
  return;
 end FunctionTests.FuncColonSubscript.f;

 function FunctionTests.FuncColonSubscript.g
  input Real[:] x;
  output Integer y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(x, 1) loop
   temp_1 := temp_1 + x[i1];
  end for;
  y := integer(temp_1);
  return;
 end FunctionTests.FuncColonSubscript.g;

end FunctionTests.FuncColonSubscript;
")})));
end FuncColonSubscript;

model Lapack_dgeqpf
  Real A[2,2] = {{1,2},{3,4}};
  Real QR[2,2];
  Real tau[2];
equation 
  (QR,tau,) = Modelica.Math.Matrices.LAPACK.dgeqpf(A);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Lapack_dgeqpf",
            description="Test scalarization of LAPACK function that has had some issues",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.Lapack_dgeqpf
 Real A[1,1];
 Real A[1,2];
 Real A[2,1];
 Real A[2,2];
 Real QR[1,1];
 Real QR[1,2];
 Real QR[2,1];
 Real QR[2,2];
 Real tau[1];
 Real tau[2];
equation
 ({{QR[1,1], QR[1,2]}, {QR[2,1], QR[2,2]}}, {tau[1], tau[2]}, ) = Modelica.Math.Matrices.LAPACK.dgeqpf({{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 A[1,1] = 1;
 A[1,2] = 2;
 A[2,1] = 3;
 A[2,2] = 4;

public
 function Modelica.Math.Matrices.LAPACK.dgeqpf
  input Real[:,:] A;
  output Real[:,:] QR;
  output Real[:] tau;
  output Integer[:] p;
  output Integer info;
  Integer lda;
  Integer ncol;
  Real[:] work;
 algorithm
  init QR as Real[size(A, 1), size(A, 2)];
  for i1 in 1:size(A, 1) loop
   for i2 in 1:size(A, 2) loop
    QR[i1,i2] := A[i1,i2];
   end for;
  end for;
  init tau as Real[min(size(A, 1), size(A, 2))];
  init p as Integer[size(A, 2)];
  for i1 in 1:size(A, 2) loop
   p[i1] := 0;
  end for;
  lda := max(1, size(A, 1));
  ncol := size(A, 2);
  init work as Real[3 * size(A, 2)];
  external \"FORTRAN 77\" dgeqpf(size(A, 1), ncol, QR, lda, p, tau, work, info);
  return;
 end Modelica.Math.Matrices.LAPACK.dgeqpf;

end FunctionTests.Lapack_dgeqpf;
")})));
end Lapack_dgeqpf;

model Lapack_QR
 Real A[2,2] = {{5,6},{7,8}};
 Real Q[2,2];
 Real R[2,2];
 //Integer piv[2];
equation 
 (Q,R,) = Modelica.Math.Matrices.QR(A);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Lapack_QR",
            description="",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.Lapack_QR
 Real A[1,1];
 Real A[1,2];
 Real A[2,1];
 Real A[2,2];
 Real Q[1,1];
 Real Q[1,2];
 Real Q[2,1];
 Real Q[2,2];
 Real R[1,1];
 Real R[1,2];
 Real R[2,1];
 Real R[2,2];
equation
 ({{Q[1,1], Q[1,2]}, {Q[2,1], Q[2,2]}}, {{R[1,1], R[1,2]}, {R[2,1], R[2,2]}}, ) = Modelica.Math.Matrices.QR({{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, true);
 A[1,1] = 5;
 A[1,2] = 6;
 A[2,1] = 7;
 A[2,2] = 8;

public
 function Modelica.Math.Matrices.QR
  input Real[:,:] A;
  input Boolean pivoting;
  output Real[:,:] Q;
  output Real[:,:] R;
  output Integer[:] p;
  Integer nrow;
  Integer ncol;
  Real[:] tau;
 algorithm
  init Q as Real[size(A, 1), size(A, 2)];
  init R as Real[size(A, 2), size(A, 2)];
  init p as Integer[size(A, 2)];
  nrow := size(A, 1);
  ncol := size(A, 2);
  init tau as Real[size(A, 2)];
  assert(nrow >= ncol, \"\\nInput matrix A[\" + String(nrow) + \",\" + String(ncol) + \"] has more columns as rows.
This is not allowed when calling Modelica.Matrices.QR(A).\");
  if pivoting then
   (Q, tau, p) := Modelica.Math.Matrices.LAPACK.dgeqpf(A);
  else
   (Q, tau) := Modelica.Math.Matrices.LAPACK.dgeqrf(A);
   for i1 in 1:size(A, 2) loop
    p[i1] := i1;
   end for;
  end if;
  for i1 in 1:size(A, 2) loop
   for i2 in 1:size(A, 2) loop
    R[i1,i2] := 0;
   end for;
  end for;
  for i in 1:ncol loop
   for j in i:ncol loop
    R[i,j] := Q[i,j];
   end for;
  end for;
  (Q) := Modelica.Math.Matrices.LAPACK.dorgqr(Q, tau);
  return;
 end Modelica.Math.Matrices.QR;

 function Modelica.Math.Matrices.LAPACK.dgeqpf
  input Real[:,:] A;
  output Real[:,:] QR;
  output Real[:] tau;
  output Integer[:] p;
  output Integer info;
  Integer lda;
  Integer ncol;
  Real[:] work;
 algorithm
  init QR as Real[size(A, 1), size(A, 2)];
  for i1 in 1:size(A, 1) loop
   for i2 in 1:size(A, 2) loop
    QR[i1,i2] := A[i1,i2];
   end for;
  end for;
  init tau as Real[min(size(A, 1), size(A, 2))];
  init p as Integer[size(A, 2)];
  for i1 in 1:size(A, 2) loop
   p[i1] := 0;
  end for;
  lda := max(1, size(A, 1));
  ncol := size(A, 2);
  init work as Real[3 * size(A, 2)];
  external \"FORTRAN 77\" dgeqpf(size(A, 1), ncol, QR, lda, p, tau, work, info);
  return;
 end Modelica.Math.Matrices.LAPACK.dgeqpf;

 function Modelica.Math.Matrices.LAPACK.dgeqrf
  input Real[:,:] A;
  output Real[:,:] Aout;
  output Real[:] tau;
  output Integer info;
  output Real[:] work;
  Integer m;
  Integer n;
  Integer lda;
  Integer lwork;
 algorithm
  init Aout as Real[size(A, 1), size(A, 2)];
  for i1 in 1:size(A, 1) loop
   for i2 in 1:size(A, 2) loop
    Aout[i1,i2] := A[i1,i2];
   end for;
  end for;
  init tau as Real[min(size(A, 1), size(A, 2))];
  init work as Real[3 * max(1, size(A, 2))];
  m := size(A, 1);
  n := size(A, 2);
  lda := max(1, m);
  lwork := 3 * max(1, n);
  external \"FORTRAN 77\" dgeqrf(m, n, Aout, lda, tau, work, lwork, info);
  return;
 end Modelica.Math.Matrices.LAPACK.dgeqrf;

 function Modelica.Math.Matrices.LAPACK.dorgqr
  input Real[:,:] QR;
  input Real[:] tau;
  output Real[:,:] Q;
  output Integer info;
  Integer lda;
  Integer lwork;
  Real[:] work;
 algorithm
  init Q as Real[size(QR, 1), size(QR, 2)];
  for i1 in 1:size(QR, 1) loop
   for i2 in 1:size(QR, 2) loop
    Q[i1,i2] := QR[i1,i2];
   end for;
  end for;
  lda := max(1, size(Q, 1));
  lwork := max(1, min(10, size(QR, 2)) * size(QR, 2));
  init work as Real[max(1, min(10, size(QR, 2)) * size(QR, 2))];
  external \"FORTRAN 77\" dorgqr(size(QR, 1), size(QR, 2), size(tau, 1), Q, lda, tau, work, lwork, info);
  return;
 end Modelica.Math.Matrices.LAPACK.dorgqr;

end FunctionTests.Lapack_QR;
")})));
end Lapack_QR;

model BindingSort1
	function f
		input Real x;
		output Real y = a + 1;
	protected
        Real a = b + e;
	    Real b = c + d;
	    Real c = x + d;
	    Real d = e + 1;
	    Real e = x + 1;
	algorithm
		y := y + x;
	end f;
	
	Real x = f(y);
	Real y = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="BindingSort1",
            description="Test sorting of binding expressions",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.BindingSort1
 Real x;
 Real y;
equation
 x = FunctionTests.BindingSort1.f(y);
 y = 1;

public
 function FunctionTests.BindingSort1.f
  input Real x;
  output Real y;
  Real a;
  Real b;
  Real c;
  Real d;
  Real e;
 algorithm
  e := x + 1;
  d := e + 1;
  c := x + d;
  b := c + d;
  a := b + e;
  y := a + 1;
  y := y + x;
  return;
 end FunctionTests.BindingSort1.f;

end FunctionTests.BindingSort1;
")})));
end BindingSort1;

model UseInterpolate

model Interpolate
    function interp
        input Real u;
        output Real value;
    algorithm
       value := u*2;
       annotation(derivative=Interpolate.interpDer);
    end interp;

    function interpDer
        input Real u;
        output Real value;
    algorithm
        value := u*3;
    end interpDer;
end Interpolate;
	
 Real result;
 Real i = 1.0;
equation
	 result = Interpolate.interp(i);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UseInterpolate",
            description="",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UseInterpolate
 Real result;
 Real i;
equation
 result = FunctionTests.UseInterpolate.Interpolate.interp(i);
 i = 1.0;

public
 function FunctionTests.UseInterpolate.Interpolate.interp
  input Real u;
  output Real value;
 algorithm
  value := u * 2;
  return;
 annotation(derivative = FunctionTests.UseInterpolate.Interpolate.interpDer);
 end FunctionTests.UseInterpolate.Interpolate.interp;

end FunctionTests.UseInterpolate;
")})));
end UseInterpolate;

model ComponentFunc1
    model A
        partial function f
            input Real x;
            output Real y;
        end f;
        
        Real z(start = 2);
    equation
        der(z) = -z;
    end A;
    
    model B
        extends A;
        redeclare function extends f
        algorithm
            y := 2 * x;
        end f;
    end B;
    
    model C
        extends A;
        redeclare function extends f
        algorithm
            y := x * x;
        end f;
    end C;
    
    B b1;
    C c1;
    Real w = b1.f(v) + c1.f(v);
    Real v = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ComponentFunc1",
            description="Calling functions in components",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.ComponentFunc1
 Real b1.z(start = 2);
 Real c1.z(start = 2);
 Real w;
 Real v;
initial equation 
 b1.z = 2;
 c1.z = 2;
equation
 der(b1.z) = - b1.z;
 der(c1.z) = - c1.z;
 w = FunctionTests.ComponentFunc1.b1.f(v) + FunctionTests.ComponentFunc1.c1.f(v);
 v = 3;

public
 function FunctionTests.ComponentFunc1.b1.f
  input Real x;
  output Real y;
 algorithm
  y := 2 * x;
  return;
 end FunctionTests.ComponentFunc1.b1.f;

 function FunctionTests.ComponentFunc1.c1.f
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  return;
 end FunctionTests.ComponentFunc1.c1.f;

end FunctionTests.ComponentFunc1;
")})));
end ComponentFunc1;


model ComponentFunc2
    model A
        partial function f
            input Real x;
            output Real y;
        end f;
        
        Real z(start = 2);
    equation
        der(z) = -z;
    end A;
    
    model B
        extends A;
        redeclare function extends f
        algorithm
            y := 2 * x;
        end f;
    end B;
    
    model C
        extends A;
        redeclare function extends f
        algorithm
            y := x * x;
        end f;
    end C;
    
	model D
		outer A a;
	    Real v = 3;
		Real w = a.f(v);
	end D;
	
	model E
		replaceable model F = A;
		inner F a;
		D d;
	end E;
	
    E eb(redeclare model F = B);
    E ec(redeclare model F = C);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ComponentFunc2",
            description="Calling functions in inner/outer components",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.ComponentFunc2
 Real eb.a.z(start = 2);
 Real eb.d.v = 3;
 Real eb.d.w = FunctionTests.ComponentFunc2.eb.a.f(eb.d.v);
 Real ec.a.z(start = 2);
 Real ec.d.v = 3;
 Real ec.d.w = FunctionTests.ComponentFunc2.ec.a.f(ec.d.v);
equation
 der(eb.a.z) = - eb.a.z;
 der(ec.a.z) = - ec.a.z;

public
 function FunctionTests.ComponentFunc2.eb.a.f
  input Real x;
  output Real y;
 algorithm
  y := 2 * x;
  return;
 end FunctionTests.ComponentFunc2.eb.a.f;

 function FunctionTests.ComponentFunc2.ec.a.f
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  return;
 end FunctionTests.ComponentFunc2.ec.a.f;

end FunctionTests.ComponentFunc2;
")})));
end ComponentFunc2;


model ComponentFunc3
    model A
        function f = f2(a = 2);
        Real x = 1;
    end A;
    
    function f2
        input Real a;
        output Real b;
    algorithm
        b := a + 1;
        b := b + a;
    end f2;
    
    A a;
    Real y = a.f();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ComponentFunc3",
            description="Calling a function through a component",
            flatModel="
fclass FunctionTests.ComponentFunc3
 Real a.x = 1;
 Real y = FunctionTests.ComponentFunc3.a.f(2);

public
 function FunctionTests.ComponentFunc3.a.f
  input Real a;
  output Real b;
 algorithm
  b := a + 1;
  b := b + a;
  return;
 end FunctionTests.ComponentFunc3.a.f;

end FunctionTests.ComponentFunc3;
")})));
end ComponentFunc3;


model ComponentFunc4
    model A
        function f = f2(a = c);
        parameter Real c = 1;
    end A;
    
    function f2
        input Real a;
        output Real b;
    algorithm
        b := a + 1;
        b := b + a;
    end f2;
    
    A a(c = 2);
    Real y = a.f();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ComponentFunc4",
            description="Calling a function through a component",
            flatModel="
fclass FunctionTests.ComponentFunc4
 parameter Real a.c = 2 /* 2 */;
 Real y = FunctionTests.ComponentFunc4.a.f(a.c);

public
 function FunctionTests.ComponentFunc4.a.f
  input Real a;
  output Real b;
 algorithm
  b := a + 1;
  b := b + a;
  return;
 end FunctionTests.ComponentFunc4.a.f;

end FunctionTests.ComponentFunc4;
")})));
end ComponentFunc4;


model ComponentFunc5
    model A
        function f
            input Real x;
            output Real y;
        algorithm
            y := x * 2;
        end f;
        
        parameter Real y = 2;
    end A;
    
    model B
        A a;
    end B;
    
    B b;
    parameter Real z = b.a.f(b.a.y);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ComponentFunc5",
            description="Calling function through nested components",
            errorMessage="
1 errors found:

Error at line 18, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ACCESS_TO_FUNCTION_THROUGH_MULTIPLE_COMPONENTS:
  Can not access function through component unless only the first part of the name is a component: 'b.a.f'
")})));
end ComponentFunc5;


model ComponentFunc6
    model A
        function f
            input Real x;
            output Real y;
        algorithm
            y := x * 2;
        end f;
        
        parameter Real y = 2;
    end A;
    
    A a[2];
    parameter Real z = a[1].f(a[1].y);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ComponentFunc6",
            description="Calling function through array component",
            errorMessage="
1 errors found:

Error at line 14, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ACCESS_TO_FUNCTION_THROUGH_ARRAY_COMPONENT:
  Can not access function through array component access: 'a[1].f'
")})));
end ComponentFunc6;


model ComponentFunc7
    model A
        function f
            input Real x;
            output Real y;
        algorithm
            y := x * 2;
        end f;
        
        parameter Real y = 2;
    end A;
    
    A a[2];
    parameter Real z = a.f(a[1].y);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ComponentFunc7",
            description="Calling function through array component",
            errorMessage="
1 errors found:

Error at line 14, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', ACCESS_TO_FUNCTION_THROUGH_ARRAY_COMPONENT:
  Can not access function through array component access: 'a.f'
")})));
end ComponentFunc7;


model ComponentFunc8
    model A
        package B
            function f
                input Real x;
                output Real y;
            algorithm
                y := x * 2;
            end f;
        end B;
        
        parameter Real y = 2;
    end A;
    
    A a;
    parameter Real z = a.B.f(a.y);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ComponentFunc8",
            description="Calling function through component, then package",
            flatModel="
fclass FunctionTests.ComponentFunc8
 parameter Real a.y = 2 /* 2 */;
 parameter Real z = FunctionTests.ComponentFunc8.a.B.f(a.y);

public
 function FunctionTests.ComponentFunc8.a.B.f
  input Real x;
  output Real y;
 algorithm
  y := x * 2;
  return;
 end FunctionTests.ComponentFunc8.a.B.f;

end FunctionTests.ComponentFunc8;
")})));
end ComponentFunc8;

model MinOnInput1
    function F
        input Real x(min=0) = 3.14;
        output Real y;
    algorithm
        y := x * 42;
    end F;
	
    Real y = F();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="MinOnInput1",
            description="Test that default arguments are correctly identified with modification on input",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.MinOnInput1
 Real y = FunctionTests.MinOnInput1.F(3.14);

public
 function FunctionTests.MinOnInput1.F
  input Real x;
  output Real y;
 algorithm
  y := x * 42;
  return;
 end FunctionTests.MinOnInput1.F;

end FunctionTests.MinOnInput1;
")})));
end MinOnInput1;

package UnknownSize

package FuncCallInSize
    package P
        function f
            input Integer n;
            output Real[f2(n)] y = 1:n;
          algorithm
        end f;
        function f2
            input Integer n;
            output Integer y = n;
          algorithm
        end f2;
    end P;
    
    model FromOtherPackage
        Real[2] y1 = P.f(2);
        constant Integer m = 2;
        Real[:] y2 = P.f(m);
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_FuncCallInSize_FromOtherPackage",
            description="Scalarization of functions: Function call from other package in declaration size",
            variability_propagation=false,
            inline_functions="none",
            common_subexp_elim=false,
            flatModel="
fclass FunctionTests.UnknownSize.FuncCallInSize.FromOtherPackage
 Real y1[1];
 Real y1[2];
 constant Integer m = 2;
 Real y2[1];
 Real y2[2];
equation
 ({y1[1], y1[2]}) = FunctionTests.UnknownSize.FuncCallInSize.P.f(2);
 ({y2[1], y2[2]}) = FunctionTests.UnknownSize.FuncCallInSize.P.f(2);

public
 function FunctionTests.UnknownSize.FuncCallInSize.P.f
  input Integer n;
  output Real[:] y;
 algorithm
  init y as Real[FunctionTests.UnknownSize.FuncCallInSize.P.f2(n)];
  for i1 in 1:FunctionTests.UnknownSize.FuncCallInSize.P.f2(n) loop
   y[i1] := i1;
  end for;
  return;
 end FunctionTests.UnknownSize.FuncCallInSize.P.f;

 function FunctionTests.UnknownSize.FuncCallInSize.P.f2
  input Integer n;
  output Integer y;
 algorithm
  y := n;
  return;
 end FunctionTests.UnknownSize.FuncCallInSize.P.f2;

end FunctionTests.UnknownSize.FuncCallInSize.FromOtherPackage;
")})));
end FromOtherPackage;

    model WithTemporary
        function s
            input Real[:] x;
            output Integer[:] n = {size(x,1), size(x,1)};
        algorithm
        end s;
        function g
            input Real[:] x;
            output Real[s(x)*{2,3}] y = x;
        algorithm
        end g;
        function f
            input Real[:] x;
            output Real[2] y;
        algorithm
            y := g(x);
        end f;
        
        Real[:] y = f({time});
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_FuncCallInSize_WithTemporary",
            description="Scalarization of functions: Function call from other package in declaration size",
            variability_propagation=false,
            inline_functions="none",
            common_subexp_elim=false,
            flatModel="
fclass FunctionTests.UnknownSize.FuncCallInSize.WithTemporary
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.f({time});

public
 function FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.f
  input Real[:] x;
  output Real[:] y;
  Integer temp_1;
  Integer temp_2;
  Integer[:] temp_3;
  Integer[:] temp_4;
  Integer temp_5;
  Integer temp_6;
  Integer[:] temp_7;
  Integer[:] temp_8;
 algorithm
  init y as Real[2];
  init temp_3 as Integer[2];
  (temp_3) := FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.s(x);
  init temp_4 as Integer[2];
  temp_4[1] := 2;
  temp_4[2] := 3;
  temp_2 := 0;
  for i1 in 1:2 loop
   temp_2 := temp_2 + temp_3[i1] * temp_4[i1];
  end for;
  temp_1 := temp_2;
  assert(temp_1 == 2, \"Mismatching sizes in FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.f\");
  init temp_7 as Integer[2];
  (temp_7) := FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.s(x);
  init temp_8 as Integer[2];
  temp_8[1] := 2;
  temp_8[2] := 3;
  temp_6 := 0;
  for i1 in 1:2 loop
   temp_6 := temp_6 + temp_7[i1] * temp_8[i1];
  end for;
  temp_5 := temp_6;
  (y) := FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.g(x);
  return;
 end FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.f;

 function FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.g
  input Real[:] x;
  output Real[:] y;
  Integer temp_1;
  Integer temp_2;
  Integer[:] temp_3;
  Integer[:] temp_4;
 algorithm
  init temp_3 as Integer[2];
  (temp_3) := FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.s(x);
  init temp_4 as Integer[2];
  temp_4[1] := 2;
  temp_4[2] := 3;
  temp_2 := 0;
  for i1 in 1:2 loop
   temp_2 := temp_2 + temp_3[i1] * temp_4[i1];
  end for;
  temp_1 := temp_2;
  init y as Real[temp_1];
  for i1 in 1:temp_1 loop
   y[i1] := x[i1];
  end for;
  return;
 end FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.g;

 function FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.s
  input Real[:] x;
  output Integer[:] n;
  Integer[:] temp_1;
 algorithm
  init n as Integer[2];
  init temp_1 as Integer[2];
  temp_1[1] := size(x, 1);
  temp_1[2] := size(x, 1);
  for i1 in 1:2 loop
   n[i1] := temp_1[i1];
  end for;
  return;
 end FunctionTests.UnknownSize.FuncCallInSize.WithTemporary.s;

end FunctionTests.UnknownSize.FuncCallInSize.WithTemporary;
")})));
end WithTemporary;

end FuncCallInSize;

package Hidden

// Unknown sizes hidden by dimension converting expressions
model Mul1
    function f
      input Real a[2, :];
      input Real b[:, 2];
      output Real[2,2] c;
      algorithm
        c := 2*(a*b);
    end f;
    
    Real[2,2] y = f({{1,2},{3,4}},{{1,2},{3,4}});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Mul1",
            description="Scalarization of functions: hidden unknown size in multiplication",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Mul1
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
equation
 ({{y[1,1], y[1,2]}, {y[2,1], y[2,2]}}) = FunctionTests.UnknownSize.Hidden.Mul1.f({{1, 2}, {3, 4}}, {{1, 2}, {3, 4}});

public
 function FunctionTests.UnknownSize.Hidden.Mul1.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] c;
  Real[:,:] temp_1;
  Real temp_2;
 algorithm
  init c as Real[2, 2];
  init temp_1 as Real[2, 2];
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    temp_2 := 0.0;
    for i3 in 1:size(b, 1) loop
     temp_2 := temp_2 + a[i1,i3] * b[i3,i2];
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    c[i1,i2] := 2 * temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownSize.Hidden.Mul1.f;

end FunctionTests.UnknownSize.Hidden.Mul1;
")})));
end Mul1;

model Scalar1
    function f
      input Real a[:, :];
      output Real c;
      algorithm
        c := 2*scalar(a);
    end f;
    Real y = f({{1}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Scalar1",
            description="Scalarization of functions: hidden unknown size in scalar operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Scalar1
 Real y;
equation
 y = FunctionTests.UnknownSize.Hidden.Scalar1.f({{1}});

public
 function FunctionTests.UnknownSize.Hidden.Scalar1.f
  input Real[:,:] a;
  output Real c;
 algorithm
  assert(size(a, 1) == 1, \"Mismatching size in dimension 1 of expression scalar(a[:,:]) in function FunctionTests.UnknownSize.Hidden.Scalar1.f\");
  assert(size(a, 2) == 1, \"Mismatching size in dimension 2 of expression scalar(a[:,:]) in function FunctionTests.UnknownSize.Hidden.Scalar1.f\");
  c := 2 * a[1,1];
  return;
 end FunctionTests.UnknownSize.Hidden.Scalar1.f;

end FunctionTests.UnknownSize.Hidden.Scalar1;
")})));
end Scalar1;

model Vector1
    function f
      input Real a[2, :];
      output Real c[size(a,1)];
      algorithm
        c := 2*vector(a);
    end f;
    Real[2] y = f({{1},{1}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Vector1",
            description="Scalarization of functions: hidden unknown size in vector operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Vector1
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = FunctionTests.UnknownSize.Hidden.Vector1.f({{1}, {1}});

public
 function FunctionTests.UnknownSize.Hidden.Vector1.f
  input Real[:,:] a;
  output Real[:] c;
  Real[:] temp_1;
 algorithm
  init c as Real[2];
  assert(2 * size(a, 2) == 2, \"Mismatching sizes in FunctionTests.UnknownSize.Hidden.Vector1.f\");
  assert(2 * size(a, 2) <= 2 + size(a, 2) - 2 + 1, \"Mismatching size in expression vector(a[1:2,:]) in function FunctionTests.UnknownSize.Hidden.Vector1.f\");
  init temp_1 as Real[2 * size(a, 2)];
  for i1 in 1:2 loop
   for i2 in 1:size(a, 2) loop
    temp_1[(i1 - 1) * size(a, 2) + (i2 - 1) + 1] := a[i1,i2];
   end for;
  end for;
  for i1 in 1:2 loop
   c[i1] := 2 * temp_1[i1];
  end for;
  return;
 end FunctionTests.UnknownSize.Hidden.Vector1.f;

end FunctionTests.UnknownSize.Hidden.Vector1;
")})));
end Vector1;

model Matrix1
    function f
      input Real a[1, 1, :];
      output Real c[1,1];
      algorithm
        c := 2*matrix(a);
    end f;
    Real[1,1] y = f({{{1}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Matrix1",
            description="Scalarization of functions: hidden unknown size in matrix operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Matrix1
 Real y[1,1];
equation
 ({{y[1,1]}}) = FunctionTests.UnknownSize.Hidden.Matrix1.f({{{1}}});

public
 function FunctionTests.UnknownSize.Hidden.Matrix1.f
  input Real[:,:,:] a;
  output Real[:,:] c;
  Real[:,:] temp_1;
 algorithm
  init c as Real[1, 1];
  assert(size(a, 3) == 1, \"Mismatching size in dimension 3 of expression matrix(a[1:1,1:1,:]) in function FunctionTests.UnknownSize.Hidden.Matrix1.f\");
  init temp_1 as Real[1, 1];
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    for i3 in 1:size(a, 3) loop
     temp_1[i1,i2] := a[i1,i2,i3];
    end for;
   end for;
  end for;
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    c[i1,i2] := 2 * temp_1[i1,i2];
   end for;
  end for;
  return;
 end FunctionTests.UnknownSize.Hidden.Matrix1.f;

end FunctionTests.UnknownSize.Hidden.Matrix1;
")})));
end Matrix1;

model Sum1
    function f
      input Real a[:];
      output Real c;
      algorithm
        c := 2*sum(a);
    end f;
    Real y = f({1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Sum1",
            description="Scalarization of functions: hidden unknown size in sum operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Sum1
 Real y;
equation
 y = FunctionTests.UnknownSize.Hidden.Sum1.f({1});

public
 function FunctionTests.UnknownSize.Hidden.Sum1.f
  input Real[:] a;
  output Real c;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 + a[i1];
  end for;
  c := 2 * temp_1;
  return;
 end FunctionTests.UnknownSize.Hidden.Sum1.f;

end FunctionTests.UnknownSize.Hidden.Sum1;
")})));
end Sum1;

model Product1
    function f
      input Real a[:];
      output Real c;
      algorithm
        c := 2*product(a);
    end f;
    Real y = f({1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Product1",
            description="Scalarization of functions: hidden unknown size in product operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Product1
 Real y;
equation
 y = FunctionTests.UnknownSize.Hidden.Product1.f({1});

public
 function FunctionTests.UnknownSize.Hidden.Product1.f
  input Real[:] a;
  output Real c;
  Real temp_1;
 algorithm
  temp_1 := 1.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 * a[i1];
  end for;
  c := 2 * temp_1;
  return;
 end FunctionTests.UnknownSize.Hidden.Product1.f;

end FunctionTests.UnknownSize.Hidden.Product1;
")})));
end Product1;

model Min1
    function f
      input Real a[:];
      output Real c;
      algorithm
        c := 2*min(a);
    end f;
    Real y = f({1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Min1",
            description="Scalarization of functions: hidden unknown size in min operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Min1
 Real y;
equation
 y = FunctionTests.UnknownSize.Hidden.Min1.f({1});

public
 function FunctionTests.UnknownSize.Hidden.Min1.f
  input Real[:] a;
  output Real c;
  Real temp_1;
 algorithm
  temp_1 := 1.7976931348623157E308;
  for i1 in 1:size(a, 1) loop
   temp_1 := if temp_1 < a[i1] then temp_1 else a[i1];
  end for;
  c := 2 * temp_1;
  return;
 end FunctionTests.UnknownSize.Hidden.Min1.f;

end FunctionTests.UnknownSize.Hidden.Min1;
")})));
end Min1;

model Max1
    function f
      input Real a[:];
      output Real c;
      algorithm
        c := 2*max(a);
    end f;
    Real y = f({1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Max1",
            description="Scalarization of functions: hidden unknown size in max operator",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Max1
 Real y;
equation
 y = FunctionTests.UnknownSize.Hidden.Max1.f({1});

public
 function FunctionTests.UnknownSize.Hidden.Max1.f
  input Real[:] a;
  output Real c;
  Real temp_1;
 algorithm
  temp_1 := -1.7976931348623157E308;
  for i1 in 1:size(a, 1) loop
   temp_1 := if temp_1 > a[i1] then temp_1 else a[i1];
  end for;
  c := 2 * temp_1;
  return;
 end FunctionTests.UnknownSize.Hidden.Max1.f;

end FunctionTests.UnknownSize.Hidden.Max1;
")})));
end Max1;

model Combinations1
    function f
      input Real a[2, :];
      input Real b[2, :];
      output Real c;
      algorithm
        c := scalar(matrix(sum(2*(a*transpose(b)))));
    end f;
    
    Real y = f({{1,2},{3,4}},{{1,2},{3,4}});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Combinations1",
            description="Scalarization of functions: hidden unknown size in multiplication",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Combinations1
 Real y;
equation
 y = FunctionTests.UnknownSize.Hidden.Combinations1.f({{1, 2}, {3, 4}}, {{1, 2}, {3, 4}});

public
 function FunctionTests.UnknownSize.Hidden.Combinations1.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real c;
  Real[:,:] temp_1;
  Real temp_2;
  Real[:,:] temp_3;
  Real temp_4;
 algorithm
  init temp_1 as Real[1, 1];
  init temp_3 as Real[2, 2];
  for i3 in 1:2 loop
   for i4 in 1:2 loop
    temp_4 := 0.0;
    for i5 in 1:size(b, 2) loop
     temp_4 := temp_4 + a[i3,i5] * b[i4,i5];
    end for;
    temp_3[i3,i4] := temp_4;
   end for;
  end for;
  temp_2 := 0.0;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    temp_2 := temp_2 + 2 * temp_3[i1,i2];
   end for;
  end for;
  temp_1[1,1] := temp_2;
  c := temp_1[1,1];
  return;
 end FunctionTests.UnknownSize.Hidden.Combinations1.f;

end FunctionTests.UnknownSize.Hidden.Combinations1;
")})));
end Combinations1;

model Combinations3
    function f
      input Real a[2, :];
      input Real b[2, :];
      output Real[1,1] c;
      algorithm
        c := 2*transpose(matrix(scalar(sum(matrix(sum(2*(a*transpose(b))) * (a * transpose(b)))))));
    end f;
    
    Real[1,1] y = f({{1,2},{3,4}},{{1,2},{3,4}});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Hidden_Combinations3",
            description="Scalarization of functions: hidden unknown size in multiplication",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Hidden.Combinations3
 Real y[1,1];
equation
 ({{y[1,1]}}) = FunctionTests.UnknownSize.Hidden.Combinations3.f({{1, 2}, {3, 4}}, {{1, 2}, {3, 4}});

public
 function FunctionTests.UnknownSize.Hidden.Combinations3.f
  input Real[:,:] a;
  input Real[:,:] b;
  output Real[:,:] c;
  Real[:,:] temp_1;
  Real temp_2;
  Real[:,:] temp_3;
  Real temp_4;
  Real[:,:] temp_5;
  Real temp_6;
  Real[:,:] temp_7;
  Real temp_8;
 algorithm
  init c as Real[1, 1];
  init temp_1 as Real[1, 1];
  init temp_3 as Real[2, 2];
  init temp_5 as Real[2, 2];
  for i7 in 1:2 loop
   for i8 in 1:2 loop
    temp_6 := 0.0;
    for i9 in 1:size(b, 2) loop
     temp_6 := temp_6 + a[i7,i9] * b[i8,i9];
    end for;
    temp_5[i7,i8] := temp_6;
   end for;
  end for;
  temp_4 := 0.0;
  for i5 in 1:2 loop
   for i6 in 1:2 loop
    temp_4 := temp_4 + 2 * temp_5[i5,i6];
   end for;
  end for;
  init temp_7 as Real[2, 2];
  for i5 in 1:2 loop
   for i6 in 1:2 loop
    temp_8 := 0.0;
    for i7 in 1:size(b, 2) loop
     temp_8 := temp_8 + a[i5,i7] * b[i6,i7];
    end for;
    temp_7[i5,i6] := temp_8;
   end for;
  end for;
  for i3 in 1:2 loop
   for i4 in 1:2 loop
    temp_3[i3,i4] := temp_4 * temp_7[i3,i4];
   end for;
  end for;
  temp_2 := 0.0;
  for i1 in 1:2 loop
   for i2 in 1:2 loop
    temp_2 := temp_2 + temp_3[i1,i2];
   end for;
  end for;
  temp_1[1,1] := temp_2;
  for i1 in 1:1 loop
   for i2 in 1:1 loop
    c[i1,i2] := 2 * temp_1[i2,i1];
   end for;
  end for;
  return;
 end FunctionTests.UnknownSize.Hidden.Combinations3.f;

end FunctionTests.UnknownSize.Hidden.Combinations3;
")})));
end Combinations3;

end Hidden;

package Misc

model Misc1
    function f
      input Integer n;
      output Integer[sum(1:n)] b;
      algorithm
        for i in 1:n loop
            b[i] := i;
        end for;
    end f;
    
    Real[6] y = f(3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Misc_Misc1",
            description="Scalarization of functions: size described with reduction expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Misc.Misc1
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
 Real y[5];
 Real y[6];
equation
 ({y[1], y[2], y[3], y[4], y[5], y[6]}) = FunctionTests.UnknownSize.Misc.Misc1.f(3);

public
 function FunctionTests.UnknownSize.Misc.Misc1.f
  input Integer n;
  output Integer[:] b;
  Integer temp_1;
 algorithm
  temp_1 := 0;
  for i1 in 1:max(n, 0) loop
   temp_1 := temp_1 + i1;
  end for;
  init b as Integer[temp_1];
  for i in 1:n loop
   b[i] := i;
  end for;
  return;
 end FunctionTests.UnknownSize.Misc.Misc1.f;

end FunctionTests.UnknownSize.Misc.Misc1;
")})));
end Misc1;

model Misc2
    function f
      input Integer[:] a;
      output Integer[max(a)] b;
      algorithm
        for i in 1:size(b,1) loop
            b[i] := i;
        end for;
    end f;
    
    Real[3] y = f({1,2,3});
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Misc_Misc2",
            description="Scalarization of functions: size described with reduction expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Misc.Misc2
 Real y[1];
 Real y[2];
 Real y[3];
equation
 ({y[1], y[2], y[3]}) = FunctionTests.UnknownSize.Misc.Misc2.f({1, 2, 3});

public
 function FunctionTests.UnknownSize.Misc.Misc2.f
  input Integer[:] a;
  output Integer[:] b;
  Integer temp_1;
 algorithm
  temp_1 := -2147483648;
  for i1 in 1:size(a, 1) loop
   temp_1 := if temp_1 > a[i1] then temp_1 else a[i1];
  end for;
  init b as Integer[temp_1];
  for i in 1:size(b, 1) loop
   b[i] := i;
  end for;
  return;
 end FunctionTests.UnknownSize.Misc.Misc2.f;

end FunctionTests.UnknownSize.Misc.Misc2;
")})));
end Misc2;

model Misc3
    record R
        parameter Integer[:] n;
        Real[sum(n)] x;
    end R;
    
    function f
      input R x;
      output Real y;
      algorithm
        y := sum(x.x);
    end f;
    
    Real y = f(R({1,2},{1,2,3}));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_Misc_Misc3",
            description="Scalarization of functions: size described with reduction expression",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass FunctionTests.UnknownSize.Misc.Misc3
 Real y;
equation
 y = FunctionTests.UnknownSize.Misc.Misc3.f(FunctionTests.UnknownSize.Misc.Misc3.R({1, 2}, {1, 2, 3}));

public
 function FunctionTests.UnknownSize.Misc.Misc3.f
  input FunctionTests.UnknownSize.Misc.Misc3.R x;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(x.x, 1) loop
   temp_1 := temp_1 + x.x[i1];
  end for;
  y := temp_1;
  return;
 end FunctionTests.UnknownSize.Misc.Misc3.f;

 record FunctionTests.UnknownSize.Misc.Misc3.R
  parameter Integer n[:];
  Real x[sum(n[:])];
 end FunctionTests.UnknownSize.Misc.Misc3.R;

end FunctionTests.UnknownSize.Misc.Misc3;
")})));
end Misc3;

end Misc;

end UnknownSize;


package FunctionLike

package NumericConversion

model Abs1
    Real x = abs(1);
    Real y[3] = abs({2,3,4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_NumericConversion_Abs1",
            description="Basic test of abs().",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionLike.NumericConversion.Abs1
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x = abs(1);
 y[1] = abs(2);
 y[2] = abs(3);
 y[3] = abs(4);
end FunctionTests.FunctionLike.NumericConversion.Abs1;
")})));
end Abs1;

model Abs2
    constant Real x = abs(-35);
    constant Real y = abs(0);
	constant Real z = abs(42);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_NumericConversion_Abs3",
            description="Evaluation of the abs operator.",
            variables="
x
y
z
",
            values="
35.0
0.0
42.0
")})));
end Abs2;

model Sign1
    Real x = sign(1);
    Real y[3] = sign({2,3,4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_NumericConversion_Sign1",
            description="Basic test of sign().",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionLike.NumericConversion.Sign1
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x = sign(1);
 y[1] = sign(2);
 y[2] = sign(3);
 y[3] = sign(4);
end FunctionTests.FunctionLike.NumericConversion.Sign1;
")})));
end Sign1;

model Sign2
    constant Real x = sign(-35);
    constant Real y = sign(0);
	constant Real z = sign(42);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_NumericConversion_Sign3",
            description="Evaluation of the sign operator.",
            variables="
x
y
z
",
            values="
-1.0
0.0
1.0
")})));
end Sign2;

model Sqrt1
    Real x = sqrt(1);
    Real y[3] = sqrt({2,3,4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_NumericConversion_Sqrt1",
            description="Basic test of sqrt().",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionLike.NumericConversion.Sqrt1
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x = sqrt(1);
 y[1] = sqrt(2);
 y[2] = sqrt(3);
 y[3] = sqrt(4);
end FunctionTests.FunctionLike.NumericConversion.Sqrt1;
")})));
end Sqrt1;

model Sqrt2
    constant Real x = sqrt(1);
    constant Real y = sqrt(4);
	constant Real z = sqrt(9);
	
    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_NumericConversion_Sqrt2",
            description="Evaluation of the sqrt operator.",
            variables="
x
y
z
",
            values="
1.0
2.0
3.0
")})));
end Sqrt2;


model Integer1
    type E = enumeration(x,a,b,c);
    Real x = Integer(E.x);
    Real y[3] = Integer({E.a,E.b,E.c});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_NumericConversion_Integer1",
            description="Basic test of Integer().",
            variability_propagation=false,
            flatModel="
fclass FunctionTests.FunctionLike.NumericConversion.Integer1
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x = Integer(FunctionTests.FunctionLike.NumericConversion.Integer1.E.x);
 y[1] = Integer(FunctionTests.FunctionLike.NumericConversion.Integer1.E.a);
 y[2] = Integer(FunctionTests.FunctionLike.NumericConversion.Integer1.E.b);
 y[3] = Integer(FunctionTests.FunctionLike.NumericConversion.Integer1.E.c);

public
 type FunctionTests.FunctionLike.NumericConversion.Integer1.E = enumeration(x, a, b, c);

end FunctionTests.FunctionLike.NumericConversion.Integer1;
")})));
end Integer1;

model Integer2
    type E = enumeration(x,a,b,c);
    constant Real x = Integer(E.x);
	constant Real y = Integer(E.b);
	constant Real z = Integer(E.c);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_NumericConversion_Integer2",
            description="Evaluation of the Integer operator.",
            variables="
x
y
z
",
            values="
1.0
3.0
4.0
")})));
end Integer2;

end NumericConversion;



package EventGen
	
model Div1
	Real x    = div(time, 2);
	Real y[2] = div({time,time},2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventGen_Div1",
            description="Basic test of div().",
            flatModel="
fclass FunctionTests.FunctionLike.EventGen.Div1
 Real x;
 Real y[1];
 Real y[2];
 discrete Real temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
initial equation 
 pre(temp_1) = 0.0;
 pre(temp_2) = 0.0;
 pre(temp_3) = 0.0;
equation
 x = temp_3;
 y[1] = temp_2;
 y[2] = temp_1;
 temp_1 = if div(time, 2) < pre(temp_1) or div(time, 2) >= pre(temp_1) + 1 or initial() then div(time, 2) else pre(temp_1);
 temp_2 = if div(time, 2) < pre(temp_2) or div(time, 2) >= pre(temp_2) + 1 or initial() then div(time, 2) else pre(temp_2);
 temp_3 = if div(time, 2) < pre(temp_3) or div(time, 2) >= pre(temp_3) + 1 or initial() then div(time, 2) else pre(temp_3);
end FunctionTests.FunctionLike.EventGen.Div1;
")})));
end Div1;

model Div2
	constant Real x = div(42.9,3);
	constant Integer y = div(42,42);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventGen_Div2",
            description="Evaluation of the div operator.",
            variables="
x
y
",
            values="
14.0
1
")})));
end Div2;

model Mod1
	Real x    = mod(time, 2);
	Real y[2] = mod({time,time},2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventGen_Mod1",
            description="Basic test of mod().",
            flatModel="
fclass FunctionTests.FunctionLike.EventGen.Mod1
 Real x;
 Real y[1];
 Real y[2];
 discrete Real temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
initial equation 
 pre(temp_1) = 0.0;
 pre(temp_2) = 0.0;
 pre(temp_3) = 0.0;
equation
 x = time - temp_3 * 2;
 y[1] = time - temp_2 * 2;
 y[2] = time - temp_1 * 2;
 temp_1 = if time / 2 < pre(temp_1) or time / 2 >= pre(temp_1) + 1 or initial() then floor(time / 2) else pre(temp_1);
 temp_2 = if time / 2 < pre(temp_2) or time / 2 >= pre(temp_2) + 1 or initial() then floor(time / 2) else pre(temp_2);
 temp_3 = if time / 2 < pre(temp_3) or time / 2 >= pre(temp_3) + 1 or initial() then floor(time / 2) else pre(temp_3);
end FunctionTests.FunctionLike.EventGen.Mod1;
")})));
end Mod1;

model Mod2
	constant Real x = mod(3.0,1.4);
	constant Real y = mod(-3.0,1.4);
	constant Real z = mod(3,-1.4);
	constant Integer a = mod(3,-5);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventGen_Mod2",
            description="Evaluation of the mod operator.",
            variables="
a
x
y
z
",
            values="
-2
0.20000000000000018
1.1999999999999993
-1.1999999999999993
")})));
end Mod2;

model Rem1
	Real x    = rem(time, 2);
	Real y[2] = rem({time,time},2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventGen_Rem1",
            description="Basic test of rem().",
            flatModel="
fclass FunctionTests.FunctionLike.EventGen.Rem1
 Real x;
 Real y[1];
 Real y[2];
 discrete Real temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
initial equation 
 pre(temp_1) = 0.0;
 pre(temp_2) = 0.0;
 pre(temp_3) = 0.0;
equation
 x = time - temp_3 * 2;
 y[1] = time - temp_2 * 2;
 y[2] = time - temp_1 * 2;
 temp_1 = if div(time, 2) < pre(temp_1) or div(time, 2) >= pre(temp_1) + 1 or initial() then div(time, 2) else pre(temp_1);
 temp_2 = if div(time, 2) < pre(temp_2) or div(time, 2) >= pre(temp_2) + 1 or initial() then div(time, 2) else pre(temp_2);
 temp_3 = if div(time, 2) < pre(temp_3) or div(time, 2) >= pre(temp_3) + 1 or initial() then div(time, 2) else pre(temp_3);
end FunctionTests.FunctionLike.EventGen.Rem1;
")})));
end Rem1;

model Rem2
	constant Real x = rem(3.0,1.4);
	constant Real y = rem(-3.0,1.4);
	constant Real z = rem(3.0,-1.4);
	constant Integer a = rem(3,-5);
	
    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventGen_Rem2",
            description="Evaluation of the rem operator.",
            variables="
a
x
y
z
",
            values="
3
0.20000000000000018
-0.20000000000000018
0.20000000000000018
")})));
end Rem2;

model Ceil1
	Real x = 4 + ceil((time * 0.3) + 4.2) * 4;
	Real y[2] = ceil({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventGen_Ceil1",
            description="Basic test of ceil().",
            flatModel="
fclass FunctionTests.FunctionLike.EventGen.Ceil1
 Real x;
 Real y[1];
 Real y[2];
 discrete Real temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
initial equation 
 pre(temp_1) = 0.0;
 pre(temp_2) = 0.0;
 pre(temp_3) = 0.0;
equation
 x = 4 + temp_3 * 4;
 y[1] = temp_2;
 y[2] = temp_1;
 temp_1 = if time * 2 <= pre(temp_1) - 1 or time * 2 > pre(temp_1) or initial() then ceil(time * 2) else pre(temp_1);
 temp_2 = if time <= pre(temp_2) - 1 or time > pre(temp_2) or initial() then ceil(time) else pre(temp_2);
 temp_3 = if time * 0.3 + 4.2 <= pre(temp_3) - 1 or time * 0.3 + 4.2 > pre(temp_3) or initial() then ceil(time * 0.3 + 4.2) else pre(temp_3);
end FunctionTests.FunctionLike.EventGen.Ceil1;
")})));
end Ceil1;

model Ceil2
	constant Real x = ceil(42.9);
	constant Real y = ceil(42.0);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventGen_Ceil2",
            description="Evaluation of the ceil operator.",
            variables="
x
y
",
            values="
43.0
42.0
")})));
end Ceil2;

model Floor1
	Real x = 4 + floor((time * 0.3) + 4.2) * 4;
	Real y[2] = floor({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventGen_Floor1",
            description="Basic test of floor().",
            flatModel="
fclass FunctionTests.FunctionLike.EventGen.Floor1
 Real x;
 Real y[1];
 Real y[2];
 discrete Real temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
initial equation 
 pre(temp_1) = 0.0;
 pre(temp_2) = 0.0;
 pre(temp_3) = 0.0;
equation
 x = 4 + temp_3 * 4;
 y[1] = temp_2;
 y[2] = temp_1;
 temp_1 = if time * 2 < pre(temp_1) or time * 2 >= pre(temp_1) + 1 or initial() then floor(time * 2) else pre(temp_1);
 temp_2 = if time < pre(temp_2) or time >= pre(temp_2) + 1 or initial() then floor(time) else pre(temp_2);
 temp_3 = if time * 0.3 + 4.2 < pre(temp_3) or time * 0.3 + 4.2 >= pre(temp_3) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_3);
end FunctionTests.FunctionLike.EventGen.Floor1;
")})));
end Floor1;

model Floor2
	constant Real x = floor(42.9);
	constant Real y = floor(42.0);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventGen_Floor2",
            description="Evaluation of the floor operator.",
            variables="
x
y
",
            values="
42.0
42.0
")})));
end Floor2;

model Integer1
	Real x = integer((0.9 + time/10) * 3.14);
	Real y[2] = integer({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventGen_Integer1",
            description="Basic test of integer().",
            flatModel="
fclass FunctionTests.FunctionLike.EventGen.Integer1
 Real x;
 Real y[1];
 Real y[2];
 discrete Integer temp_1;
 discrete Integer temp_2;
 discrete Integer temp_3;
initial equation 
 pre(temp_1) = 0;
 pre(temp_2) = 0;
 pre(temp_3) = 0;
equation
 x = temp_3;
 y[1] = temp_2;
 y[2] = temp_1;
 temp_1 = if time * 2 < pre(temp_1) or time * 2 >= pre(temp_1) + 1 or initial() then integer(time * 2) else pre(temp_1);
 temp_2 = if time < pre(temp_2) or time >= pre(temp_2) + 1 or initial() then integer(time) else pre(temp_2);
 temp_3 = if (0.9 + time / 10) * 3.14 < pre(temp_3) or (0.9 + time / 10) * 3.14 >= pre(temp_3) + 1 or initial() then integer((0.9 + time / 10) * 3.14) else pre(temp_3);
end FunctionTests.FunctionLike.EventGen.Integer1;
")})));
end Integer1;

model Integer2
	constant Integer x = integer(42.9);
	constant Integer y = integer(42.0);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventGen_Integer2",
            description="Evaluation of the integer operator.",
            variables="
x
y
",
            values="
42
42
")})));
end Integer2;



end EventGen;


package Math

model Sin
	Real x = sin(time);
	Real y[2] = sin({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Sin",
            description="Basic test of sin().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Sin
 Real x;
 Real y[1];
 Real y[2];
equation
 x = sin(time);
 y[1] = sin(time);
 y[2] = sin(time * 2);
end FunctionTests.FunctionLike.Math.Sin;
")})));
end Sin;

model Cos
	Real x = cos(time);
	Real y[2] = cos({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Cos",
            description="Basic test of cos().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Cos
 Real x;
 Real y[1];
 Real y[2];
equation
 x = cos(time);
 y[1] = cos(time);
 y[2] = cos(time * 2);
end FunctionTests.FunctionLike.Math.Cos;
")})));
end Cos;

model Tan
	Real x = tan(time);
	Real y[2] = tan({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Tan",
            description="Basic test of tan().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Tan
 Real x;
 Real y[1];
 Real y[2];
equation
 x = tan(time);
 y[1] = tan(time);
 y[2] = tan(time * 2);
end FunctionTests.FunctionLike.Math.Tan;
")})));
end Tan;

model Asin
	Real x = asin(time);
	Real y[2] = asin({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Asin",
            description="Basic test of asin().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Asin
 Real x;
 Real y[1];
 Real y[2];
equation
 x = asin(time);
 y[1] = asin(time);
 y[2] = asin(time * 2);
end FunctionTests.FunctionLike.Math.Asin;
")})));
end Asin;

model Acos
	Real x = acos(time);
	Real y[2] = acos({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Acos",
            description="Basic test of acos().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Acos
 Real x;
 Real y[1];
 Real y[2];
equation
 x = acos(time);
 y[1] = acos(time);
 y[2] = acos(time * 2);
end FunctionTests.FunctionLike.Math.Acos;
")})));
end Acos;

model Atan
	Real x = atan(time);
	Real y[2] = atan({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Atan",
            description="Basic test of atan().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Atan
 Real x;
 Real y[1];
 Real y[2];
equation
 x = atan(time);
 y[1] = atan(time);
 y[2] = atan(time * 2);
end FunctionTests.FunctionLike.Math.Atan;
")})));
end Atan;

model Atan2
	Real x = atan2(time,5);
	Real y[2] = atan2({time,time*2}, {5,6});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Atan2",
            description="Basic test of atan2().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Atan2
 Real x;
 Real y[1];
 Real y[2];
equation
 x = atan2(time, 5);
 y[1] = atan2(time, 5);
 y[2] = atan2(time * 2, 6);
end FunctionTests.FunctionLike.Math.Atan2;
")})));
end Atan2;

model Sinh
	Real x = sinh(time);
	Real y[2] = sinh({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Sinh",
            description="Basic test of sinh().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Sinh
 Real x;
 Real y[1];
 Real y[2];
equation
 x = sinh(time);
 y[1] = sinh(time);
 y[2] = sinh(time * 2);
end FunctionTests.FunctionLike.Math.Sinh;
")})));
end Sinh;

model Cosh
	Real x = cosh(time);
	Real y[2] = cosh({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Cosh",
            description="Basic test of cosh().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Cosh
 Real x;
 Real y[1];
 Real y[2];
equation
 x = cosh(time);
 y[1] = cosh(time);
 y[2] = cosh(time * 2);
end FunctionTests.FunctionLike.Math.Cosh;
")})));
end Cosh;

model Tanh
	Real x = tanh(time);
	Real y[2] = tanh({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Tanh",
            description="Basic test of tanh().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Tanh
 Real x;
 Real y[1];
 Real y[2];
equation
 x = tanh(time);
 y[1] = tanh(time);
 y[2] = tanh(time * 2);
end FunctionTests.FunctionLike.Math.Tanh;
")})));
end Tanh;

model Exp
	Real x = exp(time);
	Real y[2] = exp({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Exp",
            description="Basic test of exp().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Exp
 Real x;
 Real y[1];
 Real y[2];
equation
 x = exp(time);
 y[1] = exp(time);
 y[2] = exp(time * 2);
end FunctionTests.FunctionLike.Math.Exp;
")})));
end Exp;

model Log
	Real x = log(time);
	Real y[2] = log({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Log",
            description="Basic test of log().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Log
 Real x;
 Real y[1];
 Real y[2];
equation
 x = log(time);
 y[1] = log(time);
 y[2] = log(time * 2);
end FunctionTests.FunctionLike.Math.Log;
")})));
end Log;

model Log10
	Real x = log10(time);
	Real y[2] = log10({time,time*2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Math_Log10",
            description="Basic test of log10().",
            flatModel="
fclass FunctionTests.FunctionLike.Math.Log10
 Real x;
 Real y[1];
 Real y[2];
equation
 x = log10(time);
 y[1] = log10(time);
 y[2] = log10(time * 2);
end FunctionTests.FunctionLike.Math.Log10;
")})));
end Log10;

end Math;



package Special

model Homotopy1
  Real x = homotopy(sin(time*10) .+ 1, 1);
  Real y[2] = homotopy({sin(time*10),time} .+ 1, {1,1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_Homotopy1",
            description="Basic test of the homotopy() operator.",
            flatModel="
fclass FunctionTests.FunctionLike.Special.Homotopy1
 Real x;
 Real y[1];
 Real y[2];
equation
 x = sin(time * 10) .+ 1;
 y[1] = sin(time * 10) .+ 1;
 y[2] = time .+ 1;
end FunctionTests.FunctionLike.Special.Homotopy1;
")})));
end Homotopy1;

model Homotopy2
  Real x = homotopy(1,time);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_Special_Homotopy2",
            description="Evaluation test of the homotopy() operator.",
            variables="x",
            values="1.0"
 )})));
end Homotopy2;

model Homotopy3
    function F
        input R i;
        output Real o;
    algorithm
        o := i.x;
    end F;
    record R
        Real x;
    end R;
    R x;
equation
    x.x = homotopy(F(x), time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_Homotopy3",
            description="Test homotopy operator with records",
            homotopy_type="homotopy",
            flatModel="
fclass FunctionTests.FunctionLike.Special.Homotopy3
 Real x.x;
equation
 x.x = homotopy(x.x, time);
end FunctionTests.FunctionLike.Special.Homotopy3;
")})));
      end Homotopy3;

model SemiLinear1
  Real x = semiLinear(sin(time*10),2,-10);
  Real y[2] = semiLinear({sin(time*10),time},{2,2},{-10,3});
  parameter Real a;
  parameter Real p = semiLinear(a,1,2);
  discrete Real k;
initial equation
  k = semiLinear(time,1,2);
equation
	when time > 1 then
		k = semiLinear(time,1,2);
	end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_SemiLinear1",
            description="Basic test of the semiLinear() operator.",
            flatModel="
fclass FunctionTests.FunctionLike.Special.SemiLinear1
 Real x;
 Real y[1];
 Real y[2];
 parameter Real a;
 parameter Real p;
 discrete Real k;
 discrete Boolean temp_1;
initial equation 
 k = if time >= 0 then time else time * 2;
 pre(temp_1) = false;
parameter equation
 p = noEvent(if a >= 0 then a else a * 2);
equation
 temp_1 = time > 1;
 k = if temp_1 and not pre(temp_1) then if time >= 0 then time else time * 2 else pre(k);
 x = if sin(time * 10) >= 0 then sin(time * 10) * 2 else sin(time * 10) * -10;
 y[1] = if sin(time * 10) >= 0 then sin(time * 10) * 2 else sin(time * 10) * -10;
 y[2] = if time >= 0 then time * 2 else time * 3;
end FunctionTests.FunctionLike.Special.SemiLinear1;
")})));
end SemiLinear1;

model SemiLinear2
  Real x = semiLinear(1,2,3);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_Special_SemiLinear2",
            description="Evaluation test of the semiLinear() operator.",
            variables="x",
            values="2.0"
 )})));
end SemiLinear2;

model SemiLinear3
  Real x = 0;
  Real y = 0;
  Real sa,sb;
  parameter Real p1(fixed=false);
  parameter Real p2 = 2;
  discrete Real r1,r2;
initial equation
	y = semiLinear(x,r1,r2);
	y = semiLinear(x,p1,p2);
equation
  sa = time;
  y = semiLinear(x,sa,sb);
  
  when time > 1 then
	  r2 = 2;
	  r1 = 2;
  end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_SemiLinear3",
            description="Test of the semiLinear() operator.",
            flatModel="
fclass FunctionTests.FunctionLike.Special.SemiLinear3
 constant Real x = 0;
 Real sa;
 initial parameter Real p1(fixed = false);
 parameter Real p2 = 2 /* 2 */;
 discrete Real r1;
 discrete Real r2;
 discrete Boolean temp_1;
initial equation 
 r1 = r2;
 p1 = p2;
 pre(r2) = 0.0;
 pre(temp_1) = false;
equation
 sa = time;
 temp_1 = time > 1;
 r1 = if temp_1 and not pre(temp_1) then 2 else pre(r1);
 r2 = if temp_1 and not pre(temp_1) then 2 else pre(r2);
end FunctionTests.FunctionLike.Special.SemiLinear3;
")})));
end SemiLinear3;

model SemiLinear4
  Real x,y;
  Real sa,sb;
  Real[5] s;
equation
  sa = time;
  y = semiLinear(x,s[2],s[3]);
  sb = time;
  y = semiLinear(x,s[5],sb);
  x  = time;
  y = semiLinear(x,s[3],s[4]);
  y = semiLinear(x,s[1],s[2]);
  y = semiLinear(x,sa,s[1]);
  y = semiLinear(x,s[4],s[5]);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_SemiLinear4",
            description="Test of the semiLinear() operator. Zero flow transformation.",
            eliminate_linear_equations=false,
            flatModel="
fclass FunctionTests.FunctionLike.Special.SemiLinear4
 Real x;
 Real y;
 Real sa;
 Real sb;
 Real s[2];
equation
 sa = time;
 sb = time;
 x = time;
 s[2] = if x >= 0 then sa else sb;
 y = noEvent(if x >= 0 then x * sa else x * sb);
end FunctionTests.FunctionLike.Special.SemiLinear4;
")})));
end SemiLinear4;

model SemiLinear5
  Real x,y;
  Real sa,sb;
  Real[5] s;
equation
  semiLinear(x,s[3],s[4]) = -y;
  y = semiLinear(-x,sb,s[5]);
  y = semiLinear(--x,s[2],s[3]);
  sa = time;
  sb = time;
  x  = time;
  semiLinear(x,sa,s[1]) = --y;
  -y = semiLinear(--x,s[4],s[5]);
  -y = semiLinear(-x,s[2],s[1]);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_SemiLinear5",
            description="Test of the semiLinear() operator. Zero flow transformation.",
            eliminate_linear_equations=false,
            flatModel="
fclass FunctionTests.FunctionLike.Special.SemiLinear5
 Real x;
 Real y;
 Real sa;
 Real sb;
 Real s[2];
 Real s[3];
 Real s[5];
equation
 sa = time;
 sb = time;
 x = time;
 s[5] = if x >= 0 then s[3] else sb;
 y = - noEvent(if x >= 0 then x * s[3] else x * sb);
 s[2] = if x >= 0 then sa else s[3];
 y = noEvent(if x >= 0 then x * sa else x * s[3]);
end FunctionTests.FunctionLike.Special.SemiLinear5;
")})));
end SemiLinear5;

model SemiLinear6
  Real x,y;
  Real sa,sb,sc;
  Real[2] s;
equation
  sa = time;
  sb = time;
  x  = time;
  y = semiLinear(x,sa,s[1]);
  y = semiLinear(x,s[1],s[2]);
  y = semiLinear(x,s[2],sb);
  y = semiLinear(x,s[2],sc);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_SemiLinear6",
            description="Test of the semiLinear() operator. Zero flow transformation error",
            eliminate_linear_equations=false,
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 12, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Could not construct zero flow chain for a set of semilinear equations. This leads to an undetermined system. Involved equations:
y = semiLinear(x, sa, s[1])
y = semiLinear(x, s[1], s[2])
y = semiLinear(x, s[2], sb)
y = semiLinear(x, s[2], sc)

")})));
end SemiLinear6;

model SemiLinear7
    Real x = time;
    Real y;
    Real z = 2 * time;
equation
    y = semiLinear(if time > 1 then 1 else -1, x, z);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_Special_SemiLinear7",
            description="Check that semiLinear() with event-generating argument does not expand with smooth(0, ...)",
            eliminate_linear_equations=false,
            flatModel="
fclass FunctionTests.FunctionLike.Special.SemiLinear7
 Real x;
 Real y;
 Real z;
equation
 y = if (if time > 1 then 1 else -1) >= 0 then (if time > 1 then 1 else -1) * x else (if time > 1 then 1 else -1) * z;
 x = time;
 z = 2 * time;
end FunctionTests.FunctionLike.Special.SemiLinear7;
")})));
end SemiLinear7;

model SemiLinear8
    Real y,x;
    parameter Real sa=1,s1=2,s2=3;
equation
    y = semiLinear(x, sa, s1+1); 
    y = semiLinear(x, s1, s2);
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_SemiLinear8",
            description="",
            errorMessage="
1 errors found:

Error at line 6, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Could not construct zero flow chain for a set of semilinear equations. This leads to an undetermined system. Involved equations:
y = semiLinear(x, sa, s1 + 1)
y = semiLinear(x, s1, s2)

")})));
end SemiLinear8;


model Delay1
    Real x = delay(time, y, z);
    Real y = time;
    Real z = time ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_Delay1",
            description="Delay, non-parameter max",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', DELAY_MAX_NOT_PARAMETER:
  Calling function delay(): third argument must be of parameter variability: z
")})));
end Delay1;


model Delay2
    Real x = delay(time, y);
    Real y = time;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_Delay2",
            description="Delay, non-parameter delay without max",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', DELAY_NOT_PARAMETER:
  Calling function delay(): second argument must be of parameter variability when third argument is not given: y
")})));
end Delay2;


model Delay3
    Real x = delay(time, y, z);
    parameter Real y = 2;
    parameter Real z = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_Delay3",
            description="Delay, delay > max",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', DELAY_OVER_MAX:
  Calling function delay(): second argument may not be larger than third argument: y = 2.0 > z = 1.0
")})));
end Delay3;


model Delay4
    Real x = delay(time, y);
    parameter Real y = -1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_Delay4",
            description="Delay, delay < 0",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', DELAY_NEGATIVE:
  Calling function delay(): second argument may not be negative: y = -1.0 < 0
")})));
end Delay4;


model Delay5
    Real x = delay(time, y, z);
    Real y = time;
    parameter Real z = -1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionLike_Special_Delay5",
            description="Delay, max < 0",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', DELAY_MAX_NEGATIVE:
  Calling function delay(): third argument may not be negative: z = -1.0 < 0
")})));
end Delay5;


end Special;

package EventRel

model NoEventArray1
	Real x[2] = {1, 2};
	Real y[2] = noEvent(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_NoEventArray1",
            description="noEvent() for Real array",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.NoEventArray1
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end FunctionTests.FunctionLike.EventRel.NoEventArray1;
")})));
end NoEventArray1;

model NoEventArray2
	parameter Boolean x[2] = {true, false};
	parameter Boolean y[2] = noEvent(x);  // Not very logical, but we need to test this

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_NoEventArray2",
            description="noEvent() for Boolean array",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.NoEventArray2
 parameter Boolean x[1] = true /* true */;
 parameter Boolean x[2] = false /* false */;
 parameter Boolean y[1];
 parameter Boolean y[2];
parameter equation
 y[1] = x[1];
 y[2] = x[2];
end FunctionTests.FunctionLike.EventRel.NoEventArray2;
")})));
end NoEventArray2;

model NoEventRecord1
	record A
		Real a;
		Real b;
	end A;
	
	A x = A(1, 2);
	A y = noEvent(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_NoEventRecord1",
            description="",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.NoEventRecord1
 constant Real y.a = 1;
 constant Real y.b = 2;
end FunctionTests.FunctionLike.EventRel.NoEventRecord1;
")})));
end NoEventRecord1;

model Smooth
    Real x = smooth(2,time);
    Real y[3] = smooth(2, {1,2,3}*time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_Smooth",
            description="",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.Smooth
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x = smooth(2, time);
 y[1] = smooth(2, time);
 y[2] = smooth(2, 2 * time);
 y[3] = smooth(2, 3 * time);
end FunctionTests.FunctionLike.EventRel.Smooth;
")})));
end Smooth;

model Smooth1
    Real x,y;
equation
    der(x) = -1;
    x = smooth(0, y);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_Smooth1",
            description="",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.Smooth1
 Real x;
initial equation 
 x = 0.0;
equation
 der(x) = -1;
end FunctionTests.FunctionLike.EventRel.Smooth1;
")})));
end Smooth1;

model Smooth2
    Real a,b,c, d;
equation
    b = time;
    c = b * 2;
    d = c + b;
    a = smooth(0, if a < 0.65 then b / c * d else 0.42250000000000004 / b + d * (b - 0.65) / c);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_Smooth2",
            description="",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.Smooth2
 Real a;
 Real b;
 Real c;
 Real d;
equation
 b = time;
 c = b * 2;
 d = 3 * b;
 a = smooth(0, if a < 0.65 then b / c * d else 0.42250000000000004 / b + d * (b - 0.65) / c);
end FunctionTests.FunctionLike.EventRel.Smooth2;
")})));
end Smooth2;

model Pre1
    discrete Integer x;
    Real y = pre(x);
    discrete Integer x2[2] = {x, x};
    Real y2[2] = pre(x2);
equation
    when time > 1 then
        x = 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_Pre1",
            description="pre(): basic test",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.Pre1
 discrete Integer x;
 Real y;
 discrete Integer x2[1];
 discrete Integer x2[2];
 Real y2[1];
 Real y2[2];
 discrete Boolean temp_1;
initial equation 
 pre(x) = 0;
 pre(x2[1]) = 0;
 pre(x2[2]) = 0;
 pre(temp_1) = false;
equation
 temp_1 = time > 1;
 x = if temp_1 and not pre(temp_1) then 1 else pre(x);
 y = pre(x);
 x2[1] = x;
 x2[2] = x;
 y2[1] = pre(x2[1]);
 y2[2] = pre(x2[2]);
end FunctionTests.FunctionLike.EventRel.Pre1;
")})));
end Pre1;

model Pre2
	constant Real x = 42.9;
	constant Real y = pre(x);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventRel_Pre2",
            description="Evaluation of the pre operator.",
            variables="y",
            values="42.9"
 )})));
end Pre2;

model Edge1
	Boolean x = time > 1;
	Boolean y = edge(x);
	Boolean x2[2] = {x, x};
	Boolean y2[2] = edge(x2);
equation

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_Edge1",
            description="edge(): basic test",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.Edge1
 discrete Boolean x;
 discrete Boolean y;
 discrete Boolean x2[1];
 discrete Boolean x2[2];
 discrete Boolean y2[1];
 discrete Boolean y2[2];
initial equation 
 pre(x) = false;
 pre(y) = false;
 pre(x2[1]) = false;
 pre(x2[2]) = false;
 pre(y2[1]) = false;
 pre(y2[2]) = false;
equation
 x = time > 1;
 y = x and not pre(x);
 x2[1] = x;
 x2[2] = x;
 y2[1] = x2[1] and not pre(x2[1]);
 y2[2] = x2[2] and not pre(x2[2]);
end FunctionTests.FunctionLike.EventRel.Edge1;
")})));
end Edge1;

model Edge2
	constant Boolean x = true;
	constant Boolean y = edge(x);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventRel_Edge2",
            description="Evaluation of the edge operator.",
            variables="y",
            values="false"
 )})));
end Edge2;

model Change1
	Real x = time;
	Boolean y;
	Real x2[2] = ones(2)*time;
	Boolean y2[2];
equation
	when time > 1 then
		y = change(x);
		y2 = change(x2);
	end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_Change1",
            description="change(): basic test",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.Change1
 discrete Boolean y;
 Real x2[1];
 discrete Boolean y2[1];
 discrete Boolean y2[2];
 discrete Boolean temp_1;
initial equation 
 pre(y) = false;
 pre(y2[1]) = false;
 pre(y2[2]) = false;
 pre(temp_1) = false;
equation
 temp_1 = time > 1;
 y = if temp_1 and not pre(temp_1) then x2[1] <> pre(x2[1]) else pre(y);
 y2[1] = if temp_1 and not pre(temp_1) then x2[1] <> pre(x2[1]) else pre(y2[1]);
 y2[2] = if temp_1 and not pre(temp_1) then x2[1] <> pre(x2[1]) else pre(y2[2]);
 x2[1] = time;
end FunctionTests.FunctionLike.EventRel.Change1;
")})));
end Change1;

model Change2
	constant Boolean x = true;
	constant Boolean y = change(x);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionLike_EventRel_Change2",
            description="Evaluation of the change operator.",
            variables="y",
            values="false"
 )})));
end Change2;

model SampleTest1
	Boolean x = sample(0, 1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_SampleTest1",
            description="sample(): basic test",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.SampleTest1
 discrete Boolean x;
 discrete Integer _sampleItr_1;
initial equation 
 pre(x) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time);
equation
 x = not initial() and time >= pre(_sampleItr_1);
 _sampleItr_1 = if x and not pre(x) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\");
end FunctionTests.FunctionLike.EventRel.SampleTest1;
")})));
end SampleTest1;

model SampleTest2
   Real y;
   parameter Boolean x(start=true);
equation
    when x and sample(0.01, 0.01) then
        y = time;
   end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionLike_EventRel_SampleTest2",
            description="sample(): basic test",
            flatModel="
fclass FunctionTests.FunctionLike.EventRel.SampleTest2
 discrete Real y;
 parameter Boolean x(start = true);
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
 discrete Boolean temp_2;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0.01 then 0 else ceil((time - 0.01) / 0.01);
 pre(y) = 0.0;
 pre(temp_2) = false;
equation
 temp_2 = x and temp_1;
 y = if temp_2 and not pre(temp_2) then time else pre(y);
 temp_1 = not initial() and time >= 0.01 + pre(_sampleItr_1) * 0.01;
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < 0.01 + (pre(_sampleItr_1) + 1) * 0.01, \"Too long time steps relative to sample interval.\");
end FunctionTests.FunctionLike.EventRel.SampleTest2;
")})));
end SampleTest2;

end EventRel;

end FunctionLike;

package DerivativeAnnotation
    model MissingReference1
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative);
        end F;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_MissingReference1",
            description="Test error message given when there is no derivative function reference",
            errorMessage="
1 errors found:

Error at line 7, column 38, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Function name is missing in derivative annotation declaration
")})));
    end MissingReference1;

    model MissingDecl1
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative=notAFunction);
        end F;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_MissingDecl1",
            description="Test error message given when referencing missing derivative function",
            errorMessage="
1 errors found:

Error at line 7, column 38, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Cannot find function declaration for notAFunction
")})));
    end MissingDecl1;

    model InvalidDecl1
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative=1+2);
        end F;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidDecl1",
            description="Test error message given for invalid derivative function reference",
            errorMessage="
1 errors found:

Error at line 7, column 38, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Invalid derivative function reference
")})));
    end InvalidDecl1;

    model InvalidDecl2
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative=B);
        end F;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidDecl2",
            description="Test error message given when giving derivative function reference to non-function class",
            errorMessage="
1 errors found:

Error at line 7, column 38, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  The class B is not a function
")})));
    end InvalidDecl2;

    model MultipleOrder1
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(order=1, order=1)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_MultipleOrder1",
            description="Test error message given when there are multiple order attributes supplied",
            errorMessage="
1 errors found:

Error at line 7, column 58, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Multiple declarations of the order attribute
")})));
    end MultipleOrder1;

    model InvalidOrder1
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(order=1.1)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidOrder1",
            description="Test error message given when order argument is of non-integer type",
            errorMessage="
1 errors found:

Error at line 7, column 49, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Expecting integer typed expression for order attribute
")})));
    end InvalidOrder1;

    model InvalidOrder2
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(order=0)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidOrder2",
            description="Test error message given when order argument is invalid number (0 or less)",
            errorMessage="
1 errors found:

Error at line 7, column 49, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Order attribute must be greater or equal to one
")})));
    end InvalidOrder2;

    model MultipleVariableRestrictions1
        function F
            input Real x;
            input Real x2;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(noDerivative=x2, noDerivative=x2)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_MultipleVariableRestrictions1",
            description="Test error message given when there are multiple noDerivative attributes for the same variable",
            errorMessage="
1 errors found:

Error at line 8, column 66, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Multiple noDerivative or zeroDerivative declarations for x2
")})));
    end MultipleVariableRestrictions1;

    model MultipleVariableRestrictions2
        function F
            input Real x;
            input Real x2;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(zeroDerivative=x2, zeroDerivative=x2)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_MultipleVariableRestrictions2",
            description="Test error message given when there are multiple zeroDerivative attributes for the same variable",
            errorMessage="
1 errors found:

Error at line 8, column 68, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Multiple noDerivative or zeroDerivative declarations for x2
")})));
    end MultipleVariableRestrictions2;

    model MultipleVariableRestrictions3
        function F
            input Real x;
            input Real x2;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(noDerivative=x2, zeroDerivative=x2)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_MultipleVariableRestrictions3",
            description="Test error message given when there are one noDerivative and one zeroDerivative attribute for the same variable",
            errorMessage="
1 errors found:

Error at line 8, column 66, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Multiple noDerivative or zeroDerivative declarations for x2
")})));
    end MultipleVariableRestrictions3;

    model InvalidVariable1
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(noDerivative=1 + 1)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidVariable1",
            description="Test error message given when noDerivative attribute isn't a variable reference",
            errorMessage="
1 errors found:

Error at line 7, column 49, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Expecting variable reference for noDerivative annotation
")})));
    end InvalidVariable1;

    model InvalidVariable2
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(zeroDerivative=1 + 1)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidVariable2",
            description="Test error message given when zeroDerivative attribute isn't a variable reference",
            errorMessage="
1 errors found:

Error at line 7, column 49, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Expecting variable reference for zeroDerivative annotation
")})));
    end InvalidVariable2;

    model InvalidVariable3
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(noDerivative=notAVar)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidVariable3",
            description="Test error message given when noDerivative attribute point to missing variable",
            errorMessage="
1 errors found:

Error at line 7, column 49, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Unable to find notAVar
")})));
    end InvalidVariable3;

    model InvalidVariable4
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(zeroDerivative=notAVar)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_InvalidVariable4",
            description="Test error message given when zeroDerivative attribute point to missing variable",
            errorMessage="
1 errors found:

Error at line 7, column 49, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Unable to find notAVar
")})));
    end InvalidVariable4;

    model NonInputVariable1
        function F
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
            annotation(Inline=false, derivative(noDerivative=y)=F_der);
        end F;
        function F_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        end F_der;
        model B
            Real y;
        end B;
        Real x = F(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DerivativeAnnotation_NonInputVariable1",
            description="Test error message given when a noDerivative attribute references a non-input variable",
            errorMessage="
1 errors found:

Error at line 7, column 49, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  noDerivative annotation may only reference input variables
")})));
    end NonInputVariable1;

    model ExtendsTest1
        package P1
            replaceable partial function F
                input Real x;
                output Real y;
            end F;
        end P1;
        
        package P2
            extends P1;
            redeclare function extends F
            algorithm
                y := x;
                annotation(Inline=false, derivative=F_der);
            end F;
            
            function F_der
                input Real x;
                input Real x_der;
                output Real y_der;
            algorithm
                y_der := x_der;
                annotation(Inline=false);
            end F_der;
        end P2;
        P2 p2;
        Real x, y;
    equation
        x = p2.F(time);
        der(x) * der(y) = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="DerivativeAnnotation_ExtendsTest1",
            description="Ensure that derivative function is found when using derivative equations in redeclaring packages/functions",
            flatModel="
fclass FunctionTests.DerivativeAnnotation.ExtendsTest1
 Real x;
 Real y;
equation
 x = FunctionTests.DerivativeAnnotation.ExtendsTest1.p2.F(time);
 der(x) * der(y) = 1;

public
 function FunctionTests.DerivativeAnnotation.ExtendsTest1.p2.F
  input Real x;
  output Real y;
 algorithm
  y := x;
  return;
 annotation(derivative = FunctionTests.DerivativeAnnotation.ExtendsTest1.p2.F_der,Inline = false);
 end FunctionTests.DerivativeAnnotation.ExtendsTest1.p2.F;

 function FunctionTests.DerivativeAnnotation.ExtendsTest1.p2.F_der
  input Real x;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end FunctionTests.DerivativeAnnotation.ExtendsTest1.p2.F_der;

end FunctionTests.DerivativeAnnotation.ExtendsTest1;
")})));
    end ExtendsTest1;

    model Local1
        function f
            input Real x;
            output Real y;
            function my_der = f_der;
        algorithm
            y := x;
            annotation(Inline=false, derivative=my_der);
        end f;
        
        function f_der
            input Real x;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
            annotation(Inline=false);
        end f_der;
        
        Real x, y;
    equation
        x = f(time);
        der(x) * der(y) = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="DerivativeAnnotation_Local1",
            description="Ensure that derivative function is found also within the function",
            flatModel="
fclass FunctionTests.DerivativeAnnotation.Local1
 Real x;
 Real y;
equation
 x = FunctionTests.DerivativeAnnotation.Local1.f(time);
 der(x) * der(y) = 1;

public
 function FunctionTests.DerivativeAnnotation.Local1.f
  input Real x;
  output Real y;
 algorithm
  y := x;
  return;
 annotation(derivative = FunctionTests.DerivativeAnnotation.Local1.f_der,Inline = false);
 end FunctionTests.DerivativeAnnotation.Local1.f;

 function FunctionTests.DerivativeAnnotation.Local1.f_der
  input Real x;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end FunctionTests.DerivativeAnnotation.Local1.f_der;

end FunctionTests.DerivativeAnnotation.Local1;
")})));
    end Local1;

end DerivativeAnnotation;


model UnusedFunction1
    function f
        input Real x;
        output Real y = x;
        algorithm
    end f;
    
    record R
        Real x = f(time);
    end R;
    
    R r(x=time+1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="UnusedFunction1",
            description="",
            flatModel="
fclass FunctionTests.UnusedFunction1
 FunctionTests.UnusedFunction1.R r(x = time + 1);

public
 record FunctionTests.UnusedFunction1.R
  Real x;
 end FunctionTests.UnusedFunction1.R;

end FunctionTests.UnusedFunction1;
")})));
end UnusedFunction1;

model UnusedFunction2
    function f
        input Real x;
        output Real y = 3 * x^3;
    algorithm
        annotation(Inline=false,derivative=fd);
    end f;
    
    function fd
        input Real x;
        input Real dx;
        output Real dy = 6 * dx^2;
    algorithm
        annotation(Inline=false,derivative(order=2)=fdd);
    end fd;
    
    function fdd
        input Real x;
        input Real dx;
        input Real ddx;
        output Real y = 12 * ddx^1;
    algorithm
        annotation(Inline=false);
    end fdd;
    
    Real x;
equation
    x = f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnusedFunction2",
            description="Test behaviour with unused derivative functions",
            flatModel="
fclass FunctionTests.UnusedFunction2
 Real x;
equation
 x = FunctionTests.UnusedFunction2.f(time);

public
 function FunctionTests.UnusedFunction2.f
  input Real x;
  output Real y;
 algorithm
  y := 3 * x ^ 3;
  return;
 annotation(derivative = FunctionTests.UnusedFunction2.fd,Inline = false);
 end FunctionTests.UnusedFunction2.f;

end FunctionTests.UnusedFunction2;
")})));
end UnusedFunction2;

model AnnotationFlattening1
    function F
        input Real i1;
        input Integer i2;
        output Real o1;
    protected
        Real x = i1;
    algorithm
        o1 := x * i2 + x;
    annotation(Inline=false, derivative=F_der, smoothOrder=2);
    end F;
    
    function F_der
        input Real i1;
        input Integer i2;
        input Real i1_der;
        output Real o1_der;
    algorithm
        o1_der := i1_der * i2 + i1_der;
    annotation(Inline=false);
    end F_der;
    
    model B
        replaceable function func = F(i2=2);
        Real x,y;
    equation
        x = func(y);
        der(x) * der(y) = 1;
    end B;
    
    model C = B(redeclare function func = F(i2=3));
    
    C c;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AnnotationFlattening1",
            description="Test so that annotations are flattened correctly even if the function is a replacing short class decl",
            flatModel="
fclass FunctionTests.AnnotationFlattening1
 Real c.x;
 Real c.y;
 Real c._der_x;
initial equation 
 c.y = 0.0;
equation
 c.x = FunctionTests.AnnotationFlattening1.c.func(c.y, 3);
 c._der_x * der(c.y) = 1;
 c._der_x = FunctionTests.AnnotationFlattening1.F_der(c.y, 3, der(c.y));

public
 function FunctionTests.AnnotationFlattening1.c.func
  input Real i1;
  input Integer i2;
  output Real o1;
  Real x;
 algorithm
  x := i1;
  o1 := x * i2 + x;
  return;
 annotation(derivative = FunctionTests.AnnotationFlattening1.F_der,Inline = false,smoothOrder = 2);
 end FunctionTests.AnnotationFlattening1.c.func;

 function FunctionTests.AnnotationFlattening1.F_der
  input Real i1;
  input Integer i2;
  input Real i1_der;
  output Real o1_der;
 algorithm
  o1_der := i1_der * i2 + i1_der;
  return;
 annotation(Inline = false);
 end FunctionTests.AnnotationFlattening1.F_der;

end FunctionTests.AnnotationFlattening1;
")})));
end AnnotationFlattening1;

model AnnotationFlattening2
    function F
        input Real i1;
        input Integer i2;
        output Real o1;
    protected
        Real x = i1;
    algorithm
        o1 := x * i2 + x;
    annotation(Inline=false, derivative=F_der_wrong, smoothOrder=2);
    end F;
    
    function F_der
        input Real i1;
        input Integer i2;
        input Real i1_der;
        output Real o1_der;
    algorithm
        o1_der := i1_der * i2 + i1_der;
    annotation(Inline=false);
    end F_der;
    
    model B
        replaceable function func = F(i2=2);
        Real x,y;
    equation
        x = func(y);
        der(x) * der(y) = 1;
    end B;
    
    model C = B(redeclare function func = F(i2=3));
    
    C c;
end AnnotationFlattening2;

model ConstantInFunction1
    function f
        constant input Real x = 0;
        output Real y;
        algorithm
    end f;
    
    Real y = f(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ConstantInFunction1",
            description="Constant input",
            errorMessage="
1 errors found:

Error at line 3, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo', CONSTANT_INPUT:
  Function input may not be constant

")})));
end ConstantInFunction1;

model ConstantInFunction2
    record R
        constant Real x = 0;
    end R;
    
    function f
        input R r;
        output Real y = r.x;
        algorithm
    end f;
    
    R r(x=2);
    Real y = f(r);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantInFunction2",
            description="",
            flatModel="
fclass FunctionTests.ConstantInFunction2
 constant Real y = 2;
end FunctionTests.ConstantInFunction2;
")})));
end ConstantInFunction2;


model ConstantInFunction3
    package P1
        record R
            constant Real x = 0;
        end R;
        function f
            input R r;
            output Real y = r.x;
        algorithm
        end f;
        
        constant R r;
        
        model M
            Real y = f(r);
        end M;
    end P1;
    
    package P2
        extends P1(r(x=2));
    end P2;
    
    P2.M m;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantInFunction3",
            description="",
            flatModel="
fclass FunctionTests.ConstantInFunction3
 constant Real m.y = 2;
end FunctionTests.ConstantInFunction3;

")})));
end ConstantInFunction3;

model ConstantInFunction4
    function f
        input Real x;
        output Real y = z;
        constant Real z = x;
        algorithm
    end f;
    
    Real y = f(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ConstantInFunction4",
            description="Constant input",
            errorMessage="
1 errors found:

Error at line 5, column 27, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTests.mo':
  Could not evaluate binding expression for constant 'z': 'x'

")})));
end ConstantInFunction4;

model ConstantInFunction5
    record R
        constant Real x = 1;
    end R;
    
    function f
        function g
            output Real y = r1.x;
            algorithm
        end g;
        output Real y = g();
        constant R r1;
    algorithm
    end f;
    
    Real y = f();
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConstantInFunction5",
            description="",
            flatModel="
fclass FunctionTests.ConstantInFunction5
 Real y = FunctionTests.ConstantInFunction5.f();

public
 function FunctionTests.ConstantInFunction5.f
  output Real y;
 algorithm
  y := FunctionTests.ConstantInFunction5.f.g();
  return;
 end FunctionTests.ConstantInFunction5.f;

 function FunctionTests.ConstantInFunction5.f.g
  output Real y;
 algorithm
  y := 1.0;
  return;
 end FunctionTests.ConstantInFunction5.f.g;

end FunctionTests.ConstantInFunction5;
")})));
end ConstantInFunction5;

model ConstantInRecordFunctionArgument
    record R
        constant Integer n = 1;
        Real[n] x = 1:n;
    end R;
        
    function f
        input R r;
        output Real y;
    algorithm
        y := 0;
        for i in 1:r.n loop
            y := y + r.x[i];
        end for;
    end f;
        
    R r(n=2);
    Real y = f(r);
	
	annotation(__JModelica(UnitTesting(tests={
	    FlatteningTestCase(
		    name="ConstantInRecordFunctionArgument",
			description="",
			flatModel="
fclass FunctionTests.ConstantInRecordFunctionArgument
 FunctionTests.ConstantInRecordFunctionArgument.R r(n = 2,x(size() = {2}) = 1:2);
 Real y = FunctionTests.ConstantInRecordFunctionArgument.f(r);

public
 function FunctionTests.ConstantInRecordFunctionArgument.f
  input FunctionTests.ConstantInRecordFunctionArgument.R r;
  output Real y;
 algorithm
  assert(r.n == size(r.x, 1), \"Mismatching sizes in function 'FunctionTests.ConstantInRecordFunctionArgument.f', component 'r.x', dimension '1'\");
  y := 0;
  for i in 1:r.n loop
   y := y + r.x[i];
  end for;
  return;
 end FunctionTests.ConstantInRecordFunctionArgument.f;

 record FunctionTests.ConstantInRecordFunctionArgument.R
  constant Integer n;
  Real x[1];
 end FunctionTests.ConstantInRecordFunctionArgument.R;

end FunctionTests.ConstantInRecordFunctionArgument;
")})));
end ConstantInRecordFunctionArgument;

model ArrayWithIfInput
    function g
        input Real[:] x;
        output Real y = x[1];
        algorithm
    end g;

    function f
        input Real[:] x;
        output Real y = x[1];
        algorithm
    end f;

    parameter Real p0 = 1;
    parameter Real p1 = g({if p0 > 0 then p0 else p0 + 1});
    parameter Real p2 = f({if p1 > 0 then p1 else p1 + 1});

annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="ArrayWithIfInput",
        description="",
        flatModel="
fclass FunctionTests.ArrayWithIfInput
 parameter Real p0 = 1 /* 1 */;
 parameter Real temp_1;
 parameter Real p1;
 parameter Real temp_3;
 parameter Real p2;
parameter equation
 temp_1 = if p0 > 0 then p0 else p0 + 1;
 p1 = temp_1;
 temp_3 = if p1 > 0 then p1 else p1 + 1;
 p2 = temp_3;
end FunctionTests.ArrayWithIfInput;
")})));
end ArrayWithIfInput;


model AssignmentSizeCheck1
  function f
      input Integer n;
      output Real[n] y;
    algorithm
      y := zeros(0);
  end f;

  constant Real[:] p1 = f(1);

annotation(__JModelica(UnitTesting(tests={
    ErrorTestCase(
        name="AssignmentSizeCheck1",
        description="Verify that array size mismatches are found during evaluation; #5654.",
        errorMessage="


Error at line 9, column 25, in file '...':
  Could not evaluate binding expression for constant 'p1': 'f(1)'
    in function 'FunctionTests.AssignmentSizeCheck1.f'
    Mismatching types when evaluating assignment, type of left-hand side is Real[1], and type of right-hand side is Integer[0] at line 6, column 7, in file 'FunctionTests.mo'
")})));
end AssignmentSizeCheck1;

model AssignmentSizeCheck2
  function f
      input Integer m;
      input Integer n;
      output Real[m, n] y;
    algorithm
      y := { { 1, 2 }, { 3, 4 } };
  end f;

  constant Real[:, :] p1 = f(1, 2);

annotation(__JModelica(UnitTesting(tests={
    ErrorTestCase(
        name="AssignmentSizeCheck2",
        description="Verify that matrix size mismatches are found during evaluation; #5654.",
        errorMessage="


Error at line 10, column 28, in file '...':
  Could not evaluate binding expression for constant 'p1': 'f(1, 2)'
    in function 'FunctionTests.AssignmentSizeCheck2.f'
    Mismatching types when evaluating assignment, type of left-hand side is Real[1, 2], and type of right-hand side is Integer[2, 2] at line 7, column 7, in file 'FunctionTests.mo'
")})));
end AssignmentSizeCheck2;

model AssignmentSizeCheck3
    record R
        Real[:] x;
    end R;

  function f
      input Integer n;
      output R r(x={1});
    algorithm
      r := R(1:n);
  end f;

  constant R r = f(2);

annotation(__JModelica(UnitTesting(tests={
    ErrorTestCase(
        name="AssignmentSizeCheck3",
        description="Verify that matrix size mismatches are found during evaluation; #5654.",
        errorMessage="


Error at line 13, column 18, in file '...':
  Could not evaluate binding expression for constant 'r': 'f(2)'
    in function 'FunctionTests.AssignmentSizeCheck3.f'
    Mismatching types when evaluating assignment, type of left-hand side is FunctionTests.AssignmentSizeCheck3.R(Real[1]), and type of right-hand side is FunctionTests.AssignmentSizeCheck3.R(Real[2]) at line 10, column 7, in file 'FunctionTests.mo'

Error at line 13, column 18, in file '...':
  Could not evaluate binding expression for constant 'r.x': '(f(2)).x'
    in function 'FunctionTests.AssignmentSizeCheck3.f'
    Mismatching types when evaluating assignment, type of left-hand side is FunctionTests.AssignmentSizeCheck3.R(Real[1]), and type of right-hand side is FunctionTests.AssignmentSizeCheck3.R(Real[2]) at line 10, column 7, in file 'FunctionTests.mo'
")})));
end AssignmentSizeCheck3;

model AssignmentSizeCheck4
    record R
        Real x;
    end R;

  function f
      input Integer n;
      output R[1] r(x={1});
    algorithm
      r := {R(i) for i in 1:n};
  end f;

  constant R[:] r = f(2);

annotation(__JModelica(UnitTesting(tests={
    ErrorTestCase(
        name="AssignmentSizeCheck4",
        description="Verify that matrix size mismatches are found during evaluation; #5654.",
        errorMessage="


Error at line 13, column 21, in file '...':
  Could not evaluate binding expression for constant 'r': 'f(2)'
    in function 'FunctionTests.AssignmentSizeCheck4.f'
    Mismatching types when evaluating assignment, type of left-hand side is FunctionTests.AssignmentSizeCheck4.R(Real)[1], and type of right-hand side is FunctionTests.AssignmentSizeCheck4.R(Real)[2] at line 10, column 7, in file 'FunctionTests.mo'

Error at line 13, column 21, in file '...':
  Could not evaluate binding expression for constant 'r[1].x': '((f(2))[1]).x'
    in function 'FunctionTests.AssignmentSizeCheck4.f'
    Mismatching types when evaluating assignment, type of left-hand side is FunctionTests.AssignmentSizeCheck4.R(Real)[1], and type of right-hand side is FunctionTests.AssignmentSizeCheck4.R(Real)[2] at line 10, column 7, in file 'FunctionTests.mo'
")})));
end AssignmentSizeCheck4;

model AssignmentSizeCheck5
    record R1
        Real x;
        Real y;
    end R1;

    record R2
        Real x;
    end R2;

    function f
        input Integer n;
        output R1 r;
    algorithm
        r := R2(1);
    end f;

    constant R1 r = f(2);

annotation(__JModelica(UnitTesting(tests={
    ErrorTestCase(
        name="AssignmentSizeCheck5",
        description="Verify that record with mismatching number of components are found during evaluation; #5654.",
        errorMessage="


Error at line 15, column 9, in file '...':
  The right and left expression types of assignment are not compatible, type of left-hand side is FunctionTests.AssignmentSizeCheck5.R1, and type of right-hand side is FunctionTests.AssignmentSizeCheck5.R2

Error at line 18, column 21, in file '...':
  Could not evaluate binding expression for constant 'r': 'f(2)'
    in function 'FunctionTests.AssignmentSizeCheck5.f'
    Mismatching types when evaluating assignment, type of left-hand side is FunctionTests.AssignmentSizeCheck5.R1(Real, Real), and type of right-hand side is FunctionTests.AssignmentSizeCheck5.R2(Real) at line 15, column 9, in file 'FunctionTests.mo'

Error at line 18, column 21, in file '...':
  Could not evaluate binding expression for constant 'r.x': '(f(2)).x'
    in function 'FunctionTests.AssignmentSizeCheck5.f'
    Mismatching types when evaluating assignment, type of left-hand side is FunctionTests.AssignmentSizeCheck5.R1(Real, Real), and type of right-hand side is FunctionTests.AssignmentSizeCheck5.R2(Real) at line 15, column 9, in file 'FunctionTests.mo'

Error at line 18, column 21, in file '...':
  Could not evaluate binding expression for constant 'r.y': '(f(2)).y'
    in function 'FunctionTests.AssignmentSizeCheck5.f'
    Mismatching types when evaluating assignment, type of left-hand side is FunctionTests.AssignmentSizeCheck5.R1(Real, Real), and type of right-hand side is FunctionTests.AssignmentSizeCheck5.R2(Real) at line 15, column 9, in file 'FunctionTests.mo'
")})));
end AssignmentSizeCheck5;

end FunctionTests;
