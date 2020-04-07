within ;
package DoublePendulum "MSL Double pendulum"
  model Feedback

    DoublePendulum pendulum
      annotation (Placement(transformation(extent={{-8,32},{16,52}})));
    Real u;
    constant Real pi = Modelica.Constants.pi;
  equation
    u = -600*(pendulum.revolute1.phi-pi/2) - 400*pendulum.revolute1.w;
    pendulum.u = u;
  end Feedback;

  model Sim
    DoublePendulum pendulum
      annotation (Placement(transformation(extent={{-8,32},{16,52}})));
    input Real u;
  equation
    pendulum.u = u;
  end Sim;

    model JMSim
      DoublePendulum doublePendulum
        annotation (Placement(transformation(extent={{10,8},{30,28}})));
      Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
        tableOnFile=true,
        tableName="torque",
        fileName="/work/fredrikm/JModelica.org-BLT/double_pendulum_sol.mat")
        annotation (Placement(transformation(extent={{-62,2},{-42,22}})));
    equation
      connect(combiTimeTable.y[1], doublePendulum.u) annotation (Line(
          points={{-41,12},{-16,12},{-16,11.7},{11.4167,11.7}},
          color={0,0,127},
          smooth=Smooth.None));
      annotation (uses(Modelica(version="3.2.1")), Diagram(coordinateSystem(
              preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics));
    end JMSim;

  model DoublePendulum "MSL Double pendulum"

    extends Modelica.Icons.Example;
    inner Modelica.Mechanics.MultiBody.World world annotation (Placement(
          transformation(extent={{-88,0},{-68,20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute revolute1(useAxisFlange=true,
      phi(
        fixed=true,
        displayUnit="deg",
        start=-0.78539816339745),
      w(fixed=true,
        start=-0.78539816339745,
        displayUnit="deg/s"))                                      annotation (Placement(transformation(extent={{-48,0},
              {-28,20}}, rotation=0)));
    Modelica.Mechanics.Rotational.Components.Damper damper(d=0.1)
      annotation (Placement(transformation(extent={{-48,40},{-28,60}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Parts.BodyBox boxBody1(r={0.5,0,0}, width=0.06)
      annotation (Placement(transformation(extent={{-10,0},{10,20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute revolute2(
      useAxisFlange=false,
      phi(fixed=true, start=-0.78539816339745),
      w(fixed=true,
        displayUnit="deg/s",
        start=-0.78539816339745))                          annotation (Placement(transformation(extent={{32,0},{
              52,20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Parts.BodyBox boxBody2(r={0.5,0,0}, width=0.06)
      annotation (Placement(transformation(extent={{74,0},{94,20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Forces.WorldTorque torque1
      annotation (Placement(transformation(extent={{-46,-44},{-26,-24}})));
    Modelica.Blocks.Routing.Multiplex3 multiplex3
      annotation (Placement(transformation(extent={{-70,-40},{-58,-28}})));
    Modelica.Blocks.Interfaces.RealInput u
      annotation (Placement(transformation(extent={{-138,-78},{-108,-48}})));
    Modelica.Blocks.Sources.Constant const(k=0)
      annotation (Placement(transformation(extent={{-124,-16},{-108,0}})));
    Modelica.Blocks.Sources.Constant const1(k=0)
      annotation (Placement(transformation(extent={{-124,-42},{-108,-26}})));
  equation

    connect(revolute1.support, damper.flange_a) annotation (Line(points={{-44,20},
            {-44,28},{-58,28},{-58,50},{-48,50}}, color={0,0,0}));
    connect(revolute1.frame_b, boxBody1.frame_a)
      annotation (Line(
        points={{-28,10},{-10,10}},
        color={95,95,95},
        thickness=0.5));
    connect(revolute2.frame_b, boxBody2.frame_a)
      annotation (Line(
        points={{52,10},{74,10}},
        color={95,95,95},
        thickness=0.5));
    connect(boxBody1.frame_b, revolute2.frame_a)
      annotation (Line(
        points={{10,10},{32,10}},
        color={95,95,95},
        thickness=0.5));
    connect(world.frame_b, revolute1.frame_a)
      annotation (Line(
        points={{-68,10},{-48,10}},
        color={95,95,95},
        thickness=0.5));
    connect(damper.flange_b, revolute1.axis) annotation (Line(
        points={{-28,50},{-20,50},{-20,20},{-38,20}},
        color={0,0,0},
        smooth=Smooth.None));
    connect(torque1.frame_b, boxBody1.frame_a) annotation (Line(
        points={{-26,-34},{-20,-34},{-20,10},{-10,10}},
        color={95,95,95},
        thickness=0.5,
        smooth=Smooth.None));
    connect(multiplex3.y, torque1.torque) annotation (Line(
        points={{-57.4,-34},{-48,-34}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(multiplex3.u3[1], u) annotation (Line(
        points={{-71.2,-38.2},{-94,-38.2},{-94,-63},{-123,-63}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const1.y, multiplex3.u2[1]) annotation (Line(
        points={{-107.2,-34},{-71.2,-34}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const.y, multiplex3.u1[1]) annotation (Line(
        points={{-107.2,-8},{-94,-8},{-94,-29.8},{-71.2,-29.8}},
        color={0,0,127},
        smooth=Smooth.None));
    annotation (
      experiment(StopTime=3),
      Documentation(info="<html>
<p>
This example demonstrates that by using joint and body
elements animation is automatically available. Also the revolute
joints are animated. Note, that animation of every component
can be switched of by setting the first parameter <b>animation</b>
to <b>false</b> or by setting <b>enableAnimation</b> in the <b>world</b>
object to <b>false</b> to switch off animation of all components.
</p>

<table border=0 cellspacing=0 cellpadding=0><tr><td valign=\"top\">
<IMG src=\"modelica://Modelica/Resources/Images/Mechanics/MultiBody/Examples/Elementary/DoublePendulum.png\"
ALT=\"model Examples.Elementary.DoublePendulum\">
</td></tr></table>

</HTML>"),
      Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-140,-100},{
              100,100}}), graphics),
      Icon(coordinateSystem(extent={{-140,-100},{100,100}})));
  end DoublePendulum;

  model DoublePendulumJMSim2 "MSL Double pendulum"

    extends Modelica.Icons.Example;
    inner Modelica.Mechanics.MultiBody.World world(g=0)
                                                   annotation (Placement(
          transformation(extent={{-128,0},{-108,20}},
                                                    rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute revolute1(useAxisFlange=true,
      w(fixed=true,
        start=0,
        displayUnit="deg/s"),
      phi(
        fixed=true,
        displayUnit="deg",
        start=0.20420352248334))                                   annotation (Placement(transformation(extent={{-48,0},
              {-28,20}}, rotation=0)));
    Modelica.Mechanics.Rotational.Components.Damper damper(d=0.1)
      annotation (Placement(transformation(extent={{-48,40},{-28,60}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Parts.BodyBox boxBody1(r={0.5,0,0}, width=0.06)
      annotation (Placement(transformation(extent={{-10,0},{10,20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Joints.Revolute revolute2(
      useAxisFlange=false,
      w(fixed=true,
        displayUnit="deg/s",
        start=0),
      phi(fixed=true, start=0))                            annotation (Placement(transformation(extent={{48,0},{
              68,20}}, rotation=0)));
    Modelica.Mechanics.MultiBody.Parts.BodyBox boxBody2(r={0.5,0,0}, width=0.06)
      annotation (Placement(transformation(extent={{78,0},{98,20}}, rotation=0)));
    Modelon.Mechanics.MultiBody.Actuators.Rotate rotate(
      w={0,0,0},
      z={0,0,0},
      visualize=false)
      annotation (Placement(transformation(extent={{-82,0},{-62,20}})));
    Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
      tableOnFile=true,
      fileName="/work/fredrikm/JModelica.org-BLT/double_pendulum_sol.mat",
      tableName="opt_trajs",
      columns=3:4)
      annotation (Placement(transformation(extent={{-194,-100},{-174,-80}})));
    Modelica.Blocks.Routing.DeMultiplex2 deMultiplex2_1
      annotation (Placement(transformation(extent={{-164,-100},{-144,-80}})));
    Modelon.Mechanics.MultiBody.Actuators.Rotate rotate1(w={0,0,0}, z={0,0,0})
      annotation (Placement(transformation(extent={{18,0},{38,20}})));
    Modelica.Blocks.Routing.Multiplex3 multiplex3
      annotation (Placement(transformation(extent={{-104,-62},{-92,-50}})));
    Modelica.Blocks.Sources.Constant const(k=0)
      annotation (Placement(transformation(extent={{-146,-38},{-130,-22}})));
    Modelica.Blocks.Sources.Constant const1(k=0)
      annotation (Placement(transformation(extent={{-146,-64},{-130,-48}})));
    Modelica.Blocks.Routing.Multiplex3 multiplex1
      annotation (Placement(transformation(extent={{-18,-62},{-6,-50}})));
    Modelica.Blocks.Sources.Constant const2(
                                           k=0)
      annotation (Placement(transformation(extent={{-60,-38},{-44,-22}})));
    Modelica.Blocks.Sources.Constant const3(k=0)
      annotation (Placement(transformation(extent={{-60,-64},{-44,-48}})));
  equation

    connect(revolute1.support, damper.flange_a) annotation (Line(points={{-44,20},
            {-44,28},{-58,28},{-58,50},{-48,50}}, color={0,0,0}));
    connect(revolute2.frame_b, boxBody2.frame_a)
      annotation (Line(
        points={{68,10},{78,10}},
        color={95,95,95},
        thickness=0.5));
    connect(damper.flange_b, revolute1.axis) annotation (Line(
        points={{-28,50},{-20,50},{-20,20},{-38,20}},
        color={0,0,0},
        smooth=Smooth.None));
    connect(revolute1.frame_b, boxBody1.frame_a) annotation (Line(
        points={{-28,10},{-10,10}},
        color={95,95,95},
        thickness=0.5,
        smooth=Smooth.None));
    connect(world.frame_b, rotate.frame_a) annotation (Line(
        points={{-108,10},{-82,10}},
        color={95,95,95},
        thickness=0.5,
        smooth=Smooth.None));
    connect(rotate.frame_b, revolute1.frame_a) annotation (Line(
        points={{-62,10},{-48,10}},
        color={95,95,95},
        thickness=0.5,
        smooth=Smooth.None));
    connect(combiTimeTable.y, deMultiplex2_1.u) annotation (Line(
        points={{-173,-90},{-166,-90}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(rotate1.frame_b, revolute2.frame_a) annotation (Line(
        points={{38,10},{48,10}},
        color={95,95,95},
        thickness=0.5,
        smooth=Smooth.None));
    connect(boxBody1.frame_b, rotate1.frame_a) annotation (Line(
        points={{10,10},{18,10}},
        color={95,95,95},
        thickness=0.5,
        smooth=Smooth.None));
    connect(const1.y,multiplex3. u2[1]) annotation (Line(
        points={{-129.2,-56},{-105.2,-56}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const.y,multiplex3. u1[1]) annotation (Line(
        points={{-129.2,-30},{-116,-30},{-116,-51.8},{-105.2,-51.8}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(deMultiplex2_1.y1, multiplex3.u3) annotation (Line(
        points={{-143,-84},{-116,-84},{-116,-60.2},{-105.2,-60.2}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(multiplex3.y, rotate.p) annotation (Line(
        points={{-91.4,-56},{-78,-56},{-78,4}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const3.y,multiplex1. u2[1]) annotation (Line(
        points={{-43.2,-56},{-19.2,-56}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const2.y, multiplex1.u1[1]) annotation (Line(
        points={{-43.2,-30},{-30,-30},{-30,-51.8},{-19.2,-51.8}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(deMultiplex2_1.y2, multiplex1.u3) annotation (Line(
        points={{-143,-96},{-30,-96},{-30,-60.2},{-19.2,-60.2}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(multiplex1.y, rotate1.p) annotation (Line(
        points={{-5.4,-56},{22,-56},{22,4}},
        color={0,0,127},
        smooth=Smooth.None));
    annotation (
      experiment(StopTime=3),
      Documentation(info="<html>
<p>
This example demonstrates that by using joint and body
elements animation is automatically available. Also the revolute
joints are animated. Note, that animation of every component
can be switched of by setting the first parameter <b>animation</b>
to <b>false</b> or by setting <b>enableAnimation</b> in the <b>world</b>
object to <b>false</b> to switch off animation of all components.
</p>

<table border=0 cellspacing=0 cellpadding=0><tr><td valign=\"top\">
<IMG src=\"modelica://Modelica/Resources/Images/Mechanics/MultiBody/Examples/Elementary/DoublePendulum.png\"
ALT=\"model Examples.Elementary.DoublePendulum\">
</td></tr></table>

</HTML>"),
      Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-200,-120},{
              100,100}}), graphics),
      Icon(coordinateSystem(extent={{-200,-120},{100,100}})));
  end DoublePendulumJMSim2;
  annotation (uses(Modelica(version="3.2.1"), Modelon(version="2.1")));
end DoublePendulum;
