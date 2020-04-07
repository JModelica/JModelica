/*
 * The models contained in this package are generated 
 * with PyMBS and were provided by Christian Schubert.
 */
package PyMBSModels

model CraneCrab_recursive_der_state_Test
        CraneCrab_recursive_der_state crane;
equation
        crane.F = 0;		
end CraneCrab_recursive_der_state_Test;

model CraneCrab_recursive_der_state

// Imports from Modelica Standard Library
	import Modelica.Math.asin;
	import Modelica.Math.acos;
	import Modelica.Math.atan;
	import Modelica.Math.atan2;
	import Modelica.Constants.pi;

// State
	// Positions
	Real[2] q (start={1, 0}, each stateSelect=StateSelect.prefer) "q_TransCrab,q_RotLoad";
	// Velocities
	Real[2] qd (start={0, 0}, each stateSelect=StateSelect.prefer) "qd_TransCrab,qd_RotLoad";

// Inputs
	input Real F;

// Parameters
	parameter Real I2 = 0.0833333333333333	"inertia_2";
	parameter Real g = 9.81000000000000	"gravity";
	parameter Real l2 = 1	"length";
	parameter Real m2 = 1	"mass_2";
	parameter Real m1 = 10	"mass_1";

// Sensors
	Real[2] d;

	Real[3, 3] T_Katze;
	Real[3, 3] T_Traeger;
	Real[3] r_Traeger;
	Real[3] r_Last;
	Real[3, 3] T_Last;
	Real[3] r_Katze;

// Variables
protected
	Real[3] int_PSI_loc_Crab;
	Real[3] int_PHI_loc_Load;
	Real[3] int_alpha_C_world;
	Real[3, 3] int_O_M_tilde_Load_Load;
	Real[3] int_l_loc_Load;
	Real[3, 3] int_I_loc_Load;
	Real[3] int_G_M_Load_Crab;
	Real[3] int_G_M_Crab_Crab;
	Real[3] int_p_z_world_Crab;
	Real[3] int_I_v_Crab;
	Real[3, 3] int_T_RotLoad;
	Real[3] int_omega_Load;
	Real[3] int_G_C_Crab;
	Real[3] int_F_M_Crab_Crab;
	Real[3, 3] int_omega_tilde_Load;
	Real[3] int_l_Load;
	Real l_Position;
	Real[3] int_WF_DrivingForce;
	Real[3, 3] int_I_Load;
	Real int_M_0_0;
	Real[3] int_omegad_C_Load;
	Real[3, 3] int_l_tilde_Load;
	Real[3] int_F_DrivingForce;
	Real[3] int_G_M_Load_Load;
	Real[3, 3] int_omegad_C_tilde_Load;
	Real[3] int_L_M_Load_Load;
	Real[3] int_L_M_Load_Crab;
	Real[3, 3] int_beta_C_Load;
	Real int_M_1_1;
	Real int_M_1_0;
	Real[3] int_G_C_Load;
	Real[2, 2] M;
	Real[3] int_L_C_Load;
	Real[3] int_F_C_Crab;
	Real int_C_1;
	Real int_C_0;
	Real[2] C;
	Real[2] der_qd;

equation
	int_PSI_loc_Crab = {1,
                        0,
                        0};

	int_PHI_loc_Load = {0,
                        1,
                        0};

	T_Katze = {{1,0,0},
               {0,1,0},
               {0,0,1}};

	T_Traeger = {{1,0,0},
                 {0,1,0},
                 {0,0,1}};

	r_Traeger = {0,
                 0,
                 0};

	int_alpha_C_world = {0,
                         0,
                         g};

	int_O_M_tilde_Load_Load = {{0,-int_PHI_loc_Load[3],int_PHI_loc_Load[2]},
                               {int_PHI_loc_Load[3],0,-int_PHI_loc_Load[1]},
                               {-int_PHI_loc_Load[2],int_PHI_loc_Load[1],0}};

	int_l_loc_Load = {-l2,
                      0,
                      0};

	int_I_loc_Load = {{0,0,0},
                      {0,I2,0},
                      {0,0,0}};

	int_G_M_Load_Crab = m2*int_PSI_loc_Crab;

	int_G_M_Crab_Crab = m1*int_PSI_loc_Crab;

	der(q) = qd;

	int_p_z_world_Crab = q[1]*int_PSI_loc_Crab;

	int_I_v_Crab = qd[1]*int_PSI_loc_Crab;

	int_T_RotLoad = {{cos(q[2]),0,sin(q[2])},
                     {0,1,0},
                     {-sin(q[2]),0,cos(q[2])}};

	int_omega_Load = qd[2]*int_PHI_loc_Load;

	int_G_C_Crab = m1*int_alpha_C_world;

	int_F_M_Crab_Crab = int_G_M_Crab_Crab+int_G_M_Load_Crab;

	int_omega_tilde_Load = {{0,-int_omega_Load[3],int_omega_Load[2]},
                            {int_omega_Load[3],0,-int_omega_Load[1]},
                            {-int_omega_Load[2],int_omega_Load[1],0}};

	int_l_Load = int_T_RotLoad*int_l_loc_Load;

	r_Last = int_p_z_world_Crab;

	T_Last = int_T_RotLoad;

	l_Position = (int_p_z_world_Crab*int_p_z_world_Crab)^0.5;

	r_Katze = int_p_z_world_Crab;

	int_WF_DrivingForce = int_p_z_world_Crab*(int_p_z_world_Crab*int_p_z_world_Crab)^(-0.5);

	int_I_Load = int_T_RotLoad*int_I_loc_Load*transpose(int_T_RotLoad);

	int_M_0_0 = int_PSI_loc_Crab*int_F_M_Crab_Crab;

	int_omegad_C_Load = qd[2]*int_omega_tilde_Load*int_PHI_loc_Load;

	int_l_tilde_Load = {{0,-int_l_Load[3],int_l_Load[2]},
                        {int_l_Load[3],0,-int_l_Load[1]},
                        {-int_l_Load[2],int_l_Load[1],0}};

	d = {l_Position,
         int_p_z_world_Crab*int_I_v_Crab/l_Position};

	int_F_DrivingForce = F*int_WF_DrivingForce;

	int_G_M_Load_Load = m2*int_O_M_tilde_Load_Load*int_l_Load;

	int_omegad_C_tilde_Load = {{0,-int_omegad_C_Load[3],int_omegad_C_Load[2]},
                               {int_omegad_C_Load[3],0,-int_omegad_C_Load[1]},
                               {-int_omegad_C_Load[2],int_omegad_C_Load[1],0}};

	int_L_M_Load_Load = int_I_Load*int_PHI_loc_Load+int_l_tilde_Load*int_G_M_Load_Load;

	int_L_M_Load_Crab = int_l_tilde_Load*int_G_M_Load_Crab;

	int_beta_C_Load = int_omegad_C_tilde_Load+int_omega_tilde_Load^2;

	int_M_1_1 = int_PHI_loc_Load*int_L_M_Load_Load;

	int_M_1_0 = int_PHI_loc_Load*int_L_M_Load_Crab;

	int_G_C_Load = m2*(int_alpha_C_world+int_beta_C_Load*int_l_Load);

	M = {{int_M_0_0,int_M_1_0},
         {int_M_1_0,int_M_1_1}};

	int_L_C_Load = int_I_Load*int_omegad_C_Load+int_l_tilde_Load*int_G_C_Load+int_omega_tilde_Load*int_I_Load*int_omega_Load;

	int_F_C_Crab = int_G_C_Crab+int_G_C_Load-int_F_DrivingForce;

	int_C_1 = int_PHI_loc_Load*int_L_C_Load;

	int_C_0 = int_PSI_loc_Crab*int_F_C_Crab;

	C = {int_C_0,
         int_C_1};

	M*der(qd) = -C;

	der_qd = der(qd);

end CraneCrab_recursive_der_state;

model CraneCrab_explicit_der_state_Test
        CraneCrab_explicit_der_state crane;
equation
        crane.F = 0;		
end CraneCrab_explicit_der_state_Test;

model CraneCrab_explicit_der_state

// Imports from Modelica Standard Library
	import Modelica.Math.asin;
	import Modelica.Math.acos;
	import Modelica.Math.atan;
	import Modelica.Math.atan2;
	import Modelica.Constants.pi;

// State
	// Positions
	Real[2] q (start={1, 0}, stateSelect=StateSelect.prefer) "q_TransCrab,q_RotLoad";
	// Velocities
	Real[2] qd (start={0, 0}, stateSelect=StateSelect.prefer) "qd_TransCrab,qd_RotLoad";

// Inputs
	input Real F;

// Parameters
	parameter Real I2 = 0.0833333333333333	"inertia_2";
	parameter Real g = 9.81000000000000	"gravity";
	parameter Real l2 = 1	"length";
	parameter Real m2 = 1	"mass_2";
	parameter Real m1 = 10	"mass_1";

// Sensors
	Real[2] d;

	Real[3, 3] T_Katze;
	Real[3, 3] T_Traeger;
	Real[3] r_Traeger;
	Real[3] r_Last;
	Real[3, 3] T_Last;
	Real[3] r_Katze;

// Variables
protected
	Real[2] WF_DrivingForce;
	Real[2, 2] M;
	Real[2] h;
	Real[2] f_gravity;
	Real[2] f_ext;
	Real[2] f;
	Real[2] der_qd;

equation
	T_Katze = {{1,0,0},
               {0,1,0},
               {0,0,1}};

	T_Traeger = {{1,0,0},
                 {0,1,0},
                 {0,0,1}};

	r_Traeger = {0,
                 0,
                 0};

	der(q) = qd;

	r_Last = {q[1],
              0,
              0};

	T_Last = {{cos(q[2]),0,sin(q[2])},
              {0,1,0},
              {-sin(q[2]),0,cos(q[2])}};

	d = {abs(q[1]),
         q[1]*qd[1]/abs(q[1])};

	r_Katze = {q[1],
               0,
               0};

	WF_DrivingForce = {q[1]/abs(q[1]),
                       0};

	M = {{m1+m2,l2*m2*sin(q[2])},
         {l2*m2*sin(q[2]),I2+m2*l2^2}};

	h = {l2*m2*qd[2]^2*cos(q[2]),
         0};

	f_gravity = {0,
                 -g*l2*m2*cos(q[2])};

	f_ext = F*WF_DrivingForce;

	f = f_ext+f_gravity;

	M*der(qd) = f - h;

	der_qd = der(qd);

end CraneCrab_explicit_der_state;

end PyMBSModels;