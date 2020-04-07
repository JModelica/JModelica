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

package AliasEliminationNegatedTests

model NegatedAssign1
    Real y = -x;
protected
    Real x;
algorithm
    x := time;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NegatedAssign1",
            description="",
            flatModel="
fclass AliasEliminationNegatedTests.NegatedAssign1
 Real y;
algorithm
 y := - time;
end AliasEliminationNegatedTests.NegatedAssign1;
")})));
end NegatedAssign1;

end AliasEliminationNegatedTests;
