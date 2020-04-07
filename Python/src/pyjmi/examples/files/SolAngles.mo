model SolAngles "A model of solar angles with theta as output"

  constant Real pi=Modelica.Constants.pi;

  parameter Real N_day=100.0 "Number of the day";
  Real ex(start = 90.00) "Auxiliary angle";
  Real eq(start = -1.0) "Equation of time";
  parameter Real long=-13.22 "Local meridian (longitude)";
  parameter Real merid=-15.0 "Standard meridian";
  parameter Real lat=55.6 "Latitude";
  parameter Real azim=-90.0 "Surface azimuth (S=0, E=-90, W= 90)";
  parameter Real tilt=90.0 "Surface tilt from horizontal plane";
  Real t_cor(start = 0.0) "Time correction in minutes";
  Real t_sol(start = -200.0) "Solar time in seconds";
  Real w(start = -180.0) "Hour angle";
  Real declin(start = 0.0) "Declination";
  output Real theta(start = 100.0) "Incidence angle to the surface";
  
equation
    
  ex = 360.0*(N_day - 1.0)/365.0;

  eq = 229.2*(0.000075 + 0.001868*Modelica.Math.cos(ex*pi/180.0) - 0.032077*
    Modelica.Math.sin(ex*pi/180.0) - 0.014615*Modelica.Math.cos(2*ex*pi/180.0)
     - 0.04089*Modelica.Math.sin(2*ex*pi/180.0));

  t_cor = 4*(merid - long) + eq;

  t_sol = time + t_cor*60.0;

  w = (t_sol/3600.0 - 12.0)*15.0;

  declin = 23.45*Modelica.Math.sin(pi*2*(284.0 + N_day)/365.0);

  Modelica.Math.cos(theta*(pi/180.0)) = (declin*pi/180.0)*Modelica.Math.sin(w*
    pi/180.0)*Modelica.Math.sin(tilt*pi/180.0)*Modelica.Math.sin(azim*pi/180.0)
     + Modelica.Math.cos(declin*pi/180.0)*Modelica.Math.cos(w*pi/180.0)*
    Modelica.Math.sin(lat*pi/180.0)*Modelica.Math.sin(tilt*pi/180.0)*
    Modelica.Math.cos(azim*pi/180.0) - Modelica.Math.sin(declin*pi/180.0)*
    Modelica.Math.cos(lat*pi/180.0)*Modelica.Math.sin(tilt*pi/180.0)*
    Modelica.Math.cos(azim*pi/180.0) + Modelica.Math.cos(declin*pi/180.0)*
    Modelica.Math.cos(w*pi/180.0)*Modelica.Math.cos(lat*pi/180.0)*
    Modelica.Math.cos(tilt*pi/180.0) + Modelica.Math.sin(declin*pi/180.0)*
    Modelica.Math.sin(lat*pi/180.0)*Modelica.Math.cos(tilt*pi/180.0);
end SolAngles;