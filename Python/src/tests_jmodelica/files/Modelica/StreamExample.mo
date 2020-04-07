within ;
package StreamExample
 import SI = Modelica.SIunits;

 package Examples

   package Interfaces
     connector FlowPort
       flow SI.MassFlowRate m_flow;
       SI.Pressure p(nominal=100000,start=100000);
       stream SI.SpecificEnthalpy h_outflow(nominal=400000, start=400000);
       annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
                 -100},{100,100}}), graphics={Ellipse(
               extent={{-100,100},{100,-100}},
               lineColor={0,0,255},
               fillColor={0,0,127},
               fillPattern=FillPattern.Solid)}));
     end FlowPort;

   end Interfaces;

   package Components
     model MultiPortVolume

       parameter Integer nP=2 "Number of flow ports";
       parameter SI.Volume V;
       parameter SI.Temperature T_start;
       parameter SI.Pressure p_start;
       parameter SI.SpecificHeatCapacity cp;
       parameter SI.SpecificHeatCapacity R;
       Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort(T(start=T_start)) 
         annotation (Placement(transformation(extent={{-100,-10},{-80,10}}),
             iconTransformation(extent={{-100,-10},{-80,10}})));
       Interfaces.FlowPort[nP] flowPort 
         annotation (Placement(transformation(extent={{-22,-20},{18,20}}),
             iconTransformation(extent={{-22,-20},{18,20}})));
       SI.EnthalpyFlowRate[nP] H_flow(each nominal=400000, each start=400000)
          "Enthalpy flow rates";
       SI.MassFlowRate dM "Mass storage";
       SI.EnergyFlowRate dU(nominal=100000, start=100000)
          "Internal energy storage";
       Real du(nominal=100000, start=100000);
       SI.Mass M;
       SI.Temperature T(start=T_start, nominal = 300) "Temperature";
       SI.Pressure p(start = p_start, nominal= 1e5);
       SI.SpecificEnthalpy h(nominal= 400000, start=300000);
       SI.SpecificInternalEnergy u(nominal=250000, start=250000);
       SI.Density rho(nominal=1.0);
       SI.InternalEnergy U(nominal=250000, start=250000);

     equation
        //Energy balance
       dU=sum(H_flow) + heatPort.Q_flow;
       //Mass balance
       dM=sum(flowPort.m_flow);
       dM=(-p/R/T/T*der(T)+1/R/T*der(p))*V;
       M=rho*V;

       U=u*M;
        dU=dM*u+du*M;
       du=(cp-R)*der(T);
       u=h-R*T;
       h=cp*T;
       p=rho*R*T;

       for i in 1:nP loop
       H_flow[i]=flowPort[i].m_flow*actualStream(flowPort[i].h_outflow);
       //Port properties
       flowPort[i].p=p;
       flowPort[i].h_outflow=h;
       end for;

       //Heat transfer
       heatPort.T=T;
     initial equation
         p=p_start;
         T=T_start;
       annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}), graphics={Ellipse(
               extent={{-80,80},{80,-80}},
               lineColor={170,213,255},
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
               preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
             graphics));
     end MultiPortVolume;

     model FlowSource
          parameter SI.MassFlowRate mflow0;
         parameter SI.Temperature T0;
         parameter SI.SpecificHeatCapacity cp;
          SI.SpecificEnthalpy h(nominal= 400000);
       Interfaces.FlowPort flowPort 
         annotation (Placement(transformation(extent={{60,-20},{100,20}}),
             iconTransformation(extent={{60,-20},{100,20}})));

     equation
       h=cp*T0;
       flowPort.m_flow=-mflow0;
       flowPort.h_outflow=h;
       annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}), graphics={Rectangle(
               extent={{-80,80},{80,-80}},
               lineColor={170,213,255},
               fillColor={170,213,255},
               fillPattern=FillPattern.Solid), Polygon(
               points={{-36,48},{-36,-50},{48,2},{-36,48}},
               lineColor={85,170,255},
               smooth=Smooth.None,
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
               preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
             graphics));
     end FlowSource;

     model Reservoir
         parameter SI.Pressure p0;
         parameter SI.Temperature T0;
         parameter SI.SpecificHeatCapacity cp;
      parameter SI.SpecificEnthalpy h0=cp*T0;
       Interfaces.FlowPort flowPort 
         annotation (Placement(transformation(extent={{60,-20},{100,20}}),
             iconTransformation(extent={{60,-20},{100,20}})));

     equation
       flowPort.p=p0;
       flowPort.h_outflow=h0;
       annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}), graphics={Rectangle(
               extent={{-80,80},{80,-80}},
               lineColor={170,213,255},
               fillColor={170,213,255},
               fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
               preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
             graphics));
     end Reservoir;

     model LinearResistance
        Interfaces.FlowPort port_a 
         annotation (Placement(transformation(extent={{-100,-20},{-60,20}})));
       Interfaces.FlowPort port_b 
         annotation (Placement(transformation(extent={{60,-20},{100,20}})));

       Modelica.Blocks.Interfaces.RealInput u(start=1) annotation (Placement(transformation(
               extent={{-22,44},{18,84}}), iconTransformation(
             extent={{20,-20},{-20,20}},
             rotation=90,
             origin={0,20})));
     equation
       port_a.m_flow=(port_a.p-port_b.p)/u;
       port_a.m_flow+port_b.m_flow=0;
       port_a.h_outflow=inStream(port_b.h_outflow);
       port_b.h_outflow=inStream(port_a.h_outflow);

       annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}),
                              graphics), Icon(coordinateSystem(preserveAspectRatio=true,
               extent={{-100,-100},{100,100}}), graphics={Polygon(
               points={{-80,60},{-80,-60},{0,0},{80,-60},{80,60},{0,0},{-80,60}},
               lineColor={85,170,255},
               smooth=Smooth.None,
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}));
     end LinearResistance;

     model LinearResistanceWrap
        Interfaces.FlowPort port_a 
         annotation (Placement(transformation(extent={{-100,-20},{-60,20}})));
       Interfaces.FlowPort port_b 
         annotation (Placement(transformation(extent={{60,-20},{100,20}})));
       Modelica.Blocks.Interfaces.RealInput u annotation (Placement(transformation(
               extent={{-20,44},{20,84}}), iconTransformation(
             extent={{20,-20},{-20,20}},
             rotation=90,
             origin={0,20})));
       LinearResistance linearResistance 
         annotation (Placement(transformation(extent={{-2,-10},{18,10}})));
     equation
       connect(linearResistance.port_b, port_b) annotation (Line(
           points={{16,0},{80,0}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.port_a, port_a) annotation (Line(
           points={{0,0},{-80,0}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.u, u) annotation (Line(
           points={{8,2},{8,64},{0,64}},
           color={0,0,127},
           smooth=Smooth.None));
       annotation (Icon(graphics={                        Polygon(
               points={{-80,60},{-80,-60},{0,0},{80,-60},{80,60},{0,0},{-80,60}},
               lineColor={85,170,255},
               smooth=Smooth.None,
               fillColor={85,170,255},
               fillPattern=FillPattern.Solid)}), Diagram(graphics));
     end LinearResistanceWrap;
   end Components;

   package Systems
     model HeatedGas
       parameter SI.SpecificHeatCapacity R_gas=Modelica.Constants.R/0.0289651159;
       parameter SI.SpecificHeatCapacity cp=1000;
       StreamExample.Examples.Components.FlowSource flowSource(
          mflow0=1,
         cp=cp,
         T0=303.15) 
         annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
       StreamExample.Examples.Components.MultiPortVolume multiPortVolume(
         V=1,
         nP=2,
         cp=cp,
         R=R_gas,
          T_start=303.15,
          p_start=100000) 
         annotation (Placement(transformation(extent={{0,0},{-20,20}})));
       Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow heatSource(Q_flow=
             100000, T_ref=373.15) 
         annotation (Placement(transformation(extent={{42,-2},{22,18}})));
       Components.LinearResistance linearResistance annotation (Placement(
             transformation(
             extent={{10,-10},{-10,10}},
             rotation=-90,
             origin={-6,36})));
       Components.Reservoir reservoir(
         p0=100000,
         T0=303.15,
         cp=cp) 
          annotation (Placement(transformation(extent={{-50,44},{-30,64}})));
       Modelica.Blocks.Sources.Ramp ramp(
         offset=1e4,
         duration=1,
         startTime=5,
         height=1e4) 
         annotation (Placement(transformation(extent={{36,34},{16,54}})));

     equation
       connect(multiPortVolume.heatPort, heatSource.port) annotation (Line(
           points={{-1,10},{10,10},{10,8},{22,8}},
           color={191,0,0},
           smooth=Smooth.None));
       connect(flowSource.flowPort, multiPortVolume.flowPort[1]) annotation (
           Line(
           points={{-42,10},{-25.9,10},{-25.9,9},{-9.8,9}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(reservoir.flowPort, linearResistance.port_b) annotation (Line(
           points={{-32,54},{-14,54},{-14,56},{-6,56},{-6,44}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.port_a, multiPortVolume.flowPort[2]) 
         annotation (Line(
           points={{-6,28},{-8,28},{-8,11},{-9.8,11}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.u, ramp.y) annotation (Line(
           points={{-4,36},{6,36},{6,44},{15,44}},
           color={0,0,127},
           smooth=Smooth.None));
       annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                  -100},{100,100}}),     graphics));
     end HeatedGas;

     model HeatedGas_Simple
       parameter SI.SpecificHeatCapacity R_gas=Modelica.Constants.R/0.0289651159;
       parameter SI.SpecificHeatCapacity cp=1000;
       StreamExample.Examples.Components.FlowSource flowSource(
          mflow0=1,
         cp=cp,
         T0=303.15,flowPort(p(start=1e5))) 
         annotation (Placement(transformation(extent={{-42,0},{-22,20}})));
       Components.LinearResistance linearResistance(u(start=1)) annotation (Placement(
             transformation(
             extent={{10,-10},{-10,10}},
             rotation=-90,
             origin={-6,36})));
       Components.Reservoir reservoir(
         p0=100000,
         T0=303.15,
         cp=cp) 
          annotation (Placement(transformation(extent={{-50,44},{-30,64}})));
       Modelica.Blocks.Sources.Ramp ramp(
         offset=1e4,
         duration=1,
         startTime=5,
         height=1e4) 
         annotation (Placement(transformation(extent={{36,34},{16,54}})));

     equation
       connect(reservoir.flowPort, linearResistance.port_b) annotation (Line(
           points={{-32,54},{-14,54},{-14,56},{-6,56},{-6,44}},
           color={0,0,255},
           smooth=Smooth.None));
       connect(linearResistance.u, ramp.y) annotation (Line(
           points={{-4,36},{6,36},{6,44},{15,44}},
           color={0,0,127},
           smooth=Smooth.None));
       connect(flowSource.flowPort, linearResistance.port_a) annotation (Line(
           points={{-24,10},{-6,10},{-6,28}},
           color={0,0,255},
           smooth=Smooth.None));
       annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                 -100},{100,100}}),      graphics));
     end HeatedGas_Simple;

     model HeatedGas_SimpleWrap
       parameter SI.SpecificHeatCapacity R_gas=Modelica.Constants.R/0.0289651159;
       parameter SI.SpecificHeatCapacity cp=1000;
       StreamExample.Examples.Components.FlowSource flowSource(
          mflow0=1,
         cp=cp,
         T0=303.15) 
         annotation (Placement(transformation(extent={{-50,0},{-30,20}})));
       Components.Reservoir reservoir(
         p0=100000,
         T0=303.15,
         cp=cp) 
          annotation (Placement(transformation(extent={{-50,44},{-30,64}})));
       Modelica.Blocks.Sources.Ramp ramp(
         offset=1e4,
         duration=1,
         startTime=5,
         height=1e4) 
         annotation (Placement(transformation(extent={{36,34},{16,54}})));

       Components.LinearResistanceWrap linearResistanceWrap annotation (
           Placement(transformation(
             extent={{10,-10},{-10,10}},
             rotation=270,
             origin={-6,32})));
     equation
       connect(linearResistanceWrap.u, ramp.y) annotation (Line(
           points={{-4,32},{6,32},{6,44},{15,44}},
           color={0,0,127},
           smooth=Smooth.None));
        connect(reservoir.flowPort, linearResistanceWrap.port_b) annotation (
            Line(
            points={{-32,54},{-6,54},{-6,40}},
            color={0,0,255},
            smooth=Smooth.None));
        connect(flowSource.flowPort, linearResistanceWrap.port_a) annotation (
            Line(
            points={{-32,10},{-6,10},{-6,24}},
            color={0,0,255},
            smooth=Smooth.None));
     end HeatedGas_SimpleWrap;
   end Systems;
 end Examples;

 annotation (uses(Modelica(version="3.1")));
end StreamExample;
