within ;
model Furuta

 parameter Real armFriction = 0.012;
 parameter Real pendulumFriction = 0.002;

  inner Modelica.Mechanics.MultiBody.World world 
    annotation (Placement(transformation(extent={{-66,-58},{-46,-38}})));
  Modelica.Mechanics.MultiBody.Parts.BodyShape arm(
    r={0.245,0,0},
    m=0.165,
    I_11=0.00144) 
    annotation (Placement(transformation(extent={{-18,16},{2,36}})));
  Modelica.Mechanics.MultiBody.Parts.BodyShape pendulum(
    r={0,0.421,0},
    r_CM={0,0.421,0}/2,
    m=0.035,
    I_11=0.00384) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={62,6})));
  Modelica.Mechanics.MultiBody.Joints.Revolute armJoint(n={0,1,0},
      useAxisFlange=true) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-34,-14})));
  Modelica.Mechanics.MultiBody.Joints.Revolute pendulumJoint(
    n={1,0,0},
    useAxisFlange=true,
    phi(start=0.5235987755983)) 
    annotation (Placement(transformation(extent={{18,16},{38,36}})));
  Modelica.Mechanics.Rotational.Components.BearingFriction armBearingFriction(
    useSupport=true,
    peak=1,
    tau_pos=[0,1; 1,1]*armFriction) 
            annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-68,-20})));
  Modelica.Mechanics.Rotational.Components.BearingFriction
    pendulumBearingFriction(
    useSupport=true,
    peak=1,
    tau_pos=[0,1]*pendulumFriction) 
    annotation (Placement(transformation(extent={{12,48},{32,68}})));

equation
  connect(world.frame_b,armJoint. frame_a) annotation (Line(
      points={{-46,-48},{-34,-48},{-34,-24}},
      color={95,95,95},
      thickness=0.5,
      smooth=Smooth.None));
  connect(armJoint.frame_b, arm.frame_a) annotation (Line(
      points={{-34,-4},{-34,26},{-18,26}},
      color={95,95,95},
      thickness=0.5,
      smooth=Smooth.None));
  connect(arm.frame_b, pendulumJoint.frame_a) 
                                          annotation (Line(
      points={{2,26},{18,26}},
      color={95,95,95},
      thickness=0.5,
      smooth=Smooth.None));
  connect(pendulumJoint.frame_b, pendulum.frame_a) 
                                               annotation (Line(
      points={{38,26},{62,26},{62,16}},
      color={95,95,95},
      thickness=0.5,
      smooth=Smooth.None));
  connect(armJoint.axis, armBearingFriction.flange_b) 
                                                   annotation (Line(
      points={{-44,-14},{-50,-14},{-50,-10},{-68,-10}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(pendulumJoint.axis, pendulumBearingFriction.flange_b) 
                                                     annotation (Line(
      points={{28,36},{32,36},{32,58}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(pendulumJoint.support, pendulumBearingFriction.support) 
                                                       annotation (Line(
      points={{22,36},{22,48}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(armJoint.support, armBearingFriction.support) 
                                                     annotation (Line(
      points={{-44,-20},{-58,-20}},
      color={0,0,0},
      smooth=Smooth.None));
end Furuta;
