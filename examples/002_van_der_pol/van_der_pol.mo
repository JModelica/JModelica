model VanDerPolOscillator
  "Van der Pol oscillator with nonlinear damping"
  
  // Parameters
  parameter Real mu = 1.0 "Nonlinearity parameter";
  
  // Variables
  Real x(start=2.0) "Position";
  Real y(start=0.0) "Velocity";
  
equation
  der(x) = y;
  der(y) = mu * (1 - x^2) * y - x;
  
  annotation(Documentation(info="<html>
    <p>Van der Pol oscillator demonstrating:</p>
    <ul>
      <li>Limit cycle behavior</li>
      <li>Nonlinear damping</li>
      <li>Self-sustained oscillations</li>
    </ul>
  </html>"));
end VanDerPolOscillator;
