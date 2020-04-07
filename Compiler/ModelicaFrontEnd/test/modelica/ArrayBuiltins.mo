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
package ArrayBuiltins
	
	

package Size
	
model SizeExp1
 Real x = size(ones(2), 1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Size_SizeExp1",
            description="Size operator: first dim",
            flatModel="
fclass ArrayBuiltins.Size.SizeExp1
 constant Real x = 2;
end ArrayBuiltins.Size.SizeExp1;
")})));
end SizeExp1;


model SizeExp2
 Real x = size(ones(2, 3), 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Size_SizeExp2",
            description="Size operator: second dim",
            flatModel="
fclass ArrayBuiltins.Size.SizeExp2
 constant Real x = 3;
end ArrayBuiltins.Size.SizeExp2;
")})));
end SizeExp2;


model SizeExp3
 Real x[1] = size(ones(2));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Size_SizeExp3",
            description="Size operator: without dim",
            flatModel="
fclass ArrayBuiltins.Size.SizeExp3
 constant Real x[1] = 2;
end ArrayBuiltins.Size.SizeExp3;
")})));
end SizeExp3;


model SizeExp4
 Real x[2] = size(ones(2, 3));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Size_SizeExp4",
            description="Size operator: without dim",
            flatModel="
fclass ArrayBuiltins.Size.SizeExp4
 constant Real x[1] = 2;
 constant Real x[2] = 3;
end ArrayBuiltins.Size.SizeExp4;
")})));
end SizeExp4;


model SizeExp5
 parameter Integer p = 1;
 Real x = size(ones(2, 3), p);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Size_SizeExp5",
            description="Size operator: using parameter",
            flatModel="
fclass ArrayBuiltins.Size.SizeExp5
 structural parameter Integer p = 1 /* 1 */;
 constant Real x = 2;
end ArrayBuiltins.Size.SizeExp5;
")})));
end SizeExp5;


model SizeExp6
 Integer d = 1;
 Real x = size(ones(2, 3), d);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Size_SizeExp6",
            description="Size operator: too high variability of dim",
            errorMessage="
1 errors found:

Error at line 3, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Second argument of size() must be a scalar parameter Integer expression that evaluates to a valid dimension of the first argument
    'd' is of discrete-time variability
")})));
end SizeExp6;


model SizeExp7
 Real x = size(ones(2, 3), {1, 2});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Size_SizeExp7",
            description="Size operator: array as dim",
            errorMessage="
1 errors found:

Error at line 2, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function size(): types of positional argument 2 and input d are not compatible
    type of '{1, 2}' is Integer[2]
    expected type is Integer
")})));
end SizeExp7;


model SizeExp8
 Real x = size(ones(2, 3), 1.0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Size_SizeExp8",
            description="Size operator: Real as dim",
            errorMessage="
1 errors found:

Error at line 2, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function size(): types of positional argument 2 and input d are not compatible
    type of '1.0' is Real
    expected type is Integer
")})));
end SizeExp8;


model SizeExp9
 Real x = size(ones(2, 3), 0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Size_SizeExp9",
            description="Size operator: too low dim",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Second argument of size() must be a scalar parameter Integer expression that evaluates to a valid dimension of the first argument
    '0' evaluates to 0, and 'ones(2, 3)' has 2 dimensions
")})));
end SizeExp9;


model SizeExp10
 Real x = size(ones(2, 3), 3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Size_SizeExp10",
            description="Size operator: too high dim",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Second argument of size() must be a scalar parameter Integer expression that evaluates to a valid dimension of the first argument
    '3' evaluates to 3, and 'ones(2, 3)' has 2 dimensions
")})));
end SizeExp10;


model SizeExp11
    model A
        Real x;
    end A;
    
    A[2] y(x = ones(z));
	parameter Integer z = size(y, 1);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Size_SizeExp11",
            description="",
            flatModel="
fclass ArrayBuiltins.Size.SizeExp11
 Real y[1].x = 1;
 Real y[2].x = 1;
 structural parameter Integer z = 2 /* 2 */;
end ArrayBuiltins.Size.SizeExp11;
")})));
end SizeExp11;


model SizeExp12
    record A
        Real x;
    end A;
    
    A[2] y = fill(A(1), size(y, 1));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Size_SizeExp12",
            description="Size operator: array of records",
            flatModel="
fclass ArrayBuiltins.Size.SizeExp12
 ArrayBuiltins.Size.SizeExp12.A y[2] = fill(ArrayBuiltins.Size.SizeExp12.A(1), size(y[1:2], 1));

public
 record ArrayBuiltins.Size.SizeExp12.A
  Real x;
 end ArrayBuiltins.Size.SizeExp12.A;

end ArrayBuiltins.Size.SizeExp12;
")})));
end SizeExp12;


model SizeStructural1
	Real x[p1,size(p2,1)];
	Real y = p1 + p2 * p3 + p4;
	parameter Integer p1 = size(p3,p4);
	parameter Real p2[1] = {1};
	parameter Real p3[1] = {2};
	parameter Integer p4 = 1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Size_SizeStructural1",
            description="Using parameter as first arg of size() expression that is used as structural parameter should not make that parameter a structural parameter",
            flatModel="
fclass ArrayBuiltins.Size.SizeStructural1
 Real x[1,1];
 Real y = 1 + p2[1:1] * p3[1:1] + 1;
 structural parameter Integer p1 = 1 /* 1 */;
 parameter Real p2[1] = {1} /* { 1 } */;
 parameter Real p3[1] = {2} /* { 2 } */;
 structural parameter Integer p4 = 1 /* 1 */;
end ArrayBuiltins.Size.SizeStructural1;
")})));
end SizeStructural1;

end Size;



package Fill
	
model FillExp1
 Real x[2] = fill(1 + 2, 2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Fill_FillExp1",
            description="Fill operator: one dim",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Fill.FillExp1
 constant Real x[1] = 3;
 constant Real x[2] = 3;
end ArrayBuiltins.Fill.FillExp1;
")})));
end FillExp1;


model FillExp2
 Real x[2,3,4] = fill(1 + 2, 2, 3, 4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Fill_FillExp2",
            description="Fill operator: three dims",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Fill.FillExp2
 constant Real x[1,1,1] = 3;
 constant Real x[1,1,2] = 3;
 constant Real x[1,1,3] = 3;
 constant Real x[1,1,4] = 3;
 constant Real x[1,2,1] = 3;
 constant Real x[1,2,2] = 3;
 constant Real x[1,2,3] = 3;
 constant Real x[1,2,4] = 3;
 constant Real x[1,3,1] = 3;
 constant Real x[1,3,2] = 3;
 constant Real x[1,3,3] = 3;
 constant Real x[1,3,4] = 3;
 constant Real x[2,1,1] = 3;
 constant Real x[2,1,2] = 3;
 constant Real x[2,1,3] = 3;
 constant Real x[2,1,4] = 3;
 constant Real x[2,2,1] = 3;
 constant Real x[2,2,2] = 3;
 constant Real x[2,2,3] = 3;
 constant Real x[2,2,4] = 3;
 constant Real x[2,3,1] = 3;
 constant Real x[2,3,2] = 3;
 constant Real x[2,3,3] = 3;
 constant Real x[2,3,4] = 3;
end ArrayBuiltins.Fill.FillExp2;
")})));
end FillExp2;


model FillExp3
 Real x = fill(1 + 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Fill_FillExp3",
            description="Fill operator: no size args",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Too few arguments to fill(), must have at least 2
")})));
end FillExp3;


model FillExp4
 Real x[2] = fill(1 + 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Fill_FillExp4",
            description="Fill operator:",
            errorMessage="
1 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [3]
")})));
end FillExp4;


model FillExp5
 Real x[2] = fill(1 + 2, 2.0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Fill_FillExp5",
            description="Fill operator: Real size arg",
            errorMessage="
1 errors found:

Error at line 2, column 26, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Argument of fill() is not compatible with Integer: 2.0
")})));
end FillExp5;


model FillExp6
 Integer n = 2;
 Real x[2] = fill(1 + 2, n);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Fill_FillExp6",
            description="Fill operator: too high variability of size arg",
            errorMessage="
2 errors found:

Error at line 3, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [n]

Error at line 3, column 26, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Argument of fill() does not have constant or parameter variability: n
")})));
end FillExp6;


model FillExp7
 Real x[2] = fill();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Fill_FillExp7",
            description="Fill operator: no arguments at all",
            errorMessage="
2 errors found:

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is scalar

Error at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function fill(): missing argument for required input s
")})));
end FillExp7;


model FillExp8
 Real x[3,2] = fill({1,2}, 3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Fill_FillExp8",
            description="Fill operator: filling with array",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Fill.FillExp8
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 1;
 constant Real x[2,2] = 2;
 constant Real x[3,1] = 1;
 constant Real x[3,2] = 2;
end ArrayBuiltins.Fill.FillExp8;
")})));
end FillExp8;
 
end Fill;



package Min
	
model MinExp1
 constant Real x = min(1+2, 3+4);
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Min_MinExp1",
            description="Min operator: 2 scalar args",
            flatModel="
fclass ArrayBuiltins.Min.MinExp1
 constant Real x = 3;
 constant Real y = 3.0;
end ArrayBuiltins.Min.MinExp1;
")})));
end MinExp1;


model MinExp2
 constant Real x = min({{1,2},{3,4}});
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Min_MinExp2",
            description="Min operator: 1 array arg",
            flatModel="
fclass ArrayBuiltins.Min.MinExp2
 constant Real x = 1;
 constant Real y = 1.0;
end ArrayBuiltins.Min.MinExp2;
")})));
end MinExp2;


model MinExp3
 constant String x = min("foo", "bar");
 parameter String y1 = x;
 parameter String y2 = x;
 parameter String y3 = min(y1, y2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Min_MinExp3",
            description="Min operator: strings",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Min.MinExp3
 constant String x = \"bar\";
 parameter String y1 = \"bar\" /* \"bar\" */;
 parameter String y2 = \"bar\" /* \"bar\" */;
 parameter String y3;
parameter equation
 y3 = min(y1, y2);
end ArrayBuiltins.Min.MinExp3;
")})));
end MinExp3;


model MinExp4
 constant Boolean x = min(true, false);
 Boolean y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Min_MinExp4",
            description="Min operator: booleans",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Min.MinExp4
 constant Boolean x = false;
 constant Boolean y = false;
end ArrayBuiltins.Min.MinExp4;
")})));
end MinExp4;


model MinExp5
 Real x = min(true, 0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Min_MinExp5",
            description="Min operator: mixed types",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: min(true, 0)
    type of 'true' is Boolean
    type of '0' is Integer
")})));
end MinExp5;


model MinExp6
 Real x = min({1,2}, {3,4});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Min_MinExp6",
            description="Min operator: 2 array args",
            errorMessage="
2 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function min(): types of positional argument 1 and input x are not compatible
    type of '{1, 2}' is Integer[2]
    expected type is scalar Real, Integer, Boolean, String or enumeration

Error at line 2, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function min(): types of positional argument 2 and input y are not compatible
    type of '{3, 4}' is Integer[2]
    expected type is scalar Real, Integer, Boolean, String or enumeration
")})));
end MinExp6;


model MinExp7
 Real x = min(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Min_MinExp7",
            description="Min operator: 1 scalar arg",
            errorMessage="
1 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function min(): types of positional argument 1 and input x are not compatible
    type of '1' is Integer
    expected type is array of Real, Integer, Boolean, String or enumeration
")})));
end MinExp7;


model MinExp8
 constant Real x = min(1.0 for i in 1:4, j in {2,3,5});
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Min_MinExp8",
            description="Reduction-expression with min(): constant expression",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Min.MinExp8
 constant Real x = 1.0;
 constant Real y = 1.0;
end ArrayBuiltins.Min.MinExp8;
")})));
end MinExp8;


model MinExp9
 Real x = min(i * j for i in 1:3, j in {2,3,5});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Min_MinExp9",
            description="Reduction-expression with min(): basic test",
            flatModel="
fclass ArrayBuiltins.Min.MinExp9
 constant Real x = 2;
end ArrayBuiltins.Min.MinExp9;
")})));
end MinExp9;


model MinExp10
 Real x = min(i * j for i in {{1,2},{3,4}}, j in 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Min_MinExp10",
            description="Reduction-expression with min(): non-vector index expressions",
            errorMessage="
2 errors found:

Error at line 2, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  The expression of for index i must be a vector expression: {{1, 2}, {3, 4}} has 2 dimension(s)

Error at line 2, column 45, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  The expression of for index j must be a vector expression: 2 has 0 dimension(s)
")})));
end MinExp10;


model MinExp11
 Real x = min({i * j, 2} for i in 1:4, j in 2:5);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Min_MinExp11",
            description="Reduction-expression with min(): non-scalar expression",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  The expression of a reduction-expression must be scalar, except for sum(): {i * j, 2} has 1 dimension(s)
")})));
end MinExp11;


model MinExp12
 Real x = min(false for i in 1:4, j in 2:5);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Min_MinExp12",
            description="Reduction-expression with min(): wrong type in expression",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end MinExp12;

end Min;



package Max
	
model MaxExp1
 constant Real x = max(1+2, 3+4);
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Max_MaxExp1",
            description="Max operator: 2 scalar args",
            flatModel="
fclass ArrayBuiltins.Max.MaxExp1
 constant Real x = 7;
 constant Real y = 7.0;
end ArrayBuiltins.Max.MaxExp1;
")})));
end MaxExp1;


model MaxExp2
 constant Real x = max({{1,2},{3,4}});
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Max_MaxExp2",
            description="Max operator: 1 array arg",
            flatModel="
fclass ArrayBuiltins.Max.MaxExp2
 constant Real x = 4;
 constant Real y = 4.0;
end ArrayBuiltins.Max.MaxExp2;
")})));
end MaxExp2;


model MaxExp3
 constant String x = max("foo", "bar");
 parameter String y1 = x;
 parameter String y2 = x;
 parameter String y3 = max(y1, y2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Max_MaxExp3",
            description="Max operator: strings",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Max.MaxExp3
 constant String x = \"foo\";
 parameter String y1 = \"foo\" /* \"foo\" */;
 parameter String y2 = \"foo\" /* \"foo\" */;
 parameter String y3;
parameter equation
 y3 = max(y1, y2);
end ArrayBuiltins.Max.MaxExp3;
")})));
end MaxExp3;


model MaxExp4
 constant Boolean x = max(true, false);
 Boolean y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Max_MaxExp4",
            description="Max operator: booleans",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Max.MaxExp4
 constant Boolean x = true;
 constant Boolean y = true;
end ArrayBuiltins.Max.MaxExp4;
")})));
end MaxExp4;


model MaxExp5
 Real x = max(true, 0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Max_MaxExp5",
            description="Max operator: mixed types",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: max(true, 0)
    type of 'true' is Boolean
    type of '0' is Integer
")})));
end MaxExp5;


model MaxExp6
 Real x = max({1,2}, {3,4});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Max_MaxExp6",
            description="Max operator: 2 array args",
            errorMessage="
2 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function max(): types of positional argument 1 and input x are not compatible
    type of '{1, 2}' is Integer[2]
    expected type is scalar Real, Integer, Boolean, String or enumeration

Error at line 2, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function max(): types of positional argument 2 and input y are not compatible
    type of '{3, 4}' is Integer[2]
    expected type is scalar Real, Integer, Boolean, String or enumeration
")})));
end MaxExp6;


model MaxExp7
 Real x = max(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Max_MaxExp7",
            description="Max operator: 1 scalar arg",
            errorMessage="
1 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function max(): types of positional argument 1 and input x are not compatible
    type of '1' is Integer
    expected type is array of Real, Integer, Boolean, String or enumeration
")})));
end MaxExp7;


model MaxExp8
 Real x = max(1.0 for i in 1:4, j in {2,3,5});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Max_MaxExp8",
            description="Reduction-expression with max(): constant expression",
            flatModel="
fclass ArrayBuiltins.Max.MaxExp8
 constant Real x = 1.0;
end ArrayBuiltins.Max.MaxExp8;
")})));
end MaxExp8;


model MaxExp9
 constant Real x = max(i * j for i in 1:4, j in {2,3,5});
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Max_MaxExp9",
            description="Reduction-expression with max(): basic test",
            flatModel="
fclass ArrayBuiltins.Max.MaxExp9
 constant Real x = 20;
 constant Real y = 20.0;
end ArrayBuiltins.Max.MaxExp9;
")})));
end MaxExp9;


model MaxExp10
 Real x = max(i * j for i in {{1,2},{3,4}}, j in 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Max_MaxExp10",
            description="Reduction-expression with max(): non-vector index expressions",
            errorMessage="
2 errors found:

Error at line 2, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  The expression of for index i must be a vector expression: {{1, 2}, {3, 4}} has 2 dimension(s)

Error at line 2, column 45, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  The expression of for index j must be a vector expression: 2 has 0 dimension(s)
")})));
end MaxExp10;

model MaxExp12
 Real x = max(false for i in 1:4, j in 2:5);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Max_MaxExp12",
            description="Reduction-expression with max(): wrong type in expression",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end MaxExp12;

end Max;



package Sum
	
model SumExp1
 constant Real x = sum({1,2,3,4});
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sum_SumExp1",
            description="sum() expressions: basic test",
            flatModel="
fclass ArrayBuiltins.Sum.SumExp1
 constant Real x = 10;
 constant Real y = 10.0;
end ArrayBuiltins.Sum.SumExp1;
")})));
end SumExp1;


model SumExp2
 constant Real x = sum(i * j for i in 1:3, j in 1:3);
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sum_SumExp2",
            description="sum() expressions: reduction-expression",
            flatModel="
fclass ArrayBuiltins.Sum.SumExp2
 constant Real x = 36;
 constant Real y = 36.0;
end ArrayBuiltins.Sum.SumExp2;
")})));
end SumExp2;


model SumExp3
 constant Real x[2] = sum({i, j} for i in 1:3, j in 2:4);
 Real y[2] = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sum_SumExp3",
            description="sum() expressions: reduction-expression over array",
            flatModel="
fclass ArrayBuiltins.Sum.SumExp3
 constant Real x[1] = 18;
 constant Real x[2] = 27;
 constant Real y[1] = 18.0;
 constant Real y[2] = 27.0;
end ArrayBuiltins.Sum.SumExp3;
")})));
end SumExp3;


model SumExp4
 constant Real x = sum( { {i, j} for i in 1:3, j in 2:4 } );
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sum_SumExp4",
            description="sum() expressions: over array constructor with iterators",
            flatModel="
fclass ArrayBuiltins.Sum.SumExp4
 constant Real x = 45;
 constant Real y = 45.0;
end ArrayBuiltins.Sum.SumExp4;
")})));
end SumExp4;


model SumExp5
 Real x = sum(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Sum_SumExp5",
            description="sum() expressions: scalar input",
            errorMessage="
1 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function sum(): types of positional argument 1 and input A are not compatible
    type of '1' is Integer
    expected type is Real array
")})));
end SumExp5;


model SumExp6
	parameter Integer N = 3;
	Real wbar[N];
	Real dMdt[N + 1] ;
equation
	dMdt = 1:(N + 1);
	for j in 1:N loop
		wbar[j] = sum(dMdt[1:j+1]) + dMdt[j] / 2;
	end for;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sum_SumExp6",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Sum.SumExp6
 structural parameter Integer N = 3 /* 3 */;
 constant Real wbar[1] = 3.5;
 constant Real wbar[2] = 7.0;
 constant Real wbar[3] = 11.5;
 constant Real dMdt[1] = 1;
 constant Real dMdt[2] = 2;
 constant Real dMdt[3] = 3;
 constant Real dMdt[4] = 4;
end ArrayBuiltins.Sum.SumExp6;
")})));
end SumExp6;

model SumExp8
	parameter Real x = sum(fill(2, 0));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Sum_SumExp8",
            description="sum() expressions: empty array",
            flatModel="
fclass ArrayBuiltins.Sum.SumExp8
 parameter Real x = 0 /* 0 */;
end ArrayBuiltins.Sum.SumExp8;
")})));
end SumExp8;

end Sum;



package Product

model ProductExp1
 constant Real x = product({1,2,3,4});
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Product_ProductExp1",
            description="product() expressions: basic test",
            flatModel="
fclass ArrayBuiltins.Product.ProductExp1
 constant Real x = 24;
 constant Real y = 24.0;
end ArrayBuiltins.Product.ProductExp1;
")})));
end ProductExp1;

model ProductExp2
 constant Real x = product(i * j for i in 1:3, j in 1:3);
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Product_ProductExp2",
            description="product() expressions: reduction-expression",
            flatModel="
fclass ArrayBuiltins.Product.ProductExp2
 constant Real x = 46656;
 constant Real y = 46656.0;
end ArrayBuiltins.Product.ProductExp2;
")})));
end ProductExp2;

model ProductExp3
 constant Real x[2] = product({i, j} for i in 1:3, j in 2:4);
 Real y[2] = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Product_ProductExp3",
            description="product() expressions: reduction-expression over array",
            flatModel="
fclass ArrayBuiltins.Product.ProductExp3
 constant Real x[1] = 216;
 constant Real x[2] = 13824;
 constant Real y[1] = 216.0;
 constant Real y[2] = 13824.0;
end ArrayBuiltins.Product.ProductExp3;
")})));
end ProductExp3;

model ProductExp4
 constant Real x = product( { {i, j} for i in 1:3, j in 2:4 } );
 Real y = x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Product_ProductExp4",
            description="product() expressions: over array constructor with iterators",
            flatModel="
fclass ArrayBuiltins.Product.ProductExp4
 constant Real x = 2985984;
 constant Real y = 2985984.0;
end ArrayBuiltins.Product.ProductExp4;
")})));
end ProductExp4;

model ProductExp5
 Real x = product();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Product_ProductExp5",
            description="product() expressions: no input",
            errorMessage="
1 errors found:

Error at line 2, column 11, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function product(): missing argument for required input A
")})));
end ProductExp5;

model ProductExp6
 Real x = product(42);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Product_ProductExp6",
            description="product() expressions: scalar input",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function product(): types of positional argument 1 and input A are not compatible
    type of '42' is Integer
    expected type is Real array
")})));
end ProductExp6;

model ProductExp7
 parameter Real x = product(fill(2, 0));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Product_ProductExp7",
            description="product() expressions: empty array",
            flatModel="
fclass ArrayBuiltins.Product.ProductExp7
 parameter Real x = 1 /* 1 */;
end ArrayBuiltins.Product.ProductExp7;
")})));
end ProductExp7;

model ProductExp8
     function f
        input Real[:,:] x1;
        output Real y;
    algorithm
        y := product(x1);
    end f;

 parameter Real x = f({{1,2},{3,4}});
    

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Product_ProductExp8",
            description="product() expressions: in a function",
            flatModel="
fclass ArrayBuiltins.Product.ProductExp8
 parameter Real x = 24.0 /* 24.0 */;
end ArrayBuiltins.Product.ProductExp8;
")})));
end ProductExp8;

model ProductExp9
 function f
        input Real[:,:] x1;
        input Real[:,:] x2;
        output Real y;
    algorithm
        y := product(x1 + x2);
    end f;
 Real[2,2] v1 = {{1,2},{3,4}};
 Real[2,2] v2 = {{5,6},{7,8}};
 parameter Real x = f(v1,v2);
 
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Product_ProductExp9",
            description="product() expressions: in a function",
            variability_propagation=false,
            flatModel="
fclass ArrayBuiltins.Product.ProductExp9
 Real v1[1,1];
 Real v1[1,2];
 Real v1[2,1];
 Real v1[2,2];
 Real v2[1,1];
 Real v2[1,2];
 Real v2[2,1];
 Real v2[2,2];
 parameter Real x;
parameter equation
 x = ArrayBuiltins.Product.ProductExp9.f({{v1[1,1], v1[1,2]}, {v1[2,1], v1[2,2]}}, {{v2[1,1], v2[1,2]}, {v2[2,1], v2[2,2]}});
equation
 v1[1,1] = 1;
 v1[1,2] = 2;
 v1[2,1] = 3;
 v1[2,2] = 4;
 v2[1,1] = 5;
 v2[1,2] = 6;
 v2[2,1] = 7;
 v2[2,2] = 8;

public
 function ArrayBuiltins.Product.ProductExp9.f
  input Real[:, :] x1;
  input Real[:, :] x2;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 1.0;
  for i1 in 1:size(x1, 1) loop
   for i2 in 1:size(x1, 2) loop
    temp_1 := temp_1 * (x1[i1,i2] + x2[i1,i2]);
   end for;
  end for;
  y := temp_1;
  return;
 end ArrayBuiltins.Product.ProductExp9.f;

end ArrayBuiltins.Product.ProductExp9;
")})));
end ProductExp9;

end Product;



package Transpose
	
model Transpose1
 Real x[2,2] = transpose({{1,2},{3,4}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose1",
            description="Scalarization of transpose operator: Integer[2,2]",
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose1
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 3;
 constant Real x[2,1] = 2;
 constant Real x[2,2] = 4;
end ArrayBuiltins.Transpose.Transpose1;
")})));
end Transpose1;


model Transpose2
 Real x[2,3] = transpose({{1,2},{3,4},{5,6}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose2",
            description="Scalarization of transpose operator: Integer[3,2]",
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose2
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 3;
 constant Real x[1,3] = 5;
 constant Real x[2,1] = 2;
 constant Real x[2,2] = 4;
 constant Real x[2,3] = 6;
end ArrayBuiltins.Transpose.Transpose2;
")})));
end Transpose2;


model Transpose3
 Real x[2,1] = transpose({{1,2}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose3",
            description="Scalarization of transpose operator: Integer[1,2]",
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose3
 constant Real x[1,1] = 1;
 constant Real x[2,1] = 2;
end ArrayBuiltins.Transpose.Transpose3;
")})));
end Transpose3;


model Transpose4
 Integer x[2,2,2] = transpose({{{1,2},{3,4}},{{5,6},{7,8}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose4",
            description="Scalarization of transpose operator: Integer[2,2,2]",
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose4
 constant Integer x[1,1,1] = 1;
 constant Integer x[1,1,2] = 2;
 constant Integer x[1,2,1] = 5;
 constant Integer x[1,2,2] = 6;
 constant Integer x[2,1,1] = 3;
 constant Integer x[2,1,2] = 4;
 constant Integer x[2,2,1] = 7;
 constant Integer x[2,2,2] = 8;
end ArrayBuiltins.Transpose.Transpose4;
")})));
end Transpose4;


model Transpose5
  Real x[2] = {1,2};
  Real y[2];
equation
  y=transpose(x)*x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Transpose_Transpose5",
            description="Scalarization of transpose operator: too few dimensions of arg",
            errorMessage="
1 errors found:

Error at line 5, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function transpose(): types of positional argument 1 and input A are not compatible
    type of 'x' is Real[2]
    expected type is matrix of Real, Integer, Boolean, String or enumeration
")})));
end Transpose5;


model Transpose6
 Real x[2] = transpose(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Transpose_Transpose6",
            description="Scalarization of transpose operator: Integer",
            errorMessage="
1 errors found:

Error at line 2, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function transpose(): types of positional argument 1 and input A are not compatible
    type of '1' is Integer
    expected type is matrix of Real, Integer, Boolean, String or enumeration
")})));
end Transpose6;


model Transpose7
 Integer x[2,1] = transpose({{1.0,2}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Transpose_Transpose7",
            description="Scalarization of transpose operator: Real[1,2] -> Integer[2,1]",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end Transpose7;


model Transpose8
    Real[3,2] x = {{1,2},{3,4},{5,6}};
    Real[2,3] y = transpose(x) .+ 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose8",
            description="Scalarization of transpose operator: access to variable",
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose8
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 4;
 constant Real x[3,1] = 5;
 constant Real x[3,2] = 6;
 constant Real y[1,1] = 2.0;
 constant Real y[1,2] = 4.0;
 constant Real y[1,3] = 6.0;
 constant Real y[2,1] = 3.0;
 constant Real y[2,2] = 5.0;
 constant Real y[2,3] = 7.0;
end ArrayBuiltins.Transpose.Transpose8;
")})));
end Transpose8;

model Transpose9
	function f
		input Real[:,:] a;
		output Real[size(a,2),size(a,1)] b;
	algorithm
		b := transpose(a);
	end f;
	
	Real[2,3] x = f({{1,3},{5,7},{9,11}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose9",
            description="Scalarization of transpose operator: unknown size",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose9
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
equation
 ({{x[1,1], x[1,2], x[1,3]}, {x[2,1], x[2,2], x[2,3]}}) = ArrayBuiltins.Transpose.Transpose9.f({{1, 3}, {5, 7}, {9, 11}});

public
 function ArrayBuiltins.Transpose.Transpose9.f
  input Real[:,:] a;
  output Real[:,:] b;
 algorithm
  init b as Real[size(a, 2), size(a, 1)];
  for i1 in 1:size(a, 2) loop
   for i2 in 1:size(a, 1) loop
    b[i1,i2] := a[i2,i1];
   end for;
  end for;
  return;
 end ArrayBuiltins.Transpose.Transpose9.f;

end ArrayBuiltins.Transpose.Transpose9;
")})));
end Transpose9;

model Transpose10
	function f
		input Real[:,:,:] a;
		output Real[size(a,2),size(a,1),size(a,3)] b;
	algorithm
		b := transpose(a);
	end f;
	
	Real[2,3,2] x = f({{{1,2},{3,4}},{{5,6},{7,8}},{{9,10},{11,12}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose10",
            description="Scalarization of transpose operator: unknown size",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose10
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
equation
 ({{{x[1,1,1], x[1,1,2]}, {x[1,2,1], x[1,2,2]}, {x[1,3,1], x[1,3,2]}}, {{x[2,1,1], x[2,1,2]}, {x[2,2,1], x[2,2,2]}, {x[2,3,1], x[2,3,2]}}}) = ArrayBuiltins.Transpose.Transpose10.f({{{1, 2}, {3, 4}}, {{5, 6}, {7, 8}}, {{9, 10}, {11, 12}}});

public
 function ArrayBuiltins.Transpose.Transpose10.f
  input Real[:,:,:] a;
  output Real[:,:,:] b;
 algorithm
  init b as Real[size(a, 2), size(a, 1), size(a, 3)];
  for i1 in 1:size(a, 2) loop
   for i2 in 1:size(a, 1) loop
    for i3 in 1:size(a, 3) loop
     b[i1,i2,i3] := a[i2,i1,i3];
    end for;
   end for;
  end for;
  return;
 end ArrayBuiltins.Transpose.Transpose10.f;

end ArrayBuiltins.Transpose.Transpose10;
")})));
end Transpose10;

model Transpose11
	function f
		input Real[:,:] a;
		output Real[size(a,2),size(a,1)] b;
	algorithm
		b := a*transpose(a + a[:,:]);
	end f;
	
	Real[2,3] x = f({{1,3},{5,7},{9,11}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Transpose_Transpose11",
            description="Scalarization of transpose operator: unknown size",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass ArrayBuiltins.Transpose.Transpose11
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
equation
 ({{x[1,1], x[1,2], x[1,3]}, {x[2,1], x[2,2], x[2,3]}}) = ArrayBuiltins.Transpose.Transpose11.f({{1, 3}, {5, 7}, {9, 11}});

public
 function ArrayBuiltins.Transpose.Transpose11.f
  input Real[:,:] a;
  output Real[:,:] b;
  Real[:,:] temp_1;
  Real temp_2;
 algorithm
  init b as Real[size(a, 2), size(a, 1)];
  init temp_1 as Real[size(a, 1), size(a, 1)];
  for i1 in 1:size(a, 1) loop
   for i2 in 1:size(a, 1) loop
    temp_2 := 0.0;
    for i3 in 1:size(a, 2) loop
     temp_2 := temp_2 + a[i1,i3] * (a[i2,i3] + a[i2,i3]);
    end for;
    temp_1[i1,i2] := temp_2;
   end for;
  end for;
  for i1 in 1:size(a, 2) loop
   for i2 in 1:size(a, 1) loop
    b[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end ArrayBuiltins.Transpose.Transpose11.f;

end ArrayBuiltins.Transpose.Transpose11;
")})));
end Transpose11;

end Transpose;

package Symmetric
	
model Symmetric1
 Real x[2,2] = symmetric({{1,2},{3,4}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Symmetric_Symmetric1",
            description="Scalarization of symmetric operator: Integer[2,2]",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Symmetric.Symmetric1
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 2;
 constant Real x[2,2] = 4;
end ArrayBuiltins.Symmetric.Symmetric1;
")})));
end Symmetric1;


model Symmetric2
 Real x[3,3] = symmetric({{1,2,3},{4,5,6},{7,8,9}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Symmetric_Symmetric2",
            description="Scalarization of symmetric operator: Integer[3,3]",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Symmetric.Symmetric2
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[1,3] = 3;
 constant Real x[2,1] = 2;
 constant Real x[2,2] = 5;
 constant Real x[2,3] = 6;
 constant Real x[3,1] = 3;
 constant Real x[3,2] = 6;
 constant Real x[3,3] = 9;
end ArrayBuiltins.Symmetric.Symmetric2;
")})));
end Symmetric2;


model Symmetric3
 Real x[1,1] = symmetric({{3}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Symmetric_Symmetric3",
            description="Scalarization of symmetric operator: Integer[1,1]",
            flatModel="
fclass ArrayBuiltins.Symmetric.Symmetric3
 constant Real x[1,1] = 3;
end ArrayBuiltins.Symmetric.Symmetric3;
")})));
end Symmetric3;


model Symmetric4
 Integer x[4,4] = symmetric({{1,2,3,4},{5,6,7,8},{11,12,13,14},{15,16,17,18}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Symmetric_Symmetric4",
            description="Scalarization of symmetric operator: Integer[2,2,2]",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Symmetric.Symmetric4
 constant Integer x[1,1] = 1;
 constant Integer x[1,2] = 2;
 constant Integer x[1,3] = 3;
 constant Integer x[1,4] = 4;
 constant Integer x[2,1] = 2;
 constant Integer x[2,2] = 6;
 constant Integer x[2,3] = 7;
 constant Integer x[2,4] = 8;
 constant Integer x[3,1] = 3;
 constant Integer x[3,2] = 7;
 constant Integer x[3,3] = 13;
 constant Integer x[3,4] = 14;
 constant Integer x[4,1] = 4;
 constant Integer x[4,2] = 8;
 constant Integer x[4,3] = 14;
 constant Integer x[4,4] = 18;
end ArrayBuiltins.Symmetric.Symmetric4;
")})));
end Symmetric4;


model Symmetric5
  Real x[2] = {1,2};
  Real y[2,2];
equation
  y=symmetric(x)*x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Symmetric_Symmetric5",
            description="Scalarization of symmetric operator: too few dimensions of arg",
            errorMessage="
1 errors found:

Error at line 5, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function symmetric(): types of positional argument 1 and input A are not compatible
    type of 'x' is Real[2]
    expected type is square matrix
")})));
end Symmetric5;


model Symmetric6
 Real x[2] = symmetric(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Symmetric_Symmetric6",
            description="Scalarization of symmetric operator: Integer",
            errorMessage="
1 errors found:

Error at line 2, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function symmetric(): types of positional argument 1 and input A are not compatible
    type of '1' is Integer
    expected type is square matrix
")})));
end Symmetric6;


model Symmetric7
 Integer x[2,1] = symmetric({{1.0,2},{1,1}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Symmetric_Symmetric7",
            description="Scalarization of symmetric operator: Real[1,2] -> Integer[2,1]",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end Symmetric7;


model Symmetric8
    Real[2,2] x = {{1,2},{3,4}};
    Real[2,2] y = symmetric(x) .+ 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Symmetric_Symmetric8",
            description="Scalarization of symmetric operator: access to variable",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Symmetric.Symmetric8
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 4;
 constant Real y[1,1] = 2.0;
 constant Real y[1,2] = 3.0;
 constant Real y[2,1] = 3.0;
 constant Real y[2,2] = 5.0;
end ArrayBuiltins.Symmetric.Symmetric8;
")})));
end Symmetric8;

end Symmetric;

package Cross
	
model Cross1
 Real x[3] = cross({1,2,3}, {4.0,5,6});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Cross_Cross1",
            description="cross() operator: Real result",
            flatModel="
fclass ArrayBuiltins.Cross.Cross1
 constant Real x[1] = -3;
 constant Real x[2] = 6.0;
 constant Real x[3] = -3.0;
end ArrayBuiltins.Cross.Cross1;
")})));
end Cross1; 


model Cross2
 Integer x[3] = cross({1,2,3}, {4,5,6});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Cross_Cross2",
            description="cross() operator: Integer result",
            flatModel="
fclass ArrayBuiltins.Cross.Cross2
 discrete Integer x[3] = cross({1, 2, 3}, {4, 5, 6});
end ArrayBuiltins.Cross.Cross2;
")})));
end Cross2; 


model Cross3
 Integer x[3] = cross({1.0,2,3}, {4,5,6});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cross_Cross3",
            description="cross() operator: Real arg, assigning Integer component",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end Cross3; 


model Cross4
 Integer x = cross(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cross_Cross4",
            description="cross() operator: scalar arguments",
            errorMessage="
2 errors found:

Error at line 2, column 20, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 1 and input x are not compatible
    type of '1' is Integer
    expected type is Real[3]

Error at line 2, column 23, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 2 and input y are not compatible
    type of '2' is Integer
    expected type is Real[3]
")})));
end Cross4; 


model Cross5
 Integer x[4] = cross({1,2,3,4}, {4,5,6,7});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cross_Cross5",
            description="cross() operator: Integer[4] arguments",
            errorMessage="
2 errors found:

Error at line 2, column 23, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 1 and input x are not compatible
    type of '{1, 2, 3, 4}' is Integer[4]
    expected type is Real[3]

Error at line 2, column 34, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 2 and input y are not compatible
    type of '{4, 5, 6, 7}' is Integer[4]
    expected type is Real[3]
")})));
end Cross5; 


model Cross6
 String x[3] = cross({"1","2","3"}, {"4","5","6"});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cross_Cross6",
            description="cross() operator: String[3] arguments",
            errorMessage="
2 errors found:

Error at line 2, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 1 and input x are not compatible
    type of '{\"1\", \"2\", \"3\"}' is String[3]
    expected type is Real[3]

Error at line 2, column 37, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 2 and input y are not compatible
    type of '{\"4\", \"5\", \"6\"}' is String[3]
    expected type is Real[3]
")})));
end Cross6; 


model Cross7
 Integer x[3,3] = cross({{1,2,3},{1,2,3},{1,2,3}}, {{4,5,6},{4,5,6},{4,5,6}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cross_Cross7",
            description="cross() operator: too many dims",
            errorMessage="
2 errors found:

Error at line 2, column 25, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 1 and input x are not compatible
    type of '{{1, 2, 3}, {1, 2, 3}, {1, 2, 3}}' is Integer[3, 3]
    expected type is Real[3]

Error at line 2, column 52, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function cross(): types of positional argument 2 and input y are not compatible
    type of '{{4, 5, 6}, {4, 5, 6}, {4, 5, 6}}' is Integer[3, 3]
    expected type is Real[3]
")})));
end Cross7; 

end Cross;



package Skew

model Skew1
	Real x[3] = {1,2,3};
    Real y[3,3] = skew(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Skew_Skew1",
            description="skew() operator: basic test",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Skew.Skew1
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
 constant Real y[1,1] = 0;
 constant Real y[1,2] = -3.0;
 constant Real y[1,3] = 2.0;
 constant Real y[2,1] = 3.0;
 constant Real y[2,2] = 0;
 constant Real y[2,3] = -1.0;
 constant Real y[3,1] = -2.0;
 constant Real y[3,2] = 1.0;
 constant Real y[3,3] = 0;
end ArrayBuiltins.Skew.Skew1;
")})));
end Skew1;


model Skew2
    Real x[3,3] = skew({1,2,3,4});
    String y[3,3] = skew({"1","2","3"});
	
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Skew_Skew2",
            description="skew() operator: bad arg",
            errorMessage="
2 errors found:

Error at line 2, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function skew(): types of positional argument 1 and input x are not compatible
    type of '{1, 2, 3, 4}' is Integer[4]
    expected type is Real[3]

Error at line 3, column 26, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function skew(): types of positional argument 1 and input x are not compatible
    type of '{\"1\", \"2\", \"3\"}' is String[3]
    expected type is Real[3]
")})));
end Skew2;

end Skew;



package OuterProduct
	
model OuterProduct1
 Real x[3,2] = outerProduct({1,2,3}, {4.0,5});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="OuterProduct_OuterProduct1",
            description="outerProduct() operator: basic test",
            flatModel="
fclass ArrayBuiltins.OuterProduct.OuterProduct1
 constant Real x[1,1] = 4.0;
 constant Real x[1,2] = 5;
 constant Real x[2,1] = 8.0;
 constant Real x[2,2] = 10;
 constant Real x[3,1] = 12.0;
 constant Real x[3,2] = 15;
end ArrayBuiltins.OuterProduct.OuterProduct1;
")})));
end OuterProduct1; 


model OuterProduct2
 Integer x[3,3] = outerProduct({1,2,3}, {4,5,6});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="OuterProduct_OuterProduct2",
            description="outerProduct() operator: basic test",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.OuterProduct.OuterProduct2
 constant Integer x[1,1] = 4;
 constant Integer x[1,2] = 5;
 constant Integer x[1,3] = 6;
 constant Integer x[2,1] = 8;
 constant Integer x[2,2] = 10;
 constant Integer x[2,3] = 12;
 constant Integer x[3,1] = 12;
 constant Integer x[3,2] = 15;
 constant Integer x[3,3] = 18;
end ArrayBuiltins.OuterProduct.OuterProduct2;
")})));
end OuterProduct2; 


model OuterProduct3
 Integer x[3,3] = outerProduct({1.0,2,3}, {4,5,6});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OuterProduct_OuterProduct3",
            description="outerProduct() operator: wrong numeric type",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end OuterProduct3; 


model OuterProduct4
 Integer x = outerProduct(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OuterProduct_OuterProduct4",
            description="outerProduct() operator: scalar arguments",
            errorMessage="
2 errors found:

Error at line 2, column 27, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function outerProduct(): types of positional argument 1 and input x are not compatible
    type of '1' is Integer
    expected type is Real[:]

Error at line 2, column 30, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function outerProduct(): types of positional argument 2 and input y are not compatible
    type of '2' is Integer
    expected type is Real[:]
")})));
end OuterProduct4; 


model OuterProduct5
 String x[3,3] = outerProduct({"1","2","3"}, {"4","5","6"});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OuterProduct_OuterProduct5",
            description="outerProduct() operator: wrong type",
            errorMessage="
2 errors found:

Error at line 2, column 31, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function outerProduct(): types of positional argument 1 and input x are not compatible
    type of '{\"1\", \"2\", \"3\"}' is String[3]
    expected type is Real[:]

Error at line 2, column 46, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function outerProduct(): types of positional argument 2 and input y are not compatible
    type of '{\"4\", \"5\", \"6\"}' is String[3]
    expected type is Real[:]
")})));
end OuterProduct5; 


model OuterProduct6
 Integer x[3,3,3,3] = outerProduct({{1,2,3},{1,2,3},{1,2,3}}, {{4,5,6},{4,5,6},{4,5,6}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OuterProduct_OuterProduct6",
            description="outerProduct() operator: too many dims",
            errorMessage="
2 errors found:

Error at line 2, column 36, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function outerProduct(): types of positional argument 1 and input x are not compatible
    type of '{{1, 2, 3}, {1, 2, 3}, {1, 2, 3}}' is Integer[3, 3]
    expected type is Real[:]

Error at line 2, column 63, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function outerProduct(): types of positional argument 2 and input y are not compatible
    type of '{{4, 5, 6}, {4, 5, 6}, {4, 5, 6}}' is Integer[3, 3]
    expected type is Real[:]
")})));
end OuterProduct6; 
		
end OuterProduct;


package Cat
	
model ArrayCat1
 Real x[5,2] = cat(1, {{1,2},{3,4}}, {{5,6}}, {{7,8},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Cat_ArrayCat1",
            description="cat() operator: basic test",
            flatModel="
fclass ArrayBuiltins.Cat.ArrayCat1
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[2,1] = 3;
 constant Real x[2,2] = 4;
 constant Real x[3,1] = 5;
 constant Real x[3,2] = 6;
 constant Real x[4,1] = 7;
 constant Real x[4,2] = 8;
 constant Real x[5,1] = 9;
 constant Real x[5,2] = 0;
end ArrayBuiltins.Cat.ArrayCat1;
")})));
end ArrayCat1;


model ArrayCat2
 Real x[2,5] = cat(2, {{1.0,2.0},{6,7}}, {{3},{8}}, {{4,5},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Cat_ArrayCat2",
            description="cat() operator: basic test",
            flatModel="
fclass ArrayBuiltins.Cat.ArrayCat2
 constant Real x[1,1] = 1.0;
 constant Real x[1,2] = 2.0;
 constant Real x[1,3] = 3;
 constant Real x[1,4] = 4;
 constant Real x[1,5] = 5;
 constant Real x[2,1] = 6;
 constant Real x[2,2] = 7;
 constant Real x[2,3] = 8;
 constant Real x[2,4] = 9;
 constant Real x[2,5] = 0;
end ArrayBuiltins.Cat.ArrayCat2;
")})));
end ArrayCat2;


model ArrayCat3
 String x[2,5] = cat(2, {{"1","2"},{"6","7"}}, {{"3"},{"8"}}, {{"4","5"},{"9","0"}});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Cat_ArrayCat3",
            description="cat() operator: using strings",
            flatModel="
fclass ArrayBuiltins.Cat.ArrayCat3
 discrete String x[2,5] = cat(2, {{\"1\", \"2\"}, {\"6\", \"7\"}}, {{\"3\"}, {\"8\"}}, {{\"4\", \"5\"}, {\"9\", \"0\"}});
end ArrayBuiltins.Cat.ArrayCat3;
")})));
end ArrayCat3;


model ArrayCat4
 Integer x[5,2] = cat(2, {{1,2},{3,4}}, {{5,6,0}}, {{7,8},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayCat4",
            description="cat() operator: size mismatch",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Types do not match in array concatenation
")})));
end ArrayCat4;


model ArrayCat5
 Integer x[2,5] = cat(2, {{1,2},{6,7}}, {{3},{8},{0}}, {{4,5},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayCat5",
            description="cat() operator: size mismatch",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Types do not match in array concatenation
")})));
end ArrayCat5;


model ArrayCat6
 Integer x[2,5] = cat(2, {{1.0,2},{6,7}}, {{3},{8}}, {{4,5},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayCat6",
            description="cat() operator: type mismatch",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ArrayCat6;


model ArrayCat6b
 Integer x[2,5] = cat(2, {{"1","2"},{"6","7"}}, {{3},{8}}, {{4,5},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayCat6b",
            description="cat() operator: type mismatch",
            errorMessage="
1 errors found:

Error at line 2, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Types do not match in array concatenation
")})));
end ArrayCat6b;


model ArrayCat7
 Integer d = 1;
 Integer x[4] = cat(d, {1,2}, {4,5});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayCat7",
            description="cat() operator: to high variability of dim",
            errorMessage="
1 errors found:

Error at line 3, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Dimension argument of cat() does not have constant variability: d
")})));
end ArrayCat7;


model ArrayCat8
 parameter Integer d = 1;
 Integer x[4] = cat(d, {1,2}, {4,5});

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Cat_ArrayCat8",
            description="cat() operator: parameter dim",
            flatModel="
fclass ArrayBuiltins.Cat.ArrayCat8
 parameter Integer d = 1 /* 1 */;
 discrete Integer x[4] = cat(d, {1, 2}, {4, 5});
end ArrayBuiltins.Cat.ArrayCat8;
")})));
end ArrayCat8;


model ArrayCat9
 Integer x[4] = cat(1.0, {1,2}, {4,5});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayCat9",
            description="cat() operator: non-Integer dim",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Dimension argument of cat() is not compatible with Integer: 1.0
")})));
end ArrayCat9;


model ArrayCat10
  Real x[2] = cat(1, {1}, 2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayCat10",
            description="Records:",
            errorMessage="
1 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Types do not match in array concatenation
")})));
end ArrayCat10;


model ArrayCat11
    record A
        Real x;
    end A;
    
    A a1[2];
    A a2[3];
    A a3[5](x = 1:5) = cat(1, a1, a2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Cat_ArrayCat11",
            description="",
            flatModel="
fclass ArrayBuiltins.Cat.ArrayCat11
 ArrayBuiltins.Cat.ArrayCat11.A a1[2];
 ArrayBuiltins.Cat.ArrayCat11.A a2[3];
 ArrayBuiltins.Cat.ArrayCat11.A a3[5] = cat(1, a1[1:2], a2[1:3]);

public
 record ArrayBuiltins.Cat.ArrayCat11.A
  Real x;
 end ArrayBuiltins.Cat.ArrayCat11.A;

end ArrayBuiltins.Cat.ArrayCat11;
")})));
end ArrayCat11;

model ArrayCat12
    function f
        input Real[:] x;
        output Real[:] y = cat(1,x);
    algorithm
        annotation(Inline=false);
    end f; 
    
    constant Real[:] k = {1,2};
    constant Real[:] a = cat(1, k);
    constant Real[:] b = f(k);
    Real[:] c = cat(1, {time,time});
    Real[:] d = f({time,time});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Cat_ArrayCat12",
            description="Single argument cat",
            eliminate_linear_equations=false,
            flatModel="
fclass ArrayBuiltins.Cat.ArrayCat12
 constant Real k[1] = 1;
 constant Real k[2] = 2;
 Real c[1];
 Real c[2];
 Real d[1];
 Real d[2];
equation
 c[1] = time;
 c[2] = time;
 ({d[1], d[2]}) = ArrayBuiltins.Cat.ArrayCat12.f({time, time});

public
 function ArrayBuiltins.Cat.ArrayCat12.f
  input Real[:] x;
  output Real[:] y;
  Real[:] temp_1;
 algorithm
  init y as Real[size(x, 1)];
  init temp_1 as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   temp_1[i1] := x[i1];
  end for;
  for i1 in 1:size(x, 1) loop
   y[i1] := temp_1[i1];
  end for;
  return;
 annotation(Inline = false);
 end ArrayBuiltins.Cat.ArrayCat12.f;

end ArrayBuiltins.Cat.ArrayCat12;
")})));
end ArrayCat12;


model ArrayShortCat1
 Real x[2,3] = [1,2,3; 4,5,6];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Cat_ArrayShortCat1",
            description="Shorthand array concatenation operator: basic test",
            flatModel="
fclass ArrayBuiltins.Cat.ArrayShortCat1
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 2;
 constant Real x[1,3] = 3;
 constant Real x[2,1] = 4;
 constant Real x[2,2] = 5;
 constant Real x[2,3] = 6;
end ArrayBuiltins.Cat.ArrayShortCat1;
")})));
end ArrayShortCat1;

model ArrayShortCat2
 Real x[3,3] = [a, b; c, d];
 Real a = 1;
 Real b[1,2] = {{2,3}};
 Real c[2] = {4,7};
 Real d[2,2] = {{5,6},{8,9}};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Cat_ArrayShortCat2",
            description="Shorthand array concatenation operator: different sizes",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Cat.ArrayShortCat2
 constant Real x[1,1] = 1.0;
 constant Real x[1,2] = 2.0;
 constant Real x[1,3] = 3.0;
 constant Real x[2,1] = 4.0;
 constant Real x[2,2] = 5.0;
 constant Real x[2,3] = 6.0;
 constant Real x[3,1] = 7.0;
 constant Real x[3,2] = 8.0;
 constant Real x[3,3] = 9.0;
 constant Real a = 1;
 constant Real b[1,1] = 2;
 constant Real b[1,2] = 3;
 constant Real c[1] = 4;
 constant Real c[2] = 7;
 constant Real d[1,1] = 5;
 constant Real d[1,2] = 6;
 constant Real d[2,1] = 8;
 constant Real d[2,2] = 9;
end ArrayBuiltins.Cat.ArrayShortCat2;
")})));
end ArrayShortCat2;


model ArrayShortCat3
 Real x[2,2,2,1] = [{{{{1},{2}}}}, {{{3,4}}}; {{{5,6}}}, {{{7,8}}}];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Cat_ArrayShortCat3",
            description="Shorthand array concatenation operator: more than 2 dimensions",
            flatModel="
fclass ArrayBuiltins.Cat.ArrayShortCat3
 constant Real x[1,1,1,1] = 1;
 constant Real x[1,1,2,1] = 2;
 constant Real x[1,2,1,1] = 3;
 constant Real x[1,2,2,1] = 4;
 constant Real x[2,1,1,1] = 5;
 constant Real x[2,1,2,1] = 6;
 constant Real x[2,2,1,1] = 7;
 constant Real x[2,2,2,1] = 8;
end ArrayBuiltins.Cat.ArrayShortCat3;
")})));
end ArrayShortCat3;


model ArrayShortCat4
 Real x[2,3] = [{{1,2,3}}; {{4,5}}];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayShortCat4",
            description="Shorthand array concatenation operator:",
            errorMessage="
1 errors found:

Error at line 2, column 16, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Types do not match in array concatenation
")})));
end ArrayShortCat4;


model ArrayShortCat5
 Real x[3,2] = [{1,2,3}, {4,5}];

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Cat_ArrayShortCat5",
            description="Shorthand array concatenation operator:",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Types do not match in array concatenation
")})));
end ArrayShortCat5;

end Cat;



package End
	
model ArrayEnd1
 Real x[4] = {1,2,3,4};
 Real y[2] = x[2:end-1] * 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="End_ArrayEnd1",
            description="end operator: basic test",
            flatModel="
fclass ArrayBuiltins.End.ArrayEnd1
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
 constant Real x[4] = 4;
 constant Real y[1] = 4.0;
 constant Real y[2] = 6.0;
end ArrayBuiltins.End.ArrayEnd1;
")})));
end ArrayEnd1;


model ArrayEnd2
 Real x[4] = {1,2,3,4};
 Real y = 2 - end;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="End_ArrayEnd2",
            description="End operator: using in wrong place",
            errorMessage="
1 errors found:

Error at line 3, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  The end operator may only be used in array subscripts
")})));
end ArrayEnd2;


model ArrayEnd3
 constant Integer x1[4] = {1,2,3,4};
 Real x2[5] = {5,6,7,8,9};
 Real y[2] = x2[end.-x1[2:end-1]];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="End_ArrayEnd3",
            description="End operator: nestled array subscripts",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.End.ArrayEnd3
 constant Integer x1[1] = 1;
 constant Integer x1[2] = 2;
 constant Integer x1[3] = 3;
 constant Integer x1[4] = 4;
 constant Real x2[1] = 5;
 constant Real x2[2] = 6;
 constant Real x2[3] = 7;
 constant Real x2[4] = 8;
 constant Real x2[5] = 9;
 constant Real y[1] = 7.0;
 constant Real y[2] = 6.0;
end ArrayBuiltins.End.ArrayEnd3;
")})));
end ArrayEnd3;

end End;



package DimensionConvert

model Scalar1
	Real[1,1,1] x = {{{1}}};
	Real y = scalar(x) + 1;
	Real z = scalar({{{{2}}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DimensionConvert_Scalar1",
            description="Scalar operator: basic test",
            flatModel="
fclass ArrayBuiltins.DimensionConvert.Scalar1
 constant Real x[1,1,1] = 1;
 constant Real y = 2.0;
 constant Real z = 2;
end ArrayBuiltins.DimensionConvert.Scalar1;
")})));
end Scalar1;

model Scalar2
    Real[1,1,2] x = {{{1,2}}};
    Real y = scalar(x) + 1;
    Real z = scalar({{{{3},{4}}}});
	Real w = scalar(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DimensionConvert_Scalar2",
            description="Scalar operator: bad size",
            errorMessage="
2 errors found:

Error at line 3, column 21, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function scalar(): types of positional argument 1 and input A are not compatible
    type of 'x' is Real[1, 1, 2]
    expected type is array with exactly 1 element

Error at line 4, column 21, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function scalar(): types of positional argument 1 and input A are not compatible
    type of '{{{{3}, {4}}}}' is Integer[1, 1, 2, 1]
    expected type is array with exactly 1 element
")})));
end Scalar2;


model Vector1
    Real[1,1,1] x = {{{1}}};
    Real[1] y = vector(x) .+ 1;
    Real[1] z = vector(2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DimensionConvert_Vector1",
            description="Vector operator: scalar arg",
            flatModel="
fclass ArrayBuiltins.DimensionConvert.Vector1
 constant Real x[1,1,1] = 1;
 constant Real y[1] = 2.0;
 constant Real z[1] = 2;
end ArrayBuiltins.DimensionConvert.Vector1;
")})));
end Vector1;

model Vector2
    Real[2] x = vector({1,2});
    Real[2] y = vector({{1},{2}});
    Real[2] z = vector({{1,2}});
    Real[2] w = vector({{{{1}},{{2}}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DimensionConvert_Vector2",
            description="Vector operator: basic test",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.DimensionConvert.Vector2
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real y[1] = 1;
 constant Real y[2] = 2;
 constant Real z[1] = 1;
 constant Real z[2] = 2;
 constant Real w[1] = 1;
 constant Real w[2] = 2;
end ArrayBuiltins.DimensionConvert.Vector2;
")})));
end Vector2;

model Vector3
    Real[2] x = vector({{1,2},{3,4}});
    Real[2] y = vector({{{{{1},{2}}},{{{3},{4}}}}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DimensionConvert_Vector3",
            description="Vector operator: bad size",
            errorMessage="
2 errors found:

Error at line 2, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function vector(): types of positional argument 1 and input A are not compatible
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
    expected type is scalar or vector-shaped array

Error at line 3, column 24, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function vector(): types of positional argument 1 and input A are not compatible
    type of '{{{{{1}, {2}}}, {{{3}, {4}}}}}' is Integer[1, 2, 1, 2, 1]
    expected type is scalar or vector-shaped array
")})));
end Vector3;


model Matrix1
	Real[1,1] x = matrix(1);
    Real[2,1] y = matrix({1,2});
    Real[2,2] z = matrix({{1,2},{3,4}});
    Real[2,2] w = matrix({{{1},{2}},{{3},{4}}});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DimensionConvert_Matrix1",
            description="Matrix operator: basic test",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.DimensionConvert.Matrix1
 constant Real x[1,1] = 1;
 constant Real y[1,1] = 1;
 constant Real y[2,1] = 2;
 constant Real z[1,1] = 1;
 constant Real z[1,2] = 2;
 constant Real z[2,1] = 3;
 constant Real z[2,2] = 4;
 constant Real w[1,1] = 1;
 constant Real w[1,2] = 2;
 constant Real w[2,1] = 3;
 constant Real w[2,2] = 4;
end ArrayBuiltins.DimensionConvert.Matrix1;
")})));
end Matrix1;

model Matrix2
    Real[1,2] z = matrix({{{1,2},{3,4}}});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DimensionConvert_Matrix2",
            description="Matrix operator: bad size",
            errorMessage="
1 errors found:

Error at line 2, column 26, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function matrix(): types of positional argument 1 and input A are not compatible
    type of '{{{1, 2}, {3, 4}}}' is Integer[1, 2, 2]
    expected type is scalar, vector or matrix-shaped array
")})));
end Matrix2;

end DimensionConvert;



model Linspace1
 Real x[4] = linspace(1, 3, 4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Linspace1",
            description="Linspace operator: basic test",
            flatModel="
fclass ArrayBuiltins.Linspace1
 constant Real x[1] = 1;
 constant Real x[2] = 1.6666666666666665;
 constant Real x[3] = 2.333333333333333;
 constant Real x[4] = 3.0;
end ArrayBuiltins.Linspace1;
")})));
end Linspace1;


model Linspace2
 Real a = 1;
 Real b = 2;
 parameter Integer c = 3;
 Real x[3] = linspace(a, b, c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Linspace2",
            description="Linspace operator: using parameter component as n",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Linspace2
 Real a;
 Real b;
 structural parameter Integer c = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 a = 1;
 b = 2;
 x[1] = a;
 x[2] = a + (b - a) / 2;
 x[3] = a + 2 * ((b - a) / 2);
end ArrayBuiltins.Linspace2;
")})));
end Linspace2;


model Linspace3
 Real a = 1;
 Real b = 2;
 parameter Real c = 3;
 Real x[3] = linspace(a, b, c);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Linspace3",
            description="Linspace operator: wrong type of n",
            errorMessage="
1 errors found:

Error at line 5, column 29, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function linspace(): types of positional argument 3 and input n are not compatible
    type of 'c' is Real
    expected type is Integer
")})));
end Linspace3;


model Linspace4
 Real a = 1;
 Real b = 2;
 parameter Integer c(fixed=false);
 Real x[3] = linspace(a, b, c);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Linspace4",
            description="Linspace operator: wrong variability of n",
            errorMessage="
1 errors found:

Error at line 5, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Third argument of linspace() must be a scalar parameter Integer expression that is greater than 1
    'c' is of initial parameter variability
")})));
end Linspace4;


model Linspace5
 Integer x[4] = linspace(1, 3, 3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Linspace5",
            description="Linspace operator: using result as Integer",
            errorMessage="
1 errors found:

Error at line 2, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', BINDING_EXPRESSION_TYPE_MISMATCH:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end Linspace5;


model Linspace6
	model A
		parameter Real x;
	end A;
	
    parameter Real b = 1.5;
    parameter Real c = 3;
    parameter Integer d = 3;
	
	A a[d](x = linspace(b, c, d));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Linspace6",
            description="Linspace operator: parameter args",
            flatModel="
fclass ArrayBuiltins.Linspace6
 parameter Real b = 1.5 /* 1.5 */;
 parameter Real c = 3 /* 3 */;
 structural parameter Integer d = 3 /* 3 */;
 parameter Real a[1].x;
 parameter Real a[2].x;
 parameter Real a[3].x;
parameter equation
 a[1].x = b;
 a[2].x = b + (c - b) / 2;
 a[3].x = b + 2 * ((c - b) / 2);
end ArrayBuiltins.Linspace6;
")})));
end Linspace6;

model Linspace7
 function f
  input Integer x1;
  input Integer x2;
  input Integer n;
  output Real[n] a = linspace(x1,x2,n);
 algorithm
 end f;

 Real x[3] = f(1,4,3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Linspace7",
            description="Linspace operator: basic test",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass ArrayBuiltins.Linspace7
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = ArrayBuiltins.Linspace7.f(1, 4, 3);

public
 function ArrayBuiltins.Linspace7.f
  input Integer x1;
  input Integer x2;
  input Integer n;
  output Real[:] a;
 algorithm
  init a as Real[n];
  for i1 in 1:n loop
   a[i1] := x1 + (i1 - 1) * ((x2 - x1) / (n - 1));
  end for;
  return;
 end ArrayBuiltins.Linspace7.f;

end ArrayBuiltins.Linspace7;
")})));
end Linspace7;


model Linspace8
 Real a = 1;
 Real b = 2;
 parameter Integer c = 1;
 Real x[3] = linspace(a, b, c);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Linspace8",
            description="Linspace operator: to low value for n",
            errorMessage="
1 errors found:

Error at line 5, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Third argument of linspace() must be a scalar parameter Integer expression that is greater than 1
    'c' evaluates to 1
")})));
end Linspace8;

model Linspace9
    parameter Integer n = 1;
    Real x[n] = if n >= 2 then linspace(1, 2, n) else (1:n);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Linspace9",
            description="Linspace operator: to low value for n in inactive branch",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Linspace9
 structural parameter Integer n = 1 /* 1 */;
 constant Real x[1] = 1;
end ArrayBuiltins.Linspace9;
")})));
end Linspace9;


model NdimsExp1
 constant Integer n = ndims({{1,2},{3,4}});
 Integer x = n * 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NdimsExp1",
            description="Ndims operator: basic test",
            flatModel="
fclass ArrayBuiltins.NdimsExp1
 constant Integer n = 2;
 constant Integer x = 4;
end ArrayBuiltins.NdimsExp1;
")})));
end NdimsExp1;


model NdimsStructural1
    Real x[p1,ndims(p2)];
    Real y = p1 + p2 * p3;
    parameter Integer p1 = ndims(p3);
    parameter Real p2[1] = {1};
    parameter Real p3[1] = {2};

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NdimsStructural1",
            description="Using parameter in ndims() expression that is used as structural parameter should not make that parameter a structural parameter",
            flatModel="
fclass ArrayBuiltins.NdimsStructural1
 Real x[1,1];
 Real y = 1 + p2[1:1] * p3[1:1];
 structural parameter Integer p1 = 1 /* 1 */;
 parameter Real p2[1] = {1} /* { 1 } */;
 parameter Real p3[1] = {2} /* { 2 } */;
end ArrayBuiltins.NdimsStructural1;
")})));
end NdimsStructural1;



model ArrayIfExp1
  parameter Integer N = 3;
  parameter Real A[N,N] = identity(N);
  Real x[N](each start = 1);
equation
  der(x) = if time>=3 then A*x/N else -A*x/N;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayIfExp1",
            description="Array if expressions",
            flatModel="
fclass ArrayBuiltins.ArrayIfExp1
 structural parameter Integer N = 3 /* 3 */;
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 0 /* 0 */;
 parameter Real A[1,3] = 0 /* 0 */;
 parameter Real A[2,1] = 0 /* 0 */;
 parameter Real A[2,2] = 1 /* 1 */;
 parameter Real A[2,3] = 0 /* 0 */;
 parameter Real A[3,1] = 0 /* 0 */;
 parameter Real A[3,2] = 0 /* 0 */;
 parameter Real A[3,3] = 1 /* 1 */;
 Real x[1](start = 1);
 Real x[2](start = 1);
 Real x[3](start = 1);
initial equation 
 x[1] = 1;
 x[2] = 1;
 x[3] = 1;
equation
 der(x[1]) = if time >= 3 then (A[1,1] * x[1] + A[1,2] * x[2] + A[1,3] * x[3]) / 3 else ((- A[1,1]) * x[1] + (- A[1,2]) * x[2] + (- A[1,3]) * x[3]) / 3;
 der(x[2]) = if time >= 3 then (A[2,1] * x[1] + A[2,2] * x[2] + A[2,3] * x[3]) / 3 else ((- A[2,1]) * x[1] + (- A[2,2]) * x[2] + (- A[2,3]) * x[3]) / 3;
 der(x[3]) = if time >= 3 then (A[3,1] * x[1] + A[3,2] * x[2] + A[3,3] * x[3]) / 3 else ((- A[3,1]) * x[1] + (- A[3,2]) * x[2] + (- A[3,3]) * x[3]) / 3;
end ArrayBuiltins.ArrayIfExp1;
")})));
end ArrayIfExp1;


model ArrayIfExp2
  constant Real a = if 1 > 2 then 5 elseif 1 < 2 then 6 else 7;
  Real b = a;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayIfExp2",
            description="Constant evaluation of if expression",
            flatModel="
fclass ArrayBuiltins.ArrayIfExp2
 constant Real a = 6;
 constant Real b = 6.0;
end ArrayBuiltins.ArrayIfExp2;
")})));
end ArrayIfExp2;


model ArrayIfExp3
    parameter Real tableA[:, :] = fill(0.0, 0, 2);
    parameter Real tableB[:, :] = fill(1.0, 1, 2);
    parameter Boolean useTableA = false;
    Real y;
equation
    y = if useTableA then tableA[1, 1] else tableB[1, 1];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayIfExp3",
            description="Eliminate branches causing index out of bounds",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.ArrayIfExp3
 parameter Real tableB[1,1] = 1.0 /* 1.0 */;
 parameter Real tableB[1,2] = 1.0 /* 1.0 */;
 structural parameter Boolean useTableA = false /* false */;
 parameter Real y;
parameter equation
 y = tableB[1,1];
end ArrayBuiltins.ArrayIfExp3;
")})));
end ArrayIfExp3;



model Identity1
  parameter Real A[3,3] = identity(3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Identity1",
            description="identity() operator: basic test",
            flatModel="
fclass ArrayBuiltins.Identity1
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 0 /* 0 */;
 parameter Real A[1,3] = 0 /* 0 */;
 parameter Real A[2,1] = 0 /* 0 */;
 parameter Real A[2,2] = 1 /* 1 */;
 parameter Real A[2,3] = 0 /* 0 */;
 parameter Real A[3,1] = 0 /* 0 */;
 parameter Real A[3,2] = 0 /* 0 */;
 parameter Real A[3,3] = 1 /* 1 */;
end ArrayBuiltins.Identity1;
")})));
end Identity1;


model Identity2
  parameter Real A = identity(3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Identity2",
            description="identity() operator:",
            errorMessage="
1 errors found:

Error at line 2, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', ARRAY_SIZE_MISMATCH_IN_DECLARATION:
  Array size mismatch in declaration of A, size of declaration is scalar and size of binding expression is [3, 3]
")})));
end Identity2;


model Identity3
  Integer n = 3;
  parameter Real A[3,3] = identity(n);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Identity3",
            description="identity() operator:",
            errorMessage="
1 errors found:

Error at line 3, column 27, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Argument of identity() must be a scalar parameter Integer expression
    'n' is of discrete-time variability
")})));
end Identity3;


model Identity4
  parameter Real A[3,3] = identity(3.0);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Identity4",
            description="identity() operator:",
            errorMessage="
1 errors found:

Error at line 2, column 36, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function identity(): types of positional argument 1 and input n are not compatible
    type of '3.0' is Real
    expected type is Integer
")})));
end Identity4;



model Diagonal1
	Real x[2,2] = diagonal({1,2});
    Integer y[3,3] = diagonal({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Diagonal1",
            description="diagonal() operator: basic test",
            eliminate_alias_variables=false,
            flatModel="
fclass ArrayBuiltins.Diagonal1
 constant Real x[1,1] = 1;
 constant Real x[1,2] = 0;
 constant Real x[2,1] = 0;
 constant Real x[2,2] = 2;
 constant Integer y[1,1] = 1;
 constant Integer y[1,2] = 0;
 constant Integer y[1,3] = 0;
 constant Integer y[2,1] = 0;
 constant Integer y[2,2] = 2;
 constant Integer y[2,3] = 0;
 constant Integer y[3,1] = 0;
 constant Integer y[3,2] = 0;
 constant Integer y[3,3] = 3;
end ArrayBuiltins.Diagonal1;
")})));
end Diagonal1;


model Diagonal2
    Real x[2,2] = diagonal({{1,2},{3,4}});
    Real y[:,:] = diagonal(1);
    Boolean z[2,2] = diagonal({true,true});

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Diagonal2",
            description="diagonal() operator: wrong type of arg",
            errorMessage="
3 errors found:

Error at line 2, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function diagonal(): types of positional argument 1 and input v are not compatible
    type of '{{1, 2}, {3, 4}}' is Integer[2, 2]
    expected type is Real[:]

Error at line 3, column 28, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function diagonal(): types of positional argument 1 and input v are not compatible
    type of '1' is Integer
    expected type is Real[:]

Error at line 4, column 31, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function diagonal(): types of positional argument 1 and input v are not compatible
    type of '{true, true}' is Boolean[2]
    expected type is Real[:]
")})));
end Diagonal2;



model ScalarSize1
  Real x[1] = cat(1, {1}, size(Modelica.Constants.pi));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ScalarSize1",
            description="Size of zero-length vector",
            flatModel="
fclass ArrayBuiltins.ScalarSize1
 Real x[1] = cat(1, {1}, size(3.141592653589793));
end ArrayBuiltins.ScalarSize1;
")})));
end ScalarSize1;


model ScalarSize2
  Real x[1] = {1} + Modelica.Constants.pi;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ScalarSize2",
            description="Size of scalar dotted access",
            errorMessage="
1 errors found:

Error at line 2, column 15, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: {1} + Modelica.Constants.pi
    type of '{1}' is Integer[1]
    type of 'Modelica.Constants.pi' is Real
")})));
end ScalarSize2;


model NonVectorizedScalarization1
    function f1
        input Real x1[3];
        output Real y1[3];
    algorithm
        y1 := f2(x1) * x1;
    end f1;
    
    function f2
        input Real x2[3];
        output Real y2;
    algorithm
        y2 := sum(x2);
    end f2;
    
    Real x[3] = {1,2,3};
    Real y[3] = f1(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonVectorizedScalarization1",
            description="Test of accesses that should be kept without indices during scalarization",
            flatModel="
fclass ArrayBuiltins.NonVectorizedScalarization1
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
 constant Real y[1] = 6.0;
 constant Real y[2] = 12.0;
 constant Real y[3] = 18.0;
end ArrayBuiltins.NonVectorizedScalarization1;
")})));
end NonVectorizedScalarization1;


model NonVectorizedScalarization2
    function f1
        input Real x1[:];
        output Real y1[size(x1,1)];
    algorithm
        y1 := f2(x1) * x1;
    end f1;
    
    function f2
        input Real x2[:];
        output Real y2;
    algorithm
        y2 := sum(x2);
    end f2;
    
    Real x[3] = {1,2,3};
    Real y[3] = f1(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonVectorizedScalarization2",
            description="Test of accesses that should be kept without indices during scalarization",
            flatModel="
fclass ArrayBuiltins.NonVectorizedScalarization2
 constant Real x[1] = 1;
 constant Real x[2] = 2;
 constant Real x[3] = 3;
 constant Real y[1] = 6.0;
 constant Real y[2] = 12.0;
 constant Real y[3] = 18.0;
end ArrayBuiltins.NonVectorizedScalarization2;
")})));
end NonVectorizedScalarization2;


model NonVectorizedScalarization3

  function length
    input Real v[:];
    output Real result;
  algorithm
    result := sqrt(v*v);
  end length;

    function normalize
        input Real v[:];
        input Real eps(min=0.0)=100*Modelica.Constants.eps;
        output Real result[size(v, 1)];
    algorithm
       result := smooth(0, if length(v) >= eps then v/length(v) else v/eps);
    end normalize;
    
    Real x[3] = {1,2,3};
    Real y[3] = normalize(x);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonVectorizedScalarization3",
            description="Test of accesses that should be kept without indices during scalarization",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass ArrayBuiltins.NonVectorizedScalarization3
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
 ({y[1], y[2], y[3]}) = ArrayBuiltins.NonVectorizedScalarization3.normalize({x[1], x[2], x[3]}, 100 * 1.0E-15);

public
 function ArrayBuiltins.NonVectorizedScalarization3.normalize
  input Real[:] v;
  input Real eps;
  output Real[:] result;
 algorithm
  init result as Real[size(v, 1)];
  for i1 in 1:size(v, 1) loop
   result[i1] := smooth(0, if ArrayBuiltins.NonVectorizedScalarization3.length(v) >= eps then v[i1] / ArrayBuiltins.NonVectorizedScalarization3.length(v) else v[i1] / eps);
  end for;
  return;
 end ArrayBuiltins.NonVectorizedScalarization3.normalize;

 function ArrayBuiltins.NonVectorizedScalarization3.length
  input Real[:] v;
  output Real result;
  Real temp_1;
  Real temp_2;
 algorithm
  temp_2 := 0.0;
  for i1 in 1:size(v, 1) loop
   temp_2 := temp_2 + v[i1] * v[i1];
  end for;
  temp_1 := temp_2;
  result := sqrt(temp_1);
  return;
 end ArrayBuiltins.NonVectorizedScalarization3.length;

end ArrayBuiltins.NonVectorizedScalarization3;
")})));
end NonVectorizedScalarization3;


model InfArgsWithNamed
	Real x[2,2] = ones(2, 2, xxx = 3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InfArgsWithNamed",
            description="",
            errorMessage="
1 errors found:

Error at line 2, column 27, in file 'Compiler/ModelicaFrontEnd/test/modelica/ArrayBuiltins.mo':
  Calling function ones(): no input matching named argument xxx found
")})));
end InfArgsWithNamed;

end ArrayBuiltins;
