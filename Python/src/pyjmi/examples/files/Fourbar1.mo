within ;
package Fourbar1 "MSL fourbar1"
  model Fourbar1 "MSL fourbar1"
    extends Modelica.Icons.Example;

    output Modelica.SIunits.Angle j1_phi "angle of revolute joint j1";
    output Modelica.SIunits.Position j2_s "distance of prismatic joint j2";
    output Modelica.SIunits.AngularVelocity j1_w
      "axis speed of revolute joint j1";
    output Modelica.SIunits.Velocity j2_v "axis velocity of prismatic joint j2";

    inner Modelica.Mechanics.MultiBody.World world annotation (Placement(
          transformation(extent={{-100,-80},{-80,-60}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute j1(
      n={1,0,0},
      stateSelect=StateSelect.always,
      w(displayUnit="deg/s",
        start=0,
        fixed=true),
      phi(fixed=true, start=2.9441959151892))
                   annotation (Placement(transformation(extent={{-54,-40},{-34,
              -20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Prismatic j2(
      n={1,0,0},
      s(start=-0.2),
      boxWidth=0.05) annotation (Placement(transformation(extent={{10,-80},{30,
              -60}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Parts.BodyCylinder b1(r={0,0.5,0.1}, diameter=0.05)
      annotation (Placement(transformation(
          origin={-30,2},
          extent={{-10,-10},{10,10}},
          rotation=90)));
    Modelica.Mechanics.MultiBody.Parts.BodyCylinder b2(r={0,0.2,0}, diameter=0.05)
      annotation (Placement(transformation(
          origin={50,-50},
          extent={{-10,-10},{10,10}},
          rotation=90)));
    Modelica.Mechanics.MultiBody.Parts.BodyCylinder b3(r={-1,0.3,0.1}, diameter=0.05)
      annotation (Placement(transformation(extent={{38,20},{18,40}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute rev(n={0,1,0})
      annotation (Placement(transformation(
          origin={50,-22},
          extent={{-10,-10},{10,10}},
          rotation=90)));
    Modelica.Mechanics.MultiBody.Joints.Revolute rev1 annotation (Placement(
          transformation(extent={{60,0},{80,20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute j3(n={1,0,0}) annotation (Placement(
          transformation(extent={{-60,40},{-40,60}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute j4(n={0,1,0}) annotation (Placement(
          transformation(extent={{-32,60},{-12,80}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute j5(n={0,0,1}) annotation (Placement(
          transformation(extent={{0,70},{20,90}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Parts.FixedTranslation b0(animation=false, r={1.2,0,0})
      annotation (Placement(transformation(extent={{-40,-80},{-20,-60}}, rotation=
             0)));
    Modelica.Mechanics.MultiBody.Forces.WorldTorque torque1
      annotation (Placement(transformation(extent={{-88,-22},{-68,-2}})));
    Modelica.Blocks.Routing.Multiplex3 multiplex3
      annotation (Placement(transformation(extent={{-112,-18},{-100,-6}})));
    Modelica.Blocks.Sources.Constant const(k=0)
      annotation (Placement(transformation(extent={{-166,-50},{-150,-34}})));
    Modelica.Blocks.Sources.Constant const1(k=0)
      annotation (Placement(transformation(extent={{-166,-20},{-150,-4}})));
    Modelica.Blocks.Interfaces.RealInput u
      annotation (Placement(transformation(extent={{-180,-2},{-150,28}})));
  equation
    connect(j2.frame_b, b2.frame_a) annotation (Line(
        points={{30,-70},{50,-70},{50,-60}},
        color={95,95,95},
        thickness=0.5));
    connect(j1.frame_b, b1.frame_a) annotation (Line(
        points={{-34,-30},{-30,-30},{-30,-8}},
        color={95,95,95},
        thickness=0.5));
    connect(rev.frame_a, b2.frame_b)
      annotation (Line(
        points={{50,-32},{50,-40}},
        color={95,95,95},
        thickness=0.5));
    connect(rev.frame_b, rev1.frame_a)
      annotation (Line(
        points={{50,-12},{50,10},{60,10}},
        color={95,95,95},
        thickness=0.5));
    connect(rev1.frame_b, b3.frame_a) annotation (Line(
        points={{80,10},{90,10},{90,30},{38,30}},
        color={95,95,95},
        thickness=0.5));
    connect(world.frame_b, j1.frame_a) annotation (Line(
        points={{-80,-70},{-66,-70},{-66,-30},{-54,-30}},
        color={95,95,95},
        thickness=0.5));
    connect(b1.frame_b, j3.frame_a) annotation (Line(
        points={{-30,12},{-30,28},{-72,28},{-72,50},{-60,50}},
        color={95,95,95},
        thickness=0.5));
    connect(j3.frame_b, j4.frame_a) annotation (Line(
        points={{-40,50},{-34,50},{-42,70},{-32,70}},
        color={95,95,95},
        thickness=0.5));
    connect(j4.frame_b, j5.frame_a)
      annotation (Line(
        points={{-12,70},{-5.55112e-16,70},{-5.55112e-16,80}},
        color={95,95,95},
        thickness=0.5));
    connect(j5.frame_b, b3.frame_b) annotation (Line(
        points={{20,80},{30,80},{30,54},{4,54},{4,30},{18,30}},
        color={95,95,95},
        thickness=0.5));
    connect(b0.frame_a, world.frame_b)
      annotation (Line(
        points={{-40,-70},{-80,-70}},
        color={95,95,95},
        thickness=0.5));
    connect(b0.frame_b, j2.frame_a)
      annotation (Line(
        points={{-20,-70},{10,-70}},
        color={95,95,95},
        thickness=0.5));
    j1_phi = j1.phi;
    j2_s = j2.s;
    j1_w = j1.w;
    j2_v = j2.v;
    connect(multiplex3.y,torque1. torque) annotation (Line(
        points={{-99.4,-12},{-90,-12}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const1.y,multiplex3. u2[1]) annotation (Line(
        points={{-149.2,-12},{-113.2,-12}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(torque1.frame_b, b1.frame_a) annotation (Line(
        points={{-68,-12},{-30,-12},{-30,-8}},
        color={95,95,95},
        thickness=0.5,
        smooth=Smooth.None));
    connect(u, multiplex3.u1[1]) annotation (Line(
        points={{-165,13},{-131.5,13},{-131.5,-7.8},{-113.2,-7.8}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const.y, multiplex3.u3[1]) annotation (Line(
        points={{-149.2,-42},{-132,-42},{-132,-16.2},{-113.2,-16.2}},
        color={0,0,127},
        smooth=Smooth.None));
    annotation (
      experiment(StopTime=5),
      Documentation(info="<html>
<p>
This is a simple kinematic loop consisting of 6 revolute joints, 1 prismatic joint
and 4 bars that is often used as basic constructing unit in mechanisms.
This example demonstrates that usually no particular knowledge
of the user is needed to handle kinematic loops.
Just connect the joints and bodies together according
to the real system. In particular <b>no</b> cut-joints or a spanning tree has
to be determined. In this case, the initial condition of the angular velocity
of revolute joint j1 is set to 300 deg/s in order to drive this loop.
</p>

<IMG src=\"modelica://Modelica/Resources/Images/Mechanics/MultiBody/Examples/Loops/Fourbar1.png\" ALT=\"model Examples.Loops.Fourbar1\">
</html>"),
      Diagram(coordinateSystem(extent={{-180,-100},{100,100}},
            preserveAspectRatio=false), graphics),
      Icon(coordinateSystem(extent={{-180,-100},{100,100}})));
  end Fourbar1;

  model Fourbar1Feedback

    Fourbar1 fourbar1(j1(w(start=0)))
      annotation (Placement(transformation(extent={{6,52},{34,72}})));
    Real s_ref = -0.35;
    Real u;
    Real ie(start=0, fixed=true);
  equation
    der(ie) = (fourbar1.j2.s-s_ref);
    u = 2000*(fourbar1.j2.s-s_ref)+800*fourbar1.j2.v+1500*ie;
    //u = -50;
    fourbar1.u = u;
  end Fourbar1Feedback;

  model Fourbar1Sim
    Fourbar1 fourbar1;
    input Real u;
  equation
    fourbar1.u = u;
  end Fourbar1Sim;

  model JMSim
    Fourbar1 fourbar1_1(torque1(color={155,155,155}, Nm_to_m=300))
      annotation (Placement(transformation(extent={{44,-2},{72,18}})));
    Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
      tableOnFile=true,
      tableName="opt_trajs",
      fileName="/work/fredrikm/JModelica.org-BLT/fourbar_sol.mat")
      annotation (Placement(transformation(extent={{-46,0},{-26,20}})));
  equation
    connect(combiTimeTable.y[1], fourbar1_1.u) annotation (Line(
        points={{-25,10},{10,10},{10,9.3},{45.5,9.3}},
        color={0,0,127},
        smooth=Smooth.None));
    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{
              -100,-100},{100,100}}), graphics));
  end JMSim;
end Fourbar1;
