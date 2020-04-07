package NoState

    model Example1
      Real x(start=0);
      Real y(start=1);
      Real z(start=0);
      parameter Real m1=-1.0;
      parameter Real m15=-1.5;
      parameter Real m3=-3.0;
      parameter Real p05=0.5;
      parameter Real p1=1.0;
      parameter Real p3=3.0;
    equation
       x = if time>=p1 then (m1 + y) else  (- y);
       y = z + x +(if z>=m15 then m3 else p3);
       z = -y  - x + (if y>=p05 then m1 else p1);
    end Example1;
    
    model Example2
        Real x(start=0);
    equation
        x = if time>= 2.0 and time<=3.0 then 1.0 else -1.0;
    end Example2;
    
    model Example3
        Real x(start=0);
    equation
        x = time;
    end Example3;
    
end NoState;
