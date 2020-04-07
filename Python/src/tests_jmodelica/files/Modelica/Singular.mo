package Singular "Some tests for singular systems" 

    model Linear1
        Real x,y,z,v;
        parameter Real a11 = 1;
        parameter Real a12 = 0;
        parameter Real a13 = 0;
        parameter Real a21 = 0;
        parameter Real a22 = 1;
        parameter Real a23 = 0;
        parameter Real a31 = 0;
        parameter Real a32 = 0;
        parameter Real a33 = 1;
        parameter Real b[3] = {1,2,3};
    equation
        a11*x+a12*y+a13*z = b[1];
        a21*x+a22*y+a23*z = b[2];
        a31*x+a32*y+a33*z = b[3];
        der(v) = time;
    end Linear1;
    
    model Linear2
        extends Linear1(z(start=5));
    end Linear2;
    
    model Linear3
        extends Linear1(y(start=5));
    end Linear3;

    model NonLinear1 "Actually Linear"
        parameter Real a11 = 1;
        parameter Real a12 = 0;
        parameter Real a13 = 0;
        parameter Real a21 = 0;
        parameter Real a22 = 1;
        parameter Real a23 = 0;
        parameter Real a31 = 0;
        parameter Real a32 = 0;
        parameter Real a33 = 1;
        Real A[3,3];
        
        function MatrixMul
            input Real x,y,z;
            input Real A[:,:];
            output Real b[3];
            
        algorithm
            b[1] := A[1,1]*x+A[1,2]*y+A[1,3]*z;
            b[2] := A[2,1]*x+A[2,2]*y+A[2,3]*z;
            b[3] := A[3,1]*x+A[3,2]*y+A[3,3]*z;
            
            annotation (Inline=false);
        end MatrixMul;
        Real x,y,z,v;
        parameter Real b[3] = {1,2,3};
    equation
        A[1,1] = a11;
        A[1,2] = a12;
        A[1,3] = a13;
        A[2,1] = a21;
        A[2,2] = a22;
        A[2,3] = a23;
        A[3,1] = a31;
        A[3,2] = a32;
        A[3,3] = a33;
        b = MatrixMul(x,y,z,A);
        der(v) = time;
    end NonLinear1;
    
    model NonLinear2
        extends NonLinear1(z(start=5));
    end NonLinear2;
    
    model NonLinear3
        extends NonLinear1(y(start=5));
    end NonLinear3;
    
    model LinearInf
        extends Linear1;
    end LinearInf;
    
    model LinearEvent1
        Real x,y,z,v;
        parameter Real a11 = 1;
        parameter Real a12 = 0;
        parameter Real a13 = 0;
        parameter Real a21 = 0;
        parameter Real a22 = 0;
        parameter Real a23 = 0;
        parameter Real a31 = 1;
        parameter Real a32 = 1;
        parameter Real a33 = 1;
        parameter Real b[3] = {0,0,3};
    equation
        if y <= 1 then
        a11*x+a12*y+a13*z = b[1];
        a21*x+a22*y+a23*z = b[2];
        a31*x+a32*y+a33*z = b[3]*time;
        else
        a11*x+a12*y+a13*z = b[1];
        0*x+1*y+0*z = 1;
        a31*x+a32*y+a33*z = b[3]*time;
        end if;
        der(v) = time;
    end LinearEvent1;
    
    model LinearEvent2
        Real x,y,z,w,q,v;
        parameter Real a11 = 1;
        parameter Real a12 = 0;
        parameter Real a13 = 0;
        parameter Real a14 = 0;
        parameter Real a15 = 0;
        parameter Real a21 = 0;
        parameter Real a22 = 1;
        parameter Real a23 = 1;
        parameter Real a24 = 0;
        parameter Real a25 = 0;
        parameter Real a31 = 0;
        parameter Real a32 = 0;
        parameter Real a33 = 0;
        parameter Real a34 = 1;
        parameter Real a35 = 1;
        parameter Real a41 = 0;
        parameter Real a42 = 0;
        parameter Real a43 = 0;
        parameter Real a44 = 0;
        parameter Real a45 = 0;
        parameter Real a51 = 0;
        parameter Real a52 = 0;
        parameter Real a53 = 0;
        parameter Real a54 = 0;
        parameter Real a55 = 0;
        parameter Real b[5] = {0,2,3,0,0};
    equation
        if y <= 1 and time < 3 then
            a11*x+a12*y+a13*z+a14*w+a15*q = b[1];
            a21*x+a22*y+a23*z+a24*w+a25*q = b[2]*time;
            a31*x+a32*y+a33*z+a34*w+a35*q = b[3]*time;
            a41*x+a42*y+a43*z+a44*w+a45*q = b[4];
            a51*x+a52*y+a53*z+a54*w+a55*q = b[5];
        elseif w <= 2 then
            a11*x+a12*y+a13*z+a14*w+a15*q = b[1];
            a21*x+a22*y+a23*z+a24*w+a25*q = b[2]*time;
            a31*x+a32*y+a33*z+a34*w+a35*q = b[3]*time;
            0*x+1*y+0*z+0*w+0*q = 1;
            a51*x+a52*y+a53*z+a54*w+a55*q = b[5];
        else
            a11*x+a12*y+a13*z+a14*w+a15*q = b[1];
            a21*x+a22*y+a23*z+a24*w+a25*q = b[2]*time;
            a31*x+a32*y+a33*z+a34*w+a35*q = b[3]*time;
            a41*x+a42*y+a43*z+a44*w+a45*q = b[4];
            0*x+0*y+0*z+1*w+0*q = 2;
        end if;
        der(v) = time;
    end LinearEvent2;
    
    model LinearEvent3
		Real x(start=0), y1, y2;
		parameter Real p1=1, p2=0, p3=2;
	equation
	  y1 = noEvent(if - time >= 0.5 then (- p3) * p1 else (- p3) * x);
	  y2 = - p2 - y1;
	  y2 = noEvent(if time >= 0.5 then p3 * 0.01 else p3 * x);
	end LinearEvent3;
    
    model NonLinear4 "Actually Linear"
        parameter Real a11 = 1;
        parameter Real a12 = 0;
        parameter Real a13 = 0;
        parameter Real a21 = 0;
        parameter Real a22 = 1;
        parameter Real a23 = 0;
        parameter Real a31 = 0;
        parameter Real a32 = 0;
        parameter Real a33 = 1;
        Real A[3,3];
        
        function MatrixMul
            input Real x,y,z;
            input Real A[:,:];
            output Real b[3];
            
        algorithm
            b[1] := A[1,1]*x+A[1,2]*y+A[1,3]*z;
            b[2] := A[2,1]*x+A[2,2]*y+A[2,3]*z;
            b[3] := A[3,1]*x+A[3,2]*y+A[3,3]*z;
            
            annotation (Inline=false);
        end MatrixMul;
        Real x,y,z,v;
        parameter Real b[3] = {1,2,3};
    equation
        A[1,1] = a11;
        A[1,2] = a12;
        A[1,3] = a13;
        A[2,1] = a21;
        A[2,2] = a22;
        A[2,3] = a23;
        A[3,1] = a31;
        A[3,2] = if time <= 0.5 then a32 else 0;
        A[3,3] = if time > 0.5 then a33 else 0;
        b = MatrixMul(x,y,z,A);
        der(v) = time;
    end NonLinear4;
    
    model NonLinear5
        Real x(start=5);
        Real y(start=10);
        Real z;
    equation
        z = if time > 0.5 then x*(y+1) else 0;
        (sin(z)+y) = 0;
        (sin(x*y*z)+z) = 0;
    end NonLinear5;
	
	model NoMinimumNormSolution
        Real x,y,z,v;
        parameter Real a11 = 1;
        parameter Real a12 = 2;
        parameter Real a13 = 3;
        parameter Real a21 = 1;
        parameter Real a22 = 1;
        parameter Real a23 = 1;
        Real a31(start=0);
        Real a32(start=0);
        Real a33(start=0);
        parameter Real b[3] = {1,2,3};
    equation
		a33=a31+a32;
		a33=a31^2+a32^2;
		a33=a31-a32;
        a11*x+a12*y+a13*z = b[1];
        a21*x+a22*y+a23*z = b[2];
        a31*x+a32*y+a33*z = b[3];
        der(v) = time;
    end NoMinimumNormSolution;
    
    model ZeroColumnJacobian
        Real x(start=0, nominal=1e-1);
        Real y;
        Real z;
        Real w(start=1);

    function f
        input Real a;
        input Real b;
        output Real c;
        Real d;
    algorithm
        d := b;
        c:= a+d;
    end f;    
    equation
        z=1e-8*x;
        w^2=y;
        0=2*y-f(z,w)-1;
        z-2*y+3-f(x^2,-z)=0;
    end ZeroColumnJacobian;

    model ZeroColumnJacobian2
        extends ZeroColumnJacobian(x(nominal=1e-2));
    end ZeroColumnJacobian2;
end Singular;
