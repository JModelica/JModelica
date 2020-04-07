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

package CheckTests

model InnerOuter1
    partial model A
        Real x;
    end A;
    
    outer A a;
equation
    a.x = true; // To generate another error to show up in an error check

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuter1",
            description="Check that error is not generated for partial outer without inner in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 8, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', TYPE_MISMATCH_IN_EQUATION:
  The right and left expression types of equation are not compatible, type of left-hand side is Real, and type of right-hand side is Boolean
")})));
end InnerOuter1;


model InnerOuter2
    partial model A
        function f
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
        end f;
    end A;
    
    outer A a;
    Real z = a.f(time);
    Real w = true; // To generate another error to show up in an error check

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuter2",
            description="Check that no extra errors are generated for function called through outer withour inner",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 13, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable w does not match the declared type of the variable
")})));
end InnerOuter2;


model InnerOuter3
    model A
        outer Real x;
    end A;
    
    Real x;
    A a;
    Real w = true; // To generate another error to show up in an error check

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuter3",
            description="Check that error is not generated in check mode for outer without inner and component on top level with same name",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 8, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable w does not match the declared type of the variable
")})));
end InnerOuter3;


model InnerOuter4
    model A
        outer Real x;
    end A;
    
    model B
        outer Integer x;
    end B;
    
    A a;
    B b;
    Real w = true; // To generate another error to show up in an error check

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuter4",
            description="Check that error is not generated for multiple outers without inner with same name but different types in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 12, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable w does not match the declared type of the variable
")})));
end InnerOuter4;


model InnerOuter5
    model A
        outer Real x;
    equation
        x = time;
    end A;
    
    A a;
    parameter Real w; // To generate another warning to show up in an error check

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="InnerOuter5",
            description="Check that warning is not generated for outer without inner in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Warning at line 9, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter w does not have a binding expression
")})));
end InnerOuter5;



model ConditionalError1
	model A
		Real x = true;
	end A;
	
	A a if b;
	parameter Boolean b = false;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ConditionalError1",
            description="Check that errors in conditional components are found in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 3, column 12, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH,
In component a:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ConditionalError1;


model ConditionalError2
    model A
        Real x = true;
    end A;
    
    A a if b;
    parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalError2",
			description="Check that inactive conditional components aren't error checked in compile mode",
			flatModel="
fclass CheckTests.ConditionalError2
 parameter Boolean b = false /* false */;
end CheckTests.ConditionalError2;
")})));
end ConditionalError2;


model ConditionalError3
	type B = enumeration(c, d);
	
	function f
		input Real x;
		output Real y;
	algorithm
		y := x * x;
	end f;
	
    model A
        B x = if f(time) > 2 then B.c else B.d;
    end A;
    
    A a if b;
    parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalError3",
			description="Check that inactive conditional components aren't searched for used functions and enums when flattening in compile mode",
			flatModel="
fclass CheckTests.ConditionalError3
 parameter Boolean b = false /* false */;
end CheckTests.ConditionalError3;
")})));
end ConditionalError3;


model ConditionalError4
    model A
        Real x = true;
    end A;
    
    A a if b;
    parameter Boolean b = false;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ConditionalError4",
            description="Check that errors in conditional components are found in compile mode when using the check_inactive_contitionals option",
            check_inactive_contitionals=true,
            errorMessage="
1 errors found:

Error at line 3, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH,
In component a:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ConditionalError4;


model ConditionalError5
    model A
        parameter Integer n = 1;
        Real x[n] = (1:n) * time;
        Real y = x[1] + 1;
    end A;
    
    parameter Integer n = 0;
    A a(n=n) if n > 0;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConditionalError5",
            description="Check that array bounds errors are allowed in disabled conditionals in check mode",
            checkType=check,
            flatModel="
fclass CheckTests.ConditionalError5
 structural parameter Integer n = 0 /* 0 */;
end CheckTests.ConditionalError5;
")})));
end ConditionalError5;

model ConditionalError6
    model A
        outer Real x;
    equation
        x = time;
    end A;
    
    A a;
    inner Real x if p;
    parameter Boolean p = false;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConditionalError6",
            description="Conditional inner. This should probably give an error. See #4631.",
            checkType=check,
            flatModel="
fclass CheckTests.ConditionalError6
 structural parameter Boolean p = false /* false */;
equation
 x = time;
end CheckTests.ConditionalError6;
")})));
end ConditionalError6;


model ParamBinding1
	type B = enumeration(a,b,c);
	model A
	    parameter B b;
	    Real x;
		parameter Real z[if b == B.b then 2 else 1] = ones(size(z,1));
	equation
		if b == B.b then
			x = z[2];
	    else
		    x = time;
		end if;
	end A;
	
    parameter B b2;
	A a(b = b2);
	Integer y = 1.2; // Generate an error to be able to use error test case

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ParamBinding1",
            description="Check that no error messages are generated for structural parameters without binding expression in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 17, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end ParamBinding1;


model ParamBinding2
	replaceable function f
		input Real x;
		output real y; 
	end f;
	
	constant Real p = f(1);
    Integer y = 1.2; // Generate an error to be able to use error test case

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ParamBinding2",
            description="Check that no error messages are generated for structural parameters that can't be evaluated in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 8, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end ParamBinding2;


model ArraySize1
	parameter Integer n = size(x, 1);
    Real x[:];
    Real y[n];
    Real z[size(x, 1)];
	
    Integer e = 1.2; // Generate an error to be able to use error test case

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ArraySize1",
            description="Check that no error message is generated for incomplete array size in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 7, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable e does not match the declared type of the variable
")})));
end ArraySize1;

model ArraySize2
    function f
        input Integer n;
        input Integer[n] x;
        output Integer[n] y;
    algorithm
        for k in 1:n loop
            y[1:k] := y[1:k] + fill(x[k],k);
        end for;
    end f;
    model M
        constant Integer n = sum(f(1, {1}));
        constant Real[:] y1 = 1:n;
    end M;
    constant Real[:] c = m.y1;
    M m;
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ArraySize2",
            description="Check that functions is error checked before evaluation",
            flatModel="
fclass CheckTests.ArraySize2
 constant Real c[1] = {1};
 constant Integer m.n = 1;
 constant Real m.y1[1] = {1};

public
 function CheckTests.ArraySize2.f
  input Integer n;
  input Integer[:] x;
  output Integer[:] y;
 algorithm
  assert(n == size(x, 1), \"Mismatching sizes in function 'CheckTests.ArraySize2.f', component 'x', dimension '1'\");
  init y as Integer[n];
  for k in 1:n loop
   y[1:k] := y[1:k] + fill(x[k], k);
  end for;
  return;
 end CheckTests.ArraySize2.f;

end CheckTests.ArraySize2;
")})));
end ArraySize2;

model FunctionNoAlgorithm1
    replaceable function f
        input Real x;
        output Real y;
    end f;
    
    Real z = f(time);
    Integer y = 1.2; // Generate an error to be able to use error test case

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="FunctionNoAlgorithm1",
            description="Check that no error message is generated replaceable incomplete function in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 8, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end FunctionNoAlgorithm1;


model FunctionNoAlgorithm2
    replaceable package A
		function f
	        input Real x;
	        output Real y;
	    end f;
    end A;
    
    Real z = A.f(time);
    Integer y = 1.2; // Generate an error to be able to use error test case

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="FunctionNoAlgorithm2",
            description="Check that no error message is generated incomplete function in replaceable package in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 10, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end FunctionNoAlgorithm2;


model FunctionNoAlgorithm3
    function f
        input Real x;
        output Real y;
    end f;
    
    Real z = f(time);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="FunctionNoAlgorithm3",
            description="Check that errors are generated for use of incomplete non-replaceable function in check mode",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 7, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));
end FunctionNoAlgorithm3;


model FunctionNoAlgorithm4
    function f
        input Real x;
        output Real y;
    end f;
    
    function f2 = f3;
    
    replaceable function f3 = f;

    Real z = f2(time);
    Integer y = 1.2; // Generate an error to be able to use error test case

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionNoAlgorithm4",
            description="",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 12, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end FunctionNoAlgorithm4;


model FunctionNoAlgorithm5
    function f
        input Real x;
        output Real y;
    end f;
    
    model A
        replaceable function f2 = f;
        Real z = f2(time);
    end A;
    
    replaceable function f3 = f;

    A a(redeclare function f2 = f3);
    Integer y = 1.2; // Generate an error to be able to use error test case

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FunctionNoAlgorithm5",
            description="",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 15, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end FunctionNoAlgorithm5;



model IfEquationElse1
  Real x;
equation
  der(x) = time;
  if time > 1 then
    assert(time > 2, "msg");
  else
  end if;
  when time > 2 then
    if time > 1 then
      reinit(x,1);
    else
    end if;
  end when;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationElse1",
			description="Test empty else",
			flatModel="
fclass CheckTests.IfEquationElse1
 Real x(stateSelect = StateSelect.always);
 discrete Boolean temp_1;
initial equation 
 x = 0.0;
 pre(temp_1) = false;
equation
 der(x) = time;
 if time > 1 then
  assert(time > 2, \"msg\");
 end if;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  if time > 1 then
   reinit(x, 1);
  end if;
 end if;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end CheckTests.IfEquationElse1;
")})));
end IfEquationElse1;

model IfEquationElse2
  Real x;
equation
  der(x) = time;
  if time > 1 then
    assert(time > 2, "msg");
  end if;
  when time > 2 then
    if time > 1 then
      reinit(x,1);
    end if;
  end when;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationElse2",
			description="Test no else",
			flatModel="
fclass CheckTests.IfEquationElse2
 Real x(stateSelect = StateSelect.always);
 discrete Boolean temp_1;
initial equation 
 x = 0.0;
 pre(temp_1) = false;
equation
 der(x) = time;
 if time > 1 then
  assert(time > 2, \"msg\");
 end if;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  if time > 1 then
   reinit(x, 1);
  end if;
 end if;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end CheckTests.IfEquationElse2;
")})));
end IfEquationElse2;

model IfEquationElse3
  Real x;
equation
  if time > 2 then
  else
    assert(time < 2, "msg");
    x = 1;
  end if;
  x = 2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IfEquationElse3",
            description="Check error for imbalanced else clause with empty if clause.",
            errorMessage="
1 errors found:

Error at line 4, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  All branches in if equation with non-parameter tests must have the same number of equations
")})));
end IfEquationElse3;

model BreakWithoutLoop
    Real[2] x;
algorithm
    for i in 1:2 loop
        break;
        x[i] := i;
    end for;
    break;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BreakWithoutLoop",
            description="Test errors for break statement without enclosing loop",
            errorMessage="
1 errors found:

Error at line 8, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Break statement must be inside while- or for-statement
")})));
end BreakWithoutLoop;

model ComponentNameError1
    model A
        Real x = true;
    end A;
    
    A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ComponentNameError1",
            description="Check so that the option component_names_in_errors shows components names in errors",
            component_names_in_errors=true,
            errorMessage="
1 errors found:

Error at line 3, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH,
In component a:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ComponentNameError1;

model ComponentNameError2
    model A
        Real x = true;
    end A;
    
    A a1;
    A a2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ComponentNameError2",
            description="Check so that the option component_names_in_errors shows components names in errors",
            component_names_in_errors=true,
            errorMessage="
1 errors found:

Error at line 3, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH,
In components:
    a1
    a2
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ComponentNameError2;

model FilterWarnings1
    parameter String s1;
    
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="FilterWarnings1",
            description="Check so that filtering of warnings works",
            filter_warnings="PARAMETER_MISSING_BINDING_EXPRESSION",
            errorMessage="
1 warnings found:

Warning in flattened model:
  1 warning(s) has been ignored due to the 'filter_warnings' option
")})));
end FilterWarnings1;

model FilterWarnings2
    model A
        Real x(start=1) = 1;
    end A;
    
    model B
        extends A;
        Real x = 1;
    end B;
    
    B b;
    parameter String s1;
    
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="FilterWarnings2",
            description="Check so that filtering of multiple types of warnings works",
            filter_warnings="PARAMETER_MISSING_BINDING_EXPRESSION,UNABLE_TO_INFER_EQUALITY_FOR_DUPLICATES",
            errorMessage="
1 warnings found:

Warning in flattened model:
  2 warning(s) has been ignored due to the 'filter_warnings' option
")})));
end FilterWarnings2;

package ExtObj

model ExtObjConstructor
  model EO
    extends ExternalObject;
    function constructor
        output EO o;
        external;
    end constructor;
    
    function destructor
        input EO o;
        external;
    end destructor;
  end EO;
  
  function wrap
    input  EO eo1 = EO(); // EO default input not allowed
    output EO eo2 = EO(); // EO output not allowed
    protected
      EO eo3 = EO(); // Ok
      Real x1 = use(eo3); // Ok
      Real x2 = use(EO()); // Non-bound constructor not allowed
    algorithm
  end wrap;
  
  function use
    input EO eo; // Ok
    output Real x = 1;
    algorithm
  end use;
    
  EO eo1 = EO(); // Ok
  EO eo2 = wrap(); // Type error or error generated in wrap
  
  Real x1 = use(eo1); // Ok
  Real x2 = use(EO()); // Non-bound constructor not allowed
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExtObjConstructor",
            description="Check that external object constructor is only allowed as binding expression",
            checkType="check",
            errorMessage="
2 errors found:

Error at line 21, column 21, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Constructors for external objects can only be used as binding expressions

Error at line 35, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Constructors for external objects can only be used as binding expressions
")})));
end ExtObjConstructor;

model ExtObjConstructor2
    model X
        extends ExternalObject;
        function constructor
            output X x;
            external "C";
        end constructor;
        function destructor
            input X x;
            external "C";
        end destructor;
    end X;
    
    model X1
        extends X;
        extends ExternalObject;
    end X1;
    
    parameter X x;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExtObjConstructor2",
            description="No external object binding expression",
            errorMessage="
1 errors found:

Error at line 19, column 5, in file '...', EXTERNAL_OBJECT_MISSING_BINDING_EXPRESSION:
  The external object 'x' does not have a binding expression
")})));
end ExtObjConstructor2;

model ExtObjConstructor3
    model X
        extends ExternalObject;
        function constructor
            output X x;
            external "C";
        end constructor;
        function destructor
            input X x;
            external "C";
        end destructor;
    end X;
    
    parameter X x;
    
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ExtObjConstructor3",
            description="No external object binding expression, no error with check target",
            checkType="check",
            errorMessage="
Warning at line 14, column 5, in file '...', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter x does not have a binding expression
")})));
end ExtObjConstructor3;

end ExtObj;

package Functional

model PartialCall1
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
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
    
    Real y1 = usePartFunc(fullFunc(), time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Functional_PartialCall1",
            description="Check error when leaving out function key word",
            errorMessage="
2 errors found:

Error at line 22, column 27, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function fullFunc(): missing argument for required input x

Error at line 22, column 27, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function usePartFunc(): types of positional argument 1 and input pf are not compatible
    type of 'fullFunc()' is Real
    expected type is ((Real y) = CheckTests.Functional.PartialCall1.partFunc(Real x))
")})));
end PartialCall1;

model PartialCall2
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      algorithm
        y := partFunc(x);
    end usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(), time) + partFunc(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Functional_PartialCall2",
            description="Check error when calling partial function declaration directly",
            errorMessage="
2 errors found:

Error at line 19, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function partFunc(): can only call functions that have one algorithm section or external function specification

Error at line 22, column 56, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function partFunc(): can only call functions that have one algorithm section or external function specification
")})));
end PartialCall2;

model NumArgs1
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x2;
        output Real y2;
      algorithm
        y := x*x2;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      algorithm
        y := pf(x,x) + pf();
    end usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(), time);
    Real y2 = usePartFunc(function fullFunc(x=y1,x2=y1), y1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Functional_NumArgs1",
            description="Check missing and extra arguments for functional inputs",
            errorMessage="
4 errors found:

Error at line 20, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function pf(): too many positional arguments

Error at line 20, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function pf(): missing argument for required input x

Error at line 23, column 27, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Creating functional input argument fullFunc(): missing argument for required input x2

Error at line 24, column 45, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Creating functional input argument fullFunc(): no input matching named argument x found
")})));
end NumArgs1;

model Array1
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc[1] pf;
        input Real x;
        output Real y;
      algorithm
        y := pf(x);
    end usePartFunc;
    
    Real y1 = usePartFunc({function fullFunc()}, time);
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="Functional_Array1",
            description="Check error when declaring as array",
            errorMessage="
1 errors found:

Compliance error at line 15, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_FUNCTIONAL_ARRAY_INPUT:
  Arrays of functional input arguments is currently not supported
")})));
end Array1;

model Bind1
    partial function partFunc
        input Real x = 3;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
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
    
    Real y1 = usePartFunc(function fullFunc(), time);
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="Functional_Bind1",
            description="Check error when having input default value",
            errorMessage="
1 errors found:

Compliance error at line 15, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_FUNCTIONAL_INPUT_FROM_FUNCTION_DEFAULT:
  Creating functional input arguments from functions with default input arguments is currently not supported
")})));
end Bind1;

model Bind2
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf1 = 3;
        input partFunc pf2 = fullFunc;
        input partFunc pf3 = fullFunc;
        input Real x;
        output Real y;
      algorithm
        y := pf1(x);
    end usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(), function fullFunc(), x=time);
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="Functional_Bind2",
            description="Check error when having input default value",
            errorMessage="
6 errors found:

Compliance error at line 15, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_FUNCTIONAL_INPUT_DEFAULT:
  Default values of functional input arguments is currently not supported

Error at line 15, column 30, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable pf1 does not match the declared type of the variable

Compliance error at line 16, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_FUNCTIONAL_INPUT_DEFAULT:
  Default values of functional input arguments is currently not supported

Error at line 16, column 30, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Illegal access to class in expression: fullFunc

Compliance error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_FUNCTIONAL_INPUT_DEFAULT:
  Default values of functional input arguments is currently not supported

Error at line 17, column 30, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Illegal access to class in expression: fullFunc
")})));
end Bind2;

model Bind3
    record R
        Real a;
    end R;
    
    partial function partFunc
        input R x1;
        output Real y;
    end partFunc;
    
    partial function partFunc2
        input Real[1] x1;
        output Real y;
    end partFunc2;
    
    function fullFunc
        extends partFunc;
      algorithm
        y := x1.a;
    end fullFunc;
    
    function fullFunc2
        extends partFunc2;
      algorithm
        y := x1[1];
    end fullFunc2;
    
    function usePartFunc
        input partFunc pf;
        input partFunc2 pf2;
        output Real y;
      algorithm
        y := pf(R(1)) + pf2({1});
    end usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(),function fullFunc2());
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="Functional_Bind3",
            description="Check error when having record or array input/output",
            errorMessage="
2 errors found:

Compliance error at line 29, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_FUNCTIONAL_INPUT_COMPOSITE:
  Functional input arguments with record/array inputs/outputs is currently not supported

Compliance error at line 30, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_FUNCTIONAL_INPUT_COMPOSITE:
  Functional input arguments with record/array inputs/outputs is currently not supported
")})));
end Bind3;

model Duplicate1
    partial function partFunc
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x1;
        input Real x1;
      algorithm
        y := x1;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        output Real y;
      algorithm
        y := pf();
    end usePartFunc;
    
    Real y = usePartFunc(function fullFunc(x1=1, x1=2));
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="Functional_Duplicate1",
            description="Check error with duplicates",
            errorMessage="
2 errors found:

Error at line 9, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Duplicate component in same class: input Real x1

Error at line 21, column 26, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Creating functional input argument fullFunc(): multiple arguments matches input x1
")})));
end Duplicate1;

model Vectorized1
    partial function partFunc
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x1;
      algorithm
        y := x1;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        output Real y;
      algorithm
        y := pf();
    end usePartFunc;
    
    Real[1] y = usePartFunc(function fullFunc(x1={1}));
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="Functional_Vectorized1",
            description="Check error with vectorized",
            errorMessage="
1 errors found:

Error at line 20, column 29, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function usePartFunc(): types of positional argument 1 and input pf are not compatible
    type of 'fullFunc(x1={1})' is Real[1]
    expected type is ((Real y) = CheckTests.Functional.Vectorized1.partFunc())
")})));
end Vectorized1;

end Functional;

model FortranStrings
    function f
        input String sx;
        input Real t;
        output Real y;
        external "FORTRAN 77";
    end f;
    Real y;
    Real[1] a;
  equation
    y = f("str",time);
    a = Modelica.Math.Matrices.LAPACK.dgeev({{1}});
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FortranStrings",
            description="Check error for strings to fortran. Should not trigger for MSL lapack functions",
            errorMessage="
1 errors found:

Error at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Passing strings to external fortran functions is not allowed
")})));
end FortranStrings;


model SpatialDist1
    Real x1,x2,x3,x4,x5,x6,x7;
  equation
    x1 = spatialDistribution(1, 2, 3, true, {9,9});
    x2 = spatialDistribution(1, 2, 3, true, initialPoints={9,9});
    x3 = spatialDistribution(1, 2, 3, true, initialValues={9,9});
    x4 = spatialDistribution(1, 2, 3, true, {9,9}, {9,9});
    x5 = spatialDistribution(1, 2, 3, true, {9,9}, initialValues={9,9});
    x6 = spatialDistribution(1, 2, 3, true, initialPoints={9,9}, initialValues={9,9});
    x7 = spatialDistribution(1, 2, 3, initialPoints={1,2}, initialValues={3,4});
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="SpatialDist1",
            description="Check named arguments for spatialDistribution().",
            errorMessage="
1 errors found:

Error at line 10, column 10, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Calling function spatialDistribution(): missing argument for required input positiveVelocity
")})));
end SpatialDist1;

model FixedFalseIfEquTest1
    Real x;
    parameter Boolean b(fixed=false);
  initial equation
    b = true;
  equation
    if b then
        x = time;
    else
        x = 0;
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalseIfEquTest1",
            description="Test that fixed false parameter if test in if equation is not marked as structural.",
            flatModel="
fclass CheckTests.FixedFalseIfEquTest1
 Real x;
 initial parameter Boolean b(fixed = false);
initial equation 
 b = true;
equation
 x = if b then time else 0;
end CheckTests.FixedFalseIfEquTest1;

")})));
end FixedFalseIfEquTest1;

model FixedFalseIndex1
    parameter Integer p(fixed=false);
    Real xp;
    Real[:] x = 1:2;
  initial equation
    p = 1;
  equation 
    xp = x[p];
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalseIndex1",
            description="Test that fixed false parameter index is handled correctly",
            flatModel="
fclass CheckTests.FixedFalseIndex1
 initial parameter Integer p(fixed = false);
 initial parameter Real xp;
 constant Real x[1] = 1;
 constant Real x[2] = 2;
initial equation 
 p = 1;
 xp = ({1.0, 2.0})[p];
end CheckTests.FixedFalseIndex1;
")})));
end FixedFalseIndex1;


model SizeInDisabled1
    parameter Integer n;
    Real z[n] = 1:2 if n == 2;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="SizeInDisabled1",
            description="Test that check mode only gives warning for array length mismatch in declaration of disabled conditional",
            checkType=check,
            errorMessage="
2 errors found:

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter n does not have a binding expression

Warning at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Found error in disabled conditional:
  Array size mismatch in declaration of z, size of declaration is [0] and size of binding expression is [2]
")})));
end SizeInDisabled1;


model SizeInDisabled2
    parameter Integer n;
    Real z[n] = {1:2,3:4} if n == 2;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="SizeInDisabled2",
            description="Test that check mode gives error for mismatch in number of array dimensions in declaration of disabled conditional",
            checkType=check,
            errorMessage="
2 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of z, size of declaration is [0] and size of binding expression is [2, 2]

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter n does not have a binding expression
")})));
end SizeInDisabled2;


model SizeInDisabled3
    model A
        parameter Integer n;
        Real x[n];
        Real y[n];
    equation
        y = cat(1, {x[1]}, x[2:end] .- 1) .* x;
    end A;
    
    parameter Integer n;
    A a(n = n) if n > 0;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="SizeInDisabled3",
            description="Test that check mode only gives warning for mismatch in number of array dimensions inside disabled conditional",
            checkType=check,
            errorMessage="
2 errors found:

Warning at line 7, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', TYPE_MISMATCH_IN_EXPRESSION,
In component a:
  Found error in disabled conditional:
  Type error in expression: cat(1, {x[1]}, x[2:end] .- 1) .* x
    type of 'cat(1, {x[1]}, x[2:end] .- 1)' is Real[1]
    type of 'x' is Real[0]

Warning at line 10, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter n does not have a binding expression
")})));
end SizeInDisabled3;


model SizeInDisabled4
    model A
        parameter Integer n;
        Real x[n];
        Real y[n];
    equation
        y = cat(1, {x[1]}, x[2:end] .- 1) .* { x, x };
    end A;
    
    parameter Integer n;
    A a(n = n) if n > 0;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="SizeInDisabled4",
            description="Test that check mode gives error for mismatch in number of array dimensions inside disabled conditional",
            checkType=check,
            errorMessage="
2 errors found:

Error at line 7, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', TYPE_MISMATCH_IN_EXPRESSION,
In component a:
  Type error in expression: cat(1, {x[1]}, x[2:end] .- 1) .* {x, x}
    type of 'cat(1, {x[1]}, x[2:end] .- 1)' is Real[1]
    type of '{x, x}' is Real[2, 0]

Warning at line 10, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter n does not have a binding expression
")})));
end SizeInDisabled4;

model FortranRecord
    record R
        Real x;
    end R;
    
    function f1
        input R r;
        output R y;
        external "FORTRAN 77";
    end f1;
    
    function f2
        input R r;
        output R y;
        external "FORTRAN 77" y = f2(r);
    end f2;
    
    R r1 = f1(R(time));
    R r2 = f2(R(time));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="FortranRecord",
            description="Error for record in fortran call",
            checkType=check,
            errorMessage="
2 errors found:

Error at line 6, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Passing records to external fortran functions is not allowed

Error at line 12, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Passing records to external fortran functions is not allowed
")})));
end FortranRecord;

model ExternalRecordArray1
    record R1
        Real[1] x;
    end R1;
    
    record R2
        R1 r;
    end R2;
    
    function f2
        input R2 r;
        output R2 y;
        external "C" y = f2(r);
    end f2;
    
    R2 r2 = f2(R2(R1({time})));

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ExternalRecordArray1",
            description="Error for array in record in C call",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 10, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Record type used as input or output to external function can only contain scalar record or scalar simple types
  
Compliance error at line 10, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', UNSUPPORTED_EXTERNAL_FUNCTION_RECORD_RETURN_VALUE:
  Using records as return value from external functions is not supported

")})));
end ExternalRecordArray1;

model ExternalRecordArray2
    record R
        Real x;
    end R;
    
    function f2
        input R[1] r;
        output R[1] y;
        external;
    end f2;
    
    R[1] r = f2({R(time)});

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ExternalRecordArray2",
            description="Error for record array in C call",
            checkType=check,
            errorMessage="
1 errors found:

Error at line 6, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo':
  Record type used as input or output to external function can only contain scalar record or scalar simple types
")})));
end ExternalRecordArray2;

model NegativeFill1
    Real[2] y = cat(1,{1,2,3,4},fill(0.0, 2 - 4));
    
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NegativeFill1",
            description="",
            errorMessage="
1 errors found:

Error at line 2, column 43, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', NEGATIVE_SIZE_FILL:
  The dimension arguments of the fill() operator may not be negative

")})));
end NegativeFill1;

model NegativeFill2
    parameter Integer n = 2;
    Real[n] y;
equation
    if n > 1 then
        y = cat(1,{time,time},fill(0.0, n - 2));
    elseif n == 1 then
        y = {time};
    end if;
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NegativeFill2",
            description="",
            flatModel="
fclass CheckTests.NegativeFill2
 structural parameter Integer n = 2 /* 2 */;
 Real y[2];
equation
 if 2 > 1 then
  y[1:2] = cat(1, {time, time}, fill(0.0, 2 - 2));
 elseif 2 == 1 then
  y[1:2] = {time};
 end if;
end CheckTests.NegativeFill2;
")})));
end NegativeFill2;

model FunctionOutputSize1
    function f
        input Integer x;
        output Integer[x] y1 = 1:x;
        output Integer[x] y2 = 1:x;
        algorithm
    end f;
    parameter Integer[:] x;
    Real[1] y1;
    Real[1] y2;
equation
    (y1,y2) = f(size(x,1));
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="FunctionOutputSize1",
            description="Check that error for function outputs does not trigger in inactive branch",
            checkType=check,
            errorMessage="
1 warnings found:

Warning at line 8, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter x does not have a binding expression

")})));
end FunctionOutputSize1;

model UnknownSizeArrayIndexBounds1
    parameter Real[:] x;
    Real y = x[1];
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="UnknownSizeArrayIndexBounds1",
            description="",
            checkType=check,
            errorMessage="
1 warnings found:

Warning at line 2, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', PARAMETER_MISSING_BINDING_EXPRESSION:
  The parameter x does not have a binding expression

")})));
end UnknownSizeArrayIndexBounds1;

model ExternalFunctionAnnotation1
    function f
        input Real x;
        output Real y;
        external "C" y = f(x);
        annotation(Include="", IncludeDirectory="", Library="", LibraryDirectory="", LegalAnnotation="");
    end f;
    
    Real y = f(time);
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="ExternalFunctionAnnotation1",
            description="",
            checkType=check,
            errorMessage="
4 errors found:

Error at line 6, column 20, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', EXTERNAL_FUNCTION_ANNOTATION:
  External function annotations only allowed on external statement annotations. This annotation is attached to a class. There might be a semicolon you want to remove.

Error at line 6, column 32, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', EXTERNAL_FUNCTION_ANNOTATION:
  External function annotations only allowed on external statement annotations. This annotation is attached to a class. There might be a semicolon you want to remove.

Error at line 6, column 53, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', EXTERNAL_FUNCTION_ANNOTATION:
  External function annotations only allowed on external statement annotations. This annotation is attached to a class. There might be a semicolon you want to remove.

Error at line 6, column 65, in file 'Compiler/ModelicaFrontEnd/test/modelica/CheckTests.mo', EXTERNAL_FUNCTION_ANNOTATION:
  External function annotations only allowed on external statement annotations. This annotation is attached to a class. There might be a semicolon you want to remove.

")})));
end ExternalFunctionAnnotation1;

model NoAlgorithmEvaluation1
    partial function f
        input Integer x;
        output Integer y;
    end f;
    
    parameter Integer n = f(1);
    Real[n] x = 1:n;
    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="NoAlgorithmEvaluation1",
            description="Test for null pointer in evaluation of partial function",
            checkType=check,
            errorMessage="
Error at line 7, column 27, in file '...':
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));
end NoAlgorithmEvaluation1;

model FixedFalseString1
    parameter String s(fixed=false);
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="FixedFalseString1",
            description="",
            checkType=check,
            errorMessage="
Error at line 2, column 24, in file '...':
  Cannot find component declaration for fixed
")})));
end FixedFalseString1;

model SampleVariability1
        Integer i = integer(time);
    equation
        when (sample(i,0.1)) then
            assert(i > 0, "");
        end when;
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="SampleVariability1",
            description="",
            checkType=check,
            errorMessage="
Error at line 4, column 22, in file '...', NON_PARAMETER_SAMPLE_ARGUMENTS:
  Sample arguments need to be parameter expressions
")})));
end SampleVariability1;

model SampleType1
        
    equation
        when (sample(true,0.1)) then
            assert(1 > 0, "");
        end when;
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="SampleType1",
            description="",
            checkType=check,
            errorMessage="
Error at line 4, column 22, in file '...':
  Calling function sample(): types of positional argument 1 and input start are not compatible
    type of 'true' is Boolean
    expected type is Real
")})));
end SampleType1;

model SampleType2
    equation
        when (sample({1.},0.1)) then
            assert(1 > 0, "");
        end when;
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="SampleType2",
            description="",
            checkType=check,
            errorMessage="
Error at line 3, column 22, in file '...':
  Calling function sample(): types of positional argument 1 and input start are not compatible
    type of '{1.0}' is Real[1]
    expected type is Real
")})));
end SampleType2;

end CheckTests;
