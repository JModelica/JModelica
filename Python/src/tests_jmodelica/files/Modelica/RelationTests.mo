package RelationTests

    model Base
        Real x(start=0);
        Real y(start=0);
        input Real u;
        Real z(start=1);
    equation
        der(z)=-z+sin(time)+cos(10*time);
    end Base;

    model RelationLE
        extends Base;
    equation
        der(x)=if u>0.5 then 0 else 1;
        der(y)=if u>=0.5 then 0 else 1;
    end RelationLE;
    
    model RelationLEInv
        extends Base;
    equation
        der(x)=if 0.5<u then 0 else 1;
        der(y)=if 0.5<=u then 0 else 1;
    end RelationLEInv;
    
    model RelationGE
        extends Base;
    equation
        der(x)=if u<=0.5 then 1 else 0;
        der(y)=if u<0.5 then 1 else 0;
    end RelationGE;
    
    model RelationGEInv
        extends Base;
    equation
        der(x)=if 0.5>=u then 1 else 0;
        der(y)=if 0.5>u then 1 else 0;
    end RelationGEInv;
    
    model RelationLEInit
        extends Base;
    initial equation
        x=if u>0 then 0 else 1;
        y=if u>=0 then 0 else 1;
    equation
        der(x)=if 0.5>u then 1 else 0;
        der(y)=0;
    end RelationLEInit;
    
    model RelationGEInit
        extends Base;
    initial equation
        x=if u<0 then 1 else 0;
        y=if u<=0 then 1 else 0;
    equation
        der(x)=0;
        der(y)=0;
    end RelationGEInit;
    
    model TestRelationalOp1 
        Real v1(start=-1);
        Real v2(start=-1);
        Real v3(start=-1);
        Real v4(start=-1);
        Real y(start=1);
        Integer i(start=0);
        Boolean up(start=true);
        initial equation 
         v1 = if time>=0 and time<=3 then 0 else 0;
         v2 = if time>0 then 0 else 0;
         v3 = if time<=0 and time <= 2 then 0 else 0;
         v4 = if time<0 then 0 else 0;
        equation 
        when sample(0.1,1) then
          i = if up then pre(i) + 1 else pre(i) - 1;
          up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
          y = i;
        end when;
         der(v1) = if y<=0 then 0 else 1;
         der(v2) = if y<0 then 0 else 1;
         der(v3) = if y>=0 then 0 else 1;
         der(v4) = if y>0 then 0 else 1;
    end TestRelationalOp1;
    
    
end RelationTests;
