model Furuta
	import SI = Modelica.SIunits;
    parameter SI.MomentOfInertia Jp = (m_pa/3 + M)*lp^2;
    parameter SI.MomentOfInertia Ja = 0.00144;
	parameter SI.Length lp = 0.421;
	parameter SI.Length l = (m_pa/2 + M)/(m_pa + M)*lp;
	parameter SI.Mass M = 0.015;
	parameter SI.Length r = 0.245;
	parameter SI.Mass m_pa = 0.02;
	parameter SI.Acceleration g = 9.81;
	
	parameter SI.Angle theta_0 = 0.1;
	parameter SI.AngularVelocity dtheta_0 = 0;
	parameter SI.Angle phi_0 = 0;
	parameter SI.AngularVelocity dphi_0 = 0;
	
	output SI.Angle theta(start=theta_0);
	output SI.AngularVelocity dtheta(start=dtheta_0);
	output SI.Angle phi(start=phi_0);
	output SI.AngularVelocity dphi(start=dphi_0);
	
	input SI.Torque u;
	
protected 
	parameter Real a = Ja + (m_pa + M)*r^2;
	parameter Real b = Jp;
	parameter Real c = (m_pa + M)*r*l;
	parameter Real d = (m_pa + M)*g*l;

equation
	der(theta) = dtheta;
	der(phi) = dphi;
    c*der(dphi)*cos(theta) - b*dphi^2*sin(theta)*cos(theta) + 
		b*der(dtheta) - d*sin(theta) = 0;
	c*der(dtheta)*cos(theta) - c*dtheta^2*sin(theta) + 
		2*b*dtheta*dphi*sin(theta)*cos(theta) + 
		(a + b*sin(theta)^2)*der(dphi) = u;
end Furuta;