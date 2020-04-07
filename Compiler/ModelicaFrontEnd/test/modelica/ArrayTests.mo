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

within ;
package ArrayTests


package General

  model ArrayTest1
    Real x[2];
  equation
    x[1] = 3;
    x[2] = 4;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest1",
            description="Flattening of arrays.",
            flatModel="
fclass ArrayTests.General.ArrayTest1
 Real x[2];
equation
 x[1] = 3;
 x[2] = 4;
end ArrayTests.General.ArrayTest1;
")})));
  end ArrayTest1;

  model ArrayTest1b
  
    parameter Integer n = 2;
    Real x[n];
  equation
    x[1] = 3;
    x[2] = 4;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest1b",
            description="Flattening of arrays.",
            flatModel="
fclass ArrayTests.General.ArrayTest1b
 structural parameter Integer n = 2 /* 2 */;
 Real x[2];
equation
 x[1] = 3;
 x[2] = 4;
end ArrayTests.General.ArrayTest1b;
")})));
  end ArrayTest1b;


  model ArrayTest1c

    Real x[2];
  equation
    der(x[1]) = 3;
    der(x[2]) = 4;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest1c",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest1c
 Real x[1];
 Real x[2];
initial equation 
 x[1] = 0.0;
 x[2] = 0.0;
equation
 der(x[1]) = 3;
 der(x[2]) = 4;
end ArrayTests.General.ArrayTest1c;
")})));
  end ArrayTest1c;


  model ArrayTest2

    Real x[2,2];
  equation
    x[1,1] = 1;
    x[1,2] = 2;
    x[2,1] = 3;
    x[2,2] = 4;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest2",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest2
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 4;
end ArrayTests.General.ArrayTest2;
")})));
  end ArrayTest2;

  model ArrayTest4



    model M
      Real x[2];
    end M;
    M m[2];
  equation
    m[1].x[1] = 1;
    m[1].x[2] = 2;
    m[2].x[1] = 3;
    m[2].x[2] = 4;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest4",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest4
 constant Real m[1].x[1] = 1;
 constant Real m[1].x[2] = 2;
 constant Real m[2].x[1] = 3;
 constant Real m[2].x[2] = 4;
end ArrayTests.General.ArrayTest4;
")})));
  end ArrayTest4;

  model ArrayTest5
    model M
      Real x[3] = {-1,-2,-3};
    end M;
    M m[2](x={{1,2,3},{4,5,6}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest5",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest5
 constant Real m[1].x[1] = 1;
 constant Real m[1].x[2] = 2;
 constant Real m[1].x[3] = 3;
 constant Real m[2].x[1] = 4;
 constant Real m[2].x[2] = 5;
 constant Real m[2].x[3] = 6;
end ArrayTests.General.ArrayTest5;
")})));
  end ArrayTest5;

  model ArrayTest6
    model M
      Real x[3];
    end M;
    M m[2];
  equation
    m.x = {{1,2,3},{4,5,6}};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest6",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest6
 constant Real m[1].x[1] = 1;
 constant Real m[1].x[2] = 2;
 constant Real m[1].x[3] = 3;
 constant Real m[2].x[1] = 4;
 constant Real m[2].x[2] = 5;
 constant Real m[2].x[3] = 6;
end ArrayTests.General.ArrayTest6;
")})));
  end ArrayTest6;

  model ArrayTest7
    Real x[3];
  equation
    x[1:2] = {1,2};
    x[3] = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest7",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest7
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
end ArrayTests.General.ArrayTest7;
")})));
  end ArrayTest7;

  model ArrayTest8
    model M
      parameter Integer n = 3;
      Real x[n] = ones(n);
    end M;
      M m[2](n={1,2});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest8",
            description="Test flattening of variables with sizes given in modifications",
            flatModel="
fclass ArrayTests.General.ArrayTest8
 structural parameter Integer m[1].n = 1 /* 1 */;
 Real m[1].x[1] = ones(1);
 structural parameter Integer m[2].n = 2 /* 2 */;
 Real m[2].x[2] = ones(2);
end ArrayTests.General.ArrayTest8;
")})));
  end ArrayTest8;

      model ArrayTest9
        model M
              parameter Integer n1 = 2;
              Real x[n1] = ones(n1);
        end M;

        model N
              parameter Integer n2 = 2;
              M m[n2,n2+1];
        end N;
	    N nn;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest9",
            description="Test scalarization of variables",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest9
 structural parameter Integer nn.n2 = 2 /* 2 */;
 structural parameter Integer nn.m[1,1].n1 = 2 /* 2 */;
 constant Real nn.m[1,1].x[1] = 1;
 constant Real nn.m[1,1].x[2] = 1;
 structural parameter Integer nn.m[1,2].n1 = 2 /* 2 */;
 constant Real nn.m[1,2].x[1] = 1;
 constant Real nn.m[1,2].x[2] = 1;
 structural parameter Integer nn.m[1,3].n1 = 2 /* 2 */;
 constant Real nn.m[1,3].x[1] = 1;
 constant Real nn.m[1,3].x[2] = 1;
 structural parameter Integer nn.m[2,1].n1 = 2 /* 2 */;
 constant Real nn.m[2,1].x[1] = 1;
 constant Real nn.m[2,1].x[2] = 1;
 structural parameter Integer nn.m[2,2].n1 = 2 /* 2 */;
 constant Real nn.m[2,2].x[1] = 1;
 constant Real nn.m[2,2].x[2] = 1;
 structural parameter Integer nn.m[2,3].n1 = 2 /* 2 */;
 constant Real nn.m[2,3].x[1] = 1;
 constant Real nn.m[2,3].x[2] = 1;
end ArrayTests.General.ArrayTest9;
")})));
      end ArrayTest9;

      model ArrayTest95
        model M
              parameter Integer n1 = 3;
              Real x = n1;
        end M;

        model N
              parameter Integer n2 = 2;
              M m;
        end N;
        N n[2](m(n1={3,4}));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest95",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest95
 parameter Integer n[1].n2 = 2 /* 2 */;
 parameter Integer n[1].m.n1 = 3 /* 3 */;
 parameter Real n[1].m.x;
 parameter Integer n[2].n2 = 2 /* 2 */;
 parameter Integer n[2].m.n1 = 4 /* 4 */;
 parameter Real n[2].m.x;
parameter equation
 n[1].m.x = n[1].m.n1;
 n[2].m.x = n[2].m.n1;
end ArrayTests.General.ArrayTest95;
")})));
      end ArrayTest95;


   model ArrayTest10
    parameter Integer n;
    Real x[n];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest10",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest10
 structural parameter Integer n = 0 /* 0 */;
end ArrayTests.General.ArrayTest10;
")})));
   end ArrayTest10;

   model ArrayTest11
    model M
      Real x[2];
    end M;
      M m1[2];
      M m2[3];
   equation
      m1[:].x[:] = {{1,2},{3,4}};
      m2[1:2].x[:] = {{1,2},{3,4}};
      m2[3].x[:] = {1,2};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest11",
            description="Test scalarization of variables",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest11
 constant Real m1[1].x[1] = 1;
 constant Real m1[1].x[2] = 2;
 constant Real m1[2].x[1] = 3;
 constant Real m1[2].x[2] = 4;
 constant Real m2[1].x[1] = 1;
 constant Real m2[1].x[2] = 2;
 constant Real m2[2].x[1] = 3;
 constant Real m2[2].x[2] = 4;
 constant Real m2[3].x[1] = 1;
 constant Real m2[3].x[2] = 2;
end ArrayTests.General.ArrayTest11;
")})));
   end ArrayTest11;

      model ArrayTest12
        model M
              Real x[2];
        end M;

        model N
              M m[3];
        end N;
        N n[1];
      equation
        n.m.x={{{1,2},{3,4},{5,6}}};


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest12",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest12
 constant Real n[1].m[1].x[1] = 1;
 constant Real n[1].m[1].x[2] = 2;
 constant Real n[1].m[2].x[1] = 3;
 constant Real n[1].m[2].x[2] = 4;
 constant Real n[1].m[3].x[1] = 5;
 constant Real n[1].m[3].x[2] = 6;
end ArrayTests.General.ArrayTest12;
")})));
      end ArrayTest12;

  model ArrayTest13
    model C
      parameter Integer n = 2;
    end C;
    C c;
    C cv[c.n];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest13",
            description="Test scalarization of variables",
            flatModel="
fclass ArrayTests.General.ArrayTest13
 structural parameter Integer c.n = 2 /* 2 */;
 parameter Integer cv[1].n = 2 /* 2 */;
 parameter Integer cv[2].n = 2 /* 2 */;
end ArrayTests.General.ArrayTest13;
")})));
  end ArrayTest13;

      model ArrayTest14
        model M
              Real x[1] = ones(1);
        end M;

        model N
              M m[3,2];
        end N;
        N n;
      equation


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest14",
            description="Test scalarization of variables",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest14
 constant Real n.m[1,1].x[1] = 1;
 constant Real n.m[1,2].x[1] = 1;
 constant Real n.m[2,1].x[1] = 1;
 constant Real n.m[2,2].x[1] = 1;
 constant Real n.m[3,1].x[1] = 1;
 constant Real n.m[3,2].x[1] = 1;
end ArrayTests.General.ArrayTest14;
")})));
      end ArrayTest14;

model ArrayTest15_Err
   Real x[3] = {{2},{2},{3}};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="General_ArrayTest15_Err",
            description="Test type checking of arrays",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [3] and size of binding expression is [3, 1]
")})));
end ArrayTest15_Err;

model ArrayTest16_Err
  function f
  input Integer n;
  input Integer v[:];
  Integer x[n];
  Integer y[:];
  Integer z[2];
  output Integer o;
algorithm
  o := v[1] + x[1] + y[1] + z[1];
  x := fill(-1, 2);
  y := ones(o);
  z := zeros(2);
end f;

Integer x = f(2, {2, 2});

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="General_ArrayTest16_Err",
            description="Test type checking of arrays for unknown-size, non-input arrays in functions",
            errorMessage="
2 errors found:

Compliance error at line 10, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Using variables with undefined size is not supported

Compliance error at line 12, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Using variables with undefined size is not supported
")})));
end ArrayTest16_Err;

model ArrayTest17
  model N
    model M
      Real x[2];
	equation
	  x[2] = 1;
    end M;
    M m[2,1];
  end N;
  N n[2];
  equation
//  n.m.x=1;
  n.m.x[1]={{{1},{2}},{{3},{4}}};


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest17",
            description="Test scalarization of variables",
            eliminate_alias_variables=false,
            automatic_add_initial_equations=false,
            flatModel="
fclass ArrayTests.General.ArrayTest17
 constant Real n[1].m[1,1].x[1] = 1;
 constant Real n[1].m[1,1].x[2] = 1;
 constant Real n[1].m[2,1].x[1] = 2;
 constant Real n[1].m[2,1].x[2] = 1;
 constant Real n[2].m[1,1].x[1] = 3;
 constant Real n[2].m[1,1].x[2] = 1;
 constant Real n[2].m[2,1].x[1] = 4;
 constant Real n[2].m[2,1].x[2] = 1;
end ArrayTests.General.ArrayTest17;
")})));
end ArrayTest17;

model ArrayTest21
  Real x[2];
  Real y[2];
equation
  x=y;
  x=zeros(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest21",
            description="Flattening of arrays.",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest21
 constant Real x[1] = 0;
 constant Real x[2] = 0;
 constant Real y[1] = 0.0;
 constant Real y[2] = 0.0;
end ArrayTests.General.ArrayTest21;
")})));
end ArrayTest21;

model ArrayTest22
  Real x[2];
  Real y[2];
equation
  x=y;
  x=ones(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest22",
            description="Flattening of arrays.",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest22
 constant Real x[1] = 1;
 constant Real x[2] = 1;
 constant Real y[1] = 1.0;
 constant Real y[2] = 1.0;
end ArrayTests.General.ArrayTest22;
")})));
end ArrayTest22;

model ArrayTest23
  Real x[2,2];
  Real y[2,2];
equation
  x=y;
  x=ones(2,2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest23",
            description="Flattening of arrays.",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest23
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 1;
 constant Real x[2,1] = 1;
 constant Real x[2,2] = 1;
 constant Real y[1,1] = 1.0;
 constant Real y[1,2] = 1.0;
 constant Real y[2,1] = 1.0;
 constant Real y[2,2] = 1.0;
end ArrayTests.General.ArrayTest23;
")})));
end ArrayTest23;

model ArrayTest24

  Real x[2,2];
  Real y[2,2];
equation
  for i in 1:2, j in 1:2 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
  end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest24",
            description="Flattening of arrays.",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest24
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 1;
 constant Real x[2,1] = 2;
 constant Real x[2,2] = 2;
 constant Real y[1,1] = 2.0;
 constant Real y[1,2] = 3.0;
 constant Real y[2,1] = 3.0;
 constant Real y[2,2] = 4.0;
end ArrayTests.General.ArrayTest24;
")})));
end ArrayTest24;

model ArrayTest25

  Real x[2,3];
  Real y[2,3];
equation
  for i in 1:2 loop
   for j in 1:3 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
   end for;
  end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest25",
            description="Flattening of arrays.",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest25
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 1;
 constant Real x[1,3] = 1;
 constant Real x[2,1] = 2;
 constant Real x[2,2] = 2;
 constant Real x[2,3] = 2;
 constant Real y[1,1] = 2.0;
 constant Real y[1,2] = 3.0;
 constant Real y[1,3] = 4.0;
 constant Real y[2,1] = 3.0;
 constant Real y[2,2] = 4.0;
 constant Real y[2,3] = 5.0;
end ArrayTests.General.ArrayTest25;
")})));
end ArrayTest25;


model ArrayTest26

  Real x[4,4];
  Real y[4,4];
equation
  for i in 2:2:4 loop
   for j in 2:2:4 loop
    x[i,j] = i;
    y[i,j] = x[i,j]+j;
   end for;
  end for;
  for i in 1:2:4 loop
   for j in 1:2:4 loop
    x[i,j] = i+2;
    y[i,j] = x[i,j]+j+2;
   end for;
  end for;
  for i in 3:-2:1 loop
   for j in 1:2:4 loop
    x[i,j] = i+2;
    y[i,j] = x[i,j]+j+2;
   end for;
  end for;
  for i in 2:2:4 loop
   for j in 3:-2:1 loop
    x[i,j] = i+2;
    y[i,j] = x[i,j]+j+2;
   end for;
  end for;


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest26",
            description="Flattening of arrays.",
            eliminate_alias_variables=false,
            automatic_add_initial_equations=false,
            enable_structural_diagnosis=false,
            flatModel="
fclass ArrayTests.General.ArrayTest26
 constant Real x[1,1] = 3;
 Real x[1,2];
 constant Real x[1,3] = 3;
 Real x[1,4];
 constant Real x[2,1] = 4;
 constant Real x[2,2] = 2;
 constant Real x[2,3] = 4;
 constant Real x[2,4] = 2;
 constant Real x[3,1] = 5;
 Real x[3,2];
 constant Real x[3,3] = 5;
 Real x[3,4];
 constant Real x[4,1] = 6;
 constant Real x[4,2] = 4;
 constant Real x[4,3] = 6;
 constant Real x[4,4] = 4;
 constant Real y[1,1] = 6.0;
 Real y[1,2];
 constant Real y[1,3] = 8.0;
 Real y[1,4];
 constant Real y[2,1] = 7.0;
 constant Real y[2,2] = 4.0;
 constant Real y[2,3] = 9.0;
 constant Real y[2,4] = 6.0;
 constant Real y[3,1] = 8.0;
 Real y[3,2];
 constant Real y[3,3] = 10.0;
 Real y[3,4];
 constant Real y[4,1] = 9.0;
 constant Real y[4,2] = 6.0;
 constant Real y[4,3] = 11.0;
 constant Real y[4,4] = 8.0;
equation
 5.0 = 5;
 8.0 = 8.0;
 5.0 = 5;
 10.0 = 10.0;
 3.0 = 3;
 6.0 = 6.0;
 3.0 = 3;
 8.0 = 8.0;
end ArrayTests.General.ArrayTest26;
")})));
end ArrayTest26;


model ArrayTest27_Err
   Real x[3](start={1,2});
equation
   der(x) = ones(3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="General_ArrayTest27_Err",
            description="Test type checking of arrays",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION:
  Array size mismatch in modification of the attribute start for the variable x, expected size is [3] and size of start expression is [2]
")})));
end ArrayTest27_Err;


model ArrayTest29
   Real x[3](start={1,2,3});
equation
   der(x) = ones(3);


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest29",
            description="Flattening of arrays.",
            flatModel="
fclass ArrayTests.General.ArrayTest29
 Real x[1](start = 1);
 Real x[2](start = 2);
 Real x[3](start = 3);
initial equation 
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
equation
 der(x[1]) = 1;
 der(x[2]) = 1;
 der(x[3]) = 1;
end ArrayTests.General.ArrayTest29;
")})));
end ArrayTest29;

model ArrayTest30

   Real x[3,2](start={{1,2},{3,4},{5,6}});
equation
   der(x) = {{-1,-2},{-3,-4},{-5,-6}};


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest30",
            description="Flattening of arrays.",
            flatModel="
fclass ArrayTests.General.ArrayTest30
 Real x[1,1](start = 1);
 Real x[1,2](start = 2);
 Real x[2,1](start = 3);
 Real x[2,2](start = 4);
 Real x[3,1](start = 5);
 Real x[3,2](start = 6);
initial equation 
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;
 x[3,1] = 5;
 x[3,2] = 6;
equation
 der(x[1,1]) = -1;
 der(x[1,2]) = -2;
 der(x[2,1]) = -3;
 der(x[2,2]) = -4;
 der(x[3,1]) = -5;
 der(x[3,2]) = -6;
end ArrayTests.General.ArrayTest30;
")})));
end ArrayTest30;

model ArrayTest31
  Real x[2];
equation
 x = {sin(time),cos(time)};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest31",
            description="Flattening of arrays.",
            flatModel="
fclass ArrayTests.General.ArrayTest31
 Real x[1];
 Real x[2];
equation
 x[1] = sin(time);
 x[2] = cos(time);
end ArrayTests.General.ArrayTest31;
")})));
end ArrayTest31;

model ArrayTest32
 Real x[2];
initial equation
 x = {1,-2};
equation
 der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest32",
            description="Scalarization of initial equation",
            flatModel="
fclass ArrayTests.General.ArrayTest32
 Real x[1];
 Real x[2];
initial equation 
 x[1] = 1;
 x[2] = -2;
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
end ArrayTests.General.ArrayTest32;
")})));
end ArrayTest32;


model ArrayTest33
  model C
	Real x;
  equation
    x = 1;
  end C;
  
  C c[3];

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest33",
            description="Equations in array components",
            flatModel="
fclass ArrayTests.General.ArrayTest33
 Real c[1].x;
 Real c[2].x;
 Real c[3].x;
equation
 c[1].x = 1;
 c[2].x = 1;
 c[3].x = 1;
end ArrayTests.General.ArrayTest33;
")})));
end ArrayTest33;


model ArrayTest34
  model A
    B b[2];
  end A;
  
  model B
    Real x;
    C c[2];
  equation
    x = c[1].x;
  end B;
  
  model C
	Real x;
  equation
    x = 1;
  end C;
  
  A a[2];

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest34",
            description="Equations in array components",
            flatModel="
fclass ArrayTests.General.ArrayTest34
 Real a[1].b[1].x;
 Real a[1].b[1].c[1].x;
 Real a[1].b[1].c[2].x;
 Real a[1].b[2].x;
 Real a[1].b[2].c[1].x;
 Real a[1].b[2].c[2].x;
 Real a[2].b[1].x;
 Real a[2].b[1].c[1].x;
 Real a[2].b[1].c[2].x;
 Real a[2].b[2].x;
 Real a[2].b[2].c[1].x;
 Real a[2].b[2].c[2].x;
equation
 a[1].b[1].x = a[1].b[1].c[1].x;
 a[1].b[1].c[1].x = 1;
 a[1].b[1].c[2].x = 1;
 a[1].b[2].x = a[1].b[2].c[1].x;
 a[1].b[2].c[1].x = 1;
 a[1].b[2].c[2].x = 1;
 a[2].b[1].x = a[2].b[1].c[1].x;
 a[2].b[1].c[1].x = 1;
 a[2].b[1].c[2].x = 1;
 a[2].b[2].x = a[2].b[2].c[1].x;
 a[2].b[2].c[1].x = 1;
 a[2].b[2].c[2].x = 1;
end ArrayTests.General.ArrayTest34;
")})));
end ArrayTest34;


model ArrayTest35
	function f
		input Real[:] x;
		output Real[2 * size(x, 1) + 1] y = cat(1, x, zeros(size(x, 1) + 1));
	algorithm
	end f;
	
	Real[5] z = f({1,2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest35",
            description="Test adding array sizes that are present as expressions in tree",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.General.ArrayTest35
 constant Real z[1] = 1;
 constant Real z[2] = 2;
 constant Real z[3] = 0;
 constant Real z[4] = 0;
 constant Real z[5] = 0;
end ArrayTests.General.ArrayTest35;
")})));
end ArrayTest35;


model ArrayTest36
	model A
		Real x = b;
		parameter Real b = 1;
	end A;
	
	A[3] c(b = { j*j for j in 1:3 });

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest36",
            description="",
            flatModel="
fclass ArrayTests.General.ArrayTest36
 parameter Real c[1].x;
 parameter Real c[1].b = 1 /* 1 */;
 parameter Real c[2].x;
 parameter Real c[2].b = 4 /* 4 */;
 parameter Real c[3].x;
 parameter Real c[3].b = 9 /* 9 */;
parameter equation
 c[1].x = c[1].b;
 c[2].x = c[2].b;
 c[3].x = c[3].b;
end ArrayTests.General.ArrayTest36;
")})));
end ArrayTest36;


model ArrayTest37
    package A
        constant Integer n = 2;
        type B = Real[n];
    end A;
    
    A.B x = 1:A.n;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest37",
            description="",
            flatModel="
fclass ArrayTests.General.ArrayTest37
 ArrayTests.General.ArrayTest37.A.B x[2] = 1:2;

public
 type ArrayTests.General.ArrayTest37.A.B = Real;
end ArrayTests.General.ArrayTest37;
")})));
end ArrayTest37;


model ArrayTest38
    model A
        Real x;
    end A;
    
    parameter Integer n = 0;
    A[n] a(x = ones(n));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest38",
            description="Modification on variable in zero-size component array",
            flatModel="
fclass ArrayTests.General.ArrayTest38
 structural parameter Integer n = 0 /* 0 */;
end ArrayTests.General.ArrayTest38;
")})));
end ArrayTest38;

model ArrayTest39
    function f
        input Integer n;
        input Real t;
        output Real[n] o;
      algorithm
        o := {t for i in 1:n};
    end f;

    parameter Integer n = 0;
    parameter Real[n] y;
    parameter Real p = 1;
    parameter Real[n] a;
  initial equation
    y = f(n, p);
    a = y;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest39",
            description="Initial equation for size zero array",
            flatModel="
fclass ArrayTests.General.ArrayTest39
 structural parameter Integer n = 0 /* 0 */;
 parameter Real p = 1 /* 1 */;
end ArrayTests.General.ArrayTest39;
")})));
end ArrayTest39;


model ArrayTest40
    function f
        input Integer n;
        input Real t;
        output Real[n] o;
      algorithm
        o := {t for i in 1:n};
    end f;

    parameter Integer n = 0;
    parameter Real[n] y(start=f(n, p));
    parameter Real p = 1;
    parameter Real[n] a = y;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest40",
            description="Start value for size zero array",
            flatModel="
fclass ArrayTests.General.ArrayTest40
 structural parameter Integer n = 0 /* 0 */;
 parameter Real p = 1 /* 1 */;
end ArrayTests.General.ArrayTest40;
")})));
end ArrayTest40;


model ArrayTest41
    model A
        Real x;
    end A;
    
    parameter Integer N = 3;
    Real y[N] = (1:N) ./ time;
    A a[N](x = y[1:N]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest41",
            description="Splitting expression with access in array subscripts",
            flatModel="
fclass ArrayTests.General.ArrayTest41
 structural parameter Integer N = 3 /* 3 */;
 Real y[3] = (1:3) ./ time;
 Real a[1].x = y[1];
 Real a[2].x = y[2];
 Real a[3].x = y[3];
end ArrayTests.General.ArrayTest41;
")})));
end ArrayTest41;


model ArrayTest42
    Real x = noEvent(f());

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="General_ArrayTest42",
            description="Using noEvent on expression that gives ndims = -1",
            errorMessage="
1 errors found:

Error at line 2, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Cannot find function declaration for f()
")})));
end ArrayTest42;


model ArrayTest43
    model A
        Real x;
    end A;
    
    model B
		parameter Integer m;
        Real y[m] = (1:m) ./ time;
    end B;
    
    parameter Integer n = 3;
    A a[n](x = b.y[1:n]);
	B b(m = n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest43",
            description="Splitting expression with access in array subscripts in part of dotted access",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.General.ArrayTest43
 structural parameter Integer n = 3 /* 3 */;
 Real a[1].x;
 Real a[2].x;
 Real a[3].x;
 structural parameter Integer b.m = 3 /* 3 */;
 Real b.y[1];
 Real b.y[2];
 Real b.y[3];
equation
 a[1].x = b.y[1];
 a[2].x = b.y[2];
 a[3].x = b.y[3];
 b.y[1] = 1 ./ time;
 b.y[2] = 2 ./ time;
 b.y[3] = 3 ./ time;
end ArrayTests.General.ArrayTest43;
")})));
end ArrayTest43;


model ArrayTest44
    constant Real a[2] = {1, 2};
    
    model B
        Real x[2,2];
    equation
        for i in 1:2 loop
            x[:,i] = { a[i] + j * time for j in 1:2 };
        end for;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest44",
            description="Using loop index of surrounding for loop to index array package constant used in iteration exception",
            flatModel="
fclass ArrayTests.General.ArrayTest44
 constant Real a[1] = 1;
 constant Real a[2] = 2;
 Real b.x[1,1];
 Real b.x[1,2];
 Real b.x[2,1];
 Real b.x[2,2];
equation
 b.x[1,1] = 1.0 + time;
 b.x[2,1] = 2 * b.x[1,1] + -1;
 b.x[1,2] = b.x[1,1] + 1;
 b.x[2,2] = 2 * b.x[1,1];
end ArrayTests.General.ArrayTest44;
")})));
end ArrayTest44;


model ArrayTest45
    constant Real a[2,2] = {{1, 2}, {3, 4}};
    
    model B
        Real x[2] = { a[j,i] + i * time for i in 1:2 };
        parameter Integer j = 1;
    end B;
    
    B b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest45",
            description="Using parameter to index array package constant used in iteration exception",
            flatModel="
fclass ArrayTests.General.ArrayTest45
 constant Real a[1,1] = 1;
 constant Real a[1,2] = 2;
 constant Real a[2,1] = 3;
 constant Real a[2,2] = 4;
 Real b.x[1];
 Real b.x[2];
 parameter Integer b.j = 1 /* 1 */;
equation
 b.x[1] = ({1.0, 3.0})[b.j] + time;
 b.x[2] = ({2.0, 4.0})[b.j] + 2 * time;
end ArrayTests.General.ArrayTest45;
")})));
end ArrayTest45;


model ArrayTest46
    Real x[0] = 1:-1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest46",
            description="Check that range exp with negative end is handled properly",
            flatModel="
fclass ArrayTests.General.ArrayTest46
end ArrayTests.General.ArrayTest46;
")})));
end ArrayTest46;


model ArrayTest47
    record R
        Real x;
    end R;
    connector R_input = input R;
    connector R_output = output R;
    record B
        constant Integer n = 2;
        R_output r[n];
    end B;
    
    inner B b;
    
    model C
        outer B b;
        R_input r[b.n];
    equation
    end C;
    
    C c;
equation
    connect(b.r, c.r);
    for i in 1:b.n loop
        b.r[i].x = 1;
    end for;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="General_ArrayTest47",
        description="",
        flatModel="
fclass ArrayTests.General.ArrayTest47
 ArrayTests.General.ArrayTest47.B b(n = 2,r(size() = {2}));
 ArrayTests.General.ArrayTest47.R_input c.r[2];
equation
 b.r[1].x = 1;
 b.r[2].x = 1;
 b.r[1].x = c.r[1].x;
 b.r[2].x = c.r[2].x;

public
 record ArrayTests.General.ArrayTest47.R_output
  potential Real x;
 end ArrayTests.General.ArrayTest47.R_output;

 record ArrayTests.General.ArrayTest47.B
  constant Integer n;
  output ArrayTests.General.ArrayTest47.R_output r[2];
 end ArrayTests.General.ArrayTest47.B;

 record ArrayTests.General.ArrayTest47.R_input
  potential Real x;
 end ArrayTests.General.ArrayTest47.R_input;

end ArrayTests.General.ArrayTest47;
")})));
end ArrayTest47;

model ArrayTest48
    constant Integer n = 2;
    function f
        output Real[n] y = 1:n;
        algorithm
    end f;
    constant Real[n] y1 = f();
    constant Real[n] y2 = f();
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest48",
            description="",
            flatModel="
fclass ArrayTests.General.ArrayTest48
 constant Integer n = 2;
 constant Real y1[2] = {1, 2};
 constant Real y2[2] = {1, 2};

public
 function ArrayTests.General.ArrayTest48.f
  output Real[:] y;
 algorithm
  init y as Real[2];
  y := 1:2;
  return;
 end ArrayTests.General.ArrayTest48.f;

end ArrayTests.General.ArrayTest48;
")})));
end ArrayTest48;

model ArrayTest49
    record R
        Real[:] x;
    end R;
    
    R[:] r(x(start={1})) = {R({time})};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest49",
            description="",
            flatModel="
fclass ArrayTests.General.ArrayTest49
 Real r[1].x[1](start = 1);
equation
 r[1].x[1] = time;
end ArrayTests.General.ArrayTest49;
")})));
end ArrayTest49;

model ArrayTest50
    model B
        outer Real x;
    end B;
    
    model A
        inner Real x;
        B b;
    end A;
    
    A[2] a(x={time,time+1});
    Real[:] y = a.b.x;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest50",
            description="Flattening outer access in array",
            flatModel="
fclass ArrayTests.General.ArrayTest50
 Real y[1];
 Real y[2];
equation
 y[1] = time;
 y[2] = time + 1;
end ArrayTests.General.ArrayTest50;
")})));
end ArrayTest50;

model ArrayTest51
    model M
        Real x;
    end M;
    
    M[1] m;
equation
    der(m.x) = {0};
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="General_ArrayTest51",
            description="Flattening outer access in array",
            flatModel="
fclass ArrayTests.General.ArrayTest51
 Real m[1].x;
equation
 {der(m[1].x)} = {0};
end ArrayTests.General.ArrayTest51;
")})));
end ArrayTest51;

model ArrayTest52
        model M
            constant Real x;
        end M;
        
        M[0] m(x=1:0);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest52",
            description="Binding expression in modifier on empty array #5443",
            flatModel="
fclass ArrayTests.General.ArrayTest52
end ArrayTests.General.ArrayTest52;
")})));
end ArrayTest52;

model ArrayTest53
        model M
            parameter Real x;
        end M;
        
        M[0] m(final x=1:0);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest53",
            description="Binding expression in modifier on empty array #5443",
            flatModel="
fclass ArrayTests.General.ArrayTest53
end ArrayTests.General.ArrayTest53;
")})));
end ArrayTest53;

model ArrayTest54
        model M
            Real[0] x;
        end M;
        
        M[1] m(x= {1:0});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="General_ArrayTest54",
            description="Binding expression in modifier on empty array #5443",
            flatModel="
fclass ArrayTests.General.ArrayTest54
end ArrayTests.General.ArrayTest54;
")})));
end ArrayTest54;


model ArrayTest55
    record A
        extends B(c = D());
    end A;
    
    record B
        parameter C c annotation(Evaluate=true);
    end B;
    
    record C
        parameter Real x[:,2];
    end C;
    
    record D
        extends C(x = {{1.5 * mod(i - 1, 10), 1.5 * floor((i - 1) / 10)} for i in 1:100});
    end D;
    
    parameter A a;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="General_ArrayTest55",
        description="",
        flatModel="
fclass ArrayTests.General.ArrayTest55
 eval parameter ArrayTests.General.ArrayTest55.A a(c(x(size() = {100, 2}))) = ArrayTests.General.ArrayTest55.A(ArrayTests.General.ArrayTest55.D({{0.0, 0.0}, {1.5, 0.0}, {3.0, 0.0}, {4.5, 0.0}, {6.0, 0.0}, {7.5, 0.0}, {9.0, 0.0}, {10.5, 0.0}, {12.0, 0.0}, {13.5, 0.0}, {0.0, 1.5}, {1.5, 1.5}, {3.0, 1.5}, {4.5, 1.5}, {6.0, 1.5}, {7.5, 1.5}, {9.0, 1.5}, {10.5, 1.5}, {12.0, 1.5}, {13.5, 1.5}, {0.0, 3.0}, {1.5, 3.0}, {3.0, 3.0}, {4.5, 3.0}, {6.0, 3.0}, {7.5, 3.0}, {9.0, 3.0}, {10.5, 3.0}, {12.0, 3.0}, {13.5, 3.0}, {0.0, 4.5}, {1.5, 4.5}, {3.0, 4.5}, {4.5, 4.5}, {6.0, 4.5}, {7.5, 4.5}, {9.0, 4.5}, {10.5, 4.5}, {12.0, 4.5}, {13.5, 4.5}, {0.0, 6.0}, {1.5, 6.0}, {3.0, 6.0}, {4.5, 6.0}, {6.0, 6.0}, {7.5, 6.0}, {9.0, 6.0}, {10.5, 6.0}, {12.0, 6.0}, {13.5, 6.0}, {0.0, 7.5}, {1.5, 7.5}, {3.0, 7.5}, {4.5, 7.5}, {6.0, 7.5}, {7.5, 7.5}, {9.0, 7.5}, {10.5, 7.5}, {12.0, 7.5}, {13.5, 7.5}, {0.0, 9.0}, {1.5, 9.0}, {3.0, 9.0}, {4.5, 9.0}, {6.0, 9.0}, {7.5, 9.0}, {9.0, 9.0}, {10.5, 9.0}, {12.0, 9.0}, {13.5, 9.0}, {0.0, 10.5}, {1.5, 10.5}, {3.0, 10.5}, {4.5, 10.5}, {6.0, 10.5}, {7.5, 10.5}, {9.0, 10.5}, {10.5, 10.5}, {12.0, 10.5}, {13.5, 10.5}, {0.0, 12.0}, {1.5, 12.0}, {3.0, 12.0}, {4.5, 12.0}, {6.0, 12.0}, {7.5, 12.0}, {9.0, 12.0}, {10.5, 12.0}, {12.0, 12.0}, {13.5, 12.0}, {0.0, 13.5}, {1.5, 13.5}, {3.0, 13.5}, {4.5, 13.5}, {6.0, 13.5}, {7.5, 13.5}, {9.0, 13.5}, {10.5, 13.5}, {12.0, 13.5}, {13.5, 13.5}})) /* ArrayTests.General.ArrayTest55.A(ArrayTests.General.ArrayTest55.D({ { 0.0, 0.0 }, { 1.5, 0.0 }, { 3.0, 0.0 }, { 4.5, 0.0 }, { 6.0, 0.0 }, { 7.5, 0.0 }, { 9.0, 0.0 }, { 10.5, 0.0 }, { 12.0, 0.0 }, { 13.5, 0.0 }, { 0.0, 1.5 }, { 1.5, 1.5 }, { 3.0, 1.5 }, { 4.5, 1.5 }, { 6.0, 1.5 }, { 7.5, 1.5 }, { 9.0, 1.5 }, { 10.5, 1.5 }, { 12.0, 1.5 }, { 13.5, 1.5 }, { 0.0, 3.0 }, { 1.5, 3.0 }, { 3.0, 3.0 }, { 4.5, 3.0 }, { 6.0, 3.0 }, { 7.5, 3.0 }, { 9.0, 3.0 }, { 10.5, 3.0 }, { 12.0, 3.0 }, { 13.5, 3.0 }, { 0.0, 4.5 }, { 1.5, 4.5 }, { 3.0, 4.5 }, { 4.5, 4.5 }, { 6.0, 4.5 }, { 7.5, 4.5 }, { 9.0, 4.5 }, { 10.5, 4.5 }, { 12.0, 4.5 }, { 13.5, 4.5 }, { 0.0, 6.0 }, { 1.5, 6.0 }, { 3.0, 6.0 }, { 4.5, 6.0 }, { 6.0, 6.0 }, { 7.5, 6.0 }, { 9.0, 6.0 }, { 10.5, 6.0 }, { 12.0, 6.0 }, { 13.5, 6.0 }, { 0.0, 7.5 }, { 1.5, 7.5 }, { 3.0, 7.5 }, { 4.5, 7.5 }, { 6.0, 7.5 }, { 7.5, 7.5 }, { 9.0, 7.5 }, { 10.5, 7.5 }, { 12.0, 7.5 }, { 13.5, 7.5 }, { 0.0, 9.0 }, { 1.5, 9.0 }, { 3.0, 9.0 }, { 4.5, 9.0 }, { 6.0, 9.0 }, { 7.5, 9.0 }, { 9.0, 9.0 }, { 10.5, 9.0 }, { 12.0, 9.0 }, { 13.5, 9.0 }, { 0.0, 10.5 }, { 1.5, 10.5 }, { 3.0, 10.5 }, { 4.5, 10.5 }, { 6.0, 10.5 }, { 7.5, 10.5 }, { 9.0, 10.5 }, { 10.5, 10.5 }, { 12.0, 10.5 }, { 13.5, 10.5 }, { 0.0, 12.0 }, { 1.5, 12.0 }, { 3.0, 12.0 }, { 4.5, 12.0 }, { 6.0, 12.0 }, { 7.5, 12.0 }, { 9.0, 12.0 }, { 10.5, 12.0 }, { 12.0, 12.0 }, { 13.5, 12.0 }, { 0.0, 13.5 }, { 1.5, 13.5 }, { 3.0, 13.5 }, { 4.5, 13.5 }, { 6.0, 13.5 }, { 7.5, 13.5 }, { 9.0, 13.5 }, { 10.5, 13.5 }, { 12.0, 13.5 }, { 13.5, 13.5 } })) */;

public
 record ArrayTests.General.ArrayTest55.C
  parameter Real x[:,2];
 end ArrayTests.General.ArrayTest55.C;

 record ArrayTests.General.ArrayTest55.A
  parameter ArrayTests.General.ArrayTest55.C c;
 end ArrayTests.General.ArrayTest55.A;

 record ArrayTests.General.ArrayTest55.D
  parameter Real x[:,2];
 end ArrayTests.General.ArrayTest55.D;

end ArrayTests.General.ArrayTest55;
")})));
end ArrayTest55;


end General;


package UnknownSize

model UnknownSize1
 Real x[:,:] = {{1,2},{3,4}};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_UnknownSize1",
            description="Using unknown array sizes: deciding with binding exp",
            flatModel="
fclass ArrayTests.UnknownSize.UnknownSize1
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 4;
end ArrayTests.UnknownSize.UnknownSize1;
")})));
end UnknownSize1;


model UnknownSize2
 model A
  Real z[:] = {1};
 end A;
 
 model B
  A y[2](z={{1,2},{3,4}});
 end B;
 
 B x[2];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_UnknownSize2",
            description="Using unknown array sizes: binding exp through modification on array",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.UnknownSize.UnknownSize2
 constant Real x[1].y[1].z[1] = 1;
 constant Real x[1].y[1].z[2] = 2;
 constant Real x[1].y[2].z[1] = 3;
 constant Real x[1].y[2].z[2] = 4;
 constant Real x[2].y[1].z[1] = 1;
 constant Real x[2].y[1].z[2] = 2;
 constant Real x[2].y[2].z[1] = 3;
 constant Real x[2].y[2].z[2] = 4;
end ArrayTests.UnknownSize.UnknownSize2;
")})));
end UnknownSize2;


model UnknownSize3
 Real x[1,:] = {{1,2}};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="UnknownSize_UnknownSize3",
            description="Using unknown array sizes: one dim known, one unknown",
            flatModel="
fclass ArrayTests.UnknownSize.UnknownSize3
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
end ArrayTests.UnknownSize.UnknownSize3;
")})));
end UnknownSize3;


model UnknownSize4
 Real x[1,:] = {1,2};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownSize_UnknownSize4",
            description="Using unknown array sizes: too few dims",
            errorMessage="
2 errors found:

Error at line 2, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE:
  Can not infer array size of the variable x

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [1, :] and size of binding expression is [2]
")})));
end UnknownSize4;


model UnknownSize5
 Real x[1,:] = {{1,2},{3,4}};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownSize_UnknownSize5",
            description="Using unknown array sizes: one dim specified and does not match",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [1, 2] and size of binding expression is [2, 2]
")})));
end UnknownSize5;


model UnknownSize6
 Real x[:,:];
equation
 x = {{1,2},{3,4}};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="UnknownSize_UnknownSize6",
            description="Using unknown array sizes:",
            errorMessage="
2 errors found:

Error at line 2, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE:
  Can not infer array size of the variable x

Error at line 4, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', ARRAY_SIZE_MISMATCH_IN_EQUATION:
  The array sizes of right and left hand side of equation are not compatible, size of left-hand side is [size(x, 1), size(x, 2)], and size of right-hand side is [2, 2]
")})));
end UnknownSize6;

end UnknownSize;


package Subscripts
	
model SubscriptExpression1
 Real x[4];
equation
 x[1] = 1;
 for i in 2:4 loop
  x[i] = x[i-1] * 2;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_SubscriptExpression1",
            description="Replacing expressions in array subscripts with literals: basic test",
            flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression1
 constant Real x[1] = 1;
 constant Real x[2] = 2.0;
 constant Real x[3] = 4.0;
 constant Real x[4] = 8.0;
end ArrayTests.Subscripts.SubscriptExpression1;
")})));
end SubscriptExpression1;


model SubscriptExpression2
 Real x[4];
equation
 x[0] = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_SubscriptExpression2",
            description="Type checking array subscripts: literal < 1",
            errorMessage="
1 errors found:

Error at line 4, column 4, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 0, index expression: 0
")})));
end SubscriptExpression2;


model SubscriptExpression3
 Real x[4];
equation
 x[5] = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_SubscriptExpression3",
            description="Type checking array subscripts: literal > end",
            errorMessage="
1 errors found:

Error at line 4, column 4, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 5, index expression: 5
")})));
end SubscriptExpression3;


model SubscriptExpression4
 Real x[4];
equation
 for i in 1:4 loop
  x[i] = x[i-1] * 2;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_SubscriptExpression4",
            description="Type checking array subscripts: expression < 1",
            errorMessage="
1 errors found:

Error at line 5, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 0, index expression: i - 1
")})));
end SubscriptExpression4;


model SubscriptExpression5
 Real x[4];
equation
 for i in 1:4 loop
  x[i] = x[i+1] * 2;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_SubscriptExpression5",
            description="Type checking array subscripts: expression > end",
            errorMessage="
1 errors found:

Error at line 5, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 5, index expression: i + 1
")})));
end SubscriptExpression5;


model SubscriptExpression6
 Real x[16];
equation
 for i in 1:4, j in 1:4 loop
  x[4*(i-1) + j] = i + j * 2;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_SubscriptExpression6",
            description="Type checking array subscripts: simulating [4,4] with [16]",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression6
 constant Real x[1] = 3;
 constant Real x[2] = 5;
 constant Real x[3] = 7;
 constant Real x[4] = 9;
 constant Real x[5] = 4;
 constant Real x[6] = 6;
 constant Real x[7] = 8;
 constant Real x[8] = 10;
 constant Real x[9] = 5;
 constant Real x[10] = 7;
 constant Real x[11] = 9;
 constant Real x[12] = 11;
 constant Real x[13] = 6;
 constant Real x[14] = 8;
 constant Real x[15] = 10;
 constant Real x[16] = 12;
end ArrayTests.Subscripts.SubscriptExpression6;
")})));
end SubscriptExpression6;


model SubscriptExpression7
 Real x[4,4];
equation
 for i in 1:4, j in 1:4 loop
  x[i, j + i - min(i, j)] = i + j * 2;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_SubscriptExpression7",
            description="Type checking array subscripts: using min in subscripts",
            eliminate_alias_variables=false,
            automatic_add_initial_equations=false,
            enable_structural_diagnosis=false,
            flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression7
 constant Real x[1,1] = 3;
 constant Real x[1,2] = 5;
 constant Real x[1,3] = 7;
 constant Real x[1,4] = 9;
 Real x[2,1];
 constant Real x[2,2] = 4;
 constant Real x[2,3] = 8;
 constant Real x[2,4] = 10;
 Real x[3,1];
 Real x[3,2];
 constant Real x[3,3] = 5;
 constant Real x[3,4] = 11;
 Real x[4,1];
 Real x[4,2];
 Real x[4,3];
 constant Real x[4,4] = 6;
equation
 4.0 = 6;
 5.0 = 7;
 5.0 = 9;
 6.0 = 8;
 6.0 = 10;
 6.0 = 12;
end ArrayTests.Subscripts.SubscriptExpression7;
")})));
end SubscriptExpression7;


model SubscriptExpression8
 Real x[4];
equation
 for i in 1:4, j in 1:4 loop
  x[i + j * max(i*(1:4))] = i + j * 2;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_SubscriptExpression8",
            description="Type checking array subscripts: complex expression, several bad indices",
            errorMessage="
1 errors found:

Error at line 5, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 5, index expression: i + j * max(i * (1:4))
")})));
end SubscriptExpression8;


model SubscriptExpression9
    connector C = Real;
    C x[3], y;
equation
    for i in 1:3 loop
        if i < 3 then
            connect(x[i], x[i+1]);
        else
            connect(x[i], y);
        end if;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Subscripts_SubscriptExpression9",
            description="",
            flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression9
 Real x[3];
 Real y;
equation
 x[1] = x[2];
 x[2] = x[3];
 x[3] = y;
end ArrayTests.Subscripts.SubscriptExpression9;
")})));
end SubscriptExpression9;

model SubscriptExpression10
    record R
        Real a;
    end R;
    
    function f1
        input R x;
        output Real y;
    algorithm
        y := x.a;
        y := y + 1;
    end f1;
    
    function f2
        input Real x;
        output R y;
    algorithm
        x := x - 1;
        y.a := x;
    end f2;
    
    model M
        parameter Real b = 1;
    end M;
    
    parameter Real c[3] = { 1, 2, 3 };
    M m[3](b = f1(f2(c)));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_SubscriptExpression10",
            description="",
            inline_functions="none",
            flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression10
 parameter Real c[1] = 1 /* 1 */;
 parameter Real c[2] = 2 /* 2 */;
 parameter Real c[3] = 3 /* 3 */;
 parameter Real m[1].b;
 parameter Real m[2].b;
 parameter Real m[3].b;
parameter equation
 m[1].b = ArrayTests.Subscripts.SubscriptExpression10.f1(ArrayTests.Subscripts.SubscriptExpression10.f2(c[1]));
 m[2].b = ArrayTests.Subscripts.SubscriptExpression10.f1(ArrayTests.Subscripts.SubscriptExpression10.f2(c[2]));
 m[3].b = ArrayTests.Subscripts.SubscriptExpression10.f1(ArrayTests.Subscripts.SubscriptExpression10.f2(c[3]));

public
 function ArrayTests.Subscripts.SubscriptExpression10.f1
  input ArrayTests.Subscripts.SubscriptExpression10.R x;
  output Real y;
 algorithm
  y := x.a;
  y := y + 1;
  return;
 end ArrayTests.Subscripts.SubscriptExpression10.f1;

 function ArrayTests.Subscripts.SubscriptExpression10.f2
  input Real x;
  output ArrayTests.Subscripts.SubscriptExpression10.R y;
 algorithm
  x := x - 1;
  y.a := x;
  return;
 end ArrayTests.Subscripts.SubscriptExpression10.f2;

 record ArrayTests.Subscripts.SubscriptExpression10.R
  Real a;
 end ArrayTests.Subscripts.SubscriptExpression10.R;

end ArrayTests.Subscripts.SubscriptExpression10;
")})));
end SubscriptExpression10;

model SubscriptExpression11
    parameter Integer n1 = 2;
    parameter Integer n2[n1] = {2,3};
    Real x[sum(n2)];
equation
    for i in 1:n1 loop
        for j in 1:n2[i] loop
            x[sum(n2[k] for k in 1:(i - 1)) + j] = sin(time) * i * j;
        end for;
    end for;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_SubscriptExpression11",
            description="Scalarization of subscript expression #5216",
            inline_functions="none",
            flatModel="
fclass ArrayTests.Subscripts.SubscriptExpression11
 structural parameter Integer n1 = 2 /* 2 */;
 structural parameter Integer n2[2] = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
 Real x[5];
equation
 x[1] = sin(time);
 x[2] = sin(time) * 2;
 x[3] = sin(time) * 2;
 x[4] = sin(time) * 2 * 2;
 x[5] = sin(time) * 2 * 3;
end ArrayTests.Subscripts.SubscriptExpression11;
")})));
end SubscriptExpression11;


model NumSubscripts1
 Real x = 1;
 Real y = x[1];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_NumSubscripts1",
            description="Check number of array subscripts:",
            errorMessage="
1 errors found:

Error at line 3, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Too many array subscripts for access: 1 subscripts given, component has 0 dimensions
")})));
end NumSubscripts1;


model NumSubscripts2
 Real x[1,1] = {{1}};
 Real y = x[1,1,1];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_NumSubscripts2",
            description="Check number of array subscripts:",
            errorMessage="
1 errors found:

Error at line 3, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Too many array subscripts for access: 3 subscripts given, component has 2 dimensions
")})));
end NumSubscripts2;

model Enum1
    type ShirtSizes = enumeration(small, medium, large, xlarge);
    Real[ShirtSizes] w;
  equation
    w[ShirtSizes.small:ShirtSizes.large] = {1,1.5,2};
  algorithm
    w[ShirtSizes.xlarge] := 2.28;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_Enum1",
            description="Test subscripting with enums.",
            flatModel="
fclass ArrayTests.Subscripts.Enum1
 constant Real w[1] = 1;
 constant Real w[2] = 1.5;
 constant Real w[3] = 2;
 Real w[4];
algorithm
 w[4] := 2.28;

public
 type ArrayTests.Subscripts.Enum1.ShirtSizes = enumeration(small, medium, large, xlarge);

end ArrayTests.Subscripts.Enum1;
")})));
end Enum1;

model Enum2
    type ShirtSizes = enumeration(small, medium, large, xlarge);
    type ShirtSizesAnotherStandard = enumeration(small1, medium2, large3, xlarge4);
    Real[ShirtSizes] w;
    Real[1] v;
  equation
    w[ShirtSizes.small:ShirtSizes.large] = {1,1.5,2};
    w[4] = 2.28;
    v[ShirtSizes.medium] = 1;
    w[ShirtSizesAnotherStandard.small1] = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_Enum2",
            description="Check incompatible type index errors for enum.",
            errorMessage="
3 errors found:

Error at line 8, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Expected array index of type 'ArrayTests.Subscripts.Enum2.ShirtSizes' found 'Integer'

Error at line 9, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Expected array index of type 'Integer' found 'ArrayTests.Subscripts.Enum2.ShirtSizes'

Error at line 10, column 7, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Expected array index of type 'ArrayTests.Subscripts.Enum2.ShirtSizes' found 'ArrayTests.Subscripts.Enum2.ShirtSizesAnotherStandard'
")})));
end Enum2;

model Bool1
    Real[Boolean] b2;
  equation
    b2[false] = 5;
  algorithm
    b2[true] := 10.0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_Bool1",
            description="Test subscripting with bools.",
            flatModel="
fclass ArrayTests.Subscripts.Bool1
 constant Real b2[1] = 5;
 Real b2[2];
algorithm
 b2[2] := 10.0;
end ArrayTests.Subscripts.Bool1;
")})));
end Bool1;

model Bool2
    Real[Boolean] b2;
    Real[1] b3;
  equation
    b2[false] = 5;
    b2[2] = 10.0;
    b3[true] = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Subscripts_Bool2",
            description="Check incompatible type index errors for bool.",
            errorMessage="
2 errors found:

Error at line 6, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Expected array index of type 'Boolean' found 'Integer'

Error at line 7, column 8, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Expected array index of type 'Integer' found 'Boolean'
")})));
end Bool2;

model MixedTypes1
    
    type ShirtSizes  = enumeration(small);
    type ShirtColors = enumeration(blue, yellow);
    type SlimFit = Boolean;
    parameter Integer maxQuality = 1;
    
    Integer[ShirtSizes, maxQuality, ShirtColors, SlimFit] stock;
  equation
    stock[ShirtSizes.small, 1, ShirtColors.blue:ShirtColors.yellow, false] = {1,2};
    stock[ShirtSizes.small, 1, ShirtColors.blue:ShirtColors.yellow, true]  = {0,0};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_MixedTypes1",
            description="Test subscripting with bools.",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Subscripts.MixedTypes1
 structural parameter Integer maxQuality = 1 /* 1 */;
 constant Integer stock[1,1,1,1] = 1;
 constant Integer stock[1,1,1,2] = 0;
 constant Integer stock[1,1,2,1] = 2;
 constant Integer stock[1,1,2,2] = 0;

public
 type ArrayTests.Subscripts.MixedTypes1.ShirtSizes = enumeration(small);

 type ArrayTests.Subscripts.MixedTypes1.ShirtColors = enumeration(blue, yellow);

end ArrayTests.Subscripts.MixedTypes1;
")})));
end MixedTypes1;


model EndSubscript1
    record A
        Real x;
    end A;
    
    A a[2] = {A(time), A(2* time)};
    Real x = a[end].x + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Subscripts_EndSubscript1",
            description="Using end in access to member of last record in array of records",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.Subscripts.EndSubscript1
 Real a[1].x;
 Real a[2].x;
 Real x;
equation
 a[1].x = time;
 a[2].x = 2 * time;
 x = a[2].x + 1;
end ArrayTests.Subscripts.EndSubscript1;
")})));
end EndSubscript1;

model EndSubscript2
    record R
        parameter Integer n;
        Real[n] x;
    end R;
    
    function f
        input R r;
        output Real x = r.x[end];
        algorithm
    end f;
    
    Real x = f(R(2,1:2));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Subscripts_EndSubscript2",
            description="Using end in record with parameter size in function",
            flatModel="
fclass ArrayTests.Subscripts.EndSubscript2
 Real x = ArrayTests.Subscripts.EndSubscript2.f(ArrayTests.Subscripts.EndSubscript2.R(2, 1:2));

public
 function ArrayTests.Subscripts.EndSubscript2.f
  input ArrayTests.Subscripts.EndSubscript2.R r;
  output Real x;
 algorithm
  assert(r.n == size(r.x, 1), \"Mismatching sizes in function 'ArrayTests.Subscripts.EndSubscript2.f', component 'r.x', dimension '1'\");
  x := r.x[r.n];
  return;
 end ArrayTests.Subscripts.EndSubscript2.f;

 record ArrayTests.Subscripts.EndSubscript2.R
  parameter Integer n;
  Real x[n];
 end ArrayTests.Subscripts.EndSubscript2.R;

end ArrayTests.Subscripts.EndSubscript2;
")})));
end EndSubscript2;


end Subscripts;



/* ========== Array algebra ========== */
package Algebra

package Add
	
model ArrayAdd1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayAdd1",
            description="Scalarization of addition: Real[2] + Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayAdd1
 constant Real x[1] = 11.0;
 constant Real x[2] = 22.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Add.ArrayAdd1;
")})));
end ArrayAdd1;


model ArrayAdd2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayAdd2",
            description="Scalarization of addition: Real[2,2] + Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayAdd2
 constant Real x[1,1] = 11.0;
 constant Real x[1,2] = 22.0;
 constant Real x[2,1] = 33.0;
 constant Real x[2,2] = 44.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Add.ArrayAdd2;
")})));
end ArrayAdd2;


model ArrayAdd3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayAdd3",
            description="Scalarization of addition: Real[2,2,2] + Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayAdd3
 constant Real x[1,1,1] = 11.0;
 constant Real x[1,1,2] = 22.0;
 constant Real x[1,2,1] = 33.0;
 constant Real x[1,2,2] = 44.0;
 constant Real x[2,1,1] = 55.0;
 constant Real x[2,1,2] = 66.0;
 constant Real x[2,2,1] = 77.0;
 constant Real x[2,2,2] = 88.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Add.ArrayAdd3;
")})));
end ArrayAdd3;


model ArrayAdd4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + 10;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd4",
            description="Scalarization of addition: Real[2] + Integer",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + 10
    type of 'y' is Real[2]
    type of '10' is Integer
")})));
end ArrayAdd4;


model ArrayAdd5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y + 10;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd5",
            description="Scalarization of addition: Real[2,2] + Integer",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + 10
    type of 'y' is Real[2, 2]
    type of '10' is Integer
")})));
end ArrayAdd5;


model ArrayAdd6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y + 10;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd6",
            description="Scalarization of addition: Real[2,2,2] + Integer",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + 10
    type of 'y' is Real[2, 2, 2]
    type of '10' is Integer
")})));
end ArrayAdd6;


model ArrayAdd7
 Real x[2];
 Real y = 1;
equation
 x = y + { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd7",
            description="Scalarization of addition: Real + Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + {10, 20}
    type of 'y' is Real
    type of '{10, 20}' is Integer[2]
")})));
end ArrayAdd7;


model ArrayAdd8
 Real x[2,2];
 Real y = 1;
equation
 x = y + { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd8",
            description="Scalarization of addition: Real + Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + {{10, 20}, {30, 40}}
    type of 'y' is Real
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayAdd8;


model ArrayAdd9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y + { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd9",
            description="Scalarization of addition: Real + Integer[2,2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + {{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}}
    type of 'y' is Real
    type of '{{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}}' is Integer[2, 2, 2]
")})));
end ArrayAdd9;


model ArrayAdd10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd10",
            description="Scalarization of addition: Real[2] + Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayAdd10;


model ArrayAdd11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd11",
            description="Scalarization of addition: Real[2] + Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + {{10, 20}, {30, 40}}
    type of 'y' is Real[2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayAdd11;


model ArrayAdd12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y + { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayAdd12",
            description="Scalarization of addition: Real[2] + String[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y + {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayAdd12;



model ArrayDotAdd1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd1",
            description="Scalarization of element-wise addition: Real[2] .+ Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd1
 constant Real x[1] = 11.0;
 constant Real x[2] = 22.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Add.ArrayDotAdd1;
")})));
end ArrayDotAdd1;


model ArrayDotAdd2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd2",
            description="Scalarization of element-wise addition: Real[2,2] .+ Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd2
 constant Real x[1,1] = 11.0;
 constant Real x[1,2] = 22.0;
 constant Real x[2,1] = 33.0;
 constant Real x[2,2] = 44.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Add.ArrayDotAdd2;
")})));
end ArrayDotAdd2;


model ArrayDotAdd3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .+ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd3",
            description="Scalarization of element-wise addition: Real[2,2,2] .+ Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd3
 constant Real x[1,1,1] = 11.0;
 constant Real x[1,1,2] = 22.0;
 constant Real x[1,2,1] = 33.0;
 constant Real x[1,2,2] = 44.0;
 constant Real x[2,1,1] = 55.0;
 constant Real x[2,1,2] = 66.0;
 constant Real x[2,2,1] = 77.0;
 constant Real x[2,2,2] = 88.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Add.ArrayDotAdd3;
")})));
end ArrayDotAdd3;


model ArrayDotAdd4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd4",
            description="Scalarization of element-wise addition: Real[2] .+ Integer",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd4
 constant Real x[1] = 11.0;
 constant Real x[2] = 12.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Add.ArrayDotAdd4;
")})));
end ArrayDotAdd4;


model ArrayDotAdd5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .+ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd5",
            description="Scalarization of element-wise addition: Real[2,2] .+ Integer",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd5
 constant Real x[1,1] = 11.0;
 constant Real x[1,2] = 12.0;
 constant Real x[2,1] = 13.0;
 constant Real x[2,2] = 14.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Add.ArrayDotAdd5;
")})));
end ArrayDotAdd5;


model ArrayDotAdd6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .+ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd6",
            description="Scalarization of element-wise addition: Real[2,2,2] .+ Integer",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd6
 constant Real x[1,1,1] = 11.0;
 constant Real x[1,1,2] = 12.0;
 constant Real x[1,2,1] = 13.0;
 constant Real x[1,2,2] = 14.0;
 constant Real x[2,1,1] = 15.0;
 constant Real x[2,1,2] = 16.0;
 constant Real x[2,2,1] = 17.0;
 constant Real x[2,2,2] = 18.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Add.ArrayDotAdd6;
")})));
end ArrayDotAdd6;


model ArrayDotAdd7
 Real x[2];
 Real y = 1;
equation
 x = y .+ { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd7",
            description="Scalarization of element-wise addition: Real .+ Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd7
 constant Real x[1] = 11.0;
 constant Real x[2] = 21.0;
 constant Real y = 1;
end ArrayTests.Algebra.Add.ArrayDotAdd7;
")})));
end ArrayDotAdd7;


model ArrayDotAdd8
 Real x[2,2];
 Real y = 1;
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd8",
            description="Scalarization of element-wise addition: Real .+ Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd8
 constant Real x[1,1] = 11.0;
 constant Real x[1,2] = 21.0;
 constant Real x[2,1] = 31.0;
 constant Real x[2,2] = 41.0;
 constant Real y = 1;
end ArrayTests.Algebra.Add.ArrayDotAdd8;
")})));
end ArrayDotAdd8;


model ArrayDotAdd9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .+ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Add_ArrayDotAdd9",
            description="Scalarization of element-wise addition: Real .+ Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Add.ArrayDotAdd9
 constant Real x[1,1,1] = 11.0;
 constant Real x[1,1,2] = 21.0;
 constant Real x[1,2,1] = 31.0;
 constant Real x[1,2,2] = 41.0;
 constant Real x[2,1,1] = 51.0;
 constant Real x[2,1,2] = 61.0;
 constant Real x[2,2,1] = 71.0;
 constant Real x[2,2,2] = 81.0;
 constant Real y = 1;
end ArrayTests.Algebra.Add.ArrayDotAdd9;
")})));
end ArrayDotAdd9;


model ArrayDotAdd10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayDotAdd10",
            description="Scalarization of element-wise addition: Real[2] .+ Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .+ {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayDotAdd10;


model ArrayDotAdd11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayDotAdd11",
            description="Scalarization of element-wise addition: Real[2] .+ Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .+ {{10, 20}, {30, 40}}
    type of 'y' is Real[2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayDotAdd11;


model ArrayDotAdd12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .+ { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Add_ArrayDotAdd12",
            description="Scalarization of element-wise addition: Real[2] .+ String[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .+ {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayDotAdd12;

end Add;


package Sub
	
model ArraySub1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArraySub1",
            description="Scalarization of subtraction: Real[2] - Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArraySub1
 constant Real x[1] = -9.0;
 constant Real x[2] = -18.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Sub.ArraySub1;
")})));
end ArraySub1;


model ArraySub2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y - { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArraySub2",
            description="Scalarization of subtraction: Real[2,2] - Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArraySub2
 constant Real x[1,1] = -9.0;
 constant Real x[1,2] = -18.0;
 constant Real x[2,1] = -27.0;
 constant Real x[2,2] = -36.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Sub.ArraySub2;
")})));
end ArraySub2;


model ArraySub3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y - { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArraySub3",
            description="Scalarization of subtraction: Real[2,2,2] - Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArraySub3
 constant Real x[1,1,1] = -9.0;
 constant Real x[1,1,2] = -18.0;
 constant Real x[1,2,1] = -27.0;
 constant Real x[1,2,2] = -36.0;
 constant Real x[2,1,1] = -45.0;
 constant Real x[2,1,2] = -54.0;
 constant Real x[2,2,1] = -63.0;
 constant Real x[2,2,2] = -72.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Sub.ArraySub3;
")})));
end ArraySub3;


model ArraySub4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - 10;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub4",
            description="Scalarization of subtraction: Real[2] - Integer",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - 10
    type of 'y' is Real[2]
    type of '10' is Integer
")})));
end ArraySub4;


model ArraySub5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y - 10;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub5",
            description="Scalarization of subtraction: Real[2,2] - Integer",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - 10
    type of 'y' is Real[2, 2]
    type of '10' is Integer
")})));
end ArraySub5;


model ArraySub6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y - 10;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub6",
            description="Scalarization of subtraction: Real[2,2,2] - Integer",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - 10
    type of 'y' is Real[2, 2, 2]
    type of '10' is Integer
")})));
end ArraySub6;


model ArraySub7
 Real x[2];
 Real y = 1;
equation
 x = y - { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub7",
            description="Scalarization of subtraction: Real - Integer[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - {10, 20}
    type of 'y' is Real
    type of '{10, 20}' is Integer[2]
")})));
end ArraySub7;


model ArraySub8
 Real x[2,2];
 Real y = 1;
equation
 x = y - { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub8",
            description="Scalarization of subtraction: Real - Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - {{10, 20}, {30, 40}}
    type of 'y' is Real
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArraySub8;


model ArraySub9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y - { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub9",
            description="Scalarization of subtraction: Real - Integer[2,2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - {{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}}
    type of 'y' is Real
    type of '{{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}}' is Integer[2, 2, 2]
")})));
end ArraySub9;


model ArraySub10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub10",
            description="Scalarization of subtraction: Real[2] - Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArraySub10;


model ArraySub11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub11",
            description="Scalarization of subtraction: Real[2] - Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - {{10, 20}, {30, 40}}
    type of 'y' is Real[2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArraySub11;


model ArraySub12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y - { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArraySub12",
            description="Scalarization of subtraction: Real[2] - String[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y - {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArraySub12;



model ArrayDotSub1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub1",
            description="Scalarization of element-wise subtraction: Real[2] .- Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub1
 constant Real x[1] = -9.0;
 constant Real x[2] = -18.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Sub.ArrayDotSub1;
")})));
end ArrayDotSub1;


model ArrayDotSub2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .- { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub2",
            description="Scalarization of element-wise subtraction: Real[2,2] .- Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub2
 constant Real x[1,1] = -9.0;
 constant Real x[1,2] = -18.0;
 constant Real x[2,1] = -27.0;
 constant Real x[2,2] = -36.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Sub.ArrayDotSub2;
")})));
end ArrayDotSub2;


model ArrayDotSub3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .- { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub3",
            description="Scalarization of element-wise subtraction: Real[2,2,2] .- Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub3
 constant Real x[1,1,1] = -9.0;
 constant Real x[1,1,2] = -18.0;
 constant Real x[1,2,1] = -27.0;
 constant Real x[1,2,2] = -36.0;
 constant Real x[2,1,1] = -45.0;
 constant Real x[2,1,2] = -54.0;
 constant Real x[2,2,1] = -63.0;
 constant Real x[2,2,2] = -72.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Sub.ArrayDotSub3;
")})));
end ArrayDotSub3;


model ArrayDotSub4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub4",
            description="Scalarization of element-wise subtraction: Real[2] .- Integer",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub4
 constant Real x[1] = -9.0;
 constant Real x[2] = -8.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Sub.ArrayDotSub4;
")})));
end ArrayDotSub4;


model ArrayDotSub5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .- 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub5",
            description="Scalarization of element-wise subtraction: Real[2,2] .- Integer",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub5
 constant Real x[1,1] = -9.0;
 constant Real x[1,2] = -8.0;
 constant Real x[2,1] = -7.0;
 constant Real x[2,2] = -6.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Sub.ArrayDotSub5;
")})));
end ArrayDotSub5;


model ArrayDotSub6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .- 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub6",
            description="Scalarization of element-wise subtraction: Real[2,2,2] .- Integer",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub6
 constant Real x[1,1,1] = -9.0;
 constant Real x[1,1,2] = -8.0;
 constant Real x[1,2,1] = -7.0;
 constant Real x[1,2,2] = -6.0;
 constant Real x[2,1,1] = -5.0;
 constant Real x[2,1,2] = -4.0;
 constant Real x[2,2,1] = -3.0;
 constant Real x[2,2,2] = -2.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Sub.ArrayDotSub6;
")})));
end ArrayDotSub6;


model ArrayDotSub7
 Real x[2];
 Real y = 1;
equation
 x = y .- { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub7",
            description="Scalarization of element-wise subtraction: Real .- Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub7
 constant Real x[1] = -9.0;
 constant Real x[2] = -19.0;
 constant Real y = 1;
end ArrayTests.Algebra.Sub.ArrayDotSub7;
")})));
end ArrayDotSub7;


model ArrayDotSub8
 Real x[2,2];
 Real y = 1;
equation
 x = y .- { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub8",
            description="Scalarization of element-wise subtraction: Real .- Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub8
 constant Real x[1,1] = -9.0;
 constant Real x[1,2] = -19.0;
 constant Real x[2,1] = -29.0;
 constant Real x[2,2] = -39.0;
 constant Real y = 1;
end ArrayTests.Algebra.Sub.ArrayDotSub8;
")})));
end ArrayDotSub8;


model ArrayDotSub9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .- { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Sub_ArrayDotSub9",
            description="Scalarization of element-wise subtraction: Real .- Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Sub.ArrayDotSub9
 constant Real x[1,1,1] = -9.0;
 constant Real x[1,1,2] = -19.0;
 constant Real x[1,2,1] = -29.0;
 constant Real x[1,2,2] = -39.0;
 constant Real x[2,1,1] = -49.0;
 constant Real x[2,1,2] = -59.0;
 constant Real x[2,2,1] = -69.0;
 constant Real x[2,2,2] = -79.0;
 constant Real y = 1;
end ArrayTests.Algebra.Sub.ArrayDotSub9;
")})));
end ArrayDotSub9;


model ArrayDotSub10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArrayDotSub10",
            description="Scalarization of element-wise subtraction: Real[2] .- Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .- {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayDotSub10;


model ArrayDotSub11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArrayDotSub11",
            description="Scalarization of element-wise subtraction: Real[2] .- Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .- {{10, 20}, {30, 40}}
    type of 'y' is Real[2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayDotSub11;


model ArrayDotSub12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .- { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Sub_ArrayDotSub12",
            description="Scalarization of element-wise subtraction: Real[2] .- String[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .- {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayDotSub12;

end Sub;


package Mul
	
model ArrayMulOK1
 Real x;
 Real y[3] = { 1, 2, 3 };
equation
 x = y * { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK1",
            description="Scalarization of multiplication: Real[3] * Integer[3]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK1
 constant Real x = 140.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
 constant Real y[3] = 3;
end ArrayTests.Algebra.Mul.ArrayMulOK1;
")})));
end ArrayMulOK1;


model ArrayMulOK2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK2",
            description="Scalarization of multiplication: Real[2,2] * Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK2
 constant Real x[1,1] = 70.0;
 constant Real x[1,2] = 100.0;
 constant Real x[2,1] = 150.0;
 constant Real x[2,2] = 220.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Mul.ArrayMulOK2;
")})));
end ArrayMulOK2;


model ArrayMulOK3
 Real x[3,4];
 Real y[2,4] = { { 1, 2, 3, 4 }, { 5, 6, 7, 8 } };
equation
 x = { { 10, 20 }, { 30, 40 }, { 50, 60 } } * y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK3",
            description="Scalarization of multiplication: Integer[3,2] * Real[2,4]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK3
 constant Real x[1,1] = 110.0;
 constant Real x[1,2] = 140.0;
 constant Real x[1,3] = 170.0;
 constant Real x[1,4] = 200.0;
 constant Real x[2,1] = 230.0;
 constant Real x[2,2] = 300.0;
 constant Real x[2,3] = 370.0;
 constant Real x[2,4] = 440.0;
 constant Real x[3,1] = 350.0;
 constant Real x[3,2] = 460.0;
 constant Real x[3,3] = 570.0;
 constant Real x[3,4] = 680.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[1,3] = 3;
 constant Real y[1,4] = 4;
 constant Real y[2,1] = 5;
 constant Real y[2,2] = 6;
 constant Real y[2,3] = 7;
 constant Real y[2,4] = 8;
end ArrayTests.Algebra.Mul.ArrayMulOK3;
")})));
end ArrayMulOK3;


model ArrayMulOK4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK4",
            description="Scalarization of multiplication: Real[2] * Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK4
 constant Real x[1] = 70.0;
 constant Real x[2] = 100.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Mul.ArrayMulOK4;
")})));
end ArrayMulOK4;


model ArrayMulOK5
 Real x[2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK5",
            description="Scalarization of multiplication: Real[2,2] * Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK5
 constant Real x[1] = 50.0;
 constant Real x[2] = 110.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Mul.ArrayMulOK5;
")})));
end ArrayMulOK5;


model ArrayMulOK6
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK6",
            description="Scalarization of multiplication: Real[2] * Integer",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK6
 constant Real x[1] = 10.0;
 constant Real x[2] = 20.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Mul.ArrayMulOK6;
")})));
end ArrayMulOK6;


model ArrayMulOK7
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK7",
            description="Scalarization of multiplication: Real[2,2] * Integer",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK7
 constant Real x[1,1] = 10.0;
 constant Real x[1,2] = 20.0;
 constant Real x[2,1] = 30.0;
 constant Real x[2,2] = 40.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Mul.ArrayMulOK7;
")})));
end ArrayMulOK7;


model ArrayMulOK8
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y * 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK8",
            description="Scalarization of multiplication: Real[2,2,2] * Integer",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK8
 constant Real x[1,1,1] = 10.0;
 constant Real x[1,1,2] = 20.0;
 constant Real x[1,2,1] = 30.0;
 constant Real x[1,2,2] = 40.0;
 constant Real x[2,1,1] = 50.0;
 constant Real x[2,1,2] = 60.0;
 constant Real x[2,2,1] = 70.0;
 constant Real x[2,2,2] = 80.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Mul.ArrayMulOK8;
")})));
end ArrayMulOK8;


model ArrayMulOK9
 Real x[2];
 Real y = 1;
equation
 x = y * { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK9",
            description="Scalarization of multiplication: Real * Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK9
 constant Real x[1] = 10.0;
 constant Real x[2] = 20.0;
 constant Real y = 1;
end ArrayTests.Algebra.Mul.ArrayMulOK9;
")})));
end ArrayMulOK9;


model ArrayMulOK10
 Real x[2,2];
 Real y = 1;
equation
 x = y * { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK10",
            description="Scalarization of multiplication: Real * Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK10
 constant Real x[1,1] = 10.0;
 constant Real x[1,2] = 20.0;
 constant Real x[2,1] = 30.0;
 constant Real x[2,2] = 40.0;
 constant Real y = 1;
end ArrayTests.Algebra.Mul.ArrayMulOK10;
")})));
end ArrayMulOK10;


model ArrayMulOK11
 Real x[2,2,2];
 Real y = 1;
equation
 x = y * { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK11",
            description="Scalarization of multiplication: Real * Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK11
 constant Real x[1,1,1] = 10.0;
 constant Real x[1,1,2] = 20.0;
 constant Real x[1,2,1] = 30.0;
 constant Real x[1,2,2] = 40.0;
 constant Real x[2,1,1] = 50.0;
 constant Real x[2,1,2] = 60.0;
 constant Real x[2,2,1] = 70.0;
 constant Real x[2,2,2] = 80.0;
 constant Real y = 1;
end ArrayTests.Algebra.Mul.ArrayMulOK11;
")})));
end ArrayMulOK11;


model ArrayMulOK12
 Real x[2,1];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10 }, { 20 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK12",
            description="Scalarization of multiplication: Real[2,2] * Integer[2,1]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK12
 constant Real x[1,1] = 50.0;
 constant Real x[2,1] = 110.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Mul.ArrayMulOK12;
")})));
end ArrayMulOK12;


model ArrayMulOK13
 Real x[3] = { 1, 2, 3 };
 Real y[3] = x * x * x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayMulOK13",
            description="Scalarization of multiplication: check that type() of Real[3] * Real[3] is correct",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayMulOK13
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
 constant Real y[1] = 14.0;
 constant Real y[2] = 28.0;
 constant Real y[3] = 42.0;
end ArrayTests.Algebra.Mul.ArrayMulOK13;
")})));
end ArrayMulOK13;


model ArrayMulErr1
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y * { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr1",
            description="Scalarization of multiplication: Real[2,2,2] * Integer[2,2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}}
    type of 'y' is Real[2, 2, 2]
    type of '{{{10, 20}, {30, 40}}, {{50, 60}, {70, 80}}}' is Integer[2, 2, 2]
")})));
end ArrayMulErr1;


model ArrayMulErr2
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr2",
            description="Scalarization of multiplication: Real[2] * Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayMulErr2;


model ArrayMulErr3
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y * { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr3",
            description="Scalarization of multiplication: Real[2] * String[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayMulErr3;


model ArrayMulErr4
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 }, { 30, 40 }, { 50, 60 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr4",
            description="Scalarization of multiplication: Real[2,2] * Integer[3,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {{10, 20}, {30, 40}, {50, 60}}
    type of 'y' is Real[2, 2]
    type of '{{10, 20}, {30, 40}, {50, 60}}' is Integer[3, 2]
")})));
end ArrayMulErr4;


model ArrayMulErr5
 Real x[2,2];
 Real y[2,3] = { { 1, 2, 3 }, { 4, 5, 6 } };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr5",
            description="Scalarization of multiplication: Real[2,3] * Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {{10, 20}, {30, 40}}
    type of 'y' is Real[2, 3]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayMulErr5;


model ArrayMulErr6
 Real x[2,2];
 Real y[2,3] = { { 1, 2, 3 }, { 4, 5, 6 } };
equation
 x = y * { { 10, 20, 30 }, { 40, 50, 60 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr6",
            description="Scalarization of multiplication: Real[2,3] * Integer[2,3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {{10, 20, 30}, {40, 50, 60}}
    type of 'y' is Real[2, 3]
    type of '{{10, 20, 30}, {40, 50, 60}}' is Integer[2, 3]
")})));
end ArrayMulErr6;


model ArrayMulErr7
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr7",
            description="Scalarization of multiplication: Real[2,2] * Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {10, 20, 30}
    type of 'y' is Real[2, 2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayMulErr7;


model ArrayMulErr8
 Real x[2,2];
 Real y[3] = { 1, 2, 3 };
equation
 x = y * { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr8",
            description="Scalarization of multiplication: Real[3] * Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {{10, 20}, {30, 40}}
    type of 'y' is Real[3]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayMulErr8;


model ArrayMulErr9
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y * { { 10, 20 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayMulErr9",
            description="Scalarization of multiplication: Real[2,2] * Integer[1,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y * {{10, 20}}
    type of 'y' is Real[2, 2]
    type of '{{10, 20}}' is Integer[1, 2]
")})));
end ArrayMulErr9;



model ArrayDotMul1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul1",
            description="Scalarization of element-wise multiplication: Real[2] .* Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul1
 constant Real x[1] = 10.0;
 constant Real x[2] = 40.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Mul.ArrayDotMul1;
")})));
end ArrayDotMul1;


model ArrayDotMul2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .* { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul2",
            description="Scalarization of element-wise multiplication: Real[2,2] .* Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul2
 constant Real x[1,1] = 10.0;
 constant Real x[1,2] = 40.0;
 constant Real x[2,1] = 90.0;
 constant Real x[2,2] = 160.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Mul.ArrayDotMul2;
")})));
end ArrayDotMul2;


model ArrayDotMul3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .* { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul3",
            description="Scalarization of element-wise multiplication: Real[2,2,2] .* Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul3
 constant Real x[1,1,1] = 10.0;
 constant Real x[1,1,2] = 40.0;
 constant Real x[1,2,1] = 90.0;
 constant Real x[1,2,2] = 160.0;
 constant Real x[2,1,1] = 250.0;
 constant Real x[2,1,2] = 360.0;
 constant Real x[2,2,1] = 490.0;
 constant Real x[2,2,2] = 640.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Mul.ArrayDotMul3;
")})));
end ArrayDotMul3;


model ArrayDotMul4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul4",
            description="Scalarization of element-wise multiplication: Real[2] .* Integer",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul4
 constant Real x[1] = 10.0;
 constant Real x[2] = 20.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Mul.ArrayDotMul4;
")})));
end ArrayDotMul4;


model ArrayDotMul5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .* 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul5",
            description="Scalarization of element-wise multiplication: Real[2,2] .* Integer",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul5
 constant Real x[1,1] = 10.0;
 constant Real x[1,2] = 20.0;
 constant Real x[2,1] = 30.0;
 constant Real x[2,2] = 40.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Mul.ArrayDotMul5;
")})));
end ArrayDotMul5;


model ArrayDotMul6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .* 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul6",
            description="Scalarization of element-wise multiplication: Real[2,2,2] .* Integer",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul6
 constant Real x[1,1,1] = 10.0;
 constant Real x[1,1,2] = 20.0;
 constant Real x[1,2,1] = 30.0;
 constant Real x[1,2,2] = 40.0;
 constant Real x[2,1,1] = 50.0;
 constant Real x[2,1,2] = 60.0;
 constant Real x[2,2,1] = 70.0;
 constant Real x[2,2,2] = 80.0;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Mul.ArrayDotMul6;
")})));
end ArrayDotMul6;


model ArrayDotMul7
 Real x[2];
 Real y = 1;
equation
 x = y .* { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul7",
            description="Scalarization of element-wise multiplication: Real .* Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul7
 constant Real x[1] = 10.0;
 constant Real x[2] = 20.0;
 constant Real y = 1;
end ArrayTests.Algebra.Mul.ArrayDotMul7;
")})));
end ArrayDotMul7;


model ArrayDotMul8
 Real x[2,2];
 Real y = 1;
equation
 x = y .* { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul8",
            description="Scalarization of element-wise multiplication: Real .* Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul8
 constant Real x[1,1] = 10.0;
 constant Real x[1,2] = 20.0;
 constant Real x[2,1] = 30.0;
 constant Real x[2,2] = 40.0;
 constant Real y = 1;
end ArrayTests.Algebra.Mul.ArrayDotMul8;
")})));
end ArrayDotMul8;


model ArrayDotMul9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .* { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Mul_ArrayDotMul9",
            description="Scalarization of element-wise multiplication: Real .* Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Mul.ArrayDotMul9
 constant Real x[1,1,1] = 10.0;
 constant Real x[1,1,2] = 20.0;
 constant Real x[1,2,1] = 30.0;
 constant Real x[1,2,2] = 40.0;
 constant Real x[2,1,1] = 50.0;
 constant Real x[2,1,2] = 60.0;
 constant Real x[2,2,1] = 70.0;
 constant Real x[2,2,2] = 80.0;
 constant Real y = 1;
end ArrayTests.Algebra.Mul.ArrayDotMul9;
")})));
end ArrayDotMul9;


model ArrayDotMul10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayDotMul10",
            description="Scalarization of element-wise multiplication: Real[2] .* Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .* {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayDotMul10;


model ArrayDotMul11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayDotMul11",
            description="Scalarization of element-wise multiplication: Real[2] .* Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .* {{10, 20}, {30, 40}}
    type of 'y' is Real[2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayDotMul11;


model ArrayDotMul12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .* { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Mul_ArrayDotMul12",
            description="Scalarization of element-wise multiplication: Real[2] .* String[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .* {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayDotMul12;

end Mul;


package Div
	
model ArrayDiv1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDiv1",
            description="Scalarization of division: Real[2] / Integer[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y / {10, 20}
    type of 'y' is Real[2]
    type of '{10, 20}' is Integer[2]
")})));
end ArrayDiv1;


model ArrayDiv2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y / { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDiv2",
            description="Scalarization of division: Real[2,2] / Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y / {{10, 20}, {30, 40}}
    type of 'y' is Real[2, 2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayDiv2;


model ArrayDiv3
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDiv3",
            description="Scalarization of division: Real[2] / Integer",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDiv3
 constant Real x[1] = 0.1;
 constant Real x[2] = 0.2;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Div.ArrayDiv3;
")})));
end ArrayDiv3;


model ArrayDiv4
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y / 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDiv4",
            description="Scalarization of division: Real[2,2] / Integer",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDiv4
 constant Real x[1,1] = 0.1;
 constant Real x[1,2] = 0.2;
 constant Real x[2,1] = 0.3;
 constant Real x[2,2] = 0.4;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Div.ArrayDiv4;
")})));
end ArrayDiv4;


model ArrayDiv5
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y / 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDiv5",
            description="Scalarization of division: Real[2,2,2] / Integer",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDiv5
 constant Real x[1,1,1] = 0.1;
 constant Real x[1,1,2] = 0.2;
 constant Real x[1,2,1] = 0.3;
 constant Real x[1,2,2] = 0.4;
 constant Real x[2,1,1] = 0.5;
 constant Real x[2,1,2] = 0.6;
 constant Real x[2,2,1] = 0.7;
 constant Real x[2,2,2] = 0.8;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Div.ArrayDiv5;
")})));
end ArrayDiv5;


model ArrayDiv6
 Real x[2];
 Real y = 1;
equation
 x = y / { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDiv6",
            description="Scalarization of division: Real / Integer[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y / {10, 20}
    type of 'y' is Real
    type of '{10, 20}' is Integer[2]
")})));
end ArrayDiv6;


model ArrayDiv7
 Real x[2,2];
 Real y = 1;
equation
 x = y / { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDiv7",
            description="Scalarization of division: Real / Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y / {{10, 20}, {30, 40}}
    type of 'y' is Real
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayDiv7;


model ArrayDiv8
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y / { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDiv8",
            description="Scalarization of division: Real[2] / String",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y / {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayDiv8;



model ArrayDotDiv1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv1",
            description="Scalarization of element-wise division: Real[2] ./ Integer[2]",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv1
 constant Real x[1] = 0.1;
 constant Real x[2] = 0.1;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Div.ArrayDotDiv1;
")})));
end ArrayDotDiv1;


model ArrayDotDiv2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv2",
            description="Scalarization of element-wise division: Real[2,2] ./ Integer[2,2]",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv2
 constant Real x[1,1] = 0.1;
 constant Real x[1,2] = 0.1;
 constant Real x[2,1] = 0.1;
 constant Real x[2,2] = 0.1;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Div.ArrayDotDiv2;
")})));
end ArrayDotDiv2;


model ArrayDotDiv3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y ./ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv3",
            description="Scalarization of element-wise division: Real[2,2,2] ./ Integer[2,2,2]",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv3
 constant Real x[1,1,1] = 0.1;
 constant Real x[1,1,2] = 0.1;
 constant Real x[1,2,1] = 0.1;
 constant Real x[1,2,2] = 0.1;
 constant Real x[2,1,1] = 0.1;
 constant Real x[2,1,2] = 0.1;
 constant Real x[2,2,1] = 0.1;
 constant Real x[2,2,2] = 0.1;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Div.ArrayDotDiv3;
")})));
end ArrayDotDiv3;


model ArrayDotDiv4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv4",
            description="Scalarization of element-wise division: Real[2] ./ Integer",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv4
 constant Real x[1] = 0.1;
 constant Real x[2] = 0.2;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Div.ArrayDotDiv4;
")})));
end ArrayDotDiv4;


model ArrayDotDiv5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y ./ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv5",
            description="Scalarization of element-wise division: Real[2,2] ./ Integer",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv5
 constant Real x[1,1] = 0.1;
 constant Real x[1,2] = 0.2;
 constant Real x[2,1] = 0.3;
 constant Real x[2,2] = 0.4;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Div.ArrayDotDiv5;
")})));
end ArrayDotDiv5;


model ArrayDotDiv6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y ./ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv6",
            description="Scalarization of element-wise division: Real[2,2,2] ./ Integer",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv6
 constant Real x[1,1,1] = 0.1;
 constant Real x[1,1,2] = 0.2;
 constant Real x[1,2,1] = 0.3;
 constant Real x[1,2,2] = 0.4;
 constant Real x[2,1,1] = 0.5;
 constant Real x[2,1,2] = 0.6;
 constant Real x[2,2,1] = 0.7;
 constant Real x[2,2,2] = 0.8;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Div.ArrayDotDiv6;
")})));
end ArrayDotDiv6;


model ArrayDotDiv7
 Real x[2];
 Real y = 1;
equation
 x = y ./ { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv7",
            description="Scalarization of element-wise division: Real ./ Integer[2]",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv7
 constant Real x[1] = 0.1;
 constant Real x[2] = 0.05;
 constant Real y = 1;
end ArrayTests.Algebra.Div.ArrayDotDiv7;
")})));
end ArrayDotDiv7;


model ArrayDotDiv8
 Real x[2,2];
 Real y = 1;
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv8",
            description="Scalarization of element-wise division: Real ./ Integer[2,2]",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv8
 constant Real x[1,1] = 0.1;
 constant Real x[1,2] = 0.05;
 constant Real x[2,1] = 0.03333333333333333;
 constant Real x[2,2] = 0.025;
 constant Real y = 1;
end ArrayTests.Algebra.Div.ArrayDotDiv8;
")})));
end ArrayDotDiv8;


model ArrayDotDiv9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y ./ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Div_ArrayDotDiv9",
            description="Scalarization of element-wise division: Real ./ Integer[2,2,2]",
            flatModel="
fclass ArrayTests.Algebra.Div.ArrayDotDiv9
 constant Real x[1,1,1] = 0.1;
 constant Real x[1,1,2] = 0.05;
 constant Real x[1,2,1] = 0.03333333333333333;
 constant Real x[1,2,2] = 0.025;
 constant Real x[2,1,1] = 0.02;
 constant Real x[2,1,2] = 0.016666666666666666;
 constant Real x[2,2,1] = 0.014285714285714285;
 constant Real x[2,2,2] = 0.0125;
 constant Real y = 1;
end ArrayTests.Algebra.Div.ArrayDotDiv9;
")})));
end ArrayDotDiv9;


model ArrayDotDiv10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDotDiv10",
            description="Scalarization of element-wise division: Real[2] ./ Integer[3]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y ./ {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayDotDiv10;


model ArrayDotDiv11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDotDiv11",
            description="Scalarization of element-wise division: Real[2] ./ Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y ./ {{10, 20}, {30, 40}}
    type of 'y' is Real[2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayDotDiv11;


model ArrayDotDiv12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y ./ { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Div_ArrayDotDiv12",
            description="Scalarization of element-wise division: Real[2] ./ String[2]",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y ./ {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayDotDiv12;

end Div;


package Pow
	
model ArrayDotPow1
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow1",
            description="Scalarization of element-wise exponentiation:",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow1
 constant Real x[1] = 1.0;
 constant Real x[2] = 1048576.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Pow.ArrayDotPow1;
")})));
end ArrayDotPow1;


model ArrayDotPow2
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow2",
            description="Scalarization of element-wise exponentiation:",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow2
 constant Real x[1,1] = 1.0;
 constant Real x[1,2] = 1048576.0;
 constant Real x[2,1] = 2.05891132094649E14;
 constant Real x[2,2] = 1.2089258196146292E24;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Pow.ArrayDotPow2;
")})));
end ArrayDotPow2;


model ArrayDotPow3
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .^ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow3",
            description="Scalarization of element-wise exponentiation:",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow3
 constant Real x[1,1,1] = 1.0;
 constant Real x[1,1,2] = 1048576.0;
 constant Real x[1,2,1] = 2.05891132094649E14;
 constant Real x[1,2,2] = 1.2089258196146292E24;
 constant Real x[2,1,1] = 8.881784197001253E34;
 constant Real x[2,1,2] = 4.887367798068926E46;
 constant Real x[2,2,1] = 1.4350360160986845E59;
 constant Real x[2,2,2] = 1.7668470647783843E72;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Pow.ArrayDotPow3;
")})));
end ArrayDotPow3;


model ArrayDotPow4
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow4",
            description="Scalarization of element-wise exponentiation:",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow4
 constant Real x[1] = 1.0;
 constant Real x[2] = 1024.0;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
end ArrayTests.Algebra.Pow.ArrayDotPow4;
")})));
end ArrayDotPow4;


model ArrayDotPow5
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation
 x = y .^ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow5",
            description="Scalarization of element-wise exponentiation:",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow5
 constant Real x[1,1] = 1.0;
 constant Real x[1,2] = 1024.0;
 constant Real x[2,1] = 59049.0;
 constant Real x[2,2] = 1048576.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Pow.ArrayDotPow5;
")})));
end ArrayDotPow5;


model ArrayDotPow6
 Real x[2,2,2];
 Real y[2,2,2] = { { { 1, 2 }, { 3, 4 } }, { { 5, 6 }, { 7, 8 } } };
equation
 x = y .^ 10;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow6",
            description="Scalarization of element-wise exponentiation:",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow6
 constant Real x[1,1,1] = 1.0;
 constant Real x[1,1,2] = 1024.0;
 constant Real x[1,2,1] = 59049.0;
 constant Real x[1,2,2] = 1048576.0;
 constant Real x[2,1,1] = 9765625.0;
 constant Real x[2,1,2] = 6.0466176E7;
 constant Real x[2,2,1] = 2.82475249E8;
 constant Real x[2,2,2] = 1.073741824E9;
 constant Real y[1,1,1] = 1;
 constant Real y[1,1,2] = 2;
 constant Real y[1,2,1] = 3;
 constant Real y[1,2,2] = 4;
 constant Real y[2,1,1] = 5;
 constant Real y[2,1,2] = 6;
 constant Real y[2,2,1] = 7;
 constant Real y[2,2,2] = 8;
end ArrayTests.Algebra.Pow.ArrayDotPow6;
")})));
end ArrayDotPow6;


model ArrayDotPow7
 Real x[2];
 Real y = 1;
equation
 x = y .^ { 10, 20 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow7",
            description="Scalarization of element-wise exponentiation:",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow7
 constant Real x[1] = 1.0;
 constant Real x[2] = 1.0;
 constant Real y = 1;
end ArrayTests.Algebra.Pow.ArrayDotPow7;
")})));
end ArrayDotPow7;


model ArrayDotPow8
 Real x[2,2];
 Real y = 1;
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow8",
            description="Scalarization of element-wise exponentiation:",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow8
 constant Real x[1,1] = 1.0;
 constant Real x[1,2] = 1.0;
 constant Real x[2,1] = 1.0;
 constant Real x[2,2] = 1.0;
 constant Real y = 1;
end ArrayTests.Algebra.Pow.ArrayDotPow8;
")})));
end ArrayDotPow8;


model ArrayDotPow9
 Real x[2,2,2];
 Real y = 1;
equation
 x = y .^ { { { 10, 20 }, { 30, 40 } }, { { 50, 60 }, { 70, 80 } } };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayDotPow9",
            description="Scalarization of element-wise exponentiation:",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayDotPow9
 constant Real x[1,1,1] = 1.0;
 constant Real x[1,1,2] = 1.0;
 constant Real x[1,2,1] = 1.0;
 constant Real x[1,2,2] = 1.0;
 constant Real x[2,1,1] = 1.0;
 constant Real x[2,1,2] = 1.0;
 constant Real x[2,2,1] = 1.0;
 constant Real x[2,2,2] = 1.0;
 constant Real y = 1;
end ArrayTests.Algebra.Pow.ArrayDotPow9;
")})));
end ArrayDotPow9;


model ArrayDotPow10
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { 10, 20, 30 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayDotPow10",
            description="Scalarization of element-wise exponentiation:",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .^ {10, 20, 30}
    type of 'y' is Real[2]
    type of '{10, 20, 30}' is Integer[3]
")})));
end ArrayDotPow10;


model ArrayDotPow11
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { { 10, 20 }, { 30, 40 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayDotPow11",
            description="Scalarization of element-wise exponentiation:",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .^ {{10, 20}, {30, 40}}
    type of 'y' is Real[2]
    type of '{{10, 20}, {30, 40}}' is Integer[2, 2]
")})));
end ArrayDotPow11;


model ArrayDotPow12
 Real x[2];
 Real y[2] = { 1, 2 };
equation
 x = y .^ { "1", "2" };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayDotPow12",
            description="Scalarization of element-wise exponentiation:",
            errorMessage="
1 errors found:

Error at line 5, column 6, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: y .^ {\"1\", \"2\"}
    type of 'y' is Real[2]
    type of '{\"1\", \"2\"}' is String[2]
")})));
end ArrayDotPow12;



model ArrayPow1
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow1",
            description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 0",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow1
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 0;
 constant Real x[2,1] = 0;
 constant Real x[2,2] = 1;
end ArrayTests.Algebra.Pow.ArrayPow1;
")})));
end ArrayPow1;


model ArrayPow2
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow2",
            description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 1",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow2
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 4;
end ArrayTests.Algebra.Pow.ArrayPow2;
")})));
end ArrayPow2;


model ArrayPow3
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow3",
            description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 2",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow3
 constant Real x[1,1] = 7;
 constant Real x[1,2] = 10;
 constant Real x[2,1] = 15;
 constant Real x[2,2] = 22;
end ArrayTests.Algebra.Pow.ArrayPow3;
")})));
end ArrayPow3;


model ArrayPow4
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow4",
            description="Scalarization of element-wise exponentiation: Integer[2,2] ^ 3",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow4
 constant Real x[1,1] = 37;
 constant Real x[1,2] = 54;
 constant Real x[2,1] = 81;
 constant Real x[2,2] = 118;
end ArrayTests.Algebra.Pow.ArrayPow4;
")})));
end ArrayPow4;


model ArrayPow5
 Real x[3,3] = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } } ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow5",
            description="Scalarization of element-wise exponentiation: Integer[3,3] ^ 2",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow5
 constant Real x[1,1] = 30;
 constant Real x[1,2] = 36;
 constant Real x[1,3] = 42;
 constant Real x[2,1] = 66;
 constant Real x[2,2] = 81;
 constant Real x[2,3] = 96;
 constant Real x[3,1] = 102;
 constant Real x[3,2] = 126;
 constant Real x[3,3] = 150;
end ArrayTests.Algebra.Pow.ArrayPow5;
")})));
end ArrayPow5;


model ArrayPow6
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation 
 x = y ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow6",
            description="Scalarization of element-wise exponentiation: component Real[2,2] ^ 2",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow6
 constant Real x[1,1] = 7.0;
 constant Real x[1,2] = 10.0;
 constant Real x[2,1] = 15.0;
 constant Real x[2,2] = 22.0;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Pow.ArrayPow6;
")})));
end ArrayPow6;


model ArrayPow7
 Real x[2,2];
 Real y[2,2] = { { 1, 2 }, { 3, 4 } };
equation 
 x = y ^ 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow7",
            description="Scalarization of element-wise exponentiation:component Real[2,2] ^ 0",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow7
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 0;
 constant Real x[2,1] = 0;
 constant Real x[2,2] = 1;
 constant Real y[1,1] = 1;
 constant Real y[1,2] = 2;
 constant Real y[2,1] = 3;
 constant Real y[2,2] = 4;
end ArrayTests.Algebra.Pow.ArrayPow7;
")})));
end ArrayPow7;


model ArrayPow8
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ (-1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayPow8",
            description="Scalarization of element-wise exponentiation: Integer[2,2] ^ (negative Integer)",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {{1, 2}, {3, 4}} ^ -1
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
    type of '-1' is Integer
")})));
end ArrayPow8;


model ArrayPow9
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ 1.0;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayPow9",
            description="Scalarization of element-wise exponentiation: Integer[2,2] ^ Real",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {{1, 2}, {3, 4}} ^ 1.0
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
    type of '1.0' is Real
")})));
end ArrayPow9;


model ArrayPow10
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ { { 1, 2 }, { 3, 4 } };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayPow10",
            description="Scalarization of element-wise exponentiation: Integer[2,2] ^ Integer[2,2]",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {{1, 2}, {3, 4}} ^ {{1, 2}, {3, 4}}
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
")})));
end ArrayPow10;


model ArrayPow11
 Real x[2,3] = { { 1, 2 }, { 3, 4 }, { 5, 6 } } ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayPow11",
            description="Scalarization of element-wise exponentiation: Integer[2,3] ^ 2",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {{1, 2}, {3, 4}, {5, 6}} ^ 2
    type of '{{1, 2}, {3, 4}, {5, 6}}' is Integer[3, 2]
    type of '2' is Integer
")})));
end ArrayPow11;


model ArrayPow12
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 Integer y = 2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayPow12",
            description="Scalarization of element-wise exponentiation: Real[2,2] ^ Integer component",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {{1, 2}, {3, 4}} ^ y
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
    type of 'y' is Integer
")})));
end ArrayPow12;


model ArrayPow13
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 constant Integer y = 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow13",
            description="Scalarization of element-wise exponentiation: Real[2,2] ^ constant Integer component",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow13
 constant Real x[1,1] = 7;
 constant Real x[1,2] = 10;
 constant Real x[2,1] = 15;
 constant Real x[2,2] = 22;
 constant Integer y = 2;
end ArrayTests.Algebra.Pow.ArrayPow13;
")})));
end ArrayPow13;


model ArrayPow14
 Real x[2,2] = { { 1, 2 }, { 3, 4 } } ^ y;
 parameter Integer y = 2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayPow14",
            description="Scalarization of element-wise exponentiation: Real[2,2] ^ parameter Integer component",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {{1, 2}, {3, 4}} ^ y
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
    type of 'y' is Integer
")})));
end ArrayPow14;


model ArrayPow15
 Real x[1,1] = { { 1 } } ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow15",
            description="Scalarization of element-wise exponentiation: Integer[1,1] ^ 2",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow15
 constant Real x[1,1] = 1;
end ArrayTests.Algebra.Pow.ArrayPow15;
")})));
end ArrayPow15;


model ArrayPow16
 Real x[1] = { 1 } ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Pow_ArrayPow16",
            description="Scalarization of element-wise exponentiation: Integer[1] ^ 2",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {1} ^ 2
    type of '{1}' is Integer[1]
    type of '2' is Integer
")})));
end ArrayPow16;


model ArrayPow17
 Real x = 1 ^ 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Pow_ArrayPow17",
            description="Scalarization of element-wise exponentiation: Integer ^ 2",
            flatModel="
fclass ArrayTests.Algebra.Pow.ArrayPow17
 constant Real x = 1.0;
end ArrayTests.Algebra.Pow.ArrayPow17;
")})));
end ArrayPow17;

end Pow;


package Neg
    
model ArrayNeg1
 Integer x[3] = -{ 1, 0, -1 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Neg_ArrayNeg1",
            description="Scalarization of negation: array of Integer (literal)",
            flatModel="
fclass ArrayTests.Algebra.Neg.ArrayNeg1
 constant Integer x[1] = -1;
 constant Integer x[2] = 0;
 constant Integer x[3] = 1;
end ArrayTests.Algebra.Neg.ArrayNeg1;
")})));
end ArrayNeg1;


model ArrayNeg2
 Integer x[3] = -y;
 Integer y[3] = { 1, 0, -1 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Neg_ArrayNeg2",
            description="Scalarization of negation: array of Integer (variable)",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Neg.ArrayNeg2
 constant Integer x[1] = -1;
 constant Integer x[2] = 0;
 constant Integer x[3] = 1;
 constant Integer y[1] = 1;
 constant Integer y[2] = 0;
 constant Integer y[3] = -1;
end ArrayTests.Algebra.Neg.ArrayNeg2;
")})));
end ArrayNeg2;


model ArrayNeg3
 Integer x[3] = y;
 constant Integer y[3] = -{ 1, 0, -1 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algebra_Neg_ArrayNeg3",
            description="Scalarization of negation: constant evaluation",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Algebra.Neg.ArrayNeg3
 constant Integer x[1] = -1;
 constant Integer x[2] = 0;
 constant Integer x[3] = 1;
 constant Integer y[1] = -1;
 constant Integer y[2] = 0;
 constant Integer y[3] = 1;
end ArrayTests.Algebra.Neg.ArrayNeg3;
")})));
end ArrayNeg3;


model ArrayNeg4
 Boolean x[2] = -{ true, false };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Neg_ArrayNeg4",
            description="Scalarization of negation: -Boolean[2] (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: - {true, false}
    type of '{true, false}' is Boolean[2]
")})));
end ArrayNeg4;


model ArrayNeg5
 Boolean x[2] = -y;
 Boolean y[2] = { true, false };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Algebra_Neg_ArrayNeg5",
            description="Scalarization of negation: -Boolean[2] (component)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: - y
    type of 'y' is Boolean[2]
")})));
end ArrayNeg5;

end Neg;

end Algebra;



package Logical
	
package And

model ArrayAnd1
 Boolean x[2] = { true, true } and { true, false };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_And_ArrayAnd1",
            description="Scalarization of logical and: arrays of Booleans (literal)",
            flatModel="
fclass ArrayTests.Logical.And.ArrayAnd1
 constant Boolean x[1] = true;
 constant Boolean x[2] = false;
end ArrayTests.Logical.And.ArrayAnd1;
")})));
end ArrayAnd1;

model ArrayAnd2
 Boolean y[2] = { true, false };
 Boolean x[2] = { true, true } and y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_And_ArrayAnd2",
            description="Scalarization of logical and: arrays of Booleans (component)",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Logical.And.ArrayAnd2
 constant Boolean y[1] = true;
 constant Boolean y[2] = false;
 constant Boolean x[1] = true;
 constant Boolean x[2] = false;
end ArrayTests.Logical.And.ArrayAnd2;
")})));
end ArrayAnd2;


model ArrayAnd3
 Boolean x[2] = { true, true } and { true, false, true };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_And_ArrayAnd3",
            description="Scalarization of logical and: different array sizes (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} and {true, false, true}
    type of '{true, true}' is Boolean[2]
    type of '{true, false, true}' is Boolean[3]
")})));
end ArrayAnd3;


model ArrayAnd4
 Boolean y[3] = { true, false, true };
 Boolean x[2] = { true, true } and y;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_And_ArrayAnd4",
            description="Scalarization of logical and: different array sizes (component)",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} and y
    type of '{true, true}' is Boolean[2]
    type of 'y' is Boolean[3]
")})));
end ArrayAnd4;


model ArrayAnd5
 Boolean x[2] = { true, true } and true;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_And_ArrayAnd5",
            description="Scalarization of logical and: array and scalar (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} and true
    type of '{true, true}' is Boolean[2]
    type of 'true' is Boolean
")})));
end ArrayAnd5;


model ArrayAnd6
 Boolean y = true;
 Boolean x[2] = { true, true } and y;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_And_ArrayAnd6",
            description="Scalarization of logical and: array and scalar (component)",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} and y
    type of '{true, true}' is Boolean[2]
    type of 'y' is Boolean
")})));
end ArrayAnd6;


model ArrayAnd7
 Integer x[2] = { 1, 1 } and { 1, 0 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_And_ArrayAnd7",
            description="Scalarization of logical and: Integer[2] and Integer[2] (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {1, 1} and {1, 0}
    type of '{1, 1}' is Integer[2]
    type of '{1, 0}' is Integer[2]
")})));
end ArrayAnd7;


model ArrayAnd8
 Integer y[2] = { 1, 0 };
 Integer x[2] = { 1, 1 } and y;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_And_ArrayAnd8",
            description="Scalarization of logical and: Integer[2] and Integer[2] (component)",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {1, 1} and y
    type of '{1, 1}' is Integer[2]
    type of 'y' is Integer[2]
")})));
end ArrayAnd8;


model ArrayAnd9
 constant Boolean y[3] = { true, false, false } and { true, true, false };
 Boolean x[3] = y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_And_ArrayAnd9",
            description="Scalarization of logical and: constant evaluation",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Logical.And.ArrayAnd9
 constant Boolean y[1] = true;
 constant Boolean y[2] = false;
 constant Boolean y[3] = false;
 constant Boolean x[1] = true;
 constant Boolean x[2] = false;
 constant Boolean x[3] = false;
end ArrayTests.Logical.And.ArrayAnd9;
")})));
end ArrayAnd9;

end And;


package Or
	
model ArrayOr1
 Boolean x[2] = { true, true } or { true, false };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_Or_ArrayOr1",
            description="Scalarization of logical or: arrays of Booleans (literal)",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Logical.Or.ArrayOr1
 constant Boolean x[1] = true;
 constant Boolean x[2] = true;
end ArrayTests.Logical.Or.ArrayOr1;
")})));
end ArrayOr1;


model ArrayOr2
 Boolean y[2] = { true, false };
 Boolean x[2] = { true, true } or y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_Or_ArrayOr2",
            description="Scalarization of logical or: arrays of Booleans (component)",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Logical.Or.ArrayOr2
 constant Boolean y[1] = true;
 constant Boolean y[2] = false;
 constant Boolean x[1] = true;
 constant Boolean x[2] = true;
end ArrayTests.Logical.Or.ArrayOr2;
")})));
end ArrayOr2;


model ArrayOr3
 Boolean x[2] = { true, true } or { true, false, true };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Or_ArrayOr3",
            description="Scalarization of logical or: different array sizes (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} or {true, false, true}
    type of '{true, true}' is Boolean[2]
    type of '{true, false, true}' is Boolean[3]
")})));
end ArrayOr3;


model ArrayOr4
 Boolean y[3] = { true, false, true };
 Boolean x[2] = { true, true } or y;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Or_ArrayOr4",
            description="Scalarization of logical or: different array sizes (component)",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} or y
    type of '{true, true}' is Boolean[2]
    type of 'y' is Boolean[3]
")})));
end ArrayOr4;


model ArrayOr5
 Boolean x[2] = { true, true } or true;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Or_ArrayOr5",
            description="Scalarization of logical or: array and scalar (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} or true
    type of '{true, true}' is Boolean[2]
    type of 'true' is Boolean
")})));
end ArrayOr5;


model ArrayOr6
 Boolean y = true;
 Boolean x[2] = { true, true } or y;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Or_ArrayOr6",
            description="Scalarization of logical or: array and scalar (component)",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {true, true} or y
    type of '{true, true}' is Boolean[2]
    type of 'y' is Boolean
")})));
end ArrayOr6;


model ArrayOr7
 Integer x[2] = { 1, 1 } or { 1, 0 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Or_ArrayOr7",
            description="Scalarization of logical or: Integer[2] or Integer[2] (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {1, 1} or {1, 0}
    type of '{1, 1}' is Integer[2]
    type of '{1, 0}' is Integer[2]
")})));
end ArrayOr7;


model ArrayOr8
 Integer y[2] = { 1, 0 };
 Integer x[2] = { 1, 1 } or y;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Or_ArrayOr8",
            description="Scalarization of logical or: Integer[2] or Integer[2] (component)",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {1, 1} or y
    type of '{1, 1}' is Integer[2]
    type of 'y' is Integer[2]
")})));
end ArrayOr8;


model ArrayOr9
 constant Boolean y[3] = { true, true, false } or { true, false, false };
 Boolean x[3] = y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_Or_ArrayOr9",
            description="Scalarization of logical or: constant evaluation",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Logical.Or.ArrayOr9
 constant Boolean y[1] = true;
 constant Boolean y[2] = true;
 constant Boolean y[3] = false;
 constant Boolean x[1] = true;
 constant Boolean x[2] = true;
 constant Boolean x[3] = false;
end ArrayTests.Logical.Or.ArrayOr9;
")})));
end ArrayOr9;

end Or;



package Not
	
model ArrayNot1
 Boolean x[2] = not { true, false };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_Not_ArrayNot1",
            description="Scalarization of logical not: array of Boolean (literal)",
            flatModel="
fclass ArrayTests.Logical.Not.ArrayNot1
 constant Boolean x[1] = false;
 constant Boolean x[2] = true;
end ArrayTests.Logical.Not.ArrayNot1;
")})));
end ArrayNot1;


model ArrayNot2
 Boolean x[2] = not y;
 Boolean y[2] = { true, false };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_Not_ArrayNot2",
            description="Scalarization of logical not: array of Boolean (component)",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Logical.Not.ArrayNot2
 constant Boolean x[1] = false;
 constant Boolean x[2] = true;
 constant Boolean y[1] = true;
 constant Boolean y[2] = false;
end ArrayTests.Logical.Not.ArrayNot2;
")})));
end ArrayNot2;


model ArrayNot3
 Boolean x[2] = y;
 constant Boolean y[2] = not { true, false };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Logical_Not_ArrayNot3",
            description="Scalarization of logical not: constant evaluation",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Logical.Not.ArrayNot3
 constant Boolean x[1] = false;
 constant Boolean x[2] = true;
 constant Boolean y[1] = false;
 constant Boolean y[2] = true;
end ArrayTests.Logical.Not.ArrayNot3;
")})));
end ArrayNot3;


model ArrayNot4
 Integer x[2] = not { 1, 0 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Not_ArrayNot4",
            description="Scalarization of logical not: not Integer[2] (literal)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: not {1, 0}
    type of '{1, 0}' is Integer[2]
")})));
end ArrayNot4;


model ArrayNot5
 Integer x[2] = not y;
 Integer y[2] = { 1, 0 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Logical_Not_ArrayNot5",
            description="Scalarization of logical or: not Integer[2] (component)",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: not y
    type of 'y' is Integer[2]
")})));
end ArrayNot5;

end Not;

end Logical;



package Constructors

package LongForm
	
model LongArrayForm1
 Real x[3] = array(1, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Constructors_LongForm_LongArrayForm1",
            description="Long form of array constructor",
            flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm1
 Real x[3] = array(1, 2, 3);
end ArrayTests.Constructors.LongForm.LongArrayForm1;
")})));
end LongArrayForm1;


model LongArrayForm2
 Real x[3] = array(1, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_LongForm_LongArrayForm2",
            description="Long form of array constructor",
            flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm2
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
end ArrayTests.Constructors.LongForm.LongArrayForm2;
")})));
end LongArrayForm2;


model LongArrayForm3
 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1,x2,{7,8,9});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Constructors_LongForm_LongArrayForm3",
            description="Long form of array constructor, array component parts",
            flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm3
 Real x1[3] = array(1, 2, 3);
 Real x2[3] = {4, 5, 6};
 Real x3[3,3] = array(x1[1:3], x2[1:3], {7, 8, 9});
end ArrayTests.Constructors.LongForm.LongArrayForm3;
")})));
end LongArrayForm3;


model LongArrayForm4
 Real x1[3] = array(1,2,3);
 Real x2[3] = {4,5,6};
 Real x3[3,3] = array(x1,x2,{7,8,9});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_LongForm_LongArrayForm4",
            description="Long form of array constructor, array component parts",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.LongForm.LongArrayForm4
 constant Real x1[1] = 1;
 constant Real x1[2] = 2;
 constant Real x1[3] = 3;
 constant Real x2[1] = 4;
 constant Real x2[2] = 5;
 constant Real x2[3] = 6;
 constant Real x3[1,1] = 1.0;
 constant Real x3[1,2] = 2.0;
 constant Real x3[1,3] = 3.0;
 constant Real x3[2,1] = 4.0;
 constant Real x3[2,2] = 5.0;
 constant Real x3[2,3] = 6.0;
 constant Real x3[3,1] = 7;
 constant Real x3[3,2] = 8;
 constant Real x3[3,3] = 9;
end ArrayTests.Constructors.LongForm.LongArrayForm4;
")})));
end LongArrayForm4;

end LongForm;


package EmptyArray
	
model EmptyArray1
    Real x[3,0] = zeros(3,0);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_EmptyArray_EmptyArray1",
            description="Empty arrays, basic test",
            flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray1
end ArrayTests.Constructors.EmptyArray.EmptyArray1;
")})));
end EmptyArray1;


model EmptyArray2
    Real x[3,0] = zeros(3,0);
    Real y[3,0] = zeros(3,0);
    Real z[3,0] = x + y;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_EmptyArray_EmptyArray2",
            description="Empty arrays, addition",
            flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray2
end ArrayTests.Constructors.EmptyArray.EmptyArray2;
")})));
end EmptyArray2;


model EmptyArray3
    Real x[2,2] = {{1,2},{3,4}};
    Real y[2,0] = ones(2,0);
    Real z[0,2] = ones(0,2);
    Real w[0,0] = ones(0,0);
    Real xx[2,2] = [x, y; z, w];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_EmptyArray_EmptyArray3",
            description="Empty arrays, concatenation",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray3
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 4;
 constant Real xx[1,1] = 1.0;
 constant Real xx[1,2] = 2.0;
 constant Real xx[2,1] = 3.0;
 constant Real xx[2,2] = 4.0;
end ArrayTests.Constructors.EmptyArray.EmptyArray3;
")})));
end EmptyArray3;


model EmptyArray4
    Real x[2,0] = {{1,2},{3,4}} * ones(2,0);
    Real y[2,2] = ones(2,0) * ones(0,2);
    Real z[0,0] = ones(0,2) * ones(2,0);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_EmptyArray_EmptyArray4",
            description="Empty arrays, multiplication",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray4
 constant Real y[1,1] = 0;
 constant Real y[1,2] = 0;
 constant Real y[2,1] = 0;
 constant Real y[2,2] = 0;
end ArrayTests.Constructors.EmptyArray.EmptyArray4;
")})));
end EmptyArray4;


model EmptyArray5
    parameter Integer n = 0;
    parameter Integer p = 2;
    parameter Integer q = 2;
    input Real u[p];
    Real x[n];
    Real y[q];
    parameter Real A[n,n] = ones(n,n);
    parameter Real B[n,p] = ones(n,p);
    parameter Real C[q,n] = ones(q,n);
    parameter Real D[q,p] = { i*j for i in 1:q, j in 1:p };
equation
    der(x) = A*x + B*u;
        y  = C*x + D*u;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_EmptyArray_EmptyArray5",
            description="Empty arrays, simple equation system",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray5
 structural parameter Integer n = 0 /* 0 */;
 structural parameter Integer p = 2 /* 2 */;
 structural parameter Integer q = 2 /* 2 */;
 input Real u[1];
 input Real u[2];
 Real y[1];
 Real y[2];
 structural parameter Real D[1,1] = 1 /* 1 */;
 structural parameter Real D[1,2] = 2 /* 2 */;
 structural parameter Real D[2,1] = 2 /* 2 */;
 structural parameter Real D[2,2] = 4 /* 4 */;
equation
 y[1] = u[1] + 2.0 * u[2];
 y[2] = 2 * y[1];
end ArrayTests.Constructors.EmptyArray.EmptyArray5;
")})));
end EmptyArray5;

model EmptyArray6
    model A
        Real x;
    end A;
    
    A a[0];
    Real t;
  equation
    t = sum(a.x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_EmptyArray_EmptyArray6",
            description="Empty arrays, composite array",
            flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray6
 constant Real t = 0.0;
end ArrayTests.Constructors.EmptyArray.EmptyArray6;
")})));
end EmptyArray6;

model EmptyArray7
    constant Real x[:] = {1};
    Real[:] y = x[1:0];
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Constructors_EmptyArray_EmptyArray7",
            description="Empty arrays, composite array",
            flatModel="
fclass ArrayTests.Constructors.EmptyArray.EmptyArray7
 constant Real x[1] = {1};
 Real y[0] = fill(0.0, 0);
end ArrayTests.Constructors.EmptyArray.EmptyArray7;
")})));
end EmptyArray7;

end EmptyArray;


package Iterators

model ArrayIterTest1
 Real x[3,3] = {i * j for i in 1:3, j in {2,3,5}};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest1",
            description="Array constructor with iterators: over scalar exp",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest1
 constant Real x[1,1] = 2;
 constant Real x[1,2] = 4;
 constant Real x[1,3] = 6;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 6;
 constant Real x[2,3] = 9;
 constant Real x[3,1] = 5;
 constant Real x[3,2] = 10;
 constant Real x[3,3] = 15;
end ArrayTests.Constructors.Iterators.ArrayIterTest1;
")})));
end ArrayIterTest1;


model ArrayIterTest2
 Real x[2,2,2] = {{i * i, j} for i in 1:2, j in {2,5}};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest2",
            description="Array constructor with iterators: over array exp",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest2
 constant Real x[1,1,1] = 1;
 constant Real x[1,1,2] = 2;
 constant Real x[1,2,1] = 4;
 constant Real x[1,2,2] = 2;
 constant Real x[2,1,1] = 1;
 constant Real x[2,1,2] = 5;
 constant Real x[2,2,1] = 4;
 constant Real x[2,2,2] = 5;
end ArrayTests.Constructors.Iterators.ArrayIterTest2;
")})));
end ArrayIterTest2;


model ArrayIterTest3
 Real i = 1;
 Real x[2,2,2,2] = { { { {i, j} for j in 1:2 } for i in 3:4 } for i in 5:6 };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest3",
            description="Array constructor with iterators: nestled constructors, masking index",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest3
 constant Real i = 1;
 constant Real x[1,1,1,1] = 3;
 constant Real x[1,1,1,2] = 1;
 constant Real x[1,1,2,1] = 3;
 constant Real x[1,1,2,2] = 2;
 constant Real x[1,2,1,1] = 4;
 constant Real x[1,2,1,2] = 1;
 constant Real x[1,2,2,1] = 4;
 constant Real x[1,2,2,2] = 2;
 constant Real x[2,1,1,1] = 3;
 constant Real x[2,1,1,2] = 1;
 constant Real x[2,1,2,1] = 3;
 constant Real x[2,1,2,2] = 2;
 constant Real x[2,2,1,1] = 4;
 constant Real x[2,2,1,2] = 1;
 constant Real x[2,2,2,1] = 4;
 constant Real x[2,2,2,2] = 2;
end ArrayTests.Constructors.Iterators.ArrayIterTest3;
")})));
end ArrayIterTest3;


model ArrayIterTest4
 Real x[1,1,1] = { {1} for i in {1}, j in {1} };

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest4",
            description="Array constructor with iterators: vectors of length 1",
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest4
 constant Real x[1,1,1] = 1;
end ArrayTests.Constructors.Iterators.ArrayIterTest4;
")})));
end ArrayIterTest4;


model ArrayIterTest5
    function f
    algorithm
    end f;
    
    Real x[3] = { f() for i in 1:3 };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Constructors_Iterators_ArrayIterTest5",
            description="Iterated expression with bad size",
            errorMessage="
1 errors found:

Error at line 6, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Function f() has no outputs, but is used in expression
")})));
end ArrayIterTest5;


model ArrayIterTest6
    Real x[3,2] = { { 2 * i for i in 1:2 }, { i * i for i in 2:3 }, { 1, 2 } } * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest6",
            description="Iteration expressions as members of array constructor",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest6
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real x[3,1];
 Real x[3,2];
equation
 x[1,1] = 2 * time;
 x[1,2] = 4 * time;
 x[2,1] = 4 * time;
 x[2,2] = 9 * time;
 x[3,1] = time;
 x[3,2] = 2 * time;
end ArrayTests.Constructors.Iterators.ArrayIterTest6;
")})));
end ArrayIterTest6;

model ArrayIterTest7
    record R
        Real a;
        Real b;
    end R;
    
    function f1
        input Real x;
        output R y;
    algorithm
        y := R(x, x+1);
    end f1;
    
    Real z[2] = time * {1, 2};
    R w[2] = { f1(z[i]) for i in 1:2 };
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest7",
            description="Iteration expressions with generated temporaries",
            eliminate_linear_equations=false,
            inline_functions="none",
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest7
 Real z[1];
 Real z[2];
 Real w[1].a;
 Real w[1].b;
 Real w[2].a;
 Real w[2].b;
equation
 z[1] = time;
 z[2] = time * 2;
 (ArrayTests.Constructors.Iterators.ArrayIterTest7.R(w[1].a, w[1].b)) = ArrayTests.Constructors.Iterators.ArrayIterTest7.f1(z[1]);
 (ArrayTests.Constructors.Iterators.ArrayIterTest7.R(w[2].a, w[2].b)) = ArrayTests.Constructors.Iterators.ArrayIterTest7.f1(z[2]);

public
 function ArrayTests.Constructors.Iterators.ArrayIterTest7.f1
  input Real x;
  output ArrayTests.Constructors.Iterators.ArrayIterTest7.R y;
 algorithm
  y.a := x;
  y.b := x + 1;
  return;
 end ArrayTests.Constructors.Iterators.ArrayIterTest7.f1;

 record ArrayTests.Constructors.Iterators.ArrayIterTest7.R
  Real a;
  Real b;
 end ArrayTests.Constructors.Iterators.ArrayIterTest7.R;

end ArrayTests.Constructors.Iterators.ArrayIterTest7;
")})));
end ArrayIterTest7;

model ArrayIterTest8
    record R
        Real a;
        Real b;
    end R;
    
    function f1
        input Real x;
        output R y;
    algorithm
        y := R(x, x+1);
    end f1;
    
    function f2
        input R x;
        output Real y;
    algorithm
        y := x.a * x.b;
    end f2;
    
    Real z[2] = time * {1, 2};
    Real w[2] = { f2(f1(z[i])) for i in 1:2 };
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest8",
            description="Iteration expressions with generated temporaries",
            eliminate_linear_equations=false,
            inline_functions="none",
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest8
 Real z[1];
 Real z[2];
 Real w[1];
 Real w[2];
equation
 z[1] = time;
 z[2] = time * 2;
 w[1] = ArrayTests.Constructors.Iterators.ArrayIterTest8.f2(ArrayTests.Constructors.Iterators.ArrayIterTest8.f1(z[1]));
 w[2] = ArrayTests.Constructors.Iterators.ArrayIterTest8.f2(ArrayTests.Constructors.Iterators.ArrayIterTest8.f1(z[2]));
 
public
 function ArrayTests.Constructors.Iterators.ArrayIterTest8.f2
  input ArrayTests.Constructors.Iterators.ArrayIterTest8.R x;
  output Real y;
 algorithm
  y := x.a * x.b;
  return;
 end ArrayTests.Constructors.Iterators.ArrayIterTest8.f2;

 function ArrayTests.Constructors.Iterators.ArrayIterTest8.f1
  input Real x;
  output ArrayTests.Constructors.Iterators.ArrayIterTest8.R y;
 algorithm
  y.a := x;
  y.b := x + 1;
  return;
 end ArrayTests.Constructors.Iterators.ArrayIterTest8.f1;

 record ArrayTests.Constructors.Iterators.ArrayIterTest8.R
  Real a;
  Real b;
 end ArrayTests.Constructors.Iterators.ArrayIterTest8.R;

end ArrayTests.Constructors.Iterators.ArrayIterTest8;
")})));
end ArrayIterTest8;

model ArrayIterTest9
    record R
        Real a;
        Real b;
    end R;
    
    function f1
        input Real x;
        output R y;
    algorithm
        y := R(x, x+1);
    end f1;
    
    function f2
        input Real[2] x;
        output R[2] y = { f1(x[i]) for i in 1:2 };
        algorithm
    end f2;
    
    Real z[2] = time * {1, 2};
    R w[2] = f2(z);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest9",
            description="Iteration expressions with generated temporaries",
            inline_functions="none",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest9
 Real z[1];
 Real z[2];
 Real w[1].a;
 Real w[1].b;
 Real w[2].a;
 Real w[2].b;
equation
 z[1] = time;
 z[2] = time * 2;
 ({ArrayTests.Constructors.Iterators.ArrayIterTest9.R(w[1].a, w[1].b), ArrayTests.Constructors.Iterators.ArrayIterTest9.R(w[2].a, w[2].b)}) = ArrayTests.Constructors.Iterators.ArrayIterTest9.f2({z[1], z[2]});

public
 function ArrayTests.Constructors.Iterators.ArrayIterTest9.f2
  input Real[:] x;
  output ArrayTests.Constructors.Iterators.ArrayIterTest9.R[:] y;
  ArrayTests.Constructors.Iterators.ArrayIterTest9.R[:] temp_1;
  ArrayTests.Constructors.Iterators.ArrayIterTest9.R temp_2;
  ArrayTests.Constructors.Iterators.ArrayIterTest9.R temp_3;
 algorithm
  init y as ArrayTests.Constructors.Iterators.ArrayIterTest9.R[2];
  init temp_1 as ArrayTests.Constructors.Iterators.ArrayIterTest9.R[2];
  (temp_2) := ArrayTests.Constructors.Iterators.ArrayIterTest9.f1(x[1]);
  temp_1[1] := temp_2;
  (temp_3) := ArrayTests.Constructors.Iterators.ArrayIterTest9.f1(x[2]);
  temp_1[2] := temp_3;
  for i1 in 1:2 loop
   y[i1].a := temp_1[i1].a;
   y[i1].b := temp_1[i1].b;
  end for;
  return;
 end ArrayTests.Constructors.Iterators.ArrayIterTest9.f2;

 function ArrayTests.Constructors.Iterators.ArrayIterTest9.f1
  input Real x;
  output ArrayTests.Constructors.Iterators.ArrayIterTest9.R y;
 algorithm
  y.a := x;
  y.b := x + 1;
  return;
 end ArrayTests.Constructors.Iterators.ArrayIterTest9.f1;

 record ArrayTests.Constructors.Iterators.ArrayIterTest9.R
  Real a;
  Real b;
 end ArrayTests.Constructors.Iterators.ArrayIterTest9.R;

end ArrayTests.Constructors.Iterators.ArrayIterTest9;
")})));
end ArrayIterTest9;

model ArrayIterTest10
    constant Real[1,2] c = {{1,2}};
    parameter Real[:,:] x = {{c[i,j] for i in 1:1} for j in 1:2};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest10",
            description="Nested iteration expressions",
            inline_functions="none",
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest10
 constant Real c[1,1] = 1;
 constant Real c[1,2] = 2;
 parameter Real x[1,1] = 1.0 /* 1.0 */;
 parameter Real x[2,1] = 2.0 /* 2.0 */;
end ArrayTests.Constructors.Iterators.ArrayIterTest10;
")})));
end ArrayIterTest10;

model ArrayIterTest11
    record R
        parameter Real[:,:] x = {{i + j for i in 1:1} for j in 1:2};
    end R;
    
    R r;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest11",
            description="Nested iteration expressions",
            inline_functions="none",
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest11
 parameter Real r.x[1,1] = 2 /* 2 */;
 parameter Real r.x[2,1] = 3 /* 3 */;
end ArrayTests.Constructors.Iterators.ArrayIterTest11;
")})));
end ArrayIterTest11;

model ArrayIterTest12
    record R
        Real t[:] = {time,time};
        Real[:,:] x = {{t[i] + t[j] for i in 1:1} for j in 1:2};
    end R;
    
    R r;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest12",
            description="Nested iteration expressions",
            inline_functions="none",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest12
 Real r.t[1];
 Real r.t[2];
 Real r.x[1,1];
 Real r.x[2,1];
equation
 r.t[1] = time;
 r.t[2] = time;
 r.x[1,1] = r.t[1] + r.t[1];
 r.x[2,1] = r.t[1] + r.t[2];
end ArrayTests.Constructors.Iterators.ArrayIterTest12;
")})));
end ArrayIterTest12;

model ArrayIterTest13
    Integer[:] x0 = 1:8;
    constant Integer[:,:,:] x1 = {{{1,2},{3,4}},{{5,6},{7,8}}};
    Integer[:,:,:] x2 = {{{x0[x1[i,j,k]] for i in 1:2} for j in 1:2} for k in 1:2};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest13",
            description="Nested iteration expressions",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest13
 constant Integer x0[1] = 1;
 constant Integer x0[2] = 2;
 constant Integer x0[3] = 3;
 constant Integer x0[4] = 4;
 constant Integer x0[5] = 5;
 constant Integer x0[6] = 6;
 constant Integer x0[7] = 7;
 constant Integer x0[8] = 8;
 constant Integer x1[1,1,1] = 1;
 constant Integer x1[1,1,2] = 2;
 constant Integer x1[1,2,1] = 3;
 constant Integer x1[1,2,2] = 4;
 constant Integer x1[2,1,1] = 5;
 constant Integer x1[2,1,2] = 6;
 constant Integer x1[2,2,1] = 7;
 constant Integer x1[2,2,2] = 8;
 constant Integer x2[1,1,1] = 1;
 constant Integer x2[1,1,2] = 5;
 constant Integer x2[1,2,1] = 3;
 constant Integer x2[1,2,2] = 7;
 constant Integer x2[2,1,1] = 2;
 constant Integer x2[2,1,2] = 6;
 constant Integer x2[2,2,1] = 4;
 constant Integer x2[2,2,2] = 8;
end ArrayTests.Constructors.Iterators.ArrayIterTest13;
")})));
end ArrayIterTest13;

model ArrayIterTest14
    Real[n] L = (1:n) .+ time;
    parameter Integer n = 2;
    Real[n] z=1/sum(L)*{sum(L[1:i]) + 0.5*L[i + 1] for i in 0:n - 1};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest14",
            description="Varying size in iteration expression",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest14
 Real L[1];
 Real L[2];
 structural parameter Integer n = 2 /* 2 */;
 Real z[1];
 Real z[2];
equation
 L[1] = 1 .+ time;
 L[2] = 2 .+ time;
 z[1] = 1 / (L[1] + L[2]) * (0.5 * L[1]);
 z[2] = 1 / (L[1] + L[2]) * (L[1] + 0.5 * L[2]);
end ArrayTests.Constructors.Iterators.ArrayIterTest14;
")})));
end ArrayIterTest14;

model ArrayIterTest15
    record R
        Real x;
    end R;
    
    function f1
        input Real x;
        output R y = R(x);
        algorithm
    end f1;
    
    function f2
        input R x;
        output Real y = x.x;
        algorithm
    end f2;
    
    parameter Integer n = 3;
    Real[n] x = (1:n) .* time;
    Real[n] z = {f2(f1(x[i])) for i in 1:n};
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTest15",
            description="Varying size in iteration expression",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest15
 structural parameter Integer n = 3 /* 3 */;
 Real z[1];
 Real z[2];
 Real z[3];
equation
 z[1] = time;
 z[2] = 2 .* time;
 z[3] = 3 .* time;
end ArrayTests.Constructors.Iterators.ArrayIterTest15;
")})));
end ArrayIterTest15;

model ArrayIterTest16 
        model A 
            parameter Integer n; 
            Real[n] x = 1:n; 
        end A; 
        model M 
            parameter Integer n; 
            A[n] a(n={3-i for i in 1:n}); 
        end M; 
         
        M[2] m(n={1,2}); 
         
        Real[:] y1 = {m[i].a[end].x[end] for i in 1:2}; 
        annotation(__JModelica(UnitTesting(tests={ 
            FlatteningTestCase( 
                name="Constructors_Iterators_ArrayIterTest16", 
                description="Varying size in iteration expression", 
                flatModel=" 
    fclass ArrayTests.Constructors.Iterators.ArrayIterTest16 
     structural parameter Integer m[1].n = 1 /* 1 */; 
     structural parameter Integer m[1].a[1].n = 2 /* 2 */; 
     Real m[1].a[1].x[2] = 1:2; 
     structural parameter Integer m[2].n = 2 /* 2 */; 
     structural parameter Integer m[2].a[1].n = 2 /* 2 */; 
     Real m[2].a[1].x[2] = 1:2; 
     structural parameter Integer m[2].a[2].n = 1 /* 1 */; 
     Real m[2].a[2].x[1] = 1:1; 
     Real y1[2] = {m[1].a[1].x[2], m[2].a[2].x[1]}; 
    end ArrayTests.Constructors.Iterators.ArrayIterTest16; 
    ")}))); 
    end ArrayIterTest16; 
     
    model ArrayIterTest17 
        function f 
            input Integer i; 
            output Integer[:] y = 1:2; 
            algorithm 
        end f; 
        Real[:,:] y3 = {f(i) for i in 1:2}; 
         
        annotation(__JModelica(UnitTesting(tests={ 
            FlatteningTestCase( 
                name="Constructors_Iterators_ArrayIterTest17", 
                description="", 
                flatModel=" 
fclass ArrayTests.Constructors.Iterators.ArrayIterTest17 
 Real y3[2,2] = {ArrayTests.Constructors.Iterators.ArrayIterTest17.f(1), ArrayTests.Constructors.Iterators.ArrayIterTest17.f(2)}; 

public
 function ArrayTests.Constructors.Iterators.ArrayIterTest17.f 
  input Integer i; 
  output Integer[:] y; 
 algorithm 
  init y as Integer[2]; 
  y := 1:2; 
  return; 
 end ArrayTests.Constructors.Iterators.ArrayIterTest17.f; 

end ArrayTests.Constructors.Iterators.ArrayIterTest17; 
")}))); 
end ArrayIterTest17;

model ArrayIterTest18
    parameter Integer n = 10;
    Real a[n] = ones(n);
    Real x;
equation
    x = sum(if a[i] > 0 then 2 else 0 for i in 1:n - 2);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Constructors_Iterators_ArrayIterTest18",
            description="",
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTest18
 structural parameter Integer n = 10 /* 10 */;
 Real a[10] = ones(10);
 Real x;
equation
 x = sum({if a[1] > 0 then 2 else 0, if a[2] > 0 then 2 else 0, if a[3] > 0 then 2 else 0, if a[4] > 0 then 2 else 0, if a[5] > 0 then 2 else 0, if a[6] > 0 then 2 else 0, if a[7] > 0 then 2 else 0, if a[8] > 0 then 2 else 0});
end ArrayTests.Constructors.Iterators.ArrayIterTest18;
")})));
end ArrayIterTest18;
    
model ArrayIterTestUnknown1
    function f
		input Integer a;
		output Real x[:] = { i^2 for i in 1:a/2 };
    algorithm
        annotation(Inline=false);
    end f;
    
	Real x[3] = f(6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTestUnknown1",
            description="Array constructor with iterators: vectors of length 1",
            variability_propagation=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTestUnknown1
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = ArrayTests.Constructors.Iterators.ArrayIterTestUnknown1.f(6);

public
 function ArrayTests.Constructors.Iterators.ArrayIterTestUnknown1.f
  input Integer a;
  output Real[:] x;
  Real[:] temp_1;
 algorithm
  init x as Real[max(integer(a / 2), 0)];
  init temp_1 as Real[max(integer(a / 2), 0)];
  for i1 in 1:max(integer(a / 2), 0) loop
   temp_1[i1] := i1 ^ 2;
  end for;
  for i1 in 1:max(integer(a / 2), 0) loop
   x[i1] := temp_1[i1];
  end for;
  return;
 annotation(Inline = false);
 end ArrayTests.Constructors.Iterators.ArrayIterTestUnknown1.f;

end ArrayTests.Constructors.Iterators.ArrayIterTestUnknown1;
")})));
end ArrayIterTestUnknown1;

model ArrayIterTestUnknown2
    function f
        input Integer a;
        output Real x1[:] = { i^2 for i in 2:0.5:a/2 };
        output Real x2[:] = { i for i in 2:0.5:a/2 };
        output Real x3[:] = 2:0.5:a/2;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real x[3] = f(6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constructors_Iterators_ArrayIterTestUnknown2",
            description="",
            variability_propagation=false,
            flatModel="
fclass ArrayTests.Constructors.Iterators.ArrayIterTestUnknown2
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = ArrayTests.Constructors.Iterators.ArrayIterTestUnknown2.f(6);

public
 function ArrayTests.Constructors.Iterators.ArrayIterTestUnknown2.f
  input Integer a;
  output Real[:] x1;
  output Real[:] x2;
  output Real[:] x3;
  Real[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init x1 as Real[max(integer((a / 2 - 2) / 0.5) + 1, 0)];
  init temp_1 as Real[max(integer((a / 2 - 2) / 0.5) + 1, 0)];
  for i1 in 1:max(integer((a / 2 - 2) / 0.5) + 1, 0) loop
   temp_1[i1] := (2 + (i1 - 1) * 0.5) ^ 2;
  end for;
  for i1 in 1:max(integer((a / 2 - 2) / 0.5) + 1, 0) loop
   x1[i1] := temp_1[i1];
  end for;
  init x2 as Real[max(integer((a / 2 - 2) / 0.5) + 1, 0)];
  init temp_2 as Integer[max(integer((a / 2 - 2) / 0.5) + 1, 0)];
  for i1 in 1:max(integer((a / 2 - 2) / 0.5) + 1, 0) loop
   temp_2[i1] := 2 + (i1 - 1) * 0.5;
  end for;
  for i1 in 1:max(integer((a / 2 - 2) / 0.5) + 1, 0) loop
   x2[i1] := temp_2[i1];
  end for;
  init x3 as Real[max(integer((a / 2 - 2) / 0.5) + 1, 0)];
  for i1 in 1:max(integer((a / 2 - 2) / 0.5) + 1, 0) loop
   x3[i1] := 2 + (i1 - 1) * 0.5;
  end for;
  return;
 annotation(Inline = false);
 end ArrayTests.Constructors.Iterators.ArrayIterTestUnknown2.f;

end ArrayTests.Constructors.Iterators.ArrayIterTestUnknown2;
")})));
end ArrayIterTestUnknown2;

end Iterators;

end Constructors;



package For
	
model ForEquation1
 model A
  Real x[3];
 equation
  for i in 1:3 loop
   x[i] = i*i;
  end for;
 end A;
 
 A y;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForEquation1",
            description="Flattening of for equations: for equ in a component",
            flatModel="
fclass ArrayTests.For.ForEquation1
 Real y.x[3];
equation
 y.x[1] = 1;
 y.x[2] = 2 * 2;
 y.x[3] = 3 * 3;
end ArrayTests.For.ForEquation1;
")})));
end ForEquation1;


model ForEquation2
    model A
        parameter Integer N;
        parameter Integer[N] rev = N:-1:1;
        Real[N] x;
        Real[N] y;
    equation
        for i in 1:N loop
            x[i] = y[rev[i]];
        end for;
    end A;
    
    A a(N=3, x={1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_ForEquation2",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.For.ForEquation2
 structural parameter Integer a.N = 3 /* 3 */;
 structural parameter Integer a.rev[1] = 3 /* 3 */;
 structural parameter Integer a.rev[2] = 2 /* 2 */;
 structural parameter Integer a.rev[3] = 1 /* 1 */;
 constant Real a.x[1] = 1;
 constant Real a.x[2] = 2;
 constant Real a.x[3] = 3;
 constant Real a.y[1] = 3.0;
 constant Real a.y[2] = 2.0;
 constant Real a.y[3] = 1.0;
end ArrayTests.For.ForEquation2;
")})));
end ForEquation2;


model ForEquation3
	function f
		input Real x;
		output Real y = x + 1;
	algorithm
	end f;
	
	parameter Integer n = 3;
	Real x[n];
equation
	for i in 1:n loop
		x[i] = f(sum(1.0:i));
	end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_ForEquation3",
            description="Array expressions depending on for loop index",
            flatModel="
fclass ArrayTests.For.ForEquation3
 structural parameter Integer n = 3 /* 3 */;
 constant Real x[1] = 2.0;
 constant Real x[2] = 4.0;
 constant Real x[3] = 7.0;
end ArrayTests.For.ForEquation3;
")})));
end ForEquation3;


model ForEquation4
    parameter Integer N = 3;
    Real x[N];
equation
    for i in 1:N loop
        der(x[i]) = if i == 1 then 1 else x[i-1];
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_ForEquation4",
            description="",
            flatModel="
fclass ArrayTests.For.ForEquation4
 structural parameter Integer N = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
initial equation 
 x[1] = 0.0;
 x[2] = 0.0;
 x[3] = 0.0;
equation
 der(x[1]) = 1;
 der(x[2]) = x[1];
 der(x[3]) = x[2];
end ArrayTests.For.ForEquation4;
")})));
end ForEquation4;


model ForEquation5
    parameter Integer N = 5;
    parameter Real x[2,N] = {{1, 2, 3, 4, 3}, {0.1, 0.2, 0.1, 0.4, 0.5}};
equation
    for i in 1:N-1 loop
		if x[1,i] < x[1,i+1] then
			assert(x[2,i] < x[2,i+1], "x[:2] should rise when x[:1] rises");
        else
            assert(x[2,i] > x[2,i+1], "x[:2] should fall when x[:1] falls");
		end if;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForEquation5",
            description="Test handling of if equation with parameter test using for index in expression in array index",
            errorMessage="
2 errors found:

Error in flattened model:
  Assertion failed: x[:2] should fall when x[:1] falls

Error in flattened model:
  Assertion failed: x[:2] should rise when x[:1] rises
")})));
end ForEquation5;


model ForInitial1
  parameter Integer N = 3;
  Real x[N];
initial equation
  for i in 1:N loop
    der(x[i]) = 0;
  end for;
equation
  der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_ForInitial1",
            description="For equation in initial equation block",
            flatModel="
fclass ArrayTests.For.ForInitial1
 structural parameter Integer N = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
initial equation 
 der(x[1]) = 0;
 der(x[2]) = 0;
 der(x[3]) = 0;
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
 der(x[3]) = - x[3];
end ArrayTests.For.ForInitial1;
")})));
end ForInitial1;


model ForStructural1
	parameter Boolean[2] p = {true, false};
	Real[2] x;
equation
	for i in 1:2 loop
		if p[i] then
			x[i] = time;
        else
            x[i] = 1;
		end if;
	end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForStructural1",
            description="Check that for indices aren't converted to structural parameters",
            flatModel="
fclass ArrayTests.For.ForStructural1
 structural parameter Boolean p[2] = {true, false} /* { true, false } */;
 Real x[2];
equation
 if true then
  x[1] = time;
 else
  x[1] = 1;
 end if;
 if false then
  x[2] = time;
 else
  x[2] = 1;
 end if;
end ArrayTests.For.ForStructural1;
")})));
end ForStructural1;

model ForAlgorithm1
	function f
		input Real x;
		output Real y = x + 1;
	algorithm
	end f;
	
	constant Integer n = 3;
	Real x[n];
algorithm
	for i in 2:n + 1, j in 2:n+1 loop
		x[i-1] := f(sum(1.0:j));
	end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_ForAlgorithm1",
            description="Array expressions depending on for loop index",
            variability_propagation=false,
            flatModel="
fclass ArrayTests.For.ForAlgorithm1
 constant Integer n = 3;
 Real x[1];
 Real x[2];
 Real x[3];
algorithm
 x[1] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0);
 x[1] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0 + 3.0);
 x[1] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0 + (3.0 + 4.0));
 x[2] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0);
 x[2] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0 + 3.0);
 x[2] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0 + (3.0 + 4.0));
 x[3] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0);
 x[3] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0 + 3.0);
 x[3] := ArrayTests.For.ForAlgorithm1.f(1.0 + 2.0 + (3.0 + 4.0));

public
 function ArrayTests.For.ForAlgorithm1.f
  input Real x;
  output Real y;
 algorithm
  y := x + 1;
  return;
 end ArrayTests.For.ForAlgorithm1.f;

end ArrayTests.For.ForAlgorithm1;
")})));
end ForAlgorithm1;


model ForNoRange1
    parameter Integer n = 3;
    Real x[n];
equation
    for i loop
        x[i] = i * time;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange1",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange1
 structural parameter Integer n = 3 /* 3 */;
 Real x[3];
equation
 x[1] = time;
 x[2] = 2 * time;
 x[3] = 3 * time;
end ArrayTests.For.ForNoRange1;
")})));
end ForNoRange1;


model ForNoRange2
    parameter Integer m = 2;
    parameter Integer n = 3;
    Real x[m, n];
equation
    for i, j loop
        x[i, j] = (i + j) * time;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange2",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange2
 structural parameter Integer m = 2 /* 2 */;
 structural parameter Integer n = 3 /* 3 */;
 Real x[2,3];
equation
 x[1,1] = (1 + 1) * time;
 x[1,2] = (1 + 2) * time;
 x[1,3] = (1 + 3) * time;
 x[2,1] = (2 + 1) * time;
 x[2,2] = (2 + 2) * time;
 x[2,3] = (2 + 3) * time;
end ArrayTests.For.ForNoRange2;
")})));
end ForNoRange2;


model ForNoRange3
    parameter Integer n = 3;
    Real x[:] = (1:n) * time;
    Real y[n];
equation
    for i loop
        x[i] = y[i] + i;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange3",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange3
 structural parameter Integer n = 3 /* 3 */;
 Real x[3] = (1:3) * time;
 Real y[3];
equation
 x[1] = y[1] + 1;
 x[2] = y[2] + 2;
 x[3] = y[3] + 3;
end ArrayTests.For.ForNoRange3;
")})));
end ForNoRange3;


model ForNoRange4
    parameter Integer m = 2;
    parameter Integer n = 3;
    Real x[:] = (1:m) * time;
    Real y[n];
equation
    for i loop
        x[i] = y[i] + i;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange4",
            description="",
            errorMessage="
1 errors found:

Error at line 8, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_INCONSISTENT:
  For index with implicit iteration range used for inconsistent sizes, here used for size [3] and earlier for size [2]
")})));
end ForNoRange4;


model ForNoRange5
    parameter Integer n = 3;
    Real x[n];
equation
    for i loop
        x[end - i] = time + i;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange5",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_NOT_USED:
  For index with implicit iteration range must be used as array index
")})));
end ForNoRange5;


model ForNoRange6
    parameter Integer m = 2;
    parameter Integer n = 3;
    Real x[m, n];
algorithm
    for i, j loop
        x[i, j] := (i + j) * time;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange6",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange6
 structural parameter Integer m = 2 /* 2 */;
 structural parameter Integer n = 3 /* 3 */;
 Real x[2,3];
algorithm
 x[1,1] := (1 + 1) * time;
 x[1,2] := (1 + 2) * time;
 x[1,3] := (1 + 3) * time;
 x[2,1] := (2 + 1) * time;
 x[2,2] := (2 + 2) * time;
 x[2,3] := (2 + 3) * time;
end ArrayTests.For.ForNoRange6;
")})));
end ForNoRange6;


model ForNoRange7
    parameter Integer n = 3;
    Real x[:] = (1:n) * time;
    Real y[n];
algorithm
    for i loop
        x[i] := y[i] + i;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange7",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange7
 structural parameter Integer n = 3 /* 3 */;
 Real x[3] = (1:3) * time;
 Real y[3];
algorithm
 x[1] := y[1] + 1;
 x[2] := y[2] + 2;
 x[3] := y[3] + 3;
end ArrayTests.For.ForNoRange7;
")})));
end ForNoRange7;


model ForNoRange8
    parameter Integer m = 2;
    parameter Integer n = 3;
    Real x[:] = (1:m) * time;
    Real y[n];
algorithm
    for i loop
        x[i] := y[i] + i;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange8",
            description="",
            errorMessage="
1 errors found:

Error at line 8, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_INCONSISTENT:
  For index with implicit iteration range used for inconsistent sizes, here used for size [3] and earlier for size [2]
")})));
end ForNoRange8;


model ForNoRange9
    parameter Integer n = 3;
    Real x[n];
algorithm
    for i loop
        x[end - i] := time + i;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange9",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_NOT_USED:
  For index with implicit iteration range must be used as array index
")})));
end ForNoRange9;


model ForNoRange10
    parameter Integer m = 2;
    parameter Integer n = 3;
    Real x[m, n];
    Real y[m, n] = fill(time, m, n);
equation
    x = { (i + j) * y[i, j] for j, i };

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange10",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange10
 structural parameter Integer m = 2 /* 2 */;
 structural parameter Integer n = 3 /* 3 */;
 Real x[2,3];
 Real y[2,3] = fill(time, 2, 3);
equation
 x[1:2,1:3] = {{(1 + 1) * y[1,1], (1 + 2) * y[1,2], (1 + 3) * y[1,3]}, {(2 + 1) * y[2,1], (2 + 2) * y[2,2], (2 + 3) * y[2,3]}};
end ArrayTests.For.ForNoRange10;
")})));
end ForNoRange10;


model ForNoRange11
    parameter Integer n = 3;
    Real x[:] = (1:n) * time;
    Real y[n] = { x[i] + i for i };

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange11",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange11
 structural parameter Integer n = 3 /* 3 */;
 Real x[3] = (1:3) * time;
 Real y[3] = {x[1] + 1, x[2] + 2, x[3] + 3};
end ArrayTests.For.ForNoRange11;
")})));
end ForNoRange11;


model ForNoRange12
    parameter Integer m = 2;
    parameter Integer n = 3;
    Real x[:] = (1:m) * time;
    Real y[:] = (1:n) * time;
    Real y[:] = { x[i] + y[i] for i };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange12",
            description="",
            errorMessage="
2 errors found:

Error at line 6, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Duplicate component in same class: Real y[:] = {x[i]+y[i] for i}

Error at line 6, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_INCONSISTENT:
  For index with implicit iteration range used for inconsistent sizes, here used for size [3] and earlier for size [2]
")})));
end ForNoRange12;


model ForNoRange13
    Real x[:] = { i * i for i };

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange13",
            description="",
            errorMessage="
1 errors found:

Error at line 2, column 29, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_NOT_USED:
  For index with implicit iteration range must be used as array index
")})));
end ForNoRange13;


model ForNoRange14
    function f
        input Real y[2, 3];
        output Real x[3, 2];
    algorithm
        for i, j loop
            x[i, j] := (i + j) * y[j, i];
        end for;
    end f;

    Real x[3, 2] = f(fill(time, 2, 3));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange14",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange14
 Real x[3,2] = ArrayTests.For.ForNoRange14.f(fill(time, 2, 3));

public
 function ArrayTests.For.ForNoRange14.f
  input Real[:,:] y;
  output Real[:,:] x;
 algorithm
  assert(2 == size(y, 1), \"Mismatching sizes in function 'ArrayTests.For.ForNoRange14.f', component 'y', dimension '1'\");
  assert(3 == size(y, 2), \"Mismatching sizes in function 'ArrayTests.For.ForNoRange14.f', component 'y', dimension '2'\");
  init x as Real[3, 2];
  for i in 1:3 loop
   for j in 1:2 loop
    x[i,j] := (i + j) * y[j,i];
   end for;
  end for;
  return;
 end ArrayTests.For.ForNoRange14.f;

end ArrayTests.For.ForNoRange14;
")})));
end ForNoRange14;


model ForNoRange15
    function f
        input Real y[2];
        output Real x[3];
    algorithm
        for i loop
            x[i] := y[i] + i;
        end for;
    end f;

    Real x[3] = f((1:2) * time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange15",
            description="",
            errorMessage="
1 errors found:

Error at line 7, column 23, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_INCONSISTENT:
  For index with implicit iteration range used for inconsistent sizes, here used for size [2] and earlier for size [3]
")})));
end ForNoRange15;


model ForNoRange16
    function f
        input Real y[2];
        output Real x[2];
    algorithm
        for i loop
            x[end - i] := i;
        end for;
    end f;

    Real x[2] = f((1:2) * time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="For_ForNoRange16",
            description="",
            errorMessage="
1 errors found:

Error at line 6, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', IMPLICIT_FOR_RANGE_NOT_USED:
  For index with implicit iteration range must be used as array index
")})));
end ForNoRange16;


model ForNoRange17
    Real x[4];
    parameter Integer i[:] = {2, 4, 1};
equation
    for j loop
        x[i[j]] = j * time;
    end for;
    x[3] = x[1] + x[2];

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange17",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange17
 Real x[4];
 parameter Integer i[3] = {2, 4, 1} /* { 2, 4, 1 } */;
equation
 (x[1:4])[i[1]] = time;
 (x[1:4])[i[2]] = 2 * time;
 (x[1:4])[i[3]] = 3 * time;
 x[3] = x[1] + x[2];
end ArrayTests.For.ForNoRange17;
")})));
end ForNoRange17;


model ForNoRange18
    function f
        input Real y[:, :];
        output Real x[size(y,2), size(y,1)];
    algorithm
        for i, j loop
            x[i, j] := (i + j) * y[j, i];
        end for;
    end f;

    Real x[3, 2] = f(fill(time, 2, 3));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange18",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange18
 Real x[3,2] = ArrayTests.For.ForNoRange18.f(fill(time, 2, 3));

public
 function ArrayTests.For.ForNoRange18.f
  input Real[:,:] y;
  output Real[:,:] x;
 algorithm
  init x as Real[size(y, 2), size(y, 1)];
  assert(size(y, 2) == size(y, 2), \"For index with implicit iteration range used for inconsistent sizes, i used for different sizes in y[j,i] and x[i,j]\");
  assert(size(y, 1) == size(y, 1), \"For index with implicit iteration range used for inconsistent sizes, j used for different sizes in y[j,i] and x[i,j]\");
  for i in 1:size(y, 2) loop
   for j in 1:size(y, 1) loop
    x[i,j] := (i + j) * y[j,i];
   end for;
  end for;
  return;
 end ArrayTests.For.ForNoRange18.f;

end ArrayTests.For.ForNoRange18;
")})));
end ForNoRange18;


model ForNoRange19
    function f
        input Real y[:];
        input Real z[:];
        output Real x[size(y,1)];
    algorithm
        x := { y[i] + z[i] + 1 for i };
    end f;

    Real x[2] = f((1:2) * time, (3:4) * time);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange19",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange19
 Real x[2] = ArrayTests.For.ForNoRange19.f((1:2) * time, (3:4) * time);

public
 function ArrayTests.For.ForNoRange19.f
  input Real[:] y;
  input Real[:] z;
  output Real[:] x;
 algorithm
  init x as Real[size(y, 1)];
  assert(size(z, 1) == size(y, 1), \"For index with implicit iteration range used for inconsistent sizes, i used for different sizes in z[i] and y[i]\");
  x[:] := {y[i] + z[i] + 1 for i in 1:size(y, 1)};
  return;
 end ArrayTests.For.ForNoRange19.f;

end ArrayTests.For.ForNoRange19;
")})));
end ForNoRange19;


model ForNoRange20
    function f
        input Real y[:];
        input Real z[:];
        output Real x[size(y,1)];
    algorithm
        for i loop
            x[i] := y[i] + z[i] + i;
        end for;
    end f;

    Real x[2] = f((1:2) * time, (3:5) * time);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange20",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange20
 Real x[2] = ArrayTests.For.ForNoRange20.f((1:2) * time, (3:5) * time);

public
 function ArrayTests.For.ForNoRange20.f
  input Real[:] y;
  input Real[:] z;
  output Real[:] x;
 algorithm
  init x as Real[size(y, 1)];
  assert(size(y, 1) == size(y, 1), \"For index with implicit iteration range used for inconsistent sizes, i used for different sizes in y[i] and x[i]\");
  assert(size(z, 1) == size(y, 1), \"For index with implicit iteration range used for inconsistent sizes, i used for different sizes in z[i] and x[i]\");
  for i in 1:size(y, 1) loop
   x[i] := y[i] + z[i] + i;
  end for;
  return;
 end ArrayTests.For.ForNoRange20.f;

end ArrayTests.For.ForNoRange20;
")})));
end ForNoRange20;


model ForNoRange21
    function f
        input Real y[:];
        input Real z[:];
        input Real w[2];
        output Real x[2];
    algorithm
        for i loop
            x[i] := y[i] + z[i] + w[i] + i;
        end for;
    end f;

    Real y[2] = (1:2) * time;
    Real x[2] = f(y, y, y);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="For_ForNoRange21",
            description="",
            flatModel="
fclass ArrayTests.For.ForNoRange21
 Real y[2] = (1:2) * time;
 Real x[2] = ArrayTests.For.ForNoRange21.f(y[1:2], y[1:2], y[1:2]);

public
 function ArrayTests.For.ForNoRange21.f
  input Real[:] y;
  input Real[:] z;
  input Real[:] w;
  output Real[:] x;
 algorithm
  assert(2 == size(w, 1), \"Mismatching sizes in function 'ArrayTests.For.ForNoRange21.f', component 'w', dimension '1'\");
  init x as Real[2];
  assert(size(y, 1) == 2, \"For index with implicit iteration range used for inconsistent sizes, i used for different sizes in y[i] and x[i]\");
  assert(size(z, 1) == 2, \"For index with implicit iteration range used for inconsistent sizes, i used for different sizes in z[i] and x[i]\");
  for i in 1:2 loop
   x[i] := y[i] + z[i] + w[i] + i;
  end for;
  return;
 end ArrayTests.For.ForNoRange21.f;

end ArrayTests.For.ForNoRange21;
")})));
end ForNoRange21;

end For;



package Slices
	
model SliceTest1
 model A
  Real a[2];
 end A;
 
 A x[2](a={{1,2},{3,4}});
 Real y[2,2] = x.a .+ 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Slices_SliceTest1",
            description="Slice operations: basic test",
            flatModel="
fclass ArrayTests.Slices.SliceTest1
 Real x[1].a[2] = {1, 2};
 Real x[2].a[2] = {3, 4};
 Real y[2,2] = {{x[1].a[1], x[1].a[2]}, {x[2].a[1], x[2].a[2]}} .+ 1;
end ArrayTests.Slices.SliceTest1;
")})));
end SliceTest1;


model SliceTest2
 model A
  Real a[2];
 end A;
 
 A x[2](a={{1,2},{3,4}});
 Real y[2,2] = x.a .+ 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Slices_SliceTest2",
            description="Slice operations: basic test",
            flatModel="
fclass ArrayTests.Slices.SliceTest2
 constant Real x[1].a[1] = 1;
 constant Real x[1].a[2] = 2;
 constant Real x[2].a[1] = 3;
 constant Real x[2].a[2] = 4;
 constant Real y[1,1] = 2.0;
 constant Real y[1,2] = 3.0;
 constant Real y[2,1] = 4.0;
 constant Real y[2,2] = 5.0;
end ArrayTests.Slices.SliceTest2;
")})));
end SliceTest2;


model SliceTest3
 model A
  Real a[4];
 end A;
 
 A x[4](a={{1,2,3,4},{1,2,3,4},{1,2,3,4},{1,2,3,4}});
 Real y[2,2] = x[2:3].a[{2,4}] .+ 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Slices_SliceTest3",
            description="Slice operations: test with vector indices",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Slices.SliceTest3
 constant Real x[1].a[1] = 1;
 constant Real x[1].a[2] = 2;
 constant Real x[1].a[3] = 3;
 constant Real x[1].a[4] = 4;
 constant Real x[2].a[1] = 1;
 constant Real x[2].a[2] = 2;
 constant Real x[2].a[3] = 3;
 constant Real x[2].a[4] = 4;
 constant Real x[3].a[1] = 1;
 constant Real x[3].a[2] = 2;
 constant Real x[3].a[3] = 3;
 constant Real x[3].a[4] = 4;
 constant Real x[4].a[1] = 1;
 constant Real x[4].a[2] = 2;
 constant Real x[4].a[3] = 3;
 constant Real x[4].a[4] = 4;
 constant Real y[1,1] = 3.0;
 constant Real y[1,2] = 5.0;
 constant Real y[2,1] = 3.0;
 constant Real y[2,2] = 5.0;
end ArrayTests.Slices.SliceTest3;
")})));
end SliceTest3;

model SliceTest4
    function f
        input Real[2] i;
        output Real[2] o;
        output Real dummy = 1;
    algorithm
        o := i;
    end f;
    
    function fw
        output Real[5] o;
        output Real dummy = 1;
    algorithm
        o[{1,3,5}] := {1,1,1};
        (o[{2,4}],) := f(o[{3,5}]);
    end fw;
    
    Real[5] a,ae;
algorithm
    (a[{2,4}],) := f({1,1});
    (a[{5,4,3,2,1}],) := fw();
equation
    (ae[{5,4,3,2,1}],) = fw();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Slices_SliceTest4",
            description="Slice operations: test with vector indices",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass ArrayTests.Slices.SliceTest4
 Real a[1];
 Real a[2];
 Real a[3];
 Real a[4];
 Real a[5];
 Real ae[1];
 Real ae[2];
 Real ae[3];
 Real ae[4];
 Real ae[5];
equation
 ({ae[5], ae[4], ae[3], ae[2], ae[1]}, ) = ArrayTests.Slices.SliceTest4.fw();
algorithm
 ({a[2], a[4]}, ) := ArrayTests.Slices.SliceTest4.f({1, 1});
 ({a[5], a[4], a[3], a[2], a[1]}, ) := ArrayTests.Slices.SliceTest4.fw();

public
 function ArrayTests.Slices.SliceTest4.fw
  output Real[:] o;
  output Real dummy;
  Integer[:] temp_1;
  Integer[:] temp_2;
  Real[:] temp_3;
  Integer[:] temp_4;
  Real[:] temp_5;
  Integer[:] temp_6;
 algorithm
  init o as Real[5];
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
  init temp_4 as Integer[2];
  temp_4[1] := 3;
  temp_4[2] := 5;
  init temp_3 as Real[2];
  for i1 in 1:2 loop
   temp_3[i1] := o[temp_4[i1]];
  end for;
  init temp_5 as Real[2];
  (temp_5, ) := ArrayTests.Slices.SliceTest4.f(temp_3);
  init temp_6 as Integer[2];
  temp_6[1] := 2;
  temp_6[2] := 4;
  for i1 in 1:2 loop
   o[temp_6[i1]] := temp_5[i1];
  end for;
  return;
 end ArrayTests.Slices.SliceTest4.fw;

 function ArrayTests.Slices.SliceTest4.f
  input Real[:] i;
  output Real[:] o;
  output Real dummy;
 algorithm
  init o as Real[2];
  dummy := 1;
  for i1 in 1:2 loop
   o[i1] := i[i1];
  end for;
  return;
 end ArrayTests.Slices.SliceTest4.f;

end ArrayTests.Slices.SliceTest4;
")})));
end SliceTest4;


model MixedIndices1
 model M
   Real x[2,2] = identity(2);
 end M;
 
 M m[2];
 Real y[2,2,2];
 Real z[2,2,2];
equation
 for i in 1:2 loop
  der(y[i,:,:]) = m[i].x;
  z[i,:,:] = m[i].x;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Slices_MixedIndices1",
            description="Mixing for index subscripts with colon subscripts",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Slices.MixedIndices1
 constant Real m[1].x[1,1] = 1;
 constant Real m[1].x[1,2] = 0;
 constant Real m[1].x[2,1] = 0;
 constant Real m[1].x[2,2] = 1;
 constant Real m[2].x[1,1] = 1;
 constant Real m[2].x[1,2] = 0;
 constant Real m[2].x[2,1] = 0;
 constant Real m[2].x[2,2] = 1;
 Real y[1,1,1];
 Real y[1,1,2];
 Real y[1,2,1];
 Real y[1,2,2];
 Real y[2,1,1];
 Real y[2,1,2];
 Real y[2,2,1];
 Real y[2,2,2];
 constant Real z[1,1,1] = 1.0;
 constant Real z[1,1,2] = 0.0;
 constant Real z[1,2,1] = 0.0;
 constant Real z[1,2,2] = 1.0;
 constant Real z[2,1,1] = 1.0;
 constant Real z[2,1,2] = 0.0;
 constant Real z[2,2,1] = 0.0;
 constant Real z[2,2,2] = 1.0;
initial equation 
 y[1,1,1] = 0.0;
 y[1,1,2] = 0.0;
 y[1,2,1] = 0.0;
 y[1,2,2] = 0.0;
 y[2,1,1] = 0.0;
 y[2,1,2] = 0.0;
 y[2,2,1] = 0.0;
 y[2,2,2] = 0.0;
equation
 der(y[1,1,1]) = 1.0;
 der(y[1,1,2]) = 0.0;
 der(y[1,2,1]) = 0.0;
 der(y[1,2,2]) = 1.0;
 der(y[2,1,1]) = 1.0;
 der(y[2,1,2]) = 0.0;
 der(y[2,2,1]) = 0.0;
 der(y[2,2,2]) = 1.0;
end ArrayTests.Slices.MixedIndices1;
")})));
end MixedIndices1;


model MixedIndices2
 Real y[4,2];
 Real z[2,2] = identity(2);
equation
 for i in 0:2:2 loop
   y[(1:2).+i,:] = z[:,:] * 2;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Slices_MixedIndices2",
            description="Mixing expression subscripts containing for indices with colon subscripts",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Slices.MixedIndices2
 constant Real y[1,1] = 2.0;
 constant Real y[1,2] = 0.0;
 constant Real y[2,1] = 0.0;
 constant Real y[2,2] = 2.0;
 constant Real y[3,1] = 2.0;
 constant Real y[3,2] = 0.0;
 constant Real y[4,1] = 0.0;
 constant Real y[4,2] = 2.0;
 constant Real z[1,1] = 1;
 constant Real z[1,2] = 0;
 constant Real z[2,1] = 0;
 constant Real z[2,2] = 1;
end ArrayTests.Slices.MixedIndices2;
")})));
end MixedIndices2;


model EmptySlice1
    model A
        Real x;
    end A;
    
    parameter Integer n = 0;
    A a[n];
    Real y[n] = a.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Slices_EmptySlice1",
            description="Slice in empty array of components",
            flatModel="
fclass ArrayTests.Slices.EmptySlice1
 structural parameter Integer n = 0 /* 0 */;
 Real y[0] = fill(0.0, 0);
end ArrayTests.Slices.EmptySlice1;
")})));
end EmptySlice1;

end Slices;

package VariableIndex

model Equation
    Real table[:] = {42, 3.14};
    Integer i = if time > 1 then 1 else 2;
    Real x = table[i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Equation",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.Equation
 constant Real table[1] = 42;
 constant Real table[2] = 3.14;
 discrete Integer i;
 Real x;
initial equation 
 pre(i) = 0;
equation
 i = if time > 1 then 1 else 2;
 x = ({42.0, 3.14})[i];
end ArrayTests.VariableIndex.Equation;
")})));
end Equation;

model TwoDim1
    Real table[:,:] = {{1, 2}, {3, 4}};
    Integer i = if time > 1 then 1 else 2;
    Real x = table[i,2];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_TwoDim1",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.TwoDim1
 constant Real table[1,1] = 1;
 constant Real table[1,2] = 2;
 constant Real table[2,1] = 3;
 constant Real table[2,2] = 4;
 discrete Integer i;
 Real x;
initial equation 
 pre(i) = 0;
equation
 i = if time > 1 then 1 else 2;
 x = ({2.0, 4.0})[i];
end ArrayTests.VariableIndex.TwoDim1;
")})));
end TwoDim1;

model TwoDim2
    Real table[:,:] = {{1, 2}, {3, 4}};
    Integer i = if time > 1 then 1 else 2;
    Real x = table[1,i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_TwoDim2",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.TwoDim2
 constant Real table[1,1] = 1;
 constant Real table[1,2] = 2;
 constant Real table[2,1] = 3;
 constant Real table[2,2] = 4;
 discrete Integer i;
 Real x;
initial equation 
 pre(i) = 0;
equation
 i = if time > 1 then 1 else 2;
 x = ({1.0, 2.0})[i];
end ArrayTests.VariableIndex.TwoDim2;
")})));
end TwoDim2;

model TwoDim3
    Real table[:,:] = {{1, 2}, {3, 4}};
    Integer i1 = if time > 1 then 1 else 2;
    Integer i2 = if time > 0.5 then 1 else 2;
    Real x = table[i1,i2];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_TwoDim3",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.TwoDim3
 constant Real table[1,1] = 1;
 constant Real table[1,2] = 2;
 constant Real table[2,1] = 3;
 constant Real table[2,2] = 4;
 discrete Integer i1;
 discrete Integer i2;
 Real x;
initial equation 
 pre(i1) = 0;
 pre(i2) = 0;
equation
 i1 = if time > 1 then 1 else 2;
 i2 = if time > 0.5 then 1 else 2;
 x = ({{1.0, 2.0}, {3.0, 4.0}})[i1,i2];
end ArrayTests.VariableIndex.TwoDim3;
")})));
end TwoDim3;

model TwoDim4
    Real table[:,:] = {{1, 2}, {3, 4}};
    Integer i = if time > 1 then 1 else 2;
    Real x[2] = table[i,:];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_TwoDim4",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.TwoDim4
 constant Real table[1,1] = 1;
 constant Real table[1,2] = 2;
 constant Real table[2,1] = 3;
 constant Real table[2,2] = 4;
 discrete Integer i;
 Real x[1];
 Real x[2];
initial equation 
 pre(i) = 0;
equation
 i = if time > 1 then 1 else 2;
 x[1] = ({{1.0, 2.0}, {3.0, 4.0}})[i,1];
 x[2] = ({{1.0, 2.0}, {3.0, 4.0}})[i,2];
end ArrayTests.VariableIndex.TwoDim4;
")})));
end TwoDim4;

model TwoDim5
    Real table[:,:] = {{1, 2}, {3, 4}};
    Integer i = if time > 1 then 1 else 2;
    Real x[2] = table[:,i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_TwoDim5",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.TwoDim5
 constant Real table[1,1] = 1;
 constant Real table[1,2] = 2;
 constant Real table[2,1] = 3;
 constant Real table[2,2] = 4;
 discrete Integer i;
 Real x[1];
 Real x[2];
initial equation 
 pre(i) = 0;
equation
 i = if time > 1 then 1 else 2;
 x[1] = ({{1.0, 2.0}, {3.0, 4.0}})[1,i];
 x[2] = ({{1.0, 2.0}, {3.0, 4.0}})[2,i];
end ArrayTests.VariableIndex.TwoDim5;
")})));
end TwoDim5;

model TwoDim6
    Real table[:,:] = {{1, 2}, {3, 4}, {5, 6}, {7, 8}};
    Integer i = if time > 1 then 1 else 2;
    Real x[2] = table[{2,3},i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_TwoDim6",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.TwoDim6
 constant Real table[1,1] = 1;
 constant Real table[1,2] = 2;
 constant Real table[2,1] = 3;
 constant Real table[2,2] = 4;
 constant Real table[3,1] = 5;
 constant Real table[3,2] = 6;
 constant Real table[4,1] = 7;
 constant Real table[4,2] = 8;
 discrete Integer i;
 Real x[1];
 Real x[2];
initial equation 
 pre(i) = 0;
equation
 i = if time > 1 then 1 else 2;
 x[1] = ({{3.0, 4.0}, {5.0, 6.0}})[1,i];
 x[2] = ({{3.0, 4.0}, {5.0, 6.0}})[2,i];
end ArrayTests.VariableIndex.TwoDim6;
")})));
end TwoDim6;

model TwoDim7
    Real table[:,:] = {{1, 2, 3, 4}, {5, 6, 7, 8}};
    Integer i = if time > 1 then 1 else 2;
    Real x[2] = table[i, {2,3}];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_TwoDim7",
            description="Test array index with discrete variability in equation",
            flatModel="
fclass ArrayTests.VariableIndex.TwoDim7
 constant Real table[1,1] = 1;
 constant Real table[1,2] = 2;
 constant Real table[1,3] = 3;
 constant Real table[1,4] = 4;
 constant Real table[2,1] = 5;
 constant Real table[2,2] = 6;
 constant Real table[2,3] = 7;
 constant Real table[2,4] = 8;
 discrete Integer i;
 Real x[1];
 Real x[2];
initial equation 
 pre(i) = 0;
equation
 i = if time > 1 then 1 else 2;
 x[1] = ({{2.0, 3.0}, {6.0, 7.0}})[i,1];
 x[2] = ({{2.0, 3.0}, {6.0, 7.0}})[i,2];
end ArrayTests.VariableIndex.TwoDim7;
")})));
end TwoDim7;

model Algorithm
    Real table[:] = {42, 3.14};
    Integer i = if time > 1 then 1 else 2;
    Real x;
algorithm
    x := table[i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Algorithm",
            description="Test array index with discrete variability in algorithm",
            variability_propagation=false,
            flatModel="
fclass ArrayTests.VariableIndex.Algorithm
 Real table[1];
 Real table[2];
 discrete Integer i;
 Real x;
initial equation 
 pre(i) = 0;
algorithm
 x := ({table[1], table[2]})[i];
equation
 table[1] = 42;
 table[2] = 3.14;
 i = if time > 1 then 1 else 2;
end ArrayTests.VariableIndex.Algorithm;
")})));
end Algorithm;

model Enum
    type ABC = enumeration(A,B,C);
    ABC table[ABC] = {ABC.A, ABC.B, ABC.C};
    ABC i = if time > 1 then ABC.A else ABC.B;
    ABC x = table[i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Enum",
            description="Test enum array index with discrete variability",
            flatModel="
fclass ArrayTests.VariableIndex.Enum
 constant ArrayTests.VariableIndex.Enum.ABC table[1] = ArrayTests.VariableIndex.Enum.ABC.A;
 constant ArrayTests.VariableIndex.Enum.ABC table[2] = ArrayTests.VariableIndex.Enum.ABC.B;
 constant ArrayTests.VariableIndex.Enum.ABC table[3] = ArrayTests.VariableIndex.Enum.ABC.C;
 discrete ArrayTests.VariableIndex.Enum.ABC i;
 discrete ArrayTests.VariableIndex.Enum.ABC x;
initial equation 
 pre(i) = ArrayTests.VariableIndex.Enum.ABC.A;
 pre(x) = ArrayTests.VariableIndex.Enum.ABC.A;
equation
 i = if time > 1 then ArrayTests.VariableIndex.Enum.ABC.A else ArrayTests.VariableIndex.Enum.ABC.B;
 x = ({ArrayTests.VariableIndex.Enum.ABC.A, ArrayTests.VariableIndex.Enum.ABC.B, ArrayTests.VariableIndex.Enum.ABC.C})[i];

public
 type ArrayTests.VariableIndex.Enum.ABC = enumeration(A, B, C);

end ArrayTests.VariableIndex.Enum;
")})));
end Enum;

model Bool
    type ABC = enumeration(A,B,C);
    Boolean table[Boolean] = {true, false};
    Boolean i = if time > 1 then false else true;
    Boolean x = table[i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Bool",
            description="Test bool array index with discrete variability",
            flatModel="
fclass ArrayTests.VariableIndex.Bool
 constant Boolean table[1] = true;
 constant Boolean table[2] = false;
 discrete Boolean i;
 discrete Boolean x;
initial equation 
 pre(i) = false;
 pre(x) = false;
equation
 i = if time > 1 then false else true;
 x = ({true, false})[i];
end ArrayTests.VariableIndex.Bool;
")})));
end Bool;

model ExpEquation
    package P
      constant Real[3] c = {1,2,3};
    end P;
    input Integer i;
    Real y = P.c[i];
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_ExpEquation",
            description="Subscripted exp with discrete index",
            flatModel="
fclass ArrayTests.VariableIndex.ExpEquation
 discrete input Integer i;
 Real y;
equation
 y = ({1.0, 2.0, 3.0})[i];
end ArrayTests.VariableIndex.ExpEquation;
")})));
end ExpEquation;

model ExpEquationArray
    package P
      constant Real[3] c = {1,2,3};
    end P;
    input Integer i;
    Real[2] y = P.c[{i,i+1}];
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_ExpEquationArray",
            description="Subscripted exp with discrete index, non scalar",
            flatModel="
fclass ArrayTests.VariableIndex.ExpEquationArray
 discrete input Integer i;
 Real y[1];
 Real y[2];
equation
 y[1] = ({1.0, 2.0, 3.0})[i];
 y[2] = ({1.0, 2.0, 3.0})[i + 1];
end ArrayTests.VariableIndex.ExpEquationArray;
")})));
end ExpEquationArray;

model RecordArrayEquation1
    record R
        Real y = i + 1/2;
        Integer i;
    end R;
    R[3] x = {R(i=i+1),R(i=i+2),R(i=i+3)};
    Integer i = integer(time);
    R r = x[i];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_RecordArrayEquation1",
            description="Test of variable array index access",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.RecordArrayEquation1
 Real x[1].y;
 discrete Integer x[1].i;
 Real x[2].y;
 discrete Integer x[2].i;
 Real x[3].y;
 discrete Integer x[3].i;
 discrete Integer i;
 Real r.y;
 discrete Integer r.i;
initial equation 
 pre(i) = 0;
 pre(x[1].i) = 0;
 pre(x[2].i) = 0;
 pre(x[3].i) = 0;
 pre(r.i) = 0;
equation
 x[1].y = i + 1 + 0.5;
 x[1].i = i + 1;
 x[2].y = i + 2 + 0.5;
 x[2].i = i + 2;
 x[3].y = i + 3 + 0.5;
 x[3].i = i + 3;
 r.y = ({x[1].y, x[2].y, x[3].y})[i];
 r.i = ({x[1].i, x[2].i, x[3].i})[i];
 i = if time < pre(i) or time >= pre(i) + 1 or initial() then integer(time) else pre(i);
end ArrayTests.VariableIndex.RecordArrayEquation1;
")})));
end RecordArrayEquation1;

model RecordArrayEquation2
    record R
        Real x;
    end R;
    R[:,:] x = {{R(time) for i in 1:3}};
    Integer i = integer(time);
    R[1,2] y;
    parameter Integer p = 1;
equation
    for k in 1:1 loop
        for j in 1:2 loop
            y[k,j+i] = x[k,j+p+i];
        end for;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_RecordArrayEquation2",
            description="Test of variable array index access",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.RecordArrayEquation2
 Real x[1,1].x;
 Real x[1,2].x;
 Real x[1,3].x;
 discrete Integer i;
 Real y[1,1].x;
 Real y[1,2].x;
 parameter Integer p = 1 /* 1 */;
initial equation 
 pre(i) = 0;
equation
 ({y[1,1].x, y[1,2].x})[1 + i] = ({x[1,1].x, x[1,2].x, x[1,3].x})[1 + p + i];
 ({y[1,1].x, y[1,2].x})[2 + i] = ({x[1,1].x, x[1,2].x, x[1,3].x})[2 + p + i];
 x[1,1].x = time;
 x[1,2].x = time;
 x[1,3].x = time;
 i = if time < pre(i) or time >= pre(i) + 1 or initial() then integer(time) else pre(i);
end ArrayTests.VariableIndex.RecordArrayEquation2;
")})));
end RecordArrayEquation2;

model ExpEquationCombination
    Real[:,:,:,:] x = fill(time,2,3,4,5);
    Real[:,:] y = x[2,{i,j},2:4,k];
    discrete Integer i,j,k;
initial equation
    i = 1;
    j = 2;
    k = 3;
equation
    when time > 1 then
        i = 2;
        j = 1;
        k = 4;
    end when;
    
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_ExpEquationCombination",
            description="Test of variable array index access",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.ExpEquationCombination
 Real x[1,1,1,1];
 Real x[1,1,1,2];
 Real x[1,1,1,3];
 Real x[1,1,1,4];
 Real x[1,1,1,5];
 Real x[1,1,2,1];
 Real x[1,1,2,2];
 Real x[1,1,2,3];
 Real x[1,1,2,4];
 Real x[1,1,2,5];
 Real x[1,1,3,1];
 Real x[1,1,3,2];
 Real x[1,1,3,3];
 Real x[1,1,3,4];
 Real x[1,1,3,5];
 Real x[1,1,4,1];
 Real x[1,1,4,2];
 Real x[1,1,4,3];
 Real x[1,1,4,4];
 Real x[1,1,4,5];
 Real x[1,2,1,1];
 Real x[1,2,1,2];
 Real x[1,2,1,3];
 Real x[1,2,1,4];
 Real x[1,2,1,5];
 Real x[1,2,2,1];
 Real x[1,2,2,2];
 Real x[1,2,2,3];
 Real x[1,2,2,4];
 Real x[1,2,2,5];
 Real x[1,2,3,1];
 Real x[1,2,3,2];
 Real x[1,2,3,3];
 Real x[1,2,3,4];
 Real x[1,2,3,5];
 Real x[1,2,4,1];
 Real x[1,2,4,2];
 Real x[1,2,4,3];
 Real x[1,2,4,4];
 Real x[1,2,4,5];
 Real x[1,3,1,1];
 Real x[1,3,1,2];
 Real x[1,3,1,3];
 Real x[1,3,1,4];
 Real x[1,3,1,5];
 Real x[1,3,2,1];
 Real x[1,3,2,2];
 Real x[1,3,2,3];
 Real x[1,3,2,4];
 Real x[1,3,2,5];
 Real x[1,3,3,1];
 Real x[1,3,3,2];
 Real x[1,3,3,3];
 Real x[1,3,3,4];
 Real x[1,3,3,5];
 Real x[1,3,4,1];
 Real x[1,3,4,2];
 Real x[1,3,4,3];
 Real x[1,3,4,4];
 Real x[1,3,4,5];
 Real x[2,1,1,1];
 Real x[2,1,1,2];
 Real x[2,1,1,3];
 Real x[2,1,1,4];
 Real x[2,1,1,5];
 Real x[2,1,2,1];
 Real x[2,1,2,2];
 Real x[2,1,2,3];
 Real x[2,1,2,4];
 Real x[2,1,2,5];
 Real x[2,1,3,1];
 Real x[2,1,3,2];
 Real x[2,1,3,3];
 Real x[2,1,3,4];
 Real x[2,1,3,5];
 Real x[2,1,4,1];
 Real x[2,1,4,2];
 Real x[2,1,4,3];
 Real x[2,1,4,4];
 Real x[2,1,4,5];
 Real x[2,2,1,1];
 Real x[2,2,1,2];
 Real x[2,2,1,3];
 Real x[2,2,1,4];
 Real x[2,2,1,5];
 Real x[2,2,2,1];
 Real x[2,2,2,2];
 Real x[2,2,2,3];
 Real x[2,2,2,4];
 Real x[2,2,2,5];
 Real x[2,2,3,1];
 Real x[2,2,3,2];
 Real x[2,2,3,3];
 Real x[2,2,3,4];
 Real x[2,2,3,5];
 Real x[2,2,4,1];
 Real x[2,2,4,2];
 Real x[2,2,4,3];
 Real x[2,2,4,4];
 Real x[2,2,4,5];
 Real x[2,3,1,1];
 Real x[2,3,1,2];
 Real x[2,3,1,3];
 Real x[2,3,1,4];
 Real x[2,3,1,5];
 Real x[2,3,2,1];
 Real x[2,3,2,2];
 Real x[2,3,2,3];
 Real x[2,3,2,4];
 Real x[2,3,2,5];
 Real x[2,3,3,1];
 Real x[2,3,3,2];
 Real x[2,3,3,3];
 Real x[2,3,3,4];
 Real x[2,3,3,5];
 Real x[2,3,4,1];
 Real x[2,3,4,2];
 Real x[2,3,4,3];
 Real x[2,3,4,4];
 Real x[2,3,4,5];
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
 discrete Integer i;
 discrete Integer j;
 discrete Integer k;
 discrete Boolean temp_1;
initial equation 
 i = 1;
 j = 2;
 k = 3;
 pre(temp_1) = false;
equation
 temp_1 = time > 1;
 i = if temp_1 and not pre(temp_1) then 2 else pre(i);
 j = if temp_1 and not pre(temp_1) then 1 else pre(j);
 k = if temp_1 and not pre(temp_1) then 4 else pre(k);
 x[1,1,1,1] = time;
 x[1,1,1,2] = time;
 x[1,1,1,3] = time;
 x[1,1,1,4] = time;
 x[1,1,1,5] = time;
 x[1,1,2,1] = time;
 x[1,1,2,2] = time;
 x[1,1,2,3] = time;
 x[1,1,2,4] = time;
 x[1,1,2,5] = time;
 x[1,1,3,1] = time;
 x[1,1,3,2] = time;
 x[1,1,3,3] = time;
 x[1,1,3,4] = time;
 x[1,1,3,5] = time;
 x[1,1,4,1] = time;
 x[1,1,4,2] = time;
 x[1,1,4,3] = time;
 x[1,1,4,4] = time;
 x[1,1,4,5] = time;
 x[1,2,1,1] = time;
 x[1,2,1,2] = time;
 x[1,2,1,3] = time;
 x[1,2,1,4] = time;
 x[1,2,1,5] = time;
 x[1,2,2,1] = time;
 x[1,2,2,2] = time;
 x[1,2,2,3] = time;
 x[1,2,2,4] = time;
 x[1,2,2,5] = time;
 x[1,2,3,1] = time;
 x[1,2,3,2] = time;
 x[1,2,3,3] = time;
 x[1,2,3,4] = time;
 x[1,2,3,5] = time;
 x[1,2,4,1] = time;
 x[1,2,4,2] = time;
 x[1,2,4,3] = time;
 x[1,2,4,4] = time;
 x[1,2,4,5] = time;
 x[1,3,1,1] = time;
 x[1,3,1,2] = time;
 x[1,3,1,3] = time;
 x[1,3,1,4] = time;
 x[1,3,1,5] = time;
 x[1,3,2,1] = time;
 x[1,3,2,2] = time;
 x[1,3,2,3] = time;
 x[1,3,2,4] = time;
 x[1,3,2,5] = time;
 x[1,3,3,1] = time;
 x[1,3,3,2] = time;
 x[1,3,3,3] = time;
 x[1,3,3,4] = time;
 x[1,3,3,5] = time;
 x[1,3,4,1] = time;
 x[1,3,4,2] = time;
 x[1,3,4,3] = time;
 x[1,3,4,4] = time;
 x[1,3,4,5] = time;
 x[2,1,1,1] = time;
 x[2,1,1,2] = time;
 x[2,1,1,3] = time;
 x[2,1,1,4] = time;
 x[2,1,1,5] = time;
 x[2,1,2,1] = time;
 x[2,1,2,2] = time;
 x[2,1,2,3] = time;
 x[2,1,2,4] = time;
 x[2,1,2,5] = time;
 x[2,1,3,1] = time;
 x[2,1,3,2] = time;
 x[2,1,3,3] = time;
 x[2,1,3,4] = time;
 x[2,1,3,5] = time;
 x[2,1,4,1] = time;
 x[2,1,4,2] = time;
 x[2,1,4,3] = time;
 x[2,1,4,4] = time;
 x[2,1,4,5] = time;
 x[2,2,1,1] = time;
 x[2,2,1,2] = time;
 x[2,2,1,3] = time;
 x[2,2,1,4] = time;
 x[2,2,1,5] = time;
 x[2,2,2,1] = time;
 x[2,2,2,2] = time;
 x[2,2,2,3] = time;
 x[2,2,2,4] = time;
 x[2,2,2,5] = time;
 x[2,2,3,1] = time;
 x[2,2,3,2] = time;
 x[2,2,3,3] = time;
 x[2,2,3,4] = time;
 x[2,2,3,5] = time;
 x[2,2,4,1] = time;
 x[2,2,4,2] = time;
 x[2,2,4,3] = time;
 x[2,2,4,4] = time;
 x[2,2,4,5] = time;
 x[2,3,1,1] = time;
 x[2,3,1,2] = time;
 x[2,3,1,3] = time;
 x[2,3,1,4] = time;
 x[2,3,1,5] = time;
 x[2,3,2,1] = time;
 x[2,3,2,2] = time;
 x[2,3,2,3] = time;
 x[2,3,2,4] = time;
 x[2,3,2,5] = time;
 x[2,3,3,1] = time;
 x[2,3,3,2] = time;
 x[2,3,3,3] = time;
 x[2,3,3,4] = time;
 x[2,3,3,5] = time;
 x[2,3,4,1] = time;
 x[2,3,4,2] = time;
 x[2,3,4,3] = time;
 x[2,3,4,4] = time;
 x[2,3,4,5] = time;
 y[1,1] = ({{{x[2,1,2,1], x[2,1,2,2], x[2,1,2,3], x[2,1,2,4], x[2,1,2,5]}, {x[2,1,3,1], x[2,1,3,2], x[2,1,3,3], x[2,1,3,4], x[2,1,3,5]}, {x[2,1,4,1], x[2,1,4,2], x[2,1,4,3], x[2,1,4,4], x[2,1,4,5]}}, {{x[2,2,2,1], x[2,2,2,2], x[2,2,2,3], x[2,2,2,4], x[2,2,2,5]}, {x[2,2,3,1], x[2,2,3,2], x[2,2,3,3], x[2,2,3,4], x[2,2,3,5]}, {x[2,2,4,1], x[2,2,4,2], x[2,2,4,3], x[2,2,4,4], x[2,2,4,5]}}, {{x[2,3,2,1], x[2,3,2,2], x[2,3,2,3], x[2,3,2,4], x[2,3,2,5]}, {x[2,3,3,1], x[2,3,3,2], x[2,3,3,3], x[2,3,3,4], x[2,3,3,5]}, {x[2,3,4,1], x[2,3,4,2], x[2,3,4,3], x[2,3,4,4], x[2,3,4,5]}}})[i,1,k];
 y[1,2] = ({{{x[2,1,2,1], x[2,1,2,2], x[2,1,2,3], x[2,1,2,4], x[2,1,2,5]}, {x[2,1,3,1], x[2,1,3,2], x[2,1,3,3], x[2,1,3,4], x[2,1,3,5]}, {x[2,1,4,1], x[2,1,4,2], x[2,1,4,3], x[2,1,4,4], x[2,1,4,5]}}, {{x[2,2,2,1], x[2,2,2,2], x[2,2,2,3], x[2,2,2,4], x[2,2,2,5]}, {x[2,2,3,1], x[2,2,3,2], x[2,2,3,3], x[2,2,3,4], x[2,2,3,5]}, {x[2,2,4,1], x[2,2,4,2], x[2,2,4,3], x[2,2,4,4], x[2,2,4,5]}}, {{x[2,3,2,1], x[2,3,2,2], x[2,3,2,3], x[2,3,2,4], x[2,3,2,5]}, {x[2,3,3,1], x[2,3,3,2], x[2,3,3,3], x[2,3,3,4], x[2,3,3,5]}, {x[2,3,4,1], x[2,3,4,2], x[2,3,4,3], x[2,3,4,4], x[2,3,4,5]}}})[i,2,k];
 y[1,3] = ({{{x[2,1,2,1], x[2,1,2,2], x[2,1,2,3], x[2,1,2,4], x[2,1,2,5]}, {x[2,1,3,1], x[2,1,3,2], x[2,1,3,3], x[2,1,3,4], x[2,1,3,5]}, {x[2,1,4,1], x[2,1,4,2], x[2,1,4,3], x[2,1,4,4], x[2,1,4,5]}}, {{x[2,2,2,1], x[2,2,2,2], x[2,2,2,3], x[2,2,2,4], x[2,2,2,5]}, {x[2,2,3,1], x[2,2,3,2], x[2,2,3,3], x[2,2,3,4], x[2,2,3,5]}, {x[2,2,4,1], x[2,2,4,2], x[2,2,4,3], x[2,2,4,4], x[2,2,4,5]}}, {{x[2,3,2,1], x[2,3,2,2], x[2,3,2,3], x[2,3,2,4], x[2,3,2,5]}, {x[2,3,3,1], x[2,3,3,2], x[2,3,3,3], x[2,3,3,4], x[2,3,3,5]}, {x[2,3,4,1], x[2,3,4,2], x[2,3,4,3], x[2,3,4,4], x[2,3,4,5]}}})[i,3,k];
 y[2,1] = ({{{x[2,1,2,1], x[2,1,2,2], x[2,1,2,3], x[2,1,2,4], x[2,1,2,5]}, {x[2,1,3,1], x[2,1,3,2], x[2,1,3,3], x[2,1,3,4], x[2,1,3,5]}, {x[2,1,4,1], x[2,1,4,2], x[2,1,4,3], x[2,1,4,4], x[2,1,4,5]}}, {{x[2,2,2,1], x[2,2,2,2], x[2,2,2,3], x[2,2,2,4], x[2,2,2,5]}, {x[2,2,3,1], x[2,2,3,2], x[2,2,3,3], x[2,2,3,4], x[2,2,3,5]}, {x[2,2,4,1], x[2,2,4,2], x[2,2,4,3], x[2,2,4,4], x[2,2,4,5]}}, {{x[2,3,2,1], x[2,3,2,2], x[2,3,2,3], x[2,3,2,4], x[2,3,2,5]}, {x[2,3,3,1], x[2,3,3,2], x[2,3,3,3], x[2,3,3,4], x[2,3,3,5]}, {x[2,3,4,1], x[2,3,4,2], x[2,3,4,3], x[2,3,4,4], x[2,3,4,5]}}})[j,1,k];
 y[2,2] = ({{{x[2,1,2,1], x[2,1,2,2], x[2,1,2,3], x[2,1,2,4], x[2,1,2,5]}, {x[2,1,3,1], x[2,1,3,2], x[2,1,3,3], x[2,1,3,4], x[2,1,3,5]}, {x[2,1,4,1], x[2,1,4,2], x[2,1,4,3], x[2,1,4,4], x[2,1,4,5]}}, {{x[2,2,2,1], x[2,2,2,2], x[2,2,2,3], x[2,2,2,4], x[2,2,2,5]}, {x[2,2,3,1], x[2,2,3,2], x[2,2,3,3], x[2,2,3,4], x[2,2,3,5]}, {x[2,2,4,1], x[2,2,4,2], x[2,2,4,3], x[2,2,4,4], x[2,2,4,5]}}, {{x[2,3,2,1], x[2,3,2,2], x[2,3,2,3], x[2,3,2,4], x[2,3,2,5]}, {x[2,3,3,1], x[2,3,3,2], x[2,3,3,3], x[2,3,3,4], x[2,3,3,5]}, {x[2,3,4,1], x[2,3,4,2], x[2,3,4,3], x[2,3,4,4], x[2,3,4,5]}}})[j,2,k];
 y[2,3] = ({{{x[2,1,2,1], x[2,1,2,2], x[2,1,2,3], x[2,1,2,4], x[2,1,2,5]}, {x[2,1,3,1], x[2,1,3,2], x[2,1,3,3], x[2,1,3,4], x[2,1,3,5]}, {x[2,1,4,1], x[2,1,4,2], x[2,1,4,3], x[2,1,4,4], x[2,1,4,5]}}, {{x[2,2,2,1], x[2,2,2,2], x[2,2,2,3], x[2,2,2,4], x[2,2,2,5]}, {x[2,2,3,1], x[2,2,3,2], x[2,2,3,3], x[2,2,3,4], x[2,2,3,5]}, {x[2,2,4,1], x[2,2,4,2], x[2,2,4,3], x[2,2,4,4], x[2,2,4,5]}}, {{x[2,3,2,1], x[2,3,2,2], x[2,3,2,3], x[2,3,2,4], x[2,3,2,5]}, {x[2,3,3,1], x[2,3,3,2], x[2,3,3,3], x[2,3,3,4], x[2,3,3,5]}, {x[2,3,4,1], x[2,3,4,2], x[2,3,4,3], x[2,3,4,4], x[2,3,4,5]}}})[j,3,k];
end ArrayTests.VariableIndex.ExpEquationCombination;
")})));
end ExpEquationCombination;

model Slice1
    record R
        Real p;
    end R;
    
    Real y;
    R[2] x = { R(time), R(2 * time) };
    input Integer i;
equation
    y = if i == 0 then 1 else x[i].p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Slice1",
            description="Using variable index in slice",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.Slice1
 Real y;
 Real x[1].p;
 Real x[2].p;
 discrete input Integer i;
equation
 y = if i == 0 then 1 else ({x[1].p, x[2].p})[i];
 x[1].p = time;
 x[2].p = 2 * time;
end ArrayTests.VariableIndex.Slice1;
")})));
end Slice1;


model Slice2
    Real x[2, 2, 2] = { { {1, 2}, {3, 4} }, { {5, 6}, {7, 8} } } * time;
    Real y[2, 3] = x[i, {2, 1}, {1, 2, 2}];
    input Integer i;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Slice2",
            description="Using variable index in slice with matrix result",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.Slice2
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,2,1];
 Real x[2,2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
 discrete input Integer i;
equation
 x[1,1,1] = time;
 x[1,1,2] = 2 * time;
 x[1,2,1] = 3 * time;
 x[1,2,2] = 4 * time;
 x[2,1,1] = 5 * time;
 x[2,1,2] = 6 * time;
 x[2,2,1] = 7 * time;
 x[2,2,2] = 8 * time;
 y[1,1] = ({{{x[1,2,1], x[1,2,2], x[1,2,2]}, {x[1,1,1], x[1,1,2], x[1,1,2]}}, {{x[2,2,1], x[2,2,2], x[2,2,2]}, {x[2,1,1], x[2,1,2], x[2,1,2]}}})[i,1,1];
 y[1,2] = ({{{x[1,2,1], x[1,2,2], x[1,2,2]}, {x[1,1,1], x[1,1,2], x[1,1,2]}}, {{x[2,2,1], x[2,2,2], x[2,2,2]}, {x[2,1,1], x[2,1,2], x[2,1,2]}}})[i,1,2];
 y[1,3] = ({{{x[1,2,1], x[1,2,2], x[1,2,2]}, {x[1,1,1], x[1,1,2], x[1,1,2]}}, {{x[2,2,1], x[2,2,2], x[2,2,2]}, {x[2,1,1], x[2,1,2], x[2,1,2]}}})[i,1,3];
 y[2,1] = ({{{x[1,2,1], x[1,2,2], x[1,2,2]}, {x[1,1,1], x[1,1,2], x[1,1,2]}}, {{x[2,2,1], x[2,2,2], x[2,2,2]}, {x[2,1,1], x[2,1,2], x[2,1,2]}}})[i,2,1];
 y[2,2] = ({{{x[1,2,1], x[1,2,2], x[1,2,2]}, {x[1,1,1], x[1,1,2], x[1,1,2]}}, {{x[2,2,1], x[2,2,2], x[2,2,2]}, {x[2,1,1], x[2,1,2], x[2,1,2]}}})[i,2,2];
 y[2,3] = ({{{x[1,2,1], x[1,2,2], x[1,2,2]}, {x[1,1,1], x[1,1,2], x[1,1,2]}}, {{x[2,2,1], x[2,2,2], x[2,2,2]}, {x[2,1,1], x[2,1,2], x[2,1,2]}}})[i,2,3];
end ArrayTests.VariableIndex.Slice2;
")})));
end Slice2;


model Slice3
    record R
        Real x[2];
    end R;
    
    R r[2] =  {R({1, 2} * time), R({3, 4} * time)};
    Real x[2] = r.x[i];
    input Integer i;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Slice3",
            description="Using variable index in slice with no index on record",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.Slice3
 Real r[1].x[1];
 Real r[1].x[2];
 Real r[2].x[1];
 Real r[2].x[2];
 Real x[1];
 Real x[2];
 discrete input Integer i;
equation
 r[1].x[1] = time;
 r[1].x[2] = 2 * time;
 r[2].x[1] = 3 * time;
 r[2].x[2] = 4 * time;
 x[1] = ({{r[1].x[1], r[1].x[2]}, {r[2].x[1], r[2].x[2]}})[1,i];
 x[2] = ({{r[1].x[1], r[1].x[2]}, {r[2].x[1], r[2].x[2]}})[2,i];
end ArrayTests.VariableIndex.Slice3;
")})));
end Slice3;


model Slice4
    model A
        Real z;
    end A;

    Real y;
    A[2] x(z = {1, 2} * time);
    input Integer i;
equation
    y = x[i].z;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Slice4",
            description="Using variable index in slice over models",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.Slice4
 Real y;
 Real x[1].z;
 Real x[2].z;
 discrete input Integer i;
equation
 y = ({x[1].z, x[2].z})[i];
 x[1].z = time;
 x[2].z = 2 * time;
end ArrayTests.VariableIndex.Slice4;
")})));
end Slice4;


model Slice5
    model A
        Real z;
    end A;

    model B
        A a[2,2];
    end B;

    Real y[2];
    B b[2,2](a(z = fill(time, 2, 2, 2, 2)));
    input Integer i;
    input Integer j;
equation
    y = b[:, i].a[j, 1].z;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Slice5",
            description="Using variable index in slice over models, complex example",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayTests.VariableIndex.Slice5
 Real y[1];
 Real y[2];
 Real b[1,1].a[1,1].z;
 Real b[1,1].a[1,2].z;
 Real b[1,1].a[2,1].z;
 Real b[1,1].a[2,2].z;
 Real b[1,2].a[1,1].z;
 Real b[1,2].a[1,2].z;
 Real b[1,2].a[2,1].z;
 Real b[1,2].a[2,2].z;
 Real b[2,1].a[1,1].z;
 Real b[2,1].a[1,2].z;
 Real b[2,1].a[2,1].z;
 Real b[2,1].a[2,2].z;
 Real b[2,2].a[1,1].z;
 Real b[2,2].a[1,2].z;
 Real b[2,2].a[2,1].z;
 Real b[2,2].a[2,2].z;
 discrete input Integer i;
 discrete input Integer j;
equation
 y[1] = ({{b[1,1].a[1,1].z, b[1,1].a[2,1].z}, {b[1,2].a[1,1].z, b[1,2].a[2,1].z}})[i,j];
 y[2] = ({{b[2,1].a[1,1].z, b[2,1].a[2,1].z}, {b[2,2].a[1,1].z, b[2,2].a[2,1].z}})[i,j];
 b[1,1].a[1,1].z = time;
 b[1,1].a[1,2].z = time;
 b[1,1].a[2,1].z = time;
 b[1,1].a[2,2].z = time;
 b[1,2].a[1,1].z = time;
 b[1,2].a[1,2].z = time;
 b[1,2].a[2,1].z = time;
 b[1,2].a[2,2].z = time;
 b[2,1].a[1,1].z = time;
 b[2,1].a[1,2].z = time;
 b[2,1].a[2,1].z = time;
 b[2,1].a[2,2].z = time;
 b[2,2].a[1,1].z = time;
 b[2,2].a[1,2].z = time;
 b[2,2].a[2,1].z = time;
 b[2,2].a[2,2].z = time;
end ArrayTests.VariableIndex.Slice5;
")})));
end Slice5;

model Slice6
    function F
        input Real x;
        output Real[2] y;
    algorithm
        y := {x,x};
        annotation(Inline=false);
    end F;
    Real a[3];
    Integer b[:] = {1,3};
equation
    a[b] = F(time);
    a[2] = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Slice6",
            description="Using variable index in slice over models, complex example",
            variability_propagation=false,
            flatModel="
fclass ArrayTests.VariableIndex.Slice6
 Real a[1];
 Real a[2];
 Real a[3];
 discrete Integer b[1];
 discrete Integer b[2];
 Real temp_1[1];
 Real temp_1[2];
initial equation 
 pre(b[1]) = 0;
 pre(b[2]) = 0;
equation
 ({temp_1[1], temp_1[2]}) = ArrayTests.VariableIndex.Slice6.F(time);
 ({a[1], a[2], a[3]})[b[1]] = temp_1[1];
 ({a[1], a[2], a[3]})[b[2]] = temp_1[2];
 a[2] = time;
 b[1] = 1;
 b[2] = 3;

public
 function ArrayTests.VariableIndex.Slice6.F
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := x;
  temp_1[2] := x;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 annotation(Inline = false);
 end ArrayTests.VariableIndex.Slice6.F;

end ArrayTests.VariableIndex.Slice6;
")})));
end Slice6;

model Slice7
    model M
        Real[:] x = 1:2;
    end M;
    
    record R
        Real[1] x;
    end R;
    
    model A
        R r;
    end A;
    
    A[2] a(r(x=transpose(m.x)));
    M[1] m;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VariableIndex_Slice7",
            description="Using variable index in slice over models, complex example",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.VariableIndex.Slice7
 Real a[1].r.x[1];
 Real a[2].r.x[1];
 Real m[1].x[1];
 Real m[1].x[2];
equation
 a[1].r.x[1] = m[1].x[1];
 a[2].r.x[1] = m[1].x[2];
 m[1].x[1] = 1;
 m[1].x[2] = 2;
end ArrayTests.VariableIndex.Slice7;
")})));
end Slice7;

model Slice8
    Integer i = integer(time);
    Integer[2] x = {1,2};
    Integer y = pre(x[i]);
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="VariableIndex_Slice8",
            description="Variable index in pre",
            flatModel="
fclass ArrayTests.VariableIndex.Slice8
 discrete Integer i = integer(time);
 discrete Integer x[2] = {1, 2};
 discrete Integer y = (pre(x[1:2]))[i];
end ArrayTests.VariableIndex.Slice8;
")})));
end Slice8;

model Slice9
    constant Integer[:] c = 1:2;
    Integer i = integer(time);
    Integer[2] x = {1,2};
    Integer y = pre(x[c[i]]);
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="VariableIndex_Slice9",
            description="Variable index in pre",
            flatModel="
fclass ArrayTests.VariableIndex.Slice9
 constant Integer c[2] = {1, 2};
 discrete Integer i = integer(time);
 discrete Integer x[2] = {1, 2};
 discrete Integer y = (pre(x[1:2]))[({1, 2})[i]];
end ArrayTests.VariableIndex.Slice9;
")})));
end Slice9;

model Slice10
    constant Integer[:] c = 1:2;
    Integer i = integer(time);
    Integer[2] x = {1,2};
    Integer y = pre(c[x[i]]);
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="VariableIndex_Slice10",
            description="Variable index in pre",
            flatModel="
fclass ArrayTests.VariableIndex.Slice10
 constant Integer c[2] = {1, 2};
 discrete Integer i = integer(time);
 discrete Integer x[2] = {1, 2};
 discrete Integer y = ({1, 2})[(x[1:2])[i]];
end ArrayTests.VariableIndex.Slice10;
")})));
end Slice10;

end VariableIndex;


package Other
	
model CircularFunctionArg1
	function f 
		input Real[:] a;
		output Real[:] b = a;
	algorithm
	end f;
	
	Real[:] c = f(d);
	Real[:] d = f(c);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Other_CircularFunctionArg1",
            description="Circular dependency when calculating size of function output",
            errorMessage="
4 errors found:

Error at line 8, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE:
  Can not infer array size of the variable c

Error at line 8, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_OUTPUT:
  Could not evaluate array size of output b

Error at line 9, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE:
  Can not infer array size of the variable d

Error at line 9, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_OUTPUT:
  Could not evaluate array size of output b
")})));
end CircularFunctionArg1;



constant Real testConst[2] = { 1, 2 };


model ArrayConst1
	Real x[2] = { 1.0 / testConst[i] for i in 1:2 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Other_ArrayConst1",
			description="Array constants used with parameter index",
			flatModel="
fclass ArrayTests.Other.ArrayConst1
 constant Real x[1] = 1.0;
 constant Real x[2] = 0.5;
end ArrayTests.Other.ArrayConst1;
")})));
end ArrayConst1;


model ArrayConst2
	Real x[2];
equation
	for i in 1:2 loop
		x[i] = testConst[i];
	end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Other_ArrayConst2",
			description="Array constants used with parameter index",
			flatModel="
fclass ArrayTests.Other.ArrayConst2
 constant Real x[1] = 1.0;
 constant Real x[2] = 2.0;
end ArrayTests.Other.ArrayConst2;
")})));
end ArrayConst2;


model ArrayConst3

    constant Real[:] c = {2,3};

    function f
        input Real i;
        output Real o;
    algorithm
        o := c[integer(i)];
        annotation(Inline=false);
    end f;

    Real x = f(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Other_ArrayConst3",
            description="Array constants used with index of discrete variability",
            variability_propagation=false,
            flatModel="
fclass ArrayTests.Other.ArrayConst3
 constant Real c[1] = 2;
 constant Real c[2] = 3;
 Real x;
global variables
 constant Real ArrayTests.Other.ArrayConst3.c[2] = {2, 3};
equation
 x = ArrayTests.Other.ArrayConst3.f(1);

public
 function ArrayTests.Other.ArrayConst3.f
  input Real i;
  output Real o;
 algorithm
  o := global(ArrayTests.Other.ArrayConst3.c[integer(i)]);
  return;
 annotation(Inline = false);
 end ArrayTests.Other.ArrayConst3.f;

end ArrayTests.Other.ArrayConst3;
")})));
end ArrayConst3;


model ArrayConst4
	parameter Integer i = 1;
	Real x = testConst[i];

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Other_ArrayConst4",
			description="Array constants used with parameter index",
			flatModel="
fclass ArrayTests.Other.ArrayConst4
 parameter Integer i = 1 /* 1 */;
 parameter Real x;
parameter equation
 x = ({1.0, 2.0})[i];
end ArrayTests.Other.ArrayConst4;
")})));
end ArrayConst4;


model ArraySize2
	parameter Real x[:, size(x,1)];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Other_ArraySize2",
            description="Size of variable: one dimension refering to another",
            errorMessage="
2 errors found:

Error at line 2, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', CANNOT_INFER_ARRAY_SIZE_OF_VARIABLE:
  Can not infer array size of the variable x

Error at line 2, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Could not evaluate array size expression: size(x, 1)
")})));
end ArraySize2;


model ArraySize3
	model A
		Real x[2] = {1,2};
	end A;
	
	parameter Integer n = 2;
	A[n] b;
	Real[n] c;
equation
	for i in 1:n loop
		c[i] = b[i].x[1] + b[i].x[end];
	end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Other_ArraySize3",
			description="Handle end in for loop",
            eliminate_alias_variables=false,
			flatModel="
fclass ArrayTests.Other.ArraySize3
 structural parameter Integer n = 2 /* 2 */;
 constant Real b[1].x[1] = 1;
 constant Real b[1].x[2] = 2;
 constant Real b[2].x[1] = 1;
 constant Real b[2].x[2] = 2;
 constant Real c[1] = 3.0;
 constant Real c[2] = 3.0;
end ArrayTests.Other.ArraySize3;
")})));
end ArraySize3;


model ArraySize4
    function f
        input Real[:] x1;
        input Real[:] x2;
        output Boolean[size(x1,1)-1, size(x2,1)-1] y;
    protected
        final parameter Integer n1 = size(x1,1)-1;
        parameter Integer n2 = size(x1,1)-1;
    algorithm
        for i in 1:n1 loop
        end for;
    end f;
    
    Boolean[3,3] y = f({1,2,3,4},{1,2,3,4});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Other_ArraySize4",
            description="",
            flatModel="
fclass ArrayTests.Other.ArraySize4
 constant Boolean y[1,1] = false;
end ArrayTests.Other.ArraySize4;
")})));
end ArraySize4;

model ArraySize5
    function f
      input Integer n;
      input Real x[:];
      input Real y[:] = x[1:n];
      output Real z[:] = y;
    algorithm
    end f;
    Real[:] y = f(2,1:3);
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Other_ArraySize5",
            description="",
            flatModel="
fclass ArrayTests.Other.ArraySize5
 Real y[2] = ArrayTests.Other.ArraySize5.f(2, 1:3, (1:3)[1:2]);

public
 function ArrayTests.Other.ArraySize5.f
  input Integer n;
  input Real[:] x;
  input Real[:] y;
  output Real[:] z;
 algorithm
  init z as Real[size(y, 1)];
  z := y[:];
  return;
 end ArrayTests.Other.ArraySize5.f;

end ArrayTests.Other.ArraySize5;
")})));
end ArraySize5;

model ArraySizeInIf1
    function f1
        input Integer g;
        output Real[g] h;
    algorithm
        h := 1:g;
    end f1;
    
    function f2
        input Integer i;
        output Real[div(i, 2)] j;
        output Real[mod(i, 2)] k;
    algorithm
        j := 1:div(i, 2);
        k := 1:mod(i, 2);
    end f2;
    
    parameter Boolean a = false;
    parameter Integer b = 5;
    parameter Integer c = if a then b else div(b, 2);
    parameter Integer d = if a then 0 else mod(b, 2);
    Real e[c];
    Real f[d];
equation
    if a then
        e = f1(b);
    else
        (e, f) = f2(b);
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Other_ArraySizeInIf1",
			description="Test that array size errors lock if branches if possible",
            eliminate_alias_variables=false,
			flatModel="
fclass ArrayTests.Other.ArraySizeInIf1
 structural parameter Boolean a = false /* false */;
 structural parameter Integer b = 5 /* 5 */;
 structural parameter Integer c = 2 /* 2 */;
 structural parameter Integer d = 1 /* 1 */;
 constant Real e[1] = 1;
 constant Real e[2] = 2;
 constant Real f[1] = 1;
end ArrayTests.Other.ArraySizeInIf1;
")})));
end ArraySizeInIf1;


model ArraySizeInIf2
    function f1
        input Integer g;
        output Real[g] h;
    algorithm
        h := 1:g;
    end f1;
    
    function f2
        input Integer i;
        output Real[div(i, 2)] j;
        output Real[mod(i, 2)] k;
    algorithm
        j := 1:div(i, 2);
        k := 1:mod(i, 2);
    end f2;
    
    parameter Boolean a = false;
    parameter Integer b = 5;
    parameter Integer c = if a then b else div(b, 2);
    parameter Integer d = if a then 0 else mod(b, 2);
    Real e[c];
    Real f[d];
equation
    if time > 2 then
        e = f1(b);
    else
        (e, f) = f2(b);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Other_ArraySizeInIf2",
            description="Test that array size errors don't lock if branches if not possible",
            errorMessage="
2 errors found:

Error at line 25, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  All branches in if equation with non-parameter tests must have the same number of equations

Error at line 26, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo', ARRAY_SIZE_MISMATCH_IN_EQUATION:
  The array sizes of right and left hand side of equation are not compatible, size of left-hand side is [2], and size of right-hand side is [5]
")})));
end ArraySizeInIf2;


model ArraySizeInIf3
    function f1
        input Integer g;
        output Real[g] h;
    algorithm
        h := 1:g;
    end f1;
    
    function f2
        input Integer i;
        output Real[div(i, 2)] j;
        output Real[mod(i, 2)] k;
    algorithm
        j := 1:div(i, 2);
        k := 1:mod(i, 2);
    end f2;
    
    parameter Boolean a = true;
    parameter Integer b = 5;
    parameter Integer c = if a then b else div(b, 2);
    parameter Integer d = if a then 0 else mod(b, 2);
    Real e[c];
    Real f[d];
equation
    if a then
        e = f1(b);
    else
        (e, f) = f2(b);
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Other_ArraySizeInIf3",
			description="Test that array size errors lock if branches if possible",
            eliminate_alias_variables=false,
			flatModel="
fclass ArrayTests.Other.ArraySizeInIf3
 structural parameter Boolean a = true /* true */;
 structural parameter Integer b = 5 /* 5 */;
 structural parameter Integer c = 5 /* 5 */;
 structural parameter Integer d = 0 /* 0 */;
 constant Real e[1] = 1;
 constant Real e[2] = 2;
 constant Real e[3] = 3;
 constant Real e[4] = 4;
 constant Real e[5] = 5;
end ArrayTests.Other.ArraySizeInIf3;
")})));
end ArraySizeInIf3;

model ArraySizeInIf4
    Real[0] x = 1:0;
    Real y;
algorithm
    if size(x,1) > 0 then
        y := x[1];
    else
        y := x[1];
    end if;
            
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Other_ArraySizeInIf4",
            description="Test that array size errors lock if branches if possible",
            errorMessage="
1 errors found:

Error at line 8, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 1, index expression: 1
")})));
end ArraySizeInIf4;

model ArraySizeInIf5
    Real[0] x = 1:0;
    Real y;
algorithm
    if size(x,1) < 0 then
        y := x[1];
    elseif size(x,1) > 0 then
        y := x[1];
    elseif size(x,1) > 0 then
        y := x[1];
    else
        y := x[1];
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Other_ArraySizeInIf5",
            description="Test that array size errors lock if branches if possible",
            errorMessage="
1 errors found:

Error at line 12, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 1, index expression: 1
")})));
end ArraySizeInIf5;

model ArraySizeInIf6
    Real[0] x = 1:0;
    Real y;
algorithm
    if sum(x) > 0 then
        y := x[1];
    elseif size(x,1) < 0 then
        y := x[1];
    else
        y := x[1];
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Other_ArraySizeInIf6",
            description="Test that array size errors lock if branches if possible",
            errorMessage="
2 errors found:

Error at line 6, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 1, index expression: 1

Error at line 10, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayTests.mo':
  Array index out of bounds: 1, index expression: 1
")})));
end ArraySizeInIf6;

model ArraySizeInComp1
    record R
        Real[:] x = 1:n;
        parameter Integer n;
    end R;
    
    function f
        input R r;
        output Real[r.n] x = r.x;
        algorithm
    end f;
    
    R r1(n=2);
    Real[:] x = f(r1);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Other_ArraySizeInComp1",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Other.ArraySizeInComp1
 constant Real r1.x[1] = 1;
 constant Real r1.x[2] = 2;
 structural parameter Integer r1.n = 2 /* 2 */;
 constant Real x[1] = 1.0;
 constant Real x[2] = 2.0;
end ArrayTests.Other.ArraySizeInComp1;
")})));
end ArraySizeInComp1;

model ArraySizeInComp2
    record R
        Real[:] x = 1:n;
        parameter Integer n;
    end R;
    
    function f
        input R[:] r;
        output Real[r[2].n] x = r[2].x;
        algorithm
    end f;
    
    R r1(n=2);
    R r2(n=3);
    Real[:] x = f({r1,r2});
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Other_ArraySizeInComp2",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayTests.Other.ArraySizeInComp2
 constant Real r1.x[1] = 1;
 constant Real r1.x[2] = 2;
 structural parameter Integer r1.n = 2 /* 2 */;
 constant Real r2.x[1] = 1;
 constant Real r2.x[2] = 2;
 constant Real r2.x[3] = 3;
 structural parameter Integer r2.n = 3 /* 3 */;
 constant Real x[1] = 1.0;
 constant Real x[2] = 2.0;
 constant Real x[3] = 3.0;
end ArrayTests.Other.ArraySizeInComp2;
")})));
end ArraySizeInComp2;

model ArraySimplify1
    Real x[2], y[2], z[2];
equation
    der(x) = {1, 2} * time;
    y = 0 * x;
    z = x * 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Other_ArraySimplify1",
			description="Correct simplification of array expressions",
            eliminate_alias_variables=false,
			flatModel="
fclass ArrayTests.Other.ArraySimplify1
 Real x[1];
 Real x[2];
 constant Real y[1] = 0;
 constant Real y[2] = 0;
 constant Real z[1] = 0;
 constant Real z[2] = 0;
initial equation 
 x[1] = 0.0;
 x[2] = 0.0;
equation
 der(x[1]) = time;
 der(x[2]) = 2 * time;
end ArrayTests.Other.ArraySimplify1;
")})));
end ArraySimplify1;

package P
    function f
        input Real[:,:] x;
        output Real[size(x,1), size(x,2)] y;
      algorithm
        y := x;
    end f;
    constant Real[1,1] x = {{2}} * f({{3}});
end P;
model FuncCallInPackConstEval
    constant Real y[1,1] = P.x;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Other_FuncCallInPackConstEval",
            description="Test getArray for function call in package constant",
            flatModel="
fclass ArrayTests.Other.FuncCallInPackConstEval
 constant Real y[1,1] = 6;
end ArrayTests.Other.FuncCallInPackConstEval;
")})));
end FuncCallInPackConstEval;

model ScalarizingPre
    Integer[2] i(start={0,0});
  algorithm
    i := pre(i);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Other_ScalarizingPre",
            description="Test scalarizing of pre array",
            flatModel="
fclass ArrayTests.Other.ScalarizingPre
 discrete Integer i[1](start = 0);
 discrete Integer i[2](start = 0);
initial equation 
 pre(i[1]) = 0;
 pre(i[2]) = 0;
algorithm
 i[1] := pre(i[1]);
 i[2] := pre(i[2]);
end ArrayTests.Other.ScalarizingPre;
")})));
end ScalarizingPre;


end Other;


model IfExprTemp1
    function f
        input Real x;
        output Real[:] y = {x,x+1};
    algorithm
    end f;
    
    Real y = if sum(f(time))>0 then sum(f(time)) else sum(f(time+1));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfExprTemp1",
            description="",
            inline_functions="none",
            flatModel="
fclass ArrayTests.IfExprTemp1
 Real y;
 Real temp_1[1];
 Real temp_1[2];
 Real temp_2[1];
 Real temp_2[2];
 Real temp_3[1];
 Real temp_3[2];
equation
 ({temp_1[1], temp_1[2]}) = ArrayTests.IfExprTemp1.f(time);
 if temp_1[1] + temp_1[2] > 0 then
  ({temp_2[1], temp_2[2]}) = ArrayTests.IfExprTemp1.f(time);
 else
  temp_2[1] = 0.0;
  temp_2[2] = 0.0;
 end if;
 if not temp_1[1] + temp_1[2] > 0 then
  ({temp_3[1], temp_3[2]}) = ArrayTests.IfExprTemp1.f(time + 1);
 else
  temp_3[1] = 0.0;
  temp_3[2] = 0.0;
 end if;
 y = if temp_1[1] + temp_1[2] > 0 then temp_2[1] + temp_2[2] else temp_3[1] + temp_3[2];

public
 function ArrayTests.IfExprTemp1.f
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := x;
  temp_1[2] := x + 1;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end ArrayTests.IfExprTemp1.f;

end ArrayTests.IfExprTemp1;
")})));
end IfExprTemp1;

model IfExprTemp2
    function f
        input Real x;
        output Real[:] y = {x, x+1};
    algorithm
    end f;

    Real y;
algorithm
    y := if sum(f(time)) > 0 then sum(f(time)) else sum(f(time + 1));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfExprTemp2",
            description="",
            inline_functions="none",
            flatModel="
fclass ArrayTests.IfExprTemp2
 Real y;
 Real _eventIndicator_1;
 Real _eventIndicator_2;
 Real temp_1[1];
 Real temp_1[2];
 Real temp_2[1];
 Real temp_2[2];
 Real temp_3[1];
 Real temp_3[2];
algorithm
 ({temp_1[1], temp_1[2]}) := ArrayTests.IfExprTemp2.f(time);
 _eventIndicator_1 := temp_1[1] + temp_1[2];
 if temp_1[1] + temp_1[2] > 0 then
  ({temp_2[1], temp_2[2]}) := ArrayTests.IfExprTemp2.f(time);
 else
  ({temp_3[1], temp_3[2]}) := ArrayTests.IfExprTemp2.f(time + 1);
 end if;
 _eventIndicator_2 := temp_1[1] + temp_1[2];
 y := if temp_1[1] + temp_1[2] > 0 then temp_2[1] + temp_2[2] else temp_3[1] + temp_3[2];

public
 function ArrayTests.IfExprTemp2.f
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := x;
  temp_1[2] := x + 1;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end ArrayTests.IfExprTemp2.f;

end ArrayTests.IfExprTemp2;
")})));
end IfExprTemp2;

model IfExprTemp3
      function f
        input Real x;
        output Real[2] y = {x,x+1};
        algorithm
      end f;
      
      Real x;
      Real y;
  equation
      der(x) = time;
      y = if der(x) > x then 1 else if der(x) > x then 1 else sum(f(x));
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfExprTemp3",
            description="",
            inline_functions="none",
            flatModel="
fclass ArrayTests.IfExprTemp3
 Real x;
 Real y;
 Real temp_1[1];
 Real temp_1[2];
initial equation 
 x = 0.0;
equation
 der(x) = time;
 if not der(x) > x and not der(x) > x then
  ({temp_1[1], temp_1[2]}) = ArrayTests.IfExprTemp3.f(x);
 else
  temp_1[1] = 0.0;
  temp_1[2] = 0.0;
 end if;
 y = if der(x) > x then 1 elseif der(x) > x then 1 else temp_1[1] + temp_1[2];

public
 function ArrayTests.IfExprTemp3.f
  input Real x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  temp_1[1] := x;
  temp_1[2] := x + 1;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end ArrayTests.IfExprTemp3.f;

end ArrayTests.IfExprTemp3;
")})));
end IfExprTemp3;

model BindingExpressionBadDimension1
    record R
        Real x;
    end R;

    R[2] r(x={time});
    constant Real x = r[2].x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BindingExpressionBadDimension1",
            description="Check for NullPointerException with bad binding expression array length, #5632",
            errorMessage="
Error at line 6, column 14, in file '...', ARRAY_SIZE_MISMATCH_IN_MODIFICATION:
  Array size mismatch in modification of x, expected size is [2] and size of binding expression is [1]

Error at line 7, column 23, in file '...':
  Could not evaluate binding expression for constant 'x': 'r[2].x'

")})));
end BindingExpressionBadDimension1;

end ArrayTests;
