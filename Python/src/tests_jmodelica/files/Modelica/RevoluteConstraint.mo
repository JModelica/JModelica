model StrippedRevoluteConstraint

//Stripped version of the RevoluteConstraint model from MSL


model FixedTranslation
  import Modelica.Mechanics.MultiBody.Types;
  import Modelica.Mechanics.MultiBody.*;

  Interfaces.Frame_a frame_a;
  Interfaces.Frame_b frame_b;
  parameter Modelica.SIunits.Position r[3](start={0,0,0})
    "Vector from frame_a to frame_b resolved in frame_a";
protected 
  outer Modelica.Mechanics.MultiBody.World world;
equation 
  Connections.branch(frame_a.R, frame_b.R);

  frame_b.r_0 = frame_a.r_0 + Frames.resolve1(frame_a.R, r);
  frame_b.R = frame_a.R;

  /* Force and torque balance */
  zeros(3) = frame_a.f + frame_b.f;
  zeros(3) = frame_a.t + frame_b.t + cross(r, frame_b.f);
end FixedTranslation;

model FixedRotation
  import Modelica.Mechanics.MultiBody.*;
  import Modelica.Mechanics.MultiBody.Frames;
  import Modelica.SIunits.Conversions.to_unit1;

  Interfaces.Frame_a frame_a;
  Interfaces.Frame_b frame_b;

  parameter Modelica.SIunits.Position r[3]={0,0,0};
  parameter Modelica.Mechanics.MultiBody.Types.Axis n={1,0,0};

  parameter Modelica.Mechanics.MultiBody.Types.RotationSequence sequence(
    min={1,1,1},max={3,3,3}) = {1,2,3};
    
  parameter Modelica.SIunits.Conversions.NonSIunits.Angle_deg angles[3]={0,0,0};
  
  final parameter Frames.Orientation R_rel=Frames.axesRotations(sequence,
        Modelica.SIunits.Conversions.from_deg(angles),zeros(3));
  
protected 
  outer Modelica.Mechanics.MultiBody.World world;
  parameter Frames.Orientation R_rel_inv=Frames.from_T(transpose(R_rel.T),zeros(3));
  
equation 
  Connections.branch(frame_a.R, frame_b.R);

  frame_b.r_0 = frame_a.r_0 + Frames.resolve1(frame_a.R, r);
    frame_b.R = Frames.absoluteRotation(frame_a.R, R_rel);
    zeros(3) = frame_a.f + Frames.resolve1(R_rel, frame_b.f);
    zeros(3) = frame_a.t + Frames.resolve1(R_rel, frame_b.t) - cross(r,frame_a.f);
end FixedRotation;

model Revolute
import Modelica.Mechanics.MultiBody.Types;
  import Modelica.Mechanics.MultiBody.*;
  extends Modelica.Mechanics.MultiBody.Interfaces.PartialTwoFrames;

  parameter Types.Axis n={0,1,0} annotation (Evaluate=true);


protected 
  Frames.Orientation R_rel;
  Modelica.SIunits.Position r_rel_a[3];
  

  parameter Real e[3](each final unit="1")=Modelica.Math.Vectors.normalizeWithAssert(n);

  parameter Real nnx_a[3](each final unit="1")=if abs(e[1]) > 0.1 then {0,1,0} else (if abs(e[2])
       > 0.1 then {0,0,1} else {1,0,0})
    "Arbitrary vector that is not aligned with rotation axis n"
    annotation (Evaluate=true);
      parameter Real ey_a[3](each final unit="1")=Modelica.Math.Vectors.normalizeWithAssert(
                                          cross(e, nnx_a))
    "Unit vector orthogonal to axis n of revolute joint, resolved in frame_a"
    annotation (Evaluate=true);
  parameter Real ex_a[3](each final unit="1")=cross(ey_a, e);


equation 
  // Determine relative position vector resolved in frame_a
  R_rel = Frames.relativeRotation(frame_a.R, frame_b.R);
  r_rel_a = Frames.resolve2(frame_a.R, frame_b.r_0 - frame_a.r_0);

  r_rel_a=zeros(3);

  // Constraint equations concerning rotations
  0 = ex_a*R_rel.T*e;
  0 = ey_a*R_rel.T*e;
  frame_a.t*n=0;

  zeros(3) = frame_a.f + Frames.resolve1(R_rel, frame_b.f);
  zeros(3) = frame_a.t + Frames.resolve1(R_rel, frame_b.t) - cross(r_rel_a,
    frame_a.f);

end Revolute;

  Revolute constraint;
  
  Modelica.Mechanics.MultiBody.Sensors.RelativeSensor sensorConstraintRelative(
    resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameAB.frame_a,
    get_r_rel=true,
    get_a_rel=false,
    get_angles=true);
    
  Modelica.Mechanics.MultiBody.Parts.BodyShape bodyOfConstraint(animation=
       false,
    I_11=1,
    I_22=1,
    I_33=1,
    width=0.05,
    r_0(start={0.2,-0.5,0.1}, each fixed=false),
    v_0(each fixed=false),
    angles_fixed=false,
    w_0_fixed=false,
    final color={0,128,0},
    r={0.4,0,0},
    r_CM={0.2,0,0},
    m=1,
    angles_start={0.17453292519943,0.95993108859688,1.1868238913561});
  Modelica.Mechanics.MultiBody.Forces.Spring springOfConstraint(animation=
       false,
    width=0.1,
    coilWidth=0.005,
    c=20,
    s_unstretched=0,
    numberOfWindings=5);
  inner Modelica.Mechanics.MultiBody.World world(enableAnimation=false);
  
  FixedRotation fixedRotation(r={0.2,-0.3,0.2},angles={10,55,68});
  FixedTranslation fixedTranslation(r={0.8,0,0.3});
  
  Modelica.Mechanics.MultiBody.Joints.FreeMotionScalarInit freeMotionScalarInit(animation=
       false,
    use_angle=true,
    use_angle_d=true,
    angle_2(start=0, fixed=true),
    angle_d_2(start=0, fixed=true));
equation 
  connect(fixedTranslation.frame_a, world.frame_b);
  connect(bodyOfConstraint.frame_b, springOfConstraint.frame_b);
  connect(world.frame_b, fixedRotation.frame_a);
  connect(fixedRotation.frame_b, constraint.frame_a);
  connect(constraint.frame_a,sensorConstraintRelative. frame_a);
  connect(sensorConstraintRelative.frame_b, constraint.frame_b);
  connect(fixedTranslation.frame_b, springOfConstraint.frame_a);
  connect(bodyOfConstraint.frame_a, constraint.frame_b);
  connect(freeMotionScalarInit.frame_a, fixedRotation.frame_b);
  connect(bodyOfConstraint.frame_a, freeMotionScalarInit.frame_b);

end StrippedRevoluteConstraint;
