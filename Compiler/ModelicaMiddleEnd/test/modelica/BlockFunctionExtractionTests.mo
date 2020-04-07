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

package BlockFunctionExtractionTests

model ExtractFunctionCall
  Real a, b;
equation
  a + b = f(time);
  a * b = 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExtractFunctionCall",
            description="Tests the extraction of functions from blocks.",
			enable_block_function_extraction=true,
            flatModel="
fclass BlockFunctionExtractionTests.ExtractFunctionCall
 Real a;
 Real b;
 Real temp_1;
equation
 a + b = temp_1;
 a * b = 2;
 temp_1 = BlockFunctionExtractionTests.f(time);

public
 function BlockFunctionExtractionTests.f
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1 + 1;
  return;
 annotation(Inline = false);
 end BlockFunctionExtractionTests.f;

end BlockFunctionExtractionTests.ExtractFunctionCall;
")})));
end ExtractFunctionCall;

model ExtractFunctionCallLexicalDiff
  Real a, b;
equation
  a + b = f(time+1) + f(1+time);
  a * b = 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExtractFunctionCallLexicalDiff",
            description="Shows that the optimization doesn't recognize that the lexically different function calls are equivalent",
            enable_block_function_extraction=true,
            flatModel="
fclass BlockFunctionExtractionTests.ExtractFunctionCallLexicalDiff
 Real a;
 Real b;
 Real temp_1;
 Real temp_2;
equation
 a + b = temp_1 + temp_2;
 a * b = 2;
 temp_1 = BlockFunctionExtractionTests.f(time + 1);
 temp_2 = BlockFunctionExtractionTests.f(1 + time);

public
 function BlockFunctionExtractionTests.f
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1 + 1;
  return;
 annotation(Inline = false);
 end BlockFunctionExtractionTests.f;

end BlockFunctionExtractionTests.ExtractFunctionCallLexicalDiff;
")})));
end ExtractFunctionCallLexicalDiff;

model ExtractHeavyFunctionCall
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
  parameter Real p = 0;
  parameter Integer Lcount = 1000000;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  LoopingFunction(u0, Lcount, L, p) = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExtractHeavyFunctionCall",
            description="Extract a heavy function call from block (the C-code cannot be optimized).",
			enable_block_function_extraction=true,
            flatModel="
fclass BlockFunctionExtractionTests.ExtractHeavyFunctionCall
 Real u0;
 Real u1;
 Real u2;
 Real uL;
 Real i0;
 Real i1;
 Real i2;
 Real i3;
 Real iL;
 parameter Real R1 = 1 /* 1 */;
 parameter Real R2 = 1 /* 1 */;
 parameter Real R3 = 1 /* 1 */;
 parameter Real L = 1 /* 1 */;
 parameter Real p = 0 /* 0 */;
 parameter Integer Lcount = 1000000 /* 1000000 */;
 Real temp_1;
initial equation 
 iL = 0.0;
equation
 u0 = sin(time);
 u1 = R1 * i1;
 u2 = R2 * i2;
 u2 = R3 * i3;
 uL = L * der(iL);
 temp_1 = u1 + u2;
 uL = u1 + u2;
 i0 = i1 + iL;
 i1 = i2 + i3;
 temp_1 = BlockFunctionExtractionTests.LoopingFunction(u0, Lcount, L, p);

public
 function BlockFunctionExtractionTests.LoopingFunction
  input Real invar;
  input Integer count;
  input Real num;
  input Real p;
  output Real fac;
 algorithm
  fac := invar;
  for i in 1:count loop
   fac := fac * num + i * p;
  end for;
  return;
 end BlockFunctionExtractionTests.LoopingFunction;

end BlockFunctionExtractionTests.ExtractHeavyFunctionCall;
")})));
end ExtractHeavyFunctionCall;

function LoopingFunction
  input Real invar;
  input Integer count;
  input Real num;
  input Real p;
  output Real fac;
algorithm
  fac := invar;
  for i in 1:count loop
    fac := fac * num + i * p;
  end for;
end LoopingFunction;

function f
  input Real i1;
  output Real o1;
algorithm
  o1 := i1 + 1;
  
    annotation(Inline=false);
end f;

end BlockFunctionExtractionTests;
