package DISTLib 

  model Binary_Dist
  // Import Modelica SI unit library
    import SI = Modelica.SIunits;
    type MolarFlowRate = Real(quantity = "Molar Flow Rate", unit = "mol/s");
    type Moles = Real(quantity = "Mols", unit = "mol", displayUnit = "mols");
    
  // The model has to be rescaled in order to enable
  // use of SI units.
    
  // Model parameters
    parameter MolarFlowRate Feed = 24/60 "Feed Flow Rate"; //mol/s
    parameter SI.MassFraction x_Feed = 0.5 "Mole Fraction of Feed";
    parameter MolarFlowRate D = x_Feed*Feed "Distillate Flowrate"; //mol/s
    parameter Real vol = 1.6 "Relative Volatility = KA/KB = (yA/xA)/(yB/xB)";
    parameter Moles atray = 0.25 "Total Molar Holdup in the Condenser"; //moles
    parameter Moles acond = 0.5 "Total Molar Holdup on each Tray"; //moles
    parameter Moles areb = 1.0 "Total Molar Holdup in the Reboiler"; //moles
    
  // Algebraic variables
    Real rr "Reflux Ratio (L/D)"; //step change with u1
    MolarFlowRate L "Flowrate of the Liquid in the Rectification Section"; //mol/s
    MolarFlowRate V "Vapor Flowrate in the Column"; //mol/s
    MolarFlowRate FL "Flowrate of the Liquid in the Stripping Section"; //mol/s

    parameter Integer N = 32 "Number of trays";

    SI.MoleFraction y[N](each min=0) "Tray 1 - Vapor Mole Fraction of Component A";	
    
  // Initial values for the states
    parameter Real x_0[N]={0.9,0.9,0.8,0.8,0.7,0.7,0.6,0.6,0.6, 0.5, 0.5,
                                  0.5, 0.5, 0.5, 0.5, 0.5, 0.4, 0.4, 0.4, 0.4, 
                                  0.4, 0.4, 0.3, 0.3, 0.3, 0.2, 0.2, 0.2, 0.1, 
                                  0.1, 0.01, 0};
    
  //Guess Values for steady-state solution to be
    SI.MoleFraction x[N](start = x_0, each min = 0) 
      "Reflux Drum Liquid Mole Fraction of Component A";
    
  // Model inputs
    Modelica.Blocks.Interfaces.RealInput u1(start = 1) 
                                                     annotation (Placement(
             transformation(extent={{-100,20},{-60,60}}), iconTransformation(
               extent={{-100,20},{-60,60}})));
    
  equation 
    rr = u1;
    L = rr*D;
    V = L+D;
    FL = Feed + L;
    
    // Vapor Mole Fractions of Componenent A
    // From the equilibrium assumption and mole balances
    // 1) vol = (yA/xA)/(yB/xB)
    // 2) xA + xB = 1
    // 3) yA + yB = 1
    for i in 1:N loop
       y[i] = (x[i]*vol)/(1+((vol-1)*x[i]));
    end for;
    
    // ODE's
    der(x[1]) = (V*(y[2]-x[1]))/acond;
    for i in 2:16 loop	
      der(x[i]) = ((L*(x[i-1]-x[i]))-(V*(y[i]-y[i+1])))/atray;
    end for;    
    
    der(x[17]) = (D+(L*x[16])-(FL*x[17])-(V*(y[17]-y[18])))/atray;

    for i in 18:31 loop	
      der(x[i]) = ((FL*(x[i-1]-x[i]))-(V*(y[i]-y[i+1])))/atray;
    end for;    

    der(x[32]) = ((FL*x[31])-((Feed-D)*x[32])-(V*y[32]))/areb;
    
  end Binary_Dist;
  
  model Binary_Dist_initial
    extends Binary_Dist;
  initial equation 
  //steady state
  der(x) = zeros(N);
    
  end Binary_Dist_initial;



  package Examples 
    model Simulation 
      Modelica.Blocks.Sources.Step step(
        startTime=60,
        height=-1,
        offset=2.7) 
        annotation (Placement(transformation(extent={{-60,28},{-40,48}})));
      
      Binary_Dist_initial binary_dist_initial 
        annotation (Placement(transformation(extent={{8,-20},{28,0}})));
      
    equation 
      connect(step.y,binary_dist_initial.u1) annotation (Line(
          points={{10,-6},{-16,-6},{-16,38},{-39,38}},
          color={0,0,127},
          smooth=Smooth.None));
    end Simulation;
  end Examples;
end DISTLib;
