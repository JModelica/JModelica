/*
    Copyright (C) 2009-2018 Modelon AB

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

package TransformCanonicalTests

	model TransformCanonicalTest1
		Real x(start=1,fixed=true);
		Real y(start=3,fixed=true);
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;
                y + v = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest1",
			description="Test basic canonical transformations",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest1
 Real x(start = 1,fixed = true);
 Real y(start = 3,fixed = true);
 constant Real w(start = 1) = 2;
 Real v;
initial equation 
 x = 1;
 y = 3;
equation
 der(x) = - x;
 der(v) = 4;
 y + v = 1;
end TransformCanonicalTests.TransformCanonicalTest1;
")})));
	end TransformCanonicalTest1;
	
  model TransformCanonicalTest2
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p1;
  	parameter Real p1 = 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest2",
			description="Test parameter sorting",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest2
 parameter Real p6;
 parameter Real p5 = 5 /* 5 */;
 parameter Real p2;
 parameter Real p3;
 parameter Real p4;
 parameter Real p1 = 4 /* 4 */;
parameter equation
 p6 = p5;
 p2 = p1 * p1;
 p3 = p2 + p1;
 p4 = p3 * p3;
end TransformCanonicalTests.TransformCanonicalTest2;
")})));
  end TransformCanonicalTest2;

  model TransformCanonicalTest3_Err
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p4*p1;
  	parameter Real p1 = 4;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TransformCanonicalTest3_Err",
            description="Test parameter sorting.",
            errorMessage="
3 errors found:

Error at line 4, column 24, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p4 = p3 * p3

Error at line 5, column 24, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p3 = p2 + p1

Error at line 6, column 24, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p2 = p4 * p1
")})));
  end TransformCanonicalTest3_Err;

  model TransformCanonicalTest4_Err
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p2;
  	parameter Real p1 = 4;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TransformCanonicalTest4_Err",
            description="Test parameter sorting.",
            errorMessage="
3 errors found:

Error at line 4, column 24, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p4 = p3 * p3

Error at line 5, column 24, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p3 = p2 + p1

Error at line 6, column 24, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p2 = p1 * p2
")})));
  end TransformCanonicalTest4_Err;

  model TransformCanonicalTest5
    parameter Real p10 = p11*p3;
  	parameter Real p9 = p11*p8;
  	parameter Real p2 = p11;
  	parameter Real p11 = p7*p5;
  	parameter Real p8 = p7*p3;
  	parameter Real p7 = 1;
  	parameter Real p5 = 1;
    parameter Real p3 = 1;
  	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest5",
			description="Test parameter sorting",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest5
 parameter Real p11;
 parameter Real p8;
 parameter Real p10;
 parameter Real p2;
 parameter Real p9;
 parameter Real p7 = 1 /* 1 */;
 parameter Real p5 = 1 /* 1 */;
 parameter Real p3 = 1 /* 1 */;
parameter equation
 p11 = p7 * p5;
 p8 = p7 * p3;
 p10 = p11 * p3;
 p2 = p11;
 p9 = p11 * p8;
end TransformCanonicalTests.TransformCanonicalTest5;
")})));
  end TransformCanonicalTest5;


  model TransformCanonicalTest6

    parameter Real p1 = sin(1);
    parameter Real p2 = cos(1);
    parameter Real p3 = tan(1); 
    parameter Real p4 = asin(0.3);
    parameter Real p5 = acos(0.3);
    parameter Real p6 = atan(0.3); 
    parameter Real p7 = atan2(0.3,0.5); 	
    parameter Real p8 = sinh(1);
    parameter Real p9 = cosh(1);
    parameter Real p10 = tanh(1); 
    parameter Real p11 = exp(1);
    parameter Real p12 = log(1);
    parameter Real p13 = log10(1);   	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest6",
			description="Built-in functions.",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest6
 parameter Real p1 = 0.8414709848078965 /* 0.8414709848078965 */;
 parameter Real p2 = 0.5403023058681398 /* 0.5403023058681398 */;
 parameter Real p3 = 1.5574077246549023 /* 1.5574077246549023 */;
 parameter Real p4 = 0.3046926540153975 /* 0.3046926540153975 */;
 parameter Real p5 = 1.2661036727794992 /* 1.2661036727794992 */;
 parameter Real p6 = 0.2914567944778671 /* 0.2914567944778671 */;
 parameter Real p7 = 0.5404195002705842 /* 0.5404195002705842 */;
 parameter Real p8 = 1.1752011936438014 /* 1.1752011936438014 */;
 parameter Real p9 = 1.543080634815244 /* 1.543080634815244 */;
 parameter Real p10 = 0.7615941559557649 /* 0.7615941559557649 */;
 parameter Real p11 = 2.7182818284590455 /* 2.7182818284590455 */;
 parameter Real p12 = 0.0 /* 0.0 */;
 parameter Real p13 = 0.0 /* 0.0 */;
end TransformCanonicalTests.TransformCanonicalTest6;
")})));
  end TransformCanonicalTest6;
  
  
  model TransformCanonicalTest7
	  parameter Integer p1 = 2;
	  parameter Integer p2 = p1;
	  Real x[p2] = 1:p2;
	  Real y = x[p2]; 

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest7",
			description="Provokes a former bug that was due to tree traversals befor the flush after scalarization",
            eliminate_alias_variables=false,
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest7
 structural parameter Integer p1 = 2 /* 2 */;
 structural parameter Integer p2 = 2 /* 2 */;
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real y = 2.0;
end TransformCanonicalTests.TransformCanonicalTest7;
")})));
  end TransformCanonicalTest7;

  model TransformCanonicalTest9_Err
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
        
        EO eo = eo;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TransformCanonicalTest9_Err",
            description="Circularity in external object binding expression",
            errorMessage="
1 errors found:

Error at line 15, column 17, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: eo = eo
")})));
  end TransformCanonicalTest9_Err;

  model EvalTest1

    parameter Real p1 = sin(1);
    parameter Real p2 = cos(1);
    parameter Real p3 = tan(1); 
    parameter Real p4 = asin(0.3);
    parameter Real p5 = acos(0.3);
    parameter Real p6 = atan(0.3); 
    parameter Real p7 = atan2(0.3,0.5); 	
    parameter Real p8 = sinh(1);
    parameter Real p9 = cosh(1);
    parameter Real p10 = tanh(1); 
    parameter Real p11 = exp(1);
    parameter Real p12 = log(1);
    parameter Real p13 = log10(1); 


  	

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="EvalTest1",
			methodName="variableDiagnostics",
			description="Test evaluation of independent parameters",
			methodResult="
Independent constants: 
        
Dependent constants: 

Independent parameters: 
 p1: number of uses: 0, isLinear: true, evaluated binding exp: 0.8414709848078965
 p2: number of uses: 0, isLinear: true, evaluated binding exp: 0.5403023058681398
 p3: number of uses: 0, isLinear: true, evaluated binding exp: 1.5574077246549023
 p4: number of uses: 0, isLinear: true, evaluated binding exp: 0.3046926540153975
 p5: number of uses: 0, isLinear: true, evaluated binding exp: 1.2661036727794992
 p6: number of uses: 0, isLinear: true, evaluated binding exp: 0.2914567944778671
 p7: number of uses: 0, isLinear: true, evaluated binding exp: 0.5404195002705842
 p8: number of uses: 0, isLinear: true, evaluated binding exp: 1.1752011936438014
 p9: number of uses: 0, isLinear: true, evaluated binding exp: 1.543080634815244
 p10: number of uses: 0, isLinear: true, evaluated binding exp: 0.7615941559557649
 p11: number of uses: 0, isLinear: true, evaluated binding exp: 2.7182818284590455
 p12: number of uses: 0, isLinear: true, evaluated binding exp: 0.0
 p13: number of uses: 0, isLinear: true, evaluated binding exp: 0.0

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables:

Algebraic real variables: 

Input variables: 
")})));
  end EvalTest1;

  model EvalTest2

    parameter Real p1 = 1*10^4;
  	

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="EvalTest2",
			methodName="variableDiagnostics",
			description="Test evaluation of independent parameters",
			methodResult="
Independent constants: 

Dependent constants: 

Independent parameters: 
 p1: number of uses: 0, isLinear: true, evaluated binding exp: 10000.0

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables:

Algebraic real variables: 

Input variables: 

")})));
  end EvalTest2;




  model LinearityTest1

    Real x1;
    Real x2;
    Real x3;
    Real x4;
    Real x5;
    Real x6;
    Real x7;

    parameter Real p1 = 1;

  equation
    x1 = x1 * p1 + x2;
    x2 = x3 ^ 2;
    x3 = x4 / p1;
    x4 = p1 / x5;
    x5 = x6 - x6;
    x6 = sin(x7);
    x7 = x3 * x5;

  annotation(__JModelica(UnitTesting(tests={
    FClassMethodTestCase(
      name="LinearityTest1",
      methodName="variableDiagnostics",
      description="Test linearity of variables.",
      methodResult="

Independent constants: 

Dependent constants: 

Independent parameters: 
 p1: number of uses: 3, isLinear: true, evaluated binding exp: 1

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables:

Algebraic real variables: 
 x1: number of uses: 2, isLinear: true, alias: no
 x2: number of uses: 2, isLinear: true, alias: no
 x3: number of uses: 3, isLinear: false, alias: no
 x4: number of uses: 2, isLinear: true, alias: no
 x5: number of uses: 3, isLinear: false, alias: no
 x6: number of uses: 1, isLinear: true, alias: no
 x7: number of uses: 2, isLinear: false, alias: no

Input variables: 
  ")})));
  end LinearityTest1;


model LinearityTest2
    Real a, b;
equation
    a^2 + a = 2;
    b.^2 + b = 2;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LinearityTest2",
            description="Linearity check for .^",
            methodName="variableDiagnostics",
            methodResult="
Independent constants: 

Dependent constants: 

Independent parameters: 

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables: 

Algebraic real variables: 
 a: number of uses: 2, isLinear: false, alias: no
 b: number of uses: 2, isLinear: false, alias: no

Input variables: 
")})));
end LinearityTest2;


model LinearityTest3
    Real a, b;
equation
    a .* b = 2;
    b = time;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LinearityTest3",
            description="Linearity check for .*",
            methodName="variableDiagnostics",
            methodResult="
Independent constants: 

Dependent constants: 

Independent parameters: 

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables: 

Algebraic real variables: 
 a: number of uses: 1, isLinear: false, alias: no
 b: number of uses: 2, isLinear: false, alias: no

Input variables: 
")})));
end LinearityTest3;


model LinearityTest4
    Real a, b, c;
    parameter Real d = 3;
equation
    a ./ b = 2;
    c ./ d + a = 2;
    b = time;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LinearityTest4",
            description="Linearity check for ./",
            methodName="variableDiagnostics",
            methodResult="
Independent constants: 

Dependent constants: 

Independent parameters: 
 d: number of uses: 1, isLinear: true, evaluated binding exp: 3

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables: 

Algebraic real variables: 
 a: number of uses: 2, isLinear: false, alias: no
 b: number of uses: 2, isLinear: false, alias: no
 c: number of uses: 1, isLinear: true, alias: no

Input variables: 
")})));
end LinearityTest4;



  model AliasTest1
    Real x1 = time;
    Real x2 = time;
    Real x3,x4,x5,x6;
  equation
    x1 = -x3;
    -x1 = x4;
    x2 = -x5;
    x5 = x6;  
   

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="AliasTest1",
            methodName="aliasDiagnostics",
            description="Test computation of alias sets.",
            eliminate_linear_equations=false,
            methodResult="
Alias sets:
{x1,-x3,-x4}
{x2,-x5,-x6}
4 variables can be eliminated
")})));
  end AliasTest1;

  model AliasTest2
    Real x1 = time;
    Real x2,x3,x4;
  equation
    x1 = x2;
    x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest2",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,x3,x4}
3 variables can be eliminated
")})));
  end AliasTest2;

  model AliasTest3
    Real x1 = time;
    Real x2,x3,x4;
  equation
    x1 = x2;
    x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest3",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,-x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest3;

  model AliasTest4
    Real x1 = time;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest4",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3,x4}
3 variables can be eliminated
")})));
  end AliasTest4;

  model AliasTest5
    Real x1 = time;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest5",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest5;

  model AliasTest6
    Real x1 = time;
    Real x2,x3,x4;
  equation
    x1 = x2;
    -x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest6",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest6;

  model AliasTest7
    Real x1 = time;
    Real x2,x3,x4;
  equation
    x1 = x2;
    -x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest7",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,-x3,x4}
3 variables can be eliminated
")})));
  end AliasTest7;

  model AliasTest8
    Real x1 = time;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    -x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest8",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest8;

  model AliasTest9
    Real x1 = time;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    -x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest9",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3,x4}
3 variables can be eliminated
")})));
  end AliasTest9;

  model AliasTest10
    Real x1 = time;
    Real x2,x3;
  equation
    x1 = x2;
    x3 = x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest10",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,x3}
2 variables can be eliminated
")})));
  end AliasTest10;

  model AliasTest11
    Real x1 = time;
    Real x2,x3;
  equation
    x1 = x2;
    x3 = -x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest11",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,-x3}
2 variables can be eliminated
")})));
  end AliasTest11;

  model AliasTest12
    Real x1 = time;
    Real x2,x3;
  equation
    x1 = -x2;
    x3 = x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest12",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3}
2 variables can be eliminated
")})));
  end AliasTest12;

  model AliasTest13
    Real x1 = time;
    Real x2,x3;
  equation
    x1 = -x2;
    x3 = -x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest13",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3}
2 variables can be eliminated
")})));
  end AliasTest13;

  model AliasTest14
    Real x1 = time;
    Real x2,x3;
  equation
    -x1 = x2;
    x3 = x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest14",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3}
2 variables can be eliminated
")})));
  end AliasTest14;

  model AliasTest15
    Real x1 = time;
    Real x2,x3;
  equation
    -x1 = x2;
    x3 = -x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest15",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3}
2 variables can be eliminated
")})));
  end AliasTest15;

  model AliasTest16_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x2 = x3;
    x3=-x1;


    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AliasTest16_Err",
            description="Test alias error.",
            errorMessage="
1 errors found:

Error in flattened model:
  Alias error: trying to add the negated alias pair (x3,-x1) to the alias set {x1,x2,x3}
")})));
  end AliasTest16_Err;

  model AliasTest17_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x2 = -x3;
    x3=x1;


    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AliasTest17_Err",
            description="Test alias error.",
            errorMessage="
1 errors found:

Error in flattened model:
  Alias error: trying to add the alias pair (x3,x1) to the alias set {x1,x2,-x3}
")})));
  end AliasTest17_Err;

  model AliasTest18_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = x3;
    x3=x1;


    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AliasTest18_Err",
            description="Test alias error.",
            errorMessage="
1 errors found:

Error in flattened model:
  Alias error: trying to add the alias pair (x3,x1) to the alias set {x1,-x2,-x3}
")})));
  end AliasTest18_Err;

  model AliasTest19_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = -x3;
    x3=-x1;


    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AliasTest19_Err",
            description="Test alias error.",
            errorMessage="
1 errors found:

Error in flattened model:
  Alias error: trying to add the negated alias pair (x3,-x1) to the alias set {x1,-x2,x3}
")})));
  end AliasTest19_Err;

  model AliasTest20
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = -x3;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest20",
			description="Test elimination of alias variables",
            variability_propagation=false,
			flatModel="
fclass TransformCanonicalTests.AliasTest20
 Real x1;
equation
 x1 = 1;
end TransformCanonicalTests.AliasTest20;
")})));
  end AliasTest20;

  model AliasTest21
    Real x1,x2,x3;
  equation
    0 = x1 + x2;
    x1 = time;   
    x3 = x2^2;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest21",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2}
1 variables can be eliminated
")})));
  end AliasTest21;

  model AliasTest22
    Real x1,x2,x3;
  equation
    0 = x1 + x2;
    x1 = 1;   
    x3 = x2^2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest22",
			description="Test elimination of alias variables",
            variability_propagation=false,
			flatModel="
fclass TransformCanonicalTests.AliasTest22
 Real x1;
 Real x3;
equation
 x1 = 1;
 x3 = (- x1) ^ 2;
end TransformCanonicalTests.AliasTest22;
")})));
  end AliasTest22;


  model AliasTest23
    Real x1,x2;
  equation
    x1 = -x2;
    der(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest23",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest23
 Real x1;
initial equation 
 x1 = 0.0;
equation
 - der(x1) = 0;
end TransformCanonicalTests.AliasTest23;
")})));
  end AliasTest23;

  model AliasTest24
    Real x1,x2;
    input Real u;
  equation
    x2 = u;
    der(x1) = u;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest24",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest24
 Real x1;
 Real x2;
 input Real u;
initial equation 
 x1 = 0.0;
equation 
 x2 = u;
 der(x1) = u;

end TransformCanonicalTests.AliasTest24;
")})));
end AliasTest24;


  model AliasTest25
    Real x1(fixed=false);
    Real x2(fixed =true);
    Real x3;
  equation
    der(x3) = 1;
    x1 = x3;
    x2 = x1;	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest25",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest25
 Real x2(fixed = true);
initial equation 
 x2 = 0.0;
equation 
 der(x2) = 1;

end TransformCanonicalTests.AliasTest25;
")})));
end AliasTest25;

model AliasTest26
 parameter Real p = 1;
 Real x,y;
equation
 x = p;
 y = x+3;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest26",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest26
 parameter Real p = 1 /* 1 */;
 parameter Real x;
 parameter Real y;
parameter equation
 x = p;
 y = x + 3;
end TransformCanonicalTests.AliasTest26;
			
")})));
end AliasTest26;

model AliasTest27
 Real x1;
 Real x2;
 Real x3;
 Real x4;
 Real x5;
equation
 x4 = x5;
 x1 = x3;
 x2 = x4;
 x3 = x5;
 x3 = 1;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest27",
			description="Test elimination of alias variables.",
            variability_propagation=false,
			flatModel="
fclass TransformCanonicalTests.AliasTest27
 Real x1;
equation
 x1 = 1;
end TransformCanonicalTests.AliasTest27;
")})));
end AliasTest27;

model AliasTest28
 Real x,y;
 parameter Real p = 1;
equation
 x = -p;
 y = x + 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest28",
			description="Test elimination of alias variables.",
			flatModel="
fclass TransformCanonicalTests.AliasTest28
 parameter Real x;
 parameter Real y;
 parameter Real p = 1 /* 1 */;
parameter equation
 x = - p;
 y = x + 1;
end TransformCanonicalTests.AliasTest28;
			
")})));
end AliasTest28;

model AliasTest29
 Real pml1;
 Real pml2;
 Real pml3;
 Real mpl1;
 Real mpl2;
 Real mpl3;
 Real mml1;
 Real mml2;
 Real mml3;
 Real pmr1;
 Real pmr2;
 Real pmr3;
 Real mpr1;
 Real mpr2;
 Real mpr3;
 Real mmr1;
 Real mmr2;
 Real mmr3;
equation
 pml1-pml2=0;
 pml3+pml2*pml2=0;
 cos(pml1)+pml3*pml3=0;

 -mpl1+mpl2=0;
 mpl3+mpl2*mpl2=0;
 cos(mpl1)+mpl3*mpl3=0;

 -mml1-mml2=0;
 mml3+mml2*mml2=0;
 cos(mml1)+mml3*mml3=0;

 0=pmr1-pmr2;
 pmr3+pmr2*pmr2=0;
 cos(pmr1)+pmr3*pmr3=0;

 0=-mpr1+mpr2;
 mpr3+mpr2*mpr2=0;
 cos(mpr1)+mpr3*mpr3=0;

 0=-mmr1-mmr2;
 mmr3+mmr2*mmr2=0;
  cos(mmr1)+mmr3*mmr3=0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest29",
			description="",
			flatModel="
fclass TransformCanonicalTests.AliasTest29
 Real pml1;
 Real pml3;
 Real mpl1;
 Real mpl3;
 Real mml1;
 Real mml3;
 Real pmr1;
 Real pmr3;
 Real mpr1;
 Real mpr3;
 Real mmr1;
 Real mmr3;
equation
 pml3 + pml1 * pml1 = 0;
 cos(pml1) + pml3 * pml3 = 0;
 mpl3 + mpl1 * mpl1 = 0;
 cos(mpl1) + mpl3 * mpl3 = 0;
 mml3 + (- mml1) * (- mml1) = 0;
 cos(mml1) + mml3 * mml3 = 0;
 pmr3 + pmr1 * pmr1 = 0;
 cos(pmr1) + pmr3 * pmr3 = 0;
 mpr3 + mpr1 * mpr1 = 0;
 cos(mpr1) + mpr3 * mpr3 = 0;
 mmr3 + (- mmr1) * (- mmr1) = 0;
 cos(mmr1) + mmr3 * mmr3 = 0;
end TransformCanonicalTests.AliasTest29;
")})));
end AliasTest29;

model AliasTest30
  parameter Boolean f = true;
  Real x(start=3,fixed=f);
  Real y;
  parameter Real p = 5;
equation
 der(x) = -y;
  x= p;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest30",
			description="",
			flatModel="
fclass TransformCanonicalTests.AliasTest30
 parameter Boolean f = true /* true */;
 parameter Real x(start = 3,fixed = true);
 constant Real y = -0.0;
 parameter Real p = 5 /* 5 */;
parameter equation
 x = p;
end TransformCanonicalTests.AliasTest30;
")})));
end AliasTest30;

model AliasTest31
 Real x1;
 Real x2;
 Real x3;
 Real x4;
equation
 x1 = -x2;
 x3 = -x4;
 x2 = -x4;
 x3 = time;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest31",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3,x4}
3 variables can be eliminated
")})));
end AliasTest31;

model AliasTest32
  Integer a = 42;
  Real b;
  Real c;
equation
  a = b;
  b = c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest32",
			methodName="aliasDiagnostics",
			description="Test so that variables with different types aren't alias eliminated",
            variability_propagation=false,
			methodResult="
Alias sets:
{b, c}
1 variables can be eliminated
")})));
end AliasTest32;

model AliasTest33
  function f1
    input Real x;
    output Real y;
  algorithm
    y := x * 1;
  end f1;
  function f2
    input Real x;
    output Real y;
  algorithm
    y := x * 2;
  end f2;
  Real a (start = f1(1) * 1);
  Real b (start = f2(2) * 2) = a;
equation
 a = time;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest33",
			methodName="aliasDiagnostics",
			description="Test so that start values are printed correcly in alias set",
			methodResult="
Alias sets:
{b(start=8.0), a(start=1)}
1 variables can be eliminated
")})));
  end AliasTest33;

model AliasTest34
  Real x(start = 0.1);
  Real y;
  discrete Real switchTime(start=-1e60, fixed=true);
  parameter Boolean yOn = true;
  
  initial equation
    pre(x) + pre(y) = 2 * switchTime ^2;
    pre(x) = pre(y);
  
  equation
    when yOn then
      switchTime = time;
    end when;
    x = y;
    der(x) = x * (time - switchTime);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="AliasTest34",
            methodName="printDAEInitBLT",
            description="Test so that initial equations which link two alias variables are removed. In this case it is important that switchTime = pre(switchTime)",
            methodResult="
--- Solved equation ---
pre(switchTime) := -1.0E60

--- Solved equation ---
switchTime := pre(switchTime)

--- Solved equation ---
x := 0.1

--- Solved equation ---
der(x) := x * (time - switchTime)

--- Solved equation ---
pre(x) := 2 * switchTime ^ 2 / (1.0 + 1.0)
-------------------------------
")})));
end AliasTest34;

    model AliasTest35
        function f
            input Real x;
            input Real y;
            output Real z;
            output Real w;
        protected
            Real v1;
            Real v2;
        algorithm
            v1 := x;
            v2 := y - 1;
            z := 2*x + (v2 * x * v1);
            w := v1 * v2;
            annotation(Inline=true);
        end f;
        
        Real x = time;
        Real y = 1;
        Real z;
        Real w;
    equation
        (z, w) = f(x + 1, y);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="AliasTest35",
            methodName="aliasDiagnostics",
            description="Test so that alias sets with only temporaries in are removed",
            methodResult="
Alias sets:
{w, temp_4}
1 variables can be eliminated
")})));
    end AliasTest35;

    model AliasTest36
        parameter String s1 = "string";
        parameter String s2 = s1;
        parameter String s3 = "string" annotation(Evaluate=true);
        parameter String s4 = "string" annotation(Evaluate=true);
        parameter String s5 = s2;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="AliasTest36",
            methodName="aliasDiagnostics",
            description="String aliases",
            eliminate_alias_parameters=true,
            methodResult="
Alias sets:
{s5, s2}
{s3, s4}
2 variables can be eliminated
")})));
    end AliasTest36;

model AliasVisibility1
    Real a;
protected
    Real b(start=1);
equation
    a = b;
    a = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
         name="AliasVisibility1",
         description="",
         flatModel="
fclass TransformCanonicalTests.AliasVisibility1
protected
 Real b(start = 1);
equation
 b = time;
end TransformCanonicalTests.AliasVisibility1;
")})));
end AliasVisibility1;

model AliasFuncTest1
    function f
        input Real a;
        output Real[3] b;
    algorithm
        b := {1, 2, 3} * a;
    end f;
    
    model A
        Real x;
    end A;
    
    A[3] y(x=f(z));
    Real z = 1;

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AliasFuncTest1",
         description="",
         flatModel="
fclass TransformCanonicalTests.AliasFuncTest1
 Real y[1].x;
 Real y[2].x;
 Real y[3].x;
 Real z;
 Real temp_1[2];
 Real temp_1[3];
 Real temp_2[1];
 Real temp_2[3];
 Real temp_3[1];
 Real temp_3[2];
equation
 ({y[1].x,temp_1[2],temp_1[3]}) = TransformCanonicalTests.AliasFuncTest1.f(z);
 ({temp_2[1],y[2].x,temp_2[3]}) = TransformCanonicalTests.AliasFuncTest1.f(z);
 ({temp_3[1],temp_3[2],y[3].x}) = TransformCanonicalTests.AliasFuncTest1.f(z);
 z = 1;

public
 function TransformCanonicalTests.AliasFuncTest1.f
  input Real a;
  output Real[3] b;
 algorithm
  b[1] := ( 1 ) * ( a );
  b[2] := ( 2 ) * ( a );
  b[3] := ( 3 ) * ( a );
  return;
 end TransformCanonicalTests.AliasFuncTest1.f;

end TransformCanonicalTests.AliasFuncTest1;
")})));
end AliasFuncTest1;


model AliasPropMinMax1
	Real x1(min = 1.0, max = 5.0) = time;
	Real x2(min = 0.0, max = 2.5) = x1;
    Integer y1(min = 1, max = 5) = integer(time);
    Integer y2(min = 0, max = 3) = y1;
	type A = enumeration(a, b, c, d, e);
	A a1(min = A.b, max = A.e, start = A.b);
	A a2(min = A.a, max = A.d) = a1;
equation
	when time > 1 then
		a1 = A.c;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasPropMinMax1",
			description="Test propagation of min/max attributes in alias set",
			flatModel="
fclass TransformCanonicalTests.AliasPropMinMax1
 Real x2(min = 1.0,max = 2.5);
 discrete Integer y1(min = 1,max = 3);
 discrete TransformCanonicalTests.AliasPropMinMax1.A a1(min = TransformCanonicalTests.AliasPropMinMax1.A.b,max = TransformCanonicalTests.AliasPropMinMax1.A.d,start = TransformCanonicalTests.AliasPropMinMax1.A.b);
 discrete Boolean temp_2;
initial equation 
 pre(y1) = 0;
 pre(a1) = TransformCanonicalTests.AliasPropMinMax1.A.b;
 pre(temp_2) = false;
equation
 temp_2 = time > 1;
 a1 = if temp_2 and not pre(temp_2) then TransformCanonicalTests.AliasPropMinMax1.A.c else pre(a1);
 x2 = time;
 y1 = if time < pre(y1) or time >= pre(y1) + 1 or initial() then integer(time) else pre(y1);

public
 type TransformCanonicalTests.AliasPropMinMax1.A = enumeration(a, b, c, d, e);

end TransformCanonicalTests.AliasPropMinMax1;
")})));
end AliasPropMinMax1;


model AliasPropMinMax2
    Real x1(min = 2.6, max = 5.0) = time;
    Real x2(min = 0.0, max = 2.5) = x1;
    Integer y1(min = 3, max = 5) = integer(time);
    Integer y2(min = 0, max = 2) = y1;
    type A = enumeration(a, b, c, d, e);
    A a1(min = A.d, max = A.e, start = A.b);
    A a2(min = A.a, max = A.c) = a1;
equation
    when time > 1 then
        a1 = A.c;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AliasPropMinMax2",
            description="Test errors on impossible min/max combinations",
            errorMessage="
3 errors found:

Error at line 3, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Variable x2 is part of alias set that results in min/max combination with no possible values, min = 2.6, max = 2.5

Error at line 4, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Variable y1 is part of alias set that results in min/max combination with no possible values, min = 3, max = 2

Error at line 7, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Variable a1 is part of alias set that results in min/max combination with no possible values, min = TransformCanonicalTests.AliasPropMinMax2.A.d, max = TransformCanonicalTests.AliasPropMinMax2.A.c
")})));
end AliasPropMinMax2;


model AliasPropNominal1
    type A = Real(nominal = 2);
    
    model B
        Real x(nominal = 3);
    end B;
    
    Real x1 = time;
    A x2 = x1;
    
    Real y1 = time + 1;
    A y2 = y1;
    B y3(x = y1);
    
    Real z1 = time + 2;
    A z2 = z1;
    B z3(x = z1);
    Real z4(nominal = 4) = z1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasPropNominal1",
            description="Test propagation of nominal attribute in alias set",
            eliminate_linear_equations=false,
            flatModel="
fclass TransformCanonicalTests.AliasPropNominal1
 TransformCanonicalTests.AliasPropNominal1.A x2;
 TransformCanonicalTests.AliasPropNominal1.A y2(nominal = 3);
 TransformCanonicalTests.AliasPropNominal1.A z2(nominal = 4);
equation
 x2 = time;
 y2 = time + 1;
 z2 = time + 2;

public
 type TransformCanonicalTests.AliasPropNominal1.A = Real(nominal = 2);
end TransformCanonicalTests.AliasPropNominal1;
")})));
end AliasPropNominal1;


model AliasPropStart1
    type A = Real(start = 2);
    
    model B
        Real x(start = 3);
    end B;
    
    Real x1 = time;
    A x2 = x1;
    
    Real y1 = time + 1;
    A y2 = y1;
    B y3(x = y1);
    
    Real z1 = time + 2;
    A z2 = z1;
    B z3(x = z1);
    Real z4(start = 4) = z1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasPropStart1",
            description="Test propagation of start attribute in alias set",
            eliminate_linear_equations=false,
            flatModel="
fclass TransformCanonicalTests.AliasPropStart1
 TransformCanonicalTests.AliasPropStart1.A x2;
 TransformCanonicalTests.AliasPropStart1.A y2(start = 3);
 TransformCanonicalTests.AliasPropStart1.A z2(start = 4);
equation
 x2 = time;
 y2 = time + 1;
 z2 = time + 2;

public
 type TransformCanonicalTests.AliasPropStart1.A = Real(start = 2);
end TransformCanonicalTests.AliasPropStart1;
")})));
end AliasPropStart1;


model AliasPropStart2
    model A
        Real x(start = 1);
    end A;
    
    model B = A(x(start=2));
    model C = B(x(nominal=1));
    
    model D
        C c;
    end D;
    
    model E
        A a(x = time);
        D d(c(x = a.x));
    end E;
    
    E e;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasPropStart2",
            description="",
            flatModel="
fclass TransformCanonicalTests.AliasPropStart2
 Real e.a.x(start = 1,nominal = 1);
equation
 e.a.x = time;
end TransformCanonicalTests.AliasPropStart2;
")})));
end AliasPropStart2;


model AliasPropStart3
    model A
        Real x(start = 1);
    end A;
    
    model B = A(x(start=2));
    model C = B;
    
    model D
        C c;
    end D;
    
    model E
        A a(x = time);
        D d(c(x = a.x));
    end E;
    
    E e;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasPropStart3",
            description="",
            flatModel="
fclass TransformCanonicalTests.AliasPropStart3
 Real e.a.x(start = 1);
equation
 e.a.x = time;
end TransformCanonicalTests.AliasPropStart3;
")})));
end AliasPropStart3;


model AliasPropStart4
    model A
        Real x(start = 1);
    end A;
    
    model B = A(x(start=2));
    
    model E
        A a(x = time);
        B b(x = a.x);
    end E;
    
    E e;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasPropStart4",
            description="",
            flatModel="
fclass TransformCanonicalTests.AliasPropStart4
 Real e.b.x(start = 2);
equation
 e.b.x = time;
end TransformCanonicalTests.AliasPropStart4;
")})));
end AliasPropStart4;


model AliasPropFixed1
	Real x1(fixed = true);
	Real x2(start = 1) = x1;
	Real x3(stateSelect=StateSelect.prefer) = x2;
equation
	der(x3) = -x2 * time;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasPropFixed1",
			description="Test propagation of fixed attribute in alias set",
			flatModel="
fclass TransformCanonicalTests.AliasPropFixed1
 Real x3(stateSelect = StateSelect.prefer,start = 1,fixed = true);
initial equation 
 x3 = 1;
equation
 der(x3) = (- x3) * time;
 
public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");
 
end TransformCanonicalTests.AliasPropFixed1;
")})));
end AliasPropFixed1;


model AliasStateSelect1
    package A
        constant StateSelect ss[5] = { StateSelect.always, StateSelect.prefer, StateSelect.default, StateSelect.avoid, StateSelect.never };
        
        model B
            constant StateSelect s1;
            constant StateSelect s2;
            Real x1(stateSelect = s1);
            Real x2(stateSelect = s2);
        equation
            x1 = time;
            x1 = x2;
        end B;
    end A;
    
    A.B b[10](s1 = A.ss[{1, 1, 1, 1, 2, 2, 2, 3, 3, 4}], s2 = A.ss[{2, 3, 4, 5, 3, 4, 5, 4, 5, 5}]);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasStateSelect1",
            description="Test propagation of stateSelect attribute in alias set",
            eliminate_alias_constants=false,
            eliminate_linear_equations=false,
            flatModel="
fclass TransformCanonicalTests.AliasStateSelect1
 constant StateSelect b[1].s1 = StateSelect.always;
 constant StateSelect b[1].s2 = StateSelect.prefer;
 Real b[1].x1(stateSelect = StateSelect.always);
 constant StateSelect b[2].s1 = StateSelect.always;
 constant StateSelect b[2].s2 = StateSelect.default;
 Real b[2].x1(stateSelect = StateSelect.always);
 constant StateSelect b[3].s1 = StateSelect.always;
 constant StateSelect b[3].s2 = StateSelect.avoid;
 Real b[3].x1(stateSelect = StateSelect.always);
 constant StateSelect b[4].s1 = StateSelect.always;
 constant StateSelect b[4].s2 = StateSelect.never;
 Real b[4].x1(stateSelect = StateSelect.always);
 constant StateSelect b[5].s1 = StateSelect.prefer;
 constant StateSelect b[5].s2 = StateSelect.default;
 Real b[5].x1(stateSelect = StateSelect.prefer);
 constant StateSelect b[6].s1 = StateSelect.prefer;
 constant StateSelect b[6].s2 = StateSelect.avoid;
 Real b[6].x1(stateSelect = StateSelect.prefer);
 constant StateSelect b[7].s1 = StateSelect.prefer;
 constant StateSelect b[7].s2 = StateSelect.never;
 Real b[7].x1(stateSelect = StateSelect.prefer);
 constant StateSelect b[8].s1 = StateSelect.default;
 constant StateSelect b[8].s2 = StateSelect.avoid;
 Real b[8].x1(stateSelect = StateSelect.default);
 constant StateSelect b[9].s1 = StateSelect.default;
 constant StateSelect b[9].s2 = StateSelect.never;
 Real b[9].x1(stateSelect = StateSelect.default);
 constant StateSelect b[10].s1 = StateSelect.avoid;
 constant StateSelect b[10].s2 = StateSelect.never;
 Real b[10].x1(stateSelect = StateSelect.avoid);
 Real b[1]._der_x1;
 Real b[2]._der_x1;
 Real b[3]._der_x1;
 Real b[4]._der_x1;
 Real b[5]._der_x1;
 Real b[6]._der_x1;
 Real b[7]._der_x1;
equation
 b[1].x1 = time;
 b[2].x1 = time;
 b[3].x1 = time;
 b[4].x1 = time;
 b[5].x1 = time;
 b[6].x1 = time;
 b[7].x1 = time;
 b[8].x1 = time;
 b[9].x1 = time;
 b[10].x1 = time;
 b[1]._der_x1 = 1.0;
 b[2]._der_x1 = 1.0;
 b[3]._der_x1 = 1.0;
 b[4]._der_x1 = 1.0;
 b[5]._der_x1 = 1.0;
 b[6]._der_x1 = 1.0;
 b[7]._der_x1 = 1.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end TransformCanonicalTests.AliasStateSelect1;
")})));
end AliasStateSelect1;

model AliasStateSelect2
    Real a_s(stateSelect = StateSelect.always, start=1);
    Real a_s2(stateSelect = StateSelect.always);
    Real a_v,a_a;
equation
    a_s = a_s2;
    a_v = der(a_s);
    a_a = der(a_v);
    a_v = time;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="AliasStateSelect2",
            description="Test warnings for state select.",
            automatic_tearing=false,
            errorMessage="
1 warnings found:

Warning at line 3, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  a_s2 has stateSelect=always, but could not be selected as state
")})));
end AliasStateSelect2;

model AliasStateSelect3
    Real x(stateSelect=StateSelect.avoid) = time;
    Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasStateSelect3",
            description="Test selection of system variables with state select",
            flatModel="
fclass TransformCanonicalTests.AliasStateSelect3
 Real x(stateSelect = StateSelect.avoid);
equation
 x = time;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end TransformCanonicalTests.AliasStateSelect3;
")})));
end AliasStateSelect3;

model AliasStateSelect4
    model T = Real(stateSelect=StateSelect.avoid);
    T x = time;
    Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasStateSelect4",
            description="Test selection of system variables with state select",
            flatModel="
fclass TransformCanonicalTests.AliasStateSelect4
 TransformCanonicalTests.AliasStateSelect4.T x;
equation
 x = time;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 type TransformCanonicalTests.AliasStateSelect4.T = Real(stateSelect = StateSelect.avoid);
end TransformCanonicalTests.AliasStateSelect4;
")})));
end AliasStateSelect4;

model AliasStateSelect5
    model T = Real(stateSelect=StateSelect.prefer);
    Real x(stateSelect=StateSelect.avoid) = time;
    T y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasStateSelect5",
            description="Test selection of system variables with state select",
            flatModel="
fclass TransformCanonicalTests.AliasStateSelect5
 Real x(stateSelect = StateSelect.avoid);
equation
 x = time;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 type TransformCanonicalTests.AliasStateSelect5.T = Real(stateSelect = StateSelect.prefer);
end TransformCanonicalTests.AliasStateSelect5;
")})));
end AliasStateSelect5;


model AliasPropNegSecondRound1
    Real x(stateSelect=StateSelect.always);
    Real y(min=ymin);
    Real z;
    parameter Real ymin = 2;
equation
    x = -y * z;
    z = 1;
    der(x) = time - 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AliasPropNegSecondRound1",
            description="Test against crash when propagating negated attribute during second round of alias elimination",
            flatModel="
fclass TransformCanonicalTests.AliasPropNegSecondRound1
 Real x(stateSelect = StateSelect.always,max = - ymin);
 constant Real z = 1;
 parameter Real ymin = 2 /* 2 */;
initial equation 
 x = 0.0;
equation
 der(x) = time - 3;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end TransformCanonicalTests.AliasPropNegSecondRound1;
")})));
end AliasPropNegSecondRound1;


model ParameterBindingExpTest3_Warn

  parameter Real p;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ParameterBindingExpTest3_Warn",
            description="Test errors in binding expressions.",
            errorMessage="
1 errors found:

Warning at line 3, column 3, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter p does not have a binding expression
")})));
end ParameterBindingExpTest3_Warn;


model AttributeBindingExpTest1_Err

  Real p1;
  Real x(start=p1);
equation
  der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AttributeBindingExpTest1_Err",
            description="Test errors in binding expressions.",
            errorMessage="
1 errors found:

Error at line 4, column 16, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', START_VALUE_NOT_PARAMETER:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1
")})));
end AttributeBindingExpTest1_Err;

model AttributeBindingExpTest2_Err


  Real p1;
  Real x(start=p1+2);
equation
  der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AttributeBindingExpTest2_Err",
            description="Test errors in binding expressions..",
            errorMessage="
1 errors found:

Error at line 5, column 16, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', START_VALUE_NOT_PARAMETER:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1 + 2
")})));
end AttributeBindingExpTest2_Err;

model AttributeBindingExpTest3_Err

  Real p1;
  Real x(start=p1+2+p);
equation
  der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AttributeBindingExpTest3_Err",
            description="Test errors in binding expressions..",
            errorMessage="
2 errors found:

Error at line 4, column 16, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', START_VALUE_NOT_PARAMETER:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1 + 2 + p

Error at line 4, column 21, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Cannot find class or component declaration for p
")})));
end AttributeBindingExpTest3_Err;

model AttributeBindingExpTest4_Err

  parameter Real p1 = p2;
  parameter Real p2 = p1;

  Real x(start=p1);
equation
  der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AttributeBindingExpTest4_Err",
            description="Test errors in binding expressions..",
            errorMessage="
2 errors found:

Error at line 3, column 23, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p1 = p2

Error at line 4, column 23, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Circularity in binding expression of parameter: p2 = p1
")})));
end AttributeBindingExpTest4_Err;

model AttributeBindingExpTest5_Err

  model A
    Real p1;
    Real x(start=p1) = 2;
  end A;

  Real p2;	
  A a(x(start=p2));

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AttributeBindingExpTest5_Err",
            description="Test errors in binding expressions..",
            errorMessage="
2 errors found:

Error at line 5, column 18, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', START_VALUE_NOT_PARAMETER,
In component a:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1

Error at line 9, column 15, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', START_VALUE_NOT_PARAMETER:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p2
")})));
end AttributeBindingExpTest5_Err;

model IncidenceTest1

 Real x(start=1);
 Real y;
 input Real u;
equation
 der(x) = -x + u;
 y = x^2;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="IncidenceTest1",
			methodName="incidence",
			description="Test computation of incidence information",
			methodResult="
Incidence:
 eq 0: der(x) 
 eq 1: y 
")})));
end IncidenceTest1;


model IncidenceTest2
 Real x(start=1);
 Real y,z;
 input Real u;
equation
 z+der(x) = -sin(x) + u;
 y = x^2;
 z = 4;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="IncidenceTest2",
			description="Test computation of incidence information",
			methodName="incidence",
			methodResult="
Incidence:
 eq 0: der(x) 
 eq 1: y 
")})));
end IncidenceTest2;

model IncidenceTest3

 Real x[2](each start=1);
 Real y;
 input Real u;

 parameter Real A[2,2] = {{-1,0},{1,-1}};
 parameter Real B[2] = {1,2};
 parameter Real C[2] = {1,-1};
 parameter Real D = 0;
equation
 der(x) = A*x+B*u;
 y = C*x + D*u;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="IncidenceTest3",
			methodName="incidence",
			description="Test computation of incidence information",
			methodResult="
Incidence:
 eq 0: der(x[1]) 
 eq 1: der(x[2]) 
 eq 2: y 
")})));
end IncidenceTest3;

model DiffsAndDersTest1

 Real x[2](each start=1);
 Real y;
 input Real u;

 parameter Real A[2,2] = {{-1,0},{1,-1}};
 parameter Real B[2] = {1,2};
 parameter Real C[2] = {1,-1};
 parameter Real D = 0;
equation
 der(x) = A*x+B*u;
 y = C*x + D*u;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="DiffsAndDersTest1",
			methodName="dersAndDiffs",
			description="Test that derivatives and differentiated variables can be cross referenced",
			methodResult="
Derivatives and differentiated variables:
 der(x[1]), x[1]
 der(x[2]), x[2]
Differentiated variables and derivatives:
 x[1], der(x[1])
 x[2], der(x[2])
")})));
end DiffsAndDersTest1;

  model InitialEqTest1
    Real x1(start=1);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest1",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest1
 Real x1(start = 1);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest1;
")})));
  end InitialEqTest1;

  model InitialEqTest2

    Real v1;
    Real v2;
    Real v3;
    Real v4;
    Real v5;
    Real v6;
    Real v7;
    Real v8;
    Real v9;	
    Real v10;	
  equation
    v1 + v2 + v3 + v4 + v5 = 1;
    v1 + v2 + v3 + v4 + v6 = 1;
    v1 + v2 + v3 + v4 = 1;
    v1 + v2 + v3 + v5 = 1;
    v5 + v6 + v8 + v7 + v9 = 1;
    v5 + v6 + v8 = 0;
    v1 = 1;
    v2 = 1;
    v9 + v10 = 1;
    v10 = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEqTest2",
            description="Test algorithm for adding additional initial equations.",
            flatModel="
fclass TransformCanonicalTests.InitialEqTest2
 constant Real v1 = 1;
 Real v3;
 Real v4;
 Real v6;
 Real v7;
 Real v8;
 constant Real v9 = 0.0;
equation
 2.0 + v3 + v4 + v6 = 1;
 0 = v6;
 0 = v4;
 v6 + v6 + v8 + v7 = 1;
 0 = v7 + -1;
 end TransformCanonicalTests.InitialEqTest2;
")})));
  end InitialEqTest2;

  model InitialEqTest3

    Real x1(start=1,fixed=true);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest3",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest3
 Real x1(start = 1,fixed = true);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest3;
")})));
  end InitialEqTest3;

  model InitialEqTest4
    Real x1(start=1,fixed=true);
    Real x2(start=2,fixed=true);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest4",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest4
 Real x1(start = 1,fixed = true);
 Real x2(start = 2,fixed = true);
 Real y1;
 Real y2;
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest4;
")})));
  end InitialEqTest4;

  model InitialEqTest5
    Real x1(start=1);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;
   initial equation
    der(x1) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest5",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest5
 Real x1(start = 1);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 der(x1) = 0;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest5;
")})));
  end InitialEqTest5;

  model InitialEqTest6
    Real x1(start=1);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;
   initial equation
    der(x1) = 0;
    y2 = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest6",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest6
 Real x1(start = 1);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 der(x1) = 0;
 y2 = 0;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest6;
")})));
  end InitialEqTest6;

  function f1
    input Real x;
    input Real y;
    output Real w;
    output Real z;
  algorithm
   w := x;
   z := y;
  end f1;

  model InitialEqTest7
    Real x, y;
  equation
    (x,y) = f1(1,2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest7",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest7
 constant Real x = 1;
 constant Real y = 2;
end TransformCanonicalTests.InitialEqTest7;
")})));
  end InitialEqTest7;

  model InitialEqTest8
    Real x, y;
  equation
    der(x) = -x;
    der(y) = -y;
  initial equation
    (x,y) = f1(1,2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest8",
			inline_functions="none",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest8
 Real x;
 Real y;
initial equation 
 (x, y) = TransformCanonicalTests.f1(1, 2);
equation
 der(x) = - x;
 der(y) = - y;

public
 function TransformCanonicalTests.f1
  input Real x;
  input Real y;
  output Real w;
  output Real z;
 algorithm
  w := x;
  z := y;
  return;
 end TransformCanonicalTests.f1;

end TransformCanonicalTests.InitialEqTest8;
")})));
  end InitialEqTest8;

  function f2
    input Real x[3];
    input Real y[4];
    output Real w[3];
    output Real z[4];
  algorithm
   w := x;
   z := y;
  end f2;

  model InitialEqTest9
    Real x[3], y[4];
  equation
    (x,y) = f2(ones(3),ones(4));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest9",
			description="Test algorithm for adding additional initial equations.",
            variability_propagation=false,
            inline_functions="none",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest9
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
equation
 ({x[1], x[2], x[3]}, {y[1], y[2], y[3], y[4]}) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});

public
 function TransformCanonicalTests.f2
  input Real[:] x;
  input Real[:] y;
  output Real[:] w;
  output Real[:] z;
 algorithm
  init w as Real[3];
  init z as Real[4];
  for i1 in 1:3 loop
   w[i1] := x[i1];
  end for;
  for i1 in 1:4 loop
   z[i1] := y[i1];
  end for;
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest9;
")})));
  end InitialEqTest9;

  model InitialEqTest10
    Real x[3], y[4];
  initial equation
    (x,y) = f2(ones(3),ones(4));
  equation
    der(x) = -x;
    der(y) = -y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest10",
			inline_functions="none",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest10
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
initial equation
 ({x[1], x[2], x[3]}, {y[1], y[2], y[3], y[4]}) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
 der(x[3]) = - x[3];
 der(y[1]) = - y[1];
 der(y[2]) = - y[2];
 der(y[3]) = - y[3];
 der(y[4]) = - y[4];

public
 function TransformCanonicalTests.f2
  input Real[:] x;
  input Real[:] y;
  output Real[:] w;
  output Real[:] z;
 algorithm
  init w as Real[3];
  init z as Real[4];
  for i1 in 1:3 loop
   w[i1] := x[i1];
  end for;
  for i1 in 1:4 loop
   z[i1] := y[i1];
  end for;
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest10;
")})));
  end InitialEqTest10;

  model InitialEqTest11
    Real x[3], y[4];
  initial equation
    (x,) = f2(ones(3),ones(4));
  equation
    der(x) = -x;
    (,y) = f2(ones(3),ones(4));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest11",
			inline_functions="none",
			description="Test algorithm for adding additional initial equations.",
            variability_propagation=false,
			flatModel="
fclass TransformCanonicalTests.InitialEqTest11
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
initial equation
 ({x[1], x[2], x[3]}, ) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
 der(x[3]) = - x[3];
 (, {y[1], y[2], y[3], y[4]}) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});

public
 function TransformCanonicalTests.f2
  input Real[:] x;
  input Real[:] y;
  output Real[:] w;
  output Real[:] z;
 algorithm
  init w as Real[3];
  init z as Real[4];
  for i1 in 1:3 loop
   w[i1] := x[i1];
  end for;
  for i1 in 1:4 loop
   z[i1] := y[i1];
  end for;
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest11;
")})));
  end InitialEqTest11;

  model InitialEqTest12
    Real x[3](each start=3), y[4];
  equation
    der(x) = -x;
    (,y) = f2(ones(3),ones(4));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest12",
			description="Test algorithm for adding additional initial equations.",
            variability_propagation=false,
            inline_functions="none",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest12
 Real x[1](start = 3);
 Real x[2](start = 3);
 Real x[3](start = 3);
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
initial equation
 x[1] = 3;
 x[2] = 3;
 x[3] = 3;
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
 der(x[3]) = - x[3];
 (, {y[1], y[2], y[3], y[4]}) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});

public
 function TransformCanonicalTests.f2
  input Real[:] x;
  input Real[:] y;
  output Real[:] w;
  output Real[:] z;
 algorithm
  init w as Real[3];
  init z as Real[4];
  for i1 in 1:3 loop
   w[i1] := x[i1];
  end for;
  for i1 in 1:4 loop
   z[i1] := y[i1];
  end for;
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest12;
")})));
  end InitialEqTest12;

  model InitialEqTest13
    Real x1 (start=1);
    Real x2 (start=2);
  equation
    der(x1) = -x1;
    der(x2) = x1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest13",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest13
 Real x1(start = 1);
 Real x2(start = 2);
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = - x1;
 der(x2) = x1;
end TransformCanonicalTests.InitialEqTest13;
")})));
  end InitialEqTest13;

  model InitialEqTest14
  model M
    Real t(start=0);
    discrete Real x1 (start=1,fixed=true);
    discrete Boolean b1 (start=false,fixed=true);
    input Boolean ub1;
    discrete Integer i1 (start=4,fixed=true);
    input Integer ui1;
    discrete Real x2 (start=2);
  equation
    der(t) = 1;
    when time>1 then
      b1 = true;
      i1 = 3;
      x1 = pre(x1) + 1;
      x2 = pre(x2) + 1;
    end when;
  end M;
  input Boolean ub1;
  input Integer ui1;
  M m(ub1=ub1,ui1=ui1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest14",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest14
 discrete input Boolean ub1;
 discrete input Integer ui1;
 Real m.t(start = 0);
 discrete Real m.x1(start = 1,fixed = true);
 discrete Boolean m.b1(start = false,fixed = true);
 discrete Boolean m.ub1;
 discrete Integer m.i1(start = 4,fixed = true);
 discrete Integer m.ui1;
 discrete Real m.x2(start = 2);
 discrete Boolean temp_1;
initial equation 
 pre(m.x1) = 1;
 pre(m.b1) = false;
 pre(m.i1) = 4;
 m.t = 0;
 pre(m.x2) = 2;
 pre(m.ui1) = 0;
 pre(m.ub1) = false;
 pre(temp_1) = false;
equation
 der(m.t) = 1;
 temp_1 = time > 1;
 m.b1 = if temp_1 and not pre(temp_1) then true else pre(m.b1);
 m.i1 = if temp_1 and not pre(temp_1) then 3 else pre(m.i1);
 m.x1 = if temp_1 and not pre(temp_1) then pre(m.x1) + 1 else pre(m.x1);
 m.x2 = if temp_1 and not pre(temp_1) then pre(m.x2) + 1 else pre(m.x2);
 m.ub1 = ub1;
 m.ui1 = ui1;
end TransformCanonicalTests.InitialEqTest14;
")})));
  end InitialEqTest14;

/*
  model InitialEqTest15
  function F
    input Integer x1;
    input Integer x2;
    output Integer y1;
    output Integer y2;
  algorithm
    y1 := 2*x1;
    y2 := 3*x2;
  end F;

  model M
    Real t(start=0);
    discrete Real x1 (start=1,fixed=true);
    discrete Boolean b1 (start=false,fixed=true);
    discrete input Boolean ub1;
    discrete Integer i1 (start=4,fixed=true);
    discrete Integer i2 (start=4);
    discrete Integer i3 (start=4);
    discrete input Integer ui1;
    discrete Real x2 (start=2);
  equation
    der(t) = 1;
    when time>1 then
      b1 = true;
      i1 = 3;
      x1 = pre(x1) + 1;
      x2 = pre(x2) + 1;
      (i2,i3) = F(pre(i1)+1,pre(i2)+1);
    end when;
  end M;
  discrete input Boolean ub1;
  discrete input Integer ui1;
  M m(ub1=ub1,ui1=ui1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest15",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
")})));
  end InitialEqTest15;
*/


model InitialEqTest16
    parameter Boolean a = false;
    Real b(start = 1);
equation
    if a then
        der(b) = 2;
    else
        b = 1;
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest16",
			description="When adding initial equations for states, discount der() in dead branches",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.InitialEqTest16
 structural parameter Boolean a = false /* false */;
 constant Real b(start = 1) = 1;
end TransformCanonicalTests.InitialEqTest16;
")})));
end InitialEqTest16;

model InitialEqTest17
	type A = enumeration(a, b);
	A x = if time < 2 then A.a else A.b;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest17",
			description="Tests so that initial equations are added propperly for enum types",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest17
 discrete TransformCanonicalTests.InitialEqTest17.A x;
initial equation 
 pre(x) = TransformCanonicalTests.InitialEqTest17.A.a;
equation
 x = if time < 2 then TransformCanonicalTests.InitialEqTest17.A.a else TransformCanonicalTests.InitialEqTest17.A.b;

public
 type TransformCanonicalTests.InitialEqTest17.A = enumeration(a, b);

end TransformCanonicalTests.InitialEqTest17;
")})));
end InitialEqTest17;

model InitialEqTest18
    parameter Boolean p = true;
initial algorithm
    assert(p, "p should not be false");

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEqTest18",
            description="Test equation couting when initial system contains assert",
            flatModel="
fclass TransformCanonicalTests.InitialEqTest18
 parameter Boolean p = true /* true */;
initial equation 
 algorithm
  assert(p, \"p should not be false\");
;
end TransformCanonicalTests.InitialEqTest18;
")})));
end InitialEqTest18;

model InitialEqTest19
    parameter Boolean p = true;
initial equation
    assert(p, "p should not be false");

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEqTest19",
            description="Test equation couting when initial system contains assert",
            flatModel="
fclass TransformCanonicalTests.InitialEqTest19
 parameter Boolean p = true /* true */;
initial equation 
 assert(p, \"p should not be false\");
end TransformCanonicalTests.InitialEqTest19;
")})));
end InitialEqTest19;

model InitialEqTest20
    discrete Integer i(start=0, fixed=true);
    discrete Real t;
algorithm
    when {initial(), time > 1+t} then
        t := time + 1;
    end when;
    i := integer(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEqTest20",
            description="Test BiPGraph matching prioritazion for discrete variables (pre variables should be unmatched)",
            flatModel="
fclass TransformCanonicalTests.InitialEqTest20
 discrete Integer i(start = 0,fixed = true);
 discrete Real t;
 discrete Integer temp_1;
 Real _eventIndicator_1;
 discrete Boolean temp_2;
initial equation
 pre(temp_1) = 0;
 pre(i) = 0;
 pre(t) = 0.0;
 pre(temp_2) = false;
algorithm
 _eventIndicator_1 := time - (1 + t);
 temp_2 := time > 1 + t;
 if initial() or temp_2 and not pre(temp_2) then
  t := time + 1;
 end if;
 temp_1 := if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
 i := temp_1;
end TransformCanonicalTests.InitialEqTest20;
")})));
end InitialEqTest20;

model ParameterDerivativeTest
 Real x(start=1);
 Real y;
 parameter Real p = 2;
equation
 y = der(x) + der(p);
 x = p;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ParameterDerivativeTest",
			description="Test that derivatives of parameters are translated into zeros.",
			flatModel="
fclass TransformCanonicalTests.ParameterDerivativeTest
 parameter Real x(start = 1);
 constant Real y = 0.0;
 parameter Real p = 2 /* 2 */;
parameter equation
 x = p;
end TransformCanonicalTests.ParameterDerivativeTest;
")})));
end ParameterDerivativeTest;

model WhenEqu15
	discrete Real x[3];
        Real z[3];
equation
	der(z) = z .* { 0.1, 0.2, 0.3 };
	when { z[i] > 2 for i in 1:3 } then
		x = 1:3;
	elsewhen { z[i] < 0 for i in 1:3 } then
		x = 4:6;
	elsewhen sum(z) > 4.5 then
		x = 7:9;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="WhenEqu15",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu15
 discrete Real x[3];
 Real z[3];
equation
 der(z[1:3]) = z[1:3] .* {0.1, 0.2, 0.3};
 when {z[1] > 2, z[2] > 2, z[3] > 2} then
  x[1:3] = 1:3;
 elsewhen {z[1] < 0, z[2] < 0, z[3] < 0} then
  x[1:3] = 4:6;
 elsewhen sum(z[1:3]) > 4.5 then
  x[1:3] = 7:9;
 end when;
end TransformCanonicalTests.WhenEqu15;
")})));
end WhenEqu15;

model WhenEqu1
    discrete Real x[3];
        Real z[3];
equation
    der(z) = z .* { 0.1, 0.2, 0.3 };
    when { z[i] > 2 for i in 1:3 } then
        x = 1:3;
    elsewhen { z[i] < 0 for i in 1:3 } then
        x = 4:6;
    elsewhen sum(z) > 4.5 then
        x = 7:9;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu1",
            description="Basic test of when equations",
            equation_sorting=true,
            flatModel="
fclass TransformCanonicalTests.WhenEqu1
 discrete Real x[1];
 discrete Real x[2];
 discrete Real x[3];
 Real z[1];
 Real z[2];
 Real z[3];
 discrete Boolean temp_1;
 discrete Boolean temp_2;
 discrete Boolean temp_3;
 discrete Boolean temp_4;
 discrete Boolean temp_5;
 discrete Boolean temp_6;
 discrete Boolean temp_7;
initial equation 
 z[1] = 0.0;
 z[2] = 0.0;
 z[3] = 0.0;
 pre(x[1]) = 0.0;
 pre(x[2]) = 0.0;
 pre(x[3]) = 0.0;
 pre(temp_1) = false;
 pre(temp_2) = false;
 pre(temp_3) = false;
 pre(temp_4) = false;
 pre(temp_5) = false;
 pre(temp_6) = false;
 pre(temp_7) = false;
equation
 der(z[1]) = z[1] .* 0.1;
 der(z[2]) = z[2] .* 0.2;
 der(z[3]) = z[3] .* 0.3;
 temp_1 = z[1] > 2;
 temp_2 = z[2] > 2;
 temp_3 = z[3] > 2;
 temp_4 = z[1] < 0;
 temp_5 = z[2] < 0;
 temp_6 = z[3] < 0;
 temp_7 = z[1] + z[2] + z[3] > 4.5;
 x[1] = if temp_1 and not pre(temp_1) or temp_2 and not pre(temp_2) or temp_3 and not pre(temp_3) then 1 elseif temp_4 and not pre(temp_4) or temp_5 and not pre(temp_5) or temp_6 and not pre(temp_6) then 4 elseif temp_7 and not pre(temp_7) then 7 else pre(x[1]);
 x[2] = if temp_1 and not pre(temp_1) or temp_2 and not pre(temp_2) or temp_3 and not pre(temp_3) then 2 elseif temp_4 and not pre(temp_4) or temp_5 and not pre(temp_5) or temp_6 and not pre(temp_6) then 5 elseif temp_7 and not pre(temp_7) then 8 else pre(x[2]);
 x[3] = if temp_1 and not pre(temp_1) or temp_2 and not pre(temp_2) or temp_3 and not pre(temp_3) then 3 elseif temp_4 and not pre(temp_4) or temp_5 and not pre(temp_5) or temp_6 and not pre(temp_6) then 6 elseif temp_7 and not pre(temp_7) then 9 else pre(x[3]);
end TransformCanonicalTests.WhenEqu1;
")})));
end WhenEqu1;

model WhenEqu2
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true); 
equation
der(xx) = -x; 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when x > 2 then 
z = false; 
end when; 
when (time>1 and time<1.1) or  (time>2 and time<2.1) or  (time>3 and time<3.1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu2",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu2
 Real xx(start = 2);
 discrete Real x;
 discrete Real y;
 discrete Boolean w(start = true);
 discrete Boolean v(start = true);
 discrete Boolean z(start = true);
 discrete Boolean temp_1;
 discrete Boolean temp_2;
 discrete Boolean temp_3;
 discrete Boolean temp_4;
initial equation 
 xx = 2;
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(w) = true;
 pre(v) = true;
 pre(z) = true;
 pre(temp_1) = false;
 pre(temp_2) = false;
 pre(temp_3) = false;
 pre(temp_4) = false;
equation
 der(xx) = - x;
 temp_1 = y > 2 and pre(z);
 w = if temp_1 and not pre(temp_1) then false else pre(w);
 temp_2 = y > 2 and z;
 v = if temp_2 and not pre(temp_2) then false else pre(v);
 temp_3 = x > 2;
 z = if temp_3 and not pre(temp_3) then false else pre(z);
 temp_4 = time > 1 and time < 1.1 or time > 2 and time < 2.1 or time > 3 and time < 3.1;
 x = if temp_4 and not pre(temp_4) then pre(x) + 1.1 else pre(x);
 y = if temp_4 and not pre(temp_4) then pre(y) + 1.1 else pre(y);
end TransformCanonicalTests.WhenEqu2;
			
")})));
end WhenEqu2;

model WhenEqu3
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true);
discrete Boolean b1; 
equation
der(xx) = -x; 
when b1 and pre(z) then 
w = false; 
end when; 
when b1 and z then 
v = false; 
end when; 
when b1 then 
z = false; 
end when; 
when (time>1 and time<1.1) or  (time>2 and time<2.1) or  (time>3 and time<3.1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 
b1 = y>2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu3",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu3
 Real xx(start = 2);
 discrete Real x;
 discrete Real y;
 discrete Boolean w(start = true);
 discrete Boolean v(start = true);
 discrete Boolean z(start = true);
 discrete Boolean b1;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
 discrete Boolean temp_3;
initial equation 
 xx = 2;
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(w) = true;
 pre(v) = true;
 pre(z) = true;
 pre(b1) = false;
 pre(temp_1) = false;
 pre(temp_2) = false;
 pre(temp_3) = false;
equation
 der(xx) = - x;
 temp_1 = b1 and pre(z);
 w = if temp_1 and not pre(temp_1) then false else pre(w);
 temp_2 = b1 and z;
 v = if temp_2 and not pre(temp_2) then false else pre(v);
 z = if b1 and not pre(b1) then false else pre(z);
 temp_3 = time > 1 and time < 1.1 or time > 2 and time < 2.1 or time > 3 and time < 3.1;
 x = if temp_3 and not pre(temp_3) then pre(x) + 1.1 else pre(x);
 y = if temp_3 and not pre(temp_3) then pre(y) + 1.1 else pre(y);
 b1 = y > 2;
end TransformCanonicalTests.WhenEqu3;
			
")})));
end WhenEqu3;

model WhenEqu4
  discrete Real x,y,z,v;
  Real t;
equation
  der(t) = 1;
  when time>3 then 
    x = 1;
    y = 2;
    z = 3;
    v = 4;
  elsewhen time>4 then
    v = 1;
    z = 2;
    y = 3;
    x = 4;
  end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu4",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu4
 discrete Real x;
 discrete Real y;
 discrete Real z;
 discrete Real v;
 Real t;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
initial equation 
 t = 0.0;
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(z) = 0.0;
 pre(v) = 0.0;
 pre(temp_1) = false;
 pre(temp_2) = false;
equation
 der(t) = 1;
 temp_1 = time > 3;
 temp_2 = time > 4;
 v = if temp_1 and not pre(temp_1) then 4 elseif temp_2 and not pre(temp_2) then 1 else pre(v);
 x = if temp_1 and not pre(temp_1) then 1 elseif temp_2 and not pre(temp_2) then 4 else pre(x);
 y = if temp_1 and not pre(temp_1) then 2 elseif temp_2 and not pre(temp_2) then 3 else pre(y);
 z = if temp_1 and not pre(temp_1) then 3 elseif temp_2 and not pre(temp_2) then 2 else pre(z);
end TransformCanonicalTests.WhenEqu4;
			
")})));
end WhenEqu4;


model WhenEqu45
  type E = enumeration(a,b,c);
  discrete E e (start=E.b);
  Real t(start=0);
equation
  der(t) = 1;
  when time>1 then
    e = E.c;
  end when;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu45",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu45
 discrete TransformCanonicalTests.WhenEqu45.E e(start = TransformCanonicalTests.WhenEqu45.E.b);
 Real t(start = 0);
 discrete Boolean temp_1;
initial equation 
 t = 0;
 pre(e) = TransformCanonicalTests.WhenEqu45.E.b;
 pre(temp_1) = false;
equation
 der(t) = 1;
 temp_1 = time > 1;
 e = if temp_1 and not pre(temp_1) then TransformCanonicalTests.WhenEqu45.E.c else pre(e);

public
 type TransformCanonicalTests.WhenEqu45.E = enumeration(a, b, c);

end TransformCanonicalTests.WhenEqu45;
			
")})));
end WhenEqu45;

model WhenEqu5 

Real x(start = 1); 
discrete Real a(start = 1.0); 
discrete Boolean z(start = false); 
discrete Boolean y(start = false); 
discrete Boolean h1,h2; 
equation 
der(x) = a * x; 
h1 = x >= 2; 
h2 = der(x) >= 4; 
when h1 then 
y = true; 
end when; 
when y then 
a = 2; 
end when; 
when h2 then 
z = true; 
end when; 

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu5",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu5
 Real x(start = 1);
 discrete Real a(start = 1.0);
 discrete Boolean z(start = false);
 discrete Boolean y(start = false);
 discrete Boolean h1;
 discrete Boolean h2;
initial equation 
 x = 1;
 pre(a) = 1.0;
 pre(z) = false;
 pre(y) = false;
 pre(h1) = false;
 pre(h2) = false;
equation
 der(x) = a * x;
 h1 = x >= 2;
 h2 = der(x) >= 4;
 y = if h1 and not pre(h1) then true else pre(y);
 a = if y and not pre(y) then 2 else pre(a);
 z = if h2 and not pre(h2) then true else pre(z);
end TransformCanonicalTests.WhenEqu5;
			
")})));
end WhenEqu5; 

model WhenEqu7 

 discrete Real x(start=0);
 Real dummy;
equation
 der(dummy) = 0;
 when dummy>-1 then
   x = pre(x) + 1;
 end when;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu7",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu7
 discrete Real x(start = 0);
 Real dummy;
 discrete Boolean temp_1;
initial equation 
 dummy = 0.0;
 pre(x) = 0;
 pre(temp_1) = false;
equation
 der(dummy) = 0;
 temp_1 = dummy > -1;
 x = if temp_1 and not pre(temp_1) then pre(x) + 1 else pre(x);
end TransformCanonicalTests.WhenEqu7;
			
")})));
end WhenEqu7; 

model WhenEqu8 

 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when sample(0,2/3) then
   y = pre(y) + 1;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu8",
            description="Basic test of when equations",
            flatModel="
fclass TransformCanonicalTests.WhenEqu8
 discrete Real x;
 discrete Real y;
 Real dummy;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
 discrete Boolean temp_2;
 discrete Integer _sampleItr_2;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time / 0.6666666666666666);
 pre(temp_2) = false;
 _sampleItr_2 = if time < 0 then 0 else ceil(time / 0.3333333333333333);
 dummy = 0.0;
 pre(x) = 0.0;
 pre(y) = 0.0;
equation
 der(dummy) = 0;
 x = if temp_2 and not pre(temp_2) then pre(x) + 1 else pre(x);
 y = if temp_1 and not pre(temp_1) then pre(y) + 1 else pre(y);
 temp_1 = not initial() and time >= pre(_sampleItr_1) * 0.6666666666666666;
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < (pre(_sampleItr_1) + 1) * (2 / 3), \"Too long time steps relative to sample interval.\");
 temp_2 = not initial() and time >= pre(_sampleItr_2) * 0.3333333333333333;
 _sampleItr_2 = if temp_2 and not pre(temp_2) then pre(_sampleItr_2) + 1 else pre(_sampleItr_2);
 assert(time < (pre(_sampleItr_2) + 1) * (1 / 3), \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.WhenEqu8;
")})));
end WhenEqu8; 

model WhenEqu9 

 Real x,ref;
 discrete Real I;
 discrete Real u;

 parameter Real K = 1;
 parameter Real Ti = 0.1;
 parameter Real h = 0.05;

equation
 der(x) = -x + u;
 when sample(0,h) then
   I = pre(I) + h*(ref-x);
   u = K*(ref-x) + 1/Ti*I;
 end when;
 ref = if time <1 then 0 else 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu9",
            description="Basic test of when equations",
            flatModel="
fclass TransformCanonicalTests.WhenEqu9
 Real x;
 Real ref;
 discrete Real I;
 discrete Real u;
 parameter Real K = 1 /* 1 */;
 parameter Real Ti = 0.1 /* 0.1 */;
 parameter Real h = 0.05 /* 0.05 */;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time / h);
 x = 0.0;
 pre(I) = 0.0;
 pre(u) = 0.0;
equation
 der(x) = - x + u;
 I = if temp_1 and not pre(temp_1) then pre(I) + h * (ref - x) else pre(I);
 u = if temp_1 and not pre(temp_1) then K * (ref - x) + 1 / Ti * I else pre(u);
 ref = if time < 1 then 0 else 1;
 temp_1 = not initial() and time >= pre(_sampleItr_1) * h;
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < (pre(_sampleItr_1) + 1) * h, \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.WhenEqu9;
")})));
end WhenEqu9; 

model WhenEqu10

 discrete Boolean sampleTrigger;
 Real x_p(start=1, fixed=true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
initial equation
 x_c = pre(x_c);     
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {initial(),sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu10",
            description="Basic test of when equations",
            flatModel="
fclass TransformCanonicalTests.WhenEqu10
 discrete Boolean sampleTrigger;
 Real x_p(start = 1,fixed = true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1 /* -1 */;
 parameter Real b_p = 1 /* 1 */;
 parameter Real c_p = 1 /* 1 */;
 parameter Real a_c = 0.8 /* 0.8 */;
 parameter Real b_c = 1 /* 1 */;
 parameter Real c_c = 1 /* 1 */;
 parameter Real h = 0.1 /* 0.1 */;
 discrete Integer _sampleItr_1;
initial equation 
 x_c = pre(x_c);
 pre(sampleTrigger) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time / h);
 x_p = 1;
 pre(u_c) = 0.0;
equation
 der(x_p) = a_p * x_p + b_p * u_p;
 u_p = c_c * x_c;
 u_c = if initial() or sampleTrigger and not pre(sampleTrigger) then c_p * x_p else pre(u_c);
 x_c = if initial() or sampleTrigger and not pre(sampleTrigger) then a_c * pre(x_c) + b_c * u_c else pre(x_c);
 sampleTrigger = not initial() and time >= pre(_sampleItr_1) * h;
 _sampleItr_1 = if sampleTrigger and not pre(sampleTrigger) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < (pre(_sampleItr_1) + 1) * h, \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.WhenEqu10;
")})));
end WhenEqu10;

model WhenEqu11    
        
 discrete Boolean sampleTrigger;
 Real x_p(start=1);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
 discrete Boolean atInit = true and initial();
initial equation
 x_c = pre(x_c);     
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {atInit,sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu11",
            description="Basic test of when equations",
            flatModel="
fclass TransformCanonicalTests.WhenEqu11
 discrete Boolean sampleTrigger;
 Real x_p(start = 1);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1 /* -1 */;
 parameter Real b_p = 1 /* 1 */;
 parameter Real c_p = 1 /* 1 */;
 parameter Real a_c = 0.8 /* 0.8 */;
 parameter Real b_c = 1 /* 1 */;
 parameter Real c_c = 1 /* 1 */;
 parameter Real h = 0.1 /* 0.1 */;
 discrete Boolean atInit;
 discrete Integer _sampleItr_1;
initial equation 
 x_c = pre(x_c);
 pre(sampleTrigger) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time / h);
 x_p = 1;
 pre(x_c) = 0.0;
 pre(u_c) = 0.0;
 pre(atInit) = false;
equation
 der(x_p) = a_p * x_p + b_p * u_p;
 u_p = c_c * x_c;
 u_c = if atInit and not pre(atInit) or sampleTrigger and not pre(sampleTrigger) then c_p * x_p else pre(u_c);
 x_c = if atInit and not pre(atInit) or sampleTrigger and not pre(sampleTrigger) then a_c * pre(x_c) + b_c * u_c else pre(x_c);
 atInit = true and initial();
 sampleTrigger = not initial() and time >= pre(_sampleItr_1) * h;
 _sampleItr_1 = if sampleTrigger and not pre(sampleTrigger) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < (pre(_sampleItr_1) + 1) * h, \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.WhenEqu11;
")})));
end WhenEqu11;

model WhenEqu12
    
    function F
        input Real x;
        output Real y1;
        output Real y2;
    algorithm
        y1 := 1;
        y2 := 2;
    end F;
    Real x,y;
    equation
    when sample(0,1) then
        (x,y) = F(time);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu12",
            description="Basic test of when equations",
            inline_functions="none",
            flatModel="
fclass TransformCanonicalTests.WhenEqu12
 discrete Real x;
 discrete Real y;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time);
 pre(x) = 0.0;
 pre(y) = 0.0;
equation
 if temp_1 and not pre(temp_1) then
  (x, y) = TransformCanonicalTests.WhenEqu12.F(time);
 else
  x = pre(x);
  y = pre(y);
 end if;
 temp_1 = not initial() and time >= pre(_sampleItr_1);
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\");

public
 function TransformCanonicalTests.WhenEqu12.F
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := 1;
  y2 := 2;
  return;
 end TransformCanonicalTests.WhenEqu12.F;

end TransformCanonicalTests.WhenEqu12;
")})));
end WhenEqu12;

model WhenEqu13
Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
initial equation
 v1 = if 0<=0 then 0 else 1;
 v2 = if 0<0 then 0 else 1;
 v3 = if 0>=0 then 0 else 1;
 v4 = if 0>0 then 0 else 1;
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = if y<=0 then 0 else 1;
 der(v2) = if y<0 then 0 else 1;
 der(v3) = if y>=0 then 0 else 1;
 der(v4) = if y>0 then 0 else 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu13",
            description="Basic test of when equations",
            flatModel="
fclass TransformCanonicalTests.WhenEqu13
 Real v1(start = -1);
 Real v2(start = -1);
 Real v3(start = -1);
 Real v4(start = -1);
 discrete Real y(start = 1);
 discrete Integer i(start = 0);
 discrete Boolean up(start = true);
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
initial equation 
 v1 = 0;
 v2 = 1;
 v3 = 0;
 v4 = 1;
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0.1 then 0 else ceil(time - 0.1);
 pre(y) = 1;
 pre(i) = 0;
 pre(up) = true;
equation
 i = if temp_1 and not pre(temp_1) then if up then pre(i) + 1 else pre(i) - 1 else pre(i);
 up = if temp_1 and not pre(temp_1) then if pre(i) == 2 then false elseif pre(i) == -2 then true else pre(up) else pre(up);
 y = if temp_1 and not pre(temp_1) then i else pre(y);
 der(v1) = if y <= 0 then 0 else 1;
 der(v2) = if y < 0 then 0 else 1;
 der(v3) = if y >= 0 then 0 else 1;
 der(v4) = if y > 0 then 0 else 1;
 temp_1 = not initial() and time >= 0.1 + pre(_sampleItr_1);
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < 0.1 + (pre(_sampleItr_1) + 1), \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.WhenEqu13;
")})));
end WhenEqu13;
model WhenEqu14
    Boolean a;
initial equation
    pre(a) = false;
    a = if time > 1 then true else false;
equation
    when time > 2 then
        a = true;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="WhenEqu14",
            description="Test of when equation and initial equation assigning to pre variable",
            methodName="printDAEInitBLT",
            methodResult="
--- Solved equation ---
temp_1 := time > 2

--- Solved equation ---
pre(a) := false

--- Solved equation ---
a := if time > 1 then true else false

--- Solved equation ---
pre(temp_1) := false
-------------------------------
")})));
end WhenEqu14;

model WhenEqu16
    Boolean a;
initial equation
    pre(a) = a;
    a = if time > 1 then true else false;
equation
    when time > 2 then
        a = true;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="WhenEqu16",
            description="Test of when equation and initial equation assigning to pre variable",
            methodName="printDAEInitBLT",
            methodResult="
--- Solved equation ---
temp_1 := time > 2

--- Solved equation ---
a := if time > 1 then true else false

--- Solved equation ---
pre(a) := a

--- Solved equation ---
pre(temp_1) := false
-------------------------------
")})));
end WhenEqu16;

model WhenEqu17
    Real a;
    Real b (start = 2);
    Real c;
    Real d;
    Real e;
    Real f;
    Real g;
initial equation
    pre(a) = -1;
    c = 1;
equation
    when time > 2 then
        a = time;
    end when;
    0 = if time > 2 then b + a else b;
    c = der(d) + b + e;
    der(d) * time = 0;
    e = f + time;
    f * g = 0;
    when time > pre(g) then
        g = time + 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="WhenEqu17",
            description="Ensure that the pre propagation equations are inserted in the first init BiPGraph if necessary (e.g. all other matchings for that variables are bad)",
            methodName="printDAEInitBLT",
            methodResult="
--- Solved equation ---
temp_1 := time > 2

--- Solved equation ---
pre(a) := -1

--- Solved equation ---
a := pre(a)

--- Unsolved equation (Block 1) ---
0 = if time > 2 then b + a else b
  Computed variables: b

--- Solved equation ---
c := 1

--- Unsolved equation (Block 2) ---
der(d) * time = 0
  Computed variables: der(d)

--- Solved equation ---
e := c - der(d) - b

--- Solved equation ---
f := e - time

--- Unsolved equation (Block 3) ---
f * g = 0
  Computed variables: g

--- Solved equation ---
pre(g) := g

--- Solved equation ---
temp_2 := time > pre(g)

--- Solved equation ---
d := 0.0

--- Solved equation ---
pre(temp_1) := false

--- Solved equation ---
pre(temp_2) := false
-------------------------------
")})));
end WhenEqu17;

model WhenEqu18
    parameter Real t = 1 annotation(Evaluate=true);
    Real x;
equation
    if t < 1 then
        when time > 1 then
            x = time;
        end when;
    else
        x = time;
    end if;
    
    when time > 1 then
        if t < 1 then
            x = time;
        end if;
    end when;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu18",
            description="Variability of real in disabled when",
            flatModel="
fclass TransformCanonicalTests.WhenEqu18
 eval parameter Real t = 1 /* 1 */;
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
equation
 x = time;
 temp_1 = time > 1;
end TransformCanonicalTests.WhenEqu18;
")})));
end WhenEqu18;

model WhenEqu19
    parameter Real t = 0 annotation(Evaluate=true);
    Real x;
equation
    if t < 1 then
        x = time;
    else
        when time > 1 then
            x = time;
        end when;
    end if;
    
    when time > 1 then
        if t < 1 then
            
        else
            x = time;
        end if;
    end when;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="WhenEqu19",
            description="Variability of real in disabled when",
            flatModel="
fclass TransformCanonicalTests.WhenEqu19
 eval parameter Real t = 0 /* 0 */;
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
equation
 x = time;
 temp_1 = time > 1;
end TransformCanonicalTests.WhenEqu19;
")})));
end WhenEqu19;


model IntialWhenAlgorithm1
    Boolean a;
    Boolean x;
algorithm
    when {time > 2, initial()} then
        a := not pre(a);
        x := not a;
    end when;
end IntialWhenAlgorithm1;

model IfEqu1
	Real x[3];
equation
	if true then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="IfEqu1",
			description="If equations: flattening",
			flatModel="
fclass TransformCanonicalTests.IfEqu1
 Real x[3];
equation
 if true then
  x[1:3] = 1:3;
 elseif true then
  x[1:3] = 4:6;
 else
  x[1:3] = 7:9;
 end if;
end TransformCanonicalTests.IfEqu1;
")})));
end IfEqu1;


model IfEqu2
	Real x[3];
equation
	if true then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu2",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu2
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
end TransformCanonicalTests.IfEqu2;
")})));
end IfEqu2;


model IfEqu3
	Real x[3];
equation
	if false then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu3",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu3
 constant Real x[1] = 4;
 constant Real x[2] = 5;
 constant Real x[3] = 6;
end TransformCanonicalTests.IfEqu3;
")})));
end IfEqu3;


model IfEqu4
	Real x[3];
equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu4",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu4
 constant Real x[1] = 7;
 constant Real x[2] = 8;
 constant Real x[3] = 9;
end TransformCanonicalTests.IfEqu4;
")})));
end IfEqu4;


model IfEqu5
	Real x[3] = 7:9;
equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu5",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu5
 constant Real x[1] = 7;
 constant Real x[2] = 8;
 constant Real x[3] = 9;
end TransformCanonicalTests.IfEqu5;
")})));
end IfEqu5;


model IfEqu6
	Real x[3];
	Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu6",
			description="If equations: scalarization without elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu6
 constant Real x[1] = 4;
 constant Real x[2] = 5;
 constant Real x[3] = 6;
 constant Boolean y[1] = false;
 constant Boolean y[2] = true;
end TransformCanonicalTests.IfEqu6;
")})));
end IfEqu6;


model IfEqu7
	Real x[3];
	Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
    else
	   	x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu7",
			description="If equations: scalarization without elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu7
 constant Real x[1] = 4;
 constant Real x[2] = 5;
 constant Real x[3] = 6;
 constant Boolean y[1] = false;
 constant Boolean y[2] = true;
end TransformCanonicalTests.IfEqu7;
")})));
end IfEqu7;


model IfEqu8
	Real x[3];
	parameter Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
	else
		x = 7:9;
		x[2] = 10;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu8",
			description="If equations: branch elimination with parameter test expressions",
			flatModel="
fclass TransformCanonicalTests.IfEqu8
 constant Real x[1] = 4;
 constant Real x[2] = 5;
 constant Real x[3] = 6;
 structural parameter Boolean y[1] = false /* false */;
 structural parameter Boolean y[2] = true /* true */;
end TransformCanonicalTests.IfEqu8;
")})));
end IfEqu8;


model IfEqu9
    Real x[2];
    Boolean y = time < 3;
equation
    if false then
        x = 1:2;
    elseif y then
        x = 3:4;
    elseif false then
        x = 5:6;
    else
        x = 7:8;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEqu9",
            description="If equations: branch elimination with one test non-parameter",
            flatModel="
fclass TransformCanonicalTests.IfEqu9
 Real x[1];
 Real x[2];
 discrete Boolean y;
initial equation
 pre(y) = false;
equation
 x[1] = if y then 3 else 7;
 x[2] = if y then 4 else 8;
 y = time < 3;
end TransformCanonicalTests.IfEqu9;
")})));
end IfEqu9;


model IfEqu10
    Real x[2];
    Boolean y = time < 3;
equation
    if false then
        x = 1:2;
    elseif y then
        x = 3:4;
    elseif true then
        x = 5:6;
    else
        x = 7:8;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEqu10",
            description="If equations: branch elimination with one test non-parameter",
            flatModel="
fclass TransformCanonicalTests.IfEqu10
 Real x[1];
 Real x[2];
 discrete Boolean y;
initial equation
 pre(y) = false;
equation
 x[1] = if y then 3 else 5;
 x[2] = if y then 4 else 6;
 y = time < 3;
end TransformCanonicalTests.IfEqu10;
")})));
end IfEqu10;


model IfEqu11
    Real x[2];
    Boolean y = time < 3;
equation
    if true then
        x = 1:2;
    elseif y then
        x = 3:4;
    elseif false then
        x = 5:6;
    else
        x = 7:8;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEqu11",
            description="If equations: branch elimination with one test non-parameter",
            flatModel="
fclass TransformCanonicalTests.IfEqu11
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 discrete Boolean y;
initial equation
 pre(y) = false;
equation
 y = time < 3;
end TransformCanonicalTests.IfEqu11;
")})));
end IfEqu11;

  model IfEqu12
	Real x(start=1);
    Real u;
  equation
    if time>=1 then
      u = -1;
    else
      u = 1;
    end if;
    der(x) = -x + u;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu12",
			description="Test of if equations.",
			flatModel="
fclass TransformCanonicalTests.IfEqu12
 Real x(start = 1);
 Real u;
initial equation 
 x = 1;
equation
 u = if time >= 1 then - 1 else 1;
 der(x) = - x + u;
end TransformCanonicalTests.IfEqu12;
")})));
  end IfEqu12;

  model IfEqu13
    Real x(start=1);
    Real u;
  equation
    if time>=1 then
      u = -1;
      der(x) = -3*x + u;
    else
      u = 1;
      der(x) = 3*x + u;
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu13",
			description="Test of if equations.",
			flatModel="
fclass TransformCanonicalTests.IfEqu13
 Real x(start = 1);
 Real u;
initial equation 
 x = 1;
equation
 der(x) = if time >= 1 then -3 * x + u else 3 * x + u;
 u = if time >= 1 then -1 else 1;
end TransformCanonicalTests.IfEqu13;
")})));
  end IfEqu13;

  model IfEqu14
    Real x(start=1);
    Real u;
  equation
    if time>=1 then
      if time >=3then
        u = -1;
        der(x) = -3*x + u;
      else
        u=4;
        der(x) = 0;
      end if;
    else
      u = 1;
      der(x) = 3*x + u;
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu14",
			description="Test of if equations.",
			flatModel="
fclass TransformCanonicalTests.IfEqu14
 Real x(start = 1);
 Real u;
initial equation 
 x = 1;
equation
 der(x) = if time >= 1 then if time >= 3 then -3 * x + u else 0 else 3 * x + u;
 u = if time >= 1 then if time >= 3 then -1 else 4 else 1;
end TransformCanonicalTests.IfEqu14;
")})));
  end IfEqu14;


  model IfEqu15
      Real x;
      Real y;
      Real z1;
      Real z2;
  equation
      if time < 1 then
          y = z2 - 1;
          z1 = 2;
          x = y * y;
          z1 + z2 = x + y;
      elseif time < 3 then
          x = y + 4;
          y = 2;
          z2 = y * x;
          z1 - z2 = x + y;
      else
          z2 = 4 * x;
          x = 4;
          y = x + 2;
          z1 + z2 = x - y;
      end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu15",
			description="If equation with mixed assignment equations and non-assignment equations",
			flatModel="
fclass TransformCanonicalTests.IfEqu15
 Real x;
 Real y;
 Real z1;
 Real z2;
equation
 x = if time < 1 then y * y elseif time < 3 then y + 4 else 4;
 y = if time < 1 then z2 - 1 elseif time < 3 then 2 else x + 2;
 0.0 = if time < 1 then z1 - 2 else z2 - (if time < 3 then y * x else 4 * x);
 0.0 = if time < 1 then z1 + z2 - (x + y) elseif time < 3 then z1 - z2 - (x + y) else z1 + z2 - (x - y);
end TransformCanonicalTests.IfEqu15;
")})));
  end IfEqu15;


  model IfEqu16
      Real x;
      Real y;
      Real z1;
      Real z2;
  equation
      if time < 1 then
          y = z2 - 1;
          z1 = 2;
          x = y * y;
          z1 + z2 = x + y;
      else
          x = 4;
          if time < 3 then
              y = 2;
              z1 = y * x;
          else
              y = x + 2;
              z2 = 4 * x;
          end if;
          z1 + z2 = x - y;
      end if;

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="IfEqu16",
      description="Nested if equations with mixed assignment equations and non-assignment equations",
      flatModel="
fclass TransformCanonicalTests.IfEqu16
 Real x;
 Real y;
 Real z1;
 Real z2;
equation
 x = if time < 1 then y * y else 4;
 y = if time < 1 then z2 - 1 elseif time < 3 then 2 else x + 2;
 0.0 = if time < 1 then z1 - 2 elseif time < 3 then z1 - y * x else z2 - 4 * x;
 0.0 = if time < 1 then z1 + z2 - (x + y) else z1 + z2 - (x - y);
end TransformCanonicalTests.IfEqu16;
")})));
  end IfEqu16;


  model IfEqu17
      function f
          output Real x1 = 1;
          output Real x2 = 2;
	  algorithm
      end f;
      
      Real y1;
      Real y2;
      parameter Boolean p = false; 
  equation
      if p then
          y1 = 3;
          y2 = 3;
      else
          (y1, y2) = f();
      end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu17",
			description="Check that if equations with function call equations are eliminated",
			flatModel="
fclass TransformCanonicalTests.IfEqu17
 constant Real y1 = 1;
 constant Real y2 = 2;
 structural parameter Boolean p = false /* false */;
end TransformCanonicalTests.IfEqu17;
")})));
  end IfEqu17;


  model IfEqu18
    function F
            input Real x;
            output Real a;
            output Real b;
    algorithm
            a := x + 1;
            b := x - 42;
            annotation(Inline = false);
    end F;
    
    Real x,a,b;
equation
    x = time * 23;
    if time > 0.5 then
        (a, b) = F(x);
    else
        (a, x) = F(b);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="IfEqu18",
            description="Check compliance warning for if equations",
            errorMessage="
1 errors found:

Compliance error in flattened model:
  If equations that has non-parameter tests and contains function calls using multiple outputs must assign the same variables in all branches
")})));
  end IfEqu18;

  model IfEqu19
    Real x;
  equation
    when sample(1,0) then
        if time>=3 then
            x = pre(x) + 1;
        else
            x = pre(x) + 5;
        end if;
    end when;
            

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEqu19",
            description="Check that if equations inside when equations are treated correctly.",
            flatModel="
fclass TransformCanonicalTests.IfEqu19
 discrete Real x;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 1 then 0 else ceil((time - 1) / 0);
 pre(x) = 0.0;
equation
 x = if temp_1 and not pre(temp_1) then if time >= 3 then pre(x) + 1 else pre(x) + 5 else pre(x);
 temp_1 = not initial() and time >= 1;
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < 1, \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.IfEqu19;
")})));
  end IfEqu19;

model IfEqu20
	Real x;
initial equation
    if true then
		x = 3;
	end if;
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu20",
			description="Check that parameter if equations are rewritten in initial equation sections.",
			flatModel="
fclass TransformCanonicalTests.IfEqu20
 Real x;
initial equation 
 x = 3;
equation
 der(x) = - x;
end TransformCanonicalTests.IfEqu20;
")})));
end IfEqu20;

model IfEqu21
	Real x;
initial equation
    if  time>=3 then
		x = 3;
	else
		x = 4;
	end if;
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu21",
			description="Check that variable if equations are rewritten in initial equation sections.",
			flatModel="
fclass TransformCanonicalTests.IfEqu21
 Real x;
initial equation 
 x = if time >= 3 then 3 else 4;
equation
 der(x) = - x;
end TransformCanonicalTests.IfEqu21;
")})));
end IfEqu21;

model IfEqu22
  function f
    input Real u[2];
    output Real y[2];
  algorithm
    u:=2*y;
  end f;

  Boolean b = true;
  parameter Integer nX = 2;
  Real x[nX];
  equation
  if b then
    if nX>=0 then
      x = f({1,2});
    end if;
  else
   x = zeros(nX);
  end if;
  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="IfEqu22",
      description="Function call equation generated by scalarization inside if equation",
      flatModel="
fclass TransformCanonicalTests.IfEqu22
 constant Boolean b = true;
 structural parameter Integer nX = 2 /* 2 */;
 Real x[1];
 Real x[2];
equation
 if true then
  ({x[1], x[2]}) = TransformCanonicalTests.IfEqu22.f({1, 2});
 else
  x[1] = 0.0;
  x[2] = 0.0;
 end if;

public
 function TransformCanonicalTests.IfEqu22.f
  input Real[:] u;
  output Real[:] y;
 algorithm
  init y as Real[2];
  for i1 in 1:2 loop
   u[i1] := 2 * y[i1];
  end for;
  return;
 end TransformCanonicalTests.IfEqu22.f;

end TransformCanonicalTests.IfEqu22;
")})));
end IfEqu22;

model IfEqu23
    record R
        Real x;
        Real y;
    end R;
	
    function F
        input Real x;
        input Real y;
        output R r;
    algorithm
        r.x := x;
        r.y := y;
    end F;
	
    Real x=1;
    Real y=2;
    R r;
equation
    if time > 1 then
        r = F(x,y);
    else
        r = F(x+y,y);
    end if;
  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="IfEqu23",
      description="Function call equation generated by scalarization inside else branch of if equation",
      variability_propagation=false,
      inline_functions="none",
       flatModel="
fclass TransformCanonicalTests.IfEqu23
 Real x;
 Real y;
 Real r.x;
 Real r.y;
 Real temp_1.x;
 Real temp_1.y;
 Real temp_2.x;
 Real temp_2.y;
equation
 r.x = if time > 1 then temp_1.x else temp_2.x;
 r.y = if time > 1 then temp_1.y else temp_2.y;
 0.0 = if time > 1 then temp_2.x else temp_1.x;
 0.0 = if time > 1 then temp_2.y else temp_1.y;
 if time > 1 then
  (TransformCanonicalTests.IfEqu23.R(temp_1.x, temp_1.y)) = TransformCanonicalTests.IfEqu23.F(x, y);
 else
  (TransformCanonicalTests.IfEqu23.R(temp_2.x, temp_2.y)) = TransformCanonicalTests.IfEqu23.F(x + y, y);
 end if;
 x = 1;
 y = 2;

public
 function TransformCanonicalTests.IfEqu23.F
  input Real x;
  input Real y;
  output TransformCanonicalTests.IfEqu23.R r;
 algorithm
  r.x := x;
  r.y := y;
  return;
 end TransformCanonicalTests.IfEqu23.F;

 record TransformCanonicalTests.IfEqu23.R
  Real x;
  Real y;
 end TransformCanonicalTests.IfEqu23.R;

end TransformCanonicalTests.IfEqu23;
")})));
end IfEqu23;

model IfEqu24  "Test delay equation"
  parameter Boolean use_delay=false;
  Real x1(start = 1); 
  Real x2(start = 1);
equation
  der(x1) = sin(time);
  if use_delay then
    der(x2) = (x1 - x2) /100;
  else
    0 = x1 - x2 + 2;
  end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu24",
			description="Check correct elimination of if equation branches.",
			flatModel="
fclass TransformCanonicalTests.IfEqu24
 structural parameter Boolean use_delay = false /* false */;
 Real x1(start = 1);
 Real x2(start = 1);
initial equation 
 x1 = 1;
equation
 der(x1) = sin(time);
 0 = x1 - x2 + 2;
end TransformCanonicalTests.IfEqu24;
")})));
end IfEqu24;

model IfEqu25
	function f
		input Real x;
		output Real y;
		external "C" y = sin(x);
	end f;
	
	Real x;
	Real y;
equation
	if f(2) > 0 then
		x = time;
    else
        x = 2;
	end if;
	y = if f(2) > 0 then x else x * x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu25",
			description="Check that if elimination handles tests with external functions",
            common_subexp_elim=true,
			flatModel="
fclass TransformCanonicalTests.IfEqu25
 Real x;
 Real y;
 parameter Real temp_1;
parameter equation
 temp_1 = TransformCanonicalTests.IfEqu25.f(2);
equation
 x = if temp_1 > 0 then time else 2;
 y = if temp_1 > 0 then x else x * x;

public
 function TransformCanonicalTests.IfEqu25.f
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = sin(x);
  return;
 end TransformCanonicalTests.IfEqu25.f;

end TransformCanonicalTests.IfEqu25;
")})));
end IfEqu25;

model IfEqu26
    function F
            input Real x;
            output Real a;
            output Real b;
    algorithm
            a := x + 1;
            b := x - 42;
            annotation(Inline = false);
    end F;
    
    Real x,a,b;
equation
    x = time * 23;
    if time > 0.5 then
        (a, b) = F(x);
    else
        a = 5;
        b = 2;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IfEqu26",
            description="Test if equation in BLT",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
x := time * 23

--- Solved if equation ---
if time > 0.5 then
  (a, b) = TransformCanonicalTests.IfEqu26.F(x);
else
  a = 5;
  b = 2;
end if
  Assigned variables: a
                      b
-------------------------------
")})));
end IfEqu26;

model IfEqu27
        function F
                input Real x;
                output Real a;
                output Real b;
        algorithm
                a := x + 1;
                b := x - 42;
                annotation(Inline = false);
        end F;
        
        Real x,a,b;
equation
    x = time * 23;
    if time > 0.5 then
        (a, b) = F(x);
    else
        (a, b) = F(x - 2);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IfEqu27",
            description="Test if equation in BLT",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
x := time * 23

--- Solved if equation ---
if time > 0.5 then
  (a, b) = TransformCanonicalTests.IfEqu27.F(x);
else
  (a, b) = TransformCanonicalTests.IfEqu27.F(x - 2);
end if
  Assigned variables: a
                      b
-------------------------------
")})));
end IfEqu27;

model IfEqu28
    function F
            input Real x;
            output Real a;
            output Real b;
    algorithm
            a := x + 1;
            b := x - 42;
            annotation(Inline = false);
    end F;
    
    Real x,a,b,c,d;
equation
    x = time * 23;
    if time > 0.5 then
        (a, b) = F(x);
        (c, d) = F(x);
    else
        a = 2;
        b = 3;
        c = 4;
        d = 5;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IfEqu28",
            description="Test if equation in BLT",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
x := time * 23

--- Solved if equation ---
if time > 0.5 then
  (a, b) = TransformCanonicalTests.IfEqu28.F(x);
  (c, d) = TransformCanonicalTests.IfEqu28.F(x);
else
  a = 2;
  b = 3;
  c = 4;
  d = 5;
end if
  Assigned variables: a
                      b
                      c
                      d
-------------------------------
")})));
end IfEqu28;

model IfEqu29
        function F
                input Real x;
                output Real a;
                output Real b;
        algorithm
                a := x + 1;
                b := x - 42;
                annotation(Inline = false);
        end F;
        
        Real x,a,b,c,d;
equation
    x = time * 23;
    if time > 0.5 then
        (a, b) = F(x);
        (c, d) = F(x);
    else
        a = 2;
        (b, c) = F(x);
        d = 5;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IfEqu29",
            description="Test if equation in BLT",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
x := time * 23

--- Solved if equation ---
if time > 0.5 then
  (a, b) = TransformCanonicalTests.IfEqu29.F(x);
  (c, d) = TransformCanonicalTests.IfEqu29.F(x);
else
  a = 2;
  d = 5;
  (b, c) = TransformCanonicalTests.IfEqu29.F(x);
end if
  Assigned variables: a
                      b
                      c
                      d
-------------------------------
")})));
end IfEqu29;

model IfEqu30
    Boolean b1 = time > 0;
    Real a,b;
    Real x,y;
equation
    der(y) = time * 3.14;
    b = time * 6.28;
    if b1 then
        a = b * 2;
        x = time * 2;
    else
        b = a;
        x = der(y);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEqu30",
            description="Check bug that caused crash during if equation rewrite",
            flatModel="
fclass TransformCanonicalTests.IfEqu30
 discrete Boolean b1;
 Real a;
 Real b;
 Real x;
 Real y;
initial equation 
 y = 0.0;
 pre(b1) = false;
equation
 der(y) = time * 3.14;
 b = time * 6.28;
 x = if b1 then time * 2 else der(y);
 0.0 = if b1 then a - b * 2 else b - a;
 b1 = time > 0;
end TransformCanonicalTests.IfEqu30;
")})));
end IfEqu30;



model IfExpLeft1
	Real x;
equation
	if time>=1 then 1 else 0 = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfExpLeft1",
			description="If expression as left side of equation",
			flatModel="
fclass TransformCanonicalTests.IfExpLeft1
 Real x;
equation
 if time >= 1 then 1 else 0 = x;
end TransformCanonicalTests.IfExpLeft1;
")})));
end IfExpLeft1;



model WhenVariability1
	Real x(start=1);
equation
	when time > 2 then
		x = 2;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenVariability1",
			description="Variability of variable assigned in when clause",
			flatModel="
fclass TransformCanonicalTests.WhenVariability1
 discrete Real x(start = 1);
 discrete Boolean temp_1;
initial equation 
 pre(x) = 1;
 pre(temp_1) = false;
equation
 temp_1 = time > 2;
 x = if temp_1 and not pre(temp_1) then 2 else pre(x);
end TransformCanonicalTests.WhenVariability1;
			
")})));
end WhenVariability1;


model StateInitialPars1
	Real x(start=3);
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars1",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars1
 Real x(start = 3);
 parameter Real _start_x = 3 /* 3 */;
initial equation 
 x = _start_x;
equation
 der(x) = - x;
end TransformCanonicalTests.StateInitialPars1;
")})));
end StateInitialPars1;

model StateInitialPars2
	Real x(start=3, fixed = true);
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars2",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars2
 Real x(start = 3,fixed = true);
 parameter Real _start_x = 3 /* 3 */;
initial equation 
 x = _start_x;
equation
 der(x) = - x;
end TransformCanonicalTests.StateInitialPars2;
")})));
end StateInitialPars2;
	
model StateInitialPars3
	Real x(start=3, fixed = true);
	Real y(start = 4);
	Real z(start = 6, fixed = true);
equation
	der(x) = -x;
	der(y) = -y + z;
	z + 2*y = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars3",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars3
 Real x(start = 3,fixed = true);
 Real y(start = 4);
 Real z(start = 6,fixed = true);
 parameter Real _start_x = 3 /* 3 */;
 parameter Real _start_y = 4 /* 4 */;
initial equation 
 x = _start_x;
 y = _start_y;
equation
 der(x) = - x;
 der(y) = - y + z;
 z + 2 * y = 0;
end TransformCanonicalTests.StateInitialPars3;
")})));
end StateInitialPars3;	
	
model StateInitialPars4
	Real x(start=3);
	Real y(start = 4);
	Real z(start = 6);
initial equation
	x = 3;
	z = 5;
equation
	der(x) = -x;
	der(y) = -y + z;
	z + 2*y = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars4",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars4
 Real x(start = 3);
 Real y(start = 4);
 Real z(start = 6);
 parameter Real _start_x = 3 /* 3 */;
 parameter Real _start_y = 4 /* 4 */;
initial equation 
 x = _start_x;
 y = _start_y;
equation
 der(x) = - x;
 der(y) = - y + z;
 z + 2 * y = 0;
end TransformCanonicalTests.StateInitialPars4;
")})));
end StateInitialPars4;

model StateInitialPars5
   Real x;
equation 
  der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StateInitialPars5",
            description="Test the state initial equations option and variable without start value",
            state_initial_equations=true,
            flatModel="
fclass TransformCanonicalTests.StateInitialPars5
 Real x;
 parameter Real _start_x = 0.0 /* 0.0 */;
initial equation 
 x = _start_x;
equation
 der(x) = - x;
end TransformCanonicalTests.StateInitialPars5;
")})));
end StateInitialPars5;

model StateInitialPars6
    Real x(start = p);
    parameter Real p = 2;
equation 
    der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StateInitialPars6",
            description="Check that only independent parameters are generated for start values with state_initial_equations",
            state_initial_equations=true,
            flatModel="
fclass TransformCanonicalTests.StateInitialPars6
 Real x(start = p);
 parameter Real p = 2 /* 2 */;
 parameter Real _start_x = 2.0 /* 2.0 */;
initial equation 
 x = _start_x;
equation
 der(x) = - x;
end TransformCanonicalTests.StateInitialPars6;
")})));
end StateInitialPars6;

model StateInitialPars7
    function f
        output Real x;
        external;
    end f;
        Real x(start = f());
equation 
    der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="StateInitialPars7",
            description="Check that unevlauateable start values with state_initial_equations gives error",
            state_initial_equations=true,
            errorMessage="
1 errors found:

Error at line 6, column 24, in file 'Compiler/ModelicaMiddleEnd/src/test/TransformCanonicalTests.mo':
  Could not evaluate binding expression for attribute 'start': 'f()'
    in function 'TransformCanonicalTests.StateInitialPars7.f'
    Failed to evaluate external function 'f', external function cache unavailable
")})));
end StateInitialPars7;


model StateInitialPars8
    Real x(start = 1);
	Real y(stateSelect = StateSelect.always) = x;
equation 
    der(x) = -x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StateInitialPars8",
            description="Alias eliminating differentiated variable with state_initial_equations active",
            state_initial_equations=true,
            flatModel="
fclass TransformCanonicalTests.StateInitialPars8
 Real y(stateSelect = StateSelect.always,start = 1);
 parameter Real _start_y = 1 /* 1 */;
initial equation 
 y = _start_y;
equation
 der(y) = - y;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end TransformCanonicalTests.StateInitialPars8;
")})));
end StateInitialPars8;


  model SolveEqTest1
    Real x, y, z;
  equation
    x = time;
    y = x + 3;
    z = x - y;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest1",
			description="Test solution of equations",
            eliminate_linear_equations=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
x := time

--- Solved equation ---
y := x + 3

--- Solved equation ---
z := x + (- y)
-------------------------------
")})));
  end SolveEqTest1;

  model SolveEqTest2
    Real x, y, z;
  equation
    x = time;
    - y = x + 3;
    - z = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest2",
			description="Test solution of equations",
            eliminate_linear_equations=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
x := time

--- Solved equation ---
y := - x - 3

--- Solved equation ---
z := - x + y
-------------------------------
")})));
  end SolveEqTest2;

  model SolveEqTest3
    Real x, y, z;
  equation
    x = 1;
    2*y = x + 3;
    x*z = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest3",
			description="Test solution of equations",
			equation_sorting=true,
			variability_propagation=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
x := 1

--- Solved equation ---
y := (x + 3) / 2

--- Solved equation ---
z := (x + (- y)) / x
-------------------------------
")})));
  end SolveEqTest3;

  model SolveEqTest4
    Real x, y, z;
  equation
    x = 1;
    y/2 = x + 3;
    z/x = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest4",
			description="Test solution of equations",
			equation_sorting=true,
			variability_propagation=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
x := 1

--- Solved equation ---
y := (x + 3) / (1.0 / 2)

--- Solved equation ---
z := (x + (- y)) / (1.0 / x)
-------------------------------
")})));
  end SolveEqTest4;

  model SolveEqTest5
    Real x, y, z;
  equation
    x = 1;
    y = x + 3 + 3*y;
    z = x - y + (x+3)*z ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest5",
			description="Test solution of equations",
			equation_sorting=true,
			variability_propagation=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
x := 1

--- Solved equation ---
y := (x + 3) / (1.0 + -3)

--- Solved equation ---
z := (x + (- y)) / (1.0 + (-x - 3))
-------------------------------
")})));
  end SolveEqTest5;

  model SolveEqTest6

    Real x, y, z;
  equation
    x = 1;
    2/y = x + 3;
    x/z = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest6",
			description="Test solution of equations",
			equation_sorting=true,
			variability_propagation=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
x := 1

--- Unsolved equation (Block 1) ---
2 / y = x + 3
  Computed variables: y

--- Unsolved equation (Block 2) ---
x / z = x - y
  Computed variables: z
-------------------------------
")})));
  end SolveEqTest6;

   model SolveEqTest7

    Real x, y, z;
  equation
    x = time;
    - y = x + 3 - y + 4*y;
    - z = x - y -z - 5*z;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest7",
			description="Test solution of equations",
            eliminate_linear_equations=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
x := time

--- Solved equation ---
y := (x + 3) / (-1.0 + 1.0 + -4)

--- Solved equation ---
z := (x + (- y)) / (-1.0 + 1.0 + 5)
-------------------------------
")})));
  end SolveEqTest7;
  

  model SolveEqTest8
    Real x;
  equation
   -der(x) + x = -der(x) - (-(-(-der(x))));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest8",
			description="Test solution of equations",
			equation_sorting=true,
			variability_propagation=false,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
der(x) := (- x) / (-1.0 + 1.0 + -1.0)
-------------------------------
")})));
  end SolveEqTest8;
  
  model SolveEqTest9
        Real x;
    equation
        0 = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SolveEqTest9",
            description="Test bug found in solution framework",
            flatModel="
fclass TransformCanonicalTests.SolveEqTest9
 constant Real x = 0;
end TransformCanonicalTests.SolveEqTest9;
")})));
  end SolveEqTest9;

  model SolveEqTest10
        Real x,y;
    equation
        y = time;
        y * x = 0;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="SolveEqTest10",
            description="Test bug found in solution framework",
            eliminate_linear_equations=false,
            equation_sorting=true,
            variability_propagation=false,
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
y := time

--- Unsolved equation (Block 1) ---
y * x = 0
  Computed variables: x
-------------------------------
")})));
  end SolveEqTest10;

model BlockTest1
record R
  Real x,y;
end R;

function f1
  input Real x;
  output R r;
algorithm 
  r.x :=x;
  r.y :=x*x;
end f1;

function f2
  input Real x;
  output Real y1;
  output Real y2;
algorithm
  y1:=x*2;
  y2:=x*4;
end f2;

  R r;
  Real x;
  Real y1,y2;
equation
  x = sin(time);
  r = f1(x + r.x);
  (y1,y2) = f2(x + y1);


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest1",
			methodName="printDAEBLT",
			equation_sorting=true,
			inline_functions="none",
			automatic_tearing=false,
			description="
Test of correct creation of blocks containing functions returning records", methodResult="
--- Solved equation ---
x := sin(time)

--- Unsolved function call equation (Block 1) ---
(TransformCanonicalTests.BlockTest1.R(r.x, r.y)) = TransformCanonicalTests.BlockTest1.f1(x + r.x)
  Computed variables: r.x
                      r.y

--- Unsolved function call equation (Block 2) ---
(y1, y2) = TransformCanonicalTests.BlockTest1.f2(x + y1)
  Computed variables: y1
                      y2
-------------------------------
")})));
end BlockTest1;

model BlockTest2
record R
  Real x,y;
end R;

record R2
  Real x;
  R r;
end R2;

function f1
  input Real x;
  output R r;
algorithm 
  r.x :=x;
  r.y :=x*x;
end f1;

function f2
  input Real x;
  output Real y1;
  output Real y2;
algorithm
  y1:=x*2;
  y2:=x*4;
end f2;

function f3
  input Real x;
  output R2 r;
algorithm 
  r.x :=x;
  r.r :=R(x*x,x);
end f3;

  R r;
  R2 r2;
  Real x;
  Real y1,y2;
equation
  x = sin(time);
  r = f1(x + r.x);
  r2 = f3(x + r2.x);
  (y1,y2) = f2(x + y1);


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest2",
			methodName="printDAEBLT",
			equation_sorting=true,
			inline_functions="none",
			automatic_tearing=false,
			description="Test of correct creation of blocks containing functions returning records",
			methodResult="
--- Solved equation ---
x := sin(time)

--- Unsolved function call equation (Block 1) ---
(TransformCanonicalTests.BlockTest2.R(r.x, r.y)) = TransformCanonicalTests.BlockTest2.f1(x + r.x)
  Computed variables: r.x
                      r.y

--- Unsolved function call equation (Block 2) ---
(TransformCanonicalTests.BlockTest2.R2(r2.x, TransformCanonicalTests.BlockTest2.R(r2.r.x, r2.r.y))) = TransformCanonicalTests.BlockTest2.f3(x + r2.x)
  Computed variables: r2.x
                      r2.r.x
                      r2.r.y

--- Unsolved function call equation (Block 3) ---
(y1, y2) = TransformCanonicalTests.BlockTest2.f2(x + y1)
  Computed variables: y1
                      y2
-------------------------------
")})));
end BlockTest2;

model BlockTest3
  record R
    Real x;
    Real y;
  end R;
  function F
    input Real a;
    output R r;
  algorithm
    r := R(a*2, a*3);
  end F;
  R r1, r2;
  Real x;
equation
  x = sin(time);
  r1 = F(x + r2.x);
  r2 = F(x + r1.x);  

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest3",
			methodName="printDAEBLT",
			equation_sorting=true,
			inline_functions="none",
			automatic_tearing=false,
			description="Test of correct creation of blocks containing functions returning records",
			methodResult="
--- Solved equation ---
x := sin(time)

--- Unsolved system (Block 1) of 4 variables ---
Unknown variables:
  r2.y ()
  r2.x ()
  r1.x ()
  r1.y ()

Equations:
  (TransformCanonicalTests.BlockTest3.R(r2.x, r2.y)) = TransformCanonicalTests.BlockTest3.F(x + r1.x)
    Iteration variables: r2.y
                         r2.x
  (TransformCanonicalTests.BlockTest3.R(r1.x, r1.y)) = TransformCanonicalTests.BlockTest3.F(x + r2.x)
    Iteration variables: r1.x
                         r1.y
-------------------------------
")})));
end BlockTest3;

model BlockTest4
 Real x1,x2,z,w;
equation
w=1;
x2 = w*z + 1 + w;
x1 + x2 = z + sin(w);
x1 - x2 = z*w;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest4",
			description="Test of linear systems of equations",
			equation_sorting=true,
            automatic_tearing = false,
            eliminate_linear_equations=false,
			methodName="printDAEBLT",
			methodResult="
--- Unsolved linear system (Block 1) of 3 variables ---
Coefficient variability: constant
Unknown variables:
  x1
  z
  x2

Equations:
  x1 + x2 = z + 0.8414709848078965
    Iteration variables: x1
  x1 - x2 = z
    Iteration variables: z
  x2 = z + 1 + 1.0
    Iteration variables: x2

Jacobian:
  |1.0, - 1.0, 1.0|
  |1.0, - 1.0, - 1.0|
  |0.0, - 1.0, 1.0|
-------------------------------
")})));
end BlockTest4;

model BlockTest5
 Real x1,x2,z;
equation
x2 = z + 1 ;
x1 + x2 = z;
x1 - x2 = z;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest5",
			description="Test of linear systems of equations",
			equation_sorting=true,
            automatic_tearing = false,
            eliminate_linear_equations=false,
			methodName="printDAEBLT",
			methodResult="
--- Unsolved linear system (Block 1) of 3 variables ---
Coefficient variability: constant
Unknown variables:
  x1
  z
  x2

Equations:
  x1 + x2 = z
    Iteration variables: x1
  x1 - x2 = z
    Iteration variables: z
  x2 = z + 1
    Iteration variables: x2

Jacobian:
  |1.0, - 1.0, 1.0|
  |1.0, - 1.0, - 1.0|
  |0.0, - 1.0, 1.0|
-------------------------------
")})));
end BlockTest5;

model BlockTest6
 Real x1,x2,z;
 parameter Real p;
equation
x2 = z + p;
x1 + x2 = z;
x1 - x2 = z*p;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="BlockTest6",
            description="Test of linear systems of equations",
            eliminate_linear_equations=false,
            equation_sorting=true,
            automatic_tearing = false,
            methodName="printDAEBLT",
            methodResult="
--- Unsolved linear system (Block 1) of 3 variables ---
Coefficient variability: parameter
Unknown variables:
  x1
  z
  x2

Equations:
  x1 + x2 = z
    Iteration variables: x1
  x1 - x2 = z * p
    Iteration variables: z
  x2 = z + p
    Iteration variables: x2

Jacobian:
  |1.0, - 1.0, 1.0|
  |1.0, (- p), - 1.0|
  |0.0, - 1.0, 1.0|
-------------------------------
")})));
end BlockTest6;

model BlockTest7
    Real a;
    Real b;
    Boolean d;
equation
    a = 1 - b;
    a = b * (if d then 1 else 2);
    d = b < 0;
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="BlockTest7",
            description="Test of linear systems of equations with if expression",
            equation_sorting=true,
            automatic_tearing = false,
            methodName="printDAEBLT",
            methodResult="
--- Unsolved mixed linear system (Block 1) of 3 variables ---
Coefficient variability: discrete-time
Unknown continuous variables:
  b
  a

Solved discrete variables:
  d

Continuous residual equations:
  a = b * (if d then 1 else 2)
    Iteration variables: b
  a = 1 - b
    Iteration variables: a

Discrete equations:
  d := b < 0

Jacobian:
  |(- (if d then 1 else 2)), 1.0|
  |1.0, 1.0|
-------------------------------
")})));
end BlockTest7;

model BlockTest8
  Real y1,y2;
equation 
  y1 =  sin(time) + y2;
  y2 =  (y1 * 4) + (3 * time);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest8",
			description="Test of linear systems of equations. Checks that the time
			derivative is not included in the jacobian.",
			equation_sorting=true,
            automatic_tearing=false,
			methodName="printDAEBLT",
			methodResult="
--- Unsolved linear system (Block 1) of 2 variables ---
Coefficient variability: constant
Unknown variables:
  y2
  y1

Equations:
  y2 = y1 * 4 + 3 * time
    Iteration variables: y2
  y1 = sin(time) + y2
    Iteration variables: y1

Jacobian:
  |1.0, - 4|
  |- 1.0, 1.0|
-------------------------------
")})));
end BlockTest8;

model BlockTest9
record R
	Real[2] a;	
end R;
function f
  input Real a;
  output R b;
  output Real dummy;
  output Integer[2] c;
algorithm
  b := R({a,a});
  c := {integer(a),integer(a)};
  dummy := 1;
end f;
discrete R r;
Integer[2] i;
equation
  (r, ,i) = f(time*10);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest9",
			description="Test of linear systems of equations. Checks that function
			call equations with different return value types are matched correctly.",
			equation_sorting=true,
			inline_functions="none",
			methodName="printDAEBLT",
			methodResult="
--- Solved function call equation ---
(TransformCanonicalTests.BlockTest9.R({r.a[1], r.a[2]}), , {i[1], i[2]}) = TransformCanonicalTests.BlockTest9.f(time * 10)
  Assigned variables: r.a[1]
                      r.a[2]
                      i[1]
                      i[2]
-------------------------------
")})));
end BlockTest9;

model BlockTest10
	function F
		input Real x[2];
		output Real y[2];
	algorithm
		if x[1] < 0 then
			x := -x;
		end if;
		y := x;
	end F;
	Real z[2], w[2];
equation
	w = {time, 2};
	z + F(w) = {0, 0};
	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest10",
			description="Test alias elimination of negative function call lefts",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
--- Solved equation ---
w[1] := time

--- Solved function call equation ---
({temp_8, temp_9}) = TransformCanonicalTests.BlockTest10.F({w[1], 2.0})
  Assigned variables: temp_8
                      temp_9

--- Solved equation ---
z[1] := - temp_8

--- Solved equation ---
z[2] := - temp_9
-------------------------------
")})));
end BlockTest10;

model BlockTest11
	Real x;
equation
	12 = if x < 0.5 then 0.5 else x * time;
	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest11",
			description="Test linear block with single equation",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
--- Unsolved equation (Block 1) ---
12 = if x < 0.5 then 0.5 else x * time
  Computed variables: x
-------------------------------
")})));
end BlockTest11;

model IncidenceComputation1
    function func
        input Real x1;
        input Real x2;
        input Real x3;
        output Real y1;
        output Real y2;
        output Real y3;
      algorithm
        y1 := x1;
        y1 := x2;
        y2 := y1;
        y3 := y2;
        y3 := x1;
        y1 := x3;
    end func;
    Real a,b,c,d,e,f;
equation
    der(d) = time;
    der(e) = time;
    der(f) = time;
    (d,b,f) = func(a,e,c);
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IncidenceComputation1",
            description="Incidence computation in function call equation",
            equation_sorting=true,
            inline_functions="none",
            function_incidence_computation="all",
            methodName="printMatchedDAE",
            methodResult="
BiPGraph (6 equations, 6 variables)
Variables: {der(d) der(e) der(f) a b c }
eq_1 : der(d)@M // der(d) = time
eq_2 : der(e)@M // der(e) = time
eq_3 : der(f)@M // der(f) = time
eq_4[1] : a@M // (d, b, f) = TransformCanonicalTests.IncidenceComputation1.func(a, e, c)
eq_4[2] : b@M // Already printed, see eq_4[1]
eq_4[3] : c@M // Already printed, see eq_4[1]
")})));
end IncidenceComputation1;

model IncidenceComputation2
    function func
        input Real x1;
        input Real x2;
        input Real x3;
        input Real n;
        output Real y1;
        output Real y2;
        output Real y3;
      algorithm
        y1 := n*x1 + x2 + x3;
        y2 := x1 + n*x2 + x3;
        y3 := x1 + x2 - n/x3;
    end func;
    Real a,b,c,d,e,f;
equation
    der(d) = time;
    der(e) = time;
    der(f) = time;
    (d,b,f) = func(a,e,c,0);
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IncidenceComputation2",
            description="Incidence computation in function call equation",
            equation_sorting=true,
            inline_functions="none",
            function_incidence_computation="all",
            methodName="printMatchedDAE",
            methodResult="
BiPGraph (6 equations, 6 variables)
Variables: {der(d) der(e) der(f) a b c }
eq_1 : der(d)@M // der(d) = time
eq_2 : der(e)@M // der(e) = time
eq_3 : der(f)@M // der(f) = time
eq_4[1] : a@M // (d, b, f) = TransformCanonicalTests.IncidenceComputation2.func(a, e, c, 0)
eq_4[2] : b@M a@ c@ // Already printed, see eq_4[1]
eq_4[3] : c@M // Already printed, see eq_4[1]
")})));
end IncidenceComputation2;

model IncidenceComputation3
    function func
        input Real[3] x;
        input Real n;
        output Real[3] y;
      algorithm
        y[1] := n*x[1] + x[2] + x[3];
        y[2] := x[1] + n*x[2] + x[3];
        y[3] := x[1] + x[2] - n/x[3];
    end func;
    Real a,b,c,d,e,f;
equation
    der(d) = time;
    der(e) = time;
    der(f) = time;
    ({d,b,f}) = func({a,e,c},0);
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IncidenceComputation3",
            description="Incidence computation in function call equation",
            equation_sorting=true,
            inline_functions="none",
            function_incidence_computation="all",
            methodName="printMatchedDAE",
            methodResult="
BiPGraph (6 equations, 6 variables)
Variables: {der(d) der(e) der(f) a b c }
eq_1 : der(d)@M // der(d) = time
eq_2 : der(e)@M // der(e) = time
eq_3 : der(f)@M // der(f) = time
eq_4[1] : a@M // ({d, b, f}) = TransformCanonicalTests.IncidenceComputation3.func({a, e, c}, 0)
eq_4[2] : b@M a@ c@ // Already printed, see eq_4[1]
eq_4[3] : c@M // Already printed, see eq_4[1]
")})));
end IncidenceComputation3;

model IncidenceComputation4
    record R
        Real a;
        Real b;
        Real c;
    end R;
    
    function func
        input R x;
        input Real n;
        output R y;
      algorithm
        y.a := n*x.a + x.b + x.c;
        y.b := x.a + n*x.b + x.c;
        y.c := x.a + x.b - n/x.c;
    end func;
    Real a,b,c,d,e,f;
equation
    der(d) = time;
    der(e) = time;
    der(f) = time;
    (R(d,b,f)) = func(R(a,e,c),0);
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IncidenceComputation4",
            description="Incidence computation in function call equation",
            equation_sorting=true,
            inline_functions="none",
            function_incidence_computation="all",
            methodName="printMatchedDAE",
            methodResult="
BiPGraph (6 equations, 6 variables)
Variables: {der(d) der(e) der(f) a b c }
eq_1 : der(d)@M // der(d) = time
eq_2 : der(e)@M // der(e) = time
eq_3 : der(f)@M // der(f) = time
eq_4[1] : a@M // (TransformCanonicalTests.IncidenceComputation4.R(d, b, f)) = TransformCanonicalTests.IncidenceComputation4.func(TransformCanonicalTests.IncidenceComputation4.R(a, e, c), 0)
eq_4[2] : b@M a@ c@ // Already printed, see eq_4[1]
eq_4[3] : c@M // Already printed, see eq_4[1]
")})));
end IncidenceComputation4;

model IncidenceComputation5
    function func2
        input Real[2] x;
        input Real n;
        output Real[2] y;
      algorithm
        y[1] := n*x[1] + x[2];
        y[2] := x[1] + n*x[2];
    end func2;
    
    function func
        input Real[3] x;
        input Real n;
        output Real[3] y;
      algorithm
        y[1:2] := func2(x[1:2], n);
        y[1] := y[1] + x[3];
        y[2] := y[2] + x[3];
        y[3] := x[1] + x[2] - n/x[3];
    end func;
    Real a,b,c,d,e,f;
equation
    der(d) = time;
    der(e) = time;
    der(f) = time;
    ({d,b,f}) = func({a,e,c},0);
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IncidenceComputation5",
            description="Incidence computation in function call equation",
            equation_sorting=true,
            inline_functions="none",
            function_incidence_computation="all",
            methodName="printMatchedDAE",
            methodResult="
BiPGraph (6 equations, 6 variables)
Variables: {der(d) der(e) der(f) a b c }
eq_1 : der(d)@M // der(d) = time
eq_2 : der(e)@M // der(e) = time
eq_3 : der(f)@M // der(f) = time
eq_4[1] : a@M // ({d, b, f}) = TransformCanonicalTests.IncidenceComputation5.func({a, e, c}, 0)
eq_4[2] : b@M a@ c@ // Already printed, see eq_4[1]
eq_4[3] : c@M // Already printed, see eq_4[1]
")})));
end IncidenceComputation5;

model IncidenceComputation6
    function func
        input Real[3] x;
        input Real n;
        output Real[3] y;
      algorithm
        y := func(x,n);
    end func;
    Real a,b,c,d,e,f;
equation
    der(d) = time;
    der(e) = time;
    der(f) = time;
    ({d,b,f}) = func({a,e,c},0);
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IncidenceComputation6",
            description="Incidence computation in function call equation. Test recursive function.",
            equation_sorting=true,
            inline_functions="none",
            function_incidence_computation="all",
            methodName="printMatchedDAE",
            methodResult="
BiPGraph (6 equations, 6 variables)
Variables: {der(d) der(e) der(f) a b c }
eq_1 : der(d)@M // der(d) = time
eq_2 : der(e)@M // der(e) = time
eq_3 : der(f)@M // der(f) = time
eq_4[1] : a@M c@ // ({d, b, f}) = TransformCanonicalTests.IncidenceComputation6.func({a, e, c}, 0)
eq_4[2] : b@M a@ c@ // Already printed, see eq_4[1]
eq_4[3] : a@ c@M // Already printed, see eq_4[1]
")})));
end IncidenceComputation6;

model IncidenceComputation7
    function func
        input Real[3] x;
        input Real n;
        output Real[3] y;
      algorithm
        if x[1] > x[2] then
            y := x;
        else
            y := x;
        end if;
    end func;
    Real a,b,c,d,e,f;
equation
    der(d) = time;
    der(e) = time;
    der(f) = time;
    ({d,b,f}) = func({a,e,c},0);
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="IncidenceComputation7",
            description="Incidence computation in function call equation. Test if stmt.",
            equation_sorting=true,
            inline_functions="none",
            function_incidence_computation="all",
            methodName="printMatchedDAE",
            methodResult="
BiPGraph (6 equations, 6 variables)
Variables: {der(d) der(e) der(f) a b c }
eq_1 : der(d)@M // der(d) = time
eq_2 : der(e)@M // der(e) = time
eq_3 : der(f)@M // der(f) = time
eq_4[1] : a@M c@ // ({d, b, f}) = TransformCanonicalTests.IncidenceComputation7.func({a, e, c}, 0)
eq_4[2] : b@M a@ c@ // Already printed, see eq_4[1]
eq_4[3] : a@ c@M // Already printed, see eq_4[1]
")})));
end IncidenceComputation7;

model VarDependencyTest1
  Real x[15];
  input Real u[4];
equation
  x[1] = u[1];
  x[2] = u[2];
  x[3] = u[3];
  x[4] = u[4];
  x[5] = x[1];
  x[6] = x[1] + x[2];
  x[7] = x[3];
  x[8] = x[3];
  x[9] = x[4];
  x[10] = x[5];
  x[11] = x[5];
  x[12] = x[1] + x[6];
  x[13] = x[7] + x[8];
  x[14] = x[8] + x[9];
  x[15] = x[12] + x[3];


    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="VarDependencyTest1",
            methodName="dependencyDiagnostics",
            equation_sorting=true,
            eliminate_alias_variables=false,
            description="Test computation of direct dependencies",
            methodResult="
Variable dependencies:
Derivative variables: 

Differentiated variables: 

Algebraic real variables: 
 x[1]
    u[1]
 x[2]
    u[2]
 x[3]
    u[3]
 x[4]
    u[4]
 x[5]
    u[1]
 x[6]
    u[1]
    u[2]
 x[7]
    u[3]
 x[8]
    u[3]
 x[9]
    u[4]
 x[10]
    u[1]
 x[11]
    u[1]
 x[12]
    u[2]
    u[1]
 x[13]
    u[3]
 x[14]
    u[3]
    u[4]
 x[15]
    u[2]
    u[1]
    u[3]
")})));
end VarDependencyTest1;

model VarDependencyTest2
  Real x[2](each start=2);
  input Real u[3];
  Real y[3];
equation
  der(x[1]) = x[1] + x[2] + u[1];
  der(x[2]) = x[2] + u[2] + u[3];
  y[1] = x[2] + u[1];
  y[2] = x[1] + x[2] + u[2] + u[3];
  y[3] = x[1] + u[1] + u[3];

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="VarDependencyTest2",
			methodName="dependencyDiagnostics",
			equation_sorting=true,
			eliminate_alias_variables=false,
			description="Test computation of direct dependencies",
			methodResult="
Variable dependencies:
Derivative variables: 
 der(x[1])
    u[1]
    x[1]
    x[2]
 der(x[2])
    u[2]
    u[3]
    x[2]

Differentiated variables: 
 x[1]
 x[2]

Algebraic real variables: 
 y[1]
    u[1]
    x[2]
 y[2]
    u[2]
    u[3]
    x[1]
    x[2]
 y[3]
    u[1]
    u[3]
    x[1]
")})));
end VarDependencyTest2;

model String1
    parameter String a = "1";
    parameter String b = a + "2";
    parameter String c = b + "3";

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="String1",
            description="",
            flatModel="
fclass TransformCanonicalTests.String1
 parameter String a = \"1\" /* \"1\" */;
 parameter String b;
 parameter String c;
parameter equation
 b = a + \"2\";
 c = b + \"3\";
end TransformCanonicalTests.String1;
")})));
end String1;

model String2
    function f
        input String s;
        output String t;
    algorithm
        t := s;
        annotation(Inline=false);
    end f;
    
    parameter String p1 = "a";
    parameter String p2 = f("a");
    parameter String p3 = f(p1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
            name="String2",
			description="Test that string parameters and string parameters goes through front-end.",
			flatModel="
fclass TransformCanonicalTests.String2
 parameter String p1 = \"a\" /* \"a\" */;
 parameter String p2 = \"a\" /* \"a\" */;
 parameter String p3;
parameter equation
 p3 = TransformCanonicalTests.String2.f(p1);

public
 function TransformCanonicalTests.String2.f
  input String s;
  output String t;
 algorithm
  t := s;
  return;
 annotation(Inline = false);
 end TransformCanonicalTests.String2.f;

end TransformCanonicalTests.String2;
")})));

end String2;

model String3
    String s(start="start");
equation
    when time > 1 then
        s = "val";
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="String3",
            description="Test that string parameters and string parameters goes through front-end.",
            flatModel="
fclass TransformCanonicalTests.String3
 discrete String s(start = \"start\");
 discrete Boolean temp_1;
initial equation
 pre(temp_1) = false;
 pre(s) = \"start\";
equation
 temp_1 = time > 1;
 s = if temp_1 and not pre(temp_1) then \"val\" else pre(s);
end TransformCanonicalTests.String3;
")})));

end String3;

class MyExternalObject
 extends ExternalObject;
 
 function constructor
	 output MyExternalObject eo;
	 external "C" init_myEO();
 end constructor;
 
 function destructor
	 input MyExternalObject eo;
	 external "C" destroy_myEO(eo);
 end destructor;
end MyExternalObject;


model TestExternalObj1
 MyExternalObject myEO = MyExternalObject();

	annotation(__JModelica(UnitTesting(tests={ 
		TransformCanonicalTestCase(
			name="TestExternalObj1",
			description="",
			flatModel="
fclass TransformCanonicalTests.TestExternalObj1
 parameter TransformCanonicalTests.MyExternalObject myEO = TransformCanonicalTests.MyExternalObject.constructor() /* (unknown value) */;

public
 function TransformCanonicalTests.MyExternalObject.destructor
  input TransformCanonicalTests.MyExternalObject eo;
 algorithm
  external \"C\" destroy_myEO(eo);
  return;
 end TransformCanonicalTests.MyExternalObject.destructor;

 function TransformCanonicalTests.MyExternalObject.constructor
  output TransformCanonicalTests.MyExternalObject eo;
 algorithm
  external \"C\" init_myEO();
  return;
 end TransformCanonicalTests.MyExternalObject.constructor;

 type TransformCanonicalTests.MyExternalObject = ExternalObject;
end TransformCanonicalTests.TestExternalObj1;
")})));
end TestExternalObj1;


model TestExternalObj2
	extends MyExternalObject;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj2",
            description="Extending from external object",
            errorMessage="
1 errors found:

Error at line 2, column 2, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Classed derived from ExternalObject can neither be used in an extends-clause nor in a short class defenition
")})));
end TestExternalObj2;


model TestExternalObj3
    class NoConstructor
        extends ExternalObject;
     
        function destructor
            input NoConstructor eo;
            external "C" destroy_myEO(eo);
        end destructor;
    end NoConstructor;
    
    NoConstructor eo = NoConstructor();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj3",
            description="Non-complete external object",
            errorMessage="
1 errors found:

Error at line 11, column 24, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Cannot find function declaration for NoConstructor.constructor()
")})));
end TestExternalObj3;


model TestExternalObj4
    class NoDestructor
        extends ExternalObject;
     
        function constructor
            output NoDestructor eo;
            external "C" init_myEO();
        end constructor;
    end NoDestructor;
    
    NoDestructor eo = NoDestructor();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj4",
            description="Non-complete external object",
            errorMessage="
1 errors found:

Error at line 11, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Cannot find function declaration for NoDestructor.destructor()
")})));
end TestExternalObj4;


model TestExternalObj5
    class BadConstructor
        extends ExternalObject;
		
		record constructor
			Real x;
		end constructor;
     
        function destructor
            input BadConstructor eo;
            external "C" destroy_myEO(eo);
        end destructor;
    end BadConstructor;
    
    BadConstructor eo = BadConstructor();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj5",
            description="Non-complete external object",
            errorMessage="
2 errors found:

Error at line 5, column 3, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  An external object constructor must have exactly one output of the same type as the constructor

Error at line 15, column 25, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  The class BadConstructor.constructor is not a function
")})));
end TestExternalObj5;


model TestExternalObj6
    class BadDestructor
        extends ExternalObject;
     
        function constructor
            output BadDestructor eo;
            external "C" init_myEO();
        end constructor;
        
        model destructor
            Real x;
        end destructor;
     end BadDestructor;
    
    BadDestructor eo = BadDestructor();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj6",
            description="Non-complete external object",
            errorMessage="
2 errors found:

Error at line 10, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  An external object destructor must have exactly one input of the same type as the constructor, and no outputs

Error at line 15, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  The class BadDestructor.destructor is not a function
")})));
end TestExternalObj6;


model TestExternalObj7
    class ExtraContent
        extends ExternalObject;
        
        function constructor
            output ExtraContent eo;
            external "C" init_myEO();
        end constructor;
     
        function destructor
            input ExtraContent eo;
            external "C" destroy_myEO(eo);
        end destructor;
		
		function extra
			input Real x;
			output Real y;
		algorithm
			y := x;
		end extra;
    end ExtraContent;
    
    ExtraContent eo = ExtraContent();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj7",
            description="External object with extra elements",
            errorMessage="
1 errors found:

Error at line 2, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  External object classes may not contain any elements except the constructor and destructor
")})));
end TestExternalObj7;


model TestExternalObj8
    class ExtraContent
        extends ExternalObject;
        
        function constructor
            output ExtraContent eo;
            external "C" init_myEO();
        end constructor;
     
        function destructor
            input ExtraContent eo;
            external "C" destroy_myEO(eo);
        end destructor;
		
		Real x;
    end ExtraContent;
    
    ExtraContent eo = ExtraContent();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj8",
            description="External object with extra elements",
            errorMessage="
2 errors found:

Error at line 2, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  External object classes may not contain any elements except the constructor and destructor

Error at line 18, column 23, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable

")})));
end TestExternalObj8;


model TestExternalObj9
    class BadArgs
        extends ExternalObject;
        
        function constructor
            output BadArgs eo;
			output Real x;
            external "C" init_myEO();
        end constructor;
     
        function destructor
            input BadArgs eo;
			input Real y;
            external "C" destroy_myEO(eo);
        end destructor;
    end BadArgs;
    
    BadArgs eo = BadArgs();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj9",
            description="Extra inputs/outputs to constructor/destructor",
            errorMessage="
2 errors found:

Error at line 5, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  An external object constructor must have exactly one output of the same type as the constructor

Error at line 11, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  An external object destructor must have exactly one input of the same type as the constructor, and no outputs
")})));
end TestExternalObj9;


model TestExternalObj10
	MyExternalObject myEO = MyExternalObject.constructor();
equation
	MyExternalObject.constructor();
	MyExternalObject.destructor(myEO);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TestExternalObj10",
            description="",
            errorMessage="
3 errors found:

Error at line 2, column 26, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Constructors and destructors for ExternalObjects can not be used directly

Error at line 4, column 2, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Constructors and destructors for ExternalObjects can not be used directly

Error at line 5, column 2, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo':
  Constructors and destructors for ExternalObjects can not be used directly
")})));
end TestExternalObj10;


model GetInstanceName1
    model B
        model C
            equation
                Modelica.Utilities.Streams.print("Info from: " + getInstanceName());
        end C;
        
        String s = getInstanceName();
        C c;
    end B;
    
    B b;
    String s = getInstanceName();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="GetInstanceName1",
            description="Tests getInstanceName().",
            flatModel="
fclass TransformCanonicalTests.GetInstanceName1
 discrete String b.s = \"GetInstanceName1.b\";
 discrete String s = \"GetInstanceName1\";
equation
 Modelica.Utilities.Streams.print(\"Info from: \" + \"GetInstanceName1.b.c\", \"\");

public
 function Modelica.Utilities.Streams.print
  input String string;
  input String fileName;
 algorithm
  external \"C\" ModelicaInternal_print(string, fileName);
  return;
 end Modelica.Utilities.Streams.print;

end TransformCanonicalTests.GetInstanceName1;
")})));
end GetInstanceName1;


model GetInstanceName2
    parameter String s = getInstanceName() annotation(Evaluate=true);
    Real dummy = true;  // To generate an error.

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="GetInstanceName2",
            description="Check that constant evaluation of getInstanceName() works",
            errorMessage="
1 errors found:

Error at line 3, column 18, in file 'Compiler/ModelicaMiddleEnd/test/modelica/TransformCanonicalTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable dummy does not match the declared type of the variable
")})));
end GetInstanceName2;


package InitialParameters
    model Test1
        Real x;
        parameter Real p(fixed=false);
    initial equation
        2*x = p;
        x = 3;
    equation
        der(x) = -x;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialParameters_Test1",
            description="Test of initial parameters.",
            flatModel="
fclass TransformCanonicalTests.InitialParameters.Test1
 Real x;
 initial parameter Real p(fixed = false);
initial equation 
 2 * x = p;
 x = 3;
equation
 der(x) = - x;
end TransformCanonicalTests.InitialParameters.Test1;
")})));
    end Test1;

    model Test2
        Real x(start=p);
        parameter Real p(fixed=false) = time + x;
        Real y = p * time;
    equation
        der(x) = sin(time);
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="InitialParameters_Test2",
            description="Test incidence computation for state startvalues with initial parameters",
            methodName="printDAEInitBLT",
            methodResult="
--- Solved equation ---
der(x) := sin(time)

--- Torn linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: constant
Torn variables:
  p

Iteration variables:
  x

Torn equations:
  p := time + x

Residual equations:
  x = p
    Iteration variables: x

Jacobian:
  |1.0, -1.0|
  |-1.0, 1.0|

--- Solved equation ---
y := p * time
-------------------------------
")})));
    end Test2;

    model Differentiation1
       parameter Real a1(fixed = false);
        parameter Real a2(fixed = false);
        parameter Real b = 2;
        parameter Real c = 3;
        Real d = time * 42;
    initial equation
        c = b * a1 - a2 * d;
        a1 = a2 * 3.14;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="InitialParameters_Differentiation1",
            description="Test differentiation of initial parameters",
            methodName="printDAEInitBLT",
            methodResult="
--- Solved equation ---
d := time * 42

--- Torn linear system (Block 1) of 1 iteration variables and 1 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  a2

Iteration variables:
  a1

Torn equations:
  a2 := (- a1) / -3.14

Residual equations:
  c = b * a1 - a2 * d
    Iteration variables: a1

Jacobian:
  |-3.14, 1.0|
  |d, - b|
-------------------------------
")})));
    end Differentiation1;

end InitialParameters;
model AssertEval1
	Real x = time;
equation
	assert(true, "Test assertion");

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AssertEval1",
			description="Test assertation evaluation: passed assert",
			flatModel="
fclass TransformCanonicalTests.AssertEval1
 Real x;
equation
 x = time;
end TransformCanonicalTests.AssertEval1;
")})));
end AssertEval1;


model AssertEval2
    Real x = time;
equation
    assert(false, "Test assertion");

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AssertEval2",
            description="Test assertation evaluation: failed assert",
            errorMessage="
1 errors found:

Error in flattened model:
  Assertion failed: Test assertion
")})));
end AssertEval2;

model AssertEval3
    Real x = time;
equation
    when initial() then
        assert(true, "Test assertion");
    end when;
    when initial() then
        assert(true, "Test assertion");
    elsewhen time > 1 then
        assert(true, "Test assertion");
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AssertEval3",
            description="Test assertation evaluation: in when equation",
            flatModel="
fclass TransformCanonicalTests.AssertEval3
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
equation
 temp_1 = time > 1;
 x = time;
end TransformCanonicalTests.AssertEval3;
")})));
end AssertEval3;

model AssertEval4
    Real x = time;
equation
    when initial() then
        assert(false, "Test assertion");
    end when;
    when initial() then
        assert(true, "Test assertion");
    elsewhen time > 1 then
        assert(false, "Test assertion");
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AssertEval4",
            description="Test assertation evaluation: in when equation",
            flatModel="
fclass TransformCanonicalTests.AssertEval4
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
equation
 if initial() then
  assert(false, \"Test assertion\");
 end if;
 temp_1 = time > 1;
 if initial() then
 else
  if temp_1 and not pre(temp_1) then
   assert(false, \"Test assertion\");
  end if;
 end if;
 x = time;
end TransformCanonicalTests.AssertEval4;
")})));
end AssertEval4;

model MetaEqn1
    function F
        input Real i1[:];
    algorithm
        assert(sum(i1) > 0, "Oh, no!");
        annotation(Inline=false);
    end F;
equation
    F({-time,time});

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="MetaEqn1",
            description="Test init BLT for meta equations",
            methodName="printDAEInitBLT",
            methodResult="
--- Meta equation block ---
TransformCanonicalTests.MetaEqn1.F({- time, time})
-------------------------------
")})));
end MetaEqn1;

model MixedVariabilityFunction1
    function F
        input Real x;
        output Real y = 0;
        output Integer z = 0;
    algorithm
        while x > z loop
            y := y + 1;
            z := z + 1;
        end while;
    end F;
    Real x;
    Integer y;
equation
    (x, y) = F(time);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedVariabilityFunction1",
            description="Test matching of mixed variability function call",
            flatModel="
fclass TransformCanonicalTests.MixedVariabilityFunction1
 Real x;
 discrete Integer y;
initial equation 
 pre(y) = 0;
equation
 (x, y) = TransformCanonicalTests.MixedVariabilityFunction1.F(time);

public
 function TransformCanonicalTests.MixedVariabilityFunction1.F
  input Real x;
  output Real y;
  output Integer z;
 algorithm
  y := 0;
  z := 0;
  while x > z loop
   y := y + 1;
   z := z + 1;
  end while;
  return;
 end TransformCanonicalTests.MixedVariabilityFunction1.F;

end TransformCanonicalTests.MixedVariabilityFunction1;
")})));

end MixedVariabilityFunction1;

model MixedVariabilityFunction2
    function F
        input Real x;
        output Real y = 2;
        output Boolean z = false;
    algorithm
        while x > y loop
            y := y + 1;
            z := true;
        end while;
    end F;
    Real x;
    Boolean y;
equation
    (x, y) = F(time);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedVariabilityFunction2",
            description="Test matching of mixed variability function call",
            flatModel="
fclass TransformCanonicalTests.MixedVariabilityFunction2
 Real x;
 discrete Boolean y;
initial equation 
 pre(y) = false;
equation
 (x, y) = TransformCanonicalTests.MixedVariabilityFunction2.F(time);

public
 function TransformCanonicalTests.MixedVariabilityFunction2.F
  input Real x;
  output Real y;
  output Boolean z;
 algorithm
  y := 2;
  z := false;
  while x > y loop
   y := y + 1;
   z := true;
  end while;
  return;
 end TransformCanonicalTests.MixedVariabilityFunction2.F;

end TransformCanonicalTests.MixedVariabilityFunction2;
")})));

end MixedVariabilityFunction2;

model IllegalWhen1_Err
    discrete Real x(start=1);
  equation
    when time > x then
      x = pre(x) + 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IllegalWhen1_Err",
            description="Test illegal when, guard in loop",
            errorMessage="
1 errors found:

Error in flattened model:
  A when-guard is involved in an algebraic loop, consider breaking it using pre() expressions. Equations in block:
temp_1 = time > x
x = if temp_1 and not pre(temp_1) then pre(x) + 1 else pre(x)
")})));
end IllegalWhen1_Err;

model IllegalWhen2_Err
    Real x(start=-1);
    Real y(start=-1);
    Real z(start=0);
  equation

    when {time >= 1,x >= 0.5} then
      z = 2;
    end when;

    when z >= 1 then
      y = 3;
    end when;

	x = y - 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IllegalWhen2_Err",
            description="Test illegal when, guard in loop",
            errorMessage="
1 errors found:

Error in flattened model:
  A when-guard is involved in an algebraic loop, consider breaking it using pre() expressions. Equations in block:
temp_3 = z >= 1
y = if temp_3 and not pre(temp_3) then 3 else pre(y)
x = y - 1
temp_2 = x >= 0.5
z = if temp_1 and not pre(temp_1) or temp_2 and not pre(temp_2) then 2 else pre(z)
")})));
end IllegalWhen2_Err;
  
model IllegalWhen3_Err
    Real x(start=0);
    Real y(start=0);
    Real z(start=0);
  equation

    when time >= 1 then
      x = 2*x + y - 3;
      y = 2*x + 6*y - 1 - z;
    end when;

    y + 3 = time;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IllegalWhen3_Err",
            description="Test illegal when-matching",
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     z

  The following equation(s) could not be matched to any variable:
    y + 3 = time
")})));
end IllegalWhen3_Err;

model BLTError1
    Real x;
    Integer i;
equation
    x = if i > 10 then time else - time;
    42 * (i + 1) = integer(x);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="BLTError1",
            description="Test error message given by BLT when non-real equations are unsolved",
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     i

  The following equation(s) could not be matched to any variable:
    42 * (i + 1) = temp_1
")})));
end BLTError1;

model BLTError2
    Integer i, j;
equation
    i = j + integer(time);
    j = 1/i;

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="BLTError2",
            description="Test error message given by BLT when non-real equation contains a loop",
            errorMessage="
1 errors found:

Error in flattened model:
  Non-real equations contains an algebraic loop:
i = j + temp_1
j = 1 / i
")})));
end BLTError2;

model BLTError3
    Real x;
    Integer i;
algorithm
    x := i;
equation
    x = integer(time);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="BLTError3",
            description="Test error message given by BLT when non-real equations are unsolved",
            errorMessage="
1 errors found:

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     i

  The following equation(s) could not be matched to any variable:
    algorithm
     x := i;
")})));
end BLTError3;

model LinearBlockTest1
    Real x,y,z,a;
    Boolean b;
equation
    x = if b then y else 0.5 * y;
    y = z + 1;
    z = x * time;
    a = sqrt(x * x + y * y + z * z);
    b = a > 1;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LinearBlockTest1",
            description="Test generation of linear blocks with torn non-linear equations that doesn't affect the residuals",
            methodName="printDAEInitBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 2 iteration variables and 2 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  z
  a

Iteration variables:
  y
  x

Solved discrete variables:
  b

Torn equations:
  z := x * time
  a := sqrt(x * x + y * y + z * z)

Continuous residual equations:
  y = z + 1
    Iteration variables: y
  x = if b then y else 0.5 * y
    Iteration variables: x

Discrete equations:
  b := a > 1

Jacobian:
  |1.0, 0.0, 0.0, (- time)|
  |0.0, 1.0, 0.0, 0.0|
  |-1.0, 0.0, 1.0, 0.0|
  |0.0, 0.0, - (if b then 1.0 else 0.5), 1.0|

--- Solved equation ---
pre(b) := false
-------------------------------
")})));
end LinearBlockTest1;

model LinearBlockTest2
    Real x,y,z,a1,a2;
    Boolean b;
equation
    x = if b then y else 0.5 * y;
    y = z + 1;
    z = x * time;
    a1 = sqrt(x * x + y * y + z * z);
    a2 = a1 * 2;
    b = a2 > 1;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LinearBlockTest2",
            description="Test generation of linear blocks with torn non-linear equations that doesn't affect the residuals",
            methodName="printDAEInitBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 2 iteration variables and 3 solved variables ---
Coefficient variability: continuous-time
Torn variables:
  z
  a1
  a2

Iteration variables:
  y
  x

Solved discrete variables:
  b

Torn equations:
  z := x * time
  a1 := sqrt(x * x + y * y + z * z)
  a2 := a1 * 2

Continuous residual equations:
  y = z + 1
    Iteration variables: y
  x = if b then y else 0.5 * y
    Iteration variables: x

Discrete equations:
  b := a2 > 1

Jacobian:
  |1.0, 0.0, 0.0, 0.0, (- time)|
  |0.0, 1.0, 0.0, 0.0, 0.0|
  |0.0, 0.0, 1.0, 0.0, 0.0|
  |-1.0, 0.0, 0.0, 1.0, 0.0|
  |0.0, 0.0, 0.0, - (if b then 1.0 else 0.5), 1.0|

--- Solved equation ---
pre(b) := false
-------------------------------
")})));
end LinearBlockTest2;

model LinearBlockTest3
    Real a, b, c, d, e;
equation
    a = time + d * 2;
    e = a * 2 - d;
    d = c * 2 + a;
algorithm
    when e > 0 then
        b := pre(d) + 1;
        c := b / 2;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="LinearBlockTest3",
            description="Test generation of linear blocks with non-scalar algorithm block in the solved part",
            eliminate_linear_equations=false,
            methodName="printDAEBLT",
            methodResult="
--- Torn mixed linear system (Block 1) of 1 iteration variables and 4 solved variables ---
Coefficient variability: constant
Torn variables:
  a
  e
  b
  c

Iteration variables:
  d

Solved discrete variables:
  temp_1

Torn equations:
  a := time + d * 2
  e := a * 2 + (- d)
  algorithm
    if temp_1 and not pre(temp_1) then
      b := pre(d) + 1;
      c := b / 2;
    end if;

    Assigned variables: b
                        c

Continuous residual equations:
  d = c * 2 + a
    Iteration variables: d

Discrete equations:
  temp_1 := e > 0

Jacobian:
  |1.0, 0.0, 0.0, 0.0, -2|
  |0.0, 1.0, 0.0, 0.0, 0.0|
  |0.0, 0.0, 1.0, 0.0, 0.0|
  |0.0, 0.0, 0.0, 1.0, 0.0|
  |-1.0, 0.0, 0.0, -2, 1.0|
-------------------------------
")})));
end LinearBlockTest3;

model Sample1
    Real x;
equation
    when sample(0,1) then
        x = time * 6.28;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sample1",
            description="Test so that sample operator is extracted correctly",
            flatModel="
fclass TransformCanonicalTests.Sample1
 discrete Real x;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time);
 pre(x) = 0.0;
equation
 x = if temp_1 and not pre(temp_1) then time * 6.28 else pre(x);
 temp_1 = not initial() and time >= pre(_sampleItr_1);
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.Sample1;
")})));
end Sample1;

model Sample2
    Real x;
equation
    when sample(0,1) and time < 20 then
        x = time * 6.28;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sample2",
            description="Test so that sample operator is extracted correctly",
            flatModel="
fclass TransformCanonicalTests.Sample2
 discrete Real x;
 discrete Boolean temp_1;
 discrete Integer _sampleItr_1;
 discrete Boolean temp_2;
initial equation 
 pre(temp_1) = false;
 _sampleItr_1 = if time < 0 then 0 else ceil(time);
 pre(x) = 0.0;
 pre(temp_2) = false;
equation
 temp_2 = temp_1 and time < 20;
 x = if temp_2 and not pre(temp_2) then time * 6.28 else pre(x);
 temp_1 = not initial() and time >= pre(_sampleItr_1);
 _sampleItr_1 = if temp_1 and not pre(temp_1) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < pre(_sampleItr_1) + 1, \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.Sample2;

")})));
end Sample2;

model Sample3
    parameter input Integer a;
    parameter input Integer b;
    Boolean s;
  equation
    s = sample(a, b);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sample3",
            description="Test so that a sample equation is correctly transformed to a when-equation.",
            flatModel="
fclass TransformCanonicalTests.Sample3
 parameter input Integer a;
 parameter input Integer b;
 discrete Boolean s;
 discrete Integer _sampleItr_1;
initial equation 
 pre(s) = false;
 _sampleItr_1 = if time < a then 0 else ceil((time - a) / b);
equation
 s = not initial() and time >= a + pre(_sampleItr_1) * b;
 _sampleItr_1 = if s and not pre(s) then pre(_sampleItr_1) + 1 else pre(_sampleItr_1);
 assert(time < a + (pre(_sampleItr_1) + 1) * b, \"Too long time steps relative to sample interval.\");
end TransformCanonicalTests.Sample3;
")})));
end Sample3;

model InsertTempLHS1
    record R
        Real x;
    end R;
    
    function f
        input Real x;
        output R r = R(x);
    algorithm
        annotation(Inline=false);
    end f;
    
    Real x,y;
equation
    R(-y) = f(x);
    y = 0;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InsertTempLHS1",
            description="Test temps in lhs of function call equation",
            flatModel="
fclass TransformCanonicalTests.InsertTempLHS1
 Real x;
 constant Real y = 0;
 Real temp_3;
equation
 (TransformCanonicalTests.InsertTempLHS1.R(temp_3)) = TransformCanonicalTests.InsertTempLHS1.f(x);
 -0.0 = temp_3;

public
 function TransformCanonicalTests.InsertTempLHS1.f
  input Real x;
  output TransformCanonicalTests.InsertTempLHS1.R r;
 algorithm
  r.x := x;
  return;
 annotation(Inline = false);
 end TransformCanonicalTests.InsertTempLHS1.f;

 record TransformCanonicalTests.InsertTempLHS1.R
  Real x;
 end TransformCanonicalTests.InsertTempLHS1.R;

end TransformCanonicalTests.InsertTempLHS1;
")})));
end InsertTempLHS1;

package Operators
    package Homotopy
        model Simple1
            Real x,y;
        equation
            x = homotopy(x * x,time);
            y = homotopy(y * x,time);
        annotation(__JModelica(UnitTesting(tests={
	        FClassMethodTestCase(
	            name="Operators.Homotopy.Simple1.DAE",
	            description="Simple test that tests DAE BLT generation for homotopy",
                homotopy_type="homotopy",
	            methodName="printDAEBLT",
	            methodResult="
--- Unsolved equation (Block 1) ---
x = homotopy(x * x, time)
  Computed variables: x

--- Unsolved equation (Block 2) ---
y = homotopy(y * x, time)
  Computed variables: y
-------------------------------
"),FClassMethodTestCase(
                name="Operators.Homotopy.Simple1.DAEInit",
                description="Simple test that tests DAE init BLT generation for homotopy",
                homotopy_type="homotopy",
                methodName="printDAEInitBLT",
                methodResult="
--- Homotopy block ---
  --- Unsolved system (Block 1(Homotopy).1) of 2 variables ---
  Unknown variables:
    y ()
    x ()

  Equations:
    y = homotopy(y * x, time)
      Iteration variables: y
    x = homotopy(x * x, time)
      Iteration variables: x

  -------------------------------
  --- Unsolved equation (Block 1(Simplified).1) ---
  y = homotopy(y * x, time)
    Computed variables: y

  --- Unsolved equation (Block 1(Simplified).2) ---
  x = homotopy(x * x, time)
    Computed variables: x
  -------------------------------
-------------------------------
")})));
        end Simple1;
        
        model SuccessorMerge1
            Real x,y,a,b;
        equation
            x = homotopy(x * x,time);
            y = homotopy(y * x,time);
            b = time * 2;
            a = x + y * b;
            
        annotation(__JModelica(UnitTesting(tests={
	        FClassMethodTestCase(
                name="Operators.Homotopy.SuccessorMerge1",
                description="Simple test that tests DAE init BLT generation for homotopy",
                homotopy_type="homotopy",
                methodName="printDAEInitBLT",
                methodResult="
--- Solved equation ---
b := time * 2

--- Homotopy block ---
  --- Unsolved system (Block 1(Homotopy).1) of 2 variables ---
  Unknown variables:
    y ()
    x ()

  Equations:
    y = homotopy(y * x, time)
      Iteration variables: y
    x = homotopy(x * x, time)
      Iteration variables: x
  --- Solved equation ---
  a := x + y * b
  -------------------------------
  --- Unsolved equation (Block 1(Simplified).1) ---
  y = homotopy(y * x, time)
    Computed variables: y

  --- Unsolved equation (Block 1(Simplified).2) ---
  x = homotopy(x * x, time)
    Computed variables: x

  --- Solved equation ---
  a := x + y * b
  -------------------------------
-------------------------------
")})));
        end SuccessorMerge1;
        
        model SubBlocks1
            Real x,y;
        equation
            y = time;
            0 = homotopy(x * y, x);
        
        annotation(__JModelica(UnitTesting(tests={
	        FClassMethodTestCase(
                name="Operators.Homotopy.SubBlocks1",
                description="Tests a bug where block numbers for sub-blocks in homotopy part was generated wrong",
                homotopy_type="homotopy",
                methodName="printDAEInitBLT",
                methodResult="
--- Solved equation ---
y := time

--- Homotopy block ---
  --- Unsolved equation (Block 1(Homotopy).1) ---
  0 = homotopy(x * y, x)
    Computed variables: x
  -------------------------------
  --- Unsolved equation (Block 1(Simplified).1) ---
  0 = homotopy(x * y, x)
    Computed variables: x
  -------------------------------
-------------------------------
")})));
        end SubBlocks1;
        
    end Homotopy;
end Operators;


model ScalarizeIfInLoop1
    parameter Real x[:] = {1} annotation(Evaluate=true);
    Real y[2];
equation
    for i in 1:2 loop
        y[i] = if size(x, 1) < i then 0.0 else time * x[i];
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeIfInLoop1",
            description="Check scalarization of if expression in loop where one branch is invalid for some indices",
            flatModel="
fclass TransformCanonicalTests.ScalarizeIfInLoop1
 eval parameter Real x[1] = 1 /* 1 */;
 Real y[1];
 constant Real y[2] = 0.0;
equation
 y[1] = time;
end TransformCanonicalTests.ScalarizeIfInLoop1;
")})));
end ScalarizeIfInLoop1;


model ScalarizeIfInLoop2
    parameter Real x[:] = {1} annotation(Evaluate=true);
    Real y[2];
equation
    for i in 1:2 loop
        if size(x, 1) < i then
            y[i] = 0.0; 
        else 
            y[i] = time * x[i];
        end if;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeIfInLoop2",
            description="Check scalarization of if equation in loop where one branch is invalid for some indices",
            flatModel="
fclass TransformCanonicalTests.ScalarizeIfInLoop2
 eval parameter Real x[1] = 1 /* 1 */;
 Real y[1];
 constant Real y[2] = 0.0;
equation
 y[1] = time;
end TransformCanonicalTests.ScalarizeIfInLoop2;
")})));
end ScalarizeIfInLoop2;


model ScalarizeIfInLoop3
    parameter Real x[:] = {1} annotation(Evaluate=true);
    Real y[2];
equation
    for i in 1:2 loop
        if size(x, 1) >= i then
            y[i] = time * x[i];
        else 
            y[i] = 0.0; 
        end if;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeIfInLoop3",
            description="Check scalarization of if equation in loop where one branch is invalid for some indices",
            flatModel="
fclass TransformCanonicalTests.ScalarizeIfInLoop3
 eval parameter Real x[1] = 1 /* 1 */;
 Real y[1];
 constant Real y[2] = 0.0;
equation
 y[1] = time;
end TransformCanonicalTests.ScalarizeIfInLoop3;
")})));
end ScalarizeIfInLoop3;


model ScalarizeIfInLoop4
    Real y[1];
equation
    for i in 1:2 loop
        if size(y, 1) >= i then
            y[i] = time;
        end if;
    end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeIfInLoop4",
            description="Check scalarization of if equation in loop where no branch is active for some indices",
            flatModel="
fclass TransformCanonicalTests.ScalarizeIfInLoop4
 Real y[1];
equation
 y[1] = time;
end TransformCanonicalTests.ScalarizeIfInLoop4;
")})));
end ScalarizeIfInLoop4;

model ScalarizeCrossInFunction
    function f
        input Real[3] a;
        input Real[3] b;
        output Real[3] c;
    algorithm
        c := cross(a, g(b));
    end f;
    
    function g
        input Real[3] a;
        output Real[3] b;
    algorithm
        b := -a;
    end g;
    
    Real[3] a = {0.5,0.5,0};
    Real[3] b = {0.5,-.5,0};
    Real[3] c = f(a, b);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeCrossInFunction",
            description="Test scalarization of cross in a function",
            variability_propagation=false,
            eliminate_alias_constants=false,
            inline_functions="none",
            flatModel="
fclass TransformCanonicalTests.ScalarizeCrossInFunction
 Real a[1];
 Real a[2];
 Real a[3];
 Real b[1];
 Real b[2];
 Real b[3];
 Real c[1];
 Real c[2];
 Real c[3];
equation
 a[1] = 0.5;
 a[2] = 0.5;
 a[3] = 0;
 b[1] = 0.5;
 b[2] = -0.5;
 b[3] = 0;
 ({c[1], c[2], c[3]}) = TransformCanonicalTests.ScalarizeCrossInFunction.f({a[1], a[2], a[3]}, {b[1], b[2], b[3]});

public
 function TransformCanonicalTests.ScalarizeCrossInFunction.f
  input Real[:] a;
  input Real[:] b;
  output Real[:] c;
  Real[:] temp_1;
  Real[:] temp_2;
 algorithm
  init c as Real[3];
  init temp_1 as Real[3];
  init temp_2 as Real[3];
  (temp_2) := TransformCanonicalTests.ScalarizeCrossInFunction.g(b);
  temp_1[1] := a[2] * temp_2[3] - a[3] * temp_2[2];
  temp_1[2] := a[3] * temp_2[1] - a[1] * temp_2[3];
  temp_1[3] := a[1] * temp_2[2] - a[2] * temp_2[1];
  for i1 in 1:3 loop
   c[i1] := temp_1[i1];
  end for;
  return;
 end TransformCanonicalTests.ScalarizeCrossInFunction.f;

 function TransformCanonicalTests.ScalarizeCrossInFunction.g
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[3];
  for i1 in 1:3 loop
   b[i1] := - a[i1];
  end for;
  return;
 end TransformCanonicalTests.ScalarizeCrossInFunction.g;

end TransformCanonicalTests.ScalarizeCrossInFunction;
")})));
end ScalarizeCrossInFunction;

model ScalarizeSkewInFunction
    function f
        input Real[3] a;
        output Real[3, 3] b;
    algorithm
        b := skew(g(a));
    end f;
    
    function g
        input Real[3] a;
        output Real[3] b;
    algorithm
        b := -a;
    end g;
    
    Real[3] a = {0.5,0.5,0};
    Real[3, 3] b = f(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeSkewInFunction",
            description="Test scalarization of skew in a function",
            variability_propagation=false,
            eliminate_alias_constants=false,
            eliminate_alias_variables=false,
            inline_functions="none",
            flatModel="
fclass TransformCanonicalTests.ScalarizeSkewInFunction
 Real a[1];
 Real a[2];
 Real a[3];
 Real b[1,1];
 Real b[1,2];
 Real b[1,3];
 Real b[2,1];
 Real b[2,2];
 Real b[2,3];
 Real b[3,1];
 Real b[3,2];
 Real b[3,3];
equation
 a[1] = 0.5;
 a[2] = 0.5;
 a[3] = 0;
 ({{b[1,1], b[1,2], b[1,3]}, {b[2,1], b[2,2], b[2,3]}, {b[3,1], b[3,2], b[3,3]}}) = TransformCanonicalTests.ScalarizeSkewInFunction.f({a[1], a[2], a[3]});

public
 function TransformCanonicalTests.ScalarizeSkewInFunction.f
  input Real[:] a;
  output Real[:,:] b;
  Real[:,:] temp_1;
  Real[:] temp_2;
 algorithm
  init b as Real[3, 3];
  init temp_1 as Real[3, 3];
  init temp_2 as Real[3];
  (temp_2) := TransformCanonicalTests.ScalarizeSkewInFunction.g(a);
  temp_1[1,1] := 0;
  temp_1[1,2] := - temp_2[3];
  temp_1[1,3] := temp_2[2];
  temp_1[2,1] := temp_2[3];
  temp_1[2,2] := 0;
  temp_1[2,3] := - temp_2[1];
  temp_1[3,1] := - temp_2[2];
  temp_1[3,2] := temp_2[1];
  temp_1[3,3] := 0;
  for i1 in 1:3 loop
   for i2 in 1:3 loop
    b[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end TransformCanonicalTests.ScalarizeSkewInFunction.f;

 function TransformCanonicalTests.ScalarizeSkewInFunction.g
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[3];
  for i1 in 1:3 loop
   b[i1] := - a[i1];
  end for;
  return;
 end TransformCanonicalTests.ScalarizeSkewInFunction.g;

end TransformCanonicalTests.ScalarizeSkewInFunction;
")})));
end ScalarizeSkewInFunction;

model ScalarizeSymmetricInFunction
    function f
        input  Real[2,2] a;
        output Real[2,2] b;
    algorithm
        b := symmetric(g(a));
    end f;
    
    function g
        input  Real[:,:] a;
        output Real[size(a, 1), size(a, 2)] b;
    algorithm
        b := -a;
    end g;
    
    Real[2, 2] a = [1,2;3,4];
    Real[2, 2] b = f(a);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeSymmetricInFunction",
            description="Test scalarization of symmetric in a function",
            eliminate_alias_constants=false,
            eliminate_alias_variables=false,
            flatModel="
fclass TransformCanonicalTests.ScalarizeSymmetricInFunction
 constant Real a[1,1] = 1;
 constant Real a[1,2] = 2;
 constant Real a[2,1] = 3;
 constant Real a[2,2] = 4;
 constant Real b[1,1] = -1.0;
 constant Real b[1,2] = -2.0;
 constant Real b[2,1] = -2.0;
 constant Real b[2,2] = -4.0;
end TransformCanonicalTests.ScalarizeSymmetricInFunction;
")})));
end ScalarizeSymmetricInFunction;

model ScalarizeOuterProductInFunction
    function f
        input  Real[2] v1;
        input  Real[2] v2;
        output Real[2,2] o;
    algorithm
        o := outerProduct(v1, g(v2));
    end f;
    
    function g
        input Real[:] a;
        output Real[size(a, 1)] b;
    algorithm
        b := -a;
    end g;
    
    Real[2] a = {1,2};
    Real[2] b = {3,4};
    Real[2,2] c = f(a, b);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeOuterProductInFunction",
            description="Test scalarization of symmetric in a function",
            eliminate_alias_constants=false,
            eliminate_alias_variables=false,
            flatModel="fclass TransformCanonicalTests.ScalarizeOuterProductInFunction
 constant Real a[1] = 1;
 constant Real a[2] = 2;
 constant Real b[1] = 3;
 constant Real b[2] = 4;
 constant Real c[1,1] = -3.0;
 constant Real c[1,2] = -4.0;
 constant Real c[2,1] = -6.0;
 constant Real c[2,2] = -8.0;
end TransformCanonicalTests.ScalarizeOuterProductInFunction;
")})));
end ScalarizeOuterProductInFunction;

model ScalarizeMulExpArrayArgumentInFunction
    function f
        input  Real[3] x;
        output Real[2] y;
    algorithm
        y := g(3 * x[1:2]);
    end f;
    
    function g
        input Real[:] a;
        output Real[size(a, 1)] b;
    algorithm
        b := -a;
    end g;
    
    Real[:] a = {1,2,3};
    Real[:] z = f(a);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeMulExpArrayArgumentInFunction",
            description="Test scalarization of symmetric in a function",
            eliminate_alias_constants=false,
            eliminate_alias_variables=false,
            flatModel="
fclass TransformCanonicalTests.ScalarizeMulExpArrayArgumentInFunction
 constant Real a[1] = 1;
 constant Real a[2] = 2;
 constant Real a[3] = 3;
 constant Real z[1] = -3.0;
 constant Real z[2] = -6.0;
end TransformCanonicalTests.ScalarizeMulExpArrayArgumentInFunction;
")})));
end ScalarizeMulExpArrayArgumentInFunction;

model ScalarizeSliceInFunctionCallLeftInFunction
    function f
        input  Real[3] x;
        output Real[1,3] y;
    algorithm
        (y[1,:]) := g(x);
    end f;
    
    function g
        input Real[:] a;
        output Real[size(a, 1)] b;
    algorithm
        b := -a;
    end g;
    
    Real[:] a = {1,2,3};
    Real[1,:] z = f(a);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeSliceInFunctionCallLeftInFunction",
            description="Test scalarization of slice in a function call left",
            eliminate_alias_constants=false,
            eliminate_alias_variables=false,
            variability_propagation=false,
            inline_functions=none,
            flatModel="
fclass TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction
 Real a[1];
 Real a[2];
 Real a[3];
 Real z[1,1];
 Real z[1,2];
 Real z[1,3];
equation
 a[1] = 1;
 a[2] = 2;
 a[3] = 3;
 ({{z[1,1], z[1,2], z[1,3]}}) = TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction.f({a[1], a[2], a[3]});

public
 function TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction.f
  input Real[:] x;
  output Real[:,:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[1, 3];
  init temp_1 as Real[3];
  (temp_1) := TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction.g(x);
  for i1 in 1:3 loop
   y[1,i1] := temp_1[i1];
  end for;
  return;
 end TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction.f;

 function TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction.g
  input Real[:] a;
  output Real[:] b;
 algorithm
  init b as Real[size(a, 1)];
  for i1 in 1:size(a, 1) loop
   b[i1] := - a[i1];
  end for;
  return;
 end TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction.g;

end TransformCanonicalTests.ScalarizeSliceInFunctionCallLeftInFunction;
")})));
end ScalarizeSliceInFunctionCallLeftInFunction;


model ForOfUnknownSize1
    function f
        input Real[:] y;
        output Real x;
    algorithm
        x := 0;
        for v in y loop
            x := x + v;
        end for;
    end f;
    
    parameter Integer n = 4;
    Real x = f(y);
    Real y[n] = (1:n) * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ForOfUnknownSize1",
            description="Scalarization of for loop over unknown size array: array variable",
            flatModel="
fclass TransformCanonicalTests.ForOfUnknownSize1
 structural parameter Integer n = 4 /* 4 */;
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
equation
 x = TransformCanonicalTests.ForOfUnknownSize1.f({y[1], y[2], y[3], y[4]});
 y[1] = time;
 y[2] = 2 * y[1];
 y[3] = 3 * y[1];
 y[4] = 4 * y[1];
 
public
 function TransformCanonicalTests.ForOfUnknownSize1.f
  input Real[:] y;
  output Real x;
 algorithm
  x := 0;
  for v in y loop
   x := x + v;
  end for;
  return;
 end TransformCanonicalTests.ForOfUnknownSize1.f;

end TransformCanonicalTests.ForOfUnknownSize1;
")})));
end ForOfUnknownSize1;


model ForOfUnknownSize2
    function f
        input Integer n;
        output Real x;
    algorithm
        x := 0;
        for i in 1:n loop
            x := x + i;
        end for;
    end f;
    
    Integer n = integer(time);
    Real x = f(n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ForOfUnknownSize2",
            description="Scalarization of for loop over unknown size array: range exp",
            flatModel="
fclass TransformCanonicalTests.ForOfUnknownSize2
 discrete Integer n;
 Real x;
initial equation 
 pre(n) = 0;
equation
 x = TransformCanonicalTests.ForOfUnknownSize2.f(n);
 n = if time < pre(n) or time >= pre(n) + 1 or initial() then integer(time) else pre(n);

public
 function TransformCanonicalTests.ForOfUnknownSize2.f
  input Integer n;
  output Real x;
 algorithm
  x := 0;
  for i in 1:n loop
   x := x + i;
  end for;
  return;
 end TransformCanonicalTests.ForOfUnknownSize2.f;

end TransformCanonicalTests.ForOfUnknownSize2;
")})));
end ForOfUnknownSize2;


model ForOfUnknownSize3
    function f
        input Integer n;
        output Real x;
    algorithm
        x := 0;
        for i in (1:n).^2 loop
            x := x + i;
        end for;
    end f;
    
    Integer n = integer(time);
    Real x = f(n);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ForOfUnknownSize3",
            description="Scalarization of for loop over unknown size array: general array exp",
            flatModel="
fclass TransformCanonicalTests.ForOfUnknownSize3
 discrete Integer n;
 Real x;
initial equation 
 pre(n) = 0;
equation
 x = TransformCanonicalTests.ForOfUnknownSize3.f(n);
 n = if time < pre(n) or time >= pre(n) + 1 or initial() then integer(time) else pre(n);

public
 function TransformCanonicalTests.ForOfUnknownSize3.f
  input Integer n;
  output Real x;
  Real[:] temp_1;
 algorithm
  x := 0;
  init temp_1 as Real[max(n, 0)];
  for i1 in 1:max(n, 0) loop
   temp_1[i1] := i1 .^ 2;
  end for;
  for i in temp_1 loop
   x := x + i;
  end for;
  return;
 end TransformCanonicalTests.ForOfUnknownSize3.f;

end TransformCanonicalTests.ForOfUnknownSize3;
")})));
end ForOfUnknownSize3;


model ForOfUnknownSize4
    function f
        input Real[:] y;
        output Real x;
    algorithm
        x := 0;
        for v in y[2:end] loop
            x := x + v;
        end for;
    end f;
    
    parameter Integer n = 4;
    Real x = f(y);
    Real y[n] = (1:n) * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ForOfUnknownSize4",
            description="Scalarization of for loop over unknown size array: slice",
            flatModel="
fclass TransformCanonicalTests.ForOfUnknownSize4
 structural parameter Integer n = 4 /* 4 */;
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
equation
 x = TransformCanonicalTests.ForOfUnknownSize4.f({y[1], y[2], y[3], y[4]});
 y[1] = time;
 y[2] = 2 * y[1];
 y[3] = 3 * y[1];
 y[4] = 4 * y[1];
 
public
 function TransformCanonicalTests.ForOfUnknownSize4.f
  input Real[:] y;
  output Real x;
  Real[:] temp_1;
 algorithm
  x := 0;
  init temp_1 as Real[max(integer(size(y, 1) - 2) + 1, 0)];
  for i1 in 1:max(integer(size(y, 1) - 2) + 1, 0) loop
   temp_1[i1] := y[2 + (i1 - 1)];
  end for;
  for v in temp_1 loop
   x := x + v;
  end for;
  return;
 end TransformCanonicalTests.ForOfUnknownSize4.f;

end TransformCanonicalTests.ForOfUnknownSize4;
")})));
end ForOfUnknownSize4;


model ForOfUnknownSize5
    function f
        input Real[2,:] y;
        output Real x;
    algorithm
        x := 0;
        for v in y[2,:] loop
            x := x + v;
        end for;
    end f;
    
    parameter Integer n = 4;
    Real x = f(y);
    Real y[2,n] = {1:n, 2:n+1} * time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ForOfUnknownSize5",
            description="Scalarization of for loop over unknown size array: select one row from matrix",
            flatModel="
fclass TransformCanonicalTests.ForOfUnknownSize5
 structural parameter Integer n = 4 /* 4 */;
 Real x;
 Real y[1,1];
 Real y[1,2];
 Real y[1,3];
 Real y[1,4];
 Real y[2,1];
 Real y[2,2];
 Real y[2,3];
 Real y[2,4];
equation
 x = TransformCanonicalTests.ForOfUnknownSize5.f({{y[1,1], y[1,2], y[1,3], y[1,4]}, {y[2,1], y[2,2], y[2,3], y[2,4]}});
 y[1,1] = time;
 y[1,2] = 2 * y[1,1];
 y[1,3] = 3 * y[1,1];
 y[1,4] = 4 * y[1,1];
 y[2,1] = y[1,2];
 y[2,2] = y[1,3];
 y[2,3] = y[1,4];
 y[2,4] = 5 * y[1,1];
 
public
 function TransformCanonicalTests.ForOfUnknownSize5.f
  input Real[:,:] y;
  output Real x;
  Real[:] temp_1;
 algorithm
  x := 0;
  init temp_1 as Real[size(y, 2)];
  for i1 in 1:size(y, 2) loop
   temp_1[i1] := y[2,i1];
  end for;
  for v in temp_1 loop
   x := x + v;
  end for;
  return;
 end TransformCanonicalTests.ForOfUnknownSize5.f;

end TransformCanonicalTests.ForOfUnknownSize5;
")})));
end ForOfUnknownSize5;

model FunctionWithZeroSizeOutput1
    function f
        input Real[:] x;
        input Integer n;
        output Real[size(x,1)] y;
        output Real[size(x,1) - n] z;
    algorithm
        y := x .+ 1;
        y := y .* 2;
    end f;
    
    Real x[2];
    Real y[2];
    Real z[0];
equation
    (y, z) = f(x, 2);
    der(x) = {y[2], time};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionWithZeroSizeOutput1",
            description="",
            flatModel="
fclass TransformCanonicalTests.FunctionWithZeroSizeOutput1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
initial equation
 x[1] = 0.0;
 x[2] = 0.0;
equation
 ({y[1], y[2]}, ) = TransformCanonicalTests.FunctionWithZeroSizeOutput1.f({x[1], x[2]}, 2);
 der(x[1]) = y[2];
 der(x[2]) = time;

public
 function TransformCanonicalTests.FunctionWithZeroSizeOutput1.f
  input Real[:] x;
  input Integer n;
  output Real[:] y;
  output Real[:] z;
  Real[:] temp_1;
 algorithm
  init y as Real[size(x, 1)];
  init z as Real[size(x, 1) - n];
  for i1 in 1:size(x, 1) loop
   y[i1] := x[i1] .+ 1;
  end for;
  init temp_1 as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   temp_1[i1] := y[i1] .* 2;
  end for;
  for i1 in 1:size(x, 1) loop
   y[i1] := temp_1[i1];
  end for;
  return;
 end TransformCanonicalTests.FunctionWithZeroSizeOutput1.f;

end TransformCanonicalTests.FunctionWithZeroSizeOutput1;
")})));
end FunctionWithZeroSizeOutput1;


model FunctionWithZeroSizeOutput2
    function f
        input Real[2] x;
        output Real[2] y;
        output Real[0] z;
    algorithm
        y := x .+ 1;
        end f;
    
    Real x[2];
    Real y[2];
    Real z[0];
equation
    (y, z) = f(x);
    der(x) = {y[2], time};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionWithZeroSizeOutput2",
            description="",
            inline_functions="none",
            flatModel="
fclass TransformCanonicalTests.FunctionWithZeroSizeOutput2
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
initial equation
 x[1] = 0.0;
 x[2] = 0.0;
equation
 ({y[1], y[2]}, ) = TransformCanonicalTests.FunctionWithZeroSizeOutput2.f({x[1], x[2]});
 der(x[1]) = y[2];
 der(x[2]) = time;

public
 function TransformCanonicalTests.FunctionWithZeroSizeOutput2.f
  input Real[:] x;
  output Real[:] y;
  output Real[:] z;
 algorithm
  init y as Real[2];
  init z as Real[0];
  for i1 in 1:2 loop
   y[i1] := x[i1] .+ 1;
  end for;
  return;
 end TransformCanonicalTests.FunctionWithZeroSizeOutput2.f;
 
end TransformCanonicalTests.FunctionWithZeroSizeOutput2;
")})));
end FunctionWithZeroSizeOutput2;

end TransformCanonicalTests;
