model OutputTest
  output Real x_1(start=0.951858508368);
  output Real x_2(start=2.17691690118);
  output Real x_3(start=1.47982066619);
  output Real x_4(start=2.41568015438);
  output Real x_5(start=2.50288121643);
  output Real w_ode_1_1;
  Real w_ode_1_2;
  Real w_ode_1_3;
  output Real w_ode_2_1;
  Real w_ode_2_2;
  Real w_ode_2_3;
  output Real w_ode_3_1;
  Real w_ode_3_2;
  Real w_ode_3_3;
  output Real w_ode_4_1;
  Real w_ode_4_2;
  Real w_ode_4_3;
  output Real w_ode_5_1;
  Real w_ode_5_2;
  Real w_ode_5_3;
  output Real w_output_1_1;
  output Real w_output_1_2;
  output Real w_output_1_3;
  output Real w_output_2_1;
  output Real w_output_2_2;
  output Real w_output_2_3;
  output Real w_output_3_1;
  output Real w_output_3_2;
  output Real w_output_3_3;
  output Real w_output_4_1;
  output Real w_output_4_2;
  output Real w_output_4_3;
  output Real w_output_5_1;
  output Real w_output_5_2;
  output Real w_output_5_3;
  output Real w_output_6_1;
  output Real w_output_6_2;
  output Real w_output_6_3;
  Real w_other_1_1;
  Real w_other_1_2;
  Real w_other_1_3;
  Real w_other_2_1;
  Real w_other_2_2;
  Real w_other_2_3;
  Real w_other_3_1;
  Real w_other_3_2;
  Real w_other_3_3;
  input Real ur_1;
  input Real ur_2;
  input Real ur_3;
  input Real ur_4;
equation
(w_ode_1_1) + 4*(w_ode_1_2) + (w_ode_1_3) + sin(x_5) - (x_3) - 4*(x_5) + cos(ur_3) + 4*(ur_3) = 0;
cos(w_ode_1_1) + (w_ode_1_2)*sin(w_ode_1_3) + 4*(x_4) - 4*(x_5) - 4*(x_4) + (ur_4) + 4*(ur_1) = 0;
sin(w_ode_1_1) - sin(w_ode_1_2) - sin(w_ode_1_3) + 4*(x_2)*4*(x_3)*4*(x_3) + 4*(ur_3)*4*(ur_1) = 0;

der(x_1) = cos(w_ode_1_1)*(w_ode_1_2)*cos(w_ode_1_3) + 4*(x_2) + 4*(x_1) - (x_5) + 4*(ur_2) + cos(ur_4);

(w_ode_2_1)*sin(w_ode_2_2)*4*(w_ode_2_3) + (x_3) - (x_5) + sin(x_2) + (ur_3)*sin(ur_1) = 0;
4*(w_ode_2_1)*sin(w_ode_2_2) - cos(w_ode_2_3) + cos(x_4)*cos(x_3) - cos(x_3) + 4*(ur_1) - cos(ur_2) = 0;
(w_ode_2_1) - cos(w_ode_2_2) + cos(w_ode_2_3) + sin(x_4)*sin(x_1)*cos(x_4) + cos(ur_1)*sin(ur_1) = 0;

der(x_2) = sin(w_ode_2_1) - sin(w_ode_2_2) - sin(w_ode_2_3) + sin(w_ode_1_1) - sin(w_ode_1_2) - 4*(w_ode_1_3) + sin(x_1) + 4*(x_3) + (x_4) + (ur_2) + sin(ur_3);

4*(w_ode_3_1) - 4*(w_ode_3_2) + sin(w_ode_3_3) + (x_4) + cos(x_5) + 4*(x_3) + sin(ur_4)*cos(ur_1) = 0;
4*(w_ode_3_1) - (w_ode_3_2) + 4*(w_ode_3_3) + sin(x_2) - 4*(x_2) + (x_3) + 4*(ur_4) - 4*(ur_4) = 0;
4*(w_ode_3_1) + cos(w_ode_3_2)*cos(w_ode_3_3) + (x_3) + cos(x_2) + 4*(x_2) + cos(ur_1)*4*(ur_4) = 0;

der(x_3) = 4*(w_ode_3_1) - (w_ode_3_2)*(w_ode_3_3) + sin(w_ode_2_1) - cos(w_ode_2_2) - 4*(w_ode_2_3) + 4*(x_4) - 4*(x_2) - (x_2) + (ur_3)*4*(ur_4);

4*(w_ode_4_1)*(w_ode_4_2) - 4*(w_ode_4_3) + cos(x_1) - sin(x_2)*(x_2) + (ur_1) + 4*(ur_1) = 0;
4*(w_ode_4_1) + cos(w_ode_4_2) + sin(w_ode_4_3) + sin(x_2) + sin(x_4) + cos(x_3) + (ur_3) + sin(ur_2) = 0;
cos(w_ode_4_1)*sin(w_ode_4_2)*cos(w_ode_4_3) + cos(x_3) - cos(x_2) - (x_3) + (ur_3) - sin(ur_3) = 0;

der(x_4) = 4*(w_ode_4_1)*sin(w_ode_4_2)*4*(w_ode_4_3) + sin(w_ode_3_1) - (w_ode_3_2)*cos(w_ode_3_3) + cos(x_5) - (x_4) - (x_4) + (ur_1) + (ur_4);

4*(w_ode_5_1) + (w_ode_5_2)*(w_ode_5_3) + 4*(x_5) - 4*(x_4) + 4*(x_5) + (ur_3)*4*(ur_3) = 0;
(w_ode_5_1) + cos(w_ode_5_2)*(w_ode_5_3) + 4*(x_1) - sin(x_2) - sin(x_4) + cos(ur_2)*sin(ur_1) = 0;
cos(w_ode_5_1) + cos(w_ode_5_2)*cos(w_ode_5_3) + 4*(x_3) + (x_3)*4*(x_4) + cos(ur_3) + sin(ur_2) = 0;

der(x_5) = (w_ode_5_1) - sin(w_ode_5_2) + cos(w_ode_5_3) + 4*(w_ode_4_1) + cos(w_ode_4_2) - 4*(w_ode_4_3) + (x_3) - sin(x_2) + sin(x_2) + (ur_2)*sin(ur_4);

cos(w_output_1_1) - 4*(w_output_1_2)*cos(w_output_1_3) + sin(x_3)*4*(x_4) - (x_5) + cos(ur_1)*4*(ur_3) = 0;
(w_output_1_1) + sin(w_output_1_2) + cos(w_output_1_3) + 4*(x_5) + sin(x_5)*(x_2) + sin(ur_1) - cos(ur_4) = 0;
cos(w_output_1_1) + sin(w_output_1_2) - sin(w_output_1_3) + sin(x_2) - (x_3) + cos(x_5) + 4*(ur_1) + 4*(ur_4) = 0;

sin(w_output_2_1)*4*(w_output_2_2) + cos(w_output_2_3) + 4*(x_4)*cos(x_5) - (x_2) + cos(ur_2)*cos(ur_2) = 0;
(w_output_2_1) - cos(w_output_2_2) + 4*(w_output_2_3) + (x_4) + cos(x_1) - cos(x_5) + sin(ur_3) + (ur_2) = 0;
cos(w_output_2_1)*cos(w_output_2_2)*sin(w_output_2_3) + (x_2) - (x_2)*sin(x_5) + cos(ur_2)*sin(ur_2) = 0;

4*(w_output_3_1) + sin(w_output_3_2) + (w_output_3_3) + (x_4) - cos(x_4)*cos(x_1) + sin(ur_3) + cos(ur_1) = 0;
cos(w_output_3_1) + sin(w_output_3_2)*(w_output_3_3) + sin(x_5) - cos(x_5) - 4*(x_5) + 4*(ur_3) - cos(ur_2) = 0;
cos(w_output_3_1) + 4*(w_output_3_2) - sin(w_output_3_3) + cos(x_3) + cos(x_3) - sin(x_1) + 4*(ur_3) + 4*(ur_4) = 0;

cos(w_output_4_1) + sin(w_output_4_2) + (w_output_4_3) + 4*(x_3)*(x_5)*cos(x_2) + cos(ur_4) - 4*(ur_3) = 0;
4*(w_output_4_1)*sin(w_output_4_2)*sin(w_output_4_3) + (x_1) + sin(x_1)*cos(x_1) + sin(ur_2) - 4*(ur_3) = 0;
sin(w_output_4_1) + 4*(w_output_4_2)*sin(w_output_4_3) + (x_2) + (x_3)*(x_3) + (ur_2) + sin(ur_1) = 0;

(w_output_5_1) + (w_output_5_2) + sin(w_output_5_3) + sin(x_1)*(x_1) - sin(x_3) + (ur_1) + sin(ur_4) = 0;
(w_output_5_1) - sin(w_output_5_2) + (w_output_5_3) + sin(x_4)*sin(x_2) + sin(x_4) + sin(ur_4) + cos(ur_3) = 0;
4*(w_output_5_1) - (w_output_5_2) + (w_output_5_3) + cos(x_1)*(x_1)*sin(x_1) + 4*(ur_4) + sin(ur_4) = 0;

cos(w_output_6_1)*(w_output_6_2) + 4*(w_output_6_3) + cos(x_1)*(x_2)*cos(x_2) + 4*(ur_4) - sin(ur_3) = 0;
(w_output_6_1)*sin(w_output_6_2) + (w_output_6_3) + sin(x_4) - (x_4)*(x_4) + cos(ur_2) + (ur_4) = 0;
4*(w_output_6_1) - 4*(w_output_6_2)*sin(w_output_6_3) + sin(x_5) + sin(x_4)*(x_2) + (ur_3) - (ur_1) = 0;

(w_other_1_1) + cos(w_other_1_2) - (w_other_1_3) + cos(x_2) - 4*(x_5) - 4*(x_2) + (ur_3) + 4*(ur_1) = 0;
(w_other_1_1) + 4*(w_other_1_2) + 4*(w_other_1_3) + 4*(x_1) - cos(x_3)*4*(x_2) + sin(ur_2) + 4*(ur_3) = 0;
cos(w_other_1_1)*(w_other_1_2) - sin(w_other_1_3) + sin(x_4) + cos(x_1)*sin(x_2) + (ur_3) - 4*(ur_3) = 0;

sin(w_other_2_1) - (w_other_2_2) + (w_other_2_3) + 4*(x_5) - 4*(x_4) - sin(x_5) + 4*(ur_4) - 4*(ur_4) = 0;
sin(w_other_2_1)*4*(w_other_2_2) + 4*(w_other_2_3) + sin(x_1) - cos(x_1) + cos(x_4) + sin(ur_2)*cos(ur_2) = 0;
sin(w_other_2_1) + sin(w_other_2_2) - (w_other_2_3) + 4*(x_1)*4*(x_4) - (x_4) + cos(ur_2) - sin(ur_2) = 0;

4*(w_other_3_1) + sin(w_other_3_2)*4*(w_other_3_3) + (x_2) + cos(x_2) - (x_5) + 4*(ur_1) - 4*(ur_1) = 0;
4*(w_other_3_1)*(w_other_3_2) + (w_other_3_3) + cos(x_3) + sin(x_2) + 4*(x_1) + (ur_2) - cos(ur_2) = 0;
cos(w_other_3_1)*4*(w_other_3_2) + (w_other_3_3) + 4*(x_4) - sin(x_4) + (x_3) + 4*(ur_3) - cos(ur_4) = 0;

end OutputTest;


model OutputTest2
    Real x1,x2;
    output Real y1, y2, y3;
    input Real u1;
equation
    der(x1) = -1;
    der(x2) = -2;
    
    y2 = x2;
    y3 = u1+x1;
    y1 = x1*x2 - u1;
end OutputTest2;
