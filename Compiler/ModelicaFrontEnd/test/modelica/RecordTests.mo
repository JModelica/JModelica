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

package RecordTests


model RecordFlat1
 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat1",
            description="Records: basic flattening test",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFlat1
 RecordTests.RecordFlat1.A x;
 RecordTests.RecordFlat1.A y;
equation
 y = x;

public
 record RecordTests.RecordFlat1.A
  Real a;
  Real b;
 end RecordTests.RecordFlat1.A;

end RecordTests.RecordFlat1;
")})));
end RecordFlat1;


model RecordFlat2
 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat2",
            description="Records: accessing components",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFlat2
 RecordTests.RecordFlat2.A x;
 RecordTests.RecordFlat2.A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;

public
 record RecordTests.RecordFlat2.A
  Real a;
  Real b;
 end RecordTests.RecordFlat2.A;

end RecordTests.RecordFlat2;
")})));
end RecordFlat2;


model RecordFlat3
 record A
  Real a;
  Real b;
 end A;
 
 A x(a=1, b=2);
 A y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat3",
            description="Records: modification",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFlat3
 RecordTests.RecordFlat3.A x(a = 1,b = 2);
 RecordTests.RecordFlat3.A y;
equation
 y = x;

public
 record RecordTests.RecordFlat3.A
  Real a;
  Real b;
 end RecordTests.RecordFlat3.A;

end RecordTests.RecordFlat3;
")})));
end RecordFlat3;


model RecordFlat4
 record A
  Real a;
  Real b;
 end A;

 record B
  Real c;
  Real d;
 end B;
 
 B y;
 A x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat4",
            description="Records: two records",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFlat4
 RecordTests.RecordFlat4.B y;
 RecordTests.RecordFlat4.A x;

public
 record RecordTests.RecordFlat4.B
  Real c;
  Real d;
 end RecordTests.RecordFlat4.B;

 record RecordTests.RecordFlat4.A
  Real a;
  Real b;
 end RecordTests.RecordFlat4.A;

end RecordTests.RecordFlat4;
")})));
end RecordFlat4;


model RecordFlat5
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
  Real d;
 end B;
 
 A x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat5",
            description="Records: nestled records",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFlat5
 RecordTests.RecordFlat5.A x;

public
 record RecordTests.RecordFlat5.B
  Real c;
  Real d;
 end RecordTests.RecordFlat5.B;

 record RecordTests.RecordFlat5.A
  Real a;
  RecordTests.RecordFlat5.B b;
 end RecordTests.RecordFlat5.A;

end RecordTests.RecordFlat5;
")})));
end RecordFlat5;


model RecordFlat6
    record A
        Real a;
    end A;
    
    record B
        extends A;
        Real a;
        Real b;
    end B;
    
    B b(a = 1, b = 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat6",
            description="Merging of equivalent members when flattening records",
            flatModel="
fclass RecordTests.RecordFlat6
 RecordTests.RecordFlat6.B b(a = 1,b = 2);

public
 record RecordTests.RecordFlat6.B
  Real a;
  Real b;
 end RecordTests.RecordFlat6.B;

end RecordTests.RecordFlat6;
")})));
end RecordFlat6;


model RecordFlat7
    record A
        Real b = time;
    end A;

    model B
        A a;
    end B;

    model C
        extends B;
    end C;

    model D
        extends B;
        extends C;
    end D;

    D d;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat7",
            description="Merging of equivalent record variables when flattening",
            flatModel="
fclass RecordTests.RecordFlat7
 RecordTests.RecordFlat7.A d.a(b = time);

public
 record RecordTests.RecordFlat7.A
  Real b;
 end RecordTests.RecordFlat7.A;

end RecordTests.RecordFlat7;
")})));
end RecordFlat7;

model RecordFlat8
  record R
    Integer x;
  end R;

  constant R r(x=12);
  R r2 = r;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat8",
            description="Flattening records with modifiers.",
            flatModel="
fclass RecordTests.RecordFlat8
 constant RecordTests.RecordFlat8.R r = RecordTests.RecordFlat8.R(12);
 discrete RecordTests.RecordFlat8.R r2 = RecordTests.RecordFlat8.R(12);

public
 record RecordTests.RecordFlat8.R
  discrete Integer x;
 end RecordTests.RecordFlat8.R;

end RecordTests.RecordFlat8;
")})));
end RecordFlat8;

model RecordFlat9
    record A
      Real x;
    end A;
    
    record B
      extends A;
      Real y;
    end B;
    
    constant B b(y=2);
    B b2 = b;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat9",
            description="Flattening records with modifiers.",
            flatModel="
fclass RecordTests.RecordFlat9
 constant RecordTests.RecordFlat9.B b = RecordTests.RecordFlat9.B(0.0, 2);
 RecordTests.RecordFlat9.B b2 = RecordTests.RecordFlat9.B(0.0, 2);

public
 record RecordTests.RecordFlat9.B
  Real x;
  Real y;
 end RecordTests.RecordFlat9.B;

end RecordTests.RecordFlat9;
")})));
end RecordFlat9;

model RecordFlat10
    model R1
        function f
            input R2 r2;
            output Real x = r2.xx;
          algorithm
        end f;
        parameter R2 r2;
        final parameter Real x = f(r2) annotation(Evaluate=true);
    end R1;
    record R2
        Real x;
        Real xx = x;
    end R2;
    parameter R1 r(r2(x=3));
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat10",
            description="Flattening records with modifiers.",
            flatModel="
fclass RecordTests.RecordFlat10
 structural parameter RecordTests.RecordFlat10.R2 r.r2 = RecordTests.RecordFlat10.R2(3, 3) /* RecordTests.RecordFlat10.R2(3, 3) */;
 eval parameter Real r.x = 3 /* 3 */;

public
 function RecordTests.RecordFlat10.r.f
  input RecordTests.RecordFlat10.R2 r2;
  output Real x;
 algorithm
  x := r2.xx;
  return;
 end RecordTests.RecordFlat10.r.f;

 record RecordTests.RecordFlat10.R2
  Real x;
  Real xx;
 end RecordTests.RecordFlat10.R2;

end RecordTests.RecordFlat10;
")})));
end RecordFlat10;

/* This tests gives wrong result #3795 */
model RecordFlat11
    record A
      Real a;
    end A;
    
    record B1
      Real b1;
    end B1;
    
    record B2
      Real b2;
    end B2;
    
    record B
      extends B1;
      Real b;
      extends B2;
    end B;
    
    record C
      Real c1;
      extends A;
      Real c2;
      extends B;
      Real c3;
    end C;
    
    constant C c(c1=1,c2=2,c3=3,a=1.5,b=2.5,b1=2.25,b2=2.75);
    C c2 = c;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat11",
            description="Flattening records with modifiers.",
            flatModel="
fclass RecordTests.RecordFlat11
 constant RecordTests.RecordFlat11.C c = RecordTests.RecordFlat11.C(1.5, 2.25, 2.75, 2.5, 1, 2, 3);
 RecordTests.RecordFlat11.C c2 = RecordTests.RecordFlat11.C(1.5, 2.25, 2.75, 2.5, 1, 2, 3);

public
 record RecordTests.RecordFlat11.C
  Real a;
  Real b1;
  Real b2;
  Real b;
  Real c1;
  Real c2;
  Real c3;
 end RecordTests.RecordFlat11.C;

end RecordTests.RecordFlat11;
")})));
end RecordFlat11;

model RecordFlat12
    record R
        Real[:] x;
        Real y = x[end];
    end R;
    
    R r(x=1:2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat12",
            description="Records: end expression",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFlat12
 RecordTests.RecordFlat12.R r(x(size() = {2}) = 1:2,y = r.x[2]);

public
 record RecordTests.RecordFlat12.R
  Real x[:];
  Real y;
 end RecordTests.RecordFlat12.R;

end RecordTests.RecordFlat12;
")})));
end RecordFlat12;

model RecordFlat13
    model EO
        extends ExternalObject;
        function constructor
            output EO eo;
            external;
        end constructor;
        function destructor
            input EO eo;
            external;
        end destructor;
    end EO;
    
    record R
        EO eo = EO();
    end R;
    
    parameter EO eo = EO() annotation(Evaluate=true);
    parameter R r annotation(Evaluate=true);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFlat13",
            description="Records: eval true on external object",
            flatModel="
fclass RecordTests.RecordFlat13
 parameter RecordTests.RecordFlat13.EO eo = RecordTests.RecordFlat13.EO.constructor() /* {} */;
 parameter RecordTests.RecordFlat13.EO r.eo = RecordTests.RecordFlat13.EO.constructor() /* {} */;

public
 function RecordTests.RecordFlat13.EO.destructor
  input RecordTests.RecordFlat13.EO eo;
 algorithm
  external \"C\" destructor(eo);
  return;
 end RecordTests.RecordFlat13.EO.destructor;

 function RecordTests.RecordFlat13.EO.constructor
  output RecordTests.RecordFlat13.EO eo;
 algorithm
  external \"C\" eo = constructor();
  return;
 end RecordTests.RecordFlat13.EO.constructor;

 type RecordTests.RecordFlat13.EO = ExternalObject;
end RecordTests.RecordFlat13;
")})));
end RecordFlat13;

model RecordFlat14
    record R
        parameter Integer n = 1 annotation(Evaluate=true);
        Real[n] x = 1:n;
    end R;
    
    R r1 = R(n=2);
    R r2 = r1;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFlat14",
            description="Records: eval true on in record declaration",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordFlat14
 eval parameter Integer r1.n = 2 /* 2 */;
 Real r1.x[1];
 Real r1.x[2];
 eval parameter Integer r2.n = 2 /* 2 */;
 Real r2.x[1];
 Real r2.x[2];
equation
 r1.x[1] = 1;
 r1.x[2] = 2;
 r2.x[1] = r1.x[1];
 r2.x[2] = r1.x[2];
end RecordTests.RecordFlat14;
")})));
end RecordFlat14;

model RecordFlat15
    record R
        Real[:] values;
    end R;
    
    R a(values={0, 0.1, 0.2, 5});
    R b(values={1, 2.1, 6});
    
    R r = if 1 > 2 then a else b;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFlat15",
            description="#5692",
            flatModel="
fclass RecordTests.RecordFlat15
 constant Real a.values[1] = 0;
 constant Real a.values[2] = 0.1;
 constant Real a.values[3] = 0.2;
 constant Real a.values[4] = 5;
 constant Real r.values[1] = 1;
 constant Real r.values[2] = 2.1;
 constant Real r.values[3] = 6;
end RecordTests.RecordFlat15;
")})));
end RecordFlat15;

model EquivalentRecords1
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 A x;
 B y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentRecords1",
            description="Records: equivalent types",
            variability_propagation=false,
            flatModel="
fclass RecordTests.EquivalentRecords1
 RecordTests.EquivalentRecords1.A x;
 RecordTests.EquivalentRecords1.B y;
equation
 y = x;

public
 record RecordTests.EquivalentRecords1.A
  Real a;
  Real b;
 end RecordTests.EquivalentRecords1.A;

 record RecordTests.EquivalentRecords1.B
  Real a;
  Real b;
 end RecordTests.EquivalentRecords1.B;

end RecordTests.EquivalentRecords1;
")})));
end EquivalentRecords1;


model EquivalentRecords2
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 A x;
 B y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="EquivalentRecords2",
            description="Records: non-equivalent types (component name)",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 15, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', TYPE_MISMATCH_IN_EQUATION:
  The right and left expression types of equation are not compatible, type of left-hand side is RecordTests.EquivalentRecords2.B, and type of right-hand side is RecordTests.EquivalentRecords2.A
")})));
end EquivalentRecords2;


model EquivalentRecords3
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Boolean b;
 end B;
 
 A x;
 B y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="EquivalentRecords3",
            description="Records: non-equivalent types (component type)",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 15, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', TYPE_MISMATCH_IN_EQUATION:
  The right and left expression types of equation are not compatible, type of left-hand side is RecordTests.EquivalentRecords3.B, and type of right-hand side is RecordTests.EquivalentRecords3.A
")})));
end EquivalentRecords3;


model EquivalentRecords4
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 record C
  A a;
  Real e;
 end C;

 record D
  B a;
  Real e;
 end D;
 
 C x;
 D y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentRecords4",
            description="Records: equivalent nested types",
            variability_propagation=false,
            flatModel="
fclass RecordTests.EquivalentRecords4
 RecordTests.EquivalentRecords4.C x;
 RecordTests.EquivalentRecords4.D y;
equation
 y = x;

public
 record RecordTests.EquivalentRecords4.A
  Real a;
  Real b;
 end RecordTests.EquivalentRecords4.A;

 record RecordTests.EquivalentRecords4.C
  RecordTests.EquivalentRecords4.A a;
  Real e;
 end RecordTests.EquivalentRecords4.C;

 record RecordTests.EquivalentRecords4.B
  Real a;
  Real b;
 end RecordTests.EquivalentRecords4.B;

 record RecordTests.EquivalentRecords4.D
  RecordTests.EquivalentRecords4.B a;
  Real e;
 end RecordTests.EquivalentRecords4.D;

end RecordTests.EquivalentRecords4;
")})));
end EquivalentRecords4;


model EquivalentRecords5
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 record C
  A a;
  Real e;
 end C;

 record D
  B a;
  Real e;
 end D;
 
 C x;
 D y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="EquivalentRecords5",
            description="Records: non-equivalent nested types",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 25, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', TYPE_MISMATCH_IN_EQUATION:
  The right and left expression types of equation are not compatible, type of left-hand side is RecordTests.EquivalentRecords5.D, and type of right-hand side is RecordTests.EquivalentRecords5.C
")})));
end EquivalentRecords5;


model EquivalentRecords6
    record A
        Real x;
        String s;
    end A;
    
    record B
        String s;
        Real x;
    end B;
    
    function f
        input A a[2];
        output Real x;
    algorithm
        x := sum(a.x);
        x := x + 1;
    end f;
    
    Real x = f({ A(time, "aa"), B("bb", 2) });

annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="EquivalentRecords6",
        description="Check that elimination of equivalent records correctly reorders arguments of record constructors",
        flatModel="
fclass RecordTests.EquivalentRecords6
 Real x;
equation
 x = RecordTests.EquivalentRecords6.f({RecordTests.EquivalentRecords6.A(time, \"aa\"), RecordTests.EquivalentRecords6.A(2, \"bb\")});

public
 function RecordTests.EquivalentRecords6.f
  input RecordTests.EquivalentRecords6.A[:] a;
  output Real x;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:2 loop
   temp_1 := temp_1 + a[i1].x;
  end for;
  x := temp_1;
  x := x + 1;
  return;
 end RecordTests.EquivalentRecords6.f;

 record RecordTests.EquivalentRecords6.A
  Real x;
  discrete String s;
 end RecordTests.EquivalentRecords6.A;

end RecordTests.EquivalentRecords6;
")})));
end EquivalentRecords6;


model RecordType6
 record A
  Real a;
  Real b;
 end A;

 record B
  extends C;
 end B;

 record C
  extends D;
  Real a;
 end C;

 record D
  Real b;
 end D;
 
 A x(a=1, b=2);
 B y;
equation
 y = x;		

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordType6",
            description="Records: Inheritance",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordType6
 RecordTests.RecordType6.A x(a = 1,b = 2);
 RecordTests.RecordType6.B y;
equation
 y = x;

public
 record RecordTests.RecordType6.A
  Real a;
  Real b;
 end RecordTests.RecordType6.A;

 record RecordTests.RecordType6.B
  Real b;
  Real a;
 end RecordTests.RecordType6.B;

end RecordTests.RecordType6;
")})));
end RecordType6;


model RecordType7
	record A 
		Real x;
	end A;
	
	A a[:];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordType7",
            description="",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 6, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE:
  Can not infer array size of the variable a
")})));
end RecordType7;

model RecordType8
    record R
        constant Real[:] x = {1,2};
    end R;
    Real[:] r = R.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordType8",
            description="Records: type check of access to constant",
            flatModel="
fclass RecordTests.RecordType8
 Real r[2] = {1.0, 2.0};
end RecordTests.RecordType8;
")})));
end RecordType8;

model RecordType9
    record R
        parameter Real[:] x = {1,2};
    end R;
    record R2 = R(x={3});
    R2 r2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordType9",
            description="Records: type check of modification",
            flatModel="
fclass RecordTests.RecordType9
 parameter RecordTests.RecordType9.R2 r2(x(size() = {1}) = {3});

public
 record RecordTests.RecordType9.R2
  parameter Real x[:];
 end RecordTests.RecordType9.R2;

end RecordTests.RecordType9;
")})));
end RecordType9;

model RecordType10
record R
  parameter Real x[:];
end R;
record R1 = R(x = {1});
record R2 = R(x = {2, 3});

R1 r1;
R2 r2;
R r[2] = { r1, r2 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordType10",
            description="Records: array type calculation",
            flatModel="
fclass RecordTests.RecordType10
 parameter Real r1.x[1] = 1 /* 1 */;
 parameter Real r2.x[1] = 2 /* 2 */;
 parameter Real r2.x[2] = 3 /* 3 */;
 parameter Real r[1].x[1];
 parameter Real r[2].x[1];
 parameter Real r[2].x[2];
parameter equation
 r[1].x[1] = r1.x[1];
 r[2].x[1] = r2.x[1];
 r[2].x[2] = r2.x[2];
end RecordTests.RecordType10;
")})));
end RecordType10;

model RecordType11
record R
  parameter Real x[:];
end R;
record R1
  parameter Real x[1] = 1:1;
end R1;
record R2
  parameter Real x[2] = 1:2;
end R2;

R1 r1;
R2 r2;
R r[2] = { r1, r2};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordType11",
            description="Records: array type calculation",
            flatModel="
fclass RecordTests.RecordType11
 parameter Real r1.x[1] = 1 /* 1 */;
 parameter Real r2.x[1] = 1 /* 1 */;
 parameter Real r2.x[2] = 2 /* 2 */;
 parameter Real r[1].x[1];
 parameter Real r[2].x[1];
 parameter Real r[2].x[2];
parameter equation
 r[1].x[1] = r1.x[1];
 r[2].x[1] = r2.x[1];
 r[2].x[2] = r2.x[2];
end RecordTests.RecordType11;
")})));
end RecordType11;

model RecordType12
record R
    parameter Integer n;
    parameter Real x[n] = 1:n;
end R;

record R1
    extends R;
end R1;

record R2
    extends R;
end R2;

R r[2] = { R1(1), R2(3)};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordType12",
            description="Records: array type calculation",
            flatModel="
fclass RecordTests.RecordType12
 structural parameter Integer r[1].n = 1 /* 1 */;
 parameter Real r[1].x[1] = 1 /* 1 */;
 structural parameter Integer r[2].n = 3 /* 3 */;
 parameter Real r[2].x[1] = 1 /* 1 */;
 parameter Real r[2].x[2] = 2 /* 2 */;
 parameter Real r[2].x[3] = 3 /* 3 */;
end RecordTests.RecordType12;
")})));
end RecordType12;

model RecordBinding1
 record A
  Real a;
  Real b;
 end A;
 
 A x = y;
 A y;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordBinding1",
            description="Records: binding expression, same record type",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordBinding1
 RecordTests.RecordBinding1.A x = y;
 RecordTests.RecordBinding1.A y;

public
 record RecordTests.RecordBinding1.A
  Real a;
  Real b;
 end RecordTests.RecordBinding1.A;

end RecordTests.RecordBinding1;
")})));
end RecordBinding1;


model RecordBinding2
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 A x = y;
 B y;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordBinding2",
            description="Records: binding expression, equivalent record type",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordBinding2
 RecordTests.RecordBinding2.A x = y;
 RecordTests.RecordBinding2.B y;

public
 record RecordTests.RecordBinding2.A
  Real a;
  Real b;
 end RecordTests.RecordBinding2.A;

 record RecordTests.RecordBinding2.B
  Real a;
  Real b;
 end RecordTests.RecordBinding2.B;

end RecordTests.RecordBinding2;
")})));
end RecordBinding2;


model RecordBinding3
 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 A x = y;
 B y;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordBinding3",
            description="Records: binding expression, wrong type (incompatible record)",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 12, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end RecordBinding3;


model RecordBinding4
 record A
  Real a;
  Real b;
 end A;
 
 A x = y;
 A y[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordBinding4",
            description="Records: binding expression, wrong array size",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 7, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is scalar and size of binding expression is [2]
")})));
end RecordBinding4;


model RecordBinding5
 record A
  Real a;
  Real b;
 end A;
 
 A x(a = 1, b = "foo");

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordBinding5",
            description="Records: wrong type of binding exp of component",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 7, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable b does not match the declared type of the variable
")})));
end RecordBinding5;


model RecordBinding6
 record A
  Real a;
 end A;
 
 A x(a = y);
 Real y = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding6",
            description="Modification on record member with non-parameter expression",
            flatModel="
fclass RecordTests.RecordBinding6
 Real y;
equation
 y = time;
end RecordTests.RecordBinding6;
")})));
end RecordBinding6;


model RecordBinding7
 record A
  Real a;
 end A;
 
 A x(a(start = y));
 Real y = time;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordBinding7",
            description="Modification on attribute or record member with non-parameter expression",
            errorMessage="
1 errors found:

Error at line 6, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', START_VALUE_NOT_PARAMETER:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: y
")})));
end RecordBinding7;


model RecordBinding8
    record A
        Real a;
        Real b;
    end A;
    
    function f
        input Real x;
        output A y;
    algorithm
        y := A(x, x*x);
    end f;
    
    Real[2] x = time * (1:2);
    A[2] y1 = { A(x[i], time) for i in 1:2 };
    A[2] y2 = { f(x[1]), f(x[2]) };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding8",
            description="Generating binding equations for records with array binding expressions that cannot be split",
            eliminate_linear_equations=false,
            inline_functions="trivial",
            flatModel="
fclass RecordTests.RecordBinding8
 Real x[1];
 Real x[2];
 Real y1[1].b;
 Real y1[2].b;
 Real y2[1].b;
 Real y2[2].b;
equation
 x[1] = time;
 x[2] = time * 2;
 y1[1].b = time;
 y1[2].b = time;
 y2[1].b = x[1] * x[1];
 y2[2].b = x[2] * x[2];
end RecordTests.RecordBinding8;
")})));
end RecordBinding8;


model RecordBinding9
    record A
        constant Real a = 1;
        Real b;
    end A;
    
    parameter A x(b = 2);
    parameter A y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding9",
            description="Record containing constant as binding expression",
            flatModel="
fclass RecordTests.RecordBinding9
 constant Real x.a = 1;
 parameter Real x.b = 2 /* 2 */;
 constant Real y.a = 1.0;
 parameter Real y.b;
parameter equation
 y.b = x.b;
end RecordTests.RecordBinding9;
")})));
end RecordBinding9;


model RecordBinding10
    record A
        constant Real a = 1;
        Real b;
    end A;
    
    A x(b = time);
    A y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding10",
            description="Record containing constant as binding expression",
            flatModel="
fclass RecordTests.RecordBinding10
 constant Real x.a = 1;
 constant Real y.a = 1.0;
 Real y.b;
equation
 y.b = time;
end RecordTests.RecordBinding10;
")})));
end RecordBinding10;

model RecordBinding11
	record R
        parameter String s1 = "" annotation(Evaluate=true);
		parameter Boolean b1 = F(s1);
		Boolean b2 = F(s1);
	end R;
	function F
		input String name;
		output Boolean correct;
	algorithm
		if name == "foobar" then
			correct := true;
		else
			correct := false;
		end if;
	end F;
	parameter R r(s1="foobar");
	
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding11",
            description="Modification of string record member",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordBinding11
 eval parameter String r.s1 = \"foobar\" /* \"foobar\" */;
 structural parameter Boolean r.b1 = true /* true */;
 structural parameter Boolean r.b2 = true /* true */;
end RecordTests.RecordBinding11;
")})));
end RecordBinding11;


model RecordBinding12
	record A
		B b(c = 2 * d);
		Real d;
	end A;
	
	record B
		Real c;
	end B;
	
	parameter A a(d = 1);
	Real x = a.b.c * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding12",
            description="Modifications on nested records using members of outer record",
            flatModel="
fclass RecordTests.RecordBinding12
 parameter Real a.b.c;
 parameter Real a.d = 1 /* 1 */;
 Real x;
parameter equation
 a.b.c = 2 * a.d;
equation
 x = a.b.c * time;
end RecordTests.RecordBinding12;
")})));
end RecordBinding12;


model RecordBinding13
    record A
        B b = B(2 * d);
        Real d;
    end A;
    
    record B
        Real c;
    end B;
    
    parameter A a(d = 1);
    Real x = a.b.c * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding13",
            description="Binding expressions on nested records using members of outer record",
            flatModel="
fclass RecordTests.RecordBinding13
 parameter Real a.b.c;
 parameter Real a.d = 1 /* 1 */;
 Real x;
parameter equation
 a.b.c = 2 * a.d;
equation
 x = a.b.c * time;
end RecordTests.RecordBinding13;
")})));
end RecordBinding13;

model RecordBinding15
    record R1
      Real y1 = 50;
      parameter R2 r2(y2=y1);
    end R1;
    
    record R2
      Real x2;
      Real y2;
    end R2;
  
    parameter R1 r1(r2(x2=1));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding15",
            description="Flattening use of component in same record",
            flatModel="
fclass RecordTests.RecordBinding15
 parameter Real r1.y1 = 50 /* 50 */;
 parameter Real r1.r2.x2 = 1 /* 1 */;
 parameter Real r1.r2.y2;
parameter equation
 r1.r2.y2 = r1.y1;
end RecordTests.RecordBinding15;
")})));
end RecordBinding15;

model RecordBinding16
    record R1
      Real y1 = 52;
      parameter R2 r2(r3(y3=y1));
    end R1;
    
    record R2
      Real y2 = 51;
      R3 r3(x3=y2,y3=1);
    end R2;
    
    record R3
      Real x3;
      Real y3;
    end R3;
    
    parameter R1 r1;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding16",
            description="Flattening use of component in same record",
            flatModel="
fclass RecordTests.RecordBinding16
 parameter Real r1.y1 = 52 /* 52 */;
 parameter Real r1.r2.y2 = 51 /* 51 */;
 parameter Real r1.r2.r3.x3;
 parameter Real r1.r2.r3.y3;
parameter equation
 r1.r2.r3.x3 = r1.r2.y2;
 r1.r2.r3.y3 = r1.y1;
end RecordTests.RecordBinding16;
")})));
end RecordBinding16;

model RecordBinding17
    record R1
      Real y1 = 52;
      parameter R2 r2(r3(y3=y1));
    end R1;
  
    record R2
      Real y2 = 51;
      R3 r3(x3=y2,y3=1);
    end R2;
  
    record R3
      Real x3;
      Real y3;
    end R3;
    
    parameter R1 r1(r2(r3(y3=y2)));
    parameter Real y2 = 2;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding17",
            description="Flattening use of component in same record",
            flatModel="
fclass RecordTests.RecordBinding17
 parameter Real r1.y1 = 52 /* 52 */;
 parameter Real r1.r2.y2 = 51 /* 51 */;
 parameter Real r1.r2.r3.x3;
 parameter Real r1.r2.r3.y3;
 parameter Real y2 = 2 /* 2 */;
parameter equation
 r1.r2.r3.x3 = r1.r2.y2;
 r1.r2.r3.y3 = y2;
end RecordTests.RecordBinding17;
")})));
end RecordBinding17;

model RecordBinding18
    record R1
        Real x = time;
    end R1;
    
    R1 r1;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding18",
            description="Basic test of binding expression in record declaration",
            flatModel="
fclass RecordTests.RecordBinding18
 Real r1.x;
equation
 r1.x = time;
end RecordTests.RecordBinding18;
")})));
end RecordBinding18;

model RecordBinding19
    record R1
        parameter String x = "A" annotation(Evaluate=true);
        parameter String y = x annotation(Evaluate=true);
        Real z = time;
    end R1;
    
    R1 r1;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding19",
            description="String parameters in record with continuous part",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordBinding19
 eval parameter String r1.x = \"A\" /* \"A\" */;
 eval parameter String r1.y = \"A\" /* \"A\" */;
 Real r1.z;
equation
 r1.z = time;
end RecordTests.RecordBinding19;
")})));
end RecordBinding19;

model RecordBinding20
    record R1
        parameter String x = "A" annotation(Evaluate=true);
        parameter String y = x annotation(Evaluate=true);
        Real z = time;
    end R1;
    
    R1 r1(x="B");
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding20",
            description="Modified string parameters in record with continuous part",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordBinding20
 eval parameter String r1.x = \"B\" /* \"B\" */;
 eval parameter String r1.y = \"B\" /* \"B\" */;
 Real r1.z;
equation
 r1.z = time;
end RecordTests.RecordBinding20;
")})));
end RecordBinding20;

model RecordBinding21
    record R1
      Real y1 = 52;
      R2 r2(r3(y3=y1));
    end R1;
      
    record R2
      Real y2 = 51;
      R3 r3(x3=y2,y3=1);
    end R2;
    
    record R3
      Real x3;
      Real y3;
    end R3;
  
    R1 r1(r2(r3(y3=y2)));
    Real y2 = 2;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding21",
            description="Flattening use of component in same record",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordBinding21
 Real r1.y1;
 Real r1.r2.y2;
 Real r1.r2.r3.x3;
 Real r1.r2.r3.y3;
 Real y2;
equation
 r1.y1 = 52;
 r1.r2.y2 = 51;
 r1.r2.r3.x3 = r1.r2.y2;
 r1.r2.r3.y3 = y2;
 y2 = 2;
end RecordTests.RecordBinding21;
")})));
end RecordBinding21;

model RecordBinding22
    record R1
        Real t = 3;
        R2 r2(x=t);
    end R1;
    record R2
        Real x;
        Real y;
    end R2;
    Real t = 3.14;
    parameter R1 r1(r2(y=2));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding22",
            description="Flattening use of component in same record",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordBinding22
 Real t;
 parameter Real r1.t = 3 /* 3 */;
 parameter Real r1.r2.x;
 parameter Real r1.r2.y = 2 /* 2 */;
parameter equation
 r1.r2.x = r1.t;
equation
 t = 3.14;
end RecordTests.RecordBinding22;
")})));
end RecordBinding22;

model RecordBinding23
    record R
      parameter Real x = 1;
      final parameter Real y = x;
    end R;
    parameter R r1 = R();
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding23",
            description="Final parameter record component",
            flatModel="
fclass RecordTests.RecordBinding23
 parameter Real r1.x = 1 /* 1 */;
 parameter Real r1.y = 1 /* 1 */;
end RecordTests.RecordBinding23;
")})));
end RecordBinding23;

model RecordBinding24
    record R1
      Real y1 = 52;
      final parameter R2 r2(r3(y3=y1));
    end R1;
  
    record R2
      Real y2 = 51;
      R3 r3(x3=y2,y3=1);
    end R2;
  
    record R3
      Real x3;
      Real y3;
    end R3;
    
    parameter R1 r1;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding24",
            description="Final parameter record component",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordBinding24
 parameter Real r1.y1 = 52 /* 52 */;
 final parameter Real r1.r2.y2 = 51 /* 51 */;
 final parameter Real r1.r2.r3.x3 = 51 /* 51 */;
 parameter Real r1.r2.r3.y3;
parameter equation
 r1.r2.r3.y3 = r1.y1;
end RecordTests.RecordBinding24;
")})));
end RecordBinding24;

model RecordBinding25
  record R1
    R2 r2;
  end R1;
  record R2
    Real x;
  end R2;
  
  model Sub
    R2 r2 = R2(time);
    R1 r1;
  equation
    r1.r2 = r2;
  end Sub;
  
  Sub sub1;
  Sub[1] sub2;
  
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding25",
            description="Final parameter record component",
            eliminate_linear_equations=false,
            flatModel="
fclass RecordTests.RecordBinding25
 Real sub1.r2.x;
 Real sub2[1].r2.x;
equation
 sub1.r2.x = time;
 sub2[1].r2.x = time;
end RecordTests.RecordBinding25;
")})));
end RecordBinding25;

model RecordBinding26
    record R
        parameter Real[:,:] x = {{i + j for i in 1:1} for j in 1:2};
    end R;
    
    R r;
  
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding26",
            description="Reflatten iter exp",
            flatModel="
fclass RecordTests.RecordBinding26
 parameter Real r.x[1,1] = 2 /* 2 */;
 parameter Real r.x[2,1] = 3 /* 3 */;
end RecordTests.RecordBinding26;
")})));
end RecordBinding26;

model RecordBinding27
    record R
        Real t[:] = {time,time+1};
        Real[:,:] x = {{t[i] + t[j] for i in 1:1} for j in 1:2};
    end R;
    
    R r;
  
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding27",
            description="Reflatten iter exp",
            flatModel="
fclass RecordTests.RecordBinding27
 Real r.t[1];
 Real r.t[2];
 Real r.x[1,1];
 Real r.x[2,1];
equation
 r.t[1] = time;
 r.t[2] = time + 1;
 r.x[1,1] = r.t[1] + r.t[1];
 r.x[2,1] = r.t[1] + r.t[2];
end RecordTests.RecordBinding27;
")})));
end RecordBinding27;

model RecordBinding28
    record B
        Real[:] a;
    end B;
    
    model C
        B b = B({1});
    end C;
    
    model D
        extends C (b = b);
    end D;
    
    D d;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordBinding28",
            description="",
            errorMessage="
1 errors found:

Error at line 3, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE,
In component d:
  Can not infer array size of the variable a
")})));
end RecordBinding28;

model RecordBinding29
	type A = enumeration(a1, a2);
	
    record B
        A a;
    end B;
    
    model C
        parameter B b = B(A.a1);
    end C;
    
    model D
        extends C (b = b);
    end D;
    
    D d;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordBinding29",
            description="",
            errorMessage="
1 errors found:

Error at line 13, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo',
In component d:
  Circularity in binding expression of parameter: d.b.a = b.a
")})));
end RecordBinding29;

model RecordBinding30
    record R
        parameter Integer n = 2;
        Real[n] x = 1:n;
    end R;
    
    record RB
        extends R(n=1);
    end RB;
    
    record RW
        R r = R();
    end RW;
    
    model A
        RW rw;
    end A;
    
    model B
        extends A(rw = if b then R1() else R2());
        
        record R1
            extends RW(r = RB());
        end R1;
        
        record R2
            extends RW(r = RB(1));
        end R1;
        
        parameter Boolean b = false;
    end B;
    
    B b;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding30",
            description="Flattening and scalarization of record with if binding expression",
            flatModel="
fclass RecordTests.RecordBinding30
 parameter Boolean b.b = false /* false */;
 structural parameter Integer b.rw.r.n = 1 /* 1 */;
 constant Real b.rw.r.x[1] = 1;
end RecordTests.RecordBinding30;
")})));
end RecordBinding30;

model RecordBinding31
    record R1
        Real x;
    end R1;
    
    record R2
        R1[2] r1;
    end R2;
    
    record R3
        R2 r2;
    end R3;
    
    constant R2 r2(r1(x={1,2}));
    constant R3[1] r3(r2={r2});
    constant Real s = sum(r3[1].r2.r1.x);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding31",
            description="",
            flatModel="
fclass RecordTests.RecordBinding31
 constant Real r2.r1[1].x = 1;
 constant Real r2.r1[2].x = 2;
 constant Real s = 3.0;
end RecordTests.RecordBinding31;
")})));
end RecordBinding31;

model RecordBinding32
    record R
        parameter Integer n;
        Real[n] x = 1:n;
    end R;
    
    model M
        R r;
    end M;
    
    M[2] m(r(n={2,1}));
    R r = m[1].r;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordBinding32",
            description="",
            flatModel="
fclass RecordTests.RecordBinding32
 structural parameter Integer m[2].r.n = 1 /* 1 */;
 constant Real m[2].r.x[1] = 1;
 structural parameter Integer r.n = 2 /* 2 */;
 constant Real r.x[2] = 2;
end RecordTests.RecordBinding32;
")})));
end RecordBinding32;

model UnmodifiableComponent1
    record R
        Real x1 = -1;
        constant Real y = 2;
        final parameter Real z = 3; 
        Real x2;
    end R;
    
    R rec = R(x2=4);
    R[2] recs = {R(1,4),R(1,4)};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnmodifiableComponent1",
            description="Record constructor for record of unmodifiable components",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.UnmodifiableComponent1
 constant Real rec.x1 = -1;
 constant Real rec.y = 2;
 parameter Real rec.z = 3 /* 3 */;
 constant Real rec.x2 = 4;
 constant Real recs[1].x1 = 1;
 constant Real recs[1].y = 2;
 parameter Real recs[1].z = 3 /* 3 */;
 constant Real recs[1].x2 = 4;
 constant Real recs[2].x1 = 1;
 constant Real recs[2].y = 2;
 parameter Real recs[2].z = 3 /* 3 */;
 constant Real recs[2].x2 = 4;
end RecordTests.UnmodifiableComponent1;
")})));
end UnmodifiableComponent1;

model UnmodifiableComponent2
    record R
        constant Real c1 = 1;
        constant Real c2;
    end R;
    
    R r = R(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnmodifiableComponent2",
            description="Record constructor for record of unmodifiable components",
            flatModel="
fclass RecordTests.UnmodifiableComponent2
 constant Real r.c1 = 1;
 constant Real r.c2 = 2;
end RecordTests.UnmodifiableComponent2;
")})));
end UnmodifiableComponent2;

model UnmodifiableComponent3
    record R2
        constant Real c2;
        constant Real c1 = 1;
        Real x;
    end R2;
    
    R2 r2 = R2(2, time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnmodifiableComponent3",
            description="Record constructor for record of unmodifiable components",
            flatModel="
fclass RecordTests.UnmodifiableComponent3
 constant Real r2.c2 = 2;
 constant Real r2.c1 = 1;
 Real r2.x;
equation
 r2.x = time;
end RecordTests.UnmodifiableComponent3;
")})));
end UnmodifiableComponent3;

model UnmodifiableComponent4
    record R
        final parameter Real p1 = 1;
        final parameter Real p2;
        final Real x;
    end R;
    
    R r = R(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnmodifiableComponent4",
            description="Record constructor for record of unmodifiable components",
            flatModel="
fclass RecordTests.UnmodifiableComponent4
 parameter Real r.p1 = 1 /* 1 */;
 parameter Real r.p2 = 0.0 /* 0.0 */;
 Real r.x;
equation
 r.x = time;
end RecordTests.UnmodifiableComponent4;
")})));
end UnmodifiableComponent4;

model UnmodifiableComponent5
    record R
        constant Real x;
    end R;
    
    constant R r1(x = 1);
    constant R r2(x = 2);
    constant R r[2] = { r1, r2 };
    
    function f1
        input Integer i;
        output Real x;
    algorithm
        x := f2(r[i]);
        annotation(Inline=false);
    end f1;
    
    function f2
        input R y;
        output Real z;
    algorithm
        z := y.x;
    end f2;
    
    Real w = f1(i);
    Integer i = if time > 2 then 1 else 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnmodifiableComponent5",
            description="Record constructor for record of unmodifiable components",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.UnmodifiableComponent5
 constant Real r1.x = 1;
 constant Real r2.x = 2;
 constant Real r[1].x = 1;
 constant Real r[2].x = 2;
 Real w;
 discrete Integer i;
global variables
 constant RecordTests.UnmodifiableComponent5.R RecordTests.UnmodifiableComponent5.r[2] = {RecordTests.UnmodifiableComponent5.R(1), RecordTests.UnmodifiableComponent5.R(2)};
initial equation
 pre(i) = 0;
equation
 w = RecordTests.UnmodifiableComponent5.f1(i);
 i = if time > 2 then 1 else 2;

public
 function RecordTests.UnmodifiableComponent5.f1
  input Integer i;
  output Real x;
 algorithm
  x := RecordTests.UnmodifiableComponent5.f2(global(RecordTests.UnmodifiableComponent5.r[i]));
  return;
 annotation(Inline = false);
 end RecordTests.UnmodifiableComponent5.f1;

 function RecordTests.UnmodifiableComponent5.f2
  input RecordTests.UnmodifiableComponent5.R y;
  output Real z;
 algorithm
  z := y.x;
  return;
 end RecordTests.UnmodifiableComponent5.f2;

 record RecordTests.UnmodifiableComponent5.R
  constant Real x;
 end RecordTests.UnmodifiableComponent5.R;

end RecordTests.UnmodifiableComponent5;
")})));
end UnmodifiableComponent5;


model RecordArray1
 record A
  Real a[2];
  Real b;
 end A;
 
 A x(a={1,2}, b=1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray1",
            description="Record containing array: modification",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordArray1
 RecordTests.RecordArray1.A x(a = {1, 2},b = 1);

public
 record RecordTests.RecordArray1.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray1.A;

end RecordTests.RecordArray1;
")})));
end RecordArray1;


model RecordArray2
 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray2",
            description="Record containing array: equation with access",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordArray2
 RecordTests.RecordArray2.A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

public
 record RecordTests.RecordArray2.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray2.A;

end RecordTests.RecordArray2;
")})));
end RecordArray2;


model RecordArray3
 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
 A y;
equation
 x = y;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray3",
            description="Record containing array: equation with other record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordArray3
 RecordTests.RecordArray3.A x;
 RecordTests.RecordArray3.A y;
equation
 x = y;

public
 record RecordTests.RecordArray3.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray3.A;

end RecordTests.RecordArray3;
")})));
end RecordArray3;


model RecordArray4
 record A
  Real a;
  Real b;
 end A;
 
 A x[2](each a=1, b={1,2});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray4",
            description="Array of records: modification",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordArray4
 RecordTests.RecordArray4.A x[2](a = {1, 1},b = {1, 2});

public
 record RecordTests.RecordArray4.A
  Real a;
  Real b;
 end RecordTests.RecordArray4.A;

end RecordTests.RecordArray4;
")})));
end RecordArray4;


model RecordArray5
 record A
  Real a;
  Real b;
 end A;
 
 A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray5",
            description="Array of records: accesses",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordArray5
 RecordTests.RecordArray5.A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

public
 record RecordTests.RecordArray5.A
  Real a;
  Real b;
 end RecordTests.RecordArray5.A;

end RecordTests.RecordArray5;
")})));
end RecordArray5;


model RecordArray6
    record A
        Real x;
        Real y;
        Real z;
    end A;
    
    constant A b[2,2];
    constant A c[2,2] = b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray6",
            description="Constant array of records with missing binding expression",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordArray6
 constant RecordTests.RecordArray6.A b[2,2] = {{RecordTests.RecordArray6.A(0.0, 0.0, 0.0), RecordTests.RecordArray6.A(0.0, 0.0, 0.0)}, {RecordTests.RecordArray6.A(0.0, 0.0, 0.0), RecordTests.RecordArray6.A(0.0, 0.0, 0.0)}};
 constant RecordTests.RecordArray6.A c[2,2] = {{RecordTests.RecordArray6.A(0.0, 0.0, 0.0), RecordTests.RecordArray6.A(0.0, 0.0, 0.0)}, {RecordTests.RecordArray6.A(0.0, 0.0, 0.0), RecordTests.RecordArray6.A(0.0, 0.0, 0.0)}};

public
 record RecordTests.RecordArray6.A
  Real x;
  Real y;
  Real z;
 end RecordTests.RecordArray6.A;

end RecordTests.RecordArray6;
")})));
end RecordArray6;


model RecordArray7
    record A
        parameter Integer n;
        Real x[n];
    end A;
    
    parameter Integer m = 2;
    parameter A a = A(m, 1:m);
    Real y[m] = a.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray7",
            description="Parameter in record controlling size of array in same record: record constructor",
            flatModel="
fclass RecordTests.RecordArray7
 structural parameter Integer m = 2 /* 2 */;
 structural parameter RecordTests.RecordArray7.A a(x(size() = {2})) = RecordTests.RecordArray7.A(2, {1, 2}) /* RecordTests.RecordArray7.A(2, { 1, 2 }) */;
 Real y[2] = {1.0, 2.0};

public
 record RecordTests.RecordArray7.A
  parameter Integer n;
  Real x[n];
 end RecordTests.RecordArray7.A;

end RecordTests.RecordArray7;
")})));
end RecordArray7;


model RecordArray8
    record A
        parameter Integer n;
        Real x[n];
    end A;
    
    function f
        input Integer n2;
        output A a(n=n2);
    algorithm
        a.x := 1:n2;
    end f;
    
    parameter Integer m = 2;
    parameter A a = f(m);
    Real y[m] = a.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray8",
            description="Flattening of model with record that gets array size of member from function call that returns entire record",
            flatModel="
fclass RecordTests.RecordArray8
 structural parameter Integer m = 2 /* 2 */;
 structural parameter RecordTests.RecordArray8.A a(x(size() = {2})) = RecordTests.RecordArray8.A(2, {1, 2}) /* RecordTests.RecordArray8.A(2, { 1, 2 }) */;
 Real y[2] = {1.0, 2.0};

public
 function RecordTests.RecordArray8.f
  input Integer n2;
  output RecordTests.RecordArray8.A a;
 algorithm
  a.n := n2;
  a.x[:] := 1:n2;
  return;
 end RecordTests.RecordArray8.f;

 record RecordTests.RecordArray8.A
  parameter Integer n;
  Real x[n];
 end RecordTests.RecordArray8.A;

end RecordTests.RecordArray8;
")})));
end RecordArray8;


model RecordArray9
    record R
        parameter Integer n;
        parameter S x[n];
    end R;
    
    record S
        parameter Real a;
        parameter Real b;
    end S;
    
    model M
        R r;
    end M;
    
    S s[5] = { S(i, i+1) for i in 1:2:9 };
    R r1 = R(2, {s[1], s[2]});
    R r2 = R(3, {s[3], s[4], s[5]});
    M m1[2](r = {r1, r2});
    M m2[2](r = m1.r);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray9",
            description="Tests type checking of an array of records where the elements in the array have different sizes",
            flatModel="
fclass RecordTests.RecordArray9
 parameter RecordTests.RecordArray9.S s[5] = {RecordTests.RecordArray9.S(1, 1 + 1), RecordTests.RecordArray9.S(3, 3 + 1), RecordTests.RecordArray9.S(5, 5 + 1), RecordTests.RecordArray9.S(7, 7 + 1), RecordTests.RecordArray9.S(9, 9 + 1)} /* { RecordTests.RecordArray9.S(1, 2), RecordTests.RecordArray9.S(3, 4), RecordTests.RecordArray9.S(5, 6), RecordTests.RecordArray9.S(7, 8), RecordTests.RecordArray9.S(9, 10) } */;
 parameter RecordTests.RecordArray9.R r1(x(size() = {2})) = RecordTests.RecordArray9.R(2, {s[1], s[2]});
 parameter RecordTests.RecordArray9.R r2(x(size() = {3})) = RecordTests.RecordArray9.R(3, {s[3], s[4], s[5]});
 parameter RecordTests.RecordArray9.R m1[1].r(x(size() = {2})) = r1;
 parameter RecordTests.RecordArray9.R m1[2].r(x(size() = {3})) = r2;
 parameter RecordTests.RecordArray9.R m2[1].r(x(size() = {2})) = m1[1].r;
 parameter RecordTests.RecordArray9.R m2[2].r(x(size() = {3})) = m1[2].r;

public
 record RecordTests.RecordArray9.S
  parameter Real a;
  parameter Real b;
 end RecordTests.RecordArray9.S;

 record RecordTests.RecordArray9.R
  parameter Integer n;
  parameter RecordTests.RecordArray9.S x[n];
 end RecordTests.RecordArray9.R;

end RecordTests.RecordArray9;
")})));
end RecordArray9;


model RecordArray10
    record R
        parameter Integer n;
        parameter S x[n];
    end R;
    
    record S
        parameter Real a;
        parameter Real b;
    end S;
    
    model M
        R[2] r;
    end M;
    
    S s[:] = { S(i, i+1) for i in 1:10 };
    R r1 = R(1, {s[1]});
    R r2 = R(2, {s[2], s[3]});
    R r3 = R(3, {s[4], s[5], s[6]});
    R r4 = R(4, {s[7], s[8], s[9], s[10]});
    M m1[2](r = {{r1, r2}, {r3, r4}});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray10",
            description="Tests type checking of an array of arrays of records where the elements have different sizes",
            flatModel="
fclass RecordTests.RecordArray10
 parameter RecordTests.RecordArray10.S s[10] = {RecordTests.RecordArray10.S(1, 1 + 1), RecordTests.RecordArray10.S(2, 2 + 1), RecordTests.RecordArray10.S(3, 3 + 1), RecordTests.RecordArray10.S(4, 4 + 1), RecordTests.RecordArray10.S(5, 5 + 1), RecordTests.RecordArray10.S(6, 6 + 1), RecordTests.RecordArray10.S(7, 7 + 1), RecordTests.RecordArray10.S(8, 8 + 1), RecordTests.RecordArray10.S(9, 9 + 1), RecordTests.RecordArray10.S(10, 10 + 1)} /* { RecordTests.RecordArray10.S(1, 2), RecordTests.RecordArray10.S(2, 3), RecordTests.RecordArray10.S(3, 4), RecordTests.RecordArray10.S(4, 5), RecordTests.RecordArray10.S(5, 6), RecordTests.RecordArray10.S(6, 7), RecordTests.RecordArray10.S(7, 8), RecordTests.RecordArray10.S(8, 9), RecordTests.RecordArray10.S(9, 10), RecordTests.RecordArray10.S(10, 11) } */;
 parameter RecordTests.RecordArray10.R r1(x(size() = {1})) = RecordTests.RecordArray10.R(1, {s[1]});
 parameter RecordTests.RecordArray10.R r2(x(size() = {2})) = RecordTests.RecordArray10.R(2, {s[2], s[3]});
 parameter RecordTests.RecordArray10.R r3(x(size() = {3})) = RecordTests.RecordArray10.R(3, {s[4], s[5], s[6]});
 parameter RecordTests.RecordArray10.R r4(x(size() = {4})) = RecordTests.RecordArray10.R(4, {s[7], s[8], s[9], s[10]});
 parameter RecordTests.RecordArray10.R m1[1].r[2](x(size() = {{1}, {2}})) = {r1, r2};
 parameter RecordTests.RecordArray10.R m1[2].r[2](x(size() = {{3}, {4}})) = {r3, r4};

public
 record RecordTests.RecordArray10.S
  parameter Real a;
  parameter Real b;
 end RecordTests.RecordArray10.S;

 record RecordTests.RecordArray10.R
  parameter Integer n;
  parameter RecordTests.RecordArray10.S x[n];
 end RecordTests.RecordArray10.R;

end RecordTests.RecordArray10;
")})));
end RecordArray10;


model RecordArray11
    record A
        parameter Integer n;
        parameter Real x[1];
    end A;

    record B
        parameter Integer n;
        parameter Real x[n];
    end B;
 
    A a = A(1, {0.0});
    B b = B(2, {0.5, 1.0});
    A[2] r1 = {a, b};
    B[2] r2 = {a, b};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordArray11",
            description="Array with incompatible record at index [2]",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 14, column 15, in file '...', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable r1 does not match the declared type of the variable
")})));
end RecordArray11;


model RecordArray12
    
    record R
        parameter Real[:] z = {1, 2, 3};
    end R;
    
    R[2] array = {R(z={1}), R(z={1, 2})};
    R scalar = array[2];

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray12",
            description="Tests type checking of subscripted access in array of records.",
            flatModel="
fclass RecordTests.RecordArray12
 parameter RecordTests.RecordArray12.R array[2](z(size() = {{1}, {2}})) = {RecordTests.RecordArray12.R({1}), RecordTests.RecordArray12.R({1, 2})} /* { RecordTests.RecordArray12.R({ 1 }), RecordTests.RecordArray12.R({ 1, 2 }) } */;
 parameter RecordTests.RecordArray12.R scalar(z(size() = {2})) = array[2];

public
 record RecordTests.RecordArray12.R
  parameter Real z[:];
 end RecordTests.RecordArray12.R;

end RecordTests.RecordArray12;
")})));
end RecordArray12;

model RecordArray13
    record R
        Real[:] x = {1};
    end R;
    
    record R2
        Integer i = 0;
    end R2;
    
    function f
        input Integer x;
        output R[2] y;
    protected
        R[:] array = fill(R2(), x);
    algorithm
        y := array;
    end f;
    
    R[2] z = f(2);
    annotation(__JModelica(UnitTesting(tests={
    ErrorTestCase(
        name="RecordArray13",
        description="Array of unknown size and with incompatible records",
        variability_propagation=false,
        errorMessage="
1 errors found:

Error at line 14, column 22, in file '...', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable array does not match the declared type of the variable
")})));
end RecordArray13;


model RecordArray14
    record R1
        Real[1] z = {1};
    end R1;
    
    record R2
        Real[2] z = {1, 2};
    end R2;
    
    record R
        R1 x;
    end R;
    
    R[2] r(each x = {R1(), R2()});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordArray14",
            description="Array with incorrect each and incompatible record at index [2]",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 14, column 21, in file '...', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end RecordArray14;


model RecordArray15
    record R1
    end R1;
    
    record R2
        R1 r;
    end R2;
    
    R1[3] a;
    R2[3] b;
equation
    a = b.r;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordArray15",
            description="Tests type checking of component access in array of records.",
            flatModel="
fclass RecordTests.RecordArray15
 constant RecordTests.RecordArray15.R1 a[3] = {RecordTests.RecordArray15.R1(), RecordTests.RecordArray15.R1(), RecordTests.RecordArray15.R1()};
 constant RecordTests.RecordArray15.R2 b[3] = {RecordTests.RecordArray15.R2(RecordTests.RecordArray15.R1()), RecordTests.RecordArray15.R2(RecordTests.RecordArray15.R1()), RecordTests.RecordArray15.R2(RecordTests.RecordArray15.R1())};
equation
 {RecordTests.RecordArray15.R1(), RecordTests.RecordArray15.R1(), RecordTests.RecordArray15.R1()} = {RecordTests.RecordArray15.R1(), RecordTests.RecordArray15.R1(), RecordTests.RecordArray15.R1()};

public
 record RecordTests.RecordArray15.R1
 end RecordTests.RecordArray15.R1;

 record RecordTests.RecordArray15.R2
  constant RecordTests.RecordArray15.R1 r;
 end RecordTests.RecordArray15.R2;

end RecordTests.RecordArray15;
")})));
end RecordArray15;



model RecordConstructor1
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2, "foo");

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor1",
            description="Record constructors: basic test",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordConstructor1
 RecordTests.RecordConstructor1.A x = RecordTests.RecordConstructor1.A(1.0, 2, \"foo\");

public
 record RecordTests.RecordConstructor1.A
  Real a;
  discrete Integer b;
  parameter String c;
 end RecordTests.RecordConstructor1.A;

end RecordTests.RecordConstructor1;
")})));
end RecordConstructor1;


model RecordConstructor2
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(c="foo", a=1.0, b=2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor2",
            description="Record constructors: named args",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordConstructor2
 RecordTests.RecordConstructor2.A x = RecordTests.RecordConstructor2.A(1.0, 2, \"foo\");

public
 record RecordTests.RecordConstructor2.A
  Real a;
  discrete Integer b;
  parameter String c;
 end RecordTests.RecordConstructor2.A;

end RecordTests.RecordConstructor2;
")})));
end RecordConstructor2;


model RecordConstructor3
 record A
  Real a;
  Integer b = 0;
  constant String c = "foo";
 end A;
 
 A x = A(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor3",
            description="Record constructors: default args",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordConstructor3
 RecordTests.RecordConstructor3.A x = RecordTests.RecordConstructor3.A(1, 2, \"foo\");

public
 record RecordTests.RecordConstructor3.A
  Real a;
  discrete Integer b;
  constant String c;
 end RecordTests.RecordConstructor3.A;

end RecordTests.RecordConstructor3;
")})));
end RecordConstructor3;


model RecordConstructor4
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordConstructor4",
            description="Record constructors: wrong type of arg",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 8, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo':
  Record constructor for A: types of positional argument 3 and input c are not compatible
    type of '3' is Integer
    expected type is String
")})));
end RecordConstructor4;


model RecordConstructor5
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordConstructor5",
            description="Record constructors: too few args",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 8, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo':
  Record constructor for A: missing argument for required input c
")})));
end RecordConstructor5;


model RecordConstructor6
 record A
  Real a;
  Integer b;
  parameter String c;
 end A;
 
 A x = A(1.0, 2, "foo", 0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordConstructor6",
            description="Record constructors: too many args",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 8, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo':
  Record constructor for A: too many positional arguments
")})));
end RecordConstructor6;


model RecordConstructor7
    record A
        Real x;
    end A;
    
    record B
        extends A;
        Real y;
    end B;
    
    constant B b = B(y=2, x=1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor7",
            description="Constant evaluation of record constructors for records with inherited components",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordConstructor7
 constant Real b.x = 1;
 constant Real b.y = 2;
end RecordTests.RecordConstructor7;
")})));
end RecordConstructor7;


model RecordConstructor8
    record A
        Real x;
        Real y = x + 2;
    end A;
    
    A a = A(time);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor8",
            description="Using default value in record constructor that depends on another member",
            flatModel="
fclass RecordTests.RecordConstructor8
 RecordTests.RecordConstructor8.A a = RecordTests.RecordConstructor8.A(time, time + 2);

public
 record RecordTests.RecordConstructor8.A
  Real x;
  Real y;
 end RecordTests.RecordConstructor8.A;

end RecordTests.RecordConstructor8;
")})));
end RecordConstructor8;


model RecordConstructor9
    record A
        Integer x;
        Integer y = x + 2;
    end A;
    
    parameter A a = A(1);
    parameter Integer b = a.y - 1;
    Real z[b] = (1:b) * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor9",
            description="Constant eval of default value in record constructor that depends on another member",
            flatModel="
fclass RecordTests.RecordConstructor9
 parameter Integer a.x = 1 /* 1 */;
 structural parameter Integer a.y = 3 /* 3 */;
 structural parameter Integer b = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * z[1];
end RecordTests.RecordConstructor9;
")})));
end RecordConstructor9;


model RecordConstructor10
    record A
        Real a;
        Real b;
    end A;

    model B
        parameter Real d = 2;
    
        record C = A(b = d);
        
        model E
            C f = C(1);
        end E;
        
        E e;
    end B;

    B b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor10",
            description="Using default value in record constructor that is set in short class decl",
            flatModel="
fclass RecordTests.RecordConstructor10
 parameter Real b.d = 2 /* 2 */;
 RecordTests.RecordConstructor10.b.C b.e.f = RecordTests.RecordConstructor10.b.C(1, b.d);

public
 record RecordTests.RecordConstructor10.b.C
  Real a;
  Real b;
 end RecordTests.RecordConstructor10.b.C;

end RecordTests.RecordConstructor10;
")})));
end RecordConstructor10;


model RecordConstructor11
    record A
        Real x;
    end A;
    
    record B
        extends A;
        Real y = x + 2;
    end B;
    
    B b = B(time);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor11",
            description="Using default value in record constructor that depends on an inherited member",
            flatModel="
fclass RecordTests.RecordConstructor11
 RecordTests.RecordConstructor11.B b = RecordTests.RecordConstructor11.B(time, time + 2);

public
 record RecordTests.RecordConstructor11.B
  Real x;
  Real y;
 end RecordTests.RecordConstructor11.B;

end RecordTests.RecordConstructor11;
")})));
end RecordConstructor11;


model RecordConstructor12
    record R
        parameter Integer n = 1;
        parameter Real[n] x = 1:n;
    end R;
    
    R r1 = R();
    R r2 = R(2);
    R r3 = R(2,{1,2}); 
    R r4; 

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor12",
            description="Size of array in record depending on input to constructor",
            eliminate_alias_constants=false,
            flatModel="
fclass RecordTests.RecordConstructor12
 structural parameter Integer r1.n = 1 /* 1 */;
 parameter Real r1.x[1] = 1 /* 1 */;
 structural parameter Integer r2.n = 2 /* 2 */;
 parameter Real r2.x[1] = 1 /* 1 */;
 parameter Real r2.x[2] = 2 /* 2 */;
 structural parameter Integer r3.n = 2 /* 2 */;
 parameter Real r3.x[1] = 1 /* 1 */;
 parameter Real r3.x[2] = 2 /* 2 */;
 structural parameter Integer r4.n = 1 /* 1 */;
 structural parameter Real r4.x[1] = 1 /* 1 */;
end RecordTests.RecordConstructor12;
")})));
end RecordConstructor12;


model RecordConstructor13
    record R
        parameter Integer n = 2;
        parameter Real[n] x = 1:2;
    end R;
    
    R r = R(3, {1,2});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordConstructor13",
            description="Size of array in record depending on input to constructor",
            errorMessage="
2 errors found:

Error at line 7, column 11, in file '...', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable r does not match the declared type of the variable

Error at line 7, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo':
  Record constructor for R: types of positional argument 2 and input x are not compatible
    type of '{1, 2}' is Integer[2]
    expected type is Real[3]
")})));
end RecordConstructor13;


model RecordConstructor14
    record R
        parameter Real[:] x = {1};
        parameter Integer n = size(x, 1);
    end R;
    
    R r1 = R();
    R r2 = R({2});
    R r3 = R({1,2});
    R r4 = R({1,2,3}); 
    R r5;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor14",
            description="Parameter in record depending on size of input to constructor",
            flatModel="
fclass RecordTests.RecordConstructor14
 parameter RecordTests.RecordConstructor14.R r1(x(size() = {1})) = RecordTests.RecordConstructor14.R({1}, size({1}, 1)) /* RecordTests.RecordConstructor14.R({ 1 }, 1) */;
 parameter RecordTests.RecordConstructor14.R r2(x(size() = {1})) = RecordTests.RecordConstructor14.R({2}, size({2}, 1)) /* RecordTests.RecordConstructor14.R({ 2 }, 1) */;
 parameter RecordTests.RecordConstructor14.R r3(x(size() = {2})) = RecordTests.RecordConstructor14.R({1, 2}, size({1, 2}, 1)) /* RecordTests.RecordConstructor14.R({ 1, 2 }, 2) */;
 parameter RecordTests.RecordConstructor14.R r4(x(size() = {3})) = RecordTests.RecordConstructor14.R({1, 2, 3}, size({1, 2, 3}, 1)) /* RecordTests.RecordConstructor14.R({ 1, 2, 3 }, 3) */;
 parameter RecordTests.RecordConstructor14.R r5(x(size() = {1}) = {1},n = size(r5.x[1:1], 1));

public
 record RecordTests.RecordConstructor14.R
  parameter Real x[:];
  parameter Integer n;
 end RecordTests.RecordConstructor14.R;

end RecordTests.RecordConstructor14;
")})));
end RecordConstructor14;


model RecordConstructor15
    record R
        parameter Integer n = 1;
        parameter Real[n] x = 1:n;
    end R;
    
    parameter Integer n = 2;
    R r = R(n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor15",
            description="Size of array in record depending on input to constructor",
            eliminate_alias_constants=false,
            flatModel="
fclass RecordTests.RecordConstructor15
 structural parameter Integer n = 2 /* 2 */;
 structural parameter Integer r.n = 2 /* 2 */;
 structural parameter Real r.x[1] = 1 /* 1 */;
 structural parameter Real r.x[2] = 2 /* 2 */;
end RecordTests.RecordConstructor15;
")})));
end RecordConstructor15;


model RecordConstructor16
    record A
        Real a;
        Real b;
    end A;

    package B
        constant Real g = 2;
        constant Real h = 3;
    
        record C = A(a = g, b = h);
    end B;

    model D
        model E
            B.C j = B.C(1);
            constant B.C k = B.C(1);
            constant Real l = k.a;
        end E;
        
        E e;
    end D;

    D d;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor16",
            description="Record constructor for record with modifications that are not at original declaration",
            eliminate_alias_constants=false,
            flatModel="
fclass RecordTests.RecordConstructor16
 constant Real d.e.j.a = 1;
 constant Real d.e.j.b = 3.0;
 constant Real d.e.k.a = 1;
 constant Real d.e.k.b = 3;
 constant Real d.e.l = 1;
end RecordTests.RecordConstructor16;
")})));
end RecordConstructor16;


model RecordConstructor17
    package A
        type B = Real;
        
        record C
            B b1 = 1;
            B b2 = 2;
        end C;
    end A;
    
    model D
        A.C c = A.C(3);
    end D;
    
    D d;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor17",
            description="Record constructor for record with component of short class decl",
            flatModel="
fclass RecordTests.RecordConstructor17
 RecordTests.RecordConstructor17.A.C d.c = RecordTests.RecordConstructor17.A.C(3, 2);

public
 record RecordTests.RecordConstructor17.A.C
  Real b1;
  Real b2;
 end RecordTests.RecordConstructor17.A.C;

end RecordTests.RecordConstructor17;
")})));
end RecordConstructor17;


model RecordConstructor18
    package A
        type B = Real;
        
        record C
            B b = 1;
        end C;
    end A;
    
    package D
        type E = Real;
        
        record F
            extends A.C(b = 2);
            E e = 3;
        end F;
    end D;
    
    model G
        D.F f = D.F(e = 4);
    end G;
    
    G g;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor18",
            description="Record constructor for inherited record with components of short class decls from different locations",
            flatModel="
fclass RecordTests.RecordConstructor18
 RecordTests.RecordConstructor18.D.F g.f = RecordTests.RecordConstructor18.D.F(2, 4);

public
 record RecordTests.RecordConstructor18.D.F
  Real b;
  Real e;
 end RecordTests.RecordConstructor18.D.F;

end RecordTests.RecordConstructor18;
")})));
end RecordConstructor18;


model RecordConstructor19
    package A
        record B
            Real x = 1;
            Real y = 2;
        end B;
    end A;
    
    package C
        package D
            constant Real c = 3;
        end D;
        
        record E = A.B(y = D.c);
    end C;

    model F
        C.E b = C.E(4);
    end F;
    
    F f;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor19",
            description="Record constructor for record with modifier depending on class that is not by original declaration",
            flatModel="
fclass RecordTests.RecordConstructor19
 RecordTests.RecordConstructor19.C.E f.b = RecordTests.RecordConstructor19.C.E(4, 3.0);

public
 record RecordTests.RecordConstructor19.C.E
  Real x;
  Real y;
 end RecordTests.RecordConstructor19.C.E;

end RecordTests.RecordConstructor19;
")})));
end RecordConstructor19;


model RecordConstructor20
    package A
        import B = RecordTests.RecordConstructor20.C;
        
        record D
            B.E x = 1;
        end D;
    end A;
    
    package C
        type E = Real;
    end C;

    model F
        A.D d = A.D();
    end F;
    
    F f;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor20",
            description="Record constructor for record with component of class from import",
            flatModel="
fclass RecordTests.RecordConstructor20
 RecordTests.RecordConstructor20.A.D f.d = RecordTests.RecordConstructor20.A.D(1);

public
 record RecordTests.RecordConstructor20.A.D
  Real x;
 end RecordTests.RecordConstructor20.A.D;

end RecordTests.RecordConstructor20;
")})));
end RecordConstructor20;


model RecordConstructor21
    package A
        record B
            Real x = 1;
        end B;
        
        record C
            B b = B();
        end C;
    end A;
    
    package D
        record E
            Real y = 2;
        end B;
        
        record F
            extends A.C;
            E e = E();
        end F;
    end D;
    
    model G
        D.F f = D.F();
    end G;
    
    G g;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor21",
            description="Record constructor for record with binding expression of member using class accessible from extends",
            flatModel="
fclass RecordTests.RecordConstructor21
 RecordTests.RecordConstructor21.D.F g.f = RecordTests.RecordConstructor21.D.F(RecordTests.RecordConstructor21.A.B(1), RecordTests.RecordConstructor21.D.E(2));

public
 record RecordTests.RecordConstructor21.A.B
  Real x;
 end RecordTests.RecordConstructor21.A.B;

 record RecordTests.RecordConstructor21.D.E
  Real y;
 end RecordTests.RecordConstructor21.D.E;

 record RecordTests.RecordConstructor21.D.F
  RecordTests.RecordConstructor21.A.B b;
  RecordTests.RecordConstructor21.D.E e;
 end RecordTests.RecordConstructor21.D.F;

end RecordTests.RecordConstructor21;
")})));
end RecordConstructor21;


model RecordConstructor22
    record A
        Real x;
        Real y;
        Real z = x;
    end A;
    
    Real x = 1;
    A a = A(time, x);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor22",
            description="Record constructor with same name in record and surrounding",
            flatModel="
fclass RecordTests.RecordConstructor22
 Real x = 1;
 RecordTests.RecordConstructor22.A a = RecordTests.RecordConstructor22.A(time, x, time);

public
 record RecordTests.RecordConstructor22.A
  Real x;
  Real y;
  Real z;
 end RecordTests.RecordConstructor22.A;

end RecordTests.RecordConstructor22;
")})));
end RecordConstructor22;


model RecordConstructor23
    record A
        parameter Integer n;
        final parameter Integer m = n + 1;
        parameter Real x[:, n];
    end A;
    
    record B
        extends A(n = 1, x = {{1}, {2}});
    end B;
    
    model C
        parameter A a;
    end C;
    
    extends C(a = B());

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor23",
            description="Record constructor for record with final parameter",
            flatModel="
fclass RecordTests.RecordConstructor23
 parameter RecordTests.RecordConstructor23.A a(x(size() = {2, 1})) = RecordTests.RecordConstructor23.B(1, 1 + 1, {{1}, {2}});

public
 record RecordTests.RecordConstructor23.A
  parameter Integer n;
  parameter Integer m;
  parameter Real x[:,n];
 end RecordTests.RecordConstructor23.A;

 record RecordTests.RecordConstructor23.B
  parameter Integer n;
  parameter Integer m;
  parameter Real x[:,n];
 end RecordTests.RecordConstructor23.B;

end RecordTests.RecordConstructor23;
")})));
end RecordConstructor23;


model RecordConstructor24
    record A
        parameter Integer n;
        constant Integer m = 1;
        parameter Real x[:, n];
    end A;
    
    record B
        extends A(n = 1, x = {{1}, {2}});
    end B;
    
    model C
        parameter A a;
    end C;
    
    extends C(a = B());

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor24",
            description="Record constructor for record with constant",
            flatModel="
fclass RecordTests.RecordConstructor24
 parameter RecordTests.RecordConstructor24.A a(x(size() = {2, 1})) = RecordTests.RecordConstructor24.B(1, 1, {{1}, {2}});

public
 record RecordTests.RecordConstructor24.A
  parameter Integer n;
  constant Integer m;
  parameter Real x[:,n];
 end RecordTests.RecordConstructor24.A;

 record RecordTests.RecordConstructor24.B
  parameter Integer n;
  constant Integer m;
  parameter Real x[:,n];
 end RecordTests.RecordConstructor24.B;

end RecordTests.RecordConstructor24;
")})));
end RecordConstructor24;


model RecordConstructor25
    record A
        parameter Real x = 1;
    end A;

    block B
        parameter Integer n = 1;
        parameter A[n] a1 = { A() };
    end B;

    block C
        parameter A[:] a2 = { A() };
    end C;

    block D
        extends C;
        replaceable B b(n = size(a2, 1), a1 = a2);
    end D;

    D d(redeclare B b, a2 = {A(2), A(3)});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor25",
            description="Array of records with constructors used in modification on redeclare",
            flatModel="
fclass RecordTests.RecordConstructor25
 structural parameter Integer d.b.n = 2 /* 2 */;
 parameter RecordTests.RecordConstructor25.A d.b.a1[2] = d.a2[1:2];
 parameter RecordTests.RecordConstructor25.A d.a2[2] = {RecordTests.RecordConstructor25.A(2), RecordTests.RecordConstructor25.A(3)} /* { RecordTests.RecordConstructor25.A(2), RecordTests.RecordConstructor25.A(3) } */;

public
 record RecordTests.RecordConstructor25.A
  parameter Real x;
 end RecordTests.RecordConstructor25.A;

end RecordTests.RecordConstructor25;
")})));
end RecordConstructor25;

model RecordConstructor26
    record R1
        parameter Integer n = 2;
        Real[n] x = 1:n;
    end R1;
    
    record R2
        extends R1(n=1);
    end R2;
    
    R2 r = R2(n=3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor26",
            description="Flattening of constant record constructor",
            flatModel="
fclass RecordTests.RecordConstructor26
 RecordTests.RecordConstructor26.R2 r(x(size() = {3})) = RecordTests.RecordConstructor26.R2(3, 1:3);

public
 record RecordTests.RecordConstructor26.R2
  parameter Integer n;
  Real x[n];
 end RecordTests.RecordConstructor26.R2;

end RecordTests.RecordConstructor26;
")})));
end RecordConstructor26;


model RecordConstructor27
    package A
        record B
            C c = C(1);
        end B;
        
        record C
            Real x;
        end C;
        
        record D
            extends B(c = C(2));
        end D;
    end A;
    
    A.D d = A.D();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor27",
            description="",
            flatModel="
fclass RecordTests.RecordConstructor27
 RecordTests.RecordConstructor27.A.D d = RecordTests.RecordConstructor27.A.D(RecordTests.RecordConstructor27.A.C(2));

public
 record RecordTests.RecordConstructor27.A.C
  Real x;
 end RecordTests.RecordConstructor27.A.C;

 record RecordTests.RecordConstructor27.A.D
  RecordTests.RecordConstructor27.A.C c;
 end RecordTests.RecordConstructor27.A.D;

end RecordTests.RecordConstructor27;
")})));
end RecordConstructor27;

model RecordConstructor28

    record R
        parameter Real[:] a = {1};
        final parameter Real[size(a,1)] b = a;
    end R;
    
    parameter Real p;
    parameter R r = R(a={p});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor28",
            description="",
            flatModel="
fclass RecordTests.RecordConstructor28
 parameter Real p;
 parameter RecordTests.RecordConstructor28.R r(a(size() = {1}),b(size() = {1})) = RecordTests.RecordConstructor28.R({p}, {p});

public
 record RecordTests.RecordConstructor28.R
  parameter Real a[:];
  parameter Real b[size(a[:], 1)];
 end RecordTests.RecordConstructor28.R;

end RecordTests.RecordConstructor28;
")})));
end RecordConstructor28;

model RecordConstructor29

    record R
        parameter Real[:] a = {1};
        final parameter Real[size(a,1) + 1] b = cat(1,vector(0),a);
    end R;
    
    model B
        parameter R[:] d = {R()};
    end B;
    
    model C
        parameter Real p = -20;
        B a(d={R(a={p})});
    end C;
    
    C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConstructor29",
            description="",
            flatModel="
fclass RecordTests.RecordConstructor29
 parameter Real c.p = -20 /* -20 */;
 parameter RecordTests.RecordConstructor29.R c.a.d[1](a(size() = {{1}}),b(size() = {{2}})) = {RecordTests.RecordConstructor29.R({c.p}, cat(1, vector(0), {c.p}))};

public
 record RecordTests.RecordConstructor29.R
  parameter Real a[:];
  parameter Real b[size(a[:], 1) + 1];
 end RecordTests.RecordConstructor29.R;

end RecordTests.RecordConstructor29;
")})));
end RecordConstructor29;

model RecordConstructor30

    record R
        parameter Real[:] a = {1};
        final parameter Real[size(a,1) + 1] b = cat(1,vector(0),a);
    end R;
    
    model B
        parameter R[1] d = {R()};
    end B;
    
    model C
        parameter Real p = -20;
        B[1] a(d={R(a={p})});
    end C;
    
    C c;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="RecordConstructor30",
            description="",
            errorMessage="
1 warnings found:

Warning at line 14, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', ASSUMING_EACH,
In component c:
  Assuming 'each' for the modification 'd = {R(a={p})}'
")})));
end RecordConstructor30;

model RecordConstructor31
// Should give two errors #4908, one for each constructor call.
// Should not give the error about 'binding expression of the variable r' since it is a secondary fault.
record R
    Real[size(x,1)] y = 1:5;
    Real[:] x = {1,2,3};
end R;

model M
    R[:] r = {R()};
end M;

M m(r={R(x={1},y=1:2),R(x={2,3})});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordConstructor31",
            description="",
            errorMessage="
1 errors found:

Error at line 13, column 7, in file '...', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable r does not match the declared type of the variable

Error at line 13, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo':
  Record constructor for R: types of named argument y and input y are not compatible
    type of '1:2' is Integer[2]
    expected type is Real[1]
")})));
end RecordConstructor31;

model RecordConstructor32

record R
    Real[:] x = {1,2,3};
end R;

model M
    R[:] r = R();
end M;

M m(r={R(x={1}),R(x={2,3})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor32",
            description="",
            flatModel="
fclass RecordTests.RecordConstructor32
 constant Real m.r[1].x[1] = 1;
 constant Real m.r[2].x[1] = 2;
 constant Real m.r[2].x[2] = 3;
end RecordTests.RecordConstructor32;
")})));
end RecordConstructor32;

model RecordConstructor33

record R1
    parameter Integer n=1;
    Real[n] x = 1:n;
end R1;

record R2
    R1 r1;
    R1[:] r1s;
end R2;

model M
    R2[:] r2;
end M;

M m(r2={R2(R1(0),{R1(1)}),R2(R1(2),{R1(3),R1(4)})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor33",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordConstructor33
 structural parameter Integer m.r2[1].r1.n = 0 /* 0 */;
 structural parameter Integer m.r2[1].r1s[1].n = 1 /* 1 */;
 constant Real m.r2[1].r1s[1].x[1] = 1;
 structural parameter Integer m.r2[2].r1.n = 2 /* 2 */;
 constant Real m.r2[2].r1.x[1] = 1;
 constant Real m.r2[2].r1.x[2] = 2;
 structural parameter Integer m.r2[2].r1s[1].n = 3 /* 3 */;
 constant Real m.r2[2].r1s[1].x[1] = 1;
 constant Real m.r2[2].r1s[1].x[2] = 2;
 constant Real m.r2[2].r1s[1].x[3] = 3;
 structural parameter Integer m.r2[2].r1s[2].n = 4 /* 4 */;
 constant Real m.r2[2].r1s[2].x[1] = 1;
 constant Real m.r2[2].r1s[2].x[2] = 2;
 constant Real m.r2[2].r1s[2].x[3] = 3;
 constant Real m.r2[2].r1s[2].x[4] = 4;
end RecordTests.RecordConstructor33;
")})));
end RecordConstructor33;

model RecordConstructor34
record R1
    Real[:] x;
end R1;

record R2
    R1 r1;
    R1[:] r1s;
end R2;

record M
    R2[:] r2={R2(R1(1:0),{R1(1:0),R1(1:2),R1(1:0),R1(1:0),R1(1:3)})};
end M;

M[1] m();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor34",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordConstructor34
 constant Real m[1].r2[1].r1s[2].x[1] = 1;
 constant Real m[1].r2[1].r1s[2].x[2] = 2;
 constant Real m[1].r2[1].r1s[5].x[1] = 1;
 constant Real m[1].r2[1].r1s[5].x[2] = 2;
 constant Real m[1].r2[1].r1s[5].x[3] = 3;
end RecordTests.RecordConstructor34;
")})));
end RecordConstructor34;

model RecordConstructor35
    record R1
        parameter Real x1;
        parameter Real x2;
    end R1;
    
    record R2
        extends R1(x2=2);
    end R2;
    
    record R3
        parameter R2[:] r2 = {R2(x1=-1)};
    end R3;
    
    R3 r3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor35",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordConstructor35
 parameter Real r3.r2[1].x1 = -1 /* -1 */;
 parameter Real r3.r2[1].x2 = 2 /* 2 */;
end RecordTests.RecordConstructor35;
")})));
end RecordConstructor35;

model RecordConstructor36
    record R1
        Real x;
    end R1;
    
    model M
        R1 r1;
    end M;
    
    M[2] m(r1={R1(i+time) for i in 1:2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor36",
            description="",
            flatModel="
fclass RecordTests.RecordConstructor36
 Real m[1].r1.x;
 Real m[2].r1.x;
equation
 m[1].r1.x = 1 + time;
 m[2].r1.x = m[1].r1.x + 1;
end RecordTests.RecordConstructor36;
")})));
end RecordConstructor36;

model RecordConstructor37
    partial record A
        parameter Real x;
        parameter Real y = 1;
    end A;
    
    record B
        extends A(x=y);
    end B;
    
    parameter A a = B();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor37",
            description="",
            flatModel="
fclass RecordTests.RecordConstructor37
 parameter Real a.x = 1 /* 1 */;
 parameter Real a.y = 1 /* 1 */;
end RecordTests.RecordConstructor37;
")})));
end RecordConstructor37;

model RecordConstructor38
    partial record A
        parameter Real x;
        parameter Real y = 1;
    end A;
    
    record B
        extends A(x=y);
    end B;
    
    record C
        A a;
    end C;
    
    parameter C z(a=B());

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordConstructor38",
            description="",
            flatModel="
fclass RecordTests.RecordConstructor38
 parameter Real z.a.x = 1 /* 1 */;
 parameter Real z.a.y = 1 /* 1 */;
end RecordTests.RecordConstructor38;
")})));
end RecordConstructor38;

model RecordScalarize1
 record A
  Real a;
  Real b;
 end A;
 
 A x(a=1, b=2);
 A y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize1",
            description="Scalarization of records: modification",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize1
 Real x.a;
 Real x.b;
 Real y.a;
 Real y.b;
equation
 y.a = x.a;
 y.b = x.b;
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize1;
")})));
end RecordScalarize1;


model RecordScalarize2
 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize2",
            description="Scalarization of records: basic test",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize2
 Real x.a;
 Real x.b;
 Real y.a;
 Real y.b;
equation
 y.a = x.a;
 y.b = x.b;
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize2;
")})));
end RecordScalarize2;


model RecordScalarize3
 record A
  Real b;
  Real a;
 end A;
 
 A x = A(1, 2);
 A y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize3",
            description="Scalarization of records: record constructor",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize3
 Real x.b;
 Real x.a;
 Real y.b;
 Real y.a;
equation
 y.b = x.b;
 y.a = x.a;
 x.b = 1;
 x.a = 2;
end RecordTests.RecordScalarize3;
")})));
end RecordScalarize3;


model RecordScalarize4
 record A
  Real a;
  Real b;
 end A;

 record B
  Real c;
  Real d;
 end B;
 
 A x = A(1, 2);
 B y = B(3, 4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize4",
            description="Scalarization of records: two different records, record constructors",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize4
 Real x.a;
 Real x.b;
 Real y.c;
 Real y.d;
equation
 x.a = 1;
 x.b = 2;
 y.c = 3;
 y.d = 4;
end RecordTests.RecordScalarize4;
")})));
end RecordScalarize4;


model RecordScalarize5

 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
  Real d;
 end B;
 
 A x = A(1, y);
 B y = B(2, 3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize5",
            description="Scalarization of records: nestled records",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize5
 Real x.a;
 Real x.b.c;
 Real x.b.d;
 Real y.c;
 Real y.d;
equation
 x.a = 1;
 x.b.c = y.c;
 x.b.d = y.d;
 y.c = 2;
 y.d = 3;
end RecordTests.RecordScalarize5;
")})));
end RecordScalarize5;


model RecordScalarize6
 record A
  Real a;
  Real b;
 end A;

 record B
  Real b;
  Real a;
 end B;
 
 A x = B(2, 1);
 B y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize6",
            description="Scalarization of records: equivalent records",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize6
 Real x.a;
 Real x.b;
 Real y.b;
 Real y.a;
equation
 y.b = x.b;
 y.a = x.a;
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize6;
")})));
end RecordScalarize6;


model RecordScalarize7
 record A
  Real b;
  Real a;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 record C
  Real c;
  A x;
 end C;

 record D
  B x;
  Real c;
 end D;
 
 C x = D(B(3, 2), 1);
 D y;
equation
 y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize7",
            description="Scalarization of records: equivalent nestled records",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize7
 Real x.c;
 Real x.x.b;
 Real x.x.a;
 Real y.x.a;
 Real y.x.b;
 Real y.c;
equation
 y.x.a = x.x.a;
 y.x.b = x.x.b;
 y.c = x.c;
 x.c = 1;
 x.x.b = 2;
 x.x.a = 3;
end RecordTests.RecordScalarize7;
")})));
end RecordScalarize7;


model RecordScalarize8
 record A
  Real a[2];
  Real b;
 end A;
 
 A x(a={1,2}, b=1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize8",
            description="Scalarization of records: modification of array component",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize8
 Real x.a[1];
 Real x.a[2];
 Real x.b;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;
end RecordTests.RecordScalarize8;
")})));
end RecordScalarize8;


model RecordScalarize9
 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize9",
            description="Scalarization of records: record containing array",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize9
 Real x.a[1];
 Real x.a[2];
 Real x.b;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;
end RecordTests.RecordScalarize9;
")})));
end RecordScalarize9;


model RecordScalarize10
 record A
  Real a[2];
  Real b;
 end A;
 
 A x = A({1,2}, 3);
 A y;
equation
 x = y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize10",
            description="Scalarization of records: record containing array, using record constructor",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize10
 Real x.a[1];
 Real x.a[2];
 Real x.b;
 Real y.a[1];
 Real y.a[2];
 Real y.b;
equation
 x.a[1] = y.a[1];
 x.a[2] = y.a[2];
 x.b = y.b;
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 3;
end RecordTests.RecordScalarize10;
")})));
end RecordScalarize10;

model RecordScalarize12
 record A
  Real a;
  Real b;
 end A;
 
 A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordScalarize12",
            description="Scalarization of records: array of records",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize12
 RecordTests.RecordScalarize12.A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

public
 record RecordTests.RecordScalarize12.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize12.A;

end RecordTests.RecordScalarize12;
")})));
end RecordScalarize12;


model RecordScalarize13
 record A
  Real a;
  Real b;
 end A;
 
 A x[2] = {A(1,2), A(3,4)};
 A y[2];
equation
 x = y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize13",
            description="Scalarization of records: arrays of records, binding exp + record equation",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize13
 Real x[1].a;
 Real x[1].b;
 Real x[2].a;
 Real x[2].b;
 Real y[1].a;
 Real y[1].b;
 Real y[2].a;
 Real y[2].b;
equation
 x[1].a = y[1].a;
 x[1].b = y[1].b;
 x[2].a = y[2].a;
 x[2].b = y[2].b;
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;
end RecordTests.RecordScalarize13;
")})));
end RecordScalarize13;


model RecordScalarize14
 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 A y[2];
equation
 x = y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize14",
            description="Scalarization of records: nestled records and arrays",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize14
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[1].b[2].a[1];
 Real x[1].b[2].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y[1].b[1].a[1];
 Real y[1].b[1].a[2];
 Real y[1].b[2].a[1];
 Real y[1].b[2].a[2];
 Real y[2].b[1].a[1];
 Real y[2].b[1].a[2];
 Real y[2].b[2].a[1];
 Real y[2].b[2].a[2];
equation
 x[1].b[1].a[1] = y[1].b[1].a[1];
 x[1].b[1].a[2] = y[1].b[1].a[2];
 x[1].b[2].a[1] = y[1].b[2].a[1];
 x[1].b[2].a[2] = y[1].b[2].a[2];
 x[2].b[1].a[1] = y[2].b[1].a[1];
 x[2].b[1].a[2] = y[2].b[1].a[2];
 x[2].b[2].a[1] = y[2].b[2].a[1];
 x[2].b[2].a[2] = y[2].b[2].a[2];
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 x[1].b[2].a[1] = 3;
 x[1].b[2].a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;
end RecordTests.RecordScalarize14;
")})));
end RecordScalarize14;


model RecordScalarize15
 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 Real y = x[1].b[1].a[2];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize15",
            description="Scalarization of records: access of nestled primitive",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize15
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[1].b[2].a[1];
 Real x[1].b[2].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y;
equation
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 x[1].b[2].a[1] = 3;
 x[1].b[2].a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;
 y = x[1].b[1].a[2];
end RecordTests.RecordScalarize15;
")})));
end RecordScalarize15;


model RecordScalarize16
 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 B y = x[1].b[2];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize16",
            description="Scalarization of records: access of nested record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize16
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y.a[1];
 Real y.a[2];
equation
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 y.a[1] = 3;
 y.a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;
end RecordTests.RecordScalarize16;
")})));
end RecordScalarize16;


model RecordScalarize17
 record A
  Real a;
  Real b;
 end A;
 
 A x(b(start=3)) = A(1,2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize17",
            description="Scalarization of records: attribute on primitive in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize17
 Real x.a;
 Real x.b(start = 3);
equation
 x.a = 1;
 x.b = 2;
end RecordTests.RecordScalarize17;
")})));
end RecordScalarize17;


model RecordScalarize18
 record A
  Real a;
 end A;
 
 record B
  A b1;
  A b2;
 end B;
 
 B x(b1(a(start=3)), b2.a(start=4)) = B(A(1),A(2));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize18",
            description="Scalarization of records: attributes on primitives in nestled records",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize18
 Real x.b1.a(start = 3);
 Real x.b2.a(start = 4);
equation
 x.b1.a = 1;
 x.b2.a = 2;
end RecordTests.RecordScalarize18;
")})));
end RecordScalarize18;


model RecordScalarize19
    record A
        Real x[2];
    end A;
	
    A a1(x(stateSelect={StateSelect.default,StateSelect.default},start={1,2}));
equation
    der(a1.x) = -a1.x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize19",
            description="Scalarization of attributes of record members, from modification",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize19
 Real a1.x[1](stateSelect = StateSelect.default,start = 1);
 Real a1.x[2](stateSelect = StateSelect.default,start = 2);
initial equation
 a1.x[1] = 1;
 a1.x[2] = 2;
equation
 der(a1.x[1]) = - a1.x[1];
 der(a1.x[2]) = - a1.x[2];

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end RecordTests.RecordScalarize19;
")})));
end RecordScalarize19;


model RecordScalarize20
    record A
        Real x[2](stateSelect={StateSelect.default,StateSelect.default},start={1,2});
    end A;

    A a1;
equation
    der(a1.x) = -a1.x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize20",
            description="Scalarization of attributes of record members, from record declaration",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize20
 Real a1.x[1](stateSelect = StateSelect.default,start = 1);
 Real a1.x[2](stateSelect = StateSelect.default,start = 2);
initial equation
 a1.x[1] = 1;
 a1.x[2] = 2;
equation
 der(a1.x[1]) = - a1.x[1];
 der(a1.x[2]) = - a1.x[2];

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end RecordTests.RecordScalarize20;
")})));
end RecordScalarize20;


model RecordScalarize21
	record A
		Real x[2];
		Real y;
	end A;
	
	parameter Real y_start = 3;
	
	A a(y(start=y_start));
equation
	a = A({1,2}, 4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize21",
            description="Modifiers on record members using parameters",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize21
 parameter Real y_start = 3 /* 3 */;
 Real a.x[1];
 Real a.x[2];
 Real a.y(start = y_start);
equation
 a.x[1] = 1;
 a.x[2] = 2;
 a.y = 4;
end RecordTests.RecordScalarize21;
")})));
end RecordScalarize21;


model RecordScalarize22
    function f1
        output Real o;
        input A x[3];
    algorithm
        o := x[1].b[2].c;
    end f1;

    function f2
        input Real o;
        output A x;
    algorithm
        x := A(o, {B(o + 1), B(o + 2)});
    end f2;

    function f3
        input Real o;
        output B x;
    algorithm
        x := B(o);
    end f3;
 
    record A
        Real a;
        B b[2];
    end A;
 
    record B
        Real c;
    end B;
 
    Real x = f1({A(1,{B(2),B(3)}),f2(4),A(7,{f3(8),f3(9)})});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize22",
            description="Array of records as argument to function",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordScalarize22
 Real x;
 Real temp_1.a;
 Real temp_1.b[1].c;
 Real temp_1.b[2].c;
 Real temp_2.c;
 Real temp_3.c;
equation
 (RecordTests.RecordScalarize22.A(temp_1.a, {RecordTests.RecordScalarize22.B(temp_1.b[1].c), RecordTests.RecordScalarize22.B(temp_1.b[2].c)})) = RecordTests.RecordScalarize22.f2(4);
 (RecordTests.RecordScalarize22.B(temp_2.c)) = RecordTests.RecordScalarize22.f3(8);
 (RecordTests.RecordScalarize22.B(temp_3.c)) = RecordTests.RecordScalarize22.f3(9);
 x = RecordTests.RecordScalarize22.f1({RecordTests.RecordScalarize22.A(1, {RecordTests.RecordScalarize22.B(2), RecordTests.RecordScalarize22.B(3)}), RecordTests.RecordScalarize22.A(temp_1.a, {RecordTests.RecordScalarize22.B(temp_1.b[1].c), RecordTests.RecordScalarize22.B(temp_1.b[2].c)}), RecordTests.RecordScalarize22.A(7, {RecordTests.RecordScalarize22.B(temp_2.c), RecordTests.RecordScalarize22.B(temp_3.c)})});

public
 function RecordTests.RecordScalarize22.f1
  output Real o;
  input RecordTests.RecordScalarize22.A[:] x;
 algorithm
  for i1 in 1:3 loop
   assert(2 == size(x[i1].b, 1), \"Mismatching sizes in function 'RecordTests.RecordScalarize22.f1', component 'x[i1].b', dimension '1'\");
  end for;
  o := x[1].b[2].c;
  return;
 end RecordTests.RecordScalarize22.f1;

 function RecordTests.RecordScalarize22.f2
  input Real o;
  output RecordTests.RecordScalarize22.A x;
  RecordTests.RecordScalarize22.B[:] temp_1;
 algorithm
  init temp_1 as RecordTests.RecordScalarize22.B[2];
  temp_1[1].c := o + 1;
  temp_1[2].c := o + 2;
  x.a := o;
  for i1 in 1:2 loop
   x.b[i1].c := temp_1[i1].c;
  end for;
  return;
 end RecordTests.RecordScalarize22.f2;

 function RecordTests.RecordScalarize22.f3
  input Real o;
  output RecordTests.RecordScalarize22.B x;
 algorithm
  x.c := o;
  return;
 end RecordTests.RecordScalarize22.f3;

 record RecordTests.RecordScalarize22.B
  Real c;
 end RecordTests.RecordScalarize22.B;

 record RecordTests.RecordScalarize22.A
  Real a;
  RecordTests.RecordScalarize22.B b[2];
 end RecordTests.RecordScalarize22.A;

end RecordTests.RecordScalarize22;
")})));
end RecordScalarize22;


model RecordScalarize23
    record R
        Real[1] X;
    end R;
    
    parameter Real p = -0.1;
    parameter Real[1] s =  {0.4 - p};
    R r(X(start=s)) = R({1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize23",
            description="",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize23
 parameter Real p = -0.1 /* -0.1 */;
 parameter Real s[1];
 Real r.X[1](start = s[1]);
parameter equation
 s[1] = 0.4 - p;
equation
 r.X[1] = 1;
end RecordTests.RecordScalarize23;
")})));
end RecordScalarize23;


model RecordScalarize24
    record R
        Real[1] X;
    end R;
    
    parameter Real p = -0.1;
    R r(X(start={0.4 - p})) = R({1});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize24",
            description="",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize24
 parameter Real p = -0.1 /* -0.1 */;
 Real r.X[1](start = 0.4 - p);
equation
 r.X[1] = 1;
end RecordTests.RecordScalarize24;
")})));
end RecordScalarize24;


model RecordScalarize25
	type A = enumeration(a1, a2);
	
	record B
		Real x;
		A y;
	end B;
	
	B b(x = time, y = if b.x < 3 then A.a1 else A.a2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize25",
            description="Scalarization of enumeration variable in record",
            flatModel="
fclass RecordTests.RecordScalarize25
 Real b.x;
 discrete RecordTests.RecordScalarize25.A b.y;
initial equation
 pre(b.y) = RecordTests.RecordScalarize25.A.a1;
equation
 b.x = time;
 b.y = if b.x < 3 then RecordTests.RecordScalarize25.A.a1 else RecordTests.RecordScalarize25.A.a2;

public
 type RecordTests.RecordScalarize25.A = enumeration(a1, a2);

end RecordTests.RecordScalarize25;
")})));
end RecordScalarize25;


model RecordScalarize26
	record R
	    parameter Real x[2] = { 1, 2 };
	    Real y;
	end R;
	
	R r(y = time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize26",
            description="Scalarization of array with binding expression in record declaration",
            flatModel="
fclass RecordTests.RecordScalarize26
 parameter Real r.x[1] = 1 /* 1 */;
 parameter Real r.x[2] = 2 /* 2 */;
 Real r.y;
equation
 r.y = time;
end RecordTests.RecordScalarize26;
")})));
end RecordScalarize26;

model RecordScalarize27
    record R
        Real[n] x;
        parameter Integer n;
    end R;
    
    R r1;
    R r2(n = 0);
    R r3(x = 1:0);
    R r4(n = 2, x = {1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize27",
            description="Flattening of record with size determined by parameter component",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize27
 structural parameter Integer r1.n = 0 /* 0 */;
 structural parameter Integer r2.n = 0 /* 0 */;
 structural parameter Integer r3.n = 0 /* 0 */;
 constant Real r4.x[1] = 1;
 constant Real r4.x[2] = 2;
 structural parameter Integer r4.n = 2 /* 2 */;
end RecordTests.RecordScalarize27;
")})));
end RecordScalarize27;


model RecordScalarize28
    record R
        Real[n] x = 1:n;
        parameter Integer n = 1;
    end R;
    
    R r1;
    R r2(n = 2);
    R r3(x = {1});
    R r4(n = 3, x = {1,3,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize28",
            description="Flattening of record with size determined by parameter component",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize28
 constant Real r1.x[1] = 1;
 structural parameter Integer r1.n = 1 /* 1 */;
 constant Real r2.x[1] = 1;
 constant Real r2.x[2] = 2;
 structural parameter Integer r2.n = 2 /* 2 */;
 constant Real r3.x[1] = 1;
 structural parameter Integer r3.n = 1 /* 1 */;
 constant Real r4.x[1] = 1;
 constant Real r4.x[2] = 3;
 constant Real r4.x[3] = 2;
 structural parameter Integer r4.n = 3 /* 3 */;
end RecordTests.RecordScalarize28;
")})));
end RecordScalarize28;

model RecordScalarize29
    constant Integer n = 2;
    record R
        Real[n] x = 1:n;
    end R;
    
    function f
        output R r;
        algorithm
    end f;
    
    R r = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize29",
            description="Scalarization of record in function with non literal size",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize29
 constant Integer n = 2;
 Real r.x[1];
 Real r.x[2];
equation
 (RecordTests.RecordScalarize29.R({r.x[1], r.x[2]})) = RecordTests.RecordScalarize29.f();

public
 function RecordTests.RecordScalarize29.f
  output RecordTests.RecordScalarize29.R r;
 algorithm
  for i1 in 1:2 loop
   r.x[i1] := i1;
  end for;
  return;
 end RecordTests.RecordScalarize29.f;

 record RecordTests.RecordScalarize29.R
  Real x[2];
 end RecordTests.RecordScalarize29.R;

end RecordTests.RecordScalarize29;
")})));
end RecordScalarize29;


model RecordScalarize30
    record A
        parameter Real x;
        constant Real y;
    end A;
    
    record B
        parameter A a;
        parameter Real x;
        parameter Real y;
    end B;
    
    B b(a(x = 1, y = 2), x = 3, y = 4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize30",
            description="Variability of nested records, case that caused crash",
            flatModel="
fclass RecordTests.RecordScalarize30
 parameter Real b.a.x = 1 /* 1 */;
 constant Real b.a.y = 2;
 parameter Real b.x = 3 /* 3 */;
 parameter Real b.y = 4 /* 4 */;
end RecordTests.RecordScalarize30;
")})));
end RecordScalarize30;

model RecordScalarize31
    record A
        Real x;
    end A;
    
    record B
        A a;
    end B;
    
    function f
        input Real x;
        output A a;
    algorithm
        a := A(x);
    end f;
    
    B b(a = f(time));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize31",
            description="Scalarizing record without binding expressions.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize31
 Real b.a.x;
equation
 (RecordTests.RecordScalarize31.A(b.a.x)) = RecordTests.RecordScalarize31.f(time);

public
 function RecordTests.RecordScalarize31.f
  input Real x;
  output RecordTests.RecordScalarize31.A a;
 algorithm
  a.x := x;
  return;
 end RecordTests.RecordScalarize31.f;

 record RecordTests.RecordScalarize31.A
  Real x;
 end RecordTests.RecordScalarize31.A;

end RecordTests.RecordScalarize31;
")})));
end RecordScalarize31;

model RecordScalarize32

    record A
        Real x;
    end A;
    
    record B
        A a;
    end B;
    
    function f
        input Real x;
        output A a;
    algorithm
        a := A(x);
    end f;
    
    parameter B pb(a = f(2));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize32",
            description="Scalarizing record without binding expressions.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize32
 parameter Real pb.a.x;
parameter equation
 (RecordTests.RecordScalarize32.A(pb.a.x)) = RecordTests.RecordScalarize32.f(2);

public
 function RecordTests.RecordScalarize32.f
  input Real x;
  output RecordTests.RecordScalarize32.A a;
 algorithm
  a.x := x;
  return;
 end RecordTests.RecordScalarize32.f;

 record RecordTests.RecordScalarize32.A
  Real x;
 end RecordTests.RecordScalarize32.A;

end RecordTests.RecordScalarize32;
")})));
end RecordScalarize32;

model RecordScalarize33
    record A
        Real x;
    end A;
    
    record B
        A a1;
        parameter A a2;
    end B;
    
    function f
        input Real x;
        output A a;
    algorithm
        a := A(x);
    end f;
    
    B b(a1 = f(time), a2 = f(2));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize33",
            description="Scalarizing record without binding expressions.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize33
 Real b.a1.x;
 parameter Real b.a2.x;
parameter equation
 (RecordTests.RecordScalarize33.A(b.a2.x)) = RecordTests.RecordScalarize33.f(2);
equation
 (RecordTests.RecordScalarize33.A(b.a1.x)) = RecordTests.RecordScalarize33.f(time);

public
 function RecordTests.RecordScalarize33.f
  input Real x;
  output RecordTests.RecordScalarize33.A a;
 algorithm
  a.x := x;
  return;
 end RecordTests.RecordScalarize33.f;

 record RecordTests.RecordScalarize33.A
  Real x;
 end RecordTests.RecordScalarize33.A;

end RecordTests.RecordScalarize33;
")})));
end RecordScalarize33;

model RecordScalarize34
    record R
        parameter Real n;
        Real[:] x = cat(1, 1:n, 2:n);
    end R;
    
    R r(n=3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize34",
            description="Scalarizing record without binding expressions.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize34
 structural parameter Real r.n = 3 /* 3 */;
 Real r.x[1];
 Real r.x[2];
 Real r.x[3];
 Real r.x[4];
 Real r.x[5];
equation
 r.x[1] = 1.0;
 r.x[2] = 2.0;
 r.x[3] = 3.0;
 r.x[4] = 2.0;
 r.x[5] = 3.0;
end RecordTests.RecordScalarize34;
")})));
end RecordScalarize34;

model RecordScalarize35
    function f
        input Real i;
        output B o = B(i);
    algorithm
    end f;
    
    record B
        Real v1;
    end B;
    
    record A
        B[3] b1;
    end A;
    
    A a1(b1 = f({1,2,3}));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize35",
            description="Scalarizing record with vector function call in modifier #4316",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize35
 Real a1.b1[1].v1;
 Real a1.b1[2].v1;
 Real a1.b1[3].v1;
equation
 (RecordTests.RecordScalarize35.B(a1.b1[1].v1)) = RecordTests.RecordScalarize35.f(1);
 (RecordTests.RecordScalarize35.B(a1.b1[2].v1)) = RecordTests.RecordScalarize35.f(2);
 (RecordTests.RecordScalarize35.B(a1.b1[3].v1)) = RecordTests.RecordScalarize35.f(3);

public
 function RecordTests.RecordScalarize35.f
  input Real i;
  output RecordTests.RecordScalarize35.B o;
 algorithm
  o.v1 := i;
  return;
 end RecordTests.RecordScalarize35.f;

 record RecordTests.RecordScalarize35.B
  Real v1;
 end RecordTests.RecordScalarize35.B;

end RecordTests.RecordScalarize35;
")})));
end RecordScalarize35;

model RecordScalarize36
    record R
        parameter Integer n = 1 annotation(Evaluate=true);
        Real[n] x = 1:n;
    end R;
    
    R r(n=3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize36",
            description="Scalarizing record without binding expressions.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize36
 eval parameter Integer r.n = 3 /* 3 */;
 Real r.x[1];
 Real r.x[2];
 Real r.x[3];
equation
 r.x[1] = 1;
 r.x[2] = 2;
 r.x[3] = 3;
end RecordTests.RecordScalarize36;
")})));
end RecordScalarize36;


model RecordScalarize37
    record A
        Real x;
    end A;
    
    function AA
        input Real x;
        output A a = A(x);
      algorithm
    end AA;
    
    function f
        input A x;
        output Real a;
    algorithm
        a := 1;
    end f;
    
    A a1(x(start=f(AA(3))));
    A[2] a2(x(start={f(AA(4)),f(AA(5))}));
  equation
    a1.x = 4;
    a2[1].x = 4;
    a2[2].x = 4;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize37",
            description="Scalarizing record with temporaries in start value modifiers",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize37
 Real a1.x(start = RecordTests.RecordScalarize37.f(RecordTests.RecordScalarize37.AA(3)));
 Real a2[1].x(start = RecordTests.RecordScalarize37.f(RecordTests.RecordScalarize37.AA(4)));
 Real a2[2].x(start = RecordTests.RecordScalarize37.f(RecordTests.RecordScalarize37.AA(5)));
equation
 a1.x = 4;
 a2[1].x = 4;
 a2[2].x = 4;

public
 function RecordTests.RecordScalarize37.f
  input RecordTests.RecordScalarize37.A x;
  output Real a;
 algorithm
  a := 1;
  return;
 end RecordTests.RecordScalarize37.f;

 function RecordTests.RecordScalarize37.AA
  input Real x;
  output RecordTests.RecordScalarize37.A a;
 algorithm
  a.x := x;
  return;
 end RecordTests.RecordScalarize37.AA;

 record RecordTests.RecordScalarize37.A
  Real x;
 end RecordTests.RecordScalarize37.A;

end RecordTests.RecordScalarize37;
")})));
end RecordScalarize37;

model RecordScalarize38
    record A
        Real y[2];
    end A;
 
    A a1[2](y = {{1,2},{3,4}} * time);
    A a2 = if time > 1 then a1[1] else a1[2];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize38",
            description="Scalarizing record with binding expressions.",
            eliminate_linear_equations=false,
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize38
 Real a1[1].y[1];
 Real a1[1].y[2];
 Real a1[2].y[1];
 Real a1[2].y[2];
 Real a2.y[1];
 Real a2.y[2];
equation
 a1[1].y[1] = time;
 a1[1].y[2] = 2 * time;
 a1[2].y[1] = 3 * time;
 a1[2].y[2] = 4 * time;
 a2.y[1] = if time > 1 then a1[1].y[1] else a1[2].y[1];
 a2.y[2] = if time > 1 then a1[1].y[2] else a1[2].y[2];
end RecordTests.RecordScalarize38;
")})));
end RecordScalarize38;

model RecordScalarize39
    record R
        Real x;
    end R;
    
    R[2] r(x(start=1:2) = 1:2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize39",
            description="Scalarizing record with array start value.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize39
 Real r[1].x(start = 1);
 Real r[2].x(start = 2);
equation
 r[1].x = 1;
 r[2].x = 2;
end RecordTests.RecordScalarize39;
")})));
end RecordScalarize39;

model RecordScalarize40
    record R
        Real[2] x;
    end R;
    
    R[2] r(x(start={1:2,3:4}) = {1:2,3:4});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize40",
            description="Scalarizing record with array start value.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordScalarize40
 Real r[1].x[1](start = 1);
 Real r[1].x[2](start = 2);
 Real r[2].x[1](start = 3);
 Real r[2].x[2](start = 4);
equation
 r[1].x[1] = 1;
 r[1].x[2] = 2;
 r[2].x[1] = 3;
 r[2].x[2] = 4;
end RecordTests.RecordScalarize40;
")})));
end RecordScalarize40;

model RecordScalarize41
    record R
        Real a;
        Real b;
    end R;

    input R r1;
    output R r2 = r1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize41",
            description="Scalarization of input/output records",
            flatModel="
fclass RecordTests.RecordScalarize41
 input Real r1.a;
 input Real r1.b;
 output Real r2.a;
 output Real r2.b;
equation
 r2.a = r1.a;
 r2.b = r1.b;
end RecordTests.RecordScalarize41;
")})));
end RecordScalarize41;

model RecordScalarize42
    record R
        Real c;
        R2 r;
    end R;

    record R2
        Real a;
        Real b;
    end R2;

    input R r1;
    output R r2 = r1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize42",
            description="Scalarization of input/output records",
            flatModel="
fclass RecordTests.RecordScalarize42
 input Real r1.c;
 input Real r1.r.a;
 input Real r1.r.b;
 output Real r2.c;
 output Real r2.r.a;
 output Real r2.r.b;
equation
 r2.c = r1.c;
 r2.r.a = r1.r.a;
 r2.r.b = r1.r.b;
end RecordTests.RecordScalarize42;
")})));
end RecordScalarize42;

model RecordScalarize43
    Integer i = integer(time);
    record R
        Real[:] x;
    end R;
    
    R[:] r = {R(1:3),R(1:2)};
    Real[size(r,1)] x;
equation
    for j in 1:size(r,1) loop
        x[j] = r[j].x[i];
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize43",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize43
 discrete Integer i;
 constant Real r[1].x[1] = 1;
 constant Real r[1].x[2] = 2;
 constant Real r[1].x[3] = 3;
 constant Real r[2].x[1] = 1;
 constant Real r[2].x[2] = 2;
 Real x[1];
 Real x[2];
 discrete Integer temp_1;
initial equation
 pre(temp_1) = 0;
 pre(i) = 0;
equation
 x[1] = ({1.0, 2.0, 3.0})[i];
 x[2] = ({1.0, 2.0})[i];
 i = temp_1;
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end RecordTests.RecordScalarize43;
")})));
end RecordScalarize43;

model RecordScalarize44
    record R
        Real[:] x;
    end R;
    model M
        Integer i = integer(time);
        R[:] r = {R(1:3),R(1:2)};
        Real[size(r,1)] x;
    end M;
    M m;
equation
    for j in 1:size(m.r, 1) loop
        m.x[j] = m.r[j].x[m.i];
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize44",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize44
 discrete Integer m.i;
 constant Real m.r[1].x[1] = 1;
 constant Real m.r[1].x[2] = 2;
 constant Real m.r[1].x[3] = 3;
 constant Real m.r[2].x[1] = 1;
 constant Real m.r[2].x[2] = 2;
 Real m.x[1];
 Real m.x[2];
 discrete Integer temp_1;
initial equation
 pre(temp_1) = 0;
 pre(m.i) = 0;
equation
 m.x[1] = ({1.0, 2.0, 3.0})[m.i];
 m.x[2] = ({1.0, 2.0})[m.i];
 m.i = temp_1;
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end RecordTests.RecordScalarize44;
")})));
end RecordScalarize44;

model RecordScalarize45
    record R
        Real[:] x;
    end R;
    model M
        Integer i = integer(time);
        R[:] r = {R(1:3),R(1:2)};
        Real[size(r,1)] x;
    end M;
    M m;
equation
    for j in 1:size(m.r,1) loop
        m.x[j] = m.r[j].x[end];
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize45",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize45
 discrete Integer m.i;
 constant Real m.r[1].x[1] = 1;
 constant Real m.r[1].x[2] = 2;
 constant Real m.r[1].x[3] = 3;
 constant Real m.r[2].x[1] = 1;
 constant Real m.r[2].x[2] = 2;
 constant Real m.x[1] = 3.0;
 constant Real m.x[2] = 2.0;
 discrete Integer temp_1;
initial equation
 pre(temp_1) = 0;
 pre(m.i) = 0;
equation
 m.i = temp_1;
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end RecordTests.RecordScalarize45;
")})));
end RecordScalarize45;

model RecordScalarize46
    function f
        input R r;
        output Real y = r.x;
        algorithm
    end f;
    record R
        Real x;
    end R;
    Real[2] y;
    R[:] r = {R(1),R(2)};
equation
    for i in 1:2 loop
        y[i] = f(r[i]);
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize46",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize46
 constant Real y[1] = 1.0;
 constant Real y[2] = 2.0;
 constant Real r[1].x = 1;
 constant Real r[2].x = 2;
end RecordTests.RecordScalarize46;
")})));
end RecordScalarize46;

model RecordScalarize47
    record R
        Real x;
    end R;
    
    function f
        input R x;
        output Real y;
    algorithm
        y := x.x;
        annotation(Inline=false);
    end f;
    
    parameter Boolean p = true;
    R r1 = R(time);
    R r2 = R(2 * time);
    Real x = f(if p then r1 else r2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize47",
            description="",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass RecordTests.RecordScalarize47
 parameter Boolean p = true /* true */;
 Real r1.x;
 Real r2.x;
 Real x;
equation
 r1.x = time;
 r2.x = 2 * time;
 x = RecordTests.RecordScalarize47.f(if p then RecordTests.RecordScalarize47.R(r1.x) else RecordTests.RecordScalarize47.R(r2.x));

public
 function RecordTests.RecordScalarize47.f
  input RecordTests.RecordScalarize47.R x;
  output Real y;
 algorithm
  y := x.x;
  return;
 annotation(Inline = false);
 end RecordTests.RecordScalarize47.f;

 record RecordTests.RecordScalarize47.R
  Real x;
 end RecordTests.RecordScalarize47.R;

end RecordTests.RecordScalarize47;
")})));
end RecordScalarize47;

model RecordScalarize48
    record R
        Real x[3];
    end R;
    
    model M
        R r1;
        R r2 = r1;
    end M;
    
    R[:] r1 ={R(x),R(x)};
    R[:] r2 ={R(x),R(x)};
    Real[:] x = {1,2,3};
    M[2] m(r1=if true then r1 else r2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize48",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize48
 constant Real r1[1].x[1] = 1.0;
 constant Real r1[1].x[2] = 2.0;
 constant Real r1[1].x[3] = 3.0;
 constant Real r1[2].x[1] = 1.0;
 constant Real r1[2].x[2] = 2.0;
 constant Real r1[2].x[3] = 3.0;
 constant Real r2[1].x[1] = 1.0;
 constant Real r2[1].x[2] = 2.0;
 constant Real r2[1].x[3] = 3.0;
 constant Real r2[2].x[1] = 1.0;
 constant Real r2[2].x[2] = 2.0;
 constant Real r2[2].x[3] = 3.0;
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
 constant Real m[1].r1.x[1] = 1.0;
 constant Real m[1].r1.x[2] = 2.0;
 constant Real m[1].r1.x[3] = 3.0;
 constant Real m[1].r2.x[1] = 1.0;
 constant Real m[1].r2.x[2] = 2.0;
 constant Real m[1].r2.x[3] = 3.0;
 constant Real m[2].r1.x[1] = 1.0;
 constant Real m[2].r1.x[2] = 2.0;
 constant Real m[2].r1.x[3] = 3.0;
 constant Real m[2].r2.x[1] = 1.0;
 constant Real m[2].r2.x[2] = 2.0;
 constant Real m[2].r2.x[3] = 3.0;
end RecordTests.RecordScalarize48;
")})));
end RecordScalarize48;

model RecordScalarize49
record R1
    parameter Integer n = 1;
    Real[n] x = (1:n) .+ time;
end R1;
    
record R2
    parameter Integer n;
    R1 r1(n=2);
end R2;

R2 r2 = R2(2, R1(2,fill(0,2)));
R2 r22 = r2;
R2 r3 = R2(3, R1(3,fill(0,3)));
R2 r32 = r3;
R2[:] r = {r22,r32};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize49",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize49
 parameter Integer r2.n = 2 /* 2 */;
 structural parameter Integer r2.r1.n = 2 /* 2 */;
 constant Real r2.r1.x[1] = 0;
 constant Real r2.r1.x[2] = 0;
 parameter Integer r22.n;
 structural parameter Integer r22.r1.n = 2 /* 2 */;
 constant Real r22.r1.x[1] = 0.0;
 constant Real r22.r1.x[2] = 0.0;
 parameter Integer r3.n = 3 /* 3 */;
 structural parameter Integer r3.r1.n = 3 /* 3 */;
 constant Real r3.r1.x[1] = 0;
 constant Real r3.r1.x[2] = 0;
 constant Real r3.r1.x[3] = 0;
 parameter Integer r32.n;
 structural parameter Integer r32.r1.n = 3 /* 3 */;
 constant Real r32.r1.x[1] = 0.0;
 constant Real r32.r1.x[2] = 0.0;
 constant Real r32.r1.x[3] = 0.0;
 parameter Integer r[1].n;
 structural parameter Integer r[1].r1.n = 2 /* 2 */;
 constant Real r[1].r1.x[1] = 0.0;
 constant Real r[1].r1.x[2] = 0.0;
 parameter Integer r[2].n;
 structural parameter Integer r[2].r1.n = 3 /* 3 */;
 constant Real r[2].r1.x[1] = 0.0;
 constant Real r[2].r1.x[2] = 0.0;
 constant Real r[2].r1.x[3] = 0.0;
parameter equation
 r22.n = r2.n;
 r32.n = r3.n;
 r[1].n = r22.n;
 r[2].n = r32.n;
end RecordTests.RecordScalarize49;
")})));
end RecordScalarize49;

model RecordScalarize50
record R1
    parameter Integer n = 1;
    Real[n] x = (1:n) .+ time;
end R1;
    
record R2
    parameter Integer n;
    R1 r1(n=2);
end R2;

record R3
    R2[:] r2;
end R3;

record R4
    R3[:] r3;
end R4;

R4 r1 = R4({R3({R2(2, R1(2,fill(0,2))),R2(3, R1(3,fill(0,3)))})});
R4 r2 = r1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize50",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize50
 parameter Integer r1.r3[1].r2[1].n = 2 /* 2 */;
 structural parameter Integer r1.r3[1].r2[1].r1.n = 2 /* 2 */;
 constant Real r1.r3[1].r2[1].r1.x[1] = 0;
 constant Real r1.r3[1].r2[1].r1.x[2] = 0;
 parameter Integer r1.r3[1].r2[2].n = 3 /* 3 */;
 structural parameter Integer r1.r3[1].r2[2].r1.n = 3 /* 3 */;
 constant Real r1.r3[1].r2[2].r1.x[1] = 0;
 constant Real r1.r3[1].r2[2].r1.x[2] = 0;
 constant Real r1.r3[1].r2[2].r1.x[3] = 0;
 parameter Integer r2.r3[1].r2[1].n;
 structural parameter Integer r2.r3[1].r2[1].r1.n = 2 /* 2 */;
 constant Real r2.r3[1].r2[1].r1.x[1] = 0.0;
 constant Real r2.r3[1].r2[1].r1.x[2] = 0.0;
 parameter Integer r2.r3[1].r2[2].n;
 structural parameter Integer r2.r3[1].r2[2].r1.n = 3 /* 3 */;
 constant Real r2.r3[1].r2[2].r1.x[1] = 0.0;
 constant Real r2.r3[1].r2[2].r1.x[2] = 0.0;
 constant Real r2.r3[1].r2[2].r1.x[3] = 0.0;
parameter equation
 r2.r3[1].r2[1].n = r1.r3[1].r2[1].n;
 r2.r3[1].r2[2].n = r1.r3[1].r2[2].n;
end RecordTests.RecordScalarize50;
")})));
end RecordScalarize50;

model RecordScalarize51
    record R
        Real[n] x;
        parameter Integer n;
    end R;
    function f
        input R r;
        output Real[r.n] y = r.x;
        algorithm
    end f;
    
    model M
        parameter R r = R({1},1);
        parameter Real[r.n] y = f(r);
    end M;
    
    M m;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize51",
            description="",
            flatModel="
fclass RecordTests.RecordScalarize51
 parameter Real m.r.x[1] = 1 /* 1 */;
 structural parameter Integer m.r.n = 1 /* 1 */;
 parameter Real m.y[1];
parameter equation
 m.y[1] = m.r.x[1];
end RecordTests.RecordScalarize51;
")})));
end RecordScalarize51;

model RecordScalarize52
    record R
        Real[1] x;
    end R;
    
    function f
        output R r = R(2:2);
        algorithm
    end f;
    
    R r = if time > 1 then R(1:1) else f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize52",
            description="",
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordScalarize52
 Real r.x[1];
equation
 r.x[1] = if time > 1 then 1 else 2.0;
end RecordTests.RecordScalarize52;
")})));
end RecordScalarize52;

model RecordScalarize53
    record R
        Real x;
    end R;
    R x[2] = {R(1),R(2)};
    R y = x[integer(time)];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize53",
            description="",
            flatModel="
fclass RecordTests.RecordScalarize53
 constant Real x[1].x = 1;
 constant Real x[2].x = 2;
 Real y.x;
 discrete Integer temp_1;
initial equation
 pre(temp_1) = 0;
equation
 y.x = ({1.0, 2.0})[temp_1];
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end RecordTests.RecordScalarize53;
")})));
end RecordScalarize53;

model RecordScalarize55

function f
  input Integer n;
  output R1 r1(n=n);
algorithm
  for i in 1:n loop
    r1.r2s[i] := R2(i=i);
  end for;
end f;

record R1
  parameter Integer n = 1;
  R2 r2s[n];
end R1;

record R2
  parameter Real i = 1;
end R2;

  parameter Integer n = 3;
  Real is[n];
  R1 r1(n=n) = f(n);
equation
  for i in 1:n loop
    r1.r2s[i].i = sin(is[i]);
  end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize55",
            description="Test of lookup of variable in a record within an array of record.",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordScalarize55
 structural parameter Integer n = 3 /* 3 */;
 Real is[1];
 Real is[2];
 Real is[3];
 structural parameter Integer r1.n = 3 /* 3 */;
 structural parameter Real r1.r2s[1].i = 1 /* 1 */;
 structural parameter Real r1.r2s[2].i = 2 /* 2 */;
 structural parameter Real r1.r2s[3].i = 3 /* 3 */;
equation
 1.0 = sin(is[1]);
 2.0 = sin(is[2]);
 3.0 = sin(is[3]);
end RecordTests.RecordScalarize55;
")})));
end RecordScalarize55;

model RecordScalarize56
record R
    Real[:] x;
end R;

R r(x={i for i in 1:0});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize56",
            description="",
            flatModel="
fclass RecordTests.RecordScalarize56
end RecordTests.RecordScalarize56;
")})));
end RecordScalarize56;


model RecordScalarize57
record R
    Real t = time;
    constant Real[:] x;
end R;

R r(x=fill(1,0));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize57",
            description="",
            flatModel="
fclass RecordTests.RecordScalarize57
 Real r.t;
equation
 r.t = time;
end RecordTests.RecordScalarize57;
")})));
end RecordScalarize57;

model RecordScalarize58
record R
    Real[:] x;
end R;

constant R r(x=1:0);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordScalarize58",
            description="",
            flatModel="
fclass RecordTests.RecordScalarize58
end RecordTests.RecordScalarize58;
")})));
end RecordScalarize58;


model RecordFunc1
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc1",
            description="Scalarization of records in functions: accesses of components",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc1
 Real q;
equation
 q = RecordTests.RecordFunc1.f(1, 2);

public
 function RecordTests.RecordFunc1.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc1.A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
  return;
 end RecordTests.RecordFunc1.f;

 record RecordTests.RecordFunc1.A
  Real x;
  Real y;
 end RecordTests.RecordFunc1.A;

end RecordTests.RecordFunc1;
")})));
end RecordFunc1;


model RecordFunc2
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
  protected A w;
 algorithm
  z.x := ix;
  z.y := iy;
  w := z;
  o := w.x * w.y;
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc2",
            description="Scalarization of records in functions: assignment",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc2
 Real q;
equation
 q = RecordTests.RecordFunc2.f(1, 2);

public
 function RecordTests.RecordFunc2.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc2.A z;
  RecordTests.RecordFunc2.A w;
 algorithm
  z.x := ix;
  z.y := iy;
  w.x := z.x;
  w.y := z.y;
  o := w.x * w.y;
  return;
 end RecordTests.RecordFunc2.f;

 record RecordTests.RecordFunc2.A
  Real x;
  Real y;
 end RecordTests.RecordFunc2.A;

end RecordTests.RecordFunc2;
")})));
end RecordFunc2;


model RecordFunc3
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z := A(ix, iy);
  o := z.x * z.y;
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc3",
            description="Scalarization of records in functions: record constructor",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc3
 Real q;
equation
 q = RecordTests.RecordFunc3.f(1, 2);

public
 function RecordTests.RecordFunc3.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc3.A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
  return;
 end RecordTests.RecordFunc3.f;

 record RecordTests.RecordFunc3.A
  Real x;
  Real y;
 end RecordTests.RecordFunc3.A;

end RecordTests.RecordFunc3;
")})));
end RecordFunc3;


model RecordFunc3b
 record A
  Real x;
  Real y;
 end A;
 
 record B
  Real x;
  Real y;
 end B;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z := B(ix, iy);
  o := z.x * z.y;
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc3b",
            description="Scalarization of records in functions: record constructor for equivalent record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc3b
 Real q;
equation
 q = RecordTests.RecordFunc3b.f(1, 2);

public
 function RecordTests.RecordFunc3b.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc3b.A z;
 algorithm
  z.x := ix;
  z.y := iy;
  o := z.x * z.y;
  return;
 end RecordTests.RecordFunc3b.f;

 record RecordTests.RecordFunc3b.A
  Real x;
  Real y;
 end RecordTests.RecordFunc3b.A;

end RecordTests.RecordFunc3b;
")})));
end RecordFunc3b;


model RecordFunc4
 record A
  Real x[2];
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  o := z.x[1] * z.x[2];
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc4",
            description="Scalarization of records in functions: inner array, access",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc4
 Real q;
equation
 q = RecordTests.RecordFunc4.f(1, 2);

public
 function RecordTests.RecordFunc4.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc4.A z;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  o := z.x[1] * z.x[2];
  return;
 end RecordTests.RecordFunc4.f;

 record RecordTests.RecordFunc4.A
  Real x[2];
 end RecordTests.RecordFunc4.A;

end RecordTests.RecordFunc4;
")})));
end RecordFunc4;


model RecordFunc5
 record A
  Real x[2];
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
  protected A w;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  w := z;
  o := w.x[1] * w.x[2];
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc5",
            description="Scalarization of records in functions: inner array, assignment",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc5
 Real q;
equation
 q = RecordTests.RecordFunc5.f(1, 2);

public
 function RecordTests.RecordFunc5.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc5.A z;
  RecordTests.RecordFunc5.A w;
 algorithm
  z.x[1] := ix;
  z.x[2] := iy;
  for i1 in 1:2 loop
   w.x[i1] := z.x[i1];
  end for;
  o := w.x[1] * w.x[2];
  return;
 end RecordTests.RecordFunc5.f;

 record RecordTests.RecordFunc5.A
  Real x[2];
 end RecordTests.RecordFunc5.A;

end RecordTests.RecordFunc5;
")})));
end RecordFunc5;


model RecordFunc6
 record A
  Real x[2];
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z;
 algorithm
  z := A({ix, iy});
  o := z.x[1] * z.x[2];
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc6",
            description="Scalarization of records in functions: record constructor",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc6
 Real q;
equation
 q = RecordTests.RecordFunc6.f(1, 2);

public
 function RecordTests.RecordFunc6.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc6.A z;
  Real[:] temp_1;
 algorithm
  init temp_1 as Real[2];
  temp_1[1] := ix;
  temp_1[2] := iy;
  for i1 in 1:2 loop
   z.x[i1] := temp_1[i1];
  end for;
  o := z.x[1] * z.x[2];
  return;
 end RecordTests.RecordFunc6.f;

 record RecordTests.RecordFunc6.A
  Real x[2];
 end RecordTests.RecordFunc6.A;

end RecordTests.RecordFunc6;
")})));
end RecordFunc6;


model RecordFunc7
 record A
  Real x;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z[2];
 algorithm
  z[1].x := ix;
  z[2].x := iy;
  o := z[1].x * z[2].x;
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc7",
            description="Scalarization of records in functions: array of records, access",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc7
 Real q;
equation
 q = RecordTests.RecordFunc7.f(1, 2);

public
 function RecordTests.RecordFunc7.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc7.A[:] z;
 algorithm
  init z as RecordTests.RecordFunc7.A[2];
  z[1].x := ix;
  z[2].x := iy;
  o := z[1].x * z[2].x;
  return;
 end RecordTests.RecordFunc7.f;

 record RecordTests.RecordFunc7.A
  Real x;
 end RecordTests.RecordFunc7.A;

end RecordTests.RecordFunc7;
")})));
end RecordFunc7;


model RecordFunc8
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z[2];
  protected A w[2];
 algorithm
  z[1].x := ix;
  z[1].y := iy;
  z[2].x := ix;
  z[2].y := iy;
  w := z;
  o := w[1].x * w[2].x;
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc8",
            description="Scalarization of records in functions: array of records, assignment",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc8
 Real q;
equation
 q = RecordTests.RecordFunc8.f(1, 2);

public
 function RecordTests.RecordFunc8.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc8.A[:] z;
  RecordTests.RecordFunc8.A[:] w;
 algorithm
  init z as RecordTests.RecordFunc8.A[2];
  init w as RecordTests.RecordFunc8.A[2];
  z[1].x := ix;
  z[1].y := iy;
  z[2].x := ix;
  z[2].y := iy;
  for i1 in 1:2 loop
   w[i1].x := z[i1].x;
   w[i1].y := z[i1].y;
  end for;
  o := w[1].x * w[2].x;
  return;
 end RecordTests.RecordFunc8.f;

 record RecordTests.RecordFunc8.A
  Real x;
  Real y;
 end RecordTests.RecordFunc8.A;

end RecordTests.RecordFunc8;
")})));
end RecordFunc8;


model RecordFunc9
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input Real ix;
  input Real iy;
  output Real o;
  protected A z[2];
 algorithm
  z := {A(ix, iy), A(ix+2, iy+2)};
  o := z[1].x * z[2].x;
 end f;
 
 Real q = f(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc9",
            description="Scalarization of records in functions: array of records, constructor",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc9
 Real q;
equation
 q = RecordTests.RecordFunc9.f(1, 2);

public
 function RecordTests.RecordFunc9.f
  input Real ix;
  input Real iy;
  output Real o;
  RecordTests.RecordFunc9.A[:] z;
  RecordTests.RecordFunc9.A[:] temp_1;
 algorithm
  init z as RecordTests.RecordFunc9.A[2];
  init temp_1 as RecordTests.RecordFunc9.A[2];
  temp_1[1].x := ix;
  temp_1[1].y := iy;
  temp_1[2].x := ix + 2;
  temp_1[2].y := iy + 2;
  for i1 in 1:2 loop
   z[i1].x := temp_1[i1].x;
   z[i1].y := temp_1[i1].y;
  end for;
  o := z[1].x * z[2].x;
  return;
 end RecordTests.RecordFunc9.f;

 record RecordTests.RecordFunc9.A
  Real x;
  Real y;
 end RecordTests.RecordFunc9.A;

end RecordTests.RecordFunc9;
")})));
end RecordFunc9;


model RecordFunc10
 record A
  Real[2] x;
 end A;
 
 function f
  input A[1] x;
  output A[1] y;
 algorithm
  x := y;
 end f;
 
 A[1] a1 = {A(1:2)};
 A[1] a2 = f(a1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc10",
            description="Scalarization of records in functions: array of records with array of reals.",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordFunc10
 Real a1[1].x[1];
 Real a1[1].x[2];
 Real a2[1].x[1];
 Real a2[1].x[2];
equation
 a1[1].x[1] = 1;
 a1[1].x[2] = 2;
 ({RecordTests.RecordFunc10.A({a2[1].x[1], a2[1].x[2]})}) = RecordTests.RecordFunc10.f({RecordTests.RecordFunc10.A({a1[1].x[1], a1[1].x[2]})});

public
 function RecordTests.RecordFunc10.f
  input RecordTests.RecordFunc10.A[:] x;
  output RecordTests.RecordFunc10.A[:] y;
 algorithm
  init y as RecordTests.RecordFunc10.A[1];
  for i1 in 1:1 loop
   assert(2 == size(x[i1].x, 1), \"Mismatching sizes in function 'RecordTests.RecordFunc10.f', component 'x[i1].x', dimension '1'\");
  end for;
  for i1 in 1:1 loop
   for i2 in 1:2 loop
    x[i1].x[i2] := y[i1].x[i2];
   end for;
  end for;
  return;
 end RecordTests.RecordFunc10.f;

 record RecordTests.RecordFunc10.A
  Real x[2];
 end RecordTests.RecordFunc10.A;

end RecordTests.RecordFunc10;
")})));
end RecordFunc10;


model RecordFunc11
 record A
  Real[2] x;
 end A;
 
 function f
  input A[1] x;
  output A y;
 algorithm
  y := x[1];
 end f;
 
 A[1] a1 = {A(1:2)};
 A a2 = f(a1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordFunc11",
            description="Scalarization of records in functions: array of records with array of reals.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordFunc11
 Real a1[1].x[1];
 Real a1[1].x[2];
 Real a2.x[1];
 Real a2.x[2];
equation
 a1[1].x[1] = 1;
 a1[1].x[2] = 2;
 (RecordTests.RecordFunc11.A({a2.x[1], a2.x[2]})) = RecordTests.RecordFunc11.f({RecordTests.RecordFunc11.A({a1[1].x[1], a1[1].x[2]})});

public
 function RecordTests.RecordFunc11.f
  input RecordTests.RecordFunc11.A[:] x;
  output RecordTests.RecordFunc11.A y;
 algorithm
  for i1 in 1:1 loop
   assert(2 == size(x[i1].x, 1), \"Mismatching sizes in function 'RecordTests.RecordFunc11.f', component 'x[i1].x', dimension '1'\");
  end for;
  for i1 in 1:2 loop
   y.x[i1] := x[1].x[i1];
  end for;
  return;
 end RecordTests.RecordFunc11.f;

 record RecordTests.RecordFunc11.A
  Real x[2];
 end RecordTests.RecordFunc11.A;

end RecordTests.RecordFunc11;
")})));
end RecordFunc11;



model RecordOutput1
 record A
  Real y;
  Real x;
 end A;
 
 function f
  output A o = A(1, 2);
 algorithm
 end f;
 
 A z = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordOutput1",
            description="Scalarization of records in functions: record output: basic test",
            variability_propagation=false,
            inline_functions="none",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordOutput1
 Real z.y;
 Real z.x;
equation
 (RecordTests.RecordOutput1.A(z.y, z.x)) = RecordTests.RecordOutput1.f();

public
 function RecordTests.RecordOutput1.f
  output RecordTests.RecordOutput1.A o;
 algorithm
  o.y := 1;
  o.x := 2;
  return;
 end RecordTests.RecordOutput1.f;

 record RecordTests.RecordOutput1.A
  Real y;
  Real x;
 end RecordTests.RecordOutput1.A;

end RecordTests.RecordOutput1;
")})));
end RecordOutput1;


model RecordOutput2
 record A
  Real x;
  Real y;
 end A;
 
 function f
  output A o[2] = {A(1, 2), A(3, 4)};
 algorithm
 end f;
 
 A x[2] = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordOutput2",
            description="Scalarization of records in functions: record output: array of records",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordOutput2
 Real x[1].x;
 Real x[1].y;
 Real x[2].x;
 Real x[2].y;
equation
 ({RecordTests.RecordOutput2.A(x[1].x, x[1].y), RecordTests.RecordOutput2.A(x[2].x, x[2].y)}) = RecordTests.RecordOutput2.f();

public
 function RecordTests.RecordOutput2.f
  output RecordTests.RecordOutput2.A[:] o;
  RecordTests.RecordOutput2.A[:] temp_1;
 algorithm
  init o as RecordTests.RecordOutput2.A[2];
  init temp_1 as RecordTests.RecordOutput2.A[2];
  temp_1[1].x := 1;
  temp_1[1].y := 2;
  temp_1[2].x := 3;
  temp_1[2].y := 4;
  for i1 in 1:2 loop
   o[i1].x := temp_1[i1].x;
   o[i1].y := temp_1[i1].y;
  end for;
  return;
 end RecordTests.RecordOutput2.f;

 record RecordTests.RecordOutput2.A
  Real x;
  Real y;
 end RecordTests.RecordOutput2.A;

end RecordTests.RecordOutput2;
")})));
end RecordOutput2;


model RecordOutput3
 record A
  Real x[2];
  Real y[3];
 end A;
 
 function f
  output A o = A({1,2}, {3,4,5});
 algorithm
 end f;
 
 A x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordOutput3",
            description="Scalarization of records in functions: record output: record containing array",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordOutput3
 Real x.x[1];
 Real x.x[2];
 Real x.y[1];
 Real x.y[2];
 Real x.y[3];
equation
 (RecordTests.RecordOutput3.A({x.x[1], x.x[2]}, {x.y[1], x.y[2], x.y[3]})) = RecordTests.RecordOutput3.f();

public
 function RecordTests.RecordOutput3.f
  output RecordTests.RecordOutput3.A o;
  Integer[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init temp_1 as Integer[2];
  temp_1[1] := 1;
  temp_1[2] := 2;
  init temp_2 as Integer[3];
  temp_2[1] := 3;
  temp_2[2] := 4;
  temp_2[3] := 5;
  for i1 in 1:2 loop
   o.x[i1] := temp_1[i1];
  end for;
  for i1 in 1:3 loop
   o.y[i1] := temp_2[i1];
  end for;
  return;
 end RecordTests.RecordOutput3.f;

 record RecordTests.RecordOutput3.A
  Real x[2];
  Real y[3];
 end RecordTests.RecordOutput3.A;

end RecordTests.RecordOutput3;
")})));
end RecordOutput3;


model RecordOutput4
 record A
  Real x;
  Real y;
 end A;
 
 record B
  A x;
  Real y;
 end B;
 
 function f
  output B o = B(A(1, 2), 3);
 algorithm
 end f;
 
 B x = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordOutput4",
            description="Scalarization of records in functions: record output: nestled records",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordOutput4
 Real x.x.x;
 Real x.x.y;
 Real x.y;
equation
 (RecordTests.RecordOutput4.B(RecordTests.RecordOutput4.A(x.x.x, x.x.y), x.y)) = RecordTests.RecordOutput4.f();

public
 function RecordTests.RecordOutput4.f
  output RecordTests.RecordOutput4.B o;
 algorithm
  o.x.x := 1;
  o.x.y := 2;
  o.y := 3;
  return;
 end RecordTests.RecordOutput4.f;

 record RecordTests.RecordOutput4.A
  Real x;
  Real y;
 end RecordTests.RecordOutput4.A;

 record RecordTests.RecordOutput4.B
  RecordTests.RecordOutput4.A x;
  Real y;
 end RecordTests.RecordOutput4.B;

end RecordTests.RecordOutput4;
")})));
end RecordOutput4;


model RecordOutput5
    record R
        Real x;
        Real y;
    end R;

    function f
        input Real u;
        output R ry;
        output Real y;
    algorithm
        ry := R(1,2);
        y := u;
    end f;

    R ry;
    Real z;
equation
    (ry,z) = f(3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordOutput5",
            description="Test scalarization of function call equation left of record type",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordOutput5
 Real ry.x;
 Real ry.y;
 Real z;
equation
 (RecordTests.RecordOutput5.R(ry.x, ry.y), z) = RecordTests.RecordOutput5.f(3);

public
 function RecordTests.RecordOutput5.f
  input Real u;
  output RecordTests.RecordOutput5.R ry;
  output Real y;
 algorithm
  ry.x := 1;
  ry.y := 2;
  y := u;
  return;
 end RecordTests.RecordOutput5.f;

 record RecordTests.RecordOutput5.R
  Real x;
  Real y;
 end RecordTests.RecordOutput5.R;

end RecordTests.RecordOutput5;
")})));
end RecordOutput5;


model RecordOutput6
    record R
        Real x;
        Real y;
    end R;

    function f
        input R rx;
        output R ry;
    algorithm
        ry := rx;
    end f;

    R ry = f(R(5,6));
    Real u;
    Real y = 3;
equation
    y = u;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordOutput6",
            description="Test that access to record member with same name as alias variable isn't changed in alias elimination",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordOutput6
 Real ry.x;
 Real ry.y;
 Real y;
equation
 (RecordTests.RecordOutput6.R(ry.x, ry.y)) = RecordTests.RecordOutput6.f(RecordTests.RecordOutput6.R(5, 6));
 y = 3;

public
 function RecordTests.RecordOutput6.f
  input RecordTests.RecordOutput6.R rx;
  output RecordTests.RecordOutput6.R ry;
 algorithm
  ry.x := rx.x;
  ry.y := rx.y;
  return;
 end RecordTests.RecordOutput6.f;

 record RecordTests.RecordOutput6.R
  Real x;
  Real y;
 end RecordTests.RecordOutput6.R;

end RecordTests.RecordOutput6;
")})));
end RecordOutput6;



model RecordInput1
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f;
 
 Real x = f(A(1,{2,3}*{4,5}));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordInput1",
            description="Scalarization of records in functions: record input: record constructor",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordInput1
 Real x;
equation
 x = RecordTests.RecordInput1.f(RecordTests.RecordInput1.A(1, 2 * 4 + 3 * 5));

public
 function RecordTests.RecordInput1.f
  input RecordTests.RecordInput1.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput1.f;

 record RecordTests.RecordInput1.A
  Real x;
  Real y;
 end RecordTests.RecordInput1.A;

end RecordTests.RecordInput1;
")})));
end RecordInput1;


model RecordInput2
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f;
 
 A a = A(1,2);
 Real x = f(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordInput2",
            description="Scalarization of records in functions: record input:",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordInput2
 Real a.x;
 Real a.y;
 Real x;
equation
 a.x = 1;
 a.y = 2;
 x = RecordTests.RecordInput2.f(RecordTests.RecordInput2.A(a.x, a.y));

public
 function RecordTests.RecordInput2.f
  input RecordTests.RecordInput2.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput2.f;

 record RecordTests.RecordInput2.A
  Real x;
  Real y;
 end RecordTests.RecordInput2.A;

end RecordTests.RecordInput2;
")})));
end RecordInput2;

model RecordInput3
 record A
  Real x;
  Real y;
 end A;
 
 function f1
  output A o;
 algorithm
  o := A(1,2);
 end f1;
 
 function f2
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f2;
 
 Real x = f2(f1());

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordInput3",
            description="Scalarization of records in functions: record input: output from another function",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordInput3
 Real x;
equation
 x = RecordTests.RecordInput3.f2(RecordTests.RecordInput3.f1());

public
 function RecordTests.RecordInput3.f2
  input RecordTests.RecordInput3.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput3.f2;

 function RecordTests.RecordInput3.f1
  output RecordTests.RecordInput3.A o;
 algorithm
  o.x := 1;
  o.y := 2;
  return;
 end RecordTests.RecordInput3.f1;

 record RecordTests.RecordInput3.A
  Real x;
  Real y;
 end RecordTests.RecordInput3.A;

end RecordTests.RecordInput3;
")})));
end RecordInput3;


model RecordInput4
 record A
  Real x;
  Real y;
 end A;
 
 function f
  input A i[2];
  output Real o;
 algorithm
  o := i[1].x + i[2].y;
 end f;
 
 A a[2] = {A(1,2),A(3,4)};
 Real x = f(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordInput4",
            description="Scalarization of records in functions: record input: array of records",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordInput4
 Real a[1].x;
 Real a[1].y;
 Real a[2].x;
 Real a[2].y;
 Real x;
equation
 a[1].x = 1;
 a[1].y = 2;
 a[2].x = 3;
 a[2].y = 4;
 x = RecordTests.RecordInput4.f({RecordTests.RecordInput4.A(a[1].x, a[1].y), RecordTests.RecordInput4.A(a[2].x, a[2].y)});

public
 function RecordTests.RecordInput4.f
  input RecordTests.RecordInput4.A[:] i;
  output Real o;
 algorithm
  o := i[1].x + i[2].y;
  return;
 end RecordTests.RecordInput4.f;

 record RecordTests.RecordInput4.A
  Real x;
  Real y;
 end RecordTests.RecordInput4.A;

end RecordTests.RecordInput4;
")})));
end RecordInput4;


model RecordInput5
 record A
  Real x[2];
  Real y;
 end A;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.x[1] + i.y;
 end f;
 
 A a = A({1,2}, 3);
 Real x = f(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordInput5",
            description="Scalarization of records in functions: record input: record containing array",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordInput5
 Real a.x[1];
 Real a.x[2];
 Real a.y;
 Real x;
equation
 a.x[1] = 1;
 a.x[2] = 2;
 a.y = 3;
 x = RecordTests.RecordInput5.f(RecordTests.RecordInput5.A({a.x[1], a.x[2]}, a.y));

public
 function RecordTests.RecordInput5.f
  input RecordTests.RecordInput5.A i;
  output Real o;
 algorithm
  o := i.x[1] + i.y;
  return;
 end RecordTests.RecordInput5.f;

 record RecordTests.RecordInput5.A
  Real x[2];
  Real y;
 end RecordTests.RecordInput5.A;

end RecordTests.RecordInput5;
")})));
end RecordInput5;


model RecordInput6
 record A
  B z;
 end A;
 
 record B
  Real x;
  Real y;
 end B;
 
 function f
  input A i;
  output Real o;
 algorithm
  o := i.z.x + i.z.y;
 end f;
 
 A a = A(B(1,2));
 Real x = f(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordInput6",
            description="Scalarization of records in functions: record input: nestled records",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordInput6
 Real a.z.x;
 Real a.z.y;
 Real x;
equation
 a.z.x = 1;
 a.z.y = 2;
 x = RecordTests.RecordInput6.f(RecordTests.RecordInput6.A(RecordTests.RecordInput6.B(a.z.x, a.z.y)));

public
 function RecordTests.RecordInput6.f
  input RecordTests.RecordInput6.A i;
  output Real o;
 algorithm
  o := i.z.x + i.z.y;
  return;
 end RecordTests.RecordInput6.f;

 record RecordTests.RecordInput6.B
  Real x;
  Real y;
 end RecordTests.RecordInput6.B;

 record RecordTests.RecordInput6.A
  RecordTests.RecordInput6.B z;
 end RecordTests.RecordInput6.A;

end RecordTests.RecordInput6;
")})));
end RecordInput6;


model RecordInput7
 record A
  Real x;
  Real y;
 end A;
 
 function f1
  input A i;
  output Real o;
 algorithm
  o := f2(i);
 end f1;
  
 function f2
  input A i;
  output Real o;
 algorithm
  o := i.x + i.y;
 end f2;
 
 A a = A(1,2);
 Real x = f1(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordInput7",
            description="Scalarization of records in functions: record input: in functions",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordInput7
 Real a.x;
 Real a.y;
 Real x;
equation
 a.x = 1;
 a.y = 2;
 x = RecordTests.RecordInput7.f1(RecordTests.RecordInput7.A(a.x, a.y));

public
 function RecordTests.RecordInput7.f1
  input RecordTests.RecordInput7.A i;
  output Real o;
 algorithm
  o := RecordTests.RecordInput7.f2(i);
  return;
 end RecordTests.RecordInput7.f1;

 function RecordTests.RecordInput7.f2
  input RecordTests.RecordInput7.A i;
  output Real o;
 algorithm
  o := i.x + i.y;
  return;
 end RecordTests.RecordInput7.f2;

 record RecordTests.RecordInput7.A
  Real x;
  Real y;
 end RecordTests.RecordInput7.A;

end RecordTests.RecordInput7;
")})));
end RecordInput7;



model RecordParBexp1
	record R
		Real x = 1;
		Real y = 1;
	end R;
	
	parameter R[2] r = {R(3,3),R(4,6)};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParBexp1",
            description="Parameter with array-of-records type and literal binding expression",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordParBexp1
 parameter Real r[1].x = 3 /* 3 */;
 parameter Real r[1].y = 3 /* 3 */;
 parameter Real r[2].x = 4 /* 4 */;
 parameter Real r[2].y = 6 /* 6 */;
end RecordTests.RecordParBexp1;
")})));
end RecordParBexp1;



model RecordWithParam1
	record R
		parameter Real a;
		Real b;
	end R;
	
	R c(a = 1, b = 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordWithParam1",
            description="Record with independent parameter getting value from modification",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordWithParam1
 parameter Real c.a = 1 /* 1 */;
 Real c.b;
equation
 c.b = 2;
end RecordTests.RecordWithParam1;
")})));
end RecordWithParam1;


model RecordWithParam2
	record R
		parameter Real a;
		Real b;
	end R;
	
	R c(a = d, b = 2);
	parameter Real d = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordWithParam2",
            description="Record with dependent parameter getting value from modification",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordWithParam2
 parameter Real c.a;
 Real c.b;
 parameter Real d = 1 /* 1 */;
parameter equation
 c.a = d;
equation
 c.b = 2;
end RecordTests.RecordWithParam2;
")})));
end RecordWithParam2;



model RecordWithColonArray1
	record A
		Real a[:];
		Real b;
	end A;

	A c = A({1, 2, 3}, 4);
	A d = A({5, 6}, 7);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordWithColonArray1",
            description="Variable with : size in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordWithColonArray1
 Real c.a[1];
 Real c.a[2];
 Real c.a[3];
 Real c.b;
 Real d.a[1];
 Real d.a[2];
 Real d.b;
equation
 c.a[1] = 1;
 c.a[2] = 2;
 c.a[3] = 3;
 c.b = 4;
 d.a[1] = 5;
 d.a[2] = 6;
 d.b = 7;
end RecordTests.RecordWithColonArray1;
")})));
end RecordWithColonArray1;


model RecordWithColonArray2
	record A
		Real a[:];
		Real b;
	end A;

	A c;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="RecordWithColonArray2",
            description="Variable with : size without binding exp",
            variability_propagation=false,
            errorMessage="
1 errors found:

Error at line 3, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE:
  Can not infer array size of the variable a
")})));
end RecordWithColonArray2;


model RecordWithColonArray3
	record A
		Real a[:];
		Real b;
	end A;

	A c(a = {1, 2, 3}, b = 4);
	A d(a = {5, 6}, b = 7);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordWithColonArray3",
            description="Variable with : size in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordWithColonArray3
 Real c.a[1];
 Real c.a[2];
 Real c.a[3];
 Real c.b;
 Real d.a[1];
 Real d.a[2];
 Real d.b;
equation
 c.a[1] = 1;
 c.a[2] = 2;
 c.a[3] = 3;
 c.b = 4;
 d.a[1] = 5;
 d.a[2] = 6;
 d.b = 7;
end RecordTests.RecordWithColonArray3;
")})));
end RecordWithColonArray3;

model RecordWithColonArray4
    record R
        Real x[:];
    end R;
    
    function f
        input Integer n;
        output R r = R(1:n);
    algorithm
    end f;
    
    parameter Integer n = 3;
    R r = f(n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordWithColonArray4",
            description="Variable with : size in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordWithColonArray4
 structural parameter Integer n = 3 /* 3 */;
 Real r.x[1];
 Real r.x[2];
 Real r.x[3];
equation
 r.x[1] = 1; // TODO Investigate function inlining
 r.x[2] = 2;
 r.x[3] = 3;
end RecordTests.RecordWithColonArray4;
")})));
end RecordWithColonArray4;

model RecordWithColonArray5
    record R
        Real x[:];
    end R;
    
    record R2
        R r;
    end R2;
    
    function f
        input Integer n;
        output R r = R(1:n);
    algorithm
    end f;
    
    parameter Integer n = 3;
    R2[2] r2 = {R2(f(n)),R2(f(n))};
    
    model M
        R2 r2; 
    end M;
    
    M[2] m(r2=r2);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordWithColonArray5",
            description="Variable with : size in record",
            flatModel="
fclass RecordTests.RecordWithColonArray5
 structural parameter Integer n = 3 /* 3 */;
 RecordTests.RecordWithColonArray5.R2 r2[2](r(x(size() = {{3}, {3}}))) = {RecordTests.RecordWithColonArray5.R2(RecordTests.RecordWithColonArray5.f(3)), RecordTests.RecordWithColonArray5.R2(RecordTests.RecordWithColonArray5.f(3))};
 RecordTests.RecordWithColonArray5.R2 m[1].r2(r(x(size() = {3}))) = r2[1];
 RecordTests.RecordWithColonArray5.R2 m[2].r2(r(x(size() = {3}))) = r2[2];

public
 function RecordTests.RecordWithColonArray5.f
  input Integer n;
  output RecordTests.RecordWithColonArray5.R r;
 algorithm
  r := RecordTests.RecordWithColonArray5.R(1:n);
  return;
 end RecordTests.RecordWithColonArray5.f;

 record RecordTests.RecordWithColonArray5.R
  Real x[:];
 end RecordTests.RecordWithColonArray5.R;

 record RecordTests.RecordWithColonArray5.R2
  RecordTests.RecordWithColonArray5.R r;
 end RecordTests.RecordWithColonArray5.R2;

end RecordTests.RecordWithColonArray5;
")})));
end RecordWithColonArray5;

model RecordWithColonArray6
    record A
        parameter Real b;
    end A;
    
    record C
        parameter Integer n;
        A a[n](b = {i for i in 1:n});
    end C;
    
    C c(n = 2);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="RecordWithColonArray6",
        description="",
        flatModel="
fclass RecordTests.RecordWithColonArray6
 parameter RecordTests.RecordWithColonArray6.C c(n = 2,a(size() = {2},b = {1, 2}));

public
 record RecordTests.RecordWithColonArray6.A
  parameter Real b;
 end RecordTests.RecordWithColonArray6.A;

 record RecordTests.RecordWithColonArray6.C
  parameter Integer n;
  parameter RecordTests.RecordWithColonArray6.A a[n];
 end RecordTests.RecordWithColonArray6.C;

end RecordTests.RecordWithColonArray6;
")})));
end RecordWithColonArray6;


model RecordDer1
	record A
		Real x;
		Real y;
	end A;
	
	A a;
initial equation
	a = A(1, 0);
equation
	der(a.x) = -a.y;
	der(a.y) = -a.x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordDer1",
            description="der() on record members",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordDer1
 Real a.x;
 Real a.y;
initial equation
 a.x = 1;
 a.y = 0;
equation
 der(a.x) = - a.y;
 der(a.y) = - a.x;
end RecordTests.RecordDer1;
")})));
end RecordDer1;



model RecordParam1
	record A
		parameter Real x = 1;
		Real y;
	end A;
	
	A a1(y=2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParam1",
            description="Parameter with default value in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordParam1
 parameter Real a1.x = 1 /* 1 */;
 Real a1.y;
equation
 a1.y = 2;
end RecordTests.RecordParam1;
")})));
end RecordParam1;


model RecordParam2
	record A
		parameter Real x = 1;
		Real y;
	end A;
	
	A a1 = A(y=2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParam2",
            description="Parameter with default value in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordParam2
 parameter Real a1.x = 1 /* 1 */;
 Real a1.y;
equation
 a1.y = 2;
end RecordTests.RecordParam2;
")})));
end RecordParam2;


model RecordParam3
	function f
		input Real i;
		output Real[2] o = { i, -i };
	algorithm
	end f;
	
	record A
		parameter Real[2] x = f(1);
		Real y;
	end A;
	
	A a1(y=2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParam3",
            description="Parameter with default value in record",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordParam3
 parameter Real a1.x[1];
 parameter Real a1.x[2];
 Real a1.y;
parameter equation
 ({a1.x[1], a1.x[2]}) = RecordTests.RecordParam3.f(1);
equation
 a1.y = 2;

public
 function RecordTests.RecordParam3.f
  input Real i;
  output Real[:] o;
  Real[:] temp_1;
 algorithm
  init o as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := i;
  temp_1[2] := - i;
  for i1 in 1:2 loop
   o[i1] := temp_1[i1];
  end for;
  return;
 end RecordTests.RecordParam3.f;

end RecordTests.RecordParam3;
")})));
end RecordParam3;


model RecordParam4
	record A
		parameter Real x = 1;
		parameter Real z = x;
		Real y;
	end A;
	
	A a1(y=2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParam4",
            description="Parameter with default value in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordParam4
 parameter Real a1.x = 1 /* 1 */;
 parameter Real a1.z;
 Real a1.y;
parameter equation
 a1.z = a1.x;
equation
 a1.y = 2;
end RecordTests.RecordParam4;
")})));
end RecordParam4;


model RecordParam5
	record A
		parameter Real x = 2;
		parameter Real z = 3;
		Real y;
	end A;
	
	A a1 = A(y = 2, x = 1, z = a1.x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParam5",
            description="Parameter with default value in record",
            variability_propagation=false,
            flatModel="
fclass RecordTests.RecordParam5
 parameter Real a1.x = 1 /* 1 */;
 parameter Real a1.z;
 Real a1.y;
parameter equation
 a1.z = a1.x;
equation
 a1.y = 2;
end RecordTests.RecordParam5;
")})));
end RecordParam5;


model RecordParam6
	function f
		output Real[2] o = {1,2};
	algorithm
	end f;
	
	record A
		parameter Real x[2] = f();
		parameter Real y[2] = x;
	end A;
	
	A a1;
	A a2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParam6",
            description="",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordParam6
 parameter Real a1.x[1];
 parameter Real a1.x[2];
 parameter Real a2.x[1];
 parameter Real a2.x[2];
 parameter Real a1.y[1];
 parameter Real a1.y[2];
 parameter Real a2.y[1];
 parameter Real a2.y[2];
parameter equation
 ({a1.x[1], a1.x[2]}) = RecordTests.RecordParam6.f();
 ({a2.x[1], a2.x[2]}) = RecordTests.RecordParam6.f();
 a1.y[1] = a1.x[1];
 a1.y[2] = a1.x[2];
 a2.y[1] = a2.x[1];
 a2.y[2] = a2.x[2];

public
 function RecordTests.RecordParam6.f
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
 end RecordTests.RecordParam6.f;

end RecordTests.RecordParam6;
")})));
end RecordParam6;


model RecordParam7
    record A
        Integer n;
    end A;
    
    record B
        extends A;
    end B;
    
    parameter B b = B(2);
    Real x[b.n] = time * ones(b.n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordParam7",
            description="Variability calculation for records involving inheritance",
            eliminate_linear_equations=false,
            flatModel="
fclass RecordTests.RecordParam7
 structural parameter Integer b.n = 2 /* 2 */;
 Real x[1];
 Real x[2];
equation
 x[1] = time;
 x[2] = time;
end RecordTests.RecordParam7;
")})));
end RecordParam7;


model RecordParam8
    record A
        parameter Real x = 1;
        Real y;
    end A;
    
    parameter A a;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="RecordParam8",
            description="Check that extra warnings aren't generated about binding expressions for record parameters",
            errorMessage="
1 warnings found:

Warning at line 4, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter a.y does not have a binding expression
")})));
end RecordParam8;


model RecordParam9
    record A
        parameter Real x;
        Real y;
    end A;
    
    parameter A a = A(1, 2);
    parameter Real z;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="RecordParam9",
            description="Check that extra warnings aren't generated about binding expressions for record parameters, record has constuctor binding exp",
            errorMessage="
1 warnings found:

Warning at line 8, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter z does not have a binding expression
")})));
end RecordParam9;


model RecordParam10
    record A
        parameter Real x;
        Real y;
    end A;
	
	function f
		output A a;
	algorithm
		a := A(1,2);
	end f;
    
    parameter A a = f();
    parameter Real z;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="RecordParam10",
            description="Check that extra warnings aren't generated about binding expressions for record parameters, record has function call binding exp",
            errorMessage="
1 warnings found:

Warning at line 14, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/RecordTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter z does not have a binding expression
")})));
end RecordParam10;

model RecordVariability1
    record A1
        Real x1 = time + p1;
        parameter Real p1 = 1;
    end A1;
    
    record A2
        Real x2 = time + p2;
        parameter Real p2 = 2;
    end A2;
    
    record B
        A1 a1;
        A2 a2;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordVariability1",
            description="Nested composite variability calculations #4440",
            flatModel="
fclass RecordTests.RecordVariability1
 Real b.a1.x1;
 parameter Real b.a1.p1 = 1 /* 1 */;
 Real b.a2.x2;
 parameter Real b.a2.p2 = 2 /* 2 */;
equation
 b.a1.x1 = time + b.a1.p1;
 b.a2.x2 = time + b.a2.p2;
end RecordTests.RecordVariability1;
")})));
end RecordVariability1;


model RecordMerge1
    record R1
        Real x;
        Real y;
    end R1;
 
    record R2
        Real x;
        Real y;
    end R2;
 
    function F
        input R1 rin;
        output R2 rout;
    algorithm
        rout := rin;
    end F;
 
    R2 r2 = F(R1(1,2));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordMerge1",
            description="Check that equivalent records are merged",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass RecordTests.RecordMerge1
 Real r2.x;
 Real r2.y;
equation
 (RecordTests.RecordMerge1.R2(r2.x, r2.y)) = RecordTests.RecordMerge1.F(RecordTests.RecordMerge1.R2(1, 2));

public
 function RecordTests.RecordMerge1.F
  input RecordTests.RecordMerge1.R2 rin;
  output RecordTests.RecordMerge1.R2 rout;
 algorithm
  rout.x := rin.x;
  rout.y := rin.y;
  return;
 end RecordTests.RecordMerge1.F;

 record RecordTests.RecordMerge1.R2
  Real x;
  Real y;
 end RecordTests.RecordMerge1.R2;

end RecordTests.RecordMerge1;
")})));
end RecordMerge1;


model RecordMerge2
    record C
        Real a;
    end C;
    
    record B
        C b;
        Real c;
    end B;
    
    record A
        Real a;
    end A;
    
    B b = B(C(time), time + 1);
    C c = A(time);
    

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordMerge2",
            description="",
            flatModel="
fclass RecordTests.RecordMerge2
 Real b.c;
 Real c.a;
equation
 c.a = time;
 b.c = time + 1;
end RecordTests.RecordMerge2;
")})));
end RecordMerge2;


model RecordEval1
    record A
        Real x;
        Real y;
    end A;
    
    parameter A a(x = 1, y = 2);
    
    Real z[2] = { i * time for i in a.x:a.y };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordEval1",
            description="Test that evaluation before scalarization of record variable without binding expression works",
            flatModel="
fclass RecordTests.RecordEval1
 structural parameter Real a.x = 1 /* 1 */;
 structural parameter Real a.y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * z[1];
end RecordTests.RecordEval1;
")})));
end RecordEval1;


model RecordEval2
    record A
        Real x = 1;
        Real y = 2;
    end A;
    
    parameter A a;
    
    Real z[2] = { i * time for i in a.x:a.y };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordEval2",
            description="Test that evaluation before scalarization of record variable without binding expression works",
            flatModel="
fclass RecordTests.RecordEval2
 structural parameter Real a.x = 1 /* 1 */;
 structural parameter Real a.y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * z[1];
end RecordTests.RecordEval2;
")})));
end RecordEval2;


model RecordEval3
    record A
        Real x;
        Real y;
    end A;
    
    parameter A a[2](x = {1, 3}, each y = 2);
    
    Real z[2] = { i * time for i in a[1].x:a[2].y };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordEval3",
            description="Test that evaluation before scalarization of record variable without binding expression works",
            flatModel="
fclass RecordTests.RecordEval3
 parameter Real a[1].x = 1 /* 1 */;
 parameter Real a[1].y = 2 /* 2 */;
 parameter Real a[2].x = 3 /* 3 */;
 parameter Real a[2].y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * z[1];
end RecordTests.RecordEval3;
")})));
end RecordEval3;


model RecordEval4
    record A
        Real x = 1;
        Real y = 2;
    end A;
    
    parameter A a[2];
    
    Real z[2] = { i * time for i in a[1].x:a[2].y };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordEval4",
            description="Test that evaluation before scalarization of record variable without binding expression works",
            flatModel="
fclass RecordTests.RecordEval4
 parameter Real a[1].x = 1 /* 1 */;
 parameter Real a[1].y = 2 /* 2 */;
 parameter Real a[2].x = 1 /* 1 */;
 parameter Real a[2].y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * z[1];
end RecordTests.RecordEval4;
")})));
end RecordEval4;


model RecordEval5
    record A
        Real x[2];
        Real y = 2;
    end A;
	
	record B
		A a[2];
	end B;
    
    parameter B b[2](a(x = {{{1,2},{3,4}},{{5,6},{7,8}}}));
    
    Real z[2] = { i * time for i in b[1].a[1].x[1]:b[2].a[2].y };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordEval5",
            description="Test that evaluation before scalarization of record variable without binding expression works",
            flatModel="
fclass RecordTests.RecordEval5
 parameter Real b[1].a[1].x[1] = 1 /* 1 */;
 parameter Real b[1].a[1].x[2] = 2 /* 2 */;
 parameter Real b[1].a[1].y = 2 /* 2 */;
 parameter Real b[1].a[2].x[1] = 3 /* 3 */;
 parameter Real b[1].a[2].x[2] = 4 /* 4 */;
 parameter Real b[1].a[2].y = 2 /* 2 */;
 parameter Real b[2].a[1].x[1] = 5 /* 5 */;
 parameter Real b[2].a[1].x[2] = 6 /* 6 */;
 parameter Real b[2].a[1].y = 2 /* 2 */;
 parameter Real b[2].a[2].x[1] = 7 /* 7 */;
 parameter Real b[2].a[2].x[2] = 8 /* 8 */;
 parameter Real b[2].a[2].y = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 z[1] = time;
 z[2] = 2 * z[1];
end RecordTests.RecordEval5;
")})));
end RecordEval5;

model RecordEval6
    record R
        parameter Integer n1 = 1;
        Real x;
    end R;
    R r(n1 = n2, x = time);
    parameter Integer n2 = 2;
    Real y[n2] = ones(n2) * time;
    Real z = y * (1:r.n1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordEval6",
            description="Test that evaluation before scalarization of record variable works",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass RecordTests.RecordEval6
 structural parameter Integer r.n1 = 2 /* 2 */;
 Real r.x;
 structural parameter Integer n2 = 2 /* 2 */;
 Real y[1];
 Real y[2];
 Real z;
equation
 r.x = time;
 y[1] = time;
 y[2] = time;
 z = y[1] + y[2] * 2;
end RecordTests.RecordEval6;
")})));
end RecordEval6;

model RecordEval7
  record B
    parameter Real x;
    parameter Real y = x + 1;
    parameter Integer n;
  end B;
  
  record SB
    extends B(final n = 1);
  end SB;
  
  record A
    parameter Real x;
    SB b(final n = 2);
  end A;
  
  A a1(x=3);
  B b1 = a1.b;
  Real x;
equation
  x = b1.n;
  
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordEval7",
            description="Test that evaluation before scalarization of record variable works",
            flatModel="
fclass RecordTests.RecordEval7
 parameter RecordTests.RecordEval7.A a1(x = 3,b(y = a1.b.x + 1,n = 2));
 parameter RecordTests.RecordEval7.B b1 = a1.b;
 Real x;
equation
 x = 2;

public
 record RecordTests.RecordEval7.SB
  parameter Real x;
  parameter Real y;
  parameter Integer n;
 end RecordTests.RecordEval7.SB;

 record RecordTests.RecordEval7.A
  parameter Real x;
  parameter RecordTests.RecordEval7.SB b;
 end RecordTests.RecordEval7.A;

 record RecordTests.RecordEval7.B
  parameter Real x;
  parameter Real y;
  parameter Integer n;
 end RecordTests.RecordEval7.B;

end RecordTests.RecordEval7;
")})));
end RecordEval7;

model RecordEval8
    record R2
        function f1
            Real t = 0;
            output Real x = t;
            algorithm
        end f1;
        function f2
            extends f1;
        end f2;
        constant Real x = f2();
    end R2;
    
    record R3
        extends R2;
    end R3;
    
    R3 r3;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordEval8",
            description="Test bug in #5153",
            flatModel="
fclass RecordTests.RecordEval8
 constant RecordTests.RecordEval8.R3 r3 = RecordTests.RecordEval8.R3(0);

public
 function RecordTests.RecordEval8.r3.f2
  Real t;
  output Real x;
 algorithm
  t := 0;
  x := t;
  return;
 end RecordTests.RecordEval8.r3.f2;

 record RecordTests.RecordEval8.R3
  constant Real x;
 end RecordTests.RecordEval8.R3;

end RecordTests.RecordEval8;
")})));
end RecordEval8;

model RecordModification1
  record R
    Real x;
  end R;

  Real y = time;
  R z(x = y + 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordModification1",
            description="Modification on record with continuous variability",
            flatModel="
fclass RecordTests.RecordModification1
 Real y;
 Real z.x;
equation
 y = time;
 z.x = y + 2;
end RecordTests.RecordModification1;
")})));
end RecordModification1;

model RecordModification2
    record A
        Real x = 1;
        Real y = 2;
    end A;
    
    parameter A[2] a1;
    parameter A[2] a2 = a1;
    parameter A[2] a3(each x = 3);
    parameter A[2] a4(x = {4,5});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordModification2",
            description="Modification on record array",
            flatModel="
fclass RecordTests.RecordModification2
 parameter Real a1[1].x = 1 /* 1 */;
 parameter Real a1[1].y = 2 /* 2 */;
 parameter Real a1[2].x = 1 /* 1 */;
 parameter Real a1[2].y = 2 /* 2 */;
 parameter Real a2[1].x;
 parameter Real a2[1].y;
 parameter Real a2[2].x;
 parameter Real a2[2].y;
 parameter Real a3[1].x = 3 /* 3 */;
 parameter Real a3[1].y = 2 /* 2 */;
 parameter Real a3[2].x = 3 /* 3 */;
 parameter Real a3[2].y = 2 /* 2 */;
 parameter Real a4[1].x = 4 /* 4 */;
 parameter Real a4[1].y = 2 /* 2 */;
 parameter Real a4[2].x = 5 /* 5 */;
 parameter Real a4[2].y = 2 /* 2 */;
parameter equation
 a2[1].x = a1[1].x;
 a2[1].y = a1[1].y;
 a2[2].x = a1[2].x;
 a2[2].y = a1[2].y;
end RecordTests.RecordModification2;
")})));
end RecordModification2;

model RecordModification3
    record RA
        RB[2] b(each x = 5:6);
    end RA;
    
    record RB
        Real[2] x;
    end RB;
    
    RA[2] a1(each b(x=1:2));
    RA[2] a2(b(each x=3:4));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordModification3",
            description="Modification on record array",
            eliminate_alias_variables=false,
            flatModel="
fclass RecordTests.RecordModification3
 constant Real a1[1].b[1].x[1] = 1;
 constant Real a1[1].b[1].x[2] = 2;
 constant Real a1[1].b[2].x[1] = 1;
 constant Real a1[1].b[2].x[2] = 2;
 constant Real a1[2].b[1].x[1] = 1;
 constant Real a1[2].b[1].x[2] = 2;
 constant Real a1[2].b[2].x[1] = 1;
 constant Real a1[2].b[2].x[2] = 2;
 constant Real a2[1].b[1].x[1] = 3;
 constant Real a2[1].b[1].x[2] = 4;
 constant Real a2[1].b[2].x[1] = 3;
 constant Real a2[1].b[2].x[2] = 4;
 constant Real a2[2].b[1].x[1] = 3;
 constant Real a2[2].b[1].x[2] = 4;
 constant Real a2[2].b[2].x[1] = 3;
 constant Real a2[2].b[2].x[2] = 4;
end RecordTests.RecordModification3;
")})));
end RecordModification3;

model RecordModification4
record R
        parameter Real a=b*c;
        parameter Real b;
        parameter Real c;
end R;

R r[2](each b=2, c={3,2});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordModification4",
            description="Test bug in #5275",
            flatModel="
fclass RecordTests.RecordModification4
 parameter RecordTests.RecordModification4.R r[2](a = {r[1].b * r[1].c, r[2].b * r[2].c},b = {2, 2},c = {3, 2});

public
 record RecordTests.RecordModification4.R
  parameter Real a;
  parameter Real b;
  parameter Real c;
 end RecordTests.RecordModification4.R;

end RecordTests.RecordModification4;
")})));
end RecordModification4;

model RecordConnector1
    record A
        Real x;
        Real y;
    end A;

    connector B = A;
    
    B b;
equation
    b = B(time, 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordConnector1",
            description="Check that class can be both record and connector",
            flatModel="
fclass RecordTests.RecordConnector1
 RecordTests.RecordConnector1.B b;
equation
 b = RecordTests.RecordConnector1.B(time, 2);

public
 record RecordTests.RecordConnector1.B
  Real x;
  Real y;
 end RecordTests.RecordConnector1.B;

end RecordTests.RecordConnector1;
")})));
end RecordConnector1;


model ExternalObjectStructural1
    class A
        extends ExternalObject;
        
        function constructor
            input String b;
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
        output Real b;
        external;
    end f;
    
    parameter String b = "abc" annotation(Evaluate=true);
    parameter A a = A(b);
    parameter Real c = f(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExternalObjectStructural1",
            description="Check that external objects do not get converted to structural parameters",
            flatModel="
fclass RecordTests.ExternalObjectStructural1
 eval parameter String b = \"abc\" /* \"abc\" */;
 parameter RecordTests.ExternalObjectStructural1.A a = RecordTests.ExternalObjectStructural1.A.constructor(\"abc\") /* {\"abc\"} */;
 parameter Real c;
parameter equation
 c = RecordTests.ExternalObjectStructural1.f(a);

public
 function RecordTests.ExternalObjectStructural1.A.destructor
  input RecordTests.ExternalObjectStructural1.A a;
 algorithm
  external \"C\" destructor(a);
  return;
 end RecordTests.ExternalObjectStructural1.A.destructor;

 function RecordTests.ExternalObjectStructural1.A.constructor
  input String b;
  output RecordTests.ExternalObjectStructural1.A a;
 algorithm
  external \"C\" a = constructor(b);
  return;
 end RecordTests.ExternalObjectStructural1.A.constructor;

 function RecordTests.ExternalObjectStructural1.f
  input RecordTests.ExternalObjectStructural1.A a;
  output Real b;
 algorithm
  external \"C\" b = f(a);
  return;
 end RecordTests.ExternalObjectStructural1.f;

 type RecordTests.ExternalObjectStructural1.A = ExternalObject;
end RecordTests.ExternalObjectStructural1;
")})));
end ExternalObjectStructural1;



end RecordTests;
