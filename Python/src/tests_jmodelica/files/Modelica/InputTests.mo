package Inputs

    model DiscChange
        Real x(start=1.0);
        Real y(start=2.0);
        input Real u;
    equation
        der(x) = -y*x^2*exp(u) + cos(y) + u^0.5;
        der(y) = -y^3*u + sin(x*y*u^2);
    end DiscChange;

    model SimpleInput
        Real x(start = 0);
        Real y(start = 0);
        input Real u;
    equation
        der(x) = sin(time);
        y = u;
    end SimpleInput;
    
    model SimpleInput2
        Real x(start = 0);
        Real y(start = 0);
        Real z(start = 0);
        input Real u1;
        input Real u2;
    equation
        der(x) = sin(time);
        y = u1;
        z = u2;
    end SimpleInput2;
    
    model SimpleInput3
        Real x(start = 0);
        Real y(start = 0);
        input Real u;
        parameter Real p = 20;
    equation
        der(x) = sin(time);
        y = p*u;
    end SimpleInput3;
    
    model InputDiscontinuity
        Real x(start = 0);
        input Real u;
    equation
        x = if u > 0.5 then 1 else 0;
    end InputDiscontinuity;
    
    model PlantDiscreteInputs
        output Real T(start=10.0);
        input Real Tenv(start=0.0);
        parameter Real V = 9.0;
        parameter Real R = 1.0;
        parameter Real k = 0.05;
        input Boolean onSwitch;
    equation
        if onSwitch then
            der(T) = (Tenv - T) + V^2 / (R + k*T);
        else
            der(T) = (Tenv - T);
        end if;
    end PlantDiscreteInputs;

end Inputs;
