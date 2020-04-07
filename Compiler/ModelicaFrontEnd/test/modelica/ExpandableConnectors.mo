/*
    Copyright (C) 2013 Modelon AB

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

within;

package ExpandableConnectors

    model Expandable1
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1, ec2, ec3;
        C c1, c2;
    equation
        connect(c1, ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c2);
        c1 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable1",
            description="Basic test of expandable connectors",
            flatModel="
fclass ExpandableConnectors.Expandable1
 Real ec1.a;
 Real ec2.a;
 Real ec3.a;
 Real c1;
 Real c2;
equation
 c1 = time;
 c1 = c2;
 c2 = ec1.a;
 ec1.a = ec2.a;
 ec2.a = ec3.a;
end ExpandableConnectors.Expandable1;
")})));
    end Expandable1;


    model Expandable2
        expandable connector EC
        end EC;

        connector C
            Real a;
            flow Real b;
        end C;

        EC ec1, ec2, ec3;
        C c1, c2, c3, c4, c5;
    equation
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(c1, ec1.x);
        connect(c2, ec1.y);
        connect(ec3.x, c3);
        connect(ec3.y, c4);
        connect(ec2.x, c5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable2",
            description="Expandable connectors: adding composite connectors",
            flatModel="
fclass ExpandableConnectors.Expandable2
 Real ec1.x.a;
 Real ec1.x.b;
 Real ec1.y.a;
 Real ec1.y.b;
 Real ec2.x.a;
 Real ec2.x.b;
 Real ec2.y.a;
 Real ec2.y.b;
 Real ec3.x.a;
 Real ec3.x.b;
 Real ec3.y.a;
 Real ec3.y.b;
 potential Real c1.a;
 flow Real c1.b;
 potential Real c2.a;
 flow Real c2.b;
 potential Real c3.a;
 flow Real c3.b;
 potential Real c4.a;
 flow Real c4.b;
 potential Real c5.a;
 flow Real c5.b;
equation
 c1.a = c3.a;
 c3.a = c5.a;
 c5.a = ec1.x.a;
 ec1.x.a = ec2.x.a;
 ec2.x.a = ec3.x.a;
 - c1.b - c3.b - c5.b - ec1.x.b - ec2.x.b - ec3.x.b = 0.0;
 c2.a = c4.a;
 c4.a = ec1.y.a;
 ec1.y.a = ec2.y.a;
 ec2.y.a = ec3.y.a;
 - c2.b - c4.b - ec1.y.b - ec2.y.b - ec3.y.b = 0.0;
 ec1.x.b = 0.0;
 ec1.y.b = 0.0;
 ec2.x.b = 0.0;
 ec2.y.b = 0.0;
 ec3.x.b = 0.0;
 ec3.y.b = 0.0;
end ExpandableConnectors.Expandable2;
")})));
    end Expandable2;


    model Expandable3
        expandable connector EC
        end EC;

        connector C = Real[2];

        model M
            EC ec1, ec2, ec3;
            C c1, c2;
        equation
            connect(c1, ec1.a);
            connect(ec1, ec2);
            connect(ec2, ec3);
            connect(ec3.a, c2);
        end M;

        M m[2];

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable3",
            description="Expandable connectors: adding entire array without subscripts, within array component",
            flatModel="
fclass ExpandableConnectors.Expandable3
 ExpandableConnectors.Expandable3.C m[1].ec1.a[2];
 ExpandableConnectors.Expandable3.C m[1].ec2.a[2];
 ExpandableConnectors.Expandable3.C m[1].ec3.a[2];
 ExpandableConnectors.Expandable3.C m[1].c1[2];
 ExpandableConnectors.Expandable3.C m[1].c2[2];
 ExpandableConnectors.Expandable3.C m[2].ec1.a[2];
 ExpandableConnectors.Expandable3.C m[2].ec2.a[2];
 ExpandableConnectors.Expandable3.C m[2].ec3.a[2];
 ExpandableConnectors.Expandable3.C m[2].c1[2];
 ExpandableConnectors.Expandable3.C m[2].c2[2];
equation
 m[1].c1[1] = m[1].c2[1];
 m[1].c2[1] = m[1].ec1.a[1];
 m[1].ec1.a[1] = m[1].ec2.a[1];
 m[1].ec2.a[1] = m[1].ec3.a[1];
 m[1].c1[2] = m[1].c2[2];
 m[1].c2[2] = m[1].ec1.a[2];
 m[1].ec1.a[2] = m[1].ec2.a[2];
 m[1].ec2.a[2] = m[1].ec3.a[2];
 m[2].c1[1] = m[2].c2[1];
 m[2].c2[1] = m[2].ec1.a[1];
 m[2].ec1.a[1] = m[2].ec2.a[1];
 m[2].ec2.a[1] = m[2].ec3.a[1];
 m[2].c1[2] = m[2].c2[2];
 m[2].c2[2] = m[2].ec1.a[2];
 m[2].ec1.a[2] = m[2].ec2.a[2];
 m[2].ec2.a[2] = m[2].ec3.a[2];

public
 type ExpandableConnectors.Expandable3.C = Real;
end ExpandableConnectors.Expandable3;
")})));
    end Expandable3;


    model Expandable4
        expandable connector EC
        end EC;

        model A
            replaceable EC ec;
        end A;

        connector C = Real;

        A a1(redeclare EC ec);
        A a2(redeclare EC ec);
        A a3(redeclare EC ec);
        C c1, c2;
    equation
        connect(c1, a1.ec.b);
        connect(a1.ec, a2.ec);
        connect(a2.ec, a3.ec);
        connect(a3.ec.b, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable4",
            description="Added support for redeclaring expandable connectors",
            flatModel="
fclass ExpandableConnectors.Expandable4
 Real a1.ec.b;
 Real a2.ec.b;
 Real a3.ec.b;
 Real c1;
 Real c2;
equation
 a1.ec.b = a2.ec.b;
 a2.ec.b = a3.ec.b;
 a3.ec.b = c1;
 c1 = c2;
end ExpandableConnectors.Expandable4;
")})));
    end Expandable4;


    model Expandable5
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1, ec2, ec3;
        C c1 = 1;
        C c2;
    equation
        connect(c1, ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable5",
            description="Adding to expandable connectors from var with binding exp",
            flatModel="
fclass ExpandableConnectors.Expandable5
 Real ec1.a;
 Real ec2.a;
 Real ec3.a;
 Real c1 = 1;
 Real c2;
equation
 c1 = c2;
 c2 = ec1.a;
 ec1.a = ec2.a;
 ec2.a = ec3.a;
end ExpandableConnectors.Expandable5;
")})));
    end Expandable5;


    model Expandable5b
        expandable connector EC
        end EC;

        connector C
            Real x;
            Real y;
        end C;

        EC ec1, ec2, ec3;
        C c1(x = 1, y = 2);
        C c2;
    equation
        connect(c1, ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable5b",
            description="Adding to expandable connectors from composite with binding exps",
            flatModel="
fclass ExpandableConnectors.Expandable5b
 Real ec1.a.x;
 Real ec1.a.y;
 Real ec2.a.x;
 Real ec2.a.y;
 Real ec3.a.x;
 Real ec3.a.y;
 potential Real c1.x = 1;
 potential Real c1.y = 2;
 potential Real c2.x;
 potential Real c2.y;
equation
 c1.x = c2.x;
 c2.x = ec1.a.x;
 ec1.a.x = ec2.a.x;
 ec2.a.x = ec3.a.x;
 c1.y = c2.y;
 c2.y = ec1.a.y;
 ec1.a.y = ec2.a.y;
 ec2.a.y = ec3.a.y;
end ExpandableConnectors.Expandable5b;
")})));
    end Expandable5b;


    model Expandable6
        expandable connector EC
        end EC;

        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c[2];
    equation
        connect(c[1], ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c[2]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable6",
            description="Expandable connectors: connect to single element in array",
            flatModel="
fclass ExpandableConnectors.Expandable6
 Real ec1.a;
 Real ec2.a;
 Real ec3.a;
 Real c[2];
equation
 c[1] = c[2];
 c[2] = ec1.a;
 ec1.a = ec2.a;
 ec2.a = ec3.a;
end ExpandableConnectors.Expandable6;
")})));
    end Expandable6;


    model Expandable7
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1, ec2, ec3;
        C c[4];
    equation
        connect(c[1:2], ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c[3:4]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable7",
            description="Expandable connectors: connect to slice",
            flatModel="
fclass ExpandableConnectors.Expandable7
 Real ec1.a[2];
 Real ec2.a[2];
 Real ec3.a[2];
 Real c[4];
equation
 c[1] = c[3];
 c[3] = ec1.a[1];
 ec1.a[1] = ec2.a[1];
 ec2.a[1] = ec3.a[1];
 c[2] = c[4];
 c[4] = ec1.a[2];
 ec1.a[2] = ec2.a[2];
 ec2.a[2] = ec3.a[2];
end ExpandableConnectors.Expandable7;
")})));
    end Expandable7;


    model Expandable8
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1, ec2, ec3;
        C c1, c2, c3, c4;
    equation
        connect(c1, ec1.a[1]);
        connect(c2, ec1.a[2]);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a[1], c3);
        connect(ec3.a[2], c4);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable8",
            description="Connecting to cell of array in expandable connector",
            flatModel="
fclass ExpandableConnectors.Expandable8
 Real ec1.a[2];
 Real ec2.a[2];
 Real ec3.a[2];
 Real c1;
 Real c2;
 Real c3;
 Real c4;
equation
 c1 = c3;
 c3 = ec1.a[1];
 ec1.a[1] = ec2.a[1];
 ec2.a[1] = ec3.a[1];
 c2 = c4;
 c4 = ec1.a[2];
 ec1.a[2] = ec2.a[2];
 ec2.a[2] = ec3.a[2];
end ExpandableConnectors.Expandable8;
")})));
    end Expandable8;


    model Expandable9
        connector C = Real;

        expandable connector EC
            C x;
        end EC;

        EC ec1, ec2;
        C x = time;
    equation
        connect(ec1.x, ec2.x);
        connect(ec1.x, x);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable9",
            description="Connecting two declared members of expandable connectors",
            flatModel="
fclass ExpandableConnectors.Expandable9
 Real ec1.x;
 Real ec2.x;
 Real x = time;
equation
 ec1.x = ec2.x;
 ec2.x = x;
end ExpandableConnectors.Expandable9;
")})));
    end Expandable9;


    model Expandable10
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1, ec2, ec3;
        C c1[5], c2[5];
    equation
        connect(c1[1:2], ec1.a[1:2:3]);
        connect(c1[3:4], ec1.a[2:2:4]);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a[1:2:3], c2[1:2]);
        connect(ec3.a[2:2:4], c2[3:4]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable10",
            description="Connecting to slice of array in expandable connector",
            flatModel="
fclass ExpandableConnectors.Expandable10
 Real ec1.a[4];
 Real ec2.a[4];
 Real ec3.a[4];
 Real c1[5];
 Real c2[5];
equation
 c1[1] = c2[1];
 c2[1] = ec1.a[1];
 ec1.a[1] = ec2.a[1];
 ec2.a[1] = ec3.a[1];
 c1[2] = c2[2];
 c2[2] = ec1.a[3];
 ec1.a[3] = ec2.a[3];
 ec2.a[3] = ec3.a[3];
 c1[3] = c2[3];
 c2[3] = ec1.a[2];
 ec1.a[2] = ec2.a[2];
 ec2.a[2] = ec3.a[2];
 c1[4] = c2[4];
 c2[4] = ec1.a[4];
 ec1.a[4] = ec2.a[4];
 ec2.a[4] = ec3.a[4];
end ExpandableConnectors.Expandable10;
")})));
    end Expandable10;


    model Expandable11
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1, ec2;
        C c1[2], c2[2,2];
    equation
        connect(ec1, ec2);
        connect(ec1.a[1,:], c1);
        connect(ec1.b[:,1:2], c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable11",
            description="Connecting to slice with colon of array in expandable connector",
            flatModel="
fclass ExpandableConnectors.Expandable11
 Real ec1.a[1,2];
 Real ec1.b[2,2];
 Real ec2.a[1,2];
 Real ec2.b[2,2];
 Real c1[2];
 Real c2[2,2];
equation
 c1[1] = ec1.a[1,1];
 ec1.a[1,1] = ec2.a[1,1];
 c1[2] = ec1.a[1,2];
 ec1.a[1,2] = ec2.a[1,2];
 c2[1,1] = ec1.b[1,1];
 ec1.b[1,1] = ec2.b[1,1];
 c2[1,2] = ec1.b[1,2];
 ec1.b[1,2] = ec2.b[1,2];
 c2[2,1] = ec1.b[2,1];
 ec1.b[2,1] = ec2.b[2,1];
 c2[2,2] = ec1.b[2,2];
 ec1.b[2,2] = ec2.b[2,2];
end ExpandableConnectors.Expandable11;
")})));
    end Expandable11;


    model Expandable12
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c1[3], c2;
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a[3]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable12",
            description="Connecting to entire array and to single element",
            flatModel="
fclass ExpandableConnectors.Expandable12
 Real ec1.a[3];
 Real c1[3];
 Real c2;
equation
 c1[1] = ec1.a[1];
 c1[2] = ec1.a[2];
 c1[3] = c2;
 c2 = ec1.a[3];
end ExpandableConnectors.Expandable12;
")})));
    end Expandable12;


    model Expandable13
        expandable connector EC
            Real x;
            Real y;
        end EC;

        connector C = Real;

        EC ec;
        C c;
    equation
        connect(c, ec.x);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable13",
            description="Expandable connector with members",
            flatModel="
fclass ExpandableConnectors.Expandable13
 Real ec.x;
 Real c;
equation
 c = ec.x;
end ExpandableConnectors.Expandable13;
")})));
    end Expandable13;


    model Expandable14
        expandable connector EC
            Real a[3];
        end EC;

        connector C = Real;

        EC ec;
        C c[3];
    equation
        connect(c, ec.a);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable14",
            description="Expandable connector with members: array",
            flatModel="
fclass ExpandableConnectors.Expandable14
 Real ec.a[3];
 Real c[3];
equation
 c[1] = ec.a[1];
 c[2] = ec.a[2];
 c[3] = ec.a[3];
end ExpandableConnectors.Expandable14;
")})));
    end Expandable14;


    model Expandable15
        expandable connector EC
            C a;
        end EC;

        connector C
            Real x;
            Real y;
        end C;

        EC ec;
        C c;
    equation
        connect(c, ec.a);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable15",
            description="Expandable connector with members: composite",
            flatModel="
fclass ExpandableConnectors.Expandable15
 Real ec.a.x;
 Real ec.a.y;
 potential Real c.x;
 potential Real c.y;
equation
 c.x = ec.a.x;
 c.y = ec.a.y;
end ExpandableConnectors.Expandable15;
")})));
    end Expandable15;


    model Expandable16
        expandable connector EC
            Real x;
        end EC;

        connector C = Real;

        C c;
        EC ec;
        Real y;
    equation
        connect(c, ec.x);
        y = ec.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable16",
            description="Using member of expandable connector that is connected to",
            flatModel="
fclass ExpandableConnectors.Expandable16
 Real c;
 Real ec.x;
 Real y;
equation
 y = ec.x;
 c = ec.x;
end ExpandableConnectors.Expandable16;
")})));
    end Expandable16;


    model Expandable17
        expandable connector EC
            Real x;
        end EC;
        
        connector C = Real;
        
        C c;
        EC ec;
        Real y = ec.x;
    equation
        connect(c, ec.x);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable17",
            description="Using member of expandable connector that is connected to",
            flatModel="
fclass ExpandableConnectors.Expandable17
 Real c;
 Real ec.x;
 Real y = ec.x;
equation
 c = ec.x;
end ExpandableConnectors.Expandable17;
")})));
    end Expandable17;


    model Expandable18
        expandable connector EC
            Real x;
        end EC;
        
        model A
            Real y;
        end A;
        
        connector C = Real;
        
        C c;
        EC ec;
        A a(y = ec.x);
    equation
        connect(c, ec.x);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable18",
            description="Using member of expandable connector that is connected to",
            flatModel="
fclass ExpandableConnectors.Expandable18
 Real c;
 Real ec.x;
 Real a.y = ec.x;
equation
 c = ec.x;
end ExpandableConnectors.Expandable18;
")})));
    end Expandable18;


    model Expandable19
        expandable connector EC1
            Real x;
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        C c;
        EC1 ec1a, ec1b;
        EC2 ec2;
        Real y;
    equation
        connect(ec1a, ec1b);
        connect(ec1b, ec2);
        connect(c, ec2.x);
        y = ec1b.x;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable19",
            description="Using member of expandable connector that is connected to",
            flatModel="
fclass ExpandableConnectors.Expandable19
 Real c;
 Real ec1a.x;
 Real ec1b.x;
 Real ec2.x;
 Real y;
equation
 y = ec1b.x;
 c = ec1a.x;
 ec1a.x = ec1b.x;
 ec1b.x = ec2.x;
end ExpandableConnectors.Expandable19;
")})));
    end Expandable19;


    model Expandable20
        expandable connector EC1
            Real x;
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        C c;
        EC1 ec1a, ec1b;
        EC2 ec2;
        Real y = ec1b.x;
    equation
        connect(ec1a, ec1b);
        connect(ec1b, ec2);
        connect(c, ec2.x);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable20",
            description="Using member of expandable connector that is connected to",
            flatModel="
fclass ExpandableConnectors.Expandable20
 Real c;
 Real ec1a.x;
 Real ec1b.x;
 Real ec2.x;
 Real y = ec1b.x;
equation
 c = ec1a.x;
 ec1a.x = ec1b.x;
 ec1b.x = ec2.x;
end ExpandableConnectors.Expandable20;
")})));
    end Expandable20;


    model Expandable21
        expandable connector EC1
            Real x;
        end EC1;

        expandable connector EC2
        end EC2;

        model A
            Real y;
        end A;

        connector C = Real;

        C c;
        EC1 ec1a, ec1b;
        EC2 ec2;
        A a(y = ec1b.x);
    equation
        connect(ec1a, ec1b);
        connect(ec1b, ec2);
        connect(c, ec2.x);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable21",
            description="Using member of expandable connector that is connected to",
            flatModel="
fclass ExpandableConnectors.Expandable21
 Real c;
 Real ec1a.x;
 Real ec1b.x;
 Real ec2.x;
 Real a.y = ec1b.x;
equation
 c = ec1a.x;
 ec1a.x = ec1b.x;
 ec1b.x = ec2.x;
end ExpandableConnectors.Expandable21;
")})));
    end Expandable21;


    model Expandable22
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec;
        C c;
    equation
        connect(c, ec.x[2]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable22",
            description="Expandable connectors: Connecting to only some elements of array",
            flatModel="
fclass ExpandableConnectors.Expandable22
 Real ec.x[2];
 Real c;
equation
 c = ec.x[2];
 ec.x[1] = 0.0;
end ExpandableConnectors.Expandable22;
")})));
    end Expandable22;


    model Expandable23
        expandable connector EC
            Real x[3];
        end EC;

        connector C = Real;

        EC ec;
        C c;
    equation
        connect(c, ec.x[2]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable23",
            description="Expandable connectors: Connecting to only some elements of array",
            flatModel="
fclass ExpandableConnectors.Expandable23
 Real ec.x[3];
 Real c;
equation
 c = ec.x[2];
 ec.x[1] = 0.0;
 ec.x[3] = 0.0;
end ExpandableConnectors.Expandable23;
")})));
    end Expandable23;
    

    model Expandable24
        expandable connector EC
        end EC;

        connector C
            Real x;
            Real y;
        end C;

        EC ec;
        C c;
    equation
        connect(c, ec.x[2]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable24",
            description="Expandable connectors: Connecting to only some elements of array",
            flatModel="
fclass ExpandableConnectors.Expandable24
 Real ec.x[1].x;
 Real ec.x[1].y;
 Real ec.x[2].x;
 Real ec.x[2].y;
 potential Real c.x;
 potential Real c.y;
equation
 c.x = ec.x[2].x;
 c.y = ec.x[2].y;
 ec.x[1].x = 0.0;
 ec.x[1].y = 0.0;
end ExpandableConnectors.Expandable24;
")})));
    end Expandable24;


    model Expandable25
        expandable connector EC
            C x[3];
        end EC;

        connector C
            Real x;
            Real y;
        end C;

        EC ec;
        C c;
    equation
        connect(c, ec.x[2]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable25",
            description="Expandable connectors: Connecting to only some elements of array",
            flatModel="
fclass ExpandableConnectors.Expandable25
 Real ec.x[1].x;
 Real ec.x[1].y;
 Real ec.x[2].x;
 Real ec.x[2].y;
 Real ec.x[3].x;
 Real ec.x[3].y;
 potential Real c.x;
 potential Real c.y;
equation
 c.x = ec.x[2].x;
 c.y = ec.x[2].y;
 ec.x[1].x = 0.0;
 ec.x[1].y = 0.0;
 ec.x[3].x = 0.0;
 ec.x[3].y = 0.0;
end ExpandableConnectors.Expandable25;
")})));
    end Expandable25;


    model Expandable26
        expandable connector EC1
            EC2 ec2;
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        EC1 ec1;
        C c;
    equation
        connect(c, ec1.ec2.a);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable26",
            description="Nested declared expandable connectors: basic test",
            flatModel="
fclass ExpandableConnectors.Expandable26
 Real ec1.ec2.a;
 Real c;
equation
 c = ec1.ec2.a;
end ExpandableConnectors.Expandable26;
")})));
    end Expandable26;


    model Expandable27
        expandable connector EC1
            C1 c1;
        end EC1;

        connector C1
            EC2 ec2;
            Real x;
        end C1;

        expandable connector EC2
        end EC2;

        connector C2 = Real;

        EC1 ec1;
        C2 c2;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable27",
            description="Nested declared expandable connectors: not connected to",
            flatModel="
fclass ExpandableConnectors.Expandable27
 Real c2;
end ExpandableConnectors.Expandable27;
")})));
    end Expandable27;


    model Expandable28
        expandable connector EC1
            EC2 ec2;
        end EC1;

        expandable connector EC2
            EC3 ec3;
        end EC2;

        expandable connector EC3
        end EC3;

        connector C = Real;

        EC1 ec1;
        C c;
    equation
        connect(c, ec1.ec2.ec3.a);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable28",
            description="Nested declared expandable connectors: three deep",
            flatModel="
fclass ExpandableConnectors.Expandable28
 Real ec1.ec2.ec3.a;
 Real c;
equation
 c = ec1.ec2.ec3.a;
end ExpandableConnectors.Expandable28;
")})));
    end Expandable28;


    model Expandable29
        expandable connector EC1
            EC2 ec2;
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        EC1 ec1;
        C c1, c2;
    equation
        connect(c1, ec1.ec2.a);
        connect(c2, ec1.b);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable29",
            description="Nested declared expandable connectors: adding members to both levels",
            flatModel="
fclass ExpandableConnectors.Expandable29
 Real ec1.b;
 Real ec1.ec2.a;
 Real c1;
 Real c2;
equation
 c1 = ec1.ec2.a;
 c2 = ec1.b;
end ExpandableConnectors.Expandable29;
")})));
    end Expandable29;


    model Expandable30
        expandable connector EC1
            EC2 a;
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        EC1 ec1_1, ec1_2;
        EC2 ec2_1, ec2_2;
        C c1, c2;
    equation
        connect(ec1_1, ec1_2);
        connect(ec1_1.a, ec2_1);
        connect(ec1_2.a, ec2_2);
        connect(ec2_1.b, c1);
        connect(ec2_2.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable30",
            description="Connect expandable connectors containing other expandable connectors",
            flatModel="
fclass ExpandableConnectors.Expandable30
 Real ec1_1.a.b;
 Real ec1_1.a.c;
 Real ec1_2.a.b;
 Real ec1_2.a.c;
 Real ec2_1.b;
 Real ec2_1.c;
 Real ec2_2.b;
 Real ec2_2.c;
 Real c1;
 Real c2;
equation
 c1 = ec1_1.a.b;
 ec1_1.a.b = ec1_2.a.b;
 ec1_2.a.b = ec2_1.b;
 ec2_1.b = ec2_2.b;
 c2 = ec1_1.a.c;
 ec1_1.a.c = ec1_2.a.c;
 ec1_2.a.c = ec2_1.c;
 ec2_1.c = ec2_2.c;
end ExpandableConnectors.Expandable30;
")})));
    end Expandable30;


    model Expandable31
        expandable connector EC
        end EC;

        connector C = Real;

        model A
            EC ec;
        end A;

        A a;
        EC ec;
        C c1[2], c2[2];
    equation
        connect(ec, a.ec);
        connect(ec.b1, c1);
        connect(a.ec.b2, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable31",
            description="Make sure that extra equations aren't added for combinations of inner/outer connections",
            flatModel="
fclass ExpandableConnectors.Expandable31
 Real a.ec.b1[2];
 Real a.ec.b2[2];
 Real ec.b1[2];
 Real ec.b2[2];
 Real c1[2];
 Real c2[2];
equation
 a.ec.b1[1] = c1[1];
 c1[1] = ec.b1[1];
 a.ec.b1[2] = c1[2];
 c1[2] = ec.b1[2];
 a.ec.b2[1] = c2[1];
 c2[1] = ec.b2[1];
 a.ec.b2[2] = c2[2];
 c2[2] = ec.b2[2];
end ExpandableConnectors.Expandable31;
")})));
    end Expandable31;

    model Expandable32
        connector C = Real[2];

        expandable connector EC
        end EC;

        EC ec1, ec2;
        C x = { time, 2 * time };
    equation
        connect(ec1.x, x);
        connect(ec1, ec2.ec);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable32",
            description="Array in nested expandable connector",
            flatModel="
fclass ExpandableConnectors.Expandable32
 ExpandableConnectors.Expandable32.C ec1.x[2];
 ExpandableConnectors.Expandable32.C ec2.ec.x[2];
 ExpandableConnectors.Expandable32.C x[2] = {time, 2 * time};
equation
 ec1.x[1] = ec2.ec.x[1];
 ec2.ec.x[1] = x[1];
 ec1.x[2] = ec2.ec.x[2];
 ec2.ec.x[2] = x[2];

public
 type ExpandableConnectors.Expandable32.C = Real;
end ExpandableConnectors.Expandable32;
")})));
    end Expandable32;


    model Expandable33
        expandable connector EC
        end EC;
        connector C = Real;
        EC ec1;
        C c1;

    equation
        connect(c1, ec1.a) annotation (Line(
          points={{-22,2},{-43,2}},
          color={0,0,255},
          smooth=Smooth.None));
        c1 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Expandable33",
            description="Test expandable connector and connect equation with annotation, caused crash bug",
            flatModel="
fclass ExpandableConnectors.Expandable33
 Real ec1.a;
 Real c1;
equation
 c1 = time;
 c1 = ec1.a;
end ExpandableConnectors.Expandable33;
")})));
    end Expandable33;


model ExpandableWithInputOutput1
    connector CI = input Real;
    connector CO = output Real;
    connector C = Real;

    expandable connector EC
    end EC;

    EC ec;
    CI ci1;
    CO co1;
    input C ci2;
    output C co2;
equation
    connect(ci1, ec.ci1);
    connect(ci2, ec.ci2);
    connect(co1, ec.co1);
    connect(co2, ec.co2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExpandableWithInputOutput1",
            description="Created variables in expandable connectors shouldn't be considered top-level input/outputs",
            flatModel="
fclass ExpandableConnectors.ExpandableWithInputOutput1
 ExpandableConnectors.ExpandableWithInputOutput1.CI ec.ci1;
 Real ec.ci2;
 ExpandableConnectors.ExpandableWithInputOutput1.CO ec.co1;
 Real ec.co2;
 input ExpandableConnectors.ExpandableWithInputOutput1.CI ci1;
 output ExpandableConnectors.ExpandableWithInputOutput1.CO co1;
 input Real ci2;
 output Real co2;
equation
 ci1 = ec.ci1;
 ci2 = ec.ci2;
 co1 = ec.co1;
 co2 = ec.co2;

public
 type ExpandableConnectors.ExpandableWithInputOutput1.CI = Real;
 type ExpandableConnectors.ExpandableWithInputOutput1.CO = Real;
end ExpandableConnectors.ExpandableWithInputOutput1;
")})));
end ExpandableWithInputOutput1;


model FlowInExpandable1
    connector C
        Real p;
        flow Real f;
    end C;

    expandable connector EC
    end EC;

    model A
        B b;
        EC ec;
    equation
        connect(b.c, ec.c);
    end A;

    model B
        C c;
    end B;

    A a;
    B b;
    EC ec;
equation
    connect(a.ec, ec);
    connect(b.c, ec.c);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="FlowInExpandable1",
        description="Check that flow variables in expandable connectors get zero equations as needed",
        flatModel="
fclass ExpandableConnectors.FlowInExpandable1
 Real a.b.c.p;
 Real a.b.c.f;
 Real a.ec.c.p;
 Real a.ec.c.f;
 Real b.c.p;
 Real b.c.f;
 Real ec.c.p;
 Real ec.c.f;
equation
 a.b.c.f - a.ec.c.f = 0.0;
 a.ec.c.f + b.c.f - ec.c.f = 0.0;
 a.ec.c.p = b.c.p;
 b.c.p = ec.c.p;
 a.b.c.p = a.ec.c.p;
 ec.c.f = 0.0;
end ExpandableConnectors.FlowInExpandable1;
")})));
end FlowInExpandable1;


package Error

    model ExpandableErr1
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c[3];
    equation
        connect(c, ec1.a[1:2]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr1",
            description="Exandable connectors: local size error in connection, length differs",
            errorMessage="
1 errors found:

Error at line 10, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr1;


    model ExpandableErr2
        expandable connector EC
        end EC;

        connector C = Real;
        
        EC ec1;
        C c[3];
    equation
        connect(c, ec1.a[:,1:2]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr2",
            description="Exandable connectors: local size error in connection, number of dimensions differ",
            errorMessage="
1 errors found:

Error at line 10, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr2;


    model ExpandableErr3
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c[3,3];
    equation
        connect(c, ec1.a[:]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr3",
            description="Exandable connectors: local size error in connection, number of dimensions differ",
            errorMessage="
1 errors found:

Error at line 10, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr3;


    model ExpandableErr3b
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c[3,3];
    equation
        connect(c, ec1.a[:,1]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr3b",
            description="Exandable connectors: local size error in connection, number of dimensions differ",
            errorMessage="
1 errors found:

Error at line 10, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Can not match size of connector to access introducing member in external connector
")})));
    end ExpandableErr3b;


    model ExpandableErr4
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c1[3], c2;
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a[4]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr4",
            description="Exandable connectors: size mismatch between connections, access to specific element > fixed size",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr4;


    model ExpandableErr5
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c1[3], c2;
    equation
        connect(c2, ec1.a[4]);
        connect(c1, ec1.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr5",
            description="Exandable connectors: size mismatch between connections, access to specific element > fixed size",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr5;


    model ExpandableErr6
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c1[3], c2;
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a[3,1]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr6",
            description="Exandable connectors: size mismatch between connections, number of dimensions differ",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr6;


    model ExpandableErr7
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c1[3], c2;
    equation
        connect(c2, ec1.a[3,1]);
        connect(c1, ec1.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr7",
            description="Exandable connectors: size mismatch between connections, number of dimensions differ",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr7;


    model ExpandableErr8
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        C c1[3], c2[4];
    equation
        connect(c1, ec1.a);
        connect(c2, ec1.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr8",
            description="Exandable connectors: size mismatch between connections, different fixed sizes",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr8;


    model ExpandableErr9
        expandable connector EC
        end EC;

        connector C1
            Real x;
        end C1;

        connector C2
            Real y;
        end C2;
        
        EC ec;
        C1 c1;
        C2 c2;
    equation
        connect(c1, ec.a);
        connect(c2, ec.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr9",
            description="",
            errorMessage="
1 errors found:

Error at line 18, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr9;


    model ExpandableErr10
        expandable connector EC
        end EC;

        connector C1 = Real;

        connector C2 = Boolean;

        EC ec;
        C1 c1;
        C2 c2;
    equation
        connect(c1, ec.a[1]);
        connect(c2, ec.a[2]);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr10",
            description="",
            errorMessage="
1 errors found:

Error at line 14, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr10;


    model ExpandableErr11
        expandable connector EC
            Real a;
        end EC;

        connector C = Boolean;

        EC ec;
        C c;
    equation
        connect(c, ec.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr11",
            description="",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr11;


    model ExpandableErr12
        expandable connector EC
            Real a[3];
        end EC;

        connector C = Real;

        EC ec;
        C c[3];
    equation
        connect(c[1:2], ec.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr12",
            description="",
            errorMessage="
1 errors found:

Error at line 11, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Size introduced for external connector member does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr12;


    model ExpandableErr13
        expandable connector EC1
            Real a;
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Boolean;

        EC1 ec1;
        EC2 ec2;
        C c;
    equation
        connect(ec1, ec2);
        connect(c, ec2.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr13",
            description="",
            errorMessage="
1 errors found:

Error at line 16, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
    end ExpandableErr13;


    model ExpandableErr14
        expandable connector EC1
            Real a;
        end EC1;

        expandable connector EC2
            Boolean a;
        end EC2;

        EC1 ec1;
        EC2 ec2;
    equation
        connect(ec1, ec2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr14",
            description="",
            errorMessage="
1 errors found:

Error at line 13, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo', TYPE_MISMATCH_IN_CONNECT:
  Types of connected components do not match
")})));
    end ExpandableErr14;


    model ExpandableErr15
        expandable connector EC1
            Real a[3];
        end EC1;

        expandable connector EC2
            Real a[4];
        end EC2;

        EC1 ec1;
        EC2 ec2;
    equation
        connect(ec1, ec2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr15",
            description="",
            errorMessage="
1 errors found:

Error at line 13, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo', TYPE_MISMATCH_IN_CONNECT:
  Types of connected components do not match
")})));
    end ExpandableErr15;


    model ExpandableErr16
        expandable connector EC1
            Real a;
        end EC1;

        expandable connector EC2
        end EC2;

        expandable connector EC3
            Boolean a;
        end EC3;

        connector C = Real;

        EC1 ec1;
        EC2 ec2;
        EC3 ec3;
        C c;
    equation
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(c, ec1.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr16",
            description="",
            errorMessage="
1 errors found:

Error at line 10, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Type of declared member of expandable connector does not match declarations in other expandable connectors in same connection set
")})));
    end ExpandableErr16;


    model ExpandableErr17
        expandable connector EC1
            Real a[3];
        end EC1;

        expandable connector EC2
        end EC2;

        expandable connector EC3
            Real a[4];
        end EC3;

        connector C = Real;

        EC1 ec1;
        EC2 ec2;
        EC3 ec3;
        C c[3];
    equation
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(c, ec1.a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr17",
            description="",
            errorMessage="
1 errors found:

Error at line 10, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Size of declared member of expandable connector does not match declarations in other expandable connectors in same connection set
")})));
    end ExpandableErr17;


    model ExpandableErr18
        expandable connector EC
            Real x;
        end EC;

        connector C
            Real x;
        end C;

        EC ec;
        C c;
    equation
        connect(ec, c);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr18",
            description="",
            errorMessage="
1 errors found:

Error at line 13, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo', CONNECT_EXPANDABLE_AND_NON_EXPANDABLE_TYPE:
  Connecting an expandable connector to a non-expandable connector is not allowed
")})));
    end ExpandableErr18;


    model ExpandableErr19
        expandable connector EC
            Real x;
        end EC;
        
        EC ec;
        Real y;
    equation
        y = ec.x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr19",
            description="Using member of expandable connector that is not connected to",
            errorMessage="
1 errors found:

Error at line 9, column 13, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Using member of expandable connector is only allowed if the member is connected to in the connection set
")})));
    end ExpandableErr19;


    model ExpandableErr20
        expandable connector EC
            Real x;
        end EC;
        
        EC ec;
        Real y = ec.x;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr20",
            description="Using member of expandable connector that is not connected to",
            errorMessage="
1 errors found:

Error at line 7, column 18, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Using member of expandable connector is only allowed if the member is connected to in the connection set
")})));
    end ExpandableErr20;


    model ExpandableErr21
        expandable connector EC
            Real x;
        end EC;

        model A
            Real y;
        end A;

        EC ec;
        A a(y = ec.x);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr21",
            description="Using member of expandable connector that is not connected to",
            errorMessage="
1 errors found:

Error at line 11, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Using member of expandable connector is only allowed if the member is connected to in the connection set
")})));
    end ExpandableErr21;


model ExpandableErr22
    connector A
        Real x;
    end A;

    connector B
        Real x;
        Real y;
    end B;

    expandable connector C
    end C;
    
    C c1, c2;
    A a;
    B b;
equation
    connect(a, c1.d);
    connect(b, c2.d);
    connect(c1, c2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExpandableErr22",
            description="",
            errorMessage="
1 errors found:

Error at line 19, column 5, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Type of component introduced to external connector does not match other connections to same name in connection set or component declared in connector
")})));
end ExpandableErr22;


end Error;



package Compliance

    model ExpandableCompliance1
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec;
        C c;
    equation
        connect(c, ec.a1.a2);
        connect(ec.b1.b2, c);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ExpandableCompliance1",
            description="Nested expandable connectors: connecting with more than one unknown name",
            errorMessage="
2 errors found:

Compliance error at line 10, column 20, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Nested expandable connectors where some of the intermediate expandable connectors are neither connected to or declared are not supported

Compliance error at line 11, column 17, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Nested expandable connectors where some of the intermediate expandable connectors are neither connected to or declared are not supported
")})));
    end ExpandableCompliance1;


    model ExpandableCompliance2
        expandable connector EC
        end EC;

        connector C
            EC ec;
        end C;

        EC ec;
        C c;
    equation
        connect(c, ec.c);

    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="ExpandableCompliance2",
            description="Adding normal connector containing expandable connector to expandable connector",
            errorMessage="
1 errors found:

Compliance error at line 12, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Expandable connectors containing a non-expandable connector component, that in turn contains an expandable connector, is not supported
")})));
    end ExpandableCompliance2;

end Compliance;



package Nested

    model NestedExpandable1
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        EC ec2;
        C c;
    equation
        connect(ec1.sub1, ec2);
        connect(ec1.sub1.c, c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable1",
            description="Adding expandable connector member to expandable connector, member of parent first",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable1
 Real ec1.sub1.c;
 Real ec2.c;
 Real c;
equation
 c = ec1.sub1.c;
 ec1.sub1.c = ec2.c;
end ExpandableConnectors.Nested.NestedExpandable1;
")})));
    end NestedExpandable1;


    model NestedExpandable2
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1;
        EC ec2;
        C c;
    equation
        connect(ec1.sub1.c, c);
        connect(ec1.sub1, ec2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable2",
            description="Adding expandable connector member to expandable connector, member of child first",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable2
 Real ec1.sub1.c;
 Real ec2.c;
 Real c;
equation
 c = ec1.sub1.c;
 ec1.sub1.c = ec2.c;
end ExpandableConnectors.Nested.NestedExpandable2;
")})));
    end NestedExpandable2;


    model NestedExpandable3
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1_1, ec1_2;
        EC ec2_1, ec2_2;
        C c1, c2;
    equation
        connect(ec1_1, ec1_2);
        connect(ec1_1.a, ec2_1);
        connect(ec1_2.a, ec2_2);
        connect(ec1_1.a.b, c1);
        connect(ec1_2.a.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable3",
            description="Adding expandable connector member to expandable connector, more complicated test",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable3
 Real ec1_1.a.b;
 Real ec1_1.a.c;
 Real ec1_2.a.b;
 Real ec1_2.a.c;
 Real ec2_1.b;
 Real ec2_1.c;
 Real ec2_2.b;
 Real ec2_2.c;
 Real c1;
 Real c2;
equation
 c1 = ec1_1.a.b;
 ec1_1.a.b = ec1_2.a.b;
 ec1_2.a.b = ec2_1.b;
 ec2_1.b = ec2_2.b;
 c2 = ec1_1.a.c;
 ec1_1.a.c = ec1_2.a.c;
 ec1_2.a.c = ec2_1.c;
 ec2_1.c = ec2_2.c;
end ExpandableConnectors.Nested.NestedExpandable3;
")})));
    end NestedExpandable3;


    model NestedExpandable4
        expandable connector EC
        end EC;

        connector C = Real;
        
        EC ec1, ec2, ec3;
        C c;
    equation
        connect(ec2, ec1.ec2);
        connect(ec3, ec1.ec2.ec3);
        connect(c, ec1.ec2.ec3.a);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable4",
            description="Adding expandable connector member to expandable connector, several levels",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable4
 Real ec1.ec2.ec3.a;
 Real ec2.ec3.a;
 Real ec3.a;
 Real c;
equation
 c = ec1.ec2.ec3.a;
 ec1.ec2.ec3.a = ec2.ec3.a;
 ec2.ec3.a = ec3.a;
end ExpandableConnectors.Nested.NestedExpandable4;
")})));
    end NestedExpandable4;


    model NestedExpandable5
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1, ec2, ec3;
        C c;
    equation
        connect(c, ec1.ec2.ec3.a);
        connect(ec3, ec1.ec2.ec3);
        connect(ec2, ec1.ec2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable5",
            description="Adding expandable connector member to expandable connector, several levels, members first",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable5
 Real ec1.ec2.ec3.a;
 Real ec2.ec3.a;
 Real ec3.a;
 Real c;
equation
 c = ec1.ec2.ec3.a;
 ec1.ec2.ec3.a = ec2.ec3.a;
 ec2.ec3.a = ec3.a;
end ExpandableConnectors.Nested.NestedExpandable5;
")})));
    end NestedExpandable5;


    model NestedExpandable6
        expandable connector EC
        end EC;

        connector C1
            C2 a;
        end C1;

        connector C2 = Real;

        EC ec;
        C1 c1;
        C2 c2;
    equation
        connect(ec.sub1, c1);
        connect(ec.sub1.a, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable6",
            description="Connecting to existing member of normal connector in expandable connector",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable6
 Real ec.sub1.a;
 potential Real c1.a;
 Real c2;
equation
 c1.a = c2;
 c2 = ec.sub1.a;
end ExpandableConnectors.Nested.NestedExpandable6;
")})));
    end NestedExpandable6;


    model NestedExpandable7
        expandable connector EC
        end EC;

        connector C
            Real p;
            flow Real f;
        end C;

        EC ec1, ec2;
        C c1[2], c2[2];
    equation
        connect(ec1, ec2);
        connect(ec1.ec.c1, c1);
        connect(ec2.ec.c2, c2);
        connect(ec1.ec, ec2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NestedExpandable7",
            description="Check that recursive strucures are detected while elaborating expandable connectors",
            errorMessage="
1 errors found:

Error at line 16, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Connect introduces a copy of ec2 into a connector that is (possibly indirectly) connected back to ec2. This creates an infinite recursive structure, and is not allowed:
    connect(ec1.ec, ec2)
")})));
    end NestedExpandable7;


    model NestedExpandable8
        expandable connector EC
        end EC;

        EC ec1, ec2, ec3;
    equation
        connect(ec1.ec, ec2);
        connect(ec2.ec, ec3);
        connect(ec1, ec3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NestedExpandable8",
            description="Check that recursive strucures are detected while elaborating expandable connectors",
            errorMessage="
2 errors found:

Error at line 7, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Connect introduces a copy of ec2 into a connector that is (possibly indirectly) connected back to ec2. This creates an infinite recursive structure, and is not allowed:
    connect(ec1.ec, ec2)

Error at line 8, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Connect introduces a copy of ec3 into a connector that is (possibly indirectly) connected back to ec3. This creates an infinite recursive structure, and is not allowed:
    connect(ec2.ec, ec3)
")})));
    end NestedExpandable8;


    model NestedExpandable9
        expandable connector EC
        end EC;
        
        connector C = Real;
    
        EC ec1, ec2, ec3;
        C c1, c2, c3;
    equation
        connect(c1, ec1.ec.c1);
        connect(c2, ec2.ec.c2);
        connect(c3, ec1.c3);
        connect(ec1.ec, ec3);
        connect(ec2.ec, ec3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable9",
            description="Same expandable connector added as nested connector in two separate expandable connectors",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable9
 Real ec1.c3;
 Real ec1.ec.c1;
 Real ec1.ec.c2;
 Real ec2.ec.c1;
 Real ec2.ec.c2;
 Real ec3.c1;
 Real ec3.c2;
 Real c1;
 Real c2;
 Real c3;
equation
 c1 = ec1.ec.c1;
 ec1.ec.c1 = ec2.ec.c1;
 ec2.ec.c1 = ec3.c1;
 c2 = ec1.ec.c2;
 ec1.ec.c2 = ec2.ec.c2;
 ec2.ec.c2 = ec3.c2;
 c3 = ec1.c3;
end ExpandableConnectors.Nested.NestedExpandable9;
")})));
    end NestedExpandable9;


    model NestedExpandable10
        expandable connector EC
        end EC;
        
        connector C = Real;

        EC ec1, ec2, ec3, ec4, ec5;
        C c1, c2, c3;
    equation
        connect(c1, ec1.ec.c1);
        connect(c2, ec2.ec.c2);
        connect(c3, ec1.c3);
        connect(ec1.ec, ec3);
        connect(ec2.ec, ec4);
        connect(ec1, ec5);
        connect(ec5, ec2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable10",
            description="",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable10
 Real ec1.c3;
 Real ec1.ec.c1;
 Real ec1.ec.c2;
 Real ec2.c3;
 Real ec2.ec.c1;
 Real ec2.ec.c2;
 Real ec3.c1;
 Real ec3.c2;
 Real ec4.c1;
 Real ec4.c2;
 Real ec5.c3;
 Real ec5.ec.c1;
 Real ec5.ec.c2;
 Real c1;
 Real c2;
 Real c3;
equation
 c1 = ec1.ec.c1;
 ec1.ec.c1 = ec2.ec.c1;
 ec2.ec.c1 = ec3.c1;
 ec3.c1 = ec4.c1;
 ec4.c1 = ec5.ec.c1;
 c3 = ec1.c3;
 ec1.c3 = ec2.c3;
 ec2.c3 = ec5.c3;
 c2 = ec1.ec.c2;
 ec1.ec.c2 = ec2.ec.c2;
 ec2.ec.c2 = ec3.c2;
 ec3.c2 = ec4.c2;
 ec4.c2 = ec5.ec.c2;
end ExpandableConnectors.Nested.NestedExpandable10;
")})));
    end NestedExpandable10;


    model NestedExpandable11
        expandable connector EC1
            EC2[1] ec2;
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        EC1 ec1;
        model M
            EC2 ec2;
        end M;
        C c;
        M[1] m;
    equation
        connect(c, ec1.ec2[1].a);
        for i in 1:1 loop
            connect(ec1.ec2[i], m[i].ec2);
        end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedExpandable11",
            description="Nested with for index on last part",
            flatModel="
fclass ExpandableConnectors.Nested.NestedExpandable11
 Real ec1.ec2[1].a;
 Real c;
 Real m[1].ec2.a;
equation
 c = ec1.ec2[1].a;
 ec1.ec2[1].a = m[1].ec2.a;
end ExpandableConnectors.Nested.NestedExpandable11;
")})));
    end NestedExpandable11;


package NestedError

    model NestedExpandableError1
        expandable connector EC
        end EC;

        connector C1
            C2 c2;
        end C1;

        connector C2 = Real;

        EC ec;
        C1 c1;
        C2 c2;
    equation
        connect(ec.c1, c1);
        connect(ec.c1.a, c2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NestedExpandableError1",
            description="Connecting to non-existing member of non-expandable connector in expandable connector",
            errorMessage="
1 errors found:

Error at line 16, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Can not connect to non-existing member of non-expandable connector in expandable connector
")})));
    end NestedExpandableError1;


    model NestedExpandableError2
        expandable connector EC
        end EC;

        connector C1
            C2 c2;
        end C1;

        connector C2
            C3 c3;
        end C2;

        connector C3 = Real;

        EC ec;
        C1 c1;
        C3 c3;
    equation
        connect(ec.c1, c1);
        connect(ec.c1.c2.a, c3);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NestedExpandableError2",
            description="Connecting to non-existing member of nested non-expandable connector in expandable connector",
            errorMessage="
1 errors found:

Error at line 20, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/ExpandableConnectors.mo':
  Can not connect to non-existing member of non-expandable connector in expandable connector
")})));
    end NestedExpandableError2;

end NestedError;

end Nested;



model DuplicatedExpandable1
    expandable connector EC
    end EC;

    connector C = Real;

    model A
        extends D;
        EC ec;
        B b;
    equation
        connect(b.c, ec.c);
    end A;

    model B
        C c = time;
    end B;

    model D
        EC ec;
    end D;

    A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="DuplicatedExpandable1",
            description="Expandable connector with same name declared in both instantiated class and inherited class",
            flatModel="
fclass ExpandableConnectors.DuplicatedExpandable1
 Real a.b.c = time;
 Real a.ec.c;
equation
 a.b.c = a.ec.c;
end ExpandableConnectors.DuplicatedExpandable1;
")})));
end DuplicatedExpandable1;


model DuplicatedExpandable2
    expandable connector EC
    end EC;

    connector C = Real;

    model A
        extends D;
        EC ec;
        B b;
    equation
        connect(b.c, ec.c);
    end A;

    model B
        C c = time;
    end B;

    model D
        EC ec;
        B b2;
    equation
        connect(b2.c, ec.c2);
    end D;

     A a;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="DuplicatedExpandable2",
            description="Expandable connector with same name declared in both instantiated class and inherited class",
            flatModel="
fclass ExpandableConnectors.DuplicatedExpandable2
 Real a.b.c = time;
 Real a.ec.c;
 Real a.ec.c2;
 Real a.b2.c = time;
equation
 a.b.c = a.ec.c;
 a.b2.c = a.ec.c2;
end ExpandableConnectors.DuplicatedExpandable2;
")})));
end DuplicatedExpandable2;


model AddToNestedAndConnectTopLevel
    expandable connector EC
    end EC;
    
    expandable connector EC2
        EC ec;
    end EC2;
    
    connector C = Real;
    
    EC ec1;
    EC2 ec2;
    C c;
equation
    connect(ec1, ec2);
    connect(ec2.ec.c, c);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="AddToNestedAndConnectTopLevel",
        description="Make sure that nested connectors that are only declared to work correctly.",
        flatModel="
fclass ExpandableConnectors.AddToNestedAndConnectTopLevel
 Real ec1.ec.c;
 Real ec2.ec.c;
 Real c;
equation
 c = ec1.ec.c;
 ec1.ec.c = ec2.ec.c;
end ExpandableConnectors.AddToNestedAndConnectTopLevel;
")})));
end AddToNestedAndConnectTopLevel;


package ConnectorArrays

model ConnectorArray1
    connector C
      flow Real a[1];
      flow Real b;
      Real c[2];
    end C;

    expandable connector EC
    end EC;

    C c[1];
    EC ec;
equation
    connect(c[1], ec.x);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="ConnectorArray1",
        description="Connecting to array of connectors",
        flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray1
 flow Real c[1].a[1];
 flow Real c[1].b;
 potential Real c[1].c[2];
 Real ec.x.a[1];
 Real ec.x.b;
 Real ec.x.c[2];
equation
 - c[1].a[1:1] - ec.x.a[1:1] = zeros(1);
 - c[1].b - ec.x.b = 0.0;
 c[1].c[1:2] = ec.x.c[1:2];
 ec.x.a[1:1] = zeros(1);
 ec.x.b = 0.0;
end ExpandableConnectors.ConnectorArrays.ConnectorArray1;
")})));
end ConnectorArray1;


model ConnectorArray2
    connector C
      flow Real a[1];
      flow Real b;
      Real c[2];
    end C;

    expandable connector EC
    end EC;

    C c[2];
    EC ec;
equation
    connect(c, ec.x);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="ConnectorArray2",
        description="Connecting to array of connectors",
        flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray2
 flow Real c[1].a[1];
 flow Real c[1].b;
 potential Real c[1].c[2];
 flow Real c[2].a[1];
 flow Real c[2].b;
 potential Real c[2].c[2];
 Real ec.x[1].a[1];
 Real ec.x[1].b;
 Real ec.x[1].c[2];
 Real ec.x[2].a[1];
 Real ec.x[2].b;
 Real ec.x[2].c[2];
equation
 - c[1].a[1:1] - ec.x[1].a[1:1] = zeros(1);
 - c[1].b - ec.x[1].b = 0.0;
 c[1].c[1:2] = ec.x[1].c[1:2];
 - c[2].a[1:1] - ec.x[2].a[1:1] = zeros(1);
 - c[2].b - ec.x[2].b = 0.0;
 c[2].c[1:2] = ec.x[2].c[1:2];
 ec.x[1].a[1:1] = zeros(1);
 ec.x[1].b = 0.0;
 ec.x[2].a[1:1] = zeros(1);
 ec.x[2].b = 0.0;
end ExpandableConnectors.ConnectorArrays.ConnectorArray2;
")})));
end ConnectorArray2;


model ConnectorArray3
    connector C
      flow Real a[1];
      flow Real b;
      Real c[2];
    end C;

    expandable connector EC
    end EC;

    C c[3];
    EC ec;
equation
    connect(c[2:3], ec.x);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="ConnectorArray3",
        description="Connecting to array of connectors",
        flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray3
 flow Real c[1].a[1];
 flow Real c[1].b;
 potential Real c[1].c[2];
 flow Real c[2].a[1];
 flow Real c[2].b;
 potential Real c[2].c[2];
 flow Real c[3].a[1];
 flow Real c[3].b;
 potential Real c[3].c[2];
 Real ec.x[1].a[1];
 Real ec.x[1].b;
 Real ec.x[1].c[2];
 Real ec.x[2].a[1];
 Real ec.x[2].b;
 Real ec.x[2].c[2];
equation
 - c[2].a[1:1] - ec.x[1].a[1:1] = zeros(1);
 - c[2].b - ec.x[1].b = 0.0;
 c[2].c[1:2] = ec.x[1].c[1:2];
 - c[3].a[1:1] - ec.x[2].a[1:1] = zeros(1);
 - c[3].b - ec.x[2].b = 0.0;
 c[3].c[1:2] = ec.x[2].c[1:2];
 ec.x[1].a[1:1] = zeros(1);
 ec.x[1].b = 0.0;
 ec.x[2].a[1:1] = zeros(1);
 ec.x[2].b = 0.0;
end ExpandableConnectors.ConnectorArrays.ConnectorArray3;
")})));
end ConnectorArray3;


model ConnectorArray4
    connector C
      flow Real a[1];
      flow Real b;
      Real c[2];
    end C;

    expandable connector EC
    end EC;

    C c1, c2;
    EC ec;
equation
    connect(c1, ec.x[1]);
    connect(c2, ec.x[3]);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="ConnectorArray4",
        description="Connecting to array of connectors",
        flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray4
 flow Real c1.a[1];
 flow Real c1.b;
 potential Real c1.c[2];
 flow Real c2.a[1];
 flow Real c2.b;
 potential Real c2.c[2];
 Real ec.x[1].a[1];
 Real ec.x[1].b;
 Real ec.x[1].c[2];
 Real ec.x[2].a[1];
 Real ec.x[2].b;
 Real ec.x[2].c[2];
 Real ec.x[3].a[1];
 Real ec.x[3].b;
 Real ec.x[3].c[2];
equation
 - c1.a[1:1] - ec.x[1].a[1:1] = zeros(1);
 - c1.b - ec.x[1].b = 0.0;
 c1.c[1:2] = ec.x[1].c[1:2];
 - c2.a[1:1] - ec.x[3].a[1:1] = zeros(1);
 - c2.b - ec.x[3].b = 0.0;
 c2.c[1:2] = ec.x[3].c[1:2];
 - ec.x[2].a[1:1] = zeros(1);
 - ec.x[2].b = 0.0;
 ec.x[2].c[1:2] = zeros(2);
 ec.x[1].a[1:1] = zeros(1);
 ec.x[1].b = 0.0;
 ec.x[2].a[1:1] = zeros(1);
 ec.x[2].b = 0.0;
 ec.x[3].a[1:1] = zeros(1);
 ec.x[3].b = 0.0;
end ExpandableConnectors.ConnectorArrays.ConnectorArray4;
")})));
end ConnectorArray4;


model ConnectorArray5
    connector C
        parameter Integer n(min = 1);
        flow Real a[n];
        Real b[n];
    end C;

    expandable connector EC
    end EC;

    C c[2](n={2,3});
    EC ec;
equation
    connect(ec.x, c);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="ConnectorArray5",
        description="Structural parameters in connector",
        flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray5
 structural parameter Integer c[1].n = 2 /* 2 */;
 flow Real c[1].a[2];
 potential Real c[1].b[2];
 structural parameter Integer c[2].n = 3 /* 3 */;
 flow Real c[2].a[3];
 potential Real c[2].b[3];
 structural parameter Integer ec.x[1].n = 2 /* 2 */;
 Real ec.x[1].a[2];
 Real ec.x[1].b[2];
 structural parameter Integer ec.x[2].n = 3 /* 3 */;
 Real ec.x[2].a[3];
 Real ec.x[2].b[3];
equation
 - c[1].a[1:2] - ec.x[1].a[1:2] = zeros(2);
 c[1].b[1:2] = ec.x[1].b[1:2];
 - c[2].a[1:3] - ec.x[2].a[1:3] = zeros(3);
 c[2].b[1:3] = ec.x[2].b[1:3];
 ec.x[1].a[1:2] = zeros(2);
 ec.x[2].a[1:3] = zeros(3);
end ExpandableConnectors.ConnectorArrays.ConnectorArray5;
")})));
end ConnectorArray5;


model ConnectorArray6
    connector C
      flow Real a;
      stream Real b;
      Real c;
    end C;

    expandable connector EC
    end EC;

    C c1, c2;
    EC ec;
equation
    connect(c1, ec.x[1]);
    connect(c2, ec.x[3]);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="ConnectorArray6",
        description="Array of stream connectors, with gap",
        flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray6
 flow Real c1.a;
 stream Real c1.b;
 potential Real c1.c;
 flow Real c2.a;
 stream Real c2.b;
 potential Real c2.c;
 Real ec.x[1].a;
 Real ec.x[1].b;
 Real ec.x[1].c;
 Real ec.x[2].a;
 Real ec.x[2].b;
 Real ec.x[2].c;
 Real ec.x[3].a;
 Real ec.x[3].b;
 Real ec.x[3].c;
equation
 - c1.a - ec.x[1].a = 0.0;
 c1.b = inStream(ec.x[1].b);
 ec.x[1].b = inStream(c1.b);
 c1.c = ec.x[1].c;
 - c2.a - ec.x[3].a = 0.0;
 c2.b = inStream(ec.x[3].b);
 ec.x[3].b = inStream(c2.b);
 c2.c = ec.x[3].c;
 - ec.x[2].a = 0.0;
 ec.x[2].b = 0.0;
 ec.x[2].c = 0.0;
 ec.x[1].a = 0.0;
 ec.x[2].a = 0.0;
 ec.x[3].a = 0.0;
end ExpandableConnectors.ConnectorArrays.ConnectorArray6;
")})));
end ConnectorArray6;


model ConnectorArray7
    connector C
      flow Real a;
      Real b;
    end C;

    expandable connector EC
    end EC;

    model A
        parameter Real p = 1;
        C c(a(start=p));
    end A;

    A a;
    EC ec;
equation
    connect(ec.c, a.c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConnectorArray7",
            description="Modicication on connected component referring to parameter outside of it",
            flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray7
 parameter Real a.p = 1 /* 1 */;
 Real a.c.a(start = a.p);
 Real a.c.b;
 Real ec.c.a(start = a.p);
 Real ec.c.b;
equation
 a.c.a - ec.c.a = 0.0;
 a.c.b = ec.c.b;
 ec.c.a = 0.0;
end ExpandableConnectors.ConnectorArrays.ConnectorArray7;
")})));
end ConnectorArray7;

model ConnectorArray8
    expandable connector EC
    end EC;

    connector C = Real;

    EC ec1;
    C c[2];
equation
    for i in 1:2 loop
        connect(c[i], ec1.a[i]);
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConnectorArray8",
            description="Expandable connector with for index",
            flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray8
 Real ec1.a[2];
 Real c[2];
equation
 c[1] = ec1.a[1];
 c[2] = ec1.a[2];
end ExpandableConnectors.ConnectorArrays.ConnectorArray8;
")})));
end ConnectorArray8;

model ConnectorArray9
    expandable connector EC
    end EC;

    connector C = Real;

    EC ec1;
    C c[2];
equation
    for i in 1:1 loop
        connect(c, ec1.a[i:i+1]);
    end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConnectorArray9",
            description="Expandable connector with for index",
            flatModel="
fclass ExpandableConnectors.ConnectorArrays.ConnectorArray9
 Real ec1.a[2];
 Real c[2];
equation
 c[1] = ec1.a[1];
 c[2] = ec1.a[2];
end ExpandableConnectors.ConnectorArrays.ConnectorArray9;
")})));
end ConnectorArray9;


end ConnectorArrays;



end ExpandableConnectors;
