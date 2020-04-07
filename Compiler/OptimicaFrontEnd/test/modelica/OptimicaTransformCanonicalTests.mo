/*
    Copyright (C) 2015 Modelon AB

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
package OptimicaTransformCanonicalTests

  optimization LinearityTest1 (objective = cost(finalTime)^2, startTime=0, finalTime=1)

    Real cost;

    Real x1;
    Real x2;
    Real x3;
    Real x4;
    Real x5;
    Real x6;
    Real x7;
    Real x8;

    parameter Real p1 = 1;
    parameter Real p2(free=true,initialGuess=3);

  equation
    der(cost) = 1;
    x1 = x1 * p1 + x2;
    x2 = x3 ^ 2;
    x3 = x4 / p1;
    x4 = p1 / x5;
    x5 = x6 - x6;
    x6 = sin(x7);
    x7 = x8 * p2;
    x1 = 1;

  annotation(__JModelica(UnitTesting(tests={
    FClassMethodTestCase(
      name="LinearityTest1",
      methodName="variableDiagnostics",
      description="Test linearity of variables.",
      methodResult="  
Independent constants: 
 x1: number of uses: 0, isLinear: true

Dependent constants: 

Independent parameters: 
 p1: number of uses: 3, isLinear: true, evaluated binding exp: 1
 startTime: number of uses: 0, isLinear: true, evaluated binding exp: 0
 finalTime: number of uses: 1, isLinear: true, evaluated binding exp: 1
 p2: number of uses: 1, isLinear: false

Dependent parameters: 
 x2: number of uses: 2, isLinear: true

Differentiated variables: 
 cost: number of uses: 0, isLinear: true

Derivative variables: 
 der(cost): number of uses: 1, isLinear: true

Discrete variables: 

Algebraic real variables:
 x3: number of uses: 2, isLinear: false, alias: no
 x4: number of uses: 2, isLinear: true, alias: no
 x5: number of uses: 2, isLinear: false, alias: no
 x6: number of uses: 1, isLinear: true, alias: no
 x7: number of uses: 2, isLinear: false, alias: no
 x8: number of uses: 1, isLinear: false, alias: no

Input variables: 
")})));
  end LinearityTest1;


  optimization LinearityTest2 (objective = x(finalTime)^2, startTime=0, finalTime=5)
	parameter Real t0 = 0;
	parameter Real t1 = 1;
	parameter Real t2 = 2;
	parameter Real t3 = 3;
	parameter Real t4 = 4;
	parameter Real t5 = 5;
	
	Real x;
        Real y;

     constraint
        x = y(t0)+y(t1)^2 + sin(y(t2));
        x = 3;
        x(t3) >= 1;
        x(t4)*x(t4) <= 1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="LinearityTest2",
			methodName="timedVariablesLinearityDiagnostics",
			description="Test linearity of variables.",
			methodResult="  
Linearity of time points:
t0:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t1:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t2:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t3:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t4:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t5:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
x:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: false
  5.0, isLinear: false
y:
  0.0, isLinear: true
  1.0, isLinear: false
  2.0, isLinear: false
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
startTime:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
finalTime:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
")})));
  end LinearityTest2;	

  optimization ArrayTest1 (objective=cost(finalTime),startTime=0,finalTime=2)
    Real cost(start=0,fixed=true);
    Real x[2](start={1,1},each fixed=true);
    Real y;
    input Real u;
    parameter Real A[2,2] = {{-1,0},{1,-1}};
    parameter Real B[2] = {1,2};
    parameter Real C[2] = {1,1};
  equation 
    der(x) = A*x+B*u;
    y = C*x;
    der(cost) = y^2 + u^2;
  constraint
    u >= -1;
    u <= 1;
    x(finalTime) = {0,0};
    x <= {1,1}; // This constraint has no effect but is added for testing
    x >= {-1,-1}; // This constraint has no effect but is added for testing

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest1",
			description="Test arrays in Optimica",
			flatModel="
optimization OptimicaTransformCanonicalTests.ArrayTest1(objective = cost(finalTime),startTime = 0,finalTime = 2)
 Real cost(start = 0,fixed = true);
 Real x[1](start = 1,fixed = true);
 Real x[2](start = 1,fixed = true);
 Real y;
 input Real u;
 parameter Real A[1,1] = -1 /* -1 */;
 parameter Real A[1,2] = 0 /* 0 */;
 parameter Real A[2,1] = 1 /* 1 */;
 parameter Real A[2,2] = -1 /* -1 */;
 parameter Real B[1] = 1 /* 1 */;
 parameter Real B[2] = 2 /* 2 */;
 parameter Real C[1] = 1 /* 1 */;
 parameter Real C[2] = 1 /* 1 */;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
 Real der(x[1]);
 Real der(x[2]);
 Real der(cost);
initial equation 
 cost = 0;
 x[1] = 1;
 x[2] = 1;
equation
 der(x[1]) = A[1,1] * x[1] + A[1,2] * x[2] + B[1] * u;
 der(x[2]) = A[2,1] * x[1] + A[2,2] * x[2] + B[2] * u;
 y = C[1] * x[1] + C[2] * x[2];
 der(cost) = y ^ 2 + u ^ 2;
constraint 
 u >= - 1;
 u <= 1;
 x[1](finalTime) = 0;
 x[2](finalTime) = 0;
 x[1] <= 1;
 x[2] <= 1;
 x[1] >= - 1;
 x[2] >= - 1;
end OptimicaTransformCanonicalTests.ArrayTest1;
")})));
  end ArrayTest1;

  optimization ArrayTest2 (objective=cost(finalTime)+x[1](finalTime)^2 + x[2](finalTime)^2,startTime=0,finalTime=2)

    Real cost(start=0,fixed=true);
    Real x[2](start={1,1},each fixed=true);
    Real y;
    input Real u;
    parameter Real A[2,2] = {{-1,0},{1,-1}};
    parameter Real B[2] = {1,2};
    parameter Real C[2] = {1,1};
  equation 
    der(x) = A*x+B*u;
    y = C*x;
    der(cost) = y^2 + u^2;
  constraint
    u >= -1;
    u <= 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTest2",
			description="Test arrays in Optimica",
			flatModel="
optimization OptimicaTransformCanonicalTests.ArrayTest2(objective = cost(finalTime) + x[1](finalTime) ^ 2 + x[2](finalTime) ^ 2,startTime = 0,finalTime = 2)
 Real cost(start = 0,fixed = true);
 Real x[1](start = 1,fixed = true);
 Real x[2](start = 1,fixed = true);
 Real y;
 input Real u;
 parameter Real A[1,1] = -1 /* -1 */;
 parameter Real A[1,2] = 0 /* 0 */;
 parameter Real A[2,1] = 1 /* 1 */;
 parameter Real A[2,2] = -1 /* -1 */;
 parameter Real B[1] = 1 /* 1 */;
 parameter Real B[2] = 2 /* 2 */;
 parameter Real C[1] = 1 /* 1 */;
 parameter Real C[2] = 1 /* 1 */;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
 Real der(x[1]);
 Real der(x[2]);
 Real der(cost);
initial equation 
 cost = 0;
 x[1] = 1;
 x[2] = 1;
equation
 der(x[1]) = A[1,1] * x[1] + A[1,2] * x[2] + B[1] * u;
 der(x[2]) = A[2,1] * x[1] + A[2,2] * x[2] + B[2] * u;
 y = C[1] * x[1] + C[2] * x[2];
 der(cost) = y ^ 2 + u ^ 2;
constraint 
 u >= - 1;
 u <= 1;
end OptimicaTransformCanonicalTests.ArrayTest2;
")})));
  end ArrayTest2;

  optimization ArrayTest3_Err (objective=x(finalTime),startTime=0,startTime=3)

    Real x[2](each start=1,each fixed=true);
  equation
    der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ArrayTest3_Err",
            description="Test type checking of class attributes in Optimica.",
            errorMessage="
1 errors found:

Error at line 1, column 32, in file 'Compiler/OptimicaFrontEnd/src/test/OptimicaTransformCanonicalTests.mo', ARRAY_SIZE_MISMATCH_IN_ATTRIBUTE_MODIFICATION:
  Array size mismatch in modification of the attribute objective for the optimization ArrayTest3_Err, expected size is scalar and size of objective expression is [2]
")})));
  end ArrayTest3_Err;


optimization TimedArrayTest1 (objective=y(finalTime),startTime=0,finalTime=2)
 Real x[2] = {1,2};
 Real y = x[1];
constraint
 y <= x[2](0);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TimedArrayTest1",
			description="Timed array variables: basic test",
            eliminate_alias_variables=false,
			flatModel="
optimization OptimicaTransformCanonicalTests.TimedArrayTest1(objective = y(finalTime),startTime = 0,finalTime = 2)
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real y = 1.0;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
constraint 
 1.0 <= x[2](0);
end OptimicaTransformCanonicalTests.TimedArrayTest1;
")})));
end TimedArrayTest1;


optimization TimedArrayTest2 (objective=y(finalTime),startTime=0,finalTime=2)
 Real x[2] = {1,2};
 Real y = x[1] + 3;
constraint
 y <= x(0) * {2,3};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TimedArrayTest2",
			description="Timed array variables: scalarizing vector multiplication",
			flatModel="
optimization OptimicaTransformCanonicalTests.TimedArrayTest2(objective = y(finalTime),startTime = 0,finalTime = 2)
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real y = 4.0;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
constraint 
 4.0 <= x[1](0) * 2 + x[2](0) * 3;
end OptimicaTransformCanonicalTests.TimedArrayTest2;
")})));
end TimedArrayTest2;


optimization TimedArrayTest3 (objective=y(finalTime),startTime=0,finalTime=2)
 Real x[2] = {1,2};
 Real y = x[1] + 3;
constraint
 y <= x("0") * {2,3};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TimedArrayTest3",
            description="Type checking timed variables: string arg",
            errorMessage="
1 errors found:

Error at line 5, column 7, in file 'Compiler/OptimicaFrontEnd/src/test/OptimicaTransformCanonicalTests.mo':
  The argument of a timed variable must be a scalar parameter Real expression
    type of '\"0\"' is String
")})));
end TimedArrayTest3;


optimization TimedArrayTest4 (objective=y(finalTime),startTime=0,finalTime=2)
 Real x[2] = {1,2};
 Real y = x[1] + 3;
constraint
 y <= x(y) * {2,3};

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TimedArrayTest4",
            description="Type checking timed variables: continuous arg",
            errorMessage="
1 errors found:

Error at line 5, column 7, in file 'Compiler/OptimicaFrontEnd/src/test/OptimicaTransformCanonicalTests.mo':
  The argument of a timed variable must be a scalar parameter Real expression
    'y' is of continuous-time variability
")})));
end TimedArrayTest4;


optimization ForConstraint1 (objective=sum(y(finalTime)),startTime=0,finalTime=2)
 Real x[2] = {1,2};
 Real y[2] = {3,4} + x;
constraint
 for i in 1:2, j in 1:2 loop
  y[i] <= x[j];
 end for;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForConstraint1",
			description="Scalarization of for constraints",
			flatModel="
optimization OptimicaTransformCanonicalTests.ForConstraint1(objective = y[1](finalTime) + y[2](finalTime),startTime = 0,finalTime = 2)
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real y[1] = 4.0;
 constant Real y[2] = 6.0;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
constraint 
 4.0 <= 1.0;
 4.0 <= 2.0;
 6.0 <= 1.0;
 6.0 <= 2.0;
end OptimicaTransformCanonicalTests.ForConstraint1;
")})));
end ForConstraint1;

optimization MinTimeTest1 (objective=finalTime,finalTime(free=true,start=1,initialGuess=3)=4)
  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MinTimeTest1",
			description="Test normalization of minimum time problems",
			flatModel="
optimization OptimicaTransformCanonicalTests.MinTimeTest1(objective = finalTime,finalTime = 1.0)
 Real x(start = 1,fixed = true);
 Real dx(start = 0,fixed = true);
 input Real u;
 parameter Real startTime = 0.0 /* 0.0 */;
 free parameter Real finalTime(free = true,start = 1,initialGuess = 3);
 Real der(x);
 Real der(dx);
initial equation 
 x = 1;
 dx = 0;
equation
 der(x) / (finalTime - startTime) = dx;
 der(dx) / (finalTime - startTime) = u;
constraint 
 u <= 1;
 u >= -1;
 x(finalTime) = 0;
 dx(finalTime) = 0;
end OptimicaTransformCanonicalTests.MinTimeTest1;
")})));
end MinTimeTest1;

optimization MinTimeTest2 (objective=-startTime, startTime(free=true,initialGuess=-1)=2)

  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MinTimeTest2",
			description="Test normalization of minimum time problems",
			flatModel="
optimization OptimicaTransformCanonicalTests.MinTimeTest2(objective = - startTime,startTime = 0.0)
 Real x(start = 1,fixed = true);
 Real dx(start = 0,fixed = true);
 input Real u;
 free parameter Real startTime(free = true,initialGuess = - 1,start = - 1);
 parameter Real finalTime = 1.0 /* 1.0 */;
 Real der(x);
 Real der(dx);
initial equation 
 x = 1;
 dx = 0;
equation
 der(x) / (finalTime - startTime) = dx;
 der(dx) / (finalTime - startTime) = u;
constraint 
 u <= 1;
 u >= -1;
 x(finalTime) = 0;
 dx(finalTime) = 0;
end OptimicaTransformCanonicalTests.MinTimeTest2;
")})));
end MinTimeTest2;

optimization MinTimeTest3 (objective=finalTime, startTime(free=true,initialGuess=-1), finalTime(free=true,initialGuess = 2))
  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  startTime=-1;
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MinTimeTest3",
			description="Test normalization of minimum time problems",
			flatModel="
optimization OptimicaTransformCanonicalTests.MinTimeTest3(objective = finalTime,startTime = 0.0,finalTime = 1.0)
 Real x(start = 1,fixed = true);
 Real dx(start = 0,fixed = true);
 input Real u;
 free parameter Real startTime(free = true,initialGuess = - 1,start = - 1);
 free parameter Real finalTime(free = true,initialGuess = 2,start = 2);
 Real der(x);
 Real der(dx);
initial equation 
 x = 1;
 dx = 0;
equation
 der(x) / (finalTime - startTime) = dx;
 der(dx) / (finalTime - startTime) = u;
constraint 
 startTime = -1;
 u <= 1;
 u >= -1;
 x(finalTime) = 0;
 dx(finalTime) = 0;
end OptimicaTransformCanonicalTests.MinTimeTest3;
")})));
end MinTimeTest3;


  model DAETest1
	parameter Integer N = 5 "Number of linear ODEs/DAEs";
	parameter Integer N_states = 3 "Number of states: < N";
	Real x[N](each start=3,fixed=dynamic) "States/algebraics";
	input Real u "Control input";
	output Real y = x[1] "Output";
	parameter Real a[N] = (0.5*(N+1):-0.5:1) "Time constants";
	parameter Boolean dynamic[N] = array((if i<=N_states then true else false) for i in 1:N) "Switches for turning ODEs into DAEs";    
  equation
	// ODE equations
	for i in 1:N_states loop
		der(x[i]) = -a[i]*x[i] + a[i]*x[i+1];
	end for;
	// DAE equations
	for i in N_states+1:N-1 loop
		0 = -a[i]*x[i] + a[i]*x[i+1];
	end for;
	// The last equation is assumed to be algebraic
	0 = -a[N]*x[N] + a[N]*u;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="DAETest1",
			description="Fixed set from parameter with parameter equation",
			flatModel="
fclass OptimicaTransformCanonicalTests.DAETest1
 structural parameter Integer N = 5 \"Number of linear ODEs/DAEs\" /* 5 */;
 structural parameter Integer N_states = 3 \"Number of states: < N\" /* 3 */;
 Real x[1](start = 3,fixed = dynamic[1]) \"States/algebraics\";
 Real x[2](start = 3,fixed = dynamic[2]) \"States/algebraics\";
 Real x[3](start = 3,fixed = dynamic[3]) \"States/algebraics\";
 Real x[4](start = 3,fixed = dynamic[4]) \"States/algebraics\";
 Real x[5](start = 3,fixed = dynamic[5]) \"States/algebraics\";
 input Real u \"Control input\";
 output Real y \"Output\";
 structural parameter Real a[1] = 3.0 \"Time constants\" /* 3.0 */;
 structural parameter Real a[2] = 2.5 \"Time constants\" /* 2.5 */;
 structural parameter Real a[3] = 2.0 \"Time constants\" /* 2.0 */;
 structural parameter Real a[4] = 1.5 \"Time constants\" /* 1.5 */;
 structural parameter Real a[5] = 1.0 \"Time constants\" /* 1.0 */;
 parameter Boolean dynamic[1] = true \"Switches for turning ODEs into DAEs\" /* true */;
 parameter Boolean dynamic[2] = true \"Switches for turning ODEs into DAEs\" /* true */;
 parameter Boolean dynamic[3] = true \"Switches for turning ODEs into DAEs\" /* true */;
 parameter Boolean dynamic[4] = false \"Switches for turning ODEs into DAEs\" /* false */;
 parameter Boolean dynamic[5] = false \"Switches for turning ODEs into DAEs\" /* false */;
initial equation 
 x[1] = 3;
 x[2] = 3;
 x[3] = 3;
equation
 der(x[1]) = -3.0 * x[1] + 3.0 * x[2];
 der(x[2]) = -2.5 * x[2] + 2.5 * x[3];
 der(x[3]) = -2.0 * x[3] + 2.0 * x[4];
 0 = -1.5 * x[4] + 1.5 * x[5];
 0 = - x[5] + u;
 y = x[1];
end OptimicaTransformCanonicalTests.DAETest1;
")})));
  end DAETest1;

optimization DepParTest1 (objective=1,startTime=0,finalTime=1) 

  parameter Real p1(free=true) = 1;
  parameter Real p2 = 5;
  Real x;
equation
  x*p2 = p1;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="DepParTest1",
			methodName="freeParametersDiagnostics",
			description="Test that free dependent parameters are handled correctly",
			methodResult="  
Free independent parameters:
p1
Free dependent parameters:
")})));
end DepParTest1;

optimization DepParTest2 (objective=1,startTime=0,finalTime=1) 

  parameter Real p1(free=true) = 1;
  parameter Real p2 = p1*2;
  Real x;
equation
  x*p2 = p1;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="DepParTest2",
			methodName="freeParametersDiagnostics",
			description="Test that free dependent parameters are handled correctly.",
			methodResult="  
Free independent parameters:
p1
Free dependent parameters:
")})));
end DepParTest2;

optimization DepParTest3 (objective=1,startTime=0,finalTime=1) 

  model M
    parameter Real p1 = 1;
    Real x = 2*p1;
  end M;
  
  M m(p1=p2*3);
  parameter Real p2(free=true) = 3;
  Real x;
equation
  x*p2 = 4;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="DepParTest3",
			methodName="freeParametersDiagnostics",
			description="Test that free dependent parameters are handled correctly.",
			methodResult="
Free independent parameters:
p2
Free dependent parameters:
")})));
end DepParTest3;

optimization DepParTest4 (objective=1,startTime=0,finalTime=1) 

  model M
    parameter Real p1 = 1;
    Real x = 2*p1;
  end M;
  
  M m(p1=p2*3);
  parameter Real p2(free=true) = 3;
  Real x;
equation
  x*p2 = 4;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="DepParTest4",
			convert_free_dependent_parameters_to_algebraics=false,
			methodName="freeParametersDiagnostics",
			description="Test that free dependent parameters are handled correctly.",
			methodResult="
Free independent parameters:
p2
Free dependent parameters:
m.p1
m.x
")})));
end DepParTest4;

optimization DepParTest5 (
		objectiveIntegrand=x^2 + y^2,
		objective=x^2 + y^2)
	parameter Real x(free=true,start=5);
	parameter Real y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="DepParTest5",
			description="Test update of objective for free dependent parameters.",
			flatModel="
optimization OptimicaTransformCanonicalTests.DepParTest5(objectiveIntegrand = x ^ 2 + y ^ 2,objective = x ^ 2 + y(startTime) ^ 2)
 free parameter Real x(free = true,start = 5);
 Real y;
 parameter Real startTime = 0.0 /* 0.0 */;
 parameter Real finalTime = 1.0 /* 1.0 */;
equation
 y = x;
constraint 
end OptimicaTransformCanonicalTests.DepParTest5;
")})));
end DepParTest5;

optimization VariabilityPropagation1
	parameter Real a(free=true);
	parameter Real b = a + 1;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="VariabilityPropagation1",
			description="Test so that variability propagation of free parameters is prevented",
			flatModel="
optimization OptimicaTransformCanonicalTests.VariabilityPropagation1
 free parameter Real a(free = true);
 Real b;
 parameter Real startTime = 0.0 /* 0.0 */;
 parameter Real finalTime = 1.0 /* 1.0 */;
equation
 b = a + 1;
constraint 
end OptimicaTransformCanonicalTests.VariabilityPropagation1;
")})));
end VariabilityPropagation1;

optimization SemiLinearConstraint (objective = x(finalTime)^2, startTime=0, finalTime=5)
    Real x;
    Real y;
equation
    x = time;
    y = time;
constraint
    x >= semiLinear(time, y, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SemiLinearConstraint",
            description="Test transformation of semiLinear in constraints",
            flatModel="
optimization OptimicaTransformCanonicalTests.SemiLinearConstraint(objective = y(finalTime) ^ 2,startTime = 0,finalTime = 5)
 Real y;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 5 /* 5 */;
equation
 y = time;
constraint 
 y >= if time >= 0 then time * y else time * 2;
end OptimicaTransformCanonicalTests.SemiLinearConstraint;
")})));
end SemiLinearConstraint;

end OptimicaTransformCanonicalTests;
