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


package ScalarizeGlobalAccess
    model ScalarizeGlobalAccess1
        package P
            constant Real[2] c = 1:2;
        end P;
        
        function f
            input Real[:] x = P.c;
            output Real y = sum(x);
        algorithm
            annotation(Inline=false);
        end f;
        
        Real y1 = f();

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ScalarizeGlobalAccess1",
            description="",
            variability_propagation=false,
            flatModel="
fclass ScalarizeGlobalAccess.ScalarizeGlobalAccess1
 Real y1;
global variables
 constant Real ScalarizeGlobalAccess.ScalarizeGlobalAccess1.P.c[2] = {1, 2};
equation
 y1 = ScalarizeGlobalAccess.ScalarizeGlobalAccess1.f({global(ScalarizeGlobalAccess.ScalarizeGlobalAccess1.P.c[1]), global(ScalarizeGlobalAccess.ScalarizeGlobalAccess1.P.c[2])});

public
 function ScalarizeGlobalAccess.ScalarizeGlobalAccess1.f
  input Real[:] x;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(x, 1) loop
   temp_1 := temp_1 + x[i1];
  end for;
  y := temp_1;
  return;
 annotation(Inline = false);
 end ScalarizeGlobalAccess.ScalarizeGlobalAccess1.f;

end ScalarizeGlobalAccess.ScalarizeGlobalAccess1;
")})));
    end ScalarizeGlobalAccess1;
end ScalarizeGlobalAccess1;
