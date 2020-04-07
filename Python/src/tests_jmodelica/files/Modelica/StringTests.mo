package StringTests 

model TestStringParameterEval1
    constant String ci = "string1";
    constant String cd = ci;
    parameter String ps = "string2";
    parameter String pe = ps annotation(Evaluate=true);
    final parameter String pf = "string3";
    parameter String pi = "string4";
    parameter String pd = pi;
end TestStringParameterEval1;

model TestStringParameterScalar1
    parameter String pi = "string";
    parameter String pd = pi + "1";
end TestStringParameterScalar1;

model TestStringParameterArray1
    parameter String[:] pi = {"str1", "str2"};
    parameter String[:] pd = pi + pi;
end TestStringParameterArray1;

model TestString1
    parameter String s0 = "";
    parameter Real t(fixed=false);
    parameter String s1 = String(t);
    parameter String s2 = s1 + s1;
initial equation
    t = time + 0.5;
end TestString1;

model TestString2
    parameter String s0 = "";
    String s1;
    String s2;
equation
    s1 = String(time);
    s2 = s1 + s1;
end TestString2;

model TestStringInput1
    input String x;
    output String y = x + x;
end TestStringInput1;

model TestStringEvent1
    String s1;
    String s2;
equation
    s1 = String(time);
    if time > 1 then
        s2 = s1 + s1;
    else
        s2 = s1 + "msg";
    end if;
end TestStringEvent1;

model TestStringBlockEvent1
    String s1,s2,s3;
equation
    s1 = String(time);
    if time > 1 then
        s2 = s1 + s1;
    else
        s2 = s1 + "msg";
    end if;
    if not pre(s2) == s2 then
        s3 = pre(s1) + s2;
    else
        s3 = pre(s3);
    end if;
end TestStringBlockEvent1;

model TestStringBlockEvent2
    String s1;
    String s2(start="s2");
equation
    s1 = String(time);
    when {time > 1, time >= 1} then
        s2 = pre(s2) + ":" + pre(s1);
    end when;
end TestStringBlockEvent2;

model TestStringBlockEvent3
    function f
        input Real x;
        input String s1;
        output Real y = x;
        output String s2 = String(x) + s1;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real x;
    String s;
equation
    when time > 1 then
        (x,s) = f(pre(x),pre(s));
    end when;
end TestStringBlockEvent3;

model TestStringBlockEvent4
    String s1,s2;
    Real x,y;
equation
    y = x/2;
    when time > 1 then
        s2 = String(time);
    end when;
algorithm
    x := time + y;
    when time > 1 then
        s1 := s2 + s2;
    end when;
end TestStringBlockEvent4;

end StringTests;
