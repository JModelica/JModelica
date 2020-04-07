/*
    Copyright (C) 2019 Modelon AB

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


package FunctionInliningTemporaries
    
    model BasicInlineTemp1
        function f
            input Real[:] a;
            Real b;
            Real c;
            output Real d;
        algorithm
            b := product(a);
            c := b * b;
            d := c * c;
        end f;
        
        Real y1;
    equation
        (y1) = f({time + 1, time + 2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="BasicInlineTemp1",
            description="Inline functions with temporaries",
            inline_functions="all",
            flatModel="
fclass FunctionInliningTemporaries.BasicInlineTemp1
 Real y1;
 Real temp_7;
equation
 temp_7 = (time + 1) * (time + 2);
 y1 = temp_7 * temp_7 * (temp_7 * temp_7);
end FunctionInliningTemporaries.BasicInlineTemp1;
")})));
    end BasicInlineTemp1;
       
    model BasicInlineTempTrivial1
        function f
            input Real[:] a;
            output Real[:] d = {i^2 for i in 1:size(a,1)} .* a;
        algorithm
        end f;
        
        Real[:] y1 = f({time + 1, time + 2});

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="BasicInlineTempTrivial1",
            description="Inline functions with temporaries",
            inline_functions="trivial",
            flatModel="
fclass FunctionInliningTemporaries.BasicInlineTempTrivial1
 Real y1[1];
 Real y1[2];
equation
 y1[1] = time + 1;
 y1[2] = 4.0 .* (time + 2);
end FunctionInliningTemporaries.BasicInlineTempTrivial1;
")})));
    end BasicInlineTempTrivial1;
    
    model InlineNestedRecords1
        record R1
            Real[1] x;
        end R1;
        
        record R2
            R1 r;
            Real x;
        end R2;
        
        record R3
            R2 r;
        end R3;
        
        function g
            input R3 x;
            output R3 y = x;
        algorithm
        end g;
        
        function f
            input R3 r;
            R3 c(r(r(x={1})));
            output R3[:] y = {c, r};
            output R3 y2 = g(r);
        algorithm
            annotation(Inline=true);
        end f;
        
        R3[2] r;
        R3 y2;
    equation
        (r,y2) = f(R3(R2(R1({time}),0)));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InlineNestedRecords1",
            description="Tricky cases with nested records",
            variability_propagation=false,
            eliminate_alias_variables=false,
            flatModel="
fclass FunctionInliningTemporaries.InlineNestedRecords1
 Real r[1].r.r.x[1];
 Real r[1].r.x;
 Real r[2].r.r.x[1];
 Real r[2].r.x;
 Real y2.r.r.x[1];
 Real y2.r.x;
 Real temp_3;
equation
 temp_3 = time;
 r[1].r.r.x[1] = 1;
 r[1].r.x = 0.0;
 r[2].r.r.x[1] = temp_3;
 r[2].r.x = 0;
 y2.r.r.x[1] = temp_3;
 y2.r.x = 0;
end FunctionInliningTemporaries.InlineNestedRecords1;
")})));
    end InlineNestedRecords1;
end FunctionInliningTemporaries;
