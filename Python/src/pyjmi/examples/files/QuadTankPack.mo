package QuadTankPack

  model Sim_QuadTank
    QuadTank qt;
    input Real u1 = qt.u1;
    input Real u2 = qt.u2;
  initial equation
  //der(qt.x1) = 0;
  //der(qt.x2) = 0;
    qt.x1 = 0.0627;
    qt.x2 = 0.06044;
    qt.x3 = 0.024;
    qt.x4 = 0.023;
  end Sim_QuadTank;

  model QuadTank
    // Process parameters
	parameter Modelica.SIunits.Area A1=4.9e-4, A2=4.9e-4, A3=4.9e-4, A4=4.9e-4;
	parameter Modelica.SIunits.Area a1(min=1e-6)=0.03e-4, a2=0.03e-4, a3=0.03e-4, a4=0.03e-4;
	parameter Modelica.SIunits.Acceleration g=9.81;
	parameter Real k1_nmp(unit="m^3/s/V") = 0.56e-6, k2_nmp(unit="m^3/s/V") = 0.56e-6;
	parameter Real g1_nmp=0.30, g2_nmp=0.30;

    // Initial tank levels
	parameter Modelica.SIunits.Length x1_0 = 0.04102638;
	parameter Modelica.SIunits.Length x2_0 = 0.06607553;
	parameter Modelica.SIunits.Length x3_0 = 0.00393984;
	parameter Modelica.SIunits.Length x4_0 = 0.00556818;
	
    // Tank levels
	Modelica.SIunits.Length x1(start=x1_0,min=0.0001/*,max=0.20*/);
	Modelica.SIunits.Length x2(start=x2_0,min=0.0001/*,max=0.20*/);
	Modelica.SIunits.Length x3(start=x3_0,min=0.0001/*,max=0.20*/);
	Modelica.SIunits.Length x4(start=x4_0,min=0.0001/*,max=0.20*/);

	// Inputs
	input Modelica.SIunits.Voltage u1;
	input Modelica.SIunits.Voltage u2;

  equation
    der(x1) = -a1/A1*sqrt(2*g*x1) + a3/A1*sqrt(2*g*x3) +
					g1_nmp*k1_nmp/A1*u1;
	der(x2) = -a2/A2*sqrt(2*g*x2) + a4/A2*sqrt(2*g*x4) +
					g2_nmp*k2_nmp/A2*u2;
	der(x3) = -a3/A3*sqrt(2*g*x3) + (1-g2_nmp)*k2_nmp/A3*u2;
	der(x4) = -a4/A4*sqrt(2*g*x4) + (1-g1_nmp)*k1_nmp/A4*u1;

  end QuadTank;

end QuadTankPack;
