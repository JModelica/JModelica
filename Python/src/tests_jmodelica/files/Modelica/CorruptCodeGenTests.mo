/*
    Copyright (C) 2009 Modelon AB

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

package CorruptCodeGenTests

	model CorruptTest1
    equation
       der(x) =1;
	   
	annotation(__JModelica(UnitTesting(tests={
		GenericCodeGenTestCase(
			name="CorruptTest1",
			description="Test of code generation",
			template="$n_real_x$",
			generatedCode="
1")})));
	end CorruptTest1;


end CorruptCodeGenTests;