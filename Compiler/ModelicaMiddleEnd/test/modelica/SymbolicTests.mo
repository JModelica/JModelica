/*
    Copyright (C) 2013 Modelon AB

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
package SymbolicTests

model EquivalentIfBranch1
    type E = enumeration(E1,E2);
    Real x1 = if time > 1 then 2.0 else 2.0;
    Integer x2 = if time > 1 then 2 else 2;
    Boolean x3 = if time > 1 then true else true;
    String x4 = if time > 1 then "str" else "str";
    E x5 = if time > 1 then E.E2 else E.E2;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch1",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch1
 Real x1 = 2.0;
 discrete Integer x2 = 2;
 discrete Boolean x3 = true;
 discrete String x4 = \"str\";
 discrete SymbolicTests.EquivalentIfBranch1.E x5 = SymbolicTests.EquivalentIfBranch1.E.E2;

public
 type SymbolicTests.EquivalentIfBranch1.E = enumeration(E1, E2);

end SymbolicTests.EquivalentIfBranch1;

")})));
end EquivalentIfBranch1;

model EquivalentIfBranch2
    Real x = time;
    Real y = if x > 1 then x else x;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch2",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch2
 Real x = time;
 Real y = x;
end SymbolicTests.EquivalentIfBranch2;
")})));
end EquivalentIfBranch2;

model EquivalentIfBranch3
    Real x = time;
    Real y = if x > 1 then x elseif time > 2 then x else x;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch3",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch3
 Real x = time;
 Real y = x;
end SymbolicTests.EquivalentIfBranch3;
")})));
end EquivalentIfBranch3;

model EquivalentIfBranch4
    Real x[2] = {1,2};
    Real y = if time > 1 then x[1] else x[2];
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch4",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch4
 Real x[2] = {1, 2};
 Real y = if time > 1 then x[1] else x[2];
end SymbolicTests.EquivalentIfBranch4;
")})));
end EquivalentIfBranch4;

model EquivalentIfBranch5
    Real x = if time > 1 then 0.0 else 0;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch5",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch5
 Real x = 0.0;
end SymbolicTests.EquivalentIfBranch5;
")})));
end EquivalentIfBranch5;

model EquivalentIfBranch6
    Real x = if time > 1 then y - z else y - z;
    Real y = time;
    Real z = sin(time);
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch6",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch6
 Real x = y - z;
 Real y = time;
 Real z = sin(time);
end SymbolicTests.EquivalentIfBranch6;
")})));
end EquivalentIfBranch6;

model SimplifyNegations1
    Real x, y(start = 1), z(start = 0);
equation
    x = -(y + z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations1",
            description="Simplification of negation of addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations1
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = - y - z;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations1;
")})));
end SimplifyNegations1;


model SimplifyNegations2
    Real x, y(start = 1), z(start = 0);
equation
    x = -(-y + z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations2",
            description="Simplification of negation of addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations2
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = y - z;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations2;
")})));
end SimplifyNegations2;


model SimplifyNegations3
    Real x, y(start = 1), z(start = 0);
equation
    x = -(y - z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations3",
            description="Simplification of negation of addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations3
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = z - y;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations3;
")})));
end SimplifyNegations3;


model SimplifyNegations4
    Real x, y(start = 1), z(start = 0);
equation
    x = -(-y - z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations4",
            description="Simplification of negation of addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations4
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = z + y;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations4;
")})));
end SimplifyNegations4;


model SimplifyNegations5
    Real x, y(start = 1), z(start = 0);
equation
    x = -1 * (y + z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations5",
            description="Simplification of literal minus one multiplied by addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations5
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = - y - z;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations5;
")})));
end SimplifyNegations5;


model SimplifyNegations6
    Real x, y(start = 1), z(start = 0);
equation
    x = -1 * (-y + z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations6",
            description="Simplification of literal minus one multiplied by addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations6
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = y - z;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations6;
")})));
end SimplifyNegations6;


model SimplifyNegations7
    Real x, y(start = 1), z(start = 0);
equation
    x = -1 * (y - z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations7",
            description="Simplification of literal minus one multiplied by addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations7
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = z - y;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations7;
")})));
end SimplifyNegations7;


model SimplifyNegations8
    Real x, y(start = 1), z(start = 0);
equation
    x = -1 * (-y - z);
    der(y) = z - time;
    der(z) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations8",
            description="Simplification of literal minus one multiplied by addition or subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations8
 Real x;
 Real y(start = 1);
 Real z(start = 0);
initial equation 
 y = 1;
 z = 0;
equation
 x = z + y;
 der(y) = z - time;
 der(z) = 3;
end SymbolicTests.SimplifyNegations8;
")})));
end SimplifyNegations8;


model SimplifyNegations9
    Real x, y(start = 0);
equation
    x = -1 * -(y * 2);
    der(y) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations9",
            description="Simplifying negated expression multiplied or divided by literal minus one",
            flatModel="
fclass SymbolicTests.SimplifyNegations9
 Real x;
 Real y(start = 0);
initial equation 
 y = 0;
equation
 x = y * 2;
 der(y) = 3;
end SymbolicTests.SimplifyNegations9;
")})));
end SimplifyNegations9;


model SimplifyNegations10
    Real x, y(start = 0);
equation
    x = -(y * 2) * -1;
    der(y) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations10",
            description="Simplifying negated expression multiplied or divided by literal minus one",
            flatModel="
fclass SymbolicTests.SimplifyNegations10
 Real x;
 Real y(start = 0);
initial equation 
 y = 0;
equation
 x = y * 2;
 der(y) = 3;
end SymbolicTests.SimplifyNegations10;
")})));
end SimplifyNegations10;


model SimplifyNegations11
    Real x, y(start = 0);
equation
    x = -(y * 2) / -1;
    der(y) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations11",
            description="Simplifying negated expression multiplied or divided by literal minus one",
            flatModel="
fclass SymbolicTests.SimplifyNegations11
 Real x;
 Real y(start = 0);
initial equation 
 y = 0;
equation
 x = y * 2;
 der(y) = 3;
end SymbolicTests.SimplifyNegations11;
")})));
end SimplifyNegations11;


model SimplifyNegations12
    Real x, y(start = 0);
equation
    x = -(y .+ 1);
    der(y) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations12",
            description="Simplifying negation of dotted addition",
            flatModel="
fclass SymbolicTests.SimplifyNegations12
 Real x;
 Real y(start = 0);
initial equation 
 y = 0;
equation
 x = - y .- 1;
 der(y) = 3;
end SymbolicTests.SimplifyNegations12;
")})));
end SimplifyNegations12;


model SimplifyNegations13
    Real x, y(start = 0);
equation
    x = -(y .- 1);
    der(y) = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SimplifyNegations13",
            description="Simplifying negation of dotted subtraction",
            flatModel="
fclass SymbolicTests.SimplifyNegations13
 Real x;
 Real y(start = 0);
initial equation 
 y = 0;
equation
 x = 1 .- y;
 der(y) = 3;
end SymbolicTests.SimplifyNegations13;
")})));
end SimplifyNegations13;

end SymbolicTests;
