package BlockingInitPack

  model M
    Real x[2] (each start=1);
    Real y;
    input Real u;
   equation
    der(x) = {-x[1]+x[2],-x[2]+u};
    y=x[1]+x[2];
  end M;

  model M_init
    M m(x(each fixed=true));
    Real u = m.u;
    Real cost(start=0,fixed=true);
    equation
    m.u = sin(time);
    der(cost) = m.x[1]^2 + m.x[2]^2 + m.u^2;
  end M_init;

  optimization M_Opt (objective=cost(finalTime),startTime=0,finalTime=10)
    M m(x(each fixed=true));
    Real cost(start=0,fixed=true);
    input Real u = m.u;
    parameter Real p[9] = {1,2,3,4,5,6,7,8,9};
   equation
    der(cost) = m.x[1]^2 + m.x[2]^2 + m.u^2;
   constraint
    for i in 1:9 loop
      m.x[1](p[i]) <= 100;
    end for;
  end M_Opt;
 
end BlockingInitPack;