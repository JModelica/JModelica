/*
    Copyright (C) 2009-2018 Modelon AB

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

package FlattenTypeTests

    model FlattenArrayWithRecordConstructor
        model M
            record R1
            end R1;
            
            record R2
                extends R1;
            end R2;
            
            R1 r = R2();
        end M;
        
        M[2] m;
        
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="RecordFlat1",
            description="Records: basic flattening test",
            variability_propagation=false,
            flatModel="
fclass FlattenTypeTests.FlattenArrayWithRecordConstructor
 constant FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R1 m[1].r = FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R2();
 constant FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R1 m[2].r = FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R2();

public
 record FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R1
 end FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R1;

 record FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R2
 end FlattenTypeTests.FlattenArrayWithRecordConstructor.m.m.R2;

end FlattenTypeTests.FlattenArrayWithRecordConstructor;
")})));
    end FlattenArrayWithRecordConstructor;

end FlattenTypeTests;
