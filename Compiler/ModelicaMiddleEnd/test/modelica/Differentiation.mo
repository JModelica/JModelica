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


package Differentiation
    package Expressions
        model Cos
            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + cos(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Cos",
            description="Test differentiation of cos",
            flatModel="
fclass Differentiation.Expressions.Cos
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + cos(x2) = 0;
 _der_x1 + (- sin(x2) * der(x2)) = 0;
end Differentiation.Expressions.Cos;
")})));
        end Cos;

        model Sin
            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + sin(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Sin",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Sin
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sin(x2) = 0;
 _der_x1 + cos(x2) * der(x2) = 0;
end Differentiation.Expressions.Sin;
")})));
        end Sin;

        model Neg
            Real x1,x2(stateSelect=StateSelect.prefer);
        equation
            der(x1) + der(x2) = 1;
-           x1 + 2*x2 = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Neg",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Neg
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 - x1 + 2 * x2 = 0;
 - _der_x1 + 2 * der(x2) = 0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end Differentiation.Expressions.Neg;
")})));
        end Neg;

        model Exp
            Real x1,x2(stateSelect=StateSelect.prefer);
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + exp(x2*p*time) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Exp",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Exp
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + exp(x2 * p * time) = 0;
 _der_x1 + exp(x2 * p * time) * (x2 * p + der(x2) * p * time) = 0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end Differentiation.Expressions.Exp;
")})));
        end Exp;

        model Tan
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + tan(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Tan",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Tan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + tan(x2) = 0;
 _der_x1 + der(x2) / cos(x2) ^ 2 = 0;
end Differentiation.Expressions.Tan;
")})));
        end Tan;

        model Asin
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + asin(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Asin",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Asin
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + asin(x2) = 0;
 _der_x1 + der(x2) / sqrt(1 - x2 ^ 2) = 0;
end Differentiation.Expressions.Asin;
")})));
        end Asin;

        model Acos
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + acos(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Acos",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Acos
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + acos(x2) = 0;
 _der_x1 + (- der(x2)) / sqrt(1 - x2 ^ 2) = 0;
end Differentiation.Expressions.Acos;
")})));
        end Acos;

        model Atan
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + atan(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Atan",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Atan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + atan(x2) = 0;
 _der_x1 + der(x2) / (1 + x2 ^ 2) = 0;
end Differentiation.Expressions.Atan;
")})));
        end Atan;

        model Atan2
            Real x1,x2,x3;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            der(x3) = time;
            x1 + atan2(x2,x3) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Atan2",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Atan2
 Real x1;
 Real x2;
 Real x3;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
 x3 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 der(x3) = time;
 x1 + atan2(x2, x3) = 0;
 _der_x1 + (der(x2) * x3 - x2 * der(x3)) / (x2 * x2 + x3 * x3) = 0;
end Differentiation.Expressions.Atan2;
")})));
        end Atan2;

        model Sinh
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + sinh(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Sinh",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Sinh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sinh(x2) = 0;
 _der_x1 + cosh(x2) * der(x2) = 0;
end Differentiation.Expressions.Sinh;
")})));
        end Sinh;

        model Cosh
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + cosh(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Cosh",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Cosh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + cosh(x2) = 0;
 _der_x1 + sinh(x2) * der(x2) = 0;
end Differentiation.Expressions.Cosh;
")})));
        end Cosh;

        model Tanh
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + tanh(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Tanh",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Tanh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + tanh(x2) = 0;
 _der_x1 + der(x2) / cosh(x2) ^ 2 = 0;
end Differentiation.Expressions.Tanh;
")})));
        end Tanh;

        model Log
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + log(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Log",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Log
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + log(x2) = 0;
 _der_x1 + der(x2) / x2 = 0;
end Differentiation.Expressions.Log;
")})));
        end Log;

        model Log10
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + log10(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Log10",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Log10
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + log10(x2) = 0;
 _der_x1 + der(x2) / (x2 * log(10)) = 0;
end Differentiation.Expressions.Log10;
")})));
        end Log10;

        model Sqrt
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + sqrt(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Sqrt",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Sqrt
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + sqrt(x2) = 0;
 _der_x1 + der(x2) / (2 * sqrt(x2)) = 0;
end Differentiation.Expressions.Sqrt;
")})));
        end Sqrt;

        model If
            Real x1,x2(stateSelect=StateSelect.prefer);
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + (if p>3 then 3*x2 else if p<=3 then sin(x2) else 2*x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_If",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.If
 Real x1;
 Real x2(stateSelect = StateSelect.prefer);
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + (if p > 3 then 3 * x2 elseif p <= 3 then sin(x2) else 2 * x2) = 0;
 _der_x1 + (if p > 3 then 3 * der(x2) elseif p <= 3 then cos(x2) * der(x2) else 2 * der(x2)) = 0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end Differentiation.Expressions.If;
")})));
        end If;

        model Pow1
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            x1 + x2^p + x2^1.4 = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Pow1",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Pow1
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + x2 ^ p + x2 ^ 1.4 = 0;
 _der_x1 + p * x2 ^ (p - 1) * der(x2) + 1.4 * x2 ^ 0.3999999999999999 * der(x2) = 0;
end Differentiation.Expressions.Pow1;
")})));
        end Pow1;

        model Pow2
            Real x1,x2,x3;
        equation
            der(x1) + der(x2) = 1;
            x1 + x2 = 10^x3;
            10 ^ x3 - x2 = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Pow2",
            description="Differentiation of power with continuous expression as exponent",
            flatModel="
fclass Differentiation.Expressions.Pow2
 Real x1;
 Real x2;
 Real x3;
 Real _der_x1;
 Real _der_x2;
initial equation
 x3 = 0.0;
equation
 _der_x1 + _der_x2 = 1;
 x1 + x2 = 10 ^ x3;
 10 ^ x3 - x2 = 1;
 _der_x1 + _der_x2 = 10 ^ x3 * (der(x3) * log(10));
 10 ^ x3 * (der(x3) * log(10)) - _der_x2 = 0;
end Differentiation.Expressions.Pow2;
")})));
        end Pow2;

        model Pow3
            Real x1,x2,x3,x4;
        equation
            der(x1) + der(x2) = 1;
            x1 + x2 = x3^x4;
            x3^x4 - x2 = 1;
            x3 * x3 = x4;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Pow3",
            description="Differentiation of power with continuous expressions as both base and exponent",
            flatModel="
fclass Differentiation.Expressions.Pow3
 Real x1;
 Real x2;
 Real x3;
 Real x4;
 Real _der_x1;
 Real _der_x2;
 Real _der_x4;
initial equation
 x3 = 0.0;
equation
 _der_x1 + _der_x2 = 1;
 x1 + x2 = x3 ^ x4;
 x3 ^ x4 - x2 = 1;
 x3 * x3 = x4;
 _der_x1 + _der_x2 = x3 ^ x4 * (der(x3) * (x4 / x3) + _der_x4 * log(x3));
 x3 ^ x4 * (der(x3) * (x4 / x3) + _der_x4 * log(x3)) - _der_x2 = 0;
 x3 * der(x3) + der(x3) * x3 = _der_x4;
end Differentiation.Expressions.Pow3;
")})));
        end Pow3;

        model Div1
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            (x1 + x2)/(x1 + p) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Div1",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass Differentiation.Expressions.Div1
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 (x1 + x2) / (x1 + p) = 0;
 ((_der_x1 + der(x2)) * (x1 + p) - (x1 + x2) * _der_x1) / (x1 + p) ^ 2 = 0;
end Differentiation.Expressions.Div1;
")})));
        end Div1;

        model Div2
            Real x1,x2;
            parameter Real p1 = 2;
            parameter Real p2 = 5;
        equation
            der(x1) + der(x2) = 1;
            (x1 + x2)/(p1*p2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Div2",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.Div2
 Real x1;
 Real x2;
 parameter Real p1 = 2 /* 2 */;
 parameter Real p2 = 5 /* 5 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 (x1 + x2) / (p1 * p2) = 0;
 (_der_x1 + der(x2)) / (p1 * p2) = 0;
end Differentiation.Expressions.Div2;
")})));
        end Div2;

        model NoEvent
            Real x1,x2;
            parameter Real p = 2;
        equation
            der(x1) + der(x2) = 1;
            noEvent(x1 + sin(x2)) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_NoEvent",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.NoEvent
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 noEvent(x1 + sin(x2)) = 0;
 noEvent(_der_x1 + cos(x2) * der(x2)) = 0;
end Differentiation.Expressions.NoEvent;
")})));
        end NoEvent;

        model MinExp
            Real x1,x2,x3;
        equation
            der(x1) + der(x2) + der(x3) = 1;
            min({x1,x2}) = 0;
            min(x1,x3) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_MinExp",
            description="Test of index reduction. Min expression.",
            dynamic_states=false,
            flatModel="
fclass Differentiation.Expressions.MinExp
 Real x1;
 Real x2;
 Real x3;
 Real _der_x2;
 Real _der_x3;
initial equation
 x1 = 0.0;
equation
 der(x1) + _der_x2 + _der_x3 = 1;
 min(x1, x2) = 0;
 min(x1, x3) = 0;
 noEvent(if x1 < x2 then der(x1) else _der_x2) = 0;
 noEvent(if x1 < x3 then der(x1) else _der_x3) = 0;
end Differentiation.Expressions.MinExp;
")})));
        end MinExp;

        model MaxExp
            Real x1,x2,x3;
        equation
            der(x1) + der(x2) + der(x3) = 1;
            max({x1,x2}) = 0;
            max(x1,x3) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_MaxExp",
            description="Test of index reduction. Max expression.",
            dynamic_states=false,
            flatModel="
fclass Differentiation.Expressions.MaxExp
 Real x1;
 Real x2;
 Real x3;
 Real _der_x2;
 Real _der_x3;
initial equation
 x1 = 0.0;
equation
 der(x1) + _der_x2 + _der_x3 = 1;
 max(x1, x2) = 0;
 max(x1, x3) = 0;
 noEvent(if x1 > x2 then der(x1) else _der_x2) = 0;
 noEvent(if x1 > x3 then der(x1) else _der_x3) = 0;
end Differentiation.Expressions.MaxExp;
")})));
        end MaxExp;

        model Homotopy
            //TODO: this test should be updated when the homotopy operator is fully implemented.
            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            homotopy(x1,x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Homotopy",
            description="Test of index reduction. Homotopy expression.",
            flatModel="
fclass Differentiation.Expressions.Homotopy
 constant Real x1 = 0;
 Real x2;
initial equation
 x2 = 0.0;
equation
 der(x2) = 1;
end Differentiation.Expressions.Homotopy;
")})));
        end Homotopy;

        model DotAdd
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .+ x2 = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_DotAdd",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.DotAdd
 Real x1[1];
 Real x1[2];
initial equation
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ (- der(x1[1])) = 1;
 der(x1[2]) .+ (- der(x1[2])) = 1;
end Differentiation.Expressions.DotAdd;
")})));
        end DotAdd;

        model DotSub
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .- x2 = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_DotSub",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.Expressions.DotSub
 Real x1[1];
 Real x1[2];
initial equation
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ der(x1[1]) = 1;
 der(x1[2]) .+ der(x1[2]) = 1;
end Differentiation.Expressions.DotSub;
")})));
        end DotSub;

        model DotMul
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .* x2 = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_DotMul",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass Differentiation.Expressions.DotMul
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
 Real _der_x1[2];
initial equation
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] .* x2[1] = 0;
 x1[2] .* x2[2] = 0;
 x1[1] .* der(x2[1]) .+ _der_x1[1] .* x2[1] = 0;
 x1[2] .* der(x2[2]) .+ _der_x1[2] .* x2[2] = 0;
end Differentiation.Expressions.DotMul;
")})));
        end DotMul;

        model DotDiv
            Real x1[2],x2[2];
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 ./ x2 = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_DotDiv",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass Differentiation.Expressions.DotDiv
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
 Real _der_x1[2];
initial equation
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] .+ der(x2[1]) = 1;
 _der_x1[2] .+ der(x2[2]) = 1;
 x1[1] ./ x2[1] = 0;
 x1[2] ./ x2[2] = 0;
 (_der_x1[1] .* x2[1] .- x1[1] .* der(x2[1])) ./ x2[1] .^ 2 = 0;
 (_der_x1[2] .* x2[2] .- x1[2] .* der(x2[2])) ./ x2[2] .^ 2 = 0;
end Differentiation.Expressions.DotDiv;
")})));
        end DotDiv;

        model DotPow
            Real x1[2],x2[2];
            parameter Real p2[2] = {2,3};
        equation
            der(x1) .+ der(x2) = {1,1};
            x1 .^ p2 - x2 = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_DotPow",
            description="Cifferentiation of .^ operator",
            flatModel="
fclass Differentiation.Expressions.DotPow
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 parameter Real p2[1] = 2 /* 2 */;
 parameter Real p2[2] = 3 /* 3 */;
 Real _der_x2[1];
 Real _der_x2[2];
initial equation
 x1[1] = 0.0;
 x1[2] = 0.0;
equation
 der(x1[1]) .+ _der_x2[1] = 1;
 der(x1[2]) .+ _der_x2[2] = 1;
 x1[1] .^ p2[1] - x2[1] = 0;
 x1[2] .^ p2[2] - x2[2] = 0;
 p2[1] .* x1[1] .^ (p2[1] .- 1) .* der(x1[1]) - _der_x2[1] = 0;
 p2[2] .* x1[2] .^ (p2[2] .- 1) .* der(x1[2]) - _der_x2[2] = 0;
end Differentiation.Expressions.DotPow;
")})));
        end DotPow;

        model DivFunc
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + div(x2, 3.14) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_DivFunc",
            description="Test differentiation of div() operator. This model probably makes no sence in the real world!",
            flatModel="
fclass Differentiation.Expressions.DivFunc
 Real x1;
 Real x2;
 discrete Real temp_1;
 Real _der_x1;
initial equation
 pre(temp_1) = 0.0;
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + temp_1 = 1;
 temp_1 = if div(x2, 3.14) < pre(temp_1) or div(x2, 3.14) >= pre(temp_1) + 1 or initial() then div(x2, 3.14) else pre(temp_1);
 _der_x1 = 0;
end Differentiation.Expressions.DivFunc;
")})));
        end DivFunc;

        model FunctionCall1
            function f
                input Real x;
                output Real y;
                input Integer n;
            algorithm
                y := x*n;
            annotation(smoothOrder=2, Inline=false);
            end f;
            Real x,y;
        equation
            x = f(time, 2);
            y = der(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_FunctionCall1",
            description="Test differentiation of function calls where the function have mixed order among inputs and outputs (also mixed type).",
            flatModel="
fclass Differentiation.Expressions.FunctionCall1
 Real x;
 Real y;
equation
 x = Differentiation.Expressions.FunctionCall1.f(time, 2);
 y = Differentiation.Expressions.FunctionCall1._der_f(time, 2, 1.0);

public
 function Differentiation.Expressions.FunctionCall1.f
  input Real x;
  output Real y;
  input Integer n;
 algorithm
  y := x * n;
  return;
 annotation(Inline = false,smoothOrder = 2,derivative(order = 1) = Differentiation.Expressions.FunctionCall1._der_f);
 end Differentiation.Expressions.FunctionCall1.f;

 function Differentiation.Expressions.FunctionCall1._der_f
  input Real x;
  input Integer n;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := _der_x * n;
  y := x * n;
  return;
 annotation(smoothOrder = 1);
 end Differentiation.Expressions.FunctionCall1._der_f;

end Differentiation.Expressions.FunctionCall1;
")})));
        end FunctionCall1;
        
        model Transpose
            Real x[2,3] = { { 1,2,3 }, { 4,5,6 } } * time;
            Real y[3,2] = der(transpose(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Transpose",
            description="Derivative of transpose()",
            flatModel="
fclass Differentiation.Expressions.Transpose
 Real x[2,3] = {{1, 2, 3}, {4, 5, 6}} * time;
 Real y[3,2] = transpose(der(x[1:2,1:3]));
end Differentiation.Expressions.Transpose;
")})));
        end Transpose;
        
        model OuterProduct
            Real x[2] = { 1,2 } * time;
            Real y[2] = { 3,4 } * time;
            Real z[2,2] = der(outerProduct(x, y));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_OuterProduct",
            description="Derivative of outerProduct()",
            flatModel="
fclass Differentiation.Expressions.OuterProduct
 Real x[2] = {1, 2} * time;
 Real y[2] = {3, 4} * time;
 Real z[2,2] = outerProduct(der(x[1:2]), der(y[1:2]));
end Differentiation.Expressions.OuterProduct;
")})));
        end OuterProduct;
        
        model Symmetric
            Real x[2,2] = { { 1,2 }, { 3,4 } } * time;
            Real y[2,2] = der(symmetric(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Symmetric",
            description="Derivative of symmetric()",
            flatModel="
fclass Differentiation.Expressions.Symmetric
 Real x[2,2] = {{1, 2}, {3, 4}} * time;
 Real y[2,2] = {{der(x[1,1]), der(x[1,2])}, {der(x[1,2]), der(x[2,2])}};
end Differentiation.Expressions.Symmetric;
")})));
        end Symmetric;
        
        model Cross
            Real x[3] = { 1,2,3 } * time;
            Real y[3] = { 4,5,6 } * time;
            Real z[3] = der(cross(x, y));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Cross",
            description="Derivative of cross()",
            flatModel="
fclass Differentiation.Expressions.Cross
 Real x[3] = {1, 2, 3} * time;
 Real y[3] = {4, 5, 6} * time;
 Real z[3] = cross(der(x[1:3]), der(y[1:3]));
end Differentiation.Expressions.Cross;
")})));
        end Cross;
        
        model Skew
            Real x[3] = { 1,2,3 } * time;
            Real y[3,3] = der(skew(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Skew",
            description="Derivative of skew()",
            flatModel="
fclass Differentiation.Expressions.Skew
 Real x[3] = {1, 2, 3} * time;
 Real y[3,3] = skew(der(x[1:3]));
end Differentiation.Expressions.Skew;
")})));
        end Skew;
        
        model Div
            Real x = time;
            Real y = 2 * time;
            Real z = der(div(x, y));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Div",
            description="Derivative of div()",
            flatModel="
fclass Differentiation.Expressions.Div
 Real x = time;
 Real y = 2 * time;
 Real z = 0.0;
end Differentiation.Expressions.Div;
")})));
        end Div;
        
        model Mod
            Real x = time;
            Real y = 2 * time;
            Real z = der(mod(x, y));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Mod",
            description="Derivative of mod()",
            flatModel="
fclass Differentiation.Expressions.Mod
 Real x = time;
 Real y = 2 * time;
 Real z = der(x) .- floor(x ./ y) .* der(y);
end Differentiation.Expressions.Mod;
")})));
        end Mod;
        
        model Rem
            Real x = time;
            Real y = 2 * time;
            Real z = der(rem(x, y));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Rem",
            description="Derivative of rem()",
            flatModel="
fclass Differentiation.Expressions.Rem
 Real x = time;
 Real y = 2 * time;
 Real z = der(x) .- div(x, y) .* der(y);
end Differentiation.Expressions.Rem;
")})));
        end Rem;
        
        model Ceil
            Real x;
            Real y;
        equation
            der(x) + der(y) = 1;
            x + ceil(y) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Ceil",
            description="Derivative of ceil()",
            flatModel="
fclass Differentiation.Expressions.Ceil
 Real x;
 Real y;
 discrete Real temp_1;
 Real _der_x;
initial equation
 pre(temp_1) = 0.0;
 y = 0.0;
equation
 _der_x + der(y) = 1;
 x + temp_1 = 1;
 temp_1 = if y <= pre(temp_1) - 1 or y > pre(temp_1) or initial() then ceil(y) else pre(temp_1);
 _der_x = 0;
end Differentiation.Expressions.Ceil;
")})));
        end Ceil;
        
        model Floor
            Real x;
            Real y;
        equation
            der(x) + der(y) = 1;
            x + floor(y) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_Floor",
            description="Derivative of floor()",
            flatModel="
fclass Differentiation.Expressions.Floor
 Real x;
 Real y;
 discrete Real temp_1;
 Real _der_x;
initial equation
 pre(temp_1) = 0.0;
 y = 0.0;
equation
 _der_x + der(y) = 1;
 x + temp_1 = 1;
 temp_1 = if y < pre(temp_1) or y >= pre(temp_1) + 1 or initial() then floor(y) else pre(temp_1);
 _der_x = 0;
end Differentiation.Expressions.Floor;
")})));
        end Floor;
        
        model Cat
            Real x[2] = { 1,2 } * time;
            Real y[2] = { 3,4 } * time;
            Real z[4] = der(cat(1, x, y));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Cat",
            description="Derivative of cat()",
            flatModel="
fclass Differentiation.Expressions.Cat
 Real x[2] = {1, 2} * time;
 Real y[2] = {3, 4} * time;
 Real z[4] = cat(1, der(x[1:2]), der(y[1:2]));
end Differentiation.Expressions.Cat;
")})));
        end Cat;
        
        model ShortMatrix
            Real x[2] = { 1,2 } * time;
            Real y[2] = { 3,4 } * time;
            Real z[2,2] = der([x[1], x[2]; y[1], y[2]]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_ShortMatrix",
            description="Derivative of short-hand matrix constructor",
            flatModel="
fclass Differentiation.Expressions.ShortMatrix
 Real x[2] = {1, 2} * time;
 Real y[2] = {3, 4} * time;
 Real z[2,2] = [der(x[1]), der(x[2]); der(y[1]), der(y[2])];
end Differentiation.Expressions.ShortMatrix;
")})));
        end ShortMatrix;
        
        model Fill
            Real x = time;
            Real z[3] = der(fill(sin(x), 3));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Fill",
            description="Derivative of fill()",
            flatModel="
fclass Differentiation.Expressions.Fill
 Real x = time;
 Real z[3] = fill(cos(x) * der(x), 3);
end Differentiation.Expressions.Fill;
")})));
        end Fill;
        
        model Linspace
            Real x = time;
            Real y = 2 * time;
            Real z[3] = der(linspace(x, y, 3));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Linspace",
            description="Derivative of linspace()",
            flatModel="
fclass Differentiation.Expressions.Linspace
 Real x = time;
 Real y = 2 * time;
 Real z[3] = linspace(der(x), der(y), 3);
end Differentiation.Expressions.Linspace;
")})));
        end Linspace;
        
        model SemiLinear
            Real x = 1 - time;
            Real y = 2 * time;
            Real z = - y + 1;
            Real w = der(semiLinear(x, y, z));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_SemiLinear",
            description="Derivative of semiLinear()",
            flatModel="
fclass Differentiation.Expressions.SemiLinear
 Real x = 1 - time;
 Real y = 2 * time;
 Real z = - y + 1;
 Real w = if x >= 0.0 then der(y) .* x .+ y .* der(x) else der(z) .* x .+ z .* der(x);
end Differentiation.Expressions.SemiLinear;
")})));
        end SemiLinear;
        
        model Diagonal
            Real x[2] = { 1,2 } * time;
            Real y[2,2] = der(diagonal(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Diagonal",
            description="Derivative of diagonal()",
            flatModel="
fclass Differentiation.Expressions.Diagonal
 Real x[2] = {1, 2} * time;
 Real y[2,2] = diagonal(der(x[1:2]));
end Differentiation.Expressions.Diagonal;
")})));
        end Diagonal;
        
        model Scalar
            Real x[1,1,1] = {{{ time }}};
            Real y = der(scalar(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Scalar",
            description="Derivative of scalar()",
            flatModel="
fclass Differentiation.Expressions.Scalar
 Real x[1,1,1] = {{{time}}};
 Real y = scalar(der(x[1:1,1:1,1:1]));
end Differentiation.Expressions.Scalar;
")})));
        end Scalar;
        
        model Vector
            Real x[1,1,1] = {{{ time }}};
            Real y[1] = der(vector(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Vector",
            description="Derivative of vector()",
            flatModel="
fclass Differentiation.Expressions.Vector
 Real x[1,1,1] = {{{time}}};
 Real y[1] = vector(der(x[1:1,1:1,1:1]));
end Differentiation.Expressions.Vector;
")})));
        end Vector;
        
        model Matrix
            Real x[1,1,1] = {{{ time }}};
            Real y[1,1] = der(matrix(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Matrix",
            description="Derivative of matrix()",
            flatModel="
fclass Differentiation.Expressions.Matrix
 Real x[1,1,1] = {{{time}}};
 Real y[1,1] = matrix(der(x[1:1,1:1,1:1]));
end Differentiation.Expressions.Matrix;
")})));
        end Matrix;
        
        model Product
            Real x[3] = { 1,2,3 } * time;
            Real y = der(product(x));

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Product",
            description="Derivative of product()",
            flatModel="
fclass Differentiation.Expressions.Product
 Real x[3] = {1, 2, 3} * time;
 Real y = der(x[1]) .* x[2] .* x[3] .+ x[1] .* der(x[2]) .* x[3] .+ x[1] .* x[2] .* der(x[3]);
end Differentiation.Expressions.Product;
")})));
        end Product;
        
        model Sum
            Real x[3] = { 1,2,3 } * time;
            Real y = der(sum(x));
        end Sum;
        
        model ActualStream
            connector C
                Real p;
                flow Real f;
                stream Real s;
            end C;
            
            model A
                C c;
                Real x = actualStream(c.s);
                Real dx = der(actualStream(c.s));
            equation
                der(c.s) = time / 2;
            end A;
            
            A a1(c(f = time - 1, p = time, s(start = -1)));
            A a2(c(s(start = 1)));
        equation
            connect(a1.c, a2.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Expressions_ActualStream",
            description="Derivative of actualStream()",
            flatModel="
fclass Differentiation.Expressions.ActualStream
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s(start = -1);
 Real a1.x;
 Real a1.dx;
 Real a2.c.s(start = 1);
 Real a2.x;
 Real a2.dx;
initial equation
 a1.c.s = -1;
 a2.c.s = 1;
equation
 der(a1.c.s) = time / 2;
 der(a2.c.s) = time / 2;
 a1.c.p = time;
 a1.c.f = time - 1;
 a1.x = if a1.c.f > 0.0 then a2.c.s else a1.c.s;
 a1.dx = if a1.c.f > 0.0 then der(a2.c.s) else der(a1.c.s);
 a2.x = if - a1.c.f > 0.0 then a1.c.s else a2.c.s;
 a2.dx = if - a1.c.f > 0.0 then der(a1.c.s) else der(a2.c.s);
end Differentiation.Expressions.ActualStream;
")})));
        end ActualStream;
        
        model Iter
            Real x[3] = { 1,2,3 } * time;
            Real y[3] = der({ x[i] for i in 3:-1:1 });

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Iter",
            description="Derivative of iteration expression",
            flatModel="
fclass Differentiation.Expressions.Iter
 Real x[3] = {1, 2, 3} * time;
 Real y[3] = {der(x[3]), der(x[2]), der(x[1])};
end Differentiation.Expressions.Iter;
")})));
        end Iter;
        
        model Range
            Real x[3] = der(1.0:3.0);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Range",
            description="Derivative of range expression",
            flatModel="
fclass Differentiation.Expressions.Range
 Real x[3] = zeros(3);
end Differentiation.Expressions.Range;
")})));
        end Range;
        
        model Literal
            Real x = der(1.0);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expressions_Literal",
            description="Derivative of literal",
            flatModel="
fclass Differentiation.Expressions.Literal
 Real x = 0.0;
end Differentiation.Expressions.Literal;
")})));
        end Literal;

        model ConstantFunctionCallScalar
            function f
                input Real x;
                output Real y = x;
                algorithm
                annotation(Inline=false);
            end f;
            
            Real y = f(1);
            Real x;
        equation
            der(y) = x;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_ConstantFunctionCallScalar",
                description="",
                variability_propagation=false,
                flatModel="
fclass Differentiation.Expressions.ConstantFunctionCallScalar
 Real y;
 Real x;
equation
 y = Differentiation.Expressions.ConstantFunctionCallScalar.f(1);
 x = 0.0;

public
 function Differentiation.Expressions.ConstantFunctionCallScalar.f
  input Real x;
  output Real y;
 algorithm
  y := x;
  return;
 annotation(Inline = false);
 end Differentiation.Expressions.ConstantFunctionCallScalar.f;

end Differentiation.Expressions.ConstantFunctionCallScalar;
")})));
        end ConstantFunctionCallScalar;

        model ConstantFunctionCallRecord
            record R
                Real x;
            end R;
            function f
                input R x;
                output R y = x;
                algorithm
                annotation(Inline=false);
            end f;
            
            R y = f(R(1));
            R x;
        equation
            der(y.x) = x.x;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_ConstantFunctionCallRecord",
                description="",
                variability_propagation=false,
                flatModel="
fclass Differentiation.Expressions.ConstantFunctionCallRecord
 Real y.x;
 Real x.x;
equation
 (Differentiation.Expressions.ConstantFunctionCallRecord.R(y.x)) = Differentiation.Expressions.ConstantFunctionCallRecord.f(Differentiation.Expressions.ConstantFunctionCallRecord.R(1));
 (Differentiation.Expressions.ConstantFunctionCallRecord.R(x.x)) = Differentiation.Expressions.ConstantFunctionCallRecord.R(0.0);

public
 function Differentiation.Expressions.ConstantFunctionCallRecord.f
  input Differentiation.Expressions.ConstantFunctionCallRecord.R x;
  output Differentiation.Expressions.ConstantFunctionCallRecord.R y;
 algorithm
  y.x := x.x;
  return;
 annotation(Inline = false);
 end Differentiation.Expressions.ConstantFunctionCallRecord.f;

 record Differentiation.Expressions.ConstantFunctionCallRecord.R
  Real x;
 end Differentiation.Expressions.ConstantFunctionCallRecord.R;

end Differentiation.Expressions.ConstantFunctionCallRecord;
")})));
        end ConstantFunctionCallRecord;

        model ConstantFunctionCallArray
            function f
                input Real[2] x;
                output Real[2] y = x;
                algorithm
                annotation(Inline=false);
            end f;
            
            Real[2] y = f({1,1});
            Real[2] x;
        equation
            der(y) = x;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_ConstantFunctionCallArray",
                description="",
                variability_propagation=false,
                flatModel="
fclass Differentiation.Expressions.ConstantFunctionCallArray
 Real y[1];
 Real y[2];
 Real x[1];
 Real x[2];
equation
 ({y[1], y[2]}) = Differentiation.Expressions.ConstantFunctionCallArray.f({1, 1});
 ({x[1], x[2]}) = zeros(2);

public
 function Differentiation.Expressions.ConstantFunctionCallArray.f
  input Real[:] x;
  output Real[:] y;
 algorithm
  init y as Real[2];
  for i1 in 1:2 loop
   y[i1] := x[i1];
  end for;
  return;
 annotation(Inline = false);
 end Differentiation.Expressions.ConstantFunctionCallArray.f;

end Differentiation.Expressions.ConstantFunctionCallArray;
")})));
        end ConstantFunctionCallArray;

        model DerivativeScalar
            Real y = 1 / 2;
            Real x;
        equation
            der(y) = x;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="Expressions_DerivativeScalar",
                description="",
                variability_propagation=false,
                flatModel="
fclass Differentiation.Expressions.DerivativeScalar
 Real y;
 Real x;
equation
 y = 1 / 2;
 x = 0;
end Differentiation.Expressions.DerivativeScalar;
")})));
        end DerivativeScalar;

    end Expressions;

    model ComponentArray
        model M
            parameter Real L = 1 "Pendulum length";
            parameter Real g =9.81 "Acceleration due to gravity";
            Real x "Cartesian x coordinate";
            Real y "Cartesian x coordinate";
            Real vx "Velocity in x coordinate";
            Real vy "Velocity in y coordinate";
            Real lambda "Lagrange multiplier";
        equation
            der(x) = vx;
            der(y) = vy;
            der(vx) = lambda*x;
            der(vy) = lambda*y - g;
            x^2 + y^2 = L;
        end M;

        M m[1];

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ComponentArray",
            description="Name for der variables from FQNameString",
            dynamic_states=false,
            flatModel="
fclass Differentiation.ComponentArray
 parameter Real m[1].L = 1 \"Pendulum length\" /* 1 */;
 parameter Real m[1].g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real m[1].x \"Cartesian x coordinate\";
 Real m[1].y \"Cartesian x coordinate\";
 Real m[1].vx \"Velocity in x coordinate\";
 Real m[1].vy \"Velocity in y coordinate\";
 Real m[1].lambda \"Lagrange multiplier\";
 Real m[1]._der_x;
 Real m[1]._der_vx;
 Real m[1]._der_der_y;
initial equation
 m[1].y = 0.0;
 m[1].vy = 0.0;
equation
 m[1]._der_x = m[1].vx;
 der(m[1].y) = m[1].vy;
 m[1]._der_vx = m[1].lambda * m[1].x;
 der(m[1].vy) = m[1].lambda * m[1].y - m[1].g;
 m[1].x ^ 2 + m[1].y ^ 2 = m[1].L;
 2 * m[1].x * m[1]._der_x + 2 * m[1].y * der(m[1].y) = 0.0;
 m[1]._der_der_y = der(m[1].vy);
 2 * m[1].x * m[1]._der_vx + 2 * m[1]._der_x * m[1]._der_x + (2 * m[1].y * m[1]._der_der_y + 2 * der(m[1].y) * der(m[1].y)) = 0.0;
end Differentiation.ComponentArray;
")})));
    end ComponentArray;

    model BooleanVariable
        Real x,y;
        Boolean b = false;
    equation
        x = if b then 1 else 2 + y;
        der(x) + der(y) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="BooleanVariable",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.BooleanVariable
 Real x;
 Real y;
 constant Boolean b = false;
 Real _der_x;
initial equation
 y = 0.0;
equation
 x = 2 + y;
 _der_x + der(y) = 0;
 _der_x = der(y);
end Differentiation.BooleanVariable;
")})));
    end BooleanVariable;

    model IntegerVariable
        Real x,y;
        Integer b = 2;
    equation
        x = if b==2 then 1 else 2 + y;
        der(x) + der(y) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IntegerVariable",
            description="Test of index reduction",
            flatModel="
fclass Differentiation.IntegerVariable
 Real x;
 Real y;
 constant Integer b = 2;
 Real _der_x;
initial equation
 y = 0.0;
equation
 x = 1;
 _der_x + der(y) = 0;
 _der_x = 0;
end Differentiation.IntegerVariable;
")})));
end IntegerVariable;

package DiscreteTime
    model DifferentiatedDiscreteVariable
        Real x1,x2;
    equation
        der(x1) + der(x2) = 1;
        when time > 2 then
            x1 = sin(x2) + time;
        end when;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="DiscreteTime_DifferentiatedDiscreteVariable",
            description="Test error given when differentiating a discrete real",
            errorMessage="
1 errors found:

Error at line 2, column 9, in file 'Compiler/ModelicaMiddleEnd/test/modelica/Differentiation.mo', DIFFERENTIATED_DISCRETE_VARIABLE:
  Unable to differentiate the variable x1 which is declared or infered to be discrete
")})));
    end DifferentiatedDiscreteVariable;
    
    model AutoDiffOfDiscrete1
        Real L(start=3.14) "Pendulum length";
        parameter Real g =9.81 "Acceleration due to gravity";
        Real x "Cartesian x coordinate";
        Real y "Cartesian x coordinate";
        Real vx "Velocity in x coordinate";
        Real vy "Velocity in y coordinate";
        Real lambda "Lagrange multiplier";
    equation
        when time > 5 then
            L = 6.28;
        end when;
        der(x) = vx;
        der(y) = vy;
        der(vx) = lambda*x;
        der(vy) + 0 = lambda*y - g;
        x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DiscreteTime_AutoDiffOfDiscrete1",
            description="Ensure that we allow the index reduction to differentiate discete variable references",
            flatModel="
fclass Differentiation.DiscreteTime.AutoDiffOfDiscrete1
 discrete Real L(start = 3.14) \"Pendulum length\";
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 discrete Boolean temp_1;
 Real _der_vx;
 Real _der_vy;
 Real _der_x;
 Real _der_y;
 Real _ds.1.a1;
 Real _ds.1.s1;
 Real _ds.2.a1;
 Real _ds.2.s1;
 Real dynDer(x);
 Real dynDer(y);
 Real dynDer(_der_x);
 Real dynDer(_der_y);
initial equation
 _ds.1.s1 = 0.0;
 _ds.2.s1 = 0.0;
 y = 0.0;
 _der_y = 0.0;
 pre(L) = 3.14;
 pre(temp_1) = false;
equation
 temp_1 = time > 5;
 L = if temp_1 and not pre(temp_1) then 6.28 else pre(L);
 dynDer(x) = vx;
 dynDer(y) = vy;
 _der_vx = lambda * ds(2, x);
 _der_vy = lambda * ds(2, y) - g;
 ds(2, x) ^ 2 + ds(2, y) ^ 2 = L;
 2 * ds(2, x) * dynDer(x) + 2 * ds(2, y) * dynDer(y) = 0.0;
 dynDer(_der_x) = _der_vx;
 dynDer(_der_y) = _der_vy;
 2 * ds(2, x) * dynDer(_der_x) + 2 * dynDer(x) * dynDer(x) + (2 * ds(2, y) * dynDer(_der_y) + 2 * dynDer(y) * dynDer(y)) = 0.0;
 ds(1, _der_x) = dynDer(x);
 ds(1, _der_y) = dynDer(y);
 der(_ds.1.s1) = dsDer(1, 1);
 der(_ds.2.s1) = dsDer(2, 1);
end Differentiation.DiscreteTime.AutoDiffOfDiscrete1;
")})));
    end AutoDiffOfDiscrete1;
    
    model AutoDiffOfDiscrete2
        Real L(start=3.14) "Pendulum length";
        parameter Real g =9.81 "Acceleration due to gravity";
        Real x "Cartesian x coordinate";
        Real y "Cartesian x coordinate";
        Real vx "Velocity in x coordinate";
        Real vy "Velocity in y coordinate";
        Real lambda "Lagrange multiplier";
    equation
        when time > 5 then
            L = 6.28;
        end when;
        der(x) = vx;
        der(y) = vy;
        der(vx) = lambda*x;
        der(vy) + 0 = lambda*y - g;
        x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DiscreteTime_AutoDiffOfDiscrete2",
            description="Ensure that we allow the index reduction to differentiate discete variable references",
            flatModel="
fclass Differentiation.DiscreteTime.AutoDiffOfDiscrete2
 discrete Real L(start = 3.14) \"Pendulum length\";
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 discrete Boolean temp_1;
 Real _der_vx;
 Real _der_vy;
 Real _der_x;
 Real _der_y;
 Real _ds.1.a1;
 Real _ds.1.s1;
 Real _ds.2.a1;
 Real _ds.2.s1;
 Real dynDer(x);
 Real dynDer(y);
 Real dynDer(_der_x);
 Real dynDer(_der_y);
initial equation
 _ds.1.s1 = 0.0;
 _ds.2.s1 = 0.0;
 y = 0.0;
 _der_y = 0.0;
 pre(L) = 3.14;
 pre(temp_1) = false;
equation
 temp_1 = time > 5;
 L = if temp_1 and not pre(temp_1) then 6.28 else pre(L);
 dynDer(x) = vx;
 dynDer(y) = vy;
 _der_vx = lambda * ds(2, x);
 _der_vy = lambda * ds(2, y) - g;
 ds(2, x) ^ 2 + ds(2, y) ^ 2 = L;
 2 * ds(2, x) * dynDer(x) + 2 * ds(2, y) * dynDer(y) = 0.0;
 dynDer(_der_x) = _der_vx;
 dynDer(_der_y) = _der_vy;
 2 * ds(2, x) * dynDer(_der_x) + 2 * dynDer(x) * dynDer(x) + (2 * ds(2, y) * dynDer(_der_y) + 2 * dynDer(y) * dynDer(y)) = 0.0;
 ds(1, _der_x) = dynDer(x);
 ds(1, _der_y) = dynDer(y);
 der(_ds.1.s1) = dsDer(1, 1);
 der(_ds.2.s1) = dsDer(2, 1);
end Differentiation.DiscreteTime.AutoDiffOfDiscrete2;
")})));
    end AutoDiffOfDiscrete2;
    
    
end DiscreteTime;

model ErrorMessage1
  Real x1;
  Real x2;
algorithm
  x1 := x2;
equation
  der(x1) + der(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ErrorMessage1",
            description="Test error messages for algorithms.",
            inline_functions="none",
            errorMessage="
1 errors found:

Error in flattened model:
  Cannot differentate the equation:
   algorithm
 x1 := x2;

")})));
    end ErrorMessage1;
    
    package DerivativeAnnotation
        model Test1
            function f
                input Real x;
                output Real y;
            algorithm
                y := x^2;
            annotation(derivative=f_der);
            end f;

            function f_der
                input Real x;
                input Real der_x;
                output Real der_y;
            algorithm
                der_y := 2*x*der_x;
            end f_der;

            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + f(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DerivativeAnnotation_Test1",
            description="Test of index reduction",
            inline_functions="none",
            flatModel="
fclass Differentiation.DerivativeAnnotation.Test1
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.DerivativeAnnotation.Test1.f(x2) = 0;
 _der_x1 + Differentiation.DerivativeAnnotation.Test1.f_der(x2, der(x2)) = 0;

public
 function Differentiation.DerivativeAnnotation.Test1.f
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Test1.f_der);
 end Differentiation.DerivativeAnnotation.Test1.f;

 function Differentiation.DerivativeAnnotation.Test1.f_der
  input Real x;
  input Real der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x * der_x;
  return;
 end Differentiation.DerivativeAnnotation.Test1.f_der;

end Differentiation.DerivativeAnnotation.Test1;
")})));
        end Test1;

        model Test2
            function f
                input Real x[2];
                input Real A[2,2];
                output Real y;
            algorithm
                y := x*A*x;
            annotation(derivative=f_der);
            end f;

            function f_der
                input Real x[2];
                input Real A[2,2];
                input Real der_x[2];
                input Real der_A[2,2];
                output Real der_y;
            algorithm
                der_y := 2*x*A*der_x + x*der_A*x;
            end f_der;

            parameter Real A[2,2] = {{1,2},{3,4}};
            Real x1[2],x2[2];
        equation
            der(x1) + der(x2) = {1,2};
            x1[1] + f(x2,A) = 0;
            x1[2] = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DerivativeAnnotation_Test2",
            description="Test of index reduction",
            inline_functions="none",
            flatModel="
fclass Differentiation.DerivativeAnnotation.Test2
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1];
 constant Real x1[2] = 0;
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
initial equation
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + Differentiation.DerivativeAnnotation.Test2.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}) = 0;
 _der_x1[1] + Differentiation.DerivativeAnnotation.Test2.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}}) = 0;

public
 function Differentiation.DerivativeAnnotation.Test2.f
  input Real[:] x;
  input Real[:,:] A;
  output Real y;
  Real temp_1;
  Real temp_2;
  Real[:] temp_3;
  Real temp_4;
 algorithm
  init temp_3 as Real[2];
  for i2 in 1:2 loop
   temp_4 := 0.0;
   for i3 in 1:2 loop
    temp_4 := temp_4 + x[i3] * A[i3,i2];
   end for;
   temp_3[i2] := temp_4;
  end for;
  temp_2 := 0.0;
  for i1 in 1:2 loop
   temp_2 := temp_2 + temp_3[i1] * x[i1];
  end for;
  temp_1 := temp_2;
  y := temp_1;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Test2.f_der);
 end Differentiation.DerivativeAnnotation.Test2.f;

 function Differentiation.DerivativeAnnotation.Test2.f_der
  input Real[:] x;
  input Real[:,:] A;
  input Real[:] der_x;
  input Real[:,:] der_A;
  output Real der_y;
  Real temp_1;
  Real temp_2;
  Real[:] temp_3;
  Real temp_4;
  Real temp_5;
  Real temp_6;
  Real[:] temp_7;
  Real temp_8;
 algorithm
  init temp_3 as Real[2];
  for i2 in 1:2 loop
   temp_4 := 0.0;
   for i3 in 1:2 loop
    temp_4 := temp_4 + 2 * x[i3] * A[i3,i2];
   end for;
   temp_3[i2] := temp_4;
  end for;
  temp_2 := 0.0;
  for i1 in 1:2 loop
   temp_2 := temp_2 + temp_3[i1] * der_x[i1];
  end for;
  temp_1 := temp_2;
  init temp_7 as Real[2];
  for i2 in 1:2 loop
   temp_8 := 0.0;
   for i3 in 1:2 loop
    temp_8 := temp_8 + x[i3] * der_A[i3,i2];
   end for;
   temp_7[i2] := temp_8;
  end for;
  temp_6 := 0.0;
  for i1 in 1:2 loop
   temp_6 := temp_6 + temp_7[i1] * x[i1];
  end for;
  temp_5 := temp_6;
  der_y := temp_1 + temp_5;
  return;
 end Differentiation.DerivativeAnnotation.Test2.f_der;

end Differentiation.DerivativeAnnotation.Test2;
")})));
        end Test2;

        model Test3
            function f
                input Real x[2];
                output Real y;
            algorithm
                y := x[1]^2 + x[2]^3;
            annotation(derivative=f_der);
            end f;

            function f_der
                input Real x[2];
                input Real der_x[2];
                output Real der_y;
            algorithm
                der_y := 2*x[1]*der_x[1] + 3*x[2]^2*der_x[2];
            end f_der;

            Real x1[2],x2[2];
        equation
            der(x1) + der(x2) = {1,2};
            x1[1] + f(x2) = 0;
            x1[2] = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DerivativeAnnotation_Test3",
            description="Test of index reduction",
            inline_functions="none",
            flatModel="
fclass Differentiation.DerivativeAnnotation.Test3
 Real x1[1];
 constant Real x1[2] = 0;
 Real x2[1];
 Real x2[2];
 Real _der_x1[1];
initial equation
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 1;
 der(x2[2]) = 2;
 x1[1] + Differentiation.DerivativeAnnotation.Test3.f({x2[1], x2[2]}) = 0;
 _der_x1[1] + Differentiation.DerivativeAnnotation.Test3.f_der({x2[1], x2[2]}, {der(x2[1]), der(x2[2])}) = 0;

public
 function Differentiation.DerivativeAnnotation.Test3.f
  input Real[:] x;
  output Real y;
 algorithm
  y := x[1] ^ 2 + x[2] ^ 3;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Test3.f_der);
 end Differentiation.DerivativeAnnotation.Test3.f;

 function Differentiation.DerivativeAnnotation.Test3.f_der
  input Real[:] x;
  input Real[:] der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x[1] * der_x[1] + 3 * x[2] ^ 2 * der_x[2];
  return;
 end Differentiation.DerivativeAnnotation.Test3.f_der;

end Differentiation.DerivativeAnnotation.Test3;
")})));
        end Test3;

        model NoDerivative1
            function der_F
                import SI = Modelica.SIunits;
                input SI.Pressure p;
                input SI.SpecificEnthalpy h;
                input Integer phase=0;
                input Real z;
                input Real der_p;
                input Real der_h;
                output Real der_rho;
            algorithm
                der_rho := der_p + der_h;
            end der_F;

            function F 
                import SI = Modelica.SIunits;
                input SI.Pressure p;
                input SI.SpecificEnthalpy h;
                input Integer phase=0;
                input Real z;
                output SI.Density rho;
            algorithm
                rho := p + h;
            annotation(derivative(noDerivative=z)=der_F);
            end F;

            Real x,y;
        equation
            der(x) + der(y) = 0;
            x + F(y,x,0,x) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DerivativeAnnotation_NoDerivative1",
            description="Index reduction: function with record input & output",
            inline_functions="none",
            flatModel="
fclass Differentiation.DerivativeAnnotation.NoDerivative1
 Real x;
 Real y;
 Real _der_x;
initial equation
 y = 0.0;
equation
 _der_x + der(y) = 0;
 x + Differentiation.DerivativeAnnotation.NoDerivative1.F(y, x, 0, x) = 0;
 _der_x + Differentiation.DerivativeAnnotation.NoDerivative1.der_F(y, x, 0, x, der(y), _der_x) = 0;

public
 function Differentiation.DerivativeAnnotation.NoDerivative1.F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  output Real rho;
 algorithm
  rho := p + h;
  return;
 annotation(derivative(noDerivative = z) = Differentiation.DerivativeAnnotation.NoDerivative1.der_F);
 end Differentiation.DerivativeAnnotation.NoDerivative1.F;

 function Differentiation.DerivativeAnnotation.NoDerivative1.der_F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  input Real der_p;
  input Real der_h;
  output Real der_rho;
 algorithm
  der_rho := der_p + der_h;
  return;
 end Differentiation.DerivativeAnnotation.NoDerivative1.der_F;

end Differentiation.DerivativeAnnotation.NoDerivative1;
")})));
        end NoDerivative1;

        model Order1
            function f
                input Real x;
                output Real y;
            algorithm
                y := x * x;
                y := y * x + 2 * y + 3 * x;
                annotation(derivative=df);
            end f;

            function df
                input Real x;
                input Real dx;
                output Real dy;
            algorithm
                dy := x * x;
                dy := dy + 2 * x + 3;
                annotation(derivative(order=2)=ddf);
            end df;

            function ddf
                input Real x;
                input Real dx;
                input Real ddx;
                output Real ddy;
            algorithm
                ddy := x;
                ddy := ddy + 2;
            end ddf;
    
            Real x;
            Real dx;
            Real y;
            Real dy;
        equation
            der(x) = dx;
            der(y) = dy;
            der(dx) + der(dy) = 0;
            x + f(y) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DerivativeAnnotation_Order1",
            description="Test use of order argument to derivative annotation",
            flatModel="
fclass Differentiation.DerivativeAnnotation.Order1
 Real x;
 Real dx;
 Real y;
 Real dy;
 Real _der_x;
 Real _der_dx;
 Real _der_der_y;
initial equation
 y = 0.0;
 dy = 0.0;
equation
 _der_x = dx;
 der(y) = dy;
 _der_dx + der(dy) = 0;
 x + Differentiation.DerivativeAnnotation.Order1.f(y) = 0;
 _der_x + Differentiation.DerivativeAnnotation.Order1.df(y, der(y)) = 0;
 _der_der_y = der(dy);
 _der_dx + Differentiation.DerivativeAnnotation.Order1.ddf(y, der(y), _der_der_y) = 0;

public
 function Differentiation.DerivativeAnnotation.Order1.f
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  y := y * x + 2 * y + 3 * x;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Order1.df);
 end Differentiation.DerivativeAnnotation.Order1.f;

 function Differentiation.DerivativeAnnotation.Order1.df
  input Real x;
  input Real dx;
  output Real dy;
 algorithm
  dy := x * x;
  dy := dy + 2 * x + 3;
  return;
 annotation(derivative(order = 2) = Differentiation.DerivativeAnnotation.Order1.ddf);
 end Differentiation.DerivativeAnnotation.Order1.df;

 function Differentiation.DerivativeAnnotation.Order1.ddf
  input Real x;
  input Real dx;
  input Real ddx;
  output Real ddy;
 algorithm
  ddy := x;
  ddy := ddy + 2;
  return;
 end Differentiation.DerivativeAnnotation.Order1.ddf;

end Differentiation.DerivativeAnnotation.Order1;
")})));
        end Order1;


        model Order2
            function f
                input Real x1;
                input Real x2;
                output Real y;
            algorithm
                y := x1 * x1;
                y := y * x2;
                annotation(derivative=df);
            end f;

            function df
                input Real x1;
                input Real x2;
                input Real dx1;
                input Real dx2;
                output Real dy;
            algorithm
                dy := x1 * x1;
                dy := dy * x2;
                annotation(derivative(order=2)=ddf);
            end df;

            function ddf
                input Real x1;
                input Real x2;
                input Real dx1;
                input Real dx2;
                input Real ddx1;
                input Real ddx2;
                output Real ddy;
            algorithm
                ddy := x1 * x1;
                ddy := ddy * x2;
            end ddf;

            Real x;
            Real dx;
            Real y;
            Real dy;
        equation
            der(x) = dx;
            der(y) = dy;
            der(dx) + der(dy) = 0;
            x + f(y, time) = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DerivativeAnnotation_Order2",
            description="Test use of order argument to derivative annotation for function with two arguments",
            flatModel="
fclass Differentiation.DerivativeAnnotation.Order2
 Real x;
 Real dx;
 Real y;
 Real dy;
 Real _der_x;
 Real _der_dx;
 Real _der_der_y;
initial equation
 y = 0.0;
 dy = 0.0;
equation
 _der_x = dx;
 der(y) = dy;
 _der_dx + der(dy) = 0;
 x + Differentiation.DerivativeAnnotation.Order2.f(y, time) = 0;
 _der_x + Differentiation.DerivativeAnnotation.Order2.df(y, time, der(y), 1.0) = 0;
 _der_der_y = der(dy);
 _der_dx + Differentiation.DerivativeAnnotation.Order2.ddf(y, time, der(y), 1.0, _der_der_y, 0.0) = 0;

public
 function Differentiation.DerivativeAnnotation.Order2.f
  input Real x1;
  input Real x2;
  output Real y;
 algorithm
  y := x1 * x1;
  y := y * x2;
  return;
 annotation(derivative = Differentiation.DerivativeAnnotation.Order2.df);
 end Differentiation.DerivativeAnnotation.Order2.f;

 function Differentiation.DerivativeAnnotation.Order2.df
  input Real x1;
  input Real x2;
  input Real dx1;
  input Real dx2;
  output Real dy;
 algorithm
  dy := x1 * x1;
  dy := dy * x2;
  return;
 annotation(derivative(order = 2) = Differentiation.DerivativeAnnotation.Order2.ddf);
 end Differentiation.DerivativeAnnotation.Order2.df;

 function Differentiation.DerivativeAnnotation.Order2.ddf
  input Real x1;
  input Real x2;
  input Real dx1;
  input Real dx2;
  input Real ddx1;
  input Real ddx2;
  output Real ddy;
 algorithm
  ddy := x1 * x1;
  ddy := ddy * x2;
  return;
 end Differentiation.DerivativeAnnotation.Order2.ddf;

end Differentiation.DerivativeAnnotation.Order2;
")})));
        end Order2;

        model Functional1
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
                annotation(smoothOrder=1);
            end usePartFunc;

            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + usePartFunc(function fullFunc(x1=x2)) = 1;

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="DerivativeAnnotation_Functional1",
                description="Test differentiation of functional input arguments",
                flatModel="
fclass Differentiation.DerivativeAnnotation.Functional1
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.DerivativeAnnotation.Functional1.usePartFunc(function Differentiation.DerivativeAnnotation.Functional1.fullFunc(x2)) = 1;
 _der_x1 + Differentiation.DerivativeAnnotation.Functional1._der_usePartFunc(function Differentiation.DerivativeAnnotation.Functional1.fullFunc(x2)) = 0;

public
 function Differentiation.DerivativeAnnotation.Functional1.usePartFunc
  input ((Real y) = Differentiation.DerivativeAnnotation.Functional1.partFunc()) pf;
  output Real y;
 algorithm
  y := pf();
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = Differentiation.DerivativeAnnotation.Functional1._der_usePartFunc);
 end Differentiation.DerivativeAnnotation.Functional1.usePartFunc;

 function Differentiation.DerivativeAnnotation.Functional1.partFunc
  output Real y;
 algorithm
  return;
 end Differentiation.DerivativeAnnotation.Functional1.partFunc;

 function Differentiation.DerivativeAnnotation.Functional1.fullFunc
  output Real y;
  input Real x1;
 algorithm
  y := x1;
  return;
 end Differentiation.DerivativeAnnotation.Functional1.fullFunc;

 function Differentiation.DerivativeAnnotation.Functional1._der_usePartFunc
  input ((Real y) = Differentiation.DerivativeAnnotation.Functional1.partFunc()) pf;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := 0.0;
  y := pf();
  return;
 annotation(smoothOrder = 0);
 end Differentiation.DerivativeAnnotation.Functional1._der_usePartFunc;

end Differentiation.DerivativeAnnotation.Functional1;
")})));
        end Functional1;

        model Functional1b
            partial function partFunc
                input Real xb;
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
                y := pf(y);
                annotation(smoothOrder=1);
            end usePartFunc;

            Real x1,x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + usePartFunc(function fullFunc(x1=x2)) = 1;

        annotation(__JModelica(UnitTesting(tests={
            ErrorTestCase(
                name="DerivativeAnnotation_Functional1b",
                description="Test failing differentiation of functional input arguments",
                errorMessage="
1 errors found:

Error in flattened model:
  Cannot differentiate call to function without derivative or smooth order annotation 'pf(y)' in equation:
   x1 + Differentiation.DerivativeAnnotation.Functional1b.usePartFunc(function Differentiation.DerivativeAnnotation.Functional1b.fullFunc(x2)) = 1
")})));
        end Functional1b;

    end DerivativeAnnotation;

    package AlgorithmDifferentiation

        model Simple
            function F
                input Real x;
                output Real y;
            algorithm
                y := sin(x);
                annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_Simple",
            description="Test differentiation of simple function",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.Simple
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.Simple.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.Simple._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.Simple.F
  input Real x;
  output Real y;
 algorithm
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.Simple._der_F);
 end Differentiation.AlgorithmDifferentiation.Simple.F;

 function Differentiation.AlgorithmDifferentiation.Simple._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.Simple._der_F;

end Differentiation.AlgorithmDifferentiation.Simple;
")})));
        end Simple;

        model RecordInput
            function F
                input R x;
                output Real y;
            algorithm
                y := sin(x.x[1]);
            annotation(Inline=false, smoothOrder=1);
            end F;
            record R
                Real x[1];
            end R;

            Real x1;
            R x2;
        equation
            der(x1) + der(x2.x[1]) = 1;
            x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_RecordInput",
            description="Test differentiation of function with record input",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.RecordInput
 Real x1;
 Real x2.x[1];
 Real _der_x1;
initial equation
 x2.x[1] = 0.0;
equation
 _der_x1 + der(x2.x[1]) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.RecordInput.F(Differentiation.AlgorithmDifferentiation.RecordInput.R({x2.x[1]})) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.RecordInput._der_F(Differentiation.AlgorithmDifferentiation.RecordInput.R({x2.x[1]}), Differentiation.AlgorithmDifferentiation.RecordInput.R({der(x2.x[1])})) = 0;

public
 function Differentiation.AlgorithmDifferentiation.RecordInput.F
  input Differentiation.AlgorithmDifferentiation.RecordInput.R x;
  output Real y;
 algorithm
  y := sin(x.x[1]);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.RecordInput._der_F);
 end Differentiation.AlgorithmDifferentiation.RecordInput.F;

 function Differentiation.AlgorithmDifferentiation.RecordInput._der_F
  input Differentiation.AlgorithmDifferentiation.RecordInput.R x;
  input Differentiation.AlgorithmDifferentiation.RecordInput.R _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := cos(x.x[1]) * _der_x.x[1];
  y := sin(x.x[1]);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.RecordInput._der_F;

 record Differentiation.AlgorithmDifferentiation.RecordInput.R
  Real x[1];
 end Differentiation.AlgorithmDifferentiation.RecordInput.R;

end Differentiation.AlgorithmDifferentiation.RecordInput;
")})));
        end RecordInput;

        model RecordOutput
            function F
                input Real x;
                output R y;
            algorithm
                y.x[1] := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;
            record R
                Real x[1];
            end R;
            Real x1;
            Real x2;
            R r;
        equation
            der(x1) + der(x2) = 1;
            r = F(x2);
            x1 + r.x[1] = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_RecordOutput",
            description="Test differentiation of function with record output",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.RecordOutput
 Real x1;
 Real x2;
 Real r.x[1];
 Real _der_x1;
 Real _der_x2;
initial equation
 r.x[1] = 0.0;
equation
 _der_x1 + _der_x2 = 1;
 (Differentiation.AlgorithmDifferentiation.RecordOutput.R({r.x[1]})) = Differentiation.AlgorithmDifferentiation.RecordOutput.F(x2);
 x1 + r.x[1] = 1;
 (Differentiation.AlgorithmDifferentiation.RecordOutput.R({der(r.x[1])})) = Differentiation.AlgorithmDifferentiation.RecordOutput._der_F(x2, _der_x2);
 _der_x1 + der(r.x[1]) = 0;

public
 function Differentiation.AlgorithmDifferentiation.RecordOutput.F
  input Real x;
  output Differentiation.AlgorithmDifferentiation.RecordOutput.R y;
 algorithm
  y.x[1] := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.RecordOutput._der_F);
 end Differentiation.AlgorithmDifferentiation.RecordOutput.F;

 function Differentiation.AlgorithmDifferentiation.RecordOutput._der_F
  input Real x;
  input Real _der_x;
  output Differentiation.AlgorithmDifferentiation.RecordOutput.R _der_y;
  Differentiation.AlgorithmDifferentiation.RecordOutput.R y;
 algorithm
  _der_y.x[1] := cos(x) * _der_x;
  y.x[1] := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.RecordOutput._der_F;

 record Differentiation.AlgorithmDifferentiation.RecordOutput.R
  Real x[1];
 end Differentiation.AlgorithmDifferentiation.RecordOutput.R;

end Differentiation.AlgorithmDifferentiation.RecordOutput;
")})));
        end RecordOutput;

        model For
            function F
                input Real x;
                output Real y;
                output Real c = 0;
            algorithm
                for i in 1:10 loop
                    if i > x then
                    break;
                end if;
                    c := c + 0.5;
                end for;
                y := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_For",
            description="Test differentiation of function with for statement",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.For
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.For.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.For._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.For.F
  input Real x;
  output Real y;
  output Real c;
 algorithm
  c := 0;
  for i in 1:10 loop
   if i > x then
    break;
   end if;
   c := c + 0.5;
  end for;
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.For._der_F);
 end Differentiation.AlgorithmDifferentiation.For.F;

 function Differentiation.AlgorithmDifferentiation.For._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0;
  c := 0;
  for i in 1:10 loop
   if i > x then
    break;
   end if;
   _der_c := _der_c;
   c := c + 0.5;
  end for;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.For._der_F;

end Differentiation.AlgorithmDifferentiation.For;
")})));
        end For;

        model FunctionCall
            function F1
                input Real x1;
                input Real x2;
                output Real y;
                Real a;
                Real b;
            algorithm
                (a, b) := F2(x1, x2);
                y := a + b;
            annotation(Inline=false, smoothOrder=1);
            end F1;

            function F2
                input Real x1;
                input Real x2;
                output Real a = x1;
                output Real b = sin(x2);
            algorithm
            end F2;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            F1(x1, x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_FunctionCall",
            description="Test differentiation of function with function call statement",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.FunctionCall
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 Differentiation.AlgorithmDifferentiation.FunctionCall.F1(x1, x2) = 1;
 Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1(x1, x2, _der_x1, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.FunctionCall.F1
  input Real x1;
  input Real x2;
  output Real y;
  Real a;
  Real b;
 algorithm
  (a, b) := Differentiation.AlgorithmDifferentiation.FunctionCall.F2(x1, x2);
  y := a + b;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1);
 end Differentiation.AlgorithmDifferentiation.FunctionCall.F1;

 function Differentiation.AlgorithmDifferentiation.FunctionCall.F2
  input Real x1;
  input Real x2;
  output Real a;
  output Real b;
 algorithm
  a := x1;
  b := sin(x2);
  return;
 annotation(derivative(order = 1) = Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2);
 end Differentiation.AlgorithmDifferentiation.FunctionCall.F2;

 function Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_y;
  Real y;
  Real a;
  Real _der_a;
  Real b;
  Real _der_b;
 algorithm
  (_der_a, _der_b) := Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2(x1, x2, _der_x1, _der_x2);
  (a, b) := Differentiation.AlgorithmDifferentiation.FunctionCall.F2(x1, x2);
  _der_y := _der_a + _der_b;
  y := a + b;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.FunctionCall._der_F1;

 function Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_a;
  output Real _der_b;
  Real a;
  Real b;
 algorithm
  _der_a := _der_x1;
  a := x1;
  _der_b := cos(x2) * _der_x2;
  b := sin(x2);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.FunctionCall._der_F2;

end Differentiation.AlgorithmDifferentiation.FunctionCall;
")})));
        end FunctionCall;

        model If
            function F
                input Real x;
                output Real y;
                output Real b;
            algorithm
                if 10 > x then
                    b := 1;
                else
                    b := 2;
                end if;
                y := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_If",
            description="Test differentiation of function with if statement",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.If
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.If.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.If._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.If.F
  input Real x;
  output Real y;
  output Real b;
 algorithm
  if 10 > x then
   b := 1;
  else
   b := 2;
  end if;
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.If._der_F);
 end Differentiation.AlgorithmDifferentiation.If.F;

 function Differentiation.AlgorithmDifferentiation.If._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_b;
  Real y;
  Real b;
 algorithm
  if 10 > x then
   _der_b := 0;
   b := 1;
  else
   _der_b := 0;
   b := 2;
  end if;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.If._der_F;

end Differentiation.AlgorithmDifferentiation.If;
")})));
        end If;

        model InitArray
            function F
                    input Real[:] x;
                    output Real y;
                    Real[:] a = x .^ 2;
                algorithm
                    y := a[1];
                annotation(Inline=false, smoothOrder=3);
            end F;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F({x2}) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_InitArray",
            description="Test differentiation of function with initial array statement",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.InitArray
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.InitArray.F({x2}) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.InitArray._der_F({x2}, {der(x2)}) = 0;

public
 function Differentiation.AlgorithmDifferentiation.InitArray.F
  input Real[:] x;
  output Real y;
  Real[:] a;
 algorithm
  init a as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   a[i1] := x[i1] .^ 2;
  end for;
  y := a[1];
  return;
 annotation(Inline = false,smoothOrder = 3,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.InitArray._der_F);
 end Differentiation.AlgorithmDifferentiation.InitArray.F;

 function Differentiation.AlgorithmDifferentiation.InitArray._der_F
  input Real[:] x;
  input Real[:] _der_x;
  output Real _der_y;
  Real y;
  Real[:] a;
  Real[:] _der_a;
 algorithm
  init a as Real[size(x, 1)];
  init _der_a as Real[size(x, 1)];
  for i1 in 1:size(x, 1) loop
   _der_a[i1] := 2 .* x[i1] .* _der_x[i1];
   a[i1] := x[i1] .^ 2;
  end for;
  _der_y := _der_a[1];
  y := a[1];
  return;
 annotation(smoothOrder = 2,derivative(order = 2) = Differentiation.AlgorithmDifferentiation.InitArray._der_der_F);
 end Differentiation.AlgorithmDifferentiation.InitArray._der_F;

end Differentiation.AlgorithmDifferentiation.InitArray;
")})));
        end InitArray;

        model RecordArray
            record R
                Real x;
            end R;

            function F
                input R[1] x;
                output R[1] y;
            algorithm
                y := x;
            annotation(Inline=false, smoothOrder=3);
            end F;
    
            function e
                input R[:] r;
                output Real y = r[1].x;
                algorithm
            end e;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + e(F({R(x2)})) = 1;

        annotation(__JModelica(UnitTesting(tests={
            CCodeGenTestCase(
                name="AlgorithmDifferentiation_RecordArray",
                description="Test code gen of differentiated function with array of records #3611",
                dynamic_states=false,
                template="$C_functions$",
                generatedCode="
void func_Differentiation_AlgorithmDifferentiation_RecordArray_F_def0(R_0_ra* x_a, R_0_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, y_an, 1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, y_an, 1, 1, 1)
        y_a = y_an;
    }
    i1_0in = 0;
    i1_0ie = floor((1) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        jmi_array_rec_1(y_a, i1_0i)->x = jmi_array_rec_1(x_a, i1_0i)->x;
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_Differentiation_AlgorithmDifferentiation_RecordArray__der_F_def1(R_0_ra* x_a, R_0_ra* _der_x_a, R_0_ra* _der_y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, _der_y_an, 1, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, y_a, 1, 1)
    jmi_real_t i1_1i;
    jmi_int_t i1_1ie;
    jmi_int_t i1_1in;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, y_a, 1, 1, 1)
    if (_der_y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, _der_y_an, 1, 1, 1)
        _der_y_a = _der_y_an;
    }
    i1_1in = 0;
    i1_1ie = floor((1) - (1));
    for (i1_1i = 1; i1_1in <= i1_1ie; i1_1i = 1 + (++i1_1in)) {
        jmi_array_rec_1(_der_y_a, i1_1i)->x = jmi_array_rec_1(_der_x_a, i1_1i)->x;
        jmi_array_rec_1(y_a, i1_1i)->x = jmi_array_rec_1(x_a, i1_1i)->x;
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
        end RecordArray;

        model RecordArrayTemp1
            record R
                Real[1] x;
            end R;

            function F
                input R[1] x;
                output R[1] y;
            algorithm
                y := x;
            annotation(Inline=false, smoothOrder=3);
            end F;
    
            function e
                input R[:] r;
                R[:] rt = {r[1]};
                output Real y = rt[1].x[1];
                algorithm
                annotation(smoothOrder=1);
            end e;
            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + e(F({R({x2})})) = 1;

        annotation(__JModelica(UnitTesting(tests={
            CCodeGenTestCase(
                name="AlgorithmDifferentiation_RecordArrayTemp1",
                description="Test code gen of differentiated function with array of records #3611",
                dynamic_states=false,
                template="$C_functions$",
                generatedCode="
void func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1_e_def0(R_0_ra* r_a, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, rt_a, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_DEF(REA, y_v)
    JMI_ARR(STACK, R_0_r, R_0_ra, temp_1_a, 1, 1)
    jmi_real_t i1_0i;
    jmi_int_t i1_0ie;
    jmi_int_t i1_0in;
    jmi_real_t i2_1i;
    jmi_int_t i2_1ie;
    jmi_int_t i2_1in;
    jmi_real_t i1_2i;
    jmi_int_t i1_2ie;
    jmi_int_t i1_2in;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, rt_a, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
    jmi_array_rec_1(rt_a, 1)->x = tmp_1;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, temp_1_a, 1, 1, 1)
    *jmi_array_rec_1(temp_1_a, 1) = *jmi_array_rec_1(r_a, 1);
    i1_0in = 0;
    i1_0ie = floor((1) - (1));
    for (i1_0i = 1; i1_0in <= i1_0ie; i1_0i = 1 + (++i1_0in)) {
        i2_1in = 0;
        i2_1ie = floor((1) - (1));
        for (i2_1i = 1; i2_1in <= i2_1ie; i2_1i = 1 + (++i2_1in)) {
            jmi_array_ref_1(jmi_array_rec_1(rt_a, i1_0i)->x, i2_1i) = jmi_array_val_1(jmi_array_rec_1(temp_1_a, i1_0i)->x, i2_1i);
        }
    }
    y_v = jmi_array_val_1(jmi_array_rec_1(rt_a, 1)->x, 1);
    i1_2in = 0;
    i1_2ie = floor((jmi_array_size(r_a, 0)) - (1));
    for (i1_2i = 1; i1_2in <= i1_2ie; i1_2i = 1 + (++i1_2in)) {
        if (COND_EXP_EQ(1.0, jmi_array_size(jmi_array_rec_1(r_a, i1_2i)->x, 0), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
            jmi_assert_failed(\"Mismatching sizes in function 'Differentiation.AlgorithmDifferentiation.RecordArrayTemp1.e', component 'r[i1].x', dimension '1'\", JMI_ASSERT_ERROR);
        }
    }
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1_e_exp0(R_0_ra* r_a) {
    JMI_DEF(REA, y_v)
    func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1_e_def0(r_a, &y_v);
    return y_v;
}

void func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1_F_def1(R_0_ra* x_a, R_0_ra* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, y_an, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    jmi_real_t i1_3i;
    jmi_int_t i1_3ie;
    jmi_int_t i1_3in;
    jmi_real_t i1_4i;
    jmi_int_t i1_4ie;
    jmi_int_t i1_4in;
    jmi_real_t i2_5i;
    jmi_int_t i2_5ie;
    jmi_int_t i2_5in;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, y_an, 1, 1, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
        jmi_array_rec_1(y_an, 1)->x = tmp_1;
        y_a = y_an;
    }
    i1_3in = 0;
    i1_3ie = floor((1) - (1));
    for (i1_3i = 1; i1_3in <= i1_3ie; i1_3i = 1 + (++i1_3in)) {
        if (COND_EXP_EQ(1.0, jmi_array_size(jmi_array_rec_1(x_a, i1_3i)->x, 0), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
            jmi_assert_failed(\"Mismatching sizes in function 'Differentiation.AlgorithmDifferentiation.RecordArrayTemp1.F', component 'x[i1].x', dimension '1'\", JMI_ASSERT_ERROR);
        }
    }
    i1_4in = 0;
    i1_4ie = floor((1) - (1));
    for (i1_4i = 1; i1_4in <= i1_4ie; i1_4i = 1 + (++i1_4in)) {
        i2_5in = 0;
        i2_5ie = floor((1) - (1));
        for (i2_5i = 1; i2_5in <= i2_5ie; i2_5i = 1 + (++i2_5in)) {
            jmi_array_ref_1(jmi_array_rec_1(y_a, i1_4i)->x, i2_5i) = jmi_array_val_1(jmi_array_rec_1(x_a, i1_4i)->x, i2_5i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1__der_e_def2(R_0_ra* r_a, R_0_ra* _der_r_a, jmi_real_t* _der_y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, _der_y_v)
    JMI_ARR(STACK, R_0_r, R_0_ra, rt_a, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, _der_rt_a, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_DEF(REA, y_v)
    JMI_ARR(STACK, R_0_r, R_0_ra, temp_1_a, 1, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, _der_temp_1_a, 1, 1)
    jmi_real_t i1_6i;
    jmi_int_t i1_6ie;
    jmi_int_t i1_6in;
    jmi_real_t i2_7i;
    jmi_int_t i2_7ie;
    jmi_int_t i2_7in;
    jmi_real_t i1_8i;
    jmi_int_t i1_8ie;
    jmi_int_t i1_8in;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, rt_a, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
    jmi_array_rec_1(rt_a, 1)->x = tmp_1;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, _der_rt_a, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_rec_1(_der_rt_a, 1)->x = tmp_2;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, temp_1_a, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, _der_temp_1_a, 1, 1, 1)
    *jmi_array_rec_1(_der_temp_1_a, 1) = *jmi_array_rec_1(_der_r_a, 1);
    *jmi_array_rec_1(temp_1_a, 1) = *jmi_array_rec_1(r_a, 1);
    i1_6in = 0;
    i1_6ie = floor((1) - (1));
    for (i1_6i = 1; i1_6in <= i1_6ie; i1_6i = 1 + (++i1_6in)) {
        i2_7in = 0;
        i2_7ie = floor((1) - (1));
        for (i2_7i = 1; i2_7in <= i2_7ie; i2_7i = 1 + (++i2_7in)) {
            jmi_array_ref_1(jmi_array_rec_1(_der_rt_a, i1_6i)->x, i2_7i) = jmi_array_val_1(jmi_array_rec_1(_der_temp_1_a, i1_6i)->x, i2_7i);
            jmi_array_ref_1(jmi_array_rec_1(rt_a, i1_6i)->x, i2_7i) = jmi_array_val_1(jmi_array_rec_1(temp_1_a, i1_6i)->x, i2_7i);
        }
    }
    _der_y_v = jmi_array_val_1(jmi_array_rec_1(_der_rt_a, 1)->x, 1);
    y_v = jmi_array_val_1(jmi_array_rec_1(rt_a, 1)->x, 1);
    i1_8in = 0;
    i1_8ie = floor((jmi_array_size(r_a, 0)) - (1));
    for (i1_8i = 1; i1_8in <= i1_8ie; i1_8i = 1 + (++i1_8in)) {
        if (COND_EXP_EQ(1.0, jmi_array_size(jmi_array_rec_1(r_a, i1_8i)->x, 0), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
            jmi_assert_failed(\"Mismatching sizes in function 'Differentiation.AlgorithmDifferentiation.RecordArrayTemp1.e', component 'r[i1].x', dimension '1'\", JMI_ASSERT_ERROR);
        }
    }
    JMI_RET(GEN, _der_y_o, _der_y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1__der_e_exp2(R_0_ra* r_a, R_0_ra* _der_r_a) {
    JMI_DEF(REA, _der_y_v)
    func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1__der_e_def2(r_a, _der_r_a, &_der_y_v);
    return _der_y_v;
}

void func_Differentiation_AlgorithmDifferentiation_RecordArrayTemp1__der_F_def3(R_0_ra* x_a, R_0_ra* _der_x_a, R_0_ra* _der_y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STACK, R_0_r, R_0_ra, _der_y_an, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STACK, R_0_r, R_0_ra, y_a, 1, 1)
    JMI_ARR(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    jmi_real_t i1_9i;
    jmi_int_t i1_9ie;
    jmi_int_t i1_9in;
    jmi_real_t i1_10i;
    jmi_int_t i1_10ie;
    jmi_int_t i1_10in;
    jmi_real_t i2_11i;
    jmi_int_t i2_11ie;
    jmi_int_t i2_11in;
    JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, y_a, 1, 1, 1)
    JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_rec_1(y_a, 1)->x = tmp_2;
    if (_der_y_a == NULL) {
        JMI_ARRAY_INIT_1(STACK, R_0_r, R_0_ra, _der_y_an, 1, 1, 1)
        JMI_ARRAY_INIT_1(STACK, jmi_real_t, jmi_array_t, tmp_1, 1, 1, 1)
        jmi_array_rec_1(_der_y_an, 1)->x = tmp_1;
        _der_y_a = _der_y_an;
    }
    i1_9in = 0;
    i1_9ie = floor((1) - (1));
    for (i1_9i = 1; i1_9in <= i1_9ie; i1_9i = 1 + (++i1_9in)) {
        if (COND_EXP_EQ(1.0, jmi_array_size(jmi_array_rec_1(x_a, i1_9i)->x, 0), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
            jmi_assert_failed(\"Mismatching sizes in function 'Differentiation.AlgorithmDifferentiation.RecordArrayTemp1.F', component 'x[i1].x', dimension '1'\", JMI_ASSERT_ERROR);
        }
    }
    i1_10in = 0;
    i1_10ie = floor((1) - (1));
    for (i1_10i = 1; i1_10in <= i1_10ie; i1_10i = 1 + (++i1_10in)) {
        i2_11in = 0;
        i2_11ie = floor((1) - (1));
        for (i2_11i = 1; i2_11in <= i2_11ie; i2_11i = 1 + (++i2_11in)) {
            jmi_array_ref_1(jmi_array_rec_1(_der_y_a, i1_10i)->x, i2_11i) = jmi_array_val_1(jmi_array_rec_1(_der_x_a, i1_10i)->x, i2_11i);
            jmi_array_ref_1(jmi_array_rec_1(y_a, i1_10i)->x, i2_11i) = jmi_array_val_1(jmi_array_rec_1(x_a, i1_10i)->x, i2_11i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
        end RecordArrayTemp1;

        model While
            function F
                input Real x;
                output Real y;
                output Real c = 0;
            algorithm
                while c < x loop
                    c := c + 0.5;
                end while;
                y := sin(x);
            annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_While",
            description="Test differentiation of function with while statement",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.While
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.While.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.While._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.While.F
  input Real x;
  output Real y;
  output Real c;
 algorithm
  c := 0;
  while c < x loop
   c := c + 0.5;
  end while;
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.While._der_F);
 end Differentiation.AlgorithmDifferentiation.While.F;

 function Differentiation.AlgorithmDifferentiation.While._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_c;
  Real y;
  Real c;
 algorithm
  _der_c := 0;
  c := 0;
  while c < x loop
   _der_c := _der_c;
   c := c + 0.5;
  end while;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.While._der_F;

end Differentiation.AlgorithmDifferentiation.While;
")})));
        end While;

        model Recursive
            function F1
                input Real x1;
                input Real x2;
                output Real y;
                Real a;
                Real b;
            algorithm
                (a, b) := F2(x1, x2, 0);
                y := a + b;
            annotation(Inline=false, smoothOrder=1);
            end F1;

            function F2
                input Real x1;
                input Real x2;
                input Integer c;
                output Real a;
                output Real b;
            algorithm
                if c < 10 then
                    (a, b) := F2(x1, x2, c + 1);
                else
                    a := x1;
                    b := sin(x2);
                end if;
            end F2;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            F1(x1, x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_Recursive",
            description="Test differentiation of Recursive function",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.Recursive
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 Differentiation.AlgorithmDifferentiation.Recursive.F1(x1, x2) = 1;
 Differentiation.AlgorithmDifferentiation.Recursive._der_F1(x1, x2, _der_x1, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.Recursive.F1
  input Real x1;
  input Real x2;
  output Real y;
  Real a;
  Real b;
 algorithm
  (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, 0);
  y := a + b;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.Recursive._der_F1);
 end Differentiation.AlgorithmDifferentiation.Recursive.F1;

 function Differentiation.AlgorithmDifferentiation.Recursive.F2
  input Real x1;
  input Real x2;
  input Integer c;
  output Real a;
  output Real b;
 algorithm
  if c < 10 then
   (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, c + 1);
  else
   a := x1;
   b := sin(x2);
  end if;
  return;
 annotation(derivative(order = 1) = Differentiation.AlgorithmDifferentiation.Recursive._der_F2);
 end Differentiation.AlgorithmDifferentiation.Recursive.F2;

 function Differentiation.AlgorithmDifferentiation.Recursive._der_F1
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_y;
  Real y;
  Real a;
  Real _der_a;
  Real b;
  Real _der_b;
 algorithm
  (_der_a, _der_b) := Differentiation.AlgorithmDifferentiation.Recursive._der_F2(x1, x2, 0, _der_x1, _der_x2);
  (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, 0);
  _der_y := _der_a + _der_b;
  y := a + b;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.Recursive._der_F1;

 function Differentiation.AlgorithmDifferentiation.Recursive._der_F2
  input Real x1;
  input Real x2;
  input Integer c;
  input Real _der_x1;
  input Real _der_x2;
  output Real _der_a;
  output Real _der_b;
  Real a;
  Real b;
 algorithm
  if c < 10 then
   (_der_a, _der_b) := Differentiation.AlgorithmDifferentiation.Recursive._der_F2(x1, x2, c + 1, _der_x1, _der_x2);
   (a, b) := Differentiation.AlgorithmDifferentiation.Recursive.F2(x1, x2, c + 1);
  else
   _der_a := _der_x1;
   a := x1;
   _der_b := cos(x2) * _der_x2;
   b := sin(x2);
  end if;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.Recursive._der_F2;

end Differentiation.AlgorithmDifferentiation.Recursive;
")})));
        end Recursive;

        model DiscreteComponents
            function F
                input Real x;
                output Real y;
                output Integer c = 0;
            algorithm
                c := if x > 23 then 2 else -2;
                c := c + 23;
                y := sin(x);
                annotation(Inline=false, smoothOrder=1);
            end F;

            Real x1;
            Real x2;
        equation
            der(x1) + der(x2) = 1;
            x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_DiscreteComponents",
            description="Test differentiation of function with discrete components",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.DiscreteComponents
 Real x1;
 Real x2;
 Real _der_x1;
initial equation
 x2 = 0.0;
equation
 _der_x1 + der(x2) = 1;
 x1 + Differentiation.AlgorithmDifferentiation.DiscreteComponents.F(x2) = 1;
 _der_x1 + Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F(x2, der(x2)) = 0;

public
 function Differentiation.AlgorithmDifferentiation.DiscreteComponents.F
  input Real x;
  output Real y;
  output Integer c;
 algorithm
  c := 0;
  c := if x > 23 then 2 else -2;
  c := c + 23;
  y := sin(x);
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F);
 end Differentiation.AlgorithmDifferentiation.DiscreteComponents.F;

 function Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
  Integer c;
 algorithm
  c := 0;
  c := if x > 23 then 2 else -2;
  c := c + 23;
  _der_y := cos(x) * _der_x;
  y := sin(x);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.DiscreteComponents._der_F;

end Differentiation.AlgorithmDifferentiation.DiscreteComponents;
")})));
        end DiscreteComponents;

        model PlanarPendulum
            function square
                input Real x;
                output Real y;
            algorithm
                y := x ^ 2;
                annotation(Inline=false, smoothOrder=2);
            end square;
  
            parameter Real L = 1 "Pendulum length";
            parameter Real g =9.81 "Acceleration due to gravity";
            Real x "Cartesian x coordinate";
            Real y "Cartesian x coordinate";
            Real vx "Velocity in x coordinate";
            Real vy "Velocity in y coordinate";
            Real lambda "Lagrange multiplier";
        equation
            der(x) = vx;
            der(y) = vy;
            der(vx) = lambda*x;
            der(vy) = lambda*y - g;
            square(x) + square(y) = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_PlanarPendulum",
            description="Test differentiation of simple function twice",
            dynamic_states=false,
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.PlanarPendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 Differentiation.AlgorithmDifferentiation.PlanarPendulum.square(x) + Differentiation.AlgorithmDifferentiation.PlanarPendulum.square(y) = L;
 Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square(x, _der_x) + Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square(y, der(y)) = 0.0;
 _der_der_y = der(vy);
 Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square(x, _der_x, _der_vx) + Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square(y, der(y), _der_der_y) = 0.0;

public
 function Differentiation.AlgorithmDifferentiation.PlanarPendulum.square
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 annotation(Inline = false,smoothOrder = 2,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square);
 end Differentiation.AlgorithmDifferentiation.PlanarPendulum.square;

 function Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := 2 * x * _der_x;
  y := x ^ 2;
  return;
 annotation(smoothOrder = 1,derivative(order = 2) = Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square);
 end Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_square;

 function Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square
  input Real x;
  input Real _der_x;
  input Real _der_der_x;
  output Real _der_der_y;
  Real _der_y;
  Real y;
 algorithm
  _der_der_y := 2 * x * _der_der_x + 2 * _der_x * _der_x;
  _der_y := 2 * x * _der_x;
  y := x ^ 2;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.PlanarPendulum._der_der_square;

end Differentiation.AlgorithmDifferentiation.PlanarPendulum;
")})));
        end PlanarPendulum;

        model SelfReference_AssignStmt
            function F
                input Real x;
                output Real y;
            algorithm
                y := x * x;
                y := y * x;
            annotation(smoothOrder=1);
            end F;
            Real a = F(time * 2);
            Real b = der(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmDifferentiation_SelfReference_AssignStmt",
            description="Test differentiation of statements with lsh variable in rhs",
            flatModel="
fclass Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt
 Real a;
 Real b;
equation
 a = Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt.F(time * 2);
 b = Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F(time * 2, 2);

public
 function Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt.F
  input Real x;
  output Real y;
 algorithm
  y := x * x;
  y := y * x;
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F);
 end Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt.F;

 function Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := x * _der_x + _der_x * x;
  y := x * x;
  _der_y := y * _der_x + _der_y * x;
  y := y * x;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt._der_F;

end Differentiation.AlgorithmDifferentiation.SelfReference_AssignStmt;
")})));
        end SelfReference_AssignStmt;

        model SelfReference_FunctionCall
            function F1
                input Real x;
                output Real y;
            algorithm
                (,y) := F2(x);
                (,y) := F2(y);
            annotation(smoothOrder=1);
            end F1;
            function F2
                input Real x;
                output Real y;
                output Real z;
            algorithm
                y := 42;
                z := x * x;
                z := z * x;
            annotation(smoothOrder=1);
            end F2;
            Real a = F1(time * 2);
            Real b = der(a);

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="AlgorithmDifferentiation_SelfReference_FunctionCall",
                description="Test differentiation of statements with lsh variable in rhs",
                flatModel="
fclass Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall
 Real a;
 Real b;
equation
 a = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F1(time * 2);
 b = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1(time * 2, 2);

public
 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F1
  input Real x;
  output Real y;
 algorithm
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(x);
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(y);
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F1;

 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2
  input Real x;
  output Real y;
  output Real z;
 algorithm
  y := 42;
  z := x * x;
  z := z * x;
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2;

 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  (, _der_y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2(x, _der_x);
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(x);
  (, _der_y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2(y, _der_y);
  (, y) := Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall.F2(y);
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F1;

 function Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := 0;
  y := 42;
  _der_z := x * _der_x + _der_x * x;
  z := x * x;
  _der_z := z * _der_x + _der_z * x;
  z := z * x;
  return;
 annotation(smoothOrder = 0);
 end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall._der_F2;

end Differentiation.AlgorithmDifferentiation.SelfReference_FunctionCall;
")})));
        end SelfReference_FunctionCall;

    end AlgorithmDifferentiation;

model TempDiff
    function f
        input Real x1;
        input Real[:] x2;
        output Real y = sum(cat(1, {x1}, x2));
        algorithm
        annotation(Inline=false, smoothOrder=2);
    end f;
    
    Real x,y;
equation
    x = f(y, {time});
    der(y) = der(x);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempDiff",
            description="Test differentiation of temporary array from scalarization",
            flatModel="
fclass Differentiation.TempDiff
 Real x;
 Real y;
 Real _der_x;
initial equation
 y = 0.0;
equation
 x = Differentiation.TempDiff.f(y, {time});
 der(y) = _der_x;
 _der_x = Differentiation.TempDiff._der_f(y, {time}, der(y), {1.0});

public
 function Differentiation.TempDiff.f
  input Real x1;
  input Real[:] x2;
  output Real y;
  Real temp_1;
  Real[:] temp_2;
  Real[:] temp_3;
 algorithm
  init temp_2 as Real[1 + size(x2, 1)];
  init temp_3 as Real[1];
  temp_3[1] := x1;
  for i2 in 1:1 loop
   temp_2[i2] := temp_3[i2];
  end for;
  for i2 in 1:size(x2, 1) loop
   temp_2[i2 + 1] := x2[i2];
  end for;
  temp_1 := 0.0;
  for i1 in 1:1 + size(x2, 1) loop
   temp_1 := temp_1 + temp_2[i1];
  end for;
  y := temp_1;
  return;
 annotation(Inline = false,smoothOrder = 2,derivative(order = 1) = Differentiation.TempDiff._der_f);
 end Differentiation.TempDiff.f;

 function Differentiation.TempDiff._der_f
  input Real x1;
  input Real[:] x2;
  input Real _der_x1;
  input Real[:] _der_x2;
  output Real _der_y;
  Real y;
  Real temp_1;
  Real _der_temp_1;
  Real[:] temp_2;
  Real[:] _der_temp_2;
  Real[:] temp_3;
  Real[:] _der_temp_3;
 algorithm
  init temp_2 as Real[1 + size(x2, 1)];
  init _der_temp_2 as Real[1 + size(x2, 1)];
  init temp_3 as Real[1];
  init _der_temp_3 as Real[1];
  _der_temp_3[1] := _der_x1;
  temp_3[1] := x1;
  for i2 in 1:1 loop
   _der_temp_2[i2] := _der_temp_3[i2];
   temp_2[i2] := temp_3[i2];
  end for;
  for i2 in 1:size(x2, 1) loop
   _der_temp_2[i2 + 1] := _der_x2[i2];
   temp_2[i2 + 1] := x2[i2];
  end for;
  _der_temp_1 := 0.0;
  temp_1 := 0.0;
  for i1 in 1:1 + size(x2, 1) loop
   _der_temp_1 := _der_temp_1 + _der_temp_2[i1];
   temp_1 := temp_1 + temp_2[i1];
  end for;
  _der_y := _der_temp_1;
  y := temp_1;
  return;
 annotation(smoothOrder = 1,derivative(order = 2) = Differentiation.TempDiff._der_der_f);
 end Differentiation.TempDiff._der_f;

end Differentiation.TempDiff;
")})));
end TempDiff;


model MultipleDerivativeAnnotation1
    function f
        input Real x;
        output Real y;
    algorithm
        y := x;
        annotation (derivative(order=1) = df,
                    Inline=false);
    end f;

    function df
        input Real x;
        input Real dx;
        output Real dy;
    algorithm
        dy := x + dx;
        annotation (derivative(order=2) = d2f,
                    derivative(order=1) = ddf,
                    Inline=false);
    end df;

    function ddf
        input Real x;
        input Real dx;
        input Real dx2;
        input Real ddx;
        output Real ddy;
    algorithm
        ddy := 0;
        annotation (Inline=false);
     end ddf;

    function d2f
        input Real x;
        input Real dx;
        input Real d2x;
        output Real d2y;
    algorithm
        d2y := x + dx + d2x;
        annotation (Inline=false);
    end d2f;

    Real x;
    Real y;
    Real z;
    Real dx;
    Real dy;
equation
    x = f(time);
    der(x) = y;
    der(y) = z;
    dx = df(2.0 * time, 2.0);
    der(dx) = dy;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MultipleDerivativeAnnotation1",
            description="Multiple derivative annotation - different order",
            flatModel="
fclass Differentiation.MultipleDerivativeAnnotation1
 Real x;
 Real y;
 Real z;
 Real dx;
 Real dy;
 Real _der_x;
equation
 x = Differentiation.MultipleDerivativeAnnotation1.f(time);
 _der_x = y;
 dx = Differentiation.MultipleDerivativeAnnotation1.df(2.0 * time, 2.0);
 _der_x = Differentiation.MultipleDerivativeAnnotation1.df(time, 1.0);
 z = Differentiation.MultipleDerivativeAnnotation1.d2f(time, 1.0, 0.0);
 dy = Differentiation.MultipleDerivativeAnnotation1.ddf(2.0 * time, 2.0, 2.0, 0.0);

public
 function Differentiation.MultipleDerivativeAnnotation1.f
  input Real x;
  output Real y;
 algorithm
  y := x;
  return;
 annotation(derivative(order = 1) = Differentiation.MultipleDerivativeAnnotation1.df,Inline = false);
 end Differentiation.MultipleDerivativeAnnotation1.f;

 function Differentiation.MultipleDerivativeAnnotation1.df
  input Real x;
  input Real dx;
  output Real dy;
 algorithm
  dy := x + dx;
  return;
 annotation(derivative(order = 2) = Differentiation.MultipleDerivativeAnnotation1.d2f,derivative(order = 1) = Differentiation.MultipleDerivativeAnnotation1.ddf,Inline = false);
 end Differentiation.MultipleDerivativeAnnotation1.df;

 function Differentiation.MultipleDerivativeAnnotation1.d2f
  input Real x;
  input Real dx;
  input Real d2x;
  output Real d2y;
 algorithm
  d2y := x + dx + d2x;
  return;
 annotation(Inline = false);
 end Differentiation.MultipleDerivativeAnnotation1.d2f;

 function Differentiation.MultipleDerivativeAnnotation1.ddf
  input Real x;
  input Real dx;
  input Real dx2;
  input Real ddx;
  output Real ddy;
 algorithm
  ddy := 0;
  return;
 annotation(Inline = false);
 end Differentiation.MultipleDerivativeAnnotation1.ddf;

end Differentiation.MultipleDerivativeAnnotation1;
")})));
end MultipleDerivativeAnnotation1;


model MultipleDerivativeAnnotation2
    function f
        input Real x;
        input Real y;
        input Real t;
        output Real z;
    algorithm
        z := x + y;
        annotation (derivative(zeroDerivative=x, zeroDerivative=y, noDerivative=t) = dfcxy,
                    derivative(zeroDerivative=x, noDerivative=t) = dfcx,
                    derivative(zeroDerivative=y, noDerivative=t) = dfcy,
                    derivative(order=1, noDerivative=t) = df,
                    Inline=false);
    end f;

    function df
        input Real x;
        input Real y;
        input Real t;
        input Real dx;
        input Real dy;
        output Real dz;
    algorithm
        dz := dx + dy;
        annotation (Inline=false);
    end df;

    function dfcx
        input Real x;
        input Real y;
        input Real t;
        input Real dy;
        output Real dz;
    algorithm
        dz := dy;
        annotation (Inline=false);
     end dfcx;

    function dfcy
        input Real x;
        input Real y;
        input Real t;
        input Real dx;
        output Real dz;
    algorithm
        dz := dx;
        annotation (Inline=false);
     end dfcy;

    function dfcxy
        input Real x;
        input Real y;
        input Real t;
        output Real dz;
    algorithm
        dz := 0;
        annotation (Inline=false);
     end dfcxy;

    Real t[4] = (1:4) * time;
    Real x1;
    Real y1;
    Real x2;
    Real y2;
    Real x3;
    Real y3;
    Real x4;
    Real y4;
equation
    x1 = f(t[1], t[2], time);
    der(x1) = y1;
    x2 = f(t[3], 5, time);
    der(x2) = y2;
    x3 = f(6, t[4], time);
    der(x3) = y3;
    x4 = f(7, 8, time);
    der(x4) = y4;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MultipleDerivativeAnnotation2",
            description="Multiple derivative annotation - different zeroDerivative",
            flatModel="
fclass Differentiation.MultipleDerivativeAnnotation2
 Real t[1];
 Real t[2];
 Real t[3];
 Real t[4];
 Real x1;
 Real y1;
 Real x2;
 Real y2;
 Real x3;
 Real y3;
 Real x4;
 Real y4;
 Real _der_t[1];
 Real _der_t[2];
 Real _der_t[3];
 Real _der_t[4];
equation
 x1 = Differentiation.MultipleDerivativeAnnotation2.f(t[1], t[2], time);
 x2 = Differentiation.MultipleDerivativeAnnotation2.f(t[3], 5, time);
 x3 = Differentiation.MultipleDerivativeAnnotation2.f(6, t[4], time);
 x4 = Differentiation.MultipleDerivativeAnnotation2.f(7, 8, time);
 t[1] = time;
 t[2] = 2 * t[1];
 t[3] = 3 * t[1];
 t[4] = 4 * t[1];
 y4 = Differentiation.MultipleDerivativeAnnotation2.dfcxy(7, 8, time);
 y1 = Differentiation.MultipleDerivativeAnnotation2.df(t[1], t[2], time, _der_t[1], _der_t[2]);
 _der_t[1] = 1.0;
 _der_t[2] = 2 * _der_t[1];
 y2 = Differentiation.MultipleDerivativeAnnotation2.dfcy(t[3], 5, time, _der_t[3]);
 _der_t[3] = 3 * _der_t[1];
 y3 = Differentiation.MultipleDerivativeAnnotation2.dfcx(6, t[4], time, _der_t[4]);
 _der_t[4] = 4 * _der_t[1];

public
 function Differentiation.MultipleDerivativeAnnotation2.f
  input Real x;
  input Real y;
  input Real t;
  output Real z;
 algorithm
  z := x + y;
  return;
 annotation(derivative(zeroDerivative = x,zeroDerivative = y,noDerivative = t) = Differentiation.MultipleDerivativeAnnotation2.dfcxy,derivative(zeroDerivative = x,noDerivative = t) = Differentiation.MultipleDerivativeAnnotation2.dfcx,derivative(zeroDerivative = y,noDerivative = t) = Differentiation.MultipleDerivativeAnnotation2.dfcy,derivative(order = 1,noDerivative = t) = Differentiation.MultipleDerivativeAnnotation2.df,Inline = false);
 end Differentiation.MultipleDerivativeAnnotation2.f;

 function Differentiation.MultipleDerivativeAnnotation2.dfcxy
  input Real x;
  input Real y;
  input Real t;
  output Real dz;
 algorithm
  dz := 0;
  return;
 annotation(Inline = false);
 end Differentiation.MultipleDerivativeAnnotation2.dfcxy;

 function Differentiation.MultipleDerivativeAnnotation2.dfcx
  input Real x;
  input Real y;
  input Real t;
  input Real dy;
  output Real dz;
 algorithm
  dz := dy;
  return;
 annotation(Inline = false);
 end Differentiation.MultipleDerivativeAnnotation2.dfcx;

 function Differentiation.MultipleDerivativeAnnotation2.dfcy
  input Real x;
  input Real y;
  input Real t;
  input Real dx;
  output Real dz;
 algorithm
  dz := dx;
  return;
 annotation(Inline = false);
 end Differentiation.MultipleDerivativeAnnotation2.dfcy;

 function Differentiation.MultipleDerivativeAnnotation2.df
  input Real x;
  input Real y;
  input Real t;
  input Real dx;
  input Real dy;
  output Real dz;
 algorithm
  dz := dx + dy;
  return;
 annotation(Inline = false);
 end Differentiation.MultipleDerivativeAnnotation2.df;

end Differentiation.MultipleDerivativeAnnotation2;
")})));
end MultipleDerivativeAnnotation2;

end Differentiation;
