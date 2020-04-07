model DrumBoiler
		// parameters from ML
		parameter Real x10( nominal = 140.0) = 50.0; //initial state
		parameter Real x20( nominal = 140.0) = 50.0; //initial state
		
		parameter Real TD( nominal = 250.0, min = 0, max = 500) = 250.0; //drum time constant [s]
		parameter Real TR( nominal = 30.0, min = 0, max = 100) = 30.0; // Reheater time constant [s]
		parameter Real A4( nominal = 0.5, min = 0, max = 1.0) = 0.5; // Drum yield 
		parameter Real distE = 0.0; //Power disturbance
		parameter Real distP = 0.0; //Preassure disturbace
		
		//constants
		parameter Real K1 = 0.3;
		parameter Real A1 = 14;
		parameter Real A2 = 3.3;
		parameter Real K2 = 0.064;
		parameter Real A3 = 15;
		parameter Real K3 = 0.32;
		
		input Real uc; //control valve position
		input Real fc; // fuel flow [kg/s]
		
		Real x1(fixed = true,  start = x10); //initialGuess = 0,
		Real x2(fixed = true,start = x20); //initialGuess = 0
		
		Real E; // Power[M/W]
		Real P;  // Drum pressure[n/m²]
		
		equation
			der(x1) = K1*(A1*fc-A2*uc*x1)/TD;
			der(x2) = K2*(A2*uc*x1-A3*x2)/TR;
			E = K3*(A4*A2*uc*x1 + (1-A4)*A3*x2) + distE;
			P = x1 + distP;
			

end DrumBoiler;

