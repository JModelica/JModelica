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

package OverconstrainedConnection

model OverconstrainedCorrect1
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
equation
	connect(c1, c3);
    connect(c2, c4);
    Connections.branch(c1.t, c2.t);
	c1.t = c2.t;
    Connections.branch(c3.t, c4.t);
	c3.t = c4.t;
	Connections.root(c1.t);
	c1.t[1] = 0;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect1",
        description="Basic test of overconstrained connection graphs",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect1
 potential OverconstrainedConnection.OverconstrainedCorrect1.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect1.T1 c2.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect1.T1 c3.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect1.T1 c4.t[2];
equation
 c1.t[1:2] = c2.t[1:2];
 c3.t[1:2] = c4.t[1:2];
 c1.t[1] = 0;
 c1.t[1:2] = c3.t[1:2];
 zeros(1) = OverconstrainedConnection.OverconstrainedCorrect1.T1.equalityConstraint(c2.t[1:2], c4.t[1:2]);

public
 function OverconstrainedConnection.OverconstrainedCorrect1.T1.equalityConstraint
  input Real[:] i1;
  input Real[:] i2;
  output Real[:] o;
 algorithm
  assert(2 == size(i1, 1), \"Mismatching sizes in function 'OverconstrainedConnection.OverconstrainedCorrect1.T1.equalityConstraint', component 'i1', dimension '1'\");
  assert(2 == size(i2, 1), \"Mismatching sizes in function 'OverconstrainedConnection.OverconstrainedCorrect1.T1.equalityConstraint', component 'i2', dimension '1'\");
  init o as Real[1];
  o[1:1] := sum(i1[1:2] .+ i2[1:2]);
  return;
 end OverconstrainedConnection.OverconstrainedCorrect1.T1.equalityConstraint;

 type OverconstrainedConnection.OverconstrainedCorrect1.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect1;
")})));
end OverconstrainedCorrect1;


model OverconstrainedCorrect2
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
equation
    connect(c1, c3);
    connect(c2, c4);
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.branch(c3.t, c4.t);
    c3.t = c4.t;
    Connections.potentialRoot(c1.t);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect2",
        description="Overconstrained connection graphs with potential roots",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect2
 potential OverconstrainedConnection.OverconstrainedCorrect2.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect2.T1 c2.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect2.T1 c3.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect2.T1 c4.t[2];
equation
 c1.t[1:2] = c2.t[1:2];
 c3.t[1:2] = c4.t[1:2];
 c1.t[1] = 0;
 c1.t[1:2] = c3.t[1:2];
 zeros(1) = OverconstrainedConnection.OverconstrainedCorrect2.T1.equalityConstraint(c2.t[1:2], c4.t[1:2]);

public
 function OverconstrainedConnection.OverconstrainedCorrect2.T1.equalityConstraint
  input Real[:] i1;
  input Real[:] i2;
  output Real[:] o;
 algorithm
  assert(2 == size(i1, 1), \"Mismatching sizes in function 'OverconstrainedConnection.OverconstrainedCorrect2.T1.equalityConstraint', component 'i1', dimension '1'\");
  assert(2 == size(i2, 1), \"Mismatching sizes in function 'OverconstrainedConnection.OverconstrainedCorrect2.T1.equalityConstraint', component 'i2', dimension '1'\");
  init o as Real[1];
  o[1:1] := sum(i1[1:2] .+ i2[1:2]);
  return;
 end OverconstrainedConnection.OverconstrainedCorrect2.T1.equalityConstraint;

 type OverconstrainedConnection.OverconstrainedCorrect2.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect2;
")})));
end OverconstrainedCorrect2;


model OverconstrainedCorrect3
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.potentialRoot(c1.t, 1);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect3",
        description="Simple root selection and isRoot()",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect3
 potential OverconstrainedConnection.OverconstrainedCorrect3.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect3.T1 c2.t[2];
 constant Boolean c1Root1 = false;
 constant Boolean c1Root2 = false;
 constant Boolean c2Root1 = true;
 constant Boolean c2Root2 = true;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;

public
 type OverconstrainedConnection.OverconstrainedCorrect3.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect3;
")})));
end OverconstrainedCorrect3;


model OverconstrainedCorrect4
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect4",
        description="Simple root selection and isRoot()",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect4
 potential OverconstrainedConnection.OverconstrainedCorrect4.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect4.T1 c2.t[2];
 constant Boolean c1Root1 = false;
 constant Boolean c1Root2 = false;
 constant Boolean c2Root1 = true;
 constant Boolean c2Root2 = true;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;

public
 type OverconstrainedConnection.OverconstrainedCorrect4.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect4;
")})));
end OverconstrainedCorrect4;


model OverconstrainedCorrect5
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    Connections.branch(c1.t, c2.t);
    c1.t = c2.t;
    Connections.root(c1.t);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect5",
        description="Simple root selection and isRoot(), unbreakable branch",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect5
 potential OverconstrainedConnection.OverconstrainedCorrect5.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect5.T1 c2.t[2];
 constant Boolean c1Root1 = true;
 constant Boolean c1Root2 = true;
 constant Boolean c2Root1 = false;
 constant Boolean c2Root2 = false;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;

public
 type OverconstrainedConnection.OverconstrainedCorrect5.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect5;
")})));
end OverconstrainedCorrect5;


model OverconstrainedCorrect6
connector C1
    Real x;
	flow Real y;
end C1;
	C1 c1;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect6",
        description="Unconnected connector",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect6
 potential Real c1.x;
 flow Real c1.y;
end OverconstrainedConnection.OverconstrainedCorrect6;
")})));
end OverconstrainedCorrect6;


model OverconstrainedCorrect7
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    connect(c1, c2);
    c1.t = c2.t;
    Connections.root(c1.t);
    Connections.potentialRoot(c2.t);
    c1.t[1] = 0;

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect7",
        description="Simple root selection and isRoot(), breakable branch",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect7
 potential OverconstrainedConnection.OverconstrainedCorrect7.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect7.T1 c2.t[2];
 constant Boolean c1Root1 = true;
 constant Boolean c1Root2 = true;
 constant Boolean c2Root1 = false;
 constant Boolean c2Root2 = false;
equation
 c1.t[1:2] = c2.t[1:2];
 c1.t[1] = 0;
 c1.t[1:2] = c2.t[1:2];

public
 type OverconstrainedConnection.OverconstrainedCorrect7.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect7;
")})));
end OverconstrainedCorrect7;


model OverconstrainedCorrect8
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    C1 c3;
    constant Boolean c1Root1 = Connections.isRoot(c1.t);
    constant Boolean c1Root2 = c1Root1;
    constant Boolean c2Root1 = Connections.isRoot(c2.t);
    constant Boolean c2Root2 = c2Root1;
equation
    Connections.root(c3.t);
    Connections.potentialRoot(c1.t);
    Connections.root(c2.t);
    connect(c1, c2);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect8",
        description="Test model that failed due to ordering of roots",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect8
 potential OverconstrainedConnection.OverconstrainedCorrect8.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect8.T1 c2.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect8.T1 c3.t[2];
 constant Boolean c1Root1 = false;
 constant Boolean c1Root2 = false;
 constant Boolean c2Root1 = true;
 constant Boolean c2Root2 = true;
equation
 c1.t[1:2] = c2.t[1:2];

public
 type OverconstrainedConnection.OverconstrainedCorrect8.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect8;
")})));
end OverconstrainedCorrect8;

model OverconstrainedCorrect9
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
equation
    c1.t = {time, -time};
    connect(c1,c2);
    connect(c1,c2);
    Connections.root(c1.t);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="OverconstrainedCorrect9",
        description="Ensure that we handle multiple connections between the same nodes",
        flatModel="
fclass OverconstrainedConnection.OverconstrainedCorrect9
 potential OverconstrainedConnection.OverconstrainedCorrect9.T1 c1.t[2];
 potential OverconstrainedConnection.OverconstrainedCorrect9.T1 c2.t[2];
equation
 c1.t[1:2] = {time, - time};
 c1.t[1:2] = c2.t[1:2];

public
 type OverconstrainedConnection.OverconstrainedCorrect9.T1 = Real;
end OverconstrainedConnection.OverconstrainedCorrect9;
")})));
end OverconstrainedCorrect9;

model OverconstrainedUnrooted1
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

	C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
equation
    Connections.branch(c1.t, c2.t);
    Connections.branch(c3.t, c4.t);
	Connections.root(c1.t);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OverconstrainedUnrooted1",
            description="Unconnected connector set",
            errorMessage="
1 errors found:

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Set of unrooted connectors in overconstrained connection graph:
    c3.t
    c4.t
")})));
end OverconstrainedUnrooted1;


model OverconstrainedUnrooted2
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

	C1 c1,c2,c3,c4,c5;
equation
    Connections.branch(c1.t, c2.t);
    Connections.branch(c2.t, c3.t);
	Connections.branch(c4.t, c5.t);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OverconstrainedUnrooted2",
            description="Unconnected connector sets",
            errorMessage="
2 errors found:

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Set of unrooted connectors in overconstrained connection graph:
    c1.t
    c2.t
    c3.t

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Set of unrooted connectors in overconstrained connection graph:
    c4.t
    c5.t
")})));
end OverconstrainedUnrooted2;


model OverconstrainedMultipleRoot1
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

	C1 c1,c2,c3,c4;
equation
    Connections.branch(c1.t, c2.t);
    Connections.branch(c3.t, c4.t);
	Connections.root(c1.t);
	Connections.root(c2.t);
	Connections.root(c3.t);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OverconstrainedMultipleRoot1",
            description="Double root in connector set",
            errorMessage="
1 errors found:

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Multiple definite roots in unbreakable subgraph in overconstrained connection graph
    Selected root: c1.t
    Other root: c2.t
")})));
end OverconstrainedMultipleRoot1;


model OverconstrainedMultipleRoot2
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

	C1 c1,c2,c3,c4,c5,c6;
equation
    Connections.branch(c1.t, c2.t);
    Connections.branch(c2.t, c3.t);
    Connections.branch(c3.t, c4.t);
    Connections.branch(c4.t, c5.t);
    Connections.branch(c5.t, c6.t);
    Connections.root(c1.t);
    Connections.root(c3.t);
    Connections.root(c6.t);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OverconstrainedMultipleRoot2",
            description="Triple root in connector set",
            errorMessage="
1 errors found:

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Multiple definite roots in unbreakable subgraph in overconstrained connection graph
    Selected root: c1.t
    Other root: c3.t
    Other root: c6.t
")})));
end OverconstrainedMultipleRoot2;


model OverconstrainedUnbreakableLoop1
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

	C1 c1,c2;
equation
	Connections.root(c1.t);
	Connections.branch(c1.t,c2.t);
	Connections.branch(c2.t,c1.t);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OverconstrainedUnbreakableLoop1",
            description="Unbreakable loop in connector set",
            errorMessage="
1 errors found:

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Unbreakable loop in overconstrained connection graph
    Selected root: c1.t
")})));
end OverconstrainedUnbreakableLoop1;


model OverconstrainedUnbreakableLoop2
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

	C1 c1,c2,c3,c4,c5,c6;
equation
    Connections.branch(c1.t, c2.t);
    Connections.branch(c2.t, c3.t);
    Connections.branch(c3.t, c4.t);
    Connections.branch(c4.t, c5.t);
    Connections.branch(c5.t, c6.t);
    Connections.branch(c6.t, c1.t);
    Connections.root(c4.t);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OverconstrainedUnbreakableLoop2",
            description="Unbreakable loop in connector set",
            errorMessage="
1 errors found:

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Unbreakable loop in overconstrained connection graph
    Selected root: c4.t
")})));
end OverconstrainedUnbreakableLoop2;


model OverconstrainedMultiRootDef1
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

	C1 c1,c2;
equation
    Connections.branch(c1.t, c2.t);
    Connections.potentialRoot(c1.t);
    Connections.root(c1.t);
    Connections.potentialRoot(c2.t);
    Connections.potentialRoot(c2.t,3);
    Connections.potentialRoot(c2.t,1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="OverconstrainedMultiRootDef1",
            description="Multiple definitions of root priority",
            errorMessage="
2 errors found:

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Multiple root definitions for single connector in overconstrained connection graph
    Connector: c1.t

Error at line 17, column 9, in file 'Compiler/ModelicaFrontEnd/test/modelica/OverconstrainedConnection.mo':
  Multiple root definitions for single connector in overconstrained connection graph
    Connector: c2.t
")})));
end OverconstrainedMultiRootDef1;


model OverconstrainedArray1
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    model A
        C1 c1;
        C1 c2;
    equation
        connect(c1, c2);
    end A;
    
    model B
        C1 c[2];
    equation
        Connections.potentialRoot(c[1].t);
        Connections.potentialRoot(c[2].t);
    end B;
    
    A a[2];
    B b;
equation
    connect(a.c1, b.c);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="OverconstrainedArray1",
            description="Test that the overconstrained connection graph is built correctly when using slice access in connect",
            flatModel="
fclass OverconstrainedConnection.OverconstrainedArray1
 OverconstrainedConnection.OverconstrainedArray1.T1 a[1].c1.t[2];
 OverconstrainedConnection.OverconstrainedArray1.T1 a[1].c2.t[2];
 OverconstrainedConnection.OverconstrainedArray1.T1 a[2].c1.t[2];
 OverconstrainedConnection.OverconstrainedArray1.T1 a[2].c2.t[2];
 OverconstrainedConnection.OverconstrainedArray1.T1 b.c[1].t[2];
 OverconstrainedConnection.OverconstrainedArray1.T1 b.c[2].t[2];
equation
 a[1].c1.t[1:2] = b.c[1].t[1:2];
 a[1].c1.t[1:2] = a[1].c2.t[1:2];
 a[2].c1.t[1:2] = b.c[2].t[1:2];
 a[2].c1.t[1:2] = a[2].c2.t[1:2];

public
 type OverconstrainedConnection.OverconstrainedArray1.T1 = Real;
end OverconstrainedConnection.OverconstrainedArray1;
")})));
end OverconstrainedArray1;


model PureConnectLoop1
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
equation
    c1.t = {time, -time};
    connect(c1, c2);
    connect(c1, c2);
    Connections.potentialRoot(c1.t);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="PureConnectLoop1",
        description="Two overconstrained connectors double connected to each other",
        flatModel="
fclass OverconstrainedConnection.PureConnectLoop1
 potential OverconstrainedConnection.PureConnectLoop1.T1 c1.t[2];
 potential OverconstrainedConnection.PureConnectLoop1.T1 c2.t[2];
equation
 c1.t[1:2] = {time, - time};
 c1.t[1:2] = c2.t[1:2];

public
 type OverconstrainedConnection.PureConnectLoop1.T1 = Real;
end OverconstrainedConnection.PureConnectLoop1;
")})));
end PureConnectLoop1;


model PureConnectLoop2
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    C1 c3;
equation
    c1.t = {time, -time};
    connect(c1, c2);
    connect(c2, c3);
    connect(c3, c1);
    Connections.potentialRoot(c1.t);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="PureConnectLoop2",
        description="Three overconstrained connectors connected in a loop",
        flatModel="
fclass OverconstrainedConnection.PureConnectLoop2
 potential OverconstrainedConnection.PureConnectLoop2.T1 c1.t[2];
 potential OverconstrainedConnection.PureConnectLoop2.T1 c2.t[2];
 potential OverconstrainedConnection.PureConnectLoop2.T1 c3.t[2];
equation
 c1.t[1:2] = {time, - time};
 c1.t[1:2] = c2.t[1:2];
 c2.t[1:2] = c3.t[1:2];

public
 type OverconstrainedConnection.PureConnectLoop2.T1 = Real;
end OverconstrainedConnection.PureConnectLoop2;
")})));
end PureConnectLoop2;


model PureConnectLoop3
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
equation
    c1.t = {time, -time};
    connect(c1, c2);
    connect(c1, c2);
    Connections.branch(c2.t, c3.t);
    c2.t = c3.t;
    connect(c3, c4);
    Connections.branch(c4.t, c1.t);
    c4.t = c1.t;
    Connections.potentialRoot(c1.t);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="PureConnectLoop3",
        description="Two overconstrained connectors double connected to each other, as part of a normal overconstrained loop",
        flatModel="
fclass OverconstrainedConnection.PureConnectLoop3
 potential OverconstrainedConnection.PureConnectLoop3.T1 c1.t[2];
 potential OverconstrainedConnection.PureConnectLoop3.T1 c2.t[2];
 potential OverconstrainedConnection.PureConnectLoop3.T1 c3.t[2];
 potential OverconstrainedConnection.PureConnectLoop3.T1 c4.t[2];
equation
 c1.t[1:2] = {time, - time};
 c2.t[1:2] = c3.t[1:2];
 c4.t[1:2] = c1.t[1:2];
 c1.t[1:2] = c2.t[1:2];
 zeros(1) = OverconstrainedConnection.PureConnectLoop3.T1.equalityConstraint(c3.t[1:2], c4.t[1:2]);

public
 function OverconstrainedConnection.PureConnectLoop3.T1.equalityConstraint
  input Real[:] i1;
  input Real[:] i2;
  output Real[:] o;
 algorithm
  assert(2 == size(i1, 1), \"Mismatching sizes in function 'OverconstrainedConnection.PureConnectLoop3.T1.equalityConstraint', component 'i1', dimension '1'\");
  assert(2 == size(i2, 1), \"Mismatching sizes in function 'OverconstrainedConnection.PureConnectLoop3.T1.equalityConstraint', component 'i2', dimension '1'\");
  init o as Real[1];
  o[1:1] := sum(i1[1:2] .+ i2[1:2]);
  return;
 end OverconstrainedConnection.PureConnectLoop3.T1.equalityConstraint;

 type OverconstrainedConnection.PureConnectLoop3.T1 = Real;
end OverconstrainedConnection.PureConnectLoop3;
")})));
end PureConnectLoop3;


model PureConnectLoop4
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
    C1 c5;
equation
    c1.t = {time, -time};
    connect(c1, c2);
    connect(c2, c3);
    connect(c3, c1);
    Connections.branch(c2.t, c4.t);
    c2.t = c4.t;
    connect(c4, c5);
    Connections.branch(c5.t, c1.t);
    c5.t = c1.t;
    Connections.potentialRoot(c1.t);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="PureConnectLoop4",
        description="Three overconstrained connectors connected in a loop, as part of a normal overconstrained loop",
        flatModel="
fclass OverconstrainedConnection.PureConnectLoop4
 potential OverconstrainedConnection.PureConnectLoop4.T1 c1.t[2];
 potential OverconstrainedConnection.PureConnectLoop4.T1 c2.t[2];
 potential OverconstrainedConnection.PureConnectLoop4.T1 c3.t[2];
 potential OverconstrainedConnection.PureConnectLoop4.T1 c4.t[2];
 potential OverconstrainedConnection.PureConnectLoop4.T1 c5.t[2];
equation
 c1.t[1:2] = {time, - time};
 c2.t[1:2] = c4.t[1:2];
 c5.t[1:2] = c1.t[1:2];
 c1.t[1:2] = c2.t[1:2];
 c2.t[1:2] = c3.t[1:2];
 zeros(1) = OverconstrainedConnection.PureConnectLoop4.T1.equalityConstraint(c4.t[1:2], c5.t[1:2]);

public
 function OverconstrainedConnection.PureConnectLoop4.T1.equalityConstraint
  input Real[:] i1;
  input Real[:] i2;
  output Real[:] o;
 algorithm
  assert(2 == size(i1, 1), \"Mismatching sizes in function 'OverconstrainedConnection.PureConnectLoop4.T1.equalityConstraint', component 'i1', dimension '1'\");
  assert(2 == size(i2, 1), \"Mismatching sizes in function 'OverconstrainedConnection.PureConnectLoop4.T1.equalityConstraint', component 'i2', dimension '1'\");
  init o as Real[1];
  o[1:1] := sum(i1[1:2] .+ i2[1:2]);
  return;
 end OverconstrainedConnection.PureConnectLoop4.T1.equalityConstraint;

 type OverconstrainedConnection.PureConnectLoop4.T1 = Real;
end OverconstrainedConnection.PureConnectLoop4;
")})));
end PureConnectLoop4;


model PureConnectLoop5
    type TBase = Real[2];
    
    type T1
        extends TBase;
        
        function equalityConstraint
            input T1 i1;
            input T1 i2;
            output Real[1] o;
        algorithm
            o := sum(i1 .+ i2);
        end equalityConstraint;
    end T1;
    
    connector C1
        T1 t;
    end C1;

    C1 c1;
    C1 c2;
    C1 c3;
    C1 c4;
    C1 c5;
equation
    c1.t = {time, -time};
    connect(c1, c1);
    connect(c1, c2);
    connect(c1, c3);
    connect(c1, c4);
    connect(c1, c5);
    connect(c2, c1);
    connect(c2, c3);
    connect(c2, c4);
    connect(c2, c5);
    connect(c3, c4);
    connect(c3, c5);
    connect(c4, c5);
    Connections.potentialRoot(c1.t);

annotation(__JModelica(UnitTesting(tests={
    FlatteningTestCase(
        name="PureConnectLoop5",
        description="Five overconstrained connectors with multiple redundant connects between them",
        flatModel="
fclass OverconstrainedConnection.PureConnectLoop5
 potential OverconstrainedConnection.PureConnectLoop5.T1 c1.t[2];
 potential OverconstrainedConnection.PureConnectLoop5.T1 c2.t[2];
 potential OverconstrainedConnection.PureConnectLoop5.T1 c3.t[2];
 potential OverconstrainedConnection.PureConnectLoop5.T1 c4.t[2];
 potential OverconstrainedConnection.PureConnectLoop5.T1 c5.t[2];
equation
 c1.t[1:2] = {time, - time};
 c1.t[1:2] = c2.t[1:2];
 c2.t[1:2] = c3.t[1:2];
 c3.t[1:2] = c4.t[1:2];
 c4.t[1:2] = c5.t[1:2];

public
 type OverconstrainedConnection.PureConnectLoop5.T1 = Real;
end OverconstrainedConnection.PureConnectLoop5;
")})));
end PureConnectLoop5;

end OverconstrainedConnection;
