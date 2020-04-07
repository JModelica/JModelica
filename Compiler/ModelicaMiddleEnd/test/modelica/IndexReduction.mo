/*
    Copyright (C) 2009-2013 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


package IndexReduction

  model IndexReduction1a_PlanarPendulum
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction1a_PlanarPendulum",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction1a_PlanarPendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;
end IndexReduction.IndexReduction1a_PlanarPendulum;
")})));
  end IndexReduction1a_PlanarPendulum;

  model IndexReduction1b_PlanarPendulum
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) + 0 = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction1b_PlanarPendulum",
            description="Test of index reduction. This test exposes a nasty bug caused by rewrites of FDerExp:s in different order.",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction1b_PlanarPendulum
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;
end IndexReduction.IndexReduction1b_PlanarPendulum;
")})));
  end IndexReduction1b_PlanarPendulum;


  model IndexReduction2_Mechanical
    extends Modelica.Mechanics.Rotational.Examples.First(freqHz=5,amplitude=10,
    damper(phi_rel(stateSelect=StateSelect.always),w_rel(stateSelect=StateSelect.always)));


    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction2_Mechanical",
            description="Test of index reduction",
            flatModel="
fclass IndexReduction.IndexReduction2_Mechanical
 parameter Modelica.SIunits.Torque amplitude = 10 \"Amplitude of driving torque\" /* 10 */;
 parameter Modelica.SIunits.Frequency freqHz = 5 \"Frequency of driving torque\" /* 5 */;
 parameter Modelica.SIunits.MomentOfInertia Jmotor(min = 0) = 0.1 \"Motor inertia\" /* 0.1 */;
 parameter Modelica.SIunits.MomentOfInertia Jload(min = 0) = 2 \"Load inertia\" /* 2 */;
 parameter Real ratio = 10 \"Gear ratio\" /* 10 */;
 parameter Real damping = 10 \"Damping in bearing of gear\" /* 10 */;
 parameter Modelica.SIunits.Angle fixed.phi0 = 0 \"Fixed offset angle of housing\" /* 0 */;
 Modelica.SIunits.Torque fixed.flange.tau \"Cut torque in the flange\";
 Modelica.Blocks.Interfaces.RealInput torque.tau(unit = \"N.m\") \"Accelerating torque acting at flange (= -flange.tau)\";
 eval parameter Boolean torque.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
 parameter Modelica.SIunits.MomentOfInertia inertia1.J(min = 0,start = 1) \"Moment of inertia\";
 parameter Real idealGear.ratio(start = 1) \"Transmission ratio (flange_a.phi/flange_b.phi)\";
 parameter StateSelect inertia1.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia1.phi(stateSelect = inertia1.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia1.w(stateSelect = inertia1.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia1.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.MomentOfInertia inertia3.J(min = 0,start = 1) \"Moment of inertia\";
 Modelica.SIunits.Angle idealGear.phi_a \"Angle between left shaft flange and support\";
 Modelica.SIunits.Torque idealGear.flange_a.tau \"Cut torque in the flange\";
 Modelica.SIunits.Torque idealGear.flange_b.tau \"Cut torque in the flange\";
 Modelica.SIunits.Torque idealGear.support.tau \"Reaction torque in the support/housing\";
 Modelica.SIunits.Torque inertia2.flange_b.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.MomentOfInertia inertia2.J(min = 0,start = 1) = 2 \"Moment of inertia\" /* 2 */;
 parameter StateSelect inertia2.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia2.phi(fixed = true,start = 0,stateSelect = inertia2.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia2.w(fixed = true,start = 0,stateSelect = inertia2.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia2.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.RotationalSpringConstant spring.c(final min = 0,start = 100000.0) = 10000.0 \"Spring constant\" /* 10000.0 */;
 parameter Modelica.SIunits.Angle spring.phi_rel0 = 0 \"Unstretched spring angle\" /* 0 */;
 Modelica.SIunits.Angle spring.phi_rel(fixed = true,start = 0) \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
 Modelica.SIunits.Torque spring.tau \"Torque between flanges (= flange_b.tau)\";
 constant Modelica.SIunits.Torque inertia3.flange_b.tau = 0.0 \"Cut torque in the flange\";
 parameter Modelica.SIunits.RotationalDampingConstant damper.d(final min = 0,start = 0) \"Damping constant\";
 parameter StateSelect inertia3.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia3.phi(stateSelect = inertia3.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia3.w(fixed = true,start = 0,stateSelect = inertia3.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia3.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Real sine.amplitude \"Amplitude of sine wave\";
 Modelica.SIunits.Angle damper.phi_rel(stateSelect = StateSelect.always,start = 0,nominal = if damper.phi_nominal >= 1.0E-15 then damper.phi_nominal else 1) \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
 Modelica.SIunits.AngularVelocity damper.w_rel(stateSelect = StateSelect.always,start = 0) \"Relative angular velocity (= der(phi_rel))\";
 Modelica.SIunits.AngularAcceleration damper.a_rel(start = 0) \"Relative angular acceleration (= der(w_rel))\";
 Modelica.SIunits.Torque damper.tau \"Torque between flanges (= flange_b.tau)\";
 parameter Modelica.SIunits.Angle damper.phi_nominal(displayUnit = \"rad\",min = 0.0) = 1.0E-4 \"Nominal value of phi_rel (used for scaling)\" /* 1.0E-4 */;
 parameter StateSelect damper.stateSelect = StateSelect.prefer \"Priority to use phi_rel and w_rel as states\" /* StateSelect.prefer */;
 eval parameter Boolean damper.useHeatPort = false \"=true, if heatPort is enabled\" /* false */;
 Modelica.SIunits.Power damper.lossPower \"Loss power leaving component via heatPort (> 0, if heat is flowing out of component)\";
 parameter Modelica.SIunits.Frequency sine.freqHz(start = 1) \"Frequency of sine wave\";
 parameter Modelica.SIunits.Angle sine.phase = 0 \"Phase of sine wave\" /* 0 */;
 parameter Real sine.offset = 0 \"Offset of output signal\" /* 0 */;
 parameter Modelica.SIunits.Time sine.startTime = 0 \"Output = offset for time < startTime\" /* 0 */;
 parameter Modelica.SIunits.Angle damper.flange_b.phi \"Absolute rotation angle of flange\";
 parameter Modelica.SIunits.Angle fixed.flange.phi \"Absolute rotation angle of flange\";
 parameter Modelica.SIunits.Angle idealGear.support.phi \"Absolute rotation angle of the support/housing\";
 parameter Modelica.SIunits.Angle torque.support.phi \"Absolute rotation angle of the support/housing\";
 Real inertia1._der_phi;
 Real inertia2._der_phi;
 Real idealGear._der_phi_a;
protected
 parameter Modelica.SIunits.Angle torque.phi_support \"Absolute angle of support flange\";
 parameter Modelica.SIunits.Angle idealGear.phi_support \"Absolute angle of support flange\";
initial equation
 inertia2.phi = 0;
 inertia2.w = 0;
 spring.phi_rel = 0;
 inertia3.w = 0;
parameter equation
 inertia1.J = Jmotor;
 idealGear.ratio = ratio;
 inertia3.J = Jload;
 damper.d = damping;
 sine.amplitude = amplitude;
 sine.freqHz = freqHz;
 torque.phi_support = fixed.phi0;
 damper.flange_b.phi = torque.phi_support;
 fixed.flange.phi = torque.phi_support;
 idealGear.support.phi = torque.phi_support;
 torque.support.phi = torque.phi_support;
 idealGear.phi_support = torque.phi_support;
equation
 inertia1.w = inertia1._der_phi;
 inertia1.J * inertia1.a = torque.tau + (- idealGear.flange_a.tau);
 idealGear.phi_a = inertia1.phi - torque.phi_support;
 - damper.phi_rel = inertia2.phi - torque.phi_support;
 idealGear.phi_a = idealGear.ratio * (- damper.phi_rel);
 0 = idealGear.ratio * idealGear.flange_a.tau + idealGear.flange_b.tau;
 inertia2.w = inertia2._der_phi;
 inertia2.J * inertia2.a = - idealGear.flange_b.tau + inertia2.flange_b.tau;
 spring.tau = spring.c * (spring.phi_rel - spring.phi_rel0);
 spring.phi_rel = inertia3.phi - inertia2.phi;
 inertia3.w = der(inertia3.phi);
 inertia3.a = der(inertia3.w);
 inertia3.J * der(inertia3.w) = - spring.tau;
 damper.tau = damper.d * der(damper.phi_rel);
 damper.lossPower = damper.tau * der(damper.phi_rel);
 damper.w_rel = der(damper.phi_rel);
 damper.a_rel = der(damper.w_rel);
 torque.tau = sine.offset + (if time < sine.startTime then 0 else sine.amplitude * sin(6.283185307179586 * sine.freqHz * (time - sine.startTime) + sine.phase));
 - damper.tau + inertia2.flange_b.tau + (- spring.tau) = 0.0;
 damper.tau + fixed.flange.tau + idealGear.support.tau + torque.tau = 0.0;
 idealGear.support.tau = - idealGear.flange_a.tau - idealGear.flange_b.tau;
 - der(damper.phi_rel) = inertia2._der_phi;
 der(damper.w_rel) = - inertia2.a;
 idealGear._der_phi_a = inertia1._der_phi;
 idealGear._der_phi_a = idealGear.ratio * (- der(damper.phi_rel));
 inertia1.a = idealGear.ratio * inertia2.a;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

 type Modelica.SIunits.Torque = Real(final quantity = \"Torque\",final unit = \"N.m\");
 type Modelica.SIunits.Frequency = Real(final quantity = \"Frequency\",final unit = \"Hz\");
 type Modelica.SIunits.MomentOfInertia = Real(final quantity = \"MomentOfInertia\",final unit = \"kg.m2\");
 type Modelica.SIunits.Angle = Real(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\");
 type Modelica.Blocks.Interfaces.RealInput = Real;
 type Modelica.SIunits.AngularVelocity = Real(final quantity = \"AngularVelocity\",final unit = \"rad/s\");
 type Modelica.SIunits.AngularAcceleration = Real(final quantity = \"AngularAcceleration\",final unit = \"rad/s2\");
 type Modelica.SIunits.RotationalSpringConstant = Real(final quantity = \"RotationalSpringConstant\",final unit = \"N.m/rad\");
 type Modelica.SIunits.RotationalDampingConstant = Real(final quantity = \"RotationalDampingConstant\",final unit = \"N.m.s/rad\");
 type Modelica.SIunits.Power = Real(final quantity = \"Power\",final unit = \"W\");
 type Modelica.SIunits.Time = Real(final quantity = \"Time\",final unit = \"s\");
 type Modelica.Blocks.Interfaces.RealOutput = Real;
end IndexReduction.IndexReduction2_Mechanical;
")})));
  end IndexReduction2_Mechanical;

  model IndexReduction3_Electrical
  parameter Real omega=100;
  parameter Real R[2]={10,5};
  parameter Real L=1;
  parameter Real C=0.05;
  Real iL (start=1);
  Real uC (start=1);
  Real u0,u1,u2,uL;
  Real i0,i1,i2,iC;
equation
  u0=220*sin(time*omega);
  u1=R[1]*i1;
  u2=R[2]*i2;
  uL=L*der(iL);
  iC=C*der(uC);
  u0= u1+uL;
  uC=u1+u2;
  uL=u2;
  i0=i1+iC;
  i1=i2+iL;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction3_Electrical",
			description="Test of index reduction",
			flatModel="
fclass IndexReduction.IndexReduction3_Electrical
 parameter Real omega = 100 /* 100 */;
 parameter Real R[1] = 10 /* 10 */;
 parameter Real R[2] = 5 /* 5 */;
 parameter Real L = 1 /* 1 */;
 parameter Real C = 0.05 /* 0.05 */;
 Real iL(start = 1);
 Real uC(start = 1);
 Real u1;
 Real uL;
 Real i0;
 Real i1;
 Real i2;
 Real iC;
 Real _der_uC;
initial equation 
 iL = 1;
equation
 uC = 220 * sin(time * omega);
 u1 = R[1] * i1;
 uL = R[2] * i2;
 uL = L * der(iL);
 iC = C * _der_uC;
 uC = u1 + uL;
 i0 = i1 + iC;
 i1 = i2 + iL;
 _der_uC = 220 * (cos(time * omega) * omega);
end IndexReduction.IndexReduction3_Electrical;
")})));
  end IndexReduction3_Electrical;

model IndexReduction4_Err
  function F
    input Real x;
    output Real y;
  algorithm
    y := sin(x);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IndexReduction4_Err",
            description="Test error messages for unbalanced systems.",
            inline_functions="none",
            errorMessage="
1 errors found:

Error in flattened model:
  Cannot differentiate call to function without derivative or smooth order annotation 'IndexReduction.IndexReduction4_Err.F(x2)' in equation:
   x1 + IndexReduction.IndexReduction4_Err.F(x2) = 1
")})));
end IndexReduction4_Err;

model IndexReduction5_Err
  function F
    input Real x;
    output Real y1;
    output Real y2;
  algorithm
    y1 := sin(x);
    y1 := cos(x);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  (x1,x2) = F(x2); 

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IndexReduction5_Err",
            description="Test error messages for unbalanced systems.",
            errorMessage="
1 errors found:

Error in flattened model:
  Cannot differentiate call to function without derivative or smooth order annotation 'IndexReduction.IndexReduction5_Err.F(x2)' in equation:
   (x1, x2) = IndexReduction.IndexReduction5_Err.F(x2)
")})));
end IndexReduction5_Err;

  model IndexReduction23_BasicVolume_Err
import Modelica.SIunits.*;
parameter SpecificInternalEnergy u_0 = 209058;
parameter SpecificHeatCapacity c_v = 717;
parameter Temperature T_0 = 293;
parameter Mass m_0 = 0.00119;
parameter SpecificHeatCapacity R = 287;
Pressure P;
Volume V;
Mass m(start=m_0);
Temperature T;
MassFlowRate mdot_in;
MassFlowRate mdot_out;
SpecificEnthalpy h_in, h_out;
SpecificEnthalpy h;
Enthalpy H;
SpecificInternalEnergy u;
InternalEnergy U(start=u_0*m_0);
equation

// Boundary equations
V=1e-3;
T=293;
mdot_in=0.1e-3;
mdot_out=0.01e-3;
h_in = 300190;
h_out = h;

// Conservation of mass
der(m) = mdot_in-mdot_out;

// Conservation of energy
der(U) = h_in*mdot_in - h_out*mdot_out;

// Specific internal energy (ideal gas)
u = U/m;
u = u_0+c_v*(T-T_0);

// Specific enthalpy
H = U+P*V;
h = H/m;

// Equation of state (ideal gas)
P*V=m*R*T;  

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IndexReduction23_BasicVolume_Err",
            description="Test error messages for unbalanced systems.",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error in flattened model:
  Index reduction failed: Maximum number of differentiations has been reached

Error in flattened model:
  The system is structurally singular. The following equation(s) could not be matched to any variable:
    u = u_0 + c_v * (T - T_0)

")})));
  end IndexReduction23_BasicVolume_Err;

        model IndexReduction27_DerFunc
            function f
                input Real x[2];
                input Real A[2,2];
                output Real y[2];
            algorithm
                y := A*x;
            annotation(derivative=f_der);
            end f;

            function f_der
                input Real x[2];
                input Real A[2,2];
                input Real der_x[2];
                input Real der_A[2,2];
                output Real der_y[2];
            algorithm
                der_y := A*der_x;
            end f_der;

  parameter Real A[2,2] = {{1,2},{3,4}};
  Real x1[2],x2[2](each stateSelect=StateSelect.prefer);
equation
  der(x1) + der(x2) = {2,3};
  x1 + f(x2,A) = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction27_DerFunc",
            description="Test of index reduction",
            inline_functions="none",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction27_DerFunc
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1];
 Real x1[2];
 Real x2[1](stateSelect = StateSelect.prefer);
 Real x2[2](stateSelect = StateSelect.prefer);
 Real _der_x1[1];
 Real _der_x1[2];
 Real temp_6;
 Real temp_7;
 Real temp_10;
 Real temp_11;
initial equation
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 _der_x1[1] + der(x2[1]) = 2;
 _der_x1[2] + der(x2[2]) = 3;
 ({temp_6, temp_7}) = IndexReduction.IndexReduction27_DerFunc.f({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 - x1[1] = temp_6;
 - x1[2] = temp_7;
 ({temp_10, temp_11}) = IndexReduction.IndexReduction27_DerFunc.f_der({x2[1], x2[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2[1]), der(x2[2])}, {{0.0, 0.0}, {0.0, 0.0}});
 - _der_x1[1] = temp_10;
 - _der_x1[2] = temp_11;

public
 function IndexReduction.IndexReduction27_DerFunc.f
  input Real[:] x;
  input Real[:,:] A;
  output Real[:] y;
  Real[:] temp_1;
  Real temp_2;
 algorithm
  init y as Real[2];
  init temp_1 as Real[2];
  for i1 in 1:2 loop
   temp_2 := 0.0;
   for i2 in 1:2 loop
    temp_2 := temp_2 + A[i1,i2] * x[i2];
   end for;
   temp_1[i1] := temp_2;
  end for;
  for i1 in 1:2 loop
   y[i1] := temp_1[i1];
  end for;
  return;
 annotation(derivative = IndexReduction.IndexReduction27_DerFunc.f_der);
 end IndexReduction.IndexReduction27_DerFunc.f;

 function IndexReduction.IndexReduction27_DerFunc.f_der
  input Real[:] x;
  input Real[:,:] A;
  input Real[:] der_x;
  input Real[:,:] der_A;
  output Real[:] der_y;
  Real[:] temp_1;
  Real temp_2;
 algorithm
  init der_y as Real[2];
  init temp_1 as Real[2];
  for i1 in 1:2 loop
   temp_2 := 0.0;
   for i2 in 1:2 loop
    temp_2 := temp_2 + A[i1,i2] * der_x[i2];
   end for;
   temp_1[i1] := temp_2;
  end for;
  for i1 in 1:2 loop
   der_y[i1] := temp_1[i1];
  end for;
  return;
 end IndexReduction.IndexReduction27_DerFunc.f_der;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction27_DerFunc;
")})));
end IndexReduction27_DerFunc;

model IndexReduction28_Record
record R
    Real[2] a;
end R;

function f
  input Real x[2];
  input Real A[2,2];
  output R y;
algorithm
  y := R(A*x);
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real A[2,2];
  input Real der_x[2];
  input Real der_A[2,2];
  output R der_y;
algorithm
  der_y := R(A*der_x);
end f_der;

  parameter Real A[2,2] = {{1,2},{3,4}};
  R x1(a(stateSelect={StateSelect.prefer,StateSelect.default})),x2(a(stateSelect={StateSelect.prefer,StateSelect.default})),x3;
equation
  der(x1.a) + der(x2.a) = {2,3};
  x1.a + x3.a = {0,0};
  x3 = f(x2.a,A);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction28_Record",
            description="Index reduction: function with record input & output",
            inline_functions="none",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction28_Record
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1.a[1](stateSelect = StateSelect.prefer);
 Real x1.a[2](stateSelect = StateSelect.default);
 Real x2.a[1](stateSelect = StateSelect.prefer);
 Real x2.a[2](stateSelect = StateSelect.default);
 Real x1._der_a[2];
 Real x2._der_a[2];
 Real temp_6;
 Real temp_7;
 Real _der_temp_6;
 Real temp_9;
initial equation
 x1.a[1] = 0.0;
 x2.a[1] = 0.0;
equation
 der(x1.a[1]) + der(x2.a[1]) = 2;
 x1._der_a[2] + x2._der_a[2] = 3;
 (IndexReduction.IndexReduction28_Record.R({temp_6, temp_7})) = IndexReduction.IndexReduction28_Record.f({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}});
 - x1.a[1] = temp_6;
 - x1.a[2] = temp_7;
 (IndexReduction.IndexReduction28_Record.R({_der_temp_6, temp_9})) = IndexReduction.IndexReduction28_Record.f_der({x2.a[1], x2.a[2]}, {{A[1,1], A[1,2]}, {A[2,1], A[2,2]}}, {der(x2.a[1]), x2._der_a[2]}, {{0.0, 0.0}, {0.0, 0.0}});
 - der(x1.a[1]) = _der_temp_6;
 - x1._der_a[2] = temp_9;

public
 function IndexReduction.IndexReduction28_Record.f
  input Real[:] x;
  input Real[:,:] A;
  output IndexReduction.IndexReduction28_Record.R y;
  Real[:] temp_1;
  Real temp_2;
 algorithm
  init temp_1 as Real[2];
  for i1 in 1:2 loop
   temp_2 := 0.0;
   for i2 in 1:2 loop
    temp_2 := temp_2 + A[i1,i2] * x[i2];
   end for;
   temp_1[i1] := temp_2;
  end for;
  for i1 in 1:2 loop
   y.a[i1] := temp_1[i1];
  end for;
  return;
 annotation(derivative = IndexReduction.IndexReduction28_Record.f_der);
 end IndexReduction.IndexReduction28_Record.f;

 function IndexReduction.IndexReduction28_Record.f_der
  input Real[:] x;
  input Real[:,:] A;
  input Real[:] der_x;
  input Real[:,:] der_A;
  output IndexReduction.IndexReduction28_Record.R der_y;
  Real[:] temp_1;
  Real temp_2;
 algorithm
  init temp_1 as Real[2];
  for i1 in 1:2 loop
   temp_2 := 0.0;
   for i2 in 1:2 loop
    temp_2 := temp_2 + A[i1,i2] * der_x[i2];
   end for;
   temp_1[i1] := temp_2;
  end for;
  for i1 in 1:2 loop
   der_y.a[i1] := temp_1[i1];
  end for;
  return;
 end IndexReduction.IndexReduction28_Record.f_der;

 record IndexReduction.IndexReduction28_Record.R
  Real a[2];
 end IndexReduction.IndexReduction28_Record.R;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction28_Record;
")})));
end IndexReduction28_Record;


  model IndexReduction30_PlanarPendulum_StatePrefer
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction30_PlanarPendulum_StatePrefer",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction30_PlanarPendulum_StatePrefer
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vy;
 Real _der_der_x;
initial equation
 x = 0.0;
 vx = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 der(vx) = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 _der_der_x = der(vx);
 2 * x * _der_der_x + 2 * der(x) * der(x) + (2 * y * _der_vy + 2 * _der_y * _der_y) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction30_PlanarPendulum_StatePrefer;
")})));
  end IndexReduction30_PlanarPendulum_StatePrefer;

model IndexReduction31_PlanarPendulum_StateAlways
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.always) "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.always) "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
    

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction31_PlanarPendulum_StateAlways",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction31_PlanarPendulum_StateAlways
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.always) \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.always) \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vy;
 Real _der_der_x;
initial equation
 x = 0.0;
 vx = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 der(vx) = lambda * x;
 _der_vy = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 _der_der_x = der(vx);
 2 * x * _der_der_x + 2 * der(x) * der(x) + (2 * y * _der_vy + 2 * _der_y * _der_y) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction31_PlanarPendulum_StateAlways;
")})));
  end IndexReduction31_PlanarPendulum_StateAlways;

  model IndexReduction32_PlanarPendulum_StatePreferAlways
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y(stateSelect=StateSelect.always) "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy(stateSelect=StateSelect.always) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction32_PlanarPendulum_StatePreferAlways",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction32_PlanarPendulum_StatePreferAlways
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
 Real y(stateSelect = StateSelect.always) \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
 Real vy(stateSelect = StateSelect.always) \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction32_PlanarPendulum_StatePreferAlways;
")})));
  end IndexReduction32_PlanarPendulum_StatePreferAlways;

  model IndexReduction32_PlanarPendulum_StatePreferNever
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y(stateSelect=StateSelect.never) "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy(stateSelect=StateSelect.always) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction32_PlanarPendulum_StatePreferNever",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction32_PlanarPendulum_StatePreferNever
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
 Real y(stateSelect = StateSelect.never) \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
 Real vy(stateSelect = StateSelect.always) \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_y;
 Real _der_vx;
 Real _der_der_y;
initial equation
 x = 0.0;
 vy = 0.0;
equation
 der(x) = vx;
 _der_y = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * der(x) + 2 * y * _der_y = 0.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * der(x) * der(x) + (2 * y * _der_der_y + 2 * _der_y * _der_y) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction32_PlanarPendulum_StatePreferNever;
")})));
  end IndexReduction32_PlanarPendulum_StatePreferNever;

model IndexReduction32_PlanarPendulum_StateAvoidNever
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.never) "Cartesian x coordinate";
    Real y(stateSelect=StateSelect.avoid) "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.avoid) "Velocity in x coordinate";
    Real vy(stateSelect=StateSelect.avoid) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction32_PlanarPendulum_StateAvoidNever",
            description="Test of index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction32_PlanarPendulum_StateAvoidNever
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.never) \"Cartesian x coordinate\";
 Real y(stateSelect = StateSelect.avoid) \"Cartesian x coordinate\";
 Real vx(stateSelect = StateSelect.avoid) \"Velocity in x coordinate\";
 Real vy(stateSelect = StateSelect.avoid) \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction32_PlanarPendulum_StateAvoidNever;
")})));
end IndexReduction32_PlanarPendulum_StateAvoidNever;

model IndexReduction50
	parameter StateSelect c1_ss = StateSelect.default; 
	parameter StateSelect c2_ss = StateSelect.never; 
	parameter Real p = 0;
	Real c1_phi(stateSelect=c1_ss), c1_w(stateSelect=c1_ss), c1_a;
	Real c2_phi(stateSelect=c2_ss), c2_w(stateSelect=c2_ss), c2_a;
equation
	c1_phi = c2_phi;
	c1_w = der(c1_phi);
	c1_a = der(c1_w);
	c2_w = der(c1_phi);
	c2_a = der(c2_w);
	c2_a * p = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction50",
            description="Test of index reduction of differentiated variables with StateSelect.never",
            flatModel="
fclass IndexReduction.IndexReduction50
 parameter StateSelect c1_ss = StateSelect.default /* StateSelect.default */;
 parameter StateSelect c2_ss = StateSelect.never /* StateSelect.never */;
 parameter Real p = 0 /* 0 */;
 Real c1_phi(stateSelect = c1_ss);
 Real c1_w(stateSelect = c1_ss);
 Real c1_a;
 Real c2_w(stateSelect = c2_ss);
 Real c2_a;
initial equation
 c1_phi = 0.0;
 c1_w = 0.0;
equation
 c1_w = der(c1_phi);
 c1_a = der(c1_w);
 c2_w = der(c1_phi);
 c2_a * p = 0;
 der(c1_w) = c2_a;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction50;
")})));
end IndexReduction50;

model IndexReduction51
    parameter StateSelect c1_ss = StateSelect.default; 
    parameter StateSelect c2_ss = StateSelect.never; 
    parameter Real p = 0;
    Real c1_phi, c1_w(stateSelect=c1_ss), c1_a;
    Real c2_phi, c2_w(stateSelect=c2_ss), c2_a;
    Real x(start = 2);
    Real y;
equation
    y = 0*time;
    c1_phi = x - y;
    c1_phi = c2_phi;
    c1_w = der(c1_phi);
    c1_a = der(c1_w);
    c2_w = der(c2_phi);
    c2_a = der(c2_w);
    c2_a * p = 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction51",
            description="Test of complicated index reduction, alias elimination, expression simplification and variability propagation issue",
            flatModel="
fclass IndexReduction.IndexReduction51
 parameter StateSelect c1_ss = StateSelect.default /* StateSelect.default */;
 parameter StateSelect c2_ss = StateSelect.never /* StateSelect.never */;
 parameter Real p = 0 /* 0 */;
 Real c1_w(stateSelect = c1_ss);
 Real c1_a;
 Real c2_w(stateSelect = c2_ss);
 Real c2_a;
 Real x(start = 2);
 constant Real y = 0;
initial equation
 x = 2;
 c1_w = 0.0;
equation
 c1_w = der(x);
 c1_a = der(c1_w);
 c2_w = der(x);
 c2_a * p = 0;
 der(c1_w) = c2_a;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction51;
")})));
end IndexReduction51;

model IndexReduction52
    function F
        input Real v;
        input Real x;
        input Real y;
        input Real z;
        output Real ax;
        output Real ay;
    algorithm
        ax := v * z + x;
        ay := v * z + y;
    end F;
    Real x;
    Real y;
    Real dx;
    Real dy;
    Real v, a,b;
  equation
    sin(der(x)) = dx;
    cos(der(y)) = dy;
    der(dx) = v * x;
    der(dy) = v * y;
    a*b = 1;
    (a,b) = F(x + 3.14, 42, y, time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction52",
            description="Test of complicated index reduction, alias elimination and function inlining. temp_1 and _der_temp_1 is the smoking gun in this test",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.IndexReduction52
 Real x;
 Real y;
 Real dx;
 Real dy;
 Real v;
 Real a;
 Real b;
 Real _der_x;
 Real _der_y;
 Real _der_dy;
 Real _der_a;
 Real _der_der_x;
 Real _der_der_y;
 Real _der_der_a;
 Real _der_der_b;
 Real temp_1;
 Real temp_4;
 Real _der_temp_4;
 Real _der_der_temp_4;
initial equation
 dx = 0.0;
 b = 0.0;
equation
 sin(_der_x) = dx;
 cos(_der_y) = dy;
 der(dx) = v * x;
 _der_dy = v * y;
 a * b = 1;
 temp_1 = x + 3.14;
 temp_4 = time;
 a = temp_1 * temp_4 + 42;
 b = temp_1 * temp_4 + y;
 a * der(b) + _der_a * b = 0;
 _der_temp_4 = 1.0;
 _der_a = temp_1 * _der_temp_4 + _der_x * temp_4;
 der(b) = temp_1 * _der_temp_4 + _der_x * temp_4 + _der_y;
 cos(_der_x) * _der_der_x = der(dx);
 - sin(_der_y) * _der_der_y = _der_dy;
 a * _der_der_b + _der_a * der(b) + (_der_a * der(b) + _der_der_a * b) = 0;
 _der_der_temp_4 = 0.0;
 _der_der_a = temp_1 * _der_der_temp_4 + _der_x * _der_temp_4 + (_der_x * _der_temp_4 + _der_der_x * temp_4);
 _der_der_b = temp_1 * _der_der_temp_4 + _der_x * _der_temp_4 + (_der_x * _der_temp_4 + _der_der_x * temp_4) + _der_der_y;
end IndexReduction.IndexReduction52;
")})));
end IndexReduction52;

model NonDifferentiatedVariableWithPrefer
    Real x,y(stateSelect=StateSelect.prefer);
equation
    der(x) = -x;
    y=100*x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDifferentiatedVariableWithPrefer",
            description="Test of system with non differentiated variable with StateSelect always and prefer",
            flatModel="
fclass IndexReduction.NonDifferentiatedVariableWithPrefer
 Real x;
 Real y(stateSelect = StateSelect.prefer);
 Real _der_x;
initial equation 
 y = 0.0;
equation
 _der_x = - x;
 y = 100 * x;
 der(y) = 100 * _der_x;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.NonDifferentiatedVariableWithPrefer;
")})));
end NonDifferentiatedVariableWithPrefer;

model NonDifferentiatedVariableWithPreferWithoutIndexReduction
    Real x,y(stateSelect=StateSelect.prefer);
equation
    der(x) = -x;
    y=100*x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDifferentiatedVariableWithPreferWithoutIndexReduction",
            description="Test of system with non differentiated variable with StateSelect always and prefer but index reduction disabled",
            index_reduction=false,
            flatModel="
fclass IndexReduction.NonDifferentiatedVariableWithPreferWithoutIndexReduction
 Real x;
 Real y(stateSelect = StateSelect.prefer);
initial equation
 x = 0.0;
equation
 der(x) = - x;
 y = 100 * x;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.NonDifferentiatedVariableWithPreferWithoutIndexReduction;
")})));
end NonDifferentiatedVariableWithPreferWithoutIndexReduction;

model IndexReduction53b
    function F
        input Real i;
        output Real o;
    algorithm
        o := i * 42;
        annotation(Inline=false);
    end F;
    Real x,y(stateSelect=StateSelect.prefer);
    Real a,b(stateSelect=StateSelect.prefer);
equation
    der(x) = -x;
    y=100*x;
    
    der(a) = -a;
    b=F(a);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction53b",
            description="Test of system with non differentiated variable with StateSelect always and prefer",
            flatModel="
fclass IndexReduction.IndexReduction53b
 Real x;
 Real y(stateSelect = StateSelect.prefer);
 Real a;
 Real b(stateSelect = StateSelect.prefer);
 Real _der_x;
initial equation 
 a = 0.0;
 y = 0.0;
equation
 _der_x = - x;
 y = 100 * x;
 der(a) = - a;
 b = IndexReduction.IndexReduction53b.F(a);
 der(y) = 100 * _der_x;

public
 function IndexReduction.IndexReduction53b.F
  input Real i;
  output Real o;
 algorithm
  o := i * 42;
  return;
 annotation(Inline = false);
 end IndexReduction.IndexReduction53b.F;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction53b;
")})));
end IndexReduction53b;

model IndexReduction54
    Real x(stateSelect=StateSelect.always),y(stateSelect=StateSelect.prefer);
equation
    der(x) = -x;
    y=100*x;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction54",
            description="Test of system with non differentiated variable with StateSelect always and prefer",
            flatModel="
fclass IndexReduction.IndexReduction54
 Real x(stateSelect = StateSelect.always);
 Real y(stateSelect = StateSelect.prefer);
 Real _der_y;
initial equation 
 x = 0.0;
equation
 der(x) = - x;
 y = 100 * x;
 _der_y = 100 * der(x);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction54;
")})));
end IndexReduction54;

model SSPreferBackoff1
    function f
        input Real a;
        input Real b;
        output Real d = a + b;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real x(stateSelect = StateSelect.prefer);
    Real y(stateSelect = StateSelect.prefer);
equation
    x = y - 1;
    0 = f(x, y);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="SSPreferBackoff1",
            description="Test of system with non differentiated variable with StateSelect prefer and see if backoff works when it fails",
            flatModel="
fclass IndexReduction.SSPreferBackoff1
 Real x(stateSelect = StateSelect.prefer);
 Real y(stateSelect = StateSelect.prefer);
equation
 x = y - 1;
 0 = IndexReduction.SSPreferBackoff1.f(x, y);

public
 function IndexReduction.SSPreferBackoff1.f
  input Real a;
  input Real b;
  output Real d;
 algorithm
  d := a + b;
  return;
 annotation(Inline = false);
 end IndexReduction.SSPreferBackoff1.f;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.SSPreferBackoff1;
")})));
end SSPreferBackoff1;

model SSPreferBackoff2
    function f
        input Real a;
        output Real b = a * 42;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real x(stateSelect = StateSelect.prefer),y,z;
equation
    0 = f(x);
    x = y * 3.12;
    z = der(y);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="SSPreferBackoff2",
            description="Test of system with non differentiated variable with StateSelect prefer that is differentiated by equation dependency. Check so that no infinite loop occures.",
            errorMessage="
1 errors found:

Error in flattened model:
  Cannot differentiate call to function without derivative or smooth order annotation 'IndexReduction.SSPreferBackoff2.f(x)' in equation:
   0 = IndexReduction.SSPreferBackoff2.f(x)
")})));
end SSPreferBackoff2;

model IndexReduction55
    Real a_s;
    Real a_v(stateSelect = StateSelect.always);
    Real a_a;
    Real b_s;
    Real b_v;
    Real v1;
equation
    b_s = a_s - 3.14;
    a_v = der(a_s);
    a_a = der(a_v);
    b_v = b_s;
    v1 = 42 * (b_s - 3.14);
    21 = v1 * b_v;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction55",
            description="Test of indexreduction with SS always",
            flatModel="
fclass IndexReduction.IndexReduction55
 Real a_s;
 Real a_v(stateSelect = StateSelect.always);
 Real a_a;
 Real b_v;
 Real v1;
 Real _der_a_s;
 Real _der_b_v;
 Real _der_v1;
 Real _der_der_v1;
equation
 b_v = a_s - 3.14;
 a_v = _der_a_s;
 v1 = 42 * (b_v - 3.14);
 21 = v1 * b_v;
 _der_b_v = _der_a_s;
 _der_v1 = 42 * _der_b_v;
 0 = v1 * _der_b_v + _der_v1 * b_v;
 _der_der_v1 = 42 * a_a;
 0 = v1 * a_a + _der_v1 * _der_b_v + (_der_v1 * _der_b_v + _der_der_v1 * b_v);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction55;
")})));
end IndexReduction55;

model IndexReduction56
    Real a_s(stateSelect = StateSelect.always);
    Real a_v;
    Real a_a;
    Real b_s;
    Real b_v;
    Real v1;
equation
    b_s = a_s - 3.14;
    a_v = der(a_s);
    a_a = der(a_v);
    b_v = b_s;
    v1 = 42 * (b_s - 3.14);
    21 = v1 * b_v;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IndexReduction56",
            description="Test of indexreduction with SS always",
            flatModel="
fclass IndexReduction.IndexReduction56
 Real a_s(stateSelect = StateSelect.always);
 Real a_v;
 Real a_a;
 Real b_v;
 Real v1;
 Real _der_a_s;
 Real _der_b_v;
 Real _der_v1;
 Real _der_der_v1;
equation
 b_v = a_s - 3.14;
 a_v = _der_a_s;
 v1 = 42 * (b_v - 3.14);
 21 = v1 * b_v;
 _der_b_v = _der_a_s;
 _der_v1 = 42 * _der_b_v;
 0 = v1 * _der_b_v + _der_v1 * b_v;
 _der_der_v1 = 42 * a_a;
 0 = v1 * a_a + _der_v1 * _der_b_v + (_der_v1 * _der_b_v + _der_der_v1 * b_v);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.IndexReduction56;
")})));
end IndexReduction56;

model TemporaryVarStates1
    function f
        input Real x[2];
        input Real A[2,2];
        output Real y[2];
    algorithm
        y := A*x;
    annotation(derivative=f_der,LateInline=true);
    end f;

    function f_der
        input Real x[2];
        input Real A[2,2];
        input Real der_x[2];
        input Real der_A[2,2];
        output Real der_y[2];
    algorithm
        der_y := A*der_x;
    annotation(LateInline=true);
    end f_der;

    parameter Real A[2,2] = {{1,2},{3,4}};
    Real x1[2](each stateSelect=StateSelect.never),x2[2](each stateSelect=StateSelect.never);
equation
    der(x1) + der(x2) = {2,3};
    x1 + f(x2,A) = {0,0};

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TemporaryVarStates1",
            description="Test so that the compiler handles temporary variables as states",
            flatModel="
fclass IndexReduction.TemporaryVarStates1
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1](stateSelect = StateSelect.never);
 Real x1[2](stateSelect = StateSelect.never);
 Real x2[1](stateSelect = StateSelect.never);
 Real x2[2](stateSelect = StateSelect.never);
 Real _der_x1[1];
 Real _der_x2[1];
 Real _der_x1[2];
 Real _der_x2[2];
 Real temp_6;
 Real temp_7;
initial equation
 temp_6 = 0.0;
 temp_7 = 0.0;
equation
 _der_x1[1] + _der_x2[1] = 2;
 _der_x1[2] + _der_x2[2] = 3;
 temp_6 = A[1,1] * x2[1] + A[1,2] * x2[2];
 temp_7 = A[2,1] * x2[1] + A[2,2] * x2[2];
 - x1[1] = temp_6;
 - x1[2] = temp_7;
 der(temp_6) = A[1,1] * _der_x2[1] + A[1,2] * _der_x2[2];
 der(temp_7) = A[2,1] * _der_x2[1] + A[2,2] * _der_x2[2];
 - _der_x1[1] = der(temp_6);
 - _der_x1[2] = der(temp_7);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.TemporaryVarStates1;
")})));
end TemporaryVarStates1;

model IndexReduction57
    Real a_s;
    Real a_v(stateSelect = StateSelect.always);
    Real a_a;
    Real b_s;
    Real b_v;
    Real v1;
equation
    b_s = a_s - 3.14;
    a_v = der(a_s);
    a_a = der(a_v);
    b_v = b_s;
    v1 = 42 * (b_s - 3.14);
    21 = v1 * b_v;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="IndexReduction57",
            description="Test warnings for state select.",
            automatic_tearing=false,
            errorMessage="
3 errors found:

Warning at line 3, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/IndexReduction.mo':
  a_v has stateSelect=always, but could not be selected as state

Warning at line 6, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/IndexReduction.mo':
  Iteration variable \"b_v\" is missing start value!

Warning at line 7, column 5, in file 'Compiler/ModelicaMiddleEnd/test/modelica/IndexReduction.mo':
  Iteration variable \"v1\" is missing start value!
")})));
end IndexReduction57;

model IndexReduction58
    Real y, x;
equation
    der(y) = der(x);
    y = abs(x);

annotation(__JModelica(UnitTesting(tests={
    CCodeGenTestCase(
        name="IndexReduction58",
        description="Code generation of diffed abs expression",
        template="$C_dae_blocks_residual_functions$",
        generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _der_x_3;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_JACOBIAN) {
            jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
            jmi_real_t* Q3 = residual;
            int i;
            char trans = 'N';
            double alpha = -1;
            double beta = 1;
            int n1 = 1;
            int n2 = 1;
            Q1[0] = - COND_EXP_EQ(_sw(0), JMI_TRUE, 1.0, -1.0);
            for (i = 0; i < 1; i += 1) {
                Q1[i + 0] = (Q1[i + 0]) / (1.0);
            }
            Q2[0] = 1.0;
            memset(Q3, 0, 1 * sizeof(jmi_real_t));
            Q3[0] = -1.0;
            dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
            free(Q1);
            free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _der_x_3 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch(jmi, _x_1 - (0.0), _sw(0), JMI_REL_GEQ);
        }
        _der_y_2 = COND_EXP_EQ(_sw(0), JMI_TRUE, _der_x_3, - _der_x_3);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _der_x_3 - (_der_y_2);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end IndexReduction58;

  model AlgorithmVariability1
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
    Integer i;
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
algorithm
    if y < 3.12 then
        i := 1;
    else
        i := -1;
    end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmVariability1",
            description="Test so that variability calculations are done properly for algorithms",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.AlgorithmVariability1
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x \"Cartesian x coordinate\";
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 discrete Integer i;
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
 pre(i) = 0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
algorithm
 if y < 3.12 then
  i := 1;
 else
  i := -1;
 end if;
equation
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;
end IndexReduction.AlgorithmVariability1;
")})));
  end AlgorithmVariability1;

  model AlgorithmVariability2
    Real x;
    Real y;
    Real z;
    parameter Integer p = 1;
    parameter Integer[:] it = {1};
    parameter Real[:] rt = {2.0};
equation
    // Trigger index reduction
    y = time;
    z = x + der(y);
algorithm
    x := if it[1] == p then rt[1] else 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmVariability2",
            description="Test so that variability calculations are done properly for algorithms",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.AlgorithmVariability2
 Real x;
 Real y;
 Real z;
 parameter Integer p = 1 /* 1 */;
 parameter Integer it[1] = 1 /* 1 */;
 parameter Real rt[1] = 2.0 /* 2.0 */;
 Real _der_y;
equation
 y = time;
 z = x + _der_y;
algorithm
 x := if it[1] == p then rt[1] else 0;
equation
 _der_y = 1.0;
end IndexReduction.AlgorithmVariability2;
")})));
  end AlgorithmVariability2;

  model AlgorithmVariability3
    Real y;
    Real x;
    Real z;
equation
    // Trigger index reduction
    y = time * 2;
    z = x + der(y);
algorithm
    when time > 0.25 then
        x := y / 2;
    end when;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmVariability3",
            description="Test so that variability calculations are done properly for algorithms, it should honor in discrete location",
            flatModel="
fclass IndexReduction.AlgorithmVariability3
 Real y;
 discrete Real x;
 Real z;
 discrete Boolean temp_1;
 Real _der_y;
initial equation
 pre(x) = 0.0;
 pre(temp_1) = false;
equation
 y = time * 2;
 z = x + _der_y;
 temp_1 = time > 0.25;
algorithm
 if temp_1 and not pre(temp_1) then
  x := y / 2;
 end if;
equation
 _der_y = 2;
end IndexReduction.AlgorithmVariability3;
")})));
  end AlgorithmVariability3;

  model AlgorithmVariability4
    Real x;
    Real y;
    Boolean b;
    parameter Integer p = 1;
    parameter Integer[:] it = {1};
    parameter Real[:] rt = {2.0};
equation
    // Trigger index reduction
    x = time;
    y = der(x);
algorithm
    b := y > 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AlgorithmVariability4",
            description="Test so that variability calculations are done properly for algorithms",
            flatModel="
fclass IndexReduction.AlgorithmVariability4
 Real x;
 Real y;
 discrete Boolean b;
 parameter Integer p = 1 /* 1 */;
 parameter Integer it[1] = 1 /* 1 */;
 parameter Real rt[1] = 2.0 /* 2.0 */;
initial equation
 pre(b) = false;
equation
 x = time;
algorithm
 b := y > 0;
equation
 y = 1.0;
end IndexReduction.AlgorithmVariability4;
")})));
  end AlgorithmVariability4;

    model Variability1
        function F1
            input Real a;
            output Real b;
            output Real c;
        algorithm
            b := a * 2;
            c := -a;
            annotation(Inline=false,derivative=F1_der);
        end F1;
        function F1_der
            input Real a;
            input Real a_der;
            output Real b;
            output Real c;
        algorithm
            (b,c) := F1(a * a_der);
            annotation(Inline=true);
        end F1_der;
        parameter Real p = 2;
        Real x,y,a;
    equation
        (x, p) = F1(y + a);
        der(x) = der(y) * 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Variability1",
            description="Test so that variability calculations are done properly for function call equations with parameters in left hand side",
            flatModel="
fclass IndexReduction.Variability1
 parameter Real p = 2 /* 2 */;
 Real x;
 Real y;
 Real a;
 Real _der_x;
 Real _der_y;
 Real temp_4;
initial equation
 a = 0.0;
equation
 (x, p) = IndexReduction.Variability1.F1(y + a);
 _der_x = _der_y * 2;
 (_der_x, temp_4) = IndexReduction.Variability1.F1((y + a) * (_der_y + der(a)));
 0.0 = temp_4;

public
 function IndexReduction.Variability1.F1
  input Real a;
  output Real b;
  output Real c;
 algorithm
  b := a * 2;
  c := - a;
  return;
 annotation(derivative = IndexReduction.Variability1.F1_der,Inline = false);
 end IndexReduction.Variability1.F1;

end IndexReduction.Variability1;
")})));
    end Variability1;

model FunctionAttributeScalarization1
    function F1
        input Real x;
        input Real a[:];
        output Real y;
    algorithm
        y := x + sum(a);
    annotation(Inline=false,derivative(noDerivative=a)=F1_der);
    end F1;
    
    function F1_der
        input Real x;
        input Real a[:];
        input Real x_der;
        output Real y_der;
    algorithm
        y_der := x_der;
    annotation(Inline=false);
    end F1_der;
    
    Real x;
    Real der_y;
    Real y;
equation
    x * y = time;
    y + 42 = F1(x, {x , -x});
    der_y = der(y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionAttributeScalarization1",
            description="Test so that it is possible to reference function variables with unknown size in function attributes",
            flatModel="
fclass IndexReduction.FunctionAttributeScalarization1
 Real x;
 Real der_y;
 Real y;
 Real _der_x;
equation
 x * y = time;
 y + 42 = IndexReduction.FunctionAttributeScalarization1.F1(x, {x, - x});
 x * der_y + _der_x * y = 1.0;
 der_y = IndexReduction.FunctionAttributeScalarization1.F1_der(x, {x, - x}, _der_x);

public
 function IndexReduction.FunctionAttributeScalarization1.F1
  input Real x;
  input Real[:] a;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 + a[i1];
  end for;
  y := x + temp_1;
  return;
 annotation(derivative(noDerivative = a) = IndexReduction.FunctionAttributeScalarization1.F1_der,Inline = false);
 end IndexReduction.FunctionAttributeScalarization1.F1;

 function IndexReduction.FunctionAttributeScalarization1.F1_der
  input Real x;
  input Real[:] a;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionAttributeScalarization1.F1_der;

end IndexReduction.FunctionAttributeScalarization1;
")})));
end FunctionAttributeScalarization1;

model FunctionAttributeScalarization2
    function F1
        input Real x;
        input Real a[2];
        output Real y;
    algorithm
        y := x + sum(a);
    annotation(Inline=false,derivative(noDerivative=a)=F1_der);
    end F1;
    
    function F1_der
        input Real x;
        input Real a[2];
        input Real x_der;
        output Real y_der;
    algorithm
        y_der := x_der;
    annotation(Inline=false);
    end F1_der;
    
    Real x;
    Real der_y;
    Real y;
equation
    x * y = time;
    y + 42 = F1(x, {x , -x});
    der_y = der(y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionAttributeScalarization2",
            description="Test so that it is possible to reference function variables with known size in function attributes",
            flatModel="
fclass IndexReduction.FunctionAttributeScalarization2
 Real x;
 Real der_y;
 Real y;
 Real _der_x;
equation
 x * y = time;
 y + 42 = IndexReduction.FunctionAttributeScalarization2.F1(x, {x, - x});
 x * der_y + _der_x * y = 1.0;
 der_y = IndexReduction.FunctionAttributeScalarization2.F1_der(x, {x, - x}, _der_x);

public
 function IndexReduction.FunctionAttributeScalarization2.F1
  input Real x;
  input Real[:] a;
  output Real y;
  Real temp_1;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:2 loop
   temp_1 := temp_1 + a[i1];
  end for;
  y := x + temp_1;
  return;
 annotation(derivative(noDerivative = a) = IndexReduction.FunctionAttributeScalarization2.F1_der,Inline = false);
 end IndexReduction.FunctionAttributeScalarization2.F1;

 function IndexReduction.FunctionAttributeScalarization2.F1_der
  input Real x;
  input Real[:] a;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionAttributeScalarization2.F1_der;

end IndexReduction.FunctionAttributeScalarization2;
")})));
end FunctionAttributeScalarization2;

package NonDiffArgs

    model Test1
        function F1
            input Real x;
            input Real r;
            output Real y;
        algorithm
            y := x + r;
        annotation(Inline=false,derivative(noDerivative=r)=F1_der);
        end F1;
        
        function F1_der
            input Real x;
            input Real r;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        annotation(Inline=false);
        end F1_der;
        
        function F2
            input Real x;
            output Real r;
        algorithm
            r := x;
        annotation(Inline=false);
        end F2;
    
        Real x;
        Real der_y;
        Real y;
        Real r;
    equation
        x * y = time;
        r = F2(x);
        y + 42 = F1(x, r);
        der_y = der(y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgs_Test1",
            description="Test so that noDerivative and zeroDerivative augmenting are ignored in augmenting path",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.NonDiffArgs.Test1
 Real x;
 Real der_y;
 Real y;
 Real r;
 Real _der_x;
equation
 x * y = time;
 r = IndexReduction.NonDiffArgs.Test1.F2(x);
 y + 42 = IndexReduction.NonDiffArgs.Test1.F1(x, r);
 x * der_y + _der_x * y = 1.0;
 der_y = IndexReduction.NonDiffArgs.Test1.F1_der(x, r, _der_x);

public
 function IndexReduction.NonDiffArgs.Test1.F2
  input Real x;
  output Real r;
 algorithm
  r := x;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgs.Test1.F2;

 function IndexReduction.NonDiffArgs.Test1.F1
  input Real x;
  input Real r;
  output Real y;
 algorithm
  y := x + r;
  return;
 annotation(derivative(noDerivative = r) = IndexReduction.NonDiffArgs.Test1.F1_der,Inline = false);
 end IndexReduction.NonDiffArgs.Test1.F1;

 function IndexReduction.NonDiffArgs.Test1.F1_der
  input Real x;
  input Real r;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgs.Test1.F1_der;

end IndexReduction.NonDiffArgs.Test1;
")})));
    end Test1;
    
    model Test2
        record R
            Real a;
        end R;
    
        function F1
            input Real x;
            input R r;
            output Real y;
        algorithm
            y := x + r.a;
        annotation(Inline=false,derivative(noDerivative=r)=F1_der);
        end F1;
        
        function F1_der
            input Real x;
            input R r;
            input Real x_der;
            output Real y_der;
        algorithm
            y_der := x_der;
        annotation(Inline=false);
        end F1_der;
        
        function F2
            input Real x;
            output R r;
        algorithm
            r := R(x);
        annotation(Inline=false);
        end F2;
    
        Real x;
        Real der_y;
        Real y;
        R r;
    equation
        x * y = time;
        r = F2(x);
        y + 42 = F1(x, r);
        der_y = der(y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgs_Test2",
            description="Test so that noDerivative and zeroDerivative augmenting are ignored in augmenting path",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.NonDiffArgs.Test2
 Real x;
 Real der_y;
 Real y;
 Real r.a;
 Real _der_x;
equation
 x * y = time;
 (IndexReduction.NonDiffArgs.Test2.R(r.a)) = IndexReduction.NonDiffArgs.Test2.F2(x);
 y + 42 = IndexReduction.NonDiffArgs.Test2.F1(x, IndexReduction.NonDiffArgs.Test2.R(r.a));
 x * der_y + _der_x * y = 1.0;
 der_y = IndexReduction.NonDiffArgs.Test2.F1_der(x, IndexReduction.NonDiffArgs.Test2.R(r.a), _der_x);

public
 function IndexReduction.NonDiffArgs.Test2.F2
  input Real x;
  output IndexReduction.NonDiffArgs.Test2.R r;
 algorithm
  r.a := x;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgs.Test2.F2;

 function IndexReduction.NonDiffArgs.Test2.F1
  input Real x;
  input IndexReduction.NonDiffArgs.Test2.R r;
  output Real y;
 algorithm
  y := x + r.a;
  return;
 annotation(derivative(noDerivative = r) = IndexReduction.NonDiffArgs.Test2.F1_der,Inline = false);
 end IndexReduction.NonDiffArgs.Test2.F1;

 function IndexReduction.NonDiffArgs.Test2.F1_der
  input Real x;
  input IndexReduction.NonDiffArgs.Test2.R r;
  input Real x_der;
  output Real y_der;
 algorithm
  y_der := x_der;
  return;
 annotation(Inline = false);
 end IndexReduction.NonDiffArgs.Test2.F1_der;

 record IndexReduction.NonDiffArgs.Test2.R
  Real a;
 end IndexReduction.NonDiffArgs.Test2.R;

end IndexReduction.NonDiffArgs.Test2;
")})));
    end Test2;
    
    model Test3
        record R
            Real a,b;
        end R;
        function F1
            input Real i1;
            input R i2;
            output Real o1;
        algorithm
            o1 := i1 * i2.a + i1 * i2.b;
            annotation(InlineAfterIndexReduction=true, derivative(noDerivative=i2)=F1_der);
        end F1;
        function F1_der
            input Real i1;
            input R i2;
            input Real i1_der;
            output Real o1_der;
        algorithm
            o1_der := F1(i1_der, i2) * i1_der;
            annotation(Inline=true);
        end F1_der;
        
        function F2
            input Real i1;
            output R o1;
        algorithm
            o1.a := -i1;
            o1.b := i1;
        annotation(InlineAfterIndexReduction=false);
        end F2;
        
        function F3
            input Real i1;
            output Real o1;
        algorithm
            o1 := i1 + 1;
        annotation(InlineAfterIndexReduction=false);
        end F3;
        
        
        Real x,y,z;
    equation
        der(y) * der(x) = 1;
        z = F3(time);
        y = F1(x, F2(z));
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgs_Test3",
            description="Test so that no diff for variables in nested function calls is computed correctly",
            common_subexp_elim=true,
            flatModel="
fclass IndexReduction.NonDiffArgs.Test3
 Real x;
 Real y;
 Real z;
 Real _der_y;
 Real temp_13;
 Real temp_14;
initial equation 
 x = 0.0;
equation
 _der_y * der(x) = 1;
 z = IndexReduction.NonDiffArgs.Test3.F3(time);
 y = x * temp_13 + x * temp_14;
 _der_y = (der(x) * temp_13 + der(x) * temp_14) * der(x);
 (IndexReduction.NonDiffArgs.Test3.R(temp_13, temp_14)) = IndexReduction.NonDiffArgs.Test3.F2(z);

public
 function IndexReduction.NonDiffArgs.Test3.F3
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1 + 1;
  return;
 annotation(InlineAfterIndexReduction = false);
 end IndexReduction.NonDiffArgs.Test3.F3;

 function IndexReduction.NonDiffArgs.Test3.F2
  input Real i1;
  output IndexReduction.NonDiffArgs.Test3.R o1;
 algorithm
  o1.a := - i1;
  o1.b := i1;
  return;
 annotation(InlineAfterIndexReduction = false);
 end IndexReduction.NonDiffArgs.Test3.F2;

 record IndexReduction.NonDiffArgs.Test3.R
  Real a;
  Real b;
 end IndexReduction.NonDiffArgs.Test3.R;

end IndexReduction.NonDiffArgs.Test3;
")})));
    end Test3;
    
    model Test4
        function F
            input Real[3] x;
            input Real dummy;
            output Real res;
        algorithm
            res := x[1];
        annotation(InlineAfterIndexReduction=true, derivative(noDerivative=x)=F_der);
        end F;
        function F_der
            input Real[3] x;
            input Real dummy;
            input Real dummy_der;
            output Real res;
        algorithm
            res := x[2];
        annotation(InlineAfterIndexReduction=true, derivative(noDerivative=x,order=2)=F_der_der);
        end F_der;
        function F_der_der
            input Real[3] x;
            input Real dummy;
            input Real dummy_der;
            input Real dummy_der_der;
            output Real res;
        algorithm
            res := x[3];
        annotation(InlineAfterIndexReduction=true);
        end F_der_der;
        
        Real p1,p3(stateSelect=StateSelect.avoid);
        Real v1,v3,v3_1;
        Real a1,a3,a3_1;
    equation
        der(p1) = v1;
        der(v1) = a1;
        der(p3) = v3;
        der(v3) = a3;
        der(p3) = v3_1;
        der(v3_1) = a3_1;
        p1 = F({p3,v3,a3},time);
        a1 * v1 = 1;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgs_Test4",
            description="Test so that munkres doesn't match to nonDiff arg during dummy derivative selection'",
            flatModel="
fclass IndexReduction.NonDiffArgs.Test4
 Real p1;
 Real p3(stateSelect = StateSelect.avoid);
 Real v1;
 Real v3;
 Real v3_1;
 Real a1;
 Real a3;
 Real _der_p1;
initial equation
 v1 = 0.0;
 p3 = 0.0;
equation
 _der_p1 = v1;
 der(v1) = a1;
 der(p3) = v3;
 der(p3) = v3_1;
 p1 = p3;
 der(v1) * _der_p1 = 1;
 _der_p1 = der(p3);
 a3 = der(v1);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.NonDiffArgs.Test4;
")})));
    end Test4;

    package ExtraIncidences

        model Test1
            function F1
                input Real x;
                input Real y;
                input Real T;
                output Real z;
            algorithm
                z := x * y * T;
            annotation(Inline=false, derivative(noDerivative=y,noDerivative=T)=F1_der);
            end F1;
            function F1_der
                input Real x;
                input Real y;
                input Real T;
                input Real x_der;
                output Real z;
            algorithm
                z := F1(x_der * y, y, T); /* Yes I know, this is despicable and wrong! */
            annotation(Inline=true);
            end F1_der;
            Real s1,s2;
            Real v1,v2;
            Real a1,a2;
            Real w;
            Real T;
        equation
            v1 = der(s1);
            a1 = der(v1);
            v2 = der(s2);
            a2 = der(v2);
            s1 = F1(sin(time), w, T);
            s1 = F1(cos(time), w, T);
            w = der(s2) + sin(time);
            T = sin(s2);
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgs_ExtraIncidences_Test1",
            description="Test that has an remote high order variable and needs extra incidences in order for dummy derivative selection to succeed.",
            flatModel="
fclass IndexReduction.NonDiffArgs.ExtraIncidences.Test1
 Real s1;
 Real s2;
 Real v1;
 Real v2;
 Real a1;
 Real a2;
 Real w;
 Real T;
 Real _der_s1;
 Real _der_s2;
 Real _der_w;
 Real temp_4;
 Real temp_14;
equation
 v1 = _der_s1;
 v2 = _der_s2;
 s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1(sin(time), w, T);
 s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1(cos(time), w, T);
 w = _der_s2 + sin(time);
 T = sin(s2);
 temp_4 = cos(time);
 _der_s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1(temp_4 * w, w, T);
 _der_w = a2 + cos(time);
 a1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1((temp_4 * _der_w + (- sin(time)) * w) * w, w, T);
 temp_14 = - sin(time);
 _der_s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1(temp_14 * w, w, T);
 a1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1((temp_14 * _der_w + (- cos(time)) * w) * w, w, T);

public
 function IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1
  input Real x;
  input Real y;
  input Real T;
  output Real z;
 algorithm
  z := x * y * T;
  return;
 annotation(derivative(noDerivative = y,noDerivative = T) = IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1_der,Inline = false);
 end IndexReduction.NonDiffArgs.ExtraIncidences.Test1.F1;

end IndexReduction.NonDiffArgs.ExtraIncidences.Test1;
")})));
        end Test1;

        model Test2
            function F1
                input Real x;
                input Real y;
                input Real T;
                output Real z;
            algorithm
                z := x * y * T;
            annotation(Inline=false, derivative(noDerivative=y,noDerivative=T)=F1_der);
            end F1;
            function F1_der
                input Real x;
                input Real y;
                input Real T;
                input Real x_der;
                output Real z;
            algorithm
                z := F1(x_der * y, y, T); /* Yes I know, this is despicable and wrong! */
            annotation(Inline=true);
            end F1_der;
            Real s1,s2,s3;
            Real v1,v2,v3;
            Real a1,a2,a3;
            Real w;
            Real T;
        equation
            v1 = der(s1);
            a1 = der(v1);
            v2 = der(s2);
            a2 = der(v2);
            v3 = der(s3);
            a3 = der(v3);
            s1 = F1(sin(time), w, T);
            s1 = F1(cos(time), sin(time), T);
            s1 + s2 + s3 = 0;
            w = der(s2) + sin(time);
            T = sin(s2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgs_ExtraIncidences_Test2",
            description="Test that needs extra incidences in order for dummy derivative selection to succeed even though all high order variables and equation are connected.",
            flatModel="
fclass IndexReduction.NonDiffArgs.ExtraIncidences.Test2
 Real s1;
 Real s2;
 Real s3;
 Real v1;
 Real v2;
 Real v3;
 Real a1;
 Real a2;
 Real a3;
 Real w;
 Real T;
 Real _der_s1;
 Real _der_s2;
 Real _der_s3;
 Real _der_w;
 Real temp_4;
 Real temp_12;
 Real temp_14;
equation
 v1 = _der_s1;
 v2 = _der_s2;
 v3 = _der_s3;
 s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1(sin(time), w, T);
 s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1(cos(time), sin(time), T);
 s1 + s2 + s3 = 0;
 w = _der_s2 + sin(time);
 T = sin(s2);
 temp_4 = cos(time);
 _der_s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1(temp_4 * w, w, T);
 _der_w = a2 + cos(time);
 a1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1((temp_4 * _der_w + (- sin(time)) * w) * w, w, T);
 temp_12 = sin(time);
 temp_14 = - sin(time);
 _der_s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1(temp_14 * temp_12, temp_12, T);
 a1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1((temp_14 * cos(time) + (- cos(time)) * temp_12) * temp_12, temp_12, T);
 _der_s1 + _der_s2 + _der_s3 = 0;
 a1 + a2 + a3 = 0;

public
 function IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1
  input Real x;
  input Real y;
  input Real T;
  output Real z;
 algorithm
  z := x * y * T;
  return;
 annotation(derivative(noDerivative = y,noDerivative = T) = IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1_der,Inline = false);
 end IndexReduction.NonDiffArgs.ExtraIncidences.Test2.F1;

end IndexReduction.NonDiffArgs.ExtraIncidences.Test2;
")})));
        end Test2;

        model Test3
            function F1
                input Real x;
                input Real y;
                input Real T;
                output Real z;
            algorithm
                z := x * y * T;
            annotation(Inline=false, derivative(noDerivative=y,noDerivative=T)=F1_der);
            end F1;
            function F1_der
                input Real x;
                input Real y;
                input Real T;
                input Real x_der;
                output Real z;
            algorithm
                z := F1(x_der * y, y, T); /* Yes I know, this is despicable and wrong! */
            annotation(Inline=true);
            end F1_der;
            Real s1a,s1b,s2,s3;
            Real v1a,v1b,v2,v3;
            Real a1a,a1b,a2,a3;
            Real w;
            Real T;
        equation
            v1a = der(s1a);
            a1a = der(v1a);
            v1b = der(s1b);
            a1b = der(v1b);
            v2 = der(s2);
            a2 = der(v2);
            v3 = der(s3);
            a3 = der(v3);
            s1a + s1b = F1(sin(time), w, T);
            s1a - s1b = F1(sin(time), cos(time), T);
            s1a + s1b = F1(cos(time), sin(time), T);
            s1a + s1b + s2 + s3 = 0;
            w = der(s2) + sin(time);
            T = sin(s2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NonDiffArgs_ExtraIncidences_Test3",
            description="Test that needs extra incidences in order for dummy derivative selection to succeed even though all high order variables and equation are connected (more advanced case).",
            flatModel="
fclass IndexReduction.NonDiffArgs.ExtraIncidences.Test3
 Real s1a;
 Real s1b;
 Real s2;
 Real s3;
 Real v1a;
 Real v1b;
 Real v2;
 Real v3;
 Real a1a;
 Real a1b;
 Real a2;
 Real a3;
 Real w;
 Real T;
 Real _der_s1a;
 Real _der_s1b;
 Real _der_s2;
 Real _der_s3;
 Real _der_w;
 Real temp_4;
 Real temp_12;
 Real temp_14;
 Real temp_22;
 Real temp_24;
equation
 v1a = _der_s1a;
 v1b = _der_s1b;
 v2 = _der_s2;
 v3 = _der_s3;
 s1a + s1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1(sin(time), w, T);
 s1a - s1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1(sin(time), cos(time), T);
 s1a + s1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1(cos(time), sin(time), T);
 s1a + s1b + s2 + s3 = 0;
 w = _der_s2 + sin(time);
 T = sin(s2);
 temp_4 = cos(time);
 _der_s1a + _der_s1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1(temp_4 * w, w, T);
 _der_w = a2 + cos(time);
 a1a + a1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1((temp_4 * _der_w + (- sin(time)) * w) * w, w, T);
 temp_12 = cos(time);
 temp_14 = cos(time);
 _der_s1a - _der_s1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1(temp_14 * temp_12, temp_12, T);
 a1a - a1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1((temp_14 * (- sin(time)) + (- sin(time)) * temp_12) * temp_12, temp_12, T);
 temp_22 = sin(time);
 temp_24 = - sin(time);
 _der_s1a + _der_s1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1(temp_24 * temp_22, temp_22, T);
 a1a + a1b = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1((temp_24 * cos(time) + (- cos(time)) * temp_22) * temp_22, temp_22, T);
 _der_s1a + _der_s1b + _der_s2 + _der_s3 = 0;
 a1a + a1b + a2 + a3 = 0;

public
 function IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1
  input Real x;
  input Real y;
  input Real T;
  output Real z;
 algorithm
  z := x * y * T;
  return;
 annotation(derivative(noDerivative = y,noDerivative = T) = IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1_der,Inline = false);
 end IndexReduction.NonDiffArgs.ExtraIncidences.Test3.F1;

end IndexReduction.NonDiffArgs.ExtraIncidences.Test3;
")})));
        end Test3;

        model Test4
            function F1
                input Real x;
                input Real y;
                input Real T;
                output Real z;
            algorithm
                z := x * y * T;
            annotation(Inline=false, derivative(noDerivative=y,noDerivative=T)=F1_der);
            end F1;
            function F1_der
                input Real x;
                input Real y;
                input Real T;
                input Real x_der;
                output Real z;
            algorithm
                z := F1(x_der * y, y, T); /* Yes I know, this is despicable and wrong! */
            annotation(Inline=true);
            end F1_der;
            Real s1(stateSelect=StateSelect.prefer),s2,s3;
            Real v1,v2,v3;
            Real a1,a2,a3;
            Real w;
            Real T;
        equation
            v1 = der(s1);
            a1 = der(v1);
            v2 = der(s2);
            a2 = der(v2);
            v3 = der(s3);
            a3 = der(v3);
            a3 = time;
            s1 = F1(sin(time), w, T);
            s1 + s2 + s3 = 0;
            w = der(s2) + sin(time);
            T = sin(time);
// Disabeling this test for now since it doesn't work with the current heuristics!'
        annotation(__JModelica_disabled(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="NonDiffArgs_ExtraIncidences_Test4",
                description="Test that fails if extra incidences are inserted.",
                flatModel="
fclass IndexReduction.NonDiffArgs.ExtraIncidences.Test4
 Real s1(stateSelect = StateSelect.prefer);
 Real s2;
 Real s3;
 Real v1;
 Real v2;
 Real v3;
 Real a1;
 Real a2;
 Real a3;
 Real w;
 Real T;
 Real _der_s1;
 Real _der_v1;
 Real _der_s2;
 Real _der_v2;
 Real _der_der_s1;
 Real _der_der_s2;
 Real _der_w;
 Real _der_der_s3;
 Real temp_4;
 Real temp_7;
initial equation 
 s3 = 0.0;
 v3 = 0.0;
equation
 v1 = _der_s1;
 a1 = _der_v1;
 v2 = _der_s2;
 a2 = _der_v2;
 v3 = der(s3);
 a3 = der(v3);
 der(v3) = time;
 s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test4.F1(sin(time), w, T);
 s1 + s2 + s3 = 0;
 w = _der_s2 + sin(time);
 T = sin(time);
 temp_7 = w;
 temp_4 = cos(time);
 _der_s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test4.F1(temp_4 * temp_7, temp_7, T);
 _der_v1 = _der_der_s1;
 _der_v2 = _der_der_s2;
 _der_w = _der_der_s2 + cos(time);
 _der_der_s1 = IndexReduction.NonDiffArgs.ExtraIncidences.Test4.F1((temp_4 * _der_w + (- sin(time)) * temp_7) * temp_7, temp_7, T);
 _der_s1 + _der_s2 + der(s3) = 0;
 der(v3) = _der_der_s3;
 _der_der_s1 + _der_der_s2 + _der_der_s3 = 0;

public
 function IndexReduction.NonDiffArgs.ExtraIncidences.Test4.F1
  input Real x;
  input Real y;
  input Real T;
  output Real z;
 algorithm
  z := x * y * T;
  return;
 annotation(derivative(noDerivative = y,noDerivative = T) = IndexReduction.NonDiffArgs.ExtraIncidences.Test4.F1_der,Inline = false);
 end IndexReduction.NonDiffArgs.ExtraIncidences.Test4.F1;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.NonDiffArgs.ExtraIncidences.Test4;
")})));
        end Test4;

    end ExtraIncidences;


end NonDiffArgs;

model FunctionCallEquation1
    function f
        input Real x;
        output Real y[2];
    algorithm
        y[1] := x;
        y[2] := -x;
    annotation(Inline=false, smoothOrder=1);
    end f;
    
    Real x[2];
    Real y;
    Real z;
equation
    x = f(time);
    y = x[1] + x[2];
    z = der(y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation1",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly",
            flatModel="
fclass IndexReduction.FunctionCallEquation1
 Real x[1];
 Real x[2];
 Real y;
 Real z;
 Real _der_x[1];
 Real _der_x[2];
equation
 ({x[1], x[2]}) = IndexReduction.FunctionCallEquation1.f(time);
 y = x[1] + x[2];
 ({_der_x[1], _der_x[2]}) = IndexReduction.FunctionCallEquation1._der_f(time, 1.0);
 z = _der_x[1] + _der_x[2];

public
 function IndexReduction.FunctionCallEquation1.f
  input Real x;
  output Real[:] y;
 algorithm
  init y as Real[2];
  y[1] := x;
  y[2] := - x;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.FunctionCallEquation1._der_f);
 end IndexReduction.FunctionCallEquation1.f;

 function IndexReduction.FunctionCallEquation1._der_f
  input Real x;
  input Real _der_x;
  output Real[:] _der_y;
  Real[:] y;
 algorithm
  init y as Real[2];
  init _der_y as Real[2];
  _der_y[1] := _der_x;
  y[1] := x;
  _der_y[2] := - _der_x;
  y[2] := - x;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.FunctionCallEquation1._der_f;

end IndexReduction.FunctionCallEquation1;
")})));
end FunctionCallEquation1;

model FunctionCallEquation2
    function f
        input Real x;
        output Real y = x;
        output Real z = x;
      algorithm
        annotation(Inline=false, smoothOrder=1);
    end f;
    
    Real a,b,c,d;
  equation
    der(c) = d;
    (a,c) = f(time);
    der(a) = b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation2",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly",
            flatModel="
fclass IndexReduction.FunctionCallEquation2
 Real a;
 Real b;
 Real c;
 Real d;
equation
 (a, c) = IndexReduction.FunctionCallEquation2.f(time);
 (b, d) = IndexReduction.FunctionCallEquation2._der_f(time, 1.0);

public
 function IndexReduction.FunctionCallEquation2.f
  input Real x;
  output Real y;
  output Real z;
 algorithm
  y := x;
  z := x;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.FunctionCallEquation2._der_f);
 end IndexReduction.FunctionCallEquation2.f;

 function IndexReduction.FunctionCallEquation2._der_f
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := _der_x;
  y := x;
  _der_z := _der_x;
  z := x;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.FunctionCallEquation2._der_f;

end IndexReduction.FunctionCallEquation2;
")})));
end FunctionCallEquation2;

model FunctionCallEquation3
    function f
        input Real x;
        output Real y = x;
        output Real z = x;
      algorithm
        annotation(Inline=false, smoothOrder=1);
    end f;
    
    Real a,b,c,d;
  equation
    c = d + 1;
    (a,c) = f(time);
    der(a) = b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation3",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly",
            flatModel="
fclass IndexReduction.FunctionCallEquation3
 Real a;
 Real b;
 Real c;
 Real d;
 Real _der_c;
equation
 c = d + 1;
 (a, c) = IndexReduction.FunctionCallEquation3.f(time);
 (b, _der_c) = IndexReduction.FunctionCallEquation3._der_f(time, 1.0);

public
 function IndexReduction.FunctionCallEquation3.f
  input Real x;
  output Real y;
  output Real z;
 algorithm
  y := x;
  z := x;
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.FunctionCallEquation3._der_f);
 end IndexReduction.FunctionCallEquation3.f;

 function IndexReduction.FunctionCallEquation3._der_f
  input Real x;
  input Real _der_x;
  output Real _der_y;
  output Real _der_z;
  Real y;
  Real z;
 algorithm
  _der_y := _der_x;
  y := x;
  _der_z := _der_x;
  z := x;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.FunctionCallEquation3._der_f;

end IndexReduction.FunctionCallEquation3;
")})));
end FunctionCallEquation3;

model FunctionCallEquation4
    function F2
        input Real[2] a;
        output Real[2] y;
    algorithm
        y[1] := a[1] + a[2];
        y[2] := a[1] - a[2];
        annotation(Inline=false,derivative=F2_der);
    end F2;

    function F2_der
        input Real[2] a;
        input Real[2] a_der;
        output Real[2] y_der;
    algorithm
        y_der[1] := a_der[1] + a_der[2];
        y_der[2] := a_der[1] - a_der[2];
        annotation(Inline=false);
    end F2_der;

    Real x[2];
    Real y[2];
    Real a;
    
equation
    der(x) = der(y) * 2;
    y[1] = a + 1;
    ({a, y[2]}) = F2(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation4",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"y[1] = a + 1\" should be differentiated",
            flatModel="
fclass IndexReduction.FunctionCallEquation4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real a;
 Real _der_x[1];
 Real _der_y[1];
 Real _der_x[2];
initial equation 
 y[2] = 0.0;
 a = 0.0;
equation
 _der_x[1] = _der_y[1] * 2;
 _der_x[2] = der(y[2]) * 2;
 y[1] = a + 1;
 ({a, y[2]}) = IndexReduction.FunctionCallEquation4.F2({x[1], x[2]});
 ({der(a), der(y[2])}) = IndexReduction.FunctionCallEquation4.F2_der({x[1], x[2]}, {_der_x[1], _der_x[2]});
 _der_y[1] = der(a);

public
 function IndexReduction.FunctionCallEquation4.F2
  input Real[:] a;
  output Real[:] y;
 algorithm
  init y as Real[2];
  y[1] := a[1] + a[2];
  y[2] := a[1] - a[2];
  return;
 annotation(derivative = IndexReduction.FunctionCallEquation4.F2_der,Inline = false);
 end IndexReduction.FunctionCallEquation4.F2;

 function IndexReduction.FunctionCallEquation4.F2_der
  input Real[:] a;
  input Real[:] a_der;
  output Real[:] y_der;
 algorithm
  init y_der as Real[2];
  y_der[1] := a_der[1] + a_der[2];
  y_der[2] := a_der[1] - a_der[2];
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionCallEquation4.F2_der;

end IndexReduction.FunctionCallEquation4;
")})));
end FunctionCallEquation4;

model FunctionCallEquation5
    function F2
        input Real[2] a;
        output Real[2] y;
    algorithm
        y[1] := a[1] + a[2];
        y[2] := a[1] - a[2];
        annotation(Inline=false,derivative=F2_der);
    end F2;

    function F2_der
        input Real[2] a;
        input Real[2] a_der;
        output Real[2] y_der;
    algorithm
        y_der[1] := a_der[1] + a_der[2];
        y_der[2] := a_der[1] - a_der[2];
        annotation(Inline=false);
    end F2_der;

    Real x[2];
    Real y[2];
    Real a;
    Real b;
    
equation
    der(x) = der(y) * 2;
    b = a + 1;
    ({a, y[2]}) = F2(x);
    y[1] = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation5",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"b = a + 1;\" should not be differentiated",
            flatModel="
fclass IndexReduction.FunctionCallEquation5
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real a;
 Real b;
 Real _der_x[1];
 Real _der_y[1];
 Real _der_x[2];
initial equation 
 y[2] = 0.0;
 a = 0.0;
equation
 _der_x[1] = _der_y[1] * 2;
 _der_x[2] = der(y[2]) * 2;
 b = a + 1;
 ({a, y[2]}) = IndexReduction.FunctionCallEquation5.F2({x[1], x[2]});
 y[1] = time;
 ({der(a), der(y[2])}) = IndexReduction.FunctionCallEquation5.F2_der({x[1], x[2]}, {_der_x[1], _der_x[2]});
 _der_y[1] = 1.0;

public
 function IndexReduction.FunctionCallEquation5.F2
  input Real[:] a;
  output Real[:] y;
 algorithm
  init y as Real[2];
  y[1] := a[1] + a[2];
  y[2] := a[1] - a[2];
  return;
 annotation(derivative = IndexReduction.FunctionCallEquation5.F2_der,Inline = false);
 end IndexReduction.FunctionCallEquation5.F2;

 function IndexReduction.FunctionCallEquation5.F2_der
  input Real[:] a;
  input Real[:] a_der;
  output Real[:] y_der;
 algorithm
  init y_der as Real[2];
  y_der[1] := a_der[1] + a_der[2];
  y_der[2] := a_der[1] - a_der[2];
  return;
 annotation(Inline = false);
 end IndexReduction.FunctionCallEquation5.F2_der;

end IndexReduction.FunctionCallEquation5;
")})));
end FunctionCallEquation5;

model FunctionCallEquation6
    function f
        input Real x;
        output Integer a1;
        output Real a2;
      algorithm
        a1 := 3;
        a2 := x;
        annotation(smoothOrder=1);
    end f;
    Integer a;
    Real b,c,d;
  equation
    (a,b) = f(time);
    der(c) = der(d);
    d = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation6",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"b = a + 1;\" should not be differentiated",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.FunctionCallEquation6
 discrete Integer a;
 Real b;
 Real c;
 Real d;
 Real _der_d;
initial equation 
 c = 0.0;
 pre(a) = 0;
equation
 (a, b) = IndexReduction.FunctionCallEquation6.f(time);
 der(c) = _der_d;
 d = time;
 _der_d = 1.0;

public
 function IndexReduction.FunctionCallEquation6.f
  input Real x;
  output Integer a1;
  output Real a2;
 algorithm
  a1 := 3;
  a2 := x;
  return;
 annotation(smoothOrder = 1);
 end IndexReduction.FunctionCallEquation6.f;

end IndexReduction.FunctionCallEquation6;
")})));
end FunctionCallEquation6;

model FunctionCallEquation7
    function f
        input Real x;
        input Real e;
        output Integer a1;
        output Real a2;
      algorithm
        a1 := 3;
        a2 := x + e;
        annotation(smoothOrder=1);
    end f;
    Integer a;
    Real b,c,d;
    Real e;
  equation
    (a,b) = f(time, e);
    der(c) = der(d);
    d = time;
    e = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCallEquation7",
            description="Test so that non scalar equations such as FunctionCallEquations are handled correctly. The equation \"b = a + 1;\" should not be differentiated",
            eliminate_linear_equations=false,
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.FunctionCallEquation7
 discrete Integer a;
 Real b;
 Real c;
 Real d;
 Real e;
 Real _der_d;
initial equation 
 c = 0.0;
 pre(a) = 0;
equation
 (a, b) = IndexReduction.FunctionCallEquation7.f(time, e);
 der(c) = _der_d;
 d = time;
 e = time;
 _der_d = 1.0;

public
 function IndexReduction.FunctionCallEquation7.f
  input Real x;
  input Real e;
  output Integer a1;
  output Real a2;
 algorithm
  a1 := 3;
  a2 := x + e;
  return;
 annotation(smoothOrder = 1);
 end IndexReduction.FunctionCallEquation7.f;

end IndexReduction.FunctionCallEquation7;
")})));
end FunctionCallEquation7;

model IfEquation1
function f
    input Real t;
    output Integer x = integer(t);
    output Real y = t;
algorithm
    annotation(Inline=false);
end f;
    Integer a;
    Real b;
    Real x,y;
equation
    if time > 1 then
        (a,b) = f(x);
    else
        a = 0;
        b = 0;
    end if;
    der(x) = der(y);
    y = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEquation1",
            description="index reduction in model with if equation",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.IfEquation1
 discrete Integer a;
 Real b;
 Real x;
 Real y;
 Real _der_y;
initial equation 
 x = 0.0;
 pre(a) = 0;
equation
 if time > 1 then
  (a, b) = IndexReduction.IfEquation1.f(x);
 else
  a = 0;
  b = 0;
 end if;
 der(x) = _der_y;
 y = time;
 _der_y = 1.0;

public
 function IndexReduction.IfEquation1.f
  input Real t;
  output Integer x;
  output Real y;
 algorithm
  x := integer(t);
  y := t;
  return;
 annotation(Inline = false);
 end IndexReduction.IfEquation1.f;

end IndexReduction.IfEquation1;
")})));
end IfEquation1;

model IfEquation2
function f
    input Real t;
    output Real x = t;
    output Real y = t;
algorithm
    annotation(Inline=false, smoothOrder=3);
end f;
    Real a,b;
    Real x,y;
equation
    if time > 1 then
        (a,b) = f(time);
    else
        a = 0;
        b = 0;
    end if;
    der(x) = der(a);
    der(y) = der(b);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IfEquation2",
            description="index reduction in model with if equation",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.IfEquation2
 Real a;
 Real b;
 Real x;
 Real y;
 Real _der_a;
 Real _der_b;
initial equation 
 x = 0.0;
 y = 0.0;
equation
 if time > 1 then
  (a, b) = IndexReduction.IfEquation2.f(time);
 else
  a = 0;
  b = 0;
 end if;
 der(x) = _der_a;
 der(y) = _der_b;
 if time > 1 then
  (_der_a, _der_b) = IndexReduction.IfEquation2._der_f(time, 1.0);
 else
  _der_a = 0;
  _der_b = 0;
 end if;

public
 function IndexReduction.IfEquation2.f
  input Real t;
  output Real x;
  output Real y;
 algorithm
  x := t;
  y := t;
  return;
 annotation(Inline = false,smoothOrder = 3,derivative(order = 1) = IndexReduction.IfEquation2._der_f);
 end IndexReduction.IfEquation2.f;

 function IndexReduction.IfEquation2._der_f
  input Real t;
  input Real _der_t;
  output Real _der_x;
  output Real _der_y;
  Real x;
  Real y;
 algorithm
  _der_x := _der_t;
  x := t;
  _der_y := _der_t;
  y := t;
  return;
 annotation(smoothOrder = 2);
 end IndexReduction.IfEquation2._der_f;

end IndexReduction.IfEquation2;
")})));
end IfEquation2;

model Algorithm1
    Integer a;
    Real b;
    Real x,y;
  algorithm
    a := 3;
    a := a + 1;
    b := y;
  equation
    der(x) = der(y);
    y = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm1",
            description="Test so that non scalar equations such as Algorithms are handled correctly.",
            inline_functions="none",
            variability_propagation=false,
            flatModel="
fclass IndexReduction.Algorithm1
 discrete Integer a;
 Real b;
 Real x;
 Real y;
 Real _der_y;
initial equation 
 x = 0.0;
 pre(a) = 0;
equation
 der(x) = _der_y;
 y = time;
algorithm
 a := 3;
 a := a + 1;
 b := y;
equation
 _der_y = 1.0;
end IndexReduction.Algorithm1;
")})));
end Algorithm1;

model Algorithm2
    Real x(stateSelect=StateSelect.always);
    Real z;
equation
    x = time;
algorithm
    z := time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Algorithm2",
            description="Test index reduction and variablity computation bug with algorithms.",
            flatModel="
fclass IndexReduction.Algorithm2
 Real x(stateSelect = StateSelect.always);
 Real z;
 Real _der_x;
equation
 x = time;
algorithm
 z := time;
equation
 _der_x = 1.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.Algorithm2;
")})));
end Algorithm2;

model DoubleDifferentiationWithSS1
    parameter Real L = 1 "Pendulum length";
    parameter Real g = 9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.never) "Cartesian x coordinate";
    Real x2;
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
equation
    der(x2) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
    x = x2 + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DoubleDifferentiationWithSS1",
            description="Test double differentiation whit state select avoid or never during index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.DoubleDifferentiationWithSS1
 parameter Real L = 1 \"Pendulum length\" /* 1 */;
 parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
 Real x(stateSelect = StateSelect.never) \"Cartesian x coordinate\";
 Real x2;
 Real y \"Cartesian x coordinate\";
 Real vx \"Velocity in x coordinate\";
 Real vy \"Velocity in y coordinate\";
 Real lambda \"Lagrange multiplier\";
 Real _der_x2;
 Real _der_vx;
 Real _der_x;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x2 = vx;
 der(y) = vy;
 _der_vx = lambda * x;
 der(vy) = lambda * y - g;
 x ^ 2 + y ^ 2 = L;
 x = x2 + 1;
 2 * x * _der_x + 2 * y * der(y) = 0.0;
 _der_x = _der_x2;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.DoubleDifferentiationWithSS1;
")})));
end DoubleDifferentiationWithSS1;


model MaxNumFExpError1
    Real x1;
    Real x2;
equation
    der(x1) + der(x2) = 1;
    x1 + x2 = 1;
    atan2(atan2(x1 * x2, sqrt(x1 ^ 2 + x2 ^ 2)), x1 / x2) = 2;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="MaxNumFExpError1",
            description="Test error check that prevents runaway index reduction",
            errorMessage="
2 errors found:

Error in flattened model:
  Index reduction failed: Maximum number of expressions in a single equation has been reached

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     der(x2)

  The following equation(s) could not be matched to any variable:
    x1 + x2 = 1
    atan2(atan2(x1 * x2, sqrt(x1 ^ 2 + x2 ^ 2)), x1 / x2) = 2

")})));
end MaxNumFExpError1;

model NoMunkresSolutionError1
    function F
        input Real[3] x;
        input Real dummy;
        output Real res;
    algorithm
        res := x[1];
    annotation(InlineAfterIndexReduction=true, derivative(noDerivative=x)=F_der);
    end F;
    function F_der
        input Real[3] x;
        input Real dummy;
        input Real dummy_der;
        output Real res;
    algorithm
        res := x[2];
    annotation(InlineAfterIndexReduction=true, derivative(noDerivative=x,order=2)=F_der_der);
    end F_der;
    function F_der_der
        input Real[3] x;
        input Real dummy;
        input Real dummy_der;
        input Real dummy_der_der;
        output Real res;
    algorithm
        res := x[3];
    annotation(InlineAfterIndexReduction=true);
    end F_der_der;
    
    Real p1,p2,p3;
    Real v1,v2,v3;
    Real a1,a2,a3;
equation
    der(p1) = v1;
    der(v1) = a1;
    der(p2) = v2;
    der(v2) = a2;
    der(p3) = v3;
    der(v3) = a3;
    p1 = F({p3,v3,a3},time);
    p2 = F({p3,v3,a3},time);
    v2 * v1 = 1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NoMunkresSolutionError1",
            description="Test error check that prevents runaway index reduction",
            errorMessage="
2 errors found:

Error in flattened model:
  Index reduction failed: Munkres algorithm was unable to find a matching; Unable to find any uncovered incidence

Error in flattened model:
  The system is structurally singular. The following variable(s) could not be matched to any equation:
     a1
     a2

  The following equation(s) could not be matched to any variable:
    p2 = IndexReduction.NoMunkresSolutionError1.F({p3, der(p3), der(v3)}, time)
    der(p2) * der(p1) = 1

")})));
end NoMunkresSolutionError1;

model PartiallyPropagatedComposite1
    function f
        input Real x1;
        input Real x2;
        output Real[2] y;
      algorithm
        y[1] := x1;
        y[2] := x2;
        annotation(smoothOrder = 1);
    end f;
    Real[2] y;
    Real[2] x1;
equation
    y = f(2,time);
    x1 = der(y);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="PartiallyPropagatedComposite1",
            description="Check that index reduction can handle FNoExp in LHS of function call equation",
            inline_functions="none",
            flatModel="
fclass IndexReduction.PartiallyPropagatedComposite1
 constant Real y[1] = 2;
 Real y[2];
 constant Real x1[1] = 0.0;
 Real x1[2];
equation
 ({, y[2]}) = IndexReduction.PartiallyPropagatedComposite1.f(2, time);
 ({, x1[2]}) = IndexReduction.PartiallyPropagatedComposite1._der_f(2, time, 0, 1.0);

public
 function IndexReduction.PartiallyPropagatedComposite1.f
  input Real x1;
  input Real x2;
  output Real[:] y;
 algorithm
  init y as Real[2];
  y[1] := x1;
  y[2] := x2;
  return;
 annotation(smoothOrder = 1,derivative(order = 1) = IndexReduction.PartiallyPropagatedComposite1._der_f);
 end IndexReduction.PartiallyPropagatedComposite1.f;

 function IndexReduction.PartiallyPropagatedComposite1._der_f
  input Real x1;
  input Real x2;
  input Real _der_x1;
  input Real _der_x2;
  output Real[:] _der_y;
  Real[:] y;
 algorithm
  init y as Real[2];
  init _der_y as Real[2];
  _der_y[1] := _der_x1;
  y[1] := x1;
  _der_y[2] := _der_x2;
  y[2] := x2;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.PartiallyPropagatedComposite1._der_f;

end IndexReduction.PartiallyPropagatedComposite1;
")})));
end PartiallyPropagatedComposite1;

model ModelWithMetaEquation
    Real x,y;
equation
    x = time;
    der(x) + y = 1;
    assert(x > y, "Oh no!");
    
    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ModelWithMetaEquation",
            description="Test so that meta equations are ignored during index reduction",
            methodName="printDAEBLT",
            methodResult="
--- Solved equation ---
x := time

--- Solved equation ---
_der_x := 1.0

--- Solved equation ---
y := - _der_x + 1

--- Meta equation block ---
assert(x > y, \"Oh no!\")
-------------------------------
")})));
end ModelWithMetaEquation;

package FunctionInlining
    model Test1
        function F
            input Real i;
            output Real o1;
        algorithm
            o1 := i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der;
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = F(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test1",
            description="Test function inlining during index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.FunctionInlining.Test1
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test1.F(time);
 2 * x * _der_x + 2 * y * der(y) = 1.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = 0.0;

public
 function IndexReduction.FunctionInlining.Test1.F
  input Real i;
  output Real o1;
 algorithm
  o1 := i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test1.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test1.F;

end IndexReduction.FunctionInlining.Test1;
")})));
    end Test1;
    
    model Test2
    
        function F
            input Real i;
            output Real o1[2];
        algorithm
            o1[1] := i;
            o1[2] := -i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der[2];
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x[2];
        Real y[2];
        Real vx[2];
        Real vy[2];
        Real a[2];
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a.*x;
        der(vy) = a.*y;
        x.^2 .+ y.^2 = F(time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test2",
            description="Test function inlining during index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.FunctionInlining.Test2
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real vx[1];
 Real vx[2];
 Real vy[1];
 Real vy[2];
 Real a[1];
 Real a[2];
 Real _der_x[1];
 Real _der_x[2];
 Real _der_vx[1];
 Real _der_vx[2];
 Real _der_der_y[1];
 Real _der_der_y[2];
 Real temp_1[1];
 Real temp_1[2];
initial equation
 y[1] = 0.0;
 y[2] = 0.0;
 vy[1] = 0.0;
 vy[2] = 0.0;
equation
 _der_x[1] = vx[1];
 _der_x[2] = vx[2];
 der(y[1]) = vy[1];
 der(y[2]) = vy[2];
 _der_vx[1] = a[1] .* x[1];
 _der_vx[2] = a[2] .* x[2];
 der(vy[1]) = a[1] .* y[1];
 der(vy[2]) = a[2] .* y[2];
 ({temp_1[1], temp_1[2]}) = IndexReduction.FunctionInlining.Test2.F(time);
 x[1] .^ 2 .+ y[1] .^ 2 = temp_1[1];
 x[2] .^ 2 .+ y[2] .^ 2 = temp_1[2];
 2 .* x[1] .* _der_x[1] .+ 2 .* y[1] .* der(y[1]) = 1.0;
 _der_der_y[1] = der(vy[1]);
 2 .* x[1] .* _der_vx[1] .+ 2 .* _der_x[1] .* _der_x[1] .+ (2 .* y[1] .* _der_der_y[1] .+ 2 .* der(y[1]) .* der(y[1])) = 0.0;
 2 .* x[2] .* _der_x[2] .+ 2 .* y[2] .* der(y[2]) = -1.0;
 _der_der_y[2] = der(vy[2]);
 2 .* x[2] .* _der_vx[2] .+ 2 .* _der_x[2] .* _der_x[2] .+ (2 .* y[2] .* _der_der_y[2] .+ 2 .* der(y[2]) .* der(y[2])) = 0.0;

public
 function IndexReduction.FunctionInlining.Test2.F
  input Real i;
  output Real[:] o1;
 algorithm
  init o1 as Real[2];
  o1[1] := i;
  o1[2] := - i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test2.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test2.F;

end IndexReduction.FunctionInlining.Test2;
")})));
    end Test2;
    
    model Test3
    
        function F
            input Real i;
            output Real o1;
        algorithm
            o1 := i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der;
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
        Real b;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = F(b);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test3",
            description="Test function inlining during index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.FunctionInlining.Test3
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 Real b;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_y;
 Real _der_der_b;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test3.F(b);
 b = time;
 2 * x * _der_x + 2 * y * der(y) = IndexReduction.FunctionInlining.Test3.F(_der_b);
 _der_b = 1.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = IndexReduction.FunctionInlining.Test3.F(_der_der_b);
 _der_der_b = 0.0;

public
 function IndexReduction.FunctionInlining.Test3.F
  input Real i;
  output Real o1;
 algorithm
  o1 := i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test3.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test3.F;

end IndexReduction.FunctionInlining.Test3;
")})));
    end Test3;
    
    model Test4
    
        function F
            input Real i;
            output Real o1[2];
        algorithm
            o1[1] := i;
            o1[2] := -i;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i;
            input Real i_der;
            output Real o1_der[2];
        algorithm
            o1_der := F(i_der);
            annotation(Inline=true);
        end F_der;
    
        Real x[2];
        Real y[2];
        Real vx[2];
        Real vy[2];
        Real a[2];
        Real b;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a.*x;
        der(vy) = a.*y;
        x.^2 .+ y.^2 = F(b);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test4",
            description="Test function inlining during index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.FunctionInlining.Test4
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 Real vx[1];
 Real vx[2];
 Real vy[1];
 Real vy[2];
 Real a[1];
 Real a[2];
 Real b;
 Real _der_x[1];
 Real _der_x[2];
 Real _der_vx[1];
 Real _der_vx[2];
 Real _der_b;
 Real _der_der_y[1];
 Real _der_der_b;
 Real _der_der_y[2];
 Real temp_1[1];
 Real temp_1[2];
 Real temp_4;
 Real temp_5;
 Real temp_8;
 Real temp_9;
initial equation
 y[1] = 0.0;
 y[2] = 0.0;
 vy[1] = 0.0;
 vy[2] = 0.0;
equation
 _der_x[1] = vx[1];
 _der_x[2] = vx[2];
 der(y[1]) = vy[1];
 der(y[2]) = vy[2];
 _der_vx[1] = a[1] .* x[1];
 _der_vx[2] = a[2] .* x[2];
 der(vy[1]) = a[1] .* y[1];
 der(vy[2]) = a[2] .* y[2];
 ({temp_1[1], temp_1[2]}) = IndexReduction.FunctionInlining.Test4.F(b);
 x[1] .^ 2 .+ y[1] .^ 2 = temp_1[1];
 x[2] .^ 2 .+ y[2] .^ 2 = temp_1[2];
 b = time;
 ({temp_4, temp_5}) = IndexReduction.FunctionInlining.Test4.F(_der_b);
 2 .* x[1] .* _der_x[1] .+ 2 .* y[1] .* der(y[1]) = temp_4;
 _der_b = 1.0;
 _der_der_y[1] = der(vy[1]);
 ({temp_8, temp_9}) = IndexReduction.FunctionInlining.Test4.F(_der_der_b);
 2 .* x[1] .* _der_vx[1] .+ 2 .* _der_x[1] .* _der_x[1] .+ (2 .* y[1] .* _der_der_y[1] .+ 2 .* der(y[1]) .* der(y[1])) = temp_8;
 _der_der_b = 0.0;
 2 .* x[2] .* _der_x[2] .+ 2 .* y[2] .* der(y[2]) = temp_5;
 _der_der_y[2] = der(vy[2]);
 2 .* x[2] .* _der_vx[2] .+ 2 .* _der_x[2] .* _der_x[2] .+ (2 .* y[2] .* _der_der_y[2] .+ 2 .* der(y[2]) .* der(y[2])) = temp_9;

public
 function IndexReduction.FunctionInlining.Test4.F
  input Real i;
  output Real[:] o1;
 algorithm
  init o1 as Real[2];
  o1[1] := i;
  o1[2] := - i;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test4.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test4.F;

end IndexReduction.FunctionInlining.Test4;
")})));
    end Test4;

    model Test5
        function F
            input Real i1;
            input Real i2;
            output Real o1;
        algorithm
            o1 := i1 * i2;
            annotation(Inline=false,derivative(zeroDerivative=i2)=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            output Real o1_der;
        algorithm
            o1_der := F(i1_der, i2);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real b;
        parameter Real p = 2;
    equation
        der(x) = der(y) * 2;
        x^2 + y^2 = F(b, if p > 0 then p else 0);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test5",
            description="Test function inlining during index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.FunctionInlining.Test5
 Real x;
 Real y;
 Real b;
 parameter Real p = 2 /* 2 */;
 Real _der_x;
 Real _der_b;
 Real temp_2;
initial equation
 y = 0.0;
equation
 _der_x = der(y) * 2;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test5.F(b, if p > 0 then p else 0);
 b = time;
 temp_2 = if p > 0 then p else 0;
 2 * x * _der_x + 2 * y * der(y) = IndexReduction.FunctionInlining.Test5.F(_der_b, temp_2);
 _der_b = 1.0;

public
 function IndexReduction.FunctionInlining.Test5.F
  input Real i1;
  input Real i2;
  output Real o1;
 algorithm
  o1 := i1 * i2;
  return;
 annotation(derivative(zeroDerivative = i2) = IndexReduction.FunctionInlining.Test5.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test5.F;

end IndexReduction.FunctionInlining.Test5;
")})));
    end Test5;

    model Test6
        function F
            input Real i1;
            input Real i2;
            output Real o1;
        algorithm
            o1 := i1 * i2;
            annotation(Inline=false,derivative(zeroDerivative=i2)=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            output Real o1_der;
        algorithm
            o1_der := F(i1_der, i2);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
        Real b;
        constant Real p = 2;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = F(b, if p > 0 then p else 0);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test6",
            description="Test function inlining during index reduction",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.FunctionInlining.Test6
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 Real b;
 constant Real p = 2;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_y;
 Real _der_der_b;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = IndexReduction.FunctionInlining.Test6.F(b, 2.0);
 b = time;
 2 * x * _der_x + 2 * y * der(y) = IndexReduction.FunctionInlining.Test6.F(_der_b, 2.0);
 _der_b = 1.0;
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = IndexReduction.FunctionInlining.Test6.F(_der_der_b, 2.0);
 _der_der_b = 0.0;

public
 function IndexReduction.FunctionInlining.Test6.F
  input Real i1;
  input Real i2;
  output Real o1;
 algorithm
  o1 := i1 * i2;
  return;
 annotation(derivative(zeroDerivative = i2) = IndexReduction.FunctionInlining.Test6.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test6.F;

end IndexReduction.FunctionInlining.Test6;
")})));
    end Test6;

    model Test7
        function F
            input Real i1;
            input Real i2;
            output Real o1;
        algorithm
            o1 := if i1 > i2 then i1 else i2;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            input Real i2_der;
            output Real o1_der;
        algorithm
            o1_der := if i1 > i2 then i1_der else i2_der;
            annotation(Inline=false,derivative(order=2)=F_der2);
        end F_der;
    
        function F_der2
            input Real i1;
            input Real i2;
            input Real i1_der;
            input Real i2_der;
            input Real i1_der2;
            input Real i2_der2;
            output Real o1_der2;
        algorithm
            o1_der2 := if i1 > i2 then i1_der2 else i2_der2;
            annotation(Inline=true);
        end F_der2;
    
        Real x(stateSelect=StateSelect.prefer);
        Real y(stateSelect=StateSelect.prefer);
        Real vx(stateSelect=StateSelect.prefer);
        Real vy(stateSelect=StateSelect.prefer);
        Real a;
        Real b;
        constant Real p = 2;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x^2 + y^2 = b;
        b = F(x, y);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test7",
            description="Test function inlining during index reduction. This test requires that temporary equations and variables (introduced during index reduction) are hidden from munkres.",
            dynamic_states=false,
            flatModel="
fclass IndexReduction.FunctionInlining.Test7
 Real x(stateSelect = StateSelect.prefer);
 Real y(stateSelect = StateSelect.prefer);
 Real vx(stateSelect = StateSelect.prefer);
 Real vy(stateSelect = StateSelect.prefer);
 Real a;
 Real b;
 constant Real p = 2;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_y;
 Real _der_der_b;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x ^ 2 + y ^ 2 = b;
 b = IndexReduction.FunctionInlining.Test7.F(x, y);
 2 * x * _der_x + 2 * y * der(y) = _der_b;
 _der_b = IndexReduction.FunctionInlining.Test7.F_der(x, y, _der_x, der(y));
 _der_der_y = der(vy);
 2 * x * _der_vx + 2 * _der_x * _der_x + (2 * y * _der_der_y + 2 * der(y) * der(y)) = _der_der_b;
 _der_der_b = noEvent(if x > y then _der_vx else _der_der_y);

public
 function IndexReduction.FunctionInlining.Test7.F
  input Real i1;
  input Real i2;
  output Real o1;
 algorithm
  o1 := if i1 > i2 then i1 else i2;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test7.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test7.F;

 function IndexReduction.FunctionInlining.Test7.F_der
  input Real i1;
  input Real i2;
  input Real i1_der;
  input Real i2_der;
  output Real o1_der;
 algorithm
  o1_der := if i1 > i2 then i1_der else i2_der;
  return;
 annotation(derivative(order = 2) = IndexReduction.FunctionInlining.Test7.F_der2,Inline = false);
 end IndexReduction.FunctionInlining.Test7.F_der;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.FunctionInlining.Test7;
")})));
    end Test7;

    model Test8
        function F
            input Real i1;
            input Real i2;
            output Real o1;
            output Integer o2;
        algorithm
            o1 := i1 + i2;
            o2 := 1;
            annotation(Inline=false,derivative=F_der);
        end F;
    
        function F_der
            input Real i1;
            input Real i2;
            input Real i1_der;
            input Real i2_der;
            output Real o1_der;
        algorithm
            (o1_der, ) := F(i1_der, i2_der);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
        Real b;
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        (b,) = F(x, y);
        b = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test8",
            description="Test function inlining during index reduction. This test requires that temporary equations and variables (introduced during index reduction) are hidden from munkres.",
            flatModel="
fclass IndexReduction.FunctionInlining.Test8
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 Real b;
 Real _der_x;
 Real _der_vx;
 Real _der_b;
 Real _der_der_y;
 Real _der_der_b;
 Real temp_5;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 (b, ) = IndexReduction.FunctionInlining.Test8.F(x, y);
 b = time;
 (temp_5, ) = IndexReduction.FunctionInlining.Test8.F(_der_x, der(y));
 _der_b = temp_5;
 _der_b = 1.0;
 _der_der_y = der(vy);
 (_der_der_b, ) = IndexReduction.FunctionInlining.Test8.F(_der_vx, _der_der_y);
 _der_der_b = 0.0;

public
 function IndexReduction.FunctionInlining.Test8.F
  input Real i1;
  input Real i2;
  output Real o1;
  output Integer o2;
 algorithm
  o1 := i1 + i2;
  o2 := 1;
  return;
 annotation(derivative = IndexReduction.FunctionInlining.Test8.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test8.F;

end IndexReduction.FunctionInlining.Test8;
")})));
    end Test8;

    model Test9
        function F
            input Real i1[1];
            input Real i2;
            output Real o1;
        algorithm
            o1 := i2;
            annotation(Inline=false,derivative(noDerivative=i1)=F_der);
        end F;
    
        function F_der
            input Real i1[1];
            input Real i2;
            input Real i2_der;
            output Real o1_der;
        algorithm
            o1_der := F(i1, i2_der * i1[1] + i2 * i1[1]);
            annotation(Inline=true);
        end F_der;
    
        Real x;
        Real y;
        Real vx;
        Real vy;
        Real a;
        parameter Real[1] p = {1};
    equation
        der(x) = vx;
        der(y) = vy;
        der(vx) = a*x;
        der(vy) = a*y;
        x + y = F(p, time);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionInlining_Test9",
            description="Test function inlining during index reduction. Differentiated extra equations that aren't continuous should be removed!",
            flatModel="
fclass IndexReduction.FunctionInlining.Test9
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real a;
 parameter Real p[1] = 1 /* 1 */;
 Real _der_x;
 Real _der_vx;
 Real _der_der_y;
 Real temp_2;
 Real _der_temp_1;
initial equation
 y = 0.0;
 vy = 0.0;
equation
 _der_x = vx;
 der(y) = vy;
 _der_vx = a * x;
 der(vy) = a * y;
 x + y = IndexReduction.FunctionInlining.Test9.F({p[1]}, time);
 temp_2 = time;
 _der_x + der(y) = IndexReduction.FunctionInlining.Test9.F({p[1]}, p[1] + temp_2 * p[1]);
 _der_der_y = der(vy);
 _der_temp_1 = 0.0;
  _der_vx + _der_der_y = IndexReduction.FunctionInlining.Test9.F({p[1]}, (_der_temp_1 + (temp_2 * _der_temp_1 + p[1])) * p[1] + (p[1] + temp_2 * p[1]) * p[1]);

public
 function IndexReduction.FunctionInlining.Test9.F
  input Real[:] i1;
  input Real i2;
  output Real o1;
 algorithm
  o1 := i2;
  return;
 annotation(derivative(noDerivative = i1) = IndexReduction.FunctionInlining.Test9.F_der,Inline = false);
 end IndexReduction.FunctionInlining.Test9.F;

end IndexReduction.FunctionInlining.Test9;
")})));
    end Test9;

end FunctionInlining;

    package IncidencesThroughFunctions
        
        model RevoluteWithTranslation
            parameter Real[3] r(each stateSelect=StateSelect.never) = {1,0,0};
            inner Modelica.Mechanics.MultiBody.World world(n={0,0,-1});
            Modelica.Mechanics.MultiBody.Joints.Revolute revolute(w(start=1, fixed=true),phi(stateSelect=StateSelect.avoid),animation=false);
            Modelica.Mechanics.MultiBody.Parts.Body body(animation=false);
            Real[3] r_0(each stateSelect={StateSelect.never,StateSelect.never,StateSelect.prefer}), v_0, a_0;
        equation 
            connect(revolute.frame_a, world.frame_b);
            connect(body.frame_a, revolute.frame_b);
            r_0 = revolute.frame_b.r_0 + Modelica.Mechanics.MultiBody.Frames.resolve1(revolute.frame_b.R, r);
            v_0 = der(r_0);
            a_0 = der(v_0);

        annotation(__JModelica(UnitTesting(tests={
            FClassMethodTestCase(
                name="IncidencesThroughFunctions_RevoluteWithTranslation",
                description="Test a specific case where we need to look at the incidences through functions",
                methodName="stateDiagnosticsObj",
                methodResult="
States:
  Modelica.SIunits.Angle revolute.phi(stateSelect = StateSelect.avoid,start = 0) \"Relative rotation angle from frame_a to frame_b\"
  Modelica.SIunits.AngularVelocity revolute.w(start = 1,fixed = true,stateSelect = revolute.stateSelect) \"First derivative of angle phi (relative angular velocity)\"
")})));
        end RevoluteWithTranslation;
        
        model InlinedFunctionCall
            function F
                input Real i1;
                input Real i2;
                output Real o1;
                output Real o2;
            algorithm
                o1 := i1;
                o2 := i2;
                annotation(InlineAfterIndexReduction=true, derivative=F_der);
            end F;
            function F_der
                input Real i1;
                input Real i2;
                input Real i1_der;
                input Real i2_der;
                output Real o1_der;
                output Real o2_der;
            algorithm
                (o1_der, o2_der) := F(i1_der, i2_der);
                annotation(Inline=true);
            end F_der;
            
            Real a1,a2,a3,a4,b1,b2,b3,b4;
        equation
            der(a1) = a2;
            der(a2) = a3;
            der(b1) = b2;
            der(b2) = b3;
            a4 = time;
            b4 = time * 2;
            (a4,b4) = F(a1,b1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="IncidencesThroughFunctions_InlinedFunctionCall",
            description="Ensure that all variables referenced in the function call equation are differentiated as expected",
            flatModel="
fclass IndexReduction.IncidencesThroughFunctions.InlinedFunctionCall
 Real a1;
 Real a2;
 Real a3;
 Real a4;
 Real b1;
 Real b2;
 Real b3;
 Real b4;
 Real _der_a1;
 Real _der_b1;
 Real _der_a4;
 Real _der_b4;
equation
 _der_a1 = a2;
 _der_b1 = b2;
 a4 = time;
 b4 = 2 * a4;
 a4 = a1;
 b4 = b1;
 _der_a4 = 1.0;
 _der_b4 = 2 * _der_a4;
 _der_a4 = _der_a1;
 _der_b4 = _der_b1;
 a3 = 0.0;
 b3 = 2 * a3;
end IndexReduction.IncidencesThroughFunctions.InlinedFunctionCall;
")})));
        end InlinedFunctionCall;
        
        model AllIncidencesFallback
            record R
                Real a,b;
            end R;
            function F1
                input Real i1;
                input R i2;
                output Real o1;
            algorithm
                o1 := i1 * i2.a + i1 * i2.b;
                annotation(InlineAfterIndexReduction=true, derivative(noDerivative=i2)=F1_der);
            end F1;
            function F1_der
                input Real i1;
                input R i2;
                input Real i1_der;
                output Real o1_der;
            algorithm
                o1_der := F1(i1_der, i2) * i1_der;
                annotation(Inline=true);
            end F1_der;
            
            function F2
                input Real i1;
                output R o1;
            algorithm
                if i1 > 3.14 then
                    o1.a := i1 + 1;
                end if;
                o1.a := -i1;
                o1.b := i1;
            annotation(InlineAfterIndexReduction=false);
            end F2;
            
            function F3
                input Real i1;
                output Real o1;
            algorithm
                o1 := i1 - 1;
            annotation(InlineAfterIndexReduction=false);
            end F3;
            
            Real x,y;
        equation
            der(y) * der(x) = 1;
            y = F1(x, F2(x));

        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="IncidencesThroughFunctions_AllIncidencesFallback",
                description="If we fail with the incidence calculation (if statement in F2) then we should fall back to using all incidences",
                common_subexp_elim=true,
                flatModel="
fclass IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback
 Real x;
 Real y;
 Real _der_y;
 Real temp_13;
 Real temp_14;
initial equation 
 x = 0.0;
equation
 _der_y * der(x) = 1;
 y = x * temp_13 + x * temp_14;
 _der_y = (der(x) * temp_13 + der(x) * temp_14) * der(x);
 (IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback.R(temp_13, temp_14)) = IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback.F2(x);

public
 function IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback.F2
  input Real i1;
  output IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback.R o1;
 algorithm
  if i1 > 3.14 then
   o1.a := i1 + 1;
  end if;
  o1.a := - i1;
  o1.b := i1;
  return;
 annotation(InlineAfterIndexReduction = false);
 end IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback.F2;

 record IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback.R
  Real a;
  Real b;
 end IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback.R;

end IndexReduction.IncidencesThroughFunctions.AllIncidencesFallback;
")})));
        end AllIncidencesFallback;
        
    end IncidencesThroughFunctions;

model DiffGlobalAccess1
    record R
        Real[1] x;
    end R;

    function g
        input Real x;
        input R[:] rs;
        output Real y = x + rs[1].x[1];
    algorithm
    end g;

    function f
        input Real x;
        output Real y = g(x,rs);
        constant R[:] rs = {R({1})};
    algorithm
        annotation(Inline=false, smoothOrder=1);
    end f;

    Real x;
    Real y(stateSelect=StateSelect.always);
equation
    der(x) = -x;
    y=100*f(x);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DiffGlobalAccess1",
            description="Test of system with non differentiated variable with StateSelect always and prefer",
            flatModel="
fclass IndexReduction.DiffGlobalAccess1
 Real x;
 Real y(stateSelect = StateSelect.always);
 Real _der_x;
global variables
 constant IndexReduction.DiffGlobalAccess1.R IndexReduction.DiffGlobalAccess1.f.rs[1] = {IndexReduction.DiffGlobalAccess1.R({1})};
initial equation
 y = 0.0;
equation
 _der_x = - x;
 y = 100 * IndexReduction.DiffGlobalAccess1.f(x);
 der(y) = 100 * IndexReduction.DiffGlobalAccess1._der_f(x, _der_x);

public
 function IndexReduction.DiffGlobalAccess1.f
  input Real x;
  output Real y;
 algorithm
  y := IndexReduction.DiffGlobalAccess1.g(x, global(IndexReduction.DiffGlobalAccess1.f.rs));
  return;
 annotation(Inline = false,smoothOrder = 1,derivative(order = 1) = IndexReduction.DiffGlobalAccess1._der_f);
 end IndexReduction.DiffGlobalAccess1.f;

 function IndexReduction.DiffGlobalAccess1.g
  input Real x;
  input IndexReduction.DiffGlobalAccess1.R[:] rs;
  output Real y;
 algorithm
  y := x + rs[1].x[1];
  for i1 in 1:size(rs, 1) loop
   assert(1 == size(rs[i1].x, 1), \"Mismatching sizes in function 'IndexReduction.DiffGlobalAccess1.g', component 'rs[i1].x', dimension '1'\");
  end for;
  return;
 annotation(derivative(order = 1) = IndexReduction.DiffGlobalAccess1._der_g);
 end IndexReduction.DiffGlobalAccess1.g;

 function IndexReduction.DiffGlobalAccess1._der_f
  input Real x;
  input Real _der_x;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := IndexReduction.DiffGlobalAccess1._der_g(x, global(IndexReduction.DiffGlobalAccess1.f.rs), _der_x, {IndexReduction.DiffGlobalAccess1.R({0.0})});
  y := IndexReduction.DiffGlobalAccess1.g(x, global(IndexReduction.DiffGlobalAccess1.f.rs));
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.DiffGlobalAccess1._der_f;

 function IndexReduction.DiffGlobalAccess1._der_g
  input Real x;
  input IndexReduction.DiffGlobalAccess1.R[:] rs;
  input Real _der_x;
  input IndexReduction.DiffGlobalAccess1.R[:] _der_rs;
  output Real _der_y;
  Real y;
 algorithm
  _der_y := _der_x + _der_rs[1].x[1];
  y := x + rs[1].x[1];
  for i1 in 1:size(rs, 1) loop
   assert(1 == size(rs[i1].x, 1), \"Mismatching sizes in function 'IndexReduction.DiffGlobalAccess1.g', component 'rs[i1].x', dimension '1'\");
  end for;
  return;
 annotation(smoothOrder = 0);
 end IndexReduction.DiffGlobalAccess1._der_g;

 record IndexReduction.DiffGlobalAccess1.R
  Real x[1];
 end IndexReduction.DiffGlobalAccess1.R;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated).\", always \"Do use it as a state.\");

end IndexReduction.DiffGlobalAccess1;
")})));
end DiffGlobalAccess1;

end IndexReduction;

