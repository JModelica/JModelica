package FunctionTests "Some tests for functions" 
  
import SI = Modelica.SIunits;
  
constant SI.Temperature TSTAR1=1386.0 
  "normalization temperature for region 1 IF97";
constant SI.Pressure PSTAR1=16.53e6 
  "normalization pressure for region 1 IF97";
constant SI.Temperature TSTAR2=540.0 
  "normalization temperature for region 2 IF97";
constant SI.Pressure PSTAR2=1.0e6 "normalization pressure for region 2 IF97";

function g1pitau "derivative of g wrt pi and tau" 
  extends Modelica.Icons.Function;
  input SI.Pressure p "pressure";
  input SI.Temperature T "temperature (K)";
  output Real pi "dimensionless pressure";
  output Real tau "dimensionless temperature";
  output Real gpi "dimensionless dervative of Gibbs function wrt pi";
  output Real gtau "dimensionless dervative of Gibbs function wrt tau";
  protected 
  Real pi1 "dimensionless pressure";
  Real tau1 "dimensionless temperature";
  Real o1;
  Real o2;
  Real o3;
  Real o4;
  Real o5;
  Real o6;
  Real o7;
  Real o8;
  Real o9;
  Real o10;
  Real o11;
  Real o12;
  Real o13;
  Real o14;
  Real o15;
  Real o16;
  Real o17;
  Real o18;
  Real o19;
  Real o20;
  Real o21;
  Real o22;
  Real o23;
  Real o24;
  Real o25;
  Real o26;
  Real o27;
  Real o28;
algorithm 
  pi := p/PSTAR1;
  tau := TSTAR1/T;
  pi1 := 7.1 - pi;
  tau1 := -1.222 + tau;
  o1 := tau1*tau1;
  o2 := o1*tau1;
  o3 := 1/o2;
  o4 := o1*o1;
  o5 := o4*o4;
  o6 := o1*o5;
  o7 := o1*o4;
  o8 := 1/o4;
  o9 := o1*o4*o5;
  o10 := o4*tau1;
  o11 := 1/o10;
  o12 := o4*o5;
  o13 := o5*tau1;
  o14 := 1/o13;
  o15 := pi1*pi1;
  o16 := o15*pi1;
  o17 := o15*o15;
  o18 := o17*o17;
  o19 := o17*o18*pi1;
  o20 := o15*o17;
  o21 := o5*o5;
  o22 := o21*o21;
  o23 := o22*o5*tau1;
  o24 := 1/o23;
  o25 := o22*o5;
  o26 := 1/o25;
  o27 := o1*o22*o4*tau1;
  o28 := 1/o27;
  gtau := pi1*((-0.00254871721114236 + o1*(0.00424944110961118 + (
    0.018990068218419 + (-0.021841717175414 - 0.00015851507390979*o1)*o1)
    *o7))/o6 + pi1*(o8*(0.00141552963219801 + o4*(
    0.000047661393906987 + o1*(-0.0000132425535992538 -
    1.2358149370591e-14*o9))) + pi1*(o11*(0.000126718579380216 -
    5.11230768720618e-9*o6) + pi1*((0.000011212640954 + (
    1.30342445791202e-6 - 1.4341729937924e-12*o12)*o2)/o7 + pi1*(
    3.24135974880936e-6*o14 + o16*((1.40077319158051e-8 +
    1.04549227383804e-9*o10)/o12 + o19*(1.9941018075704e-17/(o1*
    o21*o4*o5) + o15*(-4.48827542684151e-19/o22 + o20*(-1.00075970318621e-21
    *o28 + pi1*(4.65957282962769e-22*o26 + pi1*(-7.2912378325616e-23*
    o24 + (3.83502057899078e-24*pi1)/(o1*o22*o5)))))))))))) + o3
    *(-0.29265942426334 + tau1*(0.84548187169114 + o1*(3.3855169168385
     + tau1*(-1.91583926775744 + tau1*(0.47316115539684 + (-0.066465668798004
     + 0.0040607314991784*tau1)*tau1)))));
  gpi := pi1*(pi1*((0.000095038934535162 + o4*(8.4812393955936e-6 +
    2.55615384360309e-9*o7))*o8 + pi1*(o11*(8.9701127632e-6 + (
    2.60684891582404e-6 + 5.7366919751696e-13*o12)*o2) + pi1*(
    2.02584984300585e-6/o5 + o16*(o19*(o15*(o20*(-7.63737668221055e-22
    /(o1*o22*o4) + pi1*(3.5842867920213e-22*o28 + pi1*(-5.65070932023524e-23
    *o26 + 2.99318679335866e-24*o24*pi1))) - 3.33001080055983e-19/(
    o1*o21*o4*o5*tau1)) + 1.44400475720615e-17/(o21*o4*o5*
    tau1)) + (1.01874413933128e-8 + 1.39398969845072e-9*o10)/(o1*o5
    *tau1))))) + o3*(0.00094368642146534 + o2*(0.00060003561586052 +
    (-0.000095322787813974 + o1*(8.8283690661692e-6 +
    1.45389992595188e-15*o9))*tau1))) + o14*(-0.00028319080123804 + 
    o1*(0.00060706301565874 + o7*(0.018990068218419 + tau1*(
    0.032529748770505 + (0.021841717175414 + 0.00005283835796993*o1)*
    tau1))));
end g1pitau;
  
function g1pitau_v "derivative of g wrt pi and tau, using array" 
  extends Modelica.Icons.Function;
  input SI.Pressure p "pressure";
  input SI.Temperature T "temperature (K)";
  output Real pi "dimensionless pressure";
  output Real tau "dimensionless temperature";
  output Real gpi "dimensionless dervative of Gibbs function wrt pi";
  output Real gtau "dimensionless dervative of Gibbs function wrt tau";
  protected 
  Real pi1 "dimensionless pressure";
  Real tau1 "dimensionless temperature";
  Real[28] o "vector of auxiliary variables";
algorithm 
  pi := p/PSTAR1;
  tau := TSTAR1/T;
  pi1 := 7.1 - pi;
  tau1 := -1.222 + tau;
  o[1] := tau1*tau1;
  o[2] := o[1]*tau1;
  o[3] := 1/o[2];
  o[4] := o[1]*o[1];
  o[5] := o[4]*o[4];
  o[6] := o[1]*o[5];
  o[7] := o[1]*o[4];
  o[8] := 1/o[4];
  o[9] := o[1]*o[4]*o[5];
  o[10] := o[4]*tau1;
  o[11] := 1/o[10];
  o[12] := o[4]*o[5];
  o[13] := o[5]*tau1;
  o[14] := 1/o[13];
  o[15] := pi1*pi1;
  o[16] := o[15]*pi1;
  o[17] := o[15]*o[15];
  o[18] := o[17]*o[17];
  o[19] := o[17]*o[18]*pi1;
  o[20] := o[15]*o[17];
  o[21] := o[5]*o[5];
  o[22] := o[21]*o[21];
  o[23] := o[22]*o[5]*tau1;
  o[24] := 1/o[23];
  o[25] := o[22]*o[5];
  o[26] := 1/o[25];
  o[27] := o[1]*o[22]*o[4]*tau1;
  o[28] := 1/o[27];
  gtau := pi1*((-0.00254871721114236 + o[1]*(0.00424944110961118 + (
    0.018990068218419 + (-0.021841717175414 - 0.00015851507390979*o[1])*o[
    1])*o[7]))/o[6] + pi1*(o[8]*(0.00141552963219801 + o[4]*(
    0.000047661393906987 + o[1]*(-0.0000132425535992538 -
    1.2358149370591e-14*o[9]))) + pi1*(o[11]*(0.000126718579380216 -
    5.11230768720618e-9*o[6]) + pi1*((0.000011212640954 + (
    1.30342445791202e-6 - 1.4341729937924e-12*o[12])*o[2])/o[7] + pi1*(
    3.24135974880936e-6*o[14] + o[16]*((1.40077319158051e-8 +
    1.04549227383804e-9*o[10])/o[12] + o[19]*(1.9941018075704e-17/(o[1]*o[
    21]*o[4]*o[5]) + o[15]*(-4.48827542684151e-19/o[22] + o[20]*(-1.00075970318621e-21
    *o[28] + pi1*(4.65957282962769e-22*o[26] + pi1*(-7.2912378325616e-23*
    o[24] + (3.83502057899078e-24*pi1)/(o[1]*o[22]*o[5])))))))))))) + o[3]
    *(-0.29265942426334 + tau1*(0.84548187169114 + o[1]*(3.3855169168385
     + tau1*(-1.91583926775744 + tau1*(0.47316115539684 + (-0.066465668798004
     + 0.0040607314991784*tau1)*tau1)))));
  gpi := pi1*(pi1*((0.000095038934535162 + o[4]*(8.4812393955936e-6 +
    2.55615384360309e-9*o[7]))*o[8] + pi1*(o[11]*(8.9701127632e-6 + (
    2.60684891582404e-6 + 5.7366919751696e-13*o[12])*o[2]) + pi1*(
    2.02584984300585e-6/o[5] + o[16]*(o[19]*(o[15]*(o[20]*(-7.63737668221055e-22
    /(o[1]*o[22]*o[4]) + pi1*(3.5842867920213e-22*o[28] + pi1*(-5.65070932023524e-23
    *o[26] + 2.99318679335866e-24*o[24]*pi1))) - 3.33001080055983e-19/(o[
    1]*o[21]*o[4]*o[5]*tau1)) + 1.44400475720615e-17/(o[21]*o[4]*o[5]*
    tau1)) + (1.01874413933128e-8 + 1.39398969845072e-9*o[10])/(o[1]*o[5]
    *tau1))))) + o[3]*(0.00094368642146534 + o[2]*(0.00060003561586052 +
    (-0.000095322787813974 + o[1]*(8.8283690661692e-6 +
    1.45389992595188e-15*o[9]))*tau1))) + o[14]*(-0.00028319080123804 + o[
    1]*(0.00060706301565874 + o[7]*(0.018990068218419 + tau1*(
    0.032529748770505 + (0.021841717175414 + 0.00005283835796993*o[1])*
    tau1))));
end g1pitau_v;
  
model FunctionTest1 
    
  Real temp(start = 300) = 300 + 25 * time;
  Real pres(start = 10e5) = 10e5 + 50e5 * time;
  Real pi;
  Real tau;
  Real gpi;
  Real gtau;
equation
  (pi,tau,gpi,gtau) = g1pitau(pres,temp);
end FunctionTest1;
  
model FunctionTest2 
    
  Real temp(start = 300) = 300 + 25 * time;
  Real pres(start = 10e5) = 10e5 + 50e5 * time;
  Real pi;
  Real tau;
  Real gpi;
  Real gtau;
equation
  (pi,tau,gpi,gtau) = g1pitau_v(pres,temp);
end FunctionTest2;

model IntegerArg1
    function f
        input Integer i;
        input Real a[:];
        output Real x;
    algorithm
        x := a[i];
    end f;
    
    Real x = f(2, {3, 4, 5 + time});
end IntegerArg1;

model FuncTest1
  function F
    input Real x[2];
    output Real y;
  algorithm
    y := x[1]+x[2];
  end F;
  Real x(start=0);
equation
  x = F({time,time*2});
end FuncTest1;

model TestZeroDimArray
  function f
    input Real[:] x;
    input Real y;
    output Real z;
    algorithm
        z := y + sum(x);
  end f;

  parameter Integer n = 0;
  Real x[n] = (1:n) * time;
  Real y = f(x, time);
end TestZeroDimArray;

model TestAssertSize
    function f
        input Integer n;
        input Real[2,2] d;
        input Real t;
        output Real[2,n] c;
    algorithm
        c := d;
    end f;

    Real[2,3] x = f(3,{{1,2},{3,time}}, time);
end TestAssertSize;

model TestUnkRecArray
    record R1
        R2[2] x;
    end R1;
    record R2
        Real[1] y;
    end R2;
    function f
        input Integer m;
        output R1[m,m] o;
    algorithm
        for i in 1:m loop
            o[i,:] := {R1({R2({i*j}),R2({-i*j})}) for j in 1:m};
        end for;
    end f;
    
    R1[3,3] c = f(3);
end TestUnkRecArray;

model LoadResource1
    parameter String s1 = Modelica.Utilities.Files.loadResource("C:\\a\\b\\file.txt") annotation(Evaluate=true);
    parameter String s2 = Modelica.Utilities.Files.loadResource("a\\b\\file.txt") annotation(Evaluate=true);
    parameter String s3 = Modelica.Utilities.Files.loadResource("/C:/a/b/file.txt") annotation(Evaluate=true);
    parameter String s4 = Modelica.Utilities.Files.loadResource("a/b/file.txt") annotation(Evaluate=true);
    parameter String s5 = Modelica.Utilities.Files.loadResource("modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt") annotation(Evaluate=true);
    parameter String s6 = Modelica.Utilities.Files.loadResource("file:///C:/a/b/file.txt") annotation(Evaluate=true);
  equation
    assert(time < 2, s1);
    assert(time < 2, s2);
    assert(time < 2, s3);
    assert(time < 2, s4);
    assert(time < 2, s5);
    assert(time < 2, s6);
end LoadResource1;

model StringArray1
    function fstrlen
        input String s;
        output Integer n;
    external "C" n = fStrlen(s) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
    end fstrlen;
    
    function stringify
        input Real[:] x;
        output String[size(x,1)] y;
      algorithm
        for i in 1:size(x,1) loop
            y[i] := String(x[i]);
        end for;
    end stringify;
    
    function stringcat
        input String[:] x;
        output String y;
      algorithm
        y := "";
        for i in 1:size(x,1) loop
            y := y + x[i];
        end for;
    end stringcat;
    
    function f
        input Real[:] x;
        output Integer n;
      protected
        String[:] sx = stringify(x);
        String tx = stringcat(sx);
      algorithm
        Modelica.Utilities.Streams.print(tx);
        n := fstrlen(tx);
    end f;
    
    Integer n;
    discrete Real t;
  equation
    when time > pre(t) + 0.2 then
        n = f({1,2,3,4} .+ time);
        t = pre(t) + 0.2;
    end when;
end StringArray1;

model FuncCallInputOutputArray1
    function F1
        input Integer n;
        input Real x;
        output Real[n] y;
    algorithm
        for i in 1:n loop
            y[i] := x * i;
        end for;
        y := F2(y);
    end F1;
    
    function F2
        input Real[:] x;
        output Real[size(x,1)] y;
    algorithm
        for i in 1:2 loop
            y[i] := x[1] + x[2];
        end for;
    end F2;

    parameter Real[2] p1 = F1(2,1) annotation(Evaluate=true);
    parameter Real[2] p2 = F1(2,1);
end FuncCallInputOutputArray1;

model GlobalConstant1
    record R
        Real[:] a;
    end R;
    
    function f
        input Real x;
        input Integer i;
        constant R[:] c = {R(1:2), R(3:4)};
        output Real y = c[i].a[i] + x;
        algorithm
    annotation(Inline=false);
    end f;
    
    Real y = f(time, 2);
end GlobalConstant1;

model LoopWithLargeStepSize
    function f1
        input Real X[9];
        output Real Y[7];
        Integer iStep;
    algorithm
        iStep:=integer(7);
        Y:=zeros(7);
        for i in 1:iStep loop
            for j in i:iStep:7 loop
                Y[i]:=Y[i]+X[j];
            end for;
        end for;
    annotation(Inline=false);
    end f1;
    
    parameter Real a[9]={0.0195, 0.44363, 0.0585754, 0.4130916, 0.00295055, 0.00103245, 0.06122, 100.0, 1000.0};
    Real b[7]=f1(a);
end LoopWithLargeStepSize;

model LoopWithSubtractionInBounds
    function f1
        input Integer a;
        output Integer b;
    algorithm
        b:=0;
        for i in a-1:a-2:5 loop
            b:=b+i;
        end for;
    annotation(Inline=false);
    end f1;
    
    Integer b=f1(3);
end LoopWithSubtractionInBounds;

  annotation (uses(Modelica(version="3.1")));
end FunctionTests;
