/*
    Copyright (C) 2014 Modelon AB

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

package OperatorRecordTests


    operator record Cplx
        replaceable Real re;
        replaceable Real im;

        encapsulated operator function 'constructor'
            input Real re;
            input Real im = 0;
            output Cplx c;
        algorithm
            c.re := re;
            c.im := im;
        end 'constructor';

        encapsulated operator function '0'
            output Cplx c;
        algorithm
            c := Cplx(0);
        end '0';

        encapsulated operator function '+'
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re + b.re, a.im + b.im);
        end '+';

        encapsulated operator '-'
            function sub
                input Cplx a;
                input Cplx b;
                output Cplx c;
            algorithm
                c := Cplx(a.re - b.re, a.im - b.im);
            end sub;

            function neg
                input Cplx a;
                output Cplx c;
            algorithm
                c := Cplx(-a.re, -a.im);
            end neg;
        end '-';

        encapsulated operator '*'
            function mul
                input Cplx a;
                input Cplx b;
                output Cplx c;
            algorithm
                c := Cplx(a.re*b.re - a.im*b.im, a.re*b.im + a.im*b.re);
            end mul;

            function prod
                input Cplx[:] a;
                input Cplx[size(a,1)] b;
                output Cplx c;
            algorithm
                c := Complex(0);
                for i in 1:size(a, 1) loop
                    c :=c + a[i] * b[i];
                end for;
            end prod;
        end '*';

        encapsulated operator function 'String'
            input Cplx a;
            output String b;
        algorithm
            if a.im == 0 then
                b := String(a.re);
            elseif a.re == 0 then
                b := String(a.im) + "j";
            else
                b := String(a.re) + " + " + String(a.im) + "j";
            end if;
        end 'String';

        encapsulated operator function '/' // Dummy implementation for simplicity
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re / b.re, a.im / b.im);
        end '/';

        encapsulated operator function '^' // Dummy implementation for simplicity
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re ^ b.re, a.im ^ b.im);
        end '^';

        encapsulated operator function '=='
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re == b.re and a.im == b.im;
        end '==';

        encapsulated operator function '<>'
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re <> b.re or a.im <> b.im;
        end '<>';

        encapsulated operator function '>'
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 > b.re ^ 2 + b.im ^ 2;
        end '>';

        encapsulated operator function '<'
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 < b.re ^ 2 + b.im ^ 2;
        end '<';

        encapsulated operator function '>='
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 >= b.re ^ 2 + b.im ^ 2;
        end '>=';

        encapsulated operator function '<='
            input Cplx a;
            input Cplx b;
            output Boolean c;
        algorithm
            c := a.re ^ 2 + a.im ^ 2 <= b.re ^ 2 + b.im ^ 2;
        end '<=';

        encapsulated operator function 'and' // Dummy implementation for testing
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re + b.re, a.im + b.im);
        end 'and';

        encapsulated operator function 'or' // Dummy implementation for testing
            input Cplx a;
            input Cplx b;
            output Cplx c;
        algorithm
            c := Cplx(a.re - b.re, a.im - b.im);
        end 'or';

        encapsulated operator function 'not' // Dummy implementation for testing (conjugate)
            input Cplx a;
            output Cplx c;
        algorithm
            c := Cplx(a.re, -a.im);
        end 'not';
    end Cplx;


    model OperatorOverload1
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload1",
            description="Basic test of overloaded operators: addition",
            flatModel="
fclass OperatorRecordTests.OperatorOverload1
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload1;
")})));
    end OperatorOverload1;


    model OperatorOverload2
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 - c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload2",
            description="Basic test of overloaded operators: subtraction",
            flatModel="
fclass OperatorRecordTests.OperatorOverload2
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'-'.sub(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.sub
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'-'.sub;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload2;
")})));
    end OperatorOverload2;


    model OperatorOverload3
        Cplx c1 = Cplx(1, 2);
        Cplx c3 = -c1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload3",
            description="Basic test of overloaded operators: negation",
            flatModel="
fclass OperatorRecordTests.OperatorOverload3
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'-'.neg(c1);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.neg
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(- a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'-'.neg;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload3;
")})));
    end OperatorOverload3;


    model OperatorOverload4
        Cplx c1 = Cplx(1, 2);
        Boolean b = false;
        Cplx c3 = c1 - b;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorOverload4",
            description="Basic type error test for operator records",
            errorMessage="
1 errors found:

Error at line 4, column 19, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: c1 - b
    type of 'c1' is OperatorRecordTests.Cplx
    type of 'b' is Boolean
")})));
    end OperatorOverload4;


    model OperatorOverload5
        Cplx c1 = Cplx(1, 2);
        Real r = 3;
        Cplx c3 = c1 + r;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload5",
            description="Automatic type conversion for overloaded operators: right",
            flatModel="
fclass OperatorRecordTests.OperatorOverload5
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 Real r = 3;
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, OperatorRecordTests.Cplx.'constructor'(r, 0));

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload5;
")})));
    end OperatorOverload5;


    model OperatorOverload6
        Cplx c1 = Cplx(1, 2);
        Real r = 3;
        Cplx c3 = r * 4 + c1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload6",
            description="Automatic type conversion for overloaded operators: left",
            flatModel="
fclass OperatorRecordTests.OperatorOverload6
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 Real r = 3;
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'constructor'(r * 4, 0), c1);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload6;
")})));
    end OperatorOverload6;


    model OperatorOverload7
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Cplx[2] c2 = { Cplx(5, 6), Cplx(7, 8) };
        Cplx[2] c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload7",
            description="Array addition with operator records",
            flatModel="
fclass OperatorRecordTests.OperatorOverload7
 OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)};
 OperatorRecordTests.Cplx c2[2] = {OperatorRecordTests.Cplx.'constructor'(5, 6), OperatorRecordTests.Cplx.'constructor'(7, 8)};
 OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx.'+'(c1[1], c2[1]), OperatorRecordTests.Cplx.'+'(c1[2], c2[2])};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload7;
")})));
    end OperatorOverload7;


    model OperatorOverload8
        Cplx c1 = Cplx(1, 2);
        Real[2] r = { 3, 4 };
        Cplx[2] c3 = c1 .+ r;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload8",
            description="Scalar-array addition with operator records and automatic type conversion",
            flatModel="
fclass OperatorRecordTests.OperatorOverload8
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 Real r[2] = {3, 4};
 OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx.'+'(c1, OperatorRecordTests.Cplx.'constructor'(r[1], 0)), OperatorRecordTests.Cplx.'+'(c1, OperatorRecordTests.Cplx.'constructor'(r[2], 0))};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload8;
")})));
    end OperatorOverload8;


    model OperatorOverload9
        operator record Op
            Real x;
            Real y;
            
            encapsulated operator function '*'
                input Op a;
                input Op b;
                output Op c;
            algorithm
                (c) := Op(a.x * b.x, a.y * b.y);
            end '*';
        end Op;
        
	        Op[2] c1 = { Op(1, 2), Op(3, 4) };
        Op[2] c2 = { Op(5, 6), Op(7, 8) };
        Op c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorOverload9",
            description="Error for array multiplication cases not allowed for operator records: vector*vector",
            errorMessage="
1 errors found:

Error at line 17, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: c1 * c2
    type of 'c1' is OperatorRecordTests.OperatorOverload9.Op[2]
    type of 'c2' is OperatorRecordTests.OperatorOverload9.Op[2]
")})));
    end OperatorOverload9;


    model OperatorOverload10
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Cplx[2,2] c2 = { { Cplx(5, 6), Cplx(7, 8) }, { Cplx(9, 10), Cplx(11, 12) } };
        Cplx[2] c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorOverload10",
            description="Error for array multiplication cases not allowed for operator records: vector*matrix",
            errorMessage="
1 errors found:

Error at line 4, column 22, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo', TYPE_MISMATCH_IN_EXPRESSION:
  Type error in expression: c1 * c2
    type of 'c1' is OperatorRecordTests.Cplx[2]
    type of 'c2' is OperatorRecordTests.Cplx[2, 2]
")})));
    end OperatorOverload10;


// TODO: This is wrong! Function OperatorRecordTests.Cplx.'+' is not present in flat model.
    model OperatorOverload11
        Cplx[2,2] c1 = { { Cplx(1, 2), Cplx(3, 4) }, { Cplx(5, 6), Cplx(7, 8) } };
        Cplx[2,2] c2 = { { Cplx(11, 12), Cplx(13, 14) }, { Cplx(15, 16), Cplx(17, 18) } };
        Cplx[2,2] c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload11",
            description="Matrix multiplication with operator records",
            flatModel="
fclass OperatorRecordTests.OperatorOverload11
 OperatorRecordTests.Cplx c1[2,2] = {{OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)}, {OperatorRecordTests.Cplx.'constructor'(5, 6), OperatorRecordTests.Cplx.'constructor'(7, 8)}};
 OperatorRecordTests.Cplx c2[2,2] = {{OperatorRecordTests.Cplx.'constructor'(11, 12), OperatorRecordTests.Cplx.'constructor'(13, 14)}, {OperatorRecordTests.Cplx.'constructor'(15, 16), OperatorRecordTests.Cplx.'constructor'(17, 18)}};
 OperatorRecordTests.Cplx c3[2,2] = {{OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[1,1], c2[1,1]), OperatorRecordTests.Cplx.'*'.mul(c1[1,2], c2[2,1])), OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[1,1], c2[1,2]), OperatorRecordTests.Cplx.'*'.mul(c1[1,2], c2[2,2]))}, {OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[2,1], c2[1,1]), OperatorRecordTests.Cplx.'*'.mul(c1[2,2], c2[2,1])), OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'*'.mul(c1[2,1], c2[1,2]), OperatorRecordTests.Cplx.'*'.mul(c1[2,2], c2[2,2]))}};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'*'.mul
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
  return;
 end OperatorRecordTests.Cplx.'*'.mul;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload11;
")})));
    end OperatorOverload11;


    model OperatorOverload12
        constant Cplx c1 = Cplx(1, 2);
        constant Cplx c2 = Cplx(3, 4);
        constant Cplx c3 = c1 + c2;
        constant Cplx c4 = c3;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload12",
            description="Constant eval of overloaded operator expression: scalars",
            flatModel="
fclass OperatorRecordTests.OperatorOverload12
 constant OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx(1, 2);
 constant OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx(3, 4);
 constant OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx(4.0, 6.0);
 constant OperatorRecordTests.Cplx c4 = OperatorRecordTests.Cplx(4.0, 6.0);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload12;
")})));
    end OperatorOverload12;


    model OperatorOverload13
        constant Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        constant Cplx[2] c2 = { Cplx(5, 6), Cplx(7, 8) };
        constant Cplx[2] c3 = c1 + c2;
        constant Cplx[2] c4 = c3;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload13",
            description="Constant eval of overloaded operator expression: arrays",
            flatModel="
fclass OperatorRecordTests.OperatorOverload13
 constant OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx(1, 2), OperatorRecordTests.Cplx(3, 4)};
 constant OperatorRecordTests.Cplx c2[2] = {OperatorRecordTests.Cplx(5, 6), OperatorRecordTests.Cplx(7, 8)};
 constant OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx(6.0, 8.0), OperatorRecordTests.Cplx(10.0, 12.0)};
 constant OperatorRecordTests.Cplx c4[2] = {OperatorRecordTests.Cplx(6.0, 8.0), OperatorRecordTests.Cplx(10.0, 12.0)};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload13;
")})));
    end OperatorOverload13;


    model OperatorOverload14
		operator record Cplx2 = Cplx;
        Cplx c1 = Cplx(1, 2);
        Cplx2 c2 = Cplx2(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload14",
            description="Short class decls of operator records",
            flatModel="
fclass OperatorRecordTests.OperatorOverload14
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.OperatorOverload14.Cplx2 c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

 record OperatorRecordTests.OperatorOverload14.Cplx2
  Real re;
  Real im;
 end OperatorRecordTests.OperatorOverload14.Cplx2;

end OperatorRecordTests.OperatorOverload14;
")})));
    end OperatorOverload14;


    model OperatorOverload15
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Cplx[2] c2 = { Cplx(5, 6), Cplx(7, 8) };
        Cplx c3 = c1 * c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload15",
            description="Using overloaded operator taking array args",
            flatModel="
fclass OperatorRecordTests.OperatorOverload15
 OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)};
 OperatorRecordTests.Cplx c2[2] = {OperatorRecordTests.Cplx.'constructor'(5, 6), OperatorRecordTests.Cplx.'constructor'(7, 8)};
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'*'.prod(c1[1:2], c2[1:2]);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'*'.prod
  input OperatorRecordTests.Cplx[:] a;
  input OperatorRecordTests.Cplx[:] b;
  output OperatorRecordTests.Cplx c;
 algorithm
  for i1 in 1:size(a, 1) loop
  end for;
  assert(size(a, 1) == size(b, 1), \"Mismatching sizes in function 'OperatorRecordTests.Cplx.'*'.prod', component 'b', dimension '1'\");
  for i1 in 1:size(b, 1) loop
  end for;
  (c) := Complex.'constructor'.fromReal(0, 0);
  for i in 1:size(a, 1) loop
   c := OperatorRecordTests.Cplx.'+'(c, OperatorRecordTests.Cplx.'*'.mul(a[i], b[i]));
  end for;
  return;
 end OperatorRecordTests.Cplx.'*'.prod;

 function Complex.'constructor'.fromReal
  input Real re;
  input Real im;
  output Complex result;
 algorithm
  result.re := re;
  result.im := im;
  return;
 annotation(Inline = true);
 end Complex.'constructor'.fromReal;

 function OperatorRecordTests.Cplx.'*'.mul
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
  return;
 end OperatorRecordTests.Cplx.'*'.mul;

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

 record Complex
  Real re \"Real part of complex number\";
  Real im \"Imaginary part of complex number\";
 end Complex;

end OperatorRecordTests.OperatorOverload15;
")})));
    end OperatorOverload15;


    model OperatorOverload16
        constant Cplx c1 = Cplx(1, 2);
        constant String s1 = String(c1);
        constant String s2 = s1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload16",
            description="Overloading of String()",
            flatModel="
fclass OperatorRecordTests.OperatorOverload16
 constant OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx(1, 2);
 constant String s1 = \"1.00000 + 2.00000j\";
 constant String s2 = \"1.00000 + 2.00000j\";

public
 function OperatorRecordTests.Cplx.'String'
  input OperatorRecordTests.Cplx a;
  output String b;
 algorithm
  if a.im == 0 then
   b := String(a.re);
  elseif a.re == 0 then
   b := String(a.im) + \"j\";
  else
   b := String(a.re) + \" + \" + String(a.im) + \"j\";
  end if;
  return;
 end OperatorRecordTests.Cplx.'String';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload16;
")})));
    end OperatorOverload16;


    model OperatorOverload17
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 / c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload17",
            description="Basic test of overloaded operators: division",
            flatModel="
fclass OperatorRecordTests.OperatorOverload17
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'/'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'/'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re / b.re, a.im / b.im);
  return;
 end OperatorRecordTests.Cplx.'/';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload17;
")})));
    end OperatorOverload17;


    model OperatorOverload18
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 ^ c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload18",
            description="Basic test of overloaded operators: power",
            flatModel="
fclass OperatorRecordTests.OperatorOverload18
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'^'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'^'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re ^ b.re, a.im ^ b.im);
  return;
 end OperatorRecordTests.Cplx.'^';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload18;
")})));
    end OperatorOverload18;


    model OperatorOverload19
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 == c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload19",
            description="Basic test of overloaded operators: equals",
            flatModel="
fclass OperatorRecordTests.OperatorOverload19
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'=='(c1, c2);

public
 function OperatorRecordTests.Cplx.'=='
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re == b.re and a.im == b.im;
  return;
 end OperatorRecordTests.Cplx.'==';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload19;
")})));
    end OperatorOverload19;


    model OperatorOverload20
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 <> c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload20",
            description="Basic test of overloaded operators: not equals",
            flatModel="
fclass OperatorRecordTests.OperatorOverload20
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'<>'(c1, c2);

public
 function OperatorRecordTests.Cplx.'<>'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re <> b.re or a.im <> b.im;
  return;
 end OperatorRecordTests.Cplx.'<>';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload20;
")})));
    end OperatorOverload20;


    model OperatorOverload21
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 < c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload21",
            description="Basic test of overloaded operators: less",
            flatModel="
fclass OperatorRecordTests.OperatorOverload21
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'<'(c1, c2);

public
 function OperatorRecordTests.Cplx.'<'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 < b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'<';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload21;
")})));
    end OperatorOverload21;


    model OperatorOverload22
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 > c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload22",
            description="Basic test of overloaded operators: greater",
            flatModel="
fclass OperatorRecordTests.OperatorOverload22
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'>'(c1, c2);

public
 function OperatorRecordTests.Cplx.'>'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 > b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'>';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload22;
")})));
    end OperatorOverload22;


    model OperatorOverload23
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 <= c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload23",
            description="Basic test of overloaded operators: less or equal",
            flatModel="
fclass OperatorRecordTests.OperatorOverload23
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'<='(c1, c2);

public
 function OperatorRecordTests.Cplx.'<='
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 <= b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'<=';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload23;
")})));
    end OperatorOverload23;


    model OperatorOverload24
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Boolean b = c1 >= c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload24",
            description="Basic test of overloaded operators: greater or equal",
            flatModel="
fclass OperatorRecordTests.OperatorOverload24
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 discrete Boolean b = OperatorRecordTests.Cplx.'>='(c1, c2);

public
 function OperatorRecordTests.Cplx.'>='
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output Boolean c;
 algorithm
  c := a.re ^ 2 + a.im ^ 2 >= b.re ^ 2 + b.im ^ 2;
  return;
 end OperatorRecordTests.Cplx.'>=';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload24;
")})));
    end OperatorOverload24;


    model OperatorOverload25
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 and c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload25",
            description="Basic test of overloaded operators: and",
            flatModel="
fclass OperatorRecordTests.OperatorOverload25
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'and'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'and'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'and';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload25;
")})));
    end OperatorOverload25;


    model OperatorOverload26
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = c1 or c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload26",
            description="Basic test of overloaded operators: or",
            flatModel="
fclass OperatorRecordTests.OperatorOverload26
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'or'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'or'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'or';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload26;
")})));
    end OperatorOverload26;


    model OperatorOverload27
        Cplx c1 = Cplx(1, 2);
        Cplx c3 = not c1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload27",
            description="Basic test of overloaded operators: not",
            flatModel="
fclass OperatorRecordTests.OperatorOverload27
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'not'(c1);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'not'
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'not';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload27;
")})));
    end OperatorOverload27;


    model OperatorOverload28
        Cplx c1 = Cplx(1, 2);
        Cplx c2 = Cplx(3, 4);
        Cplx c3 = if time < 2 then c1 else c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload28",
            description="If expression with operator record",
            flatModel="
fclass OperatorRecordTests.OperatorOverload28
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.Cplx c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = if time < 2 then c1 else c2;

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload28;
")})));
    end OperatorOverload28;


    model OperatorOverload29
        Cplx[2] c1 = { Cplx(1, 2), Cplx(3, 4) };
        Real r1 = 1;
        Cplx[2] c3 = c1 * r1;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorOverload29",
            description="Checks that automatic conversions are only applied for scalar inputs",
            flatModel="
fclass OperatorRecordTests.OperatorOverload29
 OperatorRecordTests.Cplx c1[2] = {OperatorRecordTests.Cplx.'constructor'(1, 2), OperatorRecordTests.Cplx.'constructor'(3, 4)};
 Real r1 = 1;
 OperatorRecordTests.Cplx c3[2] = {OperatorRecordTests.Cplx.'*'.mul(c1[1], OperatorRecordTests.Cplx.'constructor'(r1, 0)), OperatorRecordTests.Cplx.'*'.mul(c1[2], OperatorRecordTests.Cplx.'constructor'(r1, 0))};

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'*'.mul
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
  return;
 end OperatorRecordTests.Cplx.'*'.mul;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorOverload29;
")})));
    end OperatorOverload29;


    model OperatorRecordConnect1
        connector C
            Cplx x;
            flow Cplx y;
        end C;

        C c1, c2, c3;
    equation
        connect(c1, c2);
        connect(c1, c3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect1",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect1
 potential OperatorRecordTests.Cplx c1.x;
 flow OperatorRecordTests.Cplx c1.y;
 potential OperatorRecordTests.Cplx c2.x;
 flow OperatorRecordTests.Cplx c2.y;
 potential OperatorRecordTests.Cplx c3.x;
 flow OperatorRecordTests.Cplx c3.y;
equation
 c1.x = c2.x;
 c2.x = c3.x;
 OperatorRecordTests.Cplx.'-'.sub(OperatorRecordTests.Cplx.'-'.sub(OperatorRecordTests.Cplx.'-'.neg(c1.y), c2.y), c3.y) = OperatorRecordTests.Cplx.'0'();

public
 function OperatorRecordTests.Cplx.'0'
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(0, 0);
  return;
 end OperatorRecordTests.Cplx.'0';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.neg
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(- a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'-'.neg;

 function OperatorRecordTests.Cplx.'-'.sub
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'-'.sub;

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect1;
")})));
    end OperatorRecordConnect1;


    model OperatorRecordConnect2
        connector C
            Cplx x;
            flow Cplx y;
        end C;

        model A
            C c;
        end A;

        A a1, a2, a3, a4;
    equation
        connect(a1.c, a2.c);
        connect(a1.c, a3.c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect2",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect2
 OperatorRecordTests.Cplx a1.c.x;
 OperatorRecordTests.Cplx a1.c.y;
 OperatorRecordTests.Cplx a2.c.x;
 OperatorRecordTests.Cplx a2.c.y;
 OperatorRecordTests.Cplx a3.c.x;
 OperatorRecordTests.Cplx a3.c.y;
 OperatorRecordTests.Cplx a4.c.x;
 OperatorRecordTests.Cplx a4.c.y;
equation
 a1.c.x = a2.c.x;
 a2.c.x = a3.c.x;
 OperatorRecordTests.Cplx.'+'(OperatorRecordTests.Cplx.'+'(a1.c.y, a2.c.y), a3.c.y) = OperatorRecordTests.Cplx.'0'();
 a4.c.y = OperatorRecordTests.Cplx.'0'();

public
 function OperatorRecordTests.Cplx.'0'
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(0, 0);
  return;
 end OperatorRecordTests.Cplx.'0';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'-'.neg
  input OperatorRecordTests.Cplx a;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(- a.re, - a.im);
  return;
 end OperatorRecordTests.Cplx.'-'.neg;

 function OperatorRecordTests.Cplx.'-'.sub
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re - b.re, a.im - b.im);
  return;
 end OperatorRecordTests.Cplx.'-'.sub;

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect2;
")})));
    end OperatorRecordConnect2;


    model OperatorRecordConnect3
        connector C = Cplx;

        C c1, c2, c3;
    equation
        connect(c1, c2);
		c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect3",
            description="Connectors that are operator records",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect3
 OperatorRecordTests.OperatorRecordConnect3.C c1;
 OperatorRecordTests.OperatorRecordConnect3.C c2;
 OperatorRecordTests.OperatorRecordConnect3.C c3;
equation
 c3 = OperatorRecordTests.Cplx.'+'(c1, c2);
 c1 = c2;

public
 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.OperatorRecordConnect3.C
  Real re;
  Real im;
 end OperatorRecordTests.OperatorRecordConnect3.C;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect3;
")})));
    end OperatorRecordConnect3;


    model OperatorRecordConnect4
        connector C
            Cplx x;
            flow Cplx y;
        end C;

        C c;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect4",
            description="Connector with flow operator record without connection",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect4
 potential OperatorRecordTests.Cplx c.x;
 flow OperatorRecordTests.Cplx c.y;

public
 function OperatorRecordTests.Cplx.'0'
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(0, 0);
  return;
 end OperatorRecordTests.Cplx.'0';

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorRecordConnect4;
")})));
    end OperatorRecordConnect4;


    model OperatorRecordConnect5
        connector C = Cplx;
        
        model A
            C c;
        end A;
        
        A a[2];
        C c[2];
    equation
        connect(a.c, c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorRecordConnect5",
            description="Test connecting to array of operator record",
            flatModel="
fclass OperatorRecordTests.OperatorRecordConnect5
 OperatorRecordTests.OperatorRecordConnect5.C a[1].c;
 OperatorRecordTests.OperatorRecordConnect5.C a[2].c;
 OperatorRecordTests.OperatorRecordConnect5.C c[2];
equation
 a[1].c = c[1];
 a[2].c = c[2];

public
 record OperatorRecordTests.OperatorRecordConnect5.C
  Real re;
  Real im;
 end OperatorRecordTests.OperatorRecordConnect5.C;

end OperatorRecordTests.OperatorRecordConnect5;
")})));
    end OperatorRecordConnect5;


    model OperatorLimitations1
        encapsulated operator function '*'
            input Real x;
            input Real y;
            output Real z;
        algorithm
            z := x * y;
        end '*';
        
        Real x = '*'(1, time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations1",
            description="Check that operators are not allowed outside operator records",
            errorMessage="
1 errors found:

Error at line 2, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator classes are only allowed in operator records and packages in operator records
")})));
    end OperatorLimitations1;


    model OperatorLimitations2
        operator record A
            Real x;
            
            package B
                encapsulated operator function '*'
                    input A x;
                    input A y;
                    output Real z;
                algorithm
                    z := x.x * y.x;
                end '*';
            end B;
        end A;
        
        Real x = A.B.'*'(A(1), A(time));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations2",
            description="Check that operators are allowed inside packages inside operator records",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations2
 Real x = OperatorRecordTests.OperatorLimitations2.A.B.'*'(OperatorRecordTests.OperatorLimitations2.A(1), OperatorRecordTests.OperatorLimitations2.A(time));

public
 function OperatorRecordTests.OperatorLimitations2.A.B.'*'
  input OperatorRecordTests.OperatorLimitations2.A x;
  input OperatorRecordTests.OperatorLimitations2.A y;
  output Real z;
 algorithm
  z := x.x * y.x;
  return;
 end OperatorRecordTests.OperatorLimitations2.A.B.'*';

 record OperatorRecordTests.OperatorLimitations2.A
  Real x;
 end OperatorRecordTests.OperatorLimitations2.A;

end OperatorRecordTests.OperatorLimitations2;
")})));
    end OperatorLimitations2;


    model OperatorLimitations3
        model A
            encapsulated operator function '*'
                input Real x;
                input Real y;
                output Real z;
            algorithm
                z := x * y;
            end '*';
            
            Real x = '*'(1, time);
        end A;
        
        model B
            extends A;
        end B;
        
        A a;
        B b;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations3",
            description="Check that operators are not allowed outside operator records",
            errorMessage="
1 errors found:

Error at line 3, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo',
In components:
    a
    b
  Operator classes are only allowed in operator records and packages in operator records
")})));
    end OperatorLimitations3;


    model OperatorLimitations4
        operator record A
            Real x;
            
            encapsulated operator ':'
                function f
                    input A x;
                    input A y;
                    output A z;
                algorithm
                   z := A(x.x * y.x);
                end f;
            end ':';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations4",
            description="Check that only the operators listed in the spec are legal to overload",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Invalid name for operator class: ':'
")})));
    end OperatorLimitations4;


    model OperatorLimitations5
        operator record A
            Real x;
            
            encapsulated operator function f
                input A x;
                input A y;
                output A z;
            algorithm
               z := x * y;
            end f;
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations5",
            description="Check that only the operators listed in the spec are legal to overload",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Invalid name for operator class: f
")})));
    end OperatorLimitations5;


    model OperatorLimitations6
        operator record A
            Real x;
            
            encapsulated operator function '-'
                input Real x;
                input Real y;
                output A z;
            algorithm
               z := A(x - y);
            end '-';
            
            encapsulated operator function 'String'
                input Real x;
                input Real y;
                output String z;
            algorithm
               z := "test";
            end 'String';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations6",
            description="Check that operator functions for non-constructors must have an argument of the record type",
            errorMessage="
2 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions must have at least one argument that is of the type of the operator record the function belongs to

Error at line 13, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  First argument of conversion operator functions must be of the type of the operator record the function belongs to
")})));
    end OperatorLimitations6;


    model OperatorLimitations7
        operator record A
            Real x;
            
            encapsulated operator function 'constructor'
                input Real x;
                output Real z;
            algorithm
               z := x;
            end 'constructor';
            
            encapsulated operator function '0'
                output Real z;
            algorithm
               z := 0;
            end '0';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations7",
            description="Check that operator functions for constructors must have a single output of the record type",
            errorMessage="
2 errors found:

Error at line 7, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Output of operator record constructor must be of the type of the operator record the constructor belongs to

Error at line 13, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Output of operator record constructor must be of the type of the operator record the constructor belongs to
")})));
    end OperatorLimitations7;


    model OperatorLimitations8
        operator record A
            Real x;
            
            encapsulated operator function '*'
                input A x;
                input A y;
            algorithm
            end '*';
            
            encapsulated operator function '-'
                input A x;
                input A y;
                output A z1;
                output A z2;
            algorithm
               z1 := A(x - y);
               z2 := A(x + y);
            end '-';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations8",
            description="Check that operator functions must have a single output",
            errorMessage="
2 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions must have exactly one output, but '*' has 0

Error at line 11, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions must have exactly one output, but '-' has 2
")})));
    end OperatorLimitations8;


    model OperatorLimitations9
        operator record A
            Real x;
            
            operator '*'
                function f
                    input A x;
                    input A y;
                    output A z;
                algorithm
                   z := A(x.x * y.x);
                end f;
            end '*';
            
            operator function '-'
                input A x;
                input A y;
                output A z;
            algorithm
               z := A(x.x - y.x);
            end '-';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations9",
            description="Check that operators must be encapsulated",
            errorMessage="
2 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator classes must be encapsulated

Error at line 15, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator classes must be encapsulated
")})));
    end OperatorLimitations9;


    model OperatorLimitations10
        operator record A
            Real x;
            
            encapsulated package B
                function f
                    input Real x;
                    output Real y;
                algorithm
                    y := x + 1;
                end f;
            end B;
            
        end A;
        
        A a = A(A.B.f(time));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations10",
            description="Check that loose functions and packages are allowed in operator records",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations10
 OperatorRecordTests.OperatorLimitations10.A a = OperatorRecordTests.OperatorLimitations10.A(OperatorRecordTests.OperatorLimitations10.A.B.f(time));

public
 function OperatorRecordTests.OperatorLimitations10.A.B.f
  input Real x;
  output Real y;
 algorithm
  y := x + 1;
  return;
 end OperatorRecordTests.OperatorLimitations10.A.B.f;

 record OperatorRecordTests.OperatorLimitations10.A
  Real x;
 end OperatorRecordTests.OperatorLimitations10.A;

end OperatorRecordTests.OperatorLimitations10;
")})));
    end OperatorLimitations10;


    model OperatorLimitations11
        operator record A
            Real x;
            
            encapsulated package B
                constant Real d = 1;
                
                model C
                    Real x = time + 1;
                end C;
            end B;
            
            model D
                Real y = time + 2;
            end D;
            
        end A;
        
        A a = A(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations11",
            description="Check for content that is not allowed in operator records",
            errorMessage="
3 errors found:

Error at line 6, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Components are not allowed in packages in operator records

Error at line 8, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Classes other than operators, operator functions, functions and packages are not allowed in operator record classes

Error at line 13, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Classes other than operators, operator functions, functions and packages are not allowed in operator record classes
")})));
    end OperatorLimitations11;


    model OperatorLimitations12
        operator record Cplx2
            extends Cplx;
        end Cplx2;
        Cplx c1 = Cplx(1, 2);
        Cplx2 c2 = Cplx2(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations12",
            description="Extending operator record is only allowed in short class decl",
            errorMessage="
1 errors found:

Error at line 3, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Extending operator records is only allowed as a short class declaration
")})));
    end OperatorLimitations12;


    model OperatorLimitations13
        operator record Cplx2 = Cplx(re = 1);
        Cplx c1 = Cplx(1, 2);
        Cplx2 c2 = Cplx2(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations13",
            description="Short class decl of operator record may only modify attributes",
            errorMessage="
1 errors found:

Error at line 2, column 38, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo',
In component c2:
  Short class declarations extending an operator record may only modify attributes of members of the record
")})));
    end OperatorLimitations13;


    model OperatorLimitations14
        operator record A
            Real x;
            
            encapsulated operator '+'
                replaceable function f
                    input A x;
                    input A y;
                    output A z;
                algorithm
                   z := A(x.x + y.x);
               end f;
            end '+';
        end A;
        
        function g
            input B x;
            input B y;
            output B z;
        algorithm
           z := B(x.x - y.x);
        end g;
        
        operator record B = A('+'(redeclare function f = g));
        
        B b = B(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations14",
            description="Short class decl of operator record may only modify attributes",
            errorMessage="
1 errors found:

Error at line 24, column 35, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo',
In component b:
  Short class declarations extending an operator record may only modify attributes of members of the record
")})));
    end OperatorLimitations14;


    model OperatorLimitations14b
        type T = Real(max=5, nominal=2);

        operator record A
            Real x;
            
            encapsulated operator '+'
                function f
                    input A x;
                    replaceable input Real y;
                    output A z;
                algorithm
                   z := A(x.x + y);
               end f;
            end '+';
        end A;
        
        operator record B = A('+'(f(redeclare input T y)));
        
        B b = B(time);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations14b",
            description="Short class decl of operator record may only modify attributes of record member",
            errorMessage="
1 errors found:

Error at line 18, column 37, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo',
In component b:
  Short class declarations extending an operator record may only modify attributes of members of the record
")})));
    end OperatorLimitations14b;


    model OperatorLimitations15
        operator record Cplx2 = Cplx(re(min=1), im(max=5, nominal=2));
        Cplx c1 = Cplx(1, 2);
        Cplx2 c2 = Cplx2(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations15",
            description="Short class decl of operator record may modify attributes of record members",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations15
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.OperatorLimitations15.Cplx2 c2(re(min = 1),im(max = 5,nominal = 2)) = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

 record OperatorRecordTests.OperatorLimitations15.Cplx2
  Real re;
  Real im;
 end OperatorRecordTests.OperatorLimitations15.Cplx2;

end OperatorRecordTests.OperatorLimitations15;
")})));
    end OperatorLimitations15;


    model OperatorLimitations15b
        type T = Real(max=5, nominal=2);
        operator record Cplx2 = Cplx(redeclare T re, redeclare T im);
        Cplx c1 = Cplx(1, 2);
        Cplx2 c2 = Cplx2(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations15b",
            description="Short class decl of operator record may modify attributes of record members through redeclare on primitive",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations15b
 OperatorRecordTests.Cplx c1 = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.OperatorLimitations15b.Cplx2 c2 = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.Cplx c3 = OperatorRecordTests.Cplx.'+'(c1, c2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

 record OperatorRecordTests.OperatorLimitations15b.Cplx2
  OperatorRecordTests.OperatorLimitations15b.T re;
  OperatorRecordTests.OperatorLimitations15b.T im;
 end OperatorRecordTests.OperatorLimitations15b.Cplx2;

 type OperatorRecordTests.OperatorLimitations15b.T = Real(max = 5,nominal = 2);
end OperatorRecordTests.OperatorLimitations15b;
")})));
    end OperatorLimitations15b;


    model OperatorLimitations16
        operator record Cplx2 = Cplx('+'(a(re(min = 1))));
        Cplx c1 = Cplx(1, 2);
        Cplx2 c2 = Cplx2(3, 4);
        Cplx c3 = c1 + c2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations16",
            description="Short class decl of operator record may only modify attributes of record members in the record declaration (i.e. not in functions)",
            errorMessage="
1 errors found:

Error at line 2, column 47, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo',
In component c2:
  Short class declarations extending an operator record may only modify attributes of members of the record
")})));
    end OperatorLimitations16;


    model OperatorLimitations17
        operator record A
            Real x;
            
            encapsulated operator function 'constructor'
                input B x;
                output A z;
            algorithm
               z.x := x.x;
            end 'constructor';
        end A;

        operator record B
            Real x;
            
            encapsulated operator function 'constructor'
                input A x;
                output B z;
            algorithm
               z.x := x.x;
            end 'constructor';
        end B;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations17",
            description="Circular overloaded conversion operators",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Ambiguous overloaded constructors in OperatorRecordTests.OperatorLimitations17.A and OperatorRecordTests.OperatorLimitations17.B
")})));
    end OperatorLimitations17;


    model OperatorLimitations18
        operator record A
            Real x;
            
            encapsulated operator function 'constructor'
                input B x;
                output A z;
            algorithm
               z.x := x.x;
            end 'constructor';
        end A;

        operator record B
            Real x;
            
            encapsulated operator function 'constructor'
                input Real x;
                output B z;
            algorithm
               z.x := x;
            end 'constructor';
        end B;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations18",
            description="Non-circular overloaded conversion operators",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations18
 OperatorRecordTests.OperatorLimitations18.A a;

public
 record OperatorRecordTests.OperatorLimitations18.A
  Real x;
 end OperatorRecordTests.OperatorLimitations18.A;

end OperatorRecordTests.OperatorLimitations18;
")})));
    end OperatorLimitations18;


    model OperatorLimitations19
        operator record A
            Real x;
            
            encapsulated operator function '0'
                input Real x;
                output A z;
            algorithm
               z.x := x;
            end '0';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations19",
            description="Zero constructor with input",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  The '0' operator record constructor may not have any inputs, but has 1
")})));
    end OperatorLimitations19;


    model OperatorLimitations20
        operator record A
            Real x;
            
            encapsulated operator '0'
                function a
                    output A z;
                algorithm
                   z.x := 0;
                end a;
                
                function b
                    output A z;
                algorithm
                   z.x := 0;
                end b;
            end '0';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations20",
            description="More than one zero constructor",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  The '0' operator may not contain more than one function, but has 2
")})));
    end OperatorLimitations20;


    model OperatorLimitations21
        operator record A
            Real x;
            
            encapsulated operator function 'String'
                input A x;
                output Real z;
            algorithm
               z := x.x;
            end 'String';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations21",
            description="'String' operator returning Real",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  'String' operator functions must have one output of type String, but returns Real
")})));
    end OperatorLimitations21;


    model OperatorLimitations22
        operator record A
            Real x;
            
            encapsulated operator 'String'
                function a
                    input A x;
                    output String[1] z;
                algorithm
                   z := { String(x.x) };
                end a;
            end 'String';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations22",
            description="'String' operator returning array",
            errorMessage="
1 errors found:

Error at line 6, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  'String' operator functions must have one output of type String, but a returns String[1]
")})));
    end OperatorLimitations22;


    model OperatorLimitations23
        operator record A
            Real x;
            
            encapsulated operator function '*'
                input A x;
                input A y;
                output A z;
            algorithm
               z := A(x.x * y.x);
            end '*';
        end A;
        
        parameter Integer n = 0;
        A a[2, n] = fill(A(time), 2, n);
        A b[n, 2] = fill(A(time + 1), n, 2);
        A c[2, 2] = a * b;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations23",
            description="",
            errorMessage="
1 errors found:

Error at line 17, column 21, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Matrix multiplication of operator records with an inner dimension of 0 or : requires that an '0' operator is defined
")})));
    end OperatorLimitations23;


    model OperatorLimitations24
        operator record A
            Real x;
            
            encapsulated operator function '*'
                input A x;
                input A y;
                output A z;
            algorithm
               z := A(x.x * y.x);
            end '*';
            
            encapsulated operator function '+' // This function should be included in flat code
                input A x;
                input A y;
                output A z;
            algorithm
                z := A(x.x + y.x);
            end '+';
        end A;
        
        parameter Integer n = 2;
        A a[2, n] = fill(A(time), 2, n);
        A b[n, 2] = fill(A(time + 1), n, 2);
        A c[2, 2] = a * b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations24",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations24
 structural parameter Integer n = 2 /* 2 */;
 OperatorRecordTests.OperatorLimitations24.A a[2,2] = fill(OperatorRecordTests.OperatorLimitations24.A(time), 2, 2);
 OperatorRecordTests.OperatorLimitations24.A b[2,2] = fill(OperatorRecordTests.OperatorLimitations24.A(time + 1), 2, 2);
 OperatorRecordTests.OperatorLimitations24.A c[2,2] = {{OperatorRecordTests.OperatorLimitations24.A.'+'(OperatorRecordTests.OperatorLimitations24.A.'*'(a[1,1], b[1,1]), OperatorRecordTests.OperatorLimitations24.A.'*'(a[1,2], b[2,1])), OperatorRecordTests.OperatorLimitations24.A.'+'(OperatorRecordTests.OperatorLimitations24.A.'*'(a[1,1], b[1,2]), OperatorRecordTests.OperatorLimitations24.A.'*'(a[1,2], b[2,2]))}, {OperatorRecordTests.OperatorLimitations24.A.'+'(OperatorRecordTests.OperatorLimitations24.A.'*'(a[2,1], b[1,1]), OperatorRecordTests.OperatorLimitations24.A.'*'(a[2,2], b[2,1])), OperatorRecordTests.OperatorLimitations24.A.'+'(OperatorRecordTests.OperatorLimitations24.A.'*'(a[2,1], b[1,2]), OperatorRecordTests.OperatorLimitations24.A.'*'(a[2,2], b[2,2]))}};

public
 function OperatorRecordTests.OperatorLimitations24.A.'*'
  input OperatorRecordTests.OperatorLimitations24.A x;
  input OperatorRecordTests.OperatorLimitations24.A y;
  output OperatorRecordTests.OperatorLimitations24.A z;
 algorithm
  z := OperatorRecordTests.OperatorLimitations24.A(x.x * y.x);
  return;
 end OperatorRecordTests.OperatorLimitations24.A.'*';

 record OperatorRecordTests.OperatorLimitations24.A
  Real x;
 end OperatorRecordTests.OperatorLimitations24.A;

end OperatorRecordTests.OperatorLimitations24;
")})));
    end OperatorLimitations24;

    model OperatorLimitations25
        operator record A
            Real x;
            
            encapsulated operator function '*'
                input A x;
                input A y;
                output A z;
            algorithm
               z := A(x.x * y.x);
            end '*';
            
            encapsulated operator function '0'
                output A z;
            algorithm
               z := A(0);
            end '0';
        end A;
        
        parameter Integer n = 0;
        A a[2, n] = fill(A(time), 2, n);
        A b[n, 2] = fill(A(time + 1), n, 2);
        A c[2, 2] = a * b;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations25",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations25
 structural parameter Integer n = 0 /* 0 */;
 OperatorRecordTests.OperatorLimitations25.A a[2,0] = fill(OperatorRecordTests.OperatorLimitations25.A(time), 2, 0);
 OperatorRecordTests.OperatorLimitations25.A b[0,2] = fill(OperatorRecordTests.OperatorLimitations25.A(time + 1), 0, 2);
 OperatorRecordTests.OperatorLimitations25.A c[2,2] = {{OperatorRecordTests.OperatorLimitations25.A(0), OperatorRecordTests.OperatorLimitations25.A(0)}, {OperatorRecordTests.OperatorLimitations25.A(0), OperatorRecordTests.OperatorLimitations25.A(0)}};

public
 function OperatorRecordTests.OperatorLimitations25.A.'*'
  input OperatorRecordTests.OperatorLimitations25.A x;
  input OperatorRecordTests.OperatorLimitations25.A y;
  output OperatorRecordTests.OperatorLimitations25.A z;
 algorithm
  z := OperatorRecordTests.OperatorLimitations25.A(x.x * y.x);
  return;
 end OperatorRecordTests.OperatorLimitations25.A.'*';

 record OperatorRecordTests.OperatorLimitations25.A
  Real x;
 end OperatorRecordTests.OperatorLimitations25.A;

end OperatorRecordTests.OperatorLimitations25;
")})));
    end OperatorLimitations25;


    model OperatorLimitations26
        operator record A
            Real x;
            
            encapsulated operator function '*'
                input A x;
                input A y;
                output A z;
            algorithm
               z := A(x.x * y.x);
            end '*';
        end A;
        
        function f
            input A a[2, :];
            input A b[size(a,2), 2];
            output A c[2, 2];
        algorithm
            c := a * b;
        end f;
        
        parameter Integer n = 2;
        A a[2, n] = fill(A(time), 2, n);
        A b[n, 2] = fill(A(time + 1), n, 2);
        A c[2, 2] = f(a, b);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations26",
            description="",
            errorMessage="
1 errors found:

Error at line 19, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Matrix multiplication of operator records with an inner dimension of 0 or : requires that an '0' operator is defined
")})));
    end OperatorLimitations26;


    model OperatorLimitations27
        operator record A
            Real x;
            
            encapsulated operator function '+'
                input A x;
                output A z;
            algorithm
                z := A(x.x + 1);
            end '+';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations27",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions for binary operators must have exactly 2 inputs without default value, but '+' has 1
")})));
    end OperatorLimitations27;


    model OperatorLimitations28
        operator record A
            Real x;
            
            encapsulated operator function '+'
                input A x;
                input A y;
                input A w;
                output A z;
            algorithm
                z := A(x.x + y.x + w.x);
            end '+';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations28",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions for binary operators must have exactly 2 inputs without default value, but '+' has 3
")})));
    end OperatorLimitations28;


    model OperatorLimitations29
        operator record A
            Real x;
            
            encapsulated operator function '+'
                input A x;
                input A y = A(1);
                output A z;
            algorithm
                z := A(x.x + y.x);
            end '+';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations29",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions for binary operators must have exactly 2 inputs without default value, but '+' has 1
")})));
    end OperatorLimitations29;


    model OperatorLimitations30
        operator record A
            Real x;
            
            encapsulated operator function '+'
                input A x;
                input A y = A(1);
                input A w;
                output A z;
            algorithm
                z := A(x.x + y.x + w.x);
            end '+';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations30",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  All inputs without default value in operator function must be before all inputs with default value
")})));
    end OperatorLimitations30;


    model OperatorLimitations31
        operator record A
            Real x;
            
            encapsulated operator function '+'
                input A x;
                input A y;
                input A w = A(1);
                output A z;
            algorithm
                z := A(x.x + y.x + w.x);
            end '+';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations31",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations31
 OperatorRecordTests.OperatorLimitations31.A a;

public
 record OperatorRecordTests.OperatorLimitations31.A
  Real x;
 end OperatorRecordTests.OperatorLimitations31.A;

end OperatorRecordTests.OperatorLimitations31;
")})));
    end OperatorLimitations31;


    model OperatorLimitations32
        operator record A
            Real x;
            
            encapsulated operator function 'not'
                input A x;
                input A y;
                output A z;
            algorithm
                z := A(x.x * y.x);
            end 'not';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations32",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions for unary operators must have exactly 1 input without default value, but 'not' has 2
")})));
    end OperatorLimitations32;


    model OperatorLimitations33
        operator record A
            Real x;
            
            encapsulated operator function 'not'
                input A x = A(1);
                output A z;
            algorithm
                z := A(x.x * y.x);
            end 'not';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations33",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions for unary operators must have exactly 1 input without default value, but 'not' has 0
")})));
    end OperatorLimitations33;


    model OperatorLimitations34
        operator record A
            Real x;
            
            encapsulated operator function 'not'
                input A x = A(1);
                input A y;
                output A z;
            algorithm
                z := A(x.x * y.x);
            end 'not';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations34",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  All inputs without default value in operator function must be before all inputs with default value
")})));
    end OperatorLimitations34;


    model OperatorLimitations35
        operator record A
            Real x;
            
            encapsulated operator function 'not'
                input A x;
                input A y = A(1);
                output A z;
            algorithm
                z := A(x.x * y.x);
            end 'not';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations35",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations35
 OperatorRecordTests.OperatorLimitations35.A a;

public
 record OperatorRecordTests.OperatorLimitations35.A
  Real x;
 end OperatorRecordTests.OperatorLimitations35.A;

end OperatorRecordTests.OperatorLimitations35;
")})));
    end OperatorLimitations35;


    model OperatorLimitations36
        operator record A
            Real x;
            
            encapsulated operator function '-'
                input A x;
                input A y;
                input A w;
                output A z;
            algorithm
                z := A(x.x - y.x - w.x);
            end '-';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations36",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  Operator functions for operators that are both unary and binary must have exactly 1 or 2 inputs without default value, but '-' has 3
")})));
    end OperatorLimitations36;


    model OperatorLimitations37
        operator record A
            Real x;
            
            encapsulated operator function '-'
                input A x;
                input A y = A(1);
                input A w;
                output A z;
            algorithm
                z := A(x.x - y.x - w.x);
            end '-';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations37",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  All inputs without default value in operator function must be before all inputs with default value
")})));
    end OperatorLimitations37;


    model OperatorLimitations38
        operator record A
            Real x;
            
            encapsulated operator function '-'
                input A x = A(1);
                input A y;
                output A z;
            algorithm
                z := A(x.x - y.x);
            end '-';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OperatorLimitations38",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/OperatorRecordTests.mo':
  All inputs without default value in operator function must be before all inputs with default value
")})));
    end OperatorLimitations38;


    model OperatorLimitations39
        operator record A
            Real x;
            
            encapsulated operator '-'
                function a
                    input A x;
                    input A y = A(1);
                    output A z;
                algorithm
                    z := A(x.x - y.x);
                end a;
                
                function b
                    input A x;
                    input A y;
                    input A w = A(1);
                    output A z;
                algorithm
                    z := A(x.x - y.x - w.x);
                end b;
            end '-';
        end A;
        
        A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorLimitations39",
            description="",
            flatModel="
fclass OperatorRecordTests.OperatorLimitations39
 OperatorRecordTests.OperatorLimitations39.A a;

public
 record OperatorRecordTests.OperatorLimitations39.A
  Real x;
 end OperatorRecordTests.OperatorLimitations39.A;

end OperatorRecordTests.OperatorLimitations39;
")})));
    end OperatorLimitations39;


    model BuildArrayInInst1
        function f
            input Integer n;
            output Cplx[n] y;
        algorithm
            y := { Cplx(i) for i in 1:n };
        end f;
        
        parameter Integer n = 3;
        Cplx[n] x;
    equation
        x = f(n) * time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BuildArrayInInst1",
            description="Test of literal expressions for records built from constant evaluation in instance tree",
            flatModel="
fclass OperatorRecordTests.BuildArrayInInst1
 structural parameter Integer n = 3 /* 3 */;
 OperatorRecordTests.Cplx x[3];
equation
 x[1:3] = {OperatorRecordTests.Cplx.'*'.mul(OperatorRecordTests.Cplx(1, 0), OperatorRecordTests.Cplx.'constructor'(time, 0)), OperatorRecordTests.Cplx.'*'.mul(OperatorRecordTests.Cplx(2, 0), OperatorRecordTests.Cplx.'constructor'(time, 0)), OperatorRecordTests.Cplx.'*'.mul(OperatorRecordTests.Cplx(3, 0), OperatorRecordTests.Cplx.'constructor'(time, 0))};

public
 function OperatorRecordTests.BuildArrayInInst1.f
  input Integer n;
  output OperatorRecordTests.Cplx[:] y;
 algorithm
  init y as OperatorRecordTests.Cplx[n];
  y[:] := {OperatorRecordTests.Cplx.'constructor'(i, 0) for i in 1:n};
  return;
 end OperatorRecordTests.BuildArrayInInst1.f;

 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'*'.mul
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
  return;
 end OperatorRecordTests.Cplx.'*'.mul;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.BuildArrayInInst1;
")})));
    end BuildArrayInInst1;


    model OperatorInherit1
        operator record A = Cplx(re(min=-1), im(min=-1));
        A a1 = A(1,2);
        A a2 = A(3,4);
        A a3 = a1 + a2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorInherit1",
            description="Check that a short class decl of an operator record uses name of base class for functions",
            flatModel="
fclass OperatorRecordTests.OperatorInherit1
 OperatorRecordTests.OperatorInherit1.A a1(re(min = -1),im(min = -1)) = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.OperatorInherit1.A a2(re(min = -1),im(min = -1)) = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.OperatorInherit1.A a3(re(min = -1),im(min = -1)) = OperatorRecordTests.Cplx.'+'(a1, a2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.OperatorInherit1.A
  Real re;
  Real im;
 end OperatorRecordTests.OperatorInherit1.A;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorInherit1;
")})));
    end OperatorInherit1;


    model OperatorInherit2
        operator record A = B(re(min=-1), im(min=-1));
        operator record B = Cplx(re(max=10), im(max=10));
        A a1 = A(1,2);
        A a2 = A(3,4);
        A a3 = a1 + a2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OperatorInherit2",
            description="Check that a short class decl of an operator record uses name of base class for functions",
            flatModel="
fclass OperatorRecordTests.OperatorInherit2
 OperatorRecordTests.OperatorInherit2.A a1(re(min = -1,max = 10),im(min = -1,max = 10)) = OperatorRecordTests.Cplx.'constructor'(1, 2);
 OperatorRecordTests.OperatorInherit2.A a2(re(min = -1,max = 10),im(min = -1,max = 10)) = OperatorRecordTests.Cplx.'constructor'(3, 4);
 OperatorRecordTests.OperatorInherit2.A a3(re(min = -1,max = 10),im(min = -1,max = 10)) = OperatorRecordTests.Cplx.'+'(a1, a2);

public
 function OperatorRecordTests.Cplx.'constructor'
  input Real re;
  input Real im;
  output OperatorRecordTests.Cplx c;
 algorithm
  c.re := re;
  c.im := im;
  return;
 end OperatorRecordTests.Cplx.'constructor';

 function OperatorRecordTests.Cplx.'+'
  input OperatorRecordTests.Cplx a;
  input OperatorRecordTests.Cplx b;
  output OperatorRecordTests.Cplx c;
 algorithm
  (c) := OperatorRecordTests.Cplx.'constructor'(a.re + b.re, a.im + b.im);
  return;
 end OperatorRecordTests.Cplx.'+';

 record OperatorRecordTests.OperatorInherit2.A
  Real re;
  Real im;
 end OperatorRecordTests.OperatorInherit2.A;

 record OperatorRecordTests.Cplx
  Real re;
  Real im;
 end OperatorRecordTests.Cplx;

end OperatorRecordTests.OperatorInherit2;
")})));
    end OperatorInherit2;

package Eval

model RealTypeOpArg1
  constant Complex y1 = 3 * Complex(1,2);
  constant Complex y2 = 3 / Complex(1,2);
  constant Complex y3 = 3 + Complex(1,2);
  constant Complex y4 = 3 - Complex(1,2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RealTypeOpArg1",
            description="Constant eval of overloaded operator expression, real type inference",
            eliminate_alias_variables=false,
            flatModel="
fclass OperatorRecordTests.Eval.RealTypeOpArg1
 constant Real y1.re = 3.0 \"Real part of complex number\";
 constant Real y1.im = 6.0 \"Imaginary part of complex number\";
 constant Real y2.re = 0.6 \"Real part of complex number\";
 constant Real y2.im = -1.2 \"Imaginary part of complex number\";
 constant Real y3.re = 4.0 \"Real part of complex number\";
 constant Real y3.im = 2.0 \"Imaginary part of complex number\";
 constant Real y4.re = 2.0 \"Real part of complex number\";
 constant Real y4.im = -2.0 \"Imaginary part of complex number\";
end OperatorRecordTests.Eval.RealTypeOpArg1;
")})));
end RealTypeOpArg1;

model RealTypeOpArg2
  constant Complex[2] y1 = {3,4} * Complex(1,2);
  constant Complex[2] y2 = 3 * {Complex(1,2),Complex(3,4)};
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RealTypeOpArg2",
            description="Constant eval of overloaded operator expression: array real type inference",
            eliminate_alias_variables=false,
            flatModel="
fclass OperatorRecordTests.Eval.RealTypeOpArg2
 constant Real y1[1].re = 3.0 \"Real part of complex number\";
 constant Real y1[1].im = 6.0 \"Imaginary part of complex number\";
 constant Real y1[2].re = 4.0 \"Real part of complex number\";
 constant Real y1[2].im = 8.0 \"Imaginary part of complex number\";
 constant Real y2[1].re = 3.0 \"Real part of complex number\";
 constant Real y2[1].im = 6.0 \"Imaginary part of complex number\";
 constant Real y2[2].re = 9.0 \"Real part of complex number\";
 constant Real y2[2].im = 12.0 \"Imaginary part of complex number\";
end OperatorRecordTests.Eval.RealTypeOpArg2;
")})));
end RealTypeOpArg2;

model ArrayMul1
  constant Complex[2] y1 = {Complex(3,0),Complex(4,0)} * Complex(1,2);
//  constant Complex[2] y2 = {Complex(3,0),Complex(4,0)} .* {Complex(1,2),Complex(3,4)};
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ArrayMul1",
            description="Constant eval of overloaded operator expression: array multiplication",
            flatModel="
fclass OperatorRecordTests.Eval.ArrayMul1
 constant Real y1[1].re = 3.0 \"Real part of complex number\";
 constant Real y1[1].im = 6.0 \"Imaginary part of complex number\";
 constant Real y1[2].re = 4.0 \"Real part of complex number\";
 constant Real y1[2].im = 8.0 \"Imaginary part of complex number\";
end OperatorRecordTests.Eval.ArrayMul1;
")})));
end ArrayMul1;

end Eval;

end OperatorRecordTests;
