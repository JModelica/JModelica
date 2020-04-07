/*
	Copyright (C) 2018 Modelon AB

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

package SanityCheckTests
    model NoOutputs1
        function f
            input Real x;
        algorithm
            assert(x>0, "");
        end f;
    equation
        f(time);
        assert(time>0, "");
        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="NoOutputs1",
                description="Test that sanity check does not trigger on function calls without outputs",
                debug_sanity_check=true,
                flatModel="
fclass SanityCheckTests.NoOutputs1
equation
 SanityCheckTests.NoOutputs1.f(time);
 assert(time > 0, \"\");

public
 function SanityCheckTests.NoOutputs1.f
  input Real x;
 algorithm
  assert(x > 0, \"\");
  return;
 end SanityCheckTests.NoOutputs1.f;

end SanityCheckTests.NoOutputs1;
    ")})));
      end NoOutputs1;
end SanityCheckTests;
