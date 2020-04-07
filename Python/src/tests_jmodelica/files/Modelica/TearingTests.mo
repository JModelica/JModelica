package TearingTests

model TearingTest1
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;
end TearingTest1;

model Electro
 import Modelica;
   Modelica.Electrical.Analog.Sources.SineVoltage sineVoltage(V=220, freqHz=60)
    annotation (Placement(transformation(extent={{-88,4},{-78,14}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor
    annotation (Placement(transformation(extent={{-64,24},{-52,36}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor1(R=10)
    annotation (Placement(transformation(extent={{-42,4},{-30,16}})));
  Modelica.Electrical.Analog.Basic.Inductor inductor(L=1)
    annotation (Placement(transformation(extent={{-64,-12},{-52,0}})));
  Modelica.Electrical.Analog.Basic.Resistor capacitor(R=11)
    annotation (Placement(transformation(extent={{-24,8},{-12,20}})));
  Modelica.Electrical.Analog.Basic.Ground ground
    annotation (Placement(transformation(extent={{86,-102},{100,-88}})));
  Modelica.Electrical.Analog.Basic.Capacitor resistor2(C=0.005, i(start=0.05))
    annotation (Placement(transformation(extent={{-24,54},{-12,66}})));
  Modelica.Electrical.Analog.Basic.Capacitor resistor3(C=0.001)
    annotation (Placement(transformation(extent={{-24,38},{-10,52}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor4
    annotation (Placement(transformation(extent={{10,70},{20,80}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor5(R=11)
    annotation (Placement(transformation(extent={{12,48},{22,58}})));
  Modelica.Electrical.Analog.Basic.Capacitor resistor7(C=0.005)
    annotation (Placement(transformation(extent={{12,10},{22,20}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor8(R=10)
    annotation (Placement(transformation(extent={{28,82},{38,92}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor9(R=10)
    annotation (Placement(transformation(extent={{28,64},{38,74}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor10(R=10)
    annotation (Placement(transformation(extent={{28,54},{38,64}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor11(R=10)
    annotation (Placement(transformation(extent={{28,42},{38,52}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor12(R=10)
    annotation (Placement(transformation(extent={{28,32},{38,42}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor13
    annotation (Placement(transformation(extent={{28,22},{38,32}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor14(R=10)
    annotation (Placement(transformation(extent={{28,14},{38,24}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor15
    annotation (Placement(transformation(extent={{28,4},{38,14}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor16(R=10)
    annotation (Placement(transformation(extent={{26,-12},{36,-2}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor17(R=11)
    annotation (Placement(transformation(extent={{26,-20},{36,-10}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor18(R=12)
    annotation (Placement(transformation(extent={{26,-28},{36,-18}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor19(R=12)
    annotation (Placement(transformation(extent={{26,-48},{36,-38}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor20
    annotation (Placement(transformation(extent={{26,-56},{36,-46}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor21(R=11)
    annotation (Placement(transformation(extent={{26,-66},{36,-56}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor22(R=10)
    annotation (Placement(transformation(extent={{26,-76},{36,-66}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor23
    annotation (Placement(transformation(extent={{26,-88},{36,-78}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor24
    annotation (Placement(transformation(extent={{2,-14},{12,-4}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor25
    annotation (Placement(transformation(extent={{0,-48},{10,-38}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor26(R=11)
    annotation (Placement(transformation(extent={{74,84},{84,94}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor27
    annotation (Placement(transformation(extent={{74,66},{84,76}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor28(R=10)
    annotation (Placement(transformation(extent={{74,56},{84,66}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor29(R=10)
    annotation (Placement(transformation(extent={{74,44},{84,54}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor30(R=10)
    annotation (Placement(transformation(extent={{74,34},{84,44}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor31(R=11)
    annotation (Placement(transformation(extent={{74,24},{84,34}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor32(R=12)
    annotation (Placement(transformation(extent={{74,16},{84,26}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor33(R=10)
    annotation (Placement(transformation(extent={{74,6},{84,16}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor34(R=10)
    annotation (Placement(transformation(extent={{74,-4},{84,6}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor35(R=11)
    annotation (Placement(transformation(extent={{74,-22},{84,-12}})));
  Modelica.Electrical.Analog.Basic.VariableResistor
                                            resistor36
    annotation (Placement(transformation(extent={{74,-32},{84,-22}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor37(R=15)
    annotation (Placement(transformation(extent={{74,-44},{84,-34}})));
  Modelica.Electrical.Analog.Basic.Capacitor resistor38(C=0.005)
    annotation (Placement(transformation(extent={{74,-54},{84,-44}})));
  Modelica.Electrical.Analog.Basic.Capacitor resistor39(C=0.005)
    annotation (Placement(transformation(extent={{74,-64},{84,-54}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor40(R=14)
    annotation (Placement(transformation(extent={{74,-72},{84,-62}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor41(R=22)
    annotation (Placement(transformation(extent={{74,-82},{84,-72}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor42(R=12)
    annotation (Placement(transformation(extent={{20,-32},{26,-26}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor43(R=10)
    annotation (Placement(transformation(extent={{20,-40},{26,-34}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor44(R=10)
    annotation (Placement(transformation(extent={{26,-4},{36,6}})));
  Modelica.Blocks.Sources.RealExpression realExpression(y=10 + 3*resistor44.v*
        resistor44.v + 10*sin(resistor18.i) + 10*cos(resistor18.i))
    annotation (Placement(transformation(extent={{-76,-38},{-56,-18}})));
  Modelica.Blocks.Sources.RealExpression realExpression1(y=10 + resistor25.v^2 +
        15*cos(resistor16.i) + 15*sin(resistor16.i))
    annotation (Placement(transformation(extent={{-76,-52},{-56,-32}})));
  Modelica.Blocks.Sources.RealExpression realExpression2(y=15 + 11*resistor25.i*
        cos(resistor25.v) + 5*resistor9.v^2 + 11*resistor25.i*sin(resistor25.v))
    annotation (Placement(transformation(extent={{-76,-66},{-56,-46}})));
  Modelica.Blocks.Sources.RealExpression realExpression3(y=25 + 5*resistor9.v^2*
        sqrt(resistor9.i^2 + 2) + 10*cos(resistor8.v^3) + 10*sin(resistor8.v^3))
    annotation (Placement(transformation(extent={{-46,78},{-26,98}})));
  Modelica.Electrical.Analog.Sources.SineCurrent signalCurrent(I=0.05,
      freqHz=100)
    annotation (Placement(transformation(extent={{10,28},{22,40}})));
equation
  connect(sineVoltage.p, resistor.p) annotation (Line(
      points={{-88,9},{-88,30},{-64,30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor1.n, ground.p) annotation (Line(
      points={{-30,10},{-26,10},{-26,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor.n, resistor1.p) annotation (Line(
      points={{-52,30},{-48,30},{-48,10},{-42,10}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(inductor.n, sineVoltage.n) annotation (Line(
      points={{-52,-6},{-52,-18},{-78,-18},{-78,9}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor.n, inductor.p) annotation (Line(
      points={{-52,30},{-52,4},{-64,4},{-64,-6}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(sineVoltage.p, capacitor.p) annotation (Line(
      points={{-88,9},{-88,36},{-24,36},{-24,14}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor.n, resistor2.p) annotation (Line(
      points={{-52,30},{-38,30},{-38,60},{-24,60}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor.n, resistor3.p) annotation (Line(
      points={{-52,30},{-30,30},{-30,45},{-24,45}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor2.n, resistor.p) annotation (Line(
      points={{-12,60},{-12,68},{-64,68},{-64,30}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor2.n, resistor4.p) annotation (Line(
      points={{-12,60},{10,60},{10,75}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor2.n, resistor5.p) annotation (Line(
      points={{-12,60},{0,60},{0,53},{12,53}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor3.n, resistor7.p) annotation (Line(
      points={{-10,45},{2,45},{2,15},{12,15}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor4.n, resistor8.p) annotation (Line(
      points={{20,75},{24,75},{24,87},{28,87}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor4.n, resistor9.p) annotation (Line(
      points={{20,75},{24,75},{24,69},{28,69}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor5.n, resistor10.p) annotation (Line(
      points={{22,53},{26,53},{26,59},{28,59}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor5.n, resistor11.p) annotation (Line(
      points={{22,53},{26,53},{26,47},{28,47}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor7.n, resistor14.p) annotation (Line(
      points={{22,15},{26,15},{26,19},{28,19}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor7.n, resistor15.p) annotation (Line(
      points={{22,15},{26,15},{26,9},{28,9}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, ground.p) annotation (Line(
      points={{38,87},{46,87},{46,88},{54,88},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor9.n, ground.p) annotation (Line(
      points={{38,69},{54,69},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor10.n, ground.p) annotation (Line(
      points={{38,59},{54,59},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor11.n, ground.p) annotation (Line(
      points={{38,47},{54,47},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor12.n, ground.p) annotation (Line(
      points={{38,37},{54,37},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor13.n, ground.p) annotation (Line(
      points={{38,27},{54,27},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor14.n, ground.p) annotation (Line(
      points={{38,19},{54,19},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor15.n, ground.p) annotation (Line(
      points={{38,9},{54,9},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor16.n, ground.p) annotation (Line(
      points={{36,-7},{46,-7},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor17.n, ground.p) annotation (Line(
      points={{36,-15},{46,-15},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor18.n, ground.p) annotation (Line(
      points={{36,-23},{46,-23},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor19.n, ground.p) annotation (Line(
      points={{36,-43},{46,-43},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor20.n, ground.p) annotation (Line(
      points={{36,-51},{46,-51},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor21.n, ground.p) annotation (Line(
      points={{36,-61},{46,-61},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor22.n, ground.p) annotation (Line(
      points={{36,-71},{46,-71},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(capacitor.n, resistor24.p) annotation (Line(
      points={{-12,14},{-6,14},{-6,-9},{2,-9}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor24.n, resistor16.p) annotation (Line(
      points={{12,-9},{20,-9},{20,-7},{26,-7}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor24.n, resistor17.p) annotation (Line(
      points={{12,-9},{20,-9},{20,-15},{26,-15}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor24.n, resistor18.p) annotation (Line(
      points={{12,-9},{20,-9},{20,-23},{26,-23}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(capacitor.n, resistor25.p) annotation (Line(
      points={{-12,14},{-6,14},{-6,-43},{0,-43}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor25.n, resistor19.p) annotation (Line(
      points={{10,-43},{26,-43}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor25.n, resistor20.p) annotation (Line(
      points={{10,-43},{18,-43},{18,-51},{26,-51}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor25.n, resistor21.p) annotation (Line(
      points={{10,-43},{18,-43},{18,-61},{26,-61}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor25.n, resistor22.p) annotation (Line(
      points={{10,-43},{18,-43},{18,-71},{26,-71}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor25.n, resistor23.p) annotation (Line(
      points={{10,-43},{18,-43},{18,-83},{26,-83}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor23.n, ground.p) annotation (Line(
      points={{36,-83},{46,-83},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor26.p) annotation (Line(
      points={{38,87},{56,87},{56,89},{74,89}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor27.p) annotation (Line(
      points={{38,87},{56,87},{56,71},{74,71}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor28.p) annotation (Line(
      points={{38,87},{56,87},{56,61},{74,61}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor29.p) annotation (Line(
      points={{38,87},{56,87},{56,49},{74,49}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor30.p) annotation (Line(
      points={{38,87},{56,87},{56,39},{74,39}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor31.p) annotation (Line(
      points={{38,87},{56,87},{56,29},{74,29}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor32.p) annotation (Line(
      points={{38,87},{56,87},{56,21},{74,21}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor33.p) annotation (Line(
      points={{38,87},{56,87},{56,11},{74,11}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor8.n, resistor34.p) annotation (Line(
      points={{38,87},{56,87},{56,1},{74,1}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor26.n, ground.p) annotation (Line(
      points={{84,89},{90,90},{94,90},{94,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor27.n, ground.p) annotation (Line(
      points={{84,71},{94,71},{94,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor28.n, ground.p) annotation (Line(
      points={{84,61},{90,61},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor29.n, ground.p) annotation (Line(
      points={{84,49},{90,49},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor30.n, ground.p) annotation (Line(
      points={{84,39},{90,39},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor31.n, ground.p) annotation (Line(
      points={{84,29},{90,29},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor32.n, ground.p) annotation (Line(
      points={{84,21},{90,21},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor33.n, ground.p) annotation (Line(
      points={{84,11},{90,11},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor34.n, ground.p) annotation (Line(
      points={{84,1},{90,1},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor35.n, ground.p) annotation (Line(
      points={{84,-17},{90,-17},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor36.n, ground.p) annotation (Line(
      points={{84,-27},{90,-27},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor37.n, ground.p) annotation (Line(
      points={{84,-39},{90,-39},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor38.n, ground.p) annotation (Line(
      points={{84,-49},{90,-49},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor39.n, ground.p) annotation (Line(
      points={{84,-59},{90,-59},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor40.n, ground.p) annotation (Line(
      points={{84,-67},{90,-67},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor41.n, ground.p) annotation (Line(
      points={{84,-77},{90,-77},{90,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor19.n, resistor35.p) annotation (Line(
      points={{36,-43},{56,-43},{56,-17},{74,-17}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor20.n, resistor36.p) annotation (Line(
      points={{36,-51},{56,-51},{56,-27},{74,-27}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor19.n, resistor41.p) annotation (Line(
      points={{36,-43},{56,-43},{56,-77},{74,-77}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor19.n, resistor40.p) annotation (Line(
      points={{36,-43},{56,-43},{56,-67},{74,-67}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor20.n, resistor37.p) annotation (Line(
      points={{36,-51},{56,-51},{56,-39},{74,-39}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor20.n, resistor39.p) annotation (Line(
      points={{36,-51},{56,-51},{56,-59},{74,-59}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor19.n, resistor38.p) annotation (Line(
      points={{36,-43},{56,-43},{56,-49},{74,-49}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor25.n, resistor42.p) annotation (Line(
      points={{10,-43},{16,-43},{16,-29},{20,-29}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor25.n, resistor43.p) annotation (Line(
      points={{10,-43},{16,-43},{16,-37},{20,-37}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor42.n, ground.p) annotation (Line(
      points={{26,-29},{46,-29},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor43.n, ground.p) annotation (Line(
      points={{26,-37},{46,-37},{46,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor24.n, resistor44.p) annotation (Line(
      points={{12,-9},{20,-9},{20,1},{26,1}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor44.n, ground.p) annotation (Line(
      points={{36,1},{54,1},{54,-88},{93,-88}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(realExpression.y, resistor25.R) annotation (Line(
      points={{-55,-28},{-4,-28},{-4,-37.5},{5,-37.5}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(realExpression1.y, resistor24.R) annotation (Line(
      points={{-55,-42},{-24,-42},{-24,-3.5},{7,-3.5}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(resistor23.R, realExpression2.y) annotation (Line(
      points={{31,-77.5},{-12.5,-77.5},{-12.5,-56},{-55,-56}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(realExpression3.y, resistor4.R) annotation (Line(
      points={{-25,88},{-4,88},{-4,80.5},{15,80.5}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(resistor13.R, realExpression3.y) annotation (Line(
      points={{33,32.5},{34,96},{4,96},{4,88},{-25,88}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(resistor20.R, realExpression2.y) annotation (Line(
      points={{31,-45.5},{-12.5,-45.5},{-12.5,-56},{-55,-56}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(signalCurrent.p, resistor12.p) annotation (Line(
      points={{10,34},{10,44},{28,44},{28,37}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalCurrent.p, resistor13.p) annotation (Line(
      points={{10,34},{10,44},{28,44},{28,27}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(signalCurrent.n, resistor3.n) annotation (Line(
      points={{22,34},{22,24},{-10,24},{-10,45}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(resistor.R, realExpression3.y) annotation (Line(
      points={{-58,36.6},{-42,36.6},{-42,74},{-25,74},{-25,88}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(resistor27.R, realExpression.y) annotation (Line(
      points={{79,76.5},{-55,76.5},{-55,-28}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(resistor36.R, realExpression1.y) annotation (Line(
      points={{79,-21.5},{11.5,-21.5},{11.5,-42},{-55,-42}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(resistor15.R, realExpression1.y) annotation (Line(
      points={{33,14.5},{-55,14.5},{-55,-42}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (uses(Modelica(version="3.2")), Diagram(graphics));
end Electro;

package NonLinear


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
          Icon(coordinateSystem(
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
        Icon(coordinateSystem(preserveAspectRatio=true, extent={{-200,-100},{200,
              100}}), graphics));
  end CLPANL;

  model MultiSystems
    parameter Integer n = 5;
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
end NonLinear;


end TearingTests;