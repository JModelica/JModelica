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


package ModificationTests 

class ModTest1
  parameter Real y = 4;
  Real z(unit="m") = y;
  Real x;
equation
  x=4;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest1",
			description="Test of Real attribute \"unit\".",
			flatModel="
fclass ModificationTests.ModTest1
 parameter Real y=4;
 Real z(unit=\"m\")=y;
 Real x;
equation 
 x=4;
end ModificationTests.ModTest1;
")})));
end ModTest1;

class ModTest2
  class C1
    parameter Real a;
  end C1;
  
  class C2
    parameter Real b,c;
  end C2;
  
  class C3
    parameter Real x1;
    parameter Real x2 = 2;
    parameter C1 x3;
    parameter C2 x4(b=4);
    parameter C1 x5(a=5);
    extends C1;
    extends C2(b=6,c=77);
  end C3;
  
  class C4
    extends C3(x2=22, x3(a=33), x4(c=44), a=55, b=66);
  end C4;
  C4 c4;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest2",
			description="Merging of modifications",
			flatModel="  fclass ModificationTests.ModTest2
 parameter Real c4.x1;
 parameter Real c4.x2=22;
 parameter Real c4.x3.a=33;
 parameter Real c4.x4.b=4;
 parameter Real c4.x4.c=44;
 parameter Real c4.x5.a=5;
 parameter Real c4.a=55;
 parameter Real c4.b=66;
 parameter Real c4.c=77;
end ModificationTests.ModTest2;
")})));
end ModTest2;

class ModTest3
  
  class C
    Real x=3;
  end C;
  
  C c(x=5);
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest3",
			description="Simple modification test",
			flatModel="
fclass ModificationTests.ModTest3
 Real c.x=5;
end ModificationTests.ModTest3;
")})));
end ModTest3;

class ModTest5
  
  
  parameter Real p=3;
  Real y(start=p)=5;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest5",
			description="Test of start-attribute",
			flatModel=" fclass ModificationTests.ModTest5
 parameter Real p=3;
 Real y(start=p)=5;
end ModificationTests.ModTest5;
")})));
end ModTest5;

class ModTest6
class C1
 Real x;
end C1;

class C2
  parameter Real p(nominal=4)=3;
  C1 c1 (x(min=p)=5);
end C2;

C2 c2;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest6",
			description="Test merging of modifications",
			flatModel=" fclass ModificationTests.ModTest6
 parameter Real c2.p(nominal=4)=3;
 Real c2.c1.x(min=c2.p)=5;
end ModificationTests.ModTest6;
")})));
end ModTest6;

class ModTest7 
  Real x=3;
  class C2 
    Real y;
    class C3 
      Real z(nominal=1)=1;
    end C3;
    C3 c3(z(nominal=2)=3);
  end C2;
  C2 c2(c3.z(max=4)=5, y=3);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest7",
			description="Test merging of attributes",
			flatModel="
fclass ModificationTests.ModTest7
 Real x=3;
 Real c2.y=3;
 Real c2.c3.z(max=4,nominal=2)=5;
end ModificationTests.ModTest7;
")})));
end ModTest7;


class ModTest8
class C1
 Real x;
end C1;

class C2
  extends C1(x=4);
  C1 c1(x=6);
end C2;

class C3

	extends C2(x=c1.x,c1(x=44));  
  
end C3;
C3 c3;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest8",
			description="Merging of modifications in extends clauses",
			flatModel="
fclass ModificationTests.ModTest8
 Real c3.c1.x=44;
 Real c3.x=c3.c1.x;
end ModificationTests.ModTest8;
")})));
end ModTest8;

class ModTest9
  
class C1
 Real x;
end C1;

class C2
  extends C1(x(unit="qwe",start=3.0)=4);
  C1 c1(x(start=2,quantity="qwe")=6);
end C2;

class C3
	extends C2(x(quantity="qqq",unit="m2",displayUnit="m22",start=4.2,
	             min=4.1,max=9.0,nominal=0.2)=55,c1(x=44));  
  
end C3;

C3 c3;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest9",
			description="Test of attributes of Real",
			flatModel="
fclass ModificationTests.ModTest9
 Real c3.c1.x(start=2,quantity=\"qwe\")=44;
 Real c3.x(quantity=\"qqq\",unit=\"m2\",displayUnit=\"m22\",start=4.2,min=4.1,max=9.0,nominal=0.2)=55;
end ModificationTests.ModTest9;
")})));
end ModTest9;

class ModTest10
  parameter Real A=2;
  
	class C2
	  parameter Real B=1;
	  Real x=B;
	end C2;
  
  C2 c2a;
  C2 c2b(x=A);
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest10",
			description="Test of parameter-prefix in modifications.",
			flatModel="
fclass ModificationTests.ModTest10
 parameter Real A=2;
 parameter Real c2a.B=1;
 Real c2a.x=c2a.B;
 parameter Real c2b.B=1;
 Real c2b.x=A;
end ModificationTests.ModTest10;
")})));
end ModTest10;

class ModTest11
  class C2
    
    class C3
      
      class C4
        Real z=2;
        Real x=3;
      end C4;
    
      C4 c4a,c4b;
    
    end C3;
  	
  	C3 c3(c4a.z=6);
  	
  end C2;
  
  C2 c2(c3.c4a.x=4,c3.c4b.x=10);
  extends C2(c3.c4a.x=5,c3.c4b.z=8);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest11",
			description="Additional merging tests",
			flatModel=" fclass ModificationTests.ModTest11
 Real c2.c3.c4a.z=6;
 Real c2.c3.c4a.x=4;
 Real c2.c3.c4b.z=2;
 Real c2.c3.c4b.x=10;
 Real c3.c4a.z=6;
 Real c3.c4a.x=5;
 Real c3.c4b.z=8;
 Real c3.c4b.x=3;
end ModificationTests.ModTest11;
")})));
end ModTest11;
 
 model ModTest_PM_12
  
  extends C2(c3(c4a(x=5)),c3.c4b.z=a);
  //extends C2(c3.c4b.z=a);
  
  model C2
    
    model C3
      
      model C4
        Real z=2;
        Real x=3; 
        Real w=3;
      end C4;
    
        Real b=5;
    
      C4 c4a;
      C4 c4b(x=b); 
    
    end C3;
        
        C3 c3(c4a.z=6);
        
  end C2;
  
  Real a;
  
  C2 c0;
  C2 c2(c3.c4a.x=a,c3.c4b.x=c3.b,c3(c4a(w=6,z=9)));
  

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest12",
			description="Additional merging tests",
			flatModel="
fclass ModificationTests.ModTest_PM_12
 Real a;
 Real c0.c3.b=5;
 Real c0.c3.c4a.z=6;
 Real c0.c3.c4a.x=3;
 Real c0.c3.c4a.w=3;
 Real c0.c3.c4b.z=2;
 Real c0.c3.c4b.x=c0.c3.b;
 Real c0.c3.c4b.w=3;
 Real c2.c3.b=5;
 Real c2.c3.c4a.z=9;
 Real c2.c3.c4a.x=a;
 Real c2.c3.c4a.w=6;
 Real c2.c3.c4b.z=2;
 Real c2.c3.c4b.x=c3.b;
 Real c2.c3.c4b.w=3;
 Real c3.b=5;
 Real c3.c4a.z=6;
 Real c3.c4a.x=5;
 Real c3.c4a.w=3;
 Real c3.c4b.z=a;
 Real c3.c4b.x=c3.b;
 Real c3.c4b.w=3;
end ModificationTests.ModTest_PM_12;
")})));
end ModTest_PM_12;
 
model ModTest13_Err
  model A
    Real x=2;
  end A;

  A a(y=3);


    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ModTest13_Err",
            description="Test of lookup errors in modifications",
            errorMessage="
1 errors found:

Error at line 6, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo':
  Cannot find component declaration for y
")})));
end ModTest13_Err;
 
model ModTest14_Err
  model A
    Real x=2;
  end A;

  extends A(y=3);


    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ModTest14_Err",
            description="Test of lookup errors in modifications",
            errorMessage="
1 errors found:

Error at line 6, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo':
  Cannot find component declaration for y
")})));
end ModTest14_Err;

model ModTest15_Err
  model A
   Real x=4;
    Real y=5;
  end A;
  
  model B
    extends A;
  end B;
  
  model C
    extends B(x=5,z=4);
  end C;
  
  extends C(y=3);


    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ModTest15_Err",
            description="Test of lookup errors in modifications",
            errorMessage="
1 errors found:

Error at line 12, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo':
  Cannot find component declaration for z
")})));
end ModTest15_Err;


model ModTest16
    model A
        Real x;
    end A;
    
    model B
        A a[2];
    end B;
    
    extends B(a(x(start={1,2})));

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ModTest16",
			description="Modification on member of array in extends directly in compiled model",
			flatModel="
fclass ModificationTests.ModTest16
 Real a[1].x(start = 1);
 Real a[2].x(start = 2);
end ModificationTests.ModTest16;
")})));
end ModTest16;


record ModTest17

    partial record R
        parameter Real a[:, :]=[1,2;2,3];
    end R;
    
    extends R(a=[1,2,3]);

    annotation(__JModelica(UnitTesting(tests={
        NoWarningsTestCase(
            name="ModTest17",
            description="Tests that no warning is produced for erroneous each on modifier, #5724"
    )})));
end ModTest17;



model ShortClassDeclModTest1
  model A
    Real x=2;
  end A;
  
  model AA=A;
  
  AA aa(x=3);


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclModTest1",
			description="Test simple use of short class declaration and modification.",
			flatModel="
fclass ModificationTests.ShortClassDeclModTest1
 Real aa.x=3;

end ModificationTests.ShortClassDeclModTest1;
")})));
end ShortClassDeclModTest1;

 model ShortClassDeclModTest2
  model A
    Real x=2;
  end A;
  
  model AA=A(x=2.5);
  
  AA aa;


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclModTest2",
			description="Test simple use of short class declaration and modification.",
			flatModel="
fclass ModificationTests.ShortClassDeclModTest2
 Real aa.x=2.5;

end ModificationTests.ShortClassDeclModTest2;
")})));
end ShortClassDeclModTest2;

model ShortClassDeclModTest3
  model A
    Real x=2;
  end A;
  
  model AA=A(x=2.5);
  
  AA aa(x=3);


	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ShortClassDeclModTest3",
			description="Test simple use of short class declaration and modification.",
			flatModel="
fclass ModificationTests.ShortClassDeclModTest3
 Real aa.x=3;

end ModificationTests.ShortClassDeclModTest3;
")})));
end ShortClassDeclModTest3;



model ArrayModifications1
 Real a[3](each start=3) = zeros(3);
 Real b[3](start={1,2,3}) = zeros(3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications1",
			description="Modifications to arrays: array attributes",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications1
 constant Real a[1](start = 3) = 0;
 constant Real a[2](start = 3) = 0;
 constant Real a[3](start = 3) = 0;
 constant Real b[1](start = 1) = 0;
 constant Real b[2](start = 2) = 0;
 constant Real b[3](start = 3) = 0;
end ModificationTests.ArrayModifications1;
")})));
end ArrayModifications1;


model ArrayModifications2
 Real a(each start=3) = 0;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications2",
            description="Modifications to arrays: [](start=[])",
            errorMessage="
1 warning found:

Warning at line 2, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', EACH_APPLIED_ON_SCALAR:
  The 'each' keyword should not be applied to a modification of a scalar component: each start = 3
")})));
end ArrayModifications2;


model ArrayModifications3
 Real b[3](start={1,2,3,4}) = zeros(3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications3",
            description="Modifications to arrays: [3](start=[4])",
            errorMessage="
1 errors found:

Error at line 2, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION:
  Array size mismatch in modification of the attribute start for the variable b, expected size is [3] and size of start expression is [4]
")})));
end ArrayModifications3;


model ArrayModifications4
 Real a[3](each start={1,2}) = zeros(3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications4",
            description="Modifications to arrays: [3](each start=[2])",
            errorMessage="
1 errors found:

Error at line 2, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION_DUE_TO_EACH:
  Array size mismatch in modification of the attribute start for the variable a, expected size is (due to 'each') scalar and size of start expression is [2]
")})));
end ArrayModifications4;


model ArrayModifications5
 model B
  Real x[3];
  Real y[3];
 end B;
 
 B b[2](x={{1,2,3},{4,5,6}}, each y={10,20,30});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications5",
			description="Modifications to arrays: members that are arrays",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications5
 constant Real b[1].x[1] = 1;
 constant Real b[1].x[2] = 2;
 constant Real b[1].x[3] = 3;
 constant Real b[1].y[1] = 10;
 constant Real b[1].y[2] = 20;
 constant Real b[1].y[3] = 30;
 constant Real b[2].x[1] = 4;
 constant Real b[2].x[2] = 5;
 constant Real b[2].x[3] = 6;
 constant Real b[2].y[1] = 10;
 constant Real b[2].y[2] = 20;
 constant Real b[2].y[3] = 30;
end ModificationTests.ArrayModifications5;
")})));
end ArrayModifications5;


model ArrayModifications6
 model B
  Real x[3];
 end B;
 
 B b(x={1,2,3,4});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications6",
            description="Modifications to arrays: [3] = [4]",
            errorMessage="
1 errors found:

Error at line 6, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION:
  Array size mismatch in modification of x, expected size is [3] and size of binding expression is [4]
")})));
end ArrayModifications6;


model ArrayModifications7
 model B
  Real y;
 end B;
 
 B b(each y=2);

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications7",
            description="Modifications to arrays: each [] = []",
            errorMessage="
1 warnings found:

Warning at line 6, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', EACH_APPLIED_ON_SCALAR:
  The 'each' keyword should not be applied to a modification of a scalar component: each y = 2
")})));
end ArrayModifications7;


model ArrayModifications8
 model C
  Real x[2];
 end C;
 
 model B
  C y[2];
  Real x[2];
 end B;
 
 B x[2](y(each x={1,2}), x={{10,20},{30,40}});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications8",
			description="Modifications to arrays: arrays of composites: same name on different levels",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications8
 constant Real x[1].y[1].x[1] = 1;
 constant Real x[1].y[1].x[2] = 2;
 constant Real x[1].y[2].x[1] = 1;
 constant Real x[1].y[2].x[2] = 2;
 constant Real x[1].x[1] = 10;
 constant Real x[1].x[2] = 20;
 constant Real x[2].y[1].x[1] = 1;
 constant Real x[2].y[1].x[2] = 2;
 constant Real x[2].y[2].x[1] = 1;
 constant Real x[2].y[2].x[2] = 2;
 constant Real x[2].x[1] = 30;
 constant Real x[2].x[2] = 40;
end ModificationTests.ArrayModifications8;
")})));
end ArrayModifications8;


model ArrayModifications9
 model C
  Real x[2] = zeros(2);
 end C;
 
 model B
  C y[2];
  Real x[2] = zeros(2);
 end B;
 
 B x[2](y(x(each start=1)), x(start={{10,20},{30,40}}));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications9",
			description="Modifications to arrays: arrays of composites: same name on different levels, attribute",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications9
 constant Real x[1].y[1].x[1](start = 1) = 0;
 constant Real x[1].y[1].x[2](start = 1) = 0;
 constant Real x[1].y[2].x[1](start = 1) = 0;
 constant Real x[1].y[2].x[2](start = 1) = 0;
 constant Real x[1].x[1](start = 10) = 0;
 constant Real x[1].x[2](start = 20) = 0;
 constant Real x[2].y[1].x[1](start = 1) = 0;
 constant Real x[2].y[1].x[2](start = 1) = 0;
 constant Real x[2].y[2].x[1](start = 1) = 0;
 constant Real x[2].y[2].x[2](start = 1) = 0;
 constant Real x[2].x[1](start = 30) = 0;
 constant Real x[2].x[2](start = 40) = 0;
end ModificationTests.ArrayModifications9;
")})));
end ArrayModifications9;


model ArrayModifications10
 model C
  Real z[3];
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2](y(z={{{1,2,3},{4,5,6}},{{7,8,9},{10,11,12}}}));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications10",
			description="Modifications to arrays: arrays of composites: 3 levels deep, literal modifier on outer",
			flatModel="
fclass ModificationTests.ArrayModifications10
 constant Real x[1].y[1].z[1] = 1;
 constant Real x[1].y[1].z[2] = 2;
 constant Real x[1].y[1].z[3] = 3;
 constant Real x[1].y[2].z[1] = 4;
 constant Real x[1].y[2].z[2] = 5;
 constant Real x[1].y[2].z[3] = 6;
 constant Real x[2].y[1].z[1] = 7;
 constant Real x[2].y[1].z[2] = 8;
 constant Real x[2].y[1].z[3] = 9;
 constant Real x[2].y[2].z[1] = 10;
 constant Real x[2].y[2].z[2] = 11;
 constant Real x[2].y[2].z[3] = 12;
end ModificationTests.ArrayModifications10;
")})));
end ArrayModifications10;


model ArrayModifications11
 model C
  Real z[3] = zeros(3);
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2](y(z(start={{{1,2,3},{4,5,6}},{{7,8,9},{10,11,12}}})));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications11",
			description="Modifications to arrays: arrays of composites: 3 levels deep, literal attribute on outer",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications11
 constant Real x[1].y[1].z[1](start = 1) = 0;
 constant Real x[1].y[1].z[2](start = 2) = 0;
 constant Real x[1].y[1].z[3](start = 3) = 0;
 constant Real x[1].y[2].z[1](start = 4) = 0;
 constant Real x[1].y[2].z[2](start = 5) = 0;
 constant Real x[1].y[2].z[3](start = 6) = 0;
 constant Real x[2].y[1].z[1](start = 7) = 0;
 constant Real x[2].y[1].z[2](start = 8) = 0;
 constant Real x[2].y[1].z[3](start = 9) = 0;
 constant Real x[2].y[2].z[1](start = 10) = 0;
 constant Real x[2].y[2].z[2](start = 11) = 0;
 constant Real x[2].y[2].z[3](start = 12) = 0;
end ModificationTests.ArrayModifications11;
")})));
end ArrayModifications11;


model ArrayModifications12
 model C
  Real zc[3];
 end C;
 
 model B
  C yb[2];
 end B;
 
 B xa[2](yb(zc=ya));
 Real ya[2,2,3] = {{{1,2,3},{4,5,6}},{{7,8,9},{10,11,12}}};

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayModifications12",
			description="Modifications to arrays: arrays of composites: 3 levels deep, component modifier on outer",
			flatModel="
fclass ModificationTests.ArrayModifications12
 Real xa[1].yb[1].zc[3] = ya[1,1,1:3];
 Real xa[1].yb[2].zc[3] = ya[1,2,1:3];
 Real xa[2].yb[1].zc[3] = ya[2,1,1:3];
 Real xa[2].yb[2].zc[3] = ya[2,2,1:3];
 Real ya[2,2,3] = {{{1,2,3},{4,5,6}},{{7,8,9},{10,11,12}}};

end ModificationTests.ArrayModifications12;
")})));
end ArrayModifications12;


model ArrayModifications13
 model C
  Real zc[3] = zeros(3);
 end C;
 
 model B
  C yb[2];
 end B;
 
 B xa[2](yb(zc(start=za)));
 constant Real za[2,2,3] = {{{1,2,3},{4,5,6}},{{7,8,9},{10,11,12}}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications13",
			description="Modifications to arrays: arrays of composites: 3 levels deep, attribute modifier on outer",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications13
 constant Real xa[1].yb[1].zc[1](start = 1.0) = 0;
 constant Real xa[1].yb[1].zc[2](start = 2.0) = 0;
 constant Real xa[1].yb[1].zc[3](start = 3.0) = 0;
 constant Real xa[1].yb[2].zc[1](start = 4.0) = 0;
 constant Real xa[1].yb[2].zc[2](start = 5.0) = 0;
 constant Real xa[1].yb[2].zc[3](start = 6.0) = 0;
 constant Real xa[2].yb[1].zc[1](start = 7.0) = 0;
 constant Real xa[2].yb[1].zc[2](start = 8.0) = 0;
 constant Real xa[2].yb[1].zc[3](start = 9.0) = 0;
 constant Real xa[2].yb[2].zc[1](start = 10.0) = 0;
 constant Real xa[2].yb[2].zc[2](start = 11.0) = 0;
 constant Real xa[2].yb[2].zc[3](start = 12.0) = 0;
 constant Real za[1,1,1] = 1;
 constant Real za[1,1,2] = 2;
 constant Real za[1,1,3] = 3;
 constant Real za[1,2,1] = 4;
 constant Real za[1,2,2] = 5;
 constant Real za[1,2,3] = 6;
 constant Real za[2,1,1] = 7;
 constant Real za[2,1,2] = 8;
 constant Real za[2,1,3] = 9;
 constant Real za[2,2,1] = 10;
 constant Real za[2,2,2] = 11;
 constant Real za[2,2,3] = 12;
end ModificationTests.ArrayModifications13;
")})));
end ArrayModifications13;


model ArrayModifications14
 model B
  Real yb[2];
 end B;
 
 B x[2](yb={{1,2},{3,4}}*{{10,20},{30,40}});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications14",
			description="Modifications to arrays: arrays of composites: array expression modifier on outer level",
			flatModel="
fclass ModificationTests.ArrayModifications14
 constant Real x[1].yb[1] = 70;
 constant Real x[1].yb[2] = 100;
 constant Real x[2].yb[1] = 150;
 constant Real x[2].yb[2] = 220;
end ModificationTests.ArrayModifications14;
")})));
end ArrayModifications14;


model ArrayModifications15
 model B
  Real yb[2];
 end B;
 
 B x[2](yb=y*z);
 Real y[2,2] = {{1,2},{3,4}};
 Real z[2,2] = {{10,20},{30,40}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications15",
			description="Modifications to arrays: arrays of composites: array expression modifier on outer level",
			flatModel="
fclass ModificationTests.ArrayModifications15
 constant Real x[1].yb[1] = 70.0;
 constant Real x[1].yb[2] = 100.0;
 constant Real x[2].yb[1] = 150.0;
 constant Real x[2].yb[2] = 220.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
 constant Real z[1,1] = 10;
 constant Real z[1,2] = 20;
 constant Real z[2,1] = 30;
 constant Real z[2,2] = 40;
end ModificationTests.ArrayModifications15;
")})));
end ArrayModifications15;


model ArrayModifications16
 model C
  Real x[2];
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2](y(each x=1));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications16",
            description="Modifications to arrays: arrays of composites: bad size for 'each'",
            errorMessage="
1 errors found:

Error at line 10, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION_DUE_TO_EACH:
  Array size mismatch in modification of x, expected size is (due to 'each') [2] and size of binding expression is scalar
")})));
end ArrayModifications16;


model ArrayModifications17
 model C
  Real x[2];
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2](y(each x={1,2,3}));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications17",
            description="Modifications to arrays: arrays of composites: bad size for 'each'",
            errorMessage="
1 errors found:

Error at line 10, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION_DUE_TO_EACH:
  Array size mismatch in modification of x, expected size is (due to 'each') [2] and size of binding expression is [3]
")})));
end ArrayModifications17;


model ArrayModifications18
 model C
  Real x[2] = zeros(2);
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2](y(x(each start={1,2})));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications18",
            description="Modifications to arrays: arrays of composites: non-scalar attribute",
            errorMessage="
1 errors found:

Error at line 10, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION_DUE_TO_EACH:
  Array size mismatch in modification of the attribute start for the variable x, expected size is (due to 'each') scalar and size of start expression is [2]
")})));
end ArrayModifications18;


model ArrayModifications19
 model C
  parameter Real a [3];
  parameter Real d;
 end C;
 
 C c[5](each a ={1,2,3}, d={1,2,3,4,5});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications19",
			description="Modifications to arrays: arrays of composites: example from MLS v3.1 section 7.2.5",
			flatModel="
fclass ModificationTests.ArrayModifications19
 parameter Real c[1].a[1] = 1 /* 1.0 */;
 parameter Real c[1].a[2] = 2 /* 2.0 */;
 parameter Real c[1].a[3] = 3 /* 3.0 */;
 parameter Real c[1].d = 1 /* 1.0 */;
 parameter Real c[2].a[1] = 1 /* 1.0 */;
 parameter Real c[2].a[2] = 2 /* 2.0 */;
 parameter Real c[2].a[3] = 3 /* 3.0 */;
 parameter Real c[2].d = 2 /* 2.0 */;
 parameter Real c[3].a[1] = 1 /* 1.0 */;
 parameter Real c[3].a[2] = 2 /* 2.0 */;
 parameter Real c[3].a[3] = 3 /* 3.0 */;
 parameter Real c[3].d = 3 /* 3.0 */;
 parameter Real c[4].a[1] = 1 /* 1.0 */;
 parameter Real c[4].a[2] = 2 /* 2.0 */;
 parameter Real c[4].a[3] = 3 /* 3.0 */;
 parameter Real c[4].d = 4 /* 4.0 */;
 parameter Real c[5].a[1] = 1 /* 1.0 */;
 parameter Real c[5].a[2] = 2 /* 2.0 */;
 parameter Real c[5].a[3] = 3 /* 3.0 */;
 parameter Real c[5].d = 5 /* 5.0 */;

end ModificationTests.ArrayModifications19;
")})));
end ArrayModifications19;


model ArrayModifications20
 model C
  Real z[3];
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2](y(z={{{1,2},{3,4},{5,6}},{{7,8},{9,10},{11,12}}}));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications20",
            description="Modifications to arrays: arrays of composites: wrong size of binding exp",
            errorMessage="
1 errors found:

Error at line 10, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION:
  Array size mismatch in modification of z, expected size is [2, 2, 3] and size of binding expression is [2, 3, 2]
")})));
end ArrayModifications20;


model ArrayModifications21
 model C
  Real z[3] = zeros(3);
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2](y(z(start={{{1,2},{3,4},{5,6}},{{7,8},{9,10},{11,12}}})));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications21",
            description="Modifications to arrays: arrays of composites: wrong size of attribute",
            errorMessage="
1 errors found:

Error at line 10, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION:
  Array size mismatch in modification of the attribute start for the variable z, expected size is [2, 2, 3] and size of start expression is [2, 3, 2]
")})));
end ArrayModifications21;


model ArrayModifications22
 model C
  Real zc[3];
 end C;
 
 model B
  C yb[2];
 end B;
 
 B xa[2](yb(zc=ya));
 Real ya[2,3,2] = {{{1,2},{3,4},{5,6}},{{7,8},{9,10},{11,12}}};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications22",
            description="Modifications to arrays: arrays of composites: wrong size of binding exp (through access)",
            errorMessage="
1 errors found:

Error at line 10, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION:
  Array size mismatch in modification of zc, expected size is [2, 2, 3] and size of binding expression is [2, 3, 2]
")})));
end ArrayModifications22;


model ArrayModifications23
 model C
  Real zc[3] = zeros(3);
 end C;
 
 model B
  C yb[2];
 end B;
 
 B xa[2](yb(zc(start=za)));
 constant Real za[2,3,2] = {{{1,2},{3,4},{5,6}},{{7,8},{9,10},{11,12}}};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications23",
            description="Modifications to arrays: arrays of composites: wrong size of attribute (through access)",
            errorMessage="
1 errors found:

Error at line 10, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION:
  Array size mismatch in modification of the attribute start for the variable zc, expected size is [2, 2, 3] and size of start expression is [2, 3, 2]
")})));
end ArrayModifications23;


model ArrayModifications24
 model B
  Real yb[2];
 end B;
 
 B x[2](yb={{1,2},{3,4}}*{{10,20,30},{40,50,60}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications24",
            description="Modifications to arrays: arrays of composites: wrong size of binding exp (through expression)",
            errorMessage="
1 errors found:

Error at line 6, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION:
  Array size mismatch in modification of yb, expected size is [2, 2] and size of binding expression is [2, 3]
")})));
end ArrayModifications24;


model ArrayModifications25
 model B
  Real yb[2];
 end B;
 
 B x[2](yb=y*z);
 Real y[2,2] = {{1,2},{3,4}};
 Real z[2,3] = {{10,20,30},{40,50,60}};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications25",
            description="Modifications to arrays: arrays of composites: wrong size of binding exp (through expression with accesses)",
            errorMessage="
1 errors found:

Error at line 6, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION:
  Array size mismatch in modification of yb, expected size is [2, 2] and size of binding expression is [2, 3]
")})));
end ArrayModifications25;


model ArrayModifications26
 Real x1[2,3] = y[1,:,:] .+ 1;
 Real x2[2,3] = y[2,:,:] .+ 1;
 Real y[2,2,3] = {{{1,2,3},{4,5,6}},{{7,8,9},{10,11,12}}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications26",
			description="Modifications to arrays: scalarisation of accesses with colon subscrpt",
			flatModel="
fclass ModificationTests.ArrayModifications26
 constant Real x1[1,1] = 2.0;
 constant Real x1[1,2] = 3.0;
 constant Real x1[1,3] = 4.0;
 constant Real x1[2,1] = 5.0;
 constant Real x1[2,2] = 6.0;
 constant Real x1[2,3] = 7.0;
 constant Real x2[1,1] = 8.0;
 constant Real x2[1,2] = 9.0;
 constant Real x2[1,3] = 10.0;
 constant Real x2[2,1] = 11.0;
 constant Real x2[2,2] = 12.0;
 constant Real x2[2,3] = 13.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,1,3] = 3;
 constant Real y[1,2,1] = 4;
 constant Real y[1,2,2] = 5;
 constant Real y[1,2,3] = 6;
 constant Real y[2,1,1] = 7;
 constant Real y[2,1,2] = 8;
 constant Real y[2,1,3] = 9;
 constant Real y[2,2,1] = 10;
 constant Real y[2,2,2] = 11;
 constant Real y[2,2,3] = 12;
end ModificationTests.ArrayModifications26;
")})));
end ArrayModifications26;


model ArrayModifications27
 model B
  Real yb[2];
 end B;
 
 B x[2](yb(start={{1,2},{3,4}}*{{10,20},{30,40}}) = {{1,2},{3,4}});

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications27",
			description="Modifications to arrays: arrays of composites: array expression attribute on outer level",
			flatModel="
fclass ModificationTests.ArrayModifications27
 constant Real x[1].yb[1](start = 70) = 1;
 constant Real x[1].yb[2](start = 100) = 2;
 constant Real x[2].yb[1](start = 150) = 3;
 constant Real x[2].yb[2](start = 220) = 4;
end ModificationTests.ArrayModifications27;
")})));
end ArrayModifications27;


model ArrayModifications28
 model B
  Real yb[2];
 end B;
 
 B x[2](yb(start=y*z) = {{1,2},{3,4}});
 constant Real y[2,2] = {{1,2},{3,4}};
 constant Real z[2,2] = {{10,20},{30,40}};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications28",
			description="Modifications to arrays: arrays of composites: array expression (with constants) attribute on outer level",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications28
 constant Real x[1].yb[1](start = 70.0) = 1;
 constant Real x[1].yb[2](start = 100.0) = 2;
 constant Real x[2].yb[1](start = 150.0) = 3;
 constant Real x[2].yb[2](start = 220.0) = 4;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
 constant Real z[1,1] = 10;
 constant Real z[1,2] = 20;
 constant Real z[2,1] = 30;
 constant Real z[2,2] = 40;
end ModificationTests.ArrayModifications28;
")})));
end ArrayModifications28;


model ArrayModifications29
 model B
  Real yb[2];
 end B;
 
 B x[2](yb(start={{1,2},{3,4}}*{{10,20,30},{40,50,60}}));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications29",
            description="Modifications to arrays: arrays of composites: wrong size of attribute (through expression)",
            errorMessage="
1 errors found:

Error at line 6, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION:
  Array size mismatch in modification of the attribute start for the variable yb, expected size is [2, 2] and size of start expression is [2, 3]
")})));
end ArrayModifications29;


model ArrayModifications30
 model B
  Real yb[2];
 end B;
 
 B x[2](yb(start=y*z));
 constant Real y[2,2] = {{1,2},{3,4}};
 constant Real z[2,3] = {{10,20,30},{40,50,60}};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications30",
            description="Modifications to arrays: arrays of composites: wrong size of attribute (through expression with accesses)",
            errorMessage="
1 errors found:

Error at line 6, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION:
  Array size mismatch in modification of the attribute start for the variable yb, expected size is [2, 2] and size of start expression is [2, 3]
")})));
end ArrayModifications30;


model ArrayModifications31
 model C
  Real x[2] = {1,2};
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications31",
			description="Modifications to arrays: arrays of composites: 3 levels deep, binding exp on inner",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications31
 constant Real x[1].y[1].x[1] = 1;
 constant Real x[1].y[1].x[2] = 2;
 constant Real x[1].y[2].x[1] = 1;
 constant Real x[1].y[2].x[2] = 2;
 constant Real x[2].y[1].x[1] = 1;
 constant Real x[2].y[1].x[2] = 2;
 constant Real x[2].y[2].x[1] = 1;
 constant Real x[2].y[2].x[2] = 2;
end ModificationTests.ArrayModifications31;
")})));
end ArrayModifications31;


model ArrayModifications32
 model C
  Real x[2](start={1,2}) = {3,4};
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications32",
			description="Modifications to arrays: arrays of composites: 3 levels deep, attribute on inner",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications32
 constant Real x[1].y[1].x[1](start = 1) = 3;
 constant Real x[1].y[1].x[2](start = 2) = 4;
 constant Real x[1].y[2].x[1](start = 1) = 3;
 constant Real x[1].y[2].x[2](start = 2) = 4;
 constant Real x[2].y[1].x[1](start = 1) = 3;
 constant Real x[2].y[1].x[2](start = 2) = 4;
 constant Real x[2].y[2].x[1](start = 1) = 3;
 constant Real x[2].y[2].x[2](start = 2) = 4;
end ModificationTests.ArrayModifications32;
")})));
end ArrayModifications32;


model ArrayModifications33
 model C
  Real x[2];
 end C;
 
 model B
  C y[2](x={{1,2},{3,4}});
 end B;
 
 B x[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications33",
			description="Modifications to arrays: arrays of composites: 3 levels deep, binding exp on middle",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications33
 constant Real x[1].y[1].x[1] = 1;
 constant Real x[1].y[1].x[2] = 2;
 constant Real x[1].y[2].x[1] = 3;
 constant Real x[1].y[2].x[2] = 4;
 constant Real x[2].y[1].x[1] = 1;
 constant Real x[2].y[1].x[2] = 2;
 constant Real x[2].y[2].x[1] = 3;
 constant Real x[2].y[2].x[2] = 4;
end ModificationTests.ArrayModifications33;
")})));
end ArrayModifications33;


model ArrayModifications34
 model C
  Real x[2] = {3,4};
 end C;
 
 model B
  C y[2](x(start={{1,2},{3,4}}));
 end B;
 
 B x[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications34",
			description="Modifications to arrays: arrays of composites: 3 levels deep, attribute on middle",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications34
 constant Real x[1].y[1].x[1](start = 1) = 3;
 constant Real x[1].y[1].x[2](start = 2) = 4;
 constant Real x[1].y[2].x[1](start = 3) = 3;
 constant Real x[1].y[2].x[2](start = 4) = 4;
 constant Real x[2].y[1].x[1](start = 1) = 3;
 constant Real x[2].y[1].x[2](start = 2) = 4;
 constant Real x[2].y[2].x[1](start = 3) = 3;
 constant Real x[2].y[2].x[2](start = 4) = 4;
end ModificationTests.ArrayModifications34;
")})));
end ArrayModifications34;


model ArrayModifications35
 model C
  Real x[2] = {1,2,3};
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications35",
            description="Modifications to arrays: arrays of composites: 3 levels deep, binding exp on inner, wrong size",
            errorMessage="
1 errors found:

Error at line 3, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION,
In components:
    x[1].y[1]
    x[1].y[2]
    x[2].y[1]
    x[2].y[2]
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [3]
")})));
end ArrayModifications35;


model ArrayModifications36
 model C
  Real x[2] = {{1,2},{3,4}};
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications36",
            description="Modifications to arrays: arrays of composites: 3 levels deep, binding exp on inner, wrong size",
            errorMessage="
1 errors found:

Error at line 3, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION,
In components:
    x[1].y[1]
    x[1].y[2]
    x[2].y[1]
    x[2].y[2]
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [2, 2]
")})));
end ArrayModifications36;


model ArrayModifications37
 model C
  Real x[2];
 end C;
 
 model B
  C y[2](x = {1,2});
 end B;
 
 B x[2];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayModifications37",
			description="Modifications to arrays: inferring each: 3 levels deep, binding exp on middle",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.ArrayModifications37
 constant Real x[1].y[1].x[1] = 1;
 constant Real x[1].y[1].x[2] = 2;
 constant Real x[1].y[2].x[1] = 1;
 constant Real x[1].y[2].x[2] = 2;
 constant Real x[2].y[1].x[1] = 1;
 constant Real x[2].y[1].x[2] = 2;
 constant Real x[2].y[2].x[1] = 1;
 constant Real x[2].y[2].x[2] = 2;
end ModificationTests.ArrayModifications37;
")})));
end ArrayModifications37;


model ArrayModifications38
 model C
  Real x[2];
 end C;
 
 model B
  C y[2](x = {{1,2,3},{4,5,6}});
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications38",
            description="Modifications to arrays: arrays of composites: 3 levels deep, binding exp on middle, wrong size",
            errorMessage="
1 errors found:

Error at line 7, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION,
In components:
    x[1]
    x[2]
  Array size mismatch in modification of x, expected size is [2, 2] and size of binding expression is [2, 3]
")})));
end ArrayModifications38;


model ArrayModifications39
 model C
  Real x[2];
 end C;
 
 model B
  C y[2](x = {{{1,2},{3,4}},{{5,6},{7,8}}});
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications39",
            description="Modifications to arrays: arrays of composites: 3 levels deep, binding exp on middle, wrong size",
            errorMessage="
1 errors found:

Error at line 7, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION,
In components:
    x[1]
    x[2]
  Array size mismatch in modification of x, expected size is [2, 2] and size of binding expression is [2, 2, 2]
")})));
end ArrayModifications39;


model ArrayModifications40
 model C
  Real x[2](start = {1,2,3});
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications40",
            description="Modifications to arrays: arrays of composites: 3 levels deep, attribute on inner, wrong size",
            errorMessage="
1 errors found:

Error at line 3, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION,
In components:
    x[1].y[1]
    x[1].y[2]
    x[2].y[1]
    x[2].y[2]
  Array size mismatch in modification of the attribute start for the variable x, expected size is [2] and size of start expression is [3]
")})));
end ArrayModifications40;


model ArrayModifications41
 model C
  Real x[2](start = {{1,2},{3,4}});
 end C;
 
 model B
  C y[2];
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications41",
            description="Modifications to arrays: arrays of composites: 3 levels deep, attribute on inner, wrong size",
            errorMessage="
1 errors found:

Error at line 3, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION,
In components:
    x[1].y[1]
    x[1].y[2]
    x[2].y[1]
    x[2].y[2]
  Array size mismatch in modification of the attribute start for the variable x, expected size is [2] and size of start expression is [2, 2]
")})));
end ArrayModifications41;


model ArrayModifications42
 model C
  Real x[2] = {1,2};
 end C;
 
 model B
  C y[2](x(start = {1,2}));
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications42",
            description="Modifications to arrays: arrays of composites: 3 levels deep, attribute on middle, wrong size",
            errorMessage="
1 errors found:

Warning at line 7, column 10, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH,
In components:
    x[1]
    x[2]
  Assuming 'each' for the modification 'x(start = {1,2})'
")})));
end ArrayModifications42;


model ArrayModifications43
 model C
  Real x[2];
 end C;
 
 model B
  C y[2](x(start = {{1,2,3},{4,5,6}}));
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications43",
            description="Modifications to arrays: arrays of composites: 3 levels deep, attribute on middle, wrong size",
            errorMessage="
1 errors found:

Error at line 7, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION,
In components:
    x[1]
    x[2]
  Array size mismatch in modification of the attribute start for the variable x, expected size is [2, 2] and size of start expression is [2, 3]
")})));
end ArrayModifications43;


model ArrayModifications44
 model C
  Real x[2];
 end C;
 
 model B
  C y[2](x(start = {{{1,2},{3,4}},{{5,6},{7,8}}}));
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications44",
            description="Modifications to arrays: arrays of composites: 3 levels deep, attribute on middle, wrong size",
            errorMessage="
1 errors found:

Error at line 7, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION,
In components:
    x[1]
    x[2]
  Array size mismatch in modification of the attribute start for the variable x, expected size is [2, 2] and size of start expression is [2, 2, 2]
")})));
end ArrayModifications44;


model ArrayModifications45
 Real x[2](start=0) = {1,2};

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications45",
            description="Modifications to arrays: inferring each: attribute",
            errorMessage="
1 errors found:

Warning at line 2, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH:
  Assuming 'each' for the modification 'start = 0'
")})));
end ArrayModifications45;


model ArrayModifications46
 model A
  Real x[2];
 end A;
 
 A y[2](x = {1,2});

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications46",
            description="Modifications to arrays: inferring each: binding expression",
            errorMessage="
1 errors found:

Warning at line 6, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH:
  Assuming 'each' for the modification 'x = {1,2}'
")})));
end ArrayModifications46;


model ArrayModifications47
    model A
        Real x;
    end A;
    
    model B
        Real y;
    end B;
    
    A a[2](x = b.y);
    B b[2](y = {1, 2});

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayModifications47",
			description="Dotted name as modifier to array of components",
			flatModel="
fclass ModificationTests.ArrayModifications47
 Real a[1].x = b[1].y;
 Real a[2].x = b[2].y;
 Real b[1].y = 1;
 Real b[2].y = 2;
end ModificationTests.ArrayModifications47;
")})));
end ArrayModifications47;


model ArrayModifications48
    model A
        B[1] b;
    end A;
    
    model B
        parameter Real x;
    end B;
    
    A a(b(x(fixed=false)));
initial equation
    a.b[1].x = 1;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ArrayModifications48",
			description="Test setting boolean attribute of a member of an array component to a scalar constant without each",
			flatModel="
fclass ModificationTests.ArrayModifications48
 initial parameter Real a.b[1].x(fixed = false);
initial equation
 a.b[1].x = 1;
end ModificationTests.ArrayModifications48;
")})));
end ArrayModifications48;


model ArrayModifications49
    model A
        Real x = 1;
    end A;
    
    A a[3](x(each min = 1));
    parameter Real d;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications49",
            description="Test each on attribute of sclar var in array of components",
            errorMessage="
1 errors found:

Warning at line 7, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications49;


model ArrayModifications50
    model B
        Real[2] c;
    end B;

    B[2] d(each c = {1, 2});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications50",
            description="Test each on array modifier to array in array of components", 
            flatModel="
fclass ModificationTests.ArrayModifications50
 Real d[1].c[2] = {1, 2};
 Real d[2].c[2] = {1, 2};
end ModificationTests.ArrayModifications50;
")})));
end ArrayModifications50;


model ArrayModifications51
    model A
        model B
           Real c;
        end B;

        B b[3];
    end A;

    A a(each b(c = 1));
    parameter Real d;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications51",
            description="Test each on other level of modification",
            errorMessage="
3 warnings found:

Warning at line 10, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', EACH_APPLIED_ON_SCALAR:
  The 'each' keyword should not be applied to a modification of a scalar component: each b(c = 1)

Warning at line 10, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH:
  Assuming 'each' for the modification 'c = 1'

Warning at line 11, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications51;


model ArrayModifications52
    model A
        model B
           Real c;
        end B;

        B b[3];
    end A;

    A a(b(each c(start = 1)));
    parameter Real d;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications52",
            description="Test each on other level of modification",
            errorMessage="
1 errors found:

Warning at line 11, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications52;


model ArrayModifications53
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    B b[2](each a(x(start=1:3)));
    parameter Real d; // Provoke warning

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications53",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 11, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications53;


model ArrayModifications54
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2](each a(x = 1:3));
    end C;
    
    C c[2];
    parameter Real d; // Provoke warning

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications54",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 15, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications54;


model ArrayModifications55
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2](a(each x = 1:3));
    end C;
    
    C c[2];
    parameter Real d; // Provoke warning

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications55",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 15, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications55;


model ArrayModifications56
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2](a(each x(start = 1:3)));
    end C;
    
    C c[2];
    parameter Real d; // Provoke warning

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications56",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 15, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications56;


model ArrayModifications57
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2](a(x(start = 1:3)));
    end C;
    
    C c[2];

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications57",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 11, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH,
In components:
    c[1]
    c[2]
  Assuming 'each' for the modification 'a(x(start = 1:3))'
")})));
end ArrayModifications57;


model ArrayModifications58
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2](a(each x(start = 1)));
    end C;
    
    C c[2];

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications58",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 11, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH,
In components:
    c[1]
    c[2]
  Assuming 'each' for the modification 'start = 1'
")})));
end ArrayModifications58;


model ArrayModifications59
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2](a(x(each start = 1)));
    end C;
    
    C c[2];
    parameter Real d; // Provoke warning

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications59",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 15, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications59;


model ArrayModifications60
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2];
    end C;
    
    C c[2](each b(a(x = {1:3, 4:6})));
    parameter Real d; // Provoke warning

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications60",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 15, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications60;


model ArrayModifications61
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2];
    end C;
    
    C c[2](b(a(x = {1:3, 4:6})));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications61",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 14, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH:
  Assuming 'each' for the modification 'b(a(x = {1:3,4:6}))'
")})));
end ArrayModifications61;


model ArrayModifications62
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b[2];
    end C;
    
    C c[2](b(each a(x = {1:3, 4:6})));
    parameter Real d;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications62",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Error at line 14, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION_DUE_TO_EACH:
  Array size mismatch in modification of x, expected size is (due to 'each') [3] and size of binding expression is [2, 3]
")})));
end ArrayModifications62;


model ArrayModifications63
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b(each a(x = 1:3));
    end C;
    
    C c[2];

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications63",
            description="Test each on other levels of modification",
            errorMessage="
1 warnings found:

Warning at line 11, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', EACH_APPLIED_ON_SCALAR,
In components:
    c[1]
    c[2]
  The 'each' keyword should not be applied to a modification of a scalar component: each a(x = 1:3)
")})));
end ArrayModifications63;


model ArrayModifications64
    model A
        Real x[3];
    end A;
    
    model B
        A a;
    end B;
    
    model C
        B b;
    end C;
    
    C c(b(each a(x = 1:3)));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications64",
            description="Test each on other levels of modification",
            errorMessage="
1 warnings found:

Warning at line 14, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', EACH_APPLIED_ON_SCALAR:
  The 'each' keyword should not be applied to a modification of a scalar component: each a(x = 1:3)
")})));
end ArrayModifications64;


model ArrayModifications65
    model A
        Real x;
    end A;
    
    model B
        A a[3];
    end B;
    
    model C
        B b[2](a(x(start = 1:3) = 1));
    end C;
    
    C c[2];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayModifications65",
            description="Test each on other levels of modification",
            errorMessage="
2 errors found:

Error at line 11, column 20, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION,
In components:
    c[1]
    c[2]
  Array size mismatch in modification of the attribute start for the variable x, expected size is [2, 3] and size of start expression is [3]

Error at line 11, column 35, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION,
In components:
    c[1]
    c[2]
  Array size mismatch in modification of x, expected size is [2, 3] and size of binding expression is scalar
")})));
end ArrayModifications65;


model ArrayModifications66
    record R
        Real x[2];
        Real y;
    end R;
    
    model A
        R r;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b(a(r(each x = {1,2}, y = {1,2})));
    parameter Real d;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications66",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 16, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications66;


model ArrayModifications67
    record R
        Real x[2];
        Real y;
    end R;
    
    model A
        R r;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b(a(each r(x = {1,2}, y = {1,2})));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications67",
            description="Test each on other levels of modification",
            errorMessage="
1 warnings found:

Warning at line 15, column 29, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', IGNORING_EACH:
  Ignoring erroneous 'each' for the modification 'y = {1,2}'
")})));
end ArrayModifications67;


model ArrayModifications68
    record R
        Real x[2];
        Real y;
    end R;
    
    model A
        R r;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b(a(each r(x = {1,2,3}, y = 1)));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications68",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Error at line 15, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION_DUE_TO_EACH:
  Array size mismatch in modification of x, expected size is (due to 'each') [2] and size of binding expression is [3]
")})));
end ArrayModifications68;


model ArrayModifications69
    record R
        Real x[2];
        Real y;
    end R;
    
    model A
        R r;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b(a(each r(x = {1,2}, y = 1)));
    B b2(a(r = b.a.r));
    parameter Real d;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications69",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 17, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter d does not have a binding expression
")})));
end ArrayModifications69;


model ArrayModifications70
    record R
        Real x[2];
        Real y;
    end R;
    
    model A
        R r;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b(a(r(x = {1,2}, y = 1)));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications70",
            description="Test each on other levels of modification",
            errorMessage="
1 errors found:

Warning at line 15, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ASSUMING_EACH:
  Assuming 'each' for the modification 'r(x = {1,2}, y = 1)'
")})));
end ArrayModifications70;


model ArrayModifications71
    B[1] b1 = b2;
    B[1] b2(each x=0);

    record A
        Real x;
    end A;

    record B = A;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications71",
            description="Test type checking of modifiers on records with short class declarations",
            flatModel="
fclass ModificationTests.ArrayModifications71
 ModificationTests.ArrayModifications71.B b1[1] = b2[1:1];
 ModificationTests.ArrayModifications71.B b2[1](x = {0});

public
 record ModificationTests.ArrayModifications71.B
  Real x;
 end ModificationTests.ArrayModifications71.B;

end ModificationTests.ArrayModifications71;
")})));
end ArrayModifications71;


model ArrayModifications72
    B[1] b1 = b2;
    B[1] b2(each x=0);

    record A
        Real x;
    end A;

    record B
        extends A;
    end B;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications72",
            description="Test type checking of modifiers on records with inheritance",
            flatModel="
fclass ModificationTests.ArrayModifications72
 ModificationTests.ArrayModifications72.B b1[1] = b2[1:1];
 ModificationTests.ArrayModifications72.B b2[1](x = {0});

public
 record ModificationTests.ArrayModifications72.B
  Real x;
 end ModificationTests.ArrayModifications72.B;

end ModificationTests.ArrayModifications72;
")})));
end ArrayModifications72;

model ArrayModifications73
    model M1
        Real[2] x = 1:2;
    end M1;
    
    model M2
        M1 m1;
    end M2;

    M2[2] m2(each m1(x(start=3:4) = 5:6));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications73",
            description="Start value nested in modification with each",
            flatModel="
fclass ModificationTests.ArrayModifications73
 Real m2[1].m1.x[2](start = 3:4) = 5:6;
 Real m2[2].m1.x[2](start = 3:4) = 5:6;
end ModificationTests.ArrayModifications73;
")})));
end ArrayModifications73;

model ArrayModifications74
    model A
        Real[:,2] x = {{1,2}};
    end A;
    
    model A2 = A(x={{3,4}});
    A2[2] a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications74",
            description="Binding expression modification on array",
            flatModel="
fclass ModificationTests.ArrayModifications74
 Real a[1].x[1,2] = {{3, 4}};
 Real a[2].x[1,2] = {{3, 4}};
end ModificationTests.ArrayModifications74;
")})));
end ArrayModifications74;

model ArrayModifications75
    model A
        Real[1,2] x = {{1,2}};
    end A;
    
    model A2 = A[2](x={{{3,4}},{{5,6}}});
    A2 a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications75",
            description="Binding expression modification on array",
            flatModel="
fclass ModificationTests.ArrayModifications75
 Real a[1].x[1,2] = {{3, 4}};
 Real a[2].x[1,2] = {{5, 6}};
end ModificationTests.ArrayModifications75;
")})));
end ArrayModifications75;

model ArrayModifications76
    model A
        Real[1,2] x = {{1,2}};
    end A;
    
    model A2 = A[2](x={{{3,4}},{{5,6}}});
    A2[3] a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications76",
            description="Binding expression modification on array",
            flatModel="
fclass ModificationTests.ArrayModifications76
 Real a[1,1].x[1,2] = {{3, 4}};
 Real a[1,2].x[1,2] = {{5, 6}};
 Real a[2,1].x[1,2] = {{3, 4}};
 Real a[2,2].x[1,2] = {{5, 6}};
 Real a[3,1].x[1,2] = {{3, 4}};
 Real a[3,2].x[1,2] = {{5, 6}};
end ModificationTests.ArrayModifications76;
")})));
end ArrayModifications76;

model ArrayModifications77
    model A
        Real[1,2] x = {{1,2}};
    end A;
    
    model A1 = A[2](x={{{3,4}},{{5,6}}});
    model A2 = A1[2](x(start={{{{3,4}},{{5,6}}},{{{3,4}},{{5,6}}}})={{{{3,4}},{{5,6}}},{{{3,4}},{{5,6}}}});
    A2[3] a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications77",
            description="Modifications on array",
            flatModel="
fclass ModificationTests.ArrayModifications77
 Real a[1,1,1].x[1,2](start = {{3, 4}}) = {{3, 4}};
 Real a[1,1,2].x[1,2](start = {{5, 6}}) = {{5, 6}};
 Real a[1,2,1].x[1,2](start = {{3, 4}}) = {{3, 4}};
 Real a[1,2,2].x[1,2](start = {{5, 6}}) = {{5, 6}};
 Real a[2,1,1].x[1,2](start = {{3, 4}}) = {{3, 4}};
 Real a[2,1,2].x[1,2](start = {{5, 6}}) = {{5, 6}};
 Real a[2,2,1].x[1,2](start = {{3, 4}}) = {{3, 4}};
 Real a[2,2,2].x[1,2](start = {{5, 6}}) = {{5, 6}};
 Real a[3,1,1].x[1,2](start = {{3, 4}}) = {{3, 4}};
 Real a[3,1,2].x[1,2](start = {{5, 6}}) = {{5, 6}};
 Real a[3,2,1].x[1,2](start = {{3, 4}}) = {{3, 4}};
 Real a[3,2,2].x[1,2](start = {{5, 6}}) = {{5, 6}};
end ModificationTests.ArrayModifications77;
")})));
end ArrayModifications77;


model ArrayModifications78
    model A
        Real x = 1;
        Real y = 1;
    end A;
    
    model B
        A a;
    end B;
    
    B b[2](each a(x = 2, y = {3, 4}));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications78",
            description="",
            errorMessage="
1 warnings found:

Warning at line 11, column 26, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', IGNORING_EACH:
  Ignoring erroneous 'each' for the modification 'y = {3,4}'
")})));
end ArrayModifications78;


model ArrayModifications79
    Real a[3](each start={1,2,3}) = zeros(3);

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications79",
            description="",
            errorMessage="
1 warnings found:

Warning at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', IGNORING_EACH:
  Ignoring erroneous 'each' for the modification 'each start = {1,2,3}'
")})));
end ArrayModifications79;


model ArrayModifications80
    model A
        Real x = 1;
    end A;
    
    model B
        A a;
    end B;
    
    B b[2](a(x = true));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications80",
            description="",
            errorMessage="
1 errors found:

Error at line 10, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ArrayModifications80;


model ArrayModifications81
    model A
        Real x = 1;
    end A;
    
    model B
        A a;
    end B;
    
    B b[2](each a(x = {true, false}));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications81",
            description="",
            errorMessage="
1 errors found:

Error at line 10, column 23, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ArrayModifications81;


model ArrayModifications82
    model A
        Real x = 1;
    end A;
    
    model B
        A a;
    end B;
    
    B b[2](each a(x = {1, 2, 3}));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications82",
            description="",
            errorMessage="
1 errors found:

Error at line 10, column 23, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', ARRAY_SIZE_MISMATCH_IN_MODIFICATION_DUE_TO_EACH:
  Array size mismatch in modification of x, expected size is (due to 'each') scalar and size of binding expression is [3]
")})));
end ArrayModifications82;


model ArrayModifications83
    model A
        Real x = 1;
    end A;
    
    A a[2](each x(start = {1, 2}));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ArrayModifications83",
            description="",
            errorMessage="
1 warnings found:

Warning at line 6, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ModificationTests.mo', IGNORING_EACH:
  Ignoring erroneous 'each' for the modification 'start = {1,2}'
")})));
end ArrayModifications83;


model ArrayModifications84
    model A
        parameter Integer n;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b[2](a(n={i + j for i in 1:2, j in 3:3:6}));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications84",
            description="Expression splitting for iteration expressions",
            flatModel="
fclass ModificationTests.ArrayModifications84
 parameter Integer b[1].a[1].n = 1 + 3 /* 4 */;
 parameter Integer b[1].a[2].n = 2 + 3 /* 5 */;
 parameter Integer b[2].a[1].n = 1 + 6 /* 7 */;
 parameter Integer b[2].a[2].n = 2 + 6 /* 8 */;
end ModificationTests.ArrayModifications84;
")})));
end ArrayModifications84;


model ArrayModifications85
    model A
        parameter Integer n;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b[2](each a(n=1:2));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications85",
            description="Split binding expressions on the correct level",
            flatModel="
fclass ModificationTests.ArrayModifications85
 parameter Integer b[1].a[1].n = (1:2)[1] /* 1 */;
 parameter Integer b[1].a[2].n = (1:2)[2] /* 2 */;
 parameter Integer b[2].a[1].n = (1:2)[1] /* 1 */;
 parameter Integer b[2].a[2].n = (1:2)[2] /* 2 */;
end ModificationTests.ArrayModifications85;
")})));
end ArrayModifications85;


model ArrayModifications86
    model A
        parameter Integer n;
    end A;
    
    model B
        A a[2];
    end B;
    
    B b[2](a(n=1:2));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArrayModifications86",
            description="Split binding expressions on the correct level",
            flatModel="
fclass ModificationTests.ArrayModifications86
 parameter Integer b[1].a[1].n = (1:2)[1] /* 1 */;
 parameter Integer b[1].a[2].n = (1:2)[2] /* 2 */;
 parameter Integer b[2].a[1].n = (1:2)[1] /* 1 */;
 parameter Integer b[2].a[2].n = (1:2)[2] /* 2 */;
end ModificationTests.ArrayModifications86;
")})));
end ArrayModifications86;


/* ========= Modifications on type declarations ========= */

type TypeA = Real(final quantity="A", unit="1");


model TypeModifications1
 TypeA x[3] = {1, 2, 3};

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="TypeModifications1",
			description="Type declarations with modifications: array of new type",
			flatModel="
fclass ModificationTests.TypeModifications1
 ModificationTests.TypeA x[3] = {1,2,3};

public
 type ModificationTests.TypeA = Real(final quantity = \"A\",unit = \"1\");
end ModificationTests.TypeModifications1;
")})));
end TypeModifications1;


model TypeModifications2
 model B
  TypeA x[3] = {1, 2, 3};
 end B;
 
 B y[3];

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="TypeModifications2",
			description="Type declarations with modifications: array of components containing array of new type",
			flatModel="
fclass ModificationTests.TypeModifications2
 ModificationTests.TypeA y[1].x[3] = {1,2,3};
 ModificationTests.TypeA y[2].x[3] = {1,2,3};
 ModificationTests.TypeA y[3].x[3] = {1,2,3};

public
 type ModificationTests.TypeA = Real(final quantity = \"A\",unit = \"1\");
end ModificationTests.TypeModifications2;
")})));
end TypeModifications2;


model ModelB
 Real x(start=1) = 1;
 TypeA y = 1;
end ModelB;


model TypeModifications3
 ModelB z[2](y(start={2,3}));

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="TypeModifications3",
			description="Type declarations with modifications: modifying type in component decl",
			flatModel="
fclass ModificationTests.TypeModifications3
 Real z[1].x(start = 1) = 1;
 ModificationTests.TypeA z[1].y(start = 2) = 1;
 Real z[2].x(start = 1) = 1;
 ModificationTests.TypeA z[2].y(start = 3) = 1;

public
 type ModificationTests.TypeA = Real(final quantity = \"A\",unit = \"1\");
end ModificationTests.TypeModifications3;
")})));
end TypeModifications3;


type TypeC = ModelB(y(final start=1));


// TODO: Something is wrong with how this is handled
model TypeModifications4
 TypeC x[3];
end TypeModifications4;



model TypeModifications5
    type T = Real[3](min={1,2,3});
    T a = 4 * ones(3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TypeModifications5",
			description="Array-valued annotations on types: basic test",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.TypeModifications5
 constant ModificationTests.TypeModifications5.T a[1](min = 1) = 4;
 constant ModificationTests.TypeModifications5.T a[2](min = 2) = 4;
 constant ModificationTests.TypeModifications5.T a[3](min = 3) = 4;

public
 type ModificationTests.TypeModifications5.T = Real;
end ModificationTests.TypeModifications5;
")})));
end TypeModifications5;



model TypeModifications6
    type T = Real[3](min={0.1,0.2,0.3});
    
    record R
        T x;
	    T y;
    end R;
    
    R z(x = ones(3), y(each min = 0.4) = ones(3));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TypeModifications6",
			description="Array-valued annotations on types: in array",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.TypeModifications6
 constant ModificationTests.TypeModifications6.T z.x[1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications6.T z.x[2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications6.T z.x[3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications6.T z.y[1](min = 0.4) = 1;
 constant ModificationTests.TypeModifications6.T z.y[2](min = 0.4) = 1;
 constant ModificationTests.TypeModifications6.T z.y[3](min = 0.4) = 1;

public
 type ModificationTests.TypeModifications6.T = Real;
end ModificationTests.TypeModifications6;
")})));
end TypeModifications6;



model TypeModifications7
    type T = Real[3](min={0.1,0.2,0.3});
    
    T[2] x = ones(2,3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TypeModifications7",
			description="Array-valued annotations on types: in record",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.TypeModifications7
 constant ModificationTests.TypeModifications7.T x[1,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications7.T x[1,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications7.T x[1,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications7.T x[2,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications7.T x[2,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications7.T x[2,3](min = 0.3) = 1;

public
 type ModificationTests.TypeModifications7.T = Real;
end ModificationTests.TypeModifications7;
")})));
end TypeModifications7;



model TypeModifications8
    type T = Real[3](min={0.1,0.2,0.3});
    
    record R
        T[2] x;
    end R;
    
    R[4] y(x = ones(4,2,3));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TypeModifications8",
			description="Array-valued annotations on types: array of records",
            eliminate_alias_variables=false,
			flatModel="
fclass ModificationTests.TypeModifications8
 constant ModificationTests.TypeModifications8.T y[1].x[1,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[1].x[1,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[1].x[1,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications8.T y[1].x[2,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[1].x[2,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[1].x[2,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications8.T y[2].x[1,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[2].x[1,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[2].x[1,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications8.T y[2].x[2,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[2].x[2,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[2].x[2,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications8.T y[3].x[1,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[3].x[1,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[3].x[1,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications8.T y[3].x[2,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[3].x[2,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[3].x[2,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications8.T y[4].x[1,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[4].x[1,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[4].x[1,3](min = 0.3) = 1;
 constant ModificationTests.TypeModifications8.T y[4].x[2,1](min = 0.1) = 1;
 constant ModificationTests.TypeModifications8.T y[4].x[2,2](min = 0.2) = 1;
 constant ModificationTests.TypeModifications8.T y[4].x[2,3](min = 0.3) = 1;

public
 type ModificationTests.TypeModifications8.T = Real;
end ModificationTests.TypeModifications8;
")})));
end TypeModifications8;


model ConstMod1
	record A
		Real x;
	end A;
	
	package B
		constant A y;
	end B;
	
	package C
		extends B(y = A(1));
	end C;
	
	package D
		replaceable package E = A;
	end D;
	
	package F
		extends D;
		redeclare replaceable package E = C constrainedby B;
	end F;
	
	Real z = F.E.y.x;
end ConstMod1;



model ModificationLevel1
	model A
		Real x(start = 0.1) = 0;
		Real y = 0;
	end A;
	
	model B = A(y(start = 0.2));
	
	model C
		A a(y(start = 0.3));
		B b;
	end C;
	
	model D
		C c1;
		C c2(b(x(start = 0.4)));
	end D;
	
	A a(y(start = 0.5));
	B b;
	C c;
	D d(c1(a(x(start = 0.6))));

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ModificationLevel1",
            description="Test calculation of modification levels",
            eliminate_alias_variables=false,
            methodName="attributeLevels",
            methodResult="
Variables:
  a.x(start:3=0.1)
  a.y(start:2=0.5)
  b.x(start:4=0.1)
  b.y(start:3=0.2)
  c.a.x(start:4=0.1)
  c.a.y(start:3=0.3)
  c.b.x(start:5=0.1)
  c.b.y(start:4=0.2)
  d.c1.a.x(start:2=0.6)
  d.c1.a.y(start:4=0.3)
  d.c1.b.x(start:6=0.1)
  d.c1.b.y(start:5=0.2)
  d.c2.a.x(start:5=0.1)
  d.c2.a.y(start:4=0.3)
  d.c2.b.x(start:3=0.4)
  d.c2.b.y(start:5=0.2)
")})));
end ModificationLevel1;


model ModificationLevel2
    model A
        Real x(start = 0.1) = 0;
        Real y = 0;
    end A;
    
    model B = A;
	
	model C
		B b;
	end C;
	
	model D
		C c;
	end D;

    A a(y(start = 0.5));
    D d;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ModificationLevel2",
            description="Test calculation of modification levels for simple short class decl",
            eliminate_alias_variables=false,
            methodName="attributeLevels",
            methodResult="
Variables:
  a.x(start:3=0.1)
  a.y(start:2=0.5)
  d.c.b.x(start:6=0.1)
  d.c.b.y
")})));
end ModificationLevel2;

model ModificationLevel3
    record A
        Real x(start = 1) = time;
    end A;
    
    A a;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ModificationLevel3",
            description="Test calculation of modification levels for record",
            methodName="attributeLevels",
            methodResult="
Variables:
  a.x(start:1001=1)
")})));
end ModificationLevel3;

model ModificationLevel4
    record A
        Real x(start = 1) = time;
        Real y(start = 2) = time;
    end A;
    
    A a(y(start = 3));
    
    model M
        A a(y(start = 4));
    end M;
    
    model W
        M m;
    end W;
    
    W w;
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ModificationLevel4",
            description="Test merging attribute level",
            eliminate_linear_equations=false,
            methodName="attributeLevels",
            methodResult="
Variables:
  a.x(start:1001=1)
  a.y(start:2=3)
  w.m.a.x(start:1001=1)
  w.m.a.y(start:4=4)
")})));
end ModificationLevel4;

model ModificationLevel5
    record A
        Real[2] x(each start = 1) = {time,time};
    end A;
    
    A a1;
    A a2(x(each start = 2));
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ModificationLevel5",
            description="Test merging attribute level of array",
            eliminate_linear_equations=false,
            methodName="attributeLevels",
            methodResult="
Variables:
  a1.x[1](start:1001=1)
  a1.x[2](start:1001=1)
  a2.x[1](start:2=2)
  a2.x[2](start:2=2)
")})));
end ModificationLevel5;

model StartPropagation1
    Real x(start = 1);
    Real y(stateSelect = StateSelect.prefer);
equation
    x = y;
    der(y) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation1",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation1
 Real y(stateSelect = StateSelect.prefer,start = 1);
initial equation 
 y = 1;
equation
 der(y) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end ModificationTests.StartPropagation1;
")})));
end StartPropagation1;


model StartPropagation2
    Real x(start = 1);
    Real y(start = 2, stateSelect = StateSelect.prefer);
equation
    x = y;
    der(y) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation2",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation2
 Real y(start = 2,stateSelect = StateSelect.prefer);
initial equation 
 y = 2;
equation
 der(y) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end ModificationTests.StartPropagation2;
")})));
end StartPropagation2;


model StartPropagation3
	model A
		Real x(start = 1);
	end A;
	
    A a1(x(start = 2));
    A a2(x(stateSelect = StateSelect.prefer));
equation
    a1.x = a2.x;
    der(a2.x) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation3",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation3
 Real a2.x(stateSelect = StateSelect.prefer,start = 2);
initial equation 
 a2.x = 2;
equation
 der(a2.x) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end ModificationTests.StartPropagation3;
")})));
end StartPropagation3;


model StartPropagation4
    Real x(stateSelect = StateSelect.prefer);
    Real y(start = 1);
    Real z(start = 2);
equation
    x = y;
    z = y;
    der(x) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation4",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation4
 Real x(stateSelect = StateSelect.prefer,start = 1);
initial equation 
 x = 1;
equation
 der(x) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end ModificationTests.StartPropagation4;
")})));
end StartPropagation4;


model StartPropagation5
    model A
        Real x(start = 1);
    end A;
    
	type B = Real(start = 2);
	
	A a;
	B b(stateSelect = StateSelect.prefer);
equation
    a.x = b;
    der(b) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation5",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation5
 ModificationTests.StartPropagation5.B b(stateSelect = StateSelect.prefer,start = 1);
initial equation 
 b = 1;
equation
 der(b) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 type ModificationTests.StartPropagation5.B = Real(start = 2);
end ModificationTests.StartPropagation5;
")})));
end StartPropagation5;


model StartPropagation6
    type A = Real(start = 1);
    
    Real x(stateSelect = StateSelect.prefer);
    A a;
equation
    x = a;
    der(x) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation6",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation6
 Real x(stateSelect = StateSelect.prefer,start = 1);
initial equation 
 x = 1;
equation
 der(x) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 type ModificationTests.StartPropagation6.A = Real(start = 1);
end ModificationTests.StartPropagation6;
")})));
end StartPropagation6;


model StartPropagation7
    type A = Real(start = 1);
	type B = Real(start = 2);
	    
    A a(stateSelect = StateSelect.prefer);
    B b;
equation
    a = b;
    der(a) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation7",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation7
 ModificationTests.StartPropagation7.A a(stateSelect = StateSelect.prefer);
initial equation 
 a = 1;
equation
 der(a) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 type ModificationTests.StartPropagation7.A = Real(start = 1);
 type ModificationTests.StartPropagation7.B = Real(start = 2);
end ModificationTests.StartPropagation7;
")})));
end StartPropagation7;


model StartPropagation8
    model A
        Real x(start = 1);
    end A;
    
    type B = Real(start = 2);
    
    A a;
    B b(stateSelect = StateSelect.prefer);
equation
    a.x = -b;
    der(b) = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StartPropagation8",
			description="",
			flatModel="
fclass ModificationTests.StartPropagation8
 ModificationTests.StartPropagation8.B b(stateSelect = StateSelect.prefer,start = - 1);
initial equation 
 b = - 1;
equation
 der(b) = 1;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 type ModificationTests.StartPropagation8.B = Real(start = 2);
end ModificationTests.StartPropagation8;
")})));
end StartPropagation8;


model ModificationFlattening1
    package A
        type B = Real;
    end A;
    
    package C
        extends A(B(min = f(0)));
    end C;
    
    record R
        C.B x;
    end R;
    
    function f
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
    end f;
    
    R r;
equation
    r.x = time + 2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ModificationFlattening1",
            description="Flattening of functions used in modifications",
            flatModel="
fclass ModificationTests.ModificationFlattening1
 ModificationTests.ModificationFlattening1.R r(x(min = ModificationTests.ModificationFlattening1.f(0)));
equation
 r.x = time + 2;

public
 function ModificationTests.ModificationFlattening1.f
  input Real x;
  output Real y;
 algorithm
  y := x + 1;
  return;
 end ModificationTests.ModificationFlattening1.f;

 record ModificationTests.ModificationFlattening1.R
  ModificationTests.ModificationFlattening1.C.B x;
 end ModificationTests.ModificationFlattening1.R;

 type ModificationTests.ModificationFlattening1.C.B = Real(min = ModificationTests.ModificationFlattening1.f(0));
end ModificationTests.ModificationFlattening1;
")})));
end ModificationFlattening1;



model SupersededModification1
    model A
        parameter Integer n = 2;
        parameter Real x[n] = 1:n;
        parameter Real y = x[2];
    end A;
    
    A a(n = 1, y = 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SupersededModification1",
            description="Index out of bounds in modification that has been superseded",
            flatModel="
fclass ModificationTests.SupersededModification1
 structural parameter Integer a.n = 1 /* 1 */;
 structural parameter Real a.x[1] = {1} /* { 1 } */;
 parameter Real a.y = 2 /* 2 */;
end ModificationTests.SupersededModification1;
")})));
end SupersededModification1;


model SupersededModification2
    model A
        parameter Integer n = 2;
        parameter Real x[n] = 1:n;
        parameter Real y;
    end A;
    
    model B
        A a(y = a.x[2]);
    end B;
    
    B b(a(n = 1, y = 2));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SupersededModification2",
            description="Index out of bounds in modification that has been superseded",
            flatModel="
fclass ModificationTests.SupersededModification2
 structural parameter Integer b.a.n = 1 /* 1 */;
 structural parameter Real b.a.x[1] = {1} /* { 1 } */;
 parameter Real b.a.y = 2 /* 2 */;
end ModificationTests.SupersededModification2;
")})));
end SupersededModification2;


model SupersededModification3
    model A
        parameter Integer n = 2;
        parameter Real x[n] = 1:n;
        Real y(start = x[2]);
    equation
        der(y) = -time;
    end A;
    
    A a(n = 1, y(start = 2));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SupersededModification3",
            description="Index out of bounds in modification that has been superseded",
            flatModel="
fclass ModificationTests.SupersededModification3
 structural parameter Integer a.n = 1 /* 1 */;
 structural parameter Real a.x[1] = {1} /* { 1 } */;
 Real a.y(start = 2);
equation
 der(a.y) = - time;
end ModificationTests.SupersededModification3;
")})));
end SupersededModification3;


model SupersededModification4
    model A
        parameter Integer n = 2;
        parameter Real x[n] = 1:n;
        Real y;
    end A;
    
    model B
        A a(y(start = a.x[2]));
    equation
        der(a.y) = -time;
    end B;
    
    B b(a(n = 1, y(start = 2)));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SupersededModification4",
            description="Index out of bounds in modification that has been superseded",
            flatModel="
fclass ModificationTests.SupersededModification4
 structural parameter Integer b.a.n = 1 /* 1 */;
 structural parameter Real b.a.x[1] = {1} /* { 1 } */;
 Real b.a.y(start = 2);
equation
 der(b.a.y) = - time;
end ModificationTests.SupersededModification4;
")})));
end SupersededModification4;

model ForExpModifier1
    model A
        Real[:] p;
    end A;
    
    A a(p = {p for p in 1:1});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ForExpModifier1",
            description="Test for bug in #5640. For index in modification.",
            flatModel="
fclass ModificationTests.ForExpModifier1
 Real a.p[1] = {1};
end ModificationTests.ForExpModifier1;
")})));
end ForExpModifier1;

model ForExpModifier2
    model A
        Real[:] p;
    end A;
    replaceable A a constrainedby A(p = {i for i in 1:1});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ForExpModifier2",
            description="Test for bug in #5640. For index in constrainedby modification.",
            flatModel="
fclass ModificationTests.ForExpModifier2
 Real a.p[1] = {1};
end ModificationTests.ForExpModifier2;
")})));
end ForExpModifier2;

end ModificationTests;
