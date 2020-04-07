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

within;

package ExpandableConnectorArrays


    model NoConnectionSingleCell
        expandable connector EC
        end EC;

        EC ec1[1], ec2[1];
    equation
        connect(ec1, ec2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoConnectionSingleCell",
            description="Expandable to expandable only, one cell each.",
            flatModel="
fclass ExpandableConnectorArrays.NoConnectionSingleCell
end ExpandableConnectorArrays.NoConnectionSingleCell;
")})));
    end NoConnectionSingleCell;

    model NoConnectionIntegerSized
        expandable connector EC
        end EC;

        EC ec1[2], ec2[2];
    equation
        connect(ec1, ec2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EmptyIntegerSized",
            description="Expandable to expandable only, several cells each.",
            flatModel="
fclass ExpandableConnectorArrays.NoConnectionIntegerSized
end ExpandableConnectorArrays.NoConnectionIntegerSized;
")})));
    end NoConnectionIntegerSized;

    model NoConnectionParameterSized
        expandable connector EC
        end EC;

        parameter Integer n;

        EC ec1[n], ec2[n];
    equation
        connect(ec1, ec2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NoConnectionParameterSized",
            description="Expandable to expandable only, parameter sized.",
            flatModel="
fclass ExpandableConnectorArrays.NoConnectionParameterSized
 structural parameter Integer n = 0 /* 0 */;
end ExpandableConnectorArrays.NoConnectionParameterSized;
")})));
    end NoConnectionParameterSized;


    model SingleCells
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[1], ec2[1];
        C c1, c2;
    equation
        connect(c1, ec1[1].a);
        connect(ec1[1], ec2[1]);
        connect(ec2[1].a, c2);
        c1 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SingleCells",
            description="Arrays of expandable connectors, singular cells.",
            flatModel="
fclass ExpandableConnectorArrays.SingleCells
 Real ec1[1].a;
 Real ec2[1].a;
 Real c1;
 Real c2;
equation
 c1 = time;
 c1 = c2;
 c2 = ec1[1].a;
 ec1[1].a = ec2[1].a;
end ExpandableConnectorArrays.SingleCells;
")})));
    end SingleCells;


    model IntegerSized
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[2], ec2[2];
        C c1, c2, c3, c4;
    equation
        connect(c1, ec1[1].a);
        connect(c2, ec2[2].b);
        connect(ec1[1], ec2[1]);
        connect(ec1[2], ec2[2]);
        connect(ec2[2].a, c3);
        connect(ec2[2].a, c4);
        c1 = time;
        c2 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="IntegerSized",
            description="Arrays of expandable connectors, several cells each.",
            flatModel="
fclass ExpandableConnectorArrays.IntegerSized
 Real ec1[1].a;
 Real ec1[2].a;
 Real ec1[2].b;
 Real ec2[1].a;
 Real ec2[2].a;
 Real ec2[2].b;
 Real c1;
 Real c2;
 Real c3;
 Real c4;
equation
 c1 = time;
 c2 = time;
 c1 = ec1[1].a;
 ec1[1].a = ec2[1].a;
 c2 = ec1[2].b;
 ec1[2].b = ec2[2].b;
 c3 = c4;
 c4 = ec1[2].a;
 ec1[2].a = ec2[2].a;
end ExpandableConnectorArrays.IntegerSized;
")})));
    end IntegerSized;


    model BooleanSized
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[Boolean], ec2[Boolean], ec3[Boolean];
        C c1, c2, c3, c4;
    equation
        connect(c1, ec1[false].a);
        connect(c2, ec1[true].b);
        connect(c3, ec2[false].b);
        connect(c4, ec2[true].a);
        connect(ec1, ec2);
        connect(ec2[false], ec3[true]);
        c1 = time;
        c2 = time;
        c3 = time;
        c4 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BooleanSized",
            description="Arrays of expandable connectors, boolean sized.",
            flatModel="
fclass ExpandableConnectorArrays.BooleanSized
 Real ec1[1].a;
 Real ec1[1].b;
 Real ec1[2].a;
 Real ec1[2].b;
 Real ec2[1].a;
 Real ec2[1].b;
 Real ec2[2].a;
 Real ec2[2].b;
 Real ec3[2].a;
 Real ec3[2].b;
 Real c1;
 Real c2;
 Real c3;
 Real c4;
equation
 c1 = time;
 c2 = time;
 c3 = time;
 c4 = time;
 c1 = ec1[1].a;
 ec1[1].a = ec2[1].a;
 ec2[1].a = ec3[2].a;
 c2 = ec1[2].b;
 ec1[2].b = ec2[2].b;
 c3 = ec1[1].b;
 ec1[1].b = ec2[1].b;
 ec2[1].b = ec3[2].b;
 c4 = ec1[2].a;
 ec1[2].a = ec2[2].a;
end ExpandableConnectorArrays.BooleanSized;
")})));
    end BooleanSized;


    model EnumerationSized
        expandable connector EC
        end EC;

        type T = enumeration(A, B, C, D); 

        connector C = Real;

        EC ec1[T], ec2[T], ec3[T];
        C c1, c2, c3, c4;
    equation
        connect(c1, ec1[T.A].a);
        connect(c2, ec1[T.B].b);
        connect(c3, ec2[T.C].b);
        connect(c4, ec2[T.D].a);
        connect(ec1, ec2);
        connect(ec2[T.B], ec3[T.C]);
        c1 = time;
        c2 = time;
        c3 = time;
        c4 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EnumerationSized",
            description="Arrays of expandable connectors, enumeration sized.",
            flatModel="
fclass ExpandableConnectorArrays.EnumerationSized
 Real ec1[1].a;
 Real ec1[2].b;
 Real ec1[3].b;
 Real ec1[4].a;
 Real ec2[1].a;
 Real ec2[2].b;
 Real ec2[3].b;
 Real ec2[4].a;
 Real ec3[3].b;
 Real c1;
 Real c2;
 Real c3;
 Real c4;
equation
 c1 = time;
 c2 = time;
 c3 = time;
 c4 = time;
 c1 = ec1[1].a;
 ec1[1].a = ec2[1].a;
 c2 = ec1[2].b;
 ec1[2].b = ec2[2].b;
 ec2[2].b = ec3[3].b;
 c3 = ec1[3].b;
 ec1[3].b = ec2[3].b;
 c4 = ec1[4].a;
 ec1[4].a = ec2[4].a;

public
 type ExpandableConnectorArrays.EnumerationSized.T = enumeration(A, B, C, D);

end ExpandableConnectorArrays.EnumerationSized;
")})));
    end EnumerationSized;


    model ParameterSized
    
        model M
            expandable connector EC
            end EC;

            parameter Integer n;

            connector C = Real;

            EC ec1[n], ec2[n];
            C c1, c2;
        equation
            connect(c1, ec1[n - 2].a);
            connect(ec1[n - 2], ec2[n - 1]);
            connect(ec2[n - 1].a, c2);
            c1 = time;
        end M;

        M m(n = 3);
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ParameterSized",
            description="Arrays of expandable connectors, parameter sized.",
            flatModel="
fclass ExpandableConnectorArrays.ParameterSized
 structural parameter Integer m.n = 3 /* 3 */;
 Real m.ec1[1].a;
 Real m.ec2[2].a;
 Real m.c1;
 Real m.c2;
equation
 m.c1 = time;
 m.c1 = m.c2;
 m.c2 = m.ec1[1].a;
 m.ec1[1].a = m.ec2[2].a;
end ExpandableConnectorArrays.ParameterSized;
")})));
    end ParameterSized;


    model CompositeConnectors

        expandable connector EC
        end EC;

        connector C
            Real a;
            flow Real b;
        end C;

        EC ec1[3], ec2[3], ec3[3];
        C c1, c2, c3, c4, c5;
    equation
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(c1, ec1[1].x);
        connect(c2, ec1[1].y);
        connect(ec3[3].x, c3);
        connect(ec3[3].y, c4);
        connect(ec2[2].x, c5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="CompositeConnectors",
            description="Expandable connector arrays: composite connectors.",
            flatModel="
fclass ExpandableConnectorArrays.CompositeConnectors
 Real ec1[1].x.a;
 Real ec1[1].x.b;
 Real ec1[1].y.a;
 Real ec1[1].y.b;
 Real ec1[2].x.a;
 Real ec1[2].x.b;
 Real ec1[3].x.a;
 Real ec1[3].x.b;
 Real ec1[3].y.a;
 Real ec1[3].y.b;
 Real ec2[1].x.a;
 Real ec2[1].x.b;
 Real ec2[1].y.a;
 Real ec2[1].y.b;
 Real ec2[2].x.a;
 Real ec2[2].x.b;
 Real ec2[3].x.a;
 Real ec2[3].x.b;
 Real ec2[3].y.a;
 Real ec2[3].y.b;
 Real ec3[1].x.a;
 Real ec3[1].x.b;
 Real ec3[1].y.a;
 Real ec3[1].y.b;
 Real ec3[2].x.a;
 Real ec3[2].x.b;
 Real ec3[3].x.a;
 Real ec3[3].x.b;
 Real ec3[3].y.a;
 Real ec3[3].y.b;
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
 c1.a = ec1[1].x.a;
 ec1[1].x.a = ec2[1].x.a;
 ec2[1].x.a = ec3[1].x.a;
 - c1.b - ec1[1].x.b - ec2[1].x.b - ec3[1].x.b = 0.0;
 c2.a = ec1[1].y.a;
 ec1[1].y.a = ec2[1].y.a;
 ec2[1].y.a = ec3[1].y.a;
 - c2.b - ec1[1].y.b - ec2[1].y.b - ec3[1].y.b = 0.0;
 c5.a = ec1[2].x.a;
 ec1[2].x.a = ec2[2].x.a;
 ec2[2].x.a = ec3[2].x.a;
 - c5.b - ec1[2].x.b - ec2[2].x.b - ec3[2].x.b = 0.0;
 c3.a = ec1[3].x.a;
 ec1[3].x.a = ec2[3].x.a;
 ec2[3].x.a = ec3[3].x.a;
 - c3.b - ec1[3].x.b - ec2[3].x.b - ec3[3].x.b = 0.0;
 c4.a = ec1[3].y.a;
 ec1[3].y.a = ec2[3].y.a;
 ec2[3].y.a = ec3[3].y.a;
 - c4.b - ec1[3].y.b - ec2[3].y.b - ec3[3].y.b = 0.0;
 ec1[1].x.b = 0.0;
 ec1[1].y.b = 0.0;
 ec2[1].x.b = 0.0;
 ec2[1].y.b = 0.0;
 ec1[2].x.b = 0.0;
 ec2[2].x.b = 0.0;
 ec1[3].x.b = 0.0;
 ec1[3].y.b = 0.0;
 ec2[3].x.b = 0.0;
 ec2[3].y.b = 0.0;
 ec3[1].x.b = 0.0;
 ec3[1].y.b = 0.0;
 ec3[2].x.b = 0.0;
 ec3[3].x.b = 0.0;
 ec3[3].y.b = 0.0;
end ExpandableConnectorArrays.CompositeConnectors;
")})));
    end CompositeConnectors;


    model Redeclare
        expandable connector EC1
        end EC1;

        expandable connector EC2
            C a;
        end EC2;

        expandable connector EC3
            C b;
        end EC3;

        model A
            replaceable EC1 ec[3];
        end A;

        connector C = Real;

        A a1(redeclare EC2 ec);
        A a2(redeclare EC3 ec);
        C c1, c2;
    equation
        connect(c1, a1.ec[1].a);
        connect(c2, a2.ec[2].b);
        connect(a1.ec, a2.ec);
        c1 = time;
        c2 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="Redeclare",
            description="Expandable connector arrays: redeclaring expandable connectors.",
            flatModel="
fclass ExpandableConnectorArrays.Redeclare
 Real a1.ec[1].a;
 Real a1.ec[2].b;
 Real a2.ec[1].a;
 Real a2.ec[2].b;
 Real c1;
 Real c2;
equation
 c1 = time;
 c2 = time;
 a1.ec[1].a = a2.ec[1].a;
 a2.ec[1].a = c1;
 a1.ec[2].b = a2.ec[2].b;
 a2.ec[2].b = c2;
end ExpandableConnectorArrays.Redeclare;
")})));
    end Redeclare;


    model BindingExpressionComposite
        expandable connector EC
        end EC;

        connector C
            Real x;
            Real y;
        end C;

        EC ec1[1], ec2[2], ec3[3];
        C c1(x = 1, y = 2);
        C c2;
    equation
        connect(c1, ec1[1].a);
        connect(ec1[1], ec2[2]);
        connect(ec2[2], ec3[3]);
        connect(ec3[3].a, c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="BindingExpressionComposite",
            description="Adding to expandable connectors from composite with binding exps",
            flatModel="
fclass ExpandableConnectorArrays.BindingExpressionComposite
 Real ec1[1].a.x;
 Real ec1[1].a.y;
 Real ec2[2].a.x;
 Real ec2[2].a.y;
 Real ec3[3].a.x;
 Real ec3[3].a.y;
 potential Real c1.x = 1;
 potential Real c1.y = 2;
 potential Real c2.x;
 potential Real c2.y;
equation
 c1.x = c2.x;
 c2.x = ec1[1].a.x;
 ec1[1].a.x = ec2[2].a.x;
 ec2[2].a.x = ec3[3].a.x;
 c1.y = c2.y;
 c2.y = ec1[1].a.y;
 ec1[1].a.y = ec2[2].a.y;
 ec2[2].a.y = ec3[3].a.y;
end ExpandableConnectorArrays.BindingExpressionComposite;
")})));
    end BindingExpressionComposite;


    model ConnectorArray
        expandable connector EC
        end EC;

        connector C = Real[2];

        model M
            EC ec1[3], ec2[3], ec3[3];
            C c1, c2;
        equation
            connect(c1, ec1[1].a);
            connect(ec1, ec2);
            connect(ec2, ec3);
            connect(ec3[3].a, c2);
        end M;

        M m[2];

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConnectorArray",
            description="Expandable connector arrays: adding entire array without subscripts, within array component.",
            flatModel="
fclass ExpandableConnectorArrays.ConnectorArray
 ExpandableConnectorArrays.ConnectorArray.C m[1].ec1[1].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[1].ec1[3].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[1].ec2[1].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[1].ec2[3].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[1].ec3[1].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[1].ec3[3].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[1].c1[2];
 ExpandableConnectorArrays.ConnectorArray.C m[1].c2[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].ec1[1].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].ec1[3].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].ec2[1].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].ec2[3].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].ec3[1].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].ec3[3].a[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].c1[2];
 ExpandableConnectorArrays.ConnectorArray.C m[2].c2[2];
equation
 m[1].c1[1] = m[1].ec1[1].a[1];
 m[1].ec1[1].a[1] = m[1].ec2[1].a[1];
 m[1].ec2[1].a[1] = m[1].ec3[1].a[1];
 m[1].c1[2] = m[1].ec1[1].a[2];
 m[1].ec1[1].a[2] = m[1].ec2[1].a[2];
 m[1].ec2[1].a[2] = m[1].ec3[1].a[2];
 m[1].c2[1] = m[1].ec1[3].a[1];
 m[1].ec1[3].a[1] = m[1].ec2[3].a[1];
 m[1].ec2[3].a[1] = m[1].ec3[3].a[1];
 m[1].c2[2] = m[1].ec1[3].a[2];
 m[1].ec1[3].a[2] = m[1].ec2[3].a[2];
 m[1].ec2[3].a[2] = m[1].ec3[3].a[2];
 m[2].c1[1] = m[2].ec1[1].a[1];
 m[2].ec1[1].a[1] = m[2].ec2[1].a[1];
 m[2].ec2[1].a[1] = m[2].ec3[1].a[1];
 m[2].c1[2] = m[2].ec1[1].a[2];
 m[2].ec1[1].a[2] = m[2].ec2[1].a[2];
 m[2].ec2[1].a[2] = m[2].ec3[1].a[2];
 m[2].c2[1] = m[2].ec1[3].a[1];
 m[2].ec1[3].a[1] = m[2].ec2[3].a[1];
 m[2].ec2[3].a[1] = m[2].ec3[3].a[1];
 m[2].c2[2] = m[2].ec1[3].a[2];
 m[2].ec1[3].a[2] = m[2].ec2[3].a[2];
 m[2].ec2[3].a[2] = m[2].ec3[3].a[2];

public
 type ExpandableConnectorArrays.ConnectorArray.C = Real;
end ExpandableConnectorArrays.ConnectorArray;
")})));
    end ConnectorArray;



    model ConnectorSlice
        expandable connector EC
        end EC;

        connector C
            Real p;
            flow Real f;
        end C;

        EC ec1[2], ec2[2], ec3[2];
        C c[4];
    equation
        connect(c[1:2], ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c[3:4]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConnectorSlice",
            description="Expandable connectors: connect to slice",
            flatModel="
fclass ExpandableConnectorArrays.ConnectorSlice
 Real ec1[1].a.p;
 Real ec1[1].a.f;
 Real ec1[2].a.p;
 Real ec1[2].a.f;
 Real ec2[1].a.p;
 Real ec2[1].a.f;
 Real ec2[2].a.p;
 Real ec2[2].a.f;
 Real ec3[1].a.p;
 Real ec3[1].a.f;
 Real ec3[2].a.p;
 Real ec3[2].a.f;
 potential Real c[1].p;
 flow Real c[1].f;
 potential Real c[2].p;
 flow Real c[2].f;
 potential Real c[3].p;
 flow Real c[3].f;
 potential Real c[4].p;
 flow Real c[4].f;
equation
 - c[1].f - c[3].f - ec1[1].a.f - ec2[1].a.f - ec3[1].a.f = 0.0;
 c[1].p = c[3].p;
 c[3].p = ec1[1].a.p;
 ec1[1].a.p = ec2[1].a.p;
 ec2[1].a.p = ec3[1].a.p;
 - c[2].f - c[4].f - ec1[2].a.f - ec2[2].a.f - ec3[2].a.f = 0.0;
 c[2].p = c[4].p;
 c[4].p = ec1[2].a.p;
 ec1[2].a.p = ec2[2].a.p;
 ec2[2].a.p = ec3[2].a.p;
 ec1[1].a.f = 0.0;
 ec1[2].a.f = 0.0;
 ec2[1].a.f = 0.0;
 ec2[2].a.f = 0.0;
 ec3[1].a.f = 0.0;
 ec3[2].a.f = 0.0;
end ExpandableConnectorArrays.ConnectorSlice;
")})));
    end ConnectorSlice;


    model ConnectorSlicePrimitive
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[2], ec2[2], ec3[2];
        C c[4];
    equation
        connect(c[1:2], ec1.a);
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c[3:4]);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ConnectorSlicePrimitive",
            description="Expandable connectors: connect to slice",
            flatModel="
fclass ExpandableConnectorArrays.ConnectorSlicePrimitive
 Real ec1[1].a;
 Real ec1[2].a;
 Real ec2[1].a;
 Real ec2[2].a;
 Real ec3[1].a;
 Real ec3[2].a;
 Real c[4];
equation
 c[1] = c[3];
 c[3] = ec1[1].a;
 ec1[1].a = ec2[1].a;
 ec2[1].a = ec3[1].a;
 c[2] = c[4];
 c[4] = ec1[2].a;
 ec1[2].a = ec2[2].a;
 ec2[2].a = ec3[2].a;
end ExpandableConnectorArrays.ConnectorSlicePrimitive;
")})));
    end ConnectorSlicePrimitive;


    model SliceToSlice
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[2], ec2[3], ec3[4];
        C c[4];
    equation
        connect(c[1:2], ec1.a);
        connect(ec1[1:2], ec2[2:3]);
        connect(ec2[2:3], ec3[3:4]);
        connect(ec3.a, c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SliceToSlice",
            description="Expandable connectors: connect slice to slice",
            flatModel="
fclass ExpandableConnectorArrays.SliceToSlice
 Real ec1[1].a;
 Real ec1[2].a;
 Real ec2[2].a;
 Real ec2[3].a;
 Real ec3[1].a;
 Real ec3[2].a;
 Real ec3[3].a;
 Real ec3[4].a;
 Real c[4];
equation
 c[1] = c[3];
 c[3] = ec1[1].a;
 ec1[1].a = ec2[2].a;
 ec2[2].a = ec3[1].a;
 ec3[1].a = ec3[3].a;
 c[2] = c[4];
 c[4] = ec1[2].a;
 ec1[2].a = ec2[3].a;
 ec2[3].a = ec3[2].a;
 ec3[2].a = ec3[4].a;
end ExpandableConnectorArrays.SliceToSlice;
")})));
    end SliceToSlice;


    model SliceWithComponent
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[2], ec2[3];
        C c[3], c2[3,2];
    equation
        connect(c[1:2], ec1[1].a);
        connect(ec1, ec2[2:3]);
        connect(c2, ec2.a);
        c[1] = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SliceWithComponent",
            description="Expandable connectors: connect  of arrays.",
            flatModel="
fclass ExpandableConnectorArrays.SliceWithComponent
 Real ec1[1].a[2];
 Real ec1[2].a[2];
 Real ec2[1].a[2];
 Real ec2[2].a[2];
 Real ec2[3].a[2];
 Real c[3];
 Real c2[3,2];
equation
 c[1] = time;
 c2[2,1] = c[1];
 c[1] = ec1[1].a[1];
 ec1[1].a[1] = ec2[2].a[1];
 c2[2,2] = c[2];
 c[2] = ec1[1].a[2];
 ec1[1].a[2] = ec2[2].a[2];
 c2[3,1] = ec1[2].a[1];
 ec1[2].a[1] = ec2[3].a[1];
 c2[3,2] = ec1[2].a[2];
 ec1[2].a[2] = ec2[3].a[2];
 c2[1,1] = ec2[1].a[1];
 c2[1,2] = ec2[1].a[2];
end ExpandableConnectorArrays.SliceWithComponent;
")})));
    end SliceWithComponent;


    model MatrixSlices
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[2], ec2[3];
        C c1[2], c2[2,2];
    equation
        connect(ec1[1].a[1,:], c1);
        connect(ec1[2].b[:,1:2], c2);
        connect(ec2[3].a[:,1:2], c2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="MatrixSlices",
            description="Connecting to slice with colon of array in expandable connector array.",
            flatModel="
fclass ExpandableConnectorArrays.MatrixSlices
 Real ec1[1].a[1,2];
 Real ec1[2].b[2,2];
 Real ec2[3].a[2,2];
 Real c1[2];
 Real c2[2,2];
equation
 c1[1] = ec1[1].a[1,1];
 c1[2] = ec1[1].a[1,2];
 c2[1,1] = ec1[2].b[1,1];
 ec1[2].b[1,1] = ec2[3].a[1,1];
 c2[1,2] = ec1[2].b[1,2];
 ec1[2].b[1,2] = ec2[3].a[1,2];
 c2[2,1] = ec1[2].b[2,1];
 ec1[2].b[2,1] = ec2[3].a[2,1];
 c2[2,2] = ec1[2].b[2,2];
 ec1[2].b[2,2] = ec2[3].a[2,2];
end ExpandableConnectorArrays.MatrixSlices;
")})));
    end MatrixSlices;


    model MemberAccess
        expandable connector EC
            Real x;
        end EC;

        connector C = Real;

        C c1, c2, c3, c4;
        EC ec[3];
        Real q;
    equation
        connect(c1, ec[1].a);
        connect(c2, ec[2].b);
        connect(c3, ec[3].c);
        connect(c4, ec[1].x);
        connect(ec[1], ec[2]);

        q = ec[1].x;

        c1 = time;
        c2 = time;
        c3 = time;
        c4 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="MemberAccess",
            description="Using members of expandable connector array.",
            flatModel="
fclass ExpandableConnectorArrays.MemberAccess
 Real c1;
 Real c2;
 Real c3;
 Real c4;
 Real ec[1].a;
 Real ec[1].b;
 Real ec[1].x;
 Real ec[2].a;
 Real ec[2].b;
 Real ec[2].x;
 Real ec[3].c;
 Real q;
equation
 q = ec[1].x;
 c1 = time;
 c2 = time;
 c3 = time;
 c4 = time;
 c1 = ec[1].a;
 ec[1].a = ec[2].a;
 c2 = ec[1].b;
 ec[1].b = ec[2].b;
 c3 = ec[3].c;
 c4 = ec[1].x;
 ec[1].x = ec[2].x;
end ExpandableConnectorArrays.MemberAccess;
")})));
    end MemberAccess;


    model NestedAccess
        expandable connector EC1
            EC2 ec2[3];
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        EC1 ec1[2];
        C c1[2], c2[2];
    equation
        connect(c1, ec1.ec2[2].a);
        connect(c2, ec1.ec2[1].b);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedAccess",
            description="Nested declared expandable connector ",
            flatModel="
fclass ExpandableConnectorArrays.NestedAccess
 Real ec1[1].ec2[1].b;
 Real ec1[1].ec2[2].a;
 Real ec1[2].ec2[1].b;
 Real ec1[2].ec2[2].a;
 Real c1[2];
 Real c2[2];
equation
 c1[1] = ec1[1].ec2[2].a;
 c1[2] = ec1[2].ec2[2].a;
 c2[1] = ec1[1].ec2[1].b;
 c2[2] = ec1[2].ec2[1].b;
end ExpandableConnectorArrays.NestedAccess;
")})));
    end NestedAccess;


    model NestedDisconnected
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
            name="NestedDisconnected",
            description="Nested declared expandable connector arrays: not connected.",
            flatModel="
fclass ExpandableConnectorArrays.NestedDisconnected
 Real c2;
end ExpandableConnectorArrays.NestedDisconnected;
")})));
    end NestedDisconnected;


    model NestedAccesses
        expandable connector EC1
            EC2 ec2[4];
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        EC1 ec1[3];
        C c1, c2;
    equation
        connect(c1, ec1[1].ec2[3].a);
        connect(c2, ec1[1].b);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedAccesses",
            description="Nested accesses to expandable connectors.",
            flatModel="
fclass ExpandableConnectorArrays.NestedAccesses
 Real ec1[1].b;
 Real ec1[1].ec2[3].a;
 Real c1;
 Real c2;
equation
 c1 = ec1[1].ec2[3].a;
 c2 = ec1[1].b;
end ExpandableConnectorArrays.NestedAccesses;
")})));
    end NestedAccesses;


    model NestedConnections
        expandable connector EC1
            EC2 ec2[3];
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        constant Integer n = 3;

        EC1 ec1[n];
        EC2 ec3[n];
        EC1 ec4[n];

        C c1[n], c2;
    equation
        connect(c1, ec1.ec2[1].a);
        connect(ec1[2].ec2, ec3);
        connect(ec4[1], ec1[2].ec2[2]);
        connect(ec1, ec4);
        connect(ec4[1].ec2[2].b, c2);
        c1 = (1:n) * time;
        c2 = time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedConnections",
            description="Nested expandable connectors, different connection levels.",
            flatModel="
fclass ExpandableConnectorArrays.NestedConnections
 constant Integer n = 3;
 Real ec1[1].ec2[1].a;
 Real ec1[1].ec2[2].b;
 Real ec1[2].ec2[1].a;
 Real ec1[2].ec2[2].ec2[1].a;
 Real ec1[2].ec2[2].ec2[2].b;
 Real ec1[3].ec2[1].a;
 Real ec3[1].a;
 Real ec3[2].ec2[1].a;
 Real ec3[2].ec2[2].b;
 Real ec4[1].ec2[1].a;
 Real ec4[1].ec2[2].b;
 Real ec4[2].ec2[1].a;
 Real ec4[2].ec2[2].ec2[1].a;
 Real ec4[2].ec2[2].ec2[2].b;
 Real ec4[3].ec2[1].a;
 Real c1[3];
 Real c2;
equation
 c1[1:3] = (1:3) * time;
 c2 = time;
 c1[2] = ec1[2].ec2[1].a;
 ec1[2].ec2[1].a = ec3[1].a;
 ec3[1].a = ec4[2].ec2[1].a;
 c1[3] = ec1[3].ec2[1].a;
 ec1[3].ec2[1].a = ec4[3].ec2[1].a;
 c1[1] = ec1[1].ec2[1].a;
 ec1[1].ec2[1].a = ec1[2].ec2[2].ec2[1].a;
 ec1[2].ec2[2].ec2[1].a = ec3[2].ec2[1].a;
 ec3[2].ec2[1].a = ec4[1].ec2[1].a;
 ec4[1].ec2[1].a = ec4[2].ec2[2].ec2[1].a;
 c2 = ec1[1].ec2[2].b;
 ec1[1].ec2[2].b = ec1[2].ec2[2].ec2[2].b;
 ec1[2].ec2[2].ec2[2].b = ec3[2].ec2[2].b;
 ec3[2].ec2[2].b = ec4[1].ec2[2].b;
 ec4[1].ec2[2].b = ec4[2].ec2[2].ec2[2].b;
end ExpandableConnectorArrays.NestedConnections;
")})));
    end NestedConnections;


    model NestedConnectionSizes
        expandable connector EC1
            EC2 ec2[n];
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        constant Integer n = 2;

        EC1 ec1[n];
        EC2 ec3[n,n];

        C c1[n,n,n], c2[n,n];
    equation
        connect(c1, ec1.ec2.a);
        connect(c2, ec1.ec2.b);
        connect(ec1.ec2, ec3);
        c1 = fill(time, n, n, n);
        c2 = fill(time, n, n);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedConnectionSizes",
            description="Nested expandable connectors, different connection levels.",
            flatModel="
fclass ExpandableConnectorArrays.NestedConnectionSizes
 constant Integer n = 2;
 Real ec1[1].ec2[1].a[2];
 Real ec1[1].ec2[1].b;
 Real ec1[1].ec2[2].a[2];
 Real ec1[1].ec2[2].b;
 Real ec1[2].ec2[1].a[2];
 Real ec1[2].ec2[1].b;
 Real ec1[2].ec2[2].a[2];
 Real ec1[2].ec2[2].b;
 Real ec3[1,1].a[2];
 Real ec3[1,1].b;
 Real ec3[1,2].a[2];
 Real ec3[1,2].b;
 Real ec3[2,1].a[2];
 Real ec3[2,1].b;
 Real ec3[2,2].a[2];
 Real ec3[2,2].b;
 Real c1[2,2,2];
 Real c2[2,2];
equation
 c1[1:2,1:2,1:2] = fill(time, 2, 2, 2);
 c2[1:2,1:2] = fill(time, 2, 2);
 c1[1,1,1] = ec1[1].ec2[1].a[1];
 ec1[1].ec2[1].a[1] = ec3[1,1].a[1];
 c1[1,1,2] = ec1[1].ec2[1].a[2];
 ec1[1].ec2[1].a[2] = ec3[1,1].a[2];
 c1[1,2,1] = ec1[1].ec2[2].a[1];
 ec1[1].ec2[2].a[1] = ec3[1,2].a[1];
 c1[1,2,2] = ec1[1].ec2[2].a[2];
 ec1[1].ec2[2].a[2] = ec3[1,2].a[2];
 c1[2,1,1] = ec1[2].ec2[1].a[1];
 ec1[2].ec2[1].a[1] = ec3[2,1].a[1];
 c1[2,1,2] = ec1[2].ec2[1].a[2];
 ec1[2].ec2[1].a[2] = ec3[2,1].a[2];
 c1[2,2,1] = ec1[2].ec2[2].a[1];
 ec1[2].ec2[2].a[1] = ec3[2,2].a[1];
 c1[2,2,2] = ec1[2].ec2[2].a[2];
 ec1[2].ec2[2].a[2] = ec3[2,2].a[2];
 c2[1,1] = ec1[1].ec2[1].b;
 ec1[1].ec2[1].b = ec3[1,1].b;
 c2[1,2] = ec1[1].ec2[2].b;
 ec1[1].ec2[2].b = ec3[1,2].b;
 c2[2,1] = ec1[2].ec2[1].b;
 ec1[2].ec2[1].b = ec3[2,1].b;
 c2[2,2] = ec1[2].ec2[2].b;
 ec1[2].ec2[2].b = ec3[2,2].b;
end ExpandableConnectorArrays.NestedConnectionSizes;
")})));
    end NestedConnectionSizes;

    model NestedAndSlices
        expandable connector EC1
            EC2 ec2[3];
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        EC1 ec1a[2], ec1b[3];
        EC2 ec2[4];
        C c[3,3];
    equation
        connect(c[1:2,1], ec1a[1:2].a);
        connect(ec1a.ec2[1], ec2[2:3]);
        connect(ec1b[2:3].ec2[1], ec2[2:3]);
        connect(c, ec1b.ec2.b);
        connect(c, ec2[2:end].d); // TODO: Looks like the indices are wrong when adding this connect 
                                  //       to ConnectionSetManager after elaboration
        connect(c[2:3,2:3], ec1b[2:3].ec2[2:3].e);
        c = {1:3, 4:6, 7:9} .* time;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="NestedAndSlices",
            description="Expandable connectors: connect of arrays.",
            flatModel="
fclass ExpandableConnectorArrays.NestedAndSlices
 Real ec1a[1].a;
 Real ec1a[1].ec2[1].b;
 Real ec1a[1].ec2[1].d[3];
 Real ec1a[2].a;
 Real ec1a[2].ec2[1].b;
 Real ec1a[2].ec2[1].d[3];
 Real ec1b[1].ec2[1].b;
 Real ec1b[1].ec2[2].b;
 Real ec1b[1].ec2[3].b;
 Real ec1b[2].ec2[1].b;
 Real ec1b[2].ec2[1].d[3];
 Real ec1b[2].ec2[2].b;
 Real ec1b[2].ec2[2].e;
 Real ec1b[2].ec2[3].b;
 Real ec1b[2].ec2[3].e;
 Real ec1b[3].ec2[1].b;
 Real ec1b[3].ec2[1].d[3];
 Real ec1b[3].ec2[2].b;
 Real ec1b[3].ec2[2].e;
 Real ec1b[3].ec2[3].b;
 Real ec1b[3].ec2[3].e;
 Real ec2[2].b;
 Real ec2[2].d[3];
 Real ec2[3].b;
 Real ec2[3].d[3];
 Real ec2[4].d[3];
 Real c[3,3];
equation
 c[1:3,1:3] = {1:3, 4:6, 7:9} .* time;
 c[1,1] = ec1a[1].a;
 ec1a[1].a = ec1a[1].ec2[1].d[2];
 ec1a[1].ec2[1].d[2] = ec1b[1].ec2[1].b;
 ec1b[1].ec2[1].b = ec1b[2].ec2[1].d[2];
 ec1b[2].ec2[1].d[2] = ec2[2].d[2];
 c[2,1] = ec1a[1].ec2[1].b;
 ec1a[1].ec2[1].b = ec1a[2].a;
 ec1a[2].a = ec1b[2].ec2[1].b;
 ec1b[2].ec2[1].b = ec2[2].b;
 ec1a[1].ec2[1].d[1] = ec1b[2].ec2[1].d[1];
 ec1b[2].ec2[1].d[1] = ec2[2].d[1];
 ec1a[1].ec2[1].d[3] = ec1b[2].ec2[1].d[3];
 ec1b[2].ec2[1].d[3] = ec2[2].d[3];
 c[3,1] = ec1a[2].ec2[1].b;
 ec1a[2].ec2[1].b = ec1b[3].ec2[1].b;
 ec1b[3].ec2[1].b = ec2[3].b;
 ec1a[2].ec2[1].d[1] = ec1b[3].ec2[1].d[1];
 ec1b[3].ec2[1].d[1] = ec2[3].d[1];
 ec1a[2].ec2[1].d[2] = ec1b[3].ec2[1].d[2];
 ec1b[3].ec2[1].d[2] = ec2[3].d[2];
 c[1,2] = ec1a[2].ec2[1].d[3];
 ec1a[2].ec2[1].d[3] = ec1b[1].ec2[2].b;
 ec1b[1].ec2[2].b = ec1b[3].ec2[1].d[3];
 ec1b[3].ec2[1].d[3] = ec2[3].d[3];
 c[1,3] = ec1b[1].ec2[3].b;
 ec1b[1].ec2[3].b = ec2[4].d[4];
 c[2,2] = ec1b[2].ec2[2].b;
 ec1b[2].ec2[2].b = ec1b[2].ec2[2].e;
 c[2,3] = ec1b[2].ec2[3].b;
 ec1b[2].ec2[3].b = ec1b[2].ec2[3].e;
 c[3,2] = ec1b[3].ec2[2].b;
 ec1b[3].ec2[2].b = ec1b[3].ec2[2].e;
 c[3,3] = ec1b[3].ec2[3].b;
 ec1b[3].ec2[3].b = ec1b[3].ec2[3].e;
 ec2[4].d[1] = 0.0;
 ec2[4].d[2] = 0.0;
 ec2[4].d[3] = 0.0;
end ExpandableConnectorArrays.NestedAndSlices;
")})));
    end NestedAndSlices;

    model LoopedConnection
        expandable connector EC
        end EC;

        connector C = Real;

        model M
            C c;
        end M;

        parameter Integer n = 4;

        EC ec[n];
        M m[n];
    equation
        for i in 1:(n-2) loop
            connect(ec[i], ec[i+2]);
            connect(ec[i].a, m[i].c);
        end for;
        connect(ec[end-1].a, m[end-1].c);
        connect(ec[end].a, m[end].c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoopedConnection",
            description="Connecting to expandable connector in for loop",
            flatModel="
fclass ExpandableConnectorArrays.LoopedConnection
 structural parameter Integer n = 4 /* 4 */;
 Real ec[1].a;
 Real ec[2].a;
 Real ec[3].a;
 Real ec[4].a;
 Real m[1].c;
 Real m[2].c;
 Real m[3].c;
 Real m[4].c;
equation
 ec[1].a = ec[3].a;
 ec[3].a = m[1].c;
 m[1].c = m[3].c;
 ec[2].a = ec[4].a;
 ec[4].a = m[2].c;
 m[2].c = m[4].c;
end ExpandableConnectorArrays.LoopedConnection;
")})));
    end LoopedConnection;
    
    
    model LoopedNested1
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        parameter Integer n = 2;
        
        EC ec1, ec2[n];
        C c;
    equation
        for i in 1:n loop
            connect(ec1.a[i], ec2[i]);
            connect(ec1.a[i].b[i], c);
        end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoopedNested1",
            description="Introducing connections in a loop, index used on two levels, non-declared nested, outer first",
            flatModel="
fclass ExpandableConnectorArrays.LoopedNested1
 structural parameter Integer n = 2 /* 2 */;
 Real ec1.a[1].b[1];
 Real ec1.a[2].b[2];
 Real ec2[1].b[1];
 Real ec2[2].b[2];
 Real c;
equation
 c = ec1.a[1].b[1];
 ec1.a[1].b[1] = ec1.a[2].b[2];
 ec1.a[2].b[2] = ec2[1].b[1];
 ec2[1].b[1] = ec2[2].b[2];
 ec1.a[2].b[1] = ec2[2].b[1];
end ExpandableConnectorArrays.LoopedNested1;
")})));
    end LoopedNested1;
    
    
    model LoopedNested2
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        parameter Integer n = 2;
        
        EC ec1[n], ec2;
        C c;
    equation
        for i in 1:n loop
            connect(ec2.a[i].b[i], c);
            connect(ec2.a[i], ec1[i]);
        end for;

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoopedNested2",
            description="Introducing connections in a loop, index used on two levels, non-declared nested, inner first",
            flatModel="
fclass ExpandableConnectorArrays.LoopedNested2
 structural parameter Integer n = 2 /* 2 */;
 Real ec1[1].b[1];
 Real ec1[2].b[2];
 Real ec2.a[1].b[1];
 Real ec2.a[2].b[2];
 Real c;
equation
 c = ec1[1].b[1];
 ec1[1].b[1] = ec1[2].b[2];
 ec1[2].b[2] = ec2.a[1].b[1];
 ec2.a[1].b[1] = ec2.a[2].b[2];
 ec1[2].b[1] = ec2.a[2].b[1];
end ExpandableConnectorArrays.LoopedNested2;
")})));
    end LoopedNested2;
    
    
    model LoopedNested3
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        parameter Integer n = 2;
        
        EC ec1[n], ec2[n];
        C c;
    equation
        for i in 1:n loop
            connect(ec1[i].a, ec2[i]);
            connect(ec1[i].a.b[i], c);
        end for;
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoopedNested3",
            description="Introducing connections in a loop, index used on two levels, non-declared nested, outer first",
            flatModel="
fclass ExpandableConnectorArrays.LoopedNested3
 structural parameter Integer n = 2 /* 2 */;
 Real ec1[1].a.b[1];
 Real ec1[2].a.b[2];
 Real ec2[1].b[1];
 Real ec2[2].b[2];
 Real c;
equation
 c = ec1[1].a.b[1];
 ec1[1].a.b[1] = ec1[2].a.b[2];
 ec1[2].a.b[2] = ec2[1].b[1];
 ec2[1].b[1] = ec2[2].b[2];
 ec1[2].a.b[1] = ec2[2].b[1];
end ExpandableConnectorArrays.LoopedNested3;
")})));
    end LoopedNested3;
    
    
    model LoopedNested4
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        parameter Integer n = 2;
        
        EC ec1[n], ec2[n];
        C c;
    equation
        for i in 1:n loop
            connect(ec2[i].a.b[i], c);
            connect(ec2[i].a, ec1[i]);
        end for;
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="LoopedNested4",
            description="Introducing connections in a loop, index used on two levels, non-declared nested, inner first",
            flatModel="
fclass ExpandableConnectorArrays.LoopedNested4
 structural parameter Integer n = 2 /* 2 */;
 Real ec1[1].b[1];
 Real ec1[2].b[2];
 Real ec2[1].a.b[1];
 Real ec2[2].a.b[2];
 Real c;
equation
 c = ec1[1].b[1];
 ec1[1].b[1] = ec1[2].b[2];
 ec1[2].b[2] = ec2[1].a.b[1];
 ec2[1].a.b[1] = ec2[2].a.b[2];
 ec1[2].b[1] = ec2[2].a.b[1];
end ExpandableConnectorArrays.LoopedNested4;
")})));
    end LoopedNested4;
    
    
    model SliceNested1
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2[3];
        C c[3];
    equation
        connect(ec1.a[2:3], ec2[3:-1:2]);
        connect(ec2.b, c);
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SliceNested1",
            description="",
            flatModel="
fclass ExpandableConnectorArrays.SliceNested1
 Real ec1.a[2].b;
 Real ec1.a[3].b;
 Real ec2[1].b;
 Real ec2[2].b;
 Real ec2[3].b;
 Real c[3];
equation
 c[3] = ec1.a[2].b;
 ec1.a[2].b = ec2[3].b;
 c[2] = ec1.a[3].b;
 ec1.a[3].b = ec2[2].b;
 c[1] = ec2[1].b;
end ExpandableConnectorArrays.SliceNested1;
")})));
    end SliceNested1;
    
    
    model SliceNested2
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2[2,2];
        C c[2,2];
    equation
        connect(ec1.a, ec2[1,:]);
        connect(ec2.b, c);
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="SliceNested2",
            description="",
            flatModel="
fclass ExpandableConnectorArrays.SliceNested2
 Real ec1.a[1].b;
 Real ec1.a[2].b;
 Real ec2[1,1].b;
 Real ec2[1,2].b;
 Real ec2[2,1].b;
 Real ec2[2,2].b;
 Real c[2,2];
equation
 c[1,1] = ec1.a[1].b;
 ec1.a[1].b = ec2[1,1].b;
 c[1,2] = ec1.a[2].b;
 ec1.a[2].b = ec2[1,2].b;
 c[2,1] = ec2[2,1].b;
 c[2,2] = ec2[2,2].b;
end ExpandableConnectorArrays.SliceNested2;
")})));
    end SliceNested2;
    
    
    // TODO: For some reason this flattens to an empty class even though the ExpandableSets look fine.
    model SliceNested3
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1[2], ec2[2,2];
        C c[2,2];
    equation
        connect(ec1.a, ec2);
        connect(ec2.b, c);
    end SliceNested3;
    
    
    // TODO: 
    model SliceNested4
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2[2];
        C c[2, 2];
    equation
        connect(ec1.a, ec2[:]);
        connect(ec1.a[1:2].b[1:2], c);
    end SliceNested4;
    
    
    // TODO: For some reason most of the variables and connections disappear.
    model SliceNested5
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2[5];
        C c;
    equation
        connect(ec1.a[2:3], ec2[3:4]);
        connect(ec1.a[1:3].b, c);
//    annotation(__JModelica(UnitTesting(tests={
//        FlatteningTestCase(
//            name="SliceNested5",
//            description="",
//            flatModel="
//fclass ExpandableConnectorArrays.SliceNested5
// Real ec1.a[1].b; // All these variables should be here, right?
// Real ec1.a[2].b;
// Real ec1.a[3].b;
// Real ec2[3].b;
// Real ec2[4].b;
// Real c;
//equation
//end ExpandableConnectorArrays.SliceNested5;
//")})));
    end SliceNested5;
    
    
    model ThroughScalar
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3;
        
        C c1, c2;
    equation
        connect(ec2.b, c1);
        connect(ec3.d, c2);
        connect(ec1.a, ec2);
        connect(ec1.a, ec3);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ThroughScalar",
            description="Connecting expandable connectors through a scalar non-declared nested expandable connector",
            flatModel="
fclass ExpandableConnectorArrays.ThroughScalar
 Real ec1.a.b;
 Real ec1.a.d;
 Real ec2.b;
 Real ec2.d;
 Real ec3.b;
 Real ec3.d;
 Real c1;
 Real c2;
equation
 c1 = ec1.a.b;
 ec1.a.b = ec2.b;
 ec2.b = ec3.b;
 c2 = ec1.a.d;
 ec1.a.d = ec2.d;
 ec2.d = ec3.d;
end ExpandableConnectorArrays.ThroughScalar;
")})));
    end ThroughScalar;
    
    model ThroughArray
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1, ec2, ec3, ec4;
        
        C c1, c2;
    equation
        connect(ec2.b, c1);
        connect(ec4.d, c2);
        connect(ec1.a[1], ec2);
        connect(ec1.a[1], ec3);
        connect(ec1.a[2], ec4);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ThroughArray",
            description="Connecting expandable connectors through an array cell, and make contents is not propagated to other cells in same array",
            flatModel="
fclass ExpandableConnectorArrays.ThroughArray
 Real ec1.a[1].b;
 Real ec1.a[2].d;
 Real ec2.b;
 Real ec3.b;
 Real ec4.d;
 Real c1;
 Real c2;
equation
 c1 = ec1.a[1].b;
 ec1.a[1].b = ec2.b;
 ec2.b = ec3.b;
 c2 = ec1.a[2].d;
 ec1.a[2].d = ec4.d;
end ExpandableConnectorArrays.ThroughArray;
")})));
    end ThroughArray;

/* TODO: Array of expandable sub-connector declared with [:]??? */
/*
expandable connector EC
    EC2 ec[:];
end EC;
*/


/* TODO: Template that is of a type containing an array size. */
// Real[2] x; type A = Real[2](unit = "K"); A y;

package Error

/* TODO: Add test with connection where both sides are introducing members, and improve error message for that. */

    model MismatchingSize
        expandable connector EC
        end EC;

        parameter Integer n = 2;

        EC ec1[n], ec2[n + 1];
    equation
        connect(ec1, ec2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Error_MismatchingSize",
            description="Mismatching sizes.",
            errorMessage="
Error at line 9, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of 'ec1' is [2] and size of 'ec2' is [3]
")})));
    end MismatchingSize;


    model ExpandableToExpandableArray
        expandable connector EC
        end EC;

        connector C = Real;

        parameter Integer n = 2;

        EC ec1, ec2[n];
        C c1;
    equation
        connect(c1, ec2[2].a);
        connect(ec1, ec2);
        c1 = time;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Error_ExpandableToExpandableArray",
            description="Attempt to connect an expandable connector to an
                         expandable connector array cell element.",
            errorMessage="
Error at line 13, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of 'ec1' is scalar and size of 'ec2' is [2]
")})));
    end ExpandableToExpandableArray;

    model ExpandableToExpandableArrayCellElement
        expandable connector EC
        end EC;

        connector C = Real;

        parameter Integer n = 2;

        EC ec1[n], ec2[n];
        C c1;
    equation
        connect(ec1, ec2[2]);
        connect(c1, ec2[2].a);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Error_ExpandableToExpandableArrayCellElement",
            description="Mismatching sizes.",
            errorMessage="
Error at line 12, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of 'ec1' is [2] and size of 'ec2[2]' is scalar
")})));
    end ExpandableToExpandableArrayCellElement;


    model WrongSizeSlice
        expandable connector EC
        end EC;

        connector C = Real;

        EC ec1[3], ec2[3], ec3[3];
        C c[4];
        C c2[2,3];
    equation
        connect(c[1:2], ec1.a); /* Error */
        connect(ec1, ec2);
        connect(ec2, ec3);
        connect(ec3.a, c[3:4]); /* Error */
        connect(ec1.b, c2);     /* Error */

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Error_WrongSizeSlice",
            description="Mismatching sizes.",
            errorMessage="
Error at line 11, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of the part of 'ec1.a' referring to the expandable connector is [3] and size of 'c[1:2]' is [2]

Error at line 14, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of the part of 'ec3.a' referring to the expandable connector is [3] and size of 'c[3:4]' is [2]

Error at line 15, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of the part of 'ec1.b' referring to the expandable connector is [3] and size of 'c2' is [2, 3]
")})));
    end WrongSizeSlice;
    
    
    model WrongNdimsInSlice
        expandable connector EC1
            EC2 ec2[3];
        end EC1;

        expandable connector EC2
        end EC2;

        connector C = Real;

        constant Integer n = 3;

        EC1 ec1[n];
        EC2 ec3[n];

        C c1;
    equation
        connect(c1, ec1.ec2[1].a);        /* Error */
        connect(ec1.ec2, ec3);            /* Error */
        c1 = time;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="Error_WrongNdimsInSlice",
            description="Mismatching sizes.",
            errorMessage="
Error at line 18, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of the part of 'ec1.ec2[1].a' referring to the expandable connector is [3] and size of 'c1' is scalar

Error at line 19, column 9, in file '...', ARRAY_SIZE_MISMATCH_IN_CONNECT:
  Sizes do not match in connection, size of 'ec1.ec2' is [3, 3] and size of 'ec3' is [3]
")})));
    end WrongNdimsInSlice;
    
    
    // TODO: This should give an error because the ndims in second connect does not match
    model WrongNdimsInSlice2
        expandable connector EC
        end EC;
        
        connector C = Real;
        
        EC ec1;
        EC ec2[2];
        C c[2, 2];
    equation
        connect(ec1.a, ec2[:]);
        connect(ec1.a[1:2].b[:, 1:2], c);
    end WrongNdimsInSlice2;

// TODO: Add test of recursion error through array - see Source.checkRecursion (ExpandableConnectors.jrag:803)

end Error;



end ExpandableConnectorArrays;
