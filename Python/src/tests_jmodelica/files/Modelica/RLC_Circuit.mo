within ;
block Square "Generate a square-wave"
  parameter Real amplitude=1 "Amplitude of the square-wave";
  parameter Modelica.SIunits.Frequency freqHz(start=0.6)
    "Frequency of the square-wave";
  parameter Modelica.SIunits.Angle phase=0 "Phase of the square-wave";
  parameter Real offset=0 "Offset of output signal";
  extends Modelica.Blocks.Interfaces.SO;
protected
  constant Real pi=Modelica.Constants.pi;
equation
  y = offset + (if Modelica.Math.sin(2*pi*freqHz*time + phase) > 0.0 then amplitude else -1.0*amplitude);

  annotation (
    Icon(coordinateSystem(
    preserveAspectRatio=true,
    extent={{-100,-100},{100,100}},
    grid={1,1}), graphics={
        Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
        Polygon(
          points={{-80,90},{-88,68},{-72,68},{-80,90}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-90,0},{68,0}}, color={192,192,192}),
        Polygon(
          points={{90,0},{68,8},{68,-8},{90,0}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-80,0},{-80,34},{-80,53},{-80,79},{-53,79},{-44,79},{-37,
              79},{-25,79},{-4,79},{-4,61},{-4,45},{-4,22},{-4,-31},{-4,-54},{-4,
              -68},{-4,-80},{23,-80},{40.6,-80},{63,-80},{80,-80},{80,-66},{80,
              -51},{80,-29},{80,0}}, color={0,0,0}),
        Text(
          extent={{-147,-152},{153,-112}},
          lineColor={0,0,0},
          textString="freqHz=%freqHz")}),
    Diagram(coordinateSystem(
    preserveAspectRatio=true,
    extent={{-100,-100},{100,100}},
    grid={1,1}), graphics={
        Line(points={{-80,-90},{-80,84}}, color={95,95,95}),
        Polygon(
          points={{-80,97},{-84,81},{-76,81},{-80,97}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Line(points={{-99,-40},{85,-40}}, color={95,95,95}),
        Polygon(
          points={{97,-40},{81,-36},{81,-45},{97,-40}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-80,-80},{-41,-80},{-41,35},{-41,54},{-41,80},{-17,80},{-12,
              80},{-3,80},{4,80},{20,80},{20,60},{20,46},{20,21},{20,-30},{20,-52},
              {20,-70},{20,-80},{46,-80},{50.5,-80},{62,-80},{80,-80},{80,-70},
              {80,-52},{80,-27},{80,0}},
          color={0,0,255},
          thickness=0.5),
        Text(
          extent={{-39,-15},{8,-27}},
          lineColor={0,0,0},
          textString="offset"),
        Line(points={{-41,-2},{-41,-40}}, color={95,95,95}),
        Text(
          extent={{75,-47},{100,-60}},
          lineColor={0,0,0},
          textString="time"),
        Text(
          extent={{-80,99},{-40,82}},
          lineColor={0,0,0},
          textString="y"),
        Line(points={{-9,79},{43,79}}, color={95,95,95}),
        Line(points={{-80,-2},{50,-2}}, color={95,95,95}),
        Polygon(
          points={{33,79},{30,66},{37,66},{33,79}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{37,57},{83,39}},
          lineColor={0,0,0},
          textString="amplitude"),
        Polygon(
          points={{33,-2},{30,11},{36,11},{33,-2},{33,-2}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Line(points={{33,77},{33,-2}}, color={95,95,95}),
        Line(points={{-29,-8},{-29,-35}}, color={95,95,95}),
        Polygon(
          points={{-29,-39},{-32,-26},{-26,-26},{-29,-39},{-29,-39}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-29,-3},{-32,-16},{-25,-16},{-29,-3}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid)}),
Documentation(info="<html>
<p>
The Real output y is a square-wave:
</p>

<p>
<img src=\"../Images/Blocks/Sources/Sine.png\">
</p>
</html>"),
    uses(Modelica(version="3.1")));
end Square;


model RLC_Circuit_Square

  Modelica.Electrical.Analog.Basic.Ground ground 
    annotation (Placement(transformation(extent={{-54,-48},{-34,-28}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor(R=1) 
    annotation (Placement(transformation(extent={{-4,36},{16,56}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(C=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={44,28})));
  Modelica.Electrical.Analog.Basic.Inductor inductor(L=1) 
    annotation (Placement(transformation(extent={{0,-40},{20,-20}})));
  Modelica.Electrical.Analog.Basic.Inductor inductor1(L=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={78,16})));
  Modelica.Electrical.Analog.Basic.Resistor resistor1(R=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,16})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-58,18})));
  Square square(freqHz=0.6) 
    annotation (Placement(transformation(extent={{-96,8},{-76,28}})));
equation
  connect(resistor.n, capacitor.n) annotation (Line(
      points={{16,46},{44,46},{44,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(capacitor.p, inductor.n) annotation (Line(
      points={{44,18},{44,-30},{20,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor1.n, capacitor.n) annotation (Line(
      points={{78,26},{78,38},{44,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor1.p, inductor.n) annotation (Line(
      points={{78,6},{78,-30},{20,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor1.n, resistor.p) annotation (Line(
      points={{-22,26},{-14,26},{-14,46},{-4,46}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor1.p, inductor.p) annotation (Line(
      points={{-22,6},{-12,6},{-12,-30},{0,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor.p, ground.p) annotation (Line(
      points={{0,-30},{-22,-30},{-22,-28},{-44,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.n, resistor.p) annotation (Line(
      points={{-58,28},{-58,46},{-4,46}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.p, ground.p) annotation (Line(
      points={{-58,8},{-58,-28},{-44,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(square.y, signalVoltage.v) annotation (Line(
      points={{-75,18},{-65,18}},
      color={0,0,127},
      smooth=Smooth.None));
end RLC_Circuit_Square;

model RLC_Circuit

          block Sine "Generate sine signal"
            parameter Real amplitude=1 "Amplitude of sine wave";
            parameter Modelica.SIunits.Frequency freqHz(start=1) = 1
      "Frequency of sine wave";
            parameter Modelica.SIunits.Angle phase=0 "Phase of sine wave";
            parameter Real offset=0 "Offset of output signal";
            parameter Modelica.SIunits.Time startTime=0
      "Output = offset for time < startTime";
            extends Modelica.Blocks.Interfaces.SO;
    protected
            constant Real pi=Modelica.Constants.pi;
    equation
            y = offset + amplitude*Modelica.Math.sin(2*pi*freqHz*(time - startTime) + phase);

    annotation (
      Icon(coordinateSystem(
          preserveAspectRatio=true,
          extent={{-100,-100},{100,100}},
          grid={1,1}), graphics={
          Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
          Polygon(
            points={{-80,90},{-88,68},{-72,68},{-80,90}},
            lineColor={192,192,192},
            fillColor={192,192,192},
            fillPattern=FillPattern.Solid),
          Line(points={{-90,0},{68,0}}, color={192,192,192}),
          Polygon(
            points={{90,0},{68,8},{68,-8},{90,0}},
            lineColor={192,192,192},
            fillColor={192,192,192},
            fillPattern=FillPattern.Solid),
          Line(points={{-80,0},{-68.7,34.2},{-61.5,53.1},{-55.1,66.4},{-49.4,
                74.6},{-43.8,79.1},{-38.2,79.8},{-32.6,76.6},{-26.9,69.7},{-21.3,
                59.4},{-14.9,44.1},{-6.83,21.2},{10.1,-30.8},{17.3,-50.2},{23.7,
                -64.2},{29.3,-73.1},{35,-78.4},{40.6,-80},{46.2,-77.6},{51.9,-71.5},
                {57.5,-61.9},{63.9,-47.2},{72,-24.8},{80,0}}, color={0,0,0}),
          Text(
            extent={{-147,-152},{153,-112}},
            lineColor={0,0,0},
            textString="freqHz=%freqHz")}),
      Diagram(coordinateSystem(
          preserveAspectRatio=true,
          extent={{-100,-100},{100,100}},
          grid={1,1}), graphics={
          Line(points={{-80,-90},{-80,84}}, color={95,95,95}),
          Polygon(
            points={{-80,97},{-84,81},{-76,81},{-80,97}},
            lineColor={95,95,95},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid),
          Line(points={{-99,-40},{85,-40}}, color={95,95,95}),
          Polygon(
            points={{97,-40},{81,-36},{81,-45},{97,-40}},
            lineColor={95,95,95},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid),
          Line(
            points={{-41,-2},{-31.6,34.2},{-26.1,53.1},{-21.3,66.4},{-17.1,74.6},
                {-12.9,79.1},{-8.64,79.8},{-4.42,76.6},{-0.201,69.7},{4.02,59.4},
                {8.84,44.1},{14.9,21.2},{27.5,-30.8},{33,-50.2},{37.8,-64.2},{
                42,-73.1},{46.2,-78.4},{50.5,-80},{54.7,-77.6},{58.9,-71.5},{
                63.1,-61.9},{67.9,-47.2},{74,-24.8},{80,0}},
            color={0,0,255},
            thickness=0.5),
          Line(
            points={{-41,-2},{-80,-2}},
            color={0,0,255},
            thickness=0.5),
          Text(
            extent={{-87,12},{-40,0}},
            lineColor={0,0,0},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid,
            textString="offset"),
          Line(points={{-41,-2},{-41,-40}}, color={95,95,95}),
          Text(
            extent={{-60,-43},{-14,-54}},
            lineColor={0,0,0},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid,
            textString="startTime"),
          Text(
            extent={{75,-47},{100,-60}},
            lineColor={0,0,0},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid,
            textString="time"),
          Text(
            extent={{-80,99},{-40,82}},
            lineColor={0,0,0},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid,
            textString="y"),
          Line(points={{-9,79},{43,79}}, color={95,95,95}),
          Line(points={{-41,-2},{50,-2}}, color={95,95,95}),
          Polygon(
            points={{33,79},{30,66},{37,66},{33,79}},
            lineColor={95,95,95},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid),
          Text(
            extent={{37,57},{83,39}},
            lineColor={0,0,0},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid,
            textString="amplitude"),
          Polygon(
            points={{33,-2},{30,11},{36,11},{33,-2},{33,-2}},
            lineColor={95,95,95},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid),
          Line(points={{33,77},{33,-2}}, color={95,95,95})}),
      Documentation(info=
                   "<html>
<p>
The Real output y is a sine signal:
</p>
 
<p>
<img src=\"../Images/Blocks/Sources/Sine.png\">
</p>
</html>"));
          end Sine;

  Modelica.Electrical.Analog.Basic.Ground ground 
    annotation (Placement(transformation(extent={{-54,-48},{-34,-28}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor(R=1) 
    annotation (Placement(transformation(extent={{-4,36},{16,56}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(C=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={44,28})));
  Modelica.Electrical.Analog.Basic.Inductor inductor(L=1) 
    annotation (Placement(transformation(extent={{0,-40},{20,-20}})));
  Modelica.Electrical.Analog.Basic.Inductor inductor1(L=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={78,16})));
  Modelica.Electrical.Analog.Basic.Resistor resistor1(R=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,16})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-58,18})));
  Sine sine(freqHz=1)
    annotation (Placement(transformation(extent={{-96,8},{-76,28}})));
equation
  connect(resistor.n, capacitor.n) annotation (Line(
      points={{16,46},{44,46},{44,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(capacitor.p, inductor.n) annotation (Line(
      points={{44,18},{44,-30},{20,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor1.n, capacitor.n) annotation (Line(
      points={{78,26},{78,38},{44,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor1.p, inductor.n) annotation (Line(
      points={{78,6},{78,-30},{20,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor1.n, resistor.p) annotation (Line(
      points={{-22,26},{-14,26},{-14,46},{-4,46}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor1.p, inductor.p) annotation (Line(
      points={{-22,6},{-12,6},{-12,-30},{-5.55112e-16,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor.p, ground.p) annotation (Line(
      points={{-5.55112e-16,-30},{-22,-30},{-22,-28},{-44,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.n, resistor.p) annotation (Line(
      points={{-58,28},{-58,46},{-4,46}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.p, ground.p) annotation (Line(
      points={{-58,8},{-58,-28},{-44,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(sine.y, signalVoltage.v) annotation (Line(
      points={{-75,18},{-65,18}},
      color={0,0,127},
      smooth=Smooth.None));
end RLC_Circuit;


model RLC_Circuit_Input

  Modelica.Electrical.Analog.Basic.Ground ground 
    annotation (Placement(transformation(extent={{-54,-48},{-34,-28}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor(R=1) 
    annotation (Placement(transformation(extent={{-4,36},{16,56}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(C=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={44,28})));
  Modelica.Electrical.Analog.Basic.Inductor inductor(L=1) 
    annotation (Placement(transformation(extent={{0,-40},{20,-20}})));
  Modelica.Electrical.Analog.Basic.Inductor inductor1(L=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={78,16})));
  Modelica.Electrical.Analog.Basic.Resistor resistor1(R=1) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,16})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-58,18})));
  Modelica.Blocks.Interfaces.RealInput u;
equation
  connect(resistor.n, capacitor.n) annotation (Line(
      points={{16,46},{44,46},{44,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(capacitor.p, inductor.n) annotation (Line(
      points={{44,18},{44,-30},{20,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor1.n, capacitor.n) annotation (Line(
      points={{78,26},{78,38},{44,38}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor1.p, inductor.n) annotation (Line(
      points={{78,6},{78,-30},{20,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor1.n, resistor.p) annotation (Line(
      points={{-22,26},{-14,26},{-14,46},{-4,46}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor1.p, inductor.p) annotation (Line(
      points={{-22,6},{-12,6},{-12,-30},{-5.55112e-16,-30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor.p, ground.p) annotation (Line(
      points={{-5.55112e-16,-30},{-22,-30},{-22,-28},{-44,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.n, resistor.p) annotation (Line(
      points={{-58,28},{-58,46},{-4,46}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalVoltage.p, ground.p) annotation (Line(
      points={{-58,8},{-58,-28},{-44,-28}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(u, signalVoltage.v) annotation (Line(
      points={{-75,18},{-65,18}},
      color={0,0,127},
      smooth=Smooth.None));
end RLC_Circuit_Input;

model RLC_Circuit_Linearized
  Real x[3];
  Real u;
  RLC_Circuit.Sine sine(freqHz=1);
  parameter Real A[3,3] = {{0,1,-1},{-1,-1,0},{1,0,0}};
  parameter Real B[3] = {0,1,0};  
equation
  der(x) = A*x + B*u;
  u=sine.y;
end RLC_Circuit_Linearized;
