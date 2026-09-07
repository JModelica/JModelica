model PendulumModel
  "Simple pendulum with friction"
  
  // Parameters
  parameter Real L = 1.0 "Length of pendulum (m)";
  parameter Real m = 1.0 "Mass (kg)";
  parameter Real g = 9.81 "Gravitational acceleration (m/s^2)";
  parameter Real b = 0.1 "Friction coefficient";
  
  // Variables
  Real theta(start=0.5) "Angle from vertical (rad)";
  Real omega(start=0) "Angular velocity (rad/s)";
  Real E "Total energy (J)";
  
equation
  // Pendulum dynamics
  der(theta) = omega;
  der(omega) = -(g/L) * sin(theta) - b * omega;
  
  // Energy calculation
  E = 0.5 * m * L^2 * omega^2 + m * g * L * (1 - cos(theta));
  
  annotation(Documentation(info="<html>
    <p>Simple pendulum model with friction demonstrating:</p>
    <ul>
      <li>Nonlinear dynamics</li>
      <li>Energy dissipation</li>
      <li>Oscillatory behavior</li>
    </ul>
  </html>"));
end PendulumModel;
