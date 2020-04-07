/*
	Copyright (C) 2009-2013 Modelon AB

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

package EvaluationTests



model VectorMul
	parameter Integer n = 3;
	parameter Real z[n] = 1:n;
	parameter Real y[n] = n:-1:1;
	parameter Real x = z * y;
	Real q = x;

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="VectorMul",
            description="Constant evaluation of vector multiplication",
            variables="x",
            values="10.0"
 )})));
end VectorMul;


model FunctionEval1
	function f
		input Real i;
		output Real o = i + 2.0;
		algorithm
	end f;
	
	parameter Real x = f(1.0);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval1",
            description="Constant evaluation of functions: basic test",
            variables="x",
            values="3.0"
 )})));
end FunctionEval1;


model FunctionEval2
	function fib
		input Real n;
		output Real a;
	protected
		Real b;
		Real c;
		Real i;
	algorithm
		a := 1;
		b := 1;
		if n < 3 then
			return;
		end if;
		i := 2;
		while i < n loop
			c := b;
			b := a;
			a := b + c;
			i := i + 1;
		end while;
	end fib;

	parameter Real x[6] = { fib(1), fib(2), fib(3), fib(4), fib(5), fib(6) };

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval2",
            description="Constant evaluation of functions: while and if",
            variables="
x[1]
x[2]
x[3]
x[4]
x[5]
x[6]
",
            values="
1.0
1.0
2.0
3.0
5.0
8.0
")})));
end FunctionEval2;


model FunctionEval3
	function f
		input Real[3] i;
		output Real o = 1;
	protected
		Real[size(i,1)] x;
	algorithm
		x := i + (1:size(i,1));
		for j in 1:size(i,1) loop
			o := o * x[j];
		end for;
	end f;
	
	parameter Real x = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval3",
            description="Constant evaluation of functions: array inputs and for loops",
            variables="x",
            values="48.0"
 )})));
end FunctionEval3;


model FunctionEval4
	function f
		input Real[:] i;
		output Real o = 1;
	protected
		Real[size(i,1)] x;
	algorithm
		x := i + (1:size(i,1));
		for j in 1:size(i,1) loop
			o := o * x[j];
		end for;
	end f;
	
	parameter Real x = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval4",
            description="Constant evaluation of functions: unknown array sizes",
            variables="x",
            values="48.0"
 )})));
end FunctionEval4;


model FunctionEval5
	function f
		input Real[3] i;
		output Real o;
	algorithm
		o := 0;
		for x in i loop
			o := o + x;
		end for;
	end f;
	
	parameter Real x = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval5",
            description="Constant evaluation of functions: using input as for index expression",
            variables="x",
            values="6.0"
 )})));
end FunctionEval5;


model FunctionEval6
	parameter Real y[2] = {1, 2};
	parameter Real x[2] = f(y);
	
	function f
		input Real i[2];
		output Real o[2];
	algorithm
		o := i;
	end f;

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval6",
            description="Constant evaluation of functions: array output",
            variables="
x[1]
x[2]
",
            values="
1.0
2.0
")})));
end FunctionEval6;


model FunctionEval7
	parameter Real y[2] = {1, 2};
	parameter Real x[2] = f(y);
	
	function f
		input Real i[:];
		output Real o[size(i, 1)];
	algorithm
		o := i;
	end f;

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval7",
            description="Constant evaluation of functions: array output, unknown size",
            variables="
x[1]
x[2]
",
            values="
1.0
2.0
")})));
end FunctionEval7;


model FunctionEval8
	function f
		input Real i;
		output Real o = 2 * i;
	algorithm
	end f;
	
	parameter Real x[2] = { f(i) for i in 1:2 };

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval8",
            description="Constant evaluation and variability of iter exp containing function call",
            variables="
x[1]
x[2]
",
            values="
2.0
4.0
")})));
end FunctionEval8;


model FunctionEval9
	function f
		input Real i;
		output Real o;
	protected
		Real x;
	algorithm
		x := 2;
		o := 1;
		while x <= i loop
			o := o * x;
			x := x + 1;
		end while;
	end f;

	parameter Real x = f(5);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval9",
            description="Constant evaluation of functions: while loops (flat tree, independent param)",
            variables="x",
            values="120.0"
 )})));
end FunctionEval9;


model FunctionEval10
	function f
		input Real i;
		output Real o;
	protected
		Real x;
	algorithm
		x := 2;
		o := 1;
		while x <= i loop
			o := o * x;
			x := x + 1;
		end while;
	end f;

	constant Real x = f(5);
	Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval10",
            description="Constant evaluation of functions: while loops (instance tree)",
            flatModel="
fclass EvaluationTests.FunctionEval10
 constant Real x = 120.0;
 Real y = 120.0;

public
 function EvaluationTests.FunctionEval10.f
  input Real i;
  output Real o;
  Real x;
 algorithm
  x := 2;
  o := 1;
  while x <= i loop
   o := o * x;
   x := x + 1;
  end while;
  return;
 end EvaluationTests.FunctionEval10.f;

end EvaluationTests.FunctionEval10;
")})));
end FunctionEval10;


model FunctionEval11
	function f
		input Real i;
		output Real o;
	protected
		Real x;
	algorithm
		x := 2;
		o := 1;
		while x <= i loop
			o := o * x;
			x := x + 1;
		end while;
	end f;

	parameter Real x = f(y);
	parameter Real y = 5;

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval11",
            description="Constant evaluation of functions: while loops (flat tree, dependent param)",
            variables="x",
            values="120.0"
 )})));
end FunctionEval11;


model FunctionEval12
	record R
		Real a;
		Real b;
	end R;
	
	function f1
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f1;
	
	function f2
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f2;
	
	constant Real x = f2(f1(2));
	Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval12",
            description="Constant evaluation of functions: records",
            flatModel="
fclass EvaluationTests.FunctionEval12
 constant Real x = 6.0;
 Real y = 6.0;

public
 function EvaluationTests.FunctionEval12.f2
  input EvaluationTests.FunctionEval12.R a;
  output Real x;
 algorithm
  x := a.a + a.b;
  return;
 end EvaluationTests.FunctionEval12.f2;

 function EvaluationTests.FunctionEval12.f1
  input Real a;
  output EvaluationTests.FunctionEval12.R x;
 algorithm
  x := EvaluationTests.FunctionEval12.R(a, 2 * a);
  return;
 end EvaluationTests.FunctionEval12.f1;

 record EvaluationTests.FunctionEval12.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval12.R;

end EvaluationTests.FunctionEval12;
")})));
end FunctionEval12;


model FunctionEval13
	record R
		Real a;
		Real b;
	end R;
	
	function f
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f;
	
	constant R x = f(2);
	R y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval13",
            description="Constant evaluation of functions: records",
            flatModel="
fclass EvaluationTests.FunctionEval13
 constant EvaluationTests.FunctionEval13.R x = EvaluationTests.FunctionEval13.R(2, 4.0);
 EvaluationTests.FunctionEval13.R y = EvaluationTests.FunctionEval13.R(2, 4.0);

public
 function EvaluationTests.FunctionEval13.f
  input Real a;
  output EvaluationTests.FunctionEval13.R x;
 algorithm
  x := EvaluationTests.FunctionEval13.R(a, 2 * a);
  return;
 end EvaluationTests.FunctionEval13.f;

 record EvaluationTests.FunctionEval13.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval13.R;

end EvaluationTests.FunctionEval13;
")})));
end FunctionEval13;


model FunctionEval14
	record R
		Real a;
		Real b;
	end R;
	
	function f
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f;
	
	constant Real x = f(R(1, 2));
	Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval14",
            description="Constant evaluation of functions: records",
            flatModel="
fclass EvaluationTests.FunctionEval14
 constant Real x = 3.0;
 Real y = 3.0;

public
 function EvaluationTests.FunctionEval14.f
  input EvaluationTests.FunctionEval14.R a;
  output Real x;
 algorithm
  x := a.a + a.b;
  return;
 end EvaluationTests.FunctionEval14.f;

 record EvaluationTests.FunctionEval14.R
  Real a;
  Real b;
 end EvaluationTests.FunctionEval14.R;

end EvaluationTests.FunctionEval14;
")})));
end FunctionEval14;


model FunctionEval15
	record R1
		Real a[2];
		Real b[3];
	end R1;
	
	record R2
		R1 a[2];
		R1 b[3];
	end R2;
	
	function f1
		input R2 a[2];
		output Real x;
	algorithm
		x := sum(a.a.a) + sum(a.a.b) + sum(a.b.a) + sum(a.b.b);
	end f1;
	
	function f2
		output R2 x[2];
	algorithm
		x.a.a := ones(2,2,2);
		for i in 1:2, j in 1:2 loop
			x[i].a[j].b := {1, 1, 1};
			x[i].b.a[j] := x[i].a[j].b;
		end for;
		x.b.b[1] := ones(2,3);
		x.b[1].b := ones(2,3);
		x.b[2:3].b[2:3] := ones(2,2,2);
	end f2;
	
	constant Real x = f1(f2());
	Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval15",
            description="",
            flatModel="
fclass EvaluationTests.FunctionEval15
 constant Real x = 50.0;
 Real y = 50.0;

public
 function EvaluationTests.FunctionEval15.f1
  input EvaluationTests.FunctionEval15.R2[:] a;
  output Real x;
 algorithm
  assert(2 == size(a, 1), \"Mismatching sizes in function 'EvaluationTests.FunctionEval15.f1', component 'a', dimension '1'\");
  for i1 in 1:size(a, 1) loop
   assert(2 == size(a[i1].a, 1), \"Mismatching sizes in function 'EvaluationTests.FunctionEval15.f1', component 'a[i1].a', dimension '1'\");
   for i2 in 1:size(a[i1].a, 1) loop
    assert(2 == size(a[i1].a[i2].a, 1), \"Mismatching sizes in function 'EvaluationTests.FunctionEval15.f1', component 'a[i1].a[i2].a', dimension '1'\");
    assert(3 == size(a[i1].a[i2].b, 1), \"Mismatching sizes in function 'EvaluationTests.FunctionEval15.f1', component 'a[i1].a[i2].b', dimension '1'\");
   end for;
   assert(3 == size(a[i1].b, 1), \"Mismatching sizes in function 'EvaluationTests.FunctionEval15.f1', component 'a[i1].b', dimension '1'\");
   for i2 in 1:size(a[i1].b, 1) loop
    assert(2 == size(a[i1].b[i2].a, 1), \"Mismatching sizes in function 'EvaluationTests.FunctionEval15.f1', component 'a[i1].b[i2].a', dimension '1'\");
    assert(3 == size(a[i1].b[i2].b, 1), \"Mismatching sizes in function 'EvaluationTests.FunctionEval15.f1', component 'a[i1].b[i2].b', dimension '1'\");
   end for;
  end for;
  x := sum(a[1:2].a[1:2].a[1:2]) + sum(a[1:2].a[1:2].b[1:3]) + sum(a[1:2].b[1:3].a[1:2]) + sum(a[1:2].b[1:3].b[1:3]);
  return;
 end EvaluationTests.FunctionEval15.f1;

 function EvaluationTests.FunctionEval15.f2
  output EvaluationTests.FunctionEval15.R2[:] x;
 algorithm
  init x as EvaluationTests.FunctionEval15.R2[2];
  x[1:2].a[1:2].a[1:2] := ones(2, 2, 2);
  for i in 1:2 loop
   for j in 1:2 loop
    x[i].a[j].b[1:3] := {1, 1, 1};
    x[i].b[1:3].a[j] := x[i].a[j].b[1:3];
   end for;
  end for;
  x[1:2].b[1:3].b[1] := ones(2, 3);
  x[1:2].b[1].b[1:3] := ones(2, 3);
  x[1:2].b[2:3].b[2:3] := ones(2, 2, 2);
  return;
 end EvaluationTests.FunctionEval15.f2;

 record EvaluationTests.FunctionEval15.R1
  Real a[2];
  Real b[3];
 end EvaluationTests.FunctionEval15.R1;

 record EvaluationTests.FunctionEval15.R2
  EvaluationTests.FunctionEval15.R1 a[2];
  EvaluationTests.FunctionEval15.R1 b[3];
 end EvaluationTests.FunctionEval15.R2;

end EvaluationTests.FunctionEval15;
")})));
end FunctionEval15;


model FunctionEval16
	record R
		Real a;
		Real b;
	end R;
	
	function f1
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f1;
	
	function f2
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f2;
	
	parameter Real x = f2(f1(2));

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval16",
            description="Constant evaluation of functions: records",
            variables="x",
            values="6.0"
 )})));
end FunctionEval16;


model FunctionEval17
	record R
		Real a;
		Real b;
	end R;
	
	function f
		input Real a;
		output R x;
	algorithm
		x := R(a, 2*a);
	end f;
	
	parameter R x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval17",
            description="Constant evaluation of functions: records",
            variables="
x.a
x.b
",
            values="
2.0
4.0
")})));
end FunctionEval17;


model FunctionEval18
	record R
		Real a;
		Real b;
	end R;
	
	function f
		input R a;
		output Real x;
	algorithm
		x := a.a + a.b;
	end f;
	
	parameter Real x = f(R(1, 2));

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval18",
            description="Constant evaluation of functions: records",
            variables="x",
            values="3.0"
 )})));
end FunctionEval18;


model FunctionEval19
	record R1
		Real a[2];
		Real b[3];
	end R1;
	
	record R2
		R1 a[2];
		R1 b[3];
	end R2;
	
	function f1
		input R2 a[2];
		output Real x;
	algorithm
		x := sum(a.a.a) + sum(a.a.b) + sum(a.b.a) + sum(a.b.b);
	end f1;
	
	function f2
		output R2 x[2];
	algorithm
		x.a.a := ones(2,2,2);
		for i in 1:2, j in 1:2 loop
			x[i].a[j].b := {1, 1, 1};
			x[i].b.a[j] := x[i].a[j].b;
		end for;
		x.b.b[1] := ones(2,3);
		x.b[1].b := ones(2,3);
		x.b[2:3].b[2:3] := ones(2,2,2);
	end f2;
	
	parameter Real x = f1(f2());

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval19",
            description="Constant evaluation of functions: arrays of records",
            variables="x",
            values="50.0"
 )})));
end FunctionEval19;


model FunctionEval20
	function f
		input Real x[:];
		output Real y;
	algorithm
		y := x * x;
	end f;
	
	parameter Real a = f({1, 2});
	parameter Real b = f({1, 2, 3});

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval20",
            description="",
            variables="
a
b
",
            values="
5.0
14.0
")})));
end FunctionEval20;


model FunctionEval21
	function f
		input Real a;
		output Real b;
	algorithm
		assert(true, "Test");
		b := a;
	end f;
	
	parameter Real x = f(1);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval21",
            description="Evaluation of function containing assert()",
            variables="x",
            values="1.0"
 )})));
end FunctionEval21;

    
model FunctionEval22
	function f1
		input Real x1;
		input Real x2;
		output Real y;
	protected
		Real z1;
		Real z2;
	algorithm
		(z1, z2) := f2(x1, x2);
		y := z1 + z2;
    end f1;
	
    function f2
        input Real x1;
		input Real x2;
		output Real y1;
		output Real y2;
	algorithm
		y1 := x1 * x2;
		y2 := x1 + x2;
    end f2;
	
    parameter Real x = f1(1,2);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval22",
            description="Test evaluation of function containing function call statement using more than one output",
            variables="x",
            values="5.0"
 )})));
end FunctionEval22;

model FunctionEval23
    function f
        input Real x;
        output Real y;
    algorithm
        z := 5;
        y := x + z;
    end f;
	
    constant Real p = f(3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionEval23",
            description="",
            errorMessage="
3 errors found:

Error at line 6, column 9, in file 'Compiler/ModelicaFlatTree/test/modelica/EvaluationTests.mo':
  Cannot find class or component declaration for z

Error at line 7, column 18, in file 'Compiler/ModelicaFlatTree/test/modelica/EvaluationTests.mo':
  Cannot find class or component declaration for z

Error at line 10, column 23, in file 'Compiler/ModelicaFlatTree/test/modelica/EvaluationTests.mo':
  Could not evaluate binding expression for constant 'p': 'f(3)'
")})));
end FunctionEval23;

model FunctionEval24
	function f
		input Real x;
		output Real y;
	algorithm
		y := x;
	end f;
	
	constant Real z = f();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionEval24",
            description="",
            errorMessage="
2 errors found:

Error at line 9, column 20, in file 'Compiler/ModelicaFlatTree/test/modelica/EvaluationTests.mo':
  Calling function f(): missing argument for required input x

Error at line 9, column 20, in file 'Compiler/ModelicaFlatTree/test/modelica/EvaluationTests.mo':
  Could not evaluate binding expression for constant 'z': 'f()'
    Unspecified constant evaluation failure
")})));
end FunctionEval24;


model FunctionEval25
	function f
		input Real[:] x;
		output Integer y;
	algorithm
		y := 0;
		for i in 1:(size(x,1) - 1) loop
			y := y + i;
		end for;
	end f;
	
	Real x = f(ones(3));
    parameter Integer n = f(ones(4));
	Real z[n];

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval25",
            description="Check that functions containing scalar expressions depending on unknown sizes can be evaluated after being error checked",
            flatModel="
fclass EvaluationTests.FunctionEval25
 Real x = EvaluationTests.FunctionEval25.f(ones(3));
 structural parameter Integer n = 6 /* 6 */;
 Real z[6];

public
 function EvaluationTests.FunctionEval25.f
  input Real[:] x;
  output Integer y;
 algorithm
  y := 0;
  for i in 1:size(x, 1) - 1 loop
   y := y + i;
  end for;
  return;
 end EvaluationTests.FunctionEval25.f;

end EvaluationTests.FunctionEval25;
")})));
end FunctionEval25;


model FunctionEval26a
    record A
        Real x;
        Real y;
    end A;
    
    function f
        input Real x;
        output A a(x=x, y=x*x);
    algorithm
    end f;
    
    constant A a1 = f(2);
    constant A a2 = a1;

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval26a",
            description="Evaluation in instance tree of function with modifications on record variable",
            variables="
a1.x
a1.y
a2.x
a2.y
",
            values="
2.0
4.0
2.0
4.0
")})));
end FunctionEval26a;

model FunctionEval26b
    record A
        Real x;
        Real y;
    end A;
    
    function f
        input Real x;
        output A a(x=x, y=x*x);
    algorithm
    end f;
    
    A a1 = f(2);
    A a2 = a1;

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval26b",
            description="Evaluation in flat tree of function with modifications on record variable",
            eliminate_alias_variables=false,
            variables="
a1.x
a1.y
a2.x
a2.y
",
            values="
2.0
4.0
2.0
4.0
")})));
end FunctionEval26b;


model FunctionEval27
    function f
        input Real x;
        output Real y;
    algorithm
        y := x + 2;
        y := x * y;
    end f;
    
    function f2 = f;
    
    constant Real a1 = f2(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval27",
            description="Evaluation of function defined in short class decl",
            flatModel="
fclass EvaluationTests.FunctionEval27
 constant Real a1 = 8.0;

public
 function EvaluationTests.FunctionEval27.f
  input Real x;
  output Real y;
 algorithm
  y := x + 2;
  y := x * y;
  return;
 end EvaluationTests.FunctionEval27.f;

end EvaluationTests.FunctionEval27;
")})));
end FunctionEval27;


model FunctionEval28
    function f
        input Real x;
        output Real y;
    algorithm
        y := x + 2;
        y := x * y;
    end f;
    
    function f2 = f(x(min=1));
    
    constant Real a1 = f2(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval28",
            description="Evaluation of function defined in short class decl",
            flatModel="
fclass EvaluationTests.FunctionEval28
 constant Real a1 = 8.0;

public
 function EvaluationTests.FunctionEval28.f2
  input Real x;
  output Real y;
 algorithm
  y := x + 2;
  y := x * y;
  return;
 end EvaluationTests.FunctionEval28.f2;

end EvaluationTests.FunctionEval28;
")})));
end FunctionEval28;


model FunctionEval29
    function f
        input Real x;
        output Real y;
    algorithm
        y := x + 2;
        y := x * y;
    end f;
    
    function f2
        input Real x;
        output Real y;
    end f2;

    model A
        replaceable function f3 = f2;
    end A;

    model B
        extends A(redeclare function f3 = f(x = 2));
    end B;
    
    model C
        outer B b;
        constant Real x = b.f3(1);
    end B;
    
    inner B b;
    C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval29",
            description="",
            flatModel="
fclass EvaluationTests.FunctionEval29
 constant Real c.x = 3.0;

public
 function EvaluationTests.FunctionEval29.b.f3
  input Real x;
  output Real y;
 algorithm
  y := x + 2;
  y := x * y;
  return;
 end EvaluationTests.FunctionEval29.b.f3;

end EvaluationTests.FunctionEval29;
")})));
end FunctionEval29;

model FunctionEval30
    record R
        Real x;
    end R;
    function f2
        input Real  x;
        output Real y;
      algorithm
        y := x;
    end f2;
    function f1
        input Real x;
        output Real z;
      protected
        R y;
      algorithm
        (y.x) := f2(x);
        z := y.x;
    end f1;
    constant Real x = f1(3);

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval30",
            description="Constant evaluation of vector multiplication",
            variables="x",
            values="3.0"
 )})));
end FunctionEval30;

model FunctionEval31
    record R1
        Real x;
    end R2;
    record R2
        extends R1;
    end R2;
    function f
        input R2 r2;
        output Real y;
      algorithm
        y := r2.x;
    end f;
    
    constant Real y1 = f(R2(3));
    Real y2 = f(R2(3));

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval31",
            description="Constant evaluation record component in input",
            variables="
y1
y2
",
            values="
3.0
3.0
")})));
end FunctionEval31;

model FunctionEval32
    function f
        input Real[:] x;
        output Real[size(x,1)] y = zeros(n);
      protected
        Integer n = size(x,1);
        algorithm
    end f;
    
    constant Real[1] r = f({1}); 

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval32",
            description="Constant evaluation record component in input",
            variables="r[1]",
            values="0.0"
 )})));
end FunctionEval32;

model FunctionEval33
    function f
        input Integer x[:];
        output Integer y = sum(x);
    algorithm
    end f;
    
    parameter Integer n1 = f({1,2});
    Real x1[n1] = 1:n1;
    parameter Integer n2 = f({1,2,3});
    Real x2[n2] = 1:n2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval33",
            description="Evaluation of function with non-input with binding expression depending on unknown size",
            flatModel="
fclass EvaluationTests.FunctionEval33
 structural parameter Integer n1 = 3 /* 3 */;
 Real x1[3] = 1:3;
 structural parameter Integer n2 = 6 /* 6 */;
 Real x2[6] = 1:6;

public
 function EvaluationTests.FunctionEval33.f
  input Integer[:] x;
  output Integer y;
 algorithm
  y := sum(x[:]);
  return;
 end EvaluationTests.FunctionEval33.f;

end EvaluationTests.FunctionEval33;
")})));
end FunctionEval33;

model FunctionEval34
    function f
        input Real[n] x;
        input Integer n;
        output Real y;
      algorithm
        y := 0;
        for i in 1:n loop
            if x[i] > 1 then
                y := y + x[i];
            end if;
        end for;
    end f;
    
    constant Real y1 = f({1,2,4},3);
    Real y2 = f({1,2,4},3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionEval34",
            description="If statement in for statement",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.FunctionEval34
 constant Real y1 = 6.0;
 constant Real y2 = 6.0;
end EvaluationTests.FunctionEval34;
")})));
end FunctionEval34;

model FunctionEval35
    function f
        input Real[:,:] x;
        output Real[size(x,1),size(x,2)] y = x;
        output Real t = sum(x);
        algorithm
    end f;
    
    function fw
        input Real[:,:] x;
        output Real[size(x,1),size(x,2)] y;
        Real t;
      algorithm
        y := x;
        (y,t) := f(x);
    end fw;
    
    Real[1,1] y = fw({{1}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionEval35",
            description="Function call stmt assigning array with value",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.FunctionEval35
 constant Real y[1,1] = 1;
end EvaluationTests.FunctionEval35;
")})));
end FunctionEval35;

model FunctionEval36
    record R
        Real a;
    end R;
    
    function f1
        input Real x;
        output Real y;
    protected
        R r;
    algorithm
        (r.a) := f2(x);
        y := r.a + 1;
        annotation(Inline=true);
    end f1;
    
    function f2
        input Real x;
        output Real y;
    protected
        R r;
    algorithm
        y := x - 1;
        annotation(Inline=true);
    end f2;
    
    function f3
        input Real x;
        output Real y;
        output Real z;
    protected
        R r;
    algorithm
        y := f1(x);
        z := 1;
        annotation(Inline=true);
    end f3;
    
    Real x;
    Real y;
equation
    (x, y) = f3(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionEval36",
            description="Function call statement assigning record component",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.FunctionEval36
 constant Real x = 1.0;
 constant Real y = 1;
end EvaluationTests.FunctionEval36;
")})));
end FunctionEval36;


model FunctionEval37
    function f
        input Real x[2];
        input Integer i;
        output Real y;
    protected
        Real z = x[i];
    algorithm
        y := z;
    end f;

    constant Real x = f({1, 2}, 1);
    constant Real y = f({3, 4}, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionEval37",
            description="Evaluation of array index in binding expression of protected variable in function",
            flatModel="
fclass EvaluationTests.FunctionEval37
 constant Real x = 1;
 constant Real y = 4;
end EvaluationTests.FunctionEval37;
")})));
end FunctionEval37;

model FunctionEval38
    record R
        Real[:] x;
    end R;
    function f
        input R r;
        output Real x = r.x[end];
    algorithm
    end f;
    constant Real x1 = f(R({1,2}));
    Real x2 = f(R({1,2}));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionEval38",
            description="Evaluation of end exp",
            flatModel="
fclass EvaluationTests.FunctionEval38
 constant Real x1 = 2;
end EvaluationTests.FunctionEval38;
")})));
end FunctionEval38;

model FunctionEval39
    record R
        parameter Integer n;
        Real[n] x;
    end R;
    function f
        input R r;
        output Real x = r.x[end];
    algorithm
    end f;
    constant Real x1 = f(R(2,{1,2}));
    Real x2 = f(R(2,{1,2}));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionEval39",
            description="Evaluation of end exp",
            flatModel="
fclass EvaluationTests.FunctionEval39
 constant Real x1 = 2;
end EvaluationTests.FunctionEval39;
")})));
end FunctionEval39;

model FunctionEval40
    record R
        parameter Integer n;
    end R;
    
    function f
        input R r;
        output Real y;
    protected
        Real[r.n+1] N;
    algorithm
        N := 1:r.n+1;
        y := sum(N);
    end f;
    
    constant Real y = f(R(2));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionEval40",
            description="Evaluation of unknown array size in record",
            flatModel="
fclass EvaluationTests.FunctionEval40
 constant Real y = 6.0;
end EvaluationTests.FunctionEval40;
")})));
end FunctionEval40;

model FunctionEval41
    function F
        input Real[:] i;
        output Real o;
    algorithm
        o:= sqrt(i * i);
    end F;
    
    parameter Real a = F({1,2});
    parameter Real b = F({2,1});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval41",
            description="Evaluation of non-slice use",
            flatModel="
fclass EvaluationTests.FunctionEval41
 parameter Real a = EvaluationTests.FunctionEval41.F({1, 2}) /* evaluation error */;
 parameter Real b = EvaluationTests.FunctionEval41.F({2, 1}) /* evaluation error */;

public
 function EvaluationTests.FunctionEval41.F
  input Real[:] i;
  output Real o;
 algorithm
  o := sqrt(i[:] * i[:]);
  return;
 end EvaluationTests.FunctionEval41.F;

end EvaluationTests.FunctionEval41;
")})));
end FunctionEval41;

model FunctionEval42
    function f1
        input Real x;
        output Real y;
    end f1;
    
    function f2
        extends f1;
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
    end f2;
    
    constant Real a = f2(1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval42",
            description="Evaluation in instance tree of function that declares inherited inputs again",
            flatModel="
fclass EvaluationTests.FunctionEval42
 constant Real a = 2.0;

public
 function EvaluationTests.FunctionEval42.f2
  input Real x;
  output Real y;
 algorithm
  y := x + 1;
  return;
 end EvaluationTests.FunctionEval42.f2;

end EvaluationTests.FunctionEval42;
")})));
end FunctionEval42;

model FunctionEval43
    function F
        input Integer[:] x;
        output Real[sum(x)] y;
    algorithm
        for i in 1:sum(x) loop
            y[i] := i + sum(x);
        end for;
    end F;
    
    parameter Integer[:] p1 = {1,1};
    parameter Integer[:] p2 = {2};
    parameter Real[2] a1 = F(p1) + F(p2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval43",
            description="Test array caching bug #5118",
            flatModel="
fclass EvaluationTests.FunctionEval43
 structural parameter Integer p1[2] = {1, 1} /* { 1, 1 } */;
 structural parameter Integer p2[1] = {2} /* { 2 } */;
 structural parameter Real a1[2] = {6, 8} /* { 6, 8 } */;

public
 function EvaluationTests.FunctionEval43.F
  input Integer[:] x;
  output Real[:] y;
 algorithm
  init y as Real[sum(x[:])];
  for i in 1:sum(x[:]) loop
   y[i] := i + sum(x[:]);
  end for;
  return;
 end EvaluationTests.FunctionEval43.F;

end EvaluationTests.FunctionEval43;
")})));
end FunctionEval43;

model FunctionEval44
    constant Real[:] x = {sum(j for j in i:3) for i in 1:3};

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="FunctionEval44",
            description="Constant evaluation of iter exp containing function call",
            variables="
x[1]
x[2]
x[3]
",
            values="
6.0
5.0
3.0
")})));
end FunctionEval44;

model FunctionEval45
    function f
        input Real[:] x;
        output Real y = 0;
        Integer i = 1;
    algorithm
        while i <= size(x,1) loop
            y := y + sum(x[i:size(x,1)]);
            i := i + 1;
        end while;
    end f;
    constant Real y = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval45",
            description="Constant evaluation of functions: records",
            flatModel="
fclass EvaluationTests.FunctionEval45
 constant Real y = 14.0;

public
 function EvaluationTests.FunctionEval45.f
  input Real[:] x;
  output Real y;
  Integer i;
 algorithm
  y := 0;
  i := 1;
  while i <= size(x, 1) loop
   y := y + sum(x[i:size(x, 1)]);
   i := i + 1;
  end while;
  return;
 end EvaluationTests.FunctionEval45.f;

end EvaluationTests.FunctionEval45;
")})));
end FunctionEval45;

model FunctionEval46
    function f
        input Real[:] xs1;
        input Real[:] xs2;
        output Real y;
    algorithm
        y := 0;
        for x1 in xs1, x2 in xs2 loop
            y := x1 + x2;
        end for;
    end f;
    
    constant Real y = f({0.5},{0.5});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FunctionEval46",
            description="Constant evaluation of functions: real for index",
            flatModel="
fclass EvaluationTests.FunctionEval46
 constant Real y = 1.0;

public
 function EvaluationTests.FunctionEval46.f
  input Real[:] xs1;
  input Real[:] xs2;
  output Real y;
 algorithm
  y := 0;
  for x1 in xs1 loop
   for x2 in xs2 loop
    y := x1 + x2;
   end for;
  end for;
  return;
 end EvaluationTests.FunctionEval46.f;

end EvaluationTests.FunctionEval46;
")})));
end FunctionEval46;

model VectorFuncEval1
    function f
        input Real x;
        output Real y = x + x;
        algorithm
    end f;
    constant Real[2] y1 = f({1,2});
    Real[2] y2 = f({1,2});
    
    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="VectorFuncEval1",
            description="Constant evaluation of vectorized function call",
            variables="
y1[1]
y1[2]
y2[1]
y2[2]
",
            values="
2.0
4.0
2.0
4.0
")})));
end VectorFuncEval1;

model VectorFuncEval2
    function f
        input Real x1;
        input Real[:] x2;
        output Real y = x1 + sum(x2);
        algorithm
    end f;
    constant Real[3] y1 = f({1,2,3},{{1,2},{3,4},{5,6}});
    Real[3] y2 = f({1,2,3},{{1,2},{3,4},{5,6}});
    
    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="VectorFuncEval2",
            description="Constant evaluation of vectorized function call",
            variables="
y1[1]
y1[2]
y1[3]
y2[1]
y2[2]
y2[3]
",
            values="
4.0
9.0
14.0
4.0
9.0
14.0
")})));
end VectorFuncEval2;

model VectorFuncEval3
    function f
        input Real x1;
        input Real[:] x2;
        input Real[:,:] x3;
        output Real y = x1 + sum(x2) + sum(x3);
        algorithm
    end f;
    constant Real[3] y1 = f({1,2,3},{{1,2},{3,4},{5,6}}, {{1},{2},{3}});
    
    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="VectorFuncEval3",
            description="Constant evaluation of vectorized function call",
            variables="
y1[1]
y1[2]
y1[3]
",
            values="
10.0
15.0
20.0
")})));
end VectorFuncEval3;

model VectorFuncEval4
    function f
        input Real x1;
        input Real[:] x2;
        input Real[:,:] x3;
        output Real y = x1 + sum(x2) + sum(x3);
        algorithm
    end f;
    constant Real[3] y1 = f(3,{{1,2},{3,4},{5,6}}, {{{1},{1}},{{2},{2}},{{3},{3}}});
    
    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="VectorFuncEval4",
            description="Constant evaluation of vectorized function call",
            variables="
y1[1]
y1[2]
y1[3]
",
            values="
8.0
14.0
20.0
")})));
end VectorFuncEval4;

model VectorFuncEval5
    function f
            input Real x1;
            input Real[:] x2;
            output Real y = x1;
        algorithm
    end f;
    Real[:,:] y = f({{time,time}}, {{{time},{time}}});
    Real[1,2] y1 = f({{1,2}}, {{{3},{4}}});

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="VectorFuncEval5",
            description="Constant evaluation of vectorized function call",
            variables="
y1[1,1]
y1[1,2]
",
            values="
1.0
2.0
")})));
end VectorFuncEval5;

model StringConcat
 Real a = 1;
 parameter String b = "1" + "2";
 parameter String[2] c = { "1", "2" } .+ "3";
 parameter String[2] d = { "1", "2" } + { "3", "4" };

    annotation(__JModelica(UnitTesting(tests={
        EvalTestCase(
            name="StringConcat",
            description="",
            variables="
b
c[1]
c[2]
d[1]
d[2]
",
            values="
\"12\"
\"13\"
\"23\"
\"13\"
\"24\"
")})));
end StringConcat;

model ParameterEval1
	parameter Real[:,:] a = b;
	parameter Real[:,:] b = c;
	parameter Real[:,:] c = d;
	parameter Real[:,:] d = e;
	parameter Real[:,:] e = f;
	parameter Real[:,:] f = g;
	parameter Real[:,:] g = h;
	parameter Real[:,:] h = {{0,1,2,3,4,5,6,7,8,9},{10,11,12,13,14,15,16,17,18,19},{20,21,22,23,24,25,26,27,28,29},{30,31,32,33,34,35,36,37,38,39},{40,41,42,43,44,45,46,47,48,49},{50,51,52,53,54,55,56,57,58,59},{60,61,62,63,64,65,66,67,68,69},{70,71,72,73,74,75,76,77,78,79},{80,81,82,83,84,85,86,87,88,89},{90,91,92,93,94,95,96,97,98,99}};
	Boolean x;
equation
x = if a[1,1] > a[1,2] then true else false;

    annotation(__JModelica(UnitTesting(tests={
        TimeTestCase(
            name="ParameterEval1",
            description="Make sure time complexity of evaluation of array parameters is of an acceptable order",
            maxTime=2.0
 )})));
end ParameterEval1;

model EvalInheritedAnnotation
    model BaseEvalFalse
        parameter Real x(start=1);
        parameter Real y(start=3);
        replaceable parameter Real z = x + y annotation(Evaluate=false);
    end BaseEvalFalse;
    
    model EvalTrue
        extends BaseEvalFalse(redeclare replaceable parameter Real z = 2*x + y annotation(Evaluate=true)); 
    end EvalTrue;
    
    model EvalStillTrue
        extends EvalTrue(redeclare replaceable parameter Real z = 3*x + y); 
        annotation(__JModelica(UnitTesting(tests={
            FlatteningTestCase(
                name="C",
                description="Evaluate primitives without binding exp",
                flatModel="
        fclass EvaluationTests.EvalInheritedAnnotation.EvalStillTrue
         structural parameter Real x = 1 /* 1 */;
         structural parameter Real y = 3 /* 3 */;
         eval parameter Real z = 6.0 /* 6.0 */;
        end EvaluationTests.EvalInheritedAnnotation.EvalStillTrue;
    ")})));
    end EvalStillTrue;
    
    model EvalStillTrue2
        extends EvalStillTrue;
        annotation(__JModelica(UnitTesting(tests={
            FlatteningTestCase(
                name="D",
                description="Evaluate primitives without binding exp",
                flatModel="
        fclass EvaluationTests.EvalInheritedAnnotation.EvalStillTrue2
         structural parameter Real x = 1 /* 1 */;
         structural parameter Real y = 3 /* 3 */;
         eval parameter Real z = 6.0 /* 6.0 */;
        end EvaluationTests.EvalInheritedAnnotation.EvalStillTrue2;
    ")})));
    end EvalStillTrue2;
    
    model EvalDefaultFalse
        extends EvalStillTrue2(redeclare replaceable parameter Real z = y annotation());
        annotation(__JModelica(UnitTesting(tests={
            FlatteningTestCase(
                name="E",
                description="Evaluate primitives without binding exp",
                flatModel="
        fclass EvaluationTests.EvalInheritedAnnotation.EvalDefaultFalse
         parameter Real x(start = 1);
         parameter Real y(start = 3);
         parameter Real z = y;
        end EvaluationTests.EvalInheritedAnnotation.EvalDefaultFalse;
    ")})));
    end EvalDefaultFalse;
end EvalInheritedAnnotation;



model EvalNoBinding1
    parameter Real x(start=1);
    parameter Real y(start=3);
    parameter Real z = x + y annotation(Evaluate=true);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvalNoBinding1",
            description="Evaluate primitives without binding exp",
            flatModel="
fclass EvaluationTests.EvalNoBinding1
 structural parameter Real x = 1 /* 1 */;
 structural parameter Real y = 3 /* 3 */;
 eval parameter Real z = 4.0 /* 4.0 */;
end EvaluationTests.EvalNoBinding1;
")})));
end EvalNoBinding1;

model EvalNoBinding2
    parameter Real x[2,2](start={{1,2},{3,4}});
    parameter Real y[2,2](each start=5);
    parameter Real z1[2,2] = x + y annotation(Evaluate=true);
    parameter Real z2 = sum({{x[i,j] + y[i,j] for i in 1:2} for j in 1:2});
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvalNoBinding2",
            description="Evaluate array primitives without binding exp",
            flatModel="
fclass EvaluationTests.EvalNoBinding2
 structural parameter Real x[2,2] = {{1, 2}, {3, 4}} /* { { 1, 2 }, { 3, 4 } } */;
 structural parameter Real y[2,2] = {{5, 5}, {5, 5}} /* { { 5, 5 }, { 5, 5 } } */;
 eval parameter Real z1[2,2] = {{6.0, 7.0}, {8.0, 9.0}} /* { { 6.0, 7.0 }, { 8.0, 9.0 } } */;
 structural parameter Real z2 = 30.0 /* 30.0 */;
end EvaluationTests.EvalNoBinding2;
")})));
end EvalNoBinding2;

model EvalNoBinding3
    record R
        parameter Real x(start=2);
        Real[2,2] c(start={{3,4},{5,6}});
        Real[2,2] d(each start=7);
    end R;
    
    parameter R r1 annotation(Evaluate=true);
    parameter R r2 = r1 annotation(Evaluate=true);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvalNoBinding3",
            description="Evaluate primitives in record without binding exp",
            flatModel="
fclass EvaluationTests.EvalNoBinding3
 eval parameter EvaluationTests.EvalNoBinding3.R r1 = EvaluationTests.EvalNoBinding3.R(2, {{3, 4}, {5, 6}}, {{7, 7}, {7, 7}}) /* EvaluationTests.EvalNoBinding3.R(2, { { 3, 4 }, { 5, 6 } }, { { 7, 7 }, { 7, 7 } }) */;
 eval parameter EvaluationTests.EvalNoBinding3.R r2 = EvaluationTests.EvalNoBinding3.R(2, {{3, 4}, {5, 6}}, {{7, 7}, {7, 7}}) /* EvaluationTests.EvalNoBinding3.R(2, { { 3, 4 }, { 5, 6 } }, { { 7, 7 }, { 7, 7 } }) */;

public
 record EvaluationTests.EvalNoBinding3.R
  parameter Real x;
  Real c[2,2];
  Real d[2,2];
 end EvaluationTests.EvalNoBinding3.R;

end EvaluationTests.EvalNoBinding3;
")})));
end EvalNoBinding3;

model EvalNoBinding4
    record R
        parameter Real x(start=2);
        Real[2,2] c(start={{3,4},{5,6}});
        Real[2,2] d(each start=7);
    end R;
    
    parameter R r[2,2] annotation(Evaluate=true);
    parameter Real[2,2] x = {{r[i,j].c[i,j] + r[i,j].d[i,j] for j in 1:2} for i in 1:2} annotation(Evaluate=true);
    parameter Real y = sum({{r[i,j].x for j in 1:2} for i in 1:2}) annotation(Evaluate=true);
        
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvalNoBinding4",
            description="Evaluate primitives in record array without binding exp",
            flatModel="
fclass EvaluationTests.EvalNoBinding4
 eval parameter EvaluationTests.EvalNoBinding4.R r[2,2] = {{EvaluationTests.EvalNoBinding4.R(2, {{3, 4}, {5, 6}}, {{7, 7}, {7, 7}}), EvaluationTests.EvalNoBinding4.R(2, {{3, 4}, {5, 6}}, {{7, 7}, {7, 7}})}, {EvaluationTests.EvalNoBinding4.R(2, {{3, 4}, {5, 6}}, {{7, 7}, {7, 7}}), EvaluationTests.EvalNoBinding4.R(2, {{3, 4}, {5, 6}}, {{7, 7}, {7, 7}})}} /* { { EvaluationTests.EvalNoBinding4.R(2, { { 3, 4 }, { 5, 6 } }, { { 7, 7 }, { 7, 7 } }), EvaluationTests.EvalNoBinding4.R(2, { { 3, 4 }, { 5, 6 } }, { { 7, 7 }, { 7, 7 } }) }, { EvaluationTests.EvalNoBinding4.R(2, { { 3, 4 }, { 5, 6 } }, { { 7, 7 }, { 7, 7 } }), EvaluationTests.EvalNoBinding4.R(2, { { 3, 4 }, { 5, 6 } }, { { 7, 7 }, { 7, 7 } }) } } */;
 eval parameter Real x[2,2] = {{10.0, 11.0}, {12.0, 13.0}} /* { { 10.0, 11.0 }, { 12.0, 13.0 } } */;
 eval parameter Real y = 8.0 /* 8.0 */;

public
 record EvaluationTests.EvalNoBinding4.R
  parameter Real x;
  Real c[2,2];
  Real d[2,2];
 end EvaluationTests.EvalNoBinding4.R;

end EvaluationTests.EvalNoBinding4;
")})));
end EvalNoBinding4;

model EvalNoBinding5
    class A
        extends ExternalObject;
        
        function constructor
            input Real b;
            output A a;
            external;
        end constructor;
        
        function destructor
            input A a;
            external;
        end destructor;
    end A;
    
    function f
        input A a;
        output Integer b;
        external;
    end f;
    
    parameter A a;
    parameter Integer n = f(a);
    Real x[n] = (1:n) * time;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="EvalNoBinding5",
            description="Constant eval of external object lacking binding exp",
            errorMessage="
3 errors found:

Error at line 23, column 5, in file '...', EXTERNAL_OBJECT_MISSING_BINDING_EXPRESSION:
  The external object 'a' does not have a binding expression

Error at line 24, column 27, in file 'Compiler/ModelicaFlatTree/test/modelica/EvaluationTests.mo':
  Could not evaluate binding expression for structural parameter 'n': 'f(a)'
    in function 'EvaluationTests.EvalNoBinding5.f'
    Could not evaluate external function, unknown values in arguments

Error at line 25, column 12, in file 'Compiler/ModelicaFlatTree/test/modelica/EvaluationTests.mo':
  Could not evaluate array size expression: n
")})));
end EvalNoBinding5;



model EvalColonSizeCell
    function f
        input Real[:] x;
        output Real[size(x, 1) + 1] y;
    algorithm
		for i in 1:size(x,1) loop
            y[i] := x[i] / 2;
			y[i + 1] := y[i] + 1;
		end for;
    end f;
    
    parameter Real a[1] = {1};
    parameter Real b[2] = f(a);
    parameter Real c[1] = if b[1] > 0.1 then {1} else {0} annotation (Evaluate=true);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvalColonSizeCell",
            description="Evaluation of function returning array dependent on colon size",
            flatModel="
fclass EvaluationTests.EvalColonSizeCell
 structural parameter Real a[1] = {1} /* { 1 } */;
 structural parameter Real b[2] = {0.5, 1.5} /* { 0.5, 1.5 } */;
 eval parameter Real c[1] = {1} /* { 1 } */;

public
 function EvaluationTests.EvalColonSizeCell.f
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1) + 1];
  for i in 1:size(x, 1) loop
   y[i] := x[i] / 2;
   y[i + 1] := y[i] + 1;
  end for;
  return;
 end EvaluationTests.EvalColonSizeCell.f;

end EvaluationTests.EvalColonSizeCell;
")})));
end EvalColonSizeCell;


model SignEval1
	constant Integer a1 = sign(-1.0);
    constant Integer a2 = a1;
    constant Integer b1 = sign(-0.5);
    constant Integer b2 = b1;
    constant Integer c1 = sign(0.0);
    constant Integer c2 = c1;
    constant Integer d1 = sign(0.5);
    constant Integer d2 = d1;
    constant Integer e1 = sign(1.0);
    constant Integer e2 = e1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SignEval1",
            description="Test constant evaluation of sign()",
            flatModel="
fclass EvaluationTests.SignEval1
 constant Integer a1 = -1;
 constant Integer a2 = -1;
 constant Integer b1 = -1;
 constant Integer b2 = -1;
 constant Integer c1 = 0;
 constant Integer c2 = 0;
 constant Integer d1 = 1;
 constant Integer d2 = 1;
 constant Integer e1 = 1;
 constant Integer e2 = 1;
end EvaluationTests.SignEval1;
")})));
end SignEval1;

model ParameterEvalAnnotation1
	parameter Real[3] p1 = {1,2,3} annotation (Evaluate=true);
	Real[3] r;
equation
	r = {1,2,3} .* p1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ParameterEvalAnnotation1",
            description="Test constant evaluation Evaluate parameter",
            flatModel="
fclass EvaluationTests.ParameterEvalAnnotation1
 eval parameter Real p1[1] = 1 /* 1 */;
 eval parameter Real p1[2] = 2 /* 2 */;
 eval parameter Real p1[3] = 3 /* 3 */;
 constant Real r[1] = 1.0;
 constant Real r[2] = 4.0;
 constant Real r[3] = 9.0;
end EvaluationTests.ParameterEvalAnnotation1;
")})));
end ParameterEvalAnnotation1;

model ParameterEvalAnnotation2
	
	parameter Real p;
	parameter Real dp = p;
	parameter Real p1 = 1 annotation (Evaluate=true);
	parameter Real p2 = p1 + c;
	parameter Real p3 = 3*p2 + 3;
	parameter Real p4 = p1 + p;
	parameter Real p5 = p3 + dp;
	
	constant Real c = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ParameterEvalAnnotation2",
            description="Test constant evaluation Evaluate parameter",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.ParameterEvalAnnotation2
 parameter Real p;
 parameter Real dp;
 eval parameter Real p1 = 1 /* 1 */;
 structural parameter Real p2 = 2.0 /* 2.0 */;
 structural parameter Real p3 = 9.0 /* 9.0 */;
 parameter Real p4;
 parameter Real p5;
 constant Real c = 1;
parameter equation
 dp = p;
 p4 = 1.0 + p;
 p5 = 9.0 + dp;
end EvaluationTests.ParameterEvalAnnotation2;
")})));
end ParameterEvalAnnotation2;

model ParameterEvalAnnotation3
	
function f
	input Real[2] i;
	output Real[2] o = i;
algorithm
end f;

function fs
	input Real a;
	output Real b = a;
algorithm
end fs;

	constant Real[2] c = {1,2};
	parameter Real[2] x = {1,2} + 2*f(c) annotation(Evaluate=true);
	parameter Real[2] y = {1,2} + 2*fs(x);
	parameter Real[2] z = 2*f(y);
equation

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ParameterEvalAnnotation3",
            description="Test constant evaluation Evaluate parameter",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.ParameterEvalAnnotation3
 constant Real c[1] = 1;
 constant Real c[2] = 2;
 eval parameter Real x[1] = 3 /* 3 */;
 eval parameter Real x[2] = 6 /* 6 */;
 structural parameter Real y[1] = 7 /* 7 */;
 structural parameter Real y[2] = 14 /* 14 */;
 structural parameter Real z[1] = 14 /* 14 */;
 structural parameter Real z[2] = 28 /* 28 */;
end EvaluationTests.ParameterEvalAnnotation3;
")})));
end ParameterEvalAnnotation3;


model ConstantInRecord1
    record A
        constant Real a = 1;
        constant Real b = a + 1;
    end A;
    
    constant Real c = A.a;
    constant Real d = A.b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConstantInRecord1",
            description="Evaluation of constants in records",
            flatModel="
fclass EvaluationTests.ConstantInRecord1
 constant Real c = 1;
 constant Real d = 2.0;
end EvaluationTests.ConstantInRecord1;
")})));
end ConstantInRecord1;


model ShortClassWithInstanceNameHelper
    model A
        constant String b = getInstanceName();
    end A;
    
    A a;
    parameter Real c = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ShortClassWithInstanceNameHelper",
            description="",
            flatModel="
fclass EvaluationTests.ShortClassWithInstanceNameHelper
 constant String a.b = \"ShortClassWithInstanceNameHelper.a\";
 parameter Real c = 1 /* 1 */;
end EvaluationTests.ShortClassWithInstanceNameHelper;
")})));
end ShortClassWithInstanceNameHelper;


// TODO: this test gives the wrong value (may not be able to fix that in a reasonable way, since simple short class decl is only a pointer)
model ShortClassWithInstanceName1 = ShortClassWithInstanceNameHelper

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ShortClassWithInstanceName1",
            description="Check that getInstaneName() works correctly for short class declarations",
            flatModel="
fclass EvaluationTests.ShortClassWithInstanceName1
 constant String a.b = \"ShortClassWithInstanceNameHelper.a\";
 parameter Real c = 1 /* 1 */;
end EvaluationTests.ShortClassWithInstanceName1;
")})));


model ShortClassWithInstanceName2 = ShortClassWithInstanceNameHelper(c = 2)
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ShortClassWithInstanceName2",
            description="Check that getInstaneName() works correctly for short class declarations",
            flatModel="
fclass EvaluationTests.ShortClassWithInstanceName2
 constant String a.b = \"ShortClassWithInstanceName2.a\";
 parameter Real c = 2 /* 2 */;
end EvaluationTests.ShortClassWithInstanceName2;
")})));


model FuncInArrayExpEval1
    function f
        input Real x;
        output Real[2] y;
    algorithm
        y := {x, x - 1};
    end f;
    
    parameter Real[2] a = {1, 2};
    parameter Real[2] b = a + f(m);
    parameter Integer n = integer(b[1]);
	parameter Integer m = 2;
    Real x[n] = (1:n) * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FuncInArrayExpEval1",
            description="Constant evaluation of array binary expression containing function call returning array",
            variability_propagation=false,
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass EvaluationTests.FuncInArrayExpEval1
 structural parameter Real a[1] = 1 /* 1 */;
 structural parameter Real a[2] = 2 /* 2 */;
 structural parameter Real b[1] = 3.0 /* 3.0 */;
 structural parameter Real b[2] = 3.0 /* 3.0 */;
 structural parameter Integer n = 3 /* 3 */;
 structural parameter Integer m = 2 /* 2 */;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = time;
 x[2] = 2 * time;
 x[3] = 3 * time;
end EvaluationTests.FuncInArrayExpEval1;
")})));
end FuncInArrayExpEval1;

model PreExp1
    Integer x = 1;
    Integer y = pre(x);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PreExp1",
            description="Constant evaluation of pre exp.",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.PreExp1
 constant Integer x = 1;
 constant Integer y = 1;
end EvaluationTests.PreExp1;
")})));
end PreExp1;

model Delay1
    constant Real x1 = delay(1,1);
    Real x2 = delay(2,1);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Delay1",
            description="Constant evaluation of delay operator.",
            flatModel="
fclass EvaluationTests.Delay1
 constant Real x1 = 1;
 constant Real x2 = 2;
end EvaluationTests.Delay1;
")})));
end Delay1;

model SpatialDistribution1
    constant Real x1 = spatialDistribution(1,1,1,false);
    Real x2,x3;
  equation
    (x2,x3) = spatialDistribution(2,1,1,true, {0,1}, {3,4});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SpatialDistribution1",
            description="Constant evaluation of spatialDistribution operator",
            flatModel="
fclass EvaluationTests.SpatialDistribution1
 constant Real x1 = 0.0;
 constant Real x2 = 3;
 constant Real x3 = 4;
end EvaluationTests.SpatialDistribution1;
")})));
end SpatialDistribution1;

model SpatialDistribution2
    constant Real[3] x1 = spatialDistribution({1,2,3},{1,2,3},1,false);
    constant Real[3] x2 = spatialDistribution({2,3,4},{2,3,4},1,true,{0,0.5,1},{{0,1,2},{3,4,5},{6,7,8}});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SpatialDistribution2",
            description="Constant evaluation of vectorized spatialDistribution operator",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.SpatialDistribution2
 constant Real x1[1] = 0.0;
 constant Real x1[2] = 0.0;
 constant Real x1[3] = 0.0;
 constant Real x2[1] = 0;
 constant Real x2[2] = 3;
 constant Real x2[3] = 6;
end EvaluationTests.SpatialDistribution2;
")})));
end SpatialDistribution2;

model Functional1
    partial function partFunc
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
      algorithm
        y := 3;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        output Real y;
      algorithm
        y := pf();
    end usePartFunc;
    
    constant Real c1 = usePartFunc(function fullFunc());
    Real y1 = usePartFunc(function fullFunc());
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional1",
            description="Constant evaluation of functional input arguments, zero inputs",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional1
 constant Real c1 = 3;
 constant Real y1 = 3;
end EvaluationTests.Functional1;
")})));
end Functional1;

model Functional2
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      algorithm
        y := pf(x);
    end usePartFunc;
    
    constant Real c1 = usePartFunc(function fullFunc(), 3);
    Real y1 = usePartFunc(function fullFunc(), 3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional2",
            description="Constant evaluation of functional input arguments, zero inputs, one partial input",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional2
 constant Real c1 = 9.0;
 constant Real y1 = 9.0;
end EvaluationTests.Functional2;
")})));
end Functional2;

model Functional3
    partial function partFunc
        input Real x1;
        input Integer x2;
        output Real y1;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x3;
        input Integer x4;
        output Real y2;
      algorithm
        y1 := x1*x2 + x3*x4;
        y2 := y1 + 1;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Integer x;
        output Real y;
      algorithm
        y := pf(x,x+1);
    end usePartFunc;
    
    constant Real c1 = usePartFunc(function fullFunc(x3=1,x4=2), 3);
    Real y1 = usePartFunc(function fullFunc(x3=1,x4=2), 3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional3",
            description="Constant evaluation of functional input arguments, many inputs",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional3
 constant Real c1 = 14.0;
 constant Real y1 = 14.0;
end EvaluationTests.Functional3;
")})));
end Functional3;

model Functional4
    partial function partFunc
        input Real x1 = 1;
        input Integer x2 = 2;
        output Real y1 = x1 * x2;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x3 = 10;
        input Integer x4 = 11;
      algorithm
        y1 := y1 + x3*x4;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Integer x;
        output Real y;
      algorithm
        y := pf(x) + pf(x1=x) + pf(x2=x);
    end usePartFunc;
    
    constant Real c1 = usePartFunc(function fullFunc(x3=100), 3);
    constant Real c2 = usePartFunc(function fullFunc(x4=100), 3);
    Real y1 = usePartFunc(function fullFunc(x3=100), 3);
    Real y2 = usePartFunc(function fullFunc(x4=100), 3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional4",
            description="Constant evaluation of functional input arguments, binding expressions",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional4
 constant Real c1 = 3315.0;
 constant Real c2 = 3015.0;
 constant Real y1 = 3315.0;
 constant Real y2 = 3015.0;
end EvaluationTests.Functional4;
")})));
end Functional4;

model Functional5
    partial function partFunc1
        input Real x1;
        output Real y1;
    end partFunc1;
    
    partial function partFunc2
        extends partFunc1;
        input Real x2;
    end partFunc2;
    
    function fullFunc
        extends partFunc2;
        input Real x3;
      algorithm
        y1 := x1*x2*x3;
    end fullFunc;
    
    function usePartFunc
        input partFunc1 pf1;
        input partFunc2 pf2;
        input Integer x;
        output Real y;
        Real t1,t2;
      algorithm
        y := pf1(x) + pf2(x,2);
    end usePartFunc;
    
    constant Real c1 = usePartFunc(function fullFunc(x2=2,x3=1), function fullFunc(x3=2), 3);
    Real y1 = usePartFunc(function fullFunc(x2=2,x3=1), function fullFunc(x3=2), 3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional5",
            description="Constant evaluation of functional input arguments, multiple extend levels",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional5
 constant Real c1 = 18.0;
 constant Real y1 = 18.0;
end EvaluationTests.Functional5;
")})));
end Functional5;

model Functional6
    partial function partFunc1
        input Real x1;
        output Real y1;
    end partFunc1;
    
    partial function partFunc2
        extends partFunc1;
        input Real x2;
        output Real y2;
    end partFunc2;
    
    function fullFunc
        extends partFunc2;
        input Real x3;
      algorithm
        y1 := x1*x2*x3;
        y2 := 1;
    end fullFunc;
    
    function usePartFunc
        input partFunc1 pf1;
        input partFunc2 pf2;
        input Integer x;
        output Real y;
      protected
        Real t1,t2;
      algorithm
        (t1,t2) := pf2(x,2);
        y := pf1(x) + t1 + t2;
    end usePartFunc;
    
    constant Real c1 = usePartFunc(function fullFunc(x2=2,x3=1), function fullFunc(x3=2), 3);
    Real y1 = usePartFunc(function fullFunc(x2=2,x3=1), function fullFunc(x3=2), 3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional6",
            description="Constant evaluation of functional input arguments, multiple outputs",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional6
 constant Real c1 = 19.0;
 constant Real y1 = 19.0;
end EvaluationTests.Functional6;
")})));
end Functional6;

model Functional7
    partial function partFunc
        input Real x1;
        output Real y;
    end partFunc;
    
    partial function middleFunc
        extends partFunc;
        input Real x2;
    end middleFunc;
    
    function fullFunc
        extends middleFunc;
        input Real x3;
      algorithm
        y := x1 + x2 + x3;
    end fullFunc;
    
    function useMiddleFunc
        input middleFunc mf;
        input Real b;
        input Real c;
        output Real y = usePartFunc(function mf(x2=b), c);
        algorithm
    end useMiddleFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real c;
        output Real y;
      algorithm
        y := pf(c);
    end usePartFunc;
    
    constant Real c1 = useMiddleFunc(function fullFunc(x3=1), 2, 3);
    Real y1 = useMiddleFunc(function fullFunc(x3=1), 2, 3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional7",
            description="Constant evaluation of functional input arguments, chained",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional7
 constant Real c1 = 6.0;
 constant Real y1 = 6.0;
end EvaluationTests.Functional7;
")})));
end Functional7;

model Functional8
    partial function partFunc
        input Real x1;
        output Real y;
    end partFunc;
    
    function partAlias = partFunc;
    
    partial function middleFunc
        extends partAlias;
        input Real x2;
    end middleFunc;
    
    function middleAlias = middleFunc;
    
    function fullFunc
        extends middleAlias;
        input Real x3;
      algorithm
        y := x1 + x2 + x3;
    end fullFunc;
    
    function fullAlias = fullFunc;
    
    function useMiddleFunc
        input middleAlias mf;
        input Real b;
        input Real c;
        output Real y = usePartAlias(function mf(x2=b), c);
        algorithm
    end useMiddleFunc;
    
    function useMiddleAlias = useMiddleFunc;
    
    function usePartFunc
        input partAlias pf;
        input Real c;
        output Real y;
      algorithm
        y := pf(c);
    end usePartFunc;
    
    function usePartAlias = usePartFunc;
    
    constant Real c1 = useMiddleAlias(function fullAlias(x3=1), 2, 3);
    Real y1 = useMiddleAlias(function fullAlias(x3=1), 2, 3);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional8",
            description="Constant evaluation of functional input arguments, chained with shortclassdecls",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional8
 constant Real c1 = 6.0;
 constant Real y1 = 6.0;
end EvaluationTests.Functional8;
")})));
end Functional8;


model Functional9
    partial function partFunc
        input Real x1;
        input Real x3;
        input Real x5;
        output Real y;
    end partFunc;
    
    function fullFunc
        input Real x1;
        input Real x2;
        input Real x3;
        input Real x4;
        input Real x5;
        output Real y;
      algorithm
        y := x1 + x2 + x3 + x4 + x5;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        output Real y;
      algorithm
        y := pf(1,3,5);
    end usePartFunc;
    
    function usePartAlias = usePartFunc;
    
    constant Real c1 = usePartFunc(function fullFunc(x2=2, x4=4));
    Real y1 = usePartFunc(function fullFunc(x2=2, x4=4));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Functional9",
            description="Constant evaluation of functional input arguments. Interleaving binds.",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Functional9
 constant Real c1 = 15.0;
 constant Real y1 = 15.0;
end EvaluationTests.Functional9;
")})));
end Functional9;

// Checks evaluation of partially unknown expressions
package Partial
    model Mul1
        function f
            input Real x1;
            input Real x2;
            output Real y = x1 * x2 + x2 * x1;
            output Real dummy;
            algorithm
        end f;
        Real y;
      equation
       (y, ) = f(0,time);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Mul1",
            description="Evaluation of multiplication with zero and unknown",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.Mul1
 constant Real y = 0.0;
end EvaluationTests.Partial.Mul1;
")})));
    end Mul1;
    
    model Mul2
        function f
            input Real[:] x1;
            input Real[:] x2;
            output Real y = x1 * x2 + x2 * x1;
            output Real dummy;
            algorithm
        end f;
        Real y;
      equation
        (y, ) = f({0,0},{time,time});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Mul2",
            description="Evaluation of multiplication with zero and unknown",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.Mul2
 constant Real y = 0.0;
end EvaluationTests.Partial.Mul2;
")})));
    end Mul2;
    
    model Mul3
        function f
            input Real[:] x1;
            input Real[:] x2;
            output Real[size(x1,1)] y = x1 .* x2 + x2 .* x1;
            algorithm
        end f;
        Real[2] y = f({0,0},{time,time});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Mul3",
            description="Evaluation of multiplication with zero and unknown",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Partial.Mul3
 constant Real y[1] = 0.0;
 constant Real y[2] = 0.0;
end EvaluationTests.Partial.Mul3;
")})));
    end Mul3;
    
    model Mul4
        function f
            input Real[:,:] x1;
            input Real[:,:] x2;
            output Real[size(x1,1),size(x2,2)] y = x1 * x2 + x2 * x1;
            algorithm
        end f;
        Real[2,2] y = f({{0,0},{0,0}},{{time,time}, {time,time}});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Mul4",
            description="Evaluation of multiplication with zero and unknown",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Partial.Mul4
 constant Real y[1,1] = 0.0;
 constant Real y[1,2] = 0.0;
 constant Real y[2,1] = 0.0;
 constant Real y[2,2] = 0.0;
end EvaluationTests.Partial.Mul4;
")})));
    end Mul4;
    
    model AssignStmt1
        function f
            input Real[:] x1;
            input Real[:] x2;
            output Real[size(x1,1)] y;
          algorithm
            y := x1;
            y := x2;
            y := x1 .* x2;
            y := x1;
        end f;
        Real[2] y2 = f({1,2},{time,time});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AssignStmt1",
            description="Evaluation of failing assign stmt",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.AssignStmt1
 constant Real y2[1] = 1;
 constant Real y2[2] = 2;
end EvaluationTests.Partial.AssignStmt1;
")})));
    end AssignStmt1;
    
    model FunctionCallStmt1
        function f2
            input Real[:] x1;
            output Real[size(x1,1)] y = x1;
            algorithm
        end f2;
        function f
            input Real[:] x1;
            input Real[:] x2;
            output Real[size(x1,1)] y;
          algorithm
            (y) := f2(x1);
            (y) := f2(x2);
            (y) := f2(x1);
        end f;
        Real[2] y2 = f({1,2},{time,time});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallStmt1",
            description="Evaluation of function call stmt with unknown value",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.FunctionCallStmt1
 constant Real y2[1] = 1;
 constant Real y2[2] = 2;
end EvaluationTests.Partial.FunctionCallStmt1;
")})));
    end FunctionCallStmt1;
    
    model FunctionCallStmt2
        function f2
            input Real[:] x1;
            input Real[:] x2;
            output Real[size(x1,1)] y1 = x1;
            output Real[size(x2,1)] y2 = x2;
            algorithm
        end f2;
        function f
            input Real[:] x1;
            input Real[:] x2;
            output Real[size(x1,1)] y;
            Real[size(x1,1)] t;
          algorithm
            (y,t) := f2(x1,x2);
        end f;
        Real[2] y2 = f({1,2},{time,time});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallStmt2",
            description="Evaluation of function call stmt with known and unknown values",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.FunctionCallStmt2
 constant Real y2[1] = 1;
 constant Real y2[2] = 2;
end EvaluationTests.Partial.FunctionCallStmt2;
")})));
    end FunctionCallStmt2;

    model IfStmt1
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            if x[1] < x[2] then
                y := x .* n;
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt1",
            description="Partial evaluation of if stmt. All branches known.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt1
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = EvaluationTests.Partial.IfStmt1.f({time, time}, 0);

public
 function EvaluationTests.Partial.IfStmt1.f
  input Real[:] x;
  input Real n;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  if x[1] < x[2] then
   for i1 in 1:size(x, 1) loop
    y[i1] := x[i1] .* n;
   end for;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt1.f;

end EvaluationTests.Partial.IfStmt1;
")})));
    end IfStmt1;
    
    model IfStmt2
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            if x[1] < x[2] then
                y := x .* n;
            else
                y := zeros(size(x,1));
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt2",
            description="Partial evaluation of if stmt. All branches known.",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Partial.IfStmt2
 constant Real y[1] = 0.0;
 constant Real y[2] = 0.0;
end EvaluationTests.Partial.IfStmt2;
")})));
    end IfStmt2;
    
    model IfStmt3
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            if x[1] < x[2] then
                y := x .* n;
            elseif x[1] > x[2] then
                y := (x .+ 1) .* n;
            else
                y := zeros(size(x,1));
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt3",
            description="Partial evaluation of if stmt. All branches known.",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Partial.IfStmt3
 constant Real y[1] = 0.0;
 constant Real y[2] = 0.0;
end EvaluationTests.Partial.IfStmt3;
")})));
    end IfStmt3;
    
    model IfStmt4
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            if x[1] < x[2] then
                y := x .* n;
            else
                y := x;
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt4",
            description="Partial evaluation of if stmt. Unknown branch.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt4
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = EvaluationTests.Partial.IfStmt4.f({time, time}, 0);

public
 function EvaluationTests.Partial.IfStmt4.f
  input Real[:] x;
  input Real n;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  if x[1] < x[2] then
   for i1 in 1:size(x, 1) loop
    y[i1] := x[i1] .* n;
   end for;
  else
   for i1 in 1:size(x, 1) loop
    y[i1] := x[i1];
   end for;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt4.f;

end EvaluationTests.Partial.IfStmt4;
")})));
    end IfStmt4;
    
    model IfStmt5
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            if x[1] < x[2] then
                y := x;
            else
                y := x .* n;
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt5",
            description="Partial evaluation of if stmt. Unknown branch.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt5
 Real y[1];
 Real y[2];
equation
 ({y[1], y[2]}) = EvaluationTests.Partial.IfStmt5.f({time, time}, 0);

public
 function EvaluationTests.Partial.IfStmt5.f
  input Real[:] x;
  input Real n;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  if x[1] < x[2] then
   for i1 in 1:size(x, 1) loop
    y[i1] := x[i1];
   end for;
  else
   for i1 in 1:size(x, 1) loop
    y[i1] := x[i1] .* n;
   end for;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt5.f;

end EvaluationTests.Partial.IfStmt5;
")})));
    end IfStmt5;
    
    model IfStmt6
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            if n > 0 then
                y := x;
            elseif x[1] > x[2] then
                y := (x .+ 1) .* n;
            elseif n == 0 then
                y := zeros(size(x,1));
            elseif x[1] > x[2] then
                y := x;
            else
                y := x;
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt6",
            description="Partial evaluation of if stmt. Chained false, unknown, and true if tests.",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Partial.IfStmt6
 constant Real y[1] = 0.0;
 constant Real y[2] = 0.0;
end EvaluationTests.Partial.IfStmt6;
")})));
    end IfStmt6;
    
    model IfStmt7
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            if x[1] < x[2] then
                y := x .* n;
                y[1] := x[1];
            else
                y := x;
                y[2] := 0;
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt7",
            description="Partial evaluation of if stmt. Partially known array.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt7
 Real y[1];
 constant Real y[2] = 0.0;
equation
 ({y[1], }) = EvaluationTests.Partial.IfStmt7.f({time, time}, 0);

public
 function EvaluationTests.Partial.IfStmt7.f
  input Real[:] x;
  input Real n;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  if x[1] < x[2] then
   for i1 in 1:size(x, 1) loop
    y[i1] := x[i1] .* n;
   end for;
   y[1] := x[1];
  else
   for i1 in 1:size(x, 1) loop
    y[i1] := x[i1];
   end for;
   y[2] := 0;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt7.f;

end EvaluationTests.Partial.IfStmt7;
")})));
    end IfStmt7;
    
    model IfStmt8
        record R
            Real a;
            Real b;
        end R;
        function f
            input R x;
            input Real n;
            output R y;
          algorithm
            y := x;
            if x.a < x.b then
                y.a := x.a;
                y.b := x.b * n;
            else
                y.a := x.a;
                y.b := 0;
            end if;
        end f;
        
        R y = f(R(time,time), 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt8",
            description="Partial evaluation of if stmt. Partially known record.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt8
 Real y.a;
 constant Real y.b = 0.0;
equation
 (EvaluationTests.Partial.IfStmt8.R(y.a, )) = EvaluationTests.Partial.IfStmt8.f(EvaluationTests.Partial.IfStmt8.R(time, time), 0);

public
 function EvaluationTests.Partial.IfStmt8.f
  input EvaluationTests.Partial.IfStmt8.R x;
  input Real n;
  output EvaluationTests.Partial.IfStmt8.R y;
 algorithm
  y.a := x.a;
  y.b := x.b;
  if x.a < x.b then
   y.a := x.a;
   y.b := x.b * n;
  else
   y.a := x.a;
   y.b := 0;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt8.f;

 record EvaluationTests.Partial.IfStmt8.R
  Real a;
  Real b;
 end EvaluationTests.Partial.IfStmt8.R;

end EvaluationTests.Partial.IfStmt8;
")})));
    end IfStmt8;
    
    model IfStmt9
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            if x[1] < x[2] then
                y := x;
                if n > 0 then
                    y := x;
                elseif x[1] > x[2] then
                    if n > 0 then
                        y := x;
                    else
                        y := (x .+ 1) .* n;
                    end if;
                elseif n == 0 then
                    y := zeros(size(x,1));
                elseif x[1] > x[2] then
                    y := x;
                else
                    y := x;
                end if;
            else
                y := zeros(size(x,1));
            end if;
        end f;
        
        Real[2] y = f({time,time}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt9",
            description="Partial evaluation of if stmt. Nested.",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Partial.IfStmt9
 constant Real y[1] = 0.0;
 constant Real y[2] = 0.0;
end EvaluationTests.Partial.IfStmt9;
")})));
    end IfStmt9;
    
    model IfStmt10
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            for i in 1:size(x,1) loop
                if x[i] > 1 then
                    y[i] := n;
                    break;
                else
                    y[i] := 0;
                end if;
            end for;
        end f;
        
        Real[4] y = f({time,1,2,3}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt10",
            description="Partial evaluation of if stmt. Break.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt10
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
equation
 ({y[1], y[2], y[3], y[4]}) = EvaluationTests.Partial.IfStmt10.f({time, 1, 2, 3}, 0);

public
 function EvaluationTests.Partial.IfStmt10.f
  input Real[:] x;
  input Real n;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1];
  end for;
  for i in 1:size(x, 1) loop
   if x[i] > 1 then
    y[i] := n;
    break;
   else
    y[i] := 0;
   end if;
  end for;
  return;
 end EvaluationTests.Partial.IfStmt10.f;

end EvaluationTests.Partial.IfStmt10;
")})));
    end IfStmt10;
    
    model IfStmt11
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y;
          algorithm
            y := x;
            for i in 1:size(x,1) loop
                if x[i] > 1 then
                    y[i] := n;
                    break;
                else
                    y[i] := 0;
                    break;
                end if;
            end for;
        end f;
        
        Real[4] y = f({time,1,2,3}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt11",
            description="Partial evaluation of if stmt. Break.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt11
 constant Real y[1] = 0;
 constant Real y[2] = 1;
 constant Real y[3] = 2;
 constant Real y[4] = 3;
end EvaluationTests.Partial.IfStmt11;
")})));
    end IfStmt11;
    
    model IfStmt12
        function f
            input Real[:] x;
            input Real n;
            output Real[size(x,1)] y1;
            output Real y2;
            output Real y3;
          algorithm
            y1 := x;
            if x[1] < x[2] then
                y1 := x .* n;
                y2 := 3;
            else
                y1 := x;
                y1[2] := 0;
                y3 := 3;
            end if;
        end f;
        
        Real[4] y1;
        Real y2,y3;
      equation
        (y1,y2,y3) = f({time,1,2,3}, 0);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt12",
            description="Partial evaluation of if stmt. Assigned in only one branch.",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt12
 Real y1[1];
 constant Real y1[2] = 0.0;
 Real y1[3];
 Real y1[4];
 Real y2;
 Real y3;
equation
 ({y1[1], , y1[3], y1[4]}, y2, y3) = EvaluationTests.Partial.IfStmt12.f({time, 1, 2, 3}, 0);

public
 function EvaluationTests.Partial.IfStmt12.f
  input Real[:] x;
  input Real n;
  output Real[:] y1;
  output Real y2;
  output Real y3;
 algorithm
  init y1 as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   y1[i1] := x[i1];
  end for;
  if x[1] < x[2] then
   for i1 in 1:size(x, 1) loop
    y1[i1] := x[i1] .* n;
   end for;
   y2 := 3;
  else
   for i1 in 1:size(x, 1) loop
    y1[i1] := x[i1];
   end for;
   y1[2] := 0;
   y3 := 3;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt12.f;

end EvaluationTests.Partial.IfStmt12;
")})));
    end IfStmt12;
    
    model IfStmt13
        record R
            Real a,b;
        end R;
        
        function f
            input Real x1;
            input Real x2;
            output R r;
          algorithm
            r := R(x2,x2);
            if x1 < 2 then
                r.a := x1;
            end if;
            r.b := x1;
        end f;
        
        R y = f(1, time);
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt13",
            description="Partial evaluation of if stmt. Assigned in only one branch.",
            eliminate_alias_variables=false,
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt13
 constant Real y.a = 1;
 constant Real y.b = 1;
end EvaluationTests.Partial.IfStmt13;
")})));
    end IfStmt13;
    
    model IfStmt14
        record R
            Real a,b;
        end R;
        
        function f
            input Real x1;
            input Real x2;
            output R r;
          algorithm
            if x1 < x2 then
                r.a := x1;
                r.b := x1;
            else
                r.a := x1;
                r.b := x2;
            end if;
        end f;
        
        R y = f(1, time);
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt14",
            description="Partial evaluation of if stmt. Part of record assigned different values per branch, other part assigned same",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt14
 constant Real y.a = 1;
 Real y.b;
equation
 (EvaluationTests.Partial.IfStmt14.R(, y.b)) = EvaluationTests.Partial.IfStmt14.f(1, time);

public
 function EvaluationTests.Partial.IfStmt14.f
  input Real x1;
  input Real x2;
  output EvaluationTests.Partial.IfStmt14.R r;
 algorithm
  if x1 < x2 then
   r.a := x1;
   r.b := x1;
  else
   r.a := x1;
   r.b := x2;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt14.f;

 record EvaluationTests.Partial.IfStmt14.R
  Real a;
  Real b;
 end EvaluationTests.Partial.IfStmt14.R;

end EvaluationTests.Partial.IfStmt14;
")})));
    end IfStmt14;
    
    model IfStmt15
        function f
            input Real x1;
            input Real x2;
            output Real[2] r;
          algorithm
            if x1 < x2 then
                r[1] := x1;
                r[2] := x1;
            else
                r[1] := x1;
                r[2] := x2;
            end if;
        end f;
        
        Real[2] y = f(1, time);
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfStmt15",
            description="Partial evaluation of if stmt. Part of array assigned different values per branch, other part assigned same",
            inline_functions="none",
            flatModel="
fclass EvaluationTests.Partial.IfStmt15
 constant Real y[1] = 1;
 Real y[2];
equation
 ({, y[2]}) = EvaluationTests.Partial.IfStmt15.f(1, time);

public
 function EvaluationTests.Partial.IfStmt15.f
  input Real x1;
  input Real x2;
  output Real[:] r;
 algorithm
  init r as Real[2];
  if x1 < x2 then
   r[1] := x1;
   r[2] := x1;
  else
   r[1] := x1;
   r[2] := x2;
  end if;
  return;
 end EvaluationTests.Partial.IfStmt15.f;

end EvaluationTests.Partial.IfStmt15;
")})));
    end IfStmt15;
    
end Partial;



model AssigningCached1
    record R
        Real a;
    end R;
    
    function f
        input R x;
        output R y = x;
      algorithm
        y.a := 2;
    end f;
    
    constant R y1 = R(1);
    constant R y2 = f(y1);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AssigningCached1",
            description="",
            flatModel="
fclass EvaluationTests.AssigningCached1
 constant EvaluationTests.AssigningCached1.R y1 = EvaluationTests.AssigningCached1.R(1);
 constant EvaluationTests.AssigningCached1.R y2 = EvaluationTests.AssigningCached1.R(2);

public
 function EvaluationTests.AssigningCached1.f
  input EvaluationTests.AssigningCached1.R x;
  output EvaluationTests.AssigningCached1.R y;
 algorithm
  y := x;
  y.a := 2;
  return;
 end EvaluationTests.AssigningCached1.f;

 record EvaluationTests.AssigningCached1.R
  Real a;
 end EvaluationTests.AssigningCached1.R;

end EvaluationTests.AssigningCached1;
")})));
end AssigningCached1;


model AssigningCached2
    function f
        input Real[:] x;
        output Real[:] y = x;
      algorithm
        y[2] := 3;
    end f;
    constant Real[2] y1 = {1,2};
    constant Real[2] y2 = f(y1);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AssigningCached2",
            description="",
            flatModel="
fclass EvaluationTests.AssigningCached2
 constant Real y1[2] = {1, 2};
 constant Real y2[2] = {1, 3};

public
 function EvaluationTests.AssigningCached2.f
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  y := x[:];
  y[2] := 3;
  return;
 end EvaluationTests.AssigningCached2.f;

end EvaluationTests.AssigningCached2;
")})));
end AssigningCached2;


model AssigningCached3
    record R
        Real[2] a;
    end R;
    function f
        input Real[2] x;
        output R y = R(x);
      algorithm
        y.a[2] := 3;
    end f;
    constant Real[2] y1 = {1,2};
    constant R y2 = f(y1);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AssigningCached3",
            description="",
            flatModel="
fclass EvaluationTests.AssigningCached3
 constant Real y1[2] = {1, 2};
 constant EvaluationTests.AssigningCached3.R y2 = EvaluationTests.AssigningCached3.R({1, 3});

public
 function EvaluationTests.AssigningCached3.f
  input Real[:] x;
  output EvaluationTests.AssigningCached3.R y;
 algorithm
  assert(2 == size(x, 1), \"Mismatching sizes in function 'EvaluationTests.AssigningCached3.f', component 'x', dimension '1'\");
  y := EvaluationTests.AssigningCached3.R(x);
  y.a[2] := 3;
  return;
 end EvaluationTests.AssigningCached3.f;

 record EvaluationTests.AssigningCached3.R
  Real a[2];
 end EvaluationTests.AssigningCached3.R;

end EvaluationTests.AssigningCached3;
")})));
end AssigningCached3;


model AssigningCached4
    record R
        Real[3] a;
    end R;
    function f
        input Real[3] x;
        Real[size(x,1)] t;
        output R y1;
      algorithm
        t := x;
        y1 := R(t);
        t[1] := 0;
    end f;
    constant Real[3] y1 = {1,2,3};
    constant R y2 = f(y1);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="AssigningCached4",
            description="",
            flatModel="
fclass EvaluationTests.AssigningCached4
 constant Real y1[3] = {1, 2, 3};
 constant EvaluationTests.AssigningCached4.R y2 = EvaluationTests.AssigningCached4.R({1, 2, 3});

public
 function EvaluationTests.AssigningCached4.f
  input Real[:] x;
  Real[:] t;
  output EvaluationTests.AssigningCached4.R y1;
 algorithm
  assert(3 == size(x, 1), \"Mismatching sizes in function 'EvaluationTests.AssigningCached4.f', component 'x', dimension '1'\");
  init t as Real[3];
  t[1:3] := x[1:3];
  y1 := EvaluationTests.AssigningCached4.R(t);
  t[1] := 0;
  return;
 end EvaluationTests.AssigningCached4.f;

 record EvaluationTests.AssigningCached4.R
  Real a[3];
 end EvaluationTests.AssigningCached4.R;

end EvaluationTests.AssigningCached4;
")})));
end AssigningCached4;

model AssigningCached5
    function f
        input Integer n;
        Real[n2] k = 1:n2;
        Integer n2 = n;
        output Real u = sum(k);
    algorithm
        annotation(Inline=false);
    end f;

    Real y = f(1);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AssigningCached5",
            description="",
            flatModel="
fclass EvaluationTests.AssigningCached5
 constant Real y = 1.0;
end EvaluationTests.AssigningCached5;
")})));
end AssigningCached5;


model ParameterMinMax1
    parameter Integer n(min=1);
    Real[n] x = if n < 2 then {2} else 1:n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax1",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax1
 structural parameter Integer n = 1 /* 1 */;
 Real x[1] = {2};
end EvaluationTests.ParameterMinMax1;
")})));
end ParameterMinMax1;


model ParameterMinMax2
    parameter Integer n(min=1, start=2);
    Real[n] x = if n < 2 then {2} else 1:n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax2",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax2
 structural parameter Integer n = 2 /* 2 */;
 Real x[2] = 1:2;
end EvaluationTests.ParameterMinMax2;
")})));
end ParameterMinMax2;


model ParameterMinMax3
    parameter Integer n(max=-1);
    Real[-n] x = if n > -2 then {2} else 1:(-n);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax3",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax3
 structural parameter Integer n = -1 /* -1 */;
 Real x[1] = {2};
end EvaluationTests.ParameterMinMax3;
")})));
end ParameterMinMax3;


model ParameterMinMax4
    parameter Integer n(max=-1, start=-2);
    Real[-n] x = if n > -2 then {2} else 1:(-n);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax4",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax4
 structural parameter Integer n = -2 /* -2 */;
 Real x[2] = 1:2;
end EvaluationTests.ParameterMinMax4;
")})));
end ParameterMinMax4;


model ParameterMinMax5
    parameter Real n(min=1.2);
    Real[integer(n)] x = 1:size(x,1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax5",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax5
 structural parameter Real n = 1.2 /* 1.2 */;
 Real x[1] = 1:size(x[1:1], 1);
end EvaluationTests.ParameterMinMax5;
")})));
end ParameterMinMax5;


model ParameterMinMax6
    parameter Real n(max=-1.2);
    Real[integer(-n)] x = 1:size(x,1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax6",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax6
 structural parameter Real n = -1.2 /* -1.2 */;
 Real x[1] = 1:size(x[1:1], 1);
end EvaluationTests.ParameterMinMax6;
")})));
end ParameterMinMax6;


model ParameterMinMax7
    type A = enumeration(a, b, c, d, e);
    type B = A(start = B.c);
    parameter B n(min=B.d);
    Real[Integer(n)] x = 1:size(x,1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax7",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax7
 structural parameter EvaluationTests.ParameterMinMax7.B n = EvaluationTests.ParameterMinMax7.A.d /* EvaluationTests.ParameterMinMax7.A.d */;
 Real x[4] = 1:size(x[1:4], 1);

public
 type EvaluationTests.ParameterMinMax7.B = enumeration(a, b, c, d, e)(start = EvaluationTests.ParameterMinMax7.A.c);

 type EvaluationTests.ParameterMinMax7.A = enumeration(a, b, c, d, e);

end EvaluationTests.ParameterMinMax7;
")})));
end ParameterMinMax7;


model ParameterMinMax8
    type A = enumeration(a, b, c, d, e);
    type B = A(start = B.c);
    parameter B n(max=B.b);
    Real[Integer(n)] x = 1:size(x,1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterMinMax8",
            description="Constricting evaluation of parameters without binding expression to min-max range",
            flatModel="
fclass EvaluationTests.ParameterMinMax8
 structural parameter EvaluationTests.ParameterMinMax8.B n = EvaluationTests.ParameterMinMax8.A.b /* EvaluationTests.ParameterMinMax8.A.b */;
 Real x[2] = 1:size(x[1:2], 1);

public
 type EvaluationTests.ParameterMinMax8.B = enumeration(a, b, c, d, e)(start = EvaluationTests.ParameterMinMax8.A.c);

 type EvaluationTests.ParameterMinMax8.A = enumeration(a, b, c, d, e);

end EvaluationTests.ParameterMinMax8;
")})));
end ParameterMinMax8;


model ForLoopSizeVary1
    function f
        input Real x;
        output Real y = 0;
      algorithm
        for i in 1:3 loop
            for j in 1:i-1 loop
                y := y + j;
            end for;
        end for;
    end f;
    
    constant Real y1 = f(1);
    Real y2 = f(1);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ForLoopSizeVary1",
            description="Varying sizes in for loops",
            eliminate_alias_variables=false,
            inline_functions="none",
            flatModel="
fclass EvaluationTests.ForLoopSizeVary1
 constant Real y1 = 4.0;
 constant Real y2 = 4.0;
end EvaluationTests.ForLoopSizeVary1;
")})));
end ForLoopSizeVary1;

model ForLoopSizeVary2
    function f
        input Real x;
        output Real y = 0;
      algorithm
        for i in 1:3 loop
            for j in 1:3-i loop
                y := y + j;
            end for;
        end for;
    end f;
    
    constant Real y1 = f(1);
    Real y2 = f(1);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ForLoopSizeVary2",
            description="Varying sizes in for loops",
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.ForLoopSizeVary2
 constant Real y1 = 4.0;
 constant Real y2 = 4.0;
end EvaluationTests.ForLoopSizeVary2;
")})));
end ForLoopSizeVary2;

model RelExpAlmost1
    constant Real eps = 1e-16;
    constant Boolean b1 = 1 >= 1 - eps;
    constant Boolean b2 = 1 <= 1 - eps;
    constant Boolean b3 = 1 > 1 - eps;
    constant Boolean b4 = 1 < 1 - eps;
    constant Boolean b5 = 0 < 1e-15;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RelExpAlmost1",
            description="Very close real comparisons",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.RelExpAlmost1
 constant Real eps = 1.0E-16;
 constant Boolean b1 = true;
 constant Boolean b2 = true;
 constant Boolean b3 = true;
 constant Boolean b4 = false;
 constant Boolean b5 = true;
end EvaluationTests.RelExpAlmost1;
")})));
end RelExpAlmost1;


model RelExpAlmost2
    constant Real eps = 1e-20;
    constant Boolean b1 = 0 > -eps;
    constant Boolean b2 = 0 < -eps;
    constant Boolean b3 = 0 > eps;
    constant Boolean b4 = 0 < eps;
    constant Boolean b5 = 1 > 1;
    constant Boolean b6 = 1 < 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RelExpAlmost2",
            description="Very close real comparisons",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.RelExpAlmost2
 constant Real eps = 1.0E-20;
 constant Boolean b1 = true;
 constant Boolean b2 = false;
 constant Boolean b3 = false;
 constant Boolean b4 = true;
 constant Boolean b5 = false;
 constant Boolean b6 = false;
end EvaluationTests.RelExpAlmost2;
")})));
end RelExpAlmost2;


model FScalarExpEval
    constant Real x = scalar({1});
    Integer y = 1.0; // Generate error so we can use error test

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="FScalarExpEval",
            description="Check that scalar() can be constant evaluated (before scalarization)",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFlatTree/src/test/EvaluationTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end FScalarExpEval;

model Atan2
    constant Real x1 = atan2(1,5);
    Real x2 = atan2(1,5);
    
    constant Real x3 = atan2(0,5);
    constant Real x4 = atan2(1,0);

    constant Real x5 = atan2(0,0);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Atan2",
            description="Basic test of atan2().",
            eliminate_alias_variables=false,
            flatModel="
fclass EvaluationTests.Atan2
 constant Real x1 = 0.19739555984988078;
 constant Real x2 = 0.19739555984988078;
 constant Real x3 = 0.0;
 constant Real x4 = 1.5707963267948966;
 constant Real x5 = 0.0;
end EvaluationTests.Atan2;
")})));
end Atan2;


model RangeSubscript1
    function f
        input Real[2] x;
        output Real[2,2] y;
    algorithm
        y[1,:] := x[1:2];
        y[2,:] := {1,2};
    end f;
    
    model A
        parameter Real b[2];
    end A;
    
    A a[2](b = f(c));
    final parameter Real c[2] = {1,2};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RangeSubscript1",
            description="Constant eval of non-slice array access with subscripts in flat tree",
            flatModel="
fclass EvaluationTests.RangeSubscript1
 final parameter Real c[1] = 1 /* 1 */;
 final parameter Real c[2] = 2 /* 2 */;
end EvaluationTests.RangeSubscript1;
")})));
end RangeSubscript1;

model RangeSubscript2
    function f
        input Real[:] x;
        output Integer[size(x,1)] i;
        output Real[size(x,1)] y;
    algorithm
        i := 1:size(x,1);
        y := x[i];
    end f;
    
    constant Real[:] y1 = f({1,2});
    Real[:] y2 = f({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RangeSubscript2",
            description="Test proper flush for sizes after evaluation",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass EvaluationTests.RangeSubscript2
 constant Real y1[1] = 1;
 constant Real y1[2] = 2;
 Real y2[1];
 Real y2[2];
 Real y2[3];
equation
 ({y2[1], y2[2], y2[3]}) = EvaluationTests.RangeSubscript2.f({1, 2, 3});

public
 function EvaluationTests.RangeSubscript2.f
  input Real[:] x;
  output Integer[:] i;
  output Real[:] y;
 algorithm
  init i as Integer[size(x, 1)];
  init y as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   i[i1] := i1;
  end for;
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i[i1]];
  end for;
  return;
 end EvaluationTests.RangeSubscript2.f;

end EvaluationTests.RangeSubscript2;
")})));
end RangeSubscript2;

model ConstantInFunction1
    record R
        Real x;
    end R;
    
    constant R[:] r = {R(1),R(2)};
    
    function f
        input Integer i;
        output Real y = r[i].x;
    algorithm
        y := y + r[i].x;
    end f;
    
    constant Real y = f(1) + f(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantInFunction1",
            description="Constant eval of composite array package constant in function",
            flatModel="
fclass EvaluationTests.ConstantInFunction1
 constant Real r[1].x = 1;
 constant Real r[2].x = 2;
 constant Real y = 6.0;
end EvaluationTests.ConstantInFunction1;
")})));
end ConstantInFunction1;

model ConstantInFunction2
    record R
        Real x;
    end R;
    
    constant R[:] r = {R(1),R(2)};
    
    function f
        input Integer i;
        output Real y = r[i].x;
    algorithm
        y := y + r[i].x;
    end f;
    
    constant Real y1 = f(2);
    constant Real y2 = f(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ConstantInFunction2",
            description="Constant eval of composite array package constant in function",
            flatModel="
fclass EvaluationTests.ConstantInFunction2
 constant Real r[1].x = 1;
 constant Real r[2].x = 2;
 constant Real y1 = 4.0;
 constant Real y2 = 2.0;
end EvaluationTests.ConstantInFunction2;
")})));
end ConstantInFunction2;

model ZeroSizeRecordArray1
    record R
        Real x = 1;
    end R;
    
    constant R[0] r;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ZeroSizeRecordArray1",
            description="",
            flatModel="
fclass EvaluationTests.ZeroSizeRecordArray1
end EvaluationTests.ZeroSizeRecordArray1;
")})));
end ZeroSizeRecordArray1;

model EvaluatePartialFunction1
    function g
        input Integer[:] x;
        output Integer y;
    algorithm
        y := sum(x);
    end g;

    function f
        input Integer x;
        output Integer y;
    end f;
    
    constant Integer[:] n = g(f({{2}}));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="EvaluatePartialFunction1",
            description="Check for no NullPointerException when evaluating partial vectorized function",
            errorMessage="
Error at line 14, column 29, in file '...':
  Could not evaluate binding expression for constant 'n': 'g(f({{2}}))'

Error at line 14, column 31, in file '...':
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));
end EvaluatePartialFunction1;

end EvaluationTests;
