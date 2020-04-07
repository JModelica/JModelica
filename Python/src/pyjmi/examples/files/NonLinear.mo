within ;
package NonLinear

  model CauerLowPassAnalogLinear "Cauer low pass filter with analog components"
    extends Modelica.Icons.Example;

    parameter Modelica.SIunits.Inductance l1=1.304 "filter coefficient I1";
    parameter Modelica.SIunits.Inductance l2=0.8586 "filter coefficient I2";
    parameter Modelica.SIunits.Capacitance c1=1.072 "filter coefficient c1";
    parameter Modelica.SIunits.Capacitance c2=1/(1.704992^2*l1)
      "filter coefficient c2";
    parameter Modelica.SIunits.Capacitance c3=1.682 "filter coefficient c3";
    parameter Modelica.SIunits.Capacitance c4=1/(1.179945^2*l2)
      "filter coefficient c4";
    parameter Modelica.SIunits.Capacitance c5=0.7262 "filter coefficient c5";
    Modelica.Electrical.Analog.Basic.Ground G
      annotation (Placement(transformation(extent={{-10,-90},{10,-70}}, rotation=
              0)));
    Modelica.Electrical.Analog.Basic.Capacitor C1(C=c1)
      annotation (Placement(transformation(
          origin={-60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C2(C=c2)
      annotation (Placement(transformation(extent={{-40,20},{-20,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C3(C=c3)
      annotation (Placement(transformation(
          origin={0,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C4(C=c4)
      annotation (Placement(transformation(extent={{20,20},{40,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C5(C=c5)
      annotation (Placement(transformation(
          origin={60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Inductor L1(L=l1)
      annotation (Placement(transformation(extent={{-40,60},{-20,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Inductor L2(L=l2)
      annotation (Placement(transformation(extent={{20,60},{40,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Resistor R1
      annotation (Placement(transformation(extent={{-100,20},{-80,40}}, rotation=
              0)));
    Modelica.Electrical.Analog.Basic.Resistor R2
      annotation (Placement(transformation(
          origin={100,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Sources.StepVoltage V(startTime=1, offset=0)
      annotation (Placement(transformation(
          origin={-100,-10},
          extent={{-10,-10},{10,10}},
          rotation=270)));
  equation
    connect(R1.n,C1. p) annotation (Line(points={{-80,30},{-60,30},{-60,-10}},
          color={0,0,255}));
    connect(C1.n,G. p) annotation (Line(points={{-60,-30},{-60,-50},{0,-50},{0,-70}},
                   color={0,0,255}));
    connect(R1.n,C2. p)
      annotation (Line(points={{-80,30},{-40,30}}, color={0,0,255}));
    connect(L1.p,C2. p)
      annotation (Line(points={{-40,70},{-40,30}}, color={0,0,255}));
    connect(L1.p,C1. p) annotation (Line(points={{-40,70},{-40,30},{-60,30},{-60,
            -10}}, color={0,0,255}));
    connect(L1.n,C2. n)
      annotation (Line(points={{-20,70},{-20,30}}, color={0,0,255}));
    connect(C2.n,C3. p) annotation (Line(points={{-20,30},{1.83697e-015,30},{
            1.83697e-015,-10}}, color={0,0,255}));
    connect(C2.n,C4. p)
      annotation (Line(points={{-20,30},{20,30}}, color={0,0,255}));
    connect(L1.n,C3. p) annotation (Line(points={{-20,70},{-20,30},{
            1.83697e-015,30},{1.83697e-015,-10}},
                                     color={0,0,255}));
    connect(L1.n,C4. p) annotation (Line(points={{-20,70},{-20,30},{20,30}},
          color={0,0,255}));
    connect(L2.p,C4. p)
      annotation (Line(points={{20,70},{20,30}}, color={0,0,255}));
    connect(C2.n,L2. p) annotation (Line(points={{-20,30},{20,30},{20,70}}, color=
           {0,0,255}));
    connect(C3.p,L2. p) annotation (Line(points={{1.83697e-015,-10},{0,-10},{0,
            30},{20,30},{20,70}},
                              color={0,0,255}));
    connect(L2.n,C4. n)
      annotation (Line(points={{40,70},{40,30}}, color={0,0,255}));
    connect(L2.n,C5. p) annotation (Line(points={{40,70},{40,30},{60,30},{60,-10}},
          color={0,0,255}));
    connect(L2.n,R2. p) annotation (Line(points={{40,70},{40,30},{100,30},{100,
            -10}}, color={0,0,255}));
    connect(R2.n,G. p) annotation (Line(points={{100,-30},{100,-50},{0,-50},{0,-70}},
                   color={0,0,255}));
    connect(C4.n,C5. p) annotation (Line(points={{40,30},{60,30},{60,-10}}, color=
           {0,0,255}));
    connect(C4.n,R2. p) annotation (Line(points={{40,30},{100,30},{100,-10}},
          color={0,0,255}));
    connect(C3.n,G. p) annotation (Line(points={{-1.83697e-015,-30},{0,-30},{0,
            -70}}, color={0,0,255}));
    connect(C5.n,G. p) annotation (Line(points={{60,-30},{60,-50},{0,-50},{0,-70}},
          color={0,0,255}));
    connect(C1.n,C3. n) annotation (Line(points={{-60,-30},{-60,-50},{0,-50},{0,
            -30},{-1.83697e-015,-30}}, color={0,0,255}));
    connect(C1.n,C5. n) annotation (Line(points={{-60,-30},{-60,-50},{60,-50},{60,
            -30}}, color={0,0,255}));
    connect(R2.n,C5. n) annotation (Line(points={{100,-30},{100,-50},{60,-50},{60,
            -30}}, color={0,0,255}));
    connect(R2.n,C3. n) annotation (Line(points={{100,-30},{100,-50},{0,-50},{0,
            -30},{-1.83697e-015,-30}}, color={0,0,255}));
    connect(R2.n,C1. n) annotation (Line(points={{100,-30},{100,-50},{-60,-50},{
            -60,-30}}, color={0,0,255}));
    connect(C5.p,R2. p) annotation (Line(
        points={{60,-10},{60,30},{100,30},{100,-10}},
        color={0,0,255}));
    connect(R1.p, V.p)
      annotation (Line(points={{-100,30},{-100,0}}, color={0,0,255}));
    connect(V.n, G.p)            annotation (Line(points={{-100,-20},{-100,-70},{0,
            -70}},   color={0,0,255}));
    annotation (Diagram(coordinateSystem(
            preserveAspectRatio=true, extent={{-200,-100},{200,100}}), graphics={
          Rectangle(
            extent={{-62,32},{-58,28}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-2,28},{2,32}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{58,32},{62,28}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{58,-48},{62,-52}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-2,-48},{2,-52}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-62,-48},{-58,-52}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Text(
            extent={{-110,116},{100,64}},
            textString="CauerLowPassAnalog",
            lineColor={0,0,255})}),
      experiment(StopTime=60),
      Documentation(revisions="<html>
<ul>
<li><i>January 13, 2006</i>
       by Christoph Clauss<br>
       included into Modelica Standard Library</li>
<li><i>September 15, 2005</i>
       by Peter Trappe designed and by Teresa Schlegel<br>
       initially modelled.</li>
</ul>
</html>",   info="<html>
<p>The example Cauer Filter is a low-pass-filter of the fifth order. It is realized using an analog network. The voltage source V is the input voltage (step), and the R2.p.v is the filter output voltage. The pulse response is calculated.</p>
<p>The simulation end time should be 60. Please plot both V.p.v (input voltage) and R2.p.v (output voltage).</p>
</html>"),
        Icon(coordinateSystem(preserveAspectRatio=true, extent={{-200,-100},{200,
              100}}), graphics));
  end CauerLowPassAnalogLinear;

  model CauerLowPassAnalogNonLinear
    "Cauer low pass filter with analog components"
    extends Modelica.Icons.Example;

    parameter Modelica.SIunits.Inductance l1=1.304 "filter coefficient I1";
    parameter Modelica.SIunits.Inductance l2=0.8586 "filter coefficient I2";
    parameter Modelica.SIunits.Capacitance c1=1.072 "filter coefficient c1";
    parameter Modelica.SIunits.Capacitance c2=1/(1.704992^2*l1)
      "filter coefficient c2";
    parameter Modelica.SIunits.Capacitance c3=1.682 "filter coefficient c3";
    parameter Modelica.SIunits.Capacitance c4=1/(1.179945^2*l2)
      "filter coefficient c4";
    parameter Modelica.SIunits.Capacitance c5=0.7262 "filter coefficient c5";
    Modelica.Electrical.Analog.Basic.Ground G
      annotation (Placement(transformation(extent={{-10,-90},{10,-70}}, rotation=
              0)));
    Modelica.Electrical.Analog.Basic.Capacitor C1(C=c1)
      annotation (Placement(transformation(
          origin={-60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C2(C=c2)
      annotation (Placement(transformation(extent={{-40,20},{-20,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C3(C=c3)
      annotation (Placement(transformation(
          origin={0,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C4(C=c4)
      annotation (Placement(transformation(extent={{20,20},{40,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C5(C=c5)
      annotation (Placement(transformation(
          origin={60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Inductor L1(L=l1)
      annotation (Placement(transformation(extent={{-40,60},{-20,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Inductor L2(L=l2)
      annotation (Placement(transformation(extent={{20,60},{40,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Resistor R1
      annotation (Placement(transformation(extent={{-100,20},{-80,40}}, rotation=
              0)));
    Modelica.Electrical.Analog.Basic.Resistor R2
      annotation (Placement(transformation(
          origin={100,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Sources.StepVoltage V(startTime=1, offset=0)
      annotation (Placement(transformation(
          origin={-100,-10},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    VariableResistor variableResistor
      annotation (Placement(transformation(extent={{-60,-4},{-40,16}})));
    Modelica.Blocks.Sources.Sine sine(offset=10, freqHz=1)
      annotation (Placement(transformation(extent={{-152,54},{-132,74}})));
    VariableResistor variableResistor1
      annotation (Placement(transformation(extent={{-14,-2},{6,18}})));
    VariableResistor variableResistor2
      annotation (Placement(transformation(extent={{50,0},{70,20}})));
  equation
    connect(R1.n,C2. p)
      annotation (Line(points={{-80,30},{-64,30},{-64,34},{-54,34},{-54,30},{
            -40,30}},                              color={0,0,255}));
    connect(L1.p,C2. p)
      annotation (Line(points={{-40,70},{-40,30}}, color={0,0,255}));
    connect(L1.n,C2. n)
      annotation (Line(points={{-20,70},{-20,30}}, color={0,0,255}));
    connect(C2.n,C4. p)
      annotation (Line(points={{-20,30},{20,30}}, color={0,0,255}));
    connect(L1.n,C4. p) annotation (Line(points={{-20,70},{-20,30},{20,30}},
          color={0,0,255}));
    connect(L2.p,C4. p)
      annotation (Line(points={{20,70},{20,30}}, color={0,0,255}));
    connect(C2.n,L2. p) annotation (Line(points={{-20,30},{20,30},{20,70}}, color=
           {0,0,255}));
    connect(L2.n,C4. n)
      annotation (Line(points={{40,70},{40,30}}, color={0,0,255}));
    connect(R1.p, V.p)
      annotation (Line(points={{-100,30},{-100,0}}, color={0,0,255}));
    connect(V.n, G.p)            annotation (Line(points={{-100,-20},{-100,-70},{0,
            -70}},   color={0,0,255}));
    connect(R1.n, variableResistor.p) annotation (Line(
        points={{-80,30},{-76,30},{-76,6},{-60,6}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor.n, C1.p) annotation (Line(
        points={{-40,6},{-36,6},{-36,-10},{-60,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(sine.y, variableResistor.R) annotation (Line(
        points={{-131,64},{-50,64},{-50,17}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(variableResistor1.p, C2.n) annotation (Line(
        points={{-14,8},{-14,30},{-20,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor1.n, C3.p) annotation (Line(
        points={{6,8},{16,8},{16,-10},{1.83697e-015,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(sine.y, variableResistor1.R) annotation (Line(
        points={{-131,64},{-46,64},{-46,78},{-4,78},{-4,19}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(variableResistor2.p, C4.n) annotation (Line(
        points={{50,10},{50,30},{40,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor2.n, C5.p) annotation (Line(
        points={{70,10},{80,10},{80,-10},{60,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(sine.y, variableResistor2.R) annotation (Line(
        points={{-131,64},{-58,64},{-58,78},{60,78},{60,21}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(C1.n, G.p) annotation (Line(
        points={{-60,-30},{-30,-30},{-30,-70},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C3.n, G.p) annotation (Line(
        points={{-1.83697e-015,-30},{0,-30},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C5.n, G.p) annotation (Line(
        points={{60,-30},{30,-30},{30,-70},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(R2.n, C5.n) annotation (Line(
        points={{100,-30},{60,-30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(R2.p, C4.n) annotation (Line(
        points={{100,-10},{102,-10},{102,24},{104,24},{104,30},{40,30}},
        color={0,0,255},
        smooth=Smooth.None));
    annotation (Diagram(coordinateSystem(
            preserveAspectRatio=true, extent={{-200,-100},{200,100}}), graphics={
          Rectangle(
            extent={{-62,32},{-58,28}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-2,28},{2,32}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{58,32},{62,28}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{58,-48},{62,-52}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-2,-48},{2,-52}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-62,-48},{-58,-52}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Text(
            extent={{-110,116},{100,64}},
            textString="CauerLowPassAnalog",
            lineColor={0,0,255})}),
      experiment(StopTime=60),
      Documentation(revisions="<html>
<ul>
<li><i>January 13, 2006</i>
       by Christoph Clauss<br>
       included into Modelica Standard Library</li>
<li><i>September 15, 2005</i>
       by Peter Trappe designed and by Teresa Schlegel<br>
       initially modelled.</li>
</ul>
</html>",   info="<html>
<p>The example Cauer Filter is a low-pass-filter of the fifth order. It is realized using an analog network. The voltage source V is the input voltage (step), and the R2.p.v is the filter output voltage. The pulse response is calculated.</p>
<p>The simulation end time should be 60. Please plot both V.p.v (input voltage) and R2.p.v (output voltage).</p>
</html>"),
        Icon(coordinateSystem(preserveAspectRatio=true, extent={{-200,-100},{200,
              100}}), graphics));
  end CauerLowPassAnalogNonLinear;

      model VariableResistor
    "Ideal linear electrical resistor with variable resistance"
        parameter Modelica.SIunits.Temperature T_ref=300.15
      "Reference temperature";
        parameter Modelica.SIunits.LinearTemperatureCoefficient alpha=0
      "Temperature coefficient of resistance (R_actual = R*(1 + alpha*(T_heatPort - T_ref))";
        extends Modelica.Electrical.Analog.Interfaces.OnePort;
        extends Modelica.Electrical.Analog.Interfaces.ConditionalHeatPort(                    T = T_ref);
        Modelica.SIunits.Resistance R_actual
      "Actual resistance = R*(1 + alpha*(T_heatPort - T_ref))";
        Modelica.Blocks.Interfaces.RealInput R
          annotation (Placement(transformation(
        origin={0,110},
        extent={{-20,-20},{20,20}},
        rotation=270)));
      equation
        assert((1 + alpha*(T_heatPort - T_ref)) >= Modelica.Constants.eps, "Temperature outside scope of model!");
        R_actual = R*(1 + alpha*(T_heatPort - T_ref));
        v = R_actual*i;
        LossPower = v*i;
        annotation (
          Documentation(info="<html>
<p>The linear resistor connects the branch voltage <i>v</i> with the branch current <i>i</i> by 
<br><i><b>i*R = v</b></i>
<br>The Resistance <i>R</i> is given as input signal.
<br><br><b>Attention!!!</b><br>It is recommended that the R signal should not cross the zero value. Otherwise depending on the surrounding circuit the probability of singularities is high.</p>
</html>",revisions="<html>
<ul>
<li><i> August 07, 2009   </i>
       by Anton Haumer<br> temperature dependency of resistance added<br>
       </li>
<li><i> March 11, 2009   </i>
       by Christoph Clauss<br> conditional heat port added<br>
       </li>
<li><i>June 7, 2004   </i>
       by Christoph Clauss<br>changed, docu added<br>
       </li>
<li><i>April 30, 2004</i>
       by Anton Haumer<br>implemented.
       </li>
</ul>
</html>"),Icon(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}},
        grid={2,2}), graphics={
          Line(points={{-90,0},{-70,0}}, color={0,0,255}),
          Rectangle(
            extent={{-70,30},{70,-30}},
            lineColor={0,0,255},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Line(points={{70,0},{90,0}}, color={0,0,255}),
          Line(points={{0,90},{0,30}}, color={0,0,255}),
          Text(
            extent={{-148,-41},{152,-81}},
            textString="%name",
            lineColor={0,0,255})}),
          Diagram(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}},
        grid={2,2}), graphics={
          Rectangle(
            extent={{-70,30},{70,-30}},
            lineColor={0,0,255},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Line(points={{-96,0},{-70,0}}, color={0,0,255}),
          Line(points={{0,90},{0,30}}, color={0,0,255}),
          Line(points={{70,0},{96,0}}, color={0,0,255})}));
      end VariableResistor;

  model CLPANL "Cauer low pass filter with analog components"
    extends Modelica.Icons.Example;

    parameter Modelica.SIunits.Inductance l1=1.304 "filter coefficient I1";
    parameter Modelica.SIunits.Inductance l2=0.8586 "filter coefficient I2";
    parameter Modelica.SIunits.Capacitance c1=1.072 "filter coefficient c1";
    parameter Modelica.SIunits.Capacitance c2=1/(1.704992^2*l1)
      "filter coefficient c2";
    parameter Modelica.SIunits.Capacitance c3=1.682 "filter coefficient c3";
    parameter Modelica.SIunits.Capacitance c4=1/(1.179945^2*l2)
      "filter coefficient c4";
    parameter Modelica.SIunits.Capacitance c5=0.7262 "filter coefficient c5";
    Modelica.Electrical.Analog.Basic.Ground G
      annotation (Placement(transformation(extent={{-10,-90},{10,-70}}, rotation=
              0)));
    Modelica.Electrical.Analog.Basic.Capacitor C1(C=c1)
      annotation (Placement(transformation(
          origin={-60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C2(C=c2)
      annotation (Placement(transformation(extent={{-40,20},{-20,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C3(C=c3)
      annotation (Placement(transformation(
          origin={0,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C4(C=c4)
      annotation (Placement(transformation(extent={{20,20},{40,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C5(C=c5)
      annotation (Placement(transformation(
          origin={60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Inductor L1(L=l1)
      annotation (Placement(transformation(extent={{-40,60},{-20,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Inductor L2(L=l2)
      annotation (Placement(transformation(extent={{20,60},{40,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Resistor R1(R=1)
      annotation (Placement(transformation(extent={{-100,20},{-80,40}}, rotation=
              0)));
    VariableResistor variableResistor(useHeatPort=true, alpha=0.5)
      annotation (Placement(transformation(extent={{-60,-4},{-40,16}})));
    Modelica.Blocks.Sources.Sine sine(
      freqHz=1,
      amplitude=5000,
      offset=10000)
      annotation (Placement(transformation(extent={{-152,54},{-132,74}})));
    VariableResistor variableResistor1(useHeatPort=true, alpha=0.4)
      annotation (Placement(transformation(extent={{-14,-2},{6,18}})));
    VariableResistor variableResistor2(useHeatPort=true, alpha=0.3)
      annotation (Placement(transformation(extent={{50,0},{70,20}})));
    Modelica.Electrical.Analog.Interfaces.PositivePin pin_p1
      annotation (Placement(transformation(extent={{188,20},{208,40}})));
    Modelica.Electrical.Analog.Interfaces.NegativePin pin_n1
      annotation (Placement(transformation(extent={{190,-60},{210,-40}})));
    Modelica.Electrical.Analog.Interfaces.PositivePin pin_p
      annotation (Placement(transformation(extent={{-210,20},{-190,40}})));
    Modelica.Electrical.Analog.Interfaces.NegativePin pin_n
      annotation (Placement(transformation(extent={{-208,-58},{-188,-38}})));
    Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow fixedHeatFlow(
      Q_flow=1,
      alpha=0.5,
      T_ref=323.15)
      annotation (Placement(transformation(extent={{-162,-74},{-142,-54}})));
    Modelica.Electrical.Analog.Basic.Inductor inductor(L=l1)
      annotation (Placement(transformation(extent={{140,20},{160,40}})));
    Modelica.Electrical.Analog.Basic.Inductor inductor1(L=l1)
      annotation (Placement(transformation(extent={{140,-40},{160,-20}})));
  equation
    connect(R1.n,C2. p)
      annotation (Line(points={{-80,30},{-64,30},{-64,34},{-54,34},{-54,30},{
            -40,30}},                              color={0,0,255}));
    connect(L1.p,C2. p)
      annotation (Line(points={{-40,70},{-40,30}}, color={0,0,255}));
    connect(L1.n,C2. n)
      annotation (Line(points={{-20,70},{-20,30}}, color={0,0,255}));
    connect(C2.n,C4. p)
      annotation (Line(points={{-20,30},{20,30}}, color={0,0,255}));
    connect(L1.n,C4. p) annotation (Line(points={{-20,70},{-20,30},{20,30}},
          color={0,0,255}));
    connect(L2.p,C4. p)
      annotation (Line(points={{20,70},{20,30}}, color={0,0,255}));
    connect(C2.n,L2. p) annotation (Line(points={{-20,30},{20,30},{20,70}}, color=
           {0,0,255}));
    connect(L2.n,C4. n)
      annotation (Line(points={{40,70},{40,30}}, color={0,0,255}));
    connect(R1.n, variableResistor.p) annotation (Line(
        points={{-80,30},{-76,30},{-76,6},{-60,6}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor.n, C1.p) annotation (Line(
        points={{-40,6},{-36,6},{-36,-10},{-60,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(sine.y, variableResistor.R) annotation (Line(
        points={{-131,64},{-50,64},{-50,17}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(variableResistor1.p, C2.n) annotation (Line(
        points={{-14,8},{-14,30},{-20,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor1.n, C3.p) annotation (Line(
        points={{6,8},{16,8},{16,-10},{1.83697e-015,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(sine.y, variableResistor1.R) annotation (Line(
        points={{-131,64},{-46,64},{-46,78},{-4,78},{-4,19}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(variableResistor2.p, C4.n) annotation (Line(
        points={{50,10},{50,30},{40,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor2.n, C5.p) annotation (Line(
        points={{70,10},{80,10},{80,-10},{60,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(sine.y, variableResistor2.R) annotation (Line(
        points={{-131,64},{-58,64},{-58,78},{60,78},{60,21}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(C1.n, G.p) annotation (Line(
        points={{-60,-30},{-30,-30},{-30,-70},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C3.n, G.p) annotation (Line(
        points={{-1.83697e-015,-30},{0,-30},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C5.n, G.p) annotation (Line(
        points={{60,-30},{30,-30},{30,-70},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(pin_p, R1.p) annotation (Line(
        points={{-200,30},{-100,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(pin_n, C1.n) annotation (Line(
        points={{-198,-48},{-130,-48},{-130,-30},{-60,-30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(fixedHeatFlow.port, variableResistor.heatPort) annotation (Line(
        points={{-142,-64},{-90,-64},{-90,-4},{-50,-4}},
        color={191,0,0},
        smooth=Smooth.None));
    connect(fixedHeatFlow.port, variableResistor1.heatPort) annotation (Line(
        points={{-142,-64},{-66,-64},{-66,-2},{-4,-2}},
        color={191,0,0},
        smooth=Smooth.None));
    connect(fixedHeatFlow.port, variableResistor2.heatPort) annotation (Line(
        points={{-142,-64},{-34,-64},{-34,0},{60,0}},
        color={191,0,0},
        smooth=Smooth.None));
    connect(C4.n, inductor.p) annotation (Line(
        points={{40,30},{140,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(inductor.n, pin_p1) annotation (Line(
        points={{160,30},{198,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C5.n, inductor1.p) annotation (Line(
        points={{60,-30},{140,-30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(inductor1.n, pin_n1) annotation (Line(
        points={{160,-30},{180,-30},{180,-50},{200,-50}},
        color={0,0,255},
        smooth=Smooth.None));
    annotation (Diagram(coordinateSystem(
            preserveAspectRatio=true, extent={{-200,-100},{200,100}}), graphics={
          Rectangle(
            extent={{-2,28},{2,32}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{58,32},{62,28}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-2,-48},{2,-52}},
            lineColor={0,0,255},
            fillColor={85,85,255},
            fillPattern=FillPattern.Solid),
          Text(
            extent={{-110,116},{100,64}},
            textString="CauerLowPassAnalog",
            lineColor={0,0,255})}),
      experiment(StopTime=60),
      Documentation(revisions="<html>
<ul>
<li><i>January 13, 2006</i>
       by Christoph Clauss<br>
       included into Modelica Standard Library</li>
<li><i>September 15, 2005</i>
       by Peter Trappe designed and by Teresa Schlegel<br>
       initially modelled.</li>
</ul>
</html>",   info="<html>
<p>The example Cauer Filter is a low-pass-filter of the fifth order. It is realized using an analog network. The voltage source V is the input voltage (step), and the R2.p.v is the filter output voltage. The pulse response is calculated.</p>
<p>The simulation end time should be 60. Please plot both V.p.v (input voltage) and R2.p.v (output voltage).</p>
</html>"),
        Icon(coordinateSystem(preserveAspectRatio=true, extent={{-200,-100},{200,
              100}}), graphics));
  end CLPANL;

  model CLPANL_wIO
    "Cauer low pass filter with analog components and input/output"
    extends Modelica.Icons.Example;

    parameter Modelica.SIunits.Inductance l1=1.304 "filter coefficient I1";
    parameter Modelica.SIunits.Inductance l2=0.8586 "filter coefficient I2";
    parameter Modelica.SIunits.Capacitance c1=1.072 "filter coefficient c1";
    parameter Modelica.SIunits.Capacitance c2=1/(1.704992^2*l1)
      "filter coefficient c2";
    parameter Modelica.SIunits.Capacitance c3=1.682 "filter coefficient c3";
    parameter Modelica.SIunits.Capacitance c4=1/(1.179945^2*l2)
      "filter coefficient c4";
    parameter Modelica.SIunits.Capacitance c5=0.7262 "filter coefficient c5";
    Modelica.Electrical.Analog.Basic.Ground G
      annotation (Placement(transformation(extent={{-10,-90},{10,-70}}, rotation=
              0)));
    Modelica.Electrical.Analog.Basic.Capacitor C1(C=c1)
      annotation (Placement(transformation(
          origin={-60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C2(C=c2)
      annotation (Placement(transformation(extent={{-40,20},{-20,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C3(C=c3)
      annotation (Placement(transformation(
          origin={0,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Capacitor C4(C=c4)
      annotation (Placement(transformation(extent={{20,20},{40,40}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Capacitor C5(C=c5)
      annotation (Placement(transformation(
          origin={60,-20},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Inductor L1(L=l1)
      annotation (Placement(transformation(extent={{-40,60},{-20,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Inductor L2(L=l2)
      annotation (Placement(transformation(extent={{20,60},{40,80}}, rotation=0)));
    Modelica.Electrical.Analog.Basic.Resistor R1(R=1)
      annotation (Placement(transformation(extent={{-100,20},{-80,40}}, rotation=
              0)));
    VariableResistor variableResistor(useHeatPort=true, alpha=0.5)
      annotation (Placement(transformation(extent={{-60,-4},{-40,16}})));
    VariableResistor variableResistor1(useHeatPort=true, alpha=0.4)
      annotation (Placement(transformation(extent={{-14,-2},{6,18}})));
    VariableResistor variableResistor2(useHeatPort=true, alpha=0.3)
      annotation (Placement(transformation(extent={{50,0},{70,20}})));
    Modelica.Electrical.Analog.Interfaces.PositivePin pin_p1
      annotation (Placement(transformation(extent={{188,20},{208,40}})));
    Modelica.Electrical.Analog.Interfaces.NegativePin pin_n1
      annotation (Placement(transformation(extent={{190,-60},{210,-40}})));
    Modelica.Electrical.Analog.Interfaces.PositivePin pin_p
      annotation (Placement(transformation(extent={{-210,20},{-190,40}})));
    Modelica.Electrical.Analog.Interfaces.NegativePin pin_n
      annotation (Placement(transformation(extent={{-208,-58},{-188,-38}})));
    Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow
                                                        fixedHeatFlow(
      alpha=0.5,
      T_ref=323.15)
      annotation (Placement(transformation(extent={{-100,-18},{-80,2}})));
    Modelica.Electrical.Analog.Basic.Inductor inductor(L=l1)
      annotation (Placement(transformation(extent={{140,20},{160,40}})));
    Modelica.Electrical.Analog.Basic.Inductor inductor1(L=l1)
      annotation (Placement(transformation(extent={{140,-40},{160,-20}})));
    Modelica.Blocks.Interfaces.RealInput u_Resistance annotation (Placement(
          transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={100,112})));
    Modelica.Blocks.Interfaces.RealInput u_HeatFlow annotation (Placement(
          transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={-100,110})));
    Modelica.Blocks.Interfaces.RealOutput y_InterestingCurrent annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={100,-106})));
    Modelica.Blocks.Interfaces.RealOutput y_InterestingVoltage annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={-100,-104})));
    Modelica.Electrical.Analog.Sensors.PotentialSensor potentialSensor
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={-100,-70})));
    Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor
      annotation (Placement(transformation(extent={{90,-40},{110,-20}})));
  equation
    connect(R1.n,C2. p)
      annotation (Line(points={{-80,30},{-64,30},{-64,34},{-54,34},{-54,30},{
            -40,30}},                              color={0,0,255}));
    connect(L1.p,C2. p)
      annotation (Line(points={{-40,70},{-40,30}}, color={0,0,255}));
    connect(L1.n,C2. n)
      annotation (Line(points={{-20,70},{-20,30}}, color={0,0,255}));
    connect(C2.n,C4. p)
      annotation (Line(points={{-20,30},{20,30}}, color={0,0,255}));
    connect(L1.n,C4. p) annotation (Line(points={{-20,70},{-20,30},{20,30}},
          color={0,0,255}));
    connect(L2.p,C4. p)
      annotation (Line(points={{20,70},{20,30}}, color={0,0,255}));
    connect(C2.n,L2. p) annotation (Line(points={{-20,30},{20,30},{20,70}}, color=
           {0,0,255}));
    connect(L2.n,C4. n)
      annotation (Line(points={{40,70},{40,30}}, color={0,0,255}));
    connect(R1.n, variableResistor.p) annotation (Line(
        points={{-80,30},{-76,30},{-76,6},{-60,6}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor.n, C1.p) annotation (Line(
        points={{-40,6},{-36,6},{-36,-10},{-60,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor1.p, C2.n) annotation (Line(
        points={{-14,8},{-14,30},{-20,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor1.n, C3.p) annotation (Line(
        points={{6,8},{16,8},{16,-10},{1.83697e-015,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor2.p, C4.n) annotation (Line(
        points={{50,10},{50,30},{40,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(variableResistor2.n, C5.p) annotation (Line(
        points={{70,10},{80,10},{80,-10},{60,-10}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C1.n, G.p) annotation (Line(
        points={{-60,-30},{-30,-30},{-30,-70},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C3.n, G.p) annotation (Line(
        points={{-1.83697e-015,-30},{0,-30},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(C5.n, G.p) annotation (Line(
        points={{60,-30},{30,-30},{30,-70},{0,-70}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(pin_p, R1.p) annotation (Line(
        points={{-200,30},{-100,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(pin_n, C1.n) annotation (Line(
        points={{-198,-48},{-130,-48},{-130,-30},{-60,-30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(fixedHeatFlow.port, variableResistor.heatPort) annotation (Line(
        points={{-80,-8},{-50,-8},{-50,-4}},
        color={191,0,0},
        smooth=Smooth.None));
    connect(fixedHeatFlow.port, variableResistor1.heatPort) annotation (Line(
        points={{-80,-8},{-4,-8},{-4,-2}},
        color={191,0,0},
        smooth=Smooth.None));
    connect(fixedHeatFlow.port, variableResistor2.heatPort) annotation (Line(
        points={{-80,-8},{60,-8},{60,0}},
        color={191,0,0},
        smooth=Smooth.None));
    connect(C4.n, inductor.p) annotation (Line(
        points={{40,30},{140,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(inductor.n, pin_p1) annotation (Line(
        points={{160,30},{198,30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(inductor1.n, pin_n1) annotation (Line(
        points={{160,-30},{180,-30},{180,-50},{200,-50}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(u_Resistance, variableResistor.R) annotation (Line(
        points={{100,112},{100,52},{-50,52},{-50,17}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(variableResistor1.R, u_Resistance) annotation (Line(
        points={{-4,19},{-4,52},{100,52},{100,112}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(variableResistor2.R, u_Resistance) annotation (Line(
        points={{60,21},{60,52},{100,52},{100,112}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(u_HeatFlow, fixedHeatFlow.Q_flow) annotation (Line(
        points={{-100,110},{-100,60},{-120,60},{-120,-8},{-100,-8}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(potentialSensor.p, C1.n) annotation (Line(
        points={{-100,-60},{-100,-40},{-60,-40},{-60,-30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(potentialSensor.phi, y_InterestingVoltage) annotation (Line(
        points={{-100,-81},{-100,-104}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(C5.n, currentSensor.p) annotation (Line(
        points={{60,-30},{90,-30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(currentSensor.n, inductor1.p) annotation (Line(
        points={{110,-30},{140,-30}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(currentSensor.i, y_InterestingCurrent) annotation (Line(
        points={{100,-40},{100,-106}},
        color={0,0,127},
        smooth=Smooth.None));
    annotation (Diagram(coordinateSystem(
            preserveAspectRatio=true, extent={{-200,-100},{200,100}}), graphics={
          Text(
            extent={{-110,116},{100,64}},
            textString="CauerLowPassAnalog",
            lineColor={0,0,255})}),
      experiment(StopTime=60),
      Documentation(revisions="<html>
<ul>
<li><i>January 13, 2006</i>
       by Christoph Clauss<br>
       included into Modelica Standard Library</li>
<li><i>September 15, 2005</i>
       by Peter Trappe designed and by Teresa Schlegel<br>
       initially modelled.</li>
</ul>
</html>",   info="<html>
<p>The example Cauer Filter is a low-pass-filter of the fifth order. It is realized using an analog network. The voltage source V is the input voltage (step), and the R2.p.v is the filter output voltage. The pulse response is calculated.</p>
<p>The simulation end time should be 60. Please plot both V.p.v (input voltage) and R2.p.v (output voltage).</p>
</html>"),
        Icon(coordinateSystem(preserveAspectRatio=true, extent={{-200,-100},{200,
              100}}), graphics));
  end CLPANL_wIO;

  model TwoSystems
    CLPANL cLPANL
      annotation (Placement(transformation(extent={{-80,-4},{-40,16}})));
    Modelica.Electrical.Analog.Sources.SineVoltage V(startTime=1, offset=0,
      V=1)
      annotation (Placement(transformation(
          origin={-92,4},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Resistor R1(R=1)
      annotation (Placement(transformation(
          origin={90,4},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    CLPANL cLPANL1
      annotation (Placement(transformation(extent={{28,-4},{68,16}})));
  equation
    connect(V.p, cLPANL.pin_p) annotation (Line(
        points={{-92,14},{-80,14},{-80,9}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(V.n, cLPANL.pin_n) annotation (Line(
        points={{-92,-6},{-80,-6},{-80,1.2},{-79.8,1.2}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL1.pin_p1, R1.p) annotation (Line(
        points={{67.8,9},{78.9,9},{78.9,14},{90,14}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL1.pin_n1, R1.n) annotation (Line(
        points={{68,1},{80,1},{80,-6},{90,-6}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL.pin_p1, cLPANL1.pin_p) annotation (Line(
        points={{-40.2,9},{28,9}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL.pin_n1, cLPANL1.pin_n) annotation (Line(
        points={{-40,1},{-6,1},{-6,1.2},{28.2,1.2}},
        color={0,0,255},
        smooth=Smooth.None));
    annotation (Diagram(graphics));
  end TwoSystems;

  model MultiSystems
    parameter Integer n = 10;
    CLPANL[n] cLPANL
      annotation (Placement(transformation(extent={{-80,-4},{-40,16}})));
    Modelica.Electrical.Analog.Sources.SineVoltage V(startTime=1, offset=0,
      V=1)
      annotation (Placement(transformation(
          origin={-92,4},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Resistor R1(R=1)
      annotation (Placement(transformation(
          origin={90,4},
          extent={{-10,-10},{10,10}},
          rotation=270)));
  equation
    connect(V.p, cLPANL[1].pin_p);
    connect(V.n, cLPANL[1].pin_n);
    connect(cLPANL[n].pin_p1, R1.p);
    connect(cLPANL[n].pin_n1, R1.n);
    for i in 1:n-1 loop
      connect(cLPANL[i].pin_p1, cLPANL[i+1].pin_p);
      connect(cLPANL[i].pin_n1, cLPANL[i+1].pin_n);
    end for;
  end MultiSystems;

  model TwoSystems_wIO
    CLPANL_wIO
           cLPANL
      annotation (Placement(transformation(extent={{-80,-4},{-40,16}})));
    Modelica.Electrical.Analog.Sources.SineVoltage V(startTime=1, offset=0,
      V=1)
      annotation (Placement(transformation(
          origin={-92,4},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    Modelica.Electrical.Analog.Basic.Resistor R1(R=1)
      annotation (Placement(transformation(
          origin={90,4},
          extent={{-10,-10},{10,10}},
          rotation=270)));
    CLPANL_wIO
           cLPANL1
      annotation (Placement(transformation(extent={{28,-4},{68,16}})));
    Modelica.Blocks.Interfaces.RealInput u annotation (Placement(transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={-60,108})));
    Modelica.Blocks.Interfaces.RealInput u1 annotation (Placement(
          transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={-20,108})));
    Modelica.Blocks.Interfaces.RealInput u2 annotation (Placement(
          transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={20,108})));
    Modelica.Blocks.Interfaces.RealInput u3 annotation (Placement(
          transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={60,108})));
    Modelica.Blocks.Interfaces.RealOutput y annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={-60,-106})));
    Modelica.Blocks.Interfaces.RealOutput y1 annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={-20,-106})));
    Modelica.Blocks.Interfaces.RealOutput y2 annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={20,-106})));
    Modelica.Blocks.Interfaces.RealOutput y3 annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={60,-106})));
  equation
    connect(V.p, cLPANL.pin_p) annotation (Line(
        points={{-92,14},{-80,14},{-80,9}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(V.n, cLPANL.pin_n) annotation (Line(
        points={{-92,-6},{-80,-6},{-80,1.2},{-79.8,1.2}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL1.pin_p1, R1.p) annotation (Line(
        points={{67.8,9},{78.9,9},{78.9,14},{90,14}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL1.pin_n1, R1.n) annotation (Line(
        points={{68,1},{80,1},{80,-6},{90,-6}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL.pin_p1, cLPANL1.pin_p) annotation (Line(
        points={{-40.2,9},{28,9}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL.pin_n1, cLPANL1.pin_n) annotation (Line(
        points={{-40,1},{-6,1},{-6,1.2},{28.2,1.2}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(u1, cLPANL.u_Resistance) annotation (Line(
        points={{-20,108},{-20,60},{-50,60},{-50,17.2}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(u, cLPANL.u_HeatFlow) annotation (Line(
        points={{-60,108},{-60,60},{-70,60},{-70,17}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(u2, cLPANL1.u_HeatFlow) annotation (Line(
        points={{20,108},{20,60},{38,60},{38,17}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(u3, cLPANL1.u_Resistance) annotation (Line(
        points={{60,108},{60,60},{58,60},{58,17.2}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(cLPANL.y_InterestingVoltage, y) annotation (Line(
        points={{-70,-4.4},{-70,-60},{-60,-60},{-60,-106}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(cLPANL.y_InterestingCurrent, y1) annotation (Line(
        points={{-50,-4.6},{-50,-60},{-20,-60},{-20,-106}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(cLPANL1.y_InterestingVoltage, y2) annotation (Line(
        points={{38,-4.4},{38,-60},{20,-60},{20,-106}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(cLPANL1.y_InterestingCurrent, y3) annotation (Line(
        points={{58,-4.6},{58,-60},{60,-60},{60,-106}},
        color={0,0,127},
        smooth=Smooth.None));
    annotation (Diagram(graphics));
  end TwoSystems_wIO;
  annotation (uses(Modelica(version="3.2")));
end NonLinear;
