package IndexReductionTests

  model Mechanical1
     extends Modelica.Mechanics.Rotational.Examples.First(freqHz=5,amplitude=10,
    damper(phi_rel(stateSelect=StateSelect.always),w_rel(stateSelect=StateSelect.always)));
  end Mechanical1;

model Electrical1
  Modelica.Electrical.Analog.Basic.Resistor resistor(R=1);
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(C=1);
  Modelica.Electrical.Analog.Basic.Inductor inductor(L=1);
  Modelica.Electrical.Analog.Basic.Ground ground;
  Modelica.Electrical.Analog.Sources.SineCurrent sineCurrent(I=1, freqHz=1);
equation
  connect(ground.p, resistor.p);
  connect(resistor.p, capacitor.p);
  connect(resistor.n, capacitor.n);
  connect(resistor.n, inductor.p);
  connect(ground.p, sineCurrent.p);
  connect(sineCurrent.n, inductor.n);
end Electrical1;

end IndexReductionTests;