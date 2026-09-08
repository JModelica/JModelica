model LotkaVolterra
  "Predator-Prey model (Lotka-Volterra equations)"
  
  // Parameters
  parameter Real alpha = 1.5 "Prey growth rate";
  parameter Real beta = 1.0 "Predation rate";
  parameter Real gamma = 3.0 "Predator death rate";
  parameter Real delta = 1.0 "Predator growth rate from predation";
  
  // Variables
  Real prey(start=10) "Prey population";
  Real predator(start=5) "Predator population";
  
equation
  der(prey) = alpha * prey - beta * prey * predator;
  der(predator) = delta * prey * predator - gamma * predator;
  
  annotation(Documentation(info="<html>
    <p>Lotka-Volterra predator-prey model demonstrating:</p>
    <ul>
      <li>Population dynamics</li>
      <li>Cyclic behavior</li>
      <li>Ecological interactions</li>
    </ul>
  </html>"));
end LotkaVolterra;
