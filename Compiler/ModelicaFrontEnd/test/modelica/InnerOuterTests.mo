/*
    Copyright (C) 2011-2013 Modelon AB

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

package InnerOuterTests
model InnerOuterTest1
model A 
  outer Real T0;
  Real z = sin(T0);
end A;
model B 
  inner Real T0;
  A a1, a2;	// B.T0, B.a1.T0 and B.a2.T0 is the same variable
equation
  T0 = time;
end B;
B b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InnerOuterTest1",
            description="Basic test of inner outer.",
            equation_sorting=true,
            flatModel="
fclass InnerOuterTests.InnerOuterTest1
 Real b.T0;
 Real b.a1.z;
 Real b.a2.z;
equation
 b.T0 = time;
 b.a1.z = sin(b.T0);
 b.a2.z = sin(b.T0);
end InnerOuterTests.InnerOuterTest1;
")})));
end InnerOuterTest1;

model InnerOuterTest2
	model A
		outer Real TI = time;
		Real x=TI*2;
		model B
			Real TI=1;
			model C
				Real TI=2;
				model D
					outer Real TI;
					Real x = 3*TI;
				end D;
				D d;
			end C;
			C c;
		end B;
		B b;
	end A;
	model E
		inner Real TI=4*time;
		model F
			inner Real TI=5*time;			
			model G
				Real TI = 5;
				class H
					A a;
				end H;
				H h;
			end G;
			G g;
		end F;
		F f;
	end E;
	model I
		inner Real TI = 2*time;
		E e;
		A a;
	end I;
	I i;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InnerOuterTest2",
            description="Basic test of inner outer.",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            equation_sorting=true,
            flatModel="
fclass InnerOuterTests.InnerOuterTest2
 Real i.TI;
 Real i.e.TI;
 Real i.e.f.TI;
 constant Real i.e.f.g.TI = 5;
 Real i.e.f.g.h.a.x;
 constant Real i.e.f.g.h.a.b.TI = 1;
 constant Real i.e.f.g.h.a.b.c.TI = 2;
 Real i.e.f.g.h.a.b.c.d.x;
 Real i.a.x;
 constant Real i.a.b.TI = 1;
 constant Real i.a.b.c.TI = 2;
 Real i.a.b.c.d.x;
equation
 i.TI = 2 * time;
 i.e.TI = 4 * time;
 i.e.f.TI = 5 * time;
 i.e.f.g.h.a.x = i.e.f.TI * 2;
 i.e.f.g.h.a.b.c.d.x = 3 * i.e.f.TI;
 i.a.x = i.TI * 2;
 i.a.b.c.d.x = 3 * i.TI;
end InnerOuterTests.InnerOuterTest2;
")})));
end InnerOuterTest2;

model InnerOuterTest3_Err
 model A
   outer Boolean x;
 end A;
 inner Integer x = 3;
 A a;
end InnerOuterTest3_Err;

model InnerOuterTest4
	model A
		Real x;
	end A;
	model B
		outer A a;
		Real x = 2*a.x;
	end B;
	model C
		inner A a(x=sin(time));
		B b;
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest4",
			description="Basic test of inner outer.",
			equation_sorting=true,
			flatModel="
fclass InnerOuterTests.InnerOuterTest4
 Real c.a.x;
 Real c.b.x;
equation
 c.a.x = sin(time);
 c.b.x = 2 * c.a.x;
end InnerOuterTests.InnerOuterTest4;
")})));
end InnerOuterTest4;

model InnerOuterTest5
model ConditionalIntegrator 
    "Simple differential equation if isEnabled"
outer Boolean isEnabled;
Real x(start=1);
equation 
  der(x)= if isEnabled then -x else 0;
end ConditionalIntegrator;

model SubSystem 
    "subsystem that 'enable' its conditional integrators"
Boolean enableMe = time<=1; // Set inner isEnabled to outer isEnabled and enableMe 
inner outer Boolean isEnabled = isEnabled and enableMe;
ConditionalIntegrator conditionalIntegrator;
ConditionalIntegrator conditionalIntegrator2;
end SubSystem;

model System
             SubSystem subSystem;
  inner Boolean isEnabled = time>=0.5; // subSystem.conditionalIntegrator.isEnabled will be
                                       // 'isEnabled and subSystem.enableMe'
end System;

System sys;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest5",
			description="Basic test of inner outer.",
			equation_sorting=true,
			flatModel="
fclass InnerOuterTests.InnerOuterTest5
 discrete Boolean sys.subSystem.enableMe;
 discrete Boolean sys.subSystem.isEnabled;
 Real sys.subSystem.conditionalIntegrator.x(start = 1);
 Real sys.subSystem.conditionalIntegrator2.x(start = 1);
 discrete Boolean sys.isEnabled;
initial equation 
 sys.subSystem.conditionalIntegrator.x = 1;
 sys.subSystem.conditionalIntegrator2.x = 1;
 pre(sys.subSystem.enableMe) = false;
 pre(sys.subSystem.isEnabled) = false;
 pre(sys.isEnabled) = false;
equation
 der(sys.subSystem.conditionalIntegrator.x) = if sys.subSystem.isEnabled then - sys.subSystem.conditionalIntegrator.x else 0;
 der(sys.subSystem.conditionalIntegrator2.x) = if sys.subSystem.isEnabled then - sys.subSystem.conditionalIntegrator2.x else 0;
 sys.subSystem.enableMe = time <= 1;
 sys.subSystem.isEnabled = sys.isEnabled and sys.subSystem.enableMe;
 sys.isEnabled = time >= 0.5;
end InnerOuterTests.InnerOuterTest5;
")})));
end InnerOuterTest5;

model InnerOuterTest6

function A
input Real u;
output Real y;
/*algorithm
	y := u;*/
end A;

function B
  input Real u;
output Real y;
algorithm 
  y := 3*u;
end B;
// B is a subtype of A
class D
  outer function fc = A;
  Real y;
  Real u = time;
equation 
y = fc(u);
end D;

class C
  inner function fc = B;
   D d; // The equation is now treated as y = B(u)
end C;
	C c;		
end InnerOuterTest6;

model InnerOuterTest7
	model A
		Real x = 4;
	end A;
	model B
		Real x = 6;
		Real y = 9;
	end B;
    model C
		outer model Q = A;	
		Q a;
		Real z = a.x;
	end C;
	model D
	 	inner model Q = B;
		B a; 
		C c;
	end D;
	D d;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest7",
			description="Basic test of inner outer.",
			equation_sorting=true,
			eliminate_alias_variables=false,
			flatModel="
fclass InnerOuterTests.InnerOuterTest7
 constant Real d.a.x = 6;
 constant Real d.a.y = 9;
 constant Real d.c.a.x = 6;
 constant Real d.c.a.y = 9;
 constant Real d.c.z = 6.0;
end InnerOuterTests.InnerOuterTest7;
")})));
end InnerOuterTest7;
	
model InnerOuterTest8
	package P1
    	model A 
	    	Real x = 4;
	    end A;
	end P1;
	package P2
		model A
			Real x = 6;
			Real y = 9;
		end A;
	end P2;
    model C
		outer package P = P1;	
		P.A a;
		Real z = a.x;
	end C;
	model D
	 	inner package P = P2;
		C c;
	end D;
	D d;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InnerOuterTest8",
			description="Basic test of inner outer.",
			equation_sorting=true,
			eliminate_alias_variables=false,
			flatModel="
fclass InnerOuterTests.InnerOuterTest8
 constant Real d.c.a.x = 6;
 constant Real d.c.a.y = 9;
 constant Real d.c.z = 6.0;
end InnerOuterTests.InnerOuterTest8;
")})));
end InnerOuterTest8;


model InnerOuterTest9
    outer parameter Real T = 5;
    Real x = T * 23;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="InnerOuterTest9",
            description="Missing inner declaration for parameter",
            errorMessage="
2 errors found:

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo':
  Generated missing inner declaration for 'outer parameter Real T = 5'

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter T does not have a binding expression
")})));
end InnerOuterTest9;


model InnerOuterTest10
    outer constant Real T = 5;
    constant Real x = T * 23;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="InnerOuterTest10",
            description="Missing inner declaration for constant",
            errorMessage="
2 errors found:

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo':
  Generated missing inner declaration for 'outer constant Real T = 5'

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo', CONSTANT_MISSING_BINDING_EXPRESSION:
  The constant T does not have a binding expression
")})));
end InnerOuterTest10;


model InnerOuterTest12
    model A
        parameter Integer b = 2;
    end A;
    
    inner A c(b = 1);
    
    model D
        outer A c;
        parameter Integer e = c.b;
        Real x[e] = zeros(e);
    end D;
    
    D f;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="InnerOuterTest12",
			description="Constant evaluation of inner/outer",
			flatModel="
fclass InnerOuterTests.InnerOuterTest12
 structural parameter Integer c.b = 1 /* 1 */;
 structural parameter Integer f.e = 1 /* 1 */;
 Real f.x[1] = zeros(1);
end InnerOuterTests.InnerOuterTest12;
")})));
end InnerOuterTest12;


model InnerOuterTest15
    model A
        Real x[2];
    end A;
    
    model B
        outer A a;
        Real y[2];
    equation
        a.x = y;
    end B;
    
    inner A a;
    B b;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="InnerOuterTest15",
			description="",
			flatModel="
fclass InnerOuterTests.InnerOuterTest15
 Real a.x[2];
 Real b.y[2];
equation
 a.x[1:2] = b.y[1:2];
end InnerOuterTests.InnerOuterTest15;
")})));
end InnerOuterTest15;


model InnerOuterTest16
    inner Real x[3] = {1, 2, 3} * time;
    
    model A
        outer Real x[3];
        parameter Integer y = 2;
        Real z = x[y];
    end A;
    
    A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest16",
            description="Flattening of accesses to outer array with array subscripts",
            flatModel="
fclass InnerOuterTests.InnerOuterTest16
 Real x[3] = {1, 2, 3} * time;
 parameter Integer a.y = 2 /* 2 */;
 Real a.z = (x[1:3])[a.y];
end InnerOuterTests.InnerOuterTest16;
")})));
end InnerOuterTest16;


model InnerOuterTest17
    model A
        parameter Real x;
    end A;
    
    model B
        outer A a;
    end B;
    
    model C
        B b;
        parameter Real y = b.a.x;
    end C;
    
    inner A a;
    C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest17",
            description="",
            flatModel="
fclass InnerOuterTests.InnerOuterTest17
 parameter Real a.x;
 parameter Real c.y = a.x;
end InnerOuterTests.InnerOuterTest17;
")})));
end InnerOuterTest17;


model InnerOuterTest18
    model A
        parameter Real x;
    end A;
    
    model B
        outer A a;
    end B;
    
    model D
        model C
            B b;
            parameter Real y = b.a.x;
        end C;
        
        inner A a;
        C c;
    end D;
    
    D d;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest18",
            description="",
            flatModel="
fclass InnerOuterTests.InnerOuterTest18
 parameter Real d.a.x;
 parameter Real d.c.y = d.a.x;
end InnerOuterTests.InnerOuterTest18;
")})));
end InnerOuterTest18;


model InnerOuterTest19
    model B
        inner outer C c;
    end B;
    
    model C
        D d;
    equation
        d.a = time;
    end C;
    
    model D
        Real a;
    end D;

    B b;
    inner C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest19",
            description="Equation inside inner outer component",
            flatModel="
fclass InnerOuterTests.InnerOuterTest19
 Real b.c.d.a;
 Real c.d.a;
equation
 b.c.d.a = time;
 c.d.a = time;
end InnerOuterTests.InnerOuterTest19;
")})));
end InnerOuterTest19;

model InnerOuterTest20
    model R
        Real y;
    equation
        y = 1;
    end R;
    
    model A
        outer R r;
    end A;
    
    model B
        A a;
        inner outer R r;
    end B;
    
    model C
        B b;
        inner R r;
    end C;
    
    C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest20",
            description="Equation inside inner outer component",
            flatModel="
fclass InnerOuterTests.InnerOuterTest20
 Real c.b.r.y;
 Real c.r.y;
equation
 c.b.r.y = 1;
 c.r.y = 1;
end InnerOuterTests.InnerOuterTest20;
")})));
end InnerOuterTest20;

model InnerOuterTest21
    model O
        partial function f
            input Real[:] x;
            output Real[size(x,1)] y;
        end f;
    end O;
    
    model M
        function f
            input Real[2] x;
            output Real[size(x,1)] y;
        algorithm
            y := x;
        end f;
    end M;
    
    model A
        outer M m;
        Real[:] y = m.f({time,time});
    end A;
    
    model B
        A a;
        inner M m;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest21",
            description="Flattening array access in function in inner",
            flatModel="
fclass InnerOuterTests.InnerOuterTest21
 Real b.a.y[2] = InnerOuterTests.InnerOuterTest21.b.m.f({time, time});

public
 function InnerOuterTests.InnerOuterTest21.b.m.f
  input Real[:] x;
  output Real[:] y;
 algorithm
  assert(2 == size(x, 1), \"Mismatching sizes in function 'InnerOuterTests.InnerOuterTest21.b.m.f', component 'x', dimension '1'\");
  init y as Real[2];
  y[1:2] := x[1:2];
  return;
 end InnerOuterTests.InnerOuterTest21.b.m.f;

end InnerOuterTests.InnerOuterTest21;
")})));
end InnerOuterTest21;

model InnerOuterTest22
    model M
        record R
            Real[2] x;
        end R;
        function f
            input Real[:] x;
            output Real[size(x,1)] y = x;
            algorithm
        end f;
        
        function f2 = f(x=X);
        
        Real[2] y = f2();
        Real[2] X = {time,time};
    end M;
    
    model A
        outer M m;
    end A;
    
    A a;
    inner M m;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterTest22",
            description="Flattening array access in short class decl in inner",
            flatModel="
fclass InnerOuterTests.InnerOuterTest22
 Real m.y[2] = InnerOuterTests.InnerOuterTest22.m.f2(m.X[1:2]);
 Real m.X[2] = {time, time};

public
 function InnerOuterTests.InnerOuterTest22.m.f2
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[size(x, 1)];
  y := x[:];
  return;
 end InnerOuterTests.InnerOuterTest22.m.f2;

end InnerOuterTests.InnerOuterTest22;
")})));
end InnerOuterTest22;

model InnerOuterAccess1
    record R_0
        
    end R_0;
    
    record R
        Real y;
    end R;
    
    model A
        outer R_0 r;
    equation
        r.y = time;
    end A;
    
    A a;
    inner R r;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuterAccess1",
            description="Access to component in outer that only exist in inner",
            errorMessage="
1 errors found:

Error at line 13, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo',
In component a:
  Cannot use component y in inner 'inner R r', because it is not present in outer 'outer R_0 r'

")})));
end InnerOuterAccess1;

model InnerOuterAccess2
    record R_0
        
    end R_0;
    
    record R
        Real y;
    end R;
    
    model A
        outer R_0 r;
    equation
        r.y = time;
    end A;
    
    model B
        inner outer R_0 r;
        A a;
    equation
        r.y = time;
    end B;
    
    B b;
    inner R r;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuterAccess2",
            description="Access to component in outer that only exist in inner",
            errorMessage="
2 errors found:

Error at line 13, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo',
In component b.a:
  Cannot find class or component declaration for y

Error at line 20, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo',
In component b:
  Cannot use component y in inner 'inner R r', because it is not present in outer 'inner outer R_0 r'

")})));
end InnerOuterAccess2;

model InnerOuterAccess3
    record K
        Real y;
    end K;
    
    record R_0
        
    end R_0;
    
    record R
        K k;
    end R;
    
    model A
        outer R_0 r;
    equation
        r.k.y = time;
    end A;
    
    A a;
    inner R r;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuterAccess3",
            description="Access to component in outer that only exist in inner",
            errorMessage="
1 errors found:

Error at line 17, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo',
In component a:
  Cannot use component k in inner 'inner R r', because it is not present in outer 'outer R_0 r'
")})));
end InnerOuterAccess3;



model InnerOuterNested1
    model R
        Real y;
    equation
        y = 1;
    end R;
    
    model A
        outer R r;
    end A;
    
    model B
        Real t;
        outer A a;
        inner outer R r;
    equation
        t = a.r.y;
    end B;
    
    model C
        B b;
        inner R r;
    end C;
    
    C c;
    inner A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterNested1",
            description="Equation inside nested inner outer component",
            flatModel="
fclass InnerOuterTests.InnerOuterNested1
 Real c.b.t;
 Real c.b.r.y;
 Real c.r.y;
 Real r.y;
equation
 c.b.t = r.y;
 c.b.r.y = 1;
 c.r.y = 1;
 r.y = 1;
end InnerOuterTests.InnerOuterNested1;
")})));
end InnerOuterNested1;

model InnerOuterNested2
    model R
        Real y;
    equation
        y = 1;
    end R;
    
    model A
        outer R r;
    end A;
    
    model B
        Real t;
        outer A a;
        inner outer R r;
    equation
        t = a.r.y;
    end B;
    
    model C
        B b;
        inner R r;
        inner A a;
    end C;
    
    C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InnerOuterNested2",
            description="Equation inside nested inner outer component",
            flatModel="
fclass InnerOuterTests.InnerOuterNested2
 Real c.b.t;
 Real c.b.r.y;
 Real c.r.y;
equation
 c.b.t = c.r.y;
 c.b.r.y = 1;
 c.r.y = 1;
end InnerOuterTests.InnerOuterNested2;
")})));
end InnerOuterNested2;



model NoInner1
    model A
        outer Real r;
    equation
        r = time;
    end A;

    A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner1_gen",
            description="Generating missing inner for outer in component",
            flatModel="
fclass InnerOuterTests.NoInner1
 Real r;
equation
 r = time;
end InnerOuterTests.NoInner1;
"),
        WarningTestCase(
            name="NoInner1_warn",
            description="Warning for generated inner",
            errorMessage="
1 errors found:

Warning at line 3, column 9, in file 'Compiler/ModelicaFrontEnd/src/test/InnerOuterTests.mo':
  Generated missing inner declaration for 'outer Real r'
")})));
end NoInner1;


model NoInner2
    model A
        outer Real r;
    equation
        r = time;
    end A;

    model B
        extends A;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner2_gen",
            description="Generating missing inner for outer in superclass of component",
            flatModel="
fclass InnerOuterTests.NoInner2
 Real r;
equation
 r = time;
end InnerOuterTests.NoInner2;
"),
        WarningTestCase(
            name="NoInner2_warn",
            description="",
            errorMessage="
1 errors found:

Warning at line 3, column 9, in file 'Compiler/ModelicaFrontEnd/src/test/InnerOuterTests.mo',
In component b:
  Generated missing inner declaration for 'outer Real r'
")})));
end NoInner2;


model NoInner3
    model A
        inner outer Real r = time;
    equation
        r = time;
    end A;

    model B
        extends A;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner3",
            description="Generating missing inner for inner outer in superclass of component",
            flatModel="
fclass InnerOuterTests.NoInner3
 Real b.r = time;
 Real r;
equation
 r = time;
end InnerOuterTests.NoInner3;
")})));
end NoInner3;


model NoInner4
    model A
        Real x = time;
        Real y;
    end A;
    
    model B
        outer A a;
        Real z = a.y + 1;
    end B;
    
    model C
        B b;
    equation
        b.a.y = 2* time;
    end C;
    
    B b;
    C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner4",
            description="Generating missing inner for multiple composite outer of same type",
            flatModel="
fclass InnerOuterTests.NoInner4
 Real b.z = a.y + 1;
 Real c.b.z = a.y + 1;
 Real a.x = time;
 Real a.y;
equation
 a.y = 2 * time;
end InnerOuterTests.NoInner4;
")})));
end NoInner4;


model NoInner5
    outer Real x;
equation
    x = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner5",
            description="Generating missing inner for outer on top level",
            flatModel="
fclass InnerOuterTests.NoInner5
 Real x;
equation
 x = time;
end InnerOuterTests.NoInner5;
")})));
end NoInner5;


model NoInner6
    inner outer Real x;
equation
    x = time;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NoInner6",
            description="inner outer component on top level",
            errorMessage="
1 errors found:

Error at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo':
  Can not generate missing inner declaration for x, due to presence of component with same name on top level
")})));
end NoInner6;


model NoInner7
    model A
        outer Real r;
    equation
        r = time;
    end A;

    A a;
    Real r;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NoInner7",
            description="Missing inner with component on top level with same name as outer decl",
            errorMessage="
1 errors found:

Error at line 3, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo':
  Can not generate missing inner declaration for r, due to presence of component with same name on top level
")})));
end NoInner7;


model NoInner8
    partial model A
        Real x;
    end A;
    
    model B
        outer A a;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NoInner8",
            description="Missing inner for outer of partial type",
            errorMessage="
1 errors found:

Error at line 7, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo':
  Can not generate missing inner declaration for outer component a of partial type InnerOuterTests.NoInner8.A
")})));
end NoInner8;


model NoInner9
    model A
        Real x = time;
    end A;
    
    model B
        Real x = time;
    end B;
    
    model C
        outer A a;
    end C;
    
    model D
        outer B a;
    end D;
    
    C c;
    D d;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NoInner9",
            description="Missing inner for multiple outer with different types",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo':
  Can't generate missing inner declaration for a, due to the outer declarations being of different types: 
    InnerOuterTests.NoInner9.A c.a
    InnerOuterTests.NoInner9.B d.a
")})));
end NoInner9;


model NoInner10
    model A
        Real x = time;
    end A;
    
    model B
        Real x = time;
    end B;
    
    model C
        outer A a;
    end C;
    
    model D
        outer B a;
    end D;
    
    model E
        outer Real a;
    end E;
    
    model F
        C c;
        D d;
    end F;
    
    C c1, c2;
    D d;
    E e;
    F f;
    outer A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NoInner10",
            description="Missing inner for multiple outer with different types",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/InnerOuterTests.mo':
  Can't generate missing inner declaration for a, due to the outer declarations being of different types: 
    InnerOuterTests.NoInner10.A a
    InnerOuterTests.NoInner10.A c1.a
    InnerOuterTests.NoInner10.A c2.a
    InnerOuterTests.NoInner10.A f.c.a
    InnerOuterTests.NoInner10.B d.a
    InnerOuterTests.NoInner10.B f.d.a
    Real e.a
")})));
end NoInner10;


model NoInner11
    model A
        Real x = time;
    end A;
    
    model B
        Real y = z;
        outer Real z;
    end B;
    
    model C
        outer A a;
        outer Real z;
    equation
        z = a.x / 2;
    end C;
    
    model D
        outer A a;
        outer B b;
    end D;
    
    C c;
    D d;
    outer B b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner11_gen",
            description="Generating multiple missing inner, different types and names, multiple of each",
            flatModel="
fclass InnerOuterTests.NoInner11
 Real a.x = time;
 Real z;
 Real b.y = z;
equation
 z = a.x / 2;
end InnerOuterTests.NoInner11;
"),
        WarningTestCase(
            name="NoInner11_warn",
            description="Warning for generated inner",
            errorMessage="
3 errors found:

Warning at line 12, column 9, in file 'Compiler/ModelicaFrontEnd/src/test/InnerOuterTests.mo':
  Generated missing inner declaration for 'outer A a'

Warning at line 13, column 9, in file 'Compiler/ModelicaFrontEnd/src/test/InnerOuterTests.mo':
  Generated missing inner declaration for 'outer Real z'

Warning at line 20, column 9, in file 'Compiler/ModelicaFrontEnd/src/test/InnerOuterTests.mo':
  Generated missing inner declaration for 'outer B b'
")})));
end NoInner11;


model NoInner12
    model A
        Real x = 1;
    end A;
    
    model B
        inner outer A a(x(start = 2) = 3);
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner12",
            description="Generating missing inner for inner outer with modifiers",
            flatModel="
fclass InnerOuterTests.NoInner12
 Real b.a.x(start = 2) = 3;
 Real a.x = 1;
end InnerOuterTests.NoInner12;
")})));
end NoInner12;


model NoInner13
    connector C
        Real x;
        flow Real y;
    end C;
    
    model A
        C c1(x = time), c2(x = 2 * time);
        B b;
    equation
        connect(c2, b.c);
    end A;
    
    model B
        C c;
    end B;
    
    outer A a;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner13",
            description="Check that connectors in automatically generated inner components are handled correctly",
            flatModel="
fclass InnerOuterTests.NoInner13
 Real a.c1.x = time;
 Real a.c1.y;
 Real a.c2.x = 2 * time;
 Real a.c2.y;
 Real a.b.c.x;
 Real a.b.c.y;
equation
 a.b.c.x = a.c2.x;
 a.b.c.y - a.c2.y = 0.0;
 a.c1.y = 0.0;
 a.c2.y = 0.0;
end InnerOuterTests.NoInner13;
")})));
end NoInner13;

model NoInner14
    function F
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
    annotation(Inline=false);
    end F;
    record R
        parameter Real a = 1;
        parameter Real b = F(a);
    end R;
    model B
        outer R r;
    end B;
    B b;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoInner14",
            description="Check that referenced functions in automatic inner is flattened",
            flatModel="
fclass InnerOuterTests.NoInner14
 parameter InnerOuterTests.NoInner14.R r(a = 1,b = InnerOuterTests.NoInner14.F(r.a));

public
 function InnerOuterTests.NoInner14.F
  input Real x;
  output Real y;
 algorithm
  y := x + 1;
  return;
 annotation(Inline = false);
 end InnerOuterTests.NoInner14.F;

 record InnerOuterTests.NoInner14.R
  parameter Real a;
  parameter Real b;
 end InnerOuterTests.NoInner14.R;

end InnerOuterTests.NoInner14;
")})));
end NoInner14;


end InnerOuterTests;
