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


model LibraryTests 

   

   model MathFuncTest1 
      parameter Real p = Modelica.Constants.pi;   
   end MathFuncTest1;

   model MathFuncTest2
      // Lookup of constants in packages currently does not work.
      import Modelica.Math;
      parameter Real p = Math.sin(3);
   end MathFuncTest2;

   model ConstantLookupTest1
      // Lookup of constants in packages currently does not work.
      import Modelica.Constants.*;
      parameter Real p = pi;
   end ConstantLookupTest2;


   model LibraryTest1
     Modelica.Electrical.Analog.Basic.Capacitor c;
     equation
   end LibraryTest1;  

  model LibraryTest2
    Modelica.Blocks.Interfaces.RealInput u;
  end LibraryTest2;

model LibraryTest3
  annotation (uses(Modelica(version="3.0")), Diagram(coordinateSystem(
          preserveAspectRatio=true, extent={{-100,-100},{100,100}}), graphics));
  Modelica.Electrical.Analog.Basic.Resistor resistor
    annotation (Placement(transformation(extent={{-46,28},{-26,48}})));
  Modelica.Electrical.Analog.Basic.Inductor inductor annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-8,14})));
  Modelica.Electrical.Analog.Basic.Ground ground
    annotation (Placement(transformation(extent={{-44,-56},{-24,-36}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-8,-18})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-58,-2})));
  Modelica.Blocks.Sources.Sine sine
    annotation (Placement(transformation(extent={{-102,-12},{-82,8}})));
equation 
  connect(resistor.n, inductor.p) annotation (Line(
      points={{-26,38},{-8,38},{-8,24}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(capacitor.p, inductor.n) annotation (Line(
      points={{-8,-8},{-8,-4.5},{-8,-4.5},{-8,-1},{-8,4},{-8,4}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(ground.p, capacitor.n) annotation (Line(
      points={{-34,-36},{-8,-36},{-8,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.n, resistor.p) annotation (Line(
      points={{-58,8},{-58,38},{-46,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.p, ground.p) annotation (Line(
      points={{-58,-12},{-58,-36},{-34,-36}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(sine.y, signalVoltage.v) annotation (Line(
      points={{-81,-2},{-73,-2},{-73,-2},{-65,-2}},
      color={0,0,127},
      smooth=Smooth.None));
end LibraryTest3;

model LibraryTest4
  Modelica.Blocks.Interfaces.RealInput in_port;
  Modelica.Blocks.Interfaces.RealOutput out_port;
equation
connect(in_port,out_port);
end LibraryTest4;

end LibraryTests;