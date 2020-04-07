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

package XMLCodeGenTests



model RemoveCopyright
	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="RemoveCopyright",
			description="Test that licence tag is filtered out",
			template="<!-- test copyright blurb --> test",
			generatedCode="
test"
)})));
end RemoveCopyright;

model XMLExtFunc1
	function F
		input Real x;
		output Real y;
		external;
	end F;
	
	parameter Real p = F(2);

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="XMLExtFunc1",
			description="External function call binding expression",
			template="$XML_variables$",
			generatedCode="
		<ScalarVariable name=\"p\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
		</ScalarVariable>
")})));
end XMLExtFunc1;


  model XMLCodeGenTest1
  	parameter Real rp1=1;
  	parameter Real rp2=rp1;
    parameter Real rp3(start=1);
    parameter Real rp4(start=rp1);
    parameter Real rp5(start=rp1) = 5;
    Real r1(start=1);
    Real r2=3;
    Real r3;
	input Real r4 = 5;

  	parameter Integer ip1=1;
  	parameter Integer ip2=ip1;
    parameter Integer ip3(start=1);
    parameter Integer ip4(start=ip1);
    parameter Integer ip5(start=ip1) = 5;
    Integer i1(start=1);
    Integer i2=3;
  	Integer i3=4;
	input Integer r4 = 5;

  	parameter Boolean bp1=true;
  	parameter Boolean bp2=bp1;
    parameter Boolean bp3(start=true);
    parameter Boolean bp4(start=bp1);
    parameter Boolean bp5(start=bp1) = false;
    Boolean b1(start=true);
    Boolean b2=true;
	Boolean b3=true;
	input Boolean b4 =true;
		
  	parameter String sp1="hello";
  	parameter String sp2=sp1;
    parameter String sp3(start="hello");
    parameter String sp4(start=sp1);
    parameter String sp5(start=sp1) = "hello";
    String s1(start="hello");
    String s2="hello";
	String s3="hello";
	input String s4="hello";
    
    equation 
     r1 = 1;
     der(r3)=1;
     i1 = 1;
     b1 = true;
     s2 = "hello";
  end XMLCodeGenTest1;

model XMLCodeGenTest2
	parameter Real p1 = 5;
	parameter Real p2 = p1+4;
	parameter Integer i1 = 1;
	parameter Integer i2 = i1+1;
	parameter Boolean b1 = true;
	parameter Boolean b2 = false;
    equation
	
	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="XMLCodeGenTest2",
			description="Start attribute of independent parameters.",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="
<ScalarVariable name=\"b1\" valueReference=\"536870916\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Boolean start=\"true\" />
<isLinear>true</isLinear>
<VariableCategory>independentParameter</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"b2\" valueReference=\"536870917\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Boolean start=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>independentParameter</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"i1\" valueReference=\"268435458\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Integer start=\"1\" />
<isLinear>true</isLinear>
<VariableCategory>independentParameter</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"i2\" valueReference=\"268435459\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Integer />
<isLinear>true</isLinear>
<VariableCategory>dependentParameter</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"p1\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" start=\"5.0\" />
<isLinear>true</isLinear>
<VariableCategory>independentParameter</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"p2\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>dependentParameter</VariableCategory>
</ScalarVariable>
")})));
end XMLCodeGenTest2;

	model XMLCodeGenTest3	
		parameter Real p1 = 5;
		parameter Real p2 = p1+4;
		parameter Real p3 = p2-1;
		parameter Real p4 = p3*6;
		parameter Real p5 = p4/6;
		parameter Real p6 = -p5;
		parameter Real p7 = p6/83;
		parameter Real p8 = p7^2;
   	 equation
   	end XMLCodeGenTest3;

	model XMLCodeGenTest4	
		Real r(quantity="q", unit="kg", displayUnit="g", 
		  min=-2-1,max=4,start=1+1,fixed=false,nominal=4-3) = 1;
		Integer i(quantity="q", min=-2-1,max=4,start=1+1,fixed=false) = 1;
		Boolean b(quantity="q", start=true,fixed=false) = 1;
		String s(quantity="q",start="qwe") = 1;


   	 equation
   	end XMLCodeGenTest4;

	model XMLCodeGenTest5
	
		constant Real r1(unit="m", displayUnit="mm",
			min = 2*0, max = 2^5, start = 10, nominal = 0) = 1;
		parameter Real r2(quantity="q1", min = 0, max = 10, start = 0) = 2;
		discrete Real r3(quantity="q1", unit = "Hz", max = 100) = 3;
		input Real r4(start = 5, min=-10);
		output Real r5(max=4, min=3) = 1;
		
		protected Integer i1(start=5)=2;
		Integer i2(quantity="g",max=1000)=3;
		Integer i3(min=1);
		
		String s1;
		String s2(start="abc")="def";
		
		equation
			s1 = "ghi";
			r5 = der(r4);	
		
	end XMLCodeGenTest5;	

	
	model EnumerationTest1
		type A = enumeration(a "This is a", b, c) "This is A";
		type B = enumeration(a, c, b "This is b");
		
		parameter A x = A.a;
		parameter B y = B.b;

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="EnumerationTest1",
			description="Test that TypeDefinitions section is generated correctly.",
			template="$XML_typeDefinitions$",
			generatedCode="
<TypeDefinitions>
		<Type name=\"XMLCodeGenTests.EnumerationTest1.A\" description=\"This is A\">
			<EnumerationType min=\"1\" max=\"3\">
				<Item name=\"a\" description=\"This is a\"/>
				<Item name=\"b\"/>
				<Item name=\"c\"/>
			</EnumerationType>
		</Type>
		<Type name=\"XMLCodeGenTests.EnumerationTest1.B\" >
			<EnumerationType min=\"1\" max=\"3\">
				<Item name=\"a\"/>
				<Item name=\"c\"/>
				<Item name=\"b\" description=\"This is b\"/>
			</EnumerationType>
		</Type>
	</TypeDefinitions>")})));
	end EnumerationTest1;
	
	model EnumerationTest2
		type A = enumeration(a "This is a", b, c) "This is A";
		type B = enumeration(a, c, b "This is b");
		
		parameter A x = A.a;
		parameter B y = B.b;

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="EnumerationTest2",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"x\" valueReference=\"268435456\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Enumeration declaredType=\"XMLCodeGenTests.EnumerationTest2.A\" start=\"1\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y\" valueReference=\"268435457\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Enumeration declaredType=\"XMLCodeGenTests.EnumerationTest2.B\" start=\"3\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>")})));
	end EnumerationTest2;
	
	model EnumerationTest3		
		type A = enumeration(a "This is a", b, c) "This is A";
		type B = enumeration(a, c, b "This is b");
		
		parameter A x(quantity="a", min=A.a, max=A.c);
		parameter B y(fixed=true);
		
	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="EnumerationTest3",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"x\" valueReference=\"268435456\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Enumeration declaredType=\"XMLCodeGenTests.EnumerationTest3.A\" quantity=\"a\" min=\"1\" max=\"3\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"y\" valueReference=\"268435457\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Enumeration declaredType=\"XMLCodeGenTests.EnumerationTest3.B\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
")})));
	end EnumerationTest3;
	
	model EnumerationTest4
		type DigitalCurrentChoices = enumeration(zero, one);

		parameter DigitalCurrentChoices c(start = DigitalCurrentChoices.one, fixed = true);

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="EnumerationTest4",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"c\" valueReference=\"268435456\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Enumeration declaredType=\"XMLCodeGenTests.EnumerationTest4.DigitalCurrentChoices\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
")})));
	end EnumerationTest4;

    model EnumerationTest5
        type T = enumeration(LT "<", GT ">") "Type for < and >";
        parameter T t = T.LT;


    annotation(__JModelica(UnitTesting(tests={
        XMLCodeGenTestCase(
            name="EnumerationTest5",
            description="Test that attributes in the TypeDefinitions section is escaped correctly.",
            template="$XML_typeDefinitions$",
            generatedCode="
<TypeDefinitions>
    <Type name=\"XMLCodeGenTests.EnumerationTest5.T\" description=\"Type for &lt; and &gt;\">
        <EnumerationType min=\"1\" max=\"2\">
            <Item name=\"LT\" description=\"&lt;\" />
            <Item name=\"GT\" description=\"&gt;\" />
        </EnumerationType>
    </Type>
</TypeDefinitions>
")})));
    end EnumerationTest5;
	//model EnumerationTest5
		//type DigitalCurrentChoices = enumeration(zero, one);
		//type DigitalCurrent = DigitalCurrentChoices(quantity="Current",start = DigitalCurrentChoices.one, fixed = true);
		//DigitalCurrent c(start = DigitalCurrent.one, fixed = true);
		//DigitalCurrentChoices c(start = DigitalCurrentChoices.one, fixed = true);

	//end EnumerationTest5;
	
	model VariableSortingTest1	
		parameter Real d = 1;
		parameter Real a = 5;
		parameter Real c = 6;
		parameter Real b = 4;
   	 equation
		
	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="VariableSortingTest1",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"a\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"5.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"b\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"4.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"c\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"6.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"d\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>")})));
	end VariableSortingTest1;
	
	model VariableSortingTest2
		parameter Real a3 = 3;
		parameter Real a1 = 1;
		parameter Real a2 = 2;
		equation

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="VariableSortingTest2",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"a1\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a2\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a3\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>")})));
	end VariableSortingTest2;
	
	model VariableSortingTest3
		parameter Real a11 = 2;
		parameter Real a111 = 3;
		parameter Real a1 = 1;
		parameter Real a1111 = 4;
		equation 

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="VariableSortingTest3",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"a1\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a11\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a111\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a1111\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"4.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>")})));
	end VariableSortingTest3;
	
	model VariableSortingTest4
		model A
			parameter Real b = 2;
			parameter Real a = 1;
			equation
		end A;
		
		model B
			parameter Real b = 2;
			parameter Real a = 1;
			equation
		end B;
		
		A a;
		B b;
		
	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="VariableSortingTest4",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"a.a\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.b\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"b.a\" valueReference=\"3\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"b.b\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>")})));
	end VariableSortingTest4;
	
	model VariableSortingTest5
    	Real x[11] = fill(1, 11);
  		equation
    		
	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="VariableSortingTest5",
			description="",
            eliminate_alias_variables=false,
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="
		<ScalarVariable name=\"x[1]\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[2]\" valueReference=\"1\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[3]\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[4]\" valueReference=\"3\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[5]\" valueReference=\"4\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[6]\" valueReference=\"5\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[7]\" valueReference=\"6\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[8]\" valueReference=\"7\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[9]\" valueReference=\"8\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[10]\" valueReference=\"9\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[11]\" valueReference=\"10\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
")})));
	end VariableSortingTest5;
	
	model VariableSortingTest6
		parameter Real a = 1;
		parameter Real b = 2;
		parameter Real z = 5;
	    Real x[2];
	    Real y[2];
  		equation
  			der(y[2]) = 2;
    		der(x[1]) = 3;
    		der(x[2]) = 4;
    		der(y[1]) = 1;

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="VariableSortingTest6",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="
<ScalarVariable name=\"a\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" start=\"1.0\" />
<isLinear>true</isLinear>
<VariableCategory>independentParameter</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"b\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" start=\"2.0\" />
<isLinear>true</isLinear>
<VariableCategory>independentParameter</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[1]\" valueReference=\"8\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>state</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"der(x[1])\" valueReference=\"4\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>derivative</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[2]\" valueReference=\"9\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>state</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"der(x[2])\" valueReference=\"5\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>derivative</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"y[1]\" valueReference=\"10\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>state</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"der(y[1])\" valueReference=\"6\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>derivative</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"y[2]\" valueReference=\"7\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>state</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"der(y[2])\" valueReference=\"3\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" />
<isLinear>true</isLinear>
<VariableCategory>derivative</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"z\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
<Real relativeQuantity=\"false\" start=\"5.0\" />
<isLinear>true</isLinear>
<VariableCategory>independentParameter</VariableCategory>
</ScalarVariable>
")})));
	end VariableSortingTest6;
	
	model VariableSortingTest7
		class A
			Real r[2];
 			class B 
 				Real x[2,2];
				class C
		  			Real y[2];
		  			equation
		  				y[1]=2;
		  				y[2]=3;
				end C;
		  		C c;
 			end B;
 			B b;
 			equation
 				b.x[1,1] = b.c.y[1];
    			b.x[1,2] = 2;
    			b.x[2,1] = b.c.y[2];
    			b.x[2,2] = 4;
		end A;
		A a;
		equation
			a.r[1] = a.b.x[1,1];
			a.r[2] = a.b.x[2,1];

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="VariableSortingTest7",
			description="",
            eliminate_alias_variables=false,
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="
		<ScalarVariable name=\"a.b.c.y[1]\" valueReference=\"6\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.b.c.y[2]\" valueReference=\"7\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.b.x[1,1]\" valueReference=\"2\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.b.x[1,2]\" valueReference=\"3\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.b.x[2,1]\" valueReference=\"4\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.b.x[2,2]\" valueReference=\"5\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"4.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.r[1]\" valueReference=\"0\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"2.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"a.r[2]\" valueReference=\"1\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentConstant</VariableCategory>
		</ScalarVariable>
")})));
	end VariableSortingTest7;

	model DirectDependencyTest1
  Real x[15];
  Real z[3];
  input Real u[4];
  output Real y1;
  output Real y2;
equation
  der(z) = -z;
  x[1] = u[1];
  x[2] = u[2];
  x[3] = u[3];
  x[4] = u[4];
  x[5] = x[1];
  x[6] = x[1] + x[2];
  x[7] = x[3];
  x[8] = x[3];
  x[9] = x[4];
  x[10] = x[5];
  x[11] = x[5];
  x[12] = x[1] + x[6];
  x[13] = x[7] + x[8];
  x[14] = x[8] + x[9];
  x[15] = x[12] + x[3];
  y1 = x[15] + x[1] + z[1];
  y2 = x[4] + sum(z);

    annotation(__JModelica(UnitTesting(tests={
        XMLCodeGenTestCase(
            name="DirectDependencyTest1",
            description="",
            equation_sorting=true,
            eliminate_alias_variables=false,
            generate_fmi_me_xml=false,
            template="$XML_variables$",
            generatedCode="
<ScalarVariable name=\"u[1]\" valueReference=\"6\" variability=\"continuous\" causality=\"input\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"u[2]\" valueReference=\"7\" variability=\"continuous\" causality=\"input\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"u[3]\" valueReference=\"8\" variability=\"continuous\" causality=\"input\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"u[4]\" valueReference=\"9\" variability=\"continuous\" causality=\"input\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[1]\" valueReference=\"10\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[2]\" valueReference=\"11\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[3]\" valueReference=\"12\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[4]\" valueReference=\"13\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[5]\" valueReference=\"14\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[6]\" valueReference=\"15\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[7]\" valueReference=\"16\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[8]\" valueReference=\"17\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[9]\" valueReference=\"18\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[10]\" valueReference=\"19\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[11]\" valueReference=\"20\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[12]\" valueReference=\"21\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[13]\" valueReference=\"22\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[14]\" valueReference=\"23\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"x[15]\" valueReference=\"24\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"y1\" valueReference=\"25\" variability=\"continuous\" causality=\"output\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<DirectDependency>
		<Name>u[2]</Name>
		<Name>u[1]</Name>
		<Name>u[3]</Name>
	</DirectDependency>
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"y2\" valueReference=\"26\" variability=\"continuous\" causality=\"output\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<DirectDependency>
		<Name>u[4]</Name>
	</DirectDependency>
	<isLinear>true</isLinear>
	<VariableCategory>algebraic</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"z[1]\" valueReference=\"3\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>state</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"der(z[1])\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>derivative</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"z[2]\" valueReference=\"4\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>state</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"der(z[2])\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>derivative</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"z[3]\" valueReference=\"5\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>state</VariableCategory>
</ScalarVariable>
<ScalarVariable name=\"der(z[3])\" valueReference=\"2\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
	<Real relativeQuantity=\"false\" />
	<isLinear>true</isLinear>
	<VariableCategory>derivative</VariableCategory>
</ScalarVariable>
")})));
end DirectDependencyTest1;

    model DirectDependencyTest2
        input Real x;
        output Boolean b = x > 0;
        output Integer i = integer(x);

    annotation(__JModelica(UnitTesting(tests={
        XMLCodeGenTestCase(
            name="DirectDependencyTest2",
            description="Generate direct dependencies for non-real variables",
            equation_sorting=true,
            eliminate_alias_variables=false,
            generate_fmi_me_xml=false,
            template="$XML_variables$",
            generatedCode="
        <ScalarVariable name=\"b\" valueReference=\"536870917\" variability=\"discrete\" causality=\"output\" alias=\"noAlias\">
            <Boolean />
            <DirectDependency>
                <Name>x</Name>
            </DirectDependency>
            <isLinear>true</isLinear>
            <VariableCategory>algebraic</VariableCategory>
        </ScalarVariable>
        <ScalarVariable name=\"i\" valueReference=\"268435459\" variability=\"discrete\" causality=\"output\" alias=\"noAlias\">
            <Integer />
            <DirectDependency>
                <Name>x</Name>
            </DirectDependency>
            <isLinear>true</isLinear>
            <VariableCategory>algebraic</VariableCategory>
        </ScalarVariable>
        <ScalarVariable name=\"temp_1\" valueReference=\"268435460\" variability=\"discrete\" causality=\"internal\" alias=\"noAlias\">
            <Integer />
            <isLinear>true</isLinear>
            <VariableCategory>algebraic</VariableCategory>
        </ScalarVariable>
        <ScalarVariable name=\"x\" valueReference=\"0\" variability=\"continuous\" causality=\"input\" alias=\"noAlias\">
            <Real relativeQuantity=\"false\" start=\"0.0\" fixed=\"false\" />
            <isLinear>true</isLinear>
            <VariableCategory>algebraic</VariableCategory>
        </ScalarVariable>
")})));
end DirectDependencyTest2;


model NonConstantStart1
    Real x(start = 1 + a[b]);
    parameter Real a[2] = { 1, 2 };
    parameter Integer b = 1;
equation
    der(x) = x;

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="NonConstantStart1",
			description="Check that only constant start valued are included in XML file",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="
        <ScalarVariable name=\"a[1]\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
            <Real relativeQuantity=\"false\" start=\"1.0\" />
            <isLinear>true</isLinear>
            <VariableCategory>independentParameter</VariableCategory>
        </ScalarVariable>
        <ScalarVariable name=\"a[2]\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
            <Real relativeQuantity=\"false\" start=\"2.0\" />
            <isLinear>true</isLinear>
            <VariableCategory>independentParameter</VariableCategory>
        </ScalarVariable>
        <ScalarVariable name=\"b\" valueReference=\"268435458\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
            <Integer start=\"1\" />
            <isLinear>true</isLinear>
            <VariableCategory>independentParameter</VariableCategory>
        </ScalarVariable>
        <ScalarVariable name=\"x\" valueReference=\"4\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
            <Real relativeQuantity=\"false\" />
            <isLinear>true</isLinear>
            <VariableCategory>state</VariableCategory>
        </ScalarVariable>
        <ScalarVariable name=\"der(x)\" valueReference=\"3\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
            <Real relativeQuantity=\"false\" />
            <isLinear>true</isLinear>
            <VariableCategory>derivative</VariableCategory>
        </ScalarVariable>
")})));
end NonConstantStart1;

model FixedAndStart1
  Real x(start=2,fixed=true);
equation
 der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="FixedAndStart1",
			description="Check that neither start nor fixed are generated when start is converted to an initial equation.",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"x\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>state</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"der(x)\" valueReference=\"0\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>derivative</VariableCategory>
		</ScalarVariable>
")})));
end FixedAndStart1;

model FixedAndStart2
  parameter Real p = 3;
  Real x(start=p,fixed=true);
equation
 der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="FixedAndStart2",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"p\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"3.0\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x\" valueReference=\"2\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>state</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"der(x)\" valueReference=\"1\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>derivative</VariableCategory>
		</ScalarVariable>
")})));
end FixedAndStart2;

model FixedAndStart3
  parameter Integer N1 = 2;
  parameter Integer N2 = 1;
  parameter Integer N3 = N1 + N2;
  parameter Boolean b[3] = array((if i<=N2 then false else true) for i in 1:3);
  Real x[3](each start=1, fixed=b);
equation
  der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="FixedAndStart3",
			description="",
			generate_fmi_me_xml=false,
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"N1\" valueReference=\"268435456\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Integer start=\"2\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"N2\" valueReference=\"268435457\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Integer start=\"1\" />
			<isLinear>true</isLinear>
			<VariableCategory>independentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"N3\" valueReference=\"268435458\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Integer />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"b[1]\" valueReference=\"536870915\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Boolean />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"b[2]\" valueReference=\"536870916\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Boolean />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"b[3]\" valueReference=\"536870917\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Boolean />
			<isLinear>true</isLinear>
			<VariableCategory>dependentParameter</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[1]\" valueReference=\"9\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" fixed=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>state</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"der(x[1])\" valueReference=\"6\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>derivative</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[2]\" valueReference=\"10\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>state</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"der(x[2])\" valueReference=\"7\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>derivative</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"x[3]\" valueReference=\"11\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>state</VariableCategory>
		</ScalarVariable>
		<ScalarVariable name=\"der(x[3])\" valueReference=\"8\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
			<isLinear>true</isLinear>
			<VariableCategory>derivative</VariableCategory>
		</ScalarVariable>
")})));
end FixedAndStart3;

model FixedAndStart4
	parameter Real a = 1;
	parameter Real b(start=5); 
	parameter Real c(start=2) = a + b;	

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="FixedAndStart4",
			description="Test that start attributes are not generated for dependent parameters.",
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"a\" valueReference=\"0\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"1.0\" />
		</ScalarVariable>
		<ScalarVariable name=\"b\" valueReference=\"1\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" start=\"5.0\" />
		</ScalarVariable>
		<ScalarVariable name=\"c\" valueReference=\"2\" variability=\"parameter\" causality=\"internal\" alias=\"noAlias\">
			<Real relativeQuantity=\"false\" />
		</ScalarVariable>
")})));
end FixedAndStart4;

model Experiment1
    Real x = 1;
    
    annotation(
        experiment(StartTime=1, StopTime=2, Tolerance=1e-7),
        __JModelica(UnitTesting(tests={XMLCodeGenTestCase(
            name="Experiment1",
            description="Full experiment annotation",
            template="$XML_defaultExperiment$",
            generatedCode="
<DefaultExperiment startTime=\"1.0\" stopTime=\"2.0\" tolerance=\"1.0E-7\" />
")})));
end Experiment1;


model Experiment2
    Real x = 1;
    
    annotation(
        experiment(StopTime=5),
        __JModelica(UnitTesting(tests={XMLCodeGenTestCase(
            name="Experiment2",
            description="Partial experiment annotation",
            template="$XML_defaultExperiment$",
            generatedCode="
<DefaultExperiment stopTime=\"5.0\" />
")})));
end Experiment2;

model SpecialCharacter1
 Real xy(quantity="Test & comment", unit="kg & mJ") = 1 "x & y";

	annotation(__JModelica(UnitTesting(tests={
		XMLCodeGenTestCase(
			name="SpecialCharacter1",
			description="Test that the special character ampersand is generated correctly in the XML code.",
			template="$XML_variables$",
			generatedCode="

		<ScalarVariable name=\"xy\" valueReference=\"0\" description=\"x &amp; y\" variability=\"constant\" causality=\"internal\" alias=\"noAlias\">
			<Real quantity=\"Test &amp; comment\" unit=\"kg &amp; mJ\"  relativeQuantity=\"false\" start=\"1.0\" />
		</ScalarVariable>
")})));
end SpecialCharacter1;

model Comment1
  Real x = time "A \comment \t\\without\\\ backslashes\\\\.";
  annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Comment1",
            description="Verifies that backslashes do not exist in the description attribute of a model variable.",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"0\" description=\"A comment    without backslashes.\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Comment1;

model Comment2
  Real x = time "A \&comment\" \'with \<escaped \>characters\\.";
  annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Comment2",
            description="Verifies that XML special characters preceded by backslash(es) are generated correctly.",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"0\" description=\"A &amp;comment&quot; &apos;with &lt;escaped &gt;characters.\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Comment2;

model Comment3
    Real x = time "\"A comment.\\\"";
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Comment3",
            description="Verifies that citation marks surrounding a comment are preserved.",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"0\" description=\"&quot;A comment.&quot;\" variability=\"continuous\" causality=\"internal\" alias=\"noAlias\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Comment3;

model Comment4
    Real x = time "\\\"A \&comment\" \'with \<escaped \>characters\\.\"";
    annotation(__JModelica(UnitTesting(tests={
        FmiXMLCodeGenTestCase(
            name="Comment4",
            description="Extra comment generation check for FMI 2.0.",
            fmi_version="2.0",
            template="$modelVariables$",
            generatedCode="
<ModelVariables>
    <!-- Variable with index #1 -->
    <ScalarVariable name=\"x\" valueReference=\"0\" description=\"&quot;A &amp;comment&quot; &apos;with &lt;escaped &gt;characters.&quot;\" causality=\"local\" variability=\"continuous\" initial=\"calculated\">
        <Real relativeQuantity=\"false\" />
    </ScalarVariable>
</ModelVariables>
")})));
end Comment4;

model CommentFlattening1
    Real x = time "\&\<\>\'\" \\&\\<\\>\\' \\\&\\\<\\\>\\\'\\\"";
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="CommentFlattening1",
            description="Verifies that comment flattening removes backslashes from characters to be escaped for XML.",
            flatModel="
fclass XMLCodeGenTests.CommentFlattening1
  Real x = time \"&<>'\" &<>' &<>'\"\";
end XMLCodeGenTests.CommentFlattening1;
")})));
end CommentFlattening1;

model CommentFlattening2
    Real x = time "\'\"\b\f\n\t\r \\'\\b\\f\\n\\t\\r \\\'\\\"\\\b\\\f\\\n\\\t\\\r";
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="CommentFlattening2",
            description="Verifies that comment flattening removes backslashes from general characters to be escaped.",
            flatModel="
fclass XMLCodeGenTests.CommentFlattening2
 Real x = time \"'\"\b\f\n\t\r 'bfntr '\"\b\f\n\t\r\";
end XMLCodeGenTests.CommentFlattening2;
")})));
end CommentFlattening2;

end XMLCodeGenTests;
