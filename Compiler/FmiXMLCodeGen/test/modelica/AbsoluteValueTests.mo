/*
    Copyright (C) 2014 Modelon AB

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

package AbsoluteValueTests

model Fmi1AbsoluteValue1
    Real a = time;
    Real b = time annotation(absoluteValue=true);
    Real c = time annotation(absoluteValue=false);
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1AbsoluteValue1",
            description="FMI 1.0 absoluteValue",
            fmi_version="1.0",
            eliminate_alias_variables=false,
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"b\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"c\" valueReference=\"2\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"true\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1AbsoluteValue1;

model Fmi2AbsoluteValue1
    Real a = time;
    Real b = time annotation(absoluteValue=true);
    Real c = time annotation(absoluteValue=false);
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2AbsoluteValue1",
            description="FMI 2.0 absoluteValue",
            fmi_version="2.0",
            eliminate_alias_variables=false,
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"b\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"c\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"true\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi2AbsoluteValue1;

model AbsoluteValue1
    Real a = time;
    Real b = time annotation(absoluteValue=true);
    Real c = time annotation(absoluteValue=false);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValue1",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass AbsoluteValueTests.AbsoluteValue1
 Real a;
 Real b;
 Real c annotation(absoluteValue = false);
equation
 a = time;
 b = a;
 c = a;
end AbsoluteValueTests.AbsoluteValue1;
")})));
end AbsoluteValue1;

model AbsoluteValue2
    type T = Real annotation(absoluteValue=false);
    T a = time;
    T b = time annotation(absoluteValue=true);
    T c = time annotation(absoluteValue=false);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValue2",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass AbsoluteValueTests.AbsoluteValue2
 Real a annotation(absoluteValue = false);
 Real b;
 Real c annotation(absoluteValue = false);
equation
 a = time;
 b = a;
 c = a;
end AbsoluteValueTests.AbsoluteValue2;
")})));
end AbsoluteValue2;

model AbsoluteValue3
    type T1 = Real annotation(absoluteValue=false);
    type T2 = T1   annotation(absoluteValue=true);
    T2 a = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValue3",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass AbsoluteValueTests.AbsoluteValue3
 Real a;
equation
 a = time;
end AbsoluteValueTests.AbsoluteValue3;
")})));
end AbsoluteValue3;

model AbsoluteValue4
    type T1 = Real annotation(absoluteValue=true);
    type T2 = T1   annotation(absoluteValue=false);
    T2 a = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValue4",
            description="",
            flatModel="
fclass AbsoluteValueTests.AbsoluteValue4
 Real a annotation(absoluteValue = false);
equation
 a = time;
end AbsoluteValueTests.AbsoluteValue4;
")})));
end AbsoluteValue4;

model AbsoluteValue5
    type T1 = Real annotation(absoluteValue=false);
    type T2 = T1;
    T2 a = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValue5",
            description="",
            flatModel="
fclass AbsoluteValueTests.AbsoluteValue5
 Real a annotation(absoluteValue = false);
equation
 a = time;
end AbsoluteValueTests.AbsoluteValue5;
")})));
end AbsoluteValue5;

model AbsoluteValue6
    type T1 = Real annotation(absoluteValue=1);
    T1 a = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValue6",
            description="Calculation with erroneous annotation",
            flatModel="
fclass AbsoluteValueTests.AbsoluteValue6
 Real a;
equation
 a = time;
end AbsoluteValueTests.AbsoluteValue6;
")})));
end AbsoluteValue6;

model AbsoluteValueArray1
    Real[:] y = {time,time} annotation(absoluteValue=false);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValueArray1",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass AbsoluteValueTests.AbsoluteValueArray1
 Real y[1] annotation(absoluteValue = false);
 Real y[2] annotation(absoluteValue = false);
equation
 y[1] = time;
 y[2] = y[1];
end AbsoluteValueTests.AbsoluteValueArray1;
")})));
end AbsoluteValueArray1;

model AbsoluteValueRecord1
    type T1 = Real annotation(absoluteValue=false);
    record R
        T1 x;
        Real y annotation(absoluteValue=false);
    end R;
    
    R r = R(time,time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AbsoluteValueRecord1",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass AbsoluteValueTests.AbsoluteValueRecord1
 Real r.x annotation(absoluteValue = false);
 Real r.y annotation(absoluteValue = false);
equation
 r.x = time;
 r.y = r.x;
end AbsoluteValueTests.AbsoluteValueRecord1;
")})));
end AbsoluteValueRecord1;

model AbsoluteValueError1
    constant Boolean b = false;
    annotation(absoluteValue=b, __JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AbsoluteValueError1",
            description="",
            errorMessage="
Error at line 3, column 16, in file '...', ABSOLUTE_VALUE:
  absoluteValue annotation only allows scalar boolean literal values 'true' or 'false'

Error at line 3, column 16, in file '...', ABSOLUTE_VALUE_LOCATION:
  absoluteValue annotation only allowed on simple types or components of simple types
")})));
end AbsoluteValueError1;

model AbsoluteValueError2
    type T = Real   annotation(absoluteValue=1); // Should give error but only top level classes are error checked
    T a[:] = {time} annotation(absoluteValue={true});
    T b    = time   annotation(absoluteValue=1);
    

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="AbsoluteValueError2",
            description="",
            errorMessage="
Error at line 3, column 32, in file '...', ABSOLUTE_VALUE:
  absoluteValue annotation only allows scalar boolean literal values 'true' or 'false'

Error at line 4, column 32, in file '...', ABSOLUTE_VALUE:
  absoluteValue annotation only allows scalar boolean literal values 'true' or 'false'
")})));
end AbsoluteValueError2;

end AbsoluteValueTests;
