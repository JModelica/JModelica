/*
    Copyright (C) 2017 Modelon AB

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
package ComponentCountTests
    model Simple1
        Real x;
        Real y;
    equation
        x = y * 2;
        y = time;
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Simple1",
            methodName="numberOfComponents",
            description="Test the component count feature",
            methodResult="0"
    )})));
    end Simple1;

    model Simple2
        model A
            Real x;
            Real y;
        equation
            x = y * 2;
            y = time;
        end A;
        
        A a;
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Simple2",
            methodName="numberOfComponents",
            description="Test the component count feature with a component",
            methodResult="1"
    )})));
    end Simple2;

    model Simple3
        model A
            Real x;
            Real y;
        equation
            x = y * 2;
            y = time;
        end A;
        
        A a[2];
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Simple3",
            methodName="numberOfComponents",
            description="Test the component count feature with arrays",
            methodResult="2"
    )})));
    end Simple3;

    model Simple4
        record R
            parameter Real x;
            Real y;
        end R;
        
        R r[2];
    equation
        r[1].y = r[2].y * r[1].x;
        r[2].y = time;
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Simple4",
            methodName="numberOfComponents",
            description="Test the component count feature with record arrays",
            methodResult="0"
    )})));
    end Simple4;

    model Simple5
        class A
            Real x;
            Real y;
        equation
            x = y * 2;
            y = time;
        end A;
        class B
            constant Integer n = 2;
            A a[n];
        end B;
        
        B[2] b(n=4);
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Simple5",
            methodName="numberOfComponents",
            description="Test the component count feature with nestled arrays",
            methodResult="10"
    )})));
    end Simple5;

    model Conditional1
        model A
            Real x = time;
        end A;
        
        A a if b;
        parameter Boolean b = false;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Conditional1",
            methodName="numberOfComponents",
            description="Test the component count feature with conditional component",
            methodResult="0"
    )})));
    end Conditional1;

    model Conditional2
        model A
            Real x = time;
        end A;
        
        A a if b;
        parameter Boolean b = true;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Conditional2",
            methodName="numberOfComponents",
            description="Test the component count feature with conditional component",
            methodResult="1"
    )})));
    end Conditional2;

    model Connect1
        connector Ca
            Real y;
        end Ca;
    
        connector Cb
            Real y;
        end Cb;
        
        model C2
            Ca ca;
            Cb cb;
        equation
            connect(ca,cb);
            ca.y = time;
        end C2;
        
        C2 c2;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Connect1",
            methodName="numberOfComponents",
            description="Test the component count feature with connectors",
            methodResult="1"
    )})));
    end Connect1;

    model Connect2
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c1, c2;
    equation
        connect(c1, ec1.a);
        connect(ec1, ec2.nec);
        connect(ec2.nec, ec3);
        connect(ec3.a, c2);
        c1 = time;

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Connect2",
            methodName="numberOfComponents",
            description="Test the component count feature with nested expandable connectors",
            methodResult="0"
    )})));
    end Connect2;

    model InnerOuter1
        model A
            Real x;
        end A;
        model B
            outer A a;
            Real x = 2*a.x;
        end B;
        model C
            inner A a(x=sin(time));
            B b;
        end C;
        C c;
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="InnerOuter1",
            methodName="numberOfComponents",
            description="Test the component count feature with inner and outer",
            methodResult="3"
    )})));
    end InnerOuter1;

    model InnerOuter2
        model A
            Real x = sin(time);
        end A;
        model B
            outer A a;
            Real x = 2*a.x;
        end B;
        B b;
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="InnerOuter2",
            methodName="numberOfComponents",
            description="Test the component count feature with automatic addition inner component",
            methodResult="2"
    )})));
    end InnerOuter2;

    model InnerOuter3
        model A
            Real x;
        end A;
        model B
            outer A a;
            Real x = 2*a.x;
        end B;
        model C
            inner A a(x=sin(time));
            B b1;
            B b2;
        end C;
        C c;
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="InnerOuter3",
            methodName="numberOfComponents",
            description="Test the component count feature with inner and outer",
            methodResult="4"
    )})));
    end InnerOuter3;

    model Redeclare1
        model A
            Real x=1;
        end A;
 
        model B
            Real x=2;
            Real y=3;
        end B;
 
        model C
            replaceable A a;
        end C;
 
        C c(redeclare B a);
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Redeclare1",
            methodName="numberOfComponents",
            description="Test the component count feature with redeclared component",
            methodResult="2"
    )})));
    end Redeclare1;

    model Redeclare2
        model A
            Real x=1;
        end A;
        
        model B
            A a1;
        end B;
 
        model C
            A a1;
            A a2;
        end C;
 
        model D
            replaceable B b;
        end D;
 
        D d(redeclare C b);
        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="Redeclare2",
            methodName="numberOfComponents",
            description="Test the component count feature with redeclared component",
            methodResult="4"
    )})));
    end Redeclare2;

    model System1
        Modelica.Electrical.Analog.Basic.Resistor resistor1;
        Modelica.Electrical.Analog.Basic.Capacitor capacitor1;
        Modelica.Electrical.Analog.Basic.Ground ground1;
        Modelica.Electrical.Analog.Sources.ConstantVoltage constantvoltage1;
    equation
        connect(constantvoltage1.n, ground1.p);
        connect(constantvoltage1.p, resistor1.p);
        connect(ground1.p, capacitor1.n);
        connect(resistor1.n, capacitor1.p);

        
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="System1",
            methodName="numberOfComponents",
            description="Test the component count feature with a real model",
            methodResult="4"
    )})));
    end System1;

end ComponentCountTests;
