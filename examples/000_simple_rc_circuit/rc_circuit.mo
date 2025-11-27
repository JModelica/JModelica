model RCCircuit
  "Simple RC circuit with voltage source"
  
  // Parameters
  parameter Real R = 100 "Resistance in Ohms";
  parameter Real C = 1e-6 "Capacitance in Farads";
  parameter Real V_source = 5.0 "Source voltage in Volts";
  
  // Variables
  Real v(start=0) "Voltage across capacitor";
  Real i "Current through circuit";
  
equation
  // Kirchhoff's voltage law
  V_source = R * i + v;
  
  // Capacitor equation: i = C * dv/dt
  i = C * der(v);
  
  annotation(Documentation(info="<html>
    <p>Simple RC circuit model demonstrating:</p>
    <ul>
      <li>First-order system dynamics</li>
      <li>Exponential charging behavior</li>
      <li>Time constant tau = R*C</li>
    </ul>
  </html>"));
end RCCircuit;
