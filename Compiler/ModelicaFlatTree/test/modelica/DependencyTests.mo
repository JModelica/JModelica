/*
	Copyright (C) 2009-2015 Modelon AB

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

package DependencyTests

package Direct

model Basic1
    input Real x;
    output Real y = x;
    input Real a;
    output Real b = a + y;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Direct_Basic1",
            description="Testing direct dependencies. Basic.",
            methodName="directDependencyDiagnostics",
            methodResult="
y
    x
b
    a
    x
")})));
  end Basic1;
  
model Basic2
    input Real x;
    output Real y = x + a;
    input Real a;
    output Real b = y;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Direct_Basic2",
            description="Testing direct dependencies. Basic.",
            methodName="directDependencyDiagnostics",
            methodResult="
y
    x
    a
b
    x
    a
")})));
  end Basic2;
  
model Basic3
    input Real x;
    output Real y;
    Real a,b,c;
  equation
    y = a + 1;
    a = b + 1;
    b = c + 1;
    c = x + 1;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Direct_Basic3",
            description="Testing direct dependencies. Basic.",
            methodName="directDependencyDiagnostics",
            methodResult="
y
    x
")})));
end Basic3;
  
model Function1
    function f
        input Real x1;
        input Real x2;
        output Real y1 = x1;
        output Real y2 = x2;
        output Real y3 = y1 + y2;
      algorithm
    end f;
    
    input Real x1,x2;
    output Real y1,y2,y3;
  equation
    (y1,y2,y3) = f(x1,x2);
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Direct_Function1",
            description="Testing direct dependencies. Through function.",
            inline_functions="none",
            methodName="directDependencyDiagnostics",
            methodResult="
y1
    x1
    x2
y2
    x1
    x2
y3
    x1
    x2
")})));
end Function1;

model Algorithm1
    input Real x1,x2;
    output Real y1,y2,y3;
  algorithm
    y1 := x1;
    y2 := x2;
    y3 := y1 + y2;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Direct_Algorithm1",
            description="Testing direct dependencies. Through algorithm.",
            methodName="directDependencyDiagnostics",
            methodResult="
y1
    x1
    x2
y2
    x1
    x2
y3
    x1
    x2
")})));
end Algorithm1;

model Block1
    input Real x1,x2;
    Real a,b;
    output Real y1,y2,y3;
  equation
    x1 = a;
    x2 = b;
    y1 = y2 + sin(a);
    y2 = y1 + b;
    y3 = y1 + y2;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Direct_Block1",
            description="Testing direct dependencies. Through equation block.",
            methodName="directDependencyDiagnostics",
            methodResult="
y1
    x2
    x1
y2
    x2
    x1
y3
    x2
    x1
")})));
end Block1;

model Initial1
    input Real x1;
    output Real y1;
  initial equation
    y1 = x1;
  equation
    when time > 1 then
        y1 = 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Direct_Initial1",
            description="Testing direct dependencies. In initial system.",
            methodName="directDependencyDiagnostics",
            methodResult="
y1
")})));
end Initial1;

end Direct;

end DependencyTests;
