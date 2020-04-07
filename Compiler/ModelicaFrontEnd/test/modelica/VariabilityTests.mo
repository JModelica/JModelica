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

package VariabilityTests

model Structural1
    function f
        output Integer[2] y = {2,1};
      algorithm
    end f;
    parameter Integer y[2] = f();
    parameter Integer z = y[1];
    Real[z] a = {1,1};

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Structural1",
            description="Partially structural array",
            flatModel="
fclass VariabilityTests.Structural1
 structural parameter Integer y[2] = {2, 1} /* { 2, 1 } */;
 structural parameter Integer z = 2 /* 2 */;
 Real a[2] = {1, 1};

public
 function VariabilityTests.Structural1.f
  output Integer[:] y;
 algorithm
  init y as Integer[2];
  y := {2, 1};
  return;
 end VariabilityTests.Structural1.f;

end VariabilityTests.Structural1;
")})));
end Structural1;

model Structural2
    parameter Boolean b = true;
    parameter Real[:] x = if not b then 1:2 else 1:3;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Structural2",
            description="If expression branch selection for size",
            flatModel="
fclass VariabilityTests.Structural2
 structural parameter Boolean b = true /* true */;
 structural parameter Real x[3] = {1, 2, 3} /* { 1, 2, 3 } */;
end VariabilityTests.Structural2;
")})));
end Structural2;


model Structural3
    model A
        parameter Integer p;
    end A;

    model B
        parameter Integer p;
        Real x[p] = (1:p) * time;
    end B;
    
    model C
        extends A;
        extends B;
    end C;
    
    C c(p = 2);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="Structural3",
        description="",
        flatModel="
fclass VariabilityTests.Structural3
 structural parameter Integer c.p = 2 /* 2 */;
 Real c.x[2] = (1:2) * time;
end VariabilityTests.Structural3;
")})));
end Structural3;


model EvaluateAnnotation1
	parameter Real a = 1.0;
	parameter Real b = a annotation(Evaluate=true);
	Real c = a + b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation1",
            description="Check that annotation(Evaluate=true) is honored",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation1
 structural parameter Real a = 1.0 /* 1.0 */;
 eval parameter Real b = 1.0 /* 1.0 */;
 Real c = 1.0 + 1.0;
end VariabilityTests.EvaluateAnnotation1;
")})));
end EvaluateAnnotation1;

model EvaluateAnnotation2
    parameter Real p(fixed=false) annotation (Evaluate=true);
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation2",
            description="Check that annotation(Evaluate=true) is ignored when fixed equals false",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation2
 initial parameter Real p(fixed = false);
initial equation 
 p = 1;
end VariabilityTests.EvaluateAnnotation2;
")})));
end EvaluateAnnotation2;

model EvaluateAnnotation2_Warn
    parameter Real p(fixed=false) annotation (Evaluate=true);
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="EvaluateAnnotation2_Warn",
            description="Check that a warning is given when annotation(Evaluate=true) and fixed equals false",
            errorMessage="
1 warnings found:

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/VariabilityTests.mo':
  Evaluate annotation is ignored for parameters with fixed=false
")})));
end EvaluateAnnotation2_Warn;


model EvaluateAnnotation3
    parameter Real p[2](fixed={false, true}) annotation (Evaluate=true);
initial equation
    p[1] = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation3",
            description="Check that annotation(Evaluate=true) is ignored when fixed equals false",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation3
 initial parameter Real p[2](fixed = {false, true});
initial equation 
 p[1] = 1;
end VariabilityTests.EvaluateAnnotation3;
")})));
end EvaluateAnnotation3;

model EvaluateAnnotation4
    model A
        parameter Real p = 2 annotation(Evaluate=true);
    end A;
    A a(p=p);
    parameter Real p(fixed=false) annotation (Evaluate=true);
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation4",
            description="Check that annotation(Evaluate=true) is ignored when fixed equals false",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation4
 initial parameter Real a.p = p;
 initial parameter Real p(fixed = false);
initial equation 
 p = 1;
end VariabilityTests.EvaluateAnnotation4;
")})));
end EvaluateAnnotation4;

model EvaluateAnnotation5
    record R
        Real a;
    end R;
    
    parameter R r = R(1) annotation(Evaluate=true);
    Real x = r.a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation5",
            description="Check that annotation(Evaluate=true) is honored for components of recors with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation5
 eval parameter VariabilityTests.EvaluateAnnotation5.R r = VariabilityTests.EvaluateAnnotation5.R(1) /* VariabilityTests.EvaluateAnnotation5.R(1) */;
 Real x = 1.0;

public
 record VariabilityTests.EvaluateAnnotation5.R
  Real a;
 end VariabilityTests.EvaluateAnnotation5.R;

end VariabilityTests.EvaluateAnnotation5;
")})));
end EvaluateAnnotation5;

model EvaluateAnnotation6
    record R
        Real n = 1;
    end R;
    
    function f
        input R x;
        output R y = x;
      algorithm
    end f;
    
    parameter R r1 annotation(Evaluate=true);
    parameter R r2 = f(r1);
    Real x = r2.n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation6",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation6
 eval parameter VariabilityTests.EvaluateAnnotation6.R r1 = VariabilityTests.EvaluateAnnotation6.R(1) /* VariabilityTests.EvaluateAnnotation6.R(1) */;
 structural parameter VariabilityTests.EvaluateAnnotation6.R r2 = VariabilityTests.EvaluateAnnotation6.R(1) /* VariabilityTests.EvaluateAnnotation6.R(1) */;
 Real x = 1.0;

public
 function VariabilityTests.EvaluateAnnotation6.f
  input VariabilityTests.EvaluateAnnotation6.R x;
  output VariabilityTests.EvaluateAnnotation6.R y;
 algorithm
  y := x;
  return;
 end VariabilityTests.EvaluateAnnotation6.f;

 record VariabilityTests.EvaluateAnnotation6.R
  Real n;
 end VariabilityTests.EvaluateAnnotation6.R;

end VariabilityTests.EvaluateAnnotation6;
")})));
end EvaluateAnnotation6;

model EvaluateAnnotation7
    record R
        Real n = 1;
    end R;
    
    record P
        extends R;
    end P;
    
    function f
        input P x;
        output P y = x;
      algorithm
    end f;
    
    parameter P r1 annotation(Evaluate=true);
    parameter P r2 = f(r1);
    Real x = r2.n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation7",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation7
 eval parameter VariabilityTests.EvaluateAnnotation7.P r1 = VariabilityTests.EvaluateAnnotation7.P(1) /* VariabilityTests.EvaluateAnnotation7.P(1) */;
 structural parameter VariabilityTests.EvaluateAnnotation7.P r2 = VariabilityTests.EvaluateAnnotation7.P(1) /* VariabilityTests.EvaluateAnnotation7.P(1) */;
 Real x = 1.0;

public
 function VariabilityTests.EvaluateAnnotation7.f
  input VariabilityTests.EvaluateAnnotation7.P x;
  output VariabilityTests.EvaluateAnnotation7.P y;
 algorithm
  y := x;
  return;
 end VariabilityTests.EvaluateAnnotation7.f;

 record VariabilityTests.EvaluateAnnotation7.P
  Real n;
 end VariabilityTests.EvaluateAnnotation7.P;

end VariabilityTests.EvaluateAnnotation7;
")})));
end EvaluateAnnotation7;

model EvaluateAnnotation8
    record R
        Real y;
        Real x = y + 1 annotation(Evaluate=true);
    end R;
   
    parameter R r = R(y=3);
    Real x = r.x + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EvaluateAnnotation8",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation8
 parameter Real r.y = 3 /* 3 */;
 eval parameter Real r.x = 4 /* 4 */;
 constant Real x = 5.0;
end VariabilityTests.EvaluateAnnotation8;
")})));
end EvaluateAnnotation8;

model EvaluateAnnotation9
    function F
        input R i;
        output R o;
    algorithm
        o.p := i.p + 42;
    end F;
    record R
        parameter Real p = -41;
    end R;
    parameter R r1 annotation(Evaluate=true);
    parameter R r2 = F(r1);
    
    Real x = (r2.p - 1) * time;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation9",
            description="Check that annotation(Evaluate=true) is honored for components of records with the annotation",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation9
 eval parameter VariabilityTests.EvaluateAnnotation9.R r1 = VariabilityTests.EvaluateAnnotation9.R(-41) /* VariabilityTests.EvaluateAnnotation9.R(-41) */;
 structural parameter VariabilityTests.EvaluateAnnotation9.R r2 = VariabilityTests.EvaluateAnnotation9.R(1.0) /* VariabilityTests.EvaluateAnnotation9.R(1.0) */;
 Real x = (1.0 - 1) * time;

public
 function VariabilityTests.EvaluateAnnotation9.F
  input VariabilityTests.EvaluateAnnotation9.R i;
  output VariabilityTests.EvaluateAnnotation9.R o;
 algorithm
  o.p := -41;
  o.p := i.p + 42;
  return;
 end VariabilityTests.EvaluateAnnotation9.F;

 record VariabilityTests.EvaluateAnnotation9.R
  parameter Real p;
 end VariabilityTests.EvaluateAnnotation9.R;

end VariabilityTests.EvaluateAnnotation9;
")})));
end EvaluateAnnotation9;

model EvaluateAnnotation10
    record R
        parameter Real a = 1;
        parameter Real b = a;
        constant Real p = 3;
    end R;

    parameter R r1(a = 2);
    
    model M
        parameter R r2 annotation(Evaluate=true);
    end m;
    
    M m(r2 = r1);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation10",
            description="Evaluate annotation on record with mixed variabilities",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation10
 structural parameter VariabilityTests.EvaluateAnnotation10.R r1 = VariabilityTests.EvaluateAnnotation10.R(2, 2, 3);
 eval parameter VariabilityTests.EvaluateAnnotation10.R m.r2 = VariabilityTests.EvaluateAnnotation10.R(2, 2, 3);

public
 record VariabilityTests.EvaluateAnnotation10.R
  parameter Real a;
  parameter Real b;
  constant Real p;
 end VariabilityTests.EvaluateAnnotation10.R;

end VariabilityTests.EvaluateAnnotation10;
")})));
end EvaluateAnnotation10;

model EvaluateAnnotation11
    parameter A[:] a1 = {A()};
    parameter A[:] a2 = a1;
      
    record A
        parameter Integer n = 1 annotation(Evaluate=true);
        parameter Integer x = 1;
    end A;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EvaluateAnnotation11",
            description="Evaluate annotation on record with mixed variabilities",
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityTests.EvaluateAnnotation11
 eval parameter Integer a1[1].n = 1 /* 1 */;
 parameter Integer a1[1].x = 1 /* 1 */;
 eval parameter Integer a2[1].n = 1 /* 1 */;
 parameter Integer a2[1].x;
parameter equation
 a2[1].x = a1[1].x;
end VariabilityTests.EvaluateAnnotation11;
")})));
end EvaluateAnnotation11;

model EvaluateAnnotation12
    parameter Real p1 = 1;
    parameter Real p2 = p1 annotation(Evaluate=true);
    parameter Real p3 = p2;
    parameter Real p4 = p3 annotation(Evaluate=true);
    parameter Real p5 = p4;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation12",
            description="",
            flatModel="
fclass VariabilityTests.EvaluateAnnotation12
 structural parameter Real p1 = 1 /* 1 */;
 eval parameter Real p2 = 1 /* 1 */;
 structural parameter Real p3 = 1 /* 1 */;
 eval parameter Real p4 = 1 /* 1 */;
 structural parameter Real p5 = 1 /* 1 */;
end VariabilityTests.EvaluateAnnotation12;

")})));
end EvaluateAnnotation12;



model FinalParameterEval1
    model A
        parameter Real p = 1;
        Real x = p;
    end A;
    
    A a(final p = 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval1",
            description="Check that parameters with final modification are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval1
 final parameter Real a.p = 2 /* 2 */;
 Real a.x = 2.0;
end VariabilityTests.FinalParameterEval1;
")})));
end FinalParameterEval1;


model FinalParameterEval2
    final parameter Real p = 1;
    Real x = p;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval2",
            description="Check that final parameters are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval2
 final parameter Real p = 1 /* 1 */;
 Real x = 1.0;
end VariabilityTests.FinalParameterEval2;
")})));
end FinalParameterEval2;


model FinalParameterEval3
    record R
        Real a;
    end R;
    
    final parameter R r = R(1);
    Real x = r.a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval3",
            description="Check that members of final record parameters are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval3
 final parameter VariabilityTests.FinalParameterEval3.R r = VariabilityTests.FinalParameterEval3.R(1) /* VariabilityTests.FinalParameterEval3.R(1) */;
 Real x = 1.0;

public
 record VariabilityTests.FinalParameterEval3.R
  Real a;
 end VariabilityTests.FinalParameterEval3.R;

end VariabilityTests.FinalParameterEval3;
")})));
end FinalParameterEval3;


model FinalParameterEval4
    record R
        Real a;
    end R;
    
    model A
        
        parameter R r;
        Real x = r.a;
    end A;
    
    A a(final r = R(1));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval4",
            description="Check that members of record parameters with final modification are evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval4
 final parameter VariabilityTests.FinalParameterEval4.R a.r = VariabilityTests.FinalParameterEval4.R(1) /* VariabilityTests.FinalParameterEval4.R(1) */;
 Real a.x = 1.0;

public
 record VariabilityTests.FinalParameterEval4.R
  Real a;
 end VariabilityTests.FinalParameterEval4.R;

end VariabilityTests.FinalParameterEval4;
")})));
end FinalParameterEval4;


model FinalParameterEval5
    final parameter Real p(fixed = false);
    Real x = p;
initial equation
    p = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval5",
            description="Check that final parameters with fixed=false are not evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval5
 initial parameter Real p(fixed = false);
 Real x = p;
initial equation 
 p = 1;
end VariabilityTests.FinalParameterEval5;
")})));
end FinalParameterEval5;

model FinalParameterEval6
    record R
        Real n = 1;
    end R;
    
    function f
        input R x;
        output R y = x;
      algorithm
    end f;
    
    final parameter R r1;
    parameter R r2 = f(r1);
    Real x = r2.n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="FinalParameterEval6",
            description="Check that final parameters with fixed=false are not evaluated",
            flatModel="
fclass VariabilityTests.FinalParameterEval6
 final parameter VariabilityTests.FinalParameterEval6.R r1 = VariabilityTests.FinalParameterEval6.R(1) /* VariabilityTests.FinalParameterEval6.R(1) */;
 final parameter VariabilityTests.FinalParameterEval6.R r2 = VariabilityTests.FinalParameterEval6.R(1) /* VariabilityTests.FinalParameterEval6.R(1) */;
 Real x = 1.0;

public
 function VariabilityTests.FinalParameterEval6.f
  input VariabilityTests.FinalParameterEval6.R x;
  output VariabilityTests.FinalParameterEval6.R y;
 algorithm
  y := x;
  return;
 end VariabilityTests.FinalParameterEval6.f;

 record VariabilityTests.FinalParameterEval6.R
  Real n;
 end VariabilityTests.FinalParameterEval6.R;

end VariabilityTests.FinalParameterEval6;
")})));
end FinalParameterEval6;

package IfEquations

model SelectBranch1
    parameter Boolean p = false;
    Real x;
equation
    if p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SelectBranch1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.SelectBranch1
 structural parameter Boolean p = false /* false */;
 Real x;
equation
 if false then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.SelectBranch1;
")})));
end SelectBranch1;

model EvaluateAnnotation1
    parameter Boolean p = false annotation(Evaluate=false);
    Real x;
equation
    if p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation1
 parameter Boolean p = false /* false */;
 Real x;
equation
 if p then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotation1;
")})));
end EvaluateAnnotation1;

model EvaluateAnnotation2
    parameter Boolean p = false annotation(Evaluate=true);
    Real x;
equation
    if p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation2",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation2
 eval parameter Boolean p = false /* false */;
 Real x;
equation
 if false then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotation2;
")})));
end EvaluateAnnotation2;

model EvaluateAnnotation3
    record R
        parameter Boolean p = false annotation(Evaluate=true);
    end R;

    R r annotation(Evaluate=false);

    Real x;
equation
    if r.p then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation3",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation3
 parameter VariabilityTests.IfEquations.EvaluateAnnotation3.R r(p=false);
 Real x;
equation
 if r.p then
  x = time;
 else
  x = time + 1;
 end if;

public
 record VariabilityTests.IfEquations.EvaluateAnnotation3.R
  parameter Boolean p;
 end VariabilityTests.IfEquations.EvaluateAnnotation3.R;

end VariabilityTests.IfEquations.EvaluateAnnotation3;
")})));
end EvaluateAnnotation3;

model EvaluateAnnotation4
    parameter Boolean p1 = false annotation(Evaluate=false);
    parameter Boolean p2 = p1;
    Real x;
equation
    if p2 then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation4",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation4
 parameter Boolean p1 = false /* false */;
 parameter Boolean p2 = p1 /* false */;
 Real x;
equation
 if p2 then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotation4;
")})));
end EvaluateAnnotation4;

model EvaluateAnnotation5
    parameter Real[:] p = {i for i in 1:1} annotation(Evaluate=false);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotation5",
            description="For index in evaluate false",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotation5
 parameter Real p[1] = {1};
end VariabilityTests.IfEquations.EvaluateAnnotation5;
")})));
end EvaluateAnnotation5;

model EvaluateAnnotationUnbalanced1
    parameter Boolean p = false annotation(Evaluate=false);
    Real x;
equation
    if p then
        
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotationUnbalanced1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotationUnbalanced1
 structural parameter Boolean p = false /* false */;
 Real x;
equation
 if false then
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotationUnbalanced1;
")})));
end EvaluateAnnotationUnbalanced1;

model EvaluateAnnotationOverride1
    parameter Integer p = 2 annotation(Evaluate=false);
    Real x;
    Real y;
equation
    if p > 3 then
        x = time;
    else
        x = time + 1;
    end if;
    y = x + sum(1:p);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotationOverride1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotationOverride1
 structural parameter Integer p = 2 /* 2 */;
 Real x;
 Real y;
equation
 if 2 > 3 then
  x = time;
 else
  x = time + 1;
 end if;
 y = x + sum(1:2);
end VariabilityTests.IfEquations.EvaluateAnnotationOverride1;
")})));
end EvaluateAnnotationOverride1;

model EvaluateAnnotationNoValue1
    parameter Boolean p1 = false annotation(Evaluate);
    Real x;
equation
    if p1 then
        x = time;
    else
        x = time + 1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EvaluateAnnotationNoValue1",
            description="",
            flatModel="
fclass VariabilityTests.IfEquations.EvaluateAnnotationNoValue1
 structural parameter Boolean p1 = false /* false */;
 Real x;
equation
 if false then
  x = time;
 else
  x = time + 1;
 end if;
end VariabilityTests.IfEquations.EvaluateAnnotationNoValue1;
")})));
end EvaluateAnnotationNoValue1;

end IfEquations;

model Circular1
    final parameter Real x = y;
    final parameter Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Circular1",
            description="",
            errorMessage="
2 errors found:

Error at line 2, column 30, in file 'Compiler/ModelicaFrontEnd/test/modelica/VariabilityTests.mo':
  Circularity in binding expression of parameter: x = y

Error at line 3, column 30, in file 'Compiler/ModelicaFrontEnd/test/modelica/VariabilityTests.mo':
  Circularity in binding expression of parameter: y = x
")})));
end Circular1;

package LoadResource

model LoadResource1
    parameter String p1 = "modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt";
    parameter String p2 = Modelica.Utilities.Files.loadResource(p1);
    parameter String p3 = p1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoadResource1",
            description="Mark loadResource input as structural",
            regexp="/\"[^\"]+\"/\"\"/",
            flatModel="
fclass VariabilityTests.LoadResource.LoadResource1
 structural (loadResource) parameter String p1 = \"\" /* \"\" */;
 parameter String p2 = loadResource(\"\");
 structural parameter String p3 = \"\" /* \"\" */;
end VariabilityTests.LoadResource.LoadResource1;
")})));
end LoadResource1;

model LoadResource2
    function f
        input String x;
        output String y = Modelica.Utilities.Files.loadResource(x);
        algorithm
    end f;
    parameter String p1 = "modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt";
    parameter String p2 = f(p1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoadResource2",
            description="Mark loadResource input as structural",
            regexp="/\"[^\"]+\"/\"\"/",
            flatModel="
fclass VariabilityTests.LoadResource.LoadResource2
 structural (loadResource) parameter String p1 = \"\" /* \"\" */;
 structural parameter String p2 = \"\" /* \"\" */;

public
 function VariabilityTests.LoadResource.LoadResource2.f
  input String x;
  output String y;
 algorithm
  y := loadResource(x);
  return;
 end VariabilityTests.LoadResource.LoadResource2.f;

end VariabilityTests.LoadResource.LoadResource2;
")})));
end LoadResource2;

model LoadResource3
    function g
        input String x;
        output String y = f(x);
        algorithm
    end g;
    function f
        input String x;
        output String y;
    algorithm
        y := Modelica.Utilities.Files.loadResource(x);
    end f;
    parameter String p1 = "modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt";
    parameter String p2 = g(p1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoadResource3",
            description="Mark loadResource input as structural",
            regexp="/\"[^\"]+\"/\"\"/",
            flatModel="
fclass VariabilityTests.LoadResource.LoadResource3
 structural (loadResource) parameter String p1 = \"\" /* \"\" */;
 structural parameter String p2 = \"\" /* \"\" */;

public
 function VariabilityTests.LoadResource.LoadResource3.g
  input String x;
  output String y;
 algorithm
  y := VariabilityTests.LoadResource.LoadResource3.f(x);
  return;
 end VariabilityTests.LoadResource.LoadResource3.g;

 function VariabilityTests.LoadResource.LoadResource3.f
  input String x;
  output String y;
 algorithm
  y := loadResource(x);
  return;
 end VariabilityTests.LoadResource.LoadResource3.f;

end VariabilityTests.LoadResource.LoadResource3;
")})));
end LoadResource3;

model LoadResource4
    function g
        input Integer n;
        input String x;
        output String y = if n > 0 then f(n, x) else x;
        algorithm
    end g;
    function f
        input Integer n;
        input String x;
        output String y;
    algorithm
        y := g(n - 1, x);
        y := Modelica.Utilities.Files.loadResource(x);
    end f;
    parameter String p1 = "modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt";
    parameter String p2 = g(3, p1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoadResource4",
            description="Mark loadResource input as structural",
            regexp="/\"[^\"]+\"/\"\"/",
            flatModel="
fclass VariabilityTests.LoadResource.LoadResource4
 structural (loadResource) parameter String p1 = \"\" /* \"\" */;
 structural parameter String p2 = \"\" /* \"\" */;

public
 function VariabilityTests.LoadResource.LoadResource4.g
  input Integer n;
  input String x;
  output String y;
 algorithm
  y := if n > 0 then VariabilityTests.LoadResource.LoadResource4.f(n, x) else x;
  return;
 end VariabilityTests.LoadResource.LoadResource4.g;

 function VariabilityTests.LoadResource.LoadResource4.f
  input Integer n;
  input String x;
  output String y;
 algorithm
  y := VariabilityTests.LoadResource.LoadResource4.g(n - 1, x);
  y := loadResource(x);
  return;
 end VariabilityTests.LoadResource.LoadResource4.f;

end VariabilityTests.LoadResource.LoadResource4;
")})));
end LoadResource4;

model LoadResource5
    function f
        input String x;
        String s = Modelica.Utilities.Files.loadResource(x);
        output Real y1,y2;
    algorithm
        y1 := 1;
        y2 := 2;
    end f;
    parameter String p1 = "modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt";
    Real x,y;
equation
    (x,y) = f(p1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="LoadResource5",
            description="Mark loadResource input as structural, in function call clause",
            errorMessage="
Error at line 13, column 13, in file '...', CANNOT_EVALUATE_LOADRESOURCE:
  Could not evaluate function call which depends on loadResource during flattening: f(p1)
")})));
end LoadResource5;

model LoadResource6
    function f
        input String x;
        output String y = Modelica.Utilities.Files.loadResource(x);
    algorithm
        assert(false, "nope");
    end f;
    parameter String p1 = "modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt";
    parameter String p2 = f(p1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="LoadResource6",
            description="Mark loadResource input as structural",
            errorMessage="
Error at line 9, column 27, in file '...', CANNOT_EVALUATE_LOADRESOURCE:
  Could not evaluate function call which depends on loadResource during flattening: f(p1)
    in function 'VariabilityTests.LoadResource.LoadResource6.f'
    Assertion failed: nope
")})));
end LoadResource6;

model LoadResource7
    parameter String p1 = "modelica://Modelica/Resources/Data/Utilities";
    parameter String p2 = Modelica.Utilities.Files.loadResource(p1);
    String p3 = Modelica.Utilities.Files.loadResource(p1) + "file.txt";

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoadResource7",
            description="Mark loadResource input as structural",
            regexp="/\"[^\"]+\"/\"\"/",
            flatModel="
fclass VariabilityTests.LoadResource.LoadResource7
 structural (loadResource) parameter String p1 = \"\" /* \"\" */;
 structural parameter String p2 = \"\" /* \"\" */;
 discrete String p3 = \"\" + \"\";
end VariabilityTests.LoadResource.LoadResource7;
")})));
end LoadResource7;

end LoadResource;


model BindingExpVariability1
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    Real x;
    parameter EO eo = EO(x);
    parameter EO eo1 = eo1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BindingExpVariability1",
            description="",
            errorMessage="
Error at line 16, column 5, in file '...', BINDING_EXPRESSION_VARIABILITY:
  Variability of binding expression (continuous-time) must be lower or equal to the variability of the component (parameter)
  
Error at line 17, column 24, in file '...':
  Circularity in binding expression of parameter: eo1 = eo1
")})));
end BindingExpVariability1;

model RecordVariabilityScalarization1
        record R1
            Real x;
            constant Real y = 2;
        end R1;
        
        record R2
            Real x;
            constant Real z = 2;
        end R2;
        
        parameter R1 r1(x=time);
        parameter R2 r2(x=time);
        parameter Real[:] x = {r1.x, r2.x};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordVariabilityScalarization1",
            description="",
            flatModel="
fclass VariabilityTests.RecordVariabilityScalarization1
 parameter Real r1.x;
 constant Real r1.y = 2;
 parameter Real r2.x;
 parameter Real x[1];
 parameter Real x[2];
parameter equation
 r1.x = time;
 r2.x = time;
 x[1] = r1.x;
 x[2] = r2.x;
end VariabilityTests.RecordVariabilityScalarization1;
")})));
end RecordVariabilityScalarization1;

model ExternalObjectConstant1
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    function f
        input EO x;
        output Real y;
        external;
    end f;
    
    constant Real x = 1;
    constant EO eo = EO(x);
    constant EO eo1 = eo;
    constant EO eo2 = eo;
    Real y = f(eo1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalObjectConstant1",
            description="",
            flatModel="
fclass VariabilityTests.ExternalObjectConstant1
 constant Real x = 1;
 Real y = VariabilityTests.ExternalObjectConstant1.f(global(VariabilityTests.ExternalObjectConstant1.eo1));
global variables
 constant VariabilityTests.ExternalObjectConstant1.EO VariabilityTests.ExternalObjectConstant1.eo = VariabilityTests.ExternalObjectConstant1.EO.constructor(1.0);
 constant VariabilityTests.ExternalObjectConstant1.EO VariabilityTests.ExternalObjectConstant1.eo1 = global(VariabilityTests.ExternalObjectConstant1.eo);

public
 function VariabilityTests.ExternalObjectConstant1.EO.destructor
  input VariabilityTests.ExternalObjectConstant1.EO eo;
 algorithm
  external \"C\" destructor(eo);
  return;
 end VariabilityTests.ExternalObjectConstant1.EO.destructor;

 function VariabilityTests.ExternalObjectConstant1.EO.constructor
  input Real x;
  output VariabilityTests.ExternalObjectConstant1.EO eo;
 algorithm
  external \"C\" eo = constructor(x);
  return;
 end VariabilityTests.ExternalObjectConstant1.EO.constructor;

 function VariabilityTests.ExternalObjectConstant1.f
  input VariabilityTests.ExternalObjectConstant1.EO x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end VariabilityTests.ExternalObjectConstant1.f;

 type VariabilityTests.ExternalObjectConstant1.EO = ExternalObject;
end VariabilityTests.ExternalObjectConstant1;
")})));
end ExternalObjectConstant1;

model ExternalObjectConstant2
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    function f
        input EO x;
        output Real y;
        external;
    end f;
    
    function g
        input EO x;
        output EO y = x;
    algorithm
        annotation(Inline=false);
    end g;
    
    constant Real x = 1;
    constant EO eo = EO(x);
    constant EO eo1 = g(eo);
    Real y = f(eo1);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalObjectConstant2",
            description="",
            flatModel="
            
fclass VariabilityTests.ExternalObjectConstant2
 constant Real x = 1;
 Real y = VariabilityTests.ExternalObjectConstant2.f(global(VariabilityTests.ExternalObjectConstant2.eo1));
global variables
 constant VariabilityTests.ExternalObjectConstant2.EO VariabilityTests.ExternalObjectConstant2.eo = VariabilityTests.ExternalObjectConstant2.EO.constructor(1.0);
 constant VariabilityTests.ExternalObjectConstant2.EO VariabilityTests.ExternalObjectConstant2.eo1 = VariabilityTests.ExternalObjectConstant2.g(global(VariabilityTests.ExternalObjectConstant2.eo));

public
 function VariabilityTests.ExternalObjectConstant2.EO.destructor
  input VariabilityTests.ExternalObjectConstant2.EO eo;
 algorithm
  external \"C\" destructor(eo);
  return;
 end VariabilityTests.ExternalObjectConstant2.EO.destructor;

 function VariabilityTests.ExternalObjectConstant2.EO.constructor
  input Real x;
  output VariabilityTests.ExternalObjectConstant2.EO eo;
 algorithm
  external \"C\" eo = constructor(x);
  return;
 end VariabilityTests.ExternalObjectConstant2.EO.constructor;

 function VariabilityTests.ExternalObjectConstant2.g
  input VariabilityTests.ExternalObjectConstant2.EO x;
  output VariabilityTests.ExternalObjectConstant2.EO y;
 algorithm
  y := x;
  return;
 annotation(Inline = false);
 end VariabilityTests.ExternalObjectConstant2.g;

 function VariabilityTests.ExternalObjectConstant2.f
  input VariabilityTests.ExternalObjectConstant2.EO x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end VariabilityTests.ExternalObjectConstant2.f;

 type VariabilityTests.ExternalObjectConstant2.EO = ExternalObject;
end VariabilityTests.ExternalObjectConstant2;
")})));
end ExternalObjectConstant2;

model ExternalObjectGlobalConstant1
    
    package P
        model EO
            extends ExternalObject;
            function constructor
                input Real x;
                output EO eo;
                external;
            end constructor;
            function destructor
                input EO eo;
                external;
            end destructor;
        end EO;
        
        function f
            output Real y;
            external "C" y = f(eo1);
        end f;
        
        constant Real x = 1;
        constant EO eo = EO(x);
        constant EO eo1 = eo;
    end P;
    
    function f
        input Real x;
        output Real y = x + P.f();
    algorithm
    end f;

    Real y = f(time);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalObjectGlobalConstant1",
            description="",
            flatModel="
fclass VariabilityTests.ExternalObjectGlobalConstant1
 Real y = VariabilityTests.ExternalObjectGlobalConstant1.f(time);
global variables
 constant VariabilityTests.ExternalObjectGlobalConstant1.P.EO VariabilityTests.ExternalObjectGlobalConstant1.P.eo = VariabilityTests.ExternalObjectGlobalConstant1.P.EO.constructor(1.0);
 constant VariabilityTests.ExternalObjectGlobalConstant1.P.EO VariabilityTests.ExternalObjectGlobalConstant1.P.eo1 = global(VariabilityTests.ExternalObjectGlobalConstant1.P.eo);

public
 function VariabilityTests.ExternalObjectGlobalConstant1.f
  input Real x;
  output Real y;
 algorithm
  y := x + VariabilityTests.ExternalObjectGlobalConstant1.P.f();
  return;
 end VariabilityTests.ExternalObjectGlobalConstant1.f;

 function VariabilityTests.ExternalObjectGlobalConstant1.P.f
  output Real y;
 algorithm
  external \"C\" y = f(global(VariabilityTests.ExternalObjectGlobalConstant1.P.eo1));
  return;
 end VariabilityTests.ExternalObjectGlobalConstant1.P.f;

 function VariabilityTests.ExternalObjectGlobalConstant1.P.EO.destructor
  input VariabilityTests.ExternalObjectGlobalConstant1.P.EO eo;
 algorithm
  external \"C\" destructor(eo);
  return;
 end VariabilityTests.ExternalObjectGlobalConstant1.P.EO.destructor;

 function VariabilityTests.ExternalObjectGlobalConstant1.P.EO.constructor
  input Real x;
  output VariabilityTests.ExternalObjectGlobalConstant1.P.EO eo;
 algorithm
  external \"C\" eo = constructor(x);
  return;
 end VariabilityTests.ExternalObjectGlobalConstant1.P.EO.constructor;

 type VariabilityTests.ExternalObjectGlobalConstant1.P.EO = ExternalObject;
end VariabilityTests.ExternalObjectGlobalConstant1;
")})));
end ExternalObjectGlobalConstant1;

model ExternalObjectGlobalConstant2
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    function f
        input EO x;
        output Real y;
        external;
    end f;
    
    record R
        EO eo;
    end R;
    
    package P
        constant Real x = 1;
        constant EO[:] eo = {EO(x)};
    end P;
    
    Real y1 = f(P.eo[1]);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ExternalObjectGlobalConstant2",
            description="",
            errorMessage="
Compliance error at line 27, column 9, in file '...', EXTERNAL_OBJECT_CONSTANT_IN_COMPOSITE:
  Access to external object constants in arrays or records is not supported

Compliance error at line 30, column 17, in file '...', EXTERNAL_OBJECT_CONSTANT_IN_COMPOSITE:
  Access to external object constants in arrays or records is not supported

Compliance error at line 30, column 19, in file '...', EXTERNAL_OBJECT_CONSTANT_IN_COMPOSITE:
  Access to external object constants in arrays or records is not supported
")})));
end ExternalObjectGlobalConstant2;

model ExternalObjectGlobalConstant3
    model EO
        extends ExternalObject;
        function constructor
            input Real x;
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    function f
        input EO x;
        output Real y;
        external;
    end f;
    
    record R
        EO eo;
    end R;
    
    package P
        constant Real x = 1;
        constant R r = R(EO(x));
    end P;
    
    Real y2 = f(P.r.eo);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ExternalObjectGlobalConstant3",
            description="",
            errorMessage="
Compliance error at line 22, column 9, in file '...', EXTERNAL_OBJECT_CONSTANT_IN_COMPOSITE,
In component r:
  Access to external object constants in arrays or records is not supported

Compliance error at line 30, column 17, in file '...', EXTERNAL_OBJECT_CONSTANT_IN_COMPOSITE:
  Access to external object constants in arrays or records is not supported

Compliance error at line 30, column 21, in file '...', EXTERNAL_OBJECT_CONSTANT_IN_COMPOSITE:
  Access to external object constants in arrays or records is not supported
")})));
end ExternalObjectGlobalConstant3;


end VariabilityTests;
