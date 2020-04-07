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

package FmiXMLTests

model DisplayUnit1
    type A = Real(unit="N", displayUnit="kN");
    A a = time;
    Real b(unit="J", displayUnit="kW.h") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit1",
            description="Check that offset & gain are not generated incorrectly for units",
            fmi_version="1.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <BaseUnit unit=\"N\">
        <DisplayUnitDefinition displayUnit=\"kN\" gain=\"0.001\" />
    </BaseUnit>
    <BaseUnit unit=\"J\">
        <DisplayUnitDefinition displayUnit=\"kW.h\" gain=\"2.7777777777777776E-7\" />
    </BaseUnit>
</UnitDefinitions>
")})));
end DisplayUnit1;

model DisplayUnit2
    type A = Real(unit="N", displayUnit="kN");
    A a = time;
    Real b(unit="J") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit2",
            description="Check that base units without display units are generated",
            fmi_version="1.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <BaseUnit unit=\"N\">
        <DisplayUnitDefinition displayUnit=\"kN\" gain=\"0.001\" />
    </BaseUnit>
    <BaseUnit unit=\"J\">
    </BaseUnit>
</UnitDefinitions>
")})));
end DisplayUnit2;

model DisplayUnit3
    type A = Real(unit="N", displayUnit="kN");
    A a = time;
    Real b(unit="J", displayUnit="kW.h") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit3",
            description="Check that offset & gain are not generated incorrectly for units",
            fmi_version="2.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <Unit name=\"N\">
        <BaseUnit m=\"1\" s=\"-2\" kg=\"1\" />
        <DisplayUnit name=\"kN\" factor=\"0.001\" />
    </Unit>
    <Unit name=\"J\">
        <BaseUnit m=\"2\" s=\"-2\" kg=\"1\" />
        <DisplayUnit name=\"kW.h\" factor=\"2.7777777777777776E-7\" />
    </Unit>
</UnitDefinitions>
")})));
end DisplayUnit3;

model DisplayUnit4
    type A = Real(unit="N", displayUnit="kN");
    A a = time;
    Real b(unit="J") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit4",
            description="Check that base units without display units are generated",
            fmi_version="2.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <Unit name=\"N\">
        <BaseUnit m=\"1\" s=\"-2\" kg=\"1\" />
        <DisplayUnit name=\"kN\" factor=\"0.001\" />
    </Unit>
    <Unit name=\"J\">
        <BaseUnit m=\"2\" s=\"-2\" kg=\"1\" />
    </Unit>
</UnitDefinitions>
")})));
end DisplayUnit4;

model DisplayUnit5
    type A = Real(unit="N", displayUnit="kN");
    type B = Real(unit="N", displayUnit="mN");
    A a = time;
    B b = time;
    Real c(unit="J", displayUnit="kW.h") = 2 * time;
    Real d(unit="J", displayUnit="W.h") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit5",
            description="Two display unit with same base unit.",
            fmi_version="1.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <BaseUnit unit=\"N\">
        <DisplayUnitDefinition displayUnit=\"mN\" gain=\"1000.0\" />
        <DisplayUnitDefinition displayUnit=\"kN\" gain=\"0.001\" />
    </BaseUnit>
    <BaseUnit unit=\"J\">
        <DisplayUnitDefinition displayUnit=\"kW.h\" gain=\"2.7777777777777776E-7\" />
        <DisplayUnitDefinition displayUnit=\"W.h\" gain=\"2.777777777777778E-4\" />
    </BaseUnit>
</UnitDefinitions>
")})));
end DisplayUnit5;

model DisplayUnit6
    type A = Real(unit="N", displayUnit="kN");
    type B = Real(unit="N", displayUnit="mN");
    A a = time;
    B b = time;
    Real c(unit="J", displayUnit="kW.h") = 2 * time;
    Real d(unit="J", displayUnit="W.h") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit6",
            description="Two display unit with same base unit.",
            fmi_version="2.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <Unit name=\"N\">
        <BaseUnit m=\"1\" s=\"-2\" kg=\"1\" />
        <DisplayUnit name=\"mN\" factor=\"1000.0\" />
        <DisplayUnit name=\"kN\" factor=\"0.001\" />
    </Unit>
    <Unit name=\"J\">
        <BaseUnit m=\"2\" s=\"-2\" kg=\"1\" />
        <DisplayUnit name=\"kW.h\" factor=\"2.7777777777777776E-7\" />
        <DisplayUnit name=\"W.h\" factor=\"2.777777777777778E-4\" />
    </Unit>
</UnitDefinitions>
")})));
end DisplayUnit6;

model DisplayUnit7
    type A = Real(unit="kN", displayUnit="mN");
    type B = Real(unit="N", displayUnit="mN");
    A a = time;
    B b = time;
    Real c(unit="kW.h", displayUnit="J") = 2 * time;
    Real d(unit="W.h", displayUnit="J") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit7",
            description="Two display unit with same base unit.",
            fmi_version="1.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <BaseUnit unit=\"N\">
        <DisplayUnitDefinition displayUnit=\"mN\" gain=\"1000.0\" />
    </BaseUnit>
    <BaseUnit unit=\"kW.h\">
        <DisplayUnitDefinition displayUnit=\"J\" gain=\"3600000.0\" />
    </BaseUnit>
    <BaseUnit unit=\"W.h\">
        <DisplayUnitDefinition displayUnit=\"J\" gain=\"3600.0\" />
    </BaseUnit>
    <BaseUnit unit=\"kN\">
        <DisplayUnitDefinition displayUnit=\"mN\" gain=\"1000000.0\" />
    </BaseUnit>
</UnitDefinitions>
")})));
end DisplayUnit7;

model DisplayUnit8
    type A = Real(unit="kN", displayUnit="mN");
    type B = Real(unit="N", displayUnit="mN");
    A a = time;
    B b = time;
    Real c(unit="kW.h", displayUnit="J") = 2 * time;
    Real d(unit="W.h", displayUnit="J") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit8",
            description="Two display unit with same base unit.",
            fmi_version="2.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <Unit name=\"N\">
        <BaseUnit m=\"1\" s=\"-2\" kg=\"1\" />
        <DisplayUnit name=\"mN\" factor=\"1000.0\" />
    </Unit>
    <Unit name=\"kW.h\">
        <BaseUnit m=\"2\" s=\"-2\" kg=\"1\" factor=\"3600000.0\" />
        <DisplayUnit name=\"J\" factor=\"3600000.0\" />
    </Unit>
    <Unit name=\"W.h\">
        <BaseUnit m=\"2\" s=\"-2\" kg=\"1\" factor=\"3600.0\" />
        <DisplayUnit name=\"J\" factor=\"3600.0\" />
    </Unit>
    <Unit name=\"kN\">
        <BaseUnit m=\"1\" s=\"-2\" kg=\"1\" factor=\"1000.0\" />
        <DisplayUnit name=\"mN\" factor=\"1000000.0\" />
    </Unit>
</UnitDefinitions>
")})));
end DisplayUnit8;

model DisplayUnit9
    type A = Real(unit="N", displayUnit="x");
    A a = time;
    Real b(unit="Y", displayUnit="y") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit9",
            description="Test with unknown base units and display units",
            fmi_version="1.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <BaseUnit unit=\"N\">
        <DisplayUnitDefinition displayUnit=\"x\" />
    </BaseUnit>
    <BaseUnit unit=\"Y\">
        <DisplayUnitDefinition displayUnit=\"y\" />
    </BaseUnit>
</UnitDefinitions>
")})));
end DisplayUnit9;

model DisplayUnit10
    type A = Real(unit="N", displayUnit="x");
    A a = time;
    Real b(unit="Y", displayUnit="y") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit10",
            description="Test with unknown base units and display units",
            fmi_version="2.0",
            template="$unitDefinitions$",
            generatedCode="
<UnitDefinitions>
    <Unit name=\"N\">
        <BaseUnit m=\"1\" s=\"-2\" kg=\"1\" />
        <DisplayUnit name=\"x\" />
    </Unit>
    <Unit name=\"Y\">
        <DisplayUnit name=\"y\" />
    </Unit>
</UnitDefinitions>
")})));
end DisplayUnit10;

model DisplayUnit11
    Real a(displayUnit="W") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit11",
            description="Test that no displayUnit without unit is generated for XML variable",
            fmi_version="1.0",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end DisplayUnit11;

model DisplayUnit12
    Real a(displayUnit="W") = 2 * time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DisplayUnit12",
            description="Test that no displayUnit without unit is generated for XML variable",
            fmi_version="2.0",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end DisplayUnit12;

model Fmi1StartAttribute
    constant Real independent1(start=1);
    constant Real dependent1(fixed=false) = independent1*independent1;
    
    constant Real independent2(start=1);
    constant Real dependent2(fixed=true) = independent2*independent2;
    
    constant Real independent3(start=1);
    constant Real dependent3 = independent3*independent3;
    
    parameter Real independent4(start=1);
    parameter Real dependent4(fixed=false);
    
    parameter Real independent5(start=1);
    parameter Real dependent5(fixed=true) = independent5*independent5;
    
    parameter Real independent6(start=1);
    parameter Real dependent6 = independent6*independent6;
    
    Real x1(start=0);
    Real x2"start=0";
    Real x3(fixed=false, start=0);
    Real x4(fixed=true, start=0);
    Real x5"fixed=true";
  
  initial equation
    dependent4 = independent4*independent4;
    //x3*x3 = 4;

  equation
    der(x1) = x1;
    der(x2) = x2;
    der(x3) = x3;
    der(x4) = x4;
    der(x5) = x5;
    
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1StartAttribute",
            description="Check parameters without binding expressions",
            eliminate_alias_variables=false,
            fmi_version="1.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"dependent1\" valueReference=\"1\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"dependent2\" valueReference=\"3\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"dependent3\" valueReference=\"5\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"dependent4\" valueReference=\"11\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"dependent5\" valueReference=\"9\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"dependent6\" valueReference=\"10\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"independent1\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"independent2\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"independent3\" valueReference=\"4\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"independent4\" valueReference=\"6\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"independent5\" valueReference=\"7\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"independent6\" valueReference=\"8\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"x1\" valueReference=\"17\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #14 -->
    <ScalarVariable name=\"der(x1)\" valueReference=\"12\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #15 -->
    <ScalarVariable name=\"x2\" valueReference=\"18\" description=\"start=0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #16 -->
    <ScalarVariable name=\"der(x2)\" valueReference=\"13\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #17 -->
    <ScalarVariable name=\"x3\" valueReference=\"19\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #18 -->
    <ScalarVariable name=\"der(x3)\" valueReference=\"14\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #19 -->
    <ScalarVariable name=\"x4\" valueReference=\"20\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #20 -->
    <ScalarVariable name=\"der(x4)\" valueReference=\"15\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #21 -->
    <ScalarVariable name=\"x5\" valueReference=\"21\" description=\"fixed=true\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #22 -->
    <ScalarVariable name=\"der(x5)\" valueReference=\"16\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1StartAttribute;

model Fmi2StartAttribute
    constant Real independent1(start=1);
    constant Real dependent1(fixed=false) = independent1*independent1;
    
    constant Real independent2(start=1);
    constant Real dependent2(fixed=true) = independent2*independent2;
    
    constant Real independent3(start=1);
    constant Real dependent3 = independent3*independent3;
    
    parameter Real independent4(start=1);
    parameter Real dependent4(fixed=false);
    
    parameter Real independent5(start=1);
    parameter Real dependent5(fixed=true) = independent5*independent5;
    
    parameter Real independent6(start=1);
    parameter Real dependent6 = independent6*independent6;
    
    Real x1(start=0);
    Real x2"start=0";
    Real x3(fixed=false, start=0);
    Real x4(fixed=true, start=0);
    Real x5"fixed=true";
  
  initial equation
    dependent4 = independent4*independent4;
    //x3*x3 = 4;

  equation
    der(x1) = x1;
    der(x2) = x2;
    der(x3) = x3;
    der(x4) = x4;
    der(x5) = x5;
    
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2StartAttribute",
            description="Check parameters without binding expressions",
            fmi_version="2.0",
            eliminate_alias_variables=false,
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"dependent1\" valueReference=\"1\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"dependent2\" valueReference=\"3\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"dependent3\" valueReference=\"5\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"dependent4\" valueReference=\"11\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"dependent5\" valueReference=\"9\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"dependent6\" valueReference=\"10\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"independent1\" valueReference=\"0\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"independent2\" valueReference=\"2\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"independent3\" valueReference=\"4\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"independent4\" valueReference=\"6\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"independent5\" valueReference=\"7\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"independent6\" valueReference=\"8\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"x1\" valueReference=\"17\" causality=\"local\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #14 -->
    <ScalarVariable name=\"der(x1)\" valueReference=\"12\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"13\" />
    </ScalarVariable>
    <!-- Variable with index #15 -->
    <ScalarVariable name=\"x2\" valueReference=\"18\" description=\"start=0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #16 -->
    <ScalarVariable name=\"der(x2)\" valueReference=\"13\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"15\" />
    </ScalarVariable>
    <!-- Variable with index #17 -->
    <ScalarVariable name=\"x3\" valueReference=\"19\" causality=\"local\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #18 -->
    <ScalarVariable name=\"der(x3)\" valueReference=\"14\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"17\" />
    </ScalarVariable>
    <!-- Variable with index #19 -->
    <ScalarVariable name=\"x4\" valueReference=\"20\" causality=\"local\" variability=\"continuous\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #20 -->
    <ScalarVariable name=\"der(x4)\" valueReference=\"15\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"19\" />
    </ScalarVariable>
    <!-- Variable with index #21 -->
    <ScalarVariable name=\"x5\" valueReference=\"21\" description=\"fixed=true\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #22 -->
    <ScalarVariable name=\"der(x5)\" valueReference=\"16\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"21\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi2StartAttribute;

model Fmi1Enumerations
  type E = enumeration (A,B,C);
  
  E one(start = E.A);
  E two(start = E.B);
  E three(start = E.C);
  
  equation
    one = E.A;
    two = E.B;
    three = E.C;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1Enumerations",
            description="Check parameters without binding expressions",
            fmi_version="1.0",
            template="
$typeDefinitions$
$modelVariables$",
            generatedCode="
<TypeDefinitions>
    <Type name=\"FmiXMLTests.Fmi1Enumerations.E\">
        <EnumerationType min=\"1\" max=\"3\">
            <Item name=\"A\" />
            <Item name=\"B\" />
            <Item name=\"C\" />
        </EnumerationType>
    </Type>
</TypeDefinitions>
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"one\" valueReference=\"268435456\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi1Enumerations.E\" start=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"three\" valueReference=\"268435458\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi1Enumerations.E\" start=\"3\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"two\" valueReference=\"268435457\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi1Enumerations.E\" start=\"2\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1Enumerations;

model Fmi2Enumerations
  type E = enumeration (A,B,C);
  
  E one(start = E.A);
  E two(start = E.B);
  E three(start = E.C);
  
  equation
    one = E.A;
    two = E.B;
    three = E.C;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2Enumerations",
            description="Check parameters without binding expressions",
            fmi_version="2.0",
            template="
$typeDefinitions$
$modelVariables$",
            generatedCode="
<TypeDefinitions>
    <SimpleType name=\"FmiXMLTests.Fmi2Enumerations.E\">
        <Enumeration>
            <Item name=\"A\" value=\"1\" />
            <Item name=\"B\" value=\"2\" />
            <Item name=\"C\" value=\"3\" />
        </Enumeration>
    </SimpleType>
</TypeDefinitions>
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"one\" valueReference=\"268435456\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi2Enumerations.E\" start=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"three\" valueReference=\"268435458\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi2Enumerations.E\" start=\"3\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"two\" valueReference=\"268435457\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.Fmi2Enumerations.E\" start=\"2\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi2Enumerations;

model Fmi1Aliases1

    parameter Real original(start = 1.0);
    parameter Real alias = original;
    parameter Real negatedAlias = - original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1Aliases1",
            description="FMI 1.0 alias test for parameters",
            fmi_version="1.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"alias\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"negatedAlias\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"original\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1Aliases1;

model Fmi1Aliases2

    Real original(start = 1.0);
    Real alias;
    Real negatedAlias;
    
    equation
        alias = original;
        negatedAlias = -original;
        der(original) = original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi1Aliases2",
            description="FMI 1.0 alias test for reals",
            fmi_version="1.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"alias\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"alias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"negatedAlias\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"negatedAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"original\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" fixed=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(original)\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Fmi1Aliases2;

model Fmi2Aliases1

    parameter Real original(start = 1.0);
    parameter Real alias = original;
    parameter Real negatedAlias = - original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2Aliases1",
            description="FMI 2.0 alias test for parameters",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"alias\" valueReference=\"1\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"negatedAlias\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"original\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"3\" />
        <Unknown index=\"2\" dependencies=\"3\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end Fmi2Aliases1;

model Fmi2Aliases2

    Real original(start = 1.0);
    Real alias;
    Real negatedAlias;
    
    equation
        alias = original;
        negatedAlias = -original;
        der(original) = original;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Fmi2Aliases2",
            description="FMI 2.0 alias test for reals",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"alias\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"negatedAlias\" valueReference=\"134217729\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"original\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"approx\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(original)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"3\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"4\" dependencies=\"3\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"3\" dependencies=\"\" />
        <Unknown index=\"4\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end Fmi2Aliases2;

model FixedParameters2

    parameter Real fixed1(fixed=false);
    parameter Real independent = 4;
  
  initial equation
    fixed1 = independent;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="FixedParameters2",
            description="Check parameters with binding expressions",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"fixed1\" valueReference=\"1\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"independent\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"4.0\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"2\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end FixedParameters2;

model FixedParameters3

    parameter Real independent1 = 1.0;
    parameter Real fixed1(fixed=true) = independent1*independent1;
    
    parameter Real independent2 = 1.0;
    parameter Real fixed2 = independent2*independent2 "fixed=true is default";
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="FixedParameters3",
            description="Check parameters with and without the fixed attribute",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"fixed1\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"fixed2\" valueReference=\"3\" description=\"fixed=true is default\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"independent1\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"independent2\" valueReference=\"1\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"3\" />
        <Unknown index=\"2\" dependencies=\"4\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end FixedParameters3;

model ParameterDependencies1
  function f1
    input Real x;
    output Real y;
  algorithm
    y := x*x;
    annotation(Inline=false);
  end f1;

    Real x1, x2, x3, x4;
    parameter Real independentParameter1 = 1.0;
    parameter Real independentParameter2 = 1.0;
    parameter Real dependentParameter(fixed=true) = independentParameter1 * independentParameter1;
  
  initial equation
    //Block 1
    x1 = f1(x1);
    //Block 2
    x2 = f1(x1 * x2) + independentParameter2;
    //Block 3
    x3 = f1(x2 * x3) + dependentParameter;
    //Block 4
    x4 = f1(x3 * x4); 
  equation
    der(x1) = x1;
    der(x2) = x2;
    der(x3) = x3;
    der(x4) = x4;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="ParameterDependencies1",
            description="Check that the initial unknowns are correct",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"dependentParameter\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"independentParameter1\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"independentParameter2\" valueReference=\"1\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"x1\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"der(x1)\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"4\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"x2\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"der(x2)\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"6\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"x3\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"der(x3)\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"8\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"x4\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"der(x4)\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"10\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"5\" dependencies=\"4\" />
        <Unknown index=\"7\" dependencies=\"6\" />
        <Unknown index=\"9\" dependencies=\"8\" />
        <Unknown index=\"11\" dependencies=\"10\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"2\" />
        <Unknown index=\"4\" dependencies=\"\" />
        <Unknown index=\"5\" dependencies=\"\" />
        <Unknown index=\"6\" dependencies=\"3\" />
        <Unknown index=\"7\" dependencies=\"3\" />
        <Unknown index=\"8\" dependencies=\"2 3\" />
        <Unknown index=\"9\" dependencies=\"2 3\" />
        <Unknown index=\"10\" dependencies=\"2 3\" />
        <Unknown index=\"11\" dependencies=\"2 3\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end ParameterDependencies1;

model ParameterDependencies2
    Real x1, x2, x3;
    parameter Real independentParameter1 = 1.0;
    parameter Real independentParameter2 = 1.0;
    parameter Real dependentParameter1(fixed=false);
    parameter Real dependentParameter2(fixed=false);
    parameter Real dependentParameter3(fixed=false);
    parameter Real dependentParameter4(fixed=false);
    
    parameter Real dependentParameter5(fixed=true) = independentParameter2 * independentParameter2 "parameter equation";
  initial equation
    //Block 1
    dependentParameter1 = dependentParameter2 + independentParameter1;
    dependentParameter1 * dependentParameter2 = 1;
    //Block 2
    dependentParameter3 = dependentParameter4 + dependentParameter1 + dependentParameter5;
    dependentParameter3 * dependentParameter4 = 1;
  equation
    der(x1) = x1 + dependentParameter1;
    der(x2) = x2 + dependentParameter3;
    der(x3) = x3 + dependentParameter5;
    
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="ParameterDependencies2",
            description="Check that the initial unknowns are correct",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"dependentParameter1\" valueReference=\"3\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"dependentParameter2\" valueReference=\"4\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"dependentParameter3\" valueReference=\"5\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"dependentParameter4\" valueReference=\"6\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"dependentParameter5\" valueReference=\"2\" description=\"parameter equation\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"independentParameter1\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"independentParameter2\" valueReference=\"1\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"x1\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"der(x1)\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"8\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"x2\" valueReference=\"11\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"der(x2)\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"10\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"x3\" valueReference=\"12\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"der(x3)\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"12\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"9\" dependencies=\"8\" />
        <Unknown index=\"11\" dependencies=\"10\" />
        <Unknown index=\"13\" dependencies=\"12\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"6\" />
        <Unknown index=\"2\" dependencies=\"6\" />
        <Unknown index=\"3\" dependencies=\"6 7\" />
        <Unknown index=\"4\" dependencies=\"6 7\" />
        <Unknown index=\"5\" dependencies=\"7\" />
        <Unknown index=\"8\" dependencies=\"\" />
        <Unknown index=\"9\" dependencies=\"6\" />
        <Unknown index=\"10\" dependencies=\"\" />
        <Unknown index=\"11\" dependencies=\"6 7\" />
        <Unknown index=\"12\" dependencies=\"\" />
        <Unknown index=\"13\" dependencies=\"7\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end ParameterDependencies2;

model InitialUnknown1
  function f1
    input Real x;
    output Real y;
  algorithm
    y := x*x;
    annotation(Inline=false);
  end f1;
  
  function f2
    input Real x;
    output Real y;
  algorithm
    y := x*x;
    annotation(Inline=false);
  end f2;
  
  function f3
    input Real x1;
    input Real x2;
    input Real x3;
    input Real x4;
    input Real x5;
    output Real y;
  algorithm
    y := x1*x2*x3*x4*x5;
    annotation(Inline=false);
  end f3;
  
  function g1
    input Real x1;
    input Real x2;
    output Real y;
  algorithm
    y := x1*x1 + x2*x2;
    annotation(Inline=false);
  end g1;

    Real x1;
    Real x2;
    Real x3;
    output Real y;
    input Real u1,u2,u3;
    parameter Real p(start=1.0);
    Real t1,t2;
  initial equation
    y = 3.3;
    der(x2) = 0;
    x1 = 1.1;
  equation
    
    t1 + t2 = 1;
    t1      = p * p;
    
    der(x1) = f1(x2);
    der(x2) = f2(x1) + 3*p*p*x2 + 2*u1 + 3*u3;
    der(x3) = f3(x1,x3,u1,u2,u3);
    y = g1(x2, x3);

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="InitialUnknown1",
            description="Check that the initial unknowns are correct",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"p\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"t1\" valueReference=\"1\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"t2\" valueReference=\"2\" causality=\"calculatedParameter\" variability=\"fixed\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"u1\" valueReference=\"9\" causality=\"input\" variability=\"continuous\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"u2\" valueReference=\"10\" causality=\"input\" variability=\"continuous\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"u3\" valueReference=\"11\" causality=\"input\" variability=\"continuous\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"x1\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"der(x1)\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"7\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"x2\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"der(x2)\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"9\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"x3\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"der(x3)\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"11\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"y\" valueReference=\"12\" causality=\"output\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Outputs>
        <Unknown index=\"13\" dependencies=\"9 11\" />
    </Outputs>
    <Derivatives>
        <Unknown index=\"10\" dependencies=\"4 6 7 9\" />
        <Unknown index=\"8\" dependencies=\"9\" />
        <Unknown index=\"12\" dependencies=\"4 5 6 7 11\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"2\" dependencies=\"1\" />
        <Unknown index=\"3\" dependencies=\"1\" />
        <Unknown index=\"7\" dependencies=\"\" />
        <Unknown index=\"8\" dependencies=\"1 4 6\" />
        <Unknown index=\"9\" dependencies=\"1 4 6\" />
        <Unknown index=\"10\" dependencies=\"\" />
        <Unknown index=\"11\" dependencies=\"1 4 6\" />
        <Unknown index=\"12\" dependencies=\"1 4 5 6\" />
        <Unknown index=\"13\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end InitialUnknown1;

model SortingStates
    Real y,b,x,a;
  equation
    der(y) = time;
    der(x) = time;
    der(a) = time;
    der(b) = time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="SortingStatesXML",
            description="Check sorting of derivatives in model structure after value reference",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"der(a)\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"b\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(b)\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"3\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"x\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"der(x)\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"5\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"y\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"der(y)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"7\" />
    </ScalarVariable>
</ModelVariables>
<ModelStructure>
    <Derivatives>
        <Unknown index=\"8\" dependencies=\"\" />
        <Unknown index=\"6\" dependencies=\"\" />
        <Unknown index=\"2\" dependencies=\"\" />
        <Unknown index=\"4\" dependencies=\"\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"1\" dependencies=\"\" />
        <Unknown index=\"2\" dependencies=\"\" />
        <Unknown index=\"3\" dependencies=\"\" />
        <Unknown index=\"4\" dependencies=\"\" />
        <Unknown index=\"5\" dependencies=\"\" />
        <Unknown index=\"6\" dependencies=\"\" />
        <Unknown index=\"7\" dependencies=\"\" />
        <Unknown index=\"8\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end SortingStates;

model DynamicStateUnknowns
    Real x;
    Real y;
    Real vx;
    Real vy;
    Real lambda;
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - 2;
    x^2 + y^2 = 1;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DynamicStateUnknowns",
            description="Check so that dynamic states are included correctly in the dependency information for unkowns",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"_der_x\" valueReference=\"11\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"der(_der_x)\" valueReference=\"17\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"_der_y\" valueReference=\"12\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(_der_y)\" valueReference=\"18\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"_ds.1.a1\" valueReference=\"13\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"_ds.1.s1\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"der(_ds.1.s1)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"6\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"_ds.2.a1\" valueReference=\"14\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"_ds.2.s1\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"der(_ds.2.s1)\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"9\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"lambda\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"vx\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"der(vx)\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"12\" />
    </ScalarVariable>
    <!-- Variable with index #14 -->
    <ScalarVariable name=\"vy\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #15 -->
    <ScalarVariable name=\"der(vy)\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"14\" />
    </ScalarVariable>
    <!-- Variable with index #16 -->
    <ScalarVariable name=\"x\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #17 -->
    <ScalarVariable name=\"der(x)\" valueReference=\"15\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #18 -->
    <ScalarVariable name=\"y\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #19 -->
    <ScalarVariable name=\"der(y)\" valueReference=\"16\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>

<ModelStructure>
    <Derivatives>
        <Unknown index=\"7\" dependencies=\"6 9\" />
        <Unknown index=\"10\" dependencies=\"6 9\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"6\" dependencies=\"\" />
        <Unknown index=\"7\" dependencies=\"\" />
        <Unknown index=\"9\" dependencies=\"\" />
        <Unknown index=\"10\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end DynamicStateUnknowns;

model SecondOrderDerivatives
    Real x(stateSelect=StateSelect.always);
    Real y;
    Real vx(stateSelect=StateSelect.always);
    Real vy;
    Real lambda;
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - 2;
    x^2 + y^2 = 1;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="SecondOrderDerivatives",
            description="Check so that second order derivatives point at the correct lower order variables",
            fmi_version="2.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"lambda\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"vx\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"der(vx)\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"vy\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"der(vy)\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"4\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"x\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"der(x,2)\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"8\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"der(x)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"6\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"y\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"der(y)\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"9\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"der(y,2)\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"10\" />
    </ScalarVariable>
</ModelVariables>
")})));
end SecondOrderDerivatives;

model HigherOrderOrphanTempDerivatives
        function F
            input Real i;
            output Real o1[2];
        algorithm
            o1[1] := i;
            o1[2] := -i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der[2];
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x[2];
        Real vx[2];
        Real a[2];
        constant Real p[2] = {1.2, 0};
    equation
        der(x) = vx;
        der(vx) = a.*x;
        x = p + F(sin(time));

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="HigherOrderOrphanTempDerivatives",
            description="Check so that we skip generating derivative for temporaries of higher order which are orphan",
            expose_temp_vars_in_fmu=true,
            fmi_version="2.0",
            template="
$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a[1]\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"a[2]\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"p[1]\" valueReference=\"0\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.2\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"p[2]\" valueReference=\"1\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"temp_1[1]\" valueReference=\"12\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"temp_4\" valueReference=\"13\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"temp_5\" valueReference=\"14\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"vx[1]\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"der(vx[1])\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"8\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"vx[2]\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"der(vx[2])\" valueReference=\"11\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"10\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"x[1]\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"der(x[1])\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"12\" />
    </ScalarVariable>
    <!-- Variable with index #14 -->
    <ScalarVariable name=\"der(x[1],2)\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"13\" />
    </ScalarVariable>
    <!-- Variable with index #15 -->
    <ScalarVariable name=\"x[2]\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #16 -->
    <ScalarVariable name=\"der(x[2])\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"15\" />
    </ScalarVariable>
    <!-- Variable with index #17 -->
    <ScalarVariable name=\"der(x[2],2)\" valueReference=\"11\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"16\" />
    </ScalarVariable>
</ModelVariables>
"),
        FClassMethodTestCase(
            name="HigherOrderOrphanTempDerivatives_alias",
            methodName="aliasDiagnostics",
            description="Ensure that the temporary is in the set of alias variables",
            expose_temp_vars_in_fmu=true,
            fmi_version="2.0",
            methodResult="
Alias sets:
{_der_vx[2], _der_der_x[2], temp_9}
{_der_vx[1], _der_der_x[1], _der_der_temp_1[1], temp_8}
5 variables can be eliminated
")})));
end HigherOrderOrphanTempDerivatives;

model StructuralStartValueBase
    parameter Integer n = 3;
    Real[n] x = 1:n;
    parameter Real a = 3 annotation(Evaluate=true);
    final parameter Real b = 3;
end StructuralStartValue;

model StructuralStartValue1
    extends StructuralStartValueBase;
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="StructuralStartValue1",
            description="Check that structural parameters does not generate a start value.",
            fmi_version="1.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Real relativeQuantity=\"false\" start=\"3.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"b\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Real relativeQuantity=\"false\" start=\"3.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"n\" valueReference=\"268435459\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Integer start=\"3\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"x[1]\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"x[2]\" valueReference=\"1\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"2.0\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"x[3]\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"3.0\" />
    </ScalarVariable>
</ModelVariables>
")})));
end StructuralStartValue1;

model StructuralStartValue2
    extends StructuralStartValueBase;
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="StructuralStartValue2",
            description="Check that structural parameters does not generate a start value.",
            fmi_version="2.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"2\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"3.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"b\" valueReference=\"2\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"3.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"n\" valueReference=\"268435459\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Integer start=\"3\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"x[1]\" valueReference=\"0\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"x[2]\" valueReference=\"1\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"2.0\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"x[3]\" valueReference=\"2\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"3.0\" />
    </ScalarVariable>
</ModelVariables>
")})));
end StructuralStartValue2;

model NoInitialTypeForInputs
    input Real myInput;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="NoInitialTypeForInputs",
            description="Check that input variables does not generate an initial type.",
            fmi_version="2.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"myInput\" valueReference=\"0\" causality=\"input\" variability=\"continuous\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
</ModelVariables>
")})));
end NoInitialTypeForInputs;

model TempVars1
    function f
        input Real i;
        output Real o[2];
    algorithm
        o := {i,-i};
    annotation(Inline=false);
    end f;

    Real x;
equation
    x = f(time) * {3,4};

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="TempVars1",
            description="Ensures that temporary variables isn't exposed in the xml by default",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>

")})));
end TempVars1;

model TempVars2
    function f
        input Real i;
        output Real o[2];
    algorithm
        o := {i,-i};
    annotation(Inline=false);
    end f;

    Real x;
equation
    x = f(time) * {3,4};

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="TempVars2",
            description="Ensures that temporary variables are exposed in the xml when expose_temp_vars_in_fmu is set to true",
            expose_temp_vars_in_fmu=true,
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"temp_1[1]\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"temp_1[2]\" valueReference=\"2\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"x\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>

")})));
end TempVars2;

model TempVarState1
        function f
        input Real x[2];
        input Real A[2,2];
        output Real y[2];
    algorithm
        y := A*x;
    annotation(derivative=f_der,LateInline=true);
    end f;

    function f_der
        input Real x[2];
        input Real A[2,2];
        input Real der_x[2];
        input Real der_A[2,2];
        output Real der_y[2];
    algorithm
        der_y := A*der_x;
    annotation(LateInline=true);
    end f_der;

    parameter Real A[2,2] = {{1,2},{3,4}};
    Real x1[2](each stateSelect=StateSelect.never),x2[2](each stateSelect=StateSelect.never);
equation
    der(x1) + der(x2) = {2,3};
    x1 + f(x2,A) = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="TempVarState1",
            description="Ensures that temporary variables are exposed in the xml when they are differentiated (or derivative)",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"A[1,1]\" valueReference=\"0\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"A[1,2]\" valueReference=\"1\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"2.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"A[2,1]\" valueReference=\"2\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"3.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"A[2,2]\" valueReference=\"3\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"4.0\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"temp_6\" valueReference=\"6\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"der(temp_6)\" valueReference=\"4\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"5\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"temp_7\" valueReference=\"7\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"der(temp_7)\" valueReference=\"5\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"7\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"x1[1]\" valueReference=\"8\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"der(x1[1])\" valueReference=\"12\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"9\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"x1[2]\" valueReference=\"9\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"der(x1[2])\" valueReference=\"14\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"11\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"x2[1]\" valueReference=\"10\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #14 -->
    <ScalarVariable name=\"der(x2[1])\" valueReference=\"13\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"13\" />
    </ScalarVariable>
    <!-- Variable with index #15 -->
    <ScalarVariable name=\"x2[2]\" valueReference=\"11\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #16 -->
    <ScalarVariable name=\"der(x2[2])\" valueReference=\"15\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"15\" />
    </ScalarVariable>
</ModelVariables>

<ModelStructure>
    <Derivatives>
        <Unknown index=\"6\" dependencies=\"\" />
        <Unknown index=\"8\" dependencies=\"\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"5\" dependencies=\"\" />
        <Unknown index=\"6\" dependencies=\"1 2 3 4\" />
        <Unknown index=\"7\" dependencies=\"\" />
        <Unknown index=\"8\" dependencies=\"1 2 3 4\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end TempVarState1;

model ConstantAliasBase
    constant Real a = 1;
    constant Real b = a;
    constant Integer[n] c = 1:n;
    parameter Integer n = x1 + integer(x2);
    parameter Integer x1 = 1;
    parameter Real x2 = 1;
    constant String s1 = "string";
    constant String s2 = s1;
    parameter String s3 = "string" annotation(Evaluate=true);
    
    type E = enumeration(A,B,C);
    
    constant E e1 = e2;
    constant E e2 = E.B;
    constant E e3 = E.B;
    constant E e4 = E.C;
end ConstantAliasBase;

model ConstantAlias1
    extends ConstantAliasBase;
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="ConstantAlias1",
            description="Check xml with constant alias sets",
            fmi_version="1.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"b\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"c[1]\" valueReference=\"268435457\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Integer start=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"c[2]\" valueReference=\"268435458\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Integer start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"e1\" valueReference=\"268435459\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias1.E\" start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"e2\" valueReference=\"268435459\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias1.E\" start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"e3\" valueReference=\"268435459\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias1.E\" start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"e4\" valueReference=\"268435460\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias1.E\" start=\"3\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"n\" valueReference=\"268435458\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Integer start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"s1\" valueReference=\"805306368\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
        <String start=\"string\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"s2\" valueReference=\"805306368\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <String start=\"string\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"s3\" valueReference=\"805306368\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <String start=\"string\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"x1\" valueReference=\"268435457\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Integer start=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #14 -->
    <ScalarVariable name=\"x2\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"alias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
")})));
end ConstantAlias1;

model ConstantAlias2
    extends ConstantAliasBase;
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="ConstantAlias2",
            description="Check xml with constant alias sets",
            fmi_version="2.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"0\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"b\" valueReference=\"0\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"c[1]\" valueReference=\"268435457\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Integer start=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"c[2]\" valueReference=\"268435458\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Integer start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #5 -->
    <ScalarVariable name=\"e1\" valueReference=\"268435459\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias2.E\" start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #6 -->
    <ScalarVariable name=\"e2\" valueReference=\"268435459\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias2.E\" start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #7 -->
    <ScalarVariable name=\"e3\" valueReference=\"268435459\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias2.E\" start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #8 -->
    <ScalarVariable name=\"e4\" valueReference=\"268435460\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Enumeration declaredType=\"FmiXMLTests.ConstantAlias2.E\" start=\"3\" />
    </ScalarVariable>
    <!-- Variable with index #9 -->
    <ScalarVariable name=\"n\" valueReference=\"268435458\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Integer start=\"2\" />
    </ScalarVariable>
    <!-- Variable with index #10 -->
    <ScalarVariable name=\"s1\" valueReference=\"805306368\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <String start=\"string\" />
    </ScalarVariable>
    <!-- Variable with index #11 -->
    <ScalarVariable name=\"s2\" valueReference=\"805306368\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <String start=\"string\" />
    </ScalarVariable>
    <!-- Variable with index #12 -->
    <ScalarVariable name=\"s3\" valueReference=\"805306368\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <String start=\"string\" />
    </ScalarVariable>
    <!-- Variable with index #13 -->
    <ScalarVariable name=\"x1\" valueReference=\"268435457\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Integer start=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #14 -->
    <ScalarVariable name=\"x2\" valueReference=\"0\" causality=\"local\" variability=\"constant\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
</ModelVariables>
")})));
end ConstantAlias2;

model StringStartValueIllegalChars1
  parameter String a = "Carbon steel (%C <= 0.30)";
  
  annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="StringStartValueIllegalChars1",
            description="Test that no illegal XML characters are generated",
            fmi_version="1.0",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"805306368\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <String start=\"Carbon steel (%C &lt;= 0.30)\" />
    </ScalarVariable>
</ModelVariables>
")})));
end StringStartValueIllegalChars1;

model StringStartValueIllegalChars2
  parameter String a = "Carbon steel (%C <= 0.30)";
  
  annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="StringStartValueIllegalChars2",
            description="Test that no illegal XML characters are generated",
            fmi_version="2.0",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"a\" valueReference=\"805306368\" causality=\"parameter\" variability=\"fixed\" initial=\"exact\">
        <String start=\"Carbon steel (%C &lt;= 0.30)\" />
    </ScalarVariable>
</ModelVariables>
")})));
end StringStartValueIllegalChars2;

model Quantity1
    Real x(quantity="Time") = time;
  annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Quantity1",
            description="Quantity attribute",
            fmi_version="2.0",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real quantity=\"Time\" relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Quantity1;


model VendorAnnotations1
    Real x = time;

annotation(__JModelica(UnitTesting(tests={
    FmiXMLCodeGenTestCase(
        name="VendorAnnotations1",
        description="VendorAnnotations for FMI 1.0",
        fmi_version="1.0",
        template="$vendorAnnotations$",
        regexp="/Tool name=\"[^\"]+\"/Tool name=\"\"/",
        generatedCode="
<VendorAnnotations>
	<Tool name=\"\">
		<Annotation name=\"CompilerVersion\" value=\"compiler_version_file_not_read\" />
	</Tool>
</VendorAnnotations>
")})));
end VendorAnnotations1;


model VendorAnnotations2
    Real x = time;

annotation(__JModelica(UnitTesting(tests={
    FmiXMLCodeGenTestCase(
        name="VendorAnnotations2",
        description="VendorAnnotations for FMI 2.0",
        fmi_version="2.0",
        template="$vendorAnnotations$",
        regexp="/Tool name=\"[^\"]+\"/Tool name=\"\"/",
        generatedCode="
<VendorAnnotations>
	<Tool name=\"\">
		<Annotations>
			<Annotation name=\"CompilerVersion\" value=\"compiler_version_file_not_read\" />
		</Annotations>
	</Tool>
</VendorAnnotations>
")})));
end VendorAnnotations2;

model DummyDerivative1

    model M
        Real x1;
        Real x2;
    equation
        der(x1) + der(x2) = 2;
        x1 + x2*time = 0;
    end M;

    M m;


    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DummyDerivative1",
            description="XML name of dummy derivative",
            fmi_version="1.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"m.x1\" valueReference=\"2\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"der(m.x1)\" valueReference=\"3\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"m.x2\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(m.x2)\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end DummyDerivative1;

model DummyDerivative2

    model M
        Real x1;
        Real x2;
    equation
        der(x1) + der(x2) = 2;
        x1 + x2*time = 0;
    end M;

    M m;


    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="DummyDerivative2",
            description="XML name of dummy derivative",
            fmi_version="2.0",
            template="
$modelVariables$
$modelStructure$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"m.x1\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"der(m.x1)\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"m.x2\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(m.x2)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"3\" />
    </ScalarVariable>
</ModelVariables>

<ModelStructure>
    <Derivatives>
        <Unknown index=\"4\" dependencies=\"3\" />
    </Derivatives>
    <InitialUnknowns>
        <Unknown index=\"3\" dependencies=\"\" />
        <Unknown index=\"4\" dependencies=\"\" />
    </InitialUnknowns>
</ModelStructure>
")})));
end DummyDerivative2;

model Start1
    Real x(fixed=true);
    Real y(start=0, fixed=true);
equation
    der(x) = 1;
    der(y) = 1;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Start1",
            description="Start value with fixed",
            fmi_version="1.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"2\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"der(x)\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"y\" valueReference=\"3\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(y)\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Start1;

model Start2
    Real x(fixed=true);
    Real y(start=0, fixed=true);
equation
    der(x) = 1;
    der(y) = 1;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Start2",
            description="Start value with fixed",
            fmi_version="2.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"2\" causality=\"local\" variability=\"continuous\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"der(x)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"1\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"y\" valueReference=\"3\" causality=\"local\" variability=\"continuous\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #4 -->
    <ScalarVariable name=\"der(y)\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"3\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Start2;

model Start3
    Real x(start=0, fixed=true);
    Real y(start=0, fixed=true);
equation
    der(x) = time;
    y = x;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Start3",
            description="Start value with fixed, aliases",
            fmi_version="1.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"alias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"y\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"der(y)\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Start3;

model Start4
    Real x(start=0, fixed=true);
    Real y(start=0, fixed=true);
equation
    der(x) = time;
    y = x;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Start4",
            description="Start value with fixed, aliases",
            fmi_version="2.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"y\" valueReference=\"1\" causality=\"local\" variability=\"continuous\" initial=\"exact\">
        <Real relativeQuantity=\"false\" start=\"0.0\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"der(y)\" valueReference=\"0\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" derivative=\"2\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Start4;

model Start5
    parameter Real p = 1;
    Real x(start=p, fixed=true);
equation
    der(x) = time;

    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Start5",
            description="Start value with fixed, parameter start",
            fmi_version="1.0",
            template="
$modelVariables$
",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"p\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" start=\"1.0\" />
    </ScalarVariable>
    <!-- Variable with index #2 -->
    <ScalarVariable name=\"x\" valueReference=\"2\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
    <!-- Variable with index #3 -->
    <ScalarVariable name=\"der(x)\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Start5;

end FmiXMLTests;
