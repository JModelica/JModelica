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


package ScalarizeCompositeStatementTests
    model RecordStmt1
        record R
            Real x;
        end R;
        
        function f
            input R r;
            constant R c(x=1);
            output R[:] y = {c, r};
        algorithm
            annotation(Inline=false);
        end f;
        
        R[:] r = f(R(time));

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="RecordStmt1",
            description="",
            flatModel="
fclass ScalarizeCompositeStatementTests.RecordStmt1
 Real r[1].x;
 Real r[2].x;
global variables
 constant ScalarizeCompositeStatementTests.RecordStmt1.R ScalarizeCompositeStatementTests.RecordStmt1.f.c = ScalarizeCompositeStatementTests.RecordStmt1.R(1);
equation
 ({ScalarizeCompositeStatementTests.RecordStmt1.R(r[1].x), ScalarizeCompositeStatementTests.RecordStmt1.R(r[2].x)}) = ScalarizeCompositeStatementTests.RecordStmt1.f(ScalarizeCompositeStatementTests.RecordStmt1.R(time));

public
 function ScalarizeCompositeStatementTests.RecordStmt1.f
  input ScalarizeCompositeStatementTests.RecordStmt1.R r;
  output ScalarizeCompositeStatementTests.RecordStmt1.R[:] y;
  ScalarizeCompositeStatementTests.RecordStmt1.R[:] temp_1;
 algorithm
  init y as ScalarizeCompositeStatementTests.RecordStmt1.R[2];
  init temp_1 as ScalarizeCompositeStatementTests.RecordStmt1.R[2];
  temp_1[1] := global(ScalarizeCompositeStatementTests.RecordStmt1.f.c);
  temp_1[2] := r;
  for i1 in 1:2 loop
   y[i1].x := temp_1[i1].x;
  end for;
  return;
 annotation(Inline = false);
 end ScalarizeCompositeStatementTests.RecordStmt1.f;

 record ScalarizeCompositeStatementTests.RecordStmt1.R
  Real x;
 end ScalarizeCompositeStatementTests.RecordStmt1.R;

end ScalarizeCompositeStatementTests.RecordStmt1;
")})));
    end RecordStmt1;
end ScalarizeCompositeStatementTests;
