package LinearTest

    model Linear1
        parameter Real small = 1e-10;
        parameter Real A = 2496000;
        parameter Real B = 2560000*A_Qhat/small;
        parameter Real N = (7763.0 * 492 * (1.0 / 59.9));
        parameter Real A_Qhat = (2 * 0.000625)/(59.9 * 2 * 3.141592653589793 * (0.01 + 0.0025) * 1.0);
        parameter Real Ahat = (A+B)/N;
        
        Real x; //The ODE state
        
        initial equation
            der(x) = 0.0;

        equation
            //--- Solved equation ---
            der(x) = Ahat*x;
    end Linear1;
    
    model TwoTornSystems1
        Real x[3];
        parameter Real b1[3] = {2, 1, 4};
        Real y[3];
        parameter Real b2[3] = {2, 1, 4};
    equation
        b1[1] = 2 * x[1] + x[2];
        b1[2] = x[1] + 2 * x[3];
        b1[3] = 2 * x[2] + x[3];
        b2[1] = 2 * y[1] + y[2];
        b2[2] = y[1] + 2 * y[3];
        b2[3] = 2 * y[2] + y[3];
    end TwoTornSystems1;
    
    model Linear2
        Real x(start=1);
    equation
        der(x) = -1;
    end Linear2;

end package;
