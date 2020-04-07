/*
    Copyright (C) 2011-2013 Modelon AB

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

package StreamTests
  connector FluidPort
     flow Real m_flow;
     stream Real h_outflow;
     Real p;
  end FluidPort;

model Reservoir
    parameter Real p0 = 1;
    parameter Real h0 = 1;
    FluidPort fluidPort;
equation 
  fluidPort.p=p0;
  fluidPort.h_outflow=h0;
end Reservoir;

model LinearResistance

  FluidPort port_a;
  FluidPort port_b;
equation 
  port_a.m_flow=(port_a.p-port_b.p);
  port_a.m_flow+port_b.m_flow=0;
  port_a.h_outflow=inStream(port_b.h_outflow);
  port_b.h_outflow=inStream(port_a.h_outflow);
end LinearResistance;

  model StreamTest1

     Reservoir r;
     Real h = inStream(r.fluidPort.h_outflow);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamTest1",
            description="Test of inside and outside stream connectors.",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamTest1
 parameter Real r.p0 = 1 /* 1 */;
 parameter Real r.h0 = 1 /* 1 */;
 constant Real r.fluidPort.m_flow = 0.0;
 parameter Real r.fluidPort.p;
 parameter Real r.fluidPort.h_outflow;
 parameter Real h;
parameter equation
 r.fluidPort.p = r.p0;
 r.fluidPort.h_outflow = r.h0;
 h = r.fluidPort.h_outflow;
end StreamTests.StreamTest1;
")})));
  end StreamTest1;

model StreamTest2
   Reservoir r;
   Real h = actualStream(r.fluidPort.h_outflow);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamTest2",
            description="Test of inside and outside stream connectors.",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamTest2
 parameter Real r.p0 = 1 /* 1 */;
 parameter Real r.h0 = 1 /* 1 */;
 constant Real r.fluidPort.m_flow = 0.0;
 parameter Real r.fluidPort.p;
 parameter Real r.fluidPort.h_outflow;
 parameter Real h;
parameter equation
 r.fluidPort.p = r.p0;
 r.fluidPort.h_outflow = r.h0;
 h = r.fluidPort.h_outflow;
end StreamTests.StreamTest2;
")})));
end StreamTest2;

  model StreamTest3
     Reservoir r1;
     Reservoir r2;
     LinearResistance res;
  equation 
     connect(r1.fluidPort,res.port_a);
     connect(r2.fluidPort,res.port_b);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamTest3",
            description="Test of inside and outside stream connectors.",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamTest3
 parameter Real r1.p0 = 1 /* 1 */;
 parameter Real r1.h0 = 1 /* 1 */;
 parameter Real r1.fluidPort.p;
 parameter Real r1.fluidPort.h_outflow;
 parameter Real r2.fluidPort.p;
 parameter Real r2.p0 = 1 /* 1 */;
 parameter Real r2.h0 = 1 /* 1 */;
 parameter Real r2.fluidPort.h_outflow;
 parameter Real res.port_a.p;
 parameter Real res.port_b.h_outflow;
 parameter Real res.port_b.p;
 parameter Real res.port_a.h_outflow;
 parameter Real res.port_a.m_flow;
 parameter Real res.port_b.m_flow;
 parameter Real r1.fluidPort.m_flow;
 parameter Real r2.fluidPort.m_flow;
parameter equation
 r1.fluidPort.p = r1.p0;
 r1.fluidPort.h_outflow = r1.h0;
 r2.fluidPort.p = r2.p0;
 r2.fluidPort.h_outflow = r2.h0;
 res.port_a.p = r1.fluidPort.p;
 res.port_b.h_outflow = r1.fluidPort.h_outflow;
 res.port_b.p = r2.fluidPort.p;
 res.port_a.h_outflow = r2.fluidPort.h_outflow;
 res.port_a.m_flow = res.port_a.p + (- res.port_b.p);
 res.port_b.m_flow = - res.port_a.m_flow;
 r1.fluidPort.m_flow = - res.port_a.m_flow;
 r2.fluidPort.m_flow = - res.port_b.m_flow;
end StreamTests.StreamTest3;
")})));
  end StreamTest3;
  
  model StreamTest4
     Reservoir r[2];
     Real h[2] = inStream(r.fluidPort.h_outflow);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamTest4",
            description="Using inStream() on array.",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamTest4
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 constant Real r[1].fluidPort.m_flow = 0.0;
 parameter Real r[1].fluidPort.p;
 parameter Real r[1].fluidPort.h_outflow;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 constant Real r[2].fluidPort.m_flow = 0.0;
 parameter Real r[2].fluidPort.p;
 parameter Real r[2].fluidPort.h_outflow;
 parameter Real h[1];
 parameter Real h[2];
parameter equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 h[1] = r[1].fluidPort.h_outflow;
 h[2] = r[2].fluidPort.h_outflow;
end StreamTests.StreamTest4;
")})));
  end StreamTest4;


model StreamTest5
    Reservoir r[2];
    Real h[2] = actualStream(r.fluidPort.h_outflow);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamTest5",
            description="Using actualStream() on stream variables from array of connectors.",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamTest5
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 constant Real r[1].fluidPort.m_flow = 0.0;
 parameter Real r[1].fluidPort.p;
 parameter Real r[1].fluidPort.h_outflow;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 constant Real r[2].fluidPort.m_flow = 0.0;
 parameter Real r[2].fluidPort.p;
 parameter Real r[2].fluidPort.h_outflow;
 parameter Real h[1];
 parameter Real h[2];
parameter equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 h[1] = r[1].fluidPort.h_outflow;
 h[2] = r[2].fluidPort.h_outflow;
end StreamTests.StreamTest5;
")})));
end StreamTest5;
  
model StreamTest6
    connector A
        flow Real a;
        stream Real[2] b;
        Real c;
    end A;

    A d;
    Real f[2];
equation
    f = actualStream(d.b);
    f = {1,2};
    d.c = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamTest6",
            description="Using actualStream() on array of stream variables.",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamTest6
 flow Real d.a;
 stream Real d.b[1];
 stream Real d.b[2];
 potential Real d.c;
 constant Real f[1] = 1;
 constant Real f[2] = 2;
equation
 1.0 = d.b[1];
 2.0 = d.b[2];
 d.c = 0;
end StreamTests.StreamTest6;
")})));
end StreamTest6;


model StreamTest7
    connector A
       flow Real a;
       stream Real b;
       Real c;
    end A;
    
    model D
        A e;
    end D;
    D f;
    A g;
    Real h;
equation
    connect(g, f.e);
    h = actualStream(g.b);
    g.b = time;
    g.c = 2 / g.b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamTest7",
            description="",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamTest7
 Real f.e.a;
 Real f.e.b;
 Real f.e.c;
 flow Real g.a;
 stream Real g.b;
 potential Real g.c;
 Real h;
equation
 h = g.b;
 g.b = time;
 g.c = 2 / g.b;
 f.e.a - g.a = 0.0;
 g.b = f.e.b;
 f.e.c = g.c;
end StreamTests.StreamTest7;
")})));
end StreamTest7;


model StreamMinMax1
    Reservoir r[3](fluidPort(m_flow(min={-1,0,1})));
    LinearResistance l[3];
    Real h[3] = actualStream(r.fluidPort.h_outflow);
    Real g[3] = r.fluidPort.m_flow .* actualStream(r.fluidPort.h_outflow);
equation
    connect(r.fluidPort,l.port_a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax1",
            description="Expansion of actualStream() with max on flow variable",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax1
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 Real r[1].fluidPort.m_flow(min = -1);
 Real r[1].fluidPort.h_outflow;
 Real r[1].fluidPort.p;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 Real r[2].fluidPort.m_flow(min = 0);
 Real r[2].fluidPort.h_outflow;
 Real r[2].fluidPort.p;
 parameter Real r[3].p0 = 1 /* 1 */;
 parameter Real r[3].h0 = 1 /* 1 */;
 Real r[3].fluidPort.m_flow(min = 1);
 Real r[3].fluidPort.h_outflow;
 Real r[3].fluidPort.p;
 Real l[1].port_a.m_flow;
 Real l[1].port_a.h_outflow;
 Real l[1].port_a.p;
 Real l[1].port_b.m_flow;
 Real l[1].port_b.h_outflow;
 Real l[1].port_b.p;
 Real l[2].port_a.m_flow;
 Real l[2].port_a.h_outflow;
 Real l[2].port_a.p;
 Real l[2].port_b.m_flow;
 Real l[2].port_b.h_outflow;
 Real l[2].port_b.p;
 Real l[3].port_a.m_flow;
 Real l[3].port_a.h_outflow;
 Real l[3].port_a.p;
 Real l[3].port_b.m_flow;
 Real l[3].port_b.h_outflow;
 Real l[3].port_b.p;
 Real h[1];
 Real h[2];
 Real h[3];
 Real g[1];
 Real g[2];
 Real g[3];
equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 r[3].fluidPort.p = r[3].p0;
 r[3].fluidPort.h_outflow = r[3].h0;
 l[1].port_a.m_flow = l[1].port_a.p - l[1].port_b.p;
 l[1].port_a.m_flow + l[1].port_b.m_flow = 0;
 l[1].port_a.h_outflow = l[1].port_b.h_outflow;
 l[1].port_b.h_outflow = r[1].fluidPort.h_outflow;
 l[2].port_a.m_flow = l[2].port_a.p - l[2].port_b.p;
 l[2].port_a.m_flow + l[2].port_b.m_flow = 0;
 l[2].port_a.h_outflow = l[2].port_b.h_outflow;
 l[2].port_b.h_outflow = r[2].fluidPort.h_outflow;
 l[3].port_a.m_flow = l[3].port_a.p - l[3].port_b.p;
 l[3].port_a.m_flow + l[3].port_b.m_flow = 0;
 l[3].port_a.h_outflow = l[3].port_b.h_outflow;
 l[3].port_b.h_outflow = r[3].fluidPort.h_outflow;
 l[1].port_a.m_flow + r[1].fluidPort.m_flow = 0.0;
 l[1].port_a.p = r[1].fluidPort.p;
 l[2].port_a.m_flow + r[2].fluidPort.m_flow = 0.0;
 l[2].port_a.p = r[2].fluidPort.p;
 l[3].port_a.m_flow + r[3].fluidPort.m_flow = 0.0;
 l[3].port_a.p = r[3].fluidPort.p;
 l[1].port_b.m_flow = 0.0;
 l[2].port_b.m_flow = 0.0;
 l[3].port_b.m_flow = 0.0;
 h[1] = if r[1].fluidPort.m_flow > 0.0 then l[1].port_a.h_outflow else r[1].fluidPort.h_outflow;
 h[2] = if r[2].fluidPort.m_flow > 0.0 then l[2].port_a.h_outflow else r[2].fluidPort.h_outflow;
 h[3] = l[3].port_a.h_outflow;
 g[1] = r[1].fluidPort.m_flow .* smooth(0, if r[1].fluidPort.m_flow > 0.0 then l[1].port_a.h_outflow else r[1].fluidPort.h_outflow);
 g[2] = r[2].fluidPort.m_flow .* l[2].port_a.h_outflow;
 g[3] = r[3].fluidPort.m_flow .* l[3].port_a.h_outflow;
end StreamTests.StreamMinMax1;
")})));
end StreamMinMax1;


model StreamMinMax2
    Reservoir r[3](fluidPort(m_flow(max={-1,0,1})));
    LinearResistance l[3];
    Real h[3] = actualStream(r.fluidPort.h_outflow);
    Real g[3] = r.fluidPort.m_flow .* actualStream(r.fluidPort.h_outflow);
equation
    connect(r.fluidPort,l.port_a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax2",
            description="Expansion of actualStream() with max on flow variable",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax2
 parameter Real r[1].p0 = 1 /* 1 */;
 parameter Real r[1].h0 = 1 /* 1 */;
 Real r[1].fluidPort.m_flow(max = -1);
 Real r[1].fluidPort.h_outflow;
 Real r[1].fluidPort.p;
 parameter Real r[2].p0 = 1 /* 1 */;
 parameter Real r[2].h0 = 1 /* 1 */;
 Real r[2].fluidPort.m_flow(max = 0);
 Real r[2].fluidPort.h_outflow;
 Real r[2].fluidPort.p;
 parameter Real r[3].p0 = 1 /* 1 */;
 parameter Real r[3].h0 = 1 /* 1 */;
 Real r[3].fluidPort.m_flow(max = 1);
 Real r[3].fluidPort.h_outflow;
 Real r[3].fluidPort.p;
 Real l[1].port_a.m_flow;
 Real l[1].port_a.h_outflow;
 Real l[1].port_a.p;
 Real l[1].port_b.m_flow;
 Real l[1].port_b.h_outflow;
 Real l[1].port_b.p;
 Real l[2].port_a.m_flow;
 Real l[2].port_a.h_outflow;
 Real l[2].port_a.p;
 Real l[2].port_b.m_flow;
 Real l[2].port_b.h_outflow;
 Real l[2].port_b.p;
 Real l[3].port_a.m_flow;
 Real l[3].port_a.h_outflow;
 Real l[3].port_a.p;
 Real l[3].port_b.m_flow;
 Real l[3].port_b.h_outflow;
 Real l[3].port_b.p;
 Real h[1];
 Real h[2];
 Real h[3];
 Real g[1];
 Real g[2];
 Real g[3];
equation
 r[1].fluidPort.p = r[1].p0;
 r[1].fluidPort.h_outflow = r[1].h0;
 r[2].fluidPort.p = r[2].p0;
 r[2].fluidPort.h_outflow = r[2].h0;
 r[3].fluidPort.p = r[3].p0;
 r[3].fluidPort.h_outflow = r[3].h0;
 l[1].port_a.m_flow = l[1].port_a.p - l[1].port_b.p;
 l[1].port_a.m_flow + l[1].port_b.m_flow = 0;
 l[1].port_a.h_outflow = l[1].port_b.h_outflow;
 l[1].port_b.h_outflow = r[1].fluidPort.h_outflow;
 l[2].port_a.m_flow = l[2].port_a.p - l[2].port_b.p;
 l[2].port_a.m_flow + l[2].port_b.m_flow = 0;
 l[2].port_a.h_outflow = l[2].port_b.h_outflow;
 l[2].port_b.h_outflow = r[2].fluidPort.h_outflow;
 l[3].port_a.m_flow = l[3].port_a.p - l[3].port_b.p;
 l[3].port_a.m_flow + l[3].port_b.m_flow = 0;
 l[3].port_a.h_outflow = l[3].port_b.h_outflow;
 l[3].port_b.h_outflow = r[3].fluidPort.h_outflow;
 l[1].port_a.m_flow + r[1].fluidPort.m_flow = 0.0;
 l[1].port_a.p = r[1].fluidPort.p;
 l[2].port_a.m_flow + r[2].fluidPort.m_flow = 0.0;
 l[2].port_a.p = r[2].fluidPort.p;
 l[3].port_a.m_flow + r[3].fluidPort.m_flow = 0.0;
 l[3].port_a.p = r[3].fluidPort.p;
 l[1].port_b.m_flow = 0.0;
 l[2].port_b.m_flow = 0.0;
 l[3].port_b.m_flow = 0.0;
 h[1] = r[1].fluidPort.h_outflow;
 h[2] = r[2].fluidPort.h_outflow;
 h[3] = if r[3].fluidPort.m_flow > 0.0 then l[3].port_a.h_outflow else r[3].fluidPort.h_outflow;
 g[1] = r[1].fluidPort.m_flow .* r[1].fluidPort.h_outflow;
 g[2] = r[2].fluidPort.m_flow .* r[2].fluidPort.h_outflow;
 g[3] = r[3].fluidPort.m_flow .* smooth(0, if r[3].fluidPort.m_flow > 0.0 then l[3].port_a.h_outflow else r[3].fluidPort.h_outflow);
end StreamTests.StreamMinMax2;
")})));
end StreamMinMax2;



connector StreamConnector
    Real p;
    flow Real f;
    stream Real s;
end StreamConnector;


model StreamN1M0
    model A
        StreamConnector c;
    end A;
    
    A a(c(s=1, p=2));
	Real x = inStream(a.c.s);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN1M0",
            description="Test stream connectors connected N=1, M=0",
            eliminate_alias_variables=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN1M0
 Real a.c.p;
 Real a.c.f;
 Real a.c.s;
 Real x;
equation
 a.c.f = 0.0;
 a.c.p = 2;
 a.c.s = 1;
 x = a.c.s;
end StreamTests.StreamN1M0;
")})));
end StreamN1M0;


model StreamN2M0
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=2));
    A a2(c(s=3, f=time - 1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
	connect(a1.c, a2.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN2M0",
            description="Test stream connectors connected N=2, M=0",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN2M0
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s;
 Real x1;
 Real x2;
equation
 a1.c.f + a2.c.f = 0.0;
 a1.c.p = a2.c.p;
 a1.c.p = 2;
 a1.c.s = 1;
 a2.c.f = time - 1;
 a2.c.s = 3;
 x1 = a2.c.s;
 x2 = a1.c.s;
end StreamTests.StreamN2M0;
")})));
end StreamN2M0;


model StreamN1M1
    model A
        StreamConnector c;
    end A;
    
    A a(c(s=1, p=2));
    StreamConnector c;
    Real x1 = inStream(a.c.s);
    Real x2 = inStream(c.s);
equation
    connect(a.c, c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN1M1",
            description="Test stream connectors connected N=1, M=1",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN1M1
 Real a.c.p;
 Real a.c.f;
 Real a.c.s;
 potential Real c.p;
 flow Real c.f;
 stream Real c.s;
 Real x1;
 Real x2;
equation
 a.c.f - c.f = 0.0;
 a.c.p = c.p;
 c.s = a.c.s;
 a.c.p = 2;
 a.c.s = 1;
 x1 = c.s;
 x2 = c.s;
end StreamTests.StreamN1M1;
")})));
end StreamN1M1;


model StreamN0M2
    model A
        StreamConnector c1;
        StreamConnector c2;
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
    equation
        connect(c1, c2);
    end A;
    
    model B
        StreamConnector c3(p = 5, f = 6, s = 3);
        StreamConnector c4(s = 4);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c3);
    connect(a.c2, b.c4);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN0M2",
            description="Test stream connectors connected N=0, M=2",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN0M2
 Real a.c1.p;
 Real a.c1.f;
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f;
 Real a.c2.s;
 Real a.x1;
 Real a.x2;
 Real b.c3.p;
 Real b.c3.f;
 Real b.c3.s;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
equation
 a.c1.f + b.c3.f = 0.0;
 a.c1.p = b.c3.p;
 a.c2.f + b.c4.f = 0.0;
 a.c2.p = b.c4.p;
 - a.c1.f - a.c2.f = 0.0;
 a.c1.p = a.c2.p;
 a.c1.s = b.c4.s;
 a.c2.s = b.c3.s;
 a.x1 = b.c3.s;
 a.x2 = b.c4.s;
 b.c3.p = 5;
 b.c3.f = 6;
 b.c3.s = 3;
 b.c4.s = 4;
end StreamTests.StreamN0M2;
")})));
end StreamN0M2;


model StreamN3M0
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f=time));
    A a2(c(s=2, f=time-1));
    A a3(c(s=3));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
    Real x3 = inStream(a3.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, a3.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN3M0",
            description="Test stream connectors connected N=3, M=0",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN3M0
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s;
 Real a3.c.p;
 Real a3.c.f;
 Real a3.c.s;
 Real x1;
 Real x2;
 Real x3;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
equation
 a1.c.f + a2.c.f + a3.c.f = 0.0;
 a1.c.p = a2.c.p;
 a2.c.p = a3.c.p;
 a1.c.p = 4;
 a1.c.f = time;
 a1.c.s = 1;
 a2.c.f = time - 1;
 a2.c.s = 2;
 a3.c.s = 3;
 x1 = (_stream_positiveMax_1 * a2.c.s + _stream_positiveMax_2 * a3.c.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 x2 = (_stream_positiveMax_3 * a1.c.s + _stream_positiveMax_4 * a3.c.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 x3 = (_stream_positiveMax_5 * a1.c.s + _stream_positiveMax_6 * a2.c.s) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 _stream_s_1 = max(- a2.c.f, 0) + max(- a3.c.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- a3.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a1.c.f, 0) + max(- a3.c.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- a1.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(- a3.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(- a1.c.f, 0) + max(- a2.c.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(- a1.c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(- a2.c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
end StreamTests.StreamN3M0;
")})));
end StreamN3M0;


model StreamN2M1
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f=time));
    A a2(c(s=2));
    StreamConnector c;
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
    Real x3 = inStream(c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN2M1",
            description="Test stream connectors connected N=2, M=1",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN2M1
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s;
 potential Real c.p;
 flow Real c.f;
 stream Real c.s;
 Real x1;
 Real x2;
 Real x3;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
equation
 a1.c.f + a2.c.f - c.f = 0.0;
 a1.c.p = a2.c.p;
 a2.c.p = c.p;
 c.s = (_stream_positiveMax_1 * a1.c.s + _stream_positiveMax_2 * a2.c.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 a1.c.p = 4;
 a1.c.f = time;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = (_stream_positiveMax_3 * a2.c.s + _stream_positiveMax_4 * c.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 x2 = (_stream_positiveMax_5 * a1.c.s + _stream_positiveMax_6 * c.s) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 x3 = c.s;
 _stream_s_1 = max(- a1.c.f, 0) + max(- a2.c.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a1.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a2.c.f, 0) + max(c.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- a2.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(- a1.c.f, 0) + max(c.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(- a1.c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
end StreamTests.StreamN2M1;
")})));
end StreamN2M1;


model StreamN1M2
    model A
        StreamConnector c;
    end A;
    
    A a(c(s=1, p=2));
    StreamConnector c1;
    StreamConnector c2;
    Real x1 = inStream(a.c.s);
    Real x2 = inStream(c1.s);
    Real x3 = inStream(c2.s);
equation
    connect(a.c, c1);
    connect(a.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN1M2",
            description="Test stream connectors connected N=1, M=2",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN1M2
 Real a.c.p;
 Real a.c.f;
 Real a.c.s;
 potential Real c1.p;
 flow Real c1.f;
 stream Real c1.s;
 potential Real c2.p;
 flow Real c2.f;
 stream Real c2.s;
 Real x1;
 Real x2;
 Real x3;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
equation
 a.c.f - c1.f - c2.f = 0.0;
 a.c.p = c1.p;
 c1.p = c2.p;
 c1.s = (_stream_positiveMax_1 * a.c.s + _stream_positiveMax_2 * c2.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 c2.s = (_stream_positiveMax_3 * a.c.s + _stream_positiveMax_4 * c1.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 a.c.p = 2;
 a.c.s = 1;
 x1 = (_stream_positiveMax_5 * c1.s + _stream_positiveMax_6 * c2.s) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 x2 = c1.s;
 x3 = c2.s;
 _stream_s_1 = max(- a.c.f, 0) + max(c2.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(c2.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a.c.f, 0) + max(c1.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- a.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(c1.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(c1.f, 0) + max(c2.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(c1.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(c2.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
end StreamTests.StreamN1M2;
")})));
end StreamN1M2;


model StreamN0M3
    model A
        StreamConnector c1;
        StreamConnector c2;
        StreamConnector c3;
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN0M3",
            description="Test stream connectors connected N=0, M=3",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN0M3
 Real a.c1.p;
 Real a.c1.f;
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f;
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f;
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
equation
 a.c1.f + b.c4.f = 0.0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0.0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0.0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0.0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = (_stream_positiveMax_1 * b.c5.s + _stream_positiveMax_2 * b.c6.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 a.c2.s = (_stream_positiveMax_3 * b.c4.s + _stream_positiveMax_4 * b.c6.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 a.c3.s = (_stream_positiveMax_5 * b.c4.s + _stream_positiveMax_6 * b.c5.s) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
 _stream_s_1 = max(a.c2.f, 0) + max(a.c3.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(a.c2.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(a.c3.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(a.c1.f, 0) + max(a.c3.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(a.c1.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(a.c3.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(a.c1.f, 0) + max(a.c2.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(a.c1.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(a.c2.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
end StreamTests.StreamN0M3;
")})));
end StreamN0M3;


model StreamN2M2
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f=time));
    A a2(c(s=2));
    StreamConnector c1;
    StreamConnector c2;
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
    Real x3 = inStream(c1.s);
    Real x4 = inStream(c2.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamN2M2",
            description="Test stream connectors connected N=2, M=2",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamN2M2
 Real a1.c.p;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f;
 Real a2.c.s;
 potential Real c1.p;
 flow Real c1.f;
 stream Real c1.s;
 potential Real c2.p;
 flow Real c2.f;
 stream Real c2.s;
 Real x1;
 Real x2;
 Real x3;
 Real x4;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_positiveMax_3;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_4;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_7;
 Real _stream_positiveMax_8;
 Real _stream_positiveMax_9;
 Real _stream_s_4;
 Real _stream_alpha_4;
 Real _stream_positiveMax_10;
 Real _stream_positiveMax_11;
 Real _stream_positiveMax_12;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0.0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = (_stream_positiveMax_1 * a1.c.s + _stream_positiveMax_2 * a2.c.s + _stream_positiveMax_3 * c2.s) / (_stream_positiveMax_1 + _stream_positiveMax_2 + _stream_positiveMax_3);
 c2.s = (_stream_positiveMax_4 * a1.c.s + _stream_positiveMax_5 * a2.c.s + _stream_positiveMax_6 * c1.s) / (_stream_positiveMax_4 + _stream_positiveMax_5 + _stream_positiveMax_6);
 a1.c.p = 4;
 a1.c.f = time;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = (_stream_positiveMax_7 * a2.c.s + _stream_positiveMax_8 * c1.s + _stream_positiveMax_9 * c2.s) / (_stream_positiveMax_7 + _stream_positiveMax_8 + _stream_positiveMax_9);
 x2 = (_stream_positiveMax_10 * a1.c.s + _stream_positiveMax_11 * c1.s + _stream_positiveMax_12 * c2.s) / (_stream_positiveMax_10 + _stream_positiveMax_11 + _stream_positiveMax_12);
 x3 = c1.s;
 x4 = c2.s;
 _stream_s_1 = max(- a1.c.f, 0) + max(- a2.c.f, 0) + max(c2.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a1.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_3 = _stream_alpha_1 * max(c2.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a1.c.f, 0) + max(- a2.c.f, 0) + max(c1.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_4 = _stream_alpha_2 * max(- a1.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_5 = _stream_alpha_2 * max(- a2.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_2 * max(c1.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(- a2.c.f, 0) + max(c1.f, 0) + max(c2.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_7 = _stream_alpha_3 * max(- a2.c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_8 = _stream_alpha_3 * max(c1.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_9 = _stream_alpha_3 * max(c2.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_s_4 = max(- a1.c.f, 0) + max(c1.f, 0) + max(c2.f, 0);
 _stream_alpha_4 = smooth(1, if _stream_s_4 > _inStreamEpsilon then 1 elseif _stream_s_4 > 0 then _stream_s_4 / _inStreamEpsilon * (_stream_s_4 / _inStreamEpsilon * (3 - 2 * _stream_s_4)) else 0);
 _stream_positiveMax_10 = _stream_alpha_4 * max(- a1.c.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_positiveMax_11 = _stream_alpha_4 * max(c1.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_positiveMax_12 = _stream_alpha_4 * max(c2.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
end StreamTests.StreamN2M2;
")})));
end StreamN2M2;


model StreamMinMax3
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f(min=1) = time+1));
    A a2(c(s=2, f(min=-1)));
    StreamConnector c1(f(max=-1));
    StreamConnector c2(f(max=1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax3",
            description="Test stream connectors connected N=2, M=2, with min/max limiting which connectors contribute",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax3
 Real a1.c.p;
 Real a1.c.f(min = 1);
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f(min = -1);
 Real a2.c.s;
 potential Real c1.p;
 flow Real c1.f(max = -1);
 stream Real c1.s;
 potential Real c2.p;
 flow Real c2.f(max = 1);
 stream Real c2.s;
 Real x1;
 Real x2;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0.0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = (_stream_positiveMax_1 * a2.c.s + _stream_positiveMax_2 * c2.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 c2.s = a2.c.s;
 a1.c.p = 4;
 a1.c.f = time + 1;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = (_stream_positiveMax_3 * a2.c.s + _stream_positiveMax_4 * c2.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 x2 = c2.s;
 _stream_s_1 = max(- a2.c.f, 0) + max(c2.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(c2.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a2.c.f, 0) + max(c2.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- a2.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(c2.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
end StreamTests.StreamMinMax3;
")})));
end StreamMinMax3;


model StreamMinMax4
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f(min=1) = time+1));
    A a2(c(s=2, f(min=-1)));
    StreamConnector c1(f(max=-1));
    StreamConnector c2(f(max=-1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax4",
            description="Test stream connectors connected N=2, M=2, with min/max limiting which connectors contribute",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax4
 Real a1.c.p;
 Real a1.c.f(min = 1);
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f(min = -1);
 Real a2.c.s;
 potential Real c1.p;
 flow Real c1.f(max = -1);
 stream Real c1.s;
 potential Real c2.p;
 flow Real c2.f(max = -1);
 stream Real c2.s;
 Real x1;
 Real x2;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0.0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = a2.c.s;
 c2.s = a2.c.s;
 a1.c.p = 4;
 a1.c.f = time + 1;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = a2.c.s;
 x2 = a2.c.s;
end StreamTests.StreamMinMax4;
")})));
end StreamMinMax4;


model StreamMinMax5
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f(min=1) = time+1));
    A a2(c(s=2, f(min=1)));
    StreamConnector c1(f(max=-1));
    StreamConnector c2(f(max=1));
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamMinMax5",
            description="Test stream connectors connected N=2, M=2, with min/max limiting which connectors contribute",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamMinMax5
 Real a1.c.p;
 Real a1.c.f(min = 1);
 Real a1.c.s;
 Real a2.c.p;
 Real a2.c.f(min = 1);
 Real a2.c.s;
 potential Real c1.p;
 flow Real c1.f(max = -1);
 stream Real c1.s;
 potential Real c2.p;
 flow Real c2.f(max = 1);
 stream Real c2.s;
 Real x1;
 Real x2;
equation
 a1.c.f + a2.c.f - c1.f - c2.f = 0.0;
 a1.c.p = a2.c.p;
 a2.c.p = c1.p;
 c1.p = c2.p;
 c1.s = c2.s;
 c2.s = 0.0;
 a1.c.p = 4;
 a1.c.f = time + 1;
 a1.c.s = 1;
 a2.c.s = 2;
 x1 = c2.s;
 x2 = c2.s;
end StreamTests.StreamMinMax5;
")})));
end StreamMinMax5;


model StreamNominal1
    model A
        StreamConnector c1(f(nominal=0.1));
        StreamConnector c2;
        StreamConnector c3(f(nominal=2));
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamNominal1",
            description="Test affect on inStream() from nomainals on flow vars",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamNominal1
 Real a.c1.p;
 Real a.c1.f(nominal = 0.1);
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f;
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f(nominal = 2);
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
equation
 a.c1.f + b.c4.f = 0.0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0.0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0.0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0.0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = (_stream_positiveMax_1 * b.c5.s + _stream_positiveMax_2 * b.c6.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 a.c2.s = (_stream_positiveMax_3 * b.c4.s + _stream_positiveMax_4 * b.c6.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 a.c3.s = (_stream_positiveMax_5 * b.c4.s + _stream_positiveMax_6 * b.c5.s) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
 _stream_s_1 = max(a.c2.f, 0) + max(a.c3.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon * 0.1 then 1 elseif _stream_s_1 > 0 then _stream_s_1 / (_inStreamEpsilon * 0.1) * (_stream_s_1 / (_inStreamEpsilon * 0.1) * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(a.c2.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 0.1);
 _stream_positiveMax_2 = _stream_alpha_1 * max(a.c3.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 0.1);
 _stream_s_2 = max(a.c1.f, 0) + max(a.c3.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon * 0.1 then 1 elseif _stream_s_2 > 0 then _stream_s_2 / (_inStreamEpsilon * 0.1) * (_stream_s_2 / (_inStreamEpsilon * 0.1) * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(a.c1.f, 0) + (1 - _stream_alpha_2) * (_inStreamEpsilon * 0.1);
 _stream_positiveMax_4 = _stream_alpha_2 * max(a.c3.f, 0) + (1 - _stream_alpha_2) * (_inStreamEpsilon * 0.1);
 _stream_s_3 = max(a.c1.f, 0) + max(a.c2.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon * 0.1 then 1 elseif _stream_s_3 > 0 then _stream_s_3 / (_inStreamEpsilon * 0.1) * (_stream_s_3 / (_inStreamEpsilon * 0.1) * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(a.c1.f, 0) + (1 - _stream_alpha_3) * (_inStreamEpsilon * 0.1);
 _stream_positiveMax_6 = _stream_alpha_3 * max(a.c2.f, 0) + (1 - _stream_alpha_3) * (_inStreamEpsilon * 0.1);
end StreamTests.StreamNominal1;
")})));
end StreamNominal1;


model StreamNominal2
    model A
        StreamConnector c1(f(nominal=10));
        StreamConnector c2(f(nominal=10));
        StreamConnector c3(f(nominal=2));
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamNominal2",
            description="Test affect on inStream() from nomainals on flow vars",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamNominal2
 Real a.c1.p;
 Real a.c1.f(nominal = 10);
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f(nominal = 10);
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f(nominal = 2);
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
equation
 a.c1.f + b.c4.f = 0.0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0.0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0.0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0.0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = (_stream_positiveMax_1 * b.c5.s + _stream_positiveMax_2 * b.c6.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 a.c2.s = (_stream_positiveMax_3 * b.c4.s + _stream_positiveMax_4 * b.c6.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 a.c3.s = (_stream_positiveMax_5 * b.c4.s + _stream_positiveMax_6 * b.c5.s) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
 _stream_s_1 = max(a.c2.f, 0) + max(a.c3.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon * 2.0 then 1 elseif _stream_s_1 > 0 then _stream_s_1 / (_inStreamEpsilon * 2.0) * (_stream_s_1 / (_inStreamEpsilon * 2.0) * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(a.c2.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 2.0);
 _stream_positiveMax_2 = _stream_alpha_1 * max(a.c3.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 2.0);
 _stream_s_2 = max(a.c1.f, 0) + max(a.c3.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon * 2.0 then 1 elseif _stream_s_2 > 0 then _stream_s_2 / (_inStreamEpsilon * 2.0) * (_stream_s_2 / (_inStreamEpsilon * 2.0) * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(a.c1.f, 0) + (1 - _stream_alpha_2) * (_inStreamEpsilon * 2.0);
 _stream_positiveMax_4 = _stream_alpha_2 * max(a.c3.f, 0) + (1 - _stream_alpha_2) * (_inStreamEpsilon * 2.0);
 _stream_s_3 = max(a.c1.f, 0) + max(a.c2.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon * 2.0 then 1 elseif _stream_s_3 > 0 then _stream_s_3 / (_inStreamEpsilon * 2.0) * (_stream_s_3 / (_inStreamEpsilon * 2.0) * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(a.c1.f, 0) + (1 - _stream_alpha_3) * (_inStreamEpsilon * 2.0);
 _stream_positiveMax_6 = _stream_alpha_3 * max(a.c2.f, 0) + (1 - _stream_alpha_3) * (_inStreamEpsilon * 2.0);
end StreamTests.StreamNominal2;
")})));
end StreamNominal2;


model StreamAttributesOnType
    connector StreamConnector2 = StreamConnector(f(nominal=2,max=-1));

    model A
        StreamConnector c1(f(nominal=10));
        StreamConnector c2(f(nominal=10));
        StreamConnector2 c3;
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamAttributesOnType",
            description="Test that attributes on types affect generation of stream equations",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.StreamAttributesOnType
 Real a.c1.p;
 Real a.c1.f(nominal = 10);
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f(nominal = 10);
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f(nominal = 2,max = -1);
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
equation
 a.c1.f + b.c4.f = 0.0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0.0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0.0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0.0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = b.c5.s;
 a.c2.s = b.c4.s;
 a.c3.s = (_stream_positiveMax_1 * b.c4.s + _stream_positiveMax_2 * b.c5.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
 _stream_s_1 = max(a.c1.f, 0) + max(a.c2.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon * 2.0 then 1 elseif _stream_s_1 > 0 then _stream_s_1 / (_inStreamEpsilon * 2.0) * (_stream_s_1 / (_inStreamEpsilon * 2.0) * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(a.c1.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 2.0);
 _stream_positiveMax_2 = _stream_alpha_1 * max(a.c2.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 2.0);
end StreamTests.StreamAttributesOnType;
")})));
end StreamAttributesOnType;


model InStreamDer1
    connector StreamConnector2 = StreamConnector(f(nominal=2,max=-1));

    model A
        StreamConnector c1(f(nominal=10));
        StreamConnector c2(f(nominal=10));
        StreamConnector2 c3;
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    equation
        connect(c1, c2);
        connect(c1, c3);
    end A;
    
    model B
        StreamConnector c4(p = 7, f = 8, s = 4);
        StreamConnector c5(s = 5);
        StreamConnector c6(s = 6, f = 9);
    end B;
    
    A a;
    B b;
    
    Real x1 = der(inStream(a.c1.s));
    Real x2 = der(der(inStream(a.c1.s)));
equation
    connect(a.c1, b.c4);
    connect(a.c2, b.c5);
    connect(a.c3, b.c6);
    

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InStreamDer1",
            description="Test that attributes on types affect generation of stream equations",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            variability_propagation=false,
            flatModel="
fclass StreamTests.InStreamDer1
 Real a.c1.p;
 Real a.c1.f(nominal = 10);
 Real a.c1.s;
 Real a.c2.p;
 Real a.c2.f(nominal = 10);
 Real a.c2.s;
 Real a.c3.p;
 Real a.c3.f(nominal = 2,max = -1);
 Real a.c3.s;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real b.c4.p;
 Real b.c4.f;
 Real b.c4.s;
 Real b.c5.p;
 Real b.c5.f;
 Real b.c5.s;
 Real b.c6.p;
 Real b.c6.f;
 Real b.c6.s;
 Real x1;
 Real x2;
 Real b.c4._der_s;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
equation
 a.c1.f + b.c4.f = 0.0;
 a.c1.p = b.c4.p;
 a.c2.f + b.c5.f = 0.0;
 a.c2.p = b.c5.p;
 a.c3.f + b.c6.f = 0.0;
 a.c3.p = b.c6.p;
 - a.c1.f - a.c2.f - a.c3.f = 0.0;
 a.c1.p = a.c2.p;
 a.c2.p = a.c3.p;
 a.c1.s = b.c5.s;
 a.c2.s = b.c4.s;
 a.c3.s = (_stream_positiveMax_1 * b.c4.s + _stream_positiveMax_2 * b.c5.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 a.x1 = b.c4.s;
 a.x2 = b.c5.s;
 a.x3 = b.c6.s;
 b.c4.p = 7;
 b.c4.f = 8;
 b.c4.s = 4;
 b.c5.s = 5;
 b.c6.f = 9;
 b.c6.s = 6;
 x1 = b.c4._der_s;
 x2 = der(b.c4._der_s);
 _stream_s_1 = max(a.c1.f, 0) + max(a.c2.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon * 2.0 then 1 elseif _stream_s_1 > 0 then _stream_s_1 / (_inStreamEpsilon * 2.0) * (_stream_s_1 / (_inStreamEpsilon * 2.0) * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(a.c1.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 2.0);
 _stream_positiveMax_2 = _stream_alpha_1 * max(a.c2.f, 0) + (1 - _stream_alpha_1) * (_inStreamEpsilon * 2.0);
 b.c4._der_s = 0;
end StreamTests.InStreamDer1;
")})));
end InStreamDer1;


model InStreamDer2
    model A
        StreamConnector c1(p = 7, f = time, s = 4);
        StreamConnector c2(s = 5);
        StreamConnector c3(s = 6, f = 2 * time);
        Real x1 = inStream(c1.s);
        Real x2 = inStream(c2.s);
        Real x3 = inStream(c3.s);
    end A;
    
    A a;
    
    Real y1 = der(inStream(a.c1.s));
    Real y2 = der(der(inStream(a.c1.s)));
equation
    connect(a.c1, a.c2);
    connect(a.c1, a.c3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InStreamDer2",
            description="Test handling of derivative of inStream()",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass StreamTests.InStreamDer2
 constant Real a.c1.p = 7;
 Real a.c1.f;
 constant Real a.c1.s = 4;
 constant Real a.c2.p = 7.0;
 Real a.c2.f;
 constant Real a.c2.s = 5;
 constant Real a.c3.p = 7.0;
 Real a.c3.f;
 constant Real a.c3.s = 6;
 Real a.x1;
 Real a.x2;
 Real a.x3;
 Real y1;
 Real y2;
 Real a.c1._der_f;
 Real a.c2._der_f;
 Real a.c3._der_f;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
 Real _stream_s_4;
 Real _stream_alpha_4;
 Real _stream_positiveMax_7;
 Real _stream_positiveMax_8;
 Real _stream_s_5;
 Real _stream_alpha_5;
 Real _stream_positiveMax_9;
 Real _stream_positiveMax_10;
 Real _der_stream_positiveMax_7;
 Real _der_stream_positiveMax_8;
 Real _der_stream_positiveMax_9;
 Real _der_stream_positiveMax_10;
 Real _der_stream_s_4;
 Real _der_stream_alpha_4;
 Real _der_stream_s_5;
 Real _der_stream_alpha_5;
equation
 a.c1.f + a.c2.f + a.c3.f = 0.0;
 a.c1.f = time;
 a.c3.f = 2 * time;
 a.x1 = (_stream_positiveMax_1 * 5.0 + _stream_positiveMax_2 * 6.0) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 a.x2 = (_stream_positiveMax_3 * 4.0 + _stream_positiveMax_4 * 6.0) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 a.x3 = (_stream_positiveMax_5 * 4.0 + _stream_positiveMax_6 * 5.0) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 y1 = ((_der_stream_positiveMax_7 * 5.0 + _der_stream_positiveMax_8 * 6.0) * (_stream_positiveMax_7 + _stream_positiveMax_8) - (_stream_positiveMax_7 * 5.0 + _stream_positiveMax_8 * 6.0) * (_der_stream_positiveMax_7 + _der_stream_positiveMax_8)) / (_stream_positiveMax_7 + _stream_positiveMax_8) ^ 2;
 y2 = (((_der_stream_positiveMax_9 * 5.0 + _der_stream_positiveMax_10 * 6.0) * (_der_stream_positiveMax_9 + _der_stream_positiveMax_10) + (der(_der_stream_positiveMax_9) * 5.0 + der(_der_stream_positiveMax_10) * 6.0) * (_stream_positiveMax_9 + _stream_positiveMax_10) - ((_stream_positiveMax_9 * 5.0 + _stream_positiveMax_10 * 6.0) * (der(_der_stream_positiveMax_9) + der(_der_stream_positiveMax_10)) + (_der_stream_positiveMax_9 * 5.0 + _der_stream_positiveMax_10 * 6.0) * (_der_stream_positiveMax_9 + _der_stream_positiveMax_10))) * (_stream_positiveMax_9 + _stream_positiveMax_10) ^ 2 - ((_der_stream_positiveMax_9 * 5.0 + _der_stream_positiveMax_10 * 6.0) * (_stream_positiveMax_9 + _stream_positiveMax_10) - (_stream_positiveMax_9 * 5.0 + _stream_positiveMax_10 * 6.0) * (_der_stream_positiveMax_9 + _der_stream_positiveMax_10)) * (2 * (_stream_positiveMax_9 + _stream_positiveMax_10) * (_der_stream_positiveMax_9 + _der_stream_positiveMax_10))) / ((_stream_positiveMax_9 + _stream_positiveMax_10) ^ 2) ^ 2;
 _stream_s_1 = max(- a.c2.f, 0) + max(- a.c3.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a.c2.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- a.c3.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a.c1.f, 0) + max(- a.c3.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- a.c1.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(- a.c3.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(- a.c1.f, 0) + max(- a.c2.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(- a.c1.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(- a.c2.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_s_4 = max(- a.c2.f, 0) + max(- a.c3.f, 0);
 _stream_alpha_4 = smooth(1, if _stream_s_4 > _inStreamEpsilon then 1 elseif _stream_s_4 > 0 then _stream_s_4 / _inStreamEpsilon * (_stream_s_4 / _inStreamEpsilon * (3 - 2 * _stream_s_4)) else 0);
 _stream_positiveMax_7 = _stream_alpha_4 * max(- a.c2.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_positiveMax_8 = _stream_alpha_4 * max(- a.c3.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_s_5 = max(- a.c2.f, 0) + max(- a.c3.f, 0);
 _stream_alpha_5 = smooth(1, if _stream_s_5 > _inStreamEpsilon then 1 elseif _stream_s_5 > 0 then _stream_s_5 / _inStreamEpsilon * (_stream_s_5 / _inStreamEpsilon * (3 - 2 * _stream_s_5)) else 0);
 _stream_positiveMax_9 = _stream_alpha_5 * max(- a.c2.f, 0) + (1 - _stream_alpha_5) * _inStreamEpsilon;
 _stream_positiveMax_10 = _stream_alpha_5 * max(- a.c3.f, 0) + (1 - _stream_alpha_5) * _inStreamEpsilon;
 a.c1._der_f + a.c2._der_f + a.c3._der_f = 0.0;
 a.c1._der_f = 1.0;
 a.c3._der_f = 2;
 _der_stream_s_4 = noEvent(if - a.c2.f > 0 then - a.c2._der_f else 0) + noEvent(if - a.c3.f > 0 then - a.c3._der_f else 0);
 _der_stream_alpha_4 = smooth(0, if _stream_s_4 > _inStreamEpsilon then 0 elseif _stream_s_4 > 0 then _stream_s_4 / _inStreamEpsilon * (_stream_s_4 / _inStreamEpsilon * (- 2 * _der_stream_s_4) + _der_stream_s_4 * _inStreamEpsilon / _inStreamEpsilon ^ 2 * (3 - 2 * _stream_s_4)) + _der_stream_s_4 * _inStreamEpsilon / _inStreamEpsilon ^ 2 * (_stream_s_4 / _inStreamEpsilon * (3 - 2 * _stream_s_4)) else 0);
 _der_stream_positiveMax_7 = _stream_alpha_4 * noEvent(if - a.c2.f > 0 then - a.c2._der_f else 0) + _der_stream_alpha_4 * max(- a.c2.f, 0) + (- _der_stream_alpha_4) * _inStreamEpsilon;
 _der_stream_positiveMax_8 = _stream_alpha_4 * noEvent(if - a.c3.f > 0 then - a.c3._der_f else 0) + _der_stream_alpha_4 * max(- a.c3.f, 0) + (- _der_stream_alpha_4) * _inStreamEpsilon;
 _der_stream_s_5 = noEvent(if - a.c2.f > 0 then - a.c2._der_f else 0) + noEvent(if - a.c3.f > 0 then - a.c3._der_f else 0);
 _der_stream_alpha_5 = smooth(0, if _stream_s_5 > _inStreamEpsilon then 0 elseif _stream_s_5 > 0 then _stream_s_5 / _inStreamEpsilon * (_stream_s_5 / _inStreamEpsilon * (- 2 * _der_stream_s_5) + _der_stream_s_5 * _inStreamEpsilon / _inStreamEpsilon ^ 2 * (3 - 2 * _stream_s_5)) + _der_stream_s_5 * _inStreamEpsilon / _inStreamEpsilon ^ 2 * (_stream_s_5 / _inStreamEpsilon * (3 - 2 * _stream_s_5)) else 0);
 _der_stream_positiveMax_9 = _stream_alpha_5 * noEvent(if - a.c2.f > 0 then - a.c2._der_f else 0) + _der_stream_alpha_5 * max(- a.c2.f, 0) + (- _der_stream_alpha_5) * _inStreamEpsilon;
 _der_stream_positiveMax_10 = _stream_alpha_5 * noEvent(if - a.c3.f > 0 then - a.c3._der_f else 0) + _der_stream_alpha_5 * max(- a.c3.f, 0) + (- _der_stream_alpha_5) * _inStreamEpsilon;
end StreamTests.InStreamDer2;
")})));
end InStreamDer2;


model StreamWithConst1
    model A
        StreamConnector c;
    end A;
	    
    A a1(c(f = 0, p = 0, s = 2 * time)), a2(c(f = time, s = 3 * time)), a3(c(s = 4 * time));
    Real x1, x2, x3;
equation
    connect(a1.c, a2.c);
    connect(a2.c, a3.c);
    x1 = inStream(a1.c.s);
    x2 = inStream(a2.c.s);
    x3 = inStream(a3.c.s);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithConst1",
            description="Test stream connectors connected N=0, M=3, with some constant flows",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass StreamTests.StreamWithConst1
 constant Real a1.c.p = 0;
 constant Real a1.c.f = 0;
 Real a1.c.s;
 constant Real a2.c.p = 0.0;
 Real a2.c.f;
 Real a2.c.s;
 constant Real a3.c.p = 0.0;
 Real a3.c.f;
 Real a3.c.s;
 Real x1;
 Real x2;
 Real x3;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
equation
 x1 = (_stream_positiveMax_1 * a2.c.s + _stream_positiveMax_2 * a3.c.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 x2 = a3.c.s;
 x3 = a2.c.s;
 a2.c.f + a3.c.f = 0.0;
 a1.c.s = 2 * time;
 a2.c.f = time;
 a2.c.s = 3 * time;
 a3.c.s = 4 * time;
 _stream_s_1 = max(- a2.c.f, 0) + max(- a3.c.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- a3.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
end StreamTests.StreamWithConst1;
")})));
end StreamWithConst1;


model StreamWithConst2
    model A
        StreamConnector c;
    end A;
    
    A a1(c(s=1, p=4, f=1));
    A a2(c(s=2));
    StreamConnector c1;
    StreamConnector c2;
    Real x1 = inStream(a1.c.s);
    Real x2 = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithConst2",
            description="Test stream connectors connected N=2, M=2, with some constant flows",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass StreamTests.StreamWithConst2
 constant Real a1.c.p = 4;
 constant Real a1.c.f = 1;
 constant Real a1.c.s = 1;
 constant Real a2.c.p = 4.0;
 Real a2.c.f;
 constant Real a2.c.s = 2;
 potential Real c1.p;
 flow Real c1.f;
 stream Real c1.s;
 potential Real c2.p;
 flow Real c2.f;
 stream Real c2.s;
 Real x1;
 Real x2;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
 Real _stream_positiveMax_7;
 Real _stream_s_4;
 Real _stream_alpha_4;
 Real _stream_positiveMax_8;
 Real _stream_positiveMax_9;
equation
 1.0 + a2.c.f - c1.f - c2.f = 0.0;
 4.0 = c1.p;
 c1.p = c2.p;
 c1.s = (_stream_positiveMax_1 * 2.0 + _stream_positiveMax_2 * c2.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 c2.s = (_stream_positiveMax_3 * 2.0 + _stream_positiveMax_4 * c1.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 x1 = (_stream_positiveMax_5 * 2.0 + _stream_positiveMax_6 * c1.s + _stream_positiveMax_7 * c2.s) / (_stream_positiveMax_5 + _stream_positiveMax_6 + _stream_positiveMax_7);
 x2 = (_stream_positiveMax_8 * c1.s + _stream_positiveMax_9 * c2.s) / (_stream_positiveMax_8 + _stream_positiveMax_9);
 _stream_s_1 = max(- a2.c.f, 0) + max(c2.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(c2.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a2.c.f, 0) + max(c1.f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- a2.c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(c1.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(- a2.c.f, 0) + max(c1.f, 0) + max(c2.f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(- a2.c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(c1.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_7 = _stream_alpha_3 * max(c2.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_s_4 = max(c1.f, 0) + max(c2.f, 0);
 _stream_alpha_4 = smooth(1, if _stream_s_4 > _inStreamEpsilon then 1 elseif _stream_s_4 > 0 then _stream_s_4 / _inStreamEpsilon * (_stream_s_4 / _inStreamEpsilon * (3 - 2 * _stream_s_4)) else 0);
 _stream_positiveMax_8 = _stream_alpha_4 * max(c1.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_positiveMax_9 = _stream_alpha_4 * max(c2.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
end StreamTests.StreamWithConst2;
")})));
end StreamWithConst2;


model StreamWithConst3
    model A
        StreamConnector c;
    end A;
    
    A a1[2](c(s={1,2*time}, p={3,4*time}, f={1,time}));
    A a2[2](c(s={5,6*time}));
    StreamConnector c1[2];
    StreamConnector c2[2];
    Real x1[2] = inStream(a1.c.s);
    Real x2[2] = inStream(a2.c.s);
equation
    connect(a1.c, a2.c);
    connect(a1.c, c1);
    connect(a1.c, c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithConst3",
            description="Test array stream connectors connected N=2, M=2, with some constant flows",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass StreamTests.StreamWithConst3
 constant Real a1[1].c.p = 3;
 constant Real a1[1].c.f = 1;
 constant Real a1[1].c.s = 1;
 Real a1[2].c.p;
 Real a1[2].c.f;
 Real a1[2].c.s;
 constant Real a2[1].c.p = 3.0;
 Real a2[1].c.f;
 constant Real a2[1].c.s = 5;
 Real a2[2].c.p;
 Real a2[2].c.f;
 Real a2[2].c.s;
 potential Real c1[1].p;
 flow Real c1[1].f;
 stream Real c1[1].s;
 potential Real c1[2].p;
 flow Real c1[2].f;
 stream Real c1[2].s;
 potential Real c2[1].p;
 flow Real c2[1].f;
 stream Real c2[1].s;
 potential Real c2[2].p;
 flow Real c2[2].f;
 stream Real c2[2].s;
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
 Real _stream_positiveMax_7;
 Real _stream_s_4;
 Real _stream_alpha_4;
 Real _stream_positiveMax_8;
 Real _stream_positiveMax_9;
 Real _stream_positiveMax_10;
 Real _stream_s_5;
 Real _stream_alpha_5;
 Real _stream_positiveMax_11;
 Real _stream_positiveMax_12;
 Real _stream_positiveMax_13;
 Real _stream_s_6;
 Real _stream_alpha_6;
 Real _stream_positiveMax_14;
 Real _stream_positiveMax_15;
 Real _stream_positiveMax_16;
 Real _stream_s_7;
 Real _stream_alpha_7;
 Real _stream_positiveMax_17;
 Real _stream_positiveMax_18;
 Real _stream_s_8;
 Real _stream_alpha_8;
 Real _stream_positiveMax_19;
 Real _stream_positiveMax_20;
 Real _stream_positiveMax_21;
equation
 1.0 + a2[1].c.f - c1[1].f - c2[1].f = 0.0;
 3.0 = c1[1].p;
 c1[1].p = c2[1].p;
 c1[1].s = (_stream_positiveMax_1 * 5.0 + _stream_positiveMax_2 * c2[1].s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 c2[1].s = (_stream_positiveMax_3 * 5.0 + _stream_positiveMax_4 * c1[1].s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 a1[2].c.f + a2[2].c.f - c1[2].f - c2[2].f = 0.0;
 a1[2].c.p = a2[2].c.p;
 a2[2].c.p = c1[2].p;
 c1[2].p = c2[2].p;
 c1[2].s = (_stream_positiveMax_5 * a1[2].c.s + _stream_positiveMax_6 * a2[2].c.s + _stream_positiveMax_7 * c2[2].s) / (_stream_positiveMax_5 + _stream_positiveMax_6 + _stream_positiveMax_7);
 c2[2].s = (_stream_positiveMax_8 * a1[2].c.s + _stream_positiveMax_9 * a2[2].c.s + _stream_positiveMax_10 * c1[2].s) / (_stream_positiveMax_8 + _stream_positiveMax_9 + _stream_positiveMax_10);
 a1[2].c.p = 4 * time;
 a1[2].c.f = time;
 a1[2].c.s = 2 * time;
 a2[2].c.s = 6 * time;
 x1[1] = (_stream_positiveMax_11 * 5.0 + _stream_positiveMax_12 * c1[1].s + _stream_positiveMax_13 * c2[1].s) / (_stream_positiveMax_11 + _stream_positiveMax_12 + _stream_positiveMax_13);
 x1[2] = (_stream_positiveMax_14 * a2[2].c.s + _stream_positiveMax_15 * c1[2].s + _stream_positiveMax_16 * c2[2].s) / (_stream_positiveMax_14 + _stream_positiveMax_15 + _stream_positiveMax_16);
 x2[1] = (_stream_positiveMax_17 * c1[1].s + _stream_positiveMax_18 * c2[1].s) / (_stream_positiveMax_17 + _stream_positiveMax_18);
 x2[2] = (_stream_positiveMax_19 * a1[2].c.s + _stream_positiveMax_20 * c1[2].s + _stream_positiveMax_21 * c2[2].s) / (_stream_positiveMax_19 + _stream_positiveMax_20 + _stream_positiveMax_21);
 _stream_s_1 = max(- a2[1].c.f, 0) + max(c2[1].f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a2[1].c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(c2[1].f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- a2[1].c.f, 0) + max(c1[1].f, 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- a2[1].c.f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(c1[1].f, 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(- a1[2].c.f, 0) + max(- a2[2].c.f, 0) + max(c2[2].f, 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(- a1[2].c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(- a2[2].c.f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_7 = _stream_alpha_3 * max(c2[2].f, 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_s_4 = max(- a1[2].c.f, 0) + max(- a2[2].c.f, 0) + max(c1[2].f, 0);
 _stream_alpha_4 = smooth(1, if _stream_s_4 > _inStreamEpsilon then 1 elseif _stream_s_4 > 0 then _stream_s_4 / _inStreamEpsilon * (_stream_s_4 / _inStreamEpsilon * (3 - 2 * _stream_s_4)) else 0);
 _stream_positiveMax_8 = _stream_alpha_4 * max(- a1[2].c.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_positiveMax_9 = _stream_alpha_4 * max(- a2[2].c.f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_positiveMax_10 = _stream_alpha_4 * max(c1[2].f, 0) + (1 - _stream_alpha_4) * _inStreamEpsilon;
 _stream_s_5 = max(- a2[1].c.f, 0) + max(c1[1].f, 0) + max(c2[1].f, 0);
 _stream_alpha_5 = smooth(1, if _stream_s_5 > _inStreamEpsilon then 1 elseif _stream_s_5 > 0 then _stream_s_5 / _inStreamEpsilon * (_stream_s_5 / _inStreamEpsilon * (3 - 2 * _stream_s_5)) else 0);
 _stream_positiveMax_11 = _stream_alpha_5 * max(- a2[1].c.f, 0) + (1 - _stream_alpha_5) * _inStreamEpsilon;
 _stream_positiveMax_12 = _stream_alpha_5 * max(c1[1].f, 0) + (1 - _stream_alpha_5) * _inStreamEpsilon;
 _stream_positiveMax_13 = _stream_alpha_5 * max(c2[1].f, 0) + (1 - _stream_alpha_5) * _inStreamEpsilon;
 _stream_s_6 = max(- a2[2].c.f, 0) + max(c1[2].f, 0) + max(c2[2].f, 0);
 _stream_alpha_6 = smooth(1, if _stream_s_6 > _inStreamEpsilon then 1 elseif _stream_s_6 > 0 then _stream_s_6 / _inStreamEpsilon * (_stream_s_6 / _inStreamEpsilon * (3 - 2 * _stream_s_6)) else 0);
 _stream_positiveMax_14 = _stream_alpha_6 * max(- a2[2].c.f, 0) + (1 - _stream_alpha_6) * _inStreamEpsilon;
 _stream_positiveMax_15 = _stream_alpha_6 * max(c1[2].f, 0) + (1 - _stream_alpha_6) * _inStreamEpsilon;
 _stream_positiveMax_16 = _stream_alpha_6 * max(c2[2].f, 0) + (1 - _stream_alpha_6) * _inStreamEpsilon;
 _stream_s_7 = max(c1[1].f, 0) + max(c2[1].f, 0);
 _stream_alpha_7 = smooth(1, if _stream_s_7 > _inStreamEpsilon then 1 elseif _stream_s_7 > 0 then _stream_s_7 / _inStreamEpsilon * (_stream_s_7 / _inStreamEpsilon * (3 - 2 * _stream_s_7)) else 0);
 _stream_positiveMax_17 = _stream_alpha_7 * max(c1[1].f, 0) + (1 - _stream_alpha_7) * _inStreamEpsilon;
 _stream_positiveMax_18 = _stream_alpha_7 * max(c2[1].f, 0) + (1 - _stream_alpha_7) * _inStreamEpsilon;
 _stream_s_8 = max(- a1[2].c.f, 0) + max(c1[2].f, 0) + max(c2[2].f, 0);
 _stream_alpha_8 = smooth(1, if _stream_s_8 > _inStreamEpsilon then 1 elseif _stream_s_8 > 0 then _stream_s_8 / _inStreamEpsilon * (_stream_s_8 / _inStreamEpsilon * (3 - 2 * _stream_s_8)) else 0);
 _stream_positiveMax_19 = _stream_alpha_8 * max(- a1[2].c.f, 0) + (1 - _stream_alpha_8) * _inStreamEpsilon;
 _stream_positiveMax_20 = _stream_alpha_8 * max(c1[2].f, 0) + (1 - _stream_alpha_8) * _inStreamEpsilon;
 _stream_positiveMax_21 = _stream_alpha_8 * max(c2[2].f, 0) + (1 - _stream_alpha_8) * _inStreamEpsilon;
end StreamTests.StreamWithConst3;
")})));
end StreamWithConst3;


model StreamWithConst4
    model A
        StreamConnector c;
    end A;
        
    A a1(c(f = 0, p = 0, s = 2 * time)), a2(c(f = time, s = 3)), a3(c(s = 4));
    Real x1, x2, x3;
equation
    connect(a1.c, a2.c);
    connect(a2.c, a3.c);
    x1 = inStream(a1.c.s);
    x2 = inStream(a2.c.s);
    x3 = inStream(a3.c.s);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithConst4",
            description="Constant evaluation of inStream() where only one constant stream variable with a non-constant flow contributes to the result",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass StreamTests.StreamWithConst4
 constant Real a1.c.p = 0;
 constant Real a1.c.f = 0;
 Real a1.c.s;
 constant Real a2.c.p = 0.0;
 Real a2.c.f;
 constant Real a2.c.s = 3;
 constant Real a3.c.p = 0.0;
 Real a3.c.f;
 constant Real a3.c.s = 4;
 Real x1;
 Real x2;
 Real x3;
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
equation
 x1 = (_stream_positiveMax_1 * 3.0 + _stream_positiveMax_2 * 4.0) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 x2 = 4.0;
 x3 = 3.0;
 a2.c.f + a3.c.f = 0.0;
 a1.c.s = 2 * time;
 a2.c.f = time;
 _stream_s_1 = max(- a2.c.f, 0) + max(- a3.c.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- a3.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
end StreamTests.StreamWithConst4;
")})));
end StreamWithConst4;

model StreamWithParameter1
    model A
        StreamConnector c;
    end A;
        
    parameter Real p = 0;
    A a1(c(f = 0, p = 0, s = 0)), a2(c(f=p,s=p)), a3(c(s=p));
    Real x1, x2, x3;
    
equation
    connect(a1.c, a2.c);
    connect(a2.c, a3.c);
    x1 = inStream(a1.c.s);
    x2 = inStream(a2.c.s);
    x3 = inStream(a3.c.s);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithParameter1",
            description="InStream with parameter variability",
            flatModel="
fclass StreamTests.StreamWithParameter1
 parameter Real p = 0 /* 0 */;
 constant Real a1.c.f = 0;
 parameter Real a2.c.f;
 parameter Real a2.c.s;
 parameter Real a3.c.s;
 parameter Real a3.c.f;
 parameter Real x3;
 parameter Real x2;
 parameter Real _stream_s_1;
 parameter Real _stream_alpha_1;
 parameter Real _stream_positiveMax_1;
 parameter Real _stream_positiveMax_2;
 parameter Real x1;
parameter equation
 a2.c.f = p;
 a2.c.s = p;
 a3.c.s = p;
 a3.c.f = - a2.c.f;
 x3 = a2.c.s;
 x2 = a3.c.s;
 _stream_s_1 = max(- a2.c.f, 0) + max(- a3.c.f, 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- a2.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- a3.c.f, 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 x1 = (_stream_positiveMax_1 * a2.c.s + _stream_positiveMax_2 * a3.c.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
end StreamTests.StreamWithParameter1;
")})));
end StreamWithParameter1;


model StreamWithArrays1
    connector C
        Real p;
        flow Real f;
        stream Real s[0];
    end C;

    model A
        C c1, c2, c3;
        Real x1[0], x2[0], x3[0];
    equation
        connect(c1, c2);
        connect(c2, c3);
        x1 = inStream(c1.s);
        x2 = inStream(c2.s);
        x3 = inStream(c3.s);
    end A;
    
    model B
        C c(p = 1);
    end B;

    A a;
    B b;
equation
    connect(a.c1, b.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithArrays1",
            description="Test handling of outer stream connectors with arrays",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamWithArrays1
 constant Real a.c1.p = 1.0;
 constant Real a.c1.f = -0.0;
 constant Real a.c2.p = 1.0;
 constant Real a.c2.f = 0.0;
 constant Real a.c3.p = 1.0;
 constant Real a.c3.f = 0.0;
 constant Real b.c.p = 1;
 constant Real b.c.f = 0.0;
end StreamTests.StreamWithArrays1;
")})));
end StreamWithArrays1;


model StreamWithArrays2
    connector C
        Real p;
        flow Real f;
        stream Real s[2];
    end C;

    model A
        C c1, c2, c3;
        Real x1[2], x2[2], x3[2];
    equation
        connect(c1, c2);
        connect(c2, c3);
        x1 = inStream(c1.s);
        x2 = inStream(c2.s);
        x3 = inStream(c3.s);
    end A;
    
    model B
        C c(p = 1, s = {1,2});
    end B;

    A a;
    B b;
equation
    connect(a.c1, b.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithArrays2",
            description="Test handling of outer stream connectors with arrays",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamWithArrays2
 constant Real a.c1.p = 1.0;
 constant Real a.c1.f = -0.0;
 Real a.c1.s[1];
 Real a.c1.s[2];
 constant Real a.c2.p = 1.0;
 constant Real a.c2.f = 0.0;
 Real a.c2.s[1];
 Real a.c2.s[2];
 constant Real a.c3.p = 1.0;
 constant Real a.c3.f = 0.0;
 Real a.c3.s[1];
 Real a.c3.s[2];
 constant Real a.x1[1] = 1.0;
 constant Real a.x1[2] = 2.0;
 Real a.x2[1];
 Real a.x2[2];
 Real a.x3[1];
 Real a.x3[2];
 constant Real b.c.p = 1;
 constant Real b.c.f = 0.0;
 constant Real b.c.s[1] = 1;
 constant Real b.c.s[2] = 2;
equation
 a.x2[1] = a.c2.s[1];
 a.x2[2] = a.c2.s[2];
 a.x3[1] = a.c3.s[1];
 a.x3[2] = a.c3.s[2];
 a.c1.s[1] = 0;
 a.c1.s[2] = 0;
 a.c2.s[1] = 0;
 a.c2.s[2] = 0;
 a.c3.s[1] = 0;
 a.c3.s[2] = 0;
end StreamTests.StreamWithArrays2;
")})));
end StreamWithArrays2;


model StreamWithArrays3
    connector C
        Real p;
        flow Real f;
        stream Real s[2];
    end C;

    model A
        C c1[2], c2[2], c3[2];
    equation
        connect(c1, c2);
        connect(c2, c3);
    end A;
    
    model B
        C c[2](p = {1,2}, s = {{1,2},{3,4}});
    end B;

    A a[2];
    B b[2];
equation
    connect(a.c1, b.c);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamWithArrays3",
            description="Test handling of outer stream connectors with arrays",
            eliminate_alias_variables=false,
            flatModel="
fclass StreamTests.StreamWithArrays3
 constant Real a[1].c1[1].p = 1.0;
 constant Real a[1].c1[1].f = -0.0;
 Real a[1].c1[1].s[1];
 Real a[1].c1[1].s[2];
 constant Real a[1].c1[2].p = 2.0;
 constant Real a[1].c1[2].f = -0.0;
 Real a[1].c1[2].s[1];
 Real a[1].c1[2].s[2];
 constant Real a[1].c2[1].p = 1.0;
 constant Real a[1].c2[1].f = 0.0;
 Real a[1].c2[1].s[1];
 Real a[1].c2[1].s[2];
 constant Real a[1].c2[2].p = 2.0;
 constant Real a[1].c2[2].f = 0.0;
 Real a[1].c2[2].s[1];
 Real a[1].c2[2].s[2];
 constant Real a[1].c3[1].p = 1.0;
 constant Real a[1].c3[1].f = 0.0;
 Real a[1].c3[1].s[1];
 Real a[1].c3[1].s[2];
 constant Real a[1].c3[2].p = 2.0;
 constant Real a[1].c3[2].f = 0.0;
 Real a[1].c3[2].s[1];
 Real a[1].c3[2].s[2];
 constant Real a[2].c1[1].p = 1.0;
 constant Real a[2].c1[1].f = -0.0;
 Real a[2].c1[1].s[1];
 Real a[2].c1[1].s[2];
 constant Real a[2].c1[2].p = 2.0;
 constant Real a[2].c1[2].f = -0.0;
 Real a[2].c1[2].s[1];
 Real a[2].c1[2].s[2];
 constant Real a[2].c2[1].p = 1.0;
 constant Real a[2].c2[1].f = 0.0;
 Real a[2].c2[1].s[1];
 Real a[2].c2[1].s[2];
 constant Real a[2].c2[2].p = 2.0;
 constant Real a[2].c2[2].f = 0.0;
 Real a[2].c2[2].s[1];
 Real a[2].c2[2].s[2];
 constant Real a[2].c3[1].p = 1.0;
 constant Real a[2].c3[1].f = 0.0;
 Real a[2].c3[1].s[1];
 Real a[2].c3[1].s[2];
 constant Real a[2].c3[2].p = 2.0;
 constant Real a[2].c3[2].f = 0.0;
 Real a[2].c3[2].s[1];
 Real a[2].c3[2].s[2];
 constant Real b[1].c[1].p = 1;
 constant Real b[1].c[1].f = 0.0;
 constant Real b[1].c[1].s[1] = 1;
 constant Real b[1].c[1].s[2] = 2;
 constant Real b[1].c[2].p = 2;
 constant Real b[1].c[2].f = 0.0;
 constant Real b[1].c[2].s[1] = 3;
 constant Real b[1].c[2].s[2] = 4;
 constant Real b[2].c[1].p = 1;
 constant Real b[2].c[1].f = 0.0;
 constant Real b[2].c[1].s[1] = 1;
 constant Real b[2].c[1].s[2] = 2;
 constant Real b[2].c[2].p = 2;
 constant Real b[2].c[2].f = 0.0;
 constant Real b[2].c[2].s[1] = 3;
 constant Real b[2].c[2].s[2] = 4;
equation
 a[1].c1[1].s[1] = 0;
 a[1].c1[1].s[2] = 0;
 a[1].c2[1].s[1] = 0;
 a[1].c2[1].s[2] = 0;
 a[1].c3[1].s[1] = 0;
 a[1].c3[1].s[2] = 0;
 a[1].c1[2].s[1] = 0;
 a[1].c1[2].s[2] = 0;
 a[1].c2[2].s[1] = 0;
 a[1].c2[2].s[2] = 0;
 a[1].c3[2].s[1] = 0;
 a[1].c3[2].s[2] = 0;
 a[2].c1[1].s[1] = 0;
 a[2].c1[1].s[2] = 0;
 a[2].c2[1].s[1] = 0;
 a[2].c2[1].s[2] = 0;
 a[2].c3[1].s[1] = 0;
 a[2].c3[1].s[2] = 0;
 a[2].c1[2].s[1] = 0;
 a[2].c1[2].s[2] = 0;
 a[2].c2[2].s[1] = 0;
 a[2].c2[2].s[2] = 0;
 a[2].c3[2].s[1] = 0;
 a[2].c3[2].s[2] = 0;
end StreamTests.StreamWithArrays3;
")})));
end StreamWithArrays3;


model StreamDerAlias1
    model A
        StreamConnector c;
    end A;

    A a1(c(f = time * time, p = 0, s = 2 * time));
    A a2(c(f = 2 * time * time, s = 3 * time));
    A a3(c(s = 4 * time));
    Real x1, x2, x3;
    Real y1(min = 0), y2(min = 0), y3(min = 0);
equation
    connect(a1.c, a2.c);
    connect(a2.c, a3.c);
    x1 = inStream(a1.c.s);
    x2 = inStream(a2.c.s);
    x3 = inStream(a3.c.s);
    a1.c.f = der(y1);
    a2.c.f = der(y2);
    a3.c.f = der(y3);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamDerAlias1",
            description="Check expansion of inStream() when flow variables are alias eliminated against derivative variable",
            flatModel="
fclass StreamTests.StreamDerAlias1
 constant Real a1.c.p = 0;
 Real a1.c.f;
 Real a1.c.s;
 Real a2.c.f;
 Real a2.c.s;
 Real a3.c.f;
 Real a3.c.s;
 Real x1;
 Real x2;
 Real x3;
 Real y1(min = 0);
 Real y2(min = 0);
 Real y3(min = 0);
 Real _stream_s_1;
 Real _stream_alpha_1;
 Real _stream_positiveMax_1;
 Real _stream_positiveMax_2;
 Real _stream_s_2;
 Real _stream_alpha_2;
 Real _stream_positiveMax_3;
 Real _stream_positiveMax_4;
 Real _stream_s_3;
 Real _stream_alpha_3;
 Real _stream_positiveMax_5;
 Real _stream_positiveMax_6;
initial equation 
 y1 = 0.0;
 y2 = 0.0;
 y3 = 0.0;
equation
 x1 = (_stream_positiveMax_1 * a2.c.s + _stream_positiveMax_2 * a3.c.s) / (_stream_positiveMax_1 + _stream_positiveMax_2);
 x2 = (_stream_positiveMax_3 * a1.c.s + _stream_positiveMax_4 * a3.c.s) / (_stream_positiveMax_3 + _stream_positiveMax_4);
 x3 = (_stream_positiveMax_5 * a1.c.s + _stream_positiveMax_6 * a2.c.s) / (_stream_positiveMax_5 + _stream_positiveMax_6);
 a1.c.f = der(y1);
 a2.c.f = der(y2);
 a3.c.f = der(y3);
 der(y1) + der(y2) + der(y3) = 0.0;
 der(y1) = time * time;
 a1.c.s = 2 * time;
 der(y2) = 2 * time * time;
 a2.c.s = 3 * time;
 a3.c.s = 2 * a1.c.s;
 _stream_s_1 = max(- der(y2), 0) + max(- der(y3), 0);
 _stream_alpha_1 = smooth(1, if _stream_s_1 > _inStreamEpsilon then 1 elseif _stream_s_1 > 0 then _stream_s_1 / _inStreamEpsilon * (_stream_s_1 / _inStreamEpsilon * (3 - 2 * _stream_s_1)) else 0);
 _stream_positiveMax_1 = _stream_alpha_1 * max(- der(y2), 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_positiveMax_2 = _stream_alpha_1 * max(- der(y3), 0) + (1 - _stream_alpha_1) * _inStreamEpsilon;
 _stream_s_2 = max(- der(y1), 0) + max(- der(y3), 0);
 _stream_alpha_2 = smooth(1, if _stream_s_2 > _inStreamEpsilon then 1 elseif _stream_s_2 > 0 then _stream_s_2 / _inStreamEpsilon * (_stream_s_2 / _inStreamEpsilon * (3 - 2 * _stream_s_2)) else 0);
 _stream_positiveMax_3 = _stream_alpha_2 * max(- der(y1), 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_positiveMax_4 = _stream_alpha_2 * max(- der(y3), 0) + (1 - _stream_alpha_2) * _inStreamEpsilon;
 _stream_s_3 = max(- der(y1), 0) + max(- der(y2), 0);
 _stream_alpha_3 = smooth(1, if _stream_s_3 > _inStreamEpsilon then 1 elseif _stream_s_3 > 0 then _stream_s_3 / _inStreamEpsilon * (_stream_s_3 / _inStreamEpsilon * (3 - 2 * _stream_s_3)) else 0);
 _stream_positiveMax_5 = _stream_alpha_3 * max(- der(y1), 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
 _stream_positiveMax_6 = _stream_alpha_3 * max(- der(y2), 0) + (1 - _stream_alpha_3) * _inStreamEpsilon;
end StreamTests.StreamDerAlias1;
")})));
end StreamDerAlias1;


model StreamSemiLinear1
    model A
        StreamConnector c1;
        StreamConnector c2;
    end A;
    
    A a(c1(s = time, p = 1, f = 2 - time), c2(s = 2 * time));
    Real x = semiLinear(a.c1.f, actualStream(a.c1.s), a.c1.s);
equation
    connect(a.c1, a.c2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="StreamSemiLinear1",
            description="",
            eliminate_alias_variables=false,
            eliminate_linear_equations=false,
            flatModel="
fclass StreamTests.StreamSemiLinear1
 constant Real a.c1.p = 1;
 Real a.c1.f;
 Real a.c1.s;
 constant Real a.c2.p = 1.0;
 Real a.c2.f;
 Real a.c2.s;
 Real x;
equation
 a.c1.f + a.c2.f = 0.0;
 a.c1.f = 2 - time;
 a.c1.s = time;
 a.c2.s = 2 * time;
 x = noEvent(if a.c1.f >= 0 then a.c1.f * smooth(0, if a.c1.f > 0.0 then a.c2.s else a.c1.s) else a.c1.f * a.c1.s);
end StreamTests.StreamSemiLinear1;
")})));
end StreamSemiLinear1;



// TODO: Add error tests (e.g. stream connector without flow)

end StreamTests;
