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
  end CLPANL;

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
        points={{-40.2,9},{-6.1,9},{-6.1,9},{28,9}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(cLPANL.pin_n1, cLPANL1.pin_n) annotation (Line(
        points={{-40,1},{-6,1},{-6,1.2},{28.2,1.2}},
        color={0,0,255},
        smooth=Smooth.None));
    annotation (Diagram(graphics));
  end TwoSystems;

  model MultiSystems
    parameter Integer n = 4;
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
  
  model NominalStart1
    Real x(start=1), y;
equation
    sin(x/y) = 0;
    x*y = 0;
end NominalStart1;

model NominalStart2
    Real x(start=1), y(start=0);
equation
    sin(x/y) = 0;
    x*y = 0;
end NominalStart2;

model NominalStart3
    Real x(nominal=2);
equation
x^3-3*x^2+x=1;
end NominalStart3;

model NominalStart4
    Real x(start=1);
equation
x^3-3*x^2+x=1;
end NominalStart4;

model NominalStart5
    Real x(start=1, nominal=2);
equation
x^3-3*x^2+x=1;
end NominalStart5;

model NominalStart6
    Real x(nominal=1, min=-1, max=1);
    Real y(start=0, min=-1, max=1);
    final constant Real e = Modelica.Math.exp(1.0);
equation
    0 = (x - 0.680716920494911)^2 + y^2;
    0 = noEvent(if ((x - y) > 0) then e^(x - y) -(e^(2*(x - y)) - 1) * (x - y) else e^(x - y));
end NominalStart6;

model DoubleRoot1
    Real x(start=p);
    parameter Real p(start=1.5);
equation
    0=(x-1.5)^2-1e-7;
end DoubleRoot1;

model ResidualHeuristicScaling1
  function fluid_function
    input Real x;
    output Real y;
  algorithm
    y:=x*x;
    return;
  end fluid_function;
  
  parameter Real A_mean = Modelica.Constants.pi*10^60;
  Real state_a_p(start=1000.0);
  Real state_a_d;
  Real dp_fg;
  Real F_p;
  
  equation
    //Block 1
    state_a_d = fluid_function(state_a_p);  //Torn variable
    dp_fg = fluid_function(state_a_d);      //Torn variable
    F_p = A_mean * dp_fg;                   //Torn variable
    
    F_p = A_mean * (100000.0 - state_a_p);  //Residual equation
end ResidualHeuristicScaling1;

model EventIteration1
  //Iteration variable:
  Real iter_var_1(start = 300.0);
  
  //Teared variables:
  Real tear_var_1;
  Real tear_var_2;
  Real tear_var_3;
  Real tear_var_4;
  Real tear_var_5;
  Real tear_var_6;

equation
  //Teared equations:
  tear_var_1 = 0.0317558 * (4124.487568704486 * ((-40783.2321 + iter_var_1 * (2682.484665 + -800.918604 * log(max(iter_var_1, 200)) + iter_var_1 * (8.21470201 + iter_var_1 * (-0.006348572285 + iter_var_1 * (5.845350253333333E-6 + iter_var_1 * (-3.007150675E-9 + 6.73618698E-13 * iter_var_1)))))) / iter_var_1) + 4200697.462150524) + 0.15495407 * (518.2791167938085 * ((176685.0998 + iter_var_1 * (-23313.1436 + 2786.18102 * log(max(iter_var_1, 200)) + iter_var_1 * (-12.0257785 + iter_var_1 * (0.01958809645 + iter_var_1 * (-1.2063514766666667E-5 + iter_var_1 * (5.0671326075E-9 + -9.953410979999998E-13 * iter_var_1)))))) / iter_var_1) + 624355.7409524474) + (0.02871398 * (296.8383547363272 * ((-14890.45326 + iter_var_1 * (-13031.31878 + -292.2285939 * log(max(iter_var_1, 200)) + iter_var_1 * (5.72452717 + iter_var_1 * (-0.004088117515000001 + iter_var_1 * (4.856344896666666E-6 + iter_var_1 * (-2.719365755E-9 + 6.055883654E-13 * iter_var_1)))))) / iter_var_1) + 309570.6191695138) + 0.18372006 * (188.9244822140674 * ((-49436.5054 + iter_var_1 * (-45281.9846 + -626.411601 * log(max(iter_var_1, 200)) + iter_var_1 * (5.30172524 + iter_var_1 * (0.001251906908 + iter_var_1 * (-7.091029093333333E-8 + iter_var_1 * (-1.922497195E-10 + 5.699355602E-14 * iter_var_1)))))) / iter_var_1) + 212805.6215135368)) + (0.2516777 * (461.5233290850878 * ((39479.6083 + iter_var_1 * (-33039.7431 + 575.573102 * log(max(iter_var_1, 200)) + iter_var_1 * (0.931782653 + iter_var_1 * (0.00361135643 + iter_var_1 * (-2.447519123333333E-6 + iter_var_1 * (1.2387608725E-9 + -2.673866492E-13 * iter_var_1)))))) / iter_var_1) + 549760.6476280135) + 0.32785651 * (296.8033869505308 * ((-22103.71497 + iter_var_1 * (710.846086 + -381.846182 * log(max(iter_var_1, 200)) + iter_var_1 * (6.08273836 + iter_var_1 * (-0.004265457205 + iter_var_1 * (4.615487296666666E-6 + iter_var_1 * (-2.406448405E-9 + 5.039411618000001E-13 * iter_var_1)))))) / iter_var_1) + 309498.4543111511) + 0.02132189 * (259.8369938872708 * ((34255.6342 + iter_var_1 * (-3391.45487 + 484.700097 * log(max(iter_var_1, 200)) + iter_var_1 * (1.119010961 + iter_var_1 * (0.00214694462 + iter_var_1 * (-2.27876684E-7 + iter_var_1 * (-5.05843175E-10 + 2.0780800360000002E-13 * iter_var_1)))))) / iter_var_1) + 271263.4223783392));
  tear_var_2 = (tear_var_1 + 4142388.31874666) / (if iter_var_1 - 873.15 > 0 then max(1, iter_var_1 - 873.15) else min(-1, iter_var_1 - 873.15));
  tear_var_3 = noEvent(if abs(iter_var_1 - 873.15) <= 1e-9 then 2326.98032733 elseif abs(iter_var_1 - 873.15) >= 1.999999999 then tear_var_2 else (tanh(tan((abs(iter_var_1 - 873.15) - 1) * asin(1))) + 1) * (tear_var_2 - 2326.98032733) / 2 + 2326.98032733);
  tear_var_4 = min(tear_var_3, 1.6314868948475);
  tear_var_5 = 1.05 / max(1.0E-15, tear_var_4);
  tear_var_6 = -4142388.31874666 - tear_var_1;
  
  //Residual equation:
  tear_var_6 = min(0.9995, (1 - exp((- tear_var_5) * 0.99)) / (1 - 0.01 * exp((- tear_var_5) * 0.99))) * tear_var_4 * 510.00071335;
end EventIteration1;

model NonLinear3
    parameter Real Vns = -15;
    parameter Real Vps = 15;
    parameter Real V0 = 15000;
    parameter Real opAmp2_v_out = -9.9400010271391164E+00;
    parameter Real k1 = 1000; 
    parameter Real k2 = 1500;
    Real v_in(start=0);
    Real v_out;
    Real i;
    Real r1_v, r2_v;
    
equation
    r1_v = - k1 * i;
    v_in = r1_v + opAmp2_v_out;
    r2_v = k2 * i;
    v_out = min(Vps, max(Vns, V0 * v_in));
    r2_v  =  v_in - v_out;
end NonLinear3;

model NonLinear4
    parameter Real scale = 10000;
    parameter Real Vns = -Vps;
    parameter Real Vps = 15;
    parameter Real V0 = 1000*Vps;
    parameter Real opAmp2_v_out = -9.9400010271391164E+00;
    parameter Real k1 = (Vps*2)/3*100/scale; //1000; 
    parameter Real k2 = 100*Vps/scale;
    parameter Real i_start(start= -9.9760004108556469E-03*scale);
    Real v_in(start=0);
    Real v_out;
    Real i(nominal=1e3, start=i_start);
    Real r1_v, r2_v;
    
equation
    r1_v = - k1 * i;
    v_in = r1_v + opAmp2_v_out;
    r2_v = k2 * i;
    v_out = min(Vps, max(Vns, V0 * v_in));
    r2_v  =  v_in - v_out;
end NonLinear4;

model NonLinear5
   Real x(start=2);
   Real y(start=0.5);
equation
    der(x) = -1;
 100*(y^2-0.1) = 0;
end NonLinear5;

model NonLinear6
parameter Real x_start(fixed=false);
Real x(start=x_start) = log(x)*y*z^2+1;
Real z(start=0);
Real y;
initial equation
x_start=1.0;
equation
y = x_start;
z^2 = x^2;
end NonLinear6;

model NonLinear7
parameter Real x_start(fixed=false);
Real x(start=x_start, nominal=1e50) = log(x)*y*z^2+1;
Real z(start=0);
Real y;
initial equation
x_start=1.0;
equation
y = x_start;
z = x^2;
end NonLinear7;

model NonLinear8
    Real x(start=1.5, min=1, max=2);
    parameter Real p=4;
equation
    (x-0.1)^2=p;
end NonLinear8;

model RealTimeSolver1
    Real x(start=0.9);
equation
    x^2 + x = 2;
end RealTimeSolver1;

end NonLinear;

