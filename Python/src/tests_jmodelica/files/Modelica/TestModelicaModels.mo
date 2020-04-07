/*
    Copyright (C) 2013 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

model AtomicModelElementaryDivision
    parameter Real p1[3] = {1,2,3};
    parameter Real p2[3] = {4,5,6};
    parameter Real p3[3] = p1./p2;
    parameter Real p4 = p1[1]/p2[1];
    parameter Real p5[3] = p1/p2[1];
end AtomicModelElementaryDivision;

model AtomicModelElementaryMultiplication
    parameter Real p1[3] = {1,2,3};
    parameter Real p2[3] = {4,5,6};
    parameter Real p3[3] = p1.*p2;
    parameter Real p4 = p1[1]*p2[1];
    parameter Real p5[3] = p1*p2[1];
end AtomicModelElementaryMultiplication;

model AtomicModelElementaryAddition
    parameter Real p1[3] = {1,2,3};
    parameter Real p2[3] = {4,5,6};
    parameter Real p3[3] = p1 + p2;
end AtomicModelElementaryAddition;

model AtomicModelElementarySubtraction
    parameter Real p1[3] = {1,2,3};
    parameter Real p2[3] = {4,5,6};
    parameter Real p3[3] = p1 - p2;
end AtomicModelElementarySubtraction;

model AtomicModelElementaryExponentiation
    parameter Real p1[3] = {1,2,3};
    parameter Real p2[3] = {4,5,6};
    parameter Real p3[3] = p1.^p2;
    parameter Real p4[3] = p1.^p2[2];
    parameter Real p5[3] = p1[1].^p2;
    parameter Real p6 = p1[1]^p2[1];
    parameter Real p7[2,2] = [1,2;3,4];
    parameter Real p8[2,2] = [5,6;7,8];
    parameter Real p9[2,2] = p7.^p8;
    parameter Real p10[2,2] = p7[1,1].^p8;
end AtomicModelElementaryExponentiation;

model AtomicModelElementaryExpressions
    Real x1;
    Real x2;
    Real x3;
    Real x4;
equation
    der(x1) = x1+2;
    der(x2) = x2-x1;
    der(x3) = x3*x2;
    der(x4) = x4/x3;
end AtomicModelElementaryExpressions;

model AtomicModelElementaryFunctions
    Real x1;
    Real x2;
    Real x3;
    Real x4;
    Real x5;
    Real x6;
    Real x7;
    Real x8;
    Real x9;
    Real x10;
    Real x11;
    Real x12;
    Real x13;
    Real x14;
    Real x15;
    Real x16;
    Real x17;
    Real x18;
    Real x19;
equation
    der(x1) = x1^5;
    der(x2) = abs(x2);
    der(x3) = min(x3,x2);
    der(x4) = max(x4,x3);
    der(x5) = sqrt(x5);
    der(x6) = sin(x6);
    der(x7) = cos(x7);
    der(x8) = tan(x8);
    der(x9) = asin(x9);
    der(x10) = acos(x10);
    der(x11) = atan(x11);
    der(x12) = atan2(x12, x11);
    der(x13) = sinh(x13);
    der(x14) = cosh(x14);
    der(x15) = tanh(x15);
    der(x16) = exp(x16);
    der(x17) = log(x17);
    der(x18) = log10(x18);
    der(x19) = -x18;
end AtomicModelElementaryFunctions;


model AtomicModelBooleanExpressions
    Real x1;
    Boolean x2;
    Boolean x3;
    Boolean x4;
    Boolean x5;
    Boolean x6;
    Boolean x7;
    Boolean x8;
    Boolean x9;
equation
    der(x1) = if(x2) then 1 else 2;
    x2 = x1 > 0;
    x3 = x1 >= 0;
    x4 = x1 < 0;
    x5 = x1 <= 0;
    x6 = x5 == x4;
    x7 = x6 <> x5;
    x8 = x6 and x5;
    x9 = x6 or x5;
end AtomicModelBooleanExpressions;

model AtomicModelMisc
    Real x1;
    Integer x2;
    Boolean x3;
    Boolean x4;
equation
    der(x1) = 1.11;
    x2 = if (x1 > 1) then 3 else 4;
    x3 = true or (x2 > 1);
    x4 = false or x3;
end AtomicModelMisc;

model AtomicModelVariableLaziness
    Real x1;
    Real x2;
equation
    der(x1) = x2;
    der(x2) = x1;
end AtomicModelVariableLaziness;


model AtomicModelAtomicRealFunctions

    function monoInMonoOut
        input Real x;
        output Real y;
    algorithm
        y := x;
    end monoInMonoOut;
    
    function polyInMonoOut
        input Real x1;
        input Real x2;
        output Real y;
    algorithm
        y := x1+x2;
    end polyInMonoOut;
    
    function monoInMonoOutInternal
        input Real x;
        Real internal;
        output Real y;
    algorithm
        internal := sin(x);
        y := x*internal;
        internal := sin(y);
        y := x + internal;
    end monoInMonoOutInternal;

    function monoInPolyOut
        input Real x;
        output Real y1;
        output Real y2;
    algorithm
        y1 := if(x > 2) then 1 else 5;
        y2 := x;
    end monoInPolyOut;

    function polyInPolyOut
        input Real x1;
        input Real x2;
        output Real y1;
        output Real y2;
    algorithm
        y1 := x1;
        y2 := x2;
    end polyInPolyOut;

    function polyInPolyOutInternal
        input Real x1;
        input Real x2;
        Real internal1;
        Real internal2;
        output Real y1;
        output Real y2;
    algorithm
        internal1 := x1;
        internal2 := x2 + internal1;
        y1 := internal1;
        y2 := internal2 + x1;
        y2 := 1;
    end polyInPolyOutInternal;

    function monoInMonoOutReturn
        input Real x;
        output Real y;
    algorithm
        y := x;
        return;
        y := 2*x;
    end monoInMonoOutReturn;

    function functionCallInFunction
        input Real x;
        output Real y;
    algorithm
        y := monoInMonoOut(x);
    end functionCallInFunction;
    
    function functionCallEquationInFunction
        input Real x;
        Real internal;
        output Real y;
    algorithm
        (y,internal) := monoInPolyOut(x);
    end functionCallEquationInFunction;

    Real x1;
    Real x2;
    Real x3;
    Real x4;
    Real x5;
    Real x6;
    Real x7;
    Real x8;
    Real x9;
    Real x10;
    Real x11;
    Real x12;
equation
    der(x1) = sin(monoInMonoOut(x1));
    der(x2) = polyInMonoOut(x1,x2);
    (x3,x4) = monoInPolyOut(x2);
    (x5,x6) = polyInPolyOut(x1,x2);
    der(x7) = monoInMonoOutReturn(x7);
    der(x8) = functionCallInFunction(x8);
    der(x9) = functionCallEquationInFunction(x9);
    der(x10) = monoInMonoOutInternal(x10);
    (x11,x12) = polyInPolyOutInternal(x9,x10);
end AtomicModelAtomicRealFunctions;


model AtomicModelAtomicIntegerFunctions
    function monoInMonoOut
        input Integer x;
        output Integer y;
    algorithm
        y := x;
    end monoInMonoOut;
    
    function polyInMonoOut
        input Integer x1;
        input Integer x2;
        output Integer y;
    algorithm
        y := x1+x2;
    end polyInMonoOut;
    
    function monoInMonoOutInternal
        input Integer x;
        Integer internal;
        output Integer y;
    algorithm
        internal := 3*x;
        y := x*internal;
        internal := 1+y;
        y := x + internal;
    end monoInMonoOutInternal;

    function monoInPolyOut
        input Integer x;
        output Integer y1;
        output Integer y2;
    algorithm
        y1 := if(x > 2) then 1 else 5;
        y2 := x;
    end monoInPolyOut;

    function polyInPolyOut
        input Integer x1;
        input Integer x2;
        output Integer y1;
        output Integer y2;
    algorithm
        y1 := x1;
        y2 := x2;
    end polyInPolyOut;

    function polyInPolyOutInternal
        input Integer x1;
        input Integer x2;
        Integer internal1;
        Integer internal2;
        output Integer y1;
        output Integer y2;
    algorithm
        internal1 := x1;
        internal2 := x2 + internal1;
        y1 := internal1;
        y2 := internal2 + x1;
        y2 := 1;
    end polyInPolyOutInternal;

    function monoInMonoOutReturn
        input Integer x;
        output Integer y;
    algorithm
        y := x;
        return;
        y := 2*x;
    end monoInMonoOutReturn;

    function functionCallInFunction
        input Integer x;
        output Integer y;
    algorithm
        y := monoInMonoOut(x);
    end functionCallInFunction;
    
    function functionCallEquationInFunction
        input Integer x;
        Integer internal;
        output Integer y;
    algorithm
        (y,internal) := monoInPolyOut(x);
    end functionCallEquationInFunction;

    input Integer u1;
    input Integer u2;
    Integer x1 (start = 2);
    Integer x2;
    Integer x3;
    Integer x4;
    Integer x5;
    Integer x6;
    Integer x7;
    Integer x8;
    Integer x9;
    Integer x10;
    Integer x11;
    Integer x12;
equation
    x1 = monoInMonoOut(u1);
    x2 = polyInMonoOut(u1,u2);
    (x3,x4) = monoInPolyOut(u2);
    (x5,x6) = polyInPolyOut(u1,u2);
    x7 = monoInMonoOutReturn(u1);
    x8 = functionCallInFunction(u2);
    x9 = functionCallEquationInFunction(u1);
    x10 = monoInMonoOutInternal(u2);
    (x11,x12) = polyInPolyOutInternal(u1,u2);
end AtomicModelAtomicIntegerFunctions;

model AtomicModelAtomicBooleanFunctions
    function monoInMonoOut
        input Boolean x;
        output Boolean y;
    algorithm
        y := x;
    end monoInMonoOut;
    
    function polyInMonoOut
        input Boolean x1;
        input Boolean x2;
        output Boolean y;
    algorithm
        y := x1 and x2;
    end polyInMonoOut;
    
    function monoInMonoOutInternal
        input Boolean x;
        Boolean internal;
        output Boolean y;
    algorithm
        internal := x;
        y := x and internal;
        internal := false or y;
        y := false or internal;
    end monoInMonoOutInternal;

    function monoInPolyOut
        input Boolean x;
        output Boolean y1;
        output Boolean y2;
    algorithm
        y1 := if(x) then false else (x or false);
        y2 := x;
    end monoInPolyOut;

    function polyInPolyOut
        input Boolean x1;
        input Boolean x2;
        output Boolean y1;
        output Boolean y2;
    algorithm
        y1 := x1;
        y2 := x2;
    end polyInPolyOut;

    function polyInPolyOutInternal
        input Boolean x1;
        input Boolean x2;
        Boolean internal1;
        Boolean internal2;
        output Boolean y1;
        output Boolean y2;
    algorithm
        internal1 := x1;
        internal2 := x2  or internal1;
        y1 := internal1;
        y2 := internal2 or x1;
        y2 := true;
    end polyInPolyOutInternal;

    function monoInMonoOutReturn
        input Boolean x;
        output Boolean y;
    algorithm
        y := x;
        return;
        y := x or false;
    end monoInMonoOutReturn;

    function functionCallInFunction
        input Boolean x;
        output Boolean y;
    algorithm
        y := monoInMonoOut(x);
    end functionCallInFunction;
    
    function functionCallEquationInFunction
        input Boolean x;
        Boolean internal;
        output Boolean y;
    algorithm
        (y,internal) := monoInPolyOut(x);
    end functionCallEquationInFunction;

    input Boolean u1;
    input Boolean u2;
    Boolean x1 (start = false);
    Boolean x2;
    Boolean x3;
    Boolean x4;
    Boolean x5;
    Boolean x6;
    Boolean x7;
    Boolean x8;
    Boolean x9;
    Boolean x10;
    Boolean x11;
    Boolean x12;
equation
    x1 = monoInMonoOut(u1);
    x2 = polyInMonoOut(u1,u2);
    (x3,x4) = monoInPolyOut(u2);
    (x5,x6) = polyInPolyOut(u1,u2);
    x7 = monoInMonoOutReturn(u1);
    x8 = functionCallInFunction(u2);
    x9 = functionCallEquationInFunction(u1);
    x10 = monoInMonoOutInternal(u2);
    (x11,x12) = polyInPolyOutInternal(u1,u2);
end AtomicModelAtomicBooleanFunctions;


  //// Equations ////
model AtomicModelSimpleEquation
    Real x1;
equation
    der(x1) = x1;
end AtomicModelSimpleEquation;

model AtomicModelSimpleInitialEquation
    Real x1(start = 1);
equation
    der(x1) = x1;
end AtomicModelSimpleInitialEquation;

model AtomicModelFunctionCallEquation
    function f
        input Real x;
        output Real y1;
        output Real y2;
    algorithm
        y1 := 1;
        y2 := x;
    end f;

    Real x1;
    Real x2;
    Real x3;
equation
    der(x1) = x1;
    (x2,x3) = f(x1);
end AtomicModelFunctionCallEquation;


  ////// Attributes //////
  
model AtomicModelAttributeBindingExpression
    parameter Real  p1 = 2;
    parameter Real  p2 = p1;
equation
end AtomicModelAttributeBindingExpression;

model AtomicModelAttributeUnit
    Real x1(start=0.0005, unit = "kg");
equation
    der(x1) = log10(x1);
end AtomicModelAttributeUnit;

model AtomicModelAttributeQuantity
    Real x1(start=0.0005, quantity = "kg");
equation
    der(x1) = log10(x1);
end AtomicModelAttributeQuantity;

model AtomicModelAttributeDisplayUnit
    Real x1(start=0.0005, displayUnit = "kg");
equation
    der(x1) = log10(x1);
end AtomicModelAttributeDisplayUnit;

model AtomicModelAttributeMin
    Real x1(start=0.0005, min = 0.0);
equation
    der(x1) = log10(x1);
end AtomicModelAttributeMin;

model AtomicModelAttributeMax
    Real x1(start=0.0005, max = 100.0);
equation
    der(x1) = log10(x1);
end AtomicModelAttributeMax;

model AtomicModelAttributeStart
    Real x1(start=0.0005);
equation
    der(x1) = log10(x1);
end AtomicModelAttributeStart;
  
model AtomicModelAttributeFixed
    Real x1(start=0.0005, fixed = true);
equation
    der(x1) = log10(x1);
end AtomicModelAttributeFixed;

model AtomicModelAttributeNominal
    Real x1(start=0.0005, nominal = 0.1);
equation
    der(x1) = log10(x1);
end AtomicModelAttributeNominal;

model AtomicModelAttributeStateSelect
    Real x1(start=0.0005, stateSelect = StateSelect.default);
equation
    der(x1) = log10(x1);
end AtomicModelAttributeStateSelect;

model AtomicModelLt
    Boolean x1(start = true);
    input Real u(start = 10);
equation
    x1 = u < 2;
end AtomicModelLt;
  
model AtomicModelLeq
    Real x1(start = 3);
    input Real u(start = 10);
equation
    der(x1) = if(x1 <= 1) then 0.3 else u;
end AtomicModelLeq;
  
model AtomicModelGt
    Real x1(start = 3);
    input Real u(start = 10);
equation
    der(x1) = if(x1 > 1) then 0.3 else u;
end AtomicModelGt;
  
model AtomicModelGeq
    Real x1(start = 3);
    input Real u(start = 10);
equation
    der(x1) = if(x1 >= 1) then 0.3 else u;
end AtomicModelGeq;
  
model AtomicModelAnd
    Real x1(start = 3);
    input Real u(start = 10);
equation
    der(x1) = if((x1 < 1) and true) then 0.3 else u;
end AtomicModelAnd;
  
model AtomicModelOr
    Real x1(start = 3);
    input Real u(start = 10);
equation
    der(x1) = if((x1 < 1) or true) then 0.3 else u;
end AtomicModelOr;
  
model AtomicModelIf
    Real x1(start = 3);
    input Real u(start = 10);
equation
    der(x1) = if(x1 <> 1) then 0.3 else u;
end AtomicModelIf;
  
model AtomicModelComment
    Real x1(start = 3) "I am x1's comment";
equation
    der(x1) = -x1;
end AtomicModelComment;

type Voltage = Real(quantity="ElectricalPotential", unit="V");
model AtomicModelDerivedRealTypeVoltage 
    Voltage v(start=1.9);
equation
    der(v) = -sin(v);
end AtomicModelDerivedRealTypeVoltage;
  
type Steps = Integer(quantity="steps");
model AtomicModelDerivedIntegerTypeSteps
    parameter Steps v = 2;
end AtomicModelDerivedIntegerTypeSteps;

type IsDone = Boolean(quantity="Done");
model AtomicModelDerivedBooleanTypeIsDone
    parameter IsDone p = false;
end AtomicModelDerivedBooleanTypeIsDone;
  
model AtomicModelDerivedTypeAndDefaultType 
    Voltage v(start=1.9);
    Real x1;
equation
    der(v) = -sin(v);
    der(x1) = - x1;
end AtomicModelDerivedTypeAndDefaultType;


model AtomicModelIfEquation1
    Real x(start=1);
    Real u(start=2);
equation
    u = if time<=Modelica.Constants.pi /2 then sin(time) elseif
    time<= Modelica.Constants.pi  then 1 else sin(time -Modelica.Constants.pi /2);
    der(x) = u ;
end AtomicModelIfEquation1;
  
  
  ////// Variable kinds ////////
  // Real
model atomicModelRealConstant 
    constant Real pi = 3.14;
equation
    
end atomicModelRealConstant;
  
model atomicModelRealIndependentParameter 
    parameter Real pi = 3.14;
equation
    
end atomicModelRealIndependentParameter;
  
model atomicModelRealDependentParameter 
    parameter Real pi = 3.14;
    parameter Real pi2 = 2*pi;
equation
    
end atomicModelRealDependentParameter;
  
model atomicModelRealDerivative 
   Real x1(start=1.0, fixed = true);
equation
    der(x1) = -x1;
end atomicModelRealDerivative;
  
model atomicModelRealDifferentiated
   Real x1(start=1.0, fixed = true);
equation
    der(x1) = -x1;
end atomicModelRealDifferentiated;
  
model atomicModelRealInput
   input Real  x1;
equation
end atomicModelRealInput;

model atomicModelRealOutput
   output Real  x1 = 2;
equation
end atomicModelRealOutput;
  
model atomicModelRealAlgebraic
    Real x1 (start = 0.5);
equation
    x1 = sin(x1);
end atomicModelRealAlgebraic;
  
model atomicModelRealDiscrete
    discrete Real  x1 (start = 1);
equation
    x1 = if(time>1.0) then 1 else 2;
end atomicModelRealDiscrete;
  
  
  // Integer
model atomicModelIntegerConstant 
    constant Integer pi = 3;
equation
    
end atomicModelIntegerConstant;
  
model atomicModelIntegerIndependentParameter 
    parameter Integer pi = 3;
equation
    
end atomicModelIntegerIndependentParameter;
  
model atomicModelIntegerDependentParameter 
    parameter Integer pi = 3;
    parameter Integer pi2 = 2*pi;
equation
    
end atomicModelIntegerDependentParameter;
  
model atomicModelIntegerDiscrete
    Integer x1;
equation
    x1 = if(time > 1) then 2 else 3;
end atomicModelIntegerDiscrete;
  
model atomicModelIntegerInput
    input Integer x1;
equation
    
end atomicModelIntegerInput;
  
  // Boolean
model atomicModelBooleanConstant 
    constant Boolean pi = true;
equation
    
end atomicModelBooleanConstant;
  
model atomicModelBooleanIndependentParameter 
    parameter Boolean pi = true;
equation
    
end atomicModelBooleanIndependentParameter;
  
model atomicModelBooleanDependentParameter 
    parameter Boolean pi = true;
    parameter Boolean pi2 = pi and true;
equation
    
end atomicModelBooleanDependentParameter;

model atomicModelBooleanDiscrete
    Boolean x1;
equation
    x1 = if(time > 1) then true else false;
end atomicModelBooleanDiscrete;
  
model atomicModelBooleanInput
    input Boolean x1;
equation
    
end atomicModelBooleanInput;

model AtomicModelVector1
    Real A[2] (start={1,2});
    function f
        input Real A[2];
        output Real B[2];
    algorithm
        B := - A;
  end f;
equation
    der(A)  = f(A);
end  AtomicModelVector1;
  
model AtomicModelVector2
    Real A[2] (start={1,2});
    function f
        input Real A[2];
        output Real B[2];
    algorithm
        B :=  f2(A);
  end f;
    function f2
        input Real A[2];
        output Real B[2];
    algorithm
        B := - A;
  end f2;
equation
    der(A)  = f(A);
end  AtomicModelVector2;
  
model AtomicModelVector3
    Real A[2] (start={1,2});
    function f
        input Real A[2];
        input Real inParams[2];
        output Real B[2];
        output Real outParams[2];
    algorithm
        B :=  -A;
        outParams := inParams*2;
  end f;
    Real B[2] (start = {20, 1});
equation
    (A,B) = f(A,{1,2});
end  AtomicModelVector3;
  
model AtomicModelMatrix
    Real A[1,2] (start={{1,2}});
    Real X[2,1] = {{0.1},{0.3}};
    Real dx[2,2] (start={{1,2},{4,5}});
    function f
        input Real A[1,2];
        input Real X[2,1];
        output Real B[1,2];
        Real B_i1[2,1];
        Real B_i2[2,2];
    algorithm
        B := A;
        B_i1 := X;
        B[1,1] := B_i1[1,1];
        B_i2 := f2({{1,2},{3,4}});
        B[1,2] := B_i1[2,1];
  end f;
    function f2 
        input Real[2,2] A;
        output Real[2,2] B;
    algorithm
        B := - A;
  end f2;
equation
    der(A)  = -f(A,X);
    der(dx) = -f2(dx);
end  AtomicModelMatrix;
  
model AtomicModelLargerThanTwoDimensionArray
    Real A[1,2,3] (start=  { {{1,2,3}, {4,5,6}} } );
    function f
        input Real A[1,2,3];
        output Real[1,2,3] B;
    algorithm
        B:= -A;
        B[1,2,3] := 10;
  end f;
equation
    der(A)  = f(A);
end  AtomicModelLargerThanTwoDimensionArray;

model atomicModelSimpleArrayIndexing
    function f 
        output Real out[2,2];
    algorithm
        out[1,1] := 1;
        out[1,2] := 2; 
        out[2,1] := 3;
        out[2,2] := 4;
    end f;
    parameter Real A[2,2] = f();
end atomicModelSimpleArrayIndexing;

model AtomicModelRecordSeveralVars
    record Rec1
        Real A;
        Real B;
    end Rec1;
    
    record Rec2
        Rec1 r1;
        Rec1[2] rArr;
        Real[2,2] matrix;
    end Rec2;
    
    function f
       input Real num;
       output Rec2 out;
    algorithm
       out := Rec2(Rec1(1,2),{Rec1(3,4),Rec1(5,6)},{{7,8},{9,num}});
    end f;

    Rec2 r;
    Real a (start = 1);
equation
    der(a) = -a;
    r = f(a);
end AtomicModelRecordSeveralVars;

model AtomicModelRecordArbitraryDimension
    record Rec1
        Real[2,2,2] A;
    end Rec1;
    
    
    function f
       input Real num;
       output Rec1 out;
    algorithm
       out := Rec1({ { {1,2}, {3,4} } , { {5,6},{num, num*2} } });
    end f;

    Rec1 r;
    Real a (start = 1);
equation
    der(a) = -a;
    r = f(a);
end AtomicModelRecordArbitraryDimension;


model AtomicModelRecordInOutFunctionCallStatement
    record Rec1
        Real[2] A;
    end Rec1;
    
    record Rec2
        Real A;
        Real B;
    end Rec2;
    
    
    function f1
       input Real num;
       output Real out;
       Rec2 r2;
    algorithm
       r2 := f2(Rec1({num, num+2}));
       out := r2.A*r2.B;
    end f1;
    
    function f2
       input Rec1 r1;
       output Rec2 out;
    algorithm
       out := Rec2(r1.A[1], r1.A[2]*10);
    end f2;

    Real a (start = 1);
equation
    der(a) = -f1(a);
end AtomicModelRecordInOutFunctionCallStatement;
    
    
model AtomicModelRecordNestedArray
    record Complex 
        Real[2] point;
    end Complex;
    
    record ComplexPath
        Complex[2] path;
    end ComplexPath;
    
    record ComplexCurves
        ComplexPath[2] curves;
    end ComplexCurves;
    
    function generateCurves 
        input Real t;
        output ComplexCurves cc;
        Real[2] point1 = {0,t};
        Real[2] point2 = {2,3};
        Real[2] point3 = {4,5};
        Real[2] point4 = {6,7};
        Complex c1;
        Complex c2;
        Complex c3;
        Complex c4;
        ComplexPath cp1;
        ComplexPath cp2;
    algorithm
        c1.point := point1;
        c2.point := point2; 
        c3.point := point3;
        c4.point := point4; 
        cp1.path := {c1,c2};
        cp2.path := {c4,c2};
        cc.curves := {cp1,cp2};
    end generateCurves;
    
    ComplexCurves compCurve;
    Real a;
equation
    compCurve = generateCurves(a);
    der(a) = compCurve.curves[1].path[1].point[2];
end AtomicModelRecordNestedArray;

model atomicModelDependentParameter
    parameter Real p1 = 10;
    parameter Real p2 = p1*2;
    parameter Real p3 = p1*p2;
    parameter Real p4 = f(p1);

    function f
        input Real inVar;
        output Real outVar;
    algorithm
        outVar := inVar*2;
    end f;
    
    equation

end atomicModelDependentParameter;

model atomicModelPolyOutFunctionCallForDependentParameter
    function f
        input Real x;
        output Real[2] y;
    algorithm
        y := {x, x*x};
    end f;
    parameter Real p1 = 2;
    parameter Real[2] p2 = f(p1);
end atomicModelPolyOutFunctionCallForDependentParameter;

model atomicModelFunctionCallEquationIgnoredOuts
    
    function f
        input Real in1;
        input Real in2;
        output Real out1;
        output Real out2;
        output Real out3;
        output Real out4;
        
    algorithm
        out1 := in1+1;
        out2 := in2+1;
        out3 := in1+in2;
        out4 := 100;
    end f;
    Real x1 (start=1);
    Real x2 (start=2);
    Real x3 (start=2);

    equation
        der(x2) = x1+x2;
        (x1,,x2,) = f(1,x3);
end atomicModelFunctionCallEquationIgnoredOuts;

model atomicModelFunctionCallStatementIgnoredOuts
    
    function f
        input Real in1;
        input Real in2;
        output Real out1;
        output Real out2;
        output Real out3;
        
    algorithm
        out1 := in1+1;
        out2 := in2+1;
        out3 := in1+in2;
    end f;
    
    function f2
        input Real in1;
        output Real out1;
        Real internal1;
        Real internal2;
    algorithm
        internal2 := in1;
        (internal1, , out1) := f(10, internal2);
    end f2;
        
    Real x1 (start=1);
    
    equation
        x1 = f2(x1);
end atomicModelFunctionCallStatementIgnoredOuts;

model atomicModelFunctionCallStatementIgnoredArrayRecordOuts

    record Complex 
        Real[2] point;
    end Complex;
    
    function f
        input Real in1;
        input Real in2;
        output Complex out1;
        output Real out2;
        output Real[2] out3;
        output Real[2] out4;
        output Real out5;
        
    algorithm
        out1 := Complex({in1+1, in2});
        out2 := in2+1;
        out3 := {in1, in2};
        out4 := {in1, in2+ 2};
        out5 := in2 - 2;
    end f;
    
    function f2
        input Real in1;
        output Complex out1;
        output Real out2;
        output Real[2] out3;
        output Real out4;
    algorithm
        (out1, out2 , , out3, out4) := f(10, in1);
    end f2;
        
    Real x1 (start=1);
    Real x2 (start=2);
    
    equation
        (, x1, , x2) = f2(x1);
end atomicModelFunctionCallStatementIgnoredArrayRecordOuts;



model atomicModelAlias
    Real x;
    Real y;
    Real z;
equation
    der(x) = -2;
    y = x;
    z = -y;
end atomicModelAlias;

model atomicModelTime
    Real x;
    Real y (start=2);
equation
    der(x) = time;
    der(y) = time + 2;
end atomicModelTime;

package identifierTest

    model identfierTestModel 
        Real a = 1;
    end identfierTestModel;

end identifierTest;


model simpleModelWithFunctions
    Real a1(start=0.1, fixed=true);
    Real a2(start=0.4, fixed=true);
    Real b1(start=-1.0);
    Real b2(start=1.0);
    function f
        input Real in1;
        input Real in2;
        output Real out1;
        output Real out2;
        Real internal;
    algorithm
        (out1, out2) := f2(in1,in2);
        internal := out1;
        out2 := out2-internal;
        out1 := out1*2.0;
        (out1, out2) := f2(in1,in2);
    end f;
    function f2
        input Real in1;
        input Real in2;
        output Real out1;
        output Real out2;
    algorithm
        out1 := in1*0.5;
        out2 := in2+out1;
    end f2;
equation
    der(a1) = -3.14*a1-0.1-b2;
    der(a2) = -2.7*a2-0.3;
    (b1, b2) = f(a1,a2);
end simpleModelWithFunctions;

model ParameterIndexing1

Real x[N];

final parameter Integer index = max(1, max_index);
      parameter Integer max_index = 1;
      parameter Integer N(min=1)=2;
equation

x[index] = 0;
x[index+1] = 2;
end ParameterIndexing1;
