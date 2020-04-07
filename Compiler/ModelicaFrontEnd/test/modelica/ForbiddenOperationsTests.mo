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


package ForbiddenOperationsTests


/* ================ Algorithms =============== */

function WhenInFunction_Func
 input Real i1;
 output Real o1 = 1.0;
algorithm
 when i1 > 1.0 then
  o1 := 2.0;
 end when;
end WhenInFunction_Func;

model WhenInFunction
 Real x = WhenInFunction_Func(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenInFunction",
            description="Content checks in algorithms: when in function",
            errorMessage="
1 errors found:

Error at line -4, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  When statements are not allowed in functions
")})));
end WhenInFunction;

model WhenInBlocks1
 Real x;
algorithm
 if x < 1 then
  when x < 0.5 then
   x := 0.8;
  end when;
 end if;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenInBlocks1",
            description="Content checks in algorithms: when inside if clause",
            errorMessage="
1 errors found:

Error at line 5, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  When statements are not allowed inside if, for, while and when clauses
")})));
end WhenInBlocks1;

model WhenInBlocks2
 Real x;
algorithm
 when x < 1 then
  when x < 0.5 then
   x := 0.8;
  end when;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenInBlocks2",
            description="Content checks in algorithms: when inside when clause",
            errorMessage="
1 errors found:

Error at line 5, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  When statements are not allowed inside if, for, while and when clauses
")})));
end WhenInBlocks2;

model WhenInBlocks3
 Real x;
algorithm
 while x < 1 loop
  when x < 0.5 then
   x := 0.8;
  end when;
 end while;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenInBlocks3",
            description="Content checks in algorithms: when inside while clause",
            errorMessage="
1 errors found:

Error at line 5, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  When statements are not allowed inside if, for, while and when clauses
")})));
end WhenInBlocks3;

model WhenInBlocks4
 Real x;
algorithm
 for i in 1:3 loop
  when x < 0.5 then
   x := 0.8;
  end when;
 end for;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenInBlocks4",
            description="Content checks in algorithms: when inside for clause",
            errorMessage="
1 errors found:

Error at line 5, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  When statements are not allowed inside if, for, while and when clauses
")})));
end WhenInBlocks4;

model WhenInInitial
 Real x,y;
initial algorithm
 when time > 1 then
	 x := 1;
 end when;
initial equation
 when time > 1 then
	 y = 1;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenInInitial",
            description="When in initial equation",
            errorMessage="
2 errors found:

Error at line 4, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  When statements are not allowed in initial algorithms

Error at line 8, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  When equations are not allowed in initial equation sections
")})));
end WhenInInitial;

model ReturnOutsideFunction
algorithm
 return;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ReturnOutsideFunction",
            description="Content checks in algorithms: return outside function",
            errorMessage="
1 errors found:

Error at line 3, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  Return statements are only allowed in functions
")})));
end ReturnOutsideFunction;

model IfEquTest_ComplErr
 Real x;
 Boolean y = true;
equation
 if y then
   x=3;
 else
   x=5;
 end if;


    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="IfEquTest_ComplErr",
            description="",
            generate_ode=false,
            generate_dae=true,
            errorMessage="
1 errors found:

Compliance error at line 3, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo', ONLY_FMU_BOOLEAN_VARIABLES:
  Boolean variables of discrete variability is currently only supported when compiling FMUs
")})));
end IfEquTest_ComplErr;



model WhenContents1
	Real x;
	Real y;
equation
	x = y + 1;
	when time > 1 then
		x + y = 3;
		x = 2;
	end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenContents1",
            description="Check contents of when clauses",
            errorMessage="
1 errors found:

Error at line 7, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  Only assignment equations are allowed in when clauses
")})));
end WhenContents1;


model WhenContents2
	Real x;
	Real y;
equation
	when time > 1 then
		x = 3;
	elsewhen time > 2 then
		x = 3;
		y = 3;
	end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenContents2",
            description="Check contents of when clauses",
            errorMessage="
1 errors found:

Error at line 5, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  All branches in when equation must assign the same variables
")})));
end WhenContents2;


model WhenContents3
	Real x;
	Real y;
equation
	when time > 1 then
		x = 3;
	elsewhen time > 2 then
		if y < 2 then
			x = 3;
		else
			y = 3;
		end if;
	end when;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="WhenContents3",
            description="Check contents of when clauses",
            errorMessage="
1 errors found:

Error at line 8, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  All branches in if equation with non-parameter tests within when equation must assign the same variables
")})));
end WhenContents3;


model LongIntConst1
    Real x = 1000000000000;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="LongIntConst1",
			description="",
			flatModel="
fclass ForbiddenOperationsTests.LongIntConst1
 constant Real x = 1.0E12;

end ForbiddenOperationsTests.LongIntConst1;
")})));
end LongIntConst1;


model LongIntConst2
    Real x = 1000000000000;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="LongIntConst2",
            description="",
            errorMessage="
1 errors found:

Warning at line 2, column 14, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  Integer literal \"1000000000000\" is too large to represent as 32-bit Integer, using Real instead.
")})));
end LongIntConst2;


model TerminateInFunc
	function f
		output Real x;
	algorithm
		terminate("");
		x := 1;
	end f;
	
	Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="TerminateInFunc",
            description="",
            errorMessage="
1 errors found:

Error at line 5, column 3, in file 'Compiler/ModelicaFrontEnd/test/modelica/ForbiddenOperationsTests.mo':
  The terminate() statement is not allowed in functions
")})));
end TerminateInFunc;



end ForbiddenOperationsTests;
